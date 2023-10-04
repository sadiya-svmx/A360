import {
    normalizeDeveloperName,
    validateExpression,
    isEmptyString,
    isUndefinedOrNull,
    OPERATOR_TYPES,
} from 'c/utils';
import { ExpressionDetailViewModel } from './expressionDetailViewModel';

import messageInvalidException from '@salesforce/label/c.Message_InvalidExpressionError';
import { api } from 'lwc';

const TYPE = 'Standard Expression';
const EXPRESSION_TYPE = 'COMM-EXPRESSION';

export class ExpressionViewModel {
    id;
    objectAPIName = '';
    objectLabel = '';
    headerRecordObject = '';
    headerRecordObjectLabel = '';
    type = '';
    optional;
    expressionType = '';
    expressionDetails = [];
    entityFieldDefinitions = {};
    objectAPINames = new Set();

    _isDirty = false;
    _name = '';
    _developerName = '';
    _description = '';
    _advancedExpression = '';
    _selectedTagsValue = '';
    _entityDefinition;
    _fieldDefinitions = [];
    _expressionDetailList = [];
    _selectedTagsArray = [];

    constructor (expressionRecord, entityDefinitionWithFields, isOptional) {
        if (entityDefinitionWithFields) {
            this.setObjectApiAndLabel(entityDefinitionWithFields);
            this._fieldDefinitions =
                entityDefinitionWithFields.fieldDefinitions;
            this._entityDefinition = entityDefinitionWithFields;
        }

        this.optional = isOptional;

        if (expressionRecord && entityDefinitionWithFields) {
            this.id = expressionRecord.id;
            this._name = expressionRecord.name;
            this.objectAPIName = expressionRecord.objectAPIName
                ? expressionRecord.objectAPIName
                : entityDefinitionWithFields.apiName;
            this.headerRecordObject = expressionRecord.headerRecordObject;
            this.headerRecordObjectLabel = expressionRecord.headerRecordObjectLabel;
            this._description = expressionRecord.description;
            this._advancedExpression = expressionRecord.advancedExpression;
            this._selectedTagsValue = expressionRecord.selectedTagsValue;
            if (this._selectedTagsValue != null && this._selectedTagsValue !== "") {
                this._selectedTagsArray = this._selectedTagsValue.split(';');
            }
            this.type = expressionRecord.Type || TYPE;
            this.expressionType =
                expressionRecord.expressionType || EXPRESSION_TYPE;
            this._developerName = expressionRecord.developerName;

            if (expressionRecord.expressionDetailList
                && expressionRecord.expressionDetailList.length > 0) {
                expressionRecord.expressionDetailList.forEach ( detail => {
                    this.objectAPINames = detail.relatedObjectDetails ?
                        new Set(detail.relatedObjectDetails.split('.')) : new Set();
                    this.objectAPINames = detail.literalRelatedObjectDetails ?
                        new Set(detail.literalRelatedObjectDetails.split('.')) : new Set();
                });
            }
            this.objectAPINames.add(this.objectAPIName);
            if (this.objectAPINames && Array.from(this.objectAPINames).length > 0) {
                if (expressionRecord.expressionDetailList
                        && expressionRecord.expressionDetailList.length > 0) {
                    this._expressionDetailList =
                            expressionRecord.expressionDetailList;
                    this.expressionDetails = expressionRecord.expressionDetailList.map(
                        expressionDetail => {
                            return new ExpressionDetailViewModel(
                                expressionDetail,
                                entityDefinitionWithFields.fieldDefinitions
                            );
                        }
                    );
                } else if (expressionRecord.expressionDetails) {
                    this.expressionDetails = expressionRecord.expressionDetails;
                } else {
                    this.expressionDetails = [
                        new ExpressionDetailViewModel(
                            null,
                            entityDefinitionWithFields.fieldDefinitions,
                            1
                        )
                    ];
                }
            }
            else {
                if (expressionRecord.expressionDetailList
                    && expressionRecord.expressionDetailList.length > 0) {
                    this._expressionDetailList =
                        expressionRecord.expressionDetailList;
                    this.expressionDetails = expressionRecord.expressionDetailList.map(
                        expressionDetail => {
                            return new ExpressionDetailViewModel(
                                expressionDetail,
                                entityDefinitionWithFields.fieldDefinitions
                            );
                        }
                    );
                } else if (expressionRecord.expressionDetails) {
                    this.expressionDetails = expressionRecord.expressionDetails;
                } else {
                    this.expressionDetails = [
                        new ExpressionDetailViewModel(
                            null,
                            entityDefinitionWithFields.fieldDefinitions,
                            1
                        )
                    ];
                }
            }
        } else {
            this.type = TYPE;
            this.expressionType = EXPRESSION_TYPE;
            if (entityDefinitionWithFields && entityDefinitionWithFields.fieldDefinitions) {
                this.expressionDetails = [
                    new ExpressionDetailViewModel(
                        null,
                        entityDefinitionWithFields.fieldDefinitions,
                        1
                    )
                ];
            }
        }
    }

    get advancedExpression () {
        return this._advancedExpression;
    }
    set advancedExpression (value) {
        if (value !== this._advancedExpression) {
            this._advancedExpression = value;
            this._isDirty = true;
        }
    }
    get selectedTagsValue () {
        return this._selectedTagsValue;
    }
    set selectedTagsValue (value) {
        if (value !== this._selectedTagsValue) {
            this._selectedTagsValue = value;
            this._isDirty = true;
        }
    }

    get entityDefinition () {
        return this._entityDefinition;
    }
    set entityDefinition (value) {
        if (value) {
            this.setObjectApiAndLabel(value);
        }
    }

    get fieldDefinitions () {
        return this._fieldDefinitions;
    }

    set fieldDefinitions (value) {
        if (value) {
            this._fieldDefinitions = value;
            this._isDirty = true;
        }
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

    get isDirty () {

        return this._isDirty;
    }

    set isDirty (value) {
        this._isDirty = value;
    }

    markAsClone (namePrefix) {
        this._name = namePrefix + ' ' + this._name;
        this.id = null;
        this.expressionDetails.forEach(detail => { detail.id = null; });
        this._developerName = normalizeDeveloperName(this._name);
    }

    get defaultAdvancedExpression () {
        let defaultAdvancedExpression;
        if (this.expressionDetails) {
            for (let i = 0; i < this.expressionDetails.length; i++) {
                if (i === 0) {
                    defaultAdvancedExpression = 1;
                }
                if (i > 0) {
                    const sequence = i + 1;
                    defaultAdvancedExpression = defaultAdvancedExpression += ' AND ' + sequence;
                }
            }
        }
        return defaultAdvancedExpression !== 1 ? defaultAdvancedExpression : null;
    }

    getRecordData () {
        let recordDetails = [];
        if (this.optional && this.expressionDetails && this.expressionDetails.length === 1
            && isUndefinedOrNull(this.expressionDetails[0].operand)
            && this.expressionDetails[0].operator !== OPERATOR_TYPES.IS_NOT_NULL
            && this.expressionDetails[0].operator !== OPERATOR_TYPES.IS_NULL) {
            return null;
        }
        if (this.expressionDetails) {
            recordDetails = this.expressionDetails.map(detail => {
                return {
                    sourceObjectName: detail.sourceObjectName,
                    id: detail.id,
                    expressionId: detail.expressionId,
                    fieldAPIName: detail.fieldAPIName,
                    operator: detail.operator,
                    operand: detail.operand,
                    sequence: detail.sequence,
                    operandType: detail.operandType,
                    fieldType: detail._fieldType,
                    relationshipName: detail.relationshipName,
                    relationshipFieldAPIName: detail.relationshipFieldAPIName,
                    relatedObjectDetails: detail.relatedObjectDetails,
                    referenceFieldLabel: detail.referenceFieldLabel,
                    literalParameterAPIName: detail.literalParameterAPIName,
                    literalRelatedObjectDetails: detail.literalRelatedObjectDetails,
                    literalFieldLabel: detail.literalFieldLabel,
                };
            });
        }

        const record = {
            id: this.id || null,
            name: this.name,
            objectAPIName: this.objectAPIName,
            headerRecordObject: this.headerRecordObject || null,
            description: this.description,
            advancedExpression: this.advancedExpression
                ? this.advancedExpression
                : this.defaultAdvancedExpression,
            selectedTagsValue: this.selectedTagsValue,
            type: this.type,
            expressionType: this.expressionType,
            developerName: this.developerName,
            expressionDetailList: recordDetails
        };

        return record;
    }

    setObjectApiAndLabel (entityDefinitionWithFields) {
        const objLabel = entityDefinitionWithFields
            ? entityDefinitionWithFields.label
            : '';
        const objAPIName = entityDefinitionWithFields
            ? entityDefinitionWithFields.apiName
            : '';

        this.objectLabel = objLabel;
        this.objectAPIName = objAPIName;
    }

    validateAdvancedExpression () {
        let result;
        if (!validateExpression(this.expressionDetails.length, this._advancedExpression)) {
            result = {
                error: true,
                message: messageInvalidException
            };
        } else {
            result = {
                error: false
            };
        }
        return result;
    }

    @api
    isExpressionValidityRequired () {
        if (this.expressionDetails) {
            if (this.expressionDetails.length > 1) {
                return true;
            } else if (this.expressionDetails.length === 1) {
                if (!isEmptyString(this.expressionDetails[0].fieldAPIName)) {
                    return true;
                }
            }
        } else if (!isEmptyString(this.advancedExpression)) {
            return true;
        }
        return false;
    }

    clone () {
        const newExpressionRecord = {
            id: this.id,
            name: this._name,
            objectAPIName: this.objectAPIName,
            headerRecordObject: this.headerRecordObject,
            description: this._description,
            advancedExpression: this._advancedExpression,
            Type: this.type,
            expressionType: this.expressionType,
            developerName: this._developerName,
            expressionDetails: this.expressionDetails
        };
        return new ExpressionViewModel(
            newExpressionRecord,
            this.entityDefinition,
            this.optional
        );
    }
}