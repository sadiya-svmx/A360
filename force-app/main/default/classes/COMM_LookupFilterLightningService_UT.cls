/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Test class of COMM_LookupFilterLightningService.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant keni           24 Aug 2020       Created.
 *****************************************************************************************************/
@isTest
public with sharing class COMM_LookupFilterLightningService_UT {

    @testSetup public static void setup() {
        
        SVMXA360__CONF_Expression__c expressionAccRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Account',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '1',
                                                                                                                        'SVMXA360__Criteria__c' => 'AccountNumber = \'ACC001\''
                                                                                                                        });
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c', 
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionAccRec.id,
                                                  'SVMXA360__FieldAPIName__c' => 'AccountNumber',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'ACC001',
                                                  'SVMXA360__RelatedObjectDetails__c' => '',
                                                  'SVMXA360__LiteralRelatedObjectDetails__c' => '',
                                                  'SVMXA360__RelationshipFieldAPIName__c' => '',
                                                  'SVMXA360__RelationshipName__c' => '',
                                                  'SVMXA360__LiteralParameter__c' => '',
                                                  'SVMXA360__FieldType__c' => 'Text',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__OperandType__c' => 'Value'}, 1);

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_LookupConfiguration__c', 
                                              new Map<String,Object>{'SVMXA360__BasicFilter__c' => expressionAccRec.id,
                                                  'SVMXA360__DefaultOperator__c' => 'Contains',
                                                  'SVMXA360__DefaultLookupforObject__c' => true,
                                                  'Name' => 'Account Lookup Filter',
                                                  'SVMXA360__DeveloperName__c' => 'Account_Lookup',
                                                  'SVMXA360__FieldToReturn__c' => 'Name',
                                                  'SVMXA360__DisplayFields__c' => 'AccountSource',
                                                  'SVMXA360__ObjectAPIName__c' => 'Account',
                                                  'SVMXA360__SearchFields__c' => 'AccountNumber,Name',
                                                  'SVMXA360__RecordsPerPageReturn__c' => 10,
                                                  'SVMXA360__Description__c' => 'Test Account lookup filter record.'}, 1);                                                          
        
        Account accRec = (Account) SvmxTestDataFactory.insertSObject('Account', 
                                                        new Map<String,Object>{
                                                        'Name' => 'Test Account Expression Handler',
                                                        'AccountNumber' => 'ACC001'
                                                        });

        Opportunity oppRec = (Opportunity) SvmxTestDataFactory.insertSObject('Opportunity', 
                                                        new Map<String,Object>{
                                                        'Name' => 'Test Opportunity Expression Handler'
                                                        });
        
        
    }

    static testmethod void testGetLookupConfigData_emptyId() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getLookupConfigData('','','');
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetLookupConfigData_nullId() {
        
        Test.startTest();
     
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getLookupConfigData(null, null, null);
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetLookupConfigData_invalidId() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getLookupConfigData(acc.Id, 'Account', 'Name');
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    static testmethod void testGetLookupConfigData_validData() {
        
        SVMXA360__CONF_LookupConfiguration__c lkpFilter = [Select Id from SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getLookupConfigData(lkpFilter.Id, 'Account', 'Name');
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    static testmethod void testGetFilteredRecords_emptyJSON() {

        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords('');
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    static testmethod void testGetFilteredRecords_invalidJSON1() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String  requestJson = '{"searchTerm" : "test", "lookupConfigId" : "'+acc.Id+'", "searchOperator" : "equals"}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    static testmethod void testGetFilteredRecords_invalidJSON2() {
        
        String  requestJson = '{"searchTerm" : "test", "lookupConfigId" : "", "searchOperator" : "equals"}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    static testmethod void testGetFilteredRecords_validJSON1() {
        SVMXA360__CONF_LookupConfiguration__c lkpFilter = [Select Id from SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        String  requestJson = '{"searchTerm" : "ACC001", "lookupConfigId" : "'+lkpFilter.Id+'", "searchOperator" : "equals"}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    static testmethod void testGetFilteredRecords_validJSON2() {
        SVMXA360__CONF_LookupConfiguration__c lkpFilter = [Select Id from SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        String  requestJson = '{"searchTerm" : "ACC001", "lookupConfigId" : "'+lkpFilter.Id+'", "searchOperator" : "contains"}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    static testmethod void testGetFilteredRecords_validJSON3() {
        SVMXA360__CONF_LookupConfiguration__c lkpFilter = [Select Id from SVMXA360__CONF_LookupConfiguration__c LIMIT 1];
        String  requestJson = '{"searchTerm" : "ACC001", "lookupConfigId" : "'+lkpFilter.Id+'", "searchOperator" : "starts with"}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }  

    static testmethod void testGetFilteredRecords_validJSON4() {
        SVMXA360__CONF_LookupConfiguration__c lkpFilter = [Select Id from SVMXA360__CONF_LookupConfiguration__c LIMIT 1];

        Account acc = [SELECT AccountNumber FROM Account LIMIT 1];
        
        String  requestJson = '{"searchTerm" : "ACC001", "lookupConfigId" : "'+lkpFilter.Id+'", "searchOperator" : "ends with", "lookupMatchingField" : "AccountNumber", "lookupContext" : "'+acc.AccountNumber+'","applyContextFilter":true}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFilteredRecords_validJSON5() {
        SVMXA360__CONF_LookupConfiguration__c lkpFilter = [Select Id from SVMXA360__CONF_LookupConfiguration__c LIMIT 1];

        Account acc = [SELECT AccountNumber FROM Account LIMIT 1];
        
        String  requestJson = '{"id" : "'+acc.Id+'", "objectName" : "Account", "referenceNameField" : "Name"}';
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_LookupFilterLightningService.getFilteredRecords(requestJson);
        System.debug('..serviceResponse' + serviceResponse);
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }
}