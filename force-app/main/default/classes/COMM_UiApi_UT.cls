@IsTest
public class COMM_UiApi_UT {

    public static testMethod void test_uiObjectInfoApi_getObjectInfo() {
        // Expect Successful Responses
        List<String> objectApiNames = new List<String>{'User', 'Profile', 'Account', 'Contact'};
        for (String objectApiName : objectApiNames) {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            System.assertNotEquals(null, sObjectType);
            Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();

            COMM_UiApi_Structs.ObjectInfo objectInfo = COMM_UiApi.uiObjectInfoApi_getObjectInfo(objectApiName);

            if (sObjectDescribe.isAccessible()) {
                System.assertNotEquals(null, objectInfo);
                System.assertNotEquals(null, objectInfo.fields);
                System.assertNotEquals(null, objectInfo.nameFields);
                System.assertNotEquals(null, objectInfo.recordTypeInfos);
                System.assertNotEquals(null, objectInfo.childRelationships);

                System.assertEquals(sObjectDescribe.getName(), objectInfo.apiName);

                for (String fieldName : objectInfo.fields.keySet()) {
                    Schema.SObjectField sObjectField = sObjectDescribe.fields.getMap().get(fieldName);
                    System.assertNotEquals(null, sObjectField);
                    Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
                    System.assertEquals(true, fieldDescribe.isAccessible());

                    COMM_UiApi_Structs.FieldInfo fieldInfo = objectInfo.fields.get(fieldName);
                    System.assertNotEquals(null, fieldInfo);
                    System.assertEquals(fieldDescribe.getName(), fieldInfo.apiName);
                }

                for (COMM_UiApi_Structs.ChildRelationshipInfo childRelationshipInfo : objectInfo.childRelationships) {
                    System.assertNotEquals(null, childRelationshipInfo);
                    System.assertEquals(false, String.isBlank(childRelationshipInfo.fieldName));
                    System.assertEquals(false, String.isBlank(childRelationshipInfo.relationshipName));
                    System.assertEquals(false, String.isBlank(childRelationshipInfo.childObjectApiName));

                    Schema.SObjectType childSObjectType = Schema.getGlobalDescribe().get(childRelationshipInfo.childObjectApiName);
                    System.assertNotEquals(null, childSObjectType);
                    Schema.DescribeSObjectResult childSObjectDescribe = childSObjectType.getDescribe();
                    System.assertEquals(true, childSObjectDescribe.isAccessible());
                }

                for (Id recordTypeId : objectInfo.recordTypeInfos.keySet()) {
                    COMM_UiApi_Structs.RecordTypeInfo recordTypeInfo = objectInfo.recordTypeInfos.get(recordTypeId);
                    System.assertNotEquals(null, recordTypeInfo);
                    System.assertEquals(false, String.isBlank(recordTypeInfo.name));

                    Schema.RecordTypeInfo schemaRecordTypeInfo = sObjectDescribe.getRecordTypeInfosById().get(recordTypeInfo.recordTypeId);
                    System.assertNotEquals(null, schemaRecordTypeInfo);
                    System.assertEquals(schemaRecordTypeInfo.getRecordTypeId(), recordTypeId);
                    System.assertEquals(schemaRecordTypeInfo.getRecordTypeId(), recordTypeInfo.recordTypeId);
                    System.assertEquals(schemaRecordTypeInfo.getName(), recordTypeInfo.name);
                }
            } else {
                System.assertEquals(null, objectInfo);
            }
        }

        // Expect Failed Responses
        COMM_WireAdapter.WireException exceptionThrownWhenBlank;
        try {
            COMM_UiApi.uiObjectInfoApi_getObjectInfo('');
        } catch (COMM_WireAdapter.WireException e) {
            exceptionThrownWhenBlank = e;
        }
        System.assertNotEquals(null, exceptionThrownWhenBlank);
        System.assertEquals(COMM_WireAdapter.EWireType.READ, exceptionThrownWhenBlank.wireType);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.BAD_PARAMETERS, exceptionThrownWhenBlank.exceptionType);

        COMM_WireAdapter.WireException exceptionThrownWhenInvalid;
        try {
            COMM_UiApi.uiObjectInfoApi_getObjectInfo('INVALID');
        } catch (COMM_WireAdapter.WireException e) {
            exceptionThrownWhenInvalid = e;
        }
        System.assertNotEquals(null, exceptionThrownWhenInvalid);
        System.assertEquals(COMM_WireAdapter.EWireType.READ, exceptionThrownWhenInvalid.wireType);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.INSUFFICIENT_ACCESS, exceptionThrownWhenInvalid.exceptionType);
    }

    public static testMethod void test_uiObjectInfoApi_getObjectInfos() {
        // Method not yet implemented
        COMM_WireAdapter.WireException caughtException;
        try {
            Object response = COMM_UiApi.uiObjectInfoApi_getObjectInfos(null);
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, caughtException.exceptionType);
    }

    public static testMethod void test_uiObjectInfoApi_getPicklistValues() {
        // Method not yet implemented
        COMM_WireAdapter.WireException caughtException;
        try {
            Object response = COMM_UiApi.uiObjectInfoApi_getPicklistValues(null, null);
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, caughtException.exceptionType);
    }

    public static testMethod void test_uiObjectInfoApi_getPicklistValuesByRecordType() {
        // Method not yet implemented
        COMM_WireAdapter.WireException caughtException;
        try {
            Object response = COMM_UiApi.uiObjectInfoApi_getPicklistValuesByRecordType(null, null);
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, caughtException.exceptionType);
    }

    public static testMethod void test_uiRecordApi_getRecord() {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Description = 'Test Description';
        insert testAccount;

        Test.startTest();
        // Test recordid null
        System.assertEquals(null, COMM_UiApi.uiRecordApi_getRecord(
            null,
            'Account.Name',
            'Account.Description',
            null,
            null
        ));

        // Test simple success
        COMM_UiApi_Structs.Record response = COMM_UiApi.uiRecordApi_getRecord(
            testAccount.Id,
            'Account.Name',
            'Account.Description',
            null,
            null
        );

        System.assertNotEquals(null, response);
        System.assertEquals(testAccount.Id, response.id);
        System.assertEquals(true, response.childRelationships.isEmpty());

        System.assertNotEquals(null, response.fields);
        System.assertEquals(false, response.fields.isEmpty());
        System.assertEquals(testAccount.Name, response.fields.get('Name')?.value);
        System.assertEquals(testAccount.Description, response.fields.get('Description')?.value);
        Test.stopTest();
    }

    public static testMethod void test_uiRecordApi_getRecord_Exceptions() {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Description = 'Test Description';
        insert testAccount;

        Test.startTest();
        // Test duplicate field in optionalFields
        COMM_WireAdapter.WireException duplicateFieldsException;
        try {
            COMM_UiApi_Structs.Record response = COMM_UiApi.uiRecordApi_getRecord(
                testAccount.Id,
                'Account.Name',
                'Account.Name',
                null,
                null
            );
        } catch (COMM_WireAdapter.WireException e) {
            duplicateFieldsException = e;
        }
        System.assertNotEquals(null, duplicateFieldsException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.BAD_PARAMETERS, duplicateFieldsException.exceptionType);

        // Test layoutTypes not null
        COMM_WireAdapter.WireException layoutTypesUnsupportedException;
        try {
            COMM_UiApi_Structs.Record response = COMM_UiApi.uiRecordApi_getRecord(
                testAccount.Id,
                'Account.Name',
                'Account.Description',
                'Full',
                null
            );
        } catch (COMM_WireAdapter.WireException e) {
            layoutTypesUnsupportedException = e;
        }
        System.assertNotEquals(null, layoutTypesUnsupportedException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, layoutTypesUnsupportedException.exceptionType);

        // Test modes not null
        COMM_WireAdapter.WireException modesUnsupportedException;
        try {
            COMM_UiApi_Structs.Record response = COMM_UiApi.uiRecordApi_getRecord(
                testAccount.Id,
                'Account.Name',
                'Account.Description',
                null,
                'View'
            );
        } catch (COMM_WireAdapter.WireException e) {
            modesUnsupportedException = e;
        }
        System.assertNotEquals(null, modesUnsupportedException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, modesUnsupportedException.exceptionType);

        Test.stopTest();
    }

    public static testMethod void test_uiRecordApi_getRecordUi() {
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Description = 'Test Description';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'First';
        testContact.LastName = 'Last';
        insert testContact;
        testContact = [SELECT AccountId, FirstName, LastName, Name FROM Contact WHERE Id =: testContact.Id];

        Test.startTest();
        // Test recordids null
        System.assertEquals(null, COMM_UiApi.uiRecordApi_getRecordUi(
            null,
            null,
            null,
            new List<String> {}
        ));

        // Test recordids empty
        System.assertEquals(null, COMM_UiApi.uiRecordApi_getRecordUi(
            new List<Id> {},
            null,
            null,
            new List<String> {}
        ));

        // Test simple success
        COMM_UiApi_Structs.RecordUi response = COMM_UiApi.uiRecordApi_getRecordUi(
            new List<Id> {testAccount.Id, testContact.Id},
            null,
            null,
            new List<String> {
                'Account.Name',
                'Account.Description',
                'Contact.AccountId',
                'Contact.Name',
                'Contact.FirstName',
                'Contact.LastName'
            }
        );

        // Validate record data
        System.assertNotEquals(null, response.records);
        System.assertEquals(false, response.records.isEmpty());

        // Validate Account Details
        COMM_UiApi_Structs.Record accountRecord = response.records.get(testAccount.Id);
        System.assertEquals(testAccount.Id, accountRecord.id);
        System.assertEquals(true, accountRecord.childRelationships.isEmpty());

        System.assertNotEquals(null, accountRecord.fields);
        System.assertEquals(false, accountRecord.fields.isEmpty());
        System.assertEquals(testAccount.Name, accountRecord.fields.get('Name')?.value);
        System.assertEquals(testAccount.Description, accountRecord.fields.get('Description')?.value);

        // Validate Contact Details
        COMM_UiApi_Structs.Record contactRecord = response.records.get(testContact.Id);
        System.assertEquals(testContact.Id, contactRecord.id);
        System.assertEquals(true, contactRecord.childRelationships.isEmpty());

        System.assertNotEquals(null, contactRecord.fields);
        System.assertEquals(false, contactRecord.fields.isEmpty());
        System.assertEquals(testContact.Name, contactRecord.fields.get('Name')?.value);
        System.assertEquals(testContact.FirstName, contactRecord.fields.get('FirstName')?.value);
        System.assertEquals(testContact.LastName, contactRecord.fields.get('LastName')?.value);
        System.assertEquals(testContact.AccountId, contactRecord.fields.get('AccountId')?.value);

        // Validate object info data
        System.assertNotEquals(null, response.objectInfos);
        System.assertEquals(false, response.objectInfos.isEmpty());
        System.assertEquals(2, response.objectInfos.size());
        System.assertNotEquals(null, response.objectInfos.get('Account'));
        System.assertEquals('Account', response.objectInfos.get('Account').apiName);
        System.assertNotEquals(null, response.objectInfos.get('Contact'));
        System.assertEquals('Contact', response.objectInfos.get('Contact').apiName);

        System.assertNotEquals(null, response.layoutUserStates);
        System.assertEquals(true, response.layoutUserStates.isEmpty());
        System.assertNotEquals(null, response.layouts);
        System.assertEquals(true, response.layouts.isEmpty());

        Test.stopTest();
    }

    public static testMethod void test_uiRecordApi_getRecordUi_Exceptions() {

        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Description = 'Test Description';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'First';
        testContact.LastName = 'Last';
        insert testContact;
        testContact = [SELECT AccountId, FirstName, LastName, Name FROM Contact WHERE Id =: testContact.Id];

        Test.startTest();

        // Test layoutTypes not null
        COMM_WireAdapter.WireException layoutTypesUnsupportedException;
        try {
            COMM_UiApi_Structs.RecordUi response = COMM_UiApi.uiRecordApi_getRecordUi(
                new List<Id> {testAccount.Id, testContact.Id},
                'Full',
                null,
                new List<String> {
                    'Account.Name',
                    'Account.Description',
                    'Contact.AccountId',
                    'Contact.Name',
                    'Contact.FirstName',
                    'Contact.LastName'
                }
            );
        } catch (COMM_WireAdapter.WireException e) {
            layoutTypesUnsupportedException = e;
        }
        System.assertNotEquals(null, layoutTypesUnsupportedException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, layoutTypesUnsupportedException.exceptionType);

        // Test modes not null
        COMM_WireAdapter.WireException modesUnsupportedException;
        try {
            COMM_UiApi_Structs.RecordUi response = COMM_UiApi.uiRecordApi_getRecordUi(
                new List<Id> {testAccount.Id, testContact.Id},
                null,
                'View',
                new List<String> {
                    'Account.Name',
                    'Account.Description',
                    'Contact.AccountId',
                    'Contact.Name',
                    'Contact.FirstName',
                    'Contact.LastName'
                }
            );
        } catch (COMM_WireAdapter.WireException e) {
            modesUnsupportedException = e;
        }
        System.assertNotEquals(null, modesUnsupportedException);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, modesUnsupportedException.exceptionType);

        Test.stopTest();
    }
}