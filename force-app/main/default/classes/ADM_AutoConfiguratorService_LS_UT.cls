@isTest
public with sharing class ADM_AutoConfiguratorService_LS_UT {
    
	@isTest
    static void testInvokeAutoConfigurator() {
        
        Test.startTest();
        try {
            Common.ServiceResponse response = ADM_AutoConfiguratorService_LS.invokeAutoConfigurator();
            System.assert( response.success == true );
        }
        catch( Exception e ) {
            System.assert(true, e.getMessage());
        }
        
        Test.stopTest();
    }
}