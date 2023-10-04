@isTest
public class CreateContractLineItemApexAction_UT {
    
    @testSetup public static void setup() {
        SCON_ServiceContractPlanHandler_UT.setup();
    }
    
    testmethod static void testCreateCLIApexAction() {
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = SCON_ServiceContractPlanHandler_UT.getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = null;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);

        ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        Asset asserRec = [Select Id, Product2Id from Asset where Id = :assetList[0].Id];

        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = asserRec.Product2Id;
        Database.update(serviceContractPlanRecord);

        ContractLineItemData contractLineItemData = new ContractLineItemData();
        contractLineItemData.servicePlanProductId = serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c;
        contractLineItemData.serviceContractId = serviceContract.id;

        List<ContractLineAssetData> assetDataList = new List<ContractLineAssetData>();
        ContractLineAssetData contractLineAssetData = new ContractLineAssetData();
        ContractLineAssetData.assetId = asserRec.Id;
        ContractLineAssetData.startDate = Date.today();
        ContractLineAssetData.endDate = ContractLineAssetData.startDate.addDays(30);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;
        
        List<contractLineItemData> cliDataList = new List<contractLineItemData>{contractLineItemData};
        
        List<ContractLineItemData> createCLIResponse = CreateContractLineItemApexAction.createContractLineItems(cliDataList);

        System.assert( serviceContract != null );
        system.assert(createCLIResponse[0] != NULL);
    }
    
    testmethod static void testExceptionsDuringCLICreation() {

        List<contractLineItemData> cliDataList = new List<contractLineItemData>();
        List<ContractLineItemData> createCLIResponse;
        try{
            createCLIResponse = CreateContractLineItemApexAction.createContractLineItems(cliDataList);
        } catch(Exception ex) {
            System.assert(ex != null);
        }
    }
    
    testMethod static void testCLICreationFailure () {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = SCON_ServiceContractPlanHandler_UT.getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = null;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);

        ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        Asset asserRec = [Select Id, Product2Id from Asset where Id = :assetList[0].Id];

        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = asserRec.Product2Id;
        Database.update(serviceContractPlanRecord);

        ContractLineItemData contractLineItemData = new ContractLineItemData();
        contractLineItemData.servicePlanProductId = serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c;
        contractLineItemData.serviceContractId = serviceContract.id;

        List<ContractLineAssetData> assetDataList = new List<ContractLineAssetData>();
        ContractLineAssetData contractLineAssetData = new ContractLineAssetData();
        ContractLineAssetData.assetId = asserRec.Id;
        ContractLineAssetData.startDate = Date.today();
        ContractLineAssetData.endDate = ContractLineAssetData.startDate.addDays(-30);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;
        
        List<contractLineItemData> cliDataList = new List<contractLineItemData>{contractLineItemData};
        
        List<ContractLineItemData> createCLIResponse ;
        
        try{
            createCLIResponse = CreateContractLineItemApexAction.createContractLineItems(cliDataList);
        }
        catch(Exception ex) {
            System.assert(ex != null);
            
        }
    }

}