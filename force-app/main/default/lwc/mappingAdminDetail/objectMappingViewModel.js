import {
    getMappingTypeOptions,
    getFunctionMappingOptions,
    getCompatibleFieldsForFieldMapping,
    MAPPING_TYPES,
    FIELD_DATA_TYPES,
    DATA_TYPE_ICONS,
    normalizeDeveloperName,
    formatDateValue,
    getLookupReferenceToObject,
    getLookupReferenceNameFields,
    isNotUndefinedOrNull,
    TIMEZONE_GMT,
    FUNCTION_LITERALS,
    convertValueToNumber,
    isValidDate,
    isValidURL,
    isValidPhone,
    isValidEmail,
    DATE_TIME_FUNCTION_LITERALS,
    isSalesforceId,
} from 'c/utils';

import labelTrue from '@salesforce/label/c.Label_True';
import labelFalse from '@salesforce/label/c.Label_False';
import labelSearch from '@salesforce/label/c.Placeholder_Search';
import messageInvalidValue from '@salesforce/label/c.Message_InvalidValue';
import errorLiteralParameterSelection
    from '@salesforce/label/c.Error_LiteralParameterSelection';
import messageDataSourceObjectSelection
    from '@salesforce/label/c.Message_DataSourceObjectSelection';
import messageConfigureHeaderObject
    from '@salesforce/label/c.Message_ConfigureHeaderObject';

const FIELD_MAPPING_TYPE = 'Field';
const VALUE_MAPPING_TYPE = 'Value';
const FUNCTION_MAPPING_TYPE = 'Function';

const i18n = {
    trueLabel: labelTrue,
    falseLabel: labelFalse,
    invalidValue: messageInvalidValue,
    search: labelSearch,
    literalParameterSelection: errorLiteralParameterSelection,
    dataSourceObjectSelection: messageDataSourceObjectSelection,
    configureHeaderObject: messageConfigureHeaderObject,
};

export class ObjectMappingViewModel {
    id;
    sourceObjectAPIName = '';
    sourceObjectLabel = '';
    targetObjectAPIName = '';
    targetObjectLabel = '';
    headerObjectAPIName = '';
    headerObjectLabel = '';
    userObjectLabel = '';
    userObjectAPIName = '';
    type = '';
    relatedObjectDetails = '';
    userOptionLabel = '';

    objectMappingDetails = [];
    entityFieldLabels = {};
    entityFieldDefinitions = {};
    entityDefinitionsWithFields = {};
    sourceFields = [];
    targetFields = [];
    userFields = [];
    headerFields = [];

    _isDirty = false;
    _name = '';
    _developerName = '';
    _description = '';

    constructor (objectMappingRecord, entityDefinitionsWithFields, mappingType, userOptionLabel) {
        let sourceLabel = '';
        let sourceAPIName = '';
        if (entityDefinitionsWithFields && entityDefinitionsWithFields.sourceEntity) {
            sourceLabel = entityDefinitionsWithFields.sourceEntity.label;
            sourceAPIName = entityDefinitionsWithFields.sourceEntity.apiName;
        }

        let targetLabel = '';
        let targetAPIName = '';
        if (entityDefinitionsWithFields && entityDefinitionsWithFields.targetEntity) {
            targetLabel = entityDefinitionsWithFields.targetEntity.label;
            targetAPIName = entityDefinitionsWithFields.targetEntity.apiName;
        }

        let userLabel = '';
        let userAPIName = '';
        if (entityDefinitionsWithFields && entityDefinitionsWithFields.userEntity) {
            userLabel = entityDefinitionsWithFields.userEntity.label;
            userAPIName = entityDefinitionsWithFields.userEntity.apiName;
        }
        let headerLabel = '';
        let headerAPIName = '';
        if (entityDefinitionsWithFields && entityDefinitionsWithFields.headerEntity) {
            headerLabel = entityDefinitionsWithFields.headerEntity.label;
            headerAPIName = entityDefinitionsWithFields.headerEntity.apiName;
        }
        if (entityDefinitionsWithFields) {
            this.entityDefinitionsWithFields = entityDefinitionsWithFields;
        }

        this.targetObjectLabel = targetLabel;
        this.targetObjectAPIName =  targetAPIName;
        this.sourceObjectLabel = sourceLabel;
        this.sourceObjectAPIName = sourceAPIName;
        this.userObjectLabel = userLabel;
        this.userObjectAPIName = userAPIName;
        this.headerObjectLabel = headerLabel;
        this.headerObjectAPIName = headerAPIName;
        this.userOptionLabel = userOptionLabel;

        if (objectMappingRecord) {
            this._name = objectMappingRecord.name;
            this._developerName = objectMappingRecord.developerName;
            this.id = objectMappingRecord.id;
            this._description = objectMappingRecord.description;
            this.type = objectMappingRecord.mappingType;
            this.relatedObjectDetails = objectMappingRecord.relatedObjectDetails;
        } else {
            this.type = mappingType;
        }

        const enableAutoMapping = (this.type === MAPPING_TYPES.FIELD && this.id === undefined);
        this.sourceFields = this.getEntityFields(entityDefinitionsWithFields, 'sourceEntity');
        this.targetFields = this.getEntityFields(entityDefinitionsWithFields, 'targetEntity');
        this.userFields = this.getEntityFields(entityDefinitionsWithFields, 'userEntity');
        this.headerFields = this.getEntityFields(entityDefinitionsWithFields, 'headerEntity');

        const deletedTargetObjectMappings = [];
        if (objectMappingRecord && objectMappingRecord.objectMappingDetails && this.targetFields) {
            Array.from(objectMappingRecord.objectMappingDetails).forEach ( detail => {
                let isFieldFound = false;
                this.targetFields.forEach ( field => {
                    if (field.apiName === detail.targetFieldAPIName) {
                        isFieldFound = true;
                    }
                });
                if (!isFieldFound) {
                    deletedTargetObjectMappings.push(detail);
                }

            });
        }

        if (deletedTargetObjectMappings) {
            deletedTargetObjectMappings.forEach( detail =>
            {
                detail.hasError = true;
                // eslint-disable-next-line no-use-before-define
                const detailRecord = new ObjectMappingDetailViewModel(
                    this.type,
                    null,
                    detail,
                    this.sourceObjectLabel,
                    this.sourceObjectAPIName,
                    this.targetObjectAPIName,
                    this.targetObjectLabel,
                    this.headerObjectAPIName,
                    this.headerObjectLabel,
                    this.sourceFields,
                    this.targetFields,
                    this.userFields,
                    this.headerFields,
                    null,
                    enableAutoMapping,
                    this.entityFieldLabels,
                    this.userOptionLabel
                );
                this.objectMappingDetails.push(detailRecord);
            });
        }

        if (this.targetFields && this.targetFields.length > 0) {
            let mappingDetails = [];
            mappingDetails = this.targetFields
                .filter(field => {
                    const fieldIsCreatable = field.createable === true;

                    return fieldIsCreatable;
                })
                .map(field => {
                    let detailRecord;
                    if (objectMappingRecord && objectMappingRecord.objectMappingDetails) {
                        detailRecord = objectMappingRecord.objectMappingDetails.find(detail =>
                            detail.targetFieldAPIName === field.apiName
                        );
                    }

                    // eslint-disable-next-line no-use-before-define
                    return new ObjectMappingDetailViewModel(
                        this.type,
                        field,
                        detailRecord,
                        this.sourceObjectLabel,
                        this.sourceObjectAPIName,
                        this.targetObjectAPIName,
                        this.targetObjectLabel,
                        this.headerObjectAPIName,
                        this.headerObjectLabel,
                        this.sourceFields,
                        this.targetFields,
                        this.userFields,
                        this.headerFields,
                        entityDefinitionsWithFields.targetEntity.recordTypeInfos,
                        enableAutoMapping,
                        this.entityFieldLabels,
                        this.userOptionLabel
                    );
                });
            this.objectMappingDetails = [...this.objectMappingDetails , ...mappingDetails];
        }
    }

    get isDirty () {
        let childrenDirty = false;
        if (this.objectMappingDetails && this.objectMappingDetails.length > 0) {
            childrenDirty = (this.objectMappingDetails.findIndex(detail => detail.isDirty) !== -1);
        }

        return (this._isDirty || childrenDirty);
    }

    get isFieldType () {
        return (this.type === MAPPING_TYPES.FIELD);
    }

    get name () {
        return this._name;
    }
    set name (value) {
        if (value !== this._name) {
            this._name = value;
            this._isDirty = true;
        }
    }

    get developerName () {
        return this._developerName;
    }
    set developerName (value) {
        if (value !== this._developerName) {
            this._developerName = value;
            this._isDirty = true;
        }
    }

    get description () {
        return this._description;
    }
    set description (value) {
        if (value !== this._description) {
            this._description = value;
            this._isDirty = true;
        }
    }

    markAsClone (namePrefix) {
        this._name = namePrefix + ' ' + this._name;
        this.id = null;
        this._developerName = normalizeDeveloperName(this._name);

        // Remove IDs from Detail mappings
        if (this.objectMappingDetails) {
            // eslint-disable-next-line no-return-assign
            this.objectMappingDetails.forEach(detail => detail.id = null);
        }
    }

    clearAllDetailMappings () {
        this.objectMappingDetails.forEach(detail => detail.reset());
    }

    getRecordData () {
        let recordDetails = [];
        if (this.objectMappingDetails) {
            recordDetails = this.objectMappingDetails
                .filter(detail => {
                    const mappingIsDefined = isNotUndefinedOrNull(detail.mappingType);

                    const fieldMappingValid
                        = detail.mappingType === FIELD_MAPPING_TYPE
                        && isNotUndefinedOrNull(detail.sourceFieldAPIName)
                        && isNotUndefinedOrNull(detail.targetFieldAPIName);

                    const valueMappingValid
                        = detail.mappingType === VALUE_MAPPING_TYPE
                        && isNotUndefinedOrNull(detail.targetFieldAPIName)
                        && isNotUndefinedOrNull(detail.value);

                    const functionMappingValid
                        = detail.mappingType === FUNCTION_MAPPING_TYPE
                        && isNotUndefinedOrNull(detail.targetFieldAPIName)
                        && isNotUndefinedOrNull(detail.value);

                    const functionLiteralMappingValid
                        = detail.mappingType === FUNCTION_MAPPING_TYPE
                        && isNotUndefinedOrNull(detail.value)
                        && ( detail.value === FUNCTION_LITERALS.USER
                            || detail.value === FUNCTION_LITERALS.CURRENTRECORD
                            || detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER)
                        && isNotUndefinedOrNull(detail.targetFieldAPIName)
                        && isNotUndefinedOrNull(detail.literalParameterAPIName);

                    return mappingIsDefined
                            && (fieldMappingValid
                                || valueMappingValid
                                || functionMappingValid
                                || functionLiteralMappingValid);
                })
                .map(detail => {
                    return {
                        id: detail.id,
                        mappingType: detail.mappingType,
                        sourceFieldAPIName: detail.sourceFieldAPIName,
                        targetFieldAPIName: detail.targetFieldAPIName,
                        value: detail.value,
                        literalParameterAPIName: detail.literalParameterAPIName,
                        relatedObjectDetails: detail.relatedObjectDetails,
                        referenceFieldLabel: detail.referenceFieldLabel,
                    }
                });
        }

        const record = {
            id: this.id || null,
            name: this.name,
            mappingType: this.type,
            description: this.description,
            developerName: this.developerName,
            sourceObjectAPIName: this.sourceObjectAPIName,
            targetObjectAPIName: this.targetObjectAPIName,
            headerRecordObject: this.headerObjectAPIName,
            objectMappingDetails: recordDetails
        }

        return record;
    }

    validateObjectMappingDetails (entitiesWithFields) {
        let invalidValueRowCount = 0;
        this.objectMappingDetails.forEach(detail => {
            if (detail.mappingType !== 'Function' && detail.mappingType !== 'Field'
                && detail.targetField && detail.value) {
                if (
                    [   FIELD_DATA_TYPES.CURRENCY,
                        FIELD_DATA_TYPES.DOUBLE,
                        FIELD_DATA_TYPES.INTEGER,
                        FIELD_DATA_TYPES.PERCENT,
                    ].includes(detail.targetField.dataType) &&
                    !convertValueToNumber(detail.value)
                ) {
                    detail.hasWarning = true;
                    invalidValueRowCount++;
                }
                else if (
                    [   FIELD_DATA_TYPES.DATE,
                        FIELD_DATA_TYPES.DATETIME
                    ].includes(detail.targetField.dataType) &&
                    !isValidDate(detail.value)
                ) {
                    detail.hasWarning = true;
                    invalidValueRowCount++;
                }
                //invalid boolean stores to default value so emptying mapping type
                else if (
                    [   FIELD_DATA_TYPES.BOOLEAN    ].includes(detail.targetField.dataType) &&
                    typeof detail.value === "string" &&
                    !(detail.value.toLowerCase() === "true" ||
                    detail.value.toLowerCase() === "false")
                ) {
                    detail.mappingType = '';
                }
                // any field can map to string
                else if (
                    [   FIELD_DATA_TYPES.STRING,
                        FIELD_DATA_TYPES.TEXTAREA   ].includes(detail.targetField.dataType) &&
                    !(typeof detail.value === "object" || typeof detail.value === "string")
                ) {
                    detail.hasWarning = true;
                    invalidValueRowCount++;
                }
                else if (
                    [   FIELD_DATA_TYPES.URL  ].includes(detail.targetField.dataType) &&
                    !isValidURL(detail.value)
                ) {
                    detail.hasWarning = true;
                    invalidValueRowCount++;
                }
                else if (
                    [   FIELD_DATA_TYPES.PHONE  ].includes(detail.targetField.dataType) &&
                    !isValidPhone(detail.value)
                ) {
                    detail.hasWarning = true;
                    invalidValueRowCount++;
                }
                else if (
                    [   FIELD_DATA_TYPES.EMAIL  ].includes(detail.targetField.dataType) &&
                    !isValidEmail(detail.value)
                ) {
                    detail.hasWarning = true;
                    invalidValueRowCount++;
                }
                else if (
                    [   FIELD_DATA_TYPES.PICKLIST,
                        FIELD_DATA_TYPES.MULTIPICKLIST  ].includes(detail.targetField.dataType)
                    && detail.targetField.picklistValues
                    && detail.targetField.picklistValues.length > 0) {
                    const valueAsArray = detail.value.split(';');
                    const labelsArray = [];

                    valueAsArray.forEach(val => {
                        const picklistItem
                        = detail.targetField.picklistValues.find(item => item.value === val);

                        if (picklistItem) {
                            labelsArray.push(picklistItem.label);
                        }
                    });

                    if (labelsArray.length === 0) {
                        detail.hasWarning = true;
                        invalidValueRowCount++;
                    } else {
                        detail.hasWarning = false;
                    }
                } else if ( [FIELD_DATA_TYPES.REFERENCE].includes(detail.targetField.dataType)
                            && detail.targetField.apiName === 'RecordTypeId') {
                    const selectedRecordType =
                        entitiesWithFields.targetEntity.recordTypeInfos.find(recordType => {
                        return recordType.recordTypeId === detail.value;
                    })
                    if (!selectedRecordType.isActive) {
                        detail.hasWarning = true;
                        invalidValueRowCount++;
                    }
                }
                else {
                    detail.hasWarning = false;
                }
            }
            if (detail.mappingType === 'Function' &&
            Object.values(DATE_TIME_FUNCTION_LITERALS).includes(detail.value) &&
            ![FIELD_DATA_TYPES.DATE, FIELD_DATA_TYPES.DATETIME].
                includes(detail.targetField.dataType)) {
                detail.hasWarning = true;
                invalidValueRowCount++;
            }
            return invalidValueRowCount;
        });
        return invalidValueRowCount;

    }

    getEntityFields (entityDefinitions, propertyName) {
        if (entityDefinitions && Reflect.has(entityDefinitions, propertyName)) {
            const entity = Reflect.get(entityDefinitions, propertyName);

            const fieldDefinitionsPropertyName = 'fieldDefinitions';
            if (entity && Reflect.has(entity, fieldDefinitionsPropertyName)) {
                return Reflect.get(entity, fieldDefinitionsPropertyName);
            }
        }

        return [];
    }
}

export class ObjectMappingDetailViewModel {
    dataType;
    id;
    targetField;
    sourceObjectLabel;
    sourceObjectAPIName;
    headerObjectLabel;
    targetObjectLabel;
    headerObjectAPIName;
    targetObjectAPIName;
    recordTypeId;
    valueId;
    detailRecord;
    sourceFields = [];
    targetFields = [];
    userFields = [];
    headerFields = [];
    recordTypeInfos = [];
    parentMappingType;
    entityFieldLabels = {};
    userOptionLabel = '';

    _isDirty = false;
    _editMode = false;
    _isMapped = false;
    _hasWarning = false;
    _warningMessage = '';
    isTargetFieldDeleted = false;

    _mappingTypeOptions = [];
    _functionOptions = [];
    _compatibleFieldOptions = [];
    _compatibleLiteralFieldOptions = [];

    constructor (
        parentMappingType,
        targetField,
        detailRecord,
        sourceObjectLabel,
        sourceObjectAPIName,
        targetObjectAPIName,
        targetObjectLabel,
        headerObjectAPIName,
        headerObjectLabel,
        sourceFields,
        targetFields,
        userFields,
        headerFields,
        recordTypeInfos,
        enableAutoMapping,
        entityFieldLabels,
        userOptionLabel
    ) {
        this.detailRecord = detailRecord;
        this.parentMappingType = parentMappingType;
        this.targetField = targetField;
        this.sourceObjectLabel = sourceObjectLabel;
        this.sourceObjectAPIName = sourceObjectAPIName;
        this.targetObjectAPIName = targetObjectAPIName;
        this.targetObjectLabel = targetObjectLabel;
        this.headerObjectAPIName = headerObjectAPIName ? headerObjectAPIName : '';
        this.headerObjectLabel = headerObjectLabel ? headerObjectLabel : '';
        this.recordTypeInfos = recordTypeInfos;
        this.dataType = targetField ? targetField.dataType : null;
        this.entityFieldLabels = entityFieldLabels;
        this.id = (detailRecord) ? detailRecord.id : null;
        this.userOptionLabel = userOptionLabel;
        if (sourceFields && sourceFields.length > 0) {
            this.sourceFields = sourceFields;
        }

        if (targetFields && targetFields.length > 0) {
            this.targetFields = targetFields;
        }

        if (userFields && userFields.length > 0) {
            this.userFields = userFields;
        }

        if (headerFields && headerFields.length > 0) {
            this.headerFields = headerFields;
        }

        this._isMapped = (detailRecord);
        this._mappingType = (detailRecord) ? detailRecord.mappingType : null;
        this._sourceFieldAPIName = (detailRecord) ? detailRecord.sourceFieldAPIName : null;
        this._value = (detailRecord) ? detailRecord.value : null;
        this.valueId = this._value;
        if (detailRecord && detailRecord.targetFieldAPIName === 'RecordTypeId'
            && detailRecord.mappingType === 'Value') {
            if (!isSalesforceId(this._value)) {
                this._value = this.getRecordTypeId(this._value);
            }
        }
        this._literalParameterAPIName = (detailRecord) ?
            detailRecord.literalParameterAPIName : null;
        this._relatedObjectDetails = (detailRecord) ? detailRecord.relatedObjectDetails : null;
        this.hasWarning = (detailRecord) ? detailRecord.hasError : false;

        if (this.dataType && this._value && ( this.dataType === FIELD_DATA_TYPES.MULTIPICKLIST ||
            this.dataType === FIELD_DATA_TYPES.PICKLIST )) {
            //Run formatPicklist in the constructor to validate the value.
            this.formatPicklist();
        }

        //validating value against target field datatype
        if (this._mappingType !== 'Function' && this._mappingType !== 'Field' && this._value) {
            if (
                [   FIELD_DATA_TYPES.CURRENCY,
                    FIELD_DATA_TYPES.DOUBLE,
                    FIELD_DATA_TYPES.INTEGER,
                    FIELD_DATA_TYPES.PERCENT,
                ].includes(this.dataType) &&
                !convertValueToNumber(this._value)
            ) {
                this.hasWarning =  true;
            }

            if (
                [FIELD_DATA_TYPES.DATE, FIELD_DATA_TYPES.DATETIME].includes(this.dataType) &&
                !isValidDate(this._value)
            ) {
                this.hasWarning = true;
            }

            if (
                [FIELD_DATA_TYPES.BOOLEAN].includes(this.dataType) &&
                    typeof this._value === "string" &&
                    !(this._value.toLowerCase() === "true" || this._value.toLowerCase() === "false")
            ) {
                this._mappingType = '';
            }
            // any field can map to string
            if (
                [FIELD_DATA_TYPES.STRING, FIELD_DATA_TYPES.TEXTAREA].includes(this.dataType) &&
                !(typeof this._value === "object" || typeof this._value === "string")
            ) {
                this.hasWarning = true;
            }
            if (
                [   FIELD_DATA_TYPES.URL  ].includes(this.dataType) &&
                !isValidURL(this._value)
            ) {
                this.hasWarning = true;
            }
            if (
                [   FIELD_DATA_TYPES.PHONE  ].includes(this.dataType) &&
                !isValidPhone(this._value)
            ) {
                this.hasWarning = true;
            }
            if (
                [   FIELD_DATA_TYPES.EMAIL  ].includes(this.dataType) &&
                !isValidEmail(this._value)
            ) {
                this.hasWarning = true;
            }
            if (
                [   FIELD_DATA_TYPES.REFERENCE  ].includes(this.dataType) &&
                detailRecord && detailRecord.targetFieldAPIName === 'RecordTypeId'
            ) {
                this.formatReference();
            }
        }
        if (this._mappingType === 'Function'
            && Object.values(DATE_TIME_FUNCTION_LITERALS).includes(this._value)
            && ![FIELD_DATA_TYPES.DATE, FIELD_DATA_TYPES.DATETIME].includes(this.dataType)) {
            this.hasWarning = true;
        }
        // Auto-mapping functionality for new Field Mapping
        if (enableAutoMapping) {
            const targetFieldApi = this.targetField? this.targetField.apiName :
                detailRecord.targetFieldAPIName;
            const targetFieldType = this.dataType;

            const availableFields = getCompatibleFieldsForFieldMapping(sourceFields,
                targetField, sourceObjectAPIName);

            let sourceField;
            if (availableFields) {
                sourceField = availableFields.find(field => {
                // Match on field api name and data type
                    if (field.apiName === targetFieldApi && field.dataType === targetFieldType) {
                        return true;
                    }
                    // For Lookups, attempt to match up the source object ID field
                    if (targetFieldType === FIELD_DATA_TYPES.REFERENCE
                        && field.dataType === FIELD_DATA_TYPES.ID && this.targetField
                        && this.targetField.referenceTo.indexOf(sourceObjectAPIName) > -1 ) {
                        return true
                    }
                    return false;
                });
            }

            if (sourceField) {
                this._mappingType = FIELD_MAPPING_TYPE;
                this._isMapped = true;
                this._sourceFieldAPIName = sourceField.apiName;
                this._referenceFieldLabel = this.sourceObjectLabel + ': ' +
                    this.getLabelFromFieldList(this._sourceFieldAPIName);
            }
        }

    }

    get targetFieldAPIName () {
        let targetFieldAPIName;
        if (this.targetField) {
            targetFieldAPIName = this.targetField.apiName;
        } else {
            targetFieldAPIName = this.detailRecord.targetFieldAPIName;
        }
        return targetFieldAPIName;
    }

    get targetFieldLabel () {
        let targetFieldLabel;
        if (this.targetField) {
            targetFieldLabel =  this.targetField.label;
        } else {
            targetFieldLabel =  this.detailRecord.targetFieldAPIName;
            this.isTargetFieldDeleted = true;
        }
        return targetFieldLabel;
    }

    get targetFieldDataTypeIcon () {
        return DATA_TYPE_ICONS[this.dataType];
    }

    get mappingTypeLabel () {
        // eslint-disable-next-line consistent-return,array-callback-return
        return this._mappingType ? this.mappingTypeOptions?.find( type => {
            if (type?.value === this._mappingType )
                return type;
        })?.label : '';
    }

    get mappingType () {
        return this._mappingType;
    }
    set mappingType (value) {
        if (value !== this._mappingType) {
            this._mappingType = value;
            this.isDirty = true;
            this.isMapped = true;
            this.sourceFieldAPIName = null;
            this.value = null;
            this.literalParameterAPIName = null;
        }
    }

    get meta () {
        const referenceTo = getLookupReferenceToObject(this.targetField);
        return this.targetField && referenceTo
            ? {
                filters: this.targetField.apiName !== "RecordTypeId"
                    ? ""
                    : "SObjectType = '" + this.targetObjectAPIName + "' AND isActive = true ",
                icon: `standard:${referenceTo.toLowerCase()}`,
                objectApiName: referenceTo,
                fieldApiName: this.targetField.apiName,
                placeholder: i18n.search,
                referenceNameFields: getLookupReferenceNameFields(this.targetField),
            }
            : undefined;
    }

    get hasWarning () {
        return this._hasWarning;
    }

    set hasWarning (value) {
        this._hasWarning = value;
    }

    get isDirty () {
        return this._isDirty;
    }
    set isDirty (value) {
        this._isDirty = value;
    }

    get editMode () {
        return this._editMode;
    }
    set editMode (value) {
        this._editMode = value;
    }

    get isMapped () {
        return this._isMapped;
    }
    set isMapped (value) {
        if (value !== this._isMapped) {
            this._isMapped = value;
            this.isDirty = true;
        }
    }

    get sourceFieldAPIName () {
        return this._sourceFieldAPIName;
    }
    set sourceFieldAPIName (value) {
        if (value !== this._sourceFieldAPIName) {
            this._sourceFieldAPIName = value;
            this._value = null;
            this.isDirty = true;
        }
    }

    get literalParameterAPIName () {
        return this._literalParameterAPIName;
    }
    set literalParameterAPIName (value) {
        if (value !== this._literalParameterAPIName) {
            this._literalParameterAPIName = value;
            this.isDirty = true;
        }
    }

    get relatedObjectDetails () {
        return this._relatedObjectDetails;
    }
    set relatedObjectDetails (value) {
        if (value !== this._relatedObjectDetails) {
            this._relatedObjectDetails = value;
            this.isDirty = true;
        }
    }

    get referenceFieldLabel () {
        return this._referenceFieldLabel;
    }
    set referenceFieldLabel (value) {
        if (value !== this._referenceFieldLabel) {
            this._referenceFieldLabel = value;
        }
    }

    get sourceFieldLabel () {
        return this.getLabelFromFieldList(this._sourceFieldAPIName);
    }

    get literalParameterLabel () {
        return this.getLiteralLabelFromFieldList(this._literalParameterAPIName);
    }

    get functionValueLabel () {
        const functionOption = this.functionOptions.find(opt => opt.value === this.value);

        return (functionOption) ? functionOption.label : this.value;
    }

    get valueLabel () {
        if (this.dataType && this._value) {
            switch (this.dataType) {
                case FIELD_DATA_TYPES.DATE:
                case FIELD_DATA_TYPES.DATETIME:
                    if (isValidDate(this._value)) {
                        return this.formatDateValue(this.dataType);
                    }
                    break;
                case FIELD_DATA_TYPES.TIME:
                    return this.formatDateValue(this.dataType);
                case FIELD_DATA_TYPES.BOOLEAN:
                    return this.formatBoolean();
                case FIELD_DATA_TYPES.MULTIPICKLIST:
                case FIELD_DATA_TYPES.PICKLIST:
                    return this.formatPicklist();
                case FIELD_DATA_TYPES.REFERENCE:
                    return this.formatReference();
                default:
                    return this._value;
            }
        } else if (this._value) {
            return this._value;
        }

        return null;
    }

    get value () {
        return this._value;
    }
    set value (value) {
        if (value !== this._value) {
            this._value = value;
            this._sourceFieldAPIName = null;
            this.literalParameterAPIName = null;
            this.isDirty = true;
        }
    }

    get isFieldMappingType () {
        return this.mappingType === FIELD_MAPPING_TYPE;
    }

    get isValueMappingType () {
        return this.mappingType === VALUE_MAPPING_TYPE;
    }

    get isFunctionMappingType () {
        return this.mappingType === FUNCTION_MAPPING_TYPE;
    }

    get isLiteralFunctionMappingType () {
        return (this.mappingType === FUNCTION_MAPPING_TYPE &&
               (this._value === FUNCTION_LITERALS.USER ||
                this._value === FUNCTION_LITERALS.CURRENTRECORD ||
                this._value === FUNCTION_LITERALS.CURRENTRECORDHEADER));
    }

    get isCurrentRecordHeader () {
        return (this.mappingType === FUNCTION_MAPPING_TYPE &&
            this._value === FUNCTION_LITERALS.CURRENTRECORDHEADER);

    }

    get mappingTypeOptions () {
        if (!this._mappingTypeOptions || this._mappingTypeOptions.length === 0) {
            if (this.targetField) {
                this._mappingTypeOptions = getMappingTypeOptions(
                    this.parentMappingType,
                    this.targetField
                );
            }
        }

        return this._mappingTypeOptions;
    }

    get computedMappingEditorClass () {
        const cssClasses = ['slds-align-top'];

        if (
            (this.isFieldMappingType && this.compatibleFieldOptionsEmpty)
            || (this.isValueMappingType && this.dataType === FIELD_DATA_TYPES.DATETIME)
        ) {
            // Added logic to check for DateTime data types during value mapping because 
            // the datetime picker component does not stretch to fill the mapping row column.
            cssClasses.push('slds-col', 'slds-grow-none');
        } else {
            cssClasses.push('slds-size_12-of-12', 'slds-medium-size_3-of-12');
        }

        return cssClasses.join(' ');
    }

    get compatibleFieldOptionsEmpty () {
        return (this.compatibleFieldOptions.length === 0);
    }

    get compatibleFieldOptions () {
        if (!this._compatibleFieldOptions || this._compatibleFieldOptions.length === 0) {
            const availableFields = getCompatibleFieldsForFieldMapping(
                this.sourceFields,
                this.targetField,
                this.sourceObjectAPIName
            );

            if (availableFields) {
                this._compatibleFieldOptions = availableFields.map(field => {
                    return {
                        label: field.label,
                        value: field.apiName,
                        secondary: field.apiName,
                        iconName: DATA_TYPE_ICONS[field.dataType]
                    }
                });
            }
        }

        return this._compatibleFieldOptions;
    }

    get compatibleLiteralFieldOptionsEmpty () {
        return (this.compatibleLiteralFieldOptions.length === 0);
    }

    get compatibleLiteralFieldOptions () {
        let availableFields;
        if (this._value === FUNCTION_LITERALS.USER) {
            availableFields = getCompatibleFieldsForFieldMapping(
                this.userFields,
                this.targetField,
                this.sourceObjectAPIName
            );
        }
        if (availableFields) {
            this._compatibleLiteralFieldOptions = availableFields.map(field => {
                return {
                    label: field.label,
                    value: field.apiName,
                    secondary: field.apiName,
                    iconName: DATA_TYPE_ICONS[field.dataType]
                }
            });
        }
        return this._compatibleLiteralFieldOptions;

    }

    get functionOptions () {

        if (!this._functionOptions || this._functionOptions.length === 0) {
            if (this.targetField) {
                this._functionOptions = getFunctionMappingOptions(
                    this.targetField.dataType,
                    this.userOptionLabel
                );
            }
        }

        return this._functionOptions;
    }

    get warningMessage () {
        return this._warningMessage;
    }

    set warningMessage (value) {
        this._warningMessage = value;
    }

    formatPicklist () {
        if (this.targetField
            && this.targetField.picklistValues
            && this.targetField.picklistValues.length > 0
            && this._value
            && this._mappingType !== 'Function') {
            const valueAsArray = this._value.split(';');
            const labelsArray = [];

            valueAsArray.forEach(val => {
                const picklistItem
                = this.targetField.picklistValues.find(item => item.value === val);

                if (picklistItem) {
                    labelsArray.push(picklistItem.label);
                }
            });

            if (labelsArray.length === 0) {
                this.hasWarning = true;
                this.warningMessage = i18n.invalidValue;
            }

            return labelsArray.join(', ');
        }

        return null;
    }

    formatBoolean () {
        if (!this._value) return null;

        let boolValue = false;

        if (typeof this._value === 'boolean') {
            boolValue = this._value;
        } else if (typeof this._value === 'string') {
            boolValue = (this._value.toLowerCase() === 'true');
        }

        return (boolValue) ? i18n.trueLabel : i18n.falseLabel;
    }

    formatDateValue (dataType) {
        const timeZone = dataType === FIELD_DATA_TYPES.DATETIME ? TIMEZONE_GMT : undefined;

        return formatDateValue(this._value, this.dataType, timeZone);
    }

    formatReference () {
        let developerName = '';
        if (this.recordTypeInfos && this.targetFieldAPIName === 'RecordTypeId' &&
            this.mappingType === 'Value') {
            let selectedRecordType;
            if (isSalesforceId(this._value)) {
                selectedRecordType = this.recordTypeInfos.find(recordType => {
                    return recordType.recordTypeId === this._value;
                })
                developerName = selectedRecordType.name;
            } else {
                selectedRecordType = this.recordTypeInfos.find(recordType => {
                    return recordType.name === this._value; })
                developerName = this._value;
            }
            if (!selectedRecordType.isActive) {
                this.hasWarning = true;
                this.warningMessage = i18n.invalidValue;
            }
        }
        return developerName;
    }

    getRecordTypeId (value) {
        let recordTypeId = '';
            if (this.recordTypeInfos) {
                const selectedRecordType = this.recordTypeInfos.find(recordType => {
                    return recordType.developerName === value || recordType.name === value;
                })
                recordTypeId = selectedRecordType.recordTypeId;
            }
        return recordTypeId;
    }

    getLabelFromFieldList (apiName) {
        let label = '';

        if (this.sourceFields && this.sourceFields.length > 0) {
            const definition = this.sourceFields.find(field => field.apiName === apiName);

            if (definition) {
                label = definition.label;
            }
        }

        return label;
    }

    isTargetFieldNameMatch (valueToMatch) {
        if (valueToMatch && valueToMatch.length > 0) {
            const loweredValueToMatch = valueToMatch.trim().toLowerCase();

            return (this.targetFieldAPIName.toLowerCase().indexOf(loweredValueToMatch) !== -1
            || this.targetFieldLabel.toLowerCase().indexOf(loweredValueToMatch) !== -1);
        }

        return false;
    }

    reset () {
        this.mappingType = null;
        this.isMapped = false;
        this.sourceFieldAPIName = null;
        this.value = null;
        this.literalParameterAPIName = null;
        this.referenceFieldLabel = null;
    }
}