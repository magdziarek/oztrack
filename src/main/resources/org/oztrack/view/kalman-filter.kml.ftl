<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <#assign animal=analysis.animals[0]/>
    <Schema name="Overall" id="Overall">
      <SimpleField name="animalId" type="string">
        <displayName>Animal ID</displayName>
      </SimpleField>
      <SimpleField name="animalName" type="string">
        <displayName>Animal name</displayName>
      </SimpleField>
      <#list analysis.analysisType.parameterTypes as parameterType>
      <SimpleField name="${parameterType.identifier}" type="${parameterType.dataType}">
        <displayName>${parameterType.displayName}</displayName>
      </SimpleField>
      </#list>
      <#list analysis.analysisType.overallResultAttributeTypes as resultAttributeType>
      <SimpleField name="${resultAttributeType.identifier}" type="${resultAttributeType.dataType}">
        <displayName>${resultAttributeType.displayName}</displayName>
      </SimpleField>
      </#list>
    </Schema>
    <ExtendedData>
      <SchemaData schemaUrl="#Overall">
        <SimpleData name="animalId">${animal.id?c}</SimpleData>
        <SimpleData name="animalName">${animal.animalName}</SimpleData>
        <#list analysis.analysisType.parameterTypes as parameterType>
        <SimpleData name="${parameterType.identifier}"><#rt>
        <#if analysis.getParameterValue(parameterType.identifier, false)??><#t>
        <#if (parameterType.dataType == "date")><#t>
        ${analysis.getParameterValue(parameterType.identifier, false)?string("yyyy-MM-dd")}<#t>
        <#elseif (parameterType.dataType == "double")><#t>
        ${analysis.getParameterValue(parameterType.identifier, false)?c}<#t>
        <#elseif (parameterType.dataType == "boolean")><#t>
        ${analysis.getParameterValue(parameterType.identifier, false)?string}<#t>
        <#else><#t>
        ${analysis.getParameterValue(parameterType.identifier, false)?string}<#t>
        </#if><#t>
        </#if><#t>
        </SimpleData><#lt>
        </#list>
        <#list analysis.analysisType.overallResultAttributeTypes as resultAttributeType>
        <SimpleData name="${resultAttributeType.identifier}"><#rt>
        <#if (analysis.getResultAttributeValue(resultAttributeType.identifier)??)><#t>
        ${analysis.getResultAttributeValue(resultAttributeType.identifier)?c}<#t>
        </#if><#t>
        </SimpleData><#lt>
        </#list>
      </SchemaData>
    </ExtendedData>
    <name>${analysis.analysisType.displayName}</name>
    <description>
      <![CDATA[
        <div style="min-width: 500px;">
        <p>Generated by <a href="${baseUrl}/">ZoaTrack</a></p>
        <p><a href="${baseUrl}/projects/${analysis.project.id}">${analysis.project.title}</a></p>
        <p>Animal: <a href="${baseUrl}/projects/${analysis.project.id}/animals/$[Overall/animalId]">$[Overall/animalName]</a></p>
        <#if (analysis.analysisType.parameterTypes?size > 0)>
        <table style="float: left; margin-right: 20px; border-collapse: collapse;">
          <tr>
            <th style="border: 2px ridge; padding: 2px 4px; min-width: 100px; text-align: left; background-color: #ddd;">Parameter</th>
            <th style="border: 2px ridge; padding: 2px 4px; min-width: 100px; text-align: left; background-color: #ddd;">Value</th>
          </tr>
          <#list analysis.analysisType.parameterTypes as parameterType>
          <tr>
            <td style="border: 2px ridge; padding: 2px 4px;">$[Overall/${parameterType.identifier}/displayName]</td>
            <td style="border: 2px ridge; padding: 2px 4px;">$[Overall/${parameterType.identifier}]</td>
          </tr>
          </#list>
        </table>
        </#if>
        <#if (analysis.analysisType.overallResultAttributeTypes?size > 0)>
        <table style="float: left; border-collapse: collapse;">
          <tr>
            <th style="border: 2px ridge; padding: 2px 4px; min-width: 100px; text-align: left; background-color: #ddd;">Attribute</th>
            <th style="border: 2px ridge; padding: 2px 4px; min-width: 100px; text-align: left; background-color: #ddd;">Value</th>
          </tr>
          <#list analysis.analysisType.overallResultAttributeTypes as resultAttributeType>
          <tr>
            <td style="border: 2px ridge; padding: 2px 4px;">$[Overall/${resultAttributeType.identifier}/displayName]</td>
            <td style="border: 2px ridge; padding: 2px 4px;">$[Overall/${resultAttributeType.identifier}]</td>
          </tr>
          </#list>
        </table>
        </#if>
        <div style="clear: both;"></div>
        </div>
      ]]>
    </description>
    <open>1</open>
    <Style id="animal-${animal.id?c}-trajectory">
      <LineStyle>
        <color>ffffffff</color>
        <width>2</width>
      </LineStyle>
    </Style>
    <Style id="animal-${animal.id?c}-detection">
      <BalloonStyle>
        <text>
          <![CDATA[
            <p style="font-weight: bold;">$[name]</p>
            <p>Animal: <a href="${baseUrl}/projects/${analysis.project.id}/animals/$[Feature/animalId]">$[Feature/animalName]</a></p>
            <#if (analysis.analysisType.featureResultAttributeTypes?size > 0)>
            <table style="border-collapse: collapse;">
              <tr>
                <th style="border: 2px ridge; padding: 2px 4px; min-width: 100px; text-align: left; background-color: #ddd;">Attribute</th>
                <th style="border: 2px ridge; padding: 2px 4px; min-width: 100px; text-align: left; background-color: #ddd;">Value</th>
              </tr>
              <#list analysis.analysisType.featureResultAttributeTypes as resultAttributeType>
              <tr>
                <td style="border: 2px ridge; padding: 2px 4px;">$[Feature/${resultAttributeType.identifier}/displayName]</td>
                <td style="border: 2px ridge; padding: 2px 4px;">$[Feature/${resultAttributeType.identifier}]</td>
              </tr>
              </#list>
            </table>
            </#if>
          ]]>
        </text>
      </BalloonStyle>
      <IconStyle>
        <color>ffffffff</color>
        <scale>0.5</scale>
        <Icon>
          <href>http://maps.google.com/mapfiles/kml/shapes/triangle.png</href>
        </Icon>
      </IconStyle>
      <LabelStyle>
          <!-- Set alpha to 0 to hide labels -->
         <color>00ffffff</color>
      </LabelStyle>
    </Style>
    <Schema name="Feature" id="Feature">
      <SimpleField name="animalId" type="string">
        <displayName>Animal ID</displayName>
      </SimpleField>
      <SimpleField name="animalName" type="string">
        <displayName>Animal name</displayName>
      </SimpleField>
      <#list analysis.analysisType.featureResultAttributeTypes as resultAttributeType>
      <SimpleField name="${resultAttributeType.identifier}" type="${resultAttributeType.dataType}">
        <displayName>${resultAttributeType.displayName}</displayName>
      </SimpleField>
      </#list>
    </Schema>
    <Placemark>
      <name>Trajectory</name>
      <styleUrl>#animal-${animal.id?c}-trajectory</styleUrl>
      <TimeSpan>
        <begin>${analysis.resultFeatures?first.dateTime?iso_local_nz}</begin>
        <end>${analysis.resultFeatures?last.dateTime?iso_local_nz}</end>
      </TimeSpan>
      <LineString>
        <coordinates>
          <#list analysis.resultFeatures as resultFeature>
          ${resultFeature.geometry.x?c},${resultFeature.geometry.y?c}
          </#list>
        </coordinates>
      </LineString>
    </Placemark>
    <Folder>
      <name>Detections</name>
      <open>1</open>
      <#list analysis.resultFeatures as resultFeature>
      <Placemark>
        <name>${resultFeature.geometry.x?string("0.000")}, ${resultFeature.geometry.y?string("0.000")}</name>
        <styleUrl>#animal-${resultFeature.animal.id?c}-detection</styleUrl>
        <TimeStamp>
          <when>${resultFeature.dateTime?iso_local_nz}</when>
        </TimeStamp>
        <ExtendedData>
          <SchemaData schemaUrl="#Feature">
            <SimpleData name="animalId">${resultFeature.animal.id?c}</SimpleData>
            <SimpleData name="animalName">${resultFeature.animal.animalName}</SimpleData>
            <#list analysis.analysisType.featureResultAttributeTypes as resultAttributeType>
            <SimpleData name="${resultAttributeType.identifier}"><#rt>
            <#if (resultFeature.getAttributeValue(resultAttributeType.identifier)??)><#t>
            ${resultFeature.getAttributeValue(resultAttributeType.identifier)?c}<#t>
            </#if><#t>
            </SimpleData><#lt>
            </#list>
          </SchemaData>
        </ExtendedData>
        <Point>
          <coordinates>
             ${resultFeature.geometry.x?c},${resultFeature.geometry.y?c}
          </coordinates>
        </Point>
      </Placemark>
      </#list>
    </Folder>
  </Document>
</kml>