package org.oztrack.app;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.EntityTransaction;
import javax.persistence.PersistenceUnit;

import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.oztrack.data.access.ProjectActivityDao;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.access.UserDao;
import org.oztrack.data.access.impl.ProjectDaoImpl;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.ProjectActivity;
import org.oztrack.data.model.User;
import org.oztrack.data.model.types.ProjectAccess;
import org.oztrack.util.EmailBuilder;
import org.oztrack.util.EmailBuilderFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EmbargoUpdater implements Runnable {

    private final Logger logger = Logger.getLogger(getClass());
    private final SimpleDateFormat isoDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    public static final int embargoNotificationMonths = 2;

    @Autowired
    private OzTrackConfiguration configuration;

    @Autowired
    private EmailBuilderFactory emailBuilderFactory;

    @Autowired
    private UserDao userDao;

    @Autowired
    private ProjectActivityDao projectActivityDao;

    @PersistenceUnit
    private EntityManagerFactory entityManagerFactory;

    public EmbargoUpdater() {
    }

    @Override
    public void run() {
        logger.info("running embargoupdater ");
        EntityManager entityManager = entityManagerFactory.createEntityManager();
        ProjectDaoImpl projectDao = new ProjectDaoImpl();
        projectDao.setEntityManger(entityManager);
        Date currentDate = new Date();
        endEmbargo(entityManager, projectDao, currentDate);
        sendNotifications(entityManager, projectDao, currentDate);
    }

    private void endEmbargo(EntityManager entityManager, ProjectDaoImpl projectDao, Date currentDate) {
        List<Project> projects = projectDao.getProjectsWithExpiredEmbargo(currentDate);
        for (Project project : projects) {
            EntityTransaction transaction = entityManager.getTransaction();
            transaction.begin();
            try {
                project.setAccess(ProjectAccess.OPEN);
                project.setUpdateDate(currentDate);
                project.setUpdateDateForOaiPmh(currentDate);
                //project.setUpdateUser(project.getUpdateUser());
                projectDao.update(project);
                transaction.commit();

                String projectLink = configuration.getBaseUrl() + "/projects/" + project.getId();
                StringBuilder htmlMsgContent = new StringBuilder();
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    Please note that your ZoaTrack project,\n");
                htmlMsgContent.append("    <i>" + project.getTitle() + "</i>,\n");
                htmlMsgContent.append("    has <b>ended its embargo period</b>.\n");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    Data in this project are now publicly available in ZoaTrack.\n");
                htmlMsgContent.append("</p>");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    To view your project, click here:\n");
                htmlMsgContent.append("    <a href=\"" + projectLink + "\">" + projectLink + "</a>\n");
                htmlMsgContent.append("</p>\n");

                String emailDetails = "Email to: " + project.getCreateUser().getFullName() + "(" + project.getCreateUser().getEmail() + ")";
                logger.info("Making project " + project.getId() + " open access " +
                                "(embargo expired " + isoDateFormat.format(project.getEmbargoDate()) + "). " + emailDetails);
                if (!configuration.getTestServer()) {
                    EmailBuilder emailBuilder = emailBuilderFactory.getObject();
                    emailBuilder.to(project.getCreateUser());
                    emailBuilder.subject("ZoaTrack project embargo ended");
                    emailBuilder.htmlMsgContent(htmlMsgContent.toString());
                    emailBuilder.build().send();
                }

                ProjectActivity activity = new ProjectActivity();
                activity.setActivityType("embargo");
                activity.setActivityCode("expiry");
                activity.setActivityDescription(emailDetails + "||" + htmlMsgContent.toString());
                activity.setActivityDate(currentDate);
                activity.setProject(project);
                activity.setUser(userDao.getByUsername("admin"));
                projectActivityDao.save(activity);
            }
            catch (Exception e) {
                logger.error("Exception in embargo updater", e);
                try {transaction.rollback();} catch (Exception e2) {}
            }
        }
    }

    private void sendNotifications(EntityManager entityManager, ProjectDaoImpl projectDao, Date currentDate) {
        Calendar expiryCalendar = new GregorianCalendar();
        expiryCalendar.setTime(currentDate);
        expiryCalendar.add(Calendar.MONTH, EmbargoUpdater.embargoNotificationMonths);
        Date expiryDate = DateUtils.truncate(expiryCalendar.getTime(), Calendar.DATE);
        List<Project> projects = projectDao.getProjectsWithExpiredEmbargo(expiryDate);

        for (Project project : projects) {
            // Don't send notifications for projects already at end of embargo period.
            // These should be picked up by the endEmbargo updater, which sends its own notification.
            if (!currentDate.before(project.getEmbargoDate())) {
                continue;
            }
            // If notification has been sent for an earlier or equal expiry date, e.g. a one-week
            // notification has been sent and we're preparing to send two-month notifications here,
            // then skip this project. It doesn't make sense to send both if we are already in the
            // shorter period before expiry due to the scheduler not being run for a while - or to
            // send duplicate notifications for the same date.
            if ((project.getEmbargoNotificationDate() != null) && !expiryDate.before(project.getEmbargoNotificationDate())) {
                continue;
            }
            EntityTransaction transaction = entityManager.getTransaction();
            transaction.begin();
            try {
                String projectLink = configuration.getBaseUrl() + "/projects/" + project.getId();
                String projectEditLink = projectLink + "/edit#accessrights";

                StringBuilder htmlMsgContent = new StringBuilder();
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    Please note that your ZoaTrack project,\n");
                htmlMsgContent.append("    <i>" + project.getTitle() + "</i>,\n");
                htmlMsgContent.append("    will <b>end its embargo period</b> on " + isoDateFormat.format(project.getEmbargoDate()) + ".\n");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    Starting from this date, data in the project will be made publicly available in ZoaTrack.\n");
                htmlMsgContent.append("</p>");
                htmlMsgContent.append("<p style=\"color: #666;\">\n");
                htmlMsgContent.append("    <b>Extending the embargo period</b>\n");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    If necessary, you can extend the embargo period by another year \n");
                htmlMsgContent.append("    to " + isoDateFormat.format(DateUtils.addYears(project.getEmbargoDate(),1)) + ".\n");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("You can continue to extend the embargo period each year. We will notify you " + embargoNotificationMonths
                        + " months in advance of the embargo expiry date. If the embargo period is not extended, the project will become open access.");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    To update your project, and extend the embargo, click here (you will need to log in):\n");
                htmlMsgContent.append("    <a href=\"" + projectEditLink + "\">" + projectEditLink + "</a>\n");
                htmlMsgContent.append("</p>\n");
                htmlMsgContent.append("<p>\n");
                htmlMsgContent.append("    To view your project, click here:\n");
                htmlMsgContent.append("    <a href=\"" + projectLink + "\">" + projectLink + "</a>\n");
                htmlMsgContent.append("</p>\n");

                String emailDetails = "Email to: " + project.getCreateUser().getFullName() + "(" + project.getCreateUser().getEmail() + ")";
                logger.info("Sending notification for project " + project.getId() + " " +
                                "(embargo expires " + isoDateFormat.format(project.getEmbargoDate()) + "). " + emailDetails);

                if (!configuration.getTestServer()) {
                    EmailBuilder emailBuilder = emailBuilderFactory.getObject();
                    emailBuilder.to(project.getCreateUser());
                    emailBuilder.subject("ZoaTrack project embargo ending");
                    emailBuilder.htmlMsgContent(htmlMsgContent.toString());
                    emailBuilder.build().send();
                }

                project.setEmbargoNotificationDate(expiryDate);
                projectDao.update(project);
                transaction.commit();

                ProjectActivity activity = new ProjectActivity();
                activity.setActivityType("embargo");
                activity.setActivityCode("notify");
                activity.setActivityDescription(emailDetails + "||" + htmlMsgContent.toString());
                activity.setActivityDate(currentDate);
                activity.setProject(project);
                activity.setUser(userDao.getByUsername("admin"));
                projectActivityDao.save(activity);

            }
            catch (Exception e) {
                logger.error("Exception in embargo notifier", e);
                try {transaction.rollback();} catch (Exception e2) {}
            }
        }
    }
}