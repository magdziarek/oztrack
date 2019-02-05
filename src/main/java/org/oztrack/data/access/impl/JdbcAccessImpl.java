package org.oztrack.data.access.impl;

import org.oztrack.data.access.JdbcAccess;
import org.oztrack.data.model.DataFile;
    import org.springframework.jdbc.core.support.JdbcDaoSupport;

public class JdbcAccessImpl extends JdbcDaoSupport implements JdbcAccess {
    @Override
    public int loadObservations(DataFile dataFile) {
        long dataFileId = dataFile.getId();
        long projectId = dataFile.getProject().getId();

        String sql =
                "INSERT INTO positionfix (" +
                " id" +
                " ,detectiontime" +
                " ,latitude" +
                " ,longitude" +
                " ,animal_id" +
                " ,project_id" +
                " ,datafile_id" +
                " ,locationgeometry" +
                " ,deleted" +
                " ,argosclass" +
                " ,dop" +
                " ,sst)" +
                " SELECT DISTINCT rpf.id" +
                " ,rpf.detectiontime" +
                " ,rpf.latitude" +
                " ,rpf.longitude" +
                " ,ani.id" +
                " ,?" +
                " ,?" +
                " ,rpf.locationgeometry" +
                " ,rpf.deleted" +
                " ,rpf.argosclass" +
                " ,rpf.dop" +
                " ,rpf.sst" +
                " FROM rawpositionfix rpf" +
                " ,animal ani" ;
        if (dataFile.getSingleAnimalInFile()) {
            sql += " WHERE ani.id = (select max(a.id) from animal a where a.project_id = ?)";
        }
        else {
            sql += " WHERE rpf.animalid = ani.projectanimalid AND  ani.project_id = ?" ;
        }

        sql += " AND (not exists ( select id from positionfix where animal_id = ani.id and latitude = rpf.latitude and longitude = rpf.longitude and detectiontime = rpf.detectiontime ))";
        logger.debug(sql);

        int nbrObservations = getJdbcTemplate().update(sql, new Object [] {projectId, dataFileId, projectId});
        return nbrObservations;
    }

    public int[] statObservations(DataFile dataFile) {
        long dataFileId = dataFile.getId();
        long projectId = dataFile.getProject().getId();

        String sql =
                        " SELECT  count(rpf.id)" +
                        " FROM rawpositionfix rpf" +
                        " ,animal ani" ;
        if (dataFile.getSingleAnimalInFile()) {
            sql += " WHERE ani.id = (select max(a.id) from animal a where a.project_id = ?)";
        }
        else {
            sql += " WHERE rpf.animalid = ani.projectanimalid AND  ani.project_id = ?" ;
        }

        String uniqueSql = sql +
                "and (not exists (select pf.id from positionfix pf " +
                "where pf.animal_id=ani.id and pf.detectiontime=rpf.detectiontime and " +
                "latitude = rpf.latitude and longitude = rpf.longitude and detectiontime = rpf.detectiontime))";


        int allobs = getJdbcTemplate().queryForInt(sql, new Object [] {projectId});
        int uniqueObs = getJdbcTemplate().queryForInt(uniqueSql, new Object [] {projectId});
        int[] stats = {allobs,uniqueObs};
        return stats;
    }

    @Override
    public void truncateRawObservations(DataFile dataFile) {
        getJdbcTemplate().execute("TRUNCATE TABLE rawpositionfix");
    }
}