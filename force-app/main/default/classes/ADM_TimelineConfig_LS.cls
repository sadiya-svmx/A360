/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete Timeline Configurations.
 *
 * @author Adam Daw
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Adam Daw       31 May 2021      Created.
 *****************************************************************************************************/
public with sharing class ADM_TimelineConfig_LS {
    
    /**
     * This method retrieves all available Timeline Configurations 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Timeline Configurations.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllTimelineConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigurations() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().getAllTimelineConfigurations();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Timeline Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Timeline Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTimelineConfig( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - enter; timelineConfigId= ' + timelineConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().deleteTimelineConfig( timelineConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes a Timeline Detail
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Timeline Detail.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteTimelineDetail( final String timelineDetailId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - enter; timelineDetailId= ' + timelineDetailId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().deleteTimelineDetail( timelineDetailId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieved the information of Timeline Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Timeline Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse getTimelineConfigurationWithDetails( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationWithDetails() - enter; timelineConfigId= ' + timelineConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().getTimelineConfigurationWithDetails( timelineConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationWithDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Timeline Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Timeline Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveTimelineConfiguration( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.TimelineConfig timelineConfig = (Adm.TimelineConfig) JSON.deserializeStrict( requestJson, Adm.TimelineConfig.class );
            serviceResponse = new ADM_AssetManagementService().saveTimelineConfiguration( timelineConfig );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to save Timeline configuration. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    /**
     * This method retrieves all previously assigned Profiles for all Timeline Configurations
     * @return instance of Common.ServiceResponse with list of all Configuration Assignments.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllAssignedProfileDetails(){
       
        System.debug( LoggingLevel.DEBUG, 'getAllAssignedProfileDetails() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().getAllAssignedProfileDetails();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllAssignedProfileDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse saveTimelineCategories( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.TimelineConfig timelineConfig = (Adm.TimelineConfig) JSON.deserializeStrict( requestJson, Adm.TimelineConfig.class );
            serviceResponse = new ADM_AssetManagementService().saveTimelineConfiguration( timelineConfig );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to save Timeline configuration. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

}