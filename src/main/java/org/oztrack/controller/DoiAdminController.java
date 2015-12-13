package org.oztrack.controller;

import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.DoiDao;
import org.oztrack.data.model.Doi;
import org.oztrack.data.model.types.DoiStatus;
import org.oztrack.util.DoiClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import java.io.File;
import java.util.Date;

@Controller
public class DoiAdminController {

    private final Logger logger = Logger.getLogger(getClass());

    @Autowired
    private DoiDao doiDao;

    @Autowired
    private OzTrackPermissionEvaluator permissionEvaluator;

    @ModelAttribute("doi")
    public Doi getDoi(@PathVariable(value="id") Long id) {
        return doiDao.getDoiById(id);
    }

    @InitBinder("doi")
    public void initDoiBinder(WebDataBinder binder) {
        binder.setAllowedFields(
                "rejectMessage");
    }

    @RequestMapping(value="/settings/doi/{id}", method=RequestMethod.GET, produces="text/html")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String getHtmlView(@ModelAttribute(value="doi") Doi doi)  throws Exception {
        return "doi-admin-form";
    }

    @RequestMapping(value="/settings/doi/{id}/reject", method=RequestMethod.PUT, produces="text/html")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String processUpdate(Authentication authentication, @ModelAttribute(value="doi") Doi doi)  throws Exception {
        doi.setStatus(DoiStatus.REJECTED);
        doi.setRejectDate(new Date());
        doi.setUpdateDate(new Date());
        doi.setUpdateUser(permissionEvaluator.getAuthenticatedUser(authentication));
        doiDao.update(doi);
        return "redirect:/settings/doi/" + doi.getId();
    }

    @RequestMapping(value="/settings/doi/{id}/mint", method=RequestMethod.GET, produces="text/html")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public String mintDoi(Authentication authentication, Model model, @ModelAttribute(value="doi") Doi doi)  throws Exception {

        String ANDS_STATUS_OK = "MT090";
        String ANDS_MINT_SUCCESS = "MT001";
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();

        logger.info("Admin attempting to mint DOI for project " + doi.getProject().getId());
        DoiClient doiClient = new DoiClient();
        JSONObject statusResponseJson = new JSONObject();
        JSONObject mintResponseJson = new JSONObject();
        boolean mintSuccess = false;
        String doiText = "";
        String errorMessage = null;
        String view = "doi-admin-form";

        if (doi.getStatus().equals(DoiStatus.FAILED) || doi.getStatus().equals(DoiStatus.REQUESTED)) {
            try {
                statusResponseJson = doiClient.statusCheck();
            } catch (Exception e) {
                errorMessage = "Problem connecting to ANDS: " + e.getLocalizedMessage();
            }
        } else {
            errorMessage = "Cannot mint a DOI that is in " + doi.getStatus() + " status.";
        }

        if (statusResponseJson != null && statusResponseJson.getString("responsecode").equals(ANDS_STATUS_OK)) {
            logger.info("ANDS status check ok: " + statusResponseJson.getString("message") + " " + statusResponseJson.getString("verbosemessage"));
            mintResponseJson = doiClient.mintDOI(doi);
        } else {
            errorMessage = "ANDS status check is not ok: "
                    + statusResponseJson.getString("message") + " "
                    + statusResponseJson.getString("verbosemessage");
        }

        if (mintResponseJson != null && mintResponseJson.getString("responsecode").equals(ANDS_MINT_SUCCESS)) {
            mintSuccess = true;
            doiText = mintResponseJson.getString("doi");
        } else {
            doi.setStatus(DoiStatus.FAILED);
            errorMessage = "The mint was not successful. "
                    + mintResponseJson.getString("message") + " "
                    + mintResponseJson.getString("verbosemessage");
        }

        if (mintSuccess) {
            doi.setStatus(DoiStatus.COMPLETED);
            doi.setMintDate(new Date());
            doi.setPublished(true);
            doi.setCitation(doi.getCitation() + "http://dx.doi.org/" + doiText);
            doi.setDoi(doiText);

            // move the file away so it can't be changed and is released to the public
            File oldFile = new File(doi.getProject().getAbsoluteDataDirectoryPath() + File.separator + "ZoaTrack.zip");
            File newFile = new File(configuration.getDataDir() + File.separator + "publication" + File.separator + doi.getUuid().toString() + ".zip");
            if (!oldFile.renameTo(newFile)) {
                logger.error("Problem moving doi zip file. OldFile : "  + oldFile.getAbsolutePath()
                        + " newFile: " + newFile.getAbsolutePath());
                model.addAttribute("errorMessage","There's a problem with the archive. Please contact the admin.");
            }
            view = "redirect:/settings/doi/" + doi.getId();
        } else{
            logger.error(errorMessage);
            model.addAttribute("errorMessage", errorMessage);
        }

        doi.setUpdateDate(new Date());
        doi.setUpdateUser(permissionEvaluator.getAuthenticatedUser(authentication));
        doiDao.update(doi);

        return view;
    }
}




