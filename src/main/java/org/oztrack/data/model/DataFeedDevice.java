package org.oztrack.data.model;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "datafeed_device")
public class DataFeedDevice {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "datafeed_device_id_seq")
    @SequenceGenerator(name = "datafeed_device_id_seq", sequenceName = "datafeed_device_id_seq", allocationSize = 1)
    @Column(nullable=false)
    private Long id;

    @ManyToOne
    @JoinColumn(name="datafeed_id", nullable=false)
    private DataFeed dataFeed;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Project project;

    @ManyToOne
    @JoinColumn(name="animal_id", nullable=false)
    private Animal animal;

    @Column(name = "device_identifier")
    private String deviceIdentifier;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "create_date")
    private Date createDate;

    @OneToMany(mappedBy = "dataFeedDevice", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<DataFeedDetection> detections = new ArrayList<DataFeedDetection>();

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DataFeed getDataFeed() {
        return dataFeed;
    }

    public void setDataFeed(DataFeed dataFeed) {
        this.dataFeed = dataFeed;
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

    public String getDeviceIdentifier() {
        return deviceIdentifier;
    }

    public void setDeviceIdentifier(String deviceIdentifier) {
        this.deviceIdentifier = deviceIdentifier;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public List<DataFeedDetection> getDetections() {
        return detections;
    }

    public void setDetections(List<DataFeedDetection> detections) {
        this.detections = detections;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof DataFeedDevice)) {
            return false;
        }
        DataFeedDevice other = (DataFeedDevice) obj;
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
