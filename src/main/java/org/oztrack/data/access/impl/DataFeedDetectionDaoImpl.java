package org.oztrack.data.access.impl;

import au.com.bytecode.opencsv.CSVWriter;
import org.oztrack.data.access.DataFeedDetectionDao;
import org.oztrack.data.model.DataFeedDetection;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.*;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

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


    @Transactional
    public int saveRawSpotData(Long detectionId, String messengerId, String messengerName, Calendar dateTime, String messageJson) {

        String sql = "insert into datafeed_raw_spot(" +
                " id " +
                ",datafeed_detection_id " +
                ",messenger_id " +
                ",messenger_name " +
                ",message_date_time " +
                ",message_json)" +
                "select nextval('datafeed_raw_spot_id_seq') " +
                ", :detectionId " +
                ", :messengerId " +
                ", :messengerName " +
                ", :dateTime" +
                ", :messageJson ;";

        EntityTransaction transaction = em.getTransaction();
        transaction.begin();

        int r = em.createNativeQuery(sql)
                .setParameter("detectionId", detectionId)
                .setParameter("messengerId", messengerId)
                .setParameter("messengerName", messengerName)
                .setParameter("dateTime", dateTime, TemporalType.TIMESTAMP)
                .setParameter("messageJson", messageJson)
                .executeUpdate();

        transaction.commit();

        return r;
    }

    @Override
    public void writeDataFeedDetectionsCsv(Long dataFeedId, CSVWriter csvWriter) {
        String[] headers = {"animal_id", "device_ident", "detection_date", "location_date", "poll_date"};
        csvWriter.writeNext(headers);

        String queryString = "select dev.animal_id\n" +
                ", dev.device_identifier as device_id\n" +
                ", to_char(detection_date, 'yyyy-mm-dd hh24:mi:ss') as detection_date\n" +
                ", to_char(location_date, 'yyyy-mm-dd hh24:mi:ss') as location_date\n" +
                ", to_char(poll_date, 'yyyy-mm-dd hh24') as poll_date\n" +
                "from datafeed_detection det \n" +
                "inner join datafeed_device dev \n" +
                "on det.datafeed_device_id = dev.id \n" +
                "and dev.datafeed_id = :dataFeedId\n";
        Query query = em.createNativeQuery(queryString).setParameter("dataFeedId", dataFeedId);
        writeCsv(query, csvWriter);
    }

    private void writeCsv(Query query, CSVWriter csvWriter) {
        @SuppressWarnings("unchecked")
        List<Object[]> resultList = query.getResultList();
        for (Object[] o : resultList) {
            String[] s = new String[o.length];
            for (int i = 0; i < o.length; i++) {
                s[i] = (o[i] != null) ? o[i].toString() : "";
            }
            csvWriter.writeNext(s);
        }
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
