@IsTest
public class SCON_ServiceContractPlan_LS_UT {
    
    @testSetup public static void setup() {
        SCON_ServiceContractPlanManager_UT.setup();
    }
    
    testmethod static void testGetContractLineItemPlans() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getContractLineItemPlans(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetContractLineItemPlans_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getContractLineItemPlans(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetEntitledServicePlans() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getEntitledServicePlans(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetEntitledServicePlans_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getEntitledServicePlans(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetContractPriceLineItemPlans() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetContractPriceLineItemPlans_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getContractPriceLineItemPlans(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetOfferedMPTs() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getOfferedMPTs(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetOfferedMPTs_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getOfferedMPTs(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetServiceContractPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getServiceContractPlan(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetServiceContractPlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getServiceContractPlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testDeleteContractLineItemPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteContractLineItemPlan(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testDeleteContractLineItemPlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteContractLineItemPlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testDeleteEntitledServicePlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteEntitledServicePlan(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testDeleteEntitledServicePlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteEntitledServicePlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testDeleteContractPriceLinePlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteContractPriceLinePlan(serviceContractPlanRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testDeleteContractPriceLinePlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteContractPriceLinePlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testDeleteOfferedMPT() {
        
        final SVMXA360__OfferedMaintenancePlanTemplate__c offeredMPT = [SELECT Id FROM SVMXA360__OfferedMaintenancePlanTemplate__c];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteOfferedMPT(offeredMPT.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testDeleteOfferedMPT_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteOfferedMPT(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testSaveContractLineItemPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        final String requestJson = JSON.serialize(contractLineItemPlanList); 
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveContractLineItemPlan(requestJson);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testSaveContractLineItemPlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveContractLineItemPlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testSaveContractLineItemPlan_InvalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveContractLineItemPlan('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    testmethod static void testSaveEntitledServicePlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        final String requestJson = JSON.serialize(entitledServicePlanList.get(0)); 
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveEntitledServicePlan(requestJson);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testSaveEntitledServicePlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveEntitledServicePlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testSaveEntitledServicePlan_InvalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveEntitledServicePlan('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    testmethod static void testSaveContractPriceLineItemPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        final String requestJson = JSON.serialize(contractPriceLineItemPlanList.get(0)); 
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveContractPriceLineItemPlan(requestJson);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testSaveContractPriceLineItemPlan_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveContractPriceLineItemPlan(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testSaveContractPriceLineItemPlan_InvalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveContractPriceLineItemPlan('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    testmethod static void testSaveOfferedMPT() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        SVMXA360__MaintenancePlanTemplate__c mpTemplate = 
         (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c', 
                                                new Map<String,Object>{
                                                    'Name' => 'TestTemplate_2',
                                                    'SVMXA360__MaintenancePlanDuration__c' => 2,
                                                    'SVMXA360__MaintenancePlanUnitOfTime__c' => 'Years',
                                                    'SVMXA360__IsActive__c' => true,
                                                    'SVMXA360__WorkOrderGenerationMethod__c' => 'WorkOrderPerAsset',
                                                    'SVMXA360__SvcApptGenerationMethod__c' => '',
                                                    'SVMXA360__DoesAutoGenerateWorkOrders__c' => true,
                                                    'SVMXA360__GenerationTimeframe__c' => 1
                                                });
                                               
        List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = new List<Scon.OfferedMaintenancePlanTemplate>();
        
        Scon.OfferedMaintenancePlanTemplate offeredMPT = new Scon.OfferedMaintenancePlanTemplate();
        offeredMPT.serviceContractPlanId=serviceContractPlanRecord.Id;
        offeredMPT.maintenancePlanTemplateId=mpTemplate.Id;        
        offeredMPTList.add(offeredMPT);
        
        final String requestJson = JSON.serialize(offeredMPTList); 
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveOfferedMPT(requestJson);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testSaveOfferedMPT_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveOfferedMPT(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testSaveOfferedMPT_InvalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.saveOfferedMPT('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    testmethod static void testFetchAccountDetails() {
    
        final Asset assetRecord = [SELECT Id FROM Asset];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.fetchAccountDetails(assetRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testFetchAccountDetails_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.fetchAccountDetails(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testFetchMatchingContractPlans() {
    
        final Asset assetRecord = [SELECT Id FROM Asset];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.fetchMatchingContractPlans(assetRecord.id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testFetchMatchingContractPlans_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.fetchMatchingContractPlans(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testCreateServiceContract() {
    
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];
        
        Scon.ServiceContractPlanRequest sconRequest = new Scon.ServiceContractPlanRequest();
        sconRequest.sourceRecordId = accountRecord.Id;
        sconRequest.serviceContractPlanId = serviceContractPlanRecord.Id;
        sconRequest.locationId = null;
        sconRequest.serviceContractName = 'Gold SCON Template Record';
        sconRequest.serviceContractDescription = 'Contract for Gold Product';
        sconRequest.serviceContractStartDate = Date.Today();        
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.createServiceContract(JSON.serialize(sconRequest));
        
        System.assert( serviceResponse != null );
    }
    
    testmethod static void testCreateServiceContract_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.createServiceContract(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testCreateServiceContract_InvalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.createServiceContract('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    testmethod static void testGetAssetList() {
        
        final Account accountRecord = [SELECT Id FROM Account];
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getAssetList(accountRecord.Id,'test',null);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetAssetList_NullParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getAssetList(null,null,null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetAssetList_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getAssetList('test23424','234234sd3',null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetQualifiedAssets() {
    
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];
        
        Scon.ServiceContractPlanRequest sconRequest = new Scon.ServiceContractPlanRequest();
        sconRequest.sourceRecordId = accountRecord.Id;
        sconRequest.serviceContractPlanId = serviceContractPlanRecord.Id;
        sconRequest.locationId = null;
        sconRequest.serviceContractName = 'Gold SCON Template Record';
        sconRequest.serviceContractDescription = 'Contract for Gold Product';
        sconRequest.serviceContractStartDate = Date.Today();        
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getQualifiedAssets(JSON.serialize(sconRequest));
        
        System.assert( serviceResponse != null );
    }
    
    testmethod static void testGetQualifiedAssets_InvalidParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getQualifiedAssets(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testGetQualifiedAssets_InvalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getQualifiedAssets('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    testmethod static void testGetSCONAuthoringLogs() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 
        Scon.ServiceContractPlanRequest sconRequest = SCON_ServiceContractPlanHandler_UT.getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        SVMXA360__SCONAuthoringLog__c parentLogRecord = new SVMXA360__SCONAuthoringLog__c();
        parentLogRecord.SVMXA360__ServiceContractId__c = serviceContract.Id;
        parentLogRecord.SVMXA360__OperationType__c = 'Create';
        parentLogRecord.SVMXA360__TotalNumberOfBatches__c = 10;
        parentLogRecord.SVMXA360__LogType__c = 'Master';
        parentLogRecord.SVMXA360__UserId__c = UserInfo.getUserId();
        parentLogRecord.SVMXA360__TotalBatchesCompleted__c = 0;

        parentLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( parentLogRecord );
        
        Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getSCONAuthoringLogs(serviceContract.Id);
        
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testGetSCONAuthoringLogs_NullParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getSCONAuthoringLogs(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }

    testmethod static void testExecuteServiceContractDelete() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];
        final List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];
        final SVMXA360__EntitledServicePlan__c entitledServicePlanRecord = 
            (SVMXA360__EntitledServicePlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__EntitledServicePlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__EntitledServiceDuration__c' => 30,
                                                                                           'SVMXA360__EntitledServiceUnitOfTime__c' => 'Days',
                                                                                           'SVMXA360__CaseEntitlementProcess__c' => (slaProcessList!=null) ? slaProcessList[0].Id : null,
                                                                                           'SVMXA360__WorkOrderEntitlementProcess__c' => (slaProcessList!=null) ? slaProcessList[0].Id : null,
                                                                                           'SVMXA360__ServiceUnit__c' => 'Amount',
                                                                                           'SVMXA360__TotalServiceAmount__c ' => 100,
                                                                                           'SVMXA360__ServiceAmountAlertThreshold__c ' => 70,
                                                                                           'SVMXA360__EntitledServiceProductId__c'=>contractLineItemPlanRecord.SVMXA360__ProductId__c,
                                                                                           'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id,
                                                                                           'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id
                                                                                    });
        
        final SVMXA360__ContractPriceLineItemPlan__c cPLIPlanRecord = 
            (SVMXA360__ContractPriceLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__EntitledDiscount__c' => 10,
                                                                                    'SVMXA360__EntitledPrice__c' => null,
                                                                                    'SVMXA360__Surcharge__c' => null,
                                                                                    'SVMXA360__ExpenseItem__c' => 'Toll',
                                                                                    'SVMXA360__LineType__c' =>'Labor',
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id,
                                                                                    'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id,
                                                                                    'SVMXA360__EntitledServicePlanId__c' => entitledServicePlanRecord.Id
                                                                                    });
        
        
        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = SCON_ServiceContractPlanHandler_UT.getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteServiceContract(serviceContract.Id);

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }

    testmethod static void testDeleteSCON_NullParam() {
        
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.deleteServiceContract(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }

    testmethod static void testGetAuthoringSummary() {

        final ServiceContract serviceContract = [SELECT Id FROM ServiceContract];

        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getAuthoringSummary(serviceContract.Id);

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }

    testmethod static void testGetAuthoringSummary_InvalidParam() {
        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.getAuthoringSummary(null);

        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testContractStatusUpdate() {

        final ServiceContract serviceContract = [SELECT Id FROM ServiceContract];
        
        Scon.ServiceContractDetails sconRequest = new Scon.ServiceContractDetails();
        sconRequest.Id = serviceContract.Id;
        sconRequest.authoringStatus = 'Draft';
        sconRequest.statusNotes = 'Test class';
        sconRequest.canceledOn = Date.today();
        
        final String requestJson = JSON.serialize(sconRequest); 

        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.updateServiceContractStatus(requestJson);

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );
    }
    
    testmethod static void testContractStatusUpdateInvalidParam() {

        final ServiceContract serviceContract = [SELECT Id FROM ServiceContract];
        
        final String requestJson = JSON.serialize(null); 

        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.updateServiceContractStatus(requestJson);

        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    testmethod static void testContractStatusUpdateInvalidId() {

        final ServiceContract serviceContract = [SELECT Id FROM ServiceContract];
        
        Scon.ServiceContractDetails sconRequest = new Scon.ServiceContractDetails();
        sconRequest.authoringStatus = 'Draft';
        sconRequest.statusNotes = 'Test class';
        sconRequest.canceledOn = Date.today();
        
        final String requestJson = JSON.serialize(sconRequest); 

        final Common.ServiceResponse serviceResponse = SCON_ServiceContractPlan_LS.updateServiceContractStatus(requestJson);

        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
    }
    
    
}