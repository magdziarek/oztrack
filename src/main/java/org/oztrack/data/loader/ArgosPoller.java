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
import org.oztrack.util.GeometryUtils;

import javax.persistence.EntityManager;

public class ArgosPoller extends DataFeedPoller {

    public ArgosPoller(EntityManager em) {
        super(em);
    }

    @Override
    public void poll() throws DataFeedException {

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

            String credentials = getSourceSystemCredentials(dataFeed);
            ArgosClient argosClient = new ArgosClient(credentials);
            List<ArgosPlatformSummary> platformList = argosClient.getPlatformList();
            setLastPollDate(dataFeed);
            logger.info("ArgosPoller running for project " + dataFeed.getProject().getId());

            boolean detectionsFound = false;

            for (ArgosPlatformSummary platformSummary : platformList) {             // loop through each platform
                long platformId = platformSummary.getPlatformId();
                Date lastCollectionDate = platformSummary.getLastCollectDate().toGregorianCalendar().getTime();

                if (lastCollectionDate.after(pollStart.getTime())) { // if there is data here for this device, add the device/animal
                    DataFeedDevice device = getDevice(dataFeed, Long.toString(platformId));
                    Date maxBestMessageDate = deviceDao.getDeviceLatestDetectionDate(device);
                    Data platformData = argosClient.getPlatformData(platformId);
                    if (platformData.getErrors() == null) {
                        long programNumber = platformData.getProgram().get(0).getProgramNumber();
                        List<SatellitePass> satellitePassList = platformData.getProgram().get(0).getPlatform().get(0).getSatellitePass();

                        for (SatellitePass satellitePass : satellitePassList) {
                            Date bestMessageDate = satellitePass.getBestMsgDate().toGregorianCalendar().getTime();
                            if ((maxBestMessageDate == null) || (bestMessageDate.after(maxBestMessageDate))) {
                                detectionsFound = true;
                                maxBestMessageDate = bestMessageDate;
                                DataFeedDetection detection = createNewDetection(device);
                                detection.setDetectionDate(bestMessageDate);
                                PositionFix positionFix = new PositionFix();
                                Location location = satellitePass.getLocation();

                                if (location != null) {
                                    Date locationTime = location.getLocationDate().toGregorianCalendar().getTime();
                                    positionFix.setProject(dataFeed.getProject());
                                    positionFix.setAnimal(device.getAnimal());
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
                                    positionFix.setDataFeedDetection(detection);
                                    detection.setLocationDate(locationTime);
                                }
                                saveDetectionWithPositionFix(detection, positionFix); //positionfix might be empty, save detection anyway

                                detectionDao.saveRawArgosData(detection.getId()
                                        , programNumber
                                        , platformId
                                        , bestMessageDate
                                        , argosClient.getXml(satellitePass));
                            }
                        }
                    } else {
                        List<String> errorsList = platformData.getErrors().getError();
                        StringBuilder stringBuilder = new StringBuilder(errorsList.size());
                        for (int i = 0; i < errorsList.size(); i++) {
                            stringBuilder.append(errorsList.get(i));
                            if (i < errorsList.size() - 1) stringBuilder.append(";");
                        }
                        throw new DataFeedException("platform " + platformId + " errors: " + stringBuilder.toString());
                    }
                    device.setLastDetectionDate(lastCollectionDate);
                    deviceDao.save(device);
                }

            }
            if (detectionsFound) {
                renumberPositionFixes(dataFeed);
                logger.info("New detections downloaded");
            }

        }

    }

}



