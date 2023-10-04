@IsTest
public class CONF_ObjectMappingHandler_UT {
    
    @testSetup public static void setup() {
        
		SVMXA360__CONF_ObjectMapping__c objectMappingRecord = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP001',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping',
                                                                                    'SVMXA360__HeaderRecordObject__c' => 'Case'});
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetails = SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 11);
        objectMappingDetails.get(0).SVMXA360__TargetFieldAPIName__c = 'AccountId';
        objectMappingDetails.get(0).SVMXA360__SourceFieldAPIName__c = 'AccountId';
        objectMappingDetails.get(0).SVMXA360__Type__c  = 'Field';
        
        objectMappingDetails.get(1).SVMXA360__TargetFieldAPIName__c = 'StartDate';
        objectMappingDetails.get(1).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(1).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(1).SVMXA360__Value__c   = 'FsvmxToday';
        
        objectMappingDetails.get(2).SVMXA360__TargetFieldAPIName__c = 'Subject';
        objectMappingDetails.get(2).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(2).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(2).SVMXA360__Value__c   = 'Sample Subject';
        
        objectMappingDetails.get(3).SVMXA360__TargetFieldAPIName__c = 'OwnerId';
        objectMappingDetails.get(3).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(3).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(3).SVMXA360__Value__c   = 'FSVMXCURRENTUSERID';
        
        objectMappingDetails.get(3).SVMXA360__TargetFieldAPIName__c = 'RecordTypeId';
        objectMappingDetails.get(3).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(3).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(3).SVMXA360__Value__c   = 'Depot';
        
        objectMappingDetails.get(4).SVMXA360__TargetFieldAPIName__c = 'LocationId';
        objectMappingDetails.get(4).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(4).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(4).SVMXA360__Value__c   = 'FSVMXNULL';
        
        objectMappingDetails.get(5).SVMXA360__TargetFieldAPIName__c = 'MinimumCrewSize';
        objectMappingDetails.get(5).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(5).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(5).SVMXA360__Value__c   = '5';
        
        objectMappingDetails.get(6).SVMXA360__TargetFieldAPIName__c = 'Tax';
        objectMappingDetails.get(6).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(6).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(6).SVMXA360__Value__c   = '10';

        objectMappingDetails.get(7).SVMXA360__TargetFieldAPIName__c = 'Status';
        objectMappingDetails.get(7).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(7).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(7).SVMXA360__Value__c = 'User';
        objectMappingDetails.get(7).SVMXA360__LiteralParameter__c = 'CreatedBy.Name';
        objectMappingDetails.get(7).SVMXA360__RelatedObjectDetails__c = 'User';
        
        objectMappingDetails.get(8).SVMXA360__TargetFieldAPIName__c = 'Priority';
        objectMappingDetails.get(8).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(8).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(8).SVMXA360__Value__c = 'Current Record';
        objectMappingDetails.get(8).SVMXA360__LiteralParameter__c = 'CreatedBy.Name';
        objectMappingDetails.get(8).SVMXA360__RelatedObjectDetails__c = 'User';
        
        objectMappingDetails.get(9).SVMXA360__TargetFieldAPIName__c = 'SVMXA360__BillingType__c';
        objectMappingDetails.get(9).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(9).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(9).SVMXA360__Value__c = 'Current Record Header';
        objectMappingDetails.get(9).SVMXA360__LiteralParameter__c = 'Id';
        objectMappingDetails.get(9).SVMXA360__RelatedObjectDetails__c = '';
        
        objectMappingDetails.get(10).SVMXA360__TargetFieldAPIName__c = 'SVMXA360__PurposeOfVisit__c';
        objectMappingDetails.get(10).SVMXA360__SourceFieldAPIName__c = 'Account.Name';
        objectMappingDetails.get(10).SVMXA360__Type__c  = 'Field';
        objectMappingDetails.get(10).SVMXA360__RelatedObjectDetails__c = 'Account';
         
                
        insert objectMappingDetails;
        
        SVMXA360__CONF_ObjectMapping__c objectValueMappingRecord = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP002',
                                                                                    'SVMXA360__Type__c' => 'Value Mapping',
                                                                                    'SVMXA360__HeaderRecordObject__c' => 'Case'
                                                                                        });
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectValueMappingDetails = SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectValueMappingRecord.Id}, 5);
        
        objectValueMappingDetails.get(1).SVMXA360__TargetFieldAPIName__c = 'StartDate';
        objectValueMappingDetails.get(1).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(1).SVMXA360__Type__c  = 'Function';
        objectValueMappingDetails.get(1).SVMXA360__Value__c   = 'FsvmxToday';
        
        objectValueMappingDetails.get(0).SVMXA360__TargetFieldAPIName__c = 'Subject';
        objectValueMappingDetails.get(0).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(0).SVMXA360__Type__c  = 'Value';
        objectValueMappingDetails.get(0).SVMXA360__Value__c   = 'Sample Subject';

        objectValueMappingDetails.get(2).SVMXA360__TargetFieldAPIName__c = 'Status';
        objectValueMappingDetails.get(2).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(2).SVMXA360__Type__c  = 'Function';
        objectValueMappingDetails.get(2).SVMXA360__Value__c = 'User';
        objectValueMappingDetails.get(2).SVMXA360__LiteralParameter__c = 'CreatedBy.Name';
        objectValueMappingDetails.get(2).SVMXA360__RelatedObjectDetails__c = 'User';
        
        objectValueMappingDetails.get(3).SVMXA360__TargetFieldAPIName__c = 'Priority';
        objectValueMappingDetails.get(3).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(3).SVMXA360__Type__c  = 'Function';
        objectValueMappingDetails.get(3).SVMXA360__Value__c = 'Current Record';
        objectValueMappingDetails.get(3).SVMXA360__LiteralParameter__c = 'CreatedBy.Name';
        objectValueMappingDetails.get(3).SVMXA360__RelatedObjectDetails__c = 'User';
        
        objectValueMappingDetails.get(4).SVMXA360__TargetFieldAPIName__c = 'SVMXA360__BillingType__c';
        objectValueMappingDetails.get(4).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(4).SVMXA360__Type__c  = 'Function';
        objectValueMappingDetails.get(4).SVMXA360__Value__c = 'Current Record Header';
        objectValueMappingDetails.get(4).SVMXA360__LiteralParameter__c = 'Id';
        objectValueMappingDetails.get(4).SVMXA360__RelatedObjectDetails__c = '';
        
        insert objectValueMappingDetails;
                
        Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');
        SvmxTestDataFactory.insertSObject('Case', new Map<String,Object>{'AccountId' => accountRecord.Id} );
    }
    
    static testmethod void testCreateAndApplyObjectMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().createAndApplyObjectMapping( objectMappingRecord.Id, caseRecord );
        
        System.assert( workOrder.StartDate != null );
        System.assert( workOrder.Subject.equalsIgnoreCase('Sample Subject') );
        System.assert( workOrder.AccountId == caseRecord.AccountId );
        
        Test.stopTest();
    }
    
    static testmethod void testCreateAndApplyObjectMapping_invalidArguments() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        try {
            new CONF_ObjectMappingHandler().createAndApplyObjectMapping( null, caseRecord );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().createAndApplyObjectMapping( objectMappingRecord.Id, null );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_valueMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Value Mapping' LIMIT 1];
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, new WorkOrder() );
        
        System.assert(workOrder != null);
        System.assert(workOrder.StartDate != null);
        System.assert(workOrder.Subject != null);
        System.assert(workOrder.Subject.equalsIgnoreCase('Sample Subject'));
        
        Test.stopTest();
    }

    static testmethod void testApplyLiteralObjectMapping_valueMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Value Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, new WorkOrder(), null ,caseRecord );
        
        System.assert(workOrder != null);
        System.assert(workOrder.StartDate != null);
        System.assert(workOrder.Subject != null);
        System.assert(workOrder.Subject.equalsIgnoreCase('Sample Subject'));
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_fieldMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, new WorkOrder(), caseRecord );
        
        System.assert(workOrder != null);
        System.assert(workOrder.StartDate != null);
        System.assert(workOrder.Subject != null);
        System.assert(workOrder.Subject.equalsIgnoreCase('Sample Subject'));
        
        Test.stopTest();
    }

    static testmethod void testApplyLiteralObjectMapping_fieldMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, new WorkOrder(), caseRecord, caseRecord );
        
        System.assert(workOrder != null);
        System.assert(workOrder.StartDate != null);
        System.assert(workOrder.Subject != null);
        System.assert(workOrder.Subject.equalsIgnoreCase('Sample Subject'));
        
        Test.stopTest();
    }

    static testmethod void testApplyCRHLiteralObjectMapping_fieldMapping() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        final Account accountRecord = [SELECT Id, Name FROM Account LIMIT 1];
        final Case newCaseRecord = new Case();
        newCaseRecord.accountId = accountRecord.Id;
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, new WorkOrder(), caseRecord, newCaseRecord );
        
        System.assert(workOrder != null);
        System.assert(workOrder.StartDate != null);
        System.assert(workOrder.Subject != null);
        System.assert(workOrder.Subject.equalsIgnoreCase('Sample Subject'));
        
        Test.stopTest();
    }

    static testmethod void testApplyLiteralFieldMapping_ExistingTarget() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        WorkOrder woRecord = new WorkOrder();
        woRecord.AccountId = caseRecord.AccountId;
        insert woRecord;
        
        WorkOrder workOrder = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, woRecord, caseRecord, caseRecord );
        
        System.assert(workOrder != null);
        System.assert(workOrder.StartDate != null);
        System.assert(workOrder.Subject != null);
        System.assert(workOrder.Subject.equalsIgnoreCase('Sample Subject'));
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_fieldMappingWithSource() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        workOrderList.add( new WorkOrder() );
        
        Map<String,List<WorkOrder>> requestMap = new Map<String,List<WorkOrder>>();
        requestMap.put( caseRecord.Id, workOrderList );
        
         Map<String,List<SObject>> resultMap = ( Map<String,List<SObject>>) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, requestMap, new List<SObject>{caseRecord} );
        
        System.assert(resultMap != null);
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_fieldMappingWithoutSource() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        workOrderList.add( new WorkOrder() );
        
        Map<String,List<WorkOrder>> requestMap = new Map<String,List<WorkOrder>>();
        requestMap.put( caseRecord.Id, workOrderList );
        
         Map<String,List<SObject>> resultMap = ( Map<String,List<SObject>>) new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, requestMap );
        
        System.assert(resultMap != null);
        
        Test.stopTest();
    }
    
    static testmethod void testApplyObjectMapping_invalidArguments() {
        
        Test.startTest();
        
        try {
            new CONF_ObjectMappingHandler().applyObjectMapping( null, new WorkOrder() );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().applyObjectMapping( null, new WorkOrder(), new Case() );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().applyObjectMapping( '', new List<SObject>{new WorkOrder()}, new Case() );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
            new CONF_ObjectMappingHandler().applyObjectMapping( objectMappingRecord.Id, new List<SObject>{new WorkOrder()}, null );
            
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().applyObjectMapping( null, new WorkOrder(), null );
            
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().applyObjectMapping( null, new Map<String,List<SObject>>() );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().applyObjectMapping( null, new Map<String,List<SObject>>(), null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testRetrieveSourceRecord() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Case retrieveCaseRecord = ( Case) new CONF_ObjectMappingHandler().retrieveSourceRecord( objectMappingRecord.Id, caseRecord.Id, null, null );
        
        System.assert(retrieveCaseRecord != null);
        System.assert(retrieveCaseRecord.AccountId == caseRecord.AccountId);
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldValueByType() {
        
        Test.startTest();
        
        Time timeValue = (Time) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Time, '10:23:33.123z' );
        System.assert(timeValue != null);
        
        Boolean booleanValue = (Boolean) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Boolean, 'True' );
        System.assert(booleanValue );
        
        Long longValue = (Long) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Long, '234' );
        System.assert( longValue == 234 );
        
        Date dateValue = (Date) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Date, '05/03/2020' );
        System.assert( dateValue != null );
        
        dateValue = (Date) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Date, '2020-10-29' );
        System.assert( dateValue != null );
        
        Datetime datetimeValue = (Datetime) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Datetime, '2014-07-31T19:00:00.000Z' );
        System.assert( datetimeValue != null );
        
        Url urlValue = new Url( (String) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Url, 'https://www.google.com' ) );
        System.assert( urlValue != null );
        
        Test.stopTest();
    } 
    
    static testMethod void testGetFieldValueByTypeWithTargetObject() {
        
        Test.startTest();
        
        Time timeValue = (Time) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Time, '10:23:33.123z', 'WorkOrder' );
        System.assert(timeValue != null);
        
        Boolean booleanValue = (Boolean) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Boolean, 'True', 'WorkOrder' );
        System.assert(booleanValue );
        
        Long longValue = (Long) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Long, '234', 'WorkOrder' );
        System.assert( longValue == 234 );
        
        Date dateValue = (Date) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Date, '05/03/2020','WorkOrder' );
        System.assert( dateValue != null );
        
        dateValue = (Date) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Date, '2020-10-29', 'WorkOrder' );
        System.assert( dateValue != null );
        
        Datetime datetimeValue = (Datetime) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Datetime, '2014-07-31T19:00:00.000Z','WorkOrder' );
        System.assert( datetimeValue != null );
        
        Url urlValue = new Url( (String) new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Url, 'https://www.google.com','WorkOrder' ) );
        System.assert( urlValue != null );
        
        Test.stopTest();
    }

    static testMethod void testGetFieldValue_unsupported() {
        
        Test.startTest();
        
        try {
            new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Address, 'Address','WorkOrder' );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldValueByType_unsupported() {
        
        Test.startTest();
        
        try {
            new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Address, 'Address' );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldValueByType_invalidValue() {
        
        Test.startTest();
        
        try {
            new CONF_ObjectMappingHandler().getFieldValueByType( Schema.Displaytype.Date, 'Date' );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldValueByFunction_invalidValue() {
        
        Test.startTest();
        
        try {
            new CONF_ObjectMappingHandler().getFieldValueByFunction( Schema.Displaytype.Address, 'Date', null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            new CONF_ObjectMappingHandler().getFieldValueByFunction( Schema.Displaytype.Date, 'Invalid', null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetStringValueByFunction_invalidValue() {
        
        Test.startTest();
        
        try {
            new CONF_ObjectMappingHandler().getStringValueByFunction( 'Invalid', null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testMethod void testRetrieveSourceRecord_invalidMappingId() {
        
        Test.startTest();
        
        final SVMXA360__CONF_ObjectMapping__c objectMappingRecord = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c WHERE SVMXA360__Type__c = 'Field Mapping' LIMIT 1];
        
        try {
            final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
        	new CONF_ObjectMappingHandler().retrieveSourceRecord( null, caseRecord.Id, null, null );
            
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
        	new CONF_ObjectMappingHandler().retrieveSourceRecord( objectMappingRecord.Id, 'invalid', null, null );
            
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            String mappingId = null;
            final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
            new CONF_ObjectMappingHandler().retrieveSourceRecords( mappingId, new List<String>{caseRecord.Id}, new List<String>(), null );
            
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        try {
            Adm.ObjectMapping objectMapping = null;
            final Case caseRecord = [SELECT Id, AccountId FROM Case LIMIT 1];
            new CONF_ObjectMappingHandler().retrieveSourceRecords( objectMapping, new List<String>{caseRecord.Id}, new List<String>{'AssetId'}, null );
            
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
}