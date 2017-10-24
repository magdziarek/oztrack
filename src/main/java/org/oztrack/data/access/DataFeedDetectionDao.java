package org.oztrack.data.access;

import org.oztrack.data.model.DataFeedDetection;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public interface DataFeedDetectionDao {

    int saveRawArgosData(Long detectionId, Long programNumber, Long platformId, Date bestMessageDate, String satellitePassXml);

    //String getRawArgosData(Long platformId);

    void save(DataFeedDetection object);

    DataFeedDetection update(DataFeedDetection object);

    void delete(DataFeedDetection object);

}
