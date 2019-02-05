package org.oztrack.data.access.impl;

import java.io.File;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import au.com.bytecode.opencsv.CSVWriter;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.io.WKTReader;
import org.apache.commons.lang3.Range;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.log4j.Logger;
import org.oztrack.data.access.Page;
import org.oztrack.data.access.PositionFixDao;
import org.oztrack.data.model.Analysis;
import org.oztrack.data.model.AnalysisResultFeature;
import org.oztrack.data.model.Animal;
import org.oztrack.data.model.FilterResultFeature;
import org.oztrack.data.model.PositionFix;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.SearchQuery;
import org.oztrack.data.model.types.ArgosClass;
import org.oztrack.data.model.types.PositionFixStats;
import org.oztrack.data.model.types.TrajectoryStats;
import org.oztrack.util.ProjectAnimalsMutexExecutor;
import org.springframework.beans.factory.ObjectFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.vividsolutions.jts.geom.MultiPolygon;
import com.vividsolutions.jts.io.WKTWriter;


@Service
public class PositionFixDaoImpl implements PositionFixDao {
    private final Logger logger = Logger.getLogger(getClass());

    private final SimpleDateFormat isoDateFormat = new SimpleDateFormat("yyyy-MM-dd");

    private EntityManager em;

    private ProjectAnimalsMutexExecutor renumberPositionFixesExecutor;
    private ProjectAnimalsMutexExecutor updateAnimalColourExecutor;

    @PersistenceContext
    public void setEntityManger(EntityManager em) {
        this.em = em;
    }

    @Autowired
    public void setRenumberPositionFixesExecutor(ProjectAnimalsMutexExecutor renumberPositionFixesExecutor) {
        this.renumberPositionFixesExecutor = renumberPositionFixesExecutor;
    }

    @Autowired
    public void setUpdateAnimalColour(ProjectAnimalsMutexExecutor updateAnimalColourExecutor) {
        this.updateAnimalColourExecutor = updateAnimalColourExecutor;
    }

    @Override
    @Transactional
    public void save(PositionFix positionFix) {
        em.persist(positionFix);
    }

    @Override
    @Transactional
    public PositionFix update(PositionFix positionFix) {
        return em.merge(positionFix);
    }

    @Override
    public int getNumPositionFixes() {
        Query query = em.createQuery("select count(o) from org.oztrack.data.model.PositionFix o");
        return ((Number) query.getSingleResult()).intValue();
    }

    @Override
    public Page<PositionFix> getPage(SearchQuery searchQuery, int offset, int nbrObjectsPerPage) {
       try {
           if (offset >= 0) {
               Query query = buildQuery(searchQuery, false);
               logger.debug(query.toString());
               query.setFirstResult(offset);
               query.setMaxResults(nbrObjectsPerPage);
               @SuppressWarnings("unchecked")
               List<PositionFix> positionFixList = query.getResultList();
               Query countQuery = buildQuery(searchQuery, true);
               int count = Integer.parseInt(countQuery.getSingleResult().toString());
               return new Page<PositionFix>(positionFixList, offset, nbrObjectsPerPage, count);
           } else {
               logger.error("Negative value passed to getPage again: " + offset);
               return null;
           }
       } catch (NoResultException ex) {
           em.getTransaction().rollback();
           return null;
       }
    }

    public Query buildQuery(SearchQuery searchQuery, boolean count) {
        StringBuilder queryString = new StringBuilder();
        queryString.append("select " + (count ? "count(o)" : "o") + "\n");
        queryString.append("from PositionFix o " + "\n");
        queryString.append("where o.project.id = :projectId\n");
        if ((searchQuery.getIncludeDeleted() == null) || !searchQuery.getIncludeDeleted()) {
            queryString.append("and o.deleted = false\n");
        }
        if (searchQuery.getFromDate() != null) {
            queryString.append("and o.detectionTime >= :fromDate\n");
        }
        if (searchQuery.getToDate() != null) {
            queryString.append("and o.detectionTime < :toDateExcl\n");
        }
        if ((searchQuery.getAnimalIds() != null) && !searchQuery.getAnimalIds().isEmpty()) {
            queryString.append("and o.animal.id in (");
            for (int i = 0; i < searchQuery.getAnimalIds().size(); i++) {
                queryString.append(":animal" + i);
                if (i < searchQuery.getAnimalIds().size() - 1) {
                    queryString.append(",");
                }
            }
            queryString.append(")\n");
        }
        queryString.append((count ? "" : "order by o.animal.id, o.detectionTime"));
        Query query = em.createQuery(queryString.toString());
        query.setParameter("projectId", searchQuery.getProject().getId());
        if (searchQuery.getFromDate() != null) {
            Date fromDateTrunc = DateUtils.truncate(searchQuery.getFromDate(), Calendar.DATE);
            query.setParameter("fromDate", fromDateTrunc);
        }
        if (searchQuery.getToDate() != null) {
            Date toDateTrunc = DateUtils.truncate(searchQuery.getToDate(), Calendar.DATE);
            Date toDateTruncExcl = DateUtils.addDays(toDateTrunc, 1);
            query.setParameter("toDateExcl", toDateTruncExcl);
        }
        if ((searchQuery.getAnimalIds() != null) && !searchQuery.getAnimalIds().isEmpty()) {
            for (int i=0; i < searchQuery.getAnimalIds().size(); i++) {
                String paramName = "animal" + i;
                query.setParameter(paramName, searchQuery.getAnimalIds().get(i));
            }
        }
        return query;
    }

    @Override
    public List<PositionFix> getProjectPositionFixList(SearchQuery searchQuery) {
        Query query = buildQuery(searchQuery, false);
        @SuppressWarnings("unchecked")
        List<PositionFix> resultList = query.getResultList();
        return resultList;
    }

    @Override
    @Transactional
    public int setDeleted(
        Project project,
        Date fromDate,
        Date toDate,
        List<Long> animalIds,
        MultiPolygon multiPolygon,
        Set<PositionFix> speedFilterPositionFixes,
        ArgosClass minArgosClass,
        Double maxDop,
        boolean deleted
    ) {
        if ((project == null) || (animalIds == null) || animalIds.isEmpty()) {
            return 0;
        }

        int numDeleted = completeQuery(
                "update positionfix\n" +
                "set deleted = :deleted\n" +
                "where not(probable) and deleted = not(:deleted)",
                project,
                fromDate,
                toDate,
                animalIds,
                multiPolygon,
                speedFilterPositionFixes,
                minArgosClass,
                maxDop,
                deleted
            )
            .setParameter("deleted", deleted)
            .executeUpdate();

        completeQuery(
                "delete from positionfix\n" +
                "where probable",
                project,
                fromDate,
                toDate,
                animalIds,
                multiPolygon,
                speedFilterPositionFixes,
                minArgosClass,
                maxDop,
                deleted
            ).executeUpdate();

        return numDeleted;
    }

    private Query completeQuery(
        String queryString,
        Project project,
        Date fromDate,
        Date toDate,
        List<Long> animalIds,
        MultiPolygon multiPolygon,
        Set<PositionFix> speedFilterPositionFixes,
        ArgosClass minArgosClass,
        Double maxDop,
        boolean deleted
    ) {
        queryString += "\n";
        queryString += "    and project_id = :projectId\n";
        queryString += "    and animal_id in (:animalIds)\n";
        if (fromDate != null) {
            queryString += "    and detectionTime >= :fromDate\n";
        }
        if (toDate != null) {
            queryString += "    and detectionTime < :toDateExcl\n";
        }
        if (speedFilterPositionFixes != null) {
            queryString += "    and id not in (:speedFilterPositionFixes)\n";
        }
        if (multiPolygon != null) {
            String unshiftedPointExpr = "locationgeometry";
            String unshiftedMultiPolygonExpr = "ST_GeomFromText(:wkt, 4326)";
            String pointExpr = project.getCrosses180() ? "ST_Shift_Longitude(" + unshiftedPointExpr + ")" : unshiftedPointExpr;
            String multiPolygonExpr = project.getCrosses180() ? "ST_Shift_Longitude(" + unshiftedMultiPolygonExpr + ")" : unshiftedMultiPolygonExpr;
            queryString += "    and ST_Within(" + pointExpr + ", " + multiPolygonExpr + ")\n";
        }
        if (minArgosClass != null) {
            queryString += "    and argosclass < :minArgosClass\n";
        }
        if (maxDop != null) {
            queryString += "    and dop > :maxDop\n";
        }
        queryString += ";";
        Query query = em.createNativeQuery(queryString);
        query.setParameter("projectId", project.getId());
        query.setParameter("animalIds", animalIds);
        if (fromDate != null) {
            Date fromDateTrunc = DateUtils.truncate(fromDate, Calendar.DATE);
            query.setParameter("fromDate", fromDateTrunc);
        }
        if (toDate != null) {
            Date toDateTruncExcl = DateUtils.addDays(DateUtils.truncate(toDate, Calendar.DATE), 1);
            query.setParameter("toDateExcl", toDateTruncExcl);
        }
        if (speedFilterPositionFixes != null) {
            query.setParameter("speedFilterPositionFixes", speedFilterPositionFixes);
        }
        if (multiPolygon != null) {
            query.setParameter("wkt", new WKTWriter().write(multiPolygon));
        }
        if (minArgosClass != null) {
            query.setParameter("minArgosClass", minArgosClass.ordinal());
        }
        if (maxDop != null) {
            query.setParameter("maxDop", maxDop);
        }
        return query;
    }

    @Override
    @Transactional
    public void applyKalmanFilter(Analysis analysis) {
        // Delete existing position fixes
        String queryString =
            "update positionfix\n" +
            "set deleted = true\n" +
            "where\n" +
            "    project_id = :projectId\n" +
            "    and animal_id in (:animalIds)\n";
        if (analysis.getFromDate() != null) {
            queryString += "    and detectionTime >= :fromDate\n";
        }
        if (analysis.getToDate() != null) {
            queryString += "    and detectionTime < :toDateExcl\n";
        }
        queryString += ";";
        Query query = em.createNativeQuery(queryString);
        query.setParameter("projectId", analysis.getProject().getId());
        ArrayList<Long> animalIds = new ArrayList<Long>();
        for (Animal animal : analysis.getAnimals()) {
            animalIds.add(animal.getId());
        }
        query.setParameter("animalIds", animalIds);
        if (analysis.getFromDate() != null) {
            Date fromDateTrunc = DateUtils.truncate(analysis.getFromDate(), Calendar.DATE);
            query.setParameter("fromDate", fromDateTrunc);
        }
        if (analysis.getToDate() != null) {
            Date toDateTrunc = DateUtils.truncate(analysis.getToDate(), Calendar.DATE);
            Date toDateTruncExcl = DateUtils.addDays(toDateTrunc, 1);
            query.setParameter("toDateExcl", toDateTruncExcl);
        }
        query.executeUpdate();

        // Replace with Kalman Filter output
        for (AnalysisResultFeature resultFeature : analysis.getResultFeatures()) {
            FilterResultFeature f = (FilterResultFeature) resultFeature;
            PositionFix positionFix = new PositionFix();
            positionFix.setProject(analysis.getProject());
            positionFix.setAnimal(f.getAnimal());
            positionFix.setDetectionTime(f.getDateTime());
            positionFix.setLocationGeometry(f.getGeometry());
            positionFix.setLongitude(String.valueOf(f.getGeometry().getX()));
            positionFix.setLatitude(String.valueOf(f.getGeometry().getY()));
            positionFix.setProbable(true);
            save(positionFix);
        }
    }

    @Override
    @Transactional
    public void updateAnimalColour(final Project project, final List<Long> animalIds) {

        updateAnimalColourExecutor.execute(new ProjectAnimalsMutexExecutor.ProjectAnimalsRunnable(project, animalIds) {
            @Override
            public void run() {
                // there should only be one animal - needed to put it in an array to use the mutexExecutor
                Long id = animalIds.get(0);

                em.createNativeQuery(
                        "update positionfixlayer\n" +
                        "set colour = (select colour from animal where id = :id)\n" +
                        "where project_id = :projectId\n" +
                        "and animal_id = :id"
                )
                .setParameter("projectId", project.getId())
                .setParameter("id", animalIds.get(0))
                .executeUpdate();

                em.createNativeQuery(
                        "update positionfixnumbered\n" +
                        "set colour = (select colour from animal where id = :id)\n" +
                        "where project_id = :projectId\n" +
                        "and animal_id = :id"
                )
                .setParameter("projectId", project.getId())
                .setParameter("id", animalIds.get(0))
                .executeUpdate();

                em.createNativeQuery(
                        "update trajectorylayer\n" +
                        "set colour = (select colour from animal where id = :id)\n" +
                        "where project_id = :projectId\n" +
                        "and animal_id = :id"
                )
                .setParameter("projectId", project.getId())
                .setParameter("id", animalIds.get(0))
                .executeUpdate();
            }
        });
    }

    @Override
    @Transactional
    public void renumberPositionFixes(final Project project, final List<Long> animalIds) {
        if ((project == null) || (animalIds == null) || animalIds.isEmpty()) {
            return;
        }
        renumberPositionFixesExecutor.execute(new ProjectAnimalsMutexExecutor.ProjectAnimalsRunnable(project, animalIds) {
            @Override
            public void run() {
                em.createNativeQuery(
                        "delete from positionfixlayer\n" +
                        "where\n" +
                        "    project_id = :projectId and\n" +
                        "    animal_id in (:animalIds)"
                    )
                    .setParameter("projectId", project.getId())
                    .setParameter("animalIds", animalIds)
                    .executeUpdate();

                String unshiftedPointExpr = "positionfix.locationgeometry";
                String pointExpr = project.getCrosses180() ? "ST_Shift_Longitude(" + unshiftedPointExpr + ")" : unshiftedPointExpr;
                em.createNativeQuery(
                        "insert into positionfixlayer(\n" +
                        "    id,\n" +
                        "    project_id,\n" +
                        "    animal_id,\n" +
                        "    detectiontime,\n" +
                        "    locationgeometry,\n" +
                                "    argosclass,\n" +
                        "    deleted,\n" +
                        "    probable,\n" +
                        "    colour\n" +
                        ")\n" +
                        "select\n" +
                        "    positionfix.id as id,\n" +
                        "    positionfix.project_id as project_id,\n" +
                        "    positionfix.animal_id as animal_id,\n" +
                        "    positionfix.detectiontime as detectiontime,\n" +
                        "    " + pointExpr + " as locationgeometry,\n" +
                                "    positionfix.argosclass as deleted,\n" +
                        "    positionfix.deleted as deleted,\n" +
                        "    positionfix.probable as probable,\n" +
                        "    animal.colour as colour\n" +
                        "from\n" +
                        "    positionfix,\n" +
                        "    animal\n" +
                        "where\n" +
                        "    positionfix.project_id = :projectId and\n" +
                        "    positionfix.animal_id = animal.id and\n" +
                        "    animal.id in (:animalIds)"
                    )
                    .setParameter("projectId", project.getId())
                    .setParameter("animalIds", animalIds)
                    .executeUpdate();

                em.createNativeQuery(
                        "delete from positionfixnumbered\n" +
                        "where\n" +
                        "    project_id = :projectId and\n" +
                        "    animal_id in (:animalIds)"
                    )
                    .setParameter("projectId", project.getId())
                    .setParameter("animalIds", animalIds)
                    .executeUpdate();

                em.createNativeQuery(
                        "insert into positionfixnumbered(\n" +
                        "    id,\n" +
                        "    project_id,\n" +
                        "    animal_id,\n" +
                        "    detectiontime,\n" +
                        "    locationgeometry,\n" +
                        "    colour,\n" +
                        "    row_number\n" +
                        ")\n" +
                        "select\n" +
                        "    positionfix.id as id,\n" +
                        "    positionfix.project_id as project_id,\n" +
                        "    positionfix.animal_id as animal_id,\n" +
                        "    positionfix.detectiontime as detectiontime,\n" +
                        "    positionfix.locationgeometry as locationgeometry,\n" +
                        "    animal.colour as colour,\n" +
                        "    row_number() over (partition by positionfix.project_id, positionfix.animal_id order by positionfix.detectiontime) as row_number\n" +
                        "from\n" +
                        "    positionfix positionfix\n" +
                        "    inner join animal on positionfix.animal_id = animal.id\n" +
                        "where\n" +
                        "    positionfix.project_id = :projectId and\n" +
                        "    not(positionfix.deleted) and\n" +
                        "    animal.id in (:animalIds)"
                    )
                    .setParameter("projectId", project.getId())
                    .setParameter("animalIds", animalIds)
                    .executeUpdate();

                em.createNativeQuery(
                        "delete from trajectorylayer\n" +
                        "where\n" +
                        "    project_id = :projectId and\n" +
                        "    animal_id in (:animalIds)"
                    )
                    .setParameter("projectId", project.getId())
                    .setParameter("animalIds", animalIds)
                    .executeUpdate();

                String unshiftedLineExpr = "ST_MakeLine(positionfix1.locationgeometry, positionfix2.locationgeometry)";
                String lineExpr = project.getCrosses180() ? "ST_Shift_Longitude(" + unshiftedLineExpr + ")" : unshiftedLineExpr;
                em.createNativeQuery(
                        "insert into trajectorylayer(\n" +
                        "    id,\n" +
                        "    project_id,\n" +
                        "    animal_id,\n" +
                        "    startdetectiontime,\n" +
                        "    enddetectiontime,\n" +
                        "    colour,\n" +
                        "    row_number,\n" +
                        "    trajectorygeometry\n" +
                        ")\n" +
                        "select\n" +
                        "    positionfix1.id as id,\n" +
                        "    positionfix1.project_id as project_id,\n" +
                        "    positionfix1.animal_id as animal_id,\n" +
                        "    positionfix1.detectiontime as startdetectiontime,\n" +
                        "    positionfix2.detectiontime as enddetectiontime,\n" +
                        "    positionfix1.colour as colour,\n" +
                        "    positionfix1.row_number as row_number,\n" +
                        "    " + lineExpr + " as trajectorygeometry\n" +
                        "from\n" +
                        "    positionfixnumbered positionfix1\n" +
                        "    inner join positionfixnumbered positionfix2 on\n" +
                        "        positionfix1.project_id = positionfix2.project_id and\n" +
                        "        positionfix1.animal_id = positionfix2.animal_id and\n" +
                        "        positionfix1.row_number + 1 = positionfix2.row_number\n" +
                        "where\n" +
                        "    positionfix1.project_id = :projectId and\n" +
                        "    positionfix1.animal_id in (:animalIds)"
                    )
                    .setParameter("projectId", project.getId())
                    .setParameter("animalIds", animalIds)
                    .executeUpdate();

                em.createNativeQuery(
                        "delete from positionfixstats\n" +
                                "where\n" +
                                "    project_id = :projectId and\n" +
                                "    animal_id in (:animalIds)"
                ).setParameter("projectId", project.getId())
                 .setParameter("animalIds", animalIds)
                 .executeUpdate();

                String spheroidStr = "'SPHEROID[\"WGS 84\", 6378137, 298.257223563]'";
                String displacementExpr = project.getCrosses180()
                        ? "ST_Distance_Spheroid(ST_Shift_Longitude(first_fix.locationgeometry),ST_Shift_Longitude(all_fixes.locationgeometry)," + spheroidStr + ")"
                        : "ST_Distance_Spheroid(first_fix.locationgeometry,all_fixes.locationgeometry," + spheroidStr + ")";

                String queryString =
                        "insert into positionfixstats(\n" +
                        "    id,\n" +
                        "    project_id,\n" +
                        "    animal_id,\n" +
                        "    locationgeometry,\n" +
                        "    detectiontime,\n" +
                        "    detection_index,\n" +
                        "    displacement,\n" +
                        "    cumulative_distance,\n" +
                        "    step_distance,\n" +
                        "    step_duration\n" +
                        ")\n" +
                        "select all_fixes.id\n" +
                        ", all_fixes.project_id\n" +
                        ", all_fixes.animal_id\n" +
                        ", all_fixes.locationgeometry\n" +
                        ", all_fixes.detectiontime\n" +
                        ", all_fixes.row_number-1  as detection_index\n" +
                        "," + displacementExpr + " as displacement\n" +
                        ", case when trajectory.id is null\n" +
                        "  then 0\n" +
                        "  else sum(ST_Length_Spheroid(trajectory.trajectorygeometry, " + spheroidStr + ")) over (partition by trajectory.project_id, trajectory.animal_id order by trajectory.enddetectiontime)\n" +
                        "  end as cumulative_distance\n" +
                        ", case when trajectory.enddetectiontime is null then 0 else ST_Length_Spheroid(trajectory.trajectorygeometry, " + spheroidStr + ") end as step_distance\n" +
                        ", case when trajectory.enddetectiontime is null then 0 else EXTRACT(EPOCH FROM (trajectory.enddetectiontime - trajectory.startdetectiontime)) end as step_duration\n" +
                        "from positionfixnumbered all_fixes\n" +
                        "inner join positionfixnumbered first_fix\n" +
                        "  on first_fix.row_number = 1\n" +
                        "  and first_fix.project_id = :projectId\n" +
                        "  and first_fix.animal_id in (:animalIds)\n" +
                        "  and all_fixes.project_id = first_fix.project_id\n" +
                        "  and all_fixes.animal_id = first_fix.animal_id\n" +
                        "left outer join trajectorylayer trajectory\n" +
                        "  on all_fixes.project_id=trajectory.project_id\n" +
                        "  and all_fixes.animal_id=trajectory.animal_id\n" +
                        "  and all_fixes.row_number=trajectory.row_number+1\n";
                em.createNativeQuery(queryString)
                .setParameter("projectId", project.getId())
                .setParameter("animalIds", animalIds)
                .executeUpdate();

                //Caculating BBox of a project
                //box(x,x,x,x)
                String bboxQuery =  "select cast(st_extent(locationgeometry) as varchar) from positionfix  where project_id = ?1 group by project_id";

                // return ploygon with SRID
                //select st_asewkt(st_setsrid(st_extent(locationgeometry),3857)) from positionfix  where project_id = 1 group by project_id;
                //SRID=3857;POLYGON((146.064391 -17.600091,146.064391 -17.55135,146.119275 -17.55135,146.119275 -17.600091,146.064391 -17.600091))

                // return ploygon without SRID
                //select st_asewkt(st_extent(locationgeometry)) from positionfix  where project_id = 1 group by project_id;
                //POLYGON((146.064391 -17.600091,146.064391 -17.55135,146.119275 -17.55135,146.119275 -17.600091,146.064391 -17.600091))

                try {
                    Long id = project.getId();
                    String geomQuery =  "UPDATE project SET bbox = (SELECT st_setsrid(st_extent(locationgeometry),4326) from positionfix  where project_id = "+id + " group by project_id) WHERE id = "+id;
                    Query qbbox = em.createNativeQuery(geomQuery);
                    //qbbox.setParameter("projectId", id);
                    qbbox.executeUpdate();
                }catch(Exception e){
                    e.printStackTrace();
                }






            }
        });
    }

    @Override
    public Map<Long, PositionFixStats> getAnimalPositionFixStats(Project project, Date fromDate, Date toDate) {
        String totalQueryString =
            "select\n" +
            "    animal_id,\n" +
            "    min(detectiontime),\n" +
            "    max(detectiontime),\n" +
            "    count(animal_id),\n" +
            "    case" +
            "        when extract(epoch from max(detectiontime) - min(detectiontime)) > 0\n" +
            "        then count(animal_id) / (extract(epoch from max(detectiontime) - min(detectiontime)) / (60 * 60 * 24))\n" +
            "        else null\n" +
            "    end\n" +
            "from positionfixlayer\n" +
            "where project_id = :projectId\n" +
            "and not deleted\n";
        if (fromDate != null) {
            Date fromDateTrunc = DateUtils.truncate(fromDate, Calendar.DATE);
            totalQueryString += " and detectiontime >= DATE '" + isoDateFormat.format(fromDateTrunc) + "'\n";
        }
        if (toDate != null) {
            Date toDateTrunc = DateUtils.truncate(toDate, Calendar.DATE);
            Date toDateTruncExcl = DateUtils.addDays(toDateTrunc, 1);
            totalQueryString += " and detectiontime < DATE '" + isoDateFormat.format(toDateTruncExcl) + "'\n";
        }
        totalQueryString += "group by animal_id";
        @SuppressWarnings("unchecked")
        List<Object[]> totalResultList = em.createNativeQuery(totalQueryString)
            .setParameter("projectId", project.getId())
            .getResultList();
        HashMap<Long, PositionFixStats> map = new HashMap<Long, PositionFixStats>();
        for (Object[] totalResult : totalResultList) {
            PositionFixStats stats = new PositionFixStats();
            long animalId = ((Number) totalResult[0]).longValue();
            stats.setAnimalId(animalId);
            stats.setStartDate(new Date(((Timestamp) totalResult[1]).getTime()));
            stats.setEndDate(new Date(((Timestamp) totalResult[2]).getTime()));
            stats.setCount(((Number) totalResult[3]).longValue());
            stats.setDailyMean((totalResult[4] != null) ? ((Number) totalResult[4]).doubleValue() : null);
            map.put(animalId, stats);
        }

        String dailyQueryString =
            "select distinct\n" +
            "    animal_id,\n" +
            "    max(count(date_trunc('day', detectiontime))) over (partition by animal_id)\n" +
            "from positionfixlayer\n" +
                    "where project_id = :projectId\n" +
                    "and not deleted\n";
        if (fromDate != null) {
            Date fromDateTrunc = DateUtils.truncate(fromDate, Calendar.DATE);
            dailyQueryString += " and detectiontime >= DATE '" + isoDateFormat.format(fromDateTrunc) + "'\n";
        }
        if (toDate != null) {
            Date toDateTrunc = DateUtils.truncate(toDate,  Calendar.DATE);
            Date toDateTruncExcl = DateUtils.addDays(toDateTrunc, 1);
            dailyQueryString += " and detectiontime < DATE '" + isoDateFormat.format(toDateTruncExcl) + "'\n";
        }
        dailyQueryString += "group by animal_id, date_trunc('day', detectiontime)";
        @SuppressWarnings("unchecked")
        List<Object[]> dailyResultList = em.createNativeQuery(dailyQueryString)
            .setParameter("projectId", project.getId())
            .getResultList();
        for (Object[] dailyResult : dailyResultList) {
            Long animalId = ((Number) dailyResult[0]).longValue();
            map.get(animalId).setDailyMax(((Number) dailyResult[1]).longValue());
        }

        return map;
    }

    @Override
    public Map<Long, TrajectoryStats> getAnimalTrajectoryStats(Project project, Date fromDate, Date toDate) {
        String queryString =
            "select\n" +
            "    animal_id,\n" +
            "    min(startdetectiontime),\n" +
            "    max(enddetectiontime),\n" +
            "    sum(ST_Length_Spheroid(trajectorygeometry, 'SPHEROID[\"WGS 84\", 6378137, 298.257223563]')),\n" +
            "    avg(ST_Length_Spheroid(trajectorygeometry, 'SPHEROID[\"WGS 84\", 6378137, 298.257223563]')),\n" +
            "    (\n" +
            "        sum(ST_Length_Spheroid(trajectorygeometry, 'SPHEROID[\"WGS 84\", 6378137, 298.257223563]')) /\n" +
            "        sum(extract(epoch from (enddetectiontime - startdetectiontime)))" +
            "    )\n" +
            "from trajectorylayer\n" +
            "where\n" +
            "    project_id = :projectId and\n" +
            "    enddetectiontime > startdetectiontime\n";
        if (fromDate != null) {
            Date fromDateTrunc = DateUtils.truncate(fromDate, Calendar.DATE);
            queryString += " and startdetectiontime >= DATE '" + isoDateFormat.format(fromDateTrunc) + "'\n";
        }
        if (toDate != null) {
            Date toDateTrunc = DateUtils.truncate(toDate, Calendar.DATE);
            Date toDateTruncExcl = DateUtils.addDays(toDateTrunc, 1);
            queryString += " and enddetectiontime < DATE '" + isoDateFormat.format(toDateTruncExcl) + "'\n";
        }
        queryString += "group by animal_id";
        @SuppressWarnings("unchecked")
        List<Object[]> resultList = em.createNativeQuery(queryString)
            .setParameter("projectId", project.getId())
            .getResultList();
        HashMap<Long, TrajectoryStats> map = new HashMap<Long, TrajectoryStats>();
        for (Object[] result : resultList) {
            Long animalId = ((Number) result[0]).longValue();
            TrajectoryStats stats = new TrajectoryStats();
            stats.setAnimalId(animalId);
            stats.setStartDate(new Date(((Timestamp) result[1]).getTime()));
            stats.setEndDate(new Date(((Timestamp) result[2]).getTime()));
            stats.setDistance(((Number) result[3]).doubleValue());
            stats.setMeanStepDistance(((Number) result[4]).doubleValue());
            stats.setMeanStepSpeed(((Number) result[5]).doubleValue());
            map.put(animalId, stats);
        }
        return map;
    }

    @Override
    public Map<Long, Range<Date>> getAnimalStartEndDates(Project project, Date fromDate, Date toDate) {
        String queryString =
            "select animal_id, min(startdetectiontime), max(enddetectiontime)\n" +
            "from trajectorylayer\n" +
            "where project_id = :projectId\n";
        if (fromDate != null) {
            Date fromDateTrunc = DateUtils.truncate(fromDate, Calendar.DATE);
            queryString += " and startdetectiontime >= DATE '" + isoDateFormat.format(fromDateTrunc) + "'\n";
        }
        if (toDate != null) {
            Date toDateTrunc = DateUtils.truncate(toDate, Calendar.DATE);
            Date toDateTruncExcl = DateUtils.addDays(toDateTrunc, 1);
            queryString += " and enddetectiontime < DATE '" + isoDateFormat.format(toDateTruncExcl) + "'\n";
        }
        queryString += "group by animal_id";
        @SuppressWarnings("unchecked")
        List<Object[]> resultList = em.createNativeQuery(queryString)
            .setParameter("projectId", project.getId())
            .getResultList();
        HashMap<Long, Range<Date>> animalStartEndDates = new HashMap<Long, Range<Date>>();
        for (Object[] result : resultList) {
            Long animalId = ((Number) result[0]).longValue();
            Date startDate = (Date) result[1];
            Date endDate = (Date) result[2];
            animalStartEndDates.put(animalId, Range.between(startDate, endDate));
        }
        return animalStartEndDates;
    }

    @Override
    public void writePositionFixStatsCsv(Long projectId, CSVWriter csvWriter)  {

        String [] headers = { "animal_id","detectiontime","detection_index","displacement","cumulative_distance", "step_distance", "step_duration"};
        csvWriter.writeNext(headers);

        String queryString =  "select animal_id\n" +
                ", to_char(detectiontime, 'yyyy-mm-dd hh24:mi:ss') as detectiontime\n" +
                ", detection_index\n" +
                ", displacement\n" +
                ", cumulative_distance\n" +
                ", step_distance\n" +
                ", step_duration\n" +
                "from positionfixstats\n" +
                "where project_id = :projectId\n";
        Query query = em.createNativeQuery(queryString).setParameter("projectId", projectId);
        writeCsv(query, csvWriter);
    }

    @Override
    public void writeTraitsCsv(Long projectId, CSVWriter csvWriter) {

        String [] headers = { "decimalLongitude","decimalLatitude","speciesScientificName",
                "month","year","eventDate","organismId","eventId","t1_stepDistance","t2_speedOverGround",
                "t3_sex","t4_weight","t5_dimensions","t6_lifePhase","t7_releaseDate","t8_experimentalContext"};
        csvWriter.writeNext(headers);

        String queryString = "select ST_X(ps.locationgeometry) as decimalLongitude\n" +
                ", ST_Y(ps.locationgeometry) as decimalLatitude\n" +
                ", p.speciesscientificname\n" +
                ", to_char(ps.detectiontime, 'mm') as eventMonth\n" +
                ", to_char(ps.detectiontime, 'yyyy') as eventYear\n" +
                ", to_char(ps.detectiontime, 'yyyy-mm-dd hh24:mi:ss') as eventDate\n" +
                ", a.projectanimalid as animal_id\n" +
                ", ps.animal_id as eventId\n" +
                ", ps.step_distance\n" +
                ", case when ps.step_duration = 0 then 0 else ps.step_distance/ps.step_duration end\n" +
                ", a.sex\n" +
                ", a.weight\n" +
                ", a.dimensions\n" +
                ", a.lifephase\n" +
                ", to_char(a.releasedate, 'yyyy-mm-dd')\n" +
                ", a.experimentalcontext\n" +
                "from positionfixstats ps \n" +
                "inner join animal a\n" +
                " on ps.animal_id = a.id\n" +
                " and ps.project_id = a.project_id\n" +
                "inner join project p\n" +
                " on ps.project_id=p.id" +
                " where ps.project_id=:projectId";

        Query query = em.createNativeQuery(queryString).setParameter("projectId", projectId);
        writeCsv(query, csvWriter);

    }

    @Override
    public String getTraitsDescr() {
        return "Field Descriptions:\n\n" +
               "t1_stepDistance (km): The calculated minimum distance between consecutive location fixes. Calculated in WGS84.\n" +
               "t2_speedOverGround (km/hr): The calculated minimum distance between consecutive location fixes divided by the time difference between those location fixes. Calculated in WGS84.\n" +
               "t3_sex: The sex of the animal\n" +
               "t4_weight: The weight of the animal\n" +
               "t5_dimensions: Any relevant dimensions of the animal with units specified\n" +
               "t6_lifePhase: The life phase of the animal\n" +
               "t7_releaseDate: The date the animal was released after capture\n" +
               "t8_experimentalContext: A description of the tagging program for this animal eg translocation, manipulation, reintroduction";
    }

    private void writeCsv(Query query, CSVWriter csvWriter) {
        @SuppressWarnings("unchecked")
        List<Object[]> resultList = query.getResultList();
        for (Object[] o : resultList) {
            String [] s = new String[o.length];
            for (int i=0; i < o.length; i++) {
                s[i] = (o[i] != null) ?  o[i].toString() : "";
            }
            csvWriter.writeNext(s);
        }
    }

}