@isTest
public class CreateConditionalMPlanApexAction_UT {
    
    @testSetup public static void setup() {
    	Product2 productRecord = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String, Object> {
            'Name' =>  'Solar Panel 60000',
            'ProductCode' => 'SPA600',
            'IsActive' => true,
            'Family' => 'Mobile',
            'StockKeepingUnit' => 'Solar Panel 60000'  
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
        
        
        WorkType workTypeRecord = (WorkType) SvmxTestDataFactory.insertSObject( 'WorkType', 
        new Map<String,Object>{
            'Name' => 'WorkType_1',
            'ShouldAutoCreateSvcAppt' => true,
            'EstimatedDuration' => 2.00,
            'DurationType' => 'Hours',
            'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1
        });

    }
    
	@IsTest static void testCreateMaintenancePlan(){
        
    	SVMXA360__SM_MaintenancePlan__c mplanRec = new SVMXA360__SM_MaintenancePlan__c();
        mplanRec.Name = 'A360 Test Maintenance Plan';
        mplanRec.SVMXA360__StartDate__c = System.today();
        mplanRec.SVMXA360__EndDate__c = System.today() + 365;
        mplanRec.SVMXA360__Status__c = 'Active';
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttrRec = (SVMXA360__SM_TA_TechnicalAttribute__c)SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_TechnicalAttribute__c',
                                                                                                 new Map<String,Object> {'SVMXA360__DataType__c' => 'Number'});
        
        List<Mpln.ConditionTypeInfo> conditionInfoList = new List<Mpln.ConditionTypeInfo>();

        List<WorkType> workTypeList = [SELECT Id FROM WorkType];
        System.assert(workTypeList.size() > 0);
        
        Mpln.ConditionTypeInfo conditionInfo1 = new Mpln.ConditionTypeInfo();
        conditionInfo1.conditionType = 'Time';
		conditionInfo1.sequence = 1;
        conditionInfo1.recurrenceRule = 'FREQ=DAILY;INTERVAL=1';
        conditionInfoList.add(conditionInfo1);

        Mpln.ConditionTypeInfo conditionInfo2 = new Mpln.ConditionTypeInfo();
        conditionInfo2.conditionType = 'Frequency';
		conditionInfo2.sequence = 2;
        
        Mpln.FrequencyInfo frequencyInfo = new Mpln.FrequencyInfo();
        frequencyInfo.operator = 'eq';
        frequencyInfo.attributeValue = techAttrRec.Id;
            
        conditionInfo2.frequency = frequencyInfo;
        conditionInfoList.add(conditionInfo2);
        
        Mpln.ConditionTypeInfo conditionInfo3 = new Mpln.ConditionTypeInfo();
        conditionInfo3.conditionType = 'Criteria';
       	conditionInfo3.sequence = 3;
		
        Mpln.CriteriaInfo criteriaInfo = new Mpln.CriteriaInfo();
        criteriaInfo.operator = 'eq';
        criteriaInfo.attributeValue = techAttrRec.Id;
        
        conditionInfo3.criteria = criteriaInfo;
        conditionInfoList.add(conditionInfo3);

        Mpln.WorkRuleInformation workRuleInfo = new Mpln.WorkRuleInformation();
        workRuleInfo.workRuleTitle = 'Test Work Rule';
        workRuleInfo.sortOrder = 1;
        workRuleInfo.workTypeId = workTypeList[0].Id;
        workRuleInfo.detail = conditionInfoList;
            
        List<Asset> assetList = [SELECT Id FROM Asset];
        System.assert(assetList.size() > 0);


		Mpln.MaintenanceAssetInformation mAssetInfo = new Mpln.MaintenanceAssetInformation();
        mAssetInfo.assetId = assetList[0].Id;
        mAssetInfo.workTypeId = workTypeList[0].Id;
        mAssetInfo.workRules = new List<Mpln.WorkRuleInformation> {workRuleInfo};
          
        String maintenanceAssetReqJSON = JSON.serialize(new List<Mpln.MaintenanceAssetInformation>{mAssetInfo}); 
        
        Test.startTest();
        CreateConditionalMPlanApexAction.MaintenancePlanInfo mPlanInfo = new CreateConditionalMPlanApexAction.MaintenancePlanInfo();
        mPlanInfo.conditionalMPlanRecord = mplanRec;
        mPlanInfo.maintenanceAssetsJSON = maintenanceAssetReqJSON;
        List<String> mplanIds = CreateConditionalMPlanApexAction.createMaintenancePlan(new List<CreateConditionalMPlanApexAction.MaintenancePlanInfo>{mPlanInfo});
		Test.stopTest();
        
        System.assertEquals(mplanIds.size(), 1);
    }

    @IsTest static void testCreateMaintenancePlan_InvalidRequest(){
    	Test.startTest();
        try {
        	List<String> mplanIds = CreateConditionalMPlanApexAction.createMaintenancePlan(new List<CreateConditionalMPlanApexAction.MaintenancePlanInfo>());
        }
        catch (SvmxSystem.SvmxNestedException e) {
            System.assertEquals(ErrorMessage.MISSING_REQUIRED_PARAMETER, e.getMessage());
        }
        Test.stopTest();
    }

}