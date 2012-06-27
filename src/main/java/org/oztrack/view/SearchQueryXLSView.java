package org.oztrack.view;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.oztrack.data.access.PositionFixDao;
import org.oztrack.data.model.PositionFix;
import org.oztrack.data.model.SearchQuery;
import org.oztrack.data.model.types.ProjectType;
import org.springframework.web.servlet.view.document.AbstractExcelView;

public class SearchQueryXLSView extends AbstractExcelView {
    public static final String SEARCH_QUERY_KEY = "searchQuery";

    // TODO: DAO should not appear in this layer.
    private PositionFixDao positionFixDao;

    public SearchQueryXLSView(PositionFixDao positionFixDao) {
        this.positionFixDao = positionFixDao;
    }

    @Override
    protected void buildExcelDocument(
        @SuppressWarnings("rawtypes") Map model,
        HSSFWorkbook workbook,
        HttpServletRequest request,
        HttpServletResponse response
    ) throws Exception {
        SearchQuery searchQuery = (SearchQuery) model.get(SEARCH_QUERY_KEY);
        ProjectType projectType = searchQuery.getProject().getProjectType();
        HSSFSheet sheet = workbook.createSheet("OzTrack " + projectType.getDisplayName());

        switch (projectType) {
            case GPS:
               this.buildPositionFixSheet(sheet,searchQuery);
               break;
            default:
                ;
        }
    }


    protected void buildPositionFixSheet(HSSFSheet sheet, SearchQuery searchQuery) {

        List<PositionFix> positionFixes = positionFixDao.queryProjectPositionFixes(searchQuery);

        HSSFRow headerRow = sheet.createRow(0);
        headerRow.createCell(0).setCellValue("animal_id");
        headerRow.createCell(1).setCellValue("name");
        headerRow.createCell(2).setCellValue("detection_time");
        headerRow.createCell(3).setCellValue("latitude");
        headerRow.createCell(4).setCellValue("longitude");

        int rowNum = 1;
        for (PositionFix positionFix : positionFixes) {

            HSSFRow row = sheet.createRow(rowNum);
            row.createCell(0).setCellValue(positionFix.getAnimal().getId().toString());
            row.createCell(1).setCellValue(positionFix.getAnimal().getAnimalName());
            row.createCell(2).setCellValue(positionFix.getDetectionTime());
            row.createCell(3).setCellValue(positionFix.getLatitude());
            row.createCell(4).setCellValue(positionFix.getLongitude());
            rowNum++;
        }
    }
}
