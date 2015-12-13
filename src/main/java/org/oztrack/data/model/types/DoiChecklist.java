package org.oztrack.data.model.types;


public enum DoiChecklist {

    LICENCE(
            "Licence",
            "The project dataset is available under a Creative Commons Licence and is openly accessible.",
            "ZoaTrack checks the licence that has been allocated to this project."),

    AUTHORS(
            "Authors",
            "Information about the authorship of the project has been added to ZoaTrack.",
            "ZoaTrack checks that there is a list of authors, or contributors, added to the project."),

    RESEARCH(
            "Australian Research",
            "The dataset forms part of the scholarly record",
            "ZoaTrack checks that at least one of the authors has a relationship with an Australian research institution."),

    DATA(
            "Dataset",
            "The dataset contains at least one animal track",
            "ZoaTrack will check that at least one dataset exists in the project.");

    private final String title;
    private final String description;
    private final String requirements;

    private DoiChecklist(String title, String description, String requirements) {

        this.title = title;
        this.description = description;
        this.requirements = requirements;
    }

    public String getTitle() { return title; }

    public String getDescription() {
        return description;
    }

    public String getRequirements() {
        return requirements;
    }
}
