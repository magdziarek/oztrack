package org.oztrack.controller;

import org.oztrack.data.access.DoiDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;


@Controller
public class DoiPublicationListController {

    @Autowired
    private DoiDao doiDao;

    @RequestMapping(value="/publication", method= RequestMethod.GET)
    public String getListView(Model model) {
        model.addAttribute("doiList", doiDao.getAllPublished());
        return "doi-publications";
    }
}
