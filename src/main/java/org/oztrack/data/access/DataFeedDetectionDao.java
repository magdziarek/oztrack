package org.oztrack.data.access;

import au.com.bytecode.opencsv.CSVWriter;
import org.oztrack.data.model.DataFeedDetection;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.Date;

@Service
public interface DataFeedDetectionDao {

    int saveRawArgosData(Long detectionId, Long programNumber, Long platformId, Calendar bestMessageDate, String satellitePassXml);

    //String getRawArgosData(Long platformId);

    void writeDataFeedDetectionsCsv(Long dataFeedId, CSVWriter csvWriter);

    void save(DataFeedDetection object);

    DataFeedDetection update(DataFeedDetection object);

    void delete(DataFeedDetection object);

}
