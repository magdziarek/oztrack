package org.oztrack.data.access.impl;

import org.oztrack.data.access.DataFeedDetectionDao;
import org.oztrack.data.model.DataFeedDetection;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.*;
import java.util.Calendar;
import java.util.Date;

@Service
public class DataFeedDetectionDaoImpl implements DataFeedDetectionDao {

    private EntityManager em;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Override
    @Transactional
    public int saveRawArgosData(Long detectionId, Long programNumber, Long platformId, Calendar bestMessageDate, String satellitePassXml) {

        String sql = "insert into datafeed_raw_argos(" +
                " id " +
                ",datafeed_detection_id " +
                ",program_number " +
                ",platform_id " +
                ",best_message_date " +
                ",satellite_pass_xml)" +
                "select nextval('datafeed_raw_argos_id_seq') " +
                ", :detectionId " +
                ", :programNumber " +
                ", :platformId " +
                ", :bestMessageDate" +
                ", :satellitePassXml ;";

        EntityTransaction transaction = em.getTransaction();
        transaction.begin();

        int r = em.createNativeQuery(sql)
                .setParameter("detectionId", detectionId)
                .setParameter("programNumber", programNumber)
                .setParameter("platformId", platformId)
                .setParameter("bestMessageDate", bestMessageDate, TemporalType.TIMESTAMP)
                .setParameter("satellitePassXml", satellitePassXml)
                .executeUpdate();

        transaction.commit();

        return r;
    }

    @Override
    @Transactional
    public void save(DataFeedDetection object) {
        em.persist(object);
    }

    @Override
    @Transactional
    public DataFeedDetection update(DataFeedDetection object) {
        return em.merge(object);
    }

    @Override
    @Transactional
    public void delete(DataFeedDetection object) {
        em.remove(object);
    }
}
