@isTest
public with sharing class AddMaintenanceAssetApexAction_UT {

    @testSetup public static void setup() {
        Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 60000',
            'ProductCode' => 'SPA600',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 60000'  
        });

        Product2 productRecord2 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 120000',
            'ProductCode' => 'SPA6001',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 120000'  
        });

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'CustomerOwned' AND SobjectType = 'Asset'];
        Account account = new Account(Name = 'Test_Account123');
        insert account;
        Contact contact = (Contact) SvmxTestDataFactory.insertSObject( 'Contact', new Map<String,Object>{ 'LastName' => 'Test_Contact123', 'AccountId' => account.Id });
        Asset assetRecord = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset123',
            'RecordTypeId' => rt.Id,
            'Product2Id' => productRecord.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id
        });

        Asset assetRecord2 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset', 
        new Map<String,Object>{
            'Name' => 'Test-Asset12345',
            'RecordTypeId' => rt.Id,
            'Product2Id' => productRecord2.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id,
            'SerialNumber' => 'SN-12345'
        });

        WorkType workTypeRecord = (WorkType) SvmxTestDataFactory.insertSObject( 'WorkType', 
        new Map<String,Object>{
            'Name' => 'WorkType_1',
            'ShouldAutoCreateSvcAppt' => true,
            'EstimatedDuration' => 2.00,
            'DurationType' => 'Hours',
            'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1
        });

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c', 
        new Map<String,Object>{
            'Name' => 'MaintenancePlanTemplate_1',
            'SVMXA360__MaintenancePlanDuration__c' => 2,
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Years',
            'SVMXA360__IsActive__c' => true,
            'SVMXA360__WorkOrderGenerationMethod__c' => 'WorkOrderPerAsset',
            'SVMXA360__SvcApptGenerationMethod__c' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true,
            'SVMXA360__Description__c' => 'Test Desc',
            'SVMXA360__DoesGenerateUponCompletion__c' => true,
            'SVMXA360__GenerationHorizon__c' => 2,
            'SVMXA360__GenerationTimeframe__c' => 3,
            'SVMXA360__GenerationTimeframeType__c' => 'Months',
            'SVMXA360__MaintenanceWindowEndDays__c' => 2,
            'SVMXA360__MaintenanceWindowStartDays__c' => 3,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__MaintenancePlanTemplateProductId__c'=> productRecord.Id
        });

        SVMXA360__ApplicableProduct__c applicableProductRecord = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject('SVMXA360__ApplicableProduct__c',
        new Map<String,Object> {
            'SVMXA360__MaintenancePlanTemplateId__c'=> mpTemplate.id, 
            'SVMXA360__ProductId__c' => productRecord.Id, 
            'SVMXA360__ProductFamily__c' => null , 
            'SVMXA360__WorkTypeId__c' => workTypeRecord.id
        });
    }

    @IsTest
    static void testAddMaintenanceAssets(){

        Asset assetRecord = [SELECT Id FROM Asset WHERE SerialNumber = 'SN-12345'];
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test_Account123'];
        SVMXA360__MaintenancePlanTemplate__c templateRecord = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'];

        List<MaintenancePlanData> maintenancePlanDataList = new List<MaintenancePlanData>();
        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
        maintenancePlanData.sourceRecordId = accountRecord.Id;
        maintenancePlanData.maintenancePlanTemplateId = templateRecord.Id;
        maintenancePlanDataList.add(maintenancePlanData);

        Test.startTest();

        List<MaintenancePlanData> responseList = CreateMaintenancePlanApexAction.createMaintenancePlan(maintenancePlanDataList);
        System.assert(responseList != null);
        System.assert(!responseList.isEmpty());
        System.assert(responseList[0].maintenancePlanId != null);

        MaintenanceAssetData maintenanceAssetData = new MaintenanceAssetData();
        maintenanceAssetData.assetId = assetRecord.Id;

        List<MaintenancePlanAssetData> maintenancePlanAssetDataList = new List<MaintenancePlanAssetData>();

        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenancePlanId = responseList[0].maintenancePlanId;
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>{ maintenanceAssetData };
        maintenancePlanAssetDataList.add(maintenancePlanAssetData);

        List<MaintenancePlanAssetData> maintenancePlanAssetDataResponse = AddMaintenanceAssetApexAction.addMaintenanceAssets(maintenancePlanAssetDataList);
        System.assert(maintenancePlanAssetDataResponse != null);
        System.assert(!maintenancePlanAssetDataResponse.isEmpty());
        System.assert(maintenancePlanAssetDataResponse[0].maintenanceAssetDataList[0].maintenanceAssetId != null);

        Test.stopTest();
    }

    @IsTest
    static void testAddMaintenanceAssetsWithError(){

        Asset assetRecord = [SELECT Id FROM Asset WHERE SerialNumber = 'SN-12345'];
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Test_Account123'];
        Product2 productRecord = [SELECT Id FROM Product2 WHERE Name = 'Solar Panel 60000'];
        SVMXA360__MaintenancePlanTemplate__c templateRecord = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'];

        List<MaintenancePlanData> maintenancePlanDataList = new List<MaintenancePlanData>();
        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
		maintenancePlanData.sourceRecordId = accountRecord.Id;
        maintenancePlanData.maintenancePlanTemplateProductId = productRecord.Id;
        maintenancePlanData.startDate = Date.today();
        maintenancePlanData.operationType = 'FOR-PRODUCT';
        maintenancePlanDataList.add(maintenancePlanData);

        Test.startTest();

        List<MaintenancePlanData> responseList = CreateMaintenancePlanApexAction.createMaintenancePlan(maintenancePlanDataList);
        System.assert(responseList != null);
        System.assert(!responseList.isEmpty());
        System.assert(responseList[0].maintenancePlanId != null);

        MaintenanceAssetData maintenanceAssetData = new MaintenanceAssetData();
        maintenanceAssetData.assetId = assetRecord.Id;
        maintenanceAssetData.dateOfFirstWorkOrderInNextBatch = Date.today().addDays(-5);

        List<MaintenancePlanAssetData> maintenancePlanAssetDataList = new List<MaintenancePlanAssetData>();

        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenancePlanId = responseList[0].maintenancePlanId;
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>{ maintenanceAssetData };
        maintenancePlanAssetDataList.add(maintenancePlanAssetData);

        try{
            List<MaintenancePlanAssetData> maintenancePlanAssetDataResponse = AddMaintenanceAssetApexAction.addMaintenanceAssets(maintenancePlanAssetDataList);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(System.Label.Error_MaintenanceAssetCreationFailed) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testAddMaintenanceAssetsWithNullRequest(){

        Test.startTest();

        try{
            List<MaintenancePlanAssetData> maintenancePlanAssetDataResponse = AddMaintenanceAssetApexAction.addMaintenanceAssets(null);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER) != -1);
        }

        Test.stopTest();
    }
}