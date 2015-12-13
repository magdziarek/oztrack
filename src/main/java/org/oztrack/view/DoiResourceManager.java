package org.oztrack.view;

import org.apache.log4j.Logger;
import org.datacite.schema.kernel_3.Resource;
import org.datacite.schema.kernel_3.Resource.Identifier;
import org.datacite.schema.kernel_3.Resource.ResourceType;
import org.datacite.schema.kernel_3.Resource.Titles;
import org.datacite.schema.kernel_3.Resource.Titles.Title;
import org.datacite.schema.kernel_3.TitleType;
import org.datacite.schema.kernel_3.Resource.Descriptions;
import org.datacite.schema.kernel_3.Resource.Descriptions.Description;
import org.datacite.schema.kernel_3.DescriptionType;
import org.datacite.schema.kernel_3.Resource.Creators;
import org.datacite.schema.kernel_3.Resource.Creators.Creator;
import org.datacite.schema.kernel_3.Resource.Subjects;
import org.datacite.schema.kernel_3.Resource.Subjects.Subject;
import org.datacite.schema.kernel_3.Resource.RightsList;
import org.datacite.schema.kernel_3.Resource.RightsList.Rights;
import org.datacite.schema.kernel_3.Resource.Dates;
import org.datacite.schema.kernel_3.Resource.Dates.Date;

import org.datacite.schema.kernel_3.DateType;
import org.datacite.schema.kernel_3.Resource.GeoLocations.GeoLocation;
import org.datacite.schema.kernel_3.Resource.GeoLocations;
import org.oztrack.data.model.Doi;
import org.oztrack.data.model.Project;
import org.oztrack.data.model.ProjectContribution;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import java.io.StringWriter;
import java.text.SimpleDateFormat;
import java.util.*;

public class DoiResourceManager {

    private final Logger logger = Logger.getLogger(getClass());
    private Resource doiResource;
    private Project project;
    private JAXBContext jaxbContext;
    private Marshaller marshaller;
    private Unmarshaller unmarshaller;
    private final String DATA_CITE_XSD =  "http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd";


    public DoiResourceManager(Project project) {
        this.doiResource = new Resource();
        this.project = project;
        setUpMarshallers();
    }

    public Resource buildDoiResource() {
        generateDoiResource();
        return this.doiResource;
    }

    private void generateDoiResource() {

        ResourceType resourceType = new ResourceType();
        resourceType.setResourceTypeGeneral(org.datacite.schema.kernel_3.ResourceType.DATASET);
        doiResource.setResourceType(resourceType);
        doiResource.setPublisher("Atlas of Living Australia");
        doiResource.setPublicationYear(String.valueOf(Calendar.getInstance().get(Calendar.YEAR)));
        doiResource.setCreators(getCreators());
        doiResource.setTitles(getTitles());
        doiResource.setSubjects(getSubjects());
        doiResource.setDates(getDates());
        doiResource.setRightsList(getRightsList());
//      todo? doiResource.setDescriptions(getDescriptions());
//      todo? doiResource.setIdentifier(getIdentifier());

    }

    private void setUpMarshallers() {

        try {
            jaxbContext = JAXBContext.newInstance(Resource.class);
            marshaller = jaxbContext.createMarshaller();
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, false);
            marshaller.setProperty(Marshaller.JAXB_SCHEMA_LOCATION, DATA_CITE_XSD);
        } catch (JAXBException e) {
            logger.error("Problem setting up marshallers: " + e.getMessage());
        }

    }

    public String marshallDoiResource() {

        StringWriter stringWriter = new StringWriter();
        try {
            marshaller.marshal(this.doiResource, stringWriter);
        } catch (JAXBException e) {
            logger.error("Problem marshalling datacite xml: " + e.getMessage());
        }
        return stringWriter.toString();
    }

    private Creators getCreators() {

        List<Creator> creatorList = new ArrayList<Creator>();
        List<ProjectContribution> projectContributionsList = project.getProjectContributions();
        Iterator iterator = projectContributionsList.iterator();
        while (iterator.hasNext()) {
            ProjectContribution projectContribution = (ProjectContribution) iterator.next();
            Creator creator = new Creator();
            creator.setCreatorName(projectContribution.getContributor().getFullName());
            creatorList.add(creator);
        }

        Creators creators = new Creators();
        creators.getCreator().addAll(creatorList);
        return creators;
    }

    private Titles getTitles() {

        Title title = new Title();
        Title subTitle = new Title();
        title.setValue(project.getTitle());
        subTitle.setValue("Animal tracking data on the ZoaTrack platform");
        subTitle.setTitleType(TitleType.SUBTITLE);
        List<Title> titleList = new ArrayList<Title>();
        titleList.add(title);
        titleList.add(subTitle);
        Titles titles = new Titles();
        titles.getTitle().addAll(titleList);
        return titles;
    }

    private Subjects getSubjects() {
        //subjects
        Subject subject1 = new Subject();
        Subject subject2 = new Subject();
        subject1.setValue("animal telemetry");
        subject2.setValue(project.getSpeciesScientificName());
        List<Subject> subjectList = new ArrayList<Subject>();
        subjectList.add(subject1);
        subjectList.add(subject2);
        Subjects subjects = new Subjects();
        subjects.getSubject().addAll(subjectList);

        return subjects;
    }

    private Dates getDates() {

        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-mm-dd");
        Date createDate = new Date();
        createDate.setValue(simpleDateFormat.format(new java.util.Date()));
        createDate.setDateType(DateType.CREATED);
        List<Date> dateList = new ArrayList<Date>();
        dateList.add(createDate);
        Dates dates = new Dates();
        dates.getDate().addAll(dateList);
        return dates;

    }

    private RightsList getRightsList() {

        List<Rights> rightsArrayList = new ArrayList<Rights>();
        Rights ccStatement = new Rights();
        ccStatement.setValue(project.getDataLicence().getTitle());
        ccStatement.setRightsURI(project.getDataLicence().getInfoUrl());
        rightsArrayList.add(ccStatement);
        if (project.getRightsStatement() != null) {
            Rights rightsStatement = new Rights();
            rightsStatement.setValue(project.getRightsStatement());
            rightsArrayList.add(rightsStatement);
        }
        RightsList rightsList = new RightsList();
        rightsList.getRights().addAll(rightsArrayList);
        return rightsList;

    }

}
