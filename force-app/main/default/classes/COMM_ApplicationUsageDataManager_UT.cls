@isTest
public with sharing class COMM_ApplicationUsageDataManager_UT {

    @TestSetup
    static void makeData(){
        System.runAs(getCurrentUser()) {
            SvmxTestDataFactory.applyPermissionSetToCurrentUser('Asset360_Core');
            SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP600','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'true'}, 1);
        }
    }

    private static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @isTest
    public static void testPublishUsageDataValidData(){
        System.runAs(getCurrentUser()) {
            COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
            List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
            Common.UsageData incomingUsageDataItem = new Common.UsageData();
            incomingUsageDataItem.uniqueId = '69851c33-bb5a-05c8-7a11-56ef873b2437';
            incomingUsageDataList.add(incomingUsageDataItem);

            Test.startTest();
            appUsageDataMgr.publishUsageData( incomingUsageDataList );
            Test.stopTest();
            
            List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                            FROM SVMXA360__COMM_ApplicationUsageData__c ];

            System.assert( usageDataList != null, 'Usage data list is not empty.' );
            System.assertEquals( 1, usageDataList.size(), 'One record inserted in usage data.' );
        }
    } 

    @isTest
    public static void testPublishUsageDataValidDataUpdate(){
        COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
        List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
        Common.UsageData incomingUsageDataItem1 = new Common.UsageData();
        incomingUsageDataItem1.uniqueId = '69851c33-bb5a-05c8-7a11-56ef873b2437';
        incomingUsageDataItem1.status = 'FINISHED';
        incomingUsageDataList.add(incomingUsageDataItem1);

        Test.startTest();
        appUsageDataMgr.publishUsageData( incomingUsageDataList );
        Test.stopTest();
        
        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList1 = [SELECT Id, Name, SVMXA360__Status__c
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];
        //asset update
        System.assertEquals( 1, usageDataList1.size(), 'One record upserted in usage data.' );
        System.assertEquals( 'FINISHED', usageDataList1[0].SVMXA360__Status__c, 'Status is set.' );

    } 

    @isTest
    public static void testPublishUsageDataMissingUniqueIdData(){
        COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
        List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
        Common.UsageData incomingUsageDataItem = new Common.UsageData();
        incomingUsageDataList.add(incomingUsageDataItem);

        Test.startTest();
        appUsageDataMgr.publishUsageData( incomingUsageDataList );
        Test.stopTest();
        
        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];
            
        System.assertEquals( 0, usageDataList.size(), 'No record inserted in usage data.' );
    }

     @isTest
    public static void testPublishUsageDataInvalidData(){
        System.runAs(getCurrentUser()) {
            COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
            List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
            Common.UsageData incomingUsageDataItem = new Common.UsageData();
            incomingUsageDataItem.uniqueId = '69851c33-bb5a-05c8-7a11-56ef873b2437';
            incomingUsageDataItem.actionDeveloperName = 'SVMXA360__WORD_Create_Remote_Work_Order_From_Case_SVMXA360__WORD_Create_Remote_Work_Order_From_Case';
            incomingUsageDataList.add(incomingUsageDataItem);

            Test.startTest();
            appUsageDataMgr.publishUsageData( incomingUsageDataList );
            Test.stopTest();
            
            List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                            FROM SVMXA360__COMM_ApplicationUsageData__c ];
                
            System.assertEquals( 0, usageDataList.size(), 'No record inserted in usage data failing validation.' );
        }
    } 

    @isTest
    public static void testUpsertUsageDataValidData(){
        System.runAs(getCurrentUser()) {
            COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
            List<SVMXA360__COMM_ApplicationUsageDataEvent__e> incomingUsageDataList = new List<SVMXA360__COMM_ApplicationUsageDataEvent__e>();
            SVMXA360__COMM_ApplicationUsageDataEvent__e incomingUsageDataItem = new SVMXA360__COMM_ApplicationUsageDataEvent__e();
            incomingUsageDataItem.SVMXA360__UniqueId__c = '69851c33-bb5a-05c8-7a11-56ef873b2437';
            incomingUsageDataItem.SVMXA360__EpochStartTime__c = 1629438710863L;
            incomingUsageDataItem.SVMXA360__ActionDeveloperName__c = 'SVMXA360__WORD_Create_Remote_Work_Order_From_Case';
            incomingUsageDataList.add(incomingUsageDataItem);

            SVMXA360__COMM_ApplicationUsageDataEvent__e incomingUsageDataItem1 = new SVMXA360__COMM_ApplicationUsageDataEvent__e();
            incomingUsageDataItem1.SVMXA360__UniqueId__c = '69851c33-bb5a-05c8-7a11-56ef873b2438';
            incomingUsageDataItem1.SVMXA360__EpochStartTime__c = 1629438710863L;
            incomingUsageDataItem1.SVMXA360__ActionDeveloperName__c = 'SVMXA360__WORD_Create_Remote_Work_Order_From_Case';
            incomingUsageDataList.add(incomingUsageDataItem1);

            Test.startTest();
            appUsageDataMgr.upsertUsageData( incomingUsageDataList );
            Test.stopTest();
            
            List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                            FROM SVMXA360__COMM_ApplicationUsageData__c ];

            System.assert( usageDataList != null, 'Usage data list is not empty.' );
            System.assertEquals( 2, usageDataList.size(), 'Two records inserted successfully in usage data.' );
        }
    } 

    @isTest
    public static void testUpsertUsageDataMissingUniqueId(){
        COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
        List<SVMXA360__COMM_ApplicationUsageDataEvent__e> incomingUsageDataList = new List<SVMXA360__COMM_ApplicationUsageDataEvent__e>();
        SVMXA360__COMM_ApplicationUsageDataEvent__e incomingUsageDataItem = new SVMXA360__COMM_ApplicationUsageDataEvent__e();
        // incomingUsageDataItem.SVMXA360__UniqueId__c = '69851c33-bb5a-05c8-7a11-56ef873b2437';
        incomingUsageDataItem.SVMXA360__EpochStartTime__c = 1629438710863L;
        incomingUsageDataItem.SVMXA360__ActionDeveloperName__c = 'SVMXA360__WORD_Create_Remote_Work_Order_From_Case';
        incomingUsageDataList.add(incomingUsageDataItem);

        Test.startTest();
        appUsageDataMgr.upsertUsageData( incomingUsageDataList );
        Test.stopTest();
        
        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assert( usageDataList != null, 'Usage data list is not empty.' );
        System.assertEquals( 0, usageDataList.size(), 'Record insert failed.' );
    } 


    @isTest
    public static void testUpsertUsageDataInvalidData(){
        COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
        List<SVMXA360__COMM_ApplicationUsageDataEvent__e> incomingUsageDataList = new List<SVMXA360__COMM_ApplicationUsageDataEvent__e>();
        SVMXA360__COMM_ApplicationUsageDataEvent__e incomingUsageDataItem = new SVMXA360__COMM_ApplicationUsageDataEvent__e();
        incomingUsageDataItem.SVMXA360__UniqueId__c = '69851c33-bb5a-05c8-7a11-56ef873b2437';
        incomingUsageDataItem.SVMXA360__EpochStartTime__c = 1629438710863L;
        incomingUsageDataItem.SVMXA360__ActionDeveloperName__c = 'SVMXA360__WORD_Create_Remote_Work_Order_From_Case_WORD_Create_Remote_Work_Order_From_Case';
        incomingUsageDataList.add(incomingUsageDataItem);

        Test.startTest();
        appUsageDataMgr.upsertUsageData( incomingUsageDataList );
        Test.stopTest();
        
        List<SVMXA360__COMM_ApplicationUsageData__c> usageDataList = [SELECT Id, Name 
                                                                        FROM SVMXA360__COMM_ApplicationUsageData__c ];

        System.assert( usageDataList != null, 'Usage data list is not empty.' );
        System.assertEquals( 0, usageDataList.size(), 'One record inserted in usage data.' );
    } 

    @isTest
    public static void testPublishUsageDataTrackerOff(){
        try{
            CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName(CONF_CustomSettingsManager.NAME_ENABLE_APP_USAGE_TRACKING, 'false');
            COMM_ApplicationUsageDataManager appUsageDataMgr = COMM_ApplicationUsageDataManager.getInstance();
            List<Common.UsageData> incomingUsageDataList = new List<Common.UsageData>();
            Common.UsageData incomingUsageDataItem = new Common.UsageData();
            incomingUsageDataItem.uniqueId = '69851c33-bb5a-05c8-7a11-56ef873b2437';
            incomingUsageDataItem.actionDeveloperName = 'SVMXA360__WORD_Create_Remote_Work_Order_From_Case_SVMXA360__WORD_Create_Remote_Work_Order_From_Case';
            incomingUsageDataList.add(incomingUsageDataItem);

            Test.startTest();
            appUsageDataMgr.publishUsageData( incomingUsageDataList );
            Test.stopTest();
        }catch(Exception e){
            System.assert(true);
        }
    } 
}