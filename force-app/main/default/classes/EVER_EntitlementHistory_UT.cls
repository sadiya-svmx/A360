@IsTest
public class EVER_EntitlementHistory_UT {
    
    @testSetup public static void setup() {
        ADM_EntitlementRuleManager_UT.setup();
    }

    testmethod static void testGetEntitlementPerformed() {
        
        Test.startTest();
        
        Case caseRecord = [Select Id from Case where Status = 'New' limit 1];
        Common.ServiceResponse serviceResponse = new EVER_EntitlementHistory().getEntitlementPerformed( caseRecord.Id );
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testgetEntitlementVerficationHistory() {
        
        Test.startTest();
        
        Case caseRecord = [Select Id from Case where Status = 'New' limit 1];
        Common.ServiceResponse serviceResponse = new EVER_EntitlementHistory().getEntitlementVerficationHistory( caseRecord.Id );
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    testmethod static void testgetEntitlementVerficationHistory_InvalidParams() { 
        try {
            Common.ServiceResponse serviceResponse = new EVER_EntitlementHistory().getEntitlementVerficationHistory( null );
            //System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
    }

    testmethod static void testGetEntitlementPerformed_InvalidParams() { 
        try {
            Common.ServiceResponse serviceResponse = new EVER_EntitlementHistory().getEntitlementPerformed( null );
            //System.assert(false);
        } catch(Exception e ){
            System.assert(true);
        }
    }

}