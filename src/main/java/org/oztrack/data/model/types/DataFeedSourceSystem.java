package org.oztrack.data.model.types;

public enum DataFeedSourceSystem {


    // the source systems that are handled in zoatrack
    ARGOS("Argos", "API", "argos-system.cls.fr", "{username:username, password:password}", "platform", ""),
    SPOT("Spot", "API", "findmespot.com", "{feed-id:feed-id}", "device", "");

    private final String name;              // name for this datafeed
    private final String sourceSystemType;  // API, EMAIL
    private final String location;          // URL, email address
    private final String credentialsJson;   // specifies the format of access information
    private final String deviceIdentifierDescriptor;  // the term used to describe a device in this system eg. platform, sensor, device
    private final String explanation;       // explanation for handling

    DataFeedSourceSystem(String name, String sourceSystemType, String location, String credentialsJson, String deviceIdentifierDescriptor, String explanation) {
        this.name = name;
        this.sourceSystemType = sourceSystemType;
        this.location = location;
        this.credentialsJson = credentialsJson;
        this.deviceIdentifierDescriptor = deviceIdentifierDescriptor;
        this.explanation = explanation;
    }

    public String getName() {
        return this.name;
    }

    public String getSourceSystemType() {
        return this.sourceSystemType;
    }

    public String getUrl() {
        return this.location;
    }

    public String getCredentialsJson() {
        return this.credentialsJson;
    }

    public String getDeviceIdentifierDescriptor() {
        return this.deviceIdentifierDescriptor;
    }

    public String getExplanation() {
        return this.explanation;
    }

}
