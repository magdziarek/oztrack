package org.oztrack.controller;

import org.oztrack.data.access.DoiDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class DoiAdminListController {

    @Autowired
    private DoiDao doiDao;

    @RequestMapping(value="/settings/doi", method= RequestMethod.GET)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String getListView(Model model) {
        model.addAttribute("doiList", doiDao.getAll());
        return "doi-admin";
    }

}
