package org.oztrack.util;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.oztrack.data.model.types.DataFeedSourceSystem;
import org.oztrack.error.DataFeedException;

import java.net.URI;
import java.text.SimpleDateFormat;

public class SpotClient {

    private final Logger logger = Logger.getLogger(getClass());
    private String feedId;
    private String password;
    private final SimpleDateFormat isoDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss"); // no offset

    public SpotClient(String credentials) throws DataFeedException {
        try {
            JSONTokener jsonTokener = new JSONTokener(credentials);
            JSONObject jsonCredentials = new JSONObject(jsonTokener);
            this.feedId = jsonCredentials.getString("feed-id");
            this.password = jsonCredentials.getString("password");
        } catch (Exception e) {
            throw new DataFeedException("Could not usefully read credentials", e);
        }
    }

    public JSONArray retrieveMessagesJson() throws DataFeedException {
        JSONArray messageArray;
        try {
            URI uri = new URIBuilder()
                    .setScheme("https")
                    .setHost(DataFeedSourceSystem.SPOT.getUrl())
                    .setPath(this.feedId + "/message.json")
                    .setParameter("feedPassword", this.password)
                    .setParameter("endDate", isoDateTimeFormat.format(new java.util.Date()))
                    .build();
            HttpGet httpGet = new HttpGet(uri);
            DefaultHttpClient client = HttpClientUtils.createDefaultHttpClient();
            HttpResponse httpResponse = client.execute(httpGet);
            int status = httpResponse.getStatusLine().getStatusCode();
            String httpResponseString = EntityUtils.toString(httpResponse.getEntity());
            if (status != 200) {
                logger.error(status + " || " + httpResponseString);
                throw new DataFeedException("Spot http call response status: " + status);
            }
            JSONObject httpResponseJson = new JSONObject(httpResponseString);
            JSONObject spotResponse = httpResponseJson.getJSONObject("response");

            if (spotResponse.has("errors")) {
                JSONObject errors = (JSONObject) spotResponse.get("errors");
                JSONObject error = (JSONObject) errors.get("error");
                String errorString = error.getString("code") + " " + error.getString("text") + " " + error.getString("description");
                throw new DataFeedException("Spot feed error: " + errorString);
            } else {
                JSONObject feedMessageResponse = (JSONObject) spotResponse.get("feedMessageResponse");
                JSONObject messages = (JSONObject) feedMessageResponse.get("messages");
                messageArray = messages.getJSONArray("message");
            }

        } catch (Exception e) {
            logger.error("Error retrieving Spot data: " + e.getMessage());
            throw new DataFeedException("Error retrieving Spot data: " + e.getMessage());
        }
        return messageArray;
    }


}
