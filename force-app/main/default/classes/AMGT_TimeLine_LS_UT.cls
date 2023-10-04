@isTest
public class AMGT_TimeLine_LS_UT {
    @testSetup public static void setup() {
        SvmxTestDataFactory.insertDefaultAllowedCoreObjects();

        // Insert Test Records.
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        Contact cont = (Contact)SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        Asset newAsset = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Test Asset 1', 
            'Product2Id' => product.Id, 
            'AccountId'=>acc.Id, 
            'ContactId'=>cont.Id,
            'AverageUptimePerDay' => 12,
            'InstallDate'=>Date.today(), 
            'PurchaseDate'=>Date.today()});

        SvmxTestDataFactory.insertSObject('Case', new Map<String,Object>{'AssetId'=> newAsset.Id});

        WorkOrder wo = new WorkOrder();

        wo.AssetId = newAsset.Id;
        insert wo;

        // Insert Test Configuration Records.
        SVMXA360__CONF_TimelineConfig__c timelineConfig
            = (SVMXA360__CONF_TimelineConfig__c)SvmxTestDataFactory.insertSObject(
                'SVMXA360__CONF_TimelineConfig__c', 
                new Map<String,Object>{
                    'Name' => 'Test',
                    'SVMXA360__DeveloperName__c' => 'Test_Configuration',
                    'SVMXA360__IsDefault__c' => false
                }
            );

        SvmxTestDataFactory.insertSObject( 
            'SVMXA360__CONF_TimelineConfigDetail__c',
            new Map<String,Object> {
                'SVMXA360__TimelineConfigId__c' => timelineConfig.Id, 
                'SVMXA360__ObjectAPIName__c' => 'Case',
                'SVMXA360__SourceFieldAPIName__c' => 'AssetId',
                'SVMXA360__DisplayFieldAPIName__c' => 'Subject',
                'SVMXA360__StartDateFieldAPIName__c' => 'CreatedDate',
                'SVMXA360__EndDateFieldAPIName__c' => null,
                'SVMXA360__Sequence__c' => 1,
                'SVMXA360__QualifyingCriteria__c' => null
            });
        SvmxTestDataFactory.insertSObject( 
            'SVMXA360__CONF_TimelineConfigDetail__c',
            new Map<String,Object> {
                'SVMXA360__TimelineConfigId__c' => timelineConfig.Id, 
                'SVMXA360__ObjectAPIName__c' => 'Asset',
                'SVMXA360__SourceFieldAPIName__c' => 'Id',
                'SVMXA360__DisplayFieldAPIName__c' => 'Name',                
                'SVMXA360__StartDateFieldAPIName__c' => 'InstallDate',
                'SVMXA360__EndDateFieldAPIName__c' => 'PurchaseDate',
                'SVMXA360__Sequence__c' => 1,
                'SVMXA360__QualifyingCriteria__c' => null
            });

        SvmxTestDataFactory.insertSObject(
            'SVMXA360__CONF_TimelineConfigAccess__c',
            new Map<String,Object> {
                'SVMXA360__TimelineConfigId__c' => timelineConfig.Id, 
                'SVMXA360__ProfileId__c' => UserInfo.getProfileId()
            });
    }

    private static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @isTest static void testGetTimelineData_UsingInvalidRequestJson() { 
        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( '{"}' );
        System.assertEquals( false, resp.success, 'Success should be false.' );
    }

    @isTest static void testGetTimelineData_UsingNullParam() { 
        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( null );
        System.assertEquals( false, resp.success, 'Success should be false.' );
    }

    @isTest static void testGetTimelineData_UsingInvalidParam_NoValuesSetOnRequest() { 
        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( false, resp.success, 'Success should be false.' );
    }

    @isTest static void testGetTimelineData_UsingInvalidRequestProperties() { 
        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        // Invalid Parent Record Id.
        request.parentRecordId = '';
        request.fieldApiName = 'Test';
        request.startDate = Date.today();
        request.endDate = Date.today();

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( false, resp.success, 'Success should be false for invalid Parent Record Id.' );

        // Invalid fieldApiname
        request.fieldApiName = '';

        resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( false, resp.success, 'Success should be false for invalid fieldApiName.' );

        // Invalid startDate
        request.startDate = null;

        resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( false, resp.success, 'Success should be false for empty start date.' );

        // Invalid endDate
        request.endDate = null;

        resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( false, resp.success, 'Success should be false for empty end date.' );
    }

    @isTest static void testGetTimelineData() { 
        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];

        request.parentRecordId = wo.Id;
        request.fieldApiName = 'AssetId';
        request.startDate = Date.today().addDays(-30);
        request.endDate = Date.today().addDays(30);

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( true, resp.success, 'Success should be true.' );

        Amgt.TimelineResponse timelineResp = (Amgt.TimelineResponse)resp.data;

        System.assertNotEquals(null, timelineResp, 'Service Response data should not be null.' );
        System.assertNotEquals(null, timelineResp.id, 'Response id should not be null.' );
        System.assertEquals(2, timelineResp.timelineResults.size(), 'Response should have 2 item.' );
    }
    
    @isTest static void testGetTimelineData2() { 
        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];

        request.parentRecordId = wo.Id;
        request.fieldApiName = 'AssetId';
        request.startDate = Date.today().addDays(-30);
        request.endDate = Date.today().addDays(30);
        request.objectApiNameList = new List<String> {'Case','Asset'};
        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( true, resp.success, 'Success should be true.' );

        Amgt.TimelineResponse timelineResp = (Amgt.TimelineResponse)resp.data;

        System.assertNotEquals(null, timelineResp, 'Service Response data should not be null.' );
        System.assertNotEquals(null, timelineResp.id, 'Response id should not be null.' );
        System.assertEquals(2, timelineResp.timelineResults.size(), 'Response should have 2 item.' );
    }

    @isTest static void testGetTimelineData_UsingDefaultConfiguration() { 
        // Remove access records from Test Setup
        List<SVMXA360__CONF_TimelineConfigAccess__c> accessRecords = [SELECT ID FROM SVMXA360__CONF_TimelineConfigAccess__c];
        delete accessRecords;

        // Update config to set is as the default configuration.
        SVMXA360__CONF_TimelineConfig__c config = [SELECT ID, SVMXA360__IsDefault__c FROM SVMXA360__CONF_TimelineConfig__c LIMIT 1];
        config.SVMXA360__IsDefault__c = true;
        update config;

        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];

        request.parentRecordId = wo.Id;
        request.fieldApiName = 'AssetId';
        request.startDate = Date.today().addDays(-30);
        request.endDate = Date.today().addDays(30);

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( true, resp.success, 'Success should be true but had message:' + resp.message);

        Amgt.TimelineResponse timelineResp = (Amgt.TimelineResponse)resp.data;

        System.assertNotEquals(null, timelineResp, 'Service Response data should not be null.' );
        System.assertNotEquals(null, timelineResp.id, 'Response id should not be null.' );
        System.assertEquals(2, timelineResp.timelineResults.size(), 'Response should have 2 item.');
    }

    @isTest static void testGetTimelineData_UsingDefaultConfiguration2() { 
        // Remove access records from Test Setup
        List<SVMXA360__CONF_TimelineConfigAccess__c> accessRecords = [SELECT ID FROM SVMXA360__CONF_TimelineConfigAccess__c];
        delete accessRecords;

        // Update config to set is as the default configuration.
        SVMXA360__CONF_TimelineConfig__c config = [SELECT ID, SVMXA360__IsDefault__c FROM SVMXA360__CONF_TimelineConfig__c LIMIT 1];
        config.SVMXA360__IsDefault__c = true;
        update config;

        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];

        request.parentRecordId = wo.Id;
        request.fieldApiName = 'AssetId';
        request.startDate = Date.today().addDays(-30);
        request.endDate = Date.today().addDays(30);
        request.objectApiNameList = new List<String> {'Case','Asset'};

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( true, resp.success, 'Success should be true but had message:' + resp.message);

        Amgt.TimelineResponse timelineResp = (Amgt.TimelineResponse)resp.data;

        System.assertNotEquals(null, timelineResp, 'Service Response data should not be null.' );
        System.assertNotEquals(null, timelineResp.id, 'Response id should not be null.' );
        System.assertEquals(2, timelineResp.timelineResults.size(), 'Response should have 2 item.');
    }

    @isTest static void testGetTimelineData_UsingFallbackConfiguration() { 
        // Re-assign existing test data to use a different profile than the executing user.
        Profile notSystemAdminProfile = [SELECT Id, Name FROM Profile WHERE ID != :UserInfo.getProfileId()  LIMIT 1];

        List<SVMXA360__CONF_TimelineConfigAccess__c> accessRecords = [SELECT ID, SVMXA360__ProfileId__c FROM SVMXA360__CONF_TimelineConfigAccess__c];

        for (SVMXA360__CONF_TimelineConfigAccess__c accessRec : accessRecords) {
            accessRec.SVMXA360__ProfileId__c = notSystemAdminProfile.Id;
        }
        update accessRecords;

        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];

        request.parentRecordId = wo.Id;
        request.fieldApiName = 'AssetId';
        request.startDate = Date.today().addDays(-30);
        request.endDate = Date.today().addDays(30);

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( true, resp.success, 'Success should be true but had message:' + resp.message);

        Amgt.TimelineResponse timelineResp = (Amgt.TimelineResponse)resp.data;

        System.assertNotEquals(null, timelineResp, 'Service Response data should not be null.' );
        System.assertNotEquals(null, timelineResp.id, 'Response id should not be null.' );
        System.assertEquals(2, timelineResp.timelineResults.size(), 'Response should have 2 items.');
    }
    
    @isTest static void testGetTimelineData_UsingFallbackConfiguration2() { 
        // Re-assign existing test data to use a different profile than the executing user.
        Profile notSystemAdminProfile = [SELECT Id, Name FROM Profile WHERE ID != :UserInfo.getProfileId()  LIMIT 1];

        List<SVMXA360__CONF_TimelineConfigAccess__c> accessRecords = [SELECT ID, SVMXA360__ProfileId__c FROM SVMXA360__CONF_TimelineConfigAccess__c];

        for (SVMXA360__CONF_TimelineConfigAccess__c accessRec : accessRecords) {
            accessRec.SVMXA360__ProfileId__c = notSystemAdminProfile.Id;
        }
        update accessRecords;

        Amgt.TimelineRequest request = new Amgt.TimelineRequest();

        WorkOrder wo = [SELECT ID FROM WorkOrder LIMIT 1];

        request.parentRecordId = wo.Id;
        request.fieldApiName = 'AssetId';
        request.startDate = Date.today().addDays(-30);
        request.endDate = Date.today().addDays(30);
        request.objectApiNameList = new List<String> {'Case', 'WorkOrder','Asset'};

        Common.ServiceResponse resp = AMGT_TimeLine_LS.getTimelineData( JSON.serialize(request) );
        System.assertEquals( true, resp.success, 'Success should be true but had message:' + resp.message);

        Amgt.TimelineResponse timelineResp = (Amgt.TimelineResponse)resp.data;

        System.assertNotEquals(null, timelineResp, 'Service Response data should not be null.' );
        System.assertNotEquals(null, timelineResp.id, 'Response id should not be null.' );
        System.assertEquals(2, timelineResp.timelineResults.size(), 'Response should have 2 items.');
    }
    
    @istest static void testgetTimelineCategories() {
        List<Amgt.TimelineCategory> resp = AMGT_TimeLine_LS.getTimelineCategories('none');
        System.assert(resp.size() ==3);
    }
}