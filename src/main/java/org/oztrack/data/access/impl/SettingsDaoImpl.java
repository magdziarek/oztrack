package org.oztrack.data.access.impl;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import org.oztrack.data.access.SettingsDao;
import org.oztrack.data.model.Settings;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.TreeMap;

@Service
public class SettingsDaoImpl implements SettingsDao {
    @PersistenceContext
    private EntityManager em;

    @Override
    public Settings getSettings() {
        return (Settings) em
            .createQuery("from org.oztrack.data.model.Settings")
            .getSingleResult();
    }

    @Override
    @Transactional
    public Settings update(Settings settings) {
        return em.merge(settings);
    }

    @Override
    public LinkedHashMap<String, Long> getSummaryStatistics() {

        LinkedHashMap<String, Long> map = new  LinkedHashMap<String, Long> ();
        map.put("Animal Tracks", ( (Number) em.createNativeQuery("select count(*) from Animal").getSingleResult()).longValue());
        map.put("Unique species", ( (Number) em.createNativeQuery("select count(distinct speciesscientificname) from Project").getSingleResult()).longValue());
        map.put("Open Access Projects", ( (Number) em.createNativeQuery("select count(id) from Project where access = 'OPEN'").getSingleResult()).longValue());
        map.put("Delayed Access Projects", ( (Number) em.createNativeQuery("select count(id) from Project where access != 'OPEN'").getSingleResult()).longValue());
        map.put("Contributors", ( (Number) em.createNativeQuery("select count(*) from Person").getSingleResult()).longValue());
        return map;
    }
}
