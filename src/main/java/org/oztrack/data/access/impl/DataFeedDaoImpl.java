package org.oztrack.data.access.impl;

import org.oztrack.data.access.DataFeedDao;
import org.oztrack.data.model.Animal;
import org.oztrack.data.model.DataFeed;
import org.springframework.stereotype.Service;

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

    public List<DataFeed> getAllActiveDataFeeds() {
        List<DataFeed> resultList = em.createQuery(
                                "select distinct datafeed\n" +
                                "from DataFeed as datafeed\n" +
                                "where datafeed.activeFlag = true"
                )
                .getResultList();
        return resultList;
    };
}
