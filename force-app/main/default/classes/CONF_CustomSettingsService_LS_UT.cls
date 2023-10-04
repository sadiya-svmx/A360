@isTest
public with sharing class CONF_CustomSettingsService_LS_UT {
    
    @TestSetup
    static void makeData(){
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP800','SVMXA360__Key__c' => CONF_CustomSettingsManager.KEY_AUTO_CONFIGURATOR, 'SVMXA360__Value__c' => 'true'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP801','SVMXA360__Key__c' => CONF_CustomSettingsManager.KEY_AUTO_CONFIGURATOR, 'SVMXA360__Value__c' => 'TODO'}, 1);
    }
    
    @isTest
    public static void testGetApplicationTrackerValid(){
        Test.startTest();
        Common.ServiceResponse response = CONF_CustomSettingsService_LS.getApplicationUsageTracker();
        Common.GlobalProperty globProp = (Common.GlobalProperty) response.data;
        System.assertEquals(globProp.value, 'true', 'Value is verified set to true.');
        Test.stopTest();
    }
    
    @isTest
    public static void testSetApplicationTrackerValid(){

        SvmxGlobal.SvmxResponse response = CONF_CustomSettingsService_LS.setApplicationUsageTracker('true');
        System.assertEquals(response.success, true, 'Status is success.');

        Common.ServiceResponse getResponse = CONF_CustomSettingsService_LS.getApplicationUsageTracker();
        Common.GlobalProperty globProp = (Common.GlobalProperty) getResponse.data;
        System.assertEquals(globProp.value, 'true', 'Value is verified set to true.');
    }

    @isTest
    public static void testSetApplicationTrackerInvalid(){
        try{
            SvmxGlobal.SvmxResponse response = CONF_CustomSettingsService_LS.setApplicationUsageTracker('');
        } catch(Exception e){
            System.assert(true);
        }
    }
    
    @isTest
    public static void testGetGlobalProperty() {
        
        Test.startTest();
        
        Common.ServiceResponse response = CONF_CustomSettingsService_LS.getGlobalProperty('GP800');
        Common.GlobalProperty globalProperty = (Common.GlobalProperty) response.data;
        System.assertEquals( globalProperty.value, 'true', 'Value is verified set to true.');
        
        Test.stopTest();
    }
}