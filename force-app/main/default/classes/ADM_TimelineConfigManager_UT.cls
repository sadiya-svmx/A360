@IsTest
public class ADM_TimelineConfigManager_UT {
    
    @testSetup 
    public static void setup() {
        
        final List<SVMXA360__CONF_TimelineConfig__c> timelineConfigList = (List<SVMXA360__CONF_TimelineConfig__c>) SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_TimelineConfig__c', 5);
        
        final List<SVMXA360__CONF_TimelineConfigDetail__c> timelineConfigDetailList = new List<SVMXA360__CONF_TimelineConfigDetail__c>();
        final List<SVMXA360__CONF_TimelineConfigAccess__c> timelineConfigAccessList = new List<SVMXA360__CONF_TimelineConfigAccess__c>();
        
        for( SVMXA360__CONF_TimelineConfig__c timelineConfigRecord : timelineConfigList ) {
            
            final List<SVMXA360__CONF_TimelineConfigDetail__c> detailList = (List<SVMXA360__CONF_TimelineConfigDetail__c>) SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_TimelineConfigDetail__c', new Map<String,Object> {'SVMXA360__TimelineConfigId__c'=>timelineConfigRecord.id}, 5);
            timelineConfigDetailList.addAll(detailList);
            
            final List<SVMXA360__CONF_TimelineConfigAccess__c> accessList = (List<SVMXA360__CONF_TimelineConfigAccess__c>) SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_TimelineConfigAccess__c', 
                                                                                                                                                                 new Map<String,Object> {'SVMXA360__TimelineConfigId__c'=>timelineConfigRecord.id, 
                                                                                                                                                                     'SVMXA360__ProfileId__c'=>UserInfo.getProfileId()}, 1);
            timelineConfigAccessList.addAll(accessList);
        }
        
        insert timelineConfigDetailList;
        insert timelineConfigAccessList;
    }
    
	testmethod static void testGetAllTimelineConfigurations() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
    }
    
    testmethod static void testGetTimelineConfigurationWithDetails() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Adm.TimelineConfig timelineConfig = ADM_TimelineConfigManager.getInstance().getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( timelineConfig != null );
    }
    
    testmethod static void testGetAssignedProfileDetailsForTimeline() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        List<Adm.TimelineProfileInfo> timelineProfileInfoList = ADM_TimelineConfigManager.getInstance().getAssignedProfileDetailsForTimeline(timelineConfigList.get(0).id);
        
        System.assert( timelineProfileInfoList != null );
        System.assert( timelineProfileInfoList.size() == 1 );
    }

	testmethod static void testGetAllAssignedProfileDetails() {
        
        List<Adm.TimelineProfileInfo> timelineProfileInfoList = ADM_TimelineConfigManager.getInstance().getAllAssignedProfileDetails();
        
        System.assert( timelineProfileInfoList != null );
        System.assert( timelineProfileInfoList.size() == 1 );
    }    
    
    testmethod static void testSaveTimelineConfiguration() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Adm.TimelineConfig timelineConfig = ADM_TimelineConfigManager.getInstance().getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( timelineConfig != null );
        
        timelineConfig = ADM_TimelineConfigManager.getInstance().saveTimelineConfiguration(timelineConfig);
        System.assert( timelineConfig != null );
    }
    
    testmethod static void testDeleteTimelineConfig() {
        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Adm.TimelineConfig timelineConfig = ADM_TimelineConfigManager.getInstance().getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( timelineConfig != null );
        
        timelineConfig.isDefault = false;
        
        timelineConfig = ADM_TimelineConfigManager.getInstance().saveTimelineConfiguration(timelineConfig);
        System.assert( timelineConfig != null );
        
        ADM_TimelineConfigManager.getInstance().deleteTimelineConfig(timelineConfig.id);
    }
    
    testmethod static void testValidateTimelineConfig() {

		List<Adm.ReferenceData> referenceDatas  = new List<Adm.ReferenceData>();        
        List<Adm.TimelineConfig> timelineConfigList = ADM_TimelineConfigManager.getInstance().getAllTimelineConfigurations();
        
        System.assert( timelineConfigList != null );
        System.assert( timelineConfigList.size() == 5 );
        
        Adm.TimelineConfig timelineConfig = ADM_TimelineConfigManager.getInstance().getTimelineConfigurationWithDetails(timelineConfigList.get(0).id);
        
        System.assert( timelineConfig != null );
        Adm.ValidationResult result = ADM_TimelineConfigManager.getInstance().validateTimelineConfiguration(timelineConfig, referenceDatas );
        System.assert(result != null);
    }
}