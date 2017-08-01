package org.oztrack.data.model;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Entity(name="datafeed")
public class DataFeed extends OzTrackBaseEntity {

    @Id
    @GeneratedValue(strategy= GenerationType.SEQUENCE, generator="datafeedid_seq")
    @SequenceGenerator(name="datafeedid_seq", sequenceName="datafeedid_seq",allocationSize=1)
    @Column(nullable=false)
    private Long id;

    @ManyToOne(fetch=FetchType.LAZY, cascade={}) //persist project yourself
    @JoinColumn(nullable=false)
    private Project project;

    // a feed could have more than one animal; could change tags
    @OneToMany(mappedBy="dataFeed", cascade={CascadeType.ALL}, orphanRemoval=true, fetch=FetchType.EAGER)
    @OrderColumn(name="createdate", nullable=false)
    private List<Animal> animals = new ArrayList<Animal>();

    private String sourceSystem;
    private String sourceSystemIdentifier;
    private String sourceSystemUser;
    private String sourceSystemUuid;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="active_date")
    private Date activeDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="deactive_date")
    private Date deactiveDate;

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

    public List<Animal> getAnimals() {
        return animals;
    }

    public void setAnimals(List<Animal> animals) {
        this.animals = animals;
    }

    public String getSourceSystem() {
        return sourceSystem;
    }

    public void setSourceSystem(String sourceSystem) {
        this.sourceSystem = sourceSystem;
    }

    public String getSourceSystemIdentifier() {
        return sourceSystemIdentifier;
    }

    public void setSourceSystemIdentifier(String sourceSystemIdentifier) {
        this.sourceSystemIdentifier = sourceSystemIdentifier;
    }

    public String getSourceSystemUser() {
        return sourceSystemUser;
    }

    public void setSourceSystemUser(String sourceSystemUser) {
        this.sourceSystemUser = sourceSystemUser;
    }

    public String getSourceSystemUuid() {
        return sourceSystemUuid;
    }

    public void setSourceSystemUuid(String sourceSystemUuid) {
        this.sourceSystemUuid = sourceSystemUuid;
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

}
