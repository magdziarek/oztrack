package org.oztrack.controller;

import org.oztrack.data.access.DataFeedDeviceDao;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.model.DataFeedDevice;
import org.oztrack.data.model.Project;
import org.oztrack.view.ArgosCsvView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.View;

import java.util.List;


@Controller
public class DataFeedController {

    @Autowired
    private DataFeedDeviceDao dataFeedDeviceDao;

    @Autowired
    private ProjectDao projectDao;

    @ModelAttribute("project")
    public Project getProject(@PathVariable(value = "projectId") Long projectId) {
        return projectDao.getProjectById(projectId);
    }

    @RequestMapping(value = "/projects/{projectId}/datafeed", method = RequestMethod.GET, produces = "text/html")
    @PreAuthorize("hasPermission(#project, 'write')")
    public String getHtmlView(Model model, @ModelAttribute(value = "project") Project project) throws Exception {
        model.addAttribute("dataFeeds", project.getDataFeeds());
        return "datafeed";
    }

    @RequestMapping(value = "/projects/{projectId}/argosraw", method = RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'write')")
    public View handleRequest(Model model
            , @ModelAttribute(value = "project") Project project
            , @RequestParam(value = "deviceId") final String deviceId
            , @RequestParam(value = "rtype") final String rtype) {

        DataFeedDevice device = dataFeedDeviceDao.getDeviceById(Long.parseLong(deviceId));
        List<String> rawDataXml = dataFeedDeviceDao.getRawArgosData(device);
        return new ArgosCsvView(device, rawDataXml, rtype);
    }


}
