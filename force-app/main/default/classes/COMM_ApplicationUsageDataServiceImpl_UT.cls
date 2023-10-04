@isTest
public with sharing class COMM_ApplicationUsageDataServiceImpl_UT {
    
    @TestSetup
    static void makeData(){
        // SvmxTestDataFactory.applyPermissionSetToCurrentUser('Asset360_Core');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
    }
    
    @isTest
    public static void testPublishUsageDataEmptyList(){
        try {
            Test.startTest();
            new COMM_ApplicationUsageDataServiceImpl().publishUsageData(new List<Common.UsageData>());
            Test.stopTest();
            System.Assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
    }

    @isTest
    public static void testPublishUsageDataNullObject(){
        try {
            Test.startTest();
            new COMM_ApplicationUsageDataServiceImpl().publishUsageData( null );
            Test.stopTest();
            System.Assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
    }

    @isTest
    public static void testPublishUsageDataValidList(){
        
        List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
        Common.UsageData incomingUsageDataItem = new Common.UsageData();
        incomingUsageDataItem.uniqueId = '69851c33-bb5a-05c8-7a11-56ef873b2437';
        incomingUsageDataList.add(incomingUsageDataItem);
        Test.startTest();
        new COMM_ApplicationUsageDataServiceImpl().publishUsageData( incomingUsageDataList );
        Test.stopTest();

        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assertEquals( 1, usageDataList.size(), 'One record inserted in usage data.' );
    }
}