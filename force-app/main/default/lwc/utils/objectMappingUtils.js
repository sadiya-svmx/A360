import { FIELD_DATA_TYPES,
    MAPPING_TYPES,
    DATE_TIME_FUNCTION_LITERALS,
    FIELD_API_NAMES,
    FUNCTION_LITERALS,
    OBJECT_MAPPING_TYPES,
} from './constants';

import { arraysEqual } from './arrayUtils';
import labelToday from '@salesforce/label/c.Picklist_Today';
import labelTomorrow from '@salesforce/label/c.Picklist_Tomorrow';
import labelYesterday from '@salesforce/label/c.Picklist_Yesterday';
import labelNow from '@salesforce/label/c.Picklist_Now';
import labelField from '@salesforce/label/c.Picklist_Field';
import labelValue from '@salesforce/label/c.Picklist_Value';
import labelFunction from '@salesforce/label/c.Picklist_Function';
import labelInvalidCurrentHeader from '@salesforce/label/c.Error_Invalid_Current_Header_Record';
import labelInvalidCurrentRecord from '@salesforce/label/c.Error_Invalid_Current_Record';
import labelInvalidUserLiteral from '@salesforce/label/c.Error_Invalid_User_Literal';
import labelCurrentRecord from '@salesforce/label/c.Label_CurrentRecord';
import labelCurrentRecordHeader from '@salesforce/label/c.Label_CurrentRecordHeader';
import {
    resolveLiterals,
    resolveUserRecordByObjectMapping,
    resolveCurrentRecordByObjectMapping,
} from "./literals";
import { getActualValue } from "./api/uiRecord";
import { isARecord } from "./api/common";
import { isValidDate,
    convertToUserTimeZone,
    convertToLocalDateByUserTimeZone,
} from "./dateUtils";

import {
    TRANSACTION_TYPE
} from './runtimeUtils';

import { formatString } from './utils'

let mappingOptions = new Map();

export const getMappingTypeConfiguration = () => {

    if (mappingOptions.size > 0) return mappingOptions;

    const idMap = new Map([
        [MAPPING_TYPES.FIELD, ['Field', 'Function']]
    ]);

    const dateMap = new Map([
        [MAPPING_TYPES.FIELD, ['Field', 'Value', 'Function']],
        [MAPPING_TYPES.VALUE, ['Value', 'Function']],
    ]);

    const fieldValueMap = new Map([
        [MAPPING_TYPES.FIELD, ['Field', 'Value', 'Function']],
        [MAPPING_TYPES.VALUE, ['Value', 'Function']],
    ]);

    mappingOptions.set(FIELD_DATA_TYPES.ID, idMap);

    mappingOptions.set(FIELD_DATA_TYPES.DATE, dateMap);
    mappingOptions.set(FIELD_DATA_TYPES.DATETIME, dateMap);

    mappingOptions.set(FIELD_DATA_TYPES.BOOLEAN, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.CURRENCY, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.DOUBLE, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.EMAIL, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.ENCRYPTEDSTRING, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.INTEGER, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.LONG, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.MULTIPICKLIST, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.PERCENT, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.PHONE, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.PICKLIST, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.STRING, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.TEXTAREA, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.TIME, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.URL, fieldValueMap);
    mappingOptions.set(FIELD_DATA_TYPES.REFERENCE, fieldValueMap);

    return mappingOptions;
};


/**
 * Get a list of field mapping detail mapping types
 * @param {String} A string mapping type (Field or Value).
 * @param {String} A string data type of the field to determine mapping options. 
 * @return {Array} A list of mapping type options. Each option having a label and value properties.
 */

export const getMappingTypeOptions = (mappingType, fieldData) => {
    let options = [];

    if (mappingType === null || mappingType === undefined) {
        throw new Error("mappingType must be defined");
    }

    if (fieldData === null || fieldData === undefined) {
        throw new Error("fieldData must be defined");
    }

    mappingOptions = getMappingTypeConfiguration();

    if (mappingOptions.has(fieldData.dataType)) {
        const opt = mappingOptions.get(fieldData.dataType);

        const optionItems = opt.get(mappingType);

        if (optionItems) {
            options = optionItems
                .filter(option => {
                    return !(option === 'Value'
                    && fieldData.dataType === FIELD_DATA_TYPES.REFERENCE
                    && fieldData.apiName !== 'RecordTypeId');
                })
                .map(option => {
                    let label = '';
                    switch (option) {
                        case 'Field':
                            label = labelField;
                            break;
                        case 'Value':
                            label = labelValue;
                            break;
                        case 'Function':
                            label = labelFunction
                            break;
                        default:
                            break;
                    }
                    return { label: label, value: option }
                });
        }
    }

    return options;
};

/**
 * Get a list of literals for use as detail mappings where mapping type = 'Function'.
 * @param {String} A string data type of the field to determine options.
 * @returns {Array} A list of function options.
 */
export const getFunctionMappingOptions = (fieldDataType, userObjectLabel) => {
    const options = [];

    if (fieldDataType === FIELD_DATA_TYPES.DATETIME) {
        options.push({ label: labelNow, value: DATE_TIME_FUNCTION_LITERALS.NOW });
    }

    if (fieldDataType === FIELD_DATA_TYPES.DATE || fieldDataType === FIELD_DATA_TYPES.DATETIME) {
        options.push({ label: labelToday, value: DATE_TIME_FUNCTION_LITERALS.TODAY });
        options.push({ label: labelTomorrow, value: DATE_TIME_FUNCTION_LITERALS.TOMORROW });
        options.push({ label: labelYesterday, value: DATE_TIME_FUNCTION_LITERALS.YESTERDAY });
        options.push({ label: userObjectLabel, value: 'User' });
        options.push({ label: labelCurrentRecord, value: 'Current Record' });
        options.push({ label: labelCurrentRecordHeader, value: 'Current Record Header' });
    }

    if (fieldDataType !== FIELD_DATA_TYPES.DATE &&
        fieldDataType !== FIELD_DATA_TYPES.DATETIME &&
        Object.values(FIELD_DATA_TYPES).includes(fieldDataType)) {
        options.push({ label: userObjectLabel, value: 'User' });
        options.push({ label: labelCurrentRecord, value: 'Current Record' });
        options.push({ label: labelCurrentRecordHeader, value: 'Current Record Header' });
    }

    return options;
};

/**
 * Get a list of literals for use as detail expression where type = 'Function'.
 * @param {String} A string data type of the field to determine options.
 * @returns {Array} A list of function options.
 */
export const getFunctionExpressionOptions = (fieldDataType, userLabel) => {
    const options = [];

    if (fieldDataType === FIELD_DATA_TYPES.DATETIME) {
        options.push({ label: labelNow, value: DATE_TIME_FUNCTION_LITERALS.NOW });
    }

    if (fieldDataType === FIELD_DATA_TYPES.DATE || fieldDataType === FIELD_DATA_TYPES.DATETIME) {
        options.push({ label: labelToday, value: DATE_TIME_FUNCTION_LITERALS.TODAY });
        options.push({ label: labelTomorrow, value: DATE_TIME_FUNCTION_LITERALS.TOMORROW });
        options.push({ label: labelYesterday, value: DATE_TIME_FUNCTION_LITERALS.YESTERDAY });
        options.push({ label: userLabel, value: 'User' });
    }

    if (fieldDataType !== FIELD_DATA_TYPES.DATE &&
        fieldDataType !== FIELD_DATA_TYPES.DATETIME &&
        Object.values(FIELD_DATA_TYPES).includes(fieldDataType)) {
        options.push({ label: userLabel , value: 'User' });
    }

    return options;
};

/**
 * Get a list of literals for use as detail expression where type = 'Function'.
 * @param {String} A string data type of the field to determine options.
 * @returns {Array} A list of function options.
 */
export const getLookupFunctionExpressionOptions = (fieldDataType, userLabel) => {
    const options = [];

    if (fieldDataType === FIELD_DATA_TYPES.DATETIME) {
        options.push({ label: labelNow, value: DATE_TIME_FUNCTION_LITERALS.NOW });
    }

    if (fieldDataType === FIELD_DATA_TYPES.DATE || fieldDataType === FIELD_DATA_TYPES.DATETIME) {
        options.push({ label: labelToday, value: DATE_TIME_FUNCTION_LITERALS.TODAY });
        options.push({ label: labelTomorrow, value: DATE_TIME_FUNCTION_LITERALS.TOMORROW });
        options.push({ label: labelYesterday, value: DATE_TIME_FUNCTION_LITERALS.YESTERDAY });
        options.push({ label: userLabel, value: 'User' });
        options.push({ label: labelCurrentRecordHeader, value: 'Current Record Header' });
    }

    if (fieldDataType !== FIELD_DATA_TYPES.DATE &&
        fieldDataType !== FIELD_DATA_TYPES.DATETIME &&
        Object.values(FIELD_DATA_TYPES).includes(fieldDataType)) {
        options.push({ label: userLabel, value: 'User' });
        options.push({ label: labelCurrentRecordHeader, value: 'Current Record Header' });
    }

    return options;
};

/**
* Get a list of source fields that can be be mapped to a target field based on the target data type
@param {Array} sourceFieldList - An array of source fields.
@param {Object} targetField - A target field object similar to the Apex DescribeFieldResult class.
@param {String} sourceObjectAPIName - The API name of the source object
@return {Array} - A list of source fields compatible with the target field.
**/
/* eslint-disable-next-line max-len */
export const getCompatibleFieldsForFieldMapping = (sourceFieldList, targetField, sourceObjectAPIName) => {
    let fieldList = [];

    const compatibleFieldsForEmail = [
        FIELD_DATA_TYPES.TEXTAREA,
        FIELD_DATA_TYPES.STRING,
        FIELD_DATA_TYPES.EMAIL
    ];
    const compatibleFieldsForDate = [
        FIELD_DATA_TYPES.DATE,
        FIELD_DATA_TYPES.DATETIME
    ];
    const compatibleFieldsForMultiPicklist = [
        FIELD_DATA_TYPES.MULTIPICKLIST,
        FIELD_DATA_TYPES.PICKLIST
    ];
    const compatibleFieldsForText = [
        FIELD_DATA_TYPES.PICKLIST,
        FIELD_DATA_TYPES.STRING,
        FIELD_DATA_TYPES.TEXTAREA,
        FIELD_DATA_TYPES.EMAIL,
        FIELD_DATA_TYPES.URL,
        FIELD_DATA_TYPES.REFERENCE,
        FIELD_DATA_TYPES.BOOLEAN,
        FIELD_DATA_TYPES.PHONE
    ];

    const compatibleFieldsForEncryptedText =
        [FIELD_DATA_TYPES.ENCRYPTEDSTRING].concat(compatibleFieldsForText);
    if (targetField) {
        switch (targetField.dataType) {
            case FIELD_DATA_TYPES.REFERENCE:
                fieldList = sourceFieldList.filter(field =>
                    (arraysEqual(field.referenceTo, targetField.referenceTo)
                    || (
                        field.dataType === FIELD_DATA_TYPES.ID
                        && targetField.referenceTo.indexOf(sourceObjectAPIName) > -1
                    ))
                );
                break;
            case FIELD_DATA_TYPES.DOUBLE:
                fieldList = sourceFieldList.filter(field =>
                    field.dataType === targetField.dataType
                    && (field.scale <= targetField.scale || field.calculated === true)
                );
                break;
            case FIELD_DATA_TYPES.DATE:
                fieldList = sourceFieldList.filter(field =>
                    compatibleFieldsForDate.includes(field.dataType)
                );
                break;
            case FIELD_DATA_TYPES.EMAIL:
                fieldList = sourceFieldList.filter(field =>
                    compatibleFieldsForEmail.includes(field.dataType)
                    && (field.length <= 255 || field.calculated === true)
                );
                break;
            case FIELD_DATA_TYPES.MULTIPICKLIST:
                fieldList = sourceFieldList.filter(field =>
                    compatibleFieldsForMultiPicklist.includes(field.dataType)
                );
                break;
            case FIELD_DATA_TYPES.PICKLIST:
                fieldList = sourceFieldList.filter(field =>
                    field.dataType === targetField.dataType
                    || (field.dataType === FIELD_DATA_TYPES.STRING && field.calculated === true)
                );
                break;
            case FIELD_DATA_TYPES.TEXTAREA:
                if (targetField.length > 255) {
                    fieldList = sourceFieldList.filter(field =>
                        compatibleFieldsForText.includes(field.dataType)
                    );
                } else {
                    fieldList = sourceFieldList.filter(field =>
                        compatibleFieldsForText.includes(field.dataType)
                        && (field.length <= 255 || field.calculated === true)
                    );
                }
                break;
            case FIELD_DATA_TYPES.ENCRYPTEDSTRING:
                fieldList = sourceFieldList.filter(field =>
                    (compatibleFieldsForEncryptedText.includes(field.dataType) &&
                        field.length <= 255)
                    || (compatibleFieldsForEncryptedText.includes(field.dataType) &&
                        field.calculated === true)
                );
                break;
            case FIELD_DATA_TYPES.STRING:
                fieldList = sourceFieldList.filter(field =>
                    (compatibleFieldsForText.includes(field.dataType) && field.length <= 255)
                    || (compatibleFieldsForText.includes(field.dataType) &&
                    field.calculated === true)
                );
                break;
            default:
                // all remaining field types such as [BOOLEAN, CURRENCY, DATETIME, ID, INTEGER,LONG,
                // PERCENT, PHONE, TIME, URL];
                fieldList = sourceFieldList.filter(field => field.dataType ===
                    targetField.dataType);
        }
    }
    return fieldList;
};

export const getRecordType = (record) => {
    return (record || {})[FIELD_API_NAMES.RECORD_TYPE_ID];
};

export const isRecordTypeField = (fieldName) => {
    return (
        FIELD_API_NAMES.RECORD_TYPE_ID.toLowerCase() ===
        (fieldName || "").toLowerCase()
    );
};

export const convertValueToNumber = (value) => {
    if (typeof value === "number") {
        return value;
    }

    if (typeof value === "string") {
        const stringConvertedToNumber = parseFloat(value);
        return Number.isNaN(stringConvertedToNumber)
            ? null
            : stringConvertedToNumber;
    }

    return null;
};

export const isValidURL = ( value ) => {

    // Regex to check valid URL

    if (value === null || value === undefined || value === '')
    {
        return false;
    }
    // Regex to check valid URL

    const regexp = /(http|https):\/\/(\w+:{0,1}\w*)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%!\-/]))?/;
    if (regexp.test(value)) {
        return true;
    }
    return false;
};

export const isValidEmail = ( value ) => {

    // Regex to check valid Email

    if (value === null || value === undefined || value === '')
    {
        return false;
    }
    // Regex to check valid Email

    // eslint-disable-next-line max-len
    const regexp = /^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/;

    if (regexp.test(value)) {
        return true;
    }
    return false;
};

export const isValidPhone = ( value ) => {

    // Regex to check valid Phone

    if (value === null || value === undefined || value === '')
    {
        return false;
    }
    const regexp = /^[0-9-+.()\s]*$/;
    // Regex to check valid Phone
    if (regexp.test(value)) {
        return true;
    }
    return false;
};

const resolveSourceRecordByObjectMapping = async (
    mappingConfig,
    sourceRecordId,
    asyncExecuteQueryFn
) => {
    const fieldMap = ((mappingConfig || {}).objectMappingDetails || []).filter(
        (ff) => ff.mappingType === OBJECT_MAPPING_TYPES.FIELD
    );

    const fieldMapApiNameList = (fieldMap || []).map(
        (ff) => `${mappingConfig.sourceObjectAPIName}.${ff.sourceFieldAPIName}`
    );

    const resolvedSourceRecord =
      fieldMapApiNameList.length && sourceRecordId
          ? await asyncExecuteQueryFn(sourceRecordId, fieldMapApiNameList)
          : null;
    return resolvedSourceRecord;
};

export const executeObjectMapping = async (
    mappingConfig,
    userInfo,
    targetObjectDescribe,
    sourceRecordId,
    recordTypeInfo,
    currentRecord,
    headerRecord,
    asyncExecuteQueryFn,
    transactionType,
    headerObjectDescribe,
    applyValueMapping = false,
) => {
    if (!mappingConfig) return {};
    const resolvedSourceRecord =
    (await resolveSourceRecordByObjectMapping(
        mappingConfig,
        sourceRecordId,
        asyncExecuteQueryFn
    )) || {};

    const resolvedUserRecord = await resolveUserRecordByObjectMapping(
        mappingConfig,
        asyncExecuteQueryFn
    );

    const resolvedCurrentRecord = await resolveCurrentRecordByObjectMapping(
        mappingConfig,
        FUNCTION_LITERALS.CURRENTRECORD,
        currentRecord,
        asyncExecuteQueryFn
    );

    const resolvedCurrentHeaderRecord = await resolveCurrentRecordByObjectMapping(
        mappingConfig,
        FUNCTION_LITERALS.CURRENTRECORDHEADER,
        headerRecord,
        asyncExecuteQueryFn
    );

    const recordType = getRecordType(currentRecord);
    const newValues = (mappingConfig.objectMappingDetails || []).reduce(
        (acc, ff) => {
            const fieldDescribe = targetObjectDescribe[ff.targetFieldAPIName];
            const fieldType = (fieldDescribe || {}).dataType;

            const validateField = (value) => {
                if (!fieldDescribe) {
                    return { [ff.targetFieldAPIName]: value };
                }

                if (fieldType === FIELD_DATA_TYPES.PICKLIST) {
                    let pickListValues = fieldDescribe.picklistValues || [];

                    // check if the picklist is constrained by record type
                    if (
                        recordTypeInfo &&
                        recordType &&
                        !isRecordTypeField(ff.targetFieldAPIName)
                    ) {
                        const valuesByRecType = (recordTypeInfo[ff.targetFieldAPIName] || {})
                            .picklistValues;
                        pickListValues = valuesByRecType || pickListValues;
                    }

                    // check if the picklist is dependent list
                    const { controllerFieldName } = fieldDescribe;
                    if (controllerFieldName && recordTypeInfo) {
                        const controllerType =
                            targetObjectDescribe[controllerFieldName]?.dataType;
                        let controllerValue =
                            controllerType === FIELD_DATA_TYPES.BOOLEAN
                                ? acc[controllerFieldName] || false
                                : acc[controllerFieldName];

                        if (!controllerValue && Object.keys(currentRecord).length) {
                            controllerValue =
                                controllerType === FIELD_DATA_TYPES.BOOLEAN
                                    ? currentRecord[controllerFieldName] || false
                                    : currentRecord[controllerFieldName];
                        }

                        if (controllerValue) {
                            const fieldDependencies = (recordTypeInfo[ff.targetFieldAPIName] || {})
                                .fieldDependencies;
                            pickListValues = (pickListValues || []).filter(
                                (pv) => ((fieldDependencies || {})[controllerValue] || {})[pv.value]
                            );
                        }
                    }

                    // then to determine if the src value copied to target or not
                    return {
                        [ff.targetFieldAPIName]: pickListValues
                            .map((v) => v.value)
                            .includes(value)
                            ? value
                            : null,
                    };
                }
                if (
                    [
                        FIELD_DATA_TYPES.CURRENCY,
                        FIELD_DATA_TYPES.DOUBLE,
                        FIELD_DATA_TYPES.INTEGER,
                        FIELD_DATA_TYPES.PERCENT,
                    ].includes(fieldType)
                ) {
                    return { [ff.targetFieldAPIName]: convertValueToNumber(value) };
                }
                if (
                    [FIELD_DATA_TYPES.DATE, FIELD_DATA_TYPES.DATETIME].includes(fieldType) &&
                    !isValidDate(value)
                ) {
                    return { [ff.targetFieldAPIName]: null };
                }
                if (FIELD_DATA_TYPES.DATE === fieldType) {
                    const dateArr = value.split('T');
                    if (dateArr.length === 2) {
                        const date = convertToLocalDateByUserTimeZone(
                            value,
                            userInfo.timeZoneOffSet
                        );
                        return { [ff.targetFieldAPIName]: date };
                    }
                    return { [ff.targetFieldAPIName]: value };
                }
                if (
                    [FIELD_DATA_TYPES.BOOLEAN].includes(fieldType) &&
                        typeof value === "string"
                ) {
                    return { [ff.targetFieldAPIName]: value.toLowerCase() === "true" };
                }
                if (
                    [FIELD_DATA_TYPES.STRING, FIELD_DATA_TYPES.TEXTAREA].includes(
                        fieldType
                    ) &&
                    value &&
                    typeof value === "object"
                ) {
                    // any field can map to string
                    return { [ff.targetFieldAPIName]: value.value };
                }

                return { [ff.targetFieldAPIName]: value };
            };

            const resolveField = (config) => {
                return getActualValue(resolvedSourceRecord, config.sourceFieldAPIName);
            };

            const resolveLiteral = (config) => {
                let resolvedValue = config.value;

                if (
                    config.value === FUNCTION_LITERALS.USER &&
                    config.literalParameterAPIName
                ) {
                    if (isARecord(resolvedUserRecord)) {
                        resolvedValue = getActualValue(
                            resolvedUserRecord,
                            config.literalParameterAPIName
                        );
                    } else {
                        throw new Error(
                            formatString(labelInvalidUserLiteral,
                            targetObjectDescribe[ff.targetFieldAPIName]?.label ||
                            ff.targetFieldAPIName)
                        );
                    }
                } else if (
                    config.value === FUNCTION_LITERALS.CURRENTRECORD &&
                    config.literalParameterAPIName &&
                    resolvedCurrentRecord
                ) {
                    if (
                        resolvedCurrentRecord[config.literalParameterAPIName] === undefined
                    )  {
                        if (transactionType === TRANSACTION_TYPE.SOURCE_TO_TARGET
                            || applyValueMapping) {
                            resolvedValue = fieldType === FIELD_DATA_TYPES.BOOLEAN ? false : null;
                        } else {
                            throw new Error(
                                formatString(labelInvalidCurrentRecord,
                                targetObjectDescribe[ff.targetFieldAPIName]?.label ||
                                ff.targetFieldAPIName)
                            );
                        }
                    }
                    resolvedValue =
                        resolvedCurrentRecord[config.literalParameterAPIName];

                } else if (
                    config.value === FUNCTION_LITERALS.CURRENTRECORDHEADER &&
                    config.literalParameterAPIName &&
                    resolvedCurrentHeaderRecord
                ) {
                    if (resolvedCurrentHeaderRecord[config.literalParameterAPIName] === undefined) {
                        if (transactionType === TRANSACTION_TYPE.SOURCE_TO_TARGET) {
                            resolvedValue = headerObjectDescribe[config.literalParameterAPIName]
                                ?.dataType === FIELD_DATA_TYPES.BOOLEAN ? false : null;
                        } else {
                            throw new Error(formatString(labelInvalidCurrentHeader,
                                targetObjectDescribe[ff.targetFieldAPIName]?.label ||
                                ff.targetFieldAPIName));
                        }
                    } else {
                        resolvedValue =
                            resolvedCurrentHeaderRecord[config.literalParameterAPIName];
                    }
                } else {
                    resolvedValue = resolveLiterals(config.value, fieldType);
                }
                return resolvedValue;
            };

            const resolveValue = (config) => {
                const value = config.value;
                if (
                    [FIELD_DATA_TYPES.DATETIME].includes(fieldType)
                ) {
                    return convertToUserTimeZone(
                        value,
                        userInfo.timeZoneOffSet
                    );
                }
                return value;
            }

            if ([OBJECT_MAPPING_TYPES.FIELD].includes(ff.mappingType)) {
                return { ...acc, ...validateField(resolveField(ff)) };
            }
            if ([OBJECT_MAPPING_TYPES.FUNCTION].includes(ff.mappingType)) {
                return { ...acc, ...validateField(resolveLiteral(ff)) };
            }
            if ([OBJECT_MAPPING_TYPES.VALUE].includes(ff.mappingType)) {
                return { ...acc, ...validateField(resolveValue(ff)) };
            }

            return {
                ...acc,
                ...validateField(resolvedSourceRecord[ff.sourceFieldAPIName || ""]),
            };
        },
        {}
    );
    return newValues;
};