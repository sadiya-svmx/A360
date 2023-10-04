@IsTest
public  class ADM_ApplicationConfigService_UT {

    private static String jsonData = ' [{"masterText": "Return Order Management","context" : "wizardTitle","key" : "Return Order Management_wizardTitle","languageValues" : [{"name" : "fi","value" : "Palautustilaus Management"},{"name" : "de","value" : "Verwaltung von Rückgabeaufträgen"}, {"name" : "nl","value" : "Beheer van retourorders"}]}]';

     testmethod static void testgetAllConfigTranslations() {
        ADM_ApplicationConfigService config = new ADM_ApplicationConfigService();
        config.saveConfigTranslations((List<Adm.SvmxTranslations>)JSON.deserialize(jsonData, List<Adm.SvmxTranslations>.class));
        Test.startTest();
        Common.ServiceResponse response = config.getAllConfigTranslations();
        System.assert(response.data != null,'Response data should not be null');
        System.assert(((List<Adm.SvmxTranslations>)response.data).size() >0,'Response data should not be empty');
        Test.stopTest();
     }


     testmethod static void testSaveConfigTranslations() {
        ADM_ApplicationConfigService config = new ADM_ApplicationConfigService();
        Test.startTest();
        config.saveConfigTranslations((List<Adm.SvmxTranslations>)JSON.deserialize(jsonData, List<Adm.SvmxTranslations>.class));
        Common.ServiceResponse response = config.getAllConfigTranslations();
        System.assert(response.data != null,'Response data should not be null');
        System.assert(((List<Adm.SvmxTranslations>)response.data).size() >0,'Response data should not be empty');
        Test.stopTest();
     }

    testmethod static void testsaveConfigTranslationsOnCorruptData() {
        ADM_ApplicationConfigService config = new ADM_ApplicationConfigService();
        Test.startTest();
        try{
            Common.ServiceResponse response = config.saveConfigTranslations(null);
            System.assert(response.success == false,'Save translation with corrupt datat should return sucess flag as false');
        }catch(Exception e){
            System.assert(true);
        }
        
        Common.ServiceResponse response = config.getAllConfigTranslations();
        System.assert(response.data != null,'Response data should not be null');
        System.assert(((List<Adm.SvmxTranslations>)response.data).size() ==0,'Response data should  be empty');
        Test.stopTest();
     }
   
}