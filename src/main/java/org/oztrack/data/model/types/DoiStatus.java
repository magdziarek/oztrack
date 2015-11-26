package org.oztrack.data.model.types;

public enum DoiStatus {

    DRAFT("ZoaTrack has automatically generated a zipped archive containing the data and metadata for this project, " +
            "and this landing page that the DOI URL will resolve to. " +
            "While the request is a Draft, you can edit the project and rebuild the archive. " +
            "When you are satisfied the archive and landing page is ready to be given an DOI, click on Mint DOI. The Administrators " +
            "will be notified and will review and manage the request."),
    REQUESTED("The archive has been submitted to the Administrators who will review it and mint the DOI. " +
            "You will be contacted via email if there are any problems with the request. You can cancel the request and it will go back to Draft status."),
    REJECTED("The Administrators have reviewed the archive and determined that it is not appropriate to mint a DOI on it."),
    FAILED("The DOI failed to mint. The Administrators are investigating the problem and will take action."),
    COMPLETED("The DOI has been successfully minted.");

    private final String explanation;

    private DoiStatus(String explanation) {
        this.explanation = explanation;
    }

    public String getExplanation() {
        return explanation;
    }


}
