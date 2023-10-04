@isTest
public class ADM_ServicemaxTagTriggerHandler_UT {
    testmethod static void testInsertUnMatchedRecord() {
        SVMXA360__CONF_ServicemaxTags__c tag = new SVMXA360__CONF_ServicemaxTags__c();
        tag.SVMXA360__Context__c = 'Mytest1';
        tag.SVMXA360__MasterText__c = 'Mytest master text';
        SVMXA360__CONF_ServicemaxTags__c tag1 = new SVMXA360__CONF_ServicemaxTags__c();
        tag1.SVMXA360__Context__c = 'Mytest';
        tag1.SVMXA360__MasterText__c = 'Mytest master text';


        List<SVMXA360__CONF_ServicemaxTags__c> tagList =
            new List<SVMXA360__CONF_ServicemaxTags__c>();
        tagList.add(tag);
        tagList.add(tag1);
       
        try{
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(tagList,false);
            test.stopTest();
            boolean isTestSuccess = true;
            for (Database.SaveResult sr : srList) {   
                if(sr.getErrors().size()>0)      {
                    isTestSuccess = false;
                    break;
                } 
            }
            System.assertEquals(true, isTestSuccess);
        }catch(DMLException e){
            System.assert(false);
        }
    }


    testmethod static void testInsertMatchedRecord() {
        SVMXA360__CONF_ServicemaxTags__c tag = new SVMXA360__CONF_ServicemaxTags__c();
        tag.SVMXA360__Context__c = 'Mytest';
        tag.SVMXA360__MasterText__c = 'Mytest master text';
        SVMXA360__CONF_ServicemaxTags__c tag1 = new SVMXA360__CONF_ServicemaxTags__c();
        tag1.SVMXA360__Context__c = 'Mytest';
        tag1.SVMXA360__MasterText__c = 'Mytest master text';


        List<SVMXA360__CONF_ServicemaxTags__c> tagList =
            new List<SVMXA360__CONF_ServicemaxTags__c>();
        tagList.add(tag);
        tagList.add(tag1);
       
        try{
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(tagList,false);
            test.stopTest();
            boolean isTestSuccess = false;
            for (Database.SaveResult sr : srList) {   
                if(sr.getErrors().size()>0)      {
                    isTestSuccess = true;
                    break;
                } 
            }
            System.assertEquals(true, isTestSuccess);
        }catch(DMLException e){
            System.assert(false);
        }
        
    }

     testmethod static void testInsertRecord() {
        SVMXA360__CONF_ServicemaxTags__c tag = new SVMXA360__CONF_ServicemaxTags__c();
        tag.SVMXA360__Context__c = 'Mytest1';
        tag.SVMXA360__MasterText__c = 'Mytest master text';
        insert tag;
        SVMXA360__CONF_ServicemaxTags__c tag1 = new SVMXA360__CONF_ServicemaxTags__c();
        tag1.SVMXA360__Context__c = 'Mytest';
        tag1.SVMXA360__MasterText__c = 'Mytest master text';


        List<SVMXA360__CONF_ServicemaxTags__c> tagList =
            new List<SVMXA360__CONF_ServicemaxTags__c>();
        tagList.add(tag1);
       
        try{
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(tagList,false);
            test.stopTest();
            boolean isTestSuccess = true;
            for (Database.SaveResult sr : srList) {   
                if(sr.getErrors().size()>0)      {
                    isTestSuccess = false;
                    break;
                } 
            }
            System.assertEquals(true, isTestSuccess);
        }catch(DMLException e){
            System.assert(false);
        }
        
    }

     testmethod static void testInsertExistingRecord() {
        SVMXA360__CONF_ServicemaxTags__c tag = new SVMXA360__CONF_ServicemaxTags__c();
        tag.SVMXA360__Context__c = 'Mytest';
        tag.SVMXA360__MasterText__c = 'Mytest master text';
        insert tag;
        SVMXA360__CONF_ServicemaxTags__c tag1 = new SVMXA360__CONF_ServicemaxTags__c();
        tag1.SVMXA360__Context__c = 'Mytest';
        tag1.SVMXA360__MasterText__c = 'Mytest master text';


        List<SVMXA360__CONF_ServicemaxTags__c> tagList =
            new List<SVMXA360__CONF_ServicemaxTags__c>();
        tagList.add(tag1);
       
        try{
            Test.startTest();
            Database.SaveResult[] srList = Database.insert(tagList,false);
            test.stopTest();
            boolean isTestSuccess = false;
            for (Database.SaveResult sr : srList) {   
                if(sr.getErrors().size()>0)      {
                    isTestSuccess = true;
                    break;
                } 
            }
            System.assertEquals(true, isTestSuccess);
        }catch(DMLException e){
            System.assert(false);
        }
        
    }

}