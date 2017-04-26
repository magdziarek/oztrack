package org.oztrack.controller;

import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import javax.servlet.http.*;

import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.log4j.Logger;
import org.apache.commons.io.IOUtils;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.app.OzTrackConfiguration;
import org.oztrack.util.HttpClientUtils;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class ProxyController {

    private final Logger logger = Logger.getLogger(getClass());

    @RequestMapping(value="/proxy/portal.tern.org.au/ternapi/search", method=RequestMethod.GET)
    public void handleTernSearch(HttpServletRequest outerRequest, HttpServletResponse outerResponse) throws IOException {
        handle("http://portal.tern.org.au/ternapi/search", outerRequest, outerResponse);
    }

    @RequestMapping(value="/proxy/bie.ala.org.au/search", method=RequestMethod.GET)
    public void handleAlaSearch(HttpServletRequest outerRequest, HttpServletResponse outerResponse) throws IOException {
        handle("http://bie.ala.org.au/ws/search.json", outerRequest, outerResponse);
    }

    @RequestMapping(value="/proxy/bie.ala.org.au/search/auto.json", method=RequestMethod.GET)
    public void handleAlaSearchAuto(HttpServletRequest outerRequest, HttpServletResponse outerResponse) throws IOException {
        handle("http://bie.ala.org.au/ws/search/auto.json", outerRequest, outerResponse);
    }

    @RequestMapping(value="/proxy/blog", method=RequestMethod.GET)
    public void getBlogFeed(HttpServletRequest outerRequest, HttpServletResponse outerResponse) throws IOException {
        handle("https://zoatrack.wordpress.com/feed", outerRequest, outerResponse);
    }

    @RequestMapping(value="/proxy/bccvlapi", method=RequestMethod.POST, consumes="application/json")
    public void handleBccvlApi(HttpServletRequest outerRequest, HttpServletResponse outerResponse) throws IOException {

        String requestBody = IOUtils.toString(new InputStreamReader(outerRequest.getInputStream()));
        logger.info(requestBody);
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        String bccvlApiUrl = configuration.getBccvlApiUrl();
        DefaultHttpClient client = HttpClientUtils.createDefaultHttpClient();
        HttpPost innerPost = new HttpPost(URI.create("https://" + bccvlApiUrl));
        innerPost.setEntity(new StringEntity(requestBody, ContentType.APPLICATION_JSON));
        innerPost.setHeader("Authorization", outerRequest.getHeader("Authorization"));
        innerPost.setHeader("Content-type", "application/json");
        HttpResponse innerResponse = client.execute(innerPost);
        outerResponse.setStatus(innerResponse.getStatusLine().getStatusCode());
        outerResponse.setHeader("Location",innerResponse.getFirstHeader("Location").getValue());
        if (innerResponse.getEntity() != null) {
            IOUtils.copy(innerResponse.getEntity().getContent(), outerResponse.getOutputStream());
        }
    }

    private void handle(String baseUrl, HttpServletRequest request, HttpServletResponse response) throws IOException, ClientProtocolException {
        DefaultHttpClient client = HttpClientUtils.createDefaultHttpClient();
        HttpGet innerRequest = new HttpGet(URI.create(baseUrl + ((request.getQueryString() != null) ? ("?" + request.getQueryString()) : "")));
        HttpResponse innerResponse = client.execute(innerRequest);
        response.setStatus(innerResponse.getStatusLine().getStatusCode());
        if (innerResponse.getEntity() != null) {
            IOUtils.copy(innerResponse.getEntity().getContent(), response.getOutputStream());
        }
    }

    @RequestMapping(value="/proxy/youtubesearch", method=RequestMethod.GET)
    public void getYouTubeFeed(HttpServletRequest outerRequest, HttpServletResponse outerResponse) throws IOException {
        String youTubeUrl = "https://www.googleapis.com/youtube/v3/search";
        OzTrackConfiguration configuration = OzTrackApplication.getApplicationContext();
        DefaultHttpClient client = HttpClientUtils.createDefaultHttpClient();
        String newRequestString = outerRequest.getQueryString() + "&key=" + configuration.getGoogleApiKey();
        HttpGet innerRequest = new HttpGet(URI.create(youTubeUrl + ((outerRequest.getQueryString() != null) ? ("?" + newRequestString) : "")));
        HttpResponse innerResponse = client.execute(innerRequest);
        outerResponse.setStatus(innerResponse.getStatusLine().getStatusCode());

        if (innerResponse.getEntity() != null) {
            IOUtils.copy(innerResponse.getEntity().getContent(), outerResponse.getOutputStream());

        }
    }
}
