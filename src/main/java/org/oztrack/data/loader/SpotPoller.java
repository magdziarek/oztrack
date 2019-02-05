package org.oztrack.data.loader;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.oztrack.data.model.DataFeed;
import org.oztrack.data.model.DataFeedDetection;
import org.oztrack.data.model.DataFeedDevice;
import org.oztrack.data.model.PositionFix;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.oztrack.error.DataFeedException;
import org.oztrack.util.EmailBuilderFactory;
import org.oztrack.util.SpotClient;
import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.EntityManager;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class SpotPoller extends DataFeedPoller {

    private SimpleDateFormat isoDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");

    @Autowired
    private EmailBuilderFactory emailBuilderFactory;

    public SpotPoller(EntityManager em) {
        super(em);
    }

    private static class SpotMessage {
        private String messengerId;
        private String messengerName;
        private String messageType;
        private String latitude;
        private String longitude;
        private Calendar dateTime;
        private String timeZoneId;
        private String json;
    }

    @Override
    public void poll() { //throws DataFeedException {

        Calendar pollStart = Calendar.getInstance();
        pollStart.setTime(new java.util.Date());
        pollStart.add(Calendar.DATE, 7); // get the period we're polling for
        logger.info("Running SpotPoller");

        List<DataFeed> dataFeeds = getAllDataFeeds(DataFeedSourceSystem.SPOT);
        List<DataFeed> notReady = new ArrayList<DataFeed>();

        for (DataFeed dataFeed : dataFeeds) {
            if (new java.util.Date().before(dataFeed.getNextPollDate())) {
                notReady.add(dataFeed);
            }
        }
        dataFeeds.removeAll(notReady);

        for (DataFeed dataFeed : dataFeeds) {
            logger.info("SpotPoller running for project " + dataFeed.getProject().getId());
            try {
                String credentials = getSourceSystemCredentials(dataFeed);
                SpotClient spotClient = new SpotClient(credentials);

                JSONArray messagesJson = spotClient.retrieveMessagesJson();
                setLastPollDate(dataFeed);
                boolean detectionsFound = false;
                List<SpotMessage> spotMessages = extractSpotMessages(messagesJson);
                for (SpotMessage spotMessage : spotMessages) {
                    if (!spotMessage.messageType.equals("POWER-OFF")){
                        DataFeedDevice device = getDevice(dataFeed, spotMessage.messengerName);
                        Date latestDetectionDate = deviceDao.getDeviceLatestDetectionDate(device);
                        String lastDetectionDateString = (latestDetectionDate == null) ? "null" : latestDetectionDate.toString();
                        //                   logger.info(device.getDeviceIdentifier() + " latest detection: " + lastDetectionDateString +
                        //                           " this spotMessageDate: " + isoDateTimeFormat.format(spotMessage.dateTime.getTime()));
                        if ((latestDetectionDate == null) || (spotMessage.dateTime.getTime().after(latestDetectionDate))) {
                            DataFeedDetection detection = createNewDetection(device);
                            detectionDao.saveRawSpotData(detection.getId()
                                    , spotMessage.messengerId
                                    , spotMessage.messengerName
                                    , spotMessage.dateTime
                                    , spotMessage.json);
                            detection.setDetectionDate(spotMessage.dateTime.getTime());
                            detection.setLocationDate(spotMessage.dateTime.getTime());
                            detection.setTimezoneId(spotMessage.timeZoneId);
                            detectionDao.update(detection);
                            try {
                                PositionFix positionFix = createPositionFix(detection, spotMessage.latitude, spotMessage.longitude);
                                saveDetectionWithPositionFix(detection, positionFix);
                            } catch (DataFeedException d) {
                                String errorText = "Spot poller: Problem creating positionfix record for a detection dated: " + isoDateTimeFormat.format(spotMessage.dateTime.getTime());
                                logger.error(errorText + d.getMessage());
                                sendErrorNotification(emailBuilderFactory, new DataFeedException(errorText + d.getMessage())); // keep going though
                            }
                            detectionsFound = true;
                      }
                    }else{
                        logger.warn("POWER-OFF warning is detected!");
                    }
                }
                if (detectionsFound) {
                    renumberPositionFixes(dataFeed);
                    logger.info("New detections downloaded");
                }
            } catch (DataFeedException d) {
                logger.error("Spot Poller error on project:" + dataFeed.getProject().getId() + " datafeed:" + dataFeed.getId());
                sendErrorNotification(emailBuilderFactory, d);
            }
        }
    }

    private List<SpotMessage> extractSpotMessages(JSONArray messagesJson) throws DataFeedException {
        ArrayList<SpotMessage> spotMessages = new ArrayList<SpotMessage>();
        for (int i = messagesJson.length() - 1; i >= 0; i--) { //start at the end so that we get the oldest first)
            SpotMessage spotMessage = new SpotMessage();
            spotMessage.dateTime = Calendar.getInstance();
            try {
                JSONObject message = messagesJson.getJSONObject(i);
                spotMessage.messengerId = message.getString("messengerId");
                spotMessage.messengerName = message.getString("messengerName");
                spotMessage.messageType = message.getString("messageType");
                spotMessage.latitude = message.getString("latitude");
                spotMessage.longitude = message.getString("longitude");
                spotMessage.dateTime.setTime(isoDateTimeFormat.parse(message.getString("dateTime")));
                spotMessage.timeZoneId = spotMessage.dateTime.getTimeZone().getID();
                spotMessage.json = message.toString();
                //logger.info(spotMessage.messengerName + " " + isoDateTimeFormat.format(spotMessage.dateTime.getTime()) + " " + spotMessage.timeZoneId + " (" + spotMessage.latitude + "," + spotMessage.longitude + ")");
                spotMessages.add(spotMessage);
            } catch (JSONException jse) {
                logger.error("JSON exception reading spot message: " + jse.getLocalizedMessage());
            } catch (ParseException pe) {
                logger.error("Date parsing exception on spot message: " + pe.getLocalizedMessage());
            }
        }
        return spotMessages;
    }
}
