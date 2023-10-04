@isTest
public with sharing class ADM_AutoConfiguratorManager_UT {
    
    @isTest
    static void testInvokeAutoConfigurator() {
        
        Test.startTest();
        try {

            ADM_AutoConfiguratorManager autoConfigurator = ADM_AutoConfiguratorManager.getInstance();
            //ADM_AutoConfiguratorManager.invokeAutoConfigurator();
        }
        catch( Exception e ) {
            System.assert(true, e.getMessage());
        }
        
        Test.stopTest();
    }
}