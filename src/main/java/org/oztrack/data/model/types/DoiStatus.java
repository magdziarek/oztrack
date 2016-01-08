package org.oztrack.data.model.types;

public enum DoiStatus {

    DRAFT("This request is a Draft.",
            "You have just created a zip file containing the animal location data, project and individual " +
            "track metadata. These files will comprise the documentation linked to the Digital Object Identifier. " +
            "Please download the zip file and review it carefully before final submission."),
    REQUESTED("The request to mint a DOI has been submitted.",
            "The data and metadata have been submitted and will be manually reviewed and minted. " +
                "You will be contacted via email if there are any problems with the request. " +
                "You can cancel the request and it will go back to Draft status. However, once the DOI has been minted you won't be able" +
                    " to make any changes."),
    REJECTED("The request to mint a DOI has been rejected. Review and submit it again.",
            "The request to mint a DOI has been rejected by ZoaTrack. " +
                    "You can delete the request, or you update your project using the links on the left and resubmit the request."),
    FAILED("The DOI has failed to mint.",
            "The DOI failed to mint. The Administrators are investigating the problem and will take action."),
    COMPLETED("A DOI has been minted for this project."
            ,"The DOI has been successfully minted. You can no longer make changes to this dataset.");

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
