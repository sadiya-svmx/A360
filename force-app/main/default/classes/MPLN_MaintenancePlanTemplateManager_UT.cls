@IsTest
public class MPLN_MaintenancePlanTemplateManager_UT {

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

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplate2 = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProduct.Id,
            'Name' => 'Test Workrule Template 2',
            'SVMXA360__SortOrder__c' => 2,
            'SVMXA360__Type__c' => 'CriteriaValue',
            'SVMXA360__RecordsetFilterCriteriaId__c' => recordsetFilterCriteria.Id,
            'SVMXA360__RecurrencePattern__c' => ''
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

        /*SVMXA360__ApplicableProduct__c applicableProduct2 = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject('SVMXA360__ApplicableProduct__c', new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c'=> maintenanceTemplate.id,
            'SVMXA360__ProductFamily__c' => 'Laptops',
             'SVMXA360__ProductId__c' => null ,
            'SVMXA360__WorkTypeId__c' => workType.id
        });*/
    }

    @IsTest
    static void testGetAllApplicableProducts(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        Test.startTest();

        List<Mpln.ApplicableProduct> response = MPLN_MaintenancePlanTemplateManager.getInstance().getAllApplicableProducts(mpTemplate.Id);
        System.assert(response.size() == 1);

        Test.stopTest();
    }

    @IsTest
    static void testGetAllApplicableProductsWithNull(){

        Test.startTest();

        try{
            List<Mpln.ApplicableProduct> response = MPLN_MaintenancePlanTemplateManager.getInstance().getAllApplicableProducts(null);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetApplicableProduct(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];

        Test.startTest();

        Mpln.ApplicableProduct response = MPLN_MaintenancePlanTemplateManager.getInstance().getApplicableProduct(applicableProductRecord.Id);
        System.assert(response != null);
        System.assert(response.maintenancePlanTemplateId == mpTemplate.id);

        Test.stopTest();
    }

    @IsTest
    static void testGetApplicableProductWithInvalidId(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];
        delete applicableProductRecord;
        Test.startTest();

        try{
            Mpln.ApplicableProduct response = MPLN_MaintenancePlanTemplateManager.getInstance().getApplicableProduct(applicableProductRecord.id);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetApplicableProductWithNull(){

        Test.startTest();

        try{
            Mpln.ApplicableProduct response = MPLN_MaintenancePlanTemplateManager.getInstance().getApplicableProduct(null);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

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

        List<Mpln.ApplicableProduct> response = MPLN_MaintenancePlanTemplateManager.getInstance().saveApplicableProducts(applicableProducts);
        System.assert(response.size() == 1);
        System.assert(response[0].id != null);

        Test.stopTest();
    }

    @IsTest
    static void testSaveApplicableProductsWithUpdate(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];

        List<Mpln.ApplicableProduct> applicableProducts = new List<Mpln.ApplicableProduct>();

        Mpln.ApplicableProduct applicableProduct = new Mpln.ApplicableProduct();
        applicableProduct.id = applicableProductRecord.id;
        applicableProduct.maintenancePlanTemplateId = mpTemplate.id;
        applicableProduct.productFamily = 'Batteries';
        applicableProducts.add(applicableProduct);

        Test.startTest();

        List<Mpln.ApplicableProduct> response = MPLN_MaintenancePlanTemplateManager.getInstance().saveApplicableProducts(applicableProducts);
        System.assert(response.size() == 1);
        System.assert(response[0].id != null);

        Test.stopTest();
    }

    @IsTest
    static void testSaveApplicableProductsWithNull(){

        Test.startTest();

        try{
            List<Mpln.ApplicableProduct> response = MPLN_MaintenancePlanTemplateManager.getInstance().saveApplicableProducts(null);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

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

        MPLN_MaintenancePlanTemplateManager.getInstance().deleteApplicableProduct(applicableProduct.id);

        try{
            Mpln.ApplicableProduct response = MPLN_MaintenancePlanTemplateManager.getInstance().getApplicableProduct(applicableProduct.id);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testDeleteApplicableProductWithNull(){

        Test.startTest();

        try{
            MPLN_MaintenancePlanTemplateManager.getInstance().deleteApplicableProduct(null);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testDeleteApplicableProductWith_WRTemplate(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        SVMXA360__ApplicableProduct__c applicableProductRecord = [SELECT Id FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: mpTemplate.id];

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRecord = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__ApplicableProductId__c' => applicableProductRecord.id,
            'SVMXA360__RecurrencePattern__c' => 'FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;'
        });

        Test.startTest();

        MPLN_MaintenancePlanTemplateManager.getInstance().deleteApplicableProduct(applicableProductRecord.id);

        try{
            Mpln.ApplicableProduct response = MPLN_MaintenancePlanTemplateManager.getInstance().getApplicableProduct(applicableProductRecord.id);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetProductList(){

        Test.startTest();

        List<Mpln.ProductInformation> response = MPLN_MaintenancePlanTemplateManager.getInstance().getProductList('Test');
        System.assert(response != null);
        System.assert(response.size() > 0);

        Test.stopTest();
    }

    @IsTest
    static void testGetProductListWithNull(){

        Test.startTest();

        try{
            List<Mpln.ProductInformation> response = MPLN_MaintenancePlanTemplateManager.getInstance().getProductList(null);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetAllWorkRuleTemplates(){

        SVMXA360__MaintenancePlanTemplate__c mpTemplate = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'TestTemplate'];
        Test.startTest();

        List<Mpln.WorkRuleTemplate> response = MPLN_MaintenancePlanTemplateManager.getInstance().getAllMaintenanceWorkRuleTemplates(mpTemplate.Id);
        System.assert(response.size() == 2);

        Test.stopTest();
    }

    @IsTest
    static void testGetAllWorkRuleTemplatesWithNull(){

        Test.startTest();

        try{
            List<Mpln.WorkRuleTemplate> response = MPLN_MaintenancePlanTemplateManager.getInstance().getAllMaintenanceWorkRuleTemplates(null);
        } catch (Exception e) {
            System.assert(e.getMessage() == ErrorMessage.INVALID_ARGUMENT + ' maintenancePlanTemplateId= ' + null);
        }

        Test.stopTest();
    }

    @IsTest
    static void testdeleteMaintenanceWorkRuleTemplate(){

        SVMXA360__MaintenanceWorkRuleTemplate__c wrTemplate = [SELECT Id FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE Name = 'Test Workrule Template'];
        Test.startTest();

        try{
            MPLN_MaintenancePlanTemplateManager.getInstance().deleteMaintenanceWorkRuleTemplate(wrTemplate.Id);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) == -1);
        }

        Test.stopTest();
    }

    @IsTest
    static void testdeleteMaintenanceWorkRuleTemplateWithNull(){

        Test.startTest();

        try{
            MPLN_MaintenancePlanTemplateManager.getInstance().deleteMaintenanceWorkRuleTemplate(null);
        } catch (Exception e) {
            System.assert(e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT) != -1);
        }

        Test.stopTest();
    }
}