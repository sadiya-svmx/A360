@isTest
public with sharing class ApplicationUsageService_UT {
    @TestSetup
    static void makeData(){
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1); 
    }
    @isTest
    public static void testSetApplicationUsageTracker(){
        SvmxGlobal.SvmxResponse response = ApplicationUsageService.setApplicationUsageTracker(false);
        System.assertEquals(response.success, true, 'Status is success.');

        Common.ServiceResponse getResponse = new CONF_CustomSettingsService().getApplicationUsageTracker();
        Common.GlobalProperty globProp = (Common.GlobalProperty) getResponse.data;
        System.assertEquals(globProp.value, 'false', 'Value is verified set to false.');
    }
}