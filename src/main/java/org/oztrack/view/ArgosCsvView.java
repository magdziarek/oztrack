package org.oztrack.view;

import org.apache.log4j.Logger;
import org.oztrack.data.model.DataFeedDevice;
import org.oztrack.util.ArgosClient;
import org.springframework.web.servlet.view.AbstractView;
import au.com.bytecode.opencsv.CSVWriter;
import fr.cls.argos.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

public class ArgosCsvView extends AbstractView {

    private final Logger logger = Logger.getLogger(getClass());
    private DataFeedDevice device;
    private List<String> satellitePassXml;
    private String rawDataType;
    private String nullDefault = "";
    private final int maxNumberSensors = 31;

    public ArgosCsvView(DataFeedDevice device, List<String> satellitePassXml, String rawDataType) {
        this.device = device;
        this.satellitePassXml = satellitePassXml;
        this.rawDataType = rawDataType;
    }

    @Override
    protected void renderMergedOutputModel(Map<String, Object> model,
                                           HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setHeader("Content-Disposition", "attachment; filename=\"" + rawDataType + "-" + device.getDeviceIdentifier() + ".csv\"");
        CSVWriter writer = new CSVWriter(response.getWriter());
        if (rawDataType.equals("diagnostic")) {
            buildDiagnosticCsv(writer);
        } else if (rawDataType.equals("messages")) {
            buildMessagesCsv(writer);
        }
        writer.close();
    }

    private void buildDiagnosticCsv(CSVWriter writer) throws Exception {
        ArgosClient argosClient = new ArgosClient();
        String[] headers = {"platformId"
                , "satellite"
                , "bestMsgDate"
                , "duration"
                , "nbMessage"
                , "message120"
                , "bestLevel"
                , "frequency"
                , "locationDate"
                , "latitude"
                , "longitude"
                , "altitude"
                , "locationClass"
                , "gpsSpeed"
                , "gpsHeading"
                , "index"
                , "nopc"
                , "errorRadius"
                , "semiMajor"
                , "semiMinor"
                , "orientation"
                , "hdop"
                , "latitude2"
                , "longitude2"
                , "altitude2"};
        writer.writeNext(headers);
        for (String xml : satellitePassXml) {
            SatellitePass satellitePass = argosClient.getSatellitePass(xml);
            ArrayList<String> nextLine = new ArrayList<String>(headers.length);
            //String nullDefault = "";
            nextLine.add(device.getDeviceIdentifier());
            nextLine.add(satellitePass.getSatellite());
            nextLine.add(Objects.toString(satellitePass.getBestMsgDate(), nullDefault));
            nextLine.add(Objects.toString(satellitePass.getDuration(), nullDefault));
            nextLine.add(Objects.toString(satellitePass.getNbMessage(), nullDefault));
            nextLine.add(Objects.toString(satellitePass.getMessage120(), nullDefault));
            nextLine.add(Objects.toString(satellitePass.getBestLevel(), nullDefault));
            nextLine.add(Objects.toString(satellitePass.getFrequency(), nullDefault));
            if (satellitePass.getLocation() != null) {
                Location location = satellitePass.getLocation();
                nextLine.add(Objects.toString(location.getLocationDate(), nullDefault));
                nextLine.add(Objects.toString(location.getLatitude(), nullDefault));
                nextLine.add(Objects.toString(location.getLongitude(), nullDefault));
                nextLine.add(Objects.toString(location.getAltitude(), nullDefault));
                nextLine.add(Objects.toString(location.getLocationClass(), nullDefault));
                nextLine.add(Objects.toString(location.getGpsSpeed(), nullDefault));
                nextLine.add(Objects.toString(location.getGpsHeading(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getIndex(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getNopc(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getErrorRadius(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getSemiMajor(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getSemiMinor(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getOrientation(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getHdop(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getLatitude2(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getLongitude2(), nullDefault));
                nextLine.add(Objects.toString(location.getDiagnostic().getAltitude2(), nullDefault));
            }
            writer.writeNext(nextLine.toArray(new String[]{}));
        }
    }

    private void buildMessagesCsv(CSVWriter writer) {
        ArgosClient argosClient = new ArgosClient();
        ArrayList<String> headers = new ArrayList<String>();
        headers.add("platformId");
        headers.add("satellite");
        headers.add("bestMsgDate");
        headers.add("bestDate");
        headers.add("compression");
        headers.add("type");
        headers.add("alarm");
        headers.add("concatenate");
        headers.add("date");
        headers.add("level");
        headers.add("doppler");
        headers.add("rawData");
        headers.add("formatname");
        for (int i = 1; i <= maxNumberSensors; i++) {
            headers.add("sensor" + i);
        }
        writer.writeNext(headers.toArray(new String[]{}));
        for (String xml : satellitePassXml) {
            SatellitePass satellitePass = argosClient.getSatellitePass(xml);
            List<Message> messages = satellitePass.getMessage();
            for (Message message : messages == null ? Collections.<Message>emptyList() : messages) {
                List<Collect> collects = message.getCollect();
                for (Collect collect : collects == null ? Collections.<Collect>emptyList() : collects) {
                    ArrayList<String> nextLine = new ArrayList<String>(headers.size());
                    // message
                    nextLine.add(device.getDeviceIdentifier());
                    nextLine.add(satellitePass.getSatellite());
                    nextLine.add(Objects.toString(satellitePass.getBestMsgDate(), nullDefault));
                    nextLine.add(Objects.toString(message.getBestDate(), nullDefault));
                    nextLine.add(Objects.toString(message.getCompression(), nullDefault));
                    // collect
                    nextLine.add(Objects.toString(collect.getType()));
                    nextLine.add(Objects.toString(collect.getAlarm()));
                    nextLine.add(Objects.toString(collect.getConcatenated()));
                    nextLine.add(Objects.toString(collect.getDate()));
                    nextLine.add(Objects.toString(collect.getLevel()));
                    nextLine.add(Objects.toString(collect.getDoppler()));
                    nextLine.add(Objects.toString(collect.getRawData()));
                    if (message.getFormat().size() > 1)
                        logger.info("Argos message format array contains more than 1 element");
                    // format / sensor
                    Format format = message.getFormat().get(0);
                    nextLine.add(Objects.toString(format.getFormatName()));
                    List<Sensor> sensors = format.getSensor();
                    for (Sensor sensor : sensors) {
                        nextLine.add(Objects.toString(sensor.getValue()));
                    }
                    writer.writeNext(nextLine.toArray(new String[]{}));
                }
            }
        }
    }
}
