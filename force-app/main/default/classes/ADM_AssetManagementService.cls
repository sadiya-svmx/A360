/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to retrieve/save/delete operations 
 * on asset timeline and hierarchy configurations.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        	Name                    Date            Comment
 *****************************************************************************************************
 *              	Sandeep Dhariwal       25 May 2021     	Created.
 *              	Adam Daw               02 June 2021    	Added Timeline Methods
 * A360TOOL-554 	Ramachandra Mohan      08 Jun 2021		Support Apex REST services.
 *****************************************************************************************************/
public with sharing class ADM_AssetManagementService extends ADM_AbstractAssetManagementService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_AssetManagementService(){}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_AssetManagementService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    /**
     * This method retrieves all available hierarchy configurations 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all hierarchy configuration information.
     * @see ADM_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse getAllHierarchyConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigurations() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign hierarchy configuration informations to response data.
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getAllHierarchyConfigurations();
            System.debug( LoggingLevel.INFO, 'getAllHierarchyConfigurations() : Retrieved hierarchy configuration list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllHierarchyConfigurations() : Failed to retrieve hierarchy configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllHierarchyConfigurations() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all available timeline configurations 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all timeline configuration information.
     * @see ADM_AssetManagementServiceImpl
     */
    override public Common.ServiceResponse getAllTimelineConfigurations() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigurations() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign hierarchy configuration informations to response data.
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getAllTimelineConfigurations();
            System.debug( LoggingLevel.INFO, 'getAllTimelineConfigurations() : Retrieved timeline configuration list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTimelineConfigurations() : Failed to retrieve timeline configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTimelineConfigurations() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to delete the hierarchy configuration.
     * 
     * @param hierarchyConfigId Id of hierarchy configuration for which 
     *             hierarchy configuration record will be deleted.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example deleteHierarchyConfig(Id configId);
     */
    
    public Common.ServiceResponse deleteHierarchyConfig( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_AssetManagementServiceImpl().deleteHierarchyConfig( hierarchyConfigId );
            System.debug( LoggingLevel.INFO, 'deleteHierarchyConfig() : Deleted hierarchy configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteHierarchyConfig() : Failed to delete hierarchy configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to delete the timeline configuration.
     * 
     * @param timelineConfigId Id of timeline configuration for which 
     *             timeline configuration record will be deleted.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example deleteTimelineConfig(Id timelineConfigId);
     */
    
    public Common.ServiceResponse deleteTimelineConfig( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_AssetManagementServiceImpl().deleteTimelineConfig( timelineConfigId );
            System.debug( LoggingLevel.INFO, 'deleteTimelineConfig() : Deleted timeline configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineConfig() : Failed to delete timeline configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to delete the timeline detail.
     * 
     * @param timelineDetailId Id of timeline detail which will be deleted.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example deleteTimelineDetail(Id timelineDetailId);
     */
    
    public Common.ServiceResponse deleteTimelineDetail( final String timelineDetailId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_AssetManagementServiceImpl().deleteTimelineDetail( timelineDetailId );
            System.debug( LoggingLevel.INFO, 'deleteTimelineDetail() : Deleted timeline detail successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineDetail() : Failed to delete timeline detail. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve the hierarchy configuration.
     * 
     * @param hierarchyConfigId Id of hierarchy configuration for which 
     *             hierarchy configuration information will be fetched.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example getHierarchyConfigurationWithDetails(Id configId);
     */
    
    override public Common.ServiceResponse getHierarchyConfigurationWithDetails( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getHierarchyConfigurationWithDetails( hierarchyConfigId );
            System.debug( LoggingLevel.INFO, 'getHierarchyConfigurationWithDetails() : fetched hierarchy configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationWithDetails() : Failed to fetch hierarchy configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyConfigurationWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve the timeline configuration.
     * 
     * @param timelineConfigId Id of timeline configuration for which 
     *             timeline configuration information will be fetched.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example getTimelineConfigurationWithDetails(Id configId);
     */
    
    override public Common.ServiceResponse getTimelineConfigurationWithDetails( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getTimelineConfigurationWithDetails( timelineConfigId );
            System.debug( LoggingLevel.INFO, 'getTimelineConfigurationWithDetails() : fetched timeline configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationWithDetails() : Failed to fetch timeline configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineConfigurationWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save the hierarchy configuration.
     * 
     * @param hierarchyConfig Information of hierarchy configuration which will be created.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example saveHierarchyConfiguration(HierarchyConfig configId);
     */
    
    override public Common.ServiceResponse saveHierarchyConfiguration( final Adm.HierarchyConfig hierarchyConfig ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().saveHierarchyConfiguration( hierarchyConfig );
            System.debug( LoggingLevel.INFO, 'saveHierarchyConfiguration() : upserted hierarchy configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to save hierarchy configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveHierarchyConfiguration() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to validate the hierarchy configuration.
     * 
     * @param hierarchyConfig Information of hierarchy configuration which will be validated.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example validateHierarchyConfiguration(HierarchyConfig configId);
     */
    
    override public Common.ServiceResponse validateHierarchyConfiguration( final Adm.HierarchyValidationRequest hierarchyValidationRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateHierarchyConfiguration() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().validateHierarchyConfiguration( hierarchyValidationRequest );
            System.debug( LoggingLevel.INFO, 'validateHierarchyConfiguration() : upserted hierarchy configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateHierarchyConfiguration() : Failed to validate hierarchy configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateHierarchyConfiguration() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save the timeline configuration.
     * 
     * @param timelineConfig Information of timeline configuration which will be created.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example saveTimelineConfiguration(TimelineConfig configId);
     */
    
    override public Common.ServiceResponse saveTimelineConfiguration( final Adm.TimelineConfig timelineConfig ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().saveTimelineConfiguration( timelineConfig );
            System.debug( LoggingLevel.INFO, 'saveTimelineConfiguration() : upserted timeline configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to save timeline configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTimelineConfiguration() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to validate the timeline configuration.
     * 
     * @param timelineConfig Information of timeline configuration which will be validated.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example validateTimelineConfiguration(TimelineConfig configId);
     */
    
    override public Common.ServiceResponse validateTimelineConfiguration( final Adm.TimelineValidationRequest request ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateTimelineConfiguration() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().validateTimelineConfiguration( request );
            System.debug( LoggingLevel.INFO, 'validateTimelineConfiguration() : validate timeline configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTimelineConfiguration() : Failed to validate timeline configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateTimelineConfiguration() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve assigned profiles for asset hierarchy.
     */
    override public Common.ServiceResponse getHierarchyAssignedProfileDetails( final String recordId ) {
        return getAssignedProfileDetails(recordId);
    }
    
    /**
     * This method is used to retrieve assigned profiles for asset timeline.
     */
    override public Common.ServiceResponse getTimelineAssignedProfileDetails( final String recordId ) {
        return getAssignedProfileDetailsForTimeline(recordId);
    }
    
    /**
     * This method is used to retrieve the profile and related information of hierarchy configuration.
     * 
     * @param hierarchyConfigId Id of hierarchy configuration for which 
     *             related profile and hierarchy configuration information will be fetched.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example getAssignedProfileDetails(Id configId);
     */
    
    public Common.ServiceResponse getAssignedProfileDetails( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getAssignedProfileDetails( hierarchyConfigId );
            System.debug( LoggingLevel.INFO, 'getAssignedProfileDetails() : fetched profile and related hierarchy configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetails() : Failed to fetch profile hierarchy configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve the profile and related information of timeline configuration.
     * 
     * @param timelineConfigId Id of timeline configuration for which 
     *             related profile and timeline configuration information will be fetched.
     * @return Returns  instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example getAssignedProfileDetailsForTimeline(Id configId);
     */
    
    public Common.ServiceResponse getAssignedProfileDetailsForTimeline( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getAssignedProfileDetailsForTimeline( timelineConfigId );
            System.debug( LoggingLevel.INFO, 'getAssignedProfileDetailsForTimeline() : fetched profile and related timeline configuration successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetailsForTimeline() : Failed to fetch profile timeline configuration. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssignedProfileDetailsForTimeline() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve the profile and related information of timeline configuration.
     * 
     * @return Returns  instance of Common.ServiceResponse with a list of all profile assignments
     * @see ADM_AssetManagementServiceImpl
     * 
     * @example getAllAssignedProfileDetails();
     */
    
    public Common.ServiceResponse getAllAssignedProfileDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllAssignedProfileDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_AssetManagementServiceImpl().getAllAssignedProfileDetails( );
            System.debug( LoggingLevel.INFO, 'getAllAssignedProfileDetails() : fetched profiles' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllAssignedProfileDetails() : Failed to fetch profiles. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllAssignedProfileDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

}