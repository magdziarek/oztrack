package org.oztrack.data.model;

import javax.xml.bind.annotation.*;
import javax.xml.datatype.XMLGregorianCalendar;

@XmlRootElement(name = "platform")
@XmlAccessorType(XmlAccessType.FIELD)
public class ArgosPlatformSummary {

    @XmlElement
    private Integer platformId;
    @XmlElement
    private String lastLocationClass;
    @XmlElement
    @XmlSchemaType(name = "dateTime")
    private XMLGregorianCalendar lastLocationDate;
    @XmlElement
    @XmlSchemaType(name = "dateTime")
    private XMLGregorianCalendar lastCollectDate;
    @XmlElement
    private Double lastLatitude;
    @XmlElement
    private Double lastLongitude;

    public Integer getPlatformId() {
        return platformId;
    }

    public void setPlatformId(Integer platformId) {
        this.platformId = platformId;
    }

    public String getLastLocationClass() {
        return lastLocationClass;
    }

    public void setLastLocationClass(String lastLocationClass) {
        this.lastLocationClass = lastLocationClass;
    }

    public XMLGregorianCalendar getLastLocationDate() {
        return lastLocationDate;
    }

    public void setLastLocationDate(XMLGregorianCalendar lastLocationDate) {
        this.lastLocationDate = lastLocationDate;
    }

    public XMLGregorianCalendar getLastCollectDate() {
        return lastCollectDate;
    }

    public void setLastCollectDate(XMLGregorianCalendar lastCollectDate) {
        this.lastCollectDate = lastCollectDate;
    }

    public Double getLastLatitude() {
        return lastLatitude;
    }

    public void setLastLatitude(Double lastLatitude) {
        this.lastLatitude = lastLatitude;
    }

    public Double getLastLongitude() {
        return lastLongitude;
    }

    public void setLastLongitude(Double lastLongitude) {
        this.lastLongitude = lastLongitude;
    }

}
