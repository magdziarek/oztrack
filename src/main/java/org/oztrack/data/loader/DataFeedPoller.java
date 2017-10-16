package org.oztrack.data.loader;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.PrecisionModel;
import org.apache.log4j.Logger;
import org.oztrack.data.access.impl.*;
import org.oztrack.data.model.*;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.oztrack.error.DataFeedException;
import org.oztrack.util.MapUtils;
import org.oztrack.util.ProjectAnimalsMutexExecutor;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import java.util.ArrayList;
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

        } else {
            logger.info("Device already exists (" + deviceIdentifier + ")");
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

    void saveDetectionWithPositionFix(DataFeedDetection detection, PositionFix positionFix) {
        EntityTransaction transaction = entityManager.getTransaction();
        if (positionFix.getDetectionTime() != null) {
            transaction.begin();
            positionFixDao.save(positionFix);
            transaction.commit();
            detection.setPositionFix(positionFix);
        }
        transaction.begin();
        detectionDao.save(detection);
        transaction.commit();
    }

    Point getLocationGeometry(String latitude, String longitude) throws DataFeedException {
        GeometryFactory geometryFactory;
        Coordinate coordinate;

        try {
            geometryFactory = new GeometryFactory(new PrecisionModel(1000000), 4326);
            coordinate = new Coordinate(parseCoordinate(longitude), parseCoordinate(latitude));
        } catch (Exception e) {
            throw new DataFeedException("Difficulty translating location: " + e.getLocalizedMessage());
        }
        return geometryFactory.createPoint(coordinate);
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


}
