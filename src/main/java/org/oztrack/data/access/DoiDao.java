package org.oztrack.data.access;

import org.oztrack.data.model.Doi;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.User;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public interface DoiDao  {

    Doi getInProgressDoi(Project project);
    Doi getDoiByProject(Project project);
    Doi getDoiById(Long id);
    List<Doi> getAll();
    List<Doi> getAllPublished();
    Doi getDoiByUuid(UUID uuid);
    List<User> getAdminUsers();
    void save(Doi doi);
    Doi update(Doi doi);
    void delete(Doi doi);


}
