@IsTest
public class SCON_ServiceContractPlanHandler_UT {

    @testSetup public static void setup() {
        
        final Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');
        final List<Product2> productRecordList = (List<Product2>) SvmxTestDataFactory.insertSObjectList('Product2', 5);
        
        final List<Asset> assetRecordList = (List<Asset>) SvmxTestDataFactory.createSObjectList('Asset', 5);
        final Id pricebookId = Test.getStandardPricebookId();
        final List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();

        for( Integer index = 0; index < 5; index++ ) {
            
            assetRecordList.get(index).AccountId = accountRecord.Id;
            assetRecordList.get(index).Product2Id = productRecordList.get( index ).Id;
            pricebookEntryList.add( new PricebookEntry( Pricebook2Id = pricebookId, Product2Id = productRecordList.get(index).Id, UnitPrice = 10000, IsActive = true ) );
        }
        
        insert pricebookEntryList;
        insert assetRecordList[0];

        assetRecordList[1].ParentId = assetRecordList[0].Id;
        insert assetRecordList[1];

        assetRecordList[2].ParentId = assetRecordList[1].Id;
        insert assetRecordList[2];

        assetRecordList[3].ParentId = assetRecordList[2].Id;
        insert assetRecordList[3];

        assetRecordList[4].ParentId = assetRecordList[3].Id;
        insert assetRecordList[4];

        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = 
            (SVMXA360__ServiceContractPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ServiceContractPlan__c',
                                                                                 new Map<String,Object>{
                                                                                     'SVMXA360__ContractTermDuration__c' => 1,
                                                                                     'SVMXA360__ContractTermUnitOfTime__c' => 'Years'
                                                                                    });
        serviceContractPlanRecord.SVMXA360__PricebookId__c = pricebookId;
        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = productRecordList[0].Id;
        update serviceContractPlanRecord;

        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = 
            (SVMXA360__ContractLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__ContractLineDuration__c' => 90,
                                                                                    'SVMXA360__ContractLineUnitOfTime__c' => 'Days',
                                                                                    'SVMXA360__ProductFamily__c'=>null,
                                                                                    'SVMXA360__ProductId__c'=>productRecordList[0].Id,
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                    });

        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord2 = 
        (SVMXA360__ContractLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractLineItemPlan__c',
                                                                                new Map<String,Object>{
                                                                                'SVMXA360__ContractLineDuration__c' => 80,
                                                                                'SVMXA360__ContractLineUnitOfTime__c' => 'Days',
                                                                                'SVMXA360__ProductFamily__c'=>null,
                                                                                'SVMXA360__ProductId__c'=>productRecordList[1].Id,
                                                                                'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                });

        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord3 = 
        (SVMXA360__ContractLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractLineItemPlan__c',
                                                                                new Map<String,Object>{
                                                                                'SVMXA360__ContractLineDuration__c' => 80,
                                                                                'SVMXA360__ContractLineUnitOfTime__c' => 'Days',
                                                                                'SVMXA360__ProductFamily__c'=>null,
                                                                                'SVMXA360__ProductId__c'=>productRecordList[2].Id,
                                                                                'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                });

        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord4 = 
        (SVMXA360__ContractLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractLineItemPlan__c',
                                                                                new Map<String,Object>{
                                                                                'SVMXA360__ContractLineDuration__c' => 80,
                                                                                'SVMXA360__ContractLineUnitOfTime__c' => 'Days',
                                                                                'SVMXA360__ProductFamily__c'=>null,
                                                                                'SVMXA360__ProductId__c'=>productRecordList[3].Id,
                                                                                'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                });

        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord5 = 
        (SVMXA360__ContractLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractLineItemPlan__c',
                                                                                new Map<String,Object>{
                                                                                'SVMXA360__ContractLineDuration__c' => 80,
                                                                                'SVMXA360__ContractLineUnitOfTime__c' => 'Days',
                                                                                'SVMXA360__ProductFamily__c'=>null,
                                                                                'SVMXA360__ProductId__c'=>productRecordList[4].Id,
                                                                                'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                });

        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanProductFamilyRecord = 
            (SVMXA360__ContractLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__ContractLineDuration__c' => null,
                                                                                    'SVMXA360__ContractLineUnitOfTime__c' => null,
                                                                                    'SVMXA360__ProductFamily__c'=>'Service',
                                                                                    'SVMXA360__ProductId__c'=>null,
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                    });
                                                                                
        final List<SVMXA360__EntitledServicePlan__c> entitledServicePlanList = 
        (List<SVMXA360__EntitledServicePlan__c>) SvmxTestDataFactory.insertSObjectList('SVMXA360__EntitledServicePlan__c', 
                                                                                        new Map<String,Object>{
                                                                                        'SVMXA360__EntitledServiceDuration__c' => 10,
                                                                                        'SVMXA360__EntitledServiceUnitOfTime__c' => 'Days',
                                                                                        'SVMXA360__CaseEntitlementProcess__c' => null,
                                                                                        'SVMXA360__WorkOrderEntitlementProcess__c' => null,
                                                                                        'SVMXA360__ServiceUnit__c' => 'Visits',
                                                                                        'SVMXA360__EntitledServiceProductId__c'=>productRecordList[0].Id,
                                                                                        'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                        }, 1);
        List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];
        
        final List<SVMXA360__EntitledServicePlan__c> cpliEntitledServicePlanList = 
        (List<SVMXA360__EntitledServicePlan__c>) SvmxTestDataFactory.insertSObjectList('SVMXA360__EntitledServicePlan__c', 
                                                                                        new Map<String,Object>{
                                                                                        'SVMXA360__EntitledServiceDuration__c' => 30,
                                                                                        'SVMXA360__EntitledServiceUnitOfTime__c' => 'Days',
                                                                                        'SVMXA360__CaseEntitlementProcess__c' => (slaProcessList!=null) ? slaProcessList[0].Id : null,
                                                                                        'SVMXA360__WorkOrderEntitlementProcess__c' => (slaProcessList!=null) ? slaProcessList[0].Id : null,
                                                                                        'SVMXA360__ServiceUnit__c' => 'Amount',
                                                                                        'SVMXA360__EntitledServiceProductId__c'=>productRecordList[0].Id,
                                                                                        'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id,
                                                                                        'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                        }, 1);

        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Gas',
                                                  'SVMXA360__LineType__c' =>'Expense',
                                                  'SVMXA360__EntitledServicePlanId__c' => entitledServicePlanList.get(0).Id
                                                      }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Mileage',
                                                  'SVMXA360__LineType__c' =>'Expense',
                                                  'SVMXA360__EntitledServicePlanId__c' => cpliEntitledServicePlanList.get(0).Id
                                                      }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Toll',
                                                  'SVMXA360__LineType__c' =>'Expense',
                                                  'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id
                                                      }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Toll',
                                                  'SVMXA360__LineType__c' =>'Expense',
                                                  'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                      }, 1);

        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Airfare',
                                                  'SVMXA360__LineType__c' =>'Expense',
                                                  'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                      }, 1);
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
    }

    public static Scon.ServiceContractPlanRequest getSconRequestObject ( final Id sourceRecordId, final Id serviceContractPlanId, final Id locationId,
                                                                 final String serviceContractName, final String serviceContractDescription, 
                                                                 final Date serviceContractStartDate, final Boolean evaluateForChildAssets ) {
        Scon.ServiceContractPlanRequest sconRequest = new Scon.ServiceContractPlanRequest();
        sconRequest.sourceRecordId = sourceRecordId;
        sconRequest.serviceContractPlanId = serviceContractPlanId;
        sconRequest.locationId = locationId;
        sconRequest.serviceContractName = serviceContractName;
        sconRequest.serviceContractDescription = serviceContractDescription;
        sconRequest.serviceContractStartDate = serviceContractStartDate;
        sconRequest.evaluateForChildAssets = evaluateForChildAssets;
        return sconRequest;
        
    }

    testmethod static void testExecuteServiceContractPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Asset assetRecord = [SELECT Id FROM Asset limit 1];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(assetRecord.Id,null, serviceContractPlanRecord.id, true);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(assetList[0].id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);

        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        List<ContractLineItem> contractLineRecordList = [Select Id from ContractLineItem where ServiceContractId = :serviceContract.Id];
        List<SVMXA360__MaintenancePlanOffering__c> mpoList = [Select Id from SVMXA360__MaintenancePlanOffering__c where SVMXA360__ServiceContractId__c = :serviceContract.Id];
        System.assert( serviceContract != null );
        System.assert( !contractLineRecordList.isEmpty() );
        System.assert( !mpoList.isEmpty() );
    }

    testmethod static void testExecuteServiceContractPlanAsset() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final List<Asset> assetRecords = [SELECT Id FROM Asset limit 3];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(assetRecords[2].Id,null, serviceContractPlanRecord.id, true);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(assetList[0].Id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;
        List<ContractLineItem> contractLineRecordList = [Select Id from ContractLineItem where ServiceContractId = :serviceContract.Id];
        List<SVMXA360__MaintenancePlanOffering__c> mpoList = [Select Id from SVMXA360__MaintenancePlanOffering__c where SVMXA360__ServiceContractId__c = :serviceContract.Id];
        System.assert( serviceContract != null );
        System.assert( !contractLineRecordList.isEmpty() );
        System.assert( !mpoList.isEmpty() );
    }

    testmethod static void testExecuteServiceContractPlan_InvalidContractParam() {
        
        try {
            final Account accountRecord = [SELECT Id FROM Account];
            Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, accountRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
            sconRequest.createBulkContractLines = false;
            sconRequest.assetServiceContractPlanIdMap = null;

            Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.RECORD_NOT_EXISTS ) != -1 );
        }
    }
    
    testmethod static void testExecuteServiceContractPlan_InvalidContractPlanParam() {
        
        try {
            
            final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
            final Asset assetRecord = [SELECT Id FROM Asset where Product2Id = :contractLineItemPlanRecord.SVMXA360__ProductId__c];
            
            Id contractPlanId = serviceContractPlanRecord.Id;
            
            delete serviceContractPlanRecord;

            Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(assetRecord.id, contractPlanId, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
            sconRequest.createBulkContractLines = false;
            sconRequest.assetServiceContractPlanIdMap = null;
            
            Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
            System.assert(false);
        } 
        catch(Exception e ){
            System.assert(true);
        }
    }

    testmethod static void testExecuteServiceContractPlan_NullParams() {
        
        try {
            Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(null, null, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
            sconRequest.createBulkContractLines = false;
            sconRequest.assetServiceContractPlanIdMap = null;

            Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
            final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;
            System.assert(false);

            new SCON_ServiceContractPlanHandler().createContractLineItems(null,null,null,false,serviceContract);
            System.assert(false);

        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.ENTER_REQUIRED_FIELDS ) != -1 );
        }
    }

    testmethod static void testExecuteServiceContractEntitledService() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 
        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        List<Entitlement> entitlements = [Select Id from Entitlement where ServiceContractId = :serviceContract.Id];

        Scon.ServiceContractPlan serviceContractPlan = new Scon.ServiceContractPlan();
        Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails( new List<String>{serviceContractPlanRecord.Id},serviceContractPlanRecord.Id);
        serviceContractPlan = serviceContractPlanMap.get( serviceContractPlanRecord.Id );

        new SCON_ServiceContractPlanHandler().createContractLineItems(accountRecord.Id,null,serviceContractPlan,false,serviceContract);
        System.assert( serviceContract != null );
        System.assert( !entitlements.isEmpty() );
    }

    testmethod static void testExecuteServiceContractEntitledServiceOnContractLine() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = true;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Id userId = UserInfo.getUserId();
        
        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        List<Entitlement> entitlements = [Select Id from Entitlement where ServiceContractId = :serviceContract.Id];

        SVMXA360__SCONAuthoringLog__c parentLogRecord = new SVMXA360__SCONAuthoringLog__c();

            parentLogRecord.SVMXA360__ServiceContractId__c = serviceContract.Id;
            parentLogRecord.SVMXA360__OperationType__c = 'Create';
            parentLogRecord.SVMXA360__TotalNumberOfBatches__c = Integer.valueOf((assetSconPlanMap.size()/100.0).round(System.RoundingMode.CEILING));
            parentLogRecord.SVMXA360__LogType__c = 'Master';
            parentLogRecord.SVMXA360__UserId__c = userId;
            parentLogRecord.SVMXA360__TotalBatchesCompleted__c = 0;

            parentLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( parentLogRecord );

        List<ContractLineItem> createContractLineItems = new SCON_ServiceContractPlanHandler().createContractLineItems(assetSconPlanMap,true,serviceContractPlanRecord.Id,serviceContract,userId,parentLogRecord.Id);
        System.assert( serviceContract != null );
    }

    testmethod static void testExecuteServiceContractEntitledServiceOnContractLine_InvalidParams() {

        try {
        
            final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
            final Account accountRecord = [SELECT Id FROM Account];

            Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
            Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
            for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
                assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
            } 

            Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
            sconRequest.createBulkContractLines = true;
            sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

            Id userId = UserInfo.getUserId();
            
            Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
            final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

            List<Entitlement> entitlements = [Select Id from Entitlement where ServiceContractId = :serviceContract.Id];

            SVMXA360__SCONAuthoringLog__c parentLogRecord = new SVMXA360__SCONAuthoringLog__c();

                parentLogRecord.SVMXA360__ServiceContractId__c = serviceContract.Id;
                parentLogRecord.SVMXA360__OperationType__c = 'Create';
                parentLogRecord.SVMXA360__TotalNumberOfBatches__c = Integer.valueOf((assetSconPlanMap.size()/100.0).round(System.RoundingMode.CEILING));
                parentLogRecord.SVMXA360__LogType__c = 'Master';
                parentLogRecord.SVMXA360__UserId__c = userId;
                parentLogRecord.SVMXA360__TotalBatchesCompleted__c = 0;

                parentLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( parentLogRecord );

            List<ContractLineItem> createContractLineItems = new SCON_ServiceContractPlanHandler().createContractLineItems(null,true,serviceContractPlanRecord.Id,serviceContract,userId,parentLogRecord.Id);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.ENTER_REQUIRED_FIELDS ) != -1 );
        }

        
    }

    testmethod static void testExecuteServiceContractCPLI() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        final SVMXA360__ContractPriceLineItemPlan__c cPLIPlanRecord = 
            (SVMXA360__ContractPriceLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__EntitledDiscount__c' => 10,
                                                                                    'SVMXA360__EntitledPrice__c' => null,
                                                                                    'SVMXA360__Surcharge__c' => null,
                                                                                    'SVMXA360__ExpenseItem__c' => 'Toll',
                                                                                    'SVMXA360__LineType__c' =>'Labor',
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                    });

            Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
            Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
            for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        }            
        
        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;
    
        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        List<SVMXA360__ContractPriceLineItem__c> cPLIRecords = [Select Id from SVMXA360__ContractPriceLineItem__c where SVMXA360__ServiceContractId__c = :serviceContract.Id];
        System.assert( serviceContract != null );
        System.assert( !cPLIRecords.isEmpty() );
    }

    testmethod static void testExecuteServiceContractCPLIonEntitledServices() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];
        final List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];
        
        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        List<SVMXA360__ContractPriceLineItem__c> cPLIRecords = [Select Id from SVMXA360__ContractPriceLineItem__c where SVMXA360__ServiceContractId__c = :serviceContract.Id];
        System.assert( serviceContract != null );
        System.assert( !cPLIRecords.isEmpty() );
    }

    testmethod static void testExecuteServiceContractCPLIonContractLine() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];

        final SVMXA360__ContractPriceLineItemPlan__c cPLIPlanRecord = 
            (SVMXA360__ContractPriceLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__EntitledDiscount__c' => 10,
                                                                                    'SVMXA360__EntitledPrice__c' => null,
                                                                                    'SVMXA360__Surcharge__c' => null,
                                                                                    'SVMXA360__ExpenseItem__c' => 'Toll',
                                                                                    'SVMXA360__LineType__c' =>'Labor',
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id,
                                                                                    'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id
                                                                                    });
        
        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 
        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;
        
        List<SVMXA360__ContractPriceLineItem__c> cPLIRecords = [Select Id from SVMXA360__ContractPriceLineItem__c where SVMXA360__ServiceContractId__c = :serviceContract.Id];
        System.assert( serviceContract != null );
        System.assert( !cPLIRecords.isEmpty() );
    }
    
    testmethod static void testGetQualifiedAssets () {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        final Scon.QualifiedAssets assetList= new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        System.assert( assetList.qualifiedAssetList != null );
        System.assert( !assetList.qualifiedAssetList.isEmpty() );    
        
    }
    
    testmethod static void testGetQualifiedAssets_NullParam () {   
        
        try {
            final Scon.QualifiedAssets assetList= new SCON_ServiceContractPlanHandler().getQualifiedAssets(null,null, null, false);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.ENTER_REQUIRED_FIELDS ) != -1 );
        }
        
    }
    
    testmethod static void testGetQualifiedAssets_InValidParam () {   
        
        try {
            final Scon.QualifiedAssets assetList= new SCON_ServiceContractPlanHandler().getQualifiedAssets('tw3ed','322dds', '323432', false);
            System.assert(false);
        }    
        catch(Exception e ){
            System.assert(true);
        }
        
    }

    testmethod static void testExecuteServiceContractDelete() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];
        final List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];
        final SVMXA360__ContractPriceLineItemPlan__c cPLIPlanRecord = 
            (SVMXA360__ContractPriceLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__EntitledDiscount__c' => 10,
                                                                                    'SVMXA360__EntitledPrice__c' => null,
                                                                                    'SVMXA360__Surcharge__c' => null,
                                                                                    'SVMXA360__ExpenseItem__c' => 'Toll',
                                                                                    'SVMXA360__LineType__c' =>'Labor',
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id,
                                                                                    'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id
                                                                                    });
        
        
        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        Scon.ServiceContractDeleteResponse serviceContractDeleteResponse = new SCON_ServiceContractPlanHandler().deleteServiceContract(serviceContract.Id);

        System.assert( serviceContractDeleteResponse != null );
        System.assert( serviceContractDeleteResponse.deletionStatus == 'Completed' );
    }

    testmethod static void testSCONDelete_InvalidContractParam() {
        
        try {
            Scon.ServiceContractDeleteResponse serviceContractDeleteResponse = new SCON_ServiceContractPlanHandler().deleteServiceContract(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.ENTER_REQUIRED_FIELDS ) != -1 );
        }
        
    }

    testmethod static void testPublishDeleteEvents_InvalidContractParam() {
        
        try {
            SCON_ServiceContractPlanHelper.publishDeletePlatformEvents(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.ENTER_REQUIRED_FIELDS ) != -1 );
        }
        
    }

    testmethod static void testSCONDelete_createDeleteEvents() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = [SELECT Id,SVMXA360__ProductId__c FROM SVMXA360__ContractLineItemPlan__c limit 1];
        final Account accountRecord = [SELECT Id FROM Account];
        final List<SlaProcess> slaProcessList = [Select Id,Name from SlaProcess where IsActive=true];
        final SVMXA360__ContractPriceLineItemPlan__c cPLIPlanRecord = 
            (SVMXA360__ContractPriceLineItemPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ContractPriceLineItemPlan__c',
                                                                                 new Map<String,Object>{
                                                                                    'SVMXA360__EntitledDiscount__c' => 10,
                                                                                    'SVMXA360__EntitledPrice__c' => null,
                                                                                    'SVMXA360__Surcharge__c' => null,
                                                                                    'SVMXA360__ExpenseItem__c' => 'Toll',
                                                                                    'SVMXA360__LineType__c' =>'Labor',
                                                                                    'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id,
                                                                                    'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanRecord.Id
                                                                                    });
        
        
        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), false);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = assetSconPlanMap;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);
        final ServiceContract serviceContractRecord = serviceContractResponse.serviceContractRecord;

        List<ServiceContract> serviceContractRecords = SvmxDatabase.query([SELECT Id, (Select Id from ContractLineItems),
                                                            (Select Id from Entitlements), 
                                                            (Select Id from SVMXA360__Contract_Price_Line_Items__r)
                                                            FROM ServiceContract where Id =:serviceContractRecord.Id]);  

        SVMXA360__SCONAuthoringLog__c parentLog = SCON_ServiceContractPlanHelper.publishDeletePlatformEvents(serviceContractRecords[0]);

        List<Id> recordIds = new List<Id>();
        for (SVMXA360__ContractPriceLineItem__c contractPriceLineItemRecord : serviceContractRecords[0].SVMXA360__Contract_Price_Line_Items__r) {
            recordIds.add(contractPriceLineItemRecord.Id);
        } 

        new SCON_ServiceContractPlanHandler().deleteServiceContractCoverages(recordIds, UserInfo.getUserId(), parentLog.Id, serviceContractRecords[0].Id);

        System.assert(serviceContractRecord != null);
    }

    testmethod static void testGetAuthoringSummary() {
        final Account accountRecord = [Select Id from Account];
        ServiceContract serviceContract = 
        (ServiceContract)SvmxTestDataFactory.insertSObject('ServiceContract', new Map<String,Object>{'Name'=> 'Service Contract 1', 'AccountId'=> accountRecord.Id});

        SVMXA360__SCONAuthoringLog__c parentLogRecord = new SVMXA360__SCONAuthoringLog__c();
        parentLogRecord.SVMXA360__ServiceContractId__c = serviceContract.Id;
        parentLogRecord.SVMXA360__OperationType__c = 'Create';
        parentLogRecord.SVMXA360__TotalNumberOfBatches__c = 10;
        parentLogRecord.SVMXA360__LogType__c = 'Master';
        parentLogRecord.SVMXA360__UserId__c = UserInfo.getUserId();
        parentLogRecord.SVMXA360__TotalBatchesCompleted__c = 9;
        parentLogRecord.SVMXA360__Status__c = 'Failed';

        parentLogRecord = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( parentLogRecord );

        SVMXA360__SCONAuthoringLog__c failedLogRecord1 = new SVMXA360__SCONAuthoringLog__c();
        failedLogRecord1.SVMXA360__ServiceContractId__c = serviceContract.Id;
        failedLogRecord1.SVMXA360__OperationType__c = 'Create';
        failedLogRecord1.SVMXA360__LogType__c = 'Detail';
        failedLogRecord1.SVMXA360__UserId__c = UserInfo.getUserId();
        failedLogRecord1.SVMXA360__Status__c = 'Failed';
        failedLogRecord1.SVMXA360__Message__c = 'Failed';
        failedLogRecord1.SVMXA360__ParentSCONAuthoringLogId__c = parentLogRecord.Id;

        failedLogRecord1 = (SVMXA360__SCONAuthoringLog__c) SvmxDatabase.insertRecord( failedLogRecord1 );

        final Scon.AuthoringSummaryDetails authoringSummaryDetails = new SCON_ServiceContractPlanHandler().getAuthoringSummary(serviceContract.Id);

        System.assertEquals(1, authoringSummaryDetails.authoringLogOfFailedBatches.size() );
    }

    testmethod static void testExecutecreateContractLineItems_CPQ() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
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

        Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createContractLineItems(contractLineItemData);

        System.assert( serviceContract != null );
        system.assert(serviceResponse.success == true);
    }

    testmethod static void testExecutecreateContractLineItems_CPQInvalidDate() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
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
        ContractLineAssetData.endDate = ContractLineAssetData.startDate.addDays(3000);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;

        Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createContractLineItems(contractLineItemData);

        System.assert( serviceContract != null );
        system.assert(!serviceResponse.success);
    }

    testmethod static void testExecutecreateContractLineItems_CPQInvalidField() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
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
        ContractLineAssetData.subscriptionId='test description';
        ContractLineAssetData.subscriptionFieldName='Description22';
        ContractLineAssetData.subscribedAssetId=asserRec.Id;
        ContractLineAssetData.subscribedAssetFieldName='AssetId22';
        ContractLineAssetData.endDate = ContractLineAssetData.startDate.addDays(30);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;

        Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createContractLineItems(contractLineItemData);

        System.assert( serviceContract != null );
        system.assert(!serviceResponse.success );
    }
    
    testmethod static void testExecuteCreateCLIsWithoutPlan_CPQ() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = null;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);

        ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        Asset asserRec = [Select Id, Product2Id from Asset where Id = :assetList[0].Id];

        serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = asserRec.Product2Id;
        Database.update(serviceContractPlanRecord);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookEntry = [SELECT ID FROM PricebookEntry WHERE Product2Id =:asserRec.Product2Id AND Pricebook2Id = :pricebookId LIMIT 1];

        ContractLineItemData contractLineItemData = new ContractLineItemData();

        
        contractLineItemData.serviceContractId = serviceContract.id;

        List<ContractLineAssetData> assetDataList = new List<ContractLineAssetData>();
        ContractLineAssetData contractLineAssetData = new ContractLineAssetData();
        ContractLineAssetData.assetId = asserRec.Id;
        ContractLineAssetData.pricebookEntryId=pricebookEntry.Id;
        ContractLineAssetData.subscriptionId='test description';
        ContractLineAssetData.subscriptionFieldName='Description';
        ContractLineAssetData.subscribedAssetId=asserRec.Id;
        ContractLineAssetData.subscribedAssetFieldName='AssetId';
        ContractLineAssetData.startDate = Date.today();
        ContractLineAssetData.endDate = ContractLineAssetData.startDate.addDays(30);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;

        Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createContractLineItems(contractLineItemData);

        System.assert( serviceContract != null );
        system.assert(serviceResponse.success == true);
    }

    testmethod static void testExecuteCreateCLIsWithoutPlan_CPQInvalidParam() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        final Account accountRecord = [SELECT Id FROM Account];

        Scon.QualifiedAssets qualifiedAssets = new SCON_ServiceContractPlanHandler().getQualifiedAssets(accountRecord.id,null, serviceContractPlanRecord.id, false);
        Map<Id,Id> assetSconPlanMap = new Map<Id,Id>();
        List<Asset> assetList = new List<Asset>();
        assetList = qualifiedAssets.qualifiedAssetList;
        for (Asset assetRec : qualifiedAssets.qualifiedAssetList ) {
            assetSconPlanMap.put(assetRec.Id,serviceContractPlanRecord.Id);
        } 

        Scon.ServiceContractPlanRequest sconRequest = getSconRequestObject(accountRecord.id, serviceContractPlanRecord.id, null,'Gold SCON Template Record', 'Contract for Gold Product',Date.Today(), true);
        sconRequest.createBulkContractLines = false;
        sconRequest.assetServiceContractPlanIdMap = null;

        Scon.ServiceContractResponse serviceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan(sconRequest);

        ServiceContract serviceContract = serviceContractResponse.serviceContractRecord;

        Asset asserRec = [Select Id, Product2Id from Asset where Id = :assetList[0].Id];

        ContractLineItemData contractLineItemData = new ContractLineItemData();

        
        contractLineItemData.serviceContractId = serviceContract.id;

        List<ContractLineAssetData> assetDataList = new List<ContractLineAssetData>();
        ContractLineAssetData contractLineAssetData = new ContractLineAssetData();
        ContractLineAssetData.assetId = asserRec.Id;
        ContractLineAssetData.startDate = Date.today();
        ContractLineAssetData.endDate = Date.today().addDays(1000);
        assetDataList.add(ContractLineAssetData);

        contractLineItemData.assetDataList = assetDataList;

        Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createContractLineItems(contractLineItemData);

        System.assert( serviceResponse != null );
        system.assert( !serviceResponse.success );
    }

    testmethod static void testtestExecutecreateContractLineItems_CPQInvalidParam() {
        
        Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createContractLineItems(null);

        System.assert( serviceResponse != null );
        system.assert( !serviceResponse.success );
        
    }

    testmethod static void testCancelServiceContract() {
        final Account accountRecord = [Select Id from Account];

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookEntry = [SELECT ID FROM PricebookEntry WHERE Pricebook2Id = :pricebookId LIMIT 1];

        ServiceContract serviceContractRecord = (ServiceContract) SvmxTestDataFactory.insertSObject('ServiceContract', new Map<String, Object> {
            'Name' =>  'Service Contract 1',
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addYears(1),
            'AccountId'=> accountRecord.Id,
            'Pricebook2Id' => pricebookId
        });

        ContractLineItem contractLineItemRecord = (ContractLineItem) SvmxTestDataFactory.insertSObject('ContractLineItem', new Map<String, Object> {
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addYears(1),
            'ServiceContractId' => serviceContractRecord.Id,
            'Quantity' => 1,
            'PricebookEntryId' => pricebookEntry.Id
        });

        Test.startTest();

        CancelServiceContractData cancelServiceContract = new CancelServiceContractData();
        cancelServiceContract.salesContractId = 'Service Contract 1';
        cancelServiceContract.salesContractIdFieldAPIName = 'Name';
        cancelServiceContract.effectiveEndDate =  Date.today().addYears(2);
        cancelServiceContract.cancellationReason = 'I am Cancelling SC';
        cancelServiceContract.cancellationReasonFieldAPIName = 'Description';

        SVMXA360.SvmxGlobal.SvmxResponse response = ServiceContractService.cancelServiceContract(cancelServiceContract);
        system.assert(response.success == true);

        Test.stopTest();

        serviceContractRecord = [SELECT ID, EndDate, Description
            FROM ServiceContract WHERE Id =:serviceContractRecord.Id LIMIT 1];
        System.assertEquals(cancelServiceContract.effectiveEndDate, serviceContractRecord.EndDate);
        System.assertEquals(cancelServiceContract.cancellationReason, serviceContractRecord.Description);
    
        contractLineItemRecord = [SELECT ID, EndDate FROM ContractLineItem WHERE Id =:contractLineItemRecord.Id LIMIT 1];
        System.assertEquals(cancelServiceContract.effectiveEndDate, contractLineItemRecord.EndDate);
    }
}