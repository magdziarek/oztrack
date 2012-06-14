package org.oztrack.data.access;

import java.util.Date;
import java.util.List;

import org.oztrack.data.model.DataFile;
import org.oztrack.data.model.PositionFix;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.SearchQuery;
import org.springframework.stereotype.Service;

@Service
public interface PositionFixDao {
    Page<PositionFix> getPage(SearchQuery searchQuery, int offset, int nbrObjectsPerPage);

    List<PositionFix> getProjectPositionFixList(SearchQuery searchQuery);
    List<PositionFix> queryProjectPositionFixes(SearchQuery searchQuery);
   
    Date getProjectFirstDetectionDate(Project project); //not used
    Date getProjectLastDetectionDate(Project project); // not used

    Date getDataFileFirstDetectionDate(DataFile dataFile);
    Date getDataFileLastDetectionDate(DataFile dataFile);
}