package org.oztrack.data.access;

import org.oztrack.data.model.Doi;
import org.oztrack.data.model.Project;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface DoiDao  {

    Doi getInProgressDoi(Project project);
    Doi getDoiById(Long id);
    List<Doi> getDoisByProject(Project project);
    List<Doi> getCompletedDoisByProject(Project project);
    void save(Doi doi);
    Doi update(Doi doi);
    void delete(Doi doi);


}
