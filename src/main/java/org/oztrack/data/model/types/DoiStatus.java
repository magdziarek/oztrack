package org.oztrack.data.model.types;

public enum DoiStatus {

    DRAFT("The DOI package has been prepared and is being reviewed by the Manager of the Project."),
    REVIEW("The DOI package has been submitted to the Administrators for review."),
    REJECTED("The Administrators have rejected the package."),
    DELETED("The Manager of the Project has deleted this package"),
    FAILED("The DOI failed to mint."),
    COMPLETED("The DOI has been minted.");

    private final String explanation;

    private DoiStatus(String explanation) {
        this.explanation = explanation;
    }

    public String getExplanation() {
        return explanation;
    }


}
