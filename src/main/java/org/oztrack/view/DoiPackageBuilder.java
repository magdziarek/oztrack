package org.oztrack.view;

import au.com.bytecode.opencsv.CSVWriter;
import freemarker.cache.ClassTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.DefaultObjectWrapper;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.oztrack.data.access.PositionFixDao;
import org.oztrack.data.access.impl.PositionFixDaoImpl;
import org.oztrack.data.model.Animal;
import org.oztrack.data.model.Doi;
import org.oztrack.data.model.PositionFix;
import org.oztrack.data.model.SearchQuery;
import org.oztrack.data.model.types.PositionFixFileHeader;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class DoiPackageBuilder{

    private final Logger logger = Logger.getLogger(getClass());
    private Doi doi;
    private String filePrefix;
    private String filePath;
    private List<PositionFix> positionFixes;

    public DoiPackageBuilder(Doi doi, List<PositionFix> positionFixes) {
        this.doi = doi;
        this.filePrefix = doi.getProject().getTitle().replace(" ","-");
        this.filePath =  doi.getProject().getAbsoluteDataDirectoryPath() + File.separator;
        this.positionFixes = positionFixes;
    }

    public DoiPackageBuilder(Doi doi) {
        this.doi = doi;
        this.filePrefix = doi.getProject().getTitle().replace(" ","-");
        this.filePath =  doi.getProject().getAbsoluteDataDirectoryPath() + File.separator;
    }

    public String buildZip() {

        // get the short project name: first 3 words?
        deleteFiles();
        writeMetadataFiles();
        writeCsvFile();
        zipAll();
        return this.filePrefix + "-zoatrack.zip";
    }

    public void deleteFiles() {

        String[] fileList = new File(filePath).list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith(filePrefix);
            }
        });

        for (String s: fileList) {
            File f = new File(filePath + s);
            f.delete();
        }

    }


    private void writeMetadataFiles() {

        // delete files if they exist


        Configuration freemarkerConfiguration = new Configuration();
        DefaultObjectWrapper objectWrapper = new DefaultObjectWrapper();
        objectWrapper.setExposeFields(true);
        freemarkerConfiguration.setObjectWrapper(objectWrapper);
        freemarkerConfiguration.setTemplateLoader(new ClassTemplateLoader(this.getClass(), "/org/oztrack/view"));
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("doi", this.doi);
        map.put("fileNamePrefix", this.filePrefix);
        String fileOut = "metadata.txt";
        try {
            Template metadataTemplate = freemarkerConfiguration.getTemplate("doi-metadata.txt.ftl");
            FileWriter metadataFileWriter = new FileWriter(filePath + filePrefix + "-" + fileOut);
            metadataTemplate.process(map, metadataFileWriter);

            fileOut = "reference.txt";
            Template referenceTemplate = freemarkerConfiguration.getTemplate("doi-reference.txt.ftl");
            FileWriter referenceFileWriter = new FileWriter(filePath + filePrefix + "-" + fileOut);
            referenceTemplate.process(map, referenceFileWriter);

        } catch (IOException ioe) {
            logger.error("IO error writing to " + fileOut + ": " + ioe.getLocalizedMessage());

        } catch (TemplateException te) {
            logger.error("Template writing problem with " + fileOut + ": " + te.toString());
        }

    }

    private void writeCsvFile() {

        CSVWriter writer;

        try {

            FileWriter csvFileWriter = new FileWriter(filePath + filePrefix + "-zoatrack-data.csv");
            writer = new CSVWriter(csvFileWriter);

            SearchQuery searchQuery = new SearchQuery();
            searchQuery.setProject(this.doi.getProject());
            searchQuery.setIncludeDeleted(true);

            boolean includeArgos = false;
            boolean includeDop = false;
            boolean includeSst = false;
            for (PositionFix positionFix : positionFixes) {
                includeArgos = includeArgos || positionFix.getArgosClass() != null;
                includeDop = includeDop || positionFix.getDop() != null;
                includeSst = includeSst || positionFix.getSst() != null;
            }

            ArrayList<String> headerLine = new ArrayList<String>();
            headerLine.add(PositionFixFileHeader.ANIMALID.name());
            headerLine.add(PositionFixFileHeader.DATE.name());
            headerLine.add(PositionFixFileHeader.LONGITUDE.name());
            headerLine.add(PositionFixFileHeader.LATITUDE.name());
            if (includeArgos) {
                headerLine.add(PositionFixFileHeader.ARGOSCLASS.name());
            }
            if (includeDop) {
                headerLine.add(PositionFixFileHeader.DOP.name());
            }
            if (includeSst) {
                headerLine.add(PositionFixFileHeader.SST.name());
            }
            if ((searchQuery.getIncludeDeleted() != null) && searchQuery.getIncludeDeleted()) {
                headerLine.add(PositionFixFileHeader.DELETED.name());
            }
            writer.writeNext(headerLine.toArray(new String[] {}));
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
            for (PositionFix positionFix : positionFixes) {
                ArrayList<String> valuesLine = new ArrayList<String>();
                valuesLine.add(positionFix.getAnimal().getProjectAnimalId());
                valuesLine.add(dateFormat.format(positionFix.getDetectionTime()));
                valuesLine.add(String.valueOf(positionFix.getLocationGeometry().getX()));
                valuesLine.add(String.valueOf(positionFix.getLocationGeometry().getY()));
                if (includeArgos) {
                    valuesLine.add((positionFix.getArgosClass() != null) ? positionFix.getArgosClass().getCode() : "");
                }
                if (includeDop) {
                    valuesLine.add((positionFix.getDop() != null) ? String.valueOf(positionFix.getDop()) : "");
                }
                if (includeSst) {
                    valuesLine.add((positionFix.getSst() != null) ? String.valueOf(positionFix.getSst()) : "");
                }
                if ((searchQuery.getIncludeDeleted() != null) && searchQuery.getIncludeDeleted()) {
                    valuesLine.add(((positionFix.getDeleted() != null) && positionFix.getDeleted()) ? "TRUE" : "FALSE");
                }
                writer.writeNext(valuesLine.toArray(new String[] {}));
            }

            writer.close();


    } catch (IOException ioe) {
            logger.error("IO error writing -zoatrack-data.csv :" + ioe.getLocalizedMessage());
    }

    }


        private void zipAll() {

        String fullPath = filePath + filePrefix;
        try {

            FileOutputStream fileOutputStream = new FileOutputStream(fullPath + "-zoatrack.zip");
            ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream);

            String[] fileList = new File(filePath).list(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.startsWith(filePrefix) && name.endsWith("zip") == false;
                }
            });

            for (String s: fileList) {
                File f = new File(filePath + s);
                //logger.info("zipping file " + f.getName());
                ZipEntry zipEntry = new ZipEntry(f.getName());
                zipOutputStream.putNextEntry(zipEntry);
                IOUtils.copy(new FileInputStream(f), zipOutputStream);
                zipOutputStream.closeEntry();
                f.delete();
            }
            zipOutputStream.close();
            fileOutputStream.close();

        } catch (IOException ioe) {
            logger.error("IO error creating zip file: " + ioe.toString());
        }



    }


}
