@isTest
public class MPLN_ProcessScheduler_UT {
    
       @testSetup static void mPlanTestDataSetup(){
        
        Account acc = new Account(Name = 'Test Account 123');
       	insert acc;
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord1 = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.createSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'SVMXA360__SM_MaintenancePlan__c',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MPLAN0001',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord2 = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.createSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Asset',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MPLAN0002',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        
        List<SVMXA360__CONF_ObjectMapping__c> objMappingList = new List<SVMXA360__CONF_ObjectMapping__c>();
        objMappingList.add(objectMappingRecord1);
        objMappingList.add(objectMappingRecord2);

        insert objMappingList; 

        List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetails = (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord1.Id}, 3);        
        
		objectMappingDetails[0].SVMXA360__TargetFieldAPIName__c = 'Description';
        objectMappingDetails[0].SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails[0].SVMXA360__Type__c = 'Value';
        objectMappingDetails[0].SVMXA360__Value__c = 'Created from MPlan';
        
		objectMappingDetails[1].SVMXA360__TargetFieldAPIName__c = 'Status';
        objectMappingDetails[1].SVMXA360__SourceFieldAPIName__c = 'SVMXA360__Status__c';
        objectMappingDetails[1].SVMXA360__Type__c = 'Field';
        
        objectMappingDetails[2].SVMXA360__TargetFieldAPIName__c = 'AccountId';
        objectMappingDetails[2].SVMXA360__SourceFieldAPIName__c = 'SVMXA360__Account__c';
        objectMappingDetails[2].SVMXA360__Type__c = 'Field';          
        
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetails1 = (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord2.Id}, 3);  

        objectMappingDetails1[0].SVMXA360__TargetFieldAPIName__c = 'SVMXA360__Resolution__c';
        objectMappingDetails1[0].SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails1[0].SVMXA360__Type__c = 'Value';
        objectMappingDetails1[0].SVMXA360__Value__c = 'System Reboot';
        
        objectMappingDetails1[1].SVMXA360__TargetFieldAPIName__c = 'City';
        objectMappingDetails1[1].SVMXA360__SourceFieldAPIName__c = 'City';
        objectMappingDetails1[1].SVMXA360__Type__c = 'Field';
        
        objectMappingDetails1[2].SVMXA360__TargetFieldAPIName__c = 'AssetId';
        objectMappingDetails1[2].SVMXA360__SourceFieldAPIName__c = 'Id';
        objectMappingDetails1[2].SVMXA360__Type__c = 'Field';    
        
        objectMappingDetails.addAll(objectMappingDetails1);
        
        insert objectMappingDetails;

        WorkType wTypeRec = (WorkType)SvmxTestDataFactory.insertSObject('WorkType', new Map<String,Object> {'EstimatedDuration' => 10, 'DurationType' => 'Hours', 'ShouldAutoCreateSvcAppt' => true, 'MinimumCrewSize' => 1,
            'RecommendedCrewSize' => 1});
        
        SVMXA360__SM_MaintenancePlanProcess__c mplanProcess = (SVMXA360__SM_MaintenancePlanProcess__c)SvmxTestDataFactory.insertSObject('SVMXA360__SM_MaintenancePlanProcess__c',
                                                                                   new Map<String,Object> {'SVMXA360__SM_AssignTo__c' => 'User',
                                                                                       'Name'=> 'Unit Test MProcess Schedule',
                                                                                       'SVMXA360__RecurrencePattern__c' => 'FREQ=DAILY;INTERVAL=2',
                                                                                       'SVMXA360__SM_DaysInAdvance__c' => 3, 
                                                                                       'SVMXA360__SM_RunAt__c' => '4',
                                                                                       'SVMXA360__SM_TimeZone__c' => 'GMT',
                                                                                       'SVMXA360__SM_SendFailureEmailTo__c' => 'sachin.s@servicemax.com',
                                                                                       'SVMXA360__SM_SendSuccessEmailTo__c' => 'sachin.s@servicemax.com',
                                                                                       'SVMXA360__SM_Standard__c' => true, 'SVMXA360__SM_MappingAssettoWOId__c' => objectMappingRecord2.Id,
                                                                                       'SVMXA360__SM_AssignToValue__c' => Userinfo.getUserId(),
                                                                                       'SVMXA360__SM_MappingMPlantoWOId__c' =>  objectMappingRecord1.Id});
                                                                                                           
                                                                                                           
        SVMXA360__SM_MaintenancePlan__c mplan = (SVMXA360__SM_MaintenancePlan__c)SvmxTestDataFactory.insertSObject('SVMXA360__SM_MaintenancePlan__c', new Map<String,Object>{
                                                                                                            'Name'=> 'Unit Test MPlan Positive Flow','SVMXA360__Account__c' => acc.Id, 'SVMXA360__Status__c' => 'Active',
                                                                                                            'SVMXA360__WorkType__c' => wTypeRec.Id,
                                                                                                            'SVMXA360__StartDate__c' => System.today() - 30, 'SVMXA360__EndDate__c' => System.today() + 30
                                                                                                           });                                                                                                            
        List<Asset> assetRecordList = (List<Asset>) SvmxTestDataFactory.insertSObjectList('Asset', new Map<String,Object>{'Status' => 'Installed', 'AccountId' => acc.Id}, 2);
        
        SVMXA360__SM_TA_TechnicalAttribute__c techAttrRec = (SVMXA360__SM_TA_TechnicalAttribute__c)SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_TechnicalAttribute__c',
                                                                                                 new Map<String,Object> {'SVMXA360__DataType__c' => 'Number'});
        
        SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTARec = (SVMXA360__SM_TA_AssetTechnicalAttribute__c)SvmxTestDataFactory.insertSObject('SVMXA360__SM_TA_AssetTechnicalAttribute__c',
                                                                                                                                              new Map<String,Object>{'SVMXA360__Value__c' => '20', 'SVMXA360__AttributeId__c' => techAttrRec.Id, 
                                                                                                                                             'SVMXA360__NumberValue__c' => 20, 'SVMXA360__PreviousValue__c' => '10.0',
                                                                                                                                             'SVMXA360__AssetId__c' => assetRecordList[0].Id});

        
        List<SVMXA360__SM_MaintenancePlanAsset__c> mplanAssets = (List<SVMXA360__SM_MaintenancePlanAsset__c>)SvmxTestDataFactory.createSObjectList('SVMXA360__SM_MaintenancePlanAsset__c',
                                                                                                                                               new Map<String,Object>{'SVMXA360__WorkType__c' => null, 
                                                                                                                                                   'SVMXA360__MaintenancePlan__c' => mplan.Id, 
                                                                                                                                                   'SVMXA360__Asset__c' =>  assetRecordList[0].Id}, 2);
        
        mplanAssets[1].SVMXA360__Asset__c = assetRecordList[1].Id;
        insert mplanAssets;
        
        List<SVMXA360__SM_MaintenanceWorkRule__c> workRuleList = (List<SVMXA360__SM_MaintenanceWorkRule__c>)SvmxTestDataFactory.createSObjectList('SVMXA360__SM_MaintenanceWorkRule__c', new Map<String,Object>{
            	'SVMXA360__SortOrder__c' => 1, 'SVMXA360__WorkType__c' => null, 'SVMXA360__MaintenancePlan__c' => mplan.Id, 'SVMXA360__MaintenancePlanAsset__c' => mplanAssets[0].Id, 
                'SVMXA360__AdvancedExpression__c' => '1 AND 2'}, 2);
        workRuleList[1].SVMXA360__MaintenancePlanAsset__c = mplanAssets[1].Id;
        insert workRuleList;
        
        List<SVMXA360__SM_Condition__c> conditionList = (List<SVMXA360__SM_Condition__c>)SvmxTestDataFactory.createSObjectList('SVMXA360__SM_Condition__c', new Map<String,Object>{
           'SVMXA360__ConditionType__c' => 'Time', 'SVMXA360__StartAt__c' => '2023-01-01', 'SVMXA360__StopAt__c' => '2024-01-01', 'SVMXA360__FieldAPIName__c' => 'Months', 'SVMXA360__Threshold__c' => 0, 
           'SVMXA360__Sequence__c' => 1, 'SVMXA360__Operator__c' => 'Every', 'SVMXA360__Operand__c' => '1', 'SVMXA360__MaintenanceWorkRule__c' => workRuleList[0].Id}, 
                                          4); 
        conditionList[1].SVMXA360__ConditionType__c = 'Frequency';
        conditionList[1].SVMXA360__StartAt__c = '0';
        conditionList[1].SVMXA360__StopAt__c = '100';
        conditionList[1].SVMXA360__Operand__c = '10';
        conditionList[1].SVMXA360__TechnicalAttribute__c = techAttrRec.Id;
        conditionList[1].SVMXA360__Sequence__c = 2;
        
        conditionList[2].SVMXA360__MaintenanceWorkRule__c = workRuleList[1].Id;
        
        conditionList[3].SVMXA360__ConditionType__c = 'Criteria';
        conditionList[3].SVMXA360__FieldAPIName__c = 'Status';
        conditionList[3].SVMXA360__Operand__c = 'Installed';
        conditionList[3].SVMXA360__Operator__c = 'eq';
        conditionList[3].SVMXA360__Sequence__c = 2;
        conditionList[3].SVMXA360__MaintenanceWorkRule__c = workRuleList[1].Id;
        insert conditionList;
        
    }
    
    public static testMethod void processScheduler_test	(){
        Test.startTest();
        MPLN_ProcessScheduler scheduler = new MPLN_ProcessScheduler();
        String jobId = System.schedule('testProcessScheduler', '0 0 0 ? * * *', scheduler);
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered); 
		Test.stopTest();
	}
}