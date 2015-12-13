package org.oztrack.data.model;

import org.oztrack.data.model.types.DoiStatus;

import javax.persistence.*;

import java.util.Date;
import java.util.UUID;

import static javax.persistence.EnumType.STRING;

@Entity(name="Doi")
public class Doi extends OzTrackBaseEntity {

    @Id
    @GeneratedValue(strategy= GenerationType.SEQUENCE, generator="doiid_seq")
    @SequenceGenerator(name="doiid_seq", sequenceName="doiid_seq",allocationSize=1)
    @Column(nullable=false)
    private Long id;

    @Enumerated(STRING)
    @Column(name="status")
    private DoiStatus status;

    @ManyToOne(fetch=FetchType.LAZY, cascade={}) //persist project yourself
    @JoinColumn(nullable=false)
    private Project project;

    private String doi;
    private String xml;
    private String url;

    @Column(name="uuid", unique=true, nullable=false)
    @org.hibernate.annotations.Type(type="org.hibernate.type.PostgresUUIDType")
    private UUID uuid;

    private String filename;
    private String citation;
    private boolean published;
    private String title;
    private String creators;

    @Temporal(TemporalType.TIMESTAMP)
    private Date draftDate;
    @Temporal(TemporalType.TIMESTAMP)
    private Date submitDate;
    @Temporal(TemporalType.TIMESTAMP)
    private Date cancelDate;
    @Temporal(TemporalType.TIMESTAMP)
    private Date rejectDate;
    @Temporal(TemporalType.TIMESTAMP)
    private Date mintDate;
    @Temporal(TemporalType.TIMESTAMP)
    private Date mintUpdateDate;

    private String rejectMessage;
    private String mintResponse;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DoiStatus getStatus() {
        return status;
    }

    public void setStatus(DoiStatus status) {
        this.status = status;
    }

    public Project getProject() {
        return project;
    }

    public void setProject(Project project) {
        this.project = project;
    }

    public String getDoi() {
        return doi;
    }

    public void setDoi(String doi) {
        this.doi = doi;
    }

    public String getXml() {
        return xml;
    }

    public void setXml(String xml) {
        this.xml = xml;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public UUID getUuid() {
        return uuid;
    }

    public void setUuid(UUID uuid) {
        this.uuid = uuid;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getCitation() {
        return citation;
    }

    public void setCitation(String citation) {
        this.citation = citation;
    }

    public Date getDraftDate() {
        return draftDate;
    }

    public boolean isPublished() { return published; }

    public void setPublished(boolean published) { this.published = published; }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCreators() {
        return creators;
    }

    public void setCreators(String creators) {
        this.creators = creators;
    }

    public void setDraftDate(Date draftDate) { this.draftDate = draftDate; }

    public Date getSubmitDate() {
        return submitDate;
    }

    public void setSubmitDate(Date submitDate) {
        this.submitDate = submitDate;
    }

    public Date getCancelDate() {
        return cancelDate;
    }

    public void setCancelDate(Date cancelDate) {
        this.cancelDate = cancelDate;
    }

    public Date getRejectDate() {
        return rejectDate;
    }

    public void setRejectDate(Date rejectDate) {
        this.rejectDate = rejectDate;
    }

    public Date getMintDate() {
        return mintDate;
    }

    public void setMintDate(Date mintDate) {
        this.mintDate = mintDate;
    }

    public Date getMintUpdateDate() {
        return mintUpdateDate;
    }

    public void setMintUpdateDate(Date mintUpdateDate) {
        this.mintUpdateDate = mintUpdateDate;
    }

    public String getRejectMessage() {
        return rejectMessage;
    }

    public void setRejectMessage(String rejectMessage) {
        this.rejectMessage = rejectMessage;
    }

    public String getMintResponse() {
        return mintResponse;
    }

    public void setMintResponse(String mintResponse) {
        this.mintResponse = mintResponse;
    }
}
