@isTest
public class MPLN_ConditionBasedMPlan_LS_UT {
    @testSetup static void maintenancePlanTestData(){
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
        
        SVMXA360__ApplicableProduct__c applicableProduct = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ApplicableProduct__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__ProductFamily__c' => 'Turbines'
        });
        
        List<Product2> productList = new List<Product2>();

        Product2 productx1 = (Product2) SvmxTestDataFactory.createSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 700',
            'ProductCode' => 'SPA700',
            'IsActive' => true,
            'Family' => 'Turbines',
            'StockKeepingUnit' => 'Solar Panel 700'
        });
		productList.add(productx1);

        Product2 productx2 = (Product2) SvmxTestDataFactory.createSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 800',
            'ProductCode' => 'SPA800',
            'IsActive' => true,
            'Family' => 'Turbines',
            'StockKeepingUnit' => 'Solar Panel 800'
        });
		productList.add(productx2);
        insert productList;

        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account', new Map<String, Object> {
            'Name' =>  'Dream House'
        });
        
        Asset newAsset1 = (Asset) SvmxTestDataFactory.createSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 600',
            'Product2Id' => productx1.Id,
            'AccountId'=> acc.Id,
            'ParentId' => null,    
            'Status' => 'Installed',
            'InstallDate' => System.today()
        });
        insert newAsset1;

        Asset newAsset2 = (Asset) SvmxTestDataFactory.createSObject('Asset', new Map<String,Object>{
            'Name'=> 'Solar Panel 700',
            'Product2Id' => productx2.Id,
            'ParentId' => newAsset1.Id,    
            'AccountId'=>acc.Id,
            'Status' => 'Installed',
            'InstallDate' => System.today()
        });
		insert newAsset2;

        SVMXA360__ApplicableProduct__c applicableProductx1 = (SVMXA360__ApplicableProduct__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__ApplicableProduct__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__ProductId__c' => productList[0].Id,
            'SVMXA360__ProductFamily__c' => ''
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplate = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject('SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProductx1.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__SortOrder__c' => 1,
            'SVMXA360__Type__c'=>'CriteriaValue',
            'SVMXA360__RecurrencePattern__c' => 'FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;'
        });

        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplatex1 = (SVMXA360__MaintenanceWorkRuleTemplate__c) SvmxTestDataFactory.insertSObject('SVMXA360__MaintenanceWorkRuleTemplate__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id,
            'SVMXA360__ApplicableProductId__c' => applicableProductx1.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__SortOrder__c' => 2,
            'SVMXA360__Type__c'=>'CriteriaValue',
            'SVMXA360__RecurrencePattern__c' => 'FREQ=YEARLY;INTERVAL=1;BYMONTH=12;BYSETPOS=3;BYDAY=SU,MO,TU,WE,TH,FR,SA;'
        });

        SVMXA360__SM_Condition__c assetCondition = (SVMXA360__SM_Condition__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_Condition__c',
        new Map<String,Object>{
            'SVMXA360__MaintenanceWorkRuleTemplate__c' => workRuleTemplate.Id,
            'SVMXA360__ConditionType__c' => 'Frequency',
            'SVMXA360__FieldAPIName__c' => 'AccountId',
             'SVMXA360__Operand__c' => acc.Id
        });
        SVMXA360__SM_Condition__c assetConditionCriteria = (SVMXA360__SM_Condition__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_Condition__c',
        new Map<String,Object>{
            'SVMXA360__MaintenanceWorkRuleTemplate__c' => workRuleTemplate.Id,
            'SVMXA360__ConditionType__c' => 'Criteria',
            'SVMXA360__FieldAPIName__c' =>''
        });

        SVMXA360__SM_TA_Template__c attributeTemplate = (SVMXA360__SM_TA_Template__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_Template__c',
        new Map<String,Object>{
            'SVMXA360__Status__c' => 'Active',
            'SVMXA360__DeveloperName__c' => 'FrequencyTemplate',
            'Name' => 'Test Template'
        });

        SVMXA360__SM_TA_Category__c attributeCategory = (SVMXA360__SM_TA_Category__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_Category__c',
        new Map<String,Object>{
            'SVMXA360__DeveloperName__c' => 'FrequencyTemplateCategory',
            'Name' => 'Test Category'
        });

        SVMXA360__SM_TA_TechnicalAttribute__c attribute = (SVMXA360__SM_TA_TechnicalAttribute__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_TechnicalAttribute__c',
        new Map<String,Object>{
            'SVMXA360__DeveloperName__c' => 'FrequencyTemplateAttribute',
            'SVMXA360__DataType__c' => 'Text',
            'Name' => 'Test Attribute'
        });

        SVMXA360__SM_TA_TemplateItem__c templateItem = (SVMXA360__SM_TA_TemplateItem__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_TemplateItem__c',
        new Map<String,Object>{
            'SVMXA360__AttributeId__c' => attribute.Id,
            'SVMXA360__TemplateId__c' => attributeTemplate.Id,
            'SVMXA360__CategoryId__c' => attributeCategory.id,
            'Name' => 'Test TemplateItem',
            'SVMXA360__Status__c' => 'Active'
        });

        SVMXA360__SM_MaintenancePlan__c mplan = (SVMXA360__SM_MaintenancePlan__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__SM_MaintenancePlan__c',
        new Map<String,Object>{
            'Name' => 'TestMplan',
            'SVMXA360__MaintenancePlanTemplate__c' => mpTemplate.Id,
            'SVMXA360__Status__c' => 'Active',
            'SVMXA360__StartDate__c ' => System.now(),
            'SVMXA360__EndDate__c ' => System.now() + 1
        });
        
        SVMXA360__SM_MaintenancePlanAsset__c mplanAsset1 = (SVMXA360__SM_MaintenancePlanAsset__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_MaintenancePlanAsset__c',
        new Map<String,Object>{
            'Name' => 'TestMplan',
            'SVMXA360__MaintenancePlan__c' => mplan.Id,
            'SVMXA360__Asset__c' => newAsset1.Id
        }); 
        
        SVMXA360__SM_MaintenancePlanAsset__c mplanAsset2 = (SVMXA360__SM_MaintenancePlanAsset__c) SvmxTestDataFactory.insertSObject('SVMXA360__SM_MaintenancePlanAsset__c',
        new Map<String,Object>{
            'Name' => 'TestMplan',
            'SVMXA360__MaintenancePlan__c' => mplan.Id,
            'SVMXA360__Asset__c' => newAsset2.Id
        }); 
        
        SVMXA360__SM_MaintenanceWorkRule__c mWorkRule1 = (SVMXA360__SM_MaintenanceWorkRule__c ) SvmxTestDataFactory.insertSObject('SVMXA360__SM_MaintenanceWorkRule__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlan__c' => mplan.Id,
            'SVMXA360__MaintenancePlanAsset__c' => mplanAsset1.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__SortOrder__c' => 1
        });

        SVMXA360__SM_MaintenanceWorkRule__c mWorkRule2 = (SVMXA360__SM_MaintenanceWorkRule__c ) SvmxTestDataFactory.insertSObject('SVMXA360__SM_MaintenanceWorkRule__c',
        new Map<String,Object>{
            'SVMXA360__MaintenancePlan__c' => mplan.Id,
            'SVMXA360__MaintenancePlanAsset__c' => mplanAsset2.Id,
            'SVMXA360__WorkTypeId__c' => workTypeRecord.Id,
            'SVMXA360__SortOrder__c' => 1
        });
    }
    
    public static testMethod void testGetMatchingAssetsFromTemplate(){
        List<SVMXA360__MaintenancePlanTemplate__c> mPlanTemplateRec = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c LIMIT 1];
        List<Asset> assetList = [SELECT Id, Name FROM Asset WHERE ParentId = null];
        test.startTest();
        String mplanAssetRequest = '{"templateId":"' + mPlanTemplateRec[0].Id + '","sourceRecordId":"' + assetList[0].Id + '","includeChildAssets":true,"assetCriteria":"' + '' + '"}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getMatchingAssetsFromTemplate(mplanAssetRequest);
        List<Mpln.MaintenanceAssetInformation> mAssetInfoList = (List<Mpln.MaintenanceAssetInformation>)response.data;

		System.assertEquals(mAssetInfoList.size(), 2);
        test.stopTest();
    }
    
    public static testMethod void testGetMatchingAssetsFromTemplate_Invalid(){
		test.startTest();
        String mplanAssetRequest = '{"templateId":null,"sourceRecordId":null,"includeChildAssets":true,"assetCriteria":"' + '' + '"}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getMatchingAssetsFromTemplate(mplanAssetRequest);
       	System.assertEquals(response.success, false);
		test.stopTest();
    }

    public static testMethod void testgetWorkRulesFromTemplate() {
        test.startTest();
        List<SVMXA360__MaintenancePlanTemplate__c> mPlanTemplateRec = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c LIMIT 1];
        List<SVMXA360__ApplicableProduct__c> applicableProductRecList = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__ProductId__c!=null];

        String mplanWorkRuleRequest = '{"templateId":"' + mPlanTemplateRec[0].Id + '","productIds":["' + applicableProductRecList[0].SVMXA360__ProductId__c + '"]}';
        
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getWorkRulesFromTemplate(mplanWorkRuleRequest);
        List<Mpln.ProductWorkRuleInfo> productWorkRuleInfoList = (List<Mpln.ProductWorkRuleInfo>)response.data;
        System.assertEquals(productWorkRuleInfoList.size(), 1);
        test.stopTest();
    }

    public static testMethod void testgetWorkRulesFromTemplate_Invalid() {
        test.startTest();
        String mplanAssetRequest = '{"templateId":null,"productIds":null}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getWorkRulesFromTemplate(mplanAssetRequest);
       	System.assertEquals(response.success, false);
		test.stopTest();
    }

    public static testMethod void testGetAttributeTemplates() {
        test.startTest();
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAttributeTemplates();
        List<Mpln.MplnTemplateRecord> templateList = (List<Mpln.MplnTemplateRecord>) response.data;
        System.assertEquals(templateList.size(), 1);
        test.stopTest();    
    }

    public static testMethod void testGetAttributeCategories() {
        test.startTest();
        SVMXA360__SM_TA_Template__c templateRecord = [SELECT id FROM SVMXA360__SM_TA_Template__c WHERE SVMXA360__Status__c ='Active' LIMIT 1];
        String requestJson = '{"id" :"' + templateRecord.Id + '"}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAttributeCategories(requestJson);
        List<Mpln.MplnTemplateRecord> categoryList = (List<Mpln.MplnTemplateRecord>)response.data;
        System.assertEquals(categoryList.size(), 1);
        test.stopTest();    
    }

    public static testMethod void testGetAttributes() {
        test.startTest();
        SVMXA360__SM_TA_Category__c categoryRecord = [SELECT id FROM SVMXA360__SM_TA_Category__c LIMIT 1];
        String requestJson = '{"id" :"' + categoryRecord.Id + '"}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAttributes(requestJson);
        List<Mpln.TechnicalAttributeInfo> attributeList = (List<Mpln.TechnicalAttributeInfo>)response.data;
        System.assertEquals(attributeList.size(), 1);
        test.stopTest();    
    }

    public static testMethod void testGetAttributeCategories_Invalid() {
        test.startTest();
        String requestJson = '{"id":null}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAttributeCategories(requestJson);
       	System.assertEquals(response.success, false);
		test.stopTest();
    }

    public static testMethod void testGetAttributes_Invalid() {
        test.startTest();
        String requestJson = '{"id":null}';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAttributes(requestJson);
       	System.assertEquals(response.success, false);
		test.stopTest();
    }

    public static testMethod void testgetWorkRulesFromMaintenanceTemplate() {
        test.startTest();
        List<SVMXA360__MaintenancePlanTemplate__c> mPlanTemplateRec = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c LIMIT 1];
        List<SVMXA360__ApplicableProduct__c> applicableProductRecList = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__ProductId__c!=null];

        String mplanWorkRuleRequest = '{"templateId":"' + mPlanTemplateRec[0].Id+'"}';
        
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getWorkRulesFromMaintenanceTemplate(mplanWorkRuleRequest);
        List<Mpln.ProductWorkRuleInfo> productWorkRuleInfoList = (List<Mpln.ProductWorkRuleInfo>)response.data;
        System.assertEquals(response.success, true);
        test.stopTest();
    }
    
    public static testMethod void testgetWorkRulesFromMaintenanceTemplate_invalid() {
        test.startTest();
        List<SVMXA360__MaintenancePlanTemplate__c> mPlanTemplateRec = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c LIMIT 1];
        List<SVMXA360__ApplicableProduct__c> applicableProductRecList = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__ProductId__c!=null];

        String mplanWorkRuleRequest = '{"templateId":null}';
        
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getWorkRulesFromMaintenanceTemplate(mplanWorkRuleRequest);
        System.assertEquals(response.success, false);
        test.stopTest();
    }

    public static testMethod void testgetRecordTypeDetails () {
        test.startTest();
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getRecordTypeDetails('SVMXA360__MaintenancePlanTemplate__c');
        List<Common.RecordType> recordTypeList = (List<Common.RecordType>) response.data;
        System.assertEquals(recordTypeList.size() > 0, true);
		test.stopTest();    
    }

    public static testMethod void testgetRecordTypeDetails_invalid () {
        test.startTest();
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getRecordTypeDetails('');
        List<Common.RecordType> recordTypeList = (List<Common.RecordType>) response.data;
        System.assertEquals(response.success, false);
		test.stopTest();    
    }
    
    public static testMethod void testGetMaintenanceAssetsWorkRules(){
        List<SVMXA360__SM_MaintenancePlan__c> mPlanList = [SELECT Id FROM SVMXA360__SM_MaintenancePlan__c WHERE Name = 'TestMplan']; 
    	System.assert(mPlanList.size() > 0);
        test.startTest();
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getMaintenanceAssets(mPlanList[0].Id);
        List<Mpln.MaintenanceAssetInformation> mAssetInfoList = (List<Mpln.MaintenanceAssetInformation>) response.data;
    	System.assertEquals(mAssetInfoList.size(), 2);
        List<String> mAssetIds = new List<String>();
        for (Mpln.MaintenanceAssetInformation mAssetInfo : mAssetInfoList) {
			mAssetIds.add(mAssetInfo.id);
        }
        
        response = MPLN_ConditionBasedMPlan_LS.getWorkRulesFromPlan(mAssetIds);
		List<Mpln.ProductWorkRuleInfo> productWorkRuleInfoList = (List<Mpln.ProductWorkRuleInfo>) response.data;
    	System.assertEquals(productWorkRuleInfoList.size(), 2);
        test.stopTest();
    }
    
    public static testMethod void testSaveMaintenancePlanInfo(){
    	List<SVMXA360__SM_MaintenancePlan__c> mPlanList = [SELECT Id, Name, SVMXA360__MaintenancePlanTemplate__c, SVMXA360__Status__c, SVMXA360__StartDate__c,   
                                                           SVMXA360__EndDate__c FROM SVMXA360__SM_MaintenancePlan__c WHERE Name = 'TestMplan'];
    	System.assert(mPlanList.size() > 0);
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getMaintenanceAssets(mPlanList[0].Id);
        List<Mpln.MaintenanceAssetInformation> mAssetInfoList = (List<Mpln.MaintenanceAssetInformation>) response.data;
    	System.assertEquals(mAssetInfoList.size(), 2);
        String maintenanceAssetReqJSON = JSON.serialize(mAssetInfoList); 

        test.startTest();

        String mplanId = new MPLN_ConditionBasedMPlanManager().saveMaintenancePlan(mPlanList[0], maintenanceAssetReqJSON);
        System.assertEquals(mplanId, mPlanList[0].Id);
		test.stopTest();
    }
    
    public static testMethod void testGetMaintenanceAssets_Invalid(){
    	test.startTest();
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getMaintenanceAssets(null);
        System.assertEquals(response.success, false);
        test.stopTest();
	}

    public static testMethod void saveWorkRuleTemplateTest() {
        test.startTest();
        Asset assetRec = [select id,Product2Id from Asset limit 1];
        SVMXA360__MaintenancePlanTemplate__c templateRec = [select id from SVMXA360__MaintenancePlanTemplate__c limit 1];
        SVMXA360__ApplicableProduct__c applicableProduct = [select id from SVMXA360__ApplicableProduct__c limit 1];
        SVMXA360__MaintenanceWorkRuleTemplate__c workRuleRec = [select id from SVMXA360__MaintenanceWorkRuleTemplate__c limit 1];
        string request = '[{"mplnTemplateId":"'+templateRec.id+'","assetId":"'+assetRec.Id+'","assetName":"Test Product","productId":"'+assetRec.Product2Id+'","applicableProduct":"'+applicableProduct.Id+'","workRules":[{"workRuleId":"'+workRuleRec.Id+'","applicableProduct":"'+applicableProduct.Id+'","sortOrder":"2","advancedExpression":"1 and 2","attributeTemplate":"a1I05000002AP2lEAG","detail":[{"conditionType":"Frequency","frequency":{"operator":"Every"}},{"conditionType":"Criteria","criteria":{"operator":"Every"}}]}]}]';
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.saveWorkRuleTemplate(request);
        System.assertEquals(response.success, false);
        test.stopTest();
    }
    public static testMethod void saveWorkRuleTemplateTest_Invalid() {
    	test.startTest();
        Asset assetRec = [select id,Product2Id from Asset limit 1];
        SVMXA360__MaintenancePlanTemplate__c templateRec = [select id from SVMXA360__MaintenancePlanTemplate__c limit 1];
        SVMXA360__ApplicableProduct__c applicableProduct = [select id from SVMXA360__ApplicableProduct__c limit 1];
        String request = '[{"mplnTemplateId":"'+templateRec.id+'","assetId":"'+assetRec.Id+'","assetName":"Test Product","productId":"'+assetRec.Product2Id+'","workTypeId":"workTypeId","workTypeName":"workTypeName","applicableProduct":"'+applicableProduct.Id+'","workRules":["workRuleTitle":"Testing","sortOrder":"2","detail":[{"conditionType":"Frequency","frequency":{"attributeCategory":"a1E05000000XqTFEA0","attribute":"a1F05000000K8DIEA0","attributeName":"Testattrbute","attributeDatatype":"Text","attributeValue":"21","operator":"Every","threshold":""},"conditionDefination":"Every Testattrbute 21,based on% Threshold","expandByDefault":false,"enableFetch":false,"expandedRows":["Testing"]},{"conditionType":"Time","recurrenceRule":"FREQ=MONTHLY;INTERVAL=21;COUNT=1","conditionDefination":"Every 21 Months  ending after 1 occurences","expandByDefault":false,"enableFetch":false,"expandedRows":["Testing"]},{"conditionType":"Criteria","criteria":{"attributeCategory":"a1E05000000XqTFEA0","attribute":"a1F05000000K8DIEA0","attributeName":"Testattrbute","attributeDatatype":"Text","attributeValue":"34","operator":"Equals","threshold":"4"},"conditionDefination":"Equals Testattrbute 34,based on4% Threshold","expandByDefault":false,"enableFetch":false,"expandedRows":["Testing"]}],"expandByDefault":false,"enableFetch":false,"id":"Testing"}],"showHeader":true}]';
        
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.saveWorkRuleTemplate(request);
        System.assertEquals(response.success, false);
        test.stopTest();	    
    }
    public static testMethod void deleteWorkRulesTest() {
    	SVMXA360__MaintenanceWorkRuleTemplate__c workRule = [select id from SVMXA360__MaintenanceWorkRuleTemplate__c limit 1];
        List<String> workRuleIds = new List<String>{workRule.id};
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.deleteWorkRules(workRuleIds);
        System.assertEquals(response.success, true);
    }
    public static testMethod void deleteWorkRulesTest_Invalid() {
    	SVMXA360__MaintenanceWorkRuleTemplate__c workRule = [select id from SVMXA360__MaintenanceWorkRuleTemplate__c limit 1];
        List<String> workRuleIds = new List<String>();
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.deleteWorkRules(workRuleIds);
        System.assertEquals(response.success, true);
    }
    public static testMethod void getAssetFieldsTest() {
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAssetFields('Asset');
        System.assertEquals(response.success, true);
    }
    public static testMethod void getAssetFieldsTest_Invalid() {
        Common.ServiceResponse response = MPLN_ConditionBasedMPlan_LS.getAssetFields('Asset1');
        System.assertEquals(response.success, false);
    }

    public static testMethod void testDeleteMaintenancePlanInfo(){
    	List<SVMXA360__SM_MaintenancePlan__c> mPlanList = [SELECT Id, Name, SVMXA360__MaintenancePlanTemplate__c, SVMXA360__Status__c, SVMXA360__StartDate__c,   
                                                           SVMXA360__EndDate__c FROM SVMXA360__SM_MaintenancePlan__c WHERE Name = 'TestMplan'];
    	System.assert(mPlanList.size() > 0);
        test.startTest();
		delete mPlanList; 
        test.stopTest();
    	mPlanList = [SELECT Id, Name, SVMXA360__MaintenancePlanTemplate__c, SVMXA360__Status__c, SVMXA360__StartDate__c,   
                                                           SVMXA360__EndDate__c FROM SVMXA360__SM_MaintenancePlan__c WHERE Name = 'TestMplan'];
        System.assertEquals(mPlanList.size(), 0);

    }
}