package org.oztrack.data.access.impl;

import org.oztrack.data.access.ProjectActivityDao;
import org.oztrack.data.model.ProjectActivity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Service
public class ProjectActivityDaoImpl implements ProjectActivityDao {

    private EntityManager em;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Override
    @Transactional
    public void save(ProjectActivity activity) {
        em.persist(activity);
    }

}
