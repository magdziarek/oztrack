package org.oztrack.controller;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.DoiDao;
import org.oztrack.data.access.PositionFixDao;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.model.*;
import org.oztrack.data.model.types.DoiChecklist;
import org.oztrack.data.model.types.DoiStatus;
import org.oztrack.data.model.types.ProjectAccess;
import org.oztrack.view.DoiResourceManager;
import org.oztrack.util.EmailBuilder;
import org.oztrack.util.EmailBuilderFactory;
import org.oztrack.view.DoiPackageBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.util.*;

@Controller
public class DoiController {

    private final Logger logger = Logger.getLogger(getClass());

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private DoiDao doiDao;

    @Autowired
    private PositionFixDao positionFixDao;

    @Autowired
    private OzTrackPermissionEvaluator permissionEvaluator;

    @Autowired
    private OzTrackConfiguration configuration;

    @ModelAttribute("project")
    public Project getProject(@PathVariable(value="projectId") Long projectId) {
        return projectDao.getProjectById(projectId);
    }

    @RequestMapping(value="/projects/{projectId}/doi", method= RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'manage')")
    public String getManageView(
            Model model,
            @ModelAttribute(value="project") Project project
    ) {
        String view;
        Doi doiInProgress = doiDao.getInProgressDoi(project);        // is there a draft doi?

        if (doiInProgress == null) {
            view = "doi-checklist";
            HashMap<DoiChecklist, Boolean> doiChecklistMap = checkDoiChecklist(project);
            model.addAttribute("doiChecklistMap", doiChecklistMap);
        } else {
            view = "doi-manage";
            model.addAttribute("doi", doiInProgress);
        }
        return view;
    }

    @RequestMapping(value="/projects/{projectId}/doi/file", method=RequestMethod.GET, produces={ "application/zip"})
    @PreAuthorize("hasPermission(#project, 'manage')")
    public void getDoiZip(
            @ModelAttribute(value="project") Project project,
            HttpServletResponse response
    ) throws Exception {
        //Doi doiInProgress = doiDao.getInProgressDoi(project);
        response.setHeader("Content-Disposition", "attachment; filename=ZoaTrack.zip");
        response.setContentType("application/zip");
        response.setCharacterEncoding("UTF-8");
        FileInputStream fileInputStream = new FileInputStream(project.getAbsoluteDataDirectoryPath() + File.separator + "ZoaTrack.zip");
        IOUtils.copy(fileInputStream, response.getOutputStream());

    }

    @RequestMapping(value="/projects/{projectId}/doi/new", method= RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'manage')")
    public String buildPackage(
            Authentication authentication,
            Model model,
            @ModelAttribute(value="project") Project project
    ) {

        logger.info("DOI Package Build request from project " + project.getId());
        User currentUser = permissionEvaluator.getAuthenticatedUser(authentication);
        Doi doiInProgress = doiDao.getInProgressDoi(project);   // is there one in progress?
        Doi doi = (doiInProgress != null) ? doiInProgress : new Doi();

        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        UUID uuid = UUID.randomUUID();
        doi.setUuid(uuid);
        doi.setUrl(configuration.getDoiLandingBaseUrl() + "/" + uuid);
        doi.setProject(project);
        doi.setStatus(DoiStatus.DRAFT);
        doi.setCreateUser(currentUser);
        doi.setUpdateUser(currentUser);
        doi.setPublished(false);
        // Citation example e.g
        //Campbell, H, Dwyer, R, Franklin, C (2014) Data from: 'Tracking estuarine crocodiles on
        // Cape York Peninsula using GPS-based telemetry'. ZoaTrack.org.
        // doi: http://dx.doi.org/10.4225/01/XXXXXXXXXXXXXXXX
        doi.setCitation(getAuthorList(project, "citation") + "(" + Calendar.getInstance().get(Calendar.YEAR) + ") Data from: '"
                + project.getTitle() + "'. ZoaTrack.org. doi: ");
        doi.setTitle(project.getTitle());
        doi.setCreators(this.getAuthorList(project, "fullNames"));

        DoiResourceManager doiResourceManager = new DoiResourceManager(project);
        doiResourceManager.buildDoiResource();
        doi.setXml(doiResourceManager.marshallDoiResource());

        SearchQuery searchQuery = new SearchQuery();
        searchQuery.setProject(project);
        searchQuery.setIncludeDeleted(true);
        List<PositionFix> positionFixes = positionFixDao.getProjectPositionFixList(searchQuery);

        Calendar createDate = Calendar.getInstance();
        createDate.setTime(new java.util.Date());
        doi.setDraftDate(createDate.getTime());
        doi.setCreateDate(createDate.getTime());
        doi.setUpdateDate(createDate.getTime());
        DoiPackageBuilder packageBuilder = new DoiPackageBuilder(doi, positionFixes);
        packageBuilder.buildZip();
        //doi.setFilename(packageBuilder.buildZip());

        doiDao.save(doi);
        model.addAttribute("doi", doi);

        // check this went well
        File file = new File(project.getAbsoluteDataDirectoryPath() + File.separator + "ZoaTrack.zip");
        if (!file.exists()) {
            model.addAttribute("errorMessage","There was an error generating the package. Please contact the administrator.");
        }
        return "redirect:/projects/" + project.getId() + "/doi";
    }

    @RequestMapping(value="/projects/{projectId}/doi/delete", method= RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'manage')")
    public String deletePackage(
            Authentication authentication,
            Model model,
            @ModelAttribute(value="project") Project project
    ) {
        Doi doiInProgress = doiDao.getInProgressDoi(project);
        DoiPackageBuilder packageBuilder = new DoiPackageBuilder(doiInProgress);
        String view = "redirect:/projects/" + project.getId() + "/doi";

        if (doiInProgress.getStatus() == DoiStatus.DRAFT) {

            packageBuilder.deletePackage();
            doiDao.delete(doiInProgress);
        } else {
            model.addAttribute("errorMessage", "You can only delete a DOI Request in DRAFT phase.");
            view = "doi-manage";
        }
        return view;
    }

    @RequestMapping(value="/projects/{projectId}/doi/cancel", method= RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'manage')")
    public String cancelRequest(
            Authentication authentication,
            Model model,
            @ModelAttribute(value="project") Project project
    ) {
        Doi doiInProgress = doiDao.getInProgressDoi(project);
        doiInProgress.setStatus(DoiStatus.DRAFT);
        doiInProgress.setCancelDate(new java.util.Date());
        doiInProgress.setUpdateDate(new java.util.Date());
        doiInProgress.setUpdateUser(this.permissionEvaluator.getAuthenticatedUser(authentication));
        doiDao.update(doiInProgress);
        return "redirect:/projects/" + project.getId() + "/doi";
    }

    @RequestMapping(value="/projects/{projectId}/doi/request", method= RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'manage')")
    public String requestDOI(
            Authentication authentication,
            Model model,
            @ModelAttribute(value="project") Project project
    ) {
        Doi doiInProgress = doiDao.getInProgressDoi(project);
        User currentUser = permissionEvaluator.getAuthenticatedUser(authentication);
        doiInProgress.setStatus(DoiStatus.REQUESTED);
        doiInProgress.setUpdateUser(currentUser);
        doiInProgress.setUpdateDate(new java.util.Date());
        doiInProgress.setSubmitDate(new java.util.Date());
        doiDao.update(doiInProgress);
        try {
            emailMintRequestToAdmin(doiInProgress, currentUser);
            logger.info("DOI Request submitted for project " + project.getId());
        } catch (Exception e) {
            logger.error("Mint request email to admin failed " + e.getLocalizedMessage());
        }
        return "redirect:/projects/" + project.getId() + "/doi";
    }

    private void emailMintRequestToAdmin(Doi doi, User currentUser) throws Exception {

        EmailBuilderFactory emailBuilderFactory = new EmailBuilderFactory();
        EmailBuilder emailBuilder = emailBuilderFactory.getObject();
        emailBuilder.to(doiDao.getAdminUsers().get(0));
        emailBuilder.subject("Request to Mint DOI");

        StringBuilder htmlMsgContent = new StringBuilder();
        htmlMsgContent.append("<p>\n");
        htmlMsgContent.append("    " + currentUser.getFullName() + " has requested a DOI for the project \n");
        htmlMsgContent.append("    <i>" + doi.getProject().getTitle() + "</i></p>\n");

        String projectLink = configuration.getBaseUrl() + "/projects/" + doi.getProject().getId();
        htmlMsgContent.append("<p>\n");
        htmlMsgContent.append("    To view the project, click here:\n");
        htmlMsgContent.append("    <a href=\"" + projectLink + "\">" + projectLink + "</a>\n");
        htmlMsgContent.append("</p>\n");

        htmlMsgContent.append("<p>\n");
        htmlMsgContent.append("    To mint the DOI, go to the Admin screen:\n");
        htmlMsgContent.append("    <a href=\"" + configuration.getBaseUrl() + "\">settings/doi/" + doi.getId() + "/a>\n");
        htmlMsgContent.append("</p>\n");
        emailBuilder.htmlMsgContent(htmlMsgContent.toString());
        emailBuilder.build().send();
    }


    private HashMap<DoiChecklist, Boolean> checkDoiChecklist(Project project) {

        HashMap<DoiChecklist, Boolean> doiChecklistMap = new HashMap<DoiChecklist, Boolean>();
        boolean australianResearchCheck = false;
        List<ProjectContribution> contributions = project.getProjectContributions();
        Iterator contributionsIterator = contributions.iterator();
        // look for either an Australian institution or a .au email address
        while (contributionsIterator.hasNext()) {
            ProjectContribution projectContribution = (ProjectContribution) contributionsIterator.next();
            Person person = projectContribution.getContributor();
            List<Institution> institutionList = person.getInstitutions();
            Iterator institutionIterator = institutionList.iterator();
            while (institutionIterator.hasNext()) {
                Institution institution = (Institution) institutionIterator.next();
                if (institution.getCountry().getCode().equals("AU")) {
                    australianResearchCheck = true;
                }
            }
            if (person.getEmail() != null && person.getEmail().endsWith("au")) {
                australianResearchCheck = true;
            }
            if (person.getCountry() != null && person.getCountry().getCode().equals("AU")) {
                australianResearchCheck = true;
            }
        }

        doiChecklistMap.put(DoiChecklist.AUTHORS, project.getProjectContributions().size() > 0);
        doiChecklistMap.put(DoiChecklist.DATA, project.getAnimals().size() > 0);
        doiChecklistMap.put(DoiChecklist.LICENCE, (project.getDataLicence() != null && project.getAccess().equals(ProjectAccess.OPEN)));
        doiChecklistMap.put(DoiChecklist.RESEARCH, australianResearchCheck);
        return doiChecklistMap;

    }

    private String getAuthorList(Project project, String listType) {

        // listType = "fullNames" or "citation"
       List<ProjectContribution> projectContributionsList =  project.getProjectContributions();
        Iterator iterator = projectContributionsList.iterator();
        String authorList = "";
        while (iterator.hasNext()) {
            ProjectContribution projectContribution = (ProjectContribution) iterator.next();
            Person person = projectContribution.getContributor();
            if (listType.equals("citation")) {
                authorList = authorList + person.getLastName() + ", " + person.getFirstName().charAt(0);
            } else if (listType.equals("fullNames")){
                authorList = authorList + person.getFullName();
            }
                if (iterator.hasNext()) authorList = authorList + ", ";
            else authorList = authorList + " ";
        }
        return authorList;
    }
}
