@isTest
public class ContractLineItemTriggerHandler_UT {

    @testSetup public static void setup() {
        CLI_ContractLines_LS_UT.setup();
    }

    static testmethod void testDeleteCLI() {
        
        Test.startTest();
        
        List<contractLineItem> lstCLI = [SELECT Id FROM contractLineItem];

        try {
            delete lstCLI;
        }catch(DMLException e){
            System.assert(false);
        }

        Test.stopTest();
    }

    static testmethod void testDeleteCLIHavingES() {

        Test.startTest();

        List<contractLineItem> lstCLI = [SELECT Id, ServiceContract.AccountId FROM contractLineItem];

        Entitlement entitlement = new Entitlement();
        entitlement.Name = 'ES 01';
        entitlement.AccountId = lstCLI[0].ServiceContract.AccountId;
        entitlement.ContractLineItemId = lstCLI[0].Id;
        insert entitlement;

        try {
            delete lstCLI[0];
        }catch(DMLException e){
            System.assert(e.getMessage().contains(Label.Message_CLIDeleteErrorForEs));
        }

        Test.stopTest();
    }

    static testmethod void testDeleteCLIHavingCPLI() {

        Test.startTest();

        List<contractLineItem> lstCLI = [SELECT Id, ServiceContract.AccountId FROM contractLineItem];

        SVMXA360__ContractPriceLineItem__c cpli = new SVMXA360__ContractPriceLineItem__c();
        cpli.SVMXA360__ContractLineId__c = lstCLI[0].Id;
        cpli.SVMXA360__EntitledDiscount__c = 10;
        insert cpli;

        try {
            delete lstCLI[0];
        }catch(DMLException e){
            System.assert(e.getMessage().contains(Label.Message_CLIDeleteErrorForCPLI));
        }

        Test.stopTest();
    }

    static testmethod void testDeleteCLIHavingChild() {

        Test.startTest();

        List<contractLineItem> lstCLI = [SELECT Id, ServiceContract.AccountId FROM contractLineItem];

        Entitlement entitlement = new Entitlement();
        entitlement.Name = 'ES 01';
        entitlement.AccountId = lstCLI[0].ServiceContract.AccountId;
        entitlement.ContractLineItemId = lstCLI[0].Id;
        insert entitlement;

        SVMXA360__ContractPriceLineItem__c cpli = new SVMXA360__ContractPriceLineItem__c();
        cpli.SVMXA360__ContractLineId__c = lstCLI[0].Id;
        cpli.SVMXA360__EntitledDiscount__c = 10;
        insert cpli;

        try {
            delete lstCLI[0];
        }catch(DMLException e){
            System.assert(e.getMessage().contains(Label.Message_CLIDeleteError));
        }

        Test.stopTest();
    }
}