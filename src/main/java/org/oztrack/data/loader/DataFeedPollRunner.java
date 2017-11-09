package org.oztrack.data.loader;

import org.apache.log4j.Logger;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.app.OzTrackConfigurationImpl;
import org.oztrack.data.access.impl.DoiDaoImpl;
import org.oztrack.data.model.User;
import org.oztrack.error.DataFeedException;
import org.oztrack.util.EmailBuilder;
import org.oztrack.util.EmailBuilderFactory;

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
        try {
            argosPoller.poll();
        } catch (DataFeedException d) {
            logger.error("Argos Poll error: " + d.getMessage());
            sendErrorNotification(entityManager, d);

        }
    }

    private void sendErrorNotification(EntityManager em, DataFeedException dfe) {
        DoiDaoImpl doiDao = new DoiDaoImpl();
        doiDao.setEntityManger(em);
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
