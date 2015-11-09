package org.oztrack.util;

import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Point;
import com.vividsolutions.jts.geom.PrecisionModel;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GeometryUtils {


    public static Point findLocationGeometry(String latitude, String longitude) throws Exception {
        GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(1000000), 4326);
        Coordinate coordinate = new Coordinate(parseCoordinate(longitude), parseCoordinate(latitude));
        return geometryFactory.createPoint(coordinate);
    }

    public static Double parseCoordinate(String s) throws Exception {

        Pattern degPattern = Pattern.compile("^([^\\s]+)$");
        Pattern degMinPattern = Pattern.compile("^([^\\s]+)\\s+([^\\s]+)$");
        Pattern degMinSecPattern = Pattern.compile("^([^\\s]+)\\s+([^\\s]+)\\s+([^\\s]+)$");

        Matcher matcher = null;
        if ((matcher = degPattern.matcher(s)).find()) {
            return Double.parseDouble(matcher.group(1));
        }
        if ((matcher = degMinPattern.matcher(s)).find()) {
            double deg = Double.parseDouble(matcher.group(1));
            double signFactor = deg / Math.abs(deg);
            return
                    deg +
                            signFactor * (Double.parseDouble(matcher.group(2)) / 60d);
        }
        if ((matcher = degMinSecPattern.matcher(s)).find()) {
            double deg = Double.parseDouble(matcher.group(1));
            double signFactor = deg / Math.abs(deg);
            return
                    deg +
                            signFactor * (Double.parseDouble(matcher.group(2)) / 60d) +
                            signFactor * (Double.parseDouble(matcher.group(3)) / 3600d);
        }
        throw new Exception("Could not parse coordinate " + s);
    }
}
