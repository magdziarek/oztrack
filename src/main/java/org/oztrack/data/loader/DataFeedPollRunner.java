package org.oztrack.data.loader;

import org.apache.log4j.Logger;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;

public class DataFeedPollRunner {

    protected final Logger logger = Logger.getLogger(getClass());

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    public DataFeedPollRunner() {
    }

    public void pollAllDataFeeds() {
        EntityManager entityManager = entityManagerFactory.createEntityManager();
        ArgosPoller argosPoller = new ArgosPoller(entityManager);
        argosPoller.poll();
        SpotPoller spotPoller = new SpotPoller(entityManager);
        spotPoller.poll();
    }

}
