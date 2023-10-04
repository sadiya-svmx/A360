import {
    FIELD_DATA_TYPES,
    OPERATOR_OPTIONS_BY_TYPE,
    OPERATOR_OPTIONS_BY_FIELD_TYPE,
    UNSUPPORTED_FIELD_TYPES,
    getFunctionExpressionOptions,
    isEmptyString,
    parseErrorMessage,
    TEXTOPERATORS,
    SEARCH_TEXT_OPERATOR_TYPES,
} from 'c/utils';
import { guid } from 'c/utils';
import labelValue from '@salesforce/label/c.Picklist_Value';
import labelFunction from '@salesforce/label/c.Picklist_Function';
import {
    getFieldDefinitionsForEntity
} from 'c/metadataService';

export class ExpressionDetailViewModel {
    id;
    guid;
    expressionId;
    sourceObjectName;
    Name;
    fieldAPIName;
    literalParameterAPIName;
    fieldLabel;
    operator;
    operatorLabel;
    operand;
    operandLabel;
    sequence;
    relationshipName;
    relationshipFieldAPIName;
    relatedObjectDetails;
    literalRelatedObjectDetails;
    operandType = 'Value';
    sourceFields;
    fieldDefinition;
    operatorOptions = [];
    operandTypeOptions = [];
    functionOptions = [];
    operandTypeDisabled;

    _fieldType;
    _isDirty;
    _functionOptions;

    constructor (expressionDetailRecord, sourceFields, sequence) {
        this.guid = guid();
        if (sourceFields) {
            this.sourceFields = sourceFields.filter(field => {
                let validField = field.filterable;

                // Filter out Reference fields that do not have a referenceTo
                if (field.dataType === FIELD_DATA_TYPES.REFERENCE
                    && field.referenceTo.length === 0
                    && field.apiName !== 'RecordTypeId') {
                    validField = false;
                }

                // Apex class does not currently support Id fields. 
                if (field.apiName.toLowerCase() === 'id') {
                    validField = false;
                }

                // Filter out unsupported field types in Value Input
                if (UNSUPPORTED_FIELD_TYPES.has(field.dataType)) {
                    validField = false;
                }
                return validField;
            });
        }

        if (expressionDetailRecord) {
            this.id = expressionDetailRecord.id;
            this.expressionId = expressionDetailRecord.expressionId;
            this.Name = expressionDetailRecord.name;
            this.fieldAPIName = expressionDetailRecord.fieldAPIName;
            this.literalParameterAPIName = expressionDetailRecord.literalParameterAPIName;
            this.relationshipName = expressionDetailRecord.relationshipName;
            this.sourceObjectName = expressionDetailRecord.sourceObjectName;
            this.relationshipFieldAPIName = expressionDetailRecord.relationshipFieldAPIName;
            this.relatedObjectDetails = expressionDetailRecord.relatedObjectDetails;
            this.literalRelatedObjectDetails = expressionDetailRecord.literalRelatedObjectDetails;
            let sourceFieldDetail;
            if (this.fieldAPIName && this.fieldAPIName !== '') {
                sourceFieldDetail = sourceFields.find(field =>
                    field.apiName === expressionDetailRecord.fieldAPIName
                );
                if (sourceFieldDetail) {
                    this.fieldLabel = sourceFieldDetail.label;
                } else {
                    this.fieldLabel = '';
                }
                if (sourceFieldDetail && sourceFieldDetail.dataType === FIELD_DATA_TYPES.TIME) {
                    this.fieldAPIName = '';
                    this.fieldLabel = '';
                }
            }
            this.operator = expressionDetailRecord.operator;
            this.operatorLabel = this.operator
                ? OPERATOR_OPTIONS_BY_TYPE[this.operator].label
                : undefined;
            if (sourceFieldDetail && (sourceFieldDetail.dataType === FIELD_DATA_TYPES.STRING ||
                sourceFieldDetail.dataType === FIELD_DATA_TYPES.TEXTAREA ||
                sourceFieldDetail.dataType === FIELD_DATA_TYPES.URL) &&
                !TEXTOPERATORS.has(this.operator)) {
                    this.operator = '';
                    this.operatorLabel = '';
            }
            this.operand = expressionDetailRecord.operand;
            this.operandType = expressionDetailRecord.operandType
                ? expressionDetailRecord.operandType
                : 'Value';
            this.fieldType = expressionDetailRecord.fieldType;
            if (sourceFieldDetail && (sourceFieldDetail.dataType === FIELD_DATA_TYPES.PICKLIST) &&
            this.operandType === 'Value' && !SEARCH_TEXT_OPERATOR_TYPES.has(this.operator)) {
                    const validPicklistValue = sourceFieldDetail.picklistValues.find(entry =>
                        entry.value === this.operand
                    );
                    if (!validPicklistValue) {
                        this.operand = '';
                    }
            }

            if (this.fieldAPIName && this.fieldAPIName !== '') {
                if (this.fieldAPIName.includes('.')) {
                    const fieldList = this.fieldAPIName.includes('.') ?
                        this.fieldAPIName.split('.') : new Array (this.fieldAPIName);
                    const relatedObjects = expressionDetailRecord.relatedObjectDetails.split('.');
                    const lastReferenceObject = relatedObjects[relatedObjects.length -1];
                    this.getObjectFields(lastReferenceObject).then(
                        entityWithFields => {
                            this.populateFieldDefinition(entityWithFields.fieldDefinitions,
                                fieldList[fieldList.length - 1]);
                        }
                    );
                } else {
                    if (this.sourceObjectName) {
                        this.getObjectFields(this.sourceObjectName).then(
                            entityWithFields => {
                                this.populateFieldDefinition(entityWithFields.fieldDefinitions,
                                    this.fieldAPIName);
                            }
                        );
                    }
                    else {
                        this.fieldDefinition = this.sourceFields.find(
                            sourceField => sourceField.apiName === this.fieldAPIName
                        );
                    }
                }
            }

            if (this.operandType === 'Function') {
                const functionOptions = getFunctionExpressionOptions(this.fieldType).find(option =>
                    option.value === this.operand
                );
                this.operandLabel = functionOptions ? functionOptions.label : undefined;
            }
            this.sequence = expressionDetailRecord.sequence;
        } else {
            this.fieldAPIName = '';
        }

        if (sequence) {
            this.sequence = sequence;
        }
    }

    get fieldType () {
        return this._fieldType;
    }

    set fieldType (value) {
        if (value !== this._fieldType) {
            if (this._fieldType !== undefined) {
                this._isDirty = true;
            }
            this._fieldType = value;
        }
        this.setOperatorOptions();
        this.setOperandTypeOptions();
        this.setFunctionOptions();
    }

    get isDirty () {
        return this._isDirty;
    }

    setOperatorOptions () {
        this.operatorOptions = OPERATOR_OPTIONS_BY_FIELD_TYPE[this._fieldType];
    }

    setOperandTypeOptions () {
        const options = [];
        options.push({ label: labelValue, value: 'Value' });
        options.push({ label: labelFunction, value: 'Function' });
        this.operandTypeOptions = options;
    }

    setFunctionOptions () {
        this.functionOptions = getFunctionExpressionOptions(this._fieldType);
    }

    clearState () {
        this.operandType = 'Value';
        this.operator = undefined;
        this.operand = undefined;
    }

    clone () {
        const newExpressionDetailRecord = {
            id: this.id,
            expressionId: this.expressionId,
            sourceObjectName: this.sourceObjectName,
            Name: this.Name,
            fieldAPIName: this.fieldAPIName,
            operator: this.operator,
            operand: this.operand,
            operandType: this.operandType,
            fieldType: this.fieldType,
            relatedObjectDetails: this.relatedObjectDetails,
            literalParameterAPIName: this.literalParameterAPIName,
            literalRelatedObjectDetails: this.literalRelatedObjectDetails
        };

        return new ExpressionDetailViewModel(
            newExpressionDetailRecord,
            this.sourceFields
        );
    }

    async getObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

        return result;
    }
    populateFieldDefinition (sourceFields, fieldApiName) {
        this.fieldDefinition = sourceFields.find(
            sourceField => sourceField.apiName === fieldApiName
        );
    }
}