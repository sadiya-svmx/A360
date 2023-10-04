@isTest
public class CreateServiceContractApexAction_UT {
    
    @testSetup public static void setup() {
        SCON_ServiceContractPlanHandler_UT.setup();
    }

    testmethod static void testExecuteCreateServiceContract() {
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        List<CreateServiceContractApexAction.CreateServiceContractRequest> createSCONRequestList = 
            new List<CreateServiceContractApexAction.CreateServiceContractRequest>();
        CreateServiceContractApexAction.CreateServiceContractRequest createSCONRequest = 
            new CreateServiceContractApexAction.CreateServiceContractRequest();
        createSCONRequest.sourceRecordId = accountRecord.Id;
        createSCONRequest.serviceContractPlanId = serviceContractPlanRecord.Id;
        createSCONRequest.locationId = null;
        createSCONRequest.serviceContractName = 'Test Create Service Contract Record';
        createSCONRequest.serviceContractDescription = 'Test Create Service Contract Record from UT';
        createSCONRequest.serviceContractStartDate = Date.today();
        createSCONRequest.evaluateForChildAssets = false;
        createSCONRequest.createBulkContractLines = false;

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        List<AssetServiceContractPlanData> assetSconPlanList = 
            new List<AssetServiceContractPlanData>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            AssetServiceContractPlanData assetSCONPlan = new AssetServiceContractPlanData();
            assetSCONPlan.assetId = assetRec.Id;
            assetSCONPlan.serviceContractPlanId = serviceContractPlanRecord.Id;
            assetSconPlanList.add(assetSCONPlan);
        } 

        createSCONRequest.assetServiceContractPlanList = assetSconPlanList;

        createSCONRequestList.add(createSCONRequest);

        List<CreateServiceContractApexAction.CreateServiceContractResponse> respList = 
            CreateServiceContractApexAction.createServiceContract(createSCONRequestList);
        System.assert(respList != null);
        System.assert( !respList.isEmpty() );
    }

    testmethod static void testExecuteServiceContractPlan_InvalidParams() {
        
        try {
            List<CreateServiceContractApexAction.CreateServiceContractRequest> createSCONRequestList = 
            new List<CreateServiceContractApexAction.CreateServiceContractRequest>();
            CreateServiceContractApexAction.CreateServiceContractRequest createSCONRequest = 
                new CreateServiceContractApexAction.CreateServiceContractRequest();
            createSCONRequest.sourceRecordId = null;
            createSCONRequest.serviceContractPlanId = null;
            createSCONRequest.serviceContractName = 'Test Create Service Contract Record';
            createSCONRequest.serviceContractDescription = 'Test Create Service Contract Record from UT';
            createSCONRequest.serviceContractStartDate = Date.today();
            createSCONRequest.evaluateForChildAssets = false;
            createSCONRequest.createBulkContractLines = false;
            createSCONRequest.assetServiceContractPlanList = null;

            createSCONRequestList.add(createSCONRequest);
            List<CreateServiceContractApexAction.CreateServiceContractResponse> respList = 
                CreateServiceContractApexAction.createServiceContract(createSCONRequestList);
            System.assert(false);
        }    
        catch(Exception e){
           System.assert(true);
        }
    }
    
    testmethod static void testCreateServiceContract_NullParams() {
        
        try {            
            CreateServiceContractApexAction.CreateServiceContractRequest createSCONRequest = new CreateServiceContractApexAction.CreateServiceContractRequest();
            List<CreateServiceContractApexAction.CreateServiceContractResponse> respList = 
                CreateServiceContractApexAction.createServiceContract(new List<CreateServiceContractApexAction.CreateServiceContractRequest> {createSCONRequest});
            System.assert(false);
        }    
        catch(Exception e){
           System.assert(true);
        }
    }
    
    testmethod static void testCreateServiceContractForProduct() {
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id, SVMXA360__ServicePlanProductId__c FROM SVMXA360__ServiceContractPlan__c where SVMXA360__ServicePlanProductId__c != NULL LIMIT 1];
        final Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        List<CreateServiceContractApexAction.CreateServiceContractRequest> createSCONRequestList =
            new List<CreateServiceContractApexAction.CreateServiceContractRequest>();

        CreateServiceContractApexAction.CreateServiceContractRequest createSCONRequest =
            new CreateServiceContractApexAction.CreateServiceContractRequest();
        createSCONRequest.operationType = 'FOR-PRODUCT';
        createSCONRequest.sourceRecordId = accountRecord.Id;
        createSCONRequest.servicePlanProductId = serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c;
        createSCONRequest.serviceContractName = 'Test Create Service Contract Record';
        createSCONRequest.serviceContractDescription = 'Test Create Service Contract Record from UT';
        createSCONRequest.serviceContractStartDate = Date.today();
        createSCONRequest.serviceContractEndDate = Date.Today().addDays(365);
        createSCONRequestList.add(createSCONRequest);
        
        List<CreateServiceContractApexAction.CreateServiceContractResponse> respList = 
            CreateServiceContractApexAction.createServiceContract(createSCONRequestList);
        System.assert(respList != null);
        System.assert( !respList.isEmpty() );
        
    }

}