@IsTest
public class ADM_TimelineConfig_LS_UT {
    
    @testSetup 
    public static void setup() {
        ADM_TimelineConfigManager_UT.setup();
    }
    
	testmethod static void testGetAllTimelineConfigurations() {
        
        Common.ServiceResponse serviceResponse = ADM_TimelineConfig_LS.getAllTimelineConfigurations();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetTimelineConfigurationWithDetails() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Common.ServiceResponse serviceResponse = ADM_TimelineConfig_LS.getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
	testmethod static void testGetAllAssignedProfileDetails() {
        
        Common.ServiceResponse serviceResponse = ADM_TimelineConfig_LS.getAllAssignedProfileDetails();
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }    
    
    testmethod static void testSaveTimelineConfiguration() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Adm.TimelineConfig timelineConfig = ADM_TimelineConfigManager.getInstance().getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( timelineConfig != null );
        
        Common.ServiceResponse serviceResponse = ADM_TimelineConfig_LS.saveTimelineConfiguration( JSON.serialize(timelineConfig) );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testSaveTimelineConfiguration_Invalid() {
        
        Common.ServiceResponse serviceResponse = ADM_TimelineConfig_LS.saveTimelineConfiguration( '{' );
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );
    }
    
    testmethod static void testDeleteTimelineConfig() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Adm.TimelineConfig timelineConfig = ADM_TimelineConfigManager.getInstance().getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( timelineConfig != null );
        
        timelineConfig.isDefault = false;
        
        ADM_TimelineConfig_LS.deleteTimelineDetail(timelineConfig.timelineConfigDetailList.get(0).id);
        
        ADM_TimelineConfig_LS.deleteTimelineConfig(timelineConfig.id);
    }
}