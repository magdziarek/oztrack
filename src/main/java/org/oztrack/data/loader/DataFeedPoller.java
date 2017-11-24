package org.oztrack.data.loader;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.PrecisionModel;
import fr.cls.argos.Data;
import org.apache.log4j.Logger;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.impl.*;
import org.oztrack.data.model.*;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.oztrack.error.DataFeedException;
import org.oztrack.util.*;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import static org.oztrack.util.GeometryUtils.parseCoordinate;

public abstract class DataFeedPoller {

    protected final Logger logger = Logger.getLogger(getClass());
    private EntityManager entityManager;
    private DataFeedDaoImpl dataFeedDao;
    private AnimalDaoImpl animalDao;
    private PositionFixDaoImpl positionFixDao;
    DataFeedDetectionDaoImpl detectionDao;
    DataFeedDeviceDaoImpl deviceDao;

    public DataFeedPoller(EntityManager em) {
        entityManager = em;
        dataFeedDao = new DataFeedDaoImpl();
        dataFeedDao.setEntityManger(entityManager);
        deviceDao = new DataFeedDeviceDaoImpl();
        deviceDao.setEntityManger(entityManager);
        detectionDao = new DataFeedDetectionDaoImpl();
        detectionDao.setEntityManger(entityManager);
        animalDao = new AnimalDaoImpl();
        animalDao.setEntityManger(entityManager);
        positionFixDao = new PositionFixDaoImpl();
        positionFixDao.setEntityManger(entityManager);
    }

    public abstract void poll() throws DataFeedException;

    List<DataFeed> getAllDataFeeds(DataFeedSourceSystem sourceSystem) {
        return dataFeedDao.getAllActiveDataFeeds(sourceSystem);
    }

    String getSourceSystemCredentials(DataFeed datafeed) {
        return dataFeedDao.getSourceSystemCredentials(datafeed.getId());
    }

    void setLastPollDate(DataFeed dataFeed) {
        dataFeed.setLastPollDate(new java.util.Date());
        EntityTransaction transaction = entityManager.getTransaction();
        transaction.begin();
        dataFeedDao.update(dataFeed);
        transaction.commit();
    }

    // create a new device if this one doesn't exist
    DataFeedDevice getDevice(DataFeed dataFeed, String deviceIdentifier) {
        DataFeedDevice device = deviceDao.getDataFeedDeviceByIdentifier(dataFeed.getId(), deviceIdentifier);
        if (device == null) {
            logger.info("Creating device (" + deviceIdentifier + ") and animal");
            EntityTransaction transaction = entityManager.getTransaction();
            transaction.begin();
            Animal animal = new Animal();
            animal.setProject(dataFeed.getProject());
            animal.setProjectAnimalId(deviceIdentifier);
            animal.setAnimalName(deviceIdentifier);
            //animal.setAnimalDescription();
            animal.setDataRetrievalMethod("Retrieved via " +
                    dataFeed.getDataFeedSourceSystem().getName() + " " +
                    dataFeed.getDataFeedSourceSystem().getDeviceIdentifierDescriptor() + ":" + deviceIdentifier);
            animal.setCreateDate(new java.util.Date());
            animalDao.save(animal);
            transaction.commit();

            transaction.begin();
            animal.setColour(MapUtils.animalColours[(int) (animal.getId() % MapUtils.animalColours.length)]);
            animalDao.update(animal);
            device = new DataFeedDevice();
            device.setProject(dataFeed.getProject());
            device.setAnimal(animal);
            device.setDeviceIdentifier(deviceIdentifier);
            device.setDataFeed(dataFeed);
            device.setCreateDate(new java.util.Date());
            deviceDao.save(device);
            transaction.commit();
        }
        return device;
    }

    DataFeedDetection createNewDetection(DataFeedDevice device) {
        EntityTransaction transaction = entityManager.getTransaction();
        transaction.begin();
        DataFeedDetection detection = new DataFeedDetection();
        detection.setProject(device.getProject());
        detection.setAnimal(device.getAnimal());
        detection.setDataFeedDevice(device);
        detection.setPollDate(new java.util.Date());
        detection.setDetectionDate(new java.util.Date()); // placeholder : this needs to be removed once the actual detection date is found
        detectionDao.save(detection);
        transaction.commit();
        return detection;
    }

    PositionFix createPositionFix(DataFeedDetection detection, String latitude, String longitude) throws DataFeedException {

        PositionFix p = new PositionFix();
        try {
            p.setLocationGeometry(GeometryUtils.findLocationGeometry(latitude, longitude));
        } catch (Exception e) {
            throw new DataFeedException("Error translating coordinates: " + e.getLocalizedMessage());
        }
        p.setDataFeedDetection(detection);
        p.setProject(detection.getProject());
        p.setAnimal(detection.getAnimal());
        p.setDetectionTime(detection.getLocationDate());
        p.setLatitude(latitude);
        p.setLongitude(longitude);
        p.setDeleted(false);
        p.setProbable(false);
        return p;
    }

    void saveDetectionWithPositionFix(DataFeedDetection detection, PositionFix positionFix) {
        EntityTransaction transaction = entityManager.getTransaction();
        transaction.begin(); // dance
        detectionDao.save(detection);
        transaction.commit();
        if (positionFix.getDetectionTime() != null) {
            transaction.begin();
            positionFix.setDataFeedDetection(detection);
            positionFixDao.save(positionFix);
            Animal animal = positionFix.getAnimal();
            animal.setUpdateDate(detection.getPollDate());
            animalDao.update(animal);
            transaction.commit();
        }
    }

    void renumberPositionFixes(DataFeed dataFeed) {
        List<Long> animalIds = new ArrayList<Long>(dataFeed.getProject().getAnimals().size());
        List<Animal> animals = dataFeed.getProject().getAnimals();
        for (Animal animal : animals) {
            animalIds.add(animal.getId());
        }
        EntityTransaction transaction = entityManager.getTransaction();
        transaction.begin();
        positionFixDao.setRenumberPositionFixesExecutor(new ProjectAnimalsMutexExecutor());
        positionFixDao.renumberPositionFixes(dataFeed.getProject(), animalIds);
        transaction.commit();
    }

    protected void sendErrorNotification(DataFeedException dfe) {
        DoiDaoImpl doiDao = new DoiDaoImpl();
        doiDao.setEntityManger(entityManager);
        EmailBuilderFactory emailBuilderFactory = new EmailBuilderFactory();
        StringBuilder htmlMsgContent = new StringBuilder();
        htmlMsgContent.append("<p>Argos poll error thrown:</p>");
        htmlMsgContent.append(dfe.getMessage());
        User adminUser = doiDao.getAdminUsers().get(0);
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        if (configuration.getTestServer()) {
            logger.info("Email to " + adminUser.getEmail() + " " + htmlMsgContent.toString());
        } else {
            try {
                EmailBuilder emailBuilder = emailBuilderFactory.getObject();
                emailBuilder.to(adminUser);
                emailBuilder.subject("Argos Poller error");
                emailBuilder.htmlMsgContent(htmlMsgContent.toString());
                emailBuilder.build().send();
                logger.info("Argos Poll error email sent to admin");
            } catch (Exception e) {
                logger.error("Argos poller error email to admin failed.", e);
            }
        }
    }



}
