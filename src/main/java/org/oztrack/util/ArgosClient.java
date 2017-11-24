package org.oztrack.util;

import au.com.bytecode.opencsv.CSVWriter;
import fr.cls.argos.Data;
import fr.cls.argos.SatellitePass;
import fr.cls.argos.dataxmldistribution.service.DixException;
import fr.cls.argos.dataxmldistribution.service.DixService;
import fr.cls.argos.dataxmldistribution.service.DixServicePortType;
import fr.cls.argos.dataxmldistribution.service.types.*;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.oztrack.data.model.ArgosPlatformSummary;
import org.oztrack.error.DataFeedException;
import org.w3c.dom.*;
import org.xml.sax.InputSource;

import javax.activation.DataHandler;
import javax.xml.bind.*;
import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.XMLStreamWriter;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

public class ArgosClient {

    public static final int nbrDaysFromNowDefault = 10;
    private final Logger logger = Logger.getLogger(getClass());
    private String username;
    private String password;
    private DixServicePortType argosConnection;
    private DocumentBuilderFactory factory;
    private DocumentBuilder builder;


    public ArgosClient(String credentials) throws DataFeedException {

        try {
            this.factory = DocumentBuilderFactory.newInstance();
            this.builder = factory.newDocumentBuilder();
            this.argosConnection = new DixService().getDixServicePort();
            JSONTokener jsonTokener = new JSONTokener(credentials);
            JSONObject jsonCredentials = new JSONObject(jsonTokener);
            this.username = jsonCredentials.getString("username");
            this.password = jsonCredentials.getString("password");
        } catch (Exception e) {
            throw new DataFeedException("Could not usefully read credentials", e);
        }
    }

    public ArgosClient() {
    }

    private String getPlatformListXml() throws DataFeedException {
        PlatformListRequestType params = new PlatformListRequestType();
        String platformListStr = "";
        params.setUsername(this.username);
        params.setPassword(this.password);
        try {
            StringResponseType stringResponse = argosConnection.getPlatformList(params);
            platformListStr = stringResponse.getReturn();
        } catch (Exception e) {
            if (!platformListStr.isEmpty()) {
                logger.error(platformListStr);
            }
            throw new DataFeedException("Error retrieving platform list: " + e.getMessage());
        }
        return platformListStr;
    }

    public List<ArgosPlatformSummary> getPlatformList() throws DataFeedException {
        String xml = getPlatformListXml();
        //logger.info(xml);
        List<ArgosPlatformSummary> platformList = new ArrayList<ArgosPlatformSummary>();
        try {
            Document document = builder.parse(new InputSource(new StringReader(xml)));
            NodeList platformNodeList = document.getElementsByTagName("platform");
            for (int i = 0; i < platformNodeList.getLength(); i++) {
                JAXBContext jaxbContext = JAXBContext.newInstance(ArgosPlatformSummary.class);
                Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
                ArgosPlatformSummary platformSummary = (ArgosPlatformSummary) unmarshaller.unmarshal(platformNodeList.item(i));
                platformList.add(platformSummary);
            }
        } catch (Exception e) {
            if (!xml.isEmpty()) {
                logger.error(xml);
            }
            throw new DataFeedException("Platform list error: " + e.getMessage());
        }
        return platformList;
    }

    private String getXmlStream(long platformId) throws DataFeedException {
        XmlRequestType params = new XmlRequestType();
        params.setUsername(this.username);
        params.setPassword(this.password);
        params.setNbDaysFromNow(nbrDaysFromNowDefault);
        params.setPlatformId(Long.toString(platformId));
        params.setDisplayRawData(true);
        params.setDisplayDiagnostic(true);
        params.setDisplaySensor(true);
        params.setDisplayImageLocation(true);

        StreamResponseType streamResponseType = null;
        String xml = "";
        try {
            streamResponseType = argosConnection.getStreamXml(params);
            DataHandler dataHandler = streamResponseType.getReturn();
            InputStream inputStream = dataHandler.getInputStream();
            StringWriter stringWriter = new StringWriter();
            IOUtils.copy(inputStream, stringWriter);
            xml = stringWriter.toString();
        } catch (Exception e) {
            logger.error("Error retrieving data for platform " + platformId);
            throw new DataFeedException("Error retrieving data for platform " + platformId + " from Argos: " + e.getMessage());
        }
        //logger.info(xml);
        return xml;
    }

    public Data getPlatformData(long platformId) throws DataFeedException {
        String xml = getXmlStream(platformId);
        Data data = null;
        try {
            JAXBContext jaxbContext = JAXBContext.newInstance(Data.class);
            Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
            XMLInputFactory factory = XMLInputFactory.newInstance();
            XMLStreamReader streamReader = factory.createXMLStreamReader(new StringReader(xml));
            JAXBElement<Data> dataElement = unmarshaller.unmarshal(streamReader, Data.class);
            data = dataElement.getValue();
        } catch (Exception e) {
            logger.error("Error unmarshalling xml: " + e.getMessage());
            throw new DataFeedException("Error unmarshalling xml: " + e.getMessage());
        }
        return data;
    }

    public String getXml(SatellitePass satellitePass) {
        String xml = null;
        try {
            JAXBContext jaxbContext = JAXBContext.newInstance(SatellitePass.class);
            Marshaller marshaller = jaxbContext.createMarshaller();
            XMLOutputFactory factory = XMLOutputFactory.newInstance();
            StringWriter stringWriter = new StringWriter();
            XMLStreamWriter streamWriter = factory.createXMLStreamWriter(stringWriter);
            JAXBElement<SatellitePass> satellitePassJAXBElement = new JAXBElement<SatellitePass>(new QName("uri", "local"), SatellitePass.class, satellitePass);
            marshaller.marshal(satellitePassJAXBElement, streamWriter);
            xml = stringWriter.toString();

        } catch (Exception e) {
            logger.error("Error marshalling xml: " + e.getMessage());
        }
        return xml;
    }

    // used to get resources/org/oztrack/xsd/argos.xsd
    public String getXsd() {
        XsdRequestType params = new XsdRequestType();
        String xsd = "";
        try {
            StringResponseType stringResponseType = argosConnection.getXsd(params);
            xsd = stringResponseType.getReturn();
        } catch (DixException e) {
            e.printStackTrace();
        }
        return xsd;
    }

    public SatellitePass getSatellitePass(String xml) {

        SatellitePass satellitePass = null;
        try {
            JAXBContext jaxbContext = JAXBContext.newInstance(SatellitePass.class);
            Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
            XMLInputFactory factory = XMLInputFactory.newInstance();
            XMLStreamReader streamReader = factory.createXMLStreamReader(new StringReader(xml));
            JAXBElement<SatellitePass> satellitePassElement = unmarshaller.unmarshal(streamReader, SatellitePass.class);
            satellitePass = satellitePassElement.getValue();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return satellitePass;
    }

//    public CSVWriter writeSatellitePassCsvHeaders(CSVWriter writer) {
//
//    }
//
//    public CSVWriter appendSatellitePassToCsv(CSVWriter writer, SatellitePass satellitePass) {
//
//    }

}
