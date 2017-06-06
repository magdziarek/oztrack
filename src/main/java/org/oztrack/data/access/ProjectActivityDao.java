package org.oztrack.data.access;

import org.oztrack.data.model.ProjectActivity;
import org.springframework.stereotype.Service;

@Service
public interface ProjectActivityDao {
    void save(ProjectActivity activity);
}
