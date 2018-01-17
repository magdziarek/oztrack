package org.oztrack.data.access.impl;

import org.oztrack.data.access.DataFeedDao;
import org.oztrack.data.model.DataFeed;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.List;

@Service
public class DataFeedDaoImpl implements DataFeedDao {

    private EntityManager em;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Override
    public String getSourceSystemCredentials(Long dataFeedId) {
        // these are not persisted in the datafeed object
        return (String) em.createNativeQuery("select source_system_credentials from datafeed where id = :id")
                .setParameter("id", dataFeedId)
                .getSingleResult();
    }

    @Override
    public List<DataFeed> getAllActiveDataFeeds(DataFeedSourceSystem sourceSystem) {
        List<DataFeed> resultList = em.createQuery(
                "select o \n" +
                        "from DataFeed o \n" +
                        "where activeFlag = true \n" +
                        "and dataFeedSourceSystem = :sourceSystem"
        ).setParameter("sourceSystem", sourceSystem)
                .getResultList();
        return resultList;
    }

    @Override
    @Transactional
    public void save(DataFeed object) {
        em.persist(object);
    }

    @Override
    @Transactional
    public DataFeed update(DataFeed object) {
        return em.merge(object);
    }

    @Override
    @Transactional
    public void delete(DataFeed dataFeed) {
        em.remove(dataFeed);
    }
}
