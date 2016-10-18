package org.oztrack.controller;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.model.Project;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.View;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileReader;
import java.util.Map;

@Controller
public class EnvironmentDataController {

    private final Logger logger = Logger.getLogger(getClass());

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private OzTrackConfiguration configuration;

    @ModelAttribute("project")
    public Project getProject(@PathVariable(value="projectId") Long projectId) {
        return projectDao.getProjectById(projectId);
    }

    @RequestMapping(value = "/projects/{projectId}/envdata", method = RequestMethod.GET, produces="text/html")
    @PreAuthorize("hasPermission(#project, 'read')")
    public String getHtmlView(Model model, @ModelAttribute(value="project") Project project) throws Exception {
        model.addAttribute("project",project);
        return "env-demo";
    }

    @RequestMapping(value = "/projects/{projectId}/env", method = RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'read')")
    public View getCsv(Model model
            , @ModelAttribute(value="project") Project project
            , @RequestParam(value="id", required=false) String animalId) throws Exception {

        String sep = File.separator;
        final String path, fileName;

        if (animalId != null) {
            path = project.getAbsoluteDataDirectoryPath() + sep + "env" + sep;
            fileName = "env-" + animalId + ".csv";
        } else {
            logger.info("no animalid");
            path = configuration.getDataDir() + "common" + sep;
            fileName = "env-metadata.csv";
        }
        logger.info("file: " + path + fileName);

        return new View() {
            @Override
            public String getContentType() {
                return "text/csv";
            }

            @Override
            public void render(Map<String, ?> model
                        , HttpServletRequest request
                        , HttpServletResponse response) throws Exception {
                logger.info("render");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                response.setContentType("text/csv");
                IOUtils.copy(new FileReader(new File(path + fileName)), response.getWriter());
            }
       };
    }

}
