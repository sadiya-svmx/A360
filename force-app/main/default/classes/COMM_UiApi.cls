/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The intentions of this class is to provide Apex-backed fallback services for the Ui Api methods
 * that are available through the LWC module. This fallback is used for cases where an object we
 * must interact with is not directly supported by the Ui Api.
 * The Inputs/Outputs of these methods should match their associated Ui Api methods.
 * 
 * WARNING: This class is not intended to be used in server-side only applications. Instead it is
 * oriented towards being directly referenced by client-side code (one transaction per @AuraEnabled
 * execution). Memoization has not yet been implemented for the root-level @AuraEnabled response
 * values, thus performance issues may be encountered if these methods are used multiple times in a
 * single transaction.
 * 
 * This class is a modular service layer class for the all Lightning Web Components.
 * This class should not be compile-time dependent on any product-specific code/config so as to
 * promote re-use across all products.
 * Optional dependencies that are resolved at runtime are fine if absolutely necessary.
 *
 * @author Jason Bradley
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jason Bradley          13 August 2021     Created.
 * 
 *****************************************************************************************************/
public with sharing class COMM_UiApi {
    private static final Set<String> DEFAULT_QUERIED_FIELDS =
        new Set<String>{'LastModifiedDate', 'LastModifiedById', 'SystemModstamp', 'RecordTypeId'};

    // #region uiObjectInfoApi
    
    // #region uiObjectInfoApi Methods
    @AuraEnabled(cacheable=true)
    public static COMM_UiApi_Structs.ObjectInfo uiObjectInfoApi_getObjectInfo(String objectApiName) {
        COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);

        if (String.isBlank(objectApiName)) {
            COMM_WireAdapter.throwBadParameters('objectApiName cannot be blank.');
        }

        if (!COMM_UiApi_Utils.hasAccessToObject(objectApiName)) {
            COMM_WireAdapter.throwInsufficientAccess();
        }

        COMM_UiApi_Structs.ObjectInfo objectInfoResponse = new COMM_UiApi_Structs.ObjectInfo(COMM_UiApi_Utils.getObjectDescribe(objectApiName));
        COMM_WireAdapter.popWireType();
        return objectInfoResponse;
    }

    @AuraEnabled(cacheable=true)
    public static List<COMM_UiApi_Structs.ObjectInfo> uiObjectInfoApi_getObjectInfos(List<String> objectApiNames) {
        COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);

        COMM_WireAdapter.throwUnimplementedException();
        COMM_WireAdapter.popWireType();
		return null;
    }

    @AuraEnabled(cacheable=true)
    public static Object uiObjectInfoApi_getPicklistValues(Id recordTypeId, String fieldApiName) {
        COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);

        COMM_WireAdapter.throwUnimplementedException();
        COMM_WireAdapter.popWireType();
		return null;
    }

    @AuraEnabled(cacheable=true)
    public static Object uiObjectInfoApi_getPicklistValuesByRecordType(String objectApiName, Id recordTypeId) {
        COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);

        COMM_WireAdapter.throwUnimplementedException();
        COMM_WireAdapter.popWireType();
		return null;
    }
    // #endregion uiObjectInfoApi Methods
    // #endregion uiObjectInfoApi

    // #region uiRecordApi

    // #region uiRecordApi Methods
    
    // #region uiRecordApi_getRecord
    @AuraEnabled(cacheable=true)
    public static COMM_UiApi_Structs.Record uiRecordApi_getRecord(
        Id recordId,
        Object fields,
        Object optionalFields,
        Object layoutTypes,
        Object modes
    ) {
        COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);

        // #region Input validation
        // Similar to standard Ui Api wire adapters, treat empty input parameters as a no-op
        if (String.isBlank(recordId)) {
            return null;
        }

        String objectApiName = String.valueOf(recordId.getSObjectType());
        if (!COMM_UiApi_Utils.hasAccessToObject(objectApiName)) {
            COMM_WireAdapter.throwInsufficientAccess();
        }

        List<String> requiredFields = COMM_UiApi_Utils.getAccessibleFields(objectApiName, fields, 'fields', true);

        List<String> accessibleOptionalFields = COMM_UiApi_Utils.getAccessibleFields(objectApiName, optionalFields, 'optionalFields', false);
        for (String optionalField : accessibleOptionalFields) {
            if (requiredFields.contains(optionalField)) {
                COMM_WireAdapter.throwBadParameters('Duplicate field in "optionalFields" value. Already selected in "fields".');
            }
        }

        if (layoutTypes != null) {
            COMM_WireAdapter.throwUnimplementedException('uiRecordApi_getRecord support for "layouts"');
        }
        
        if (modes != null) {
            COMM_WireAdapter.throwUnimplementedException('uiRecordApi_getRecord support for "modes"');
        }
        // #endregion Input validation

        // #region Query target record
        Set<String> allAccessibleFields = new Set<String>();
        allAccessibleFields.addAll(requiredFields);
        allAccessibleFields.addAll(accessibleOptionalFields);
        COMM_UiApi_Utils.appendAccessibleFields(allAccessibleFields, objectApiName, DEFAULT_QUERIED_FIELDS);
        COMM_UiApi_Utils.appendAccessibleFields(allAccessibleFields, objectApiName, COMM_UiApi_Utils.getNameFields(objectApiName));

        String recordQuery = 'SELECT ' + String.join(new List<String>(allAccessibleFields), ',') +
            ' FROM ' + objectApiName +
            + ' WHERE Id =: recordId';

        List<SObject> matchingRecords = Database.query(recordQuery);
        if (matchingRecords.isEmpty()) {
            COMM_WireAdapter.throwInsufficientAccess();
        }

        SObject matchingRecord = matchingRecords[0];
        // #endregion Query target record

        COMM_UiApi_Structs.Record recordResponse = new COMM_UiApi_Structs.Record(matchingRecord);
        COMM_WireAdapter.popWireType();
        return recordResponse;
    }
    // #endregion uiRecordApi_getRecord

    // #region uiRecordApi_getRecordUi
    @AuraEnabled(cacheable=true)
    public static COMM_UiApi_Structs.RecordUI uiRecordApi_getRecordUi(
        Object recordIds,
        Object layoutTypes,
        Object modes,
        Object optionalFields
    ) {
        COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);

        // #region Input validation
        List<Id> validatedRecordIds = COMM_UiApi_Utils.getValidatedRecordIds(recordIds, 'recordIds');

        // Similar to standard Ui Api wire adapters, treat empty input parameters as a no-op
        if (recordIds == null || validatedRecordIds.isEmpty()) {
            return null;
        }

        Map<String, Set<Id>> idsByObjectApiName = COMM_UiApi_Utils.organizeRecordIdsByObjectApiName(validatedRecordIds);
        
        for (String objectApiName : idsByObjectApiName.keySet()) {
            if (!COMM_UiApi_Utils.hasAccessToObject(objectApiName)) {
                COMM_WireAdapter.throwInsufficientAccess();
            }
        }

        if (layoutTypes != null) {
            COMM_WireAdapter.throwUnimplementedException('uiRecordApi_getRecordUi support for "layouts"');
        }

        if (modes != null) {
            COMM_WireAdapter.throwUnimplementedException('uiRecordApi_getRecordUi support for "modes"');
        }

        Map<String, Set<String>> accessibleOptionalFieldsByObjectApiName = COMM_UiApi_Utils.getAccessibleFieldsByObject(optionalFields, 'optionalFields');
        
        // #endregion Input validation

        // #region Query target records
        Map<Id, SObject> recordsById = new Map<Id, SObject>();
        for (String objectApiName : idsByObjectApiName.keySet()) {
            Set<Id> recordIdsForObject = idsByObjectApiName.get(objectApiName);

            Set<String> accessibleFields = accessibleOptionalFieldsByObjectApiName.get(objectApiName);
            COMM_UiApi_Utils.appendAccessibleFields(accessibleFields, objectApiName, DEFAULT_QUERIED_FIELDS);
            COMM_UiApi_Utils.appendAccessibleFields(accessibleFields, objectApiName, COMM_UiApi_Utils.getNameFields(objectApiName));

            String recordsQuery = 'SELECT ' + String.join(new List<String>(accessibleFields), ',') +
                ' FROM ' + objectApiName +
                ' WHERE Id IN: recordIdsForObject';

            List<SObject> matchingRecords = Database.query(recordsQuery);
            if (matchingRecords.size() != recordIdsForObject.size()) {
                COMM_WireAdapter.throwInsufficientAccess();
            }

            for (SObject matchingRecord : matchingRecords) {
                recordsById.put(matchingRecord.Id, matchingRecord);
            }
        }
        // #endregion Query target records

        COMM_UiApi_Structs.RecordUI recordUiResponse = new COMM_UiApi_Structs.RecordUI(recordsById);
        COMM_WireAdapter.popWireType();
        return recordUiResponse;
    }
    // #region uiRecordApi_getRecordUi

    // #endregion uiRecordApi Methods
    // #endregion uiRecordApi
}