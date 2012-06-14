package org.oztrack.view;

import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.oztrack.app.OzTrackApplication;
import org.oztrack.data.access.ProjectDao;
import org.oztrack.data.access.UserDao;
import org.oztrack.data.model.Project;
import org.oztrack.error.DataSpaceInterfaceException;
import org.oztrack.util.DataSpaceInterface;
import org.springframework.web.servlet.view.AbstractView;

public class DataSpaceInterfaceView extends AbstractView {
    protected final Log logger = LogFactory.getLog(getClass());
    
    public DataSpaceInterfaceView() {
    }
    
    @Override
	protected void renderMergedOutputModel(
	    @SuppressWarnings("rawtypes") Map model,
	    HttpServletRequest request,
	    HttpServletResponse response
    ) throws Exception {
        // TODO: DAOs should not appear in this layer.
        ProjectDao projectDao = (ProjectDao) model.get("projectDao");
        UserDao userDao = (UserDao) model.get("userDao");
        
        @SuppressWarnings("unchecked")
        HashMap<String, Object> projectActionMap = (HashMap<String, Object>) model.get("projectActionMap");
	    
		Project tempProject = (Project) projectActionMap.get("project");
		String action = (String) projectActionMap.get("action");
		
	    Project project = projectDao.getProjectById(tempProject.getId());
	    String errorMessage = "";
	    
	    try {
	    	DataSpaceInterface dsi = new DataSpaceInterface(projectDao, userDao);
	    	if (action.equals("publish")) {
		    	dsi.updateDataSpace(project);
	    	} else if (action.equals("delete")) {
	    		dsi.deleteFromDataSpace(project);
	    	}
	    	project = projectDao.getProjectById(project.getId());

	    } catch (DataSpaceInterfaceException e) {
	    	errorMessage = e.getMessage();
	    }
	    
	    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");//("yyyy-MM-dd'T'HH:mm:ss'Z'");
	    String dataSpaceURL = OzTrackApplication.getApplicationContext().getDataSpaceURL() ;
	    
	    String agentURL = dataSpaceURL + "agents/" + project.getDataSpaceAgent().getDataSpaceAgentURI();	    
		String collectionURL = dataSpaceURL + "collections/" + project.getDataSpaceURI();
	    
	    String json = "{ \"dataSpaceAgentURL\" : \"" + agentURL + "\""
	    			+ ",\"dataSpaceAgentUpdateDate\" : \"" + simpleDateFormat.format(project.getDataSpaceAgent().getDataSpaceAgentUpdateDate()) + "\""
	    			+ ",\"dataSpaceCollectionURL\" : \"" + collectionURL + "\""
	    			+ ",\"dataSpaceUpdateDate\" : \"" + simpleDateFormat.format(project.getDataSpaceUpdateDate()) + "\""
	    			+ ",\"errorMessage\" : \"" + errorMessage + "\""
	    			+ "}";	
	    
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		response.getWriter().write(json);
		response.getWriter().flush();
		
	}

}
