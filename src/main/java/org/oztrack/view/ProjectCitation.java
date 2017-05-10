package org.oztrack.view;

import org.oztrack.data.model.*;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

import org.apache.log4j.Logger;

public class ProjectCitation {

    private final Project project;

    public ProjectCitation(Project project) {
        this.project = project;
    }

    public File createCitationAndTermsFile(String directory) throws IOException {
        //String tempDir = System.getProperty("java.io.tmpdir");
        File citationFile = new File(directory + "citation.txt");
        FileWriter fw2 = new FileWriter(citationFile);
        fw2.write(citation() + relatedPublications() + licence());
        fw2.close();
        return citationFile;

    }

    private String citation() {

        StringBuilder stringBuilder = new StringBuilder("Citation\n");
        List<Doi> dois = this.project.getDois();
        if (!dois.isEmpty()) {
            for (Doi doi:dois) {
                stringBuilder.append(doi.getCitation() + "\n\n");
            }
        } else {
            List<ProjectContribution> projectContributionsList =  project.getProjectContributions();
            Iterator iterator = projectContributionsList.iterator();
            String authorList = "";
            while (iterator.hasNext()) {
                ProjectContribution projectContribution = (ProjectContribution) iterator.next();
                Person person = projectContribution.getContributor();
                String [] initialsArray = person.getFirstName().split(" ");
                String initials = "";
                for (String s:initialsArray) initials = initials + s.charAt(0);
                authorList = authorList + person.getLastName() + ", " + initials;
                if (iterator.hasNext()) authorList = authorList + ", ";
                else authorList = authorList + " ";
            }

            SimpleDateFormat sdfYear = new SimpleDateFormat("yyyy");
            SimpleDateFormat sdfDate = new SimpleDateFormat("dd MMM yyyy");
            stringBuilder.append(authorList + "(" + sdfYear.format(project.getCreateDate()) +
                    ") Data from: '" + project.getTitle() + ".'" + " ZoaTrack.org Date Accessed: " + sdfDate.format(new Date()) +"\n\n");
        }
        stringBuilder.append("If you use these data in any type of publication then you must cite the above and any published " +
                "peer-reviewed papers associated with the study. We strongly recommend that you contact the data custodians to " +
                "discuss data usage and appropriate accreditation.\n\n");
        return stringBuilder.toString();
    }

    private String licence() {

        //Terms of Use
        //Licence: ${dataLicence.title} (${dataLicence.identifier})
        //${dataLicence.infoUrl}
        //Data Provider Rights Statement
        //${rightsStatement}
        DataLicence licence = project.getDataLicence();
        String termsOfUse = "Terms of Use\n" +
                "Licence: " + licence.getTitle() + "(" + licence.getIdentifier() + ")\n" +
                 licence.getInfoUrl()+ "\n\n";
        termsOfUse += project.getRightsStatement().isEmpty() ? "" : "Data Provider Rights Statement\n" + project.getRightsStatement() + "\n\n";
        return termsOfUse;
    }

    private String relatedPublications() {

        List<Publication> publicationList = project.getPublications();
        Collections.sort(publicationList, new Comparator<Publication>(){
            public int compare(Publication p1, Publication p2){
                return p1.getOrdinal() - p2.getOrdinal();
            }
        });

        StringBuilder stringBuilder = new StringBuilder("Related Publications\n\n");
        for(Publication publication : publicationList) {
            stringBuilder.append(publication.getReference() + "\n" + publication.getUrl() + "\n\n");
        }
        return publicationList.isEmpty() ? "" : stringBuilder.toString();

    }

}
