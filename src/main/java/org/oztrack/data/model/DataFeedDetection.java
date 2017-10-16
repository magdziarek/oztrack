package org.oztrack.data.model;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "datafeed_detection", uniqueConstraints = @UniqueConstraint(columnNames = {"project_id", "datafeed_device_id", "detection_date"}))
public class DataFeedDetection {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "datafeed_detection_id_seq")
    @SequenceGenerator(name = "datafeed_detection_id_seq", sequenceName = "datafeed_detection_id_seq", allocationSize = 1)
    @Column(nullable = false)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "datafeed_device_id", nullable = false)
    private DataFeedDevice dataFeedDevice;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Project project;

    @ManyToOne
    @JoinColumn(name = "animal_id", nullable = false)
    private Animal animal;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "detection_date")
    private Date detectionDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "location_date")
    private Date locationDate;

    // a detection from argos may just be a detection time without a position fix
    @OneToOne
    @JoinColumn(name = "positionfix_id", nullable = true)
    private PositionFix positionFix;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "poll_date")
    private Date pollDate;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DataFeedDevice getDataFeedDevice() {
        return dataFeedDevice;
    }

    public void setDataFeedDevice(DataFeedDevice dataFeedDevice) {
        this.dataFeedDevice = dataFeedDevice;
    }

    public Project getProject() {
        return project;
    }

    public void setProject(Project project) {
        this.project = project;
    }

    public Animal getAnimal() {
        return animal;
    }

    public void setAnimal(Animal animal) {
        this.animal = animal;
    }

    public Date getDetectionDate() {
        return detectionDate;
    }

    public void setDetectionDate(Date detectionDate) {
        this.detectionDate = detectionDate;
    }

    public Date getLocationDate() {
        return locationDate;
    }

    public void setLocationDate(Date locationDate) {
        this.locationDate = locationDate;
    }

    public PositionFix getPositionFix() {
        return positionFix;
    }

    public void setPositionFix(PositionFix positionFix) {
        this.positionFix = positionFix;
    }

    public Date getPollDate() {
        return pollDate;
    }

    public void setPollDate(Date pollDate) {
        this.pollDate = pollDate;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof DataFeedDetection)) {
            return false;
        }
        DataFeedDetection other = (DataFeedDetection) obj;
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
