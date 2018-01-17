package org.oztrack.data.access;

import org.oztrack.data.model.DataFeed;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface DataFeedDao {
    List<DataFeed> getAllActiveDataFeeds(DataFeedSourceSystem sourceSystem);

    String getSourceSystemCredentials(Long dataFeedId);

    void save(DataFeed object);

    DataFeed update(DataFeed object);

    void delete(DataFeed object);
}
