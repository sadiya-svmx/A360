/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * The intentions of this class is to the common utility methods used by the
 * Apex-backed fallback services for the Ui Api methods that are available through the LWC module.
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
public inherited sharing class COMM_UiApi_Utils {
    // #region Describe Caches
    private static final Map<String, Schema.DescribeSObjectResult> OBJECT_DESCRIBE_CACHE = new Map<String, Schema.DescribeSObjectResult>();
    private static final Map<String, List<String>> OBJECT_NAME_FIELDS_CACHE = new Map<String, List<String>>();
    private static final Map<String, Map<String, List<String>>> OBJECT_COMPOUND_FIELD_COMPONENT_CACHE = new Map<String, Map<String, List<String>>>();
    private static final Map<String, Map<String, Schema.DescribeFieldResult>> OBJECT_FIELD_DESCRIBE_CACHE = new Map<String, Map<String, Schema.DescribeFieldResult>>();
    // #endregion Describe Caches

    // #region Describe Utilities
    public static Schema.DescribeSObjectResult getObjectDescribe(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            return null;
        }

        String objectKey = objectApiName.toLowerCase();

        if (OBJECT_DESCRIBE_CACHE.containsKey(objectKey)) {
            return OBJECT_DESCRIBE_CACHE.get(objectKey);
        }

        Schema.DescribeSObjectResult sObjectDescribe;
        try {
            List<Schema.DescribeSObjectResult> sObjectDescribes = Schema.describeSObjects(new List<String> {objectApiName});
            if (!sObjectDescribes.isEmpty()) {
                sObjectDescribe = sObjectDescribes[0];
            }
        } catch (InvalidParameterValueException e) {
            // Remap to null in cache
            sObjectDescribe = null;
        }
        OBJECT_DESCRIBE_CACHE.put(objectKey, sObjectDescribe);

        return sObjectDescribe;
    }

    public static Boolean hasAccessToObject(String objectApiName) {
        Schema.DescribeSObjectResult sObjectDescribe = getObjectDescribe(objectApiName);
        if (sObjectDescribe == null) {
            return false;
        }

        return sObjectDescribe.isAccessible();
    }

    public static List<String> getNameFields(String objectApiName) {
        List<String> nameFields = new List<String>();

        if (String.isBlank(objectApiName)) {
            return nameFields;
        }

        String objectKey = objectApiName.toLowerCase();

        if (OBJECT_NAME_FIELDS_CACHE.containsKey(objectKey)) {
            return OBJECT_NAME_FIELDS_CACHE.get(objectKey);
        }

        Schema.DescribeSObjectResult sObjectDescribe = getObjectDescribe(objectApiName);
        if (sObjectDescribe != null) {
            Map<String, List<String>> compoundFieldMapping = getCompoundFieldMapping(objectApiName);

            Set<String> fieldApiNames = sObjectDescribe.fields.getMap().keySet();
            for (String fieldApiName : fieldApiNames) {
                Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectApiName, fieldApiName);
                if (fieldDescribe.isNameField()) {
                    String nameFieldApi = fieldDescribe.getName();
                    nameFields.add(nameFieldApi);
                    
                    List<String> componentFields = compoundFieldMapping.get(nameFieldApi);
                    if (componentFields != null && !componentFields.isEmpty()) {
                        Integer injectionIndex = 0;
                        for (String componentField : componentFields) {
                            if (componentField != nameFieldApi) {
                                nameFields.add(injectionIndex, componentField);
                                injectionIndex++;
                            }
                        }
                    }
                }
            }
        }
        OBJECT_NAME_FIELDS_CACHE.put(objectKey, nameFields);

        return nameFields;
    }

    public static Map<String, List<String>> getCompoundFieldMapping(String objectApiName) {
        Map<String, List<String>> componentFieldMapping = new Map<String, List<String>>();

        if (String.isBlank(objectApiName)) {
            return componentFieldMapping;
        }

        String objectKey = objectApiName.toLowerCase();

        if (OBJECT_COMPOUND_FIELD_COMPONENT_CACHE.containsKey(objectKey)) {
            return OBJECT_COMPOUND_FIELD_COMPONENT_CACHE.get(objectKey);
        }

        Schema.DescribeSObjectResult sObjectDescribe = getObjectDescribe(objectApiName);
        if (sObjectDescribe != null) {
            List<String> fieldApiNames = new List<String>(sObjectDescribe.fields.getMap().keySet());
            fieldApiNames.sort();
            for (String fieldApiName : fieldApiNames) {
                Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectApiName, fieldApiName);
                String compoundFieldName = fieldDescribe.getCompoundFieldName();

                if (String.isNotBlank(compoundFieldName)) {
                    List<String> relatedComponentFields = componentFieldMapping.get(compoundFieldName);
                    if (relatedComponentFields == null) {
                        relatedComponentFields = new List<String>();
                        componentFieldMapping.put(compoundFieldName, relatedComponentFields);
                    }

                    relatedComponentFields.add(fieldDescribe.getName());
                }
            }
        }
        OBJECT_COMPOUND_FIELD_COMPONENT_CACHE.put(objectKey, componentFieldMapping);

        return componentFieldMapping;
    }

    public static Schema.DescribeFieldResult getFieldDescribe(String objectApiName, String fieldApiName) {
        if (String.isBlank(objectApiName)) {
            return null;
        }
        
        if (String.isBlank(fieldApiName)) {
            return null;
        }

        String objectKey = objectApiName.toLowerCase(),
            fieldKey = fieldApiName.toLowerCase();

        Map<String, Schema.DescribeFieldResult> fieldDescribeCache;
        if (OBJECT_FIELD_DESCRIBE_CACHE.containsKey(objectKey)) {
            fieldDescribeCache = OBJECT_FIELD_DESCRIBE_CACHE.get(objectKey);
        } else {
            fieldDescribeCache = new Map<String, Schema.DescribeFieldResult>();
            OBJECT_FIELD_DESCRIBE_CACHE.put(objectKey, fieldDescribeCache);
        }

        if (fieldDescribeCache.containsKey(fieldKey)) {
            return fieldDescribeCache.get(fieldKey);
        }

        Schema.DescribeSObjectResult sObjectDescribe = getObjectDescribe(objectApiName);
        Schema.DescribeFieldResult fieldDescribe;
        if (sObjectDescribe != null) {
            Schema.SObjectField sObjectField = sObjectDescribe.fields.getMap().get(fieldApiName);
            if (sObjectField != null) {
                fieldDescribe = sObjectField.getDescribe();
            }
        }
        fieldDescribeCache.put(fieldKey, fieldDescribe);

        return fieldDescribe;
    }

    public static Boolean hasAccessToField(String objectApiName, String fieldApiName) {
        if (!hasAccessToObject(objectApiName)) {
            return false;
        }

        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectApiName, fieldApiName);
        if (fieldDescribe == null) {
            return false;
        }

        return fieldDescribe.isAccessible();
    }

    public static Boolean isStringArray(Object input) {
        if (input instanceof List<String>) {
            return true;
        }

        if (!(input instanceof List<Object>)) {
            return false;
        }

        List<Object> inputAsList = (List<Object>)input;
        if (inputAsList.isEmpty()) {
            return true;
        }

        for (Object value : inputAsList) {
            if (!(value instanceof String)) {
                return false;
            }
        }

        return true;
    }

    public static Boolean isIdArray(Object input) {
        if (input instanceof List<Id>) {
            return true;
        }

        if (!(input instanceof List<Object>)) {
            return false;
        }

        List<Object> inputAsList = (List<Object>)input;
        if (inputAsList.isEmpty()) {
            return true;
        }

        for (Object value : inputAsList) {
            if (!(value instanceof Id)) {
                return false;
            }
        }

        return true;
    }

    public static List<String> convertToStringArray(List<Object> input) {
        if (input == null) {
            return null;
        }

        List<String> inputAsStringArray = new List<String>();
        for (Object inputValue : input) {
            inputAsStringArray.add( inputValue != null ? String.escapeSingleQuotes( String.valueOf(inputValue) ) : String.valueOf(inputValue) );
        }
        return inputAsStringArray;
    }

    public static List<Id> convertToIdArray(List<Object> input) {
        if (input == null) {
            return null;
        }

        List<Id> inputAsIdArray = new List<Id>();
        for (Object inputValue : input) {
            inputAsIdArray.add(Id.valueOf(String.valueOf(inputValue)));
        }
        return inputAsIdArray;
    }

    public static List<String> getValueAsStringArray(Object inputValue) {
        if (inputValue instanceof String) {
            return new List<String> {String.escapeSingleQuotes( (String)inputValue ) };
        } else if (isStringArray(inputValue)) {
            return convertToStringArray((List<Object>)inputValue);
        } else {
            Exception e = new IllegalArgumentException();
            e.setMessage('Invalid list value. Must be a string or string array.');
            throw e;
        }
    }

    public static List<Id> getValueAsIdArray(Object inputValue) {
        if (inputValue instanceof Id) {
            return new List<Id> {(Id)inputValue};
        } else if (isIdArray(inputValue)) {
            return convertToIdArray((List<Object>)inputValue);
        } else {
            Exception e = new IllegalArgumentException();
            e.setMessage('Invalid list value. Must be an Id or Id array.');
            throw e;
        }
    }

    public static List<String> convertUiApiFieldsToApexFields(List<String> uiApiFields) {
        List<String> apexFields = new List<String>();

        if (uiApiFields != null) {
            for (String apexField : uiApiFields) {
                apexFields.add(apexField.substringAfter('.'));
            }
        }

        return apexFields;
    }

    public static List<Id> getValidatedRecordIds(Object inputRecordIds, String paramName) {
        List<Id> validatedRecordIds;
        if (inputRecordIds != null) {
            try {
                validatedRecordIds = COMM_UiApi_Utils.getValueAsIdArray(inputRecordIds);
            } catch (IllegalArgumentException e) {
                COMM_WireAdapter.throwBadParameters('Invalid "' + paramName + '" value. Must be an Id or Id array.');
            }
        }
        return validatedRecordIds;
    }

    public static List<String> getAccessibleFields(String objectApiName, Object inputFields, String paramName, Boolean shouldThrowOnInaccessible) {
        List<String> accessibleFields = new List<String>();

        if (inputFields != null) {
            // Validate data format of "fields" argument
            List<String> allFields;
            try {
                allFields = COMM_UiApi_Utils.getValueAsStringArray(inputFields);
            } catch (IllegalArgumentException e) {
                COMM_WireAdapter.throwBadParameters('Invalid "' + paramName + '" value. Must be a string or string array.');
            }

            // Convert fields from Ui Api format to Apex format
            allFields = COMM_UiApi_Utils.convertUiApiFieldsToApexFields(allFields);

            // Ensure user has read access to the target fields
            for (String fieldApiName : allFields) {
                if (COMM_UiApi_Utils.hasAccessToField(objectApiName, fieldApiName)) {
                    accessibleFields.add(fieldApiName);
                } else if (shouldThrowOnInaccessible == true) {
                    COMM_WireAdapter.throwInsufficientAccess();
                }
            }
        } else {
            accessibleFields = new List<String>();
        }

        return accessibleFields;
    }

    public static Map<String, Set<Id>> organizeRecordIdsByObjectApiName(List<Id> recordIds) {
        Map<String, Set<Id>> idsByObjectApiName = new Map<String, Set<Id>>();
        for (Id recordId : recordIds) {
            if (recordId != null) {
                String objectApiName = String.valueOf(recordId.getSObjectType());
                Set<Id> adjacentIds = idsByObjectApiName.get(objectApiName);
                if (adjacentIds == null) {
                    adjacentIds = new Set<Id>();
                    idsByObjectApiName.put(objectApiName, adjacentIds);
                }
                adjacentIds.add(recordId);
            }
        }
        return idsByObjectApiName;
    }

    public static Map<String, Set<String>> getAccessibleFieldsByObject(Object inputFields, String paramName) {
        Map<String, Set<String>> accessibleFieldsByObjectApiName = new Map<String, Set<String>>();
        if (inputFields != null) {
            // Validate data format of "fields" argument
            List<String> allFields;
            try {
                allFields = getValueAsStringArray(inputFields);
            } catch (IllegalArgumentException e) {
                COMM_WireAdapter.throwBadParameters('Invalid "' + paramName + '" value. Must be a string or string array.');
            }

            // Organize optional fields by their associated object api name
            for (String fieldApiPath : allFields) {
                String objectApiName = fieldApiPath.substringBefore('.'),
                    fieldApiName = fieldApiPath.substringAfter('.');

                // Ensure user has read access to the target fields, and remove any that they do not have access to
                if (hasAccessToField(objectApiName, fieldApiName)) {
                    Set<String> adjacentFields = accessibleFieldsByObjectApiName.get(objectApiName);
                    if (adjacentFields == null) {
                        adjacentFields = new Set<String>();
                        accessibleFieldsByObjectApiName.put(objectApiName, adjacentFields);
                    }
                    adjacentFields.add(fieldApiName);
                }
            }
        }
        return accessibleFieldsByObjectApiName;
    }

    // Could really use an overarching iterable class here to avoid method duplication, but this is Apex so ¯\_(ツ)_/¯
    public static void appendAccessibleFields(Set<String> fields, String objectApiName, List<String> fieldsToAdd) {
        if (fields == null) {
            fields = new Set<String>();
        }

        for (String fieldToAdd : fieldsToAdd) {
            if (hasAccessToField(objectApiName, fieldToAdd)) {
                fields.add(fieldToAdd);
            }
        }
    }

    public static void appendAccessibleFields(Set<String> fields, String objectApiName, Set<String> fieldsToAdd) {
        if (fields == null) {
            fields = new Set<String>();
        }

        for (String fieldToAdd : fieldsToAdd) {
            if (hasAccessToField(objectApiName, fieldToAdd)) {
                fields.add(fieldToAdd);
            }
        }
    }
    // #endregion Describe Utilities
}