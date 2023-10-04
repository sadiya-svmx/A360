@isTest
public class EntitlementTriggerHandler_UT {

    @testSetup public static void setup() {
        EVER_EntitledServiceManager_UT.setup();
    }

    static testmethod void testDeleteES() {

        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();
        List<Entitlement> lstEntitlement = [SELECT Id, RecordType.Name FROM Entitlement 
            WHERE RecordTypeId = :recordTypeId];
        Test.startTest();

        try {
            delete lstEntitlement[0];
        }catch(DMLException e){
            System.assert(false, 'failed as exception occures: ' + e.getMessage());
        }

        Test.stopTest();
    }

    static testmethod void testDeleteESHavingCPLI() {

        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();
        List<Entitlement> lstEntitlement = [SELECT Id, RecordType.Name FROM Entitlement 
            WHERE RecordTypeId = :recordTypeId];

        SVMXA360__ContractPriceLineItem__c cpli = new SVMXA360__ContractPriceLineItem__c();
        cpli.SVMXA360__EntitledServiceId__c = lstEntitlement[0].Id;
        cpli.SVMXA360__EntitledDiscount__c = 10;
        insert cpli;

        Test.startTest();

        try {
            delete lstEntitlement[0];
        }catch(DMLException e){
            System.assert(e.getMessage().contains(Label.Message_CLIDeleteErrorForCPLI));
        }

        Test.stopTest();
    }

}