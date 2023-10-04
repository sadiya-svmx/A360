/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete operations 
 * on Hierarchy Configurations.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       25 May 2021     Created.
 *              Adam Daw               02 June 2021    Updated with Timeline methods.
 *****************************************************************************************************/
public with sharing class ADM_AssetManagementServiceImpl {
    
    private final ADM_HierarchyConfigManager hierarchyConfigManager = ADM_HierarchyConfigManager.getInstance();
    private final ADM_TimelineConfigManager timelineConfigManager = ADM_TimelineConfigManager.getInstance();

    /**
     * This method retrieves all hierarchy configurations and populates 
     * information it to the hierarchy config wrapper.
     */
	public List<Adm.HierarchyConfig> getAllHierarchyConfigurations() {
        System.debug( LoggingLevel.FINEST, 'getAllHierarchyConfigurations() - enter');
        
        List<Adm.HierarchyConfig> hierarchyConfigList = new List<Adm.HierarchyConfig>();
        
        try {
            // Retrieve hierarchy configuration information from hierarchyConfig manager.
            hierarchyConfigList = hierarchyConfigManager.getAllHierarchyConfigurations();
            System.debug( LoggingLevel.INFO, 'getAllHierarchyConfigurations() : Retrieved all hierarchy configuration information. hierarchyConfigList.size()= ' + hierarchyConfigList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllHierarchyConfigurations() : Failed to retrieve hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllHierarchyConfigurations() - exit; hierarchyConfigList.size()= ' + hierarchyConfigList.size() );
        }
        
        return hierarchyConfigList;
    }

    /**
     * This method retrieves all timeline configurations and populates 
     * information it to the timeline config wrapper.
     */
	public List<Adm.TimelineConfig> getAllTimelineConfigurations() {
        System.debug( LoggingLevel.FINEST, 'getAllTimelineConfigurations() - enter');
        
        List<Adm.TimelineConfig> timelineConfigList = new List<Adm.TimelineConfig>();
        
        try {
            // Retrieve timeline configuration information from timelineConfig manager.
            timelineConfigList = timelineConfigManager.getAllTimelineConfigurations();
            System.debug( LoggingLevel.INFO, 'getAllTimelineConfigurations() : Retrieved all timeline configuration information. timelineConfigList.size()= ' + timelineConfigList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTimelineConfigurations() : Failed to retrieve timeline configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllTimelineConfigurations() - exit; timelineConfigList.size()= ' + timelineConfigList.size() );
        }
        
        return timelineConfigList;
    }

    /**
     * This method retrieves all timeline profile assignments 
     * 
     */
	public List<Adm.TimelineProfileInfo> getAllAssignedProfileDetails() {
        System.debug( LoggingLevel.FINEST, 'getAllAssignedProfileDetails() - enter');
        
        List<Adm.TimelineProfileInfo> timelineAssignmentList = new List<Adm.TimelineProfileInfo>();
        
        try {
            // Retrieve timeline configuration information from timelineConfig manager.
            timelineAssignmentList = timelineConfigManager.getAllAssignedProfileDetails();
            System.debug( LoggingLevel.INFO, 'getAllAssignedProfileDetails() : Retrieved all timeline configuration information. timelineAssignmentList.size()= ' + timelineAssignmentList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllAssignedProfileDetails() : Failed to retrieve timeline configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllAssignedProfileDetails() - exit; timelineAssignmentList.size()= ' + timelineAssignmentList.size() );
        }
        
        return timelineAssignmentList;
    }

    /**
     * Method to delete hierarchy config record.
     */
    public void deleteHierarchyConfig( final String hierarchyConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - enter; hierarchyConfigId= ' + hierarchyConfigId );
        
        try {
            
            if( String.isBlank(hierarchyConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' hierarchyConfigId= ' + hierarchyConfigId );
            }

            hierarchyConfigManager.deleteHierarchyConfig(hierarchyConfigId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteHierarchyConfig() : Failed to hierarchy config record. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteHierarchyConfig() : Failed to delete hierarchy config record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteHierarchyConfig() - exit' );
        }
    }

    /**
     * Method to delete timeline config record.
     */
    public void deleteTimelineConfig( final String timelineConfigId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - enter; timelineConfigId= ' + timelineConfigId );
        
        try {
            
            if( String.isBlank(timelineConfigId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineConfigId= ' + timelineConfigId );
            }

            timelineConfigManager.deleteTimelineConfig(timelineConfigId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineConfig() : Failed to timeline config record. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineConfig() : Failed to delete timeline config record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineConfig() - exit' );
        }
    }

    /**
     * Method to delete timeline config record.
     */
    public void deleteTimelineDetail( final String timelineDetailId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - enter; timelineDetailId= ' + timelineDetailId );
        
        try {
            
            if( String.isBlank(timelineDetailId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' timelineDetailId= ' + timelineDetailId );
            }

            timelineConfigManager.deleteTimelineDetail(timelineDetailId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineDetail() : Failed to timeline detail record. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteTimelineDetail() : Failed to delete timeline detail record. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteTimelineDetail() - exit' );
        }
    }

    /**
     * This method retrieves the hierarchy configuration and populates 
     * information it to the hierarchy config wrapper.
     */
	public Adm.HierarchyConfig getHierarchyConfigurationWithDetails( final String hierarchyConfigId ) {
        System.debug( LoggingLevel.FINEST, 'getHierarchyConfigurationWithDetails() - enter');
        
        Adm.HierarchyConfig hierarchyConfig = new Adm.HierarchyConfig();
        
        try {
            // Retrieve hierarchy configuration information from hierarchyConfig manager.
            hierarchyConfig = hierarchyConfigManager.getHierarchyConfigurationWithDetails(hierarchyConfigId);
            System.debug( LoggingLevel.INFO, 'getHierarchyConfigurationWithDetails() : Retrieved the hierarchy configuration information. hierarchyConfig= ' + hierarchyConfig );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getHierarchyConfigurationWithDetails() : Failed to retrieve hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getHierarchyConfigurationWithDetails() - exit;');
        }
        
        return hierarchyConfig;
    }

     /**
     * This method retrieves the timeline configuration and populates 
     * information in it to the timline config wrapper.
     */
	public Adm.TimelineConfig getTimelineConfigurationWithDetails( final String timelineConfigId ) {
        System.debug( LoggingLevel.FINEST, 'getTimelineConfigurationWithDetails() - enter');
        
        Adm.TimelineConfig timelineConfig = new Adm.TimelineConfig();
        
        try {
            // Retrieve timeline configuration information from timelineConfigManager.
            timelineConfig = timelineConfigManager.getTimelineConfigurationWithDetails(timelineConfigId);
            System.debug( LoggingLevel.INFO, 'getTimelineConfigurationWithDetails() : Retrieved the timeline configuration information. timelineConfig= ' + timelineConfig );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTimelineConfigurationWithDetails() : Failed to retrieve timeline configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getTimelineConfigurationWithDetails() - exit;');
        }
        
        return timelineConfig;
    }

    /**
     * This method saves the hierarchy configuration for the information provided
     */
	public Adm.HierarchyConfig saveHierarchyConfiguration( final Adm.HierarchyConfig hierarchyConfig ) {
        System.debug( LoggingLevel.FINEST, 'saveHierarchyConfiguration() - enter');
        
        Adm.HierarchyConfig hierarchyConfigRec = new Adm.HierarchyConfig();
        
        try {
            // Saves hierarchy configuration information from hierarchyConfig manager.
            hierarchyConfigRec = hierarchyConfigManager.saveHierarchyConfiguration(hierarchyConfig);
            System.debug( LoggingLevel.INFO, 'saveHierarchyConfiguration() : Upserted the hierarchy configuration information. hierarchyConfig= ' + hierarchyConfig );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveHierarchyConfiguration() : Failed to save hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveHierarchyConfiguration() - exit;');
        }
        
        return hierarchyConfigRec;
    }
    
    /**
     * This method validate the hierarchy configuration for the information provided
     */
	public Adm.ValidationResult validateHierarchyConfiguration( final Adm.HierarchyValidationRequest request ) {
        
        System.debug( LoggingLevel.FINEST, 'validateHierarchyConfiguration() - enter');
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            // Validates hierarchy configuration information from hierarchyConfig manager.
            validationResult = hierarchyConfigManager.validateHierarchyConfiguration(request.hierarchyConfig, request.referenceDatas);
            System.debug( LoggingLevel.INFO, 'validateHierarchyConfiguration() : validate the hierarchy configuration information. hierarchyConfig= ' + request.hierarchyConfig );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateHierarchyConfiguration() : Failed to validate hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateHierarchyConfiguration() - exit;');
        }
        
        return validationResult;
    }
    
    /**
     * This method saves the timeline configuration for the information provided
     */
	public Adm.TimelineConfig saveTimelineConfiguration( final Adm.TimelineConfig timelineConfig ) {
        System.debug( LoggingLevel.FINEST, 'saveTimelineConfiguration() - enter');
        
        Adm.TimelineConfig timelineConfigRec = new Adm.TimelineConfig();
        
        try {
            // Saves timeline configuration information from timelineConfig manager.
            timelineConfigRec = timelineConfigManager.saveTimelineConfiguration(timelineConfig);
            System.debug( LoggingLevel.INFO, 'saveTimelineConfiguration() : Upserted the timeline configuration information. timelineConfig= ' + timelineConfig );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTimelineConfiguration() : Failed to save timeline configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveTimelineConfiguration() - exit;');
        }
        
        return timelineConfigRec;
    }
    
    /**
     * This method validate the timeline configuration for the information provided
     */
	public Adm.ValidationResult validateTimelineConfiguration( final Adm.TimelineValidationRequest request ) {
        System.debug( LoggingLevel.FINEST, 'validateTimelineConfiguration() - enter');
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            // Saves timeline configuration information from timelineConfig manager.
            validationResult = timelineConfigManager.validateTimelineConfiguration( request.timelineConfig, request.referenceDatas );
            System.debug( LoggingLevel.INFO, 'validateTimelineConfiguration() : Validated the timeline configuration information. timelineConfig= ' + request.timelineConfig );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTimelineConfiguration() : Failed to validate timeline configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateTimelineConfiguration() - exit;');
        }
        
        return validationResult;
    }

    /**
     * This method retrieves retrieve profile Ids and the associated configuration information 
     */
	public List<Adm.ProfileInfo> getAssignedProfileDetails( final String hierarchyConfigId ) {
        System.debug( LoggingLevel.FINEST, 'getAssignedProfileDetails() - enter');
        
        List<Adm.ProfileInfo> profileDetailsList = new List<Adm.ProfileInfo>();
        
        try {
            
            profileDetailsList = hierarchyConfigManager.getAssignedProfileDetails(hierarchyConfigId);
            System.debug( LoggingLevel.INFO, 'getAssignedProfileDetails() : Retrieved the profile hierarchy configuration information. profileDetailsList= ' + profileDetailsList );
        
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetails() : Failed to retrieve profile hierarchy configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAssignedProfileDetails() - exit;');
        }
        
        return profileDetailsList;
    }

    /**
     * This method retrieves retrieve profile Ids and the associated configuration information 
     */
	public List<Adm.TimelineProfileInfo> getAssignedProfileDetailsForTimeline( final String timelineConfigId ) {
        System.debug( LoggingLevel.FINEST, 'getAssignedProfileDetails() - enter');
        
        List<Adm.TimelineProfileInfo> profileDetailsList = new List<Adm.TimelineProfileInfo>();
        
        try {
            
            profileDetailsList = timelineConfigManager.getAssignedProfileDetailsForTimeline(timelineConfigId);
            System.debug( LoggingLevel.INFO, 'getAssignedProfileDetailsForTimeline() : Retrieved the profile timeline configuration information. profileDetailsList= ' + profileDetailsList );
        
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssignedProfileDetailsForTimeline() : Failed to retrieve profile timeline configuration. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAssignedProfileDetailsForTimeline() - exit;');
        }
        
        return profileDetailsList;
    }
    
}