package org.oztrack.controller;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.DoiDao;
import org.oztrack.data.model.Doi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.util.UUID;

@Controller
public class DoiPublicationController {

    @Autowired
    private DoiDao doiDao;

    @ModelAttribute("doi")
    public Doi getDoi(@PathVariable(value="uuid") String uuid) {
        UUID convertedUuid = UUID.fromString(uuid);
        return doiDao.getDoiByUuid(convertedUuid);
    }

    @RequestMapping(value="/publication/{uuid}", method={RequestMethod.GET,RequestMethod.HEAD}, produces="text/html")
    public String getHtmlView(@ModelAttribute(value="doi") Doi doi, Model model)  throws Exception {
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        File zipFile = new File(configuration.getDataDir() + File.separator + "publication"  + File.separator + doi.getUuid().toString() + ".zip");
        model.addAttribute("fileSize", FileUtils.byteCountToDisplaySize(zipFile.length()));
        return "doi-publication";
    }

    @RequestMapping(value="/publication/{uuid}/file", method=RequestMethod.GET, produces={ "application/zip"})
    public void getDoiZip(
            @ModelAttribute(value="doi") Doi doi,
            HttpServletResponse response
    ) throws Exception {
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        String zipFile = configuration.getDataDir() + File.separator + "publication"  + File.separator + doi.getUuid().toString() + ".zip";
        response.setHeader("Content-Disposition", "attachment; filename=ZoaTrack.zip");
        response.setContentType("application/zip");
        response.setCharacterEncoding("UTF-8");
        FileInputStream fileInputStream = new FileInputStream(zipFile);
        IOUtils.copy(fileInputStream, response.getOutputStream());
    }
}
