package org.oztrack.controller;

import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.AnimalDao;

import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.access.ProjectVisitDao;
import org.oztrack.data.model.Animal;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.ProjectVisit;
import org.oztrack.data.model.types.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Controller
public class SimpleMapController {

    @Autowired
    private OzTrackConfiguration configuration;

    @Autowired
    private AnimalDao animalDao;

    @Autowired
    private ProjectVisitDao projectVisitDao;

    @Autowired
    private ProjectDao projectDao;

    @InitBinder("project")
    public void initProjectBinder(WebDataBinder binder) {
        binder.setAllowedFields(
                "title",
                "description",
                "spatialCoverageDescr",
                "speciesCommonName",
                "speciesScientificName",
                "srsIdentifier",
                "access",
                "rightsStatement",
                "licencingAndEthics",
                "institution",
                "simpleMapAccess"
        );
    }

    @ModelAttribute("project")
    public Project getProject(@PathVariable(value="id") Long projectId) {
        return projectDao.getProjectById(projectId);
    }


    @InitBinder("animal")
    public void initAnimalBinder(WebDataBinder binder) {
        binder.setAllowedFields( "projectAnimalId, animalName");
    }

    @RequestMapping(value="/projects/{id}/map", method= RequestMethod.GET)
    public String getMapView(Model model, @PathVariable("id") Long projectId, @RequestParam(value="a", required=false) Long a) {
        Project project = projectDao.getProjectById(projectId);
        if (project.getAccess() == ProjectAccess.OPEN || project.getSimpleMapAccess()) {
            projectVisitDao.save(new ProjectVisit(project, ProjectVisitType.ANALYSIS, new Date()));
            List<Animal> projectAnimalsList;
            if (a != null) {
                projectAnimalsList = new ArrayList<Animal>();
                projectAnimalsList.add(animalDao.getAnimalById(a));
            } else {
                projectAnimalsList = animalDao.getAnimalsByProjectId(project.getId());
            }
            model.addAttribute("mapLayerTypeList", MapLayerType.values());
            model.addAttribute("projectAnimalsList", projectAnimalsList);
            model.addAttribute("projectBoundingBox", projectDao.getBoundingBox(project, false));
            model.addAttribute("animalBoundingBoxes", projectDao.getAnimalBoundingBoxes(project, false));
            model.addAttribute("projectDetectionDateRange", projectDao.getDetectionDateRange(project, false));
            model.addAttribute("googleApiKey", configuration.getGoogleApiKey());
            return "simple-map";
        } else {
            return "redirect:" + "/projects/{id}";
        }
    }

}
