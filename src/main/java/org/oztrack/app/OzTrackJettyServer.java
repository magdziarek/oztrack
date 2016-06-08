package org.oztrack.app;

import java.io.File;
import org.eclipse.jetty.http.HttpVersion;
import org.eclipse.jetty.server.*;
import org.eclipse.jetty.util.ssl.SslContextFactory;
import org.eclipse.jetty.webapp.WebAppContext;


public class OzTrackJettyServer {
    public static void main(String[] args) throws Exception {

        Server server = new Server();

        File keystoreFile = new File("keystore");

        HttpConfiguration http_config = new HttpConfiguration();
        http_config.setSecureScheme("https");
        http_config.setSecurePort(9443);
        http_config.setOutputBufferSize(32768);

        ServerConnector http = new ServerConnector(server,
                new HttpConnectionFactory(http_config));
        http.setPort(8181);
        http.setIdleTimeout(30000);

        SslContextFactory sslContextFactory = new SslContextFactory();
        sslContextFactory.setKeyStorePath(keystoreFile.getAbsolutePath());
        sslContextFactory.setKeyStorePassword("123456");
        sslContextFactory.setKeyManagerPassword("123456");

        HttpConfiguration https_config = new HttpConfiguration(http_config);
        SecureRequestCustomizer src = new SecureRequestCustomizer();
        https_config.addCustomizer(src);

        ServerConnector https = new ServerConnector(server,
                new SslConnectionFactory(sslContextFactory,HttpVersion.HTTP_1_1.asString()),
                new HttpConnectionFactory(https_config));
        https.setPort(9443);
        https.setIdleTimeout(500000);

        server.setConnectors(new Connector[] { http, https });

        WebAppContext context = new WebAppContext();
        context.setContextPath("/");
        context.setResourceBase("src/main/webapp");
        context.setParentLoaderPriority(true);
        context.setInitParameter("org.eclipse.jetty.servlet.SessionIdPathParameterName", "none");
        server.setHandler(context);

        server.start();
        server.join();
    }
}