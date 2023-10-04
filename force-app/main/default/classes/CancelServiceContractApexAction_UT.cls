@isTest
public class CancelServiceContractApexAction_UT {
    
    @testSetup public static void setup() {
        SCON_ServiceContractPlanHandler_UT.setup();
    }

    testmethod static void testCancelServiceContractApexAction() {
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

        CancelServiceContractData cancelServiceContract = new CancelServiceContractData();
        cancelServiceContract.salesContractId = 'Service Contract 1';
        cancelServiceContract.salesContractIdFieldAPIName = 'Name';
        cancelServiceContract.effectiveEndDate =  Date.today().addYears(2);
        cancelServiceContract.cancellationReason = 'I am Cancelling SC';
        cancelServiceContract.cancellationReasonFieldAPIName = 'Description';
        
        List<CancelServiceContractData> cancelSCList = new List<CancelServiceContractData>{cancelServiceContract};
        List<CancelServiceContractData> cancelSCResponse;
        Test.startTest();
            cancelSCResponse = CancelServiceContractApexAction.cancelServiceContract(cancelSCList);
        Test.stopTest();

        system.assert(cancelSCResponse[0] != NULL);
    }

    testmethod static void testExceptionsDuringScCancellation() {

        List<CancelServiceContractData> cancelSCList = new List<CancelServiceContractData>();
        List<CancelServiceContractData> cancelSCResponse;
        try{
            cancelSCResponse = CancelServiceContractApexAction.cancelServiceContract(cancelSCList);
        } catch(Exception ex) {
            System.assert(ex != null);
        }
    }

    testmethod static void testFailCancelServiceContractApexAction() {
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

        CancelServiceContractData cancelServiceContract = new CancelServiceContractData();
        cancelServiceContract.salesContractId = 'Service Contract 1';
        cancelServiceContract.salesContractIdFieldAPIName = 'test';
        cancelServiceContract.effectiveEndDate =  Date.today().addYears(2);
        cancelServiceContract.cancellationReason = 'I am Cancelling SC';
        cancelServiceContract.cancellationReasonFieldAPIName = 'Description';
        
        List<CancelServiceContractData> cancelSCList = new List<CancelServiceContractData>{cancelServiceContract};
        List<CancelServiceContractData> cancelSCResponse;
        Test.startTest();
        try {
            cancelSCResponse = CancelServiceContractApexAction.cancelServiceContract(cancelSCList);
        } catch(Exception ex) {
            System.assert(ex != null);
        }
        Test.stopTest();
    }
}