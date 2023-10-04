import { FIELD_DATA_TYPES } from './constants';

export const fieldIsType = (fieldDefinition, fieldType) =>
    fieldDefinition && fieldDefinition.dataType &&
        fieldDefinition.dataType.toUpperCase() === fieldType;

export const isAddressField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.ADDRESS);

export const isBase64Field = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.BASE64);

export const isBooleanField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.BOOLEAN);

export const isComboboxField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.COMBOBOX);

export const isCurrencyField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.CURRENCY);

export const isDateField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.DATE);

export const isDatetimeField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.DATETIME);

export const isDoubleField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.DOUBLE);

export const isEmailField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.EMAIL);

export const isEncryptedField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.ENCRYPTEDSTRING);

export const isIdField = fieldDefinition =>
    fieldDefinition.apiName === 'Id' || fieldIsType(fieldDefinition, FIELD_DATA_TYPES.ID);

export const isIntegerField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.INTEGER);

export const isLocationField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.LOCATION);

export const isLongField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.LONG);

export const isMultiPicklistField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.MULTIPICKLIST);

export const isPercentField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.PERCENT);

export const isPhoneField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.PHONE);

export const isPicklistField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.PICKLIST);

export const isReferenceField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.REFERENCE);

export const isStringField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.STRING);

export const isTextAreaField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.TEXTAREA);

export const isTimeField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.TIME);

export const isUrlField = fieldDefinition =>
    fieldIsType(fieldDefinition, FIELD_DATA_TYPES.URL);