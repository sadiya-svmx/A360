/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for asset management service implementation.
 *
 * @author Ramachandra Mohan
 * @version Sum 21
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       08 Jun 2021     Created.
 *****************************************************************************************************/
public abstract class ADM_AbstractAssetManagementService extends COMM_SvmxRestBase {
    
    public ADM_AbstractAssetManagementService(){
    }
    
    protected ADM_AbstractAssetManagementService(RestRequest req, RestResponse res) {
        super(req, res, 'assetManagement');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getAllHierarchyConfigurations' {
                    response = getAllHierarchyConfigurations();
                }            
                when 'getAllTimelineConfigurations' {
                    response = getAllTimelineConfigurations();
                }
                when 'getHierarchyConfigurationWithDetails' {          
                    response = getHierarchyConfigurationWithDetails( recordId );
                }
                when 'getTimelineConfigurationWithDetails' {          
                    response = getTimelineConfigurationWithDetails( recordId );
                }
                when 'saveHierarchyConfiguration' {                
                    response = saveHierarchyConfiguration( (Adm.HierarchyConfig) deserializeRequestTo( Adm.HierarchyConfig.class ) );
                }
                when 'validateHierarchyConfiguration' {                
                    response = validateHierarchyConfiguration( (Adm.HierarchyValidationRequest) deserializeRequestTo( Adm.HierarchyValidationRequest.class ) );
                }
                when 'saveTimelineConfiguration' {                
                    response = saveTimelineConfiguration( (Adm.TimelineConfig) deserializeRequestTo( Adm.TimelineConfig.class ) );
                }
                when 'validateTimelineConfiguration' {                
                    response = validateTimelineConfiguration( (Adm.TimelineValidationRequest) deserializeRequestTo( Adm.TimelineValidationRequest.class ) );
                }
                when 'getHierarchyAssignedProfileDetails' {          
                    response = getHierarchyAssignedProfileDetails( recordId );
                }
                when 'getTimelineAssignedProfileDetails' {          
                    response = getTimelineAssignedProfileDetails( recordId );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }
    
    /**
     * This method is used to retrieve all Hierarchy Configurations from the Org.
     * 
     * @return Returns list of all Hierarchy Configurations.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/assetManagement/v1/getAllHierarchyConfigurations/
     */
    public abstract Common.ServiceResponse getAllHierarchyConfigurations();
    
    /**
     * This method is used to retrieve all Timeline Configurations from the Org.
     * 
     * @return Returns list of all Timeline Configurations.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/assetManagement/v1/getAllTimelineConfigurations/
     */
    public abstract Common.ServiceResponse getAllTimelineConfigurations();

    /**
     * This method is used to save the Hierarchy Configuration in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/assetManagement/v1/saveHierarchyConfiguration/
     */
    public abstract Common.ServiceResponse saveHierarchyConfiguration( final Adm.HierarchyConfig hierarchyConfig );
    
    /**
     * This method is used to validate the Hierarchy Configuration in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/assetManagement/v1/validateHierarchyConfiguration/
     */
    public abstract Common.ServiceResponse validateHierarchyConfiguration( final Adm.HierarchyValidationRequest hierarchyValidationRequest );
    
    /**
     * This method is used to save the Timeline Configuration in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/assetManagement/v1/saveTimelineConfiguration/
     */
    public abstract Common.ServiceResponse saveTimelineConfiguration( final Adm.TimelineConfig timelineConfig );
    
    /**
     * This method is used to validate the Timeline Configuration in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/assetManagement/v1/validateTimelineConfiguration/
     */
    public abstract Common.ServiceResponse validateTimelineConfiguration( final Adm.TimelineValidationRequest timelineConfig );
    
    /**
     * This method is used to retrieve the Hierarchy with details in the Org for the given id.
     * 
     * 
     * @example GET /services/apexrest/SVMXA360/admin/assetManagement/v1/getHierarchyConfigurationWithDetails/
     */
    public abstract Common.ServiceResponse getHierarchyConfigurationWithDetails( final String recordId );
    
    /**
     * This method is used to retrieve the Timeline with details in the Org for the given id.
     * 
     * 
     * @example GET /services/apexrest/SVMXA360/admin/assetManagement/v1/getTimelineConfigurationWithDetails/
     */
    public abstract Common.ServiceResponse getTimelineConfigurationWithDetails( final String recordId );
    
    /**
     * This method is used to retrieve the Hierarchy assigned profile details 
     * in the Org for the given id.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/assetManagement/v1/getHierarchyAssignedProfileDetails/
     */
    public abstract Common.ServiceResponse getHierarchyAssignedProfileDetails( final String recordId );
    
    /**
     * This method is used to retrieve the Timeline assigned profile details 
     * in the Org for the given id.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/assetManagement/v1/getTimelineAssignedProfileDetails/
     */
    public abstract Common.ServiceResponse getTimelineAssignedProfileDetails( final String recordId );
}