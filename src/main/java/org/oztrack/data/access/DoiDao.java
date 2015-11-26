package org.oztrack.data.access;

import org.oztrack.data.model.Doi;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.User;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface DoiDao  {

    Doi getInProgressDoi(Project project);
    Doi getDoiById(Long id);
    List<Doi> getAll();
    List<User> getAdminUsers();
    void save(Doi doi);
    Doi update(Doi doi);
    void delete(Doi doi);


}
