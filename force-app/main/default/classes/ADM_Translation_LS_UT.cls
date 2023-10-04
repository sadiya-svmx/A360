@istest
public class ADM_Translation_LS_UT {

    private static User getCurrentUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

   @testSetup public static void setup() {

      SVMXA360__CONF_ServicemaxTags__c record = (SVMXA360__CONF_ServicemaxTags__c) SvmxTestDataFactory.insertSObject(    
           'SVMXA360__CONF_ServicemaxTags__c', 
            new Map<String,Object>{
               'SVMXA360__MasterText__c' => 'test',
               'SVMXA360__Context__c' => 'title'
               });
    }
   
   static testMethod void testGetAllTranslations() {
      Test.startTest();
      List<Adm.TranslationTag> retList = ADM_Translation_LS.getTranslations('en_US');
      Test.stopTest();
      System.assertEquals (retList.size(), 1, 'trasnlations returned should be one');
   }

   static testMethod void testGetAllTranslationsWithNullParams() {
      try{
         Test.startTest();
         List<Adm.TranslationTag> retList = ADM_Translation_LS.getTranslations(null);  
         Test.stopTest();
         system.assert(false, 'on null params, it should throw error');
      }catch(Exception e){
         System.assert(true);
      }
   }

   static testMethod void testGetTagDetails() {
     
      System.runAs(getCurrentUser()) {
         Test.startTest();
         List<Adm.TranslationTag> retAllList = ADM_Translation_LS.getTranslations('en_US');
         List<Adm.TranslationTag> retList = ADM_Translation_LS.getTagDetails(retAllList[0].tagId);
         Test.stopTest();
         System.assertEquals ( 0,retList.size(), 'trasnlations returned should be one');
      }     
   }

   static testMethod void testGetTagDetailsWithNullParams() {
      try{
         Test.startTest();
         List<Adm.TranslationTag> retList = ADM_Translation_LS.getTagDetails(null);
         Test.stopTest();
         system.assert(false, 'on null params, it should throw error');
      }catch(Exception e){
         System.assert(true);
      }
   }

   static testMethod void testGetTranslationContexts() {
     
      System.runAs(getCurrentUser()) {
         Test.startTest();
        
         List<Adm.option> retList = ADM_Translation_LS.getTranslationContexts();
         Test.stopTest();
         System.assert (retList.size()>0, 'trasnlations returned atleast should be one');
      }     
   }

   static testMethod void testGetSupportedLanguages() {
     
      System.runAs(getCurrentUser()) {
         Test.startTest();
        
         List<Adm.option> retList = ADM_Translation_LS.getSupportedLanguages();
         Test.stopTest();
         System.assert (retList.size()>0, 'trasnlations returned atleast should be one');
      }     
   }

   static testMethod void testUpsertTranslatedTags() {
      try{
         Test.startTest();
         Adm.TranslationTag tag = ADM_Translation_LS.getTranslations('en_US')[0];
         tag.language = 'en_US';
         tag.translatedValue = 'en-test';
         List<Adm.TranslationTag> tagList = new List<Adm.TranslationTag>();
         tagList.add(tag);
         Common.ServiceResponse response = ADM_Translation_LS.upsertTranslatedTags(JSON.serialize(tagList));
         Test.stopTest();
         System.assert(true);
      }catch(Exception e){
         System.assert(false);
      }
      
     
   }
    
   static testMethod void testupsertTranslatedTagsByContextAndMasterText() {
      try{
         Test.startTest();
         Adm.TranslationTag tag = ADM_Translation_LS.getTranslations('en_US')[0];
         tag.language = 'en_US';
         tag.translatedValue = 'en-test';
          tag.masterText = 'test'; 
          tag.context = 'title'; 
         List<Adm.TranslationTag> tagList = new List<Adm.TranslationTag>();
         tagList.add(tag);
         Common.ServiceResponse response = ADM_Translation_LS.upsertTranslatedTagsByContextAndMasterText(JSON.serialize(tagList));
         Test.stopTest();
         System.assert(true);
      }catch(Exception e){
         System.assert(false);
      }
      
     
   }

   static testMethod void testUpsertTranslatedTagsForInvalidInput() {
      System.runAs(getCurrentUser()) {
         Test.startTest();
         try{
            Common.ServiceResponse response = ADM_Translation_LS.upsertTranslatedTags('dummy');
            System.assertEquals(false, response.success,'on invalid param, error should be thrown');
         }catch(Exception e){
            System.assert(true);
         }
         Test.stopTest();
         
      }     
   }

}