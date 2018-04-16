package org.oztrack.controller;

import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import au.com.bytecode.opencsv.CSVWriter;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.client.utils.URIBuilder;
import org.apache.log4j.Logger;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.AnalysisDao;
import org.oztrack.data.access.AnimalDao;
import org.oztrack.data.access.PositionFixDao;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.access.ProjectVisitDao;
import org.oztrack.data.access.SrsDao;
import org.oztrack.data.model.*;
import org.oztrack.data.model.types.AnalysisType;
import org.oztrack.data.model.types.MapLayerType;
import org.oztrack.data.model.types.ProjectVisitType;
import org.oztrack.view.ProjectCitation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class ProjectAnalysisController {

    private final Logger logger = Logger.getLogger(getClass());

    @Autowired
    private OzTrackConfiguration configuration;

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private ProjectVisitDao projectVisitDao;

    @Autowired
    private AnalysisDao analysisDao;

    @Autowired
    private AnimalDao animalDao;

    @Autowired
    private PositionFixDao positionFixDao;

    @Autowired
    private SrsDao srsDao;

    @Autowired
    private OzTrackPermissionEvaluator permissionEvaluator;

    @InitBinder("project")
    public void initProjectBinder(WebDataBinder binder) {
        binder.setAllowedFields();
    }

    @ModelAttribute("project")
    public Project getProject(@PathVariable(value="id") Long projectId) {
        return projectDao.getProjectById(projectId);
    }

    @RequestMapping(value="/projects/{id}/analysis", method=RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'read')")
    public String getView(
        Authentication authentication,
        HttpServletRequest request,
        Model model,
        @ModelAttribute(value="project") Project project,
        @RequestParam(value="a", required=false) String action
    ) {
        projectVisitDao.save(new ProjectVisit(project, ProjectVisitType.ANALYSIS, new Date()));
        List<Animal> projectAnimalsList = animalDao.getAnimalsByProjectId(project.getId());
        model.addAttribute("mapLayerTypeList", MapLayerType.values());
        ArrayList<AnalysisType> analysisTypeList = new ArrayList<AnalysisType>();
        for (AnalysisType analysisType : AnalysisType.values()) {
            analysisTypeList.add(analysisType);
        }
        if (!StringUtils.isBlank(action)) {
            if (action.equals("temporal")) {
                model.addAttribute("temporal", true); }
            if (action.equals("bccvl-export")) {
                model.addAttribute("temporal", true);
                model.addAttribute("bccvlApiUrl", configuration.getBccvlApiUrl());
            }
        }
        model.addAttribute("analysisTypeList", analysisTypeList);
        model.addAttribute("projectAnimalsList", projectAnimalsList);
        model.addAttribute("projectBoundingBox", projectDao.getBoundingBox(project, false));
        model.addAttribute("animalBoundingBoxes", projectDao.getAnimalBoundingBoxes(project, false));
        model.addAttribute("projectDetectionDateRange", projectDao.getDetectionDateRange(project, false));
        model.addAttribute("googleApiKey", configuration.getGoogleApiKey());
        User currentUser = permissionEvaluator.getAuthenticatedUser(authentication);
        HttpSession currentSession = request.getSession(false);
        String currentSessionId = (currentSession != null) ? currentSession.getId() : null;
        model.addAttribute("savedAnalyses", analysisDao.getSavedAnalyses(project));
        model.addAttribute("previousAnalyses", analysisDao.getPreviousAnalyses(project, currentUser, currentSessionId));
        return "project-analysis.html";
    }

    @RequestMapping(value="/projects/{id}/analysis/posfixstats", method=RequestMethod.GET, produces="text/csv")
    @PreAuthorize("hasPermission(#project, 'read')")
    public void handlePosFixStatsCsvRequest(HttpServletResponse response, @ModelAttribute(value="project") Project project) throws IOException {
        response.setHeader("Content-Disposition", "attachment; filename=\"posfixstats.csv\"");
        CSVWriter csvWriter = new CSVWriter(response.getWriter());
        positionFixDao.writePositionFixStatsCsv(project.getId(), csvWriter);
        csvWriter.close();
    }

    @RequestMapping(value="/projects/{id}/analysis/posfixexport", method=RequestMethod.GET, produces="application/zip")
    @PreAuthorize("hasPermission(#project, 'read')")
    public void handlePosFixStatsExport(HttpServletRequest request, HttpServletResponse response, @ModelAttribute(value="project") Project project) throws IOException {
        projectVisitDao.save(new ProjectVisit(project, ProjectVisitType.DATA_DOWNLOAD, new Date()));
        handleExport(response, project, "posfix");
    }

    @RequestMapping(value="/projects/{id}/analysis/traitexport", method=RequestMethod.GET, produces={"application/zip"})
    @PreAuthorize("hasPermission(#project, 'read')")
    public void handleBccvlExport(HttpServletResponse response, @ModelAttribute(value="project") Project project) throws IOException {
        projectVisitDao.save(new ProjectVisit(project, ProjectVisitType.BCCVL_EXPORT, new Date()));
        handleExport(response, project, "traits");
    }

    //to distinguish bccvl
    @RequestMapping(value="/projects/{id}/analysis/traitdownload", method=RequestMethod.GET, produces={"application/zip"})
    @PreAuthorize("hasPermission(#project, 'read')")
    public void handleTraitsExport(HttpServletResponse response, @ModelAttribute(value="project") Project project) throws IOException {
        projectVisitDao.save(new ProjectVisit(project, ProjectVisitType.TRAIT_DATA_DOWNLOAD, new Date()));
        handleExport(response, project, "traits");
    }

    private void handleExport(HttpServletResponse response, Project project, String type) {

        try {
            String baseFileName = type.equals("traits") ? "trait" : "ZoaTrackPositionFixStats";
            File sysTempDirectory = new File(System.getProperty("java.io.tmpdir"));
            File tempDirectory = new File(sysTempDirectory, "export" + UUID.randomUUID().toString());
            tempDirectory.mkdir();
            File tempCsv = new File(tempDirectory, baseFileName + ".csv");
            File citationFile = new ProjectCitation(project).createCitationAndTermsFile(tempDirectory.getAbsolutePath() + File.separator);
            FileWriter fileWriter = new FileWriter(tempCsv);
            CSVWriter csvWriter = new CSVWriter(fileWriter);
            if (type.equals("traits")) {
                positionFixDao.writeTraitsCsv(project.getId(), csvWriter);
                FileWriter fileWriter1 = new FileWriter(citationFile,true); // true:append
                fileWriter1.write(positionFixDao.getTraitsDescr());
                fileWriter1.close();
            } else {
                positionFixDao.writePositionFixStatsCsv(project.getId(), csvWriter);
            }
            fileWriter.close();
            csvWriter.close();
            File zipFile = new File(tempDirectory, baseFileName + ".zip");
            zipFiles(zipFile, new File[]{tempCsv,citationFile});
            response.setHeader("Content-Disposition", "attachment; filename=\"" + baseFileName + ".zip\"");
            response.setContentType("application/zip");
            response.setCharacterEncoding("UTF-8");
            IOUtils.copy(new FileInputStream(zipFile), response.getOutputStream());
            zipFile.delete();
            tempDirectory.delete();
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void zipFiles(File zipFile,  File[] filesToAdd) throws IOException {
        FileOutputStream fileOutputStream = new FileOutputStream(zipFile);
        ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream);
        for (File f: filesToAdd) {
            ZipEntry zipEntry = new ZipEntry(f.getName());
            zipOutputStream.putNextEntry(zipEntry);
            IOUtils.copy(new FileInputStream(f), zipOutputStream);
            zipOutputStream.closeEntry();
            f.delete();
        }
        zipOutputStream.close();
        fileOutputStream.close();
    }

    @RequestMapping(value="/projects/{id}/analysis/bccvl-init", method=RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'read')")
    public ModelAndView redirectToBccvl(HttpServletRequest request, HttpServletResponse response, @ModelAttribute(value="project") Project project) throws URISyntaxException {

        String baseUrl = configuration.getBaseUrl().replace("http","https");
        URI uri = new URIBuilder()
                .setScheme("https")
                .setHost(configuration.getBccvlAuthUrl())
                .setParameter("client_id", configuration.getBccvlClientId())
                .setParameter("response_type", "token")
                .setParameter("redirect_uri", baseUrl + "/projects/" + project.getId() + "/analysis?a=bccvl-export")
                .build();

        logger.info(uri.toString());
        return new ModelAndView("redirect:" + uri.toString());
    }

}