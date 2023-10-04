@isTest
public with sharing class COMM_ApplicationUsageDataService_UT {
    
    @TestSetup
    static void makeData(){
        // SvmxTestDataFactory.applyPermissionSetToCurrentUser('Asset360_Core');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
    }
    
    @isTest
    public static void testPublishUsageDataEmptyList(){
        Test.startTest();
        Common.ServiceResponse serviceResponse = new COMM_ApplicationUsageDataService().publishUsageData(new List<Common.UsageData>());
        Test.stopTest();
        System.assertEquals(false, serviceResponse.success, 'Empty list failed.');
    }

    @isTest
    public static void testPublishUsageDataNullObject(){

        Test.startTest();
        Common.ServiceResponse serviceResponse = new COMM_ApplicationUsageDataService().publishUsageData( null );
        Test.stopTest();
        System.assertEquals(false, serviceResponse.success, 'Null value passed on list. ');
    }

    @isTest
    public static void testPublishUsageDataValidList(){
        
        List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
        Common.UsageData incomingUsageDataItem = new Common.UsageData();
        incomingUsageDataItem.uniqueId = '69851c33-bb5a-05c8-7a11-56ef873b2437';
        incomingUsageDataList.add(incomingUsageDataItem);
        Test.startTest();
        Common.ServiceResponse serviceResponse = new COMM_ApplicationUsageDataService().publishUsageData( incomingUsageDataList );
        Test.stopTest();

        System.assertEquals(true, serviceResponse.success, 'Valid list value');

        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assertEquals( 1, usageDataList.size(), 'One record inserted in usage data.' );
    }
}