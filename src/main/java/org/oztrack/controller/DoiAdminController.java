package org.oztrack.controller;

import org.oztrack.data.access.DoiDao;
import org.oztrack.data.model.Doi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;

@Controller
public class DoiAdminController {

    @Autowired
    private DoiDao doiDao;

    @ModelAttribute("doi")
    public Doi getDoi(@PathVariable(value="id") Long id) {
        return doiDao.getDoiById(id);
    }

    @RequestMapping(value="/settings/doi/{id}", method=RequestMethod.GET, produces="text/html")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String getHtmlView(@ModelAttribute(value="doi") Doi doi)  throws Exception {
        return "doi-admin-form";
    }


}
