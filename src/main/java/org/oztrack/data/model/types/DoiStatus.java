package org.oztrack.data.model.types;

public enum DoiStatus {

    DRAFT("This is a Draft. Please review the zip file and metadata before requesting to mint the DOI.",
            "You have created a zip file containing the raw animal detection data and associated metadata " +
            "that will form the content of your DOI. " +
            "Please download the file and review it carefully before submitting. "),
    REQUESTED("The request to mint a DOI has been submitted.",
            "The data and metadata have been submitted and will be manually reviewed and minted. " +
                "You will be contacted via email if there are any problems with the request. " +
                "You can cancel the request and it will go back to Draft status. However, once the DOI has been minted you won't be able" +
                    " to make any changes."),
    REJECTED("The request to mint a DOI has been rejected. Review and submit it again.",
            "The request to mint a DOI has been rejected by ZoaTrack. " +
                    "You can delete the request, update your project and resubmit the request."),
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
