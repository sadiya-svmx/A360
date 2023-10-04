@IsTest
public class PSC_ManageResults_LS_UT {

    @IsTest
    static void testGetResultLineStatusWithNull(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_ManageResults_LS.getResultLineStatus(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultLineStatusWithLine(){
        Test.startTest();
        
        ProductServiceCampaign pscRecord = createRecords();
        Common.ServiceResponse response = PSC_ManageResults_LS.getResultLineStatus(String.valueOf(pscRecord.Id));
        System.assert(response.success == true);

        Psc.ResultLineStatus data = (Psc.ResultLineStatus) response.data;
        System.assert(data.casesDelivered == 1);
        System.assert(data.linesGenerated == 1);
        System.assert(data.linesDelivered == 1);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultLinesWithNull(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_ManageResults_LS.getResultLines(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultLinesWithInvalidJson(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_ManageResults_LS.getResultLines('{"Test"}');
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetResultLines(){
        Test.startTest();
        
        ProductServiceCampaign pscRecord = createRecords();

        Psc.ResultLineRequest request = new Psc.ResultLineRequest();
        request.id = pscRecord.Id;
        request.fieldApiNames = new List<String>{'Asset.Name', 'Asset.Location.Name', 'Status'};

        Common.ServiceResponse response = PSC_ManageResults_LS.getResultLines(JSON.serialize(request));
        System.assert(response.success == true);

        List<Map<String, Object>> records = (List<Map<String, Object>>) response.data;
        System.assert(records.size() == 1);

        Test.stopTest();
    }

    @IsTest
    static void testGetAddAssetColumns(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_ManageResults_LS.getAddAssetColumns();
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testGetAssetRecordsWithNull(){
        Test.startTest();
        
        Common.ServiceResponse response = PSC_ManageResults_LS.getAssetRecords(null);
        System.assert(response.success == false);

        response = PSC_ManageResults_LS.getAssetRecords('{\'test\':\'t\'}');
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetAssetRecordsWithData(){
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Test.startTest();
        
        Psc.SearchAssetRequest request = new Psc.SearchAssetRequest();
        request.id = product.Id;
        request.searchKeyword = 'Test';
        Common.ServiceResponse response = PSC_ManageResults_LS.getAssetRecords(JSON.serialize(request));
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testInsertUpdatePsciRecordsWithData(){
        Date todayDate = System.today();
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2)
        });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        List<ProductServiceCampaignItem> psciRecordList = new List<ProductServiceCampaignItem>();

        ProductServiceCampaignItem psciRecord = new ProductServiceCampaignItem();
        psciRecord.ProductServiceCampaignId = pscRecord.Id;
        psciRecord.AssetId = assetRecord.Id;
        psciRecord.SVMXA360__DeliveryMethod__c = 'Case';
        psciRecordList.add(psciRecord);

        Test.startTest();
        
        String request = JSON.serialize(psciRecordList);
        Common.ServiceResponse response = PSC_ManageResults_LS.insertUpdatePsciRecords(request);
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testInsertUpdatePsciRecordsWithInvalidJson(){
        ProductServiceCampaignItem psciRecord = new ProductServiceCampaignItem();
        psciRecord.SVMXA360__DeliveryMethod__c = 'Case';

        Test.startTest();
        
        String request = JSON.serialize(psciRecord);
        Common.ServiceResponse response = PSC_ManageResults_LS.insertUpdatePsciRecords(request);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testInsertUpdatePsciRecordsWithInvalidData(){
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        List<ProductServiceCampaignItem> psciRecordList = new List<ProductServiceCampaignItem>();

        ProductServiceCampaignItem psciRecord = new ProductServiceCampaignItem();
        psciRecord.AssetId = assetRecord.Id;
        psciRecord.SVMXA360__DeliveryMethod__c = 'Case';
        psciRecordList.add(psciRecord);

        Test.startTest();
        
        String request = JSON.serialize(psciRecordList);
        Common.ServiceResponse response = PSC_ManageResults_LS.insertUpdatePsciRecords(request);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testInitiateGenerateOutputBatchWithNull(){

        Test.startTest();
        
        Common.ServiceResponse response = PSC_ManageResults_LS.initiateGenerateOutputBatch(null);
        System.assert(response.success == false);
        System.assert(response.message == ErrorMessage.INVALID_ARGUMENT);

        Test.stopTest();
    }

    static ProductServiceCampaign createRecords() {
        Date todayDate = System.today();
        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2', new Map<String,Object>{ 'Name' => 'TestProduct' });

        ProductServiceCampaign pscRecord = (ProductServiceCampaign) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaign', 
        new Map<String,Object>{
            'ProductServiceCampaignName' => 'TestPSC',
            'Type' => 'Recall',
            'Status' => 'New',
            'StartDate' => todayDate,
            'EndDate' => todayDate.addMonths(2)
        });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = (Account) SvmxTestDataFactory.insertSObject( 'Account', new Map<String,Object>{ 'Name' => 'Test-Account' });
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test-Contact', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset',
            'RecordTypeId' => rt.Id,
            'Product2Id' => product.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        ProductServiceCampaignItem psciRecord = (ProductServiceCampaignItem) SvmxTestDataFactory.insertSObject( 'ProductServiceCampaignItem', 
        new Map<String,Object>{
            'ProductServiceCampaignId' => pscRecord.Id,
            'AssetId' => assetRecord.Id,
            'SVMXA360__DeliveryMethod__c' => 'Case',
            'Status' => 'OutputGenerated'
        });

        return pscRecord;
    }
}