package org.oztrack.data.access.impl;

import fr.cls.argos.SatellitePass;
import org.oztrack.data.access.DataFeedDeviceDao;
import org.oztrack.data.access.DataFileDao;
import org.oztrack.data.model.DataFeed;
import org.oztrack.data.model.DataFeedDetection;
import org.oztrack.data.model.DataFeedDevice;
import org.oztrack.data.model.DataFile;
import org.springframework.stereotype.Service;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;

import org.springframework.transaction.annotation.Transactional;

import javax.persistence.Query;
import java.util.Calendar;
import java.util.Date;
import java.util.List;


@Service
public class DataFeedDeviceDaoImpl implements DataFeedDeviceDao {

    private EntityManager em;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Override
    public DataFeedDevice getDataFeedDeviceByIdentifier(Long datafeedId, String deviceIdentifier) {

        Query query = em.createQuery("select o from DataFeedDevice o \n" +
                "WHERE o.dataFeed.id = :datafeed_id " +
                "AND o.deviceIdentifier = :device_identifier");
        query.setParameter("datafeed_id", datafeedId);
        query.setParameter("device_identifier", deviceIdentifier);
        try {
            return (DataFeedDevice) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }

    }

    @Override
    public Date getDeviceLatestDetectionDate(DataFeedDevice device) {
        Query query = em.createQuery("select max(detectionDate) from org.oztrack.data.model.DataFeedDetection o \n" +
                "WHERE o.dataFeedDevice = :device ");
        query.setParameter("device", device);
        try {
            return (Date) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public boolean checkDetectionExists(DataFeedDevice device, Date detectionDate){
        Query query = em.createQuery("select count(o) from org.oztrack.data.model.DataFeedDetection o \n" +
                "WHERE o.project = :project \n" +
                "AND o.dataFeedDevice = :device \n" +
                "AND o.detectionDate = :detectionDate ");
        query.setParameter("project", device.getProject());
        query.setParameter("device",device);
        query.setParameter("detectionDate",detectionDate);
        Long count = (Long) query.getSingleResult();
        try {
            return count.intValue() == 0 ? false : true;
        } catch (NoResultException ex) {
            return false;
        }

    }

    @Override
    public DataFeedDevice getDeviceById(Long id) {
        Query query = em.createQuery("select o from DataFeedDevice o \n" +
                "where o.id = :id");
        query.setParameter("id", id);
        try {
            return (DataFeedDevice) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<String> getRawArgosData(DataFeedDevice device) {
        Query query = em.createNativeQuery("select satellite_pass_xml from datafeed_raw_argos \n" +
                " where datafeed_detection_id in (select id from datafeed_detection \n" +
                "where datafeed_device_id = :deviceId)");
        query.setParameter("deviceId", device.getId());
        try {
            return query.getResultList();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<String> getRawSpotData(DataFeedDevice device) {
        Query query = em.createNativeQuery("select message_json from datafeed_raw_spot \n" +
                " where datafeed_detection_id in (select id from datafeed_detection \n" +
                "where datafeed_device_id = :deviceId)");
        query.setParameter("deviceId", device.getId());
        try {
            return query.getResultList();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    @Transactional
    public void save(DataFeedDevice object) {
        em.persist(object);
    }

    @Override
    @Transactional
    public DataFeedDevice update(DataFeedDevice object) {
        return em.merge(object);
    }

    @Override
    @Transactional
    public void delete(DataFeedDevice object) {
        em.remove(object);
    }


}
