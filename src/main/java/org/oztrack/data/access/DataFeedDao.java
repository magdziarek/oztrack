package org.oztrack.data.access;

import org.oztrack.data.model.DataFeed;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface DataFeedDao {
    List<DataFeed> getAllActiveDataFeeds();

}
