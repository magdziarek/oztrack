package org.oztrack.data.access;

import fr.cls.argos.SatellitePass;
import org.oztrack.data.model.DataFeedDevice;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public interface DataFeedDeviceDao {

    DataFeedDevice getDataFeedDeviceByIdentifier(Long datafeed_id, String deviceIdentifier);

    Date getDeviceLatestDetectionDate(DataFeedDevice device);

    DataFeedDevice getDeviceById(Long id);

    List<String> getRawArgosData(DataFeedDevice device);

    void save(DataFeedDevice object);

    DataFeedDevice update(DataFeedDevice object);

    void delete(DataFeedDevice object);

}
