@IsTest
public class MPLN_MaintenancePlanTemplate_LS_UT {

    @testSetup public static void setup() {
        SVMXA360__MaintenancePlanTemplate__c mpTemplate = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c',
        new Map<String,Object>{
            'Name' => 'TestTemplate',
            'SVMXA360__MaintenancePlanDuration__c' => 2,
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Years',
            'SVMXA360__IsActive__c' => true,
            'SVMXA360__WorkOrderGenerationMethod__c' => 'WorkOrderPerAsset',
            'SVMXA360__SvcApptGenerationMethod__c' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true,
            'SVMXA360__GenerationTimeframe__c' => 1
        });

        WorkType workTypeRecord = (WorkType) SvmxTestDataFactory.insertSObject( 'WorkType',
        new Map<String,Object>{
            'Name' => 'TestWorkType',
            'ShouldAutoCreateSvcAppt' => true,
            'EstimatedDuration' => 1.00,
            'DurationType' => 'Hours',
            'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1
        });

        RecordsetFilterCriteria recordsetFilterCriteria = (RecordsetFilterCriteria) SvmxTestDataFactory.insertSObject( 'RecordsetFilterCriteria',
        new Map<String,Object>{
            'Name' => 'Test Filter Criteria',
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

        SVMXA360__ApplicableProduct__c applicableProduct = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ApplicableProduct__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ProductFamily__c' => 'Turbines'
        });


        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplate = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProduct.Id,
            'Name' => 'Test Workrule Template',
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__RecurrencePattern__c' => 'FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;'
        });

        Product2 product = (Product2) SvmxTestDataFactory.insertSObject( 'Product2',
        new Map<String,Object>{
            'Name' => 'TestProduct',
            'IsActive' => true
        });

        Product2 product1 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 600',
            'ProductCode' => 'SPA600',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 600'
        });

        Product2 product2 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 700',
            'ProductCode' => 'SPA700',
            'IsActive' => true,
            'Family' => 'Laptops',
            'StockKeepingUnit' => 'Solar Panel 700'
        });

        Product2 product3 = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 800',
            'ProductCode' => 'SPA800',
            'IsActive' => true,
            'Family' => 'Laptops',
            'StockKeepingUnit' => 'Solar Panel 800'
        });

        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account', new Map<String, Object> {
            'Name' =>  'Dream House'
        });

        Asset newAsset1 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 600',
            'Product2Id' => product1.Id,
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today()
        });

        Asset newAsset2 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 700',
            'Product2Id' => product2.Id,
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today()
        });

        Asset newAsset3 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 800',
            'Product2Id' => product3.Id,
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today(),
            'SerialNumber' => 'SP8001'
        });

        Asset newAsset4 = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 800 C1',
            'Product2Id' => product3.Id,
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today(),
            'SerialNumber' => 'SP8001C1',
            'ParentId' =>  newAsset3.id
        });

        WorkType workType = (WorkType) SvmxTestDataFactory.insertSObject('WorkType', new Map<String,Object>{
            'Name'=> 'Solar Maintenance',
            'EstimatedDuration' => 1,
            'DurationType'=>'Hours',
            'ShouldAutoCreateSvcAppt' => true,
            'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1
        });

        SVMXA360__MaintenancePlanTemplate__c  maintenanceTemplate = (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject('SVMXA360__MaintenancePlanTemplate__c', new Map<String,Object>{
            'Name'=> 'Solar Panel Template',
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Months',
            'SVMXA360__GenerationHorizon__c' => 3,
            'SVMXA360__GenerationTimeframe__c' => 3,
            'SVMXA360__GenerationTimeframeType__c' => 'Months',
            'SVMXA360__IsActive__c' => true,
            'SVMXA360__MaintenancePlanDuration__c' => 3,
            'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Months',
            'SVMXA360__MaintenanceWindowEndDays__c' => 3,
            'SVMXA360__MaintenanceWindowStartDays__c' => 3,
            'SVMXA360__WorkTypeId__c' => workType.id,
            'SVMXA360__WorkOrderGenerationMethod__c' => 'WorkOrderPerAsset',
            'SVMXA360__SvcApptGenerationMethod__c' => '',
            'SVMXA360__DoesAutoGenerateWorkOrders__c' => true
        });

        SVMXA360__ApplicableProduct__c applicableProduct1 = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject('SVMXA360__ApplicableProduct__c', new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c'=> maintenanceTemplate.id,
            'SVMXA360__ProductId__c' => product1.Id,
            'SVMXA360__ProductFamily__c' => null ,
            'SVMXA360__WorkTypeId__c' => workType.id
        });

        Schema.Location locationVar = (Schema.Location) SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{
            'Name'=> 'Test location',
            'LocationType' => 'Van',
            'ExternalReference' => 'test123'
        });

        AssociatedLocation assoLocation = (AssociatedLocation) SvmxTestDataFactory.insertSObject('AssociatedLocation', new Map<String,Object>{
            'ParentRecordId'=> acc.id,
            'LocationId' => locationVar.id
        });
    }

    @IsTest
    static void testGetAllApplicableProducts(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAllApplicableProducts(mpTemplate.Id);
        System.assert(response.success == true);

        List<Mpln.ApplicableProduct> records = (List<Mpln.ApplicableProduct>) response.data;
        System.assert(records.size() == 1);

        Test.stopTest();
    }

    @IsTest
    static void testGetAllApplicableProductsWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAllApplicableProducts(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetApplicableProduct(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getApplicableProduct(applicableProductRecord.Id);
        System.assert(response.success == true);

        Mpln.ApplicableProduct record = (Mpln.ApplicableProduct) response.data;
        System.assert(record != null);

        Test.stopTest();
    }

    @IsTest
    static void testGetApplicableProductWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getApplicableProduct(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testSaveApplicableProducts(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        WorkType workTypeRecord = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];

        List<Mpln.ApplicableProduct> applicableProducts = new List<Mpln.ApplicableProduct>();

        Mpln.ApplicableProduct applicableProduct = new Mpln.ApplicableProduct();
        applicableProduct.maintenancePlanTemplateId = mpTemplate.id;
        applicableProduct.productFamily = 'Batteries';
        applicableProduct.workTypeId = workTypeRecord.id;
        applicableProducts.add(applicableProduct);

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveApplicableProducts(JSON.serialize(applicableProducts));
        System.assert(response.success == true);

        List<Mpln.ApplicableProduct> records = (List<Mpln.ApplicableProduct>) response.data;
        System.assert(records.size() == 1);

        Test.stopTest();
    }

    @IsTest
    static void testSaveApplicableProductsWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveApplicableProducts(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testSaveApplicableProductsWithInvalidJSON(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveApplicableProducts('abc');
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testDeleteApplicableProduct(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];

        Test.startTest();

        SVMXA360__ApplicableProduct__c applicableProduct = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ApplicableProduct__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => mpworkType.Id,
            'SVMXA360__ProductFamily__c' => 'Batteries'
        });
        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.deleteApplicableProduct(applicableProduct.Id);
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testDeleteApplicableProductWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.deleteApplicableProduct(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetProductList(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getProductList('Test');
        System.assert(response.success == true);

        List<Mpln.ProductInformation> records = (List<Mpln.ProductInformation>) response.data;
        System.assert(records.size() > 0);

        Test.stopTest();
    }

    @IsTest
    static void testGetProductListWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getProductList(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetAssetList(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAssetList('Solar', new List<String>{'Installed'}, null);
        System.assert(response.success == true);

        List<Mpln.AssetInformation> records = (List<Mpln.AssetInformation>) response.data;
        System.assert(records.size() > 0);

        Test.stopTest();
    }

    @IsTest
    static void testGetAssetListWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAssetList(null, null, null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetAllWorkRuleTemplates(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAllMaintenanceWorkRuleTemplates(mpTemplate.Id);
        System.assert(response.success == true);

        List<Mpln.WorkRuleTemplate> records = (List<Mpln.WorkRuleTemplate>) response.data;
        System.assert(records.size() == 1);

        Test.stopTest();
    }

    @IsTest
    static void testGetAllWorkRuleTemplatesWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAllMaintenanceWorkRuleTemplates(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testGetMaintenanceWorkRuleTemplateWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getAllMaintenanceWorkRuleTemplates(null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testdeleteMaintenanceWorkRuleTemplate(){

        SVMXA360__MaintenanceWorkRuleTemplate__c wrTemplate = [SELECT Id FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE Name = 'Test Workrule Template'];
        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.deleteMaintenanceWorkRuleTemplate(wrTemplate.Id);
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testdeleteMaintenanceWorkRuleTemplateWithNull(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.deleteMaintenanceWorkRuleTemplate(null);
        System.assert(response.success == false);

        Test.stopTest();
    }
    @IsTest
    static void testSaveMaintenanceWorkRuleTemplate(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];
        Test.startTest();
        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.name = 'Test WorkRule Name';
        workRuleTemplate.maintenancePlanTemplateId = mpTemplate.id;
        workRuleTemplate.workTypeId = mpworkType.id;
        workRuleTemplate.sortOrder = 1;
        workRuleTemplate.applicableProductId = applicableProductRecord.id;
        workRuleTemplates.add(workRuleTemplate);


        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testSaveMaintenanceWorkRuleTemplateWithUpdate(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];
        Test.startTest();
        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.name = 'Test WorkRule Name';
        workRuleTemplate.maintenancePlanTemplateId = mpTemplate.id;
        workRuleTemplate.workTypeId = mpworkType.id;
        workRuleTemplate.sortOrder = 1;
        workRuleTemplate.applicableProductId = applicableProductRecord.id;
        workRuleTemplates.add(workRuleTemplate);


        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == true);

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec = [SELECT Id FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE Name = 'Test WorkRule Name'];
        workRuleTemplates[0].id = workRuleTemplateRec.Id;
        workRuleTemplates[0].name = 'Test WorkRule Name updated';

        response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == true);

        Test.stopTest();
    }
    @IsTest
    static void testSaveMaintenanceWorkRuleTemplateWithInvalidRecPatternUpdate(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];
        Test.startTest();
        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.name = 'Test WorkRule Name';
        workRuleTemplate.maintenancePlanTemplateId = mpTemplate.id;
        workRuleTemplate.workTypeId = mpworkType.id;
        workRuleTemplate.sortOrder = 1;
        workRuleTemplate.applicableProductId = applicableProductRecord.id;
        workRuleTemplate.type = 'Calendar';
        workRuleTemplate.recurrencePattern = 'FREQ=YEARLY;INTERVAL=1;BYMONTH=13;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;UNTIL=20220501T000000Z';
        workRuleTemplates.add(workRuleTemplate);


        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == false);

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRec = [SELECT Id FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE Name = 'Test Workrule Template'];
        workRuleTemplates[0].id = workRuleTemplateRec.Id;
        workRuleTemplates[0].name = 'Test WorkRule Name updated';
        workRuleTemplates[0].recurrencePattern = 'FREQ=YEARLY;INTERVAL=1;BYMONTH=14;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;UNTIL=20220501T000000Z';

        try {
            workRuleTemplateRec.SVMXA360__RecurrencePattern__c = 'FREQ=YEARLY;INTERVAL=1;BYMONTH=14;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;UNTIL=20220501T000000Z';
            update workRuleTemplateRec;
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(System.Label.Error_Invalid_Recurrence_Pattern) != -1);
        }

        response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testSaveMaintenanceWorkRuleTemplatewithRec(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];
        Test.startTest();
        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.name = 'Test WorkRule Name';
        workRuleTemplate.maintenancePlanTemplateId = mpTemplate.id;
        workRuleTemplate.workTypeId = mpworkType.id;
        workRuleTemplate.sortOrder = 1;
        workRuleTemplate.applicableProductId = applicableProductRecord.id;
        workRuleTemplate.type = 'Calendar';
        workRuleTemplate.recurrencePattern = 'FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;';
        workRuleTemplates.add(workRuleTemplate);


        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == true);

        Test.stopTest();
    }
    @IsTest
    static void testSaveMaintenanceWorkRuleTemplatewithRecInvalid(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];
        Test.startTest();
        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.name = 'Test WorkRule Name';
        workRuleTemplate.maintenancePlanTemplateId = mpTemplate.id;
        workRuleTemplate.workTypeId = mpworkType.id;
        workRuleTemplate.sortOrder = 1;
        workRuleTemplate.applicableProductId = applicableProductRecord.id;
        workRuleTemplate.type = 'Calendar';
        workRuleTemplate.recurrencePattern = 'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=21;COUNT=0';
        workRuleTemplates.add(workRuleTemplate);


        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testSaveMaintenanceWorkRuleTemplatewithRFC(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        WorkType mpworkType = [SELECT Id FROM WorkType WHERE Name = 'TestWorkType'];
        RecordsetFilterCriteria recordsetFilterCriteria = [SELECT Id FROM RecordsetFilterCriteria WHERE Name = 'Test Filter Criteria'];

        Test.startTest();
        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.name = 'Test WorkRule Name 1';
        workRuleTemplate.maintenancePlanTemplateId = mpTemplate.id;
        workRuleTemplate.workTypeId = mpworkType.id;
        workRuleTemplate.sortOrder = 1;
        workRuleTemplate.applicableProductId = applicableProductRecord.id;
        workRuleTemplate.type = 'CriteriaValue';
        workRuleTemplate.recurrencePattern = null;
        workRuleTemplate.recordsetFilterCriteriaId = recordsetFilterCriteria.Id;
        workRuleTemplates.add(workRuleTemplate);


        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response != null);
        System.assert(response.success == true);

        Test.stopTest();
    }

    @IsTest
    static void testSaveMaintenanceWorkRuleTemplateWithNull(){

        Test.startTest();

        List<Mpln.WorkRuleTemplate> workRuleTemplates = new List<Mpln.WorkRuleTemplate>();
        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize(workRuleTemplates));
        System.assert(response.success == false);

        Test.stopTest();
    }

    @IsTest
    static void testSaveMaintenanceWorkRuleTemplateWithJSONException(){

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate(JSON.serialize('Test'));
        System.assert(response.success == false);

        Test.stopTest();
    }

    @isTest static void getMaintenaceAssets(){

        String templateId = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'Solar Panel Template'].Id;
        String accountId = [SELECT Id FROM Account where Name = 'Dream House'].Id;

        Test.startTest();

        Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
        maintenanceAssetRequest.templateId = templateId;
        maintenanceAssetRequest.sourceRecordId = accountId;
        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getMaintenanceAssets( JSON.serialize(maintenanceAssetRequest));

        System.assert(response !=null );
        List<Mpln.MaintenanceAssetInformation> records = (List<Mpln.MaintenanceAssetInformation>) response.data;

        System.assertEquals(records.size() > 0 , true);

        Test.stopTest();
    }
    @isTest static void getMaintenaceAssetsWithNullAruguments(){

        Test.startTest();

        Mpln.MaintenanceAssetRequest maintenanceAssetRequest = new Mpln.MaintenanceAssetRequest();
        Common.ServiceResponse response =  MPLN_MaintenancePlanTemplate_LS.getMaintenanceAssets( JSON.serialize(maintenanceAssetRequest) );

        System.assertEquals(response.success , false) ;

        Test.stopTest();

    }
    @isTest static void getMaintenaceAssetsInvalidRequestJSONException(){

        Test.startTest();

        Common.ServiceResponse response =  MPLN_MaintenancePlanTemplate_LS.getMaintenanceAssets( JSON.serialize('Test') );
        System.assertEquals(response.success , false, 'should throw JSON exception') ;

        Test.stopTest();

    }
    @isTest static void getLocationAccounts(){

        String locationId = [SELECT Id FROM Location WHERE Name = 'Test location'].Id;

        Test.startTest();

        Common.ServiceResponse response = MPLN_MaintenancePlanTemplate_LS.getLocationAccounts(locationId);

        System.assert(response !=null );


        Test.stopTest();
    }
    @isTest static void getLocationAccountsWithNullAruguments(){

        Test.startTest();

        Common.ServiceResponse response =  MPLN_MaintenancePlanTemplate_LS.getLocationAccounts(null);

        System.assertEquals(response.success , false) ;

        Test.stopTest();

    }
    @isTest static void testcalculateEndDate(){

        Test.startTest();

        Common.ServiceResponse response =  MPLN_MaintenancePlanTemplate_LS.calculateEndDate(System.Today(), 2, 'Months');

        System.assertEquals(response.success , true) ;

        Test.stopTest();

    }
    @isTest static void getcalculateEndDateWithNullAruguments(){

        Test.startTest();

        Common.ServiceResponse response =  MPLN_MaintenancePlanTemplate_LS.calculateEndDate(null, 2, 'Months');

        System.assertEquals(response.success , false) ;

        Test.stopTest();

    }
}