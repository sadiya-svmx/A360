@IsTest
public class SCON_ServiceContractPlanTrgHandler_UT {

    @testSetup public static void setup() {
        SCON_ServiceContractPlanManager_UT.setup();
    }

    testmethod static void testPreventDuplicateCPLIPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        contractPriceLineItemPlanList.get(0).id = null;
        contractPriceLineItemPlanList.get(0).expenseItem = 'Parking';
        
        Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlanList.get(0));
        
        System.assert( contractPriceLineItemPlan != null );
        System.assert( contractPriceLineItemPlan.id != null );
    }
    
    static testmethod void testDuplicateCPLIPlan_Insert() {
        
        Test.startTest();
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        contractPriceLineItemPlanList.get(0).id = null;
        
        try{
            //Create duplicate record 
            Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlanList.get(0));
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        
        Test.stopTest();
    }

    static testmethod void testDuplicateCPLIPlan_Update() {
        
        Test.startTest();
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractPriceLineItemPlans(serviceContractPlanRecord.id);
        
        if (contractPriceLineItemPlanList.get(0).expenseItem != 'Toll') {
            contractPriceLineItemPlanList.get(0).expenseItem = 'Toll';
        } else {
            contractPriceLineItemPlanList.get(0).expenseItem = 'Airfare';
        }        
        contractPriceLineItemPlanList.get(0).uniqueKey = null;        
        
        try{
            Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractPriceLineItemPlan(contractPriceLineItemPlanList.get(0));
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }

        Test.stopTest();
    }

    static testmethod void testDuplicateCPLIPlanList() {
        
        Test.startTest();
        
        //Insert contract price line item plans
        final List<SVMXA360__ContractPriceLineItemPlan__c> contractPriceLineItemPlanList = (List<SVMXA360__ContractPriceLineItemPlan__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__ContractPriceLineItemPlan__c', 5);
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        for( Integer index = 0; index < 5; index++ ) {
            
            contractPriceLineItemPlanList.get(index).SVMXA360__ServiceContractPlanId__c = serviceContractPlanRecord.Id;                     
            contractPriceLineItemPlanList.get(index).SVMXA360__LineType__c = 'Travel';
            contractPriceLineItemPlanList.get(index).SVMXA360__EntitledPrice__c = null;
            contractPriceLineItemPlanList.get(index).SVMXA360__Surcharge__c = null;
            contractPriceLineItemPlanList.get(index).SVMXA360__EntitledDiscount__c = null;
        }
        
        try{

            insert contractPriceLineItemPlanList;            
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }
    
    testmethod static void testPreventDuplicateCLIPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        contractLineItemPlanList.get(0).id = null;
        contractLineItemPlanList.get(0).productId = null;
        contractLineItemPlanList.get(0).productFamily = 'Service';
        
        Scon.ContractLineItemPlan contractLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlan(contractLineItemPlanList.get(0));
        
        System.assert( contractLineItemPlan != null );
        System.assert( contractLineItemPlan.id != null );
    }
    
    static testmethod void testDuplicateCLIPlan() {
        
        Test.startTest();
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        List<Scon.ContractLineItemPlan> contractLineItemPlanList = SCON_ServiceContractPlanManager.getInstance().getContractLineItemPlans(serviceContractPlanRecord.id);
        contractLineItemPlanList.get(0).id = null;
        
        try{
            //Create duplicate record 
            Scon.ContractLineItemPlan contractLineItemPlan = SCON_ServiceContractPlanManager.getInstance().saveContractLineItemPlan(contractLineItemPlanList.get(0));
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    testmethod static void testPreventDuplicateESPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
            
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        entitledServicePlanList.get(0).id = null;
        entitledServicePlanList.get(0).serviceProductId = null;
        
        Scon.EntitledServicePlan entitledServicePlan = SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(entitledServicePlanList.get(0));
        
        System.assert( entitledServicePlan != null );
        System.assert( entitledServicePlan.id != null );
    }
    
    static testmethod void testDuplicateESPlan() {
        
        Test.startTest();
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<Scon.EntitledServicePlan> entitledServicePlanList = SCON_ServiceContractPlanManager.getInstance().getEntitledServicePlans(serviceContractPlanRecord.id);
        entitledServicePlanList.get(0).id = null;
        
        try{
            //Create duplicate record 
            Scon.EntitledServicePlan entitledServicePlan = SCON_ServiceContractPlanManager.getInstance().saveEntitledServicePlan(entitledServicePlanList.get(0));
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testDuplicateESPlanList() {
        
        Test.startTest();
        
        //Insert ES Plans
        final List<SVMXA360__EntitledServicePlan__c> entitledServicePlanList = (List<SVMXA360__EntitledServicePlan__c>) SvmxTestDataFactory.createSObjectList('SVMXA360__EntitledServicePlan__c', 5);
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        for( Integer index = 0; index < 5; index++ ) {            
            entitledServicePlanList.get(index).SVMXA360__ServiceContractPlanId__c = serviceContractPlanRecord.Id;                     
            entitledServicePlanList.get(index).SVMXA360__EntitledServiceDuration__c = 10;
            entitledServicePlanList.get(index).SVMXA360__EntitledServiceUnitOfTime__c = 'Days';
            entitledServicePlanList.get(index).SVMXA360__CaseEntitlementProcess__c = null;
            entitledServicePlanList.get(index).SVMXA360__WorkOrderEntitlementProcess__c = null;
            entitledServicePlanList.get(index).SVMXA360__ServiceUnit__c = 'Amount';
            entitledServicePlanList.get(index).SVMXA360__EntitledServiceProductId__c = null;
        }        
        try{
            insert entitledServicePlanList;            
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }
    
    testmethod static void testValidateDurationOfContractPlan() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id,SVMXA360__ContractTermDuration__c,SVMXA360__ContractTermUnitOfTime__c FROM SVMXA360__ServiceContractPlan__c limit 1];
        
        serviceContractPlanRecord.SVMXA360__ContractTermDuration__c = 10;
        serviceContractPlanRecord.SVMXA360__ContractTermUnitOfTime__c = 'Years';
        update serviceContractPlanRecord;     
        System.assert( serviceContractPlanRecord != null );
        System.assert( serviceContractPlanRecord.id != null );  
        
    }
    
    testmethod static void testVallidateCSPlan_NoDuration() {
        
        final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id,SVMXA360__ContractTermDuration__c,SVMXA360__ContractTermUnitOfTime__c FROM SVMXA360__ServiceContractPlan__c limit 1];
        
        try{
            serviceContractPlanRecord.SVMXA360__ContractTermDuration__c = null;
            serviceContractPlanRecord.SVMXA360__ContractTermUnitOfTime__c = null;
            update serviceContractPlanRecord;            
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
    }
    
    static testmethod void testDuplicateOfferedMPT() {
        
        Test.startTest();
        
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        
        List<SVMXA360__MaintenancePlanTemplate__c> mptList = [Select id from SVMXA360__MaintenancePlanTemplate__c];
        List<SVMXA360__OfferedMaintenancePlanTemplate__c> offeredMPTList = new List<SVMXA360__OfferedMaintenancePlanTemplate__c>();
        for(Integer index=0; index<3; index++){
            SVMXA360__OfferedMaintenancePlanTemplate__c offeredMPT = new SVMXA360__OfferedMaintenancePlanTemplate__c();
            offeredMPT.SVMXA360__ServiceContractPlanId__c=serviceContractPlanRecord.Id;
            offeredMPT.SVMXA360__MaintenancePlanTemplateId__c=mptList[0].Id;        
            offeredMPTList.add(offeredMPT);
        }
        
        try{
            insert offeredMPTList;
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }

    static testMethod void testDuplicateScpProduct() {

        Test.startTest();
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord = [SELECT Id FROM SVMXA360__ServiceContractPlan__c];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

            serviceContractPlanRecord.SVMXA360__ServicePlanProductId__c = product.Id;
            update serviceContractPlanRecord;
            try{
                final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord1 = 
                (SVMXA360__ServiceContractPlan__c) SvmxTestDataFactory.insertSObject('SVMXA360__ServiceContractPlan__c',
                                                                                    new Map<String,Object>{
                                                                                        'SVMXA360__ContractTermDuration__c' => 1,
                                                                                        'SVMXA360__ContractTermUnitOfTime__c' => 'Years',
                                                                                        'SVMXA360__ServicePlanProductId__c' => product.Id
                                                                                    });
                System.assert(false);
            }
            catch(Exception e){
                
                System.assert(true);
            }
        Test.stopTest();
    }
}