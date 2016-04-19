package org.oztrack.data.access.impl;


import org.oztrack.data.access.DoiDao;
import org.oztrack.data.model.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import java.util.List;
import java.util.UUID;

@Service
public class DoiDaoImpl implements DoiDao {

    private EntityManager em;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Override
    public Doi getInProgressDoi(Project project){
        Query query = em.createQuery("SELECT o FROM Doi o where o.project = :project and o.published = false");
        query.setParameter("project", project);
        try {
            return (Doi) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public Doi getDoiByProject(Project project){
        Query query = em.createQuery("SELECT o FROM Doi o where o.project = :project");
        query.setParameter("project", project);
        try {
            return (Doi) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public Doi getDoiById(Long id) {
        Query query = em.createQuery("SELECT o FROM Doi o WHERE o.id = :id");
        query.setParameter("id", id);
        try {
            return (Doi) query.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<User> getAdminUsers() {
        Query query = em.createQuery("SELECT o from org.oztrack.data.model.User o where o.admin = TRUE");
        try {
            List <User> resultList = query.getResultList();
            return resultList;
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<Doi> getAll() {
        Query query = em.createQuery("SELECT o from Doi o order by o.updateDate desc");
        try {
            List<Doi> resultList = query.getResultList();
            return resultList;
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public List<Doi> getAllPublished() {
        Query query = em.createQuery("SELECT o from Doi o where o.published = true order by o.updateDate desc");
        try {
            List<Doi> resultList = query.getResultList();
            return resultList;
        } catch (NoResultException ex) {
            return null;
        }
    }

    @Override
    public Doi getDoiByUuid(UUID uuid) {
        Query query = em.createQuery("SELECT o FROM Doi o WHERE o.uuid = :uuid");
        query.setParameter("uuid", uuid);
        try {
            return (Doi) query.getSingleResult();
        } catch (NoResultException ex) {
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
