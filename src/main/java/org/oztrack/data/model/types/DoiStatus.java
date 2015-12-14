package org.oztrack.data.model.types;

public enum DoiStatus {

    DRAFT("This is a Draft. Please review the file and metadata before requesting to mint.",
            "ZoaTrack has automatically generated a zipped archive containing the data and metadata for this project. " +
            "While the request is a Draft, you can edit the project and rebuild the archive. " +
            "When you are satisfied that the archive and metadata are ready to be published, click on Mint DOI. The Administrators " +
            "will be notified and will review and manage the request."),
    REQUESTED("The request to mint a DOI has been submitted.",
            "The metadata and archive have been submitted to the Administrators who will review it and mint the DOI. " +
            "You will be contacted via email if there are any problems with the request. You can cancel the request and it will go back to Draft status."),
    REJECTED("The request has been rejected by the admin. Review and submit it again.",
            "The Administrators have determined that this dataset and metadata is not appropriate to publish. You can update your project, rebuild " +
            "the archive and resubmit the request."),
    FAILED("The DOI has failed to mint",
            "The DOI failed to mint. The Administrators are investigating the problem and will take action."),
    COMPLETED("This DOI has been minted"
            ,"The DOI has been successfully minted.");

    private final String shortMessage;
    private final String explanation;

    private DoiStatus(String shortMessage, String explanation) {
        this.shortMessage = shortMessage;
        this.explanation = explanation;
    }

    public String getExplanation() {
        return explanation;
    }
    public String getShortMessage() { return shortMessage; }


}
