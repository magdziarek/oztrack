package org.oztrack.controller;

import java.io.IOException;

import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.access.impl.ProjectDaoImpl;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.types.ProjectAccess;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.view.RedirectView;

import javax.servlet.http.HttpServletRequest;

@Controller
public class RedirectController {

    @Autowired
    private OzTrackConfiguration configuration;

    @Autowired
    private ProjectDao projectDao;

    @RequestMapping(value="/home", method=RequestMethod.GET)
    public RedirectView redirectOldHomeUrl() throws IOException {
        return redirectTo("/");
    }

    @RequestMapping(value="/projectdescr", method=RequestMethod.GET)
    public RedirectView redirectProjectDescriptionView(@RequestParam(value="id") Long id) {
        return redirectTo("/projects/" + id);
    }

    @RequestMapping(value="/whalesharkrace", method=RequestMethod.GET)
    public RedirectView redirectWhaleSharkRace() {
        Long project_id = configuration.getWhaleSharkRaceId().longValue();
        Project whaleSharkProject = projectDao.getProjectById(project_id);
        String url = "/projects/" + project_id.toString();
        if (whaleSharkProject.getAccess().equals(ProjectAccess.OPEN)) {
            url += "/analysis";
        }
        RedirectView redirectView = new RedirectView(url,true);
        redirectView.setExposeModelAttributes(false);
        redirectView.setExposePathVariables(false);
        return redirectView;
    }

    private RedirectView redirectTo(String url) {
        RedirectView redirectView = new RedirectView(url, true);
        redirectView.setStatusCode(HttpStatus.MOVED_PERMANENTLY);
        redirectView.setExposeModelAttributes(false);
        redirectView.setExposePathVariables(false);
        return redirectView;
    }

}