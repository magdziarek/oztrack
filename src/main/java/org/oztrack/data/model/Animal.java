package org.oztrack.data.model;

import com.vividsolutions.jts.geom.Point;
import org.hibernate.annotations.Type;

import java.util.LinkedList;
import java.util.List;
import java.util.Date;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;


@Entity(name="Animal")
public class Animal extends OzTrackBaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "animalid_seq")
    @SequenceGenerator(name = "animalid_seq", sequenceName = "animalid_seq", allocationSize = 1)
    @Column(nullable = false)
    private Long id;

    @Column(nullable = true)
    private String projectAnimalId;

    @Column(nullable = true)
    private String animalName;

    private String animalDescription;

    private String createDescription;

    @Column(name = "colour", nullable = true)
    private String colour;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Project project;

    @OneToMany(fetch = FetchType.LAZY, mappedBy = "animal", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PositionFix> positionFixes = new LinkedList<PositionFix>();

    @Column(columnDefinition = "TEXT")
    private String sex;

    @Column(columnDefinition = "TEXT")
    private String weight;

    @Column(columnDefinition = "TEXT")
    private String dimensions;

    @Column(columnDefinition = "TEXT")
    private String lifePhase;

    @Column(columnDefinition = "TEXT")
    private String tagIdentifier;

    @Column(columnDefinition = "TEXT")
    private String tagManufacturerModel;

    @Temporal(TemporalType.DATE)
    @Column(name = "capturedate")
    private Date captureDate;

    @Temporal(TemporalType.DATE)
    @Column(name = "releasedate")
    private Date releaseDate;

    @Column(name = "captureGeometry", columnDefinition = "GEOMETRY")
    @Type(type = "org.hibernatespatial.GeometryUserType")
    private Point captureGeometry;

    @Column(name = "releaseGeometry", columnDefinition = "GEOMETRY")
    @Type(type = "org.hibernatespatial.GeometryUserType")
    private Point releaseGeometry;

    private String captureLatitude;
    private String captureLongitude;
    private String releaseLatitude;
    private String releaseLongitude;

    @Temporal(TemporalType.DATE)
    @Column(name = "tagdeploystartdate")
    private Date tagDeployStartDate;

    @Temporal(TemporalType.DATE)
    @Column(name = "tagdeployenddate")
    private Date tagDeployEndDate;

    @Column(columnDefinition = "TEXT")
    private String experimentalContext;

    @Column(columnDefinition = "TEXT")
    private String tagAttachmentTechnique;

    @Column(columnDefinition = "TEXT")
    private String tagDimensions;

    @Column(columnDefinition = "TEXT")
    private String tagDutyCycleComments;

    private String stateOnDetachment;

    @Column(columnDefinition = "TEXT")
    private String dataRetrievalMethod;

    @Column(columnDefinition = "TEXT")
    private String dataManipulation;

    @Column(columnDefinition = "TEXT")
    private String tagDeploymentComments;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getProjectAnimalId() {
        return projectAnimalId;
    }

    public void setProjectAnimalId(String projectAnimalId) {
        this.projectAnimalId = projectAnimalId;
    }

    public String getAnimalName() {
        return animalName;
    }

    public void setAnimalName(String animalName) {
        this.animalName = animalName;
    }

    public String getAnimalDescription() {
        return animalDescription;
    }

    public void setAnimalDescription(String animalDescription) {
        this.animalDescription = animalDescription;
    }

    public String getCreateDescription() {
        return createDescription;
    }

    public void setCreateDescription(String createDescription) {
        this.createDescription = createDescription;
    }

    public String getColour() {
        return colour;
    }

    public void setColour(String colour) {
        this.colour = colour;
    }

    public Project getProject() {
        return project;
    }

    public void setProject(Project project) {
        this.project = project;
    }

    public List<PositionFix> getPositionFixes() {
        return positionFixes;
    }

    public void setPositionFixes(List<PositionFix> positionFixes) {
        this.positionFixes = positionFixes;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getWeight() {
        return weight;
    }

    public void setWeight(String weight) {
        this.weight = weight;
    }

    public String getDimensions() {
        return dimensions;
    }

    public void setDimensions(String dimensions) {
        this.dimensions = dimensions;
    }

    public String getLifePhase() {
        return lifePhase;
    }

    public void setLifePhase(String lifePhase) {
        this.lifePhase = lifePhase;
    }

    public String getTagIdentifier() {
        return tagIdentifier;
    }

    public void setTagIdentifier(String tagIdentifier) {
        this.tagIdentifier = tagIdentifier;
    }

    public String getTagManufacturerModel() {
        return tagManufacturerModel;
    }

    public void setTagManufacturerModel(String tagManufacturerModel) {
        this.tagManufacturerModel = tagManufacturerModel;
    }

    public Date getCaptureDate() {
        return captureDate;
    }

    public void setCaptureDate(Date captureDate) {
        this.captureDate = captureDate;
    }

    public Date getReleaseDate() {
        return releaseDate;
    }

    public void setReleaseDate(Date releaseDate) {
        this.releaseDate = releaseDate;
    }

    public Point getCaptureGeometry() {
        return captureGeometry;
    }

    public void setCaptureGeometry(Point captureGeometry) {
        this.captureGeometry = captureGeometry;
    }

    public Point getReleaseGeometry() {
        return releaseGeometry;
    }

    public void setReleaseGeometry(Point releaseGeometry) {
        this.releaseGeometry = releaseGeometry;
    }

    public String getCaptureLatitude() {
        return captureLatitude;
    }

    public void setCaptureLatitude(String captureLatitude) {
        this.captureLatitude = captureLatitude;
    }

    public String getCaptureLongitude() {
        return captureLongitude;
    }

    public void setCaptureLongitude(String captureLongitude) {
        this.captureLongitude = captureLongitude;
    }

    public String getReleaseLatitude() {
        return releaseLatitude;
    }

    public void setReleaseLatitude(String releaseLatitude) {
        this.releaseLatitude = releaseLatitude;
    }

    public String getReleaseLongitude() {
        return releaseLongitude;
    }

    public void setReleaseLongitude(String releaseLongitude) {
        this.releaseLongitude = releaseLongitude;
    }

    public Date getTagDeployStartDate() {
        return tagDeployStartDate;
    }

    public void setTagDeployStartDate(Date tagDeployStartDate) {
        this.tagDeployStartDate = tagDeployStartDate;
    }

    public Date getTagDeployEndDate() {
        return tagDeployEndDate;
    }

    public void setTagDeployEndDate(Date tagDeployEndDate) {
        this.tagDeployEndDate = tagDeployEndDate;
    }

    public String getExperimentalContext() {
        return experimentalContext;
    }

    public void setExperimentalContext(String experimentalContext) {
        this.experimentalContext = experimentalContext;
    }

    public String getTagAttachmentTechnique() {
        return tagAttachmentTechnique;
    }

    public void setTagAttachmentTechnique(String tagAttachmentTechnique) {
        this.tagAttachmentTechnique = tagAttachmentTechnique;
    }

    public String getTagDimensions() {
        return tagDimensions;
    }

    public void setTagDimensions(String tagDimensions) {
        this.tagDimensions = tagDimensions;
    }

    public String getTagDutyCycleComments() {
        return tagDutyCycleComments;
    }

    public void setTagDutyCycleComments(String tagDutyCycleComments) {
        this.tagDutyCycleComments = tagDutyCycleComments;
    }

    public String getStateOnDetachment() {
        return stateOnDetachment;
    }

    public void setStateOnDetachment(String stateOnDetachment) {
        this.stateOnDetachment = stateOnDetachment;
    }

    public String getDataRetrievalMethod() {
        return dataRetrievalMethod;
    }

    public void setDataRetrievalMethod(String dataRetrievalMethod) {
        this.dataRetrievalMethod = dataRetrievalMethod;
    }

    public String getDataManipulation() {
        return dataManipulation;
    }

    public void setDataManipulation(String dataManipulation) {
        this.dataManipulation = dataManipulation;
    }

    public String getTagDeploymentComments() {
        return tagDeploymentComments;
    }

    public void setTagDeploymentComments(String tagDeploymentComments) {
        this.tagDeploymentComments = tagDeploymentComments;
    }

}