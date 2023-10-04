@isTest
public with sharing class ADM_ProcessWizardComponent_LS_UT {

    @TestSetup
    static void makeData(){
        // SvmxTestDataFactory.applyPermissionSetToCurrentUser('Asset360_Core');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
    }

    private static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    @isTest
    public static void testPublishUsageDataValidRequest(){
        System.runAs(getCurrentUser()) {
            String requestJSON = '{'+
                '"uniqueId":"69851c33-bb5a-05c8-7a11-56ef873b2437",'+
                '"actionDeveloperName":"SVMXA360__WORD_Create_Remote_Work_Order_From_Case",'+
                '"actionName":"Create Remote Work Order",'+
                '"epochStartTime":"1629438710863"'+
            '}';

                Test.startTest();
                Common.ServiceResponse serviceResponse = ADM_ProcessWizardComponent_LS.publishUsageData( requestJSON );
                Test.stopTest();

                System.assert( serviceResponse.success, 'Service Response should be success.' );
                
                List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                                FROM SVMXA360__COMM_ApplicationUsageData__c ];
                    
                System.debug('usageDataList' + usageDataList);
                System.assert( usageDataList != null, 'Usage data list is not empty.' );
                System.assertEquals( 1, usageDataList.size(), 'One record inserted in usage data.' );
        }
    }

    @isTest
    public static void testpublishUsageDataWithInvalidData(){
        String requestJSON = '{'+
            '"actionDeveloperName":"SVMXA360__WORD_Create_Remote_Work_Order_From_Case_WORD_Create_Remote_Work_Order_From_Case",'+
            '"actionName":"Create Remote Work Order",'+
            '"epochStartTime":"1629438710863"'+
        '}';

        Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardComponent_LS.publishUsageData( requestJSON );
        System.debug(serviceResponse);
        Test.stopTest();

        System.assertEquals(true, serviceResponse.success, 'Invalid request voilates field validation.');

        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assertEquals( 0, usageDataList.size(), 'One record inserted in usage data.' );
    }

    @isTest
    public static void testpublishUsageDataWithNullRequest(){

        Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardComponent_LS.publishUsageData( null );
        Test.stopTest();

        System.assertEquals(false, serviceResponse.success, 'Null request.');

    }

    @isTest
    public static void testpublishUsageDataWithInvalidJSONRequest(){

        String requestJSON = 'dummyString';

        Test.startTest();
        Common.ServiceResponse serviceResponse = ADM_ProcessWizardComponent_LS.publishUsageData( requestJSON );
        System.debug(serviceResponse);
        Test.stopTest();

        System.assertEquals(false, serviceResponse.success, 'Invalid request json.');
    }

    @isTest
   static void testGetApplicationUsageTracker(){
        Test.startTest();
        Common.ServiceResponse response = ADM_ProcessWizardComponent_LS.getApplicationUsageTracker();
        Common.GlobalProperty globProp = (Common.GlobalProperty) response.data;
        System.assertEquals(globProp.value, 'true', 'Value is verified set to true.');
        Test.stopTest();
   }
}