package org.oztrack.controller;

import java.util.ArrayList;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.oztrack.data.access.AnimalDao;
import org.oztrack.data.access.PositionFixDao;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.model.Animal;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.SearchQuery;
import org.oztrack.view.KMLExportView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.View;

@Controller
public class KMLExportController {
    protected final Log logger = LogFactory.getLog(getClass());
    
    @Autowired
    private ProjectDao projectDao;
    
    @Autowired
    private AnimalDao animalDao;
    
    @Autowired
    private PositionFixDao positionFixDao;

    @ModelAttribute("project")
    public Project getProject(@RequestParam(value="projectId") Long projectId) {
        return projectDao.getProjectById(projectId);
    }

    @RequestMapping(value="/exportKML", method=RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'read')")
    public View handleRequest(
        Model model,
        @ModelAttribute(value="project") Project project,
        @RequestParam(value="animalId", required=false) String animalId
    ) throws Exception {
        SearchQuery searchQuery = new SearchQuery();
        if ((project != null) && (animalId != null))  {
            logger.debug("for projectId: " + project.getId());
            
            searchQuery.setProject(project);
            
            Animal animal = animalDao.getAnimalById(Long.valueOf(animalId));
            ArrayList<Animal> animalList = new ArrayList<Animal>(1);
            animalList.add(animal);
            searchQuery.setAnimalList(animalList);
        }
        else {
            logger.debug("no projectId or queryType");
        }
        model.addAttribute("searchQuery", searchQuery);
        return new KMLExportView(positionFixDao);
    }
}
