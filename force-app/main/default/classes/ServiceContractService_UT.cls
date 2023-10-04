@IsTest
public with sharing class ServiceContractService_UT {
    
    @testSetup public static void setup() {
        SCON_ServiceContractPlanHandler_UT.setup();
        
        Product2 prod = [Select id from Product2 limit 1 ];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pricebookEntry = [Select id from PricebookEntry where Product2Id=:prod.Id];
        
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [Select id from SVMXA360__ServiceContractPlan__c limit 1];
     
     SVMXA360__MaintenancePlanTemplate__c mpTemplate = 
         (SVMXA360__MaintenancePlanTemplate__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__MaintenancePlanTemplate__c', 
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
        
       SvmxTestDataFactory.insertSObjectList('SVMXA360__OfferedMaintenancePlanTemplate__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id,
                                                  'SVMXA360__MaintenancePlanTemplateId__c' => mpTemplate.Id
                                                      }, 1);
        
        final Account accountRecord = [Select Id from Account];
        ServiceContract scon = 
        (ServiceContract)SvmxTestDataFactory.insertSObject('ServiceContract', 
                                                new Map<String,Object>{
                                                    'Name'=> 'Service Contract 1',
                                                    'AccountId'=> accountRecord.Id,
                                                    'StartDate' => Date.today(),
                                                    'EndDate' => Date.today().addDays(350),
                                                    'Pricebook2Id' => pricebookId
                                                });
        
                                            
        ContractLineItem cliRecord = 
         (ContractLineItem) SvmxTestDataFactory.insertSObject( 'ContractLineItem', 
                                                new Map<String,Object>{
                                                    'ServiceContractId' => scon.Id,
                                                    'PricebookEntryId' => pricebookEntry.Id,
                                                    'Discount' => 10,
                                                    'Quantity' => 10,
                                                    'StartDate' => Date.today(),
                                                    'EndDate' => Date.today().addDays(250)
                                                });
    }
    
    testmethod static void testCreateServiceContract() {
        Test.startTest();
        
        Account accountRecord = [SELECT Id FROM Account];
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = product.Id;
        update serviceContractPlanRecord;
        
        ServiceContractData serviceContractData = new ServiceContractData();
        serviceContractData.accountId=accountRecord.Id;
        serviceContractData.servicePlanProductId=product.Id;
        serviceContractData.startDate=System.today();        
        serviceContractData.serviceContractName='Test SCON';
        serviceContractData.salesContractId='description field';
        serviceContractData.salesContractIdFieldName='Description';
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createServiceContract(serviceContractData);
        
        System.assert( response != null ); 
        
        Test.stopTest();
    }
    
    testmethod static void testCreateServiceContractFromCLIPlan() {
        Test.startTest();
        
        Account accountRecord = [SELECT Id FROM Account];
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = product.Id;
        update serviceContractPlanRecord;
        
        ServiceContractData serviceContractData = new ServiceContractData();
        serviceContractData.accountId=accountRecord.Id;
        serviceContractData.servicePlanProductId=product.Id;
        serviceContractData.isCLIPlanProductId = true;
        serviceContractData.startDate=System.today();        
        serviceContractData.serviceContractName='Test SCON';
        serviceContractData.salesContractId='description field';
        serviceContractData.salesContractIdFieldName='Description';
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createServiceContract(serviceContractData);
        
        System.assert( response != null ); 
        
        Test.stopTest();
    }
    
    testmethod static void testCreateServiceContract_Error() {
        Test.startTest();
        
        Account accountRecord = [SELECT Id FROM Account];
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = product.Id;
        update serviceContractPlanRecord;
        
        ServiceContractData serviceContractData = new ServiceContractData();
        serviceContractData.accountId=accountRecord.Id;
        serviceContractData.servicePlanProductId=product.Id;
        serviceContractData.startDate=System.today();  
        serviceContractData.endDate =System.today();       
        serviceContractData.serviceContractName='Test SCON';
        serviceContractData.salesContractId='description field';
        serviceContractData.salesContractIdFieldName='Description';
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse= ServiceContractService.createServiceContract(serviceContractData);
        
        System.assert( serviceResponse != null );
        
        Test.stopTest();
    }
    
    testmethod static void testCreateServiceContract_NullParam() {
        Test.startTest();
        
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.createServiceContract(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testCreateServiceContract_InvalidParam() {
        Test.startTest();
        
        ServiceContractData serviceContractData = new ServiceContractData();
        serviceContractData.accountId='test';
        
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.createServiceContract(serviceContractData);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
        
        Test.stopTest();
    }

    testmethod static void testCreateContractLineItems() {

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

        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createContractLineItems(contractLineItemData);

        System.assert( serviceContract != null );
    }
    
    testmethod static void testCreateContractLineItemsFromCLIPlan() {

        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

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
        contractLineItemData.isCLIPlanProductId = true;
        contractLineItemData.serviceContractId = serviceContract.id;

        List<ContractLineAssetData> assetDataList = new List<ContractLineAssetData>();
        ContractLineAssetData contractLineAssetData = new ContractLineAssetData();
        ContractLineAssetData.assetId = asserRec.Id;
        ContractLineAssetData.startDate = Date.today();
        ContractLineAssetData.endDate = ContractLineAssetData.startDate.addDays(30);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;

        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createContractLineItems(contractLineItemData);

        System.assert( serviceContract != null );
    }
    
    testmethod static void testCreateCLIFromCLIPlan_WOPriceBookEntry() {

        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        List<Asset> assetList = [Select Id,Product2Id  From Asset LIMIT 5];
        
        assetList[2].Product2Id =null;
        Database.update(assetList);

        Scon.ServiceContractPlanRequest sconRequest = SCON_ServiceContractPlanHandler_UT.getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = null;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);

        ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;
        
        List<ContractLineAssetData> assetDataList = new List<ContractLineAssetData>();
        ContractLineAssetData asd1 = new ContractLineAssetData();
        asd1.assetId= assetList[2].Id ;
        asd1.startDate=System.Today();
        assetDataList .add(asd1);
        
        ContractLineItemData cliData = new ContractLineItemData();
        cliData.serviceContractId =serviceContract.Id;
        cliData.servicePlanProductId =product.Id;
        cliData.isCLIPlanProductId = true;
        cliData.assetDataList = assetDataList;

        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createContractLineItems(cliData);

        System.assert( serviceContract != null );
    }

    testmethod static void testCreateContractLineItems_InvalidParam() {
        Test.startTest();

        final Account accountRecord = [SELECT Id FROM Account];
        
        ContractLineItemData contractLineItemData = new ContractLineItemData();
        contractLineItemData.servicePlanProductId = accountRecord.Id;
        
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.createContractLineItems(contractLineItemData);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices() {
        Test.startTest();
        
        
        ServiceContract serviceContractRecord= [SELECT Id FROM ServiceContract];        
        ContractLineItem contractLineRecord= [SELECT Id FROM ContractLineItem ];        
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];        
        List<Asset> assetList = [Select Id from Asset ];
        
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = serviceContractRecord.Id;
        entitledServiceData.contractLineItemId = contractLineRecord.Id;
        entitledServiceData.serviceProductId = product.Id;
        entitledServiceData.serviceUnit = 'Hours';
        entitledServiceData.serviceQty = '15';      
        entitledServiceData.subscriptionFieldName = 'Type'; 
        entitledServiceData.subscriptionId = 'Phone Support'; 
        entitledServiceData.subscribedAssetFieldName = 'AssetId'; 
        entitledServiceData.subscribedAssetId = assetList[0] != null ? assetList[0].Id : null;        
        
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createEntitledServices(entitledServiceData);       
        
        System.assert( response!= null );    
        System.assert( response.success ); 
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_Amount() {
        Test.startTest();
        
        ServiceContract serviceContractRecord= [SELECT Id FROM ServiceContract];
        
        ContractLineItem contractLineRecord= [SELECT Id FROM ContractLineItem ];
        
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<Asset> assetList = [Select Id from Asset ];
        
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = serviceContractRecord.Id;
        entitledServiceData.contractLineItemId = contractLineRecord.Id;
        entitledServiceData.serviceProductId = product.Id;
        entitledServiceData.serviceUnit = 'Amount';
        entitledServiceData.serviceQty = '15';
        entitledServiceData.startDate = System.today();
        entitledServiceData.endDate = System.today().addDays(20);
        entitledServiceData.subscriptionFieldName = 'Type'; 
        entitledServiceData.subscriptionId = 'Phone Support'; 
        entitledServiceData.subscribedAssetFieldName = 'AssetId'; 
        entitledServiceData.subscribedAssetId = assetList[0] != null ? assetList[0].Id : null; 
        
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createEntitledServices(entitledServiceData);
        
        System.assert( response!= null );    
        System.assert( response.success ); 
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_Exception() {
        Test.startTest();
        
        ServiceContract serviceContractRecord= [SELECT Id FROM ServiceContract];        
        ContractLineItem contractLineRecord= [SELECT Id FROM ContractLineItem ];        
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = serviceContractRecord.Id;
        entitledServiceData.contractLineItemId = contractLineRecord.Id;
        entitledServiceData.serviceProductId = product.Id;
        entitledServiceData.serviceUnit = 'Amount';
        entitledServiceData.serviceQty = '15';
        entitledServiceData.startDate = System.today();
        entitledServiceData.endDate = System.today().addMonths(500);
        
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createEntitledServices(entitledServiceData);
        
        System.assert( response!= null );    
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_InvalidField1() {
        Test.startTest();
        
        ServiceContract serviceContractRecord= [SELECT Id FROM ServiceContract];        
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = serviceContractRecord.Id;
        entitledServiceData.serviceProductId = product.Id;
        entitledServiceData.serviceUnit = 'Hours';
        entitledServiceData.serviceQty = '15';      
        entitledServiceData.subscriptionFieldName = 'Type22'; 
        entitledServiceData.subscriptionId = 'Phone Support';
                
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createEntitledServices(entitledServiceData);
        
        System.assert( response!= null );    
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_InvalidField2() {
        Test.startTest();
        
        ServiceContract serviceContractRecord= [SELECT Id FROM ServiceContract];        
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = serviceContractRecord.Id;
        entitledServiceData.serviceProductId = product.Id;
        entitledServiceData.serviceUnit = 'Hours';
        entitledServiceData.serviceQty = '15';
        entitledServiceData.subscribedAssetFieldName = 'InValidField'; 
        entitledServiceData.subscribedAssetId = 'test22'; 
                
        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.createEntitledServices(entitledServiceData);
        
        System.assert( response!= null );    
        System.assert( !response.success );
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_InvalidServiceContract() {
        Test.startTest();
                
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = 'Test123ServiceContract';
        entitledServiceData.serviceProductId = 'Test Product';
        entitledServiceData.serviceUnit = 'Hours';
        entitledServiceData.serviceQty = '15'; 
        
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.createEntitledServices(entitledServiceData);
        System.assert( serviceResponse != null );
        System.assert(!serviceResponse.success ); 
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_InvalidParam () {
        Test.startTest();
        
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.createEntitledServices(entitledServiceData);
        System.assert( serviceResponse != null );
        System.assert(!serviceResponse.success ); 
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledServices_NullParam() {
        Test.startTest();
        
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.createEntitledServices(null);
        
        System.assert( serviceResponse != null );
        System.assert( !serviceResponse.success );
        
        Test.stopTest();
    }

    testmethod static void testCancelServiceContractWithInvalidArgument() {
        Test.startTest();
            SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.cancelServiceContract(null);

            System.assert( serviceResponse != null );
            System.assert( !serviceResponse.success );
        Test.stopTest();
    }

    testmethod static void testCancelServiceContractWithMissingParam() {
        Test.startTest();
            CancelServiceContractData cancelServiceContract = new CancelServiceContractData();
            SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = ServiceContractService.cancelServiceContract(cancelServiceContract);

            System.assert( serviceResponse != null );
            System.assert( !serviceResponse.success );
        Test.stopTest();
    }
}