package org.oztrack.data.access;

import org.oztrack.data.model.DataFeedDevice;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public interface DataFeedDeviceDao {

    DataFeedDevice getDataFeedDeviceByIdentifier(Long datafeed_id, String deviceIdentifier);

    Date getDeviceLatestDetectionDate(DataFeedDevice device);

    void save(DataFeedDevice object);

    DataFeedDevice update(DataFeedDevice object);

    void delete(DataFeedDevice object);

}
