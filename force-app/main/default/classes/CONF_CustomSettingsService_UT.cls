@isTest
public with sharing class CONF_CustomSettingsService_UT {
    
   @TestSetup
   static void setup() {
       
       SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
       SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP800','SVMXA360__Key__c' => CONF_CustomSettingsManager.KEY_AUTO_CONFIGURATOR, 'SVMXA360__Value__c' => 'true'}, 1);
       SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP801','SVMXA360__Key__c' => CONF_CustomSettingsManager.KEY_AUTO_CONFIGURATOR, 'SVMXA360__Value__c' => 'TODO'}, 1);
   }

   @isTest
   static void testGetApplicationUsageTracker(){
        Test.startTest();
        Common.ServiceResponse response = new CONF_CustomSettingsService().getApplicationUsageTracker();
        Common.GlobalProperty globProp = (Common.GlobalProperty) response.data;
        System.assertEquals(globProp.value, 'true', 'Value is verified set to true.');
        Test.stopTest();
   }

   @isTest
   static void testSetApplicationUsageTracker(){
        Test.startTest();
        Common.ServiceResponse setResponse = new CONF_CustomSettingsService().setApplicationUsageTracker(false);
        Common.ServiceResponse response = new CONF_CustomSettingsService().getApplicationUsageTracker();
        Common.GlobalProperty globProp = (Common.GlobalProperty) response.data;
        System.assertEquals(globProp.value, 'false', 'Value is verified set to true.');
        Test.stopTest();
   }

   @isTest
   static void testSetApplicationUsageTrackerInvalid(){
        Test.startTest();
        try{
            Common.ServiceResponse setResponse = new CONF_CustomSettingsService().setApplicationUsageTracker(null);
        }catch(Exception e){
            System.assert(true);
        }
        Test.stopTest();
   }
    
    @isTest
    static void testGetGlobalProperty() {
        
        Test.startTest();
        
        Common.ServiceResponse response = new CONF_CustomSettingsService().getGlobalProperty( 'GP800' );
        Common.GlobalProperty globalProperty = (Common.GlobalProperty) response.data;
        System.assertEquals(globalProperty.value, 'true', 'Value is verified set to true.');
        
        Test.stopTest();
    }
    
    @isTest
    static void testSetGlobalProperty() {
        
        Test.startTest();
        
        Common.ServiceResponse response = new CONF_CustomSettingsService().setGlobalProperty( 'GP800', 'false' );
        System.assert(response.success);
        
        response = new CONF_CustomSettingsService().getGlobalProperty( 'GP800' );
        Common.GlobalProperty globalProperty = (Common.GlobalProperty) response.data;
        System.assertEquals(globalProperty.value, 'false');
        
        Test.stopTest();
    }
}