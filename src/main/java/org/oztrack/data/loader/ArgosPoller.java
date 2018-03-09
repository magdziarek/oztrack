package org.oztrack.data.loader;


import org.oztrack.data.model.ArgosPlatformSummary;
import org.oztrack.data.model.DataFeed;
import org.oztrack.data.model.DataFeedDevice;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.oztrack.error.DataFeedException;
import org.oztrack.util.ArgosClient;

import java.util.*;

import fr.cls.argos.*;
import org.oztrack.data.model.*;
import org.oztrack.data.model.types.ArgosClass;
import org.oztrack.util.EmailBuilderFactory;
import org.oztrack.util.GeometryUtils;
import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.EntityManager;

public class ArgosPoller extends DataFeedPoller {

    public ArgosPoller(EntityManager em) {
        super(em);
    }

    @Autowired
    private EmailBuilderFactory emailBuilderFactory;

    @Override
    public void poll() { //throws DataFeedException {

        Calendar pollStart = Calendar.getInstance();
        pollStart.setTime(new java.util.Date());
        pollStart.add(Calendar.DATE, ArgosClient.nbrDaysFromNowDefault * -1); // get the period we're polling for
        logger.info("Running ArgosPoller");

        List<DataFeed> dataFeeds = getAllDataFeeds(DataFeedSourceSystem.ARGOS);
        List<DataFeed> notReady = new ArrayList<DataFeed>(); // get rid of those that are not ready

        for (DataFeed dataFeed : dataFeeds) {
            if (new java.util.Date().before(dataFeed.getNextPollDate())) {
                notReady.add(dataFeed);

            }
        }
        dataFeeds.removeAll(notReady);

        for (DataFeed dataFeed : dataFeeds) {

            try {
                logger.info("ArgosPoller running for project " + dataFeed.getProject().getId());
                String credentials = getSourceSystemCredentials(dataFeed);
                ArgosClient argosClient = new ArgosClient(credentials);
                List<ArgosPlatformSummary> platformList = argosClient.getPlatformList();
                setLastPollDate(dataFeed);
                boolean detectionsFound = false;

                for (ArgosPlatformSummary platformSummary : platformList) {             // loop through each platform
                    long platformId = platformSummary.getPlatformId();

                    if (platformSummary.getLastCollectDate() != null) {
                        try { // get the platform data for this
                            Data platformData = argosClient.getPlatformData(platformId);
                            if (platformData.getErrors() == null) {
                                DataFeedDevice device = getDevice(dataFeed, Long.toString(platformId)); // if there is data here for this device, add the device/animal
                                long programNumber = platformData.getProgram().get(0).getProgramNumber();
                                List<SatellitePass> satellitePassList = platformData.getProgram().get(0).getPlatform().get(0).getSatellitePass();
                                for (SatellitePass satellitePass : satellitePassList) {
                                    Calendar bestMessageDate = satellitePass.getBestMsgDate().toGregorianCalendar();
                                    if (!deviceDao.checkDetectionExists(device,bestMessageDate.getTime())) {
                                        detectionsFound = true;
                                        DataFeedDetection detection = createNewDetection(device);
                                        detectionDao.saveRawArgosData(detection.getId()
                                                , programNumber
                                                , platformId
                                                , bestMessageDate
                                                , argosClient.getXml(satellitePass));
                                        detection.setDetectionDate(bestMessageDate.getTime());
                                        detection.setTimezoneId(bestMessageDate.getTimeZone().getID());
                                        PositionFix positionFix = new PositionFix();
                                        Location location = satellitePass.getLocation();
                                        if (location != null) {
                                            Date locationTime = location.getLocationDate().toGregorianCalendar().getTime();
                                            positionFix.setProject(dataFeed.getProject());
                                            positionFix.setAnimal(device.getAnimal());
                                            positionFix.setDataFeedDetection(detection);
                                            detection.setLocationDate(locationTime);
                                            positionFix.setDetectionTime(locationTime);
                                            positionFix.setLatitude(location.getLatitude().toString());
                                            positionFix.setLongitude(location.getLongitude().toString());
                                            try {
                                                positionFix.setLocationGeometry(GeometryUtils.findLocationGeometry(location.getLatitude().toString()
                                                        , location.getLongitude().toString()));
                                            } catch (Exception e) {
                                                throw new DataFeedException("Error translating coordinates: " + e.getLocalizedMessage());
                                            }
                                            positionFix.setDeleted(false);
                                            positionFix.setProbable(false);
                                            positionFix.setDop(Double.parseDouble(location.getDiagnostic().getHdop()));
                                            positionFix.setArgosClass(ArgosClass.fromCode(location.getLocationClass()));
                                        }
                                        saveDetectionWithPositionFix(detection, positionFix); //positionfix might be empty, save detection anyway
                                    }
                                }
                                if (detectionsFound) logger.info("platform " + platformId + " new detections");
                                //device.setLastDetectionDate(lastCollectionDate);
                                //deviceDao.save(device);
                            } else {
                                List<String> errorsList = platformData.getErrors().getError();
                                StringBuilder stringBuilder = new StringBuilder(errorsList.size());
                                for (int i = 0; i < errorsList.size(); i++) {
                                    String thisErrorStr = errorsList.get(i);
                                    stringBuilder.append(thisErrorStr);
                                    if (i < errorsList.size() - 1) stringBuilder.append(";");
                                    if (thisErrorStr.equals("no data")) { //ignore this error
                                        logger.error("platform " + platformId + " no data");
                                    } else {
                                        throw new DataFeedException("platform " + platformId + " errors: " + stringBuilder.toString()); //others are a problem though
                                    }
                                }
                            }
                        } catch (Exception e) {
                            String errorText = "Argos poller error platformId: " + platformId + ": " + e.getMessage();
                            logger.error(errorText);
                            sendErrorNotification(emailBuilderFactory,new DataFeedException(errorText));
                        }
                    }

                }
                if (detectionsFound) {
                    renumberPositionFixes(dataFeed);
                    logger.info("New detections downloaded - running renumber");
                }

            } catch (DataFeedException d) {
                logger.error("Argos Poller error datafeedId:" + dataFeed.getId() + " " + d.getMessage()); // couldn't read platformSummary probably
                sendErrorNotification(emailBuilderFactory, d);
            }
        }
    }

}



