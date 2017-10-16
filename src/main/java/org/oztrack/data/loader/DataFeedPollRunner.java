package org.oztrack.data.loader;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;

public class DataFeedPollRunner {

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    public DataFeedPollRunner() {
    }

    public void pollAllDataFeeds() throws Exception {
        EntityManager entityManager = entityManagerFactory.createEntityManager();
        ArgosPoller argosPoller = new ArgosPoller(entityManager);
        argosPoller.poll();
    }

}
