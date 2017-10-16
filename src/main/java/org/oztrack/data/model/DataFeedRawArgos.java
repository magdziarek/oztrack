package org.oztrack.data.model;


import fr.cls.argos.SatellitePass;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "datafeed_raw_argos")
public class DataFeedRawArgos {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "datafeed_raw_argos_id_seq")
    @SequenceGenerator(name = "datafeed_raw_argos_id_seq", sequenceName = "datafeed_raw_argos_id_seq", allocationSize = 1)
    @Column(nullable = false)
    private Long id;

    @OneToOne
    @JoinColumn(name = "datafeed_detection_id", nullable = false)
    private DataFeedDetection dataFeedDetection;

    @Column(name = "program_number", columnDefinition = "bigint")
    private Long programNumber;

    @Column(name = "platform_id", columnDefinition = "bigint")
    private Long platformId;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "best_message_date")
    private Date bestMessageDate;

    @Column(name = "satellite_pass_xml", columnDefinition = "TEXT")
    private String satellitePassXml;

    @Transient
    private SatellitePass satellitePass;

    public DataFeedDetection getDataFeedDetection() {
        return dataFeedDetection;
    }

    public void setDataFeedDetection(DataFeedDetection dataFeedDetection) {
        this.dataFeedDetection = dataFeedDetection;
    }

    public Long getProgramNumber() {
        return programNumber;
    }

    public void setProgramNumber(Long programNumber) {
        this.programNumber = programNumber;
    }

    public Long getPlatformId() {
        return platformId;
    }

    public void setPlatformId(Long platformId) {
        this.platformId = platformId;
    }

    public Date getBestMessageDate() {
        return bestMessageDate;
    }

    public void setBestMessageDate(Date bestMessageDate) {
        this.bestMessageDate = bestMessageDate;
    }

    public String getSatellitePassXml() {
        return satellitePassXml;
    }

    public void setSatellitePassXml(String satellitePassXml) {
        this.satellitePassXml = satellitePassXml;
    }

    public SatellitePass getSatellitePass() {
        return this.satellitePass;
    }

    public void setSatellitePass(SatellitePass satellitePass) {
        this.satellitePass = satellitePass;
    }

}
