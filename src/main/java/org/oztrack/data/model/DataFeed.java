package org.oztrack.data.model;

import org.oztrack.data.model.types.DataFeedSourceSystem;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import static javax.persistence.EnumType.STRING;

@Entity
@Table(name = "datafeed")
public class DataFeed extends OzTrackBaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "datafeed_id_seq")
    @SequenceGenerator(name = "datafeed_id_seq", sequenceName = "datafeed_id_seq", allocationSize = 1)
    @Column(nullable=false)
    private Long id;

    @ManyToOne
    @JoinColumn(nullable=false)
    private Project project;

    @Enumerated(STRING)
    @Column(name = "source_system")
    private DataFeedSourceSystem dataFeedSourceSystem;

    private transient String sourceSystemCredentials;

    @Column(name = "poll_frequency_hours")
    private Long pollFrequencyHours;

    @Column(name = "active_flag")
    private boolean activeFlag;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="active_date")
    private Date activeDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="deactive_date")
    private Date deactiveDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "last_poll_date")
    private Date lastPollDate;

    @OneToMany(mappedBy = "dataFeed", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<DataFeedDevice> devices = new ArrayList<DataFeedDevice>();

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

    public DataFeedSourceSystem getDataFeedSourceSystem() {
        return dataFeedSourceSystem;
    }

    public void setDataFeedSourceSystem(DataFeedSourceSystem dataFeedSourceSystem) {
        this.dataFeedSourceSystem = dataFeedSourceSystem;
    }

    public String getSourceSystemCredentials() {
        return sourceSystemCredentials;
    }

    public void setSourceSystemCredentials(String sourceSystemCredentials) {
        this.sourceSystemCredentials = sourceSystemCredentials;
    }

    public Long getPollFrequencyHours() {
        return pollFrequencyHours;
    }

    public void setPollFrequencyHours(Long pollFrequencyHours) {
        this.pollFrequencyHours = pollFrequencyHours;
    }

    public boolean isActiveFlag() {
        return activeFlag;
    }

    public void setActiveFlag(boolean activeFlag) {
        this.activeFlag = activeFlag;
    }

    public Date getActiveDate() {
        return activeDate;
    }

    public void setActiveDate(Date activeDate) {
        this.activeDate = activeDate;
    }

    public Date getDeactiveDate() {
        return deactiveDate;
    }

    public void setDeactiveDate(Date deactiveDate) {
        this.deactiveDate = deactiveDate;
    }

    public Date getLastPollDate() {
        return lastPollDate;
    }

    public void setLastPollDate(Date lastPollDate) {
        this.lastPollDate = lastPollDate;
    }

    public List<DataFeedDevice> getDevices() {
        return devices;
    }

    public void setDevices(List<DataFeedDevice> devices) {
        this.devices = devices;
    }

    public Date getNextPollDate() {
        Calendar c = Calendar.getInstance();
        if (this.lastPollDate != null) {
            c.setTime(this.lastPollDate);
            c.add(Calendar.HOUR, this.pollFrequencyHours.intValue());
        } else {
            c.setTime(new java.util.Date());
        }
        return c.getTime();
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof DataFeed)) {
            return false;
        }
        DataFeed other = (DataFeed) obj;
        return getId().equals(other.getId());
    }

    @Override
    public int hashCode() {
        if (id != null) {
            return id.hashCode();
        } else {
            return super.hashCode();
        }
    }

}
