package org.oztrack.controller;

import au.com.bytecode.opencsv.CSVWriter;
import org.oztrack.data.access.*;
import org.oztrack.data.model.*;
import org.oztrack.data.model.types.MapLayerType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@Controller
public class ProjectTemporalAnalysisController {

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private AnimalDao animalDao;

    @Autowired
    private PositionFixDao positionFixDao;

    @Autowired
    private OzTrackPermissionEvaluator permissionEvaluator;

    @InitBinder("project")
    public void initProjectBinder(WebDataBinder binder) {
        binder.setAllowedFields();
    }

    @ModelAttribute("project")
    public Project getProject(@PathVariable(value = "id") Long projectId) {
        return projectDao.getProjectById(projectId);
    }

    @RequestMapping(value = "/projects/{id}/temporal", method = RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'read')")
    public String getView(
            Authentication authentication,
            HttpServletRequest request,
            Model model,
            @ModelAttribute(value = "project") Project project
    ) {
        List<Animal> projectAnimalsList = animalDao.getAnimalsByProjectId(project.getId());
        model.addAttribute("mapLayerTypeList", MapLayerType.values());
        model.addAttribute("projectAnimalsList", projectAnimalsList);
        model.addAttribute("projectBoundingBox", projectDao.getBoundingBox(project, false));
        model.addAttribute("animalBoundingBoxes", projectDao.getAnimalBoundingBoxes(project, false));
        model.addAttribute("projectDetectionDateRange", projectDao.getDetectionDateRange(project, false));
        User currentUser = permissionEvaluator.getAuthenticatedUser(authentication);
        HttpSession currentSession = request.getSession(false);
        String currentSessionId = (currentSession != null) ? currentSession.getId() : null;
        return "project-temporal-analysis";
    }

    @RequestMapping(value="/projects/{id}/posfixstats", method=RequestMethod.GET, produces="text/csv")
    @PreAuthorize("hasPermission(#project, 'read')")
    public void handleCsvRequest( HttpServletResponse response, @ModelAttribute(value="project") Project project) throws IOException  {
        response.setHeader("Content-Disposition", "attachment; filename=\"posfixstats.csv\"");
        CSVWriter writer = new CSVWriter(response.getWriter());
        String [] headers = { "animal_id","detectiontime","detection_index","displacement","cumulative_distance"};
        writer.writeNext(headers);
        List<Object[]> resultList = positionFixDao.getProjectPositionFixStats(project.getId());
        for (Object[] o : resultList) {
            String [] s = new String[o.length];
            for (int i=0; i < o.length; i++) {
                s[i] = o[i].toString();
            }
            writer.writeNext(s);
        }
        writer.close();
    }
}