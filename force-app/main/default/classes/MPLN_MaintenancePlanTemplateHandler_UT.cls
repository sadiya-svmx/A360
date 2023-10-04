@isTest
public class MPLN_MaintenancePlanTemplateHandler_UT {

    @testSetup public static void setup(){
        MPLN_MaintenancePlanTemplate_LS_UT.setup();

        //Data setup for creation of Maintenance Plan, Maintenance Asset and Maintenance Work Rule
        Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 60000',
            'ProductCode' => 'SPA600',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 60000'
        });

        Schema.Location locationRecord = (Schema.Location) SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{
            'Name'=> 'Test_location_1',
            'LocationType' => 'Van',
            'ExternalReference' => 'test123'
        });

        RecordsetFilterCriteria recordsetFilterCriteria = (RecordsetFilterCriteria) SvmxTestDataFactory.insertSObject( 'RecordsetFilterCriteria',
        new Map<String,Object>{
            'Name' => 'Test Filter Criteria_1',
            'IsActive' => true,
            'FilteredObject' => 'Asset',
            'SourceObject' => 'MaintenanceWorkRule',
            'LogicalOperator' => 'AND'
        });

        RecordsetFilterCriteriaRule recordsetFilterCriteriaRule = new RecordsetFilterCriteriaRule();
        recordsetFilterCriteriaRule.RecordsetFilterCriteriaId = recordsetFilterCriteria.Id;
        recordsetFilterCriteriaRule.CriteriaField = 'Asset.Status';
        recordsetFilterCriteriaRule.Operator = 'Equals';
        recordsetFilterCriteriaRule.Value = 'Installed';
        recordsetFilterCriteriaRule.Index = 1;
        insert recordsetFilterCriteriaRule;

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
            'ContactId' => contact.Id,
            'LocationId' => locationRecord.Id
        });

        Asset assetRecord2 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset',
        new Map<String,Object>{
            'Name' => 'Test-Asset12345',
            'RecordTypeId' => rt.Id,
            'Product2Id' => productRecord.Id,
            'Status' => 'Shipped',
            'AccountId' => account.Id,
            'ContactId' => contact.Id,
            'LocationId' => locationRecord.Id
        });

        Asset assetRecord3 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset',
        new Map<String,Object>{
            'Name' => 'SPASSET001',
            'RecordTypeId' => rt.Id,
            'Product2Id' => productRecord.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id,
            'LocationId' => locationRecord.Id,
            'SerialNumber' => 'SPASSET001'
        });

        Asset assetRecord4 = (Asset) SvmxTestDataFactory.insertSObject( 'Asset',
        new Map<String,Object>{
            'Name' => 'SPASSET002',
            'RecordTypeId' => rt.Id,
            'Status' => 'Installed',
            'AccountId' => account.Id,
            'ContactId' => contact.Id,
            'LocationId' => locationRecord.Id,
            'SerialNumber' => 'SPASSET002'
        });

        WorkType workTypeRecord = (WorkType) SvmxTestDataFactory.insertSObject( 'WorkType',
        new Map<String,Object>{
            'Name' => 'WorkType_1',
            'ShouldAutoCreateSvcAppt' => true,
            'EstimatedDuration' => 1.00,
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
            'SVMXA360__MaintenancePlanTemplateProductId__c' => productRecord.Id
        });

        SVMXA360__ApplicableProduct__c applicableProductRecord = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject('SVMXA360__ApplicableProduct__c',
        new Map<String,Object> {
            'SVMXA360__MaintenancePlanTemplateId__c'=> mpTemplate.id,
            'SVMXA360__ProductId__c' => productRecord.Id,
            'SVMXA360__ProductFamily__c' => null ,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.id
        });

        SVMXA360__ApplicableProduct__c applicableProductRecord2 = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ApplicableProduct__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ProductFamily__c' => 'Turbines',
            'SVMXA360__ProductId__c' => null
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateForMPTemplate = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'Name' => 'WorkRuleTemplate_1',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => 'FREQ=MONTHLY;INTERVAL=2;BYMONTHDAY=1',
            'SVMXA360__Type__c' => 'Calendar',
            'SVMXA360__RecordsetFilterCriteriaId__c' => null
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateForAppProduct = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProductRecord.Id,
            'Name' => 'WorkRuleTemplate_2',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => 'FREQ=MONTHLY;INTERVAL=2;BYMONTHDAY=1',
            'SVMXA360__Type__c' => 'Calendar',
            'SVMXA360__RecordsetFilterCriteriaId__c' => null
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateForAppProduct2 = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProductRecord2.Id,
            'Name' => 'WorkRuleTemplate_3',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => 'FREQ=MONTHLY;INTERVAL=2;BYMONTHDAY=1',
            'SVMXA360__Type__c' => 'Calendar',
            'SVMXA360__RecordsetFilterCriteriaId__c' => null
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateForAppProduct3 = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProductRecord2.Id,
            'Name' => 'WorkRuleTemplate_4',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => null,
            'SVMXA360__Type__c' => 'CriteriaValue',
            'SVMXA360__RecordsetFilterCriteriaId__c' => recordsetFilterCriteria.Id
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateForAppProduct4 = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProductRecord2.Id,
            'Name' => 'WorkRuleTemplate_4',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => null,
            'SVMXA360__Type__c' => 'CriteriaValue',
            'SVMXA360__RecordsetFilterCriteriaId__c' => 'dummyId'
        });

        // Service Contract Source
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookEntryRecord1 = (PricebookEntry) SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String, Object> {
            'Pricebook2Id' =>  pricebookId,
            'IsActive' => true,
            'UnitPrice' => 1.0,
            'Product2Id' => productRecord.Id,
            'UseStandardPrice' => false
        });

        ServiceContract serviceContractRecord = (ServiceContract) SvmxTestDataFactory.insertSObject('ServiceContract', new Map<String, Object> {
            'Name' =>  'ServiceContract_1',
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addYears(1),
            'Pricebook2Id' => pricebookId
        });

        ContractLineItem contractLineItemRecord = (ContractLineItem) SvmxTestDataFactory.insertSObject('ContractLineItem', new Map<String, Object> {
            'AssetId' =>  assetRecord.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addYears(1),
            'ServiceContractId' => serviceContractRecord.Id,
            'Quantity' => 1,
            'PricebookEntryId' => pricebookEntryRecord1.Id
        });

        /*
        // Maintenance Plan Template without Work Rule Template
        SVMXA360__MaintenancePlanTemplate__c templateWithoutWorkRule = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c',
        new Map<String,Object>{
            'Name' => 'Template_Without_WorkRule',
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
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id
        });*/

        Map<String, Schema.SObjectField> mPlanFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenancePlan');
        Map<String,Object> recordMap1 = new Map<String,Object>{
            'MaintenancePlanTitle' => 'Maintenance CPQ Plan',
            'WorkOrderGenerationMethod' => 'WorkOrderPerAsset',
            'SvcApptGenerationMethod' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true,
            'Description' => 'Test CPQ service',
            'DoesAutoGenerateWorkOrders' => true,
            'GenerationHorizon' => 2,
            'GenerationTimeframe' => 3,
            'GenerationTimeframeType' => 'Months',
            'MaintenanceWindowEndDays' => 2,
            'MaintenanceWindowStartDays' => 3,
            'StartDate' => System.today(),
            'EndDate' => System.today()+365,
            'WorkTypeId' => workTypeRecord.Id,
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id
        };
        Map<String,Object> recordMap2 = new Map<String,Object>{
            'MaintenancePlanTitle' => 'Maintenance CPQ Plan No Template',
            'WorkOrderGenerationMethod' => 'WorkOrderPerAsset',
            'SvcApptGenerationMethod' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true,
            'Description' => 'Test CPQ service',
            'DoesAutoGenerateWorkOrders' => true,
            'GenerationHorizon' => 2,
            'GenerationTimeframe' => 3,
            'GenerationTimeframeType' => 'Months',
            'MaintenanceWindowEndDays' => 2,
            'MaintenanceWindowStartDays' => 3,
            'StartDate' => System.today(),
            'EndDate' => System.today()+365,
            'WorkTypeId' => workTypeRecord.Id
        };
        if (!mPlanFieldMap.isEmpty() && mPlanFieldMap.containsKey('Frequency') && mPlanFieldMap.containsKey('FrequencyType')) {
            recordMap1.put('Frequency', 1);
            recordMap1.put('FrequencyType', 'Days');
            recordMap2.put('Frequency', 1);
            recordMap2.put('FrequencyType', 'Days');
        }
        MaintenancePlan maintenancePlan1 = (MaintenancePlan) SvmxTestDataFactory.insertSObject( 'MaintenancePlan', recordMap1);
        MaintenancePlan maintenancePlan2 = (MaintenancePlan) SvmxTestDataFactory.insertSObject( 'MaintenancePlan', recordMap2);
    }

    @isTest
    static void testGetMaintenaceAssets(){

        String templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'Solar Panel Template'].Id;
        String accountId = [SELECT Id FROM Account where Name = 'Dream House'].Id;

        Test.startTest();


        Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
        maintenanceAssetRequest.templateId = templateId;
        maintenanceAssetRequest.sourceRecordId = accountId;
        List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = (new MPLN_MaintenancePlanTemplateHandler() ).getMaintenanceAssets(maintenanceAssetRequest);

        System.assert(maintenanceAssetList !=null );

        Test.stopTest();
    }

    @isTest
    static void testGetMaintenaceAssetsWithAssetStatus(){

        String templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'Solar Panel Template'].Id;
        String accountId = [SELECT Id FROM Account where Name = 'Dream House'].Id;

        Test.startTest();

        Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
        maintenanceAssetRequest.templateId = templateId;
        maintenanceAssetRequest.sourceRecordId = accountId;
        maintenanceAssetRequest.assetStatusValues = new List<String>{'Installed'};
        List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = (new MPLN_MaintenancePlanTemplateHandler() ).getMaintenanceAssets(maintenanceAssetRequest);

        System.assert(maintenanceAssetList !=null );

        Test.stopTest();
    }

    @isTest
    static void testGetMaintenaceAssetsWithNullArgument(){

        Test.startTest();

        try{
            Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
            List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = (new MPLN_MaintenancePlanTemplateHandler()) .getMaintenanceAssets(maintenanceAssetRequest);
        }
        catch(Exception e){
            System.assertEquals( e instanceOf SvmxSystem.SvmxNestedException , true );
        }
        Test.stopTest();
    }

    @isTest static void getMaintenaceAssetsWithNullRequest(){

        Test.startTest();

        try{
            List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = (new MPLN_MaintenancePlanTemplateHandler()) .getMaintenanceAssets(null);
        }
        catch(Exception e){
            System.assertEquals( e instanceOf SvmxSystem.SvmxNestedException , true , 'request should be null');
        }

        Test.stopTest();

    }

    @isTest
    static void testGetMaintenaceAssetsForIncludeChildWhenIsRoot(){

        String templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'Solar Panel Template'].Id;
        String assetId = [SELECT Id FROM Asset where SerialNumber = 'SP8001'].Id;

        Test.startTest();

        Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
        maintenanceAssetRequest.templateId = templateId;
        maintenanceAssetRequest.sourceRecordId = assetId;
        maintenanceAssetRequest.assetStatusValues = new List<String>{'Installed'};
        maintenanceAssetRequest.includeChildAssets = true;
        List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = (new MPLN_MaintenancePlanTemplateHandler() ).getMaintenanceAssets(maintenanceAssetRequest);
        System.assert(maintenanceAssetList !=null,'maintenanceAssetList should not be null');

        Test.stopTest();
    }

    @isTest
    static void testGetMaintenaceAssetsForIncludeChildWhenIsChild(){

        String templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'Solar Panel Template'].Id;
        String assetId = [SELECT Id FROM Asset where SerialNumber = 'SP8001C1'].Id;

        Test.startTest();
        Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
        maintenanceAssetRequest.templateId = templateId;
        maintenanceAssetRequest.sourceRecordId = assetId;
        maintenanceAssetRequest.assetStatusValues = new List<String>{'Installed'};
        maintenanceAssetRequest.includeChildAssets = true;
        List<Mpln.MaintenanceAssetInformation> maintenanceAssetList = (new MPLN_MaintenancePlanTemplateHandler() ).getMaintenanceAssets(maintenanceAssetRequest);
        System.assert(maintenanceAssetList !=null,'maintenanceAssetList should not be null');

        Test.stopTest();
    }

    @IsTest
    static void testGetAssetList(){

        Test.startTest();

        List<Mpln.AssetInformation> response = new MPLN_MaintenancePlanTemplateHandler().getAssetList('Solar', new List<String>{'Installed'}, null);
        System.assert(response.size() > 0);

		response = new MPLN_MaintenancePlanTemplateHandler().getAssetList('Solar', null, null);
        System.assert(response.size() > 0);

        Test.stopTest();
    }

    @IsTest
    static void testGetAssetListWithNull(){

        Test.startTest();

        try{
            List<Mpln.AssetInformation> response = new MPLN_MaintenancePlanTemplateHandler().getAssetList(null, null, null);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }
        Test.stopTest();
    }

    @IsTest
    static void testExecuteMaintenancePlanForAccount(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123'].Id;
        request.templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'].Id;

        Test.startTest();

        MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);

        System.assert(response != null);
        System.assert(response.Id != null);

        Test.stopTest();
    }

    @IsTest
    static void testExecuteMaintenancePlanForAccountWithMAssets(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123'].Id;
        request.templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'].Id;

        Asset assetRec = [SELECT Id FROM Asset WHERE Status = 'Shipped'];
        MaintenanceAsset mAsset = new MaintenanceAsset();
        mAsset.AssetId = assetRec.Id;
        request.maintenanceAssetRecords = new List<MaintenanceAsset>{ mAsset };

        Test.startTest();

        MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);

        System.assert(response != null);
        System.assert(response.Id != null);

        Test.stopTest();
    }

    @IsTest
    static void testExecuteMaintenancePlanWithNull(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = null;
        request.templateId = null;

        Test.startTest();

        try {
            MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

        try {
            MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(null);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testExecuteMaintenancePlanWithInvalidTemplate(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123'].Id;
        SVMXA360__MaintenancePlanTemplate__c templateRecord = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'];
        request.templateId = templateRecord.Id;
        delete templateRecord;
        Test.startTest();

        try {
            MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS) != -1);
        }

        Test.stopTest();
    }

    /*
    @IsTest
    static void testExecuteMaintenancePlanWithNoWorkRuleTemplate(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123'].Id;
        SVMXA360__MaintenancePlanTemplate__c templateRecord = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'Template_Without_WorkRule'];
        request.templateId = templateRecord.Id;
        Test.startTest();

        try {
            MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);
        }
        catch(Exception e){
            System.assert(e.getMessage().indexOf(ErrorMessage.TEMPLATE_WITHOUT_WORK_RULE) != -1);
        }

        Test.stopTest();
    }
    */

    @IsTest
    static void testExecuteMaintenancePlanForLocation(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM Location WHERE Name = 'Test_location_1'].Id;
        request.templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'].Id;

        Test.startTest();

        MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);

        System.assert(response != null);
        System.assert(response.Id != null);

        Test.stopTest();
    }

    @IsTest
    static void testExecuteMaintenancePlanForServiceContract(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM ServiceContract WHERE Name = 'ServiceContract_1'].Id;
        request.templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'].Id;

        Test.startTest();

        MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);

        System.assert(response != null);
        System.assert(response.Id != null);

        Test.stopTest();
    }

    @IsTest
    static void testExecuteMaintenancePlanForAsset(){

        Mpln.MaintenancePlanRequest request = new Mpln.MaintenancePlanRequest();
        request.sourceRecordId = [SELECT Id FROM Asset][0].Id;
        request.templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'].Id;

        Test.startTest();

        MaintenancePlan response = new MPLN_MaintenancePlanTemplateHandler().executeMaintenancePlan(request);

        System.assert(response != null);
        System.assert(response.Id != null);

        Test.stopTest();
    }

    //CPQ service unit test
    @IsTest
    static void testaddMaintenanceAssets(){

        List<Asset> assetList= ([SELECT Id FROM Asset where SerialNumber IN ('SPASSET001', 'SPASSET002') ORDER BY SerialNumber ASC ]);
        String maintenancePlanId = [SELECT Id FROM MaintenancePlan where MaintenancePlanTitle = 'Maintenance CPQ Plan'].id;

        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;

        Test.startTest();

        MaintenanceAssetData maintenanceAssetData1 = new MaintenanceAssetData();
        maintenanceAssetData1.assetId = assetList[0].Id; // qualified asset with applicable product
        maintenanceAssetData1.dateOfFirstWorkOrderInNextBatch = System.Today() + 3;

        MaintenanceAssetData maintenanceAssetData2 = new MaintenanceAssetData();
        maintenanceAssetData2.assetId = assetList[1].Id;// non qualified asset with applicable product
        maintenanceAssetData2.dateOfFirstWorkOrderInNextBatch = System.Today() + 3;

        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData> {maintenanceAssetData1 , maintenanceAssetData2};
        Common.ServiceResponse response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, true, 'request should execute successfully');

        Test.stopTest();
    }

    @IsTest
    static void testaddMaintenanceAssetsWithInvalidRequest(){

        MaintenancePlanAssetData maintenancePlanAssetData = null;
        Common.ServiceResponse response = null;

        Test.startTest();
        // null request
        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');

        // when MaintenanceAssetData null
        maintenancePlanAssetData = new MaintenancePlanAssetData();
        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');

        // when maintenancePlanId is null
        maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>();
        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');

        Test.stopTest();
    }

    @IsTest
    static void testaddMaintenanceAssetsWithInvalidRequestData1(){

        String assetId = [SELECT Id FROM Asset where SerialNumber = 'SPASSET001'].id;
        String maintenancePlanId = [SELECT Id FROM MaintenancePlan where MaintenancePlanTitle = 'Maintenance CPQ Plan No Template'].id;

        MaintenancePlanAssetData maintenancePlanAssetData = null;
        Common.ServiceResponse response = null;

        Test.startTest();

        maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>();
        maintenancePlanAssetData.maintenancePlanId = assetId;// sending assetId instead maintenanceplan id
        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');

        maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;
        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');

        Test.stopTest();
    }

    @IsTest
    static void testaddMaintenanceAssetsWithInvalidRequestData2(){

        String maintenancePlanId = [SELECT Id FROM MaintenancePlan where MaintenancePlanTitle = 'Maintenance CPQ Plan'].id;

        MaintenancePlanAssetData maintenancePlanAssetData = null;
        Common.ServiceResponse response = null;

        Test.startTest();

        //correct maintenanceplan but no assetId withh data
        maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;
        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');


        maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData>();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;

        MaintenanceAssetData maintenanceAssetData = new MaintenanceAssetData();
        maintenanceAssetData.assetId = maintenancePlanId;// sending maintenancePlan id instead assetId
        maintenanceAssetData.dateOfFirstWorkOrderInNextBatch = System.Today() + 3;
        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData> {maintenanceAssetData };

        response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.message, null , 'should return error message');

        Test.stopTest();
    }

    /*
      dateOfFirstWorkOrderInNextBatch is incorrect for one of the asset
      Error : The Date of the first work order in the next batch must be later than or equal to the related maintenance plan's Start Date
    */
    @IsTest
    static void testaddMaintenanceAssetsWithInvalidRequestData3(){

        List<Asset> assetList= ([SELECT Id FROM Asset where SerialNumber IN ('SPASSET001', 'SPASSET002') ORDER BY SerialNumber ASC ]);
        String maintenancePlanId = [SELECT Id FROM MaintenancePlan where MaintenancePlanTitle = 'Maintenance CPQ Plan'].id;

        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;

        Test.startTest();

        MaintenanceAssetData maintenanceAssetData1 = new MaintenanceAssetData();
        maintenanceAssetData1.assetId = assetList[0].Id; // qualified asset with applicable product
        maintenanceAssetData1.dateOfFirstWorkOrderInNextBatch = System.Today() + 3;

        MaintenanceAssetData maintenanceAssetData2 = new MaintenanceAssetData();
        maintenanceAssetData2.assetId = assetList[1].Id;// non qualified asset with applicable product
        maintenanceAssetData2.dateOfFirstWorkOrderInNextBatch = System.Today() - 10; // Invalid

        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData> {maintenanceAssetData1 , maintenanceAssetData2};
        Common.ServiceResponse response = new MPLN_MaintenancePlanTemplateHandler().addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.errors, null, 'There shoud be an error');

        Test.stopTest();
    }

    // MaintenancePlanService Unit test
    @IsTest
    static void testaddMaintenanceAssetsService(){


        String assetId = [SELECT Id FROM Asset where SerialNumber = 'SPASSET001'].id;
        String maintenancePlanId = [SELECT Id FROM MaintenancePlan where MaintenancePlanTitle = 'Maintenance CPQ Plan'].id;

        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;

        Test.startTest();

        MaintenanceAssetData maintenanceAssetData1 = new MaintenanceAssetData();
        maintenanceAssetData1.assetId = assetId; // qualified asset with applicable product
        maintenanceAssetData1.dateOfFirstWorkOrderInNextBatch = System.Today() + 3;


        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData> {maintenanceAssetData1 };
        SvmxGlobal.SvmxResponse response = MaintenancePlanService.addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, true, 'request should execute successfully');

        Test.stopTest();

    }
    /*
      dateOfFirstWorkOrderInNextBatch is incorrect
      Error : The Date of the first work order in the next batch must be later than or equal to the related maintenance plan's Start Date
    */
    @IsTest
    static void testaddMaintenanceAssetsServiceInvalidData1(){


        String assetId = [SELECT Id FROM Asset where SerialNumber = 'SPASSET001'].id;
        String maintenancePlanId = [SELECT Id FROM MaintenancePlan where MaintenancePlanTitle = 'Maintenance CPQ Plan'].id;

        MaintenancePlanAssetData maintenancePlanAssetData = new MaintenancePlanAssetData();
        maintenancePlanAssetData.maintenancePlanId = maintenancePlanId;

        Test.startTest();

        MaintenanceAssetData maintenanceAssetData1 = new MaintenanceAssetData();
        maintenanceAssetData1.assetId = assetId; // qualified asset with applicable product
        maintenanceAssetData1.dateOfFirstWorkOrderInNextBatch = System.Today() - 10;//Invalid


        maintenancePlanAssetData.maintenanceAssetDataList = new List<MaintenanceAssetData> {maintenanceAssetData1 };
        SvmxGlobal.SvmxResponse response = MaintenancePlanService.addMaintenanceAssets (maintenancePlanAssetData);

        System.assertNotEquals(response, null , 'response should not be null');
        System.assertEquals(response.success, false, 'request should fail');
        System.assertNotEquals(response.errors, null, 'There shoud be an error');

        Test.stopTest();
    }

    @IsTest
    static void testCreateMaintenancePlan(){

        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
        maintenancePlanData.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123' LIMIT 1].Id;
        maintenancePlanData.dateOfFirstWorkOrderInNextBatch = Date.today();
        maintenancePlanData.maintenancePlanTemplateProductId = [SELECT Id FROM Product2 WHERE Name = 'Solar Panel 60000' LIMIT 1].Id;
        maintenancePlanData.maintenancePlanTitle = 'Test Maintenance Plan';
        maintenancePlanData.startDate = Date.today();
        maintenancePlanData.subscriptionFieldName = 'Description';
        maintenancePlanData.subscriptionId = 'TestDesc';

        Test.startTest();

        SvmxGlobal.SvmxResponse response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == true);

        maintenancePlanData = (MaintenancePlanData) response.data;
        System.assert(maintenancePlanData.maintenancePlanId != null);

        Test.stopTest();
    }

    @IsTest
    static void testCreateMaintenancePlanWithInvalidReq(){

        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
        maintenancePlanData.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123' LIMIT 1].Id;
        maintenancePlanData.dateOfFirstWorkOrderInNextBatch = Date.today();
        maintenancePlanData.maintenancePlanTemplateProductId = [SELECT Id FROM Product2 WHERE Name = 'Solar Panel 60000' LIMIT 1].Id;
        maintenancePlanData.maintenancePlanTitle = 'Test Maintenance Plan';
        maintenancePlanData.startDate = Date.today();
        maintenancePlanData.subscriptionFieldName = 'Description';

        Test.startTest();

        // subscriptionFieldName is present and subscriptionId is missing
        SvmxGlobal.SvmxResponse response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == false);

        maintenancePlanData.subscriptionFieldName = null;
        maintenancePlanData.subscriptionId = 'TestDesc';

        // subscriptionId is present and subscriptionFieldName is missing
        response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testCreateMaintenancePlanWithNullReq(){

        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();

        Test.startTest();

        SvmxGlobal.SvmxResponse response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == false);
        System.assert(response.message == ErrorMessage.MISSING_REQUIRED_PARAMETER);

        response = MaintenancePlanService.createMaintenancePlan(null);
        System.assert(response.success == false);
        System.assert(response.message == ErrorMessage.INVALID_ARGUMENT);

        Test.stopTest();
    }

    @IsTest
    static void testCreateMaintenancePlanWithNoTemplate(){

        Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 11000',
            'ProductCode' => 'SPA6001',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 6000011'
        });

        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
        maintenancePlanData.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123' LIMIT 1].Id;
        maintenancePlanData.maintenancePlanTemplateProductId = productRecord.Id;
        maintenancePlanData.startDate = Date.today();

        Test.startTest();

        SvmxGlobal.SvmxResponse response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testCreateMaintenancePlanWithMultipleTemplate(){

        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Solar Panel 60000' LIMIT 1].Id;
        SVMXA360__MaintenancePlanTemplate__c mpTemplate = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c',
        new Map<String,Object>{
            'Name' => 'MaintenancePlanTemplate_123',
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
            'SVMXA360__MaintenancePlanTemplateProductId__c' => productId
        });

        MaintenancePlanData maintenancePlanData = new MaintenancePlanData();
        maintenancePlanData.sourceRecordId = [SELECT Id FROM Account WHERE Name = 'Test_Account123' LIMIT 1].Id;
        maintenancePlanData.maintenancePlanTemplateProductId = productId;
        maintenancePlanData.startDate = Date.today();

        Test.startTest();

        SvmxGlobal.SvmxResponse response = MaintenancePlanService.createMaintenancePlan(maintenancePlanData);
        System.assert(response.success == false);

        Test.stopTest();
    }
}