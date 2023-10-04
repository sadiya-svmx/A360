@IsTest
public  class ADM_ConfigurationUsageService_UT {

    private static String jsonData = ' [{"entityType": "RecordPage","entityLabel" : "A360 - Work Order Record Page","entityName" : "SVMXA360__WorkOrderRecordPage"}]';

     testmethod static void testGetAllConfigurationUsages() {
        ADM_ConfigurationUsageService config = new ADM_ConfigurationUsageService();
        config.saveConfigurationUsages((List<Adm.ConfigurationUsage>)JSON.deserialize(jsonData, List<Adm.ConfigurationUsage>.class));
        Test.startTest();
        Common.ServiceResponse response = config.getAllConfigurationUsages();
        System.assert(response.data != null,'Response data should not be null');
        System.assert(((List<Adm.ConfigurationUsage>)response.data).size() >0,'Response data should not be empty');
        Test.stopTest();
     }


     testmethod static void testSaveConfigurationUsages() {
        ADM_ConfigurationUsageService config = new ADM_ConfigurationUsageService();
        Test.startTest();
        config.saveConfigurationUsages((List<Adm.ConfigurationUsage>)JSON.deserialize(jsonData, List<Adm.ConfigurationUsage>.class));
        Common.ServiceResponse response = config.getAllConfigurationUsages();
        System.assert(response.data != null,'Response data should not be null');
        System.assert(((List<Adm.ConfigurationUsage>)response.data).size() >0,'Response data should not be empty');
        Test.stopTest();
     }
   
}