@isTest
public with sharing class COMM_ApplicationUsageData_LS_UT {
    @TestSetup
    static void makeData(){
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
    }
    
    @isTest
    public static void testpublishUsageDataWithValidData(){
        String requestJSON = '{'+
            '"uniqueId":"69851c33-bb5a-05c8-7a11-56ef873b2437",'+
            '"actionDeveloperName":"SVMXA360__WORD_Create_Remote_Work_Order_From_Case",'+
            '"actionName":"Create Remote Work Order",'+
            '"epochStartTime":"1629438710863"'+
        '}';

        Test.startTest();
        Common.ServiceResponse serviceResponse = COMM_ApplicationUsageData_LS.publishUsageData( requestJSON );
        System.debug(serviceResponse);
        Test.stopTest();

        System.assertEquals(true, serviceResponse.success, 'Valid request json.');

        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assertEquals( 1, usageDataList.size(), 'One record inserted in usage data.' );
    }

    @isTest
    public static void testpublishUsageDataWithInvalidData(){
        String requestJSON = '{'+
            '"actionDeveloperName":"SVMXA360__WORD_Create_Remote_Work_Order_From_Case_WORD_Create_Remote_Work_Order_From_Case",'+
            '"actionName":"Create Remote Work Order",'+
            '"epochStartTime":"1629438710863"'+
        '}';

        Test.startTest();
        Common.ServiceResponse serviceResponse = COMM_ApplicationUsageData_LS.publishUsageData( requestJSON );
        System.debug(serviceResponse);
        Test.stopTest();

        System.assertEquals(true, serviceResponse.success, 'Invalid request json.');

        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assertEquals( 0, usageDataList.size(), 'One record inserted in usage data.' );
    }

    @isTest
    public static void testpublishUsageDataWithNullRequest(){

        Test.startTest();
        Common.ServiceResponse serviceResponse = COMM_ApplicationUsageData_LS.publishUsageData( null );
        System.debug(serviceResponse);
        Test.stopTest();

        System.assertEquals(false, serviceResponse.success, 'Null request.');

    }

    @isTest
    public static void testpublishUsageDataWithInvalidJSONRequest(){

        String requestJSON = 'dummyString';

        Test.startTest();
        Common.ServiceResponse serviceResponse = COMM_ApplicationUsageData_LS.publishUsageData( requestJSON );
        System.debug(serviceResponse);
        Test.stopTest();

        System.assertEquals(false, serviceResponse.success, 'Invalid request json.');
    }
}