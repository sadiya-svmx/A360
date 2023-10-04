@isTest
public with sharing class COMM_SvmxQueryService_UT {
    @testSetup public static void setup() {
        COMM_DatabaseUtils_UT.setup();
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LookupConfiguration__c', 5);
    }
    
    @isTest static void testQueryRecords_id() {
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMapping = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c LIMIT 1];
        
        Config.FilterCriteria filterCriteria = new Config.FilterCriteria();
        filterCriteria.id = objectMapping.id;
        filterCriteria.objectName = 'SVMXA360__CONF_ObjectMapping__c';
        filterCriteria.fields = new List<String>{'id'};
        
        Common.ServiceResponse serviceResponse = new COMM_SvmxQueryService().queryRecords( filterCriteria );
        
        System.assert( serviceResponse != null, 'Something went wrong.' );
        System.assert( serviceResponse.success == true, 'Something went wrong.' );
         
        Test.stopTest();
    }
    
    @isTest static void testQueryRecords_like() {
        
        Test.startTest();
        
        Config.FilterCriteria filterCriteria = new Config.FilterCriteria();
        filterCriteria.searchTerm = 'Default';
        filterCriteria.objectName = 'SVMXA360__CONF_ObjectMapping__c';
        filterCriteria.fields = new List<String>{'id'};
        filterCriteria.whereClause = 'Name != null';
        
        Common.ServiceResponse serviceResponse = new COMM_SvmxQueryService().queryRecords( filterCriteria );
        
        System.assert( serviceResponse != null, 'Something went wrong.' );
        System.assert( serviceResponse.success == true, 'Something went wrong.' );
        
        Test.stopTest();
    }
    
    @isTest static void testQueryRecords_missingParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new COMM_SvmxQueryService().queryRecords( new Config.FilterCriteria() );
        
        System.assert( serviceResponse != null, 'Something went wrong.' );
        System.assert( serviceResponse.success == false, 'Something went wrong.' );
        
        Test.stopTest();
    }
    
    testmethod static void testQueryRecords_invalid() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new COMM_SvmxQueryService().queryRecords( null );
        
        System.assert( serviceResponse != null, 'Something went wrong.' );
        System.assert( serviceResponse.success == false, 'Something went wrong.' );
        
        Test.stopTest();
    }
    
    @isTest static void testGetLookupConfigRecords () {
        
        Test.startTest();
        
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [select id,Name,SVMXA360__DeveloperName__c from SVMXA360__CONF_LookupConfiguration__c];
        
        Config.FilterCriteria filterCriteria = new Config.FilterCriteria(); 
        filterCriteria.objectName = 'SVMXA360__CONF_LookupConfiguration__c';
        filterCriteria.fields = new List<String>{'id','Name','SVMXA360__DeveloperName__c'};
        filterCriteria.developerNames = new List<String>{lookupConfigList[0].SVMXA360__DeveloperName__c };
        
        Common.ServiceResponse serviceResponse = new COMM_SvmxQueryService().queryRecords( filterCriteria );
        
        System.assert( serviceResponse != null , 'Something went wrong.');
        System.assert( serviceResponse.success == true, 'Something went wrong.' );
        List<SVMXA360__CONF_LookupConfiguration__c>  objLookupConfigList= (List<SVMXA360__CONF_LookupConfiguration__c>) serviceResponse.data;
        System.assertEquals( lookupConfigList[0].Id, objLookupConfigList[0].Id, 'Something went wrong.');
        
        Test.stopTest();
    }
}