package org.oztrack.data.access.impl;


import org.oztrack.data.access.DoiDao;
import org.oztrack.data.model.DataFile;
import org.oztrack.data.model.Doi;
import org.oztrack.data.model.Person;
import org.oztrack.data.model.Project;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import java.util.List;

@Service
public class DoiDaoImpl implements DoiDao {

    private EntityManager em;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Override
    public Doi getInProgressDoi(Project project){
        Query query = em.createQuery("SELECT o FROM doi o where o.project = :project and o.published = false");
        query.setParameter("project", project);
        try {
            return (Doi) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public Doi getDoiById(Long id) {
        Query query = em.createQuery("SELECT o FROM doi o WHERE o.id = :id");
        query.setParameter("id", id);
        try {
            return (Doi) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<Doi> getDoisByProject(Project project) {
        Query query = em.createQuery("SELECT o from doi o where o.project = :project order by o.createDate");
        query.setParameter("project", project);
        try {
            @SuppressWarnings("unchecked")
            List <Doi> resultList = query.getResultList();
            return resultList;
        }catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<Doi> getCompletedDoisByProject(Project project) {
        Query query = em.createQuery("SELECT o from doi o where o.project = :project and o.status = 'COMPLETED' order by o.createDate");
        query.setParameter("project", project);
        try {
            @SuppressWarnings("unchecked")
            List <Doi> resultList = query.getResultList();
            return resultList;
        }catch (NoResultException ex) {
            return null;
        }

    }

    @Override
    @Transactional
    public void save(Doi doi) {
        em.persist(doi);
    }

    @Override
    @Transactional
    public Doi update(Doi doi) { return em.merge(doi); }

    @Override
    @Transactional
    public void delete(Doi doi) {
        em.remove(doi);
    }
}
