package org.oztrack.util;

import org.apache.commons.codec.binary.StringUtils;
import org.apache.http.*;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.commons.codec.binary.Base64;
import org.apache.http.entity.ContentType;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import java.net.URI;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONObject;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.data.access.DoiDao;
import org.oztrack.data.model.Doi;

public class DoiClient {

    private final Logger logger = Logger.getLogger(getClass());

    String andsDoiBaseUrl;
    String andsDoiAppId;
    String andsDoiKey;
    String andsDoiClientId;

    public DoiClient()  {

        logger.info("init DoiClient");
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        this.andsDoiBaseUrl = configuration.getDoiBaseUrl();
        this.andsDoiAppId = configuration.getDoiAppId();
        this.andsDoiKey = configuration.getDoiKey();
        this.andsDoiClientId = configuration.getDoiClientId();

    }

    public JSONObject statusCheck()  throws Exception {

        URI uri = new URIBuilder()
                .setScheme("https")
                .setHost(this.andsDoiBaseUrl)
                .setPath("status.json")
                .build();

        logger.info("Status check URI : " + uri.toString());

        HttpGet httpGet = new HttpGet(uri);
        DefaultHttpClient client = HttpClientUtils.createDefaultHttpClient();
        HttpResponse httpResponse = client.execute(httpGet);
        JSONObject httpResponseJson = new JSONObject(EntityUtils.toString(httpResponse.getEntity()));
        JSONObject andsResponse = httpResponseJson.getJSONObject("response");
        return andsResponse;

    }

    public JSONObject mintDOI(Doi doi) throws Exception {

        String secret = Base64.encodeBase64String(StringUtils.getBytesUtf8(this.andsDoiAppId + ":" + this.andsDoiKey));
        URI uri = new URIBuilder()
                .setScheme("https")
                .setHost(this.andsDoiBaseUrl)
                .setPath("mint.json/")
                .setParameter("app_id", this.andsDoiAppId)
                .setParameter("url", URLEncoder.encode(doi.getUrl(), "UTF-8"))
                .setParameter("response_type", "json")
                .build();

        HttpPost httpPost = new HttpPost(uri);
        httpPost.addHeader("Accept", "ContentType.JSON");
        httpPost.addHeader("Authorization", "Basic " + secret);

        List<NameValuePair> nameValuePairList = new ArrayList<NameValuePair>();
        nameValuePairList.add(new BasicNameValuePair("xml", doi.getXml()));
        UrlEncodedFormEntity fe = new UrlEncodedFormEntity(nameValuePairList, Consts.UTF_8);
        fe.setContentType(ContentType.APPLICATION_FORM_URLENCODED.toString());
        httpPost.setEntity(fe);

        DefaultHttpClient client = HttpClientUtils.createDefaultHttpClient();
        HttpResponse httpResponse = client.execute(httpPost);
        JSONObject httpResponseJson = new JSONObject(EntityUtils.toString(httpResponse.getEntity()));
        logger.info("return json: " + httpResponseJson.toString());
        JSONObject andsResponse = httpResponseJson.getJSONObject("response");

    return andsResponse;

    }


}
