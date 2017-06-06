package org.oztrack.data.model;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name="project_activity")
public class ProjectActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "projectactivityid_seq")
    @SequenceGenerator(name = "projectactivityid_seq", sequenceName = "projectactivityid_seq", allocationSize = 1)
    @Column(nullable = false)
    private Long id;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Project project;

    @ManyToOne
    @JoinColumn(name = "appuser_id", nullable = false)
    private User user;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "activitydate", nullable = false)
    private Date activityDate;

    @Column(name = "activitytype", nullable = false)
    private String activityType;

    @Column(name = "activitycode", nullable = false)
    private String activityCode;

    @Column(name = "activitydescr", columnDefinition = "TEXT", nullable = false)
    private String activityDescription;


    @Column(name = "user_ip", columnDefinition = "TEXT")
    private String userIp;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Project getProject() {
        return project;
    }

    public void setProject(Project project) {
        this.project = project;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Date getActivityDate() {
        return activityDate;
    }

    public void setActivityDate(Date activityDate) {
        this.activityDate = activityDate;
    }

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public String getActivityCode() {
        return activityCode;
    }

    public void setActivityCode(String activityCode) {
        this.activityCode = activityCode;
    }

    public String getActivityDescription() {
        return activityDescription;
    }

    public void setActivityDescription(String activityDescription) {
        this.activityDescription = activityDescription;
    }

    public String getUserIp() {
        return userIp;
    }

    public void setUserIp(String userIp) {
        this.userIp = userIp;
    }

}
