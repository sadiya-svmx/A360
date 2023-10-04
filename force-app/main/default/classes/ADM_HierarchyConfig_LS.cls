/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete Hierarchy Configurations.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       25 May 2021      Created.
 *****************************************************************************************************/
public with sharing class ADM_HierarchyConfig_LS {
    
    /**
     * This method retrieves all available Hierarchy Configurations 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Hierarchy Configurations.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllHierarchyConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigurations() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().getAllHierarchyConfigurations();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Hierarchy Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of deleted Hierarchy Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse deleteHierarchyConfig( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - enter; hierarchyConfigId= ' + hierarchyConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().deleteHierarchyConfig( hierarchyConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieved the information of Hierarchy Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Hierarchy Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse getHierarchyConfigurationWithDetails( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationWithDetails() - enter; hierarchyConfigId= ' + hierarchyConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().getHierarchyConfigurationWithDetails( hierarchyConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationWithDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method saves the information of Hierarchy Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Hierarchy Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveHierarchyConfiguration( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.HierarchyConfig hierarchyConfig = (Adm.HierarchyConfig) JSON.deserializeStrict( requestJson, Adm.HierarchyConfig.class );
            serviceResponse = new ADM_AssetManagementService().saveHierarchyConfiguration( hierarchyConfig );
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to deserialize the requestJson parameter. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to save Hierarchy configuration. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieved the information of profile and related Hierarchy Configuration 
     * 
     * @return Returns instance of Common.ServiceResponse with response of the profile and related Hierarchy Configuration.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAssignedProfileDetails( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - enter; hierarchyConfigId= ' + hierarchyConfigId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_AssetManagementService().getAssignedProfileDetails( hierarchyConfigId );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

}