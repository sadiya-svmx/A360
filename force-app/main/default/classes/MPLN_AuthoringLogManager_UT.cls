@isTest
public with sharing class MPLN_AuthoringLogManager_UT {

    @testSetup public static void setup() {
        Account account = new Account(Name = 'Test_Account123');
        insert account;

        ServiceContract seviceContract = (ServiceContract) SvmxTestDataFactory.insertSObject('ServiceContract', new Map<String, Object> {
            'Name' =>  'ServiceContract1',
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(5),
            'AccountId' => account.Id
        });

        SVMXA360__MPLNAuthoringLog__c parentLog = (SVMXA360__MPLNAuthoringLog__c) SvmxTestDataFactory.insertSObject('SVMXA360__MPLNAuthoringLog__c', new Map<String, Object> {
            'SVMXA360__LogType__c' =>  'Master',
            'SVMXA360__ServiceContractId__c' => seviceContract.Id,
            'SVMXA360__Status__c' => 'Success',
            'SVMXA360__TotalNumberOfBatches__c' => 2,
            'SVMXA360__UserId__c' => UserInfo.getUserId(),
            'SVMXA360__TotalBatchesCompleted__c' => 0,
            'SVMXA360__OperationType__c' => 'Create',
            'SVMXA360__Message__c' => null
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
            'SVMXA360__MaintenanceWindowStartDays__c' => 3
        });
    }
    
    @IsTest
    static void testCreateSuccessLog(){
        Map<String, Schema.SObjectField> mPlanFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenancePlan');
        ServiceContract serviceContract = [SELECT Id FROM ServiceContract WHERE Name =  'ServiceContract1'];
        SVMXA360__MaintenancePlanTemplate__c templateRecord = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'];
        SVMXA360__MPLNAuthoringLog__c parentLogRecord = [SELECT Id FROM SVMXA360__MPLNAuthoringLog__c WHERE SVMXA360__ServiceContractId__c =: serviceContract.Id AND SVMXA360__LogType__c =  'Master'];

        SVMXA360__ApplicationEventBus__e applicationEventBus = new SVMXA360__ApplicationEventBus__e();
        applicationEventBus.SVMXA360__Payload__c = templateRecord.Id + ';' + parentLogRecord.Id;
        applicationEventBus.SVMXA360__SourceRecordId__c = serviceContract.Id;
        applicationEventBus.SVMXA360__UserId__c = UserInfo.getUserId();

        MaintenancePlan maintenancePlan = new MaintenancePlan();
        maintenancePlan.StartDate = Date.today();
        maintenancePlan.NextSuggestedMaintenanceDate = Date.today();
        if (!mPlanFieldMap.isEmpty() && mPlanFieldMap.containsKey('Frequency') && mPlanFieldMap.containsKey('FrequencyType')) {
            maintenancePlan.put('Frequency', 1);
            maintenancePlan.put('FrequencyType', 'Days');
        }
        maintenancePlan.GenerationTimeframe = 1;
        maintenancePlan.GenerationTimeframeType = 'Days';
        insert maintenancePlan;

        MPLN_AuthoringLogManager.getInstance().createSuccessLog(applicationEventBus, maintenancePlan);

        System.assert([SELECT Id FROM SVMXA360__MPLNAuthoringLog__c WHERE SVMXA360__LogType__c = 'Detail'].size() > 0);
    }

    @IsTest
    static void testcreateFailureLog(){
        ServiceContract serviceContract = [SELECT Id FROM ServiceContract WHERE Name =  'ServiceContract1'];
        SVMXA360__MaintenancePlanTemplate__c templateRecord = [SELECT Id FROM SVMXA360__MaintenancePlanTemplate__c WHERE Name = 'MaintenancePlanTemplate_1'];
        SVMXA360__MPLNAuthoringLog__c parentLogRecord = [SELECT Id FROM SVMXA360__MPLNAuthoringLog__c WHERE SVMXA360__ServiceContractId__c =: serviceContract.Id AND SVMXA360__LogType__c =  'Master'];

        SVMXA360__ApplicationEventBus__e applicationEventBus = new SVMXA360__ApplicationEventBus__e();
        applicationEventBus.SVMXA360__Payload__c = templateRecord.Id + ';' + parentLogRecord.Id;
        applicationEventBus.SVMXA360__SourceRecordId__c = serviceContract.Id;
        applicationEventBus.SVMXA360__UserId__c = UserInfo.getUserId();

        MPLN_AuthoringLogManager.getInstance().createFailureLog(applicationEventBus, 'Test_Error_Message');

        System.assert([SELECT Id FROM SVMXA360__MPLNAuthoringLog__c WHERE SVMXA360__LogType__c = 'Detail'].size() > 0);
    }
}