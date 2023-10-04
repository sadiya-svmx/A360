import {
    getFieldValue,
    getFieldDisplayValue
} from 'lightning/uiRecordApi';

import {
    getNameFieldsWithPreferredFirst
} from './uiObjectInfo';

import {
    isStaticFieldImport,
    validateIsARecord
} from './common';

import {
    isReferenceField
} from '../metadataUtils';

/**
 * Performs validation/normalization on the field value retrieval functions, prior to executing the
 * intended value retrieval function.
 * @param {uiRecordApi.Record} record A Record instance (from uiRecordApi.getRecord or
 *  uiRecordApi.getRecordUi)
 * @param {string|fieldImport} fieldName The target field to retrieve.
 *  The string variant expects ONLY the field name (simple and compound supported), while the
 *  fieldImport route expects an object with two properties (objectApiName and fieldApiName) and
 *  matches the structure of static field imports in LWC.
 * @param {function} getFunc The true retrieval function to use after value validation/normalization
 *  Expected to be either uiRecordApi.getFieldValue OR uiRecordApi.getFieldDisplayValue.
 */
function fieldValueGetter (record = {}, fieldName = '', getFunc = () => {}) {
    validateIsARecord(record);

    if (!fieldName) {
        // TODO: Custom Label
        throw new Error('The provided fieldName cannot be empty.');
    }

    let objectApiName, fieldApiName;
    if (isStaticFieldImport(fieldName)) {
        objectApiName = fieldName.objectApiName;
        fieldApiName = fieldName.fieldApiName;
    } else {
        objectApiName = record.apiName;
        if (fieldName.startsWith(`${record.apiName}.`)) {
            fieldApiName = fieldName.substring(record.apiName.length + 1, fieldName.length);
        } else {
            fieldApiName = fieldName;
        }
    }

    return getFunc(record, `${objectApiName}.${fieldApiName}`);
}

/**
 * Helper function for uiRecordApi.getFieldValue.
 * Polishes up the rough edges of the standard api by:
 *  - Auto-prepends the Object API name from record to fieldName
 * @param {uiRecordApi.Record} record A Record instance (from uiRecordApi.getRecord or
 *  uiRecordApi.getRecordUi).
 * @param {string|fieldImport} fieldName Field name (simple or compound) to retrieve the target
 *  value from.
 */
export function getValue (record, fieldName) {
    return fieldValueGetter(record, fieldName, getFieldValue);
}

export function getActualValue (record, fieldName) {
    const value =  getValue(record, fieldName);
    return value && typeof value === 'object' ? value.value : value;
}
/**
 * Helper function for uiRecordApi.getFieldDisplayValue.
 * Polishes up the rough edges of the standard api by:
 *  - Auto-prepends the Object API name from record to fieldName
 *  - Falls back to uiRecordApi.getFieldValue if the displayValue isn't populated.
 * @param {uiRecordApi.Record} record A Record instance (from uiRecordApi.getRecord or
 *  uiRecordApi.getRecordUi).
 * @param {string|fieldImport} fieldName Field name (simple or compound) to retrieve the target
 *  value from.
 */
export function getDisplayValue (record, fieldName) {
    const displayValueResult = fieldValueGetter(record, fieldName, getFieldDisplayValue);

    // Fallback to ui api "getValue" response (.value) if "displayValue" key isn't found
    return displayValueResult?.value || displayValueResult ||
        fieldValueGetter(record, fieldName, getFieldValue);
}

/**
 * Generates a Record structure for the Ui Api given an object name and optional field data.
 * @param {string} objectName - Api name of the object the provided data represents.
 * @param {object} recordData - Map of field names to field values.
 * @returns {uiRecordApi.Record}
 */
export function getUiRecord (objectName, recordData = {}) {
    if (!objectName) {
        throw new Error('Object name cannot be empty.');
    }

    const fields = Object.assign({}, recordData);
    const { Id } = fields;
    delete fields.Id;

    return {
        apiName: objectName,
        id: Id,
        fields
    };
}

/**
 * Generates an array of name field values for the given Record.
 * @param {uiRecordApi.Record} record - A Record instance to generate the name values from
 * @param {uiObjectInfoApi.ObjectInfo} objectDefinition - Object definition for the given record
 * @returns {Array[string]} - Array of name field values for the given record
 */
export function getUiRecordName (record, objectDefinition) {
    if (!objectDefinition) {
        throw new Error('Object definition cannot be empty.');
    }

    const nameFields = getNameFieldsWithPreferredFirst(
        Array.isArray(objectDefinition.nameFields) ?
            objectDefinition.nameFields : [objectDefinition.nameFields]
    );

    let labels = [];
    if (record && nameFields?.length && objectDefinition?.fields) {
        labels = nameFields
            .map(field => {
                let normalizedFieldName = field;
                const fieldDefinition = objectDefinition.fields[field];
                if (isReferenceField(fieldDefinition)) {
                    const referenceNameField = fieldDefinition.referenceToInfos[0].nameFields[0];
                    normalizedFieldName =
                        `${fieldDefinition.relationshipName}.${referenceNameField}`;
                }
                return getDisplayValue(record, normalizedFieldName)
            })

            // Remove blank labels
            .filter(label => (label || '').trim().length);
    }
    return labels;
}