package org.oztrack.data.loader;

import org.apache.log4j.Logger;
import org.oztrack.data.access.DataFeedDao;
import org.oztrack.data.access.impl.DataFeedDaoImpl;
import org.oztrack.data.access.impl.ProjectDaoImpl;
import org.oztrack.data.model.DataFeed;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;
import java.util.List;


public class DataFeedPoller implements Runnable {

    protected final Logger logger = Logger.getLogger(getClass());

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    @Override
    public void run() {
        logger.info("Running");



        pollAllDataFeeds();

    }

    private void pollAllDataFeeds() {
        EntityManager entityManager = entityManagerFactory.createEntityManager();
        DataFeedDaoImpl dataFeedDao = new DataFeedDaoImpl();
        dataFeedDao.setEntityManger(entityManager);
        List<DataFeed> dataFeeds = dataFeedDao.getAllActiveDataFeeds();
        for (DataFeed dataFeed:dataFeeds) {
            if (dataFeed.getSourceSystem().equals("ARGOS")) {
                pollArgos(dataFeed);
            }

        }
    }

    private void pollArgos(DataFeed dataFeed) {

    }

}
