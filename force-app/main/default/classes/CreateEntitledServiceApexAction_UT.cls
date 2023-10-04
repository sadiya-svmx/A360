@isTest
public class CreateEntitledServiceApexAction_UT{

    @testSetup public static void setup() {
        SCON_ServiceContractPlanHandler_UT.setup();

        final Account accountRecord = [Select Id from Account];
        Id pricebookId = Test.getStandardPricebookId();
        ServiceContract scon = 
        (ServiceContract)SvmxTestDataFactory.insertSObject('ServiceContract', 
                                                new Map<String,Object>{
                                                    'Name'=> 'Service Contract 1',
                                                    'AccountId'=> accountRecord.Id,
                                                    'StartDate' => Date.today(),
                                                    'EndDate' => Date.today().addDays(350),
                                                    'Pricebook2Id' => pricebookId
                                                });

    }
    
    testmethod static void testCreateEntitledService() {

        Test.startTest();
        
        ServiceContract serviceContractRecord= [SELECT Id FROM ServiceContract];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        List<EntitledServiceData> esDataList = new List<EntitledServiceData>();
        EntitledServiceData entitledServiceData = new EntitledServiceData();
        entitledServiceData.entitledServiceName = 'New ES-1';        
        entitledServiceData.serviceContractId = serviceContractRecord.Id;
        entitledServiceData.serviceProductId = product.Id;
        entitledServiceData.serviceUnit = 'Hours';
        entitledServiceData.serviceQty = '15';      
        entitledServiceData.subscriptionFieldName = 'Type'; 
        entitledServiceData.subscriptionId = 'Phone Support';     
        esDataList.add(entitledServiceData);
        
        List<EntitledServiceData> createEntitledServiceResponse = CreateEntitledServiceApexAction.createEntitledService(esDataList);       
        
        System.assert( createEntitledServiceResponse != null );
        system.assert(createEntitledServiceResponse[0] != NULL);
        
        Test.stopTest();
    }
    
    testmethod static void testCreateEntitledService_InvalidParam() {
        Test.startTest();
            
        List<EntitledServiceData> esDataList = new List<EntitledServiceData>();
        EntitledServiceData esData = new EntitledServiceData();
        esData.serviceContractId = null;
        esData.serviceProductId = null;
        esData.entitledServiceName = 'CPQ-ES-Apex Action-1';
        esData.serviceUnit = 'Hours';
        esData.serviceQty = '60';
        esDataList.add(esData);
        
        try {
            List<EntitledServiceData> createEntitledServiceResponse = CreateEntitledServiceApexAction.createEntitledService(esDataList);  
            System.assert(false);
        } catch(Exception ex) {
            System.assert(ex != null);
        }
    
        Test.stopTest();
    }

    testmethod static void testExecuteCreateEntitledService_Exception() {
        Test.startTest();

        List<EntitledServiceData> esDataList = new List<EntitledServiceData>();

        try{
            List<EntitledServiceData> createEntitledServiceResponse = CreateEntitledServiceApexAction.createEntitledService(esDataList);
        } catch(Exception ex) {
            System.assert(ex != null);
        }
        
        Test.stopTest();
    }
}