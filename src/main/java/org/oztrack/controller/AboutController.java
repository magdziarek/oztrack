package org.oztrack.controller;

import org.oztrack.data.access.AnalysisDao;
import org.oztrack.data.access.SettingsDao;
import org.oztrack.data.model.Settings;
import org.oztrack.data.model.types.AnalysisType;
import org.oztrack.data.model.types.DoiChecklist;
import org.springframework.ui.Model;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.util.ArrayList;

@Controller
public class AboutController {
    @Autowired
    private SettingsDao settingsDao;


    @InitBinder("settings")
    public void initTextBinder(WebDataBinder binder) {
        binder.setAllowedFields();
    }

    @ModelAttribute("settings")
    public Settings getSettings() throws Exception {
        return settingsDao.getSettings();
    }

    @RequestMapping(value="/about", method=RequestMethod.GET)
    @PreAuthorize("permitAll")
    public String handleAboutRequest() {
        return "about";
    }

    @RequestMapping(value="/about/{section:people|publications|software|layers|artwork}", method=RequestMethod.GET)
    @PreAuthorize("permitAll")
    public String handleAboutSectionRequest(@PathVariable("section") String section) {
        return "about-" + section;
    }

    @RequestMapping(value="/toolkit", method=RequestMethod.GET)
    @PreAuthorize("permitAll")
    public String handleToolkitRequest(Model model) {
        ArrayList<AnalysisType> analysisTypeList = new ArrayList<AnalysisType>();
        for (AnalysisType analysisType : AnalysisType.values()) {
            analysisTypeList.add(analysisType);
        }
        model.addAttribute("analysisTypeList", analysisTypeList);

        ArrayList<DoiChecklist> doiChecklist = new ArrayList<DoiChecklist>();
        for (DoiChecklist ch : DoiChecklist.values()) {
            doiChecklist.add(ch);
        }
        model.addAttribute("doiChecklist", doiChecklist);

        return "toolkit";
    }

    @RequestMapping(value="/toolkit/{section:getstarted|analysis|datamgt|doi}", method=RequestMethod.GET)
    @PreAuthorize("permitAll")
    public String handleToolkitSectionRequest(Model model, @PathVariable("section") String section) {

        ArrayList<AnalysisType> analysisTypeList = new ArrayList<AnalysisType>();
        for (AnalysisType analysisType : AnalysisType.values()) {
            analysisTypeList.add(analysisType);
        }
        model.addAttribute("analysisTypeList", analysisTypeList);
        model.addAttribute("section", section);
        return "toolkit";
    }

}