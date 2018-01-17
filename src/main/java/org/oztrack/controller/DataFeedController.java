package org.oztrack.controller;

import au.com.bytecode.opencsv.CSVWriter;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.oztrack.data.access.DataFeedDetectionDao;
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
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Controller
public class DataFeedController {

    @Autowired
    private DataFeedDeviceDao dataFeedDeviceDao;

    @Autowired
    private DataFeedDetectionDao dataFeedDetectionDao;

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

    @RequestMapping(value = "/projects/{projectId}/detcsv", method = RequestMethod.GET, produces = "text/csv")
    @PreAuthorize("hasPermission(#project, 'write')")
    public void handleDetectionsCsvRequest(HttpServletResponse response
            , @ModelAttribute(value = "project") Project project
            , @RequestParam(value = "dataFeedId") final String dataFeedId) throws IOException {
        response.setHeader("Content-Disposition", "attachment; filename=\"datafeeddetections.csv\"");
        CSVWriter csvWriter = new CSVWriter(response.getWriter());
        dataFeedDetectionDao.writeDataFeedDetectionsCsv(Long.parseLong(dataFeedId), csvWriter);
        csvWriter.close();
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

    @RequestMapping(value = "/projects/{projectId}/spotraw", method = RequestMethod.GET)
    @PreAuthorize("hasPermission(#project, 'write')")
    public void handleSpotRequest(Model model
            , HttpServletResponse response
            , @ModelAttribute(value = "project") Project project
            , @RequestParam(value = "deviceId") final String deviceId) throws Exception {
        DataFeedDevice device = dataFeedDeviceDao.getDeviceById(Long.parseLong(deviceId));
        response.setHeader("Content-Disposition", "attachment; filename=spot-" + device.getDeviceIdentifier() + ".csv");
        CSVWriter writer = new CSVWriter(response.getWriter());
        String[] headers = {"id"
                , "messengerId"
                , "messengerName"
                , "unixTime"
                , "messageType"
                , "latitude"
                , "longitude"
                , "modelId"
                , "showCustomMsg"
                , "dateTime"
                , "messageDetail"
                , "batteryState"
                , "hidden"
                , "altitude"};
        writer.writeNext(headers);
        List<String> rawDataJson = dataFeedDeviceDao.getRawSpotData(device);
        for (String jsonString : rawDataJson) {
            JSONObject json = new JSONObject(jsonString);
            ArrayList<String> nextLine = new ArrayList<String>(headers.length);
            nextLine.add(Objects.toString(json.getString("id"), ""));
            nextLine.add(Objects.toString(json.getString("messengerId"), ""));
            nextLine.add(Objects.toString(json.getString("messengerName"), ""));
            nextLine.add(Objects.toString(json.getString("unixTime"), ""));
            nextLine.add(Objects.toString(json.getString("messageType"), ""));
            nextLine.add(Objects.toString(json.getString("latitude"), ""));
            nextLine.add(Objects.toString(json.getString("longitude"), ""));
            nextLine.add(Objects.toString(json.getString("modelId"), ""));
            nextLine.add(Objects.toString(json.getString("showCustomMsg"), ""));
            nextLine.add(Objects.toString(json.getString("dateTime"), ""));
            nextLine.add(Objects.toString(json.getString("messageDetail"), ""));
            nextLine.add(Objects.toString(json.getString("batteryState"), ""));
            nextLine.add(Objects.toString(json.getString("hidden"), ""));
            nextLine.add(Objects.toString(json.getString("altitude"), ""));
            writer.writeNext(nextLine.toArray(new String[]{}));
        }
        writer.close();
    }





}
