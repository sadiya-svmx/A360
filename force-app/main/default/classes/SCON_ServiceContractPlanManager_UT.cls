@IsTest
public class SCON_ServiceContractPlanManager_UT {

    @testSetup public static void setup() {
        
        final Product2 prod = (Product2) SvmxTestDataFactory.insertSObject('Product2', new Map<String,Object>{'Name'=>'Test Product 1'});
        
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPricebookEntry = 
        (PricebookEntry)SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String,Object>{'IsActive'=>true, 'Pricebook2Id'=>standardPricebookId, 
                                                                            'Product2Id'=>prod.Id, 'UnitPrice'=>200, 'UseStandardPrice'=>false});

        Pricebook2 pricebook = 
        (Pricebook2)SvmxTestDataFactory.insertSObject('Pricebook2', new Map<String,Object>{'IsActive'=> true, 'Description'=>'Test Pricebook 1', 'Name'=> 'Test Pricebook 1'});

        PricebookEntry pricebookEntry = 
        (PricebookEntry)SvmxTestDataFactory.insertSObject('PricebookEntry', new Map<String,Object>{'IsActive'=> true, 'Pricebook2Id'=>pricebook.Id, 
                                                                            'Product2Id'=> prod.Id,'UnitPrice' => 200});

        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        
        Contact cont = (Contact) SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => prod.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id, 'InstallDate'=>Date.today(), 'PurchaseDate'=>Date.today()});


        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = 
            (SVMXA360__ServiceContractPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ServiceContractPlan__c',
                                                                                 new Map<String,Object>{
                                                                                     'SVMXA360__ContractTermDuration__c' => 1,
                                                                                     'SVMXA360__ContractTermUnitOfTime__c' => 'Years'
                                                                                         });
        final List<SVMXA360__ContractLineItemPlan__c> contractLineItemPlanList = 
            (List<SVMXA360__ContractLineItemPlan__c>) SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractLineItemPlan__c',
                                                                                            new Map<String,Object>{
                                                                                           'SVMXA360__ContractLineDuration__c' => 90,
                                                                                           'SVMXA360__ContractLineUnitOfTime__c' => 'Days',
                                                                                           'SVMXA360__ProductId__c'=>prod.Id,
                                                                                           'SVMXA360__ProductFamily__c'=>null,
                                                                                           'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                                                            }, 1);
        
       
        final List<SVMXA360__EntitledServicePlan__c> entitledServicePlanList = 
            (List<SVMXA360__EntitledServicePlan__c>) SvmxTestDataFactory.insertSObjectList('SVMXA360__EntitledServicePlan__c', 
                                                                                            new Map<String,Object>{
                                                                                           'SVMXA360__EntitledServiceDuration__c' => 30,
                                                                                           'SVMXA360__EntitledServiceUnitOfTime__c' => 'Days',
                                                                                           'SVMXA360__CaseEntitlementProcess__c' => null,
                                                                                           'SVMXA360__WorkOrderEntitlementProcess__c' => null,
                                                                                           'SVMXA360__ServiceUnit__c' => 'Visits',
                                                                                           'SVMXA360__EntitledServiceProductId__c'=>prod.Id,
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
                                                                                           'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanList.get(0).Id
                                                                                            }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Gas',
                                                  'SVMXA360__LineType__c' =>'Labor',
                                                  'SVMXA360__EntitledServicePlanId__c' => entitledServicePlanList.get(0).Id
                                                      }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Mileage',
                                                  'SVMXA360__LineType__c' =>'Labor',
                                                  'SVMXA360__EntitledServicePlanId__c' => cpliEntitledServicePlanList.get(0).Id
                                                      }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Toll',
                                                  'SVMXA360__LineType__c' =>'Labor',
                                                  'SVMXA360__ContractLineItemPlanId__c' => contractLineItemPlanList.get(0).Id
                                                      }, 1);
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Toll',
                                                  'SVMXA360__LineType__c' =>'Labor',
                                                  'SVMXA360__ServiceContractPlanId__c' => serviceContractPlanRecord.Id
                                                      }, 1);

        SvmxTestDataFactory.insertSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 
                                              new Map<String,Object>{
                                                  'SVMXA360__UniqueKey__c' => String.valueOf( Math.random() ),
                                                  'SVMXA360__EntitledDiscount__c' => 10,
                                                  'SVMXA360__EntitledPrice__c' => null,
                                                  'SVMXA360__Surcharge__c' => null,
                                                  'SVMXA360__ExpenseItem__c' => 'Airfare',
                                                  'SVMXA360__LineType__c' =>'Labor',
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
        
        final Account accountRecord = [Select Id from Account];
        ServiceContract scon = 
        (ServiceContract)SvmxTestDataFactory.insertSObject('ServiceContract', new Map<String,Object>{'Name'=> 'Service Contract 1', 'AccountId'=> accountRecord.Id});
        
        
        final List<SVMXA360__SCONAuthoringLog__c> parentLogRecords= 
            (List<SVMXA360__SCONAuthoringLog__c>) SvmxTestDataFactory.insertSObjectList('SVMXA360__SCONAuthoringLog__c', 
                                                    new Map<String,Object>{
                                                    'SVMXA360__OperationType__c' => 'Create',
                                                    'SVMXA360__ServiceContractId__c' => scon.Id,
                                                    'SVMXA360__TotalNumberOfBatches__c' => 3,
                                                    'SVMXA360__LogType__c' => 'Master',
                                                    'SVMXA360__UserId__c' => UserInfo.getUserId(),
                                                    'SVMXA360__TotalBatchesCompleted__c' => 3,
                                                    'SVMXA360__Status__c' => 'Success'
                                                    }, 1);

        final List<SVMXA360__SCONAuthoringLog__c> childLogRecords= 
            (List<SVMXA360__SCONAuthoringLog__c>) SvmxTestDataFactory.insertSObjectList('SVMXA360__SCONAuthoringLog__c', 
                                                    new Map<String,Object>{
                                                    'SVMXA360__OperationType__c' => 'Create',
                                                    'SVMXA360__ServiceContractId__c' => scon.Id,
                                                    'SVMXA360__ParentSCONAuthoringLogId__c' => parentLogRecords[0].Id,
                                                    'SVMXA360__LogType__c' => 'Detail',
                                                    'SVMXA360__UserId__c' => UserInfo.getUserId(),
                                                    'SVMXA360__Status__c' => 'Success'
                                                    }, 3);                                                        
        
    }
    
    testmethod static void testGetAllServiceContractPlans() {
        
        List<Scon.ServiceContractPlan> serviceContractPlanList = SCON_ServiceContractPlanManager.getInstance().getAllServiceContractPlans();
        
        System.assert( serviceContractPlanList != null );
        System.assert( !serviceContractPlanList.isEmpty() );
    }
    
    testmethod static void testGetServiceContractPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        final Scon.ServiceContractPlan serviceContractPlan = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlan(serviceContractPlanRecord.id);
        
        System.assert( serviceContractPlan != null );
    }
    
    testmethod static void testGetServiceContractPlan_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().getServiceContractPlan(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testGetServiceContractPlanWithDetails() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        final Scon.ServiceContractPlan serviceContractPlan = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails(serviceContractPlanRecord.id);
        
        System.assert( serviceContractPlan != null );
    }
    
    testmethod static void testGetServiceContractPlanWithDetails_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testGetContractLineItemPlans() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        
        System.assert( contractLineItemPlanList != null );
        System.assert( !contractLineItemPlanList.isEmpty() );
        System.assert( contractLineItemPlanList.size() == 1, contractLineItemPlanList.size());
    }
    
    testmethod static void testGetContractLineItemPlans_InvalidParam() {
        
        try {
            String serviceContractPlanId = null;
            SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanId);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testGetEntitledServicePlans() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        
        System.assert( entitledServicePlanList != null );
        System.assert( !entitledServicePlanList.isEmpty() );
        System.assert( entitledServicePlanList.size() == 1, entitledServicePlanList.size());
    }
    
    testmethod static void testGetEntitledServicePlans_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(recordId);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIdList = null;
            SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(recordIdList);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testGetContractPriceLineItemPlans() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        
        System.assert( contractPriceLineItemPlanList != null );
        System.assert( !contractPriceLineItemPlanList.isEmpty() );
        System.assert( contractPriceLineItemPlanList.size() == 2, contractPriceLineItemPlanList.size());
    }
    
    testmethod static void testGetContractPriceLineItemPlans_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(recordId);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIdList = null;
            SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(recordIdList);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testSaveContractLineItemPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        contractLineItemPlanList.get(0).id = null;
        contractLineItemPlanList.get(0).productId = null;
        contractLineItemPlanList.get(0).productFamily = 'Service';
        
        Scon.ContractLineItemPlan contractLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlan(contractLineItemPlanList.get(0));
        
        System.assert( contractLineItemPlan != null );
        System.assert( contractLineItemPlan.id != null );
    }
    
    testmethod static void testSaveContractLineItemPlan_Update() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        contractLineItemPlanList.get(0).productFamily = 'Service';
        contractLineItemPlanList.get(0).productId = null;
        
        Scon.ContractLineItemPlan contractLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlan(contractLineItemPlanList.get(0));
        
        System.assert( contractLineItemPlan != null );
        System.assert( contractLineItemPlan.id != null );
    }
    
    testmethod static void testSaveContractLineItemPlan_InvalidRequest() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        contractLineItemPlanList.get(0).serviceContractPlanId = null;
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlan(contractLineItemPlanList.get(0));
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }
        
    }
    
    testmethod static void testSaveContractLineItemPlan_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlan(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlans(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testSaveEntitledServicePlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        entitledServicePlanList.get(0).id = null;
        entitledServicePlanList.get(0).serviceProductId = null;
        
        Scon.EntitledServicePlan entitledServicePlan = SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(entitledServicePlanList.get(0));
        
        System.assert( entitledServicePlan != null );
        System.assert( entitledServicePlan.id != null );
    }
    
    testmethod static void testSaveEntitledServicePlan_Update() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        entitledServicePlanList.get(0).serviceUnit = 'Amount';
        entitledServicePlanList.get(0).totalService = 100;
        entitledServicePlanList.get(0).serviceAlertThreshold = 70;
        
        Scon.EntitledServicePlan entitledServicePlan = SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(entitledServicePlanList.get(0));
        
        System.assert( entitledServicePlan != null );
        System.assert( entitledServicePlan.id != null );
    }
    
    testmethod static void testSaveEntitledServicePlan_InvalidRequest() {
    
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        entitledServicePlanList.get(0).serviceContractPlanId = null;
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(entitledServicePlanList.get(0));
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }        
    }
    
    testmethod static void testSaveEntitledServicePlan_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlans(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testSaveContractPriceLineItemPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        contractPriceLineItemPlanList.get(0).id = null;
        contractPriceLineItemPlanList.get(0).expenseItem = 'Parts';
        
        Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlanList.get(0));
        
        System.assert( contractPriceLineItemPlan != null );
        System.assert( contractPriceLineItemPlan.id != null );
    }
    
    testmethod static void testSaveContractPriceLineItemPlan_Update() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        contractPriceLineItemPlanList.get(0).expenseItem = 'Parts';
        
        Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlanList.get(0));
        
        System.assert( contractPriceLineItemPlan != null );
        System.assert( contractPriceLineItemPlan.id != null );
    }
    
    testmethod static void testSaveContractPriceLineItemPlan_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlans(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testSaveContractPriceLineItemPlan_InvalidRequest() {
    
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        contractPriceLineItemPlanList.get(0).id = null;
        contractPriceLineItemPlanList.get(0).expenseItem = 'Parts';
        contractPriceLineItemPlanList.get(0).serviceContractPlanId = null;        
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlanList.get(0));
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.MISSING_REQUIRED_PARAMETER ) != -1 );
        }
        
    }
    
    testmethod static void testHandleServiceContractPlanDelete() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        SCON_ServiceContractPlanManager.getInstance().handleServiceContractPlanDelete(serviceContractPlanRecord.id);
        
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        
        System.assert( contractPriceLineItemPlanList != null );
        System.assert( contractPriceLineItemPlanList.isEmpty() );
    }
    
    testmethod static void testHandleServiceContractPlanDelete_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().handleServiceContractPlanDelete(recordId);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIds;
            SCON_ServiceContractPlanManager.getInstance().handleServiceContractPlanDelete(recordIds);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testDeleteContractLineItemPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        
        SCON_ServiceContractPlanManager.getInstance().deleteContractLineItemPlan(contractLineItemPlanList.get(0).id);
        
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(contractLineItemPlanList.get(0).id);
        
        System.assert( contractPriceLineItemPlanList != null );
        System.assert( contractPriceLineItemPlanList.isEmpty() );
    }
    
    testmethod static void testDeleteContractLineItemPlan_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().deleteContractLineItemPlan(recordId);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIds;
            SCON_ServiceContractPlanManager.getInstance().deleteContractLineItemPlans(recordIds);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testDeleteEntitledServicePlan() {
        
        List<SVMXA360__EntitledServicePlan__c> entitledServicePlanRecords = [SELECT Id FROM SVMXA360__EntitledServicePlan__c];
        
        SCON_ServiceContractPlanManager.getInstance().deleteEntitledServicePlan(entitledServicePlanRecords.get(0).id);
        
        entitledServicePlanRecords = [SELECT Id FROM SVMXA360__EntitledServicePlan__c];
        
        System.assert( entitledServicePlanRecords != null );
        System.assert( !entitledServicePlanRecords.isEmpty() );
        System.assert( entitledServicePlanRecords.size() == 1, entitledServicePlanRecords.size());
    }
    
    testmethod static void testDeleteEntitledServicePlan_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().deleteEntitledServicePlan(recordId);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIds;
            SCON_ServiceContractPlanManager.getInstance().deleteEntitledServicePlans(recordIds);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testDeleteContractPriceLinePlan() {
        
        List<SVMXA360__ContractPriceLineItemPlan__c> contractPriceLineItemPlanRecords = [SELECT Id FROM SVMXA360__ContractPriceLineItemPlan__c];
        
        SCON_ServiceContractPlanManager.getInstance().deleteContractPriceLinePlan(contractPriceLineItemPlanRecords.get(0).id);
        
        contractPriceLineItemPlanRecords = [SELECT Id FROM SVMXA360__ContractPriceLineItemPlan__c];
        
        System.assert( contractPriceLineItemPlanRecords != null );
        System.assert( !contractPriceLineItemPlanRecords.isEmpty() );
        System.assert( contractPriceLineItemPlanRecords.size() == 4, contractPriceLineItemPlanRecords.size());
    }
    
    testmethod static void testDeleteContractPriceLinePlan_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().deleteContractPriceLinePlan(recordId);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIds;
            SCON_ServiceContractPlanManager.getInstance().deleteContractPriceLinePlans(recordIds);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testFetchMatchingContractPlans() {
        
        final Asset assetRecord = [SELECT Id FROM Asset];
        List<Id> contractLineItemPlanIds = SCON_ServiceContractPlanManager.getInstance().fetchMatchingContractPlans(assetRecord.id);
        
        System.assert( contractLineItemPlanIds != null );
        System.assert( !contractLineItemPlanIds.isEmpty() );
        System.assert( contractLineItemPlanIds.size() == 1, contractLineItemPlanIds.size());
    }
    
    testmethod static void testFetchMatchingContractPlans_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().fetchMatchingContractPlans(null);
            System.assert(false);
        }    
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testSaveOfferedMPTs() {
        
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
        
        offeredMPTList = SCON_ServiceContractPlanManager.getInstance().saveOfferedMPTs(offeredMPTList);
        
        System.assert( offeredMPTList!= null );
        System.assert( offeredMPTList[0].id != null );
    }
    
    testmethod static void testSaveOfferedMPTs_Duplicate() {
        
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<SVMXA360__MaintenancePlanTemplate__c> mptList = [Select id from SVMXA360__MaintenancePlanTemplate__c];
        List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = new List<Scon.OfferedMaintenancePlanTemplate>();
        for(Integer index=0; index<3; index++){
            Scon.OfferedMaintenancePlanTemplate offeredMPT = new Scon.OfferedMaintenancePlanTemplate();
            offeredMPT.serviceContractPlanId=serviceContractPlanRecord.Id;
            offeredMPT.maintenancePlanTemplateId=mptList[0].Id;        
            offeredMPTList.add(offeredMPT);
        }
        try {
            offeredMPTList = SCON_ServiceContractPlanManager.getInstance().saveOfferedMPTs(offeredMPTList);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        
    }   
    
    testmethod static void testSaveOfferedMPTs_InvalidRequest() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = SCON_ServiceContractPlanManager.getInstance().getOfferedMPTs(serviceContractPlanRecord.id);
        offeredMPTList.get(0).serviceContractPlanId = null;
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveOfferedMPTs(offeredMPTList);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        
    }
    
    testmethod static void testSaveOfferedMPTs_InvalidParam() {
        
        try {
            SCON_ServiceContractPlanManager.getInstance().saveOfferedMPTs(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
    }
    
    testmethod static void testDeleteOfferedMPT() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = SCON_ServiceContractPlanManager.getInstance().getOfferedMPTs(serviceContractPlanRecord.id);
        
        SCON_ServiceContractPlanManager.getInstance().deleteOfferedMPT(offeredMPTList.get(0).id);
        
        offeredMPTList  = SCON_ServiceContractPlanManager.getInstance().getOfferedMPTs(serviceContractPlanRecord.id);
        
        System.assert( offeredMPTList != null );
        System.assert( offeredMPTList.isEmpty() );
    }
    
    testmethod static void testtestDeleteOfferedMPT_InvalidParam() {
        
        try {
            final String recordId = null;
            SCON_ServiceContractPlanManager.getInstance().deleteOfferedMPT(recordId);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
        
        try {
            final List<String> recordIds;
            SCON_ServiceContractPlanManager.getInstance().deleteOfferedMPTs(recordIds);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testGetAssetList() {
        
        final Account accountRecord = [SELECT Id FROM Account];
        String searchText = 'test';
        
        List<Asset> assetList =  SCON_ServiceContractPlanManager.getInstance().getAssetList(accountRecord.Id,searchText,null);
        
        System.assert( assetList != null );
        System.assert( assetList[0].id != null );
    }
    
    testmethod static void testGetAssetList_NullParam() {
                
        try {
            SCON_ServiceContractPlanManager.getInstance().getAssetList(null,null,null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
    
    testmethod static void testGetSCONAuthoringLogs() {
        
        final SVMXA360__SCONAuthoringLog__c parentLog = [SELECT Id FROM SVMXA360__SCONAuthoringLog__c where SVMXA360__LogType__c='Master' ];
        
        List<SVMXA360__SCONAuthoringLog__c> sconAuthoringLogRecords =  SCON_ServiceContractPlanManager.getInstance().getSCONAuthoringLogs(parentLog.Id);
        
        System.assert( sconAuthoringLogRecords != null );
        System.assert( sconAuthoringLogRecords[0].id != null );
    }
    
    testmethod static void testGetSCONAuthoringLogs_NullParam() {
                
        try {
            SCON_ServiceContractPlanManager.getInstance().getSCONAuthoringLogs(null);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert( e.getMessage().indexOf(ErrorMessage.INVALID_ARGUMENT ) != -1 );
        }
    }
}