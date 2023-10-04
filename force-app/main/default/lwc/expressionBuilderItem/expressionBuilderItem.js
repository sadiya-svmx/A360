import { LightningElement, api, track } from 'lwc';
import {
    DATA_TYPE_ICONS,
    OPERATOR_TYPES,
    FIELD_DATA_TYPES,
    formatDateValue,
    getLookupReferenceToObject,
    getLookupReferenceNameFields,
    UNSUPPORTED_UI_API_OBJECTS,
    parseErrorMessage,
    FUNCTION_LITERALS,
    getFunctionExpressionOptions,
    getLookupFunctionExpressionOptions,
    SEARCH_TEXT_OPERATOR_TYPES,
    isEmptyString
} from 'c/utils';

import {
    getFieldDefinitionsForEntities
} from 'c/metadataService';

import labelCondition from '@salesforce/label/c.Label_Condition';
import labelEditCondition from '@salesforce/label/c.Label_Edit_Condition';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelDeleteCondition from '@salesforce/label/c.Label_Delete_Condition';
import labelOperator from '@salesforce/label/c.Label_Operator';
import labelOperandType from '@salesforce/label/c.Label_Operand_Type';
import labelTrue from '@salesforce/label/c.Label_True';
import labelFalse from '@salesforce/label/c.Label_False';
import labelLoading from '@salesforce/label/c.Label_Loading';
import messageDataSourceSelectionEnable from
    '@salesforce/label/c.Message_DataSourceSelectionEnable';
import labelValue from '@salesforce/label/c.Picklist_Value';
import labelFunction from '@salesforce/label/c.Picklist_Function';
import errorNotValid from '@salesforce/label/c.Error_NotValid';
import messageInvalidReference from '@salesforce/label/c.Message_InvalidTargetReference';
import errorOperatorValidation from '@salesforce/label/c.Error_OperatorValidation';


const i18n = {
    trueLabel: labelTrue,
    falseLabel: labelFalse,
    editCondition: labelEditCondition,
    condition: labelCondition,
    deleteCondition: labelDeleteCondition,
    select: labelSelect,
    operator: labelOperator,
    operandType: labelOperandType,
    loading: labelLoading,
    dataSourceSelectionEnable: messageDataSourceSelectionEnable,
    invalidReference: messageInvalidReference,
    notValid: errorNotValid,
    operatorValidation: errorOperatorValidation,
};

const NUMBER_TYPES = [
    FIELD_DATA_TYPES.LONG,
    FIELD_DATA_TYPES.INTEGER,
    FIELD_DATA_TYPES.PERCENT,
    FIELD_DATA_TYPES.CURRENCY,
    FIELD_DATA_TYPES.DOUBLE,
];

export default class ExpressionBuilderItem extends LightningElement {
    @api userLabel;
    @api editMode;
    @api editModeType;
    @api index;
    @api deleteDisabled;
    @api objectApiName;
    @api objectLabel = '';
    @api headerRecordObject = '';
    @api headerRecordObjectLabel;
    @api isLookupCriteria = false;
    entityRecordTypeInfos;
    showRelatedPicklistDialog = false;
    showTooltip = false;
    showLiteralRelatedPicklistDialog = false;
    showLiteralTooltip = false;
    rowEditMode = false;
    @api showAsTitleTooltip;

    @track fieldDefinition;
    @track _detail;
    @track _headerRecordObject;
    @track referenceFieldLabel = '';
    @track literalFieldLabel = '';
    @track entityFieldLabels= {};
    @track entityFieldDefinitions= {};
    @track recordHeaderLiteralTooltip;
    @track _objectApiField;
    @track _recordTypeObjectDetails;
    @track referenceFieldTitle = '';

    @api
    get objectApiField () {
        return this._objectApiField;
    }

    set objectApiField (value) {
        this._objectApiField = value;
        if (this._objectApiField) {
            this.populateItem();
        }
    }

    @api
    get recordTypeObjectDetails () {
        return this._recordTypeObjectDetails;
    }

    set recordTypeObjectDetails (value) {
        this._recordTypeObjectDetails = value;
    }

    @api
    get detail () {
        this.formattedLabel();
        return this._detail;
    }

    set detail (value) {
        this._detail = value;
        this.fieldDefinition = this.detail.fieldDefinition
            ? this.detail.fieldDefinition
            : undefined;
    }

    @api
    checkValidity () {
        const allValid = [...this.template.querySelectorAll('.dataField')].reduce(
            (validSoFar, inputField) => {
                if (inputField.reportValidity) {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }
                return validSoFar;
            },
            true
        );
        return allValid;
    }

    @api
    reportValidity () {
        const valid = this.checkValidity();
        return valid;
    }

    connectedCallback () {
        if (this.detail.fieldLabel && !this.isUserLiteral && !this.isRecordHeaderLiteral) {
            this.referenceFieldLabel = this.detail.fieldLabel;
        }

    }
    populateItem () {
        const selectedObject = (this.detail.sourceObjectName ?
            this.detail.sourceObjectName : this.objectApiName);
        const objectAPINames = new Set();
        let expressionObjectAPINames = new Set();
        let literalObjectAPINames = new Set();
        if (this.detail.relatedObjectDetails &&
                this.detail.relatedObjectDetails.includes('.')) {
            expressionObjectAPINames = new Set(this.detail.relatedObjectDetails.split('.'));
        } else if (this.detail.relatedObjectDetails) {
            expressionObjectAPINames.add(this.detail.relatedObjectDetails);
        }
        if (this.detail.literalRelatedObjectDetails &&
                this.detail.literalRelatedObjectDetails.includes('.')) {
            literalObjectAPINames = new Set(this.detail.literalRelatedObjectDetails.split('.'));
        } else if (this.detail.literalRelatedObjectDetails) {
            literalObjectAPINames.add(this.detail.literalRelatedObjectDetails);
        }
        expressionObjectAPINames.forEach(elem => objectAPINames.add(elem));
        literalObjectAPINames.forEach(elem => objectAPINames.add(elem));
        objectAPINames.add(this.objectApiName);
        if (this.headerRecordObject) {
            objectAPINames.add(this.headerRecordObject);
        }
        objectAPINames.add('User');
        if (objectAPINames && Array.from(objectAPINames).length > 0) {
            const filteredArray = ( this._objectApiField &&
            Object.keys(this._objectApiField) && Object.keys(this._objectApiField).length !== 0) ?
                this._objectApiField.filter(item => objectAPINames.has(item.apiName)) : [];

            if (filteredArray && filteredArray.length > 0) {
                Array.from(filteredArray).forEach( item => {
                    const fieldDetails = {};
                    const fieldLabels = {};
                    item.fieldDefinitions.forEach ( entity => {
                        fieldLabels[entity.apiName] = entity.label;
                        fieldDetails[entity.apiName] = entity;
                    });
                    this.entityFieldLabels[item.apiName] = fieldLabels;
                    this.entityFieldDefinitions[item.apiName] = fieldDetails;
                });
                if (this.detail.fieldAPIName) {
                    this.referenceFieldLabel =
                        this.getReferenceFieldLabel(this.detail.relatedObjectDetails,
                            this.detail.fieldAPIName, selectedObject);
                }
                if (this.detail.literalParameterAPIName && this.isUserLiteral) {
                    this.literalFieldLabel =
                        this.getReferenceFieldLabel(this.detail.literalRelatedObjectDetails,
                            this.detail.literalParameterAPIName, 'User');
                }
                if (this.detail.literalParameterAPIName && this.isRecordHeaderLiteral) {
                    this.literalFieldLabel =
                        this.getReferenceFieldLabel(this.detail.literalRelatedObjectDetails,
                            this.detail.literalParameterAPIName, this.headerRecordObject);
                }
            }
        }
    }
    showLoading (loading) {
        this.dispatchEvent(new CustomEvent('showloading', {
            detail: {
                loading
            }
        }));
    }

    get computedLineItemClass () {
        if (this.editModeType && this.editModeType === 'read') {
            return '';
        }

        const lineItemClasses = [
            'slds-expression__row',
            'slds-p-bottom_small',
            'slds-border_bottom',
            'svmx-expression-edit_item'
        ];
        if (Number.isInteger(this.index)) {
            lineItemClasses.push(`svmx-expression-edit_item-${this.index}`);
        }

        return lineItemClasses.join(' ');
    }

    get computedContainerClass () {
        const cssClasses = [
            'slds-grid',
            'slds-grid_align-start',
            'slds-grid_vertical-align-start',
            'slds-gutters_xx-small'
        ];
        if (!this.editMode) {
            cssClasses.push('slds-p-left_medium');
        }
        return cssClasses.join(' ');
    }

    get i18n () {
        return i18n;
    }

    get isFunction () {
        return this.detail && this.detail.operandType === 'Function';
    }

    get isLiteral () {
        return this.detail && (this.detail.operandType === 'Function') &&
                (this.detail.operand === FUNCTION_LITERALS.USER ||
                this.detail.operand === FUNCTION_LITERALS.CURRENTRECORDHEADER);
    }

    get isUserLiteral () {
        return this.detail && (this.detail.operandType === 'Function') &&
        (this.detail.operand === FUNCTION_LITERALS.USER);
    }

    get isRecordHeaderLiteral () {
        return this.detail && (this.detail.operandType === 'Function') &&
        (this.detail.operand === FUNCTION_LITERALS.CURRENTRECORDHEADER);
    }

    get isNew () {
        return this.detail &&
            !this.detail.fieldAPIName &&
            !this.detail.operator &&
            !this.detail.operand
            ? true
            : false;
    }

    get isHeaderRecordSelected () {
        return this.headerRecordObject ? true : false;
    }

    get lookupConfig () {
        const isRecordType = (this.fieldDefinition || {}).apiName === "RecordTypeId";
        const objectApiName = getLookupReferenceToObject(this.fieldDefinition);
        let recordTypeObject = '';
        const selectedObject = (this.detail.sourceObjectName ?
            this.detail.sourceObjectName : this.objectApiName);
        if (isRecordType) {
            if (this.detail.relatedObjectDetails &&
                this.detail.relatedObjectDetails.includes('.')) {
                recordTypeObject = this.detail.relatedObjectDetails.split('.').pop();
            } else if (this.detail.relatedObjectDetails) {
                recordTypeObject = this.detail.relatedObjectDetails;
            } else {
                recordTypeObject = selectedObject;
            }
        }
        return this.fieldDefinition
                    && (this.fieldDefinition.referenceTo
                    || this.fieldDefinition.referenceNameFields)
            ? {
                filters: !isRecordType
                    ? ""
                    : "SObjectType = '" + recordTypeObject + "' AND isActive = true ",
                icon: `standard:${getLookupReferenceToObject(this.fieldDefinition)
                    .toLowerCase()}`,
                objectApiName: objectApiName,
                fieldApiName: this.fieldDefinition.apiName,
                placeholder: 'Search',
                referenceNameFields: getLookupReferenceNameFields(this.fieldDefinition),
                enableAdvancedSearch: !UNSUPPORTED_UI_API_OBJECTS.has(objectApiName) ,
                advancedSearchConfig: isRecordType ? {
                    contextObjectName: recordTypeObject,
                    contextReferenceNameFields: getLookupReferenceNameFields(this.fieldDefinition),
                    contextValue: recordTypeObject,
                    lookupMatchingField: "SobjectType",
                    fieldName: this.fieldDefinition.apiName
                } : undefined
            }
            : undefined;
    }

    get isValue () {
        return this.detail && this.detail.operandType === 'Value';
    }

    get isReadOnly () {
        return this.editModeType && this.editModeType === 'read';
    }

    get showView () {
        return (
            (this.editMode === false && this.isNew === false) ||
            this.editMode === true
        );
    }

    get isOperandExist () {
        if (!this.detail.operand) {
            this.rowEditMode = true;
        }
        return this.detail.operand;
    }

    get fieldOptions () {
        return this.detail
            ? this.detail.sourceFields.map(sourceField => ({
                label: sourceField.label,
                value: sourceField.apiName,
                secondary: sourceField.apiName,
                iconName: DATA_TYPE_ICONS[sourceField.dataType]
            }))
            : undefined;
    }

    get functionOptions () {
        let options = [];
        if (this.detail.operandType === 'Function') {
            if (this.isLookupCriteria) {
                options = getLookupFunctionExpressionOptions(this.detail._fieldType,
                    this.userLabel);
            } else {
                options = getFunctionExpressionOptions(this.detail._fieldType, this.userLabel);
            }
        }
        return options;
    }

    get operandTypeOptions () {
        const options = [];
        options.push({ label: labelValue, value: 'Value' });
        if (!(this.detail._fieldType === FIELD_DATA_TYPES.REFERENCE &&
                SEARCH_TEXT_OPERATOR_TYPES.has(this.detail.operator)) &&
                this.objectApiName !== 'SVMXA360__CONF_Layout__c') {
            options.push({ label: labelFunction, value: 'Function' });
        }
        return options;
    }

    get operandLabel () {
        let options = [];
        if (this.detail.operandType === 'Function') {
            if (this.isLookupCriteria) {
                options = getLookupFunctionExpressionOptions(
                    this.detail._fieldType,
                    this.userLabel
                ).find(option =>
                    option.value === this.detail.operand
                );
            } else {
                options = getFunctionExpressionOptions(
                    this.detail._fieldType,
                    this.userLabel ).find(option =>
                    option.value === this.detail.operand
                );
            }
        }
        return options ? options.label : undefined;
    }

    get canHaveOperand () {
        return (
            this.detail.operator !== OPERATOR_TYPES.IS_NULL &&
            this.detail.operator !== OPERATOR_TYPES.IS_NOT_NULL
        );
    }

    get conditionNumber () {
        return this.index ? this.index + 1 : 1;
    }

    get viewIsBoolean () {
        return FIELD_DATA_TYPES.BOOLEAN === this.detail._fieldType;
    }

    get viewIsText () {
        return !this.viewIsDate && !this.viewIsBoolean && !this.viewIsTime;
    }

    get viewIsDate () {
        return (
            FIELD_DATA_TYPES.DATETIME === this.detail._fieldType ||
            FIELD_DATA_TYPES.DATE === this.detail._fieldType
        );
    }

    get viewIsTime () {
        return FIELD_DATA_TYPES.TIME === this.detail._fieldType;
    }

    get isTypeNumber () {
        return NUMBER_TYPES.includes(this.detail._fieldType);
    }

    get formattedBoolean () {
        return this.detail.operand === 'true'
            ? i18n.trueLabel
            : i18n.falseLabel;
    }

    get formattedDateTime () {
        return formatDateValue(this.detail.operand, this.detail._fieldType);
    }

    formattedLabel () {
        if (this._detail.operand && this._detail.fieldAPIName.endsWith('RecordTypeId')
            && this._detail.operandType === 'Value') {
                let lastObjectAPIName = '';
                if (isEmptyString(this._detail.relatedObjectDetails)) {
                    lastObjectAPIName = this.objectApiName;
                } else if (this._detail.relatedObjectDetails &&
                        this._detail.relatedObjectDetails.includes('.')) {
                    const splittedString = this._detail.relatedObjectDetails.split('.');
                    lastObjectAPIName = splittedString[splittedString.length - 1];
                } else {
                    lastObjectAPIName = this._detail.relatedObjectDetails;
                }
            if (this._recordTypeObjectDetails &&
                    this._recordTypeObjectDetails.get(lastObjectAPIName)) {
                this._recordTypeObjectDetails.get(lastObjectAPIName).forEach(record => {
                    if ( record.developerName === this._detail.operand ) {
                        this._detail.operand = record.name;
                    }
                });
            }
        }
    }

    get isRecordTypeId () {
        return this.detail.fieldAPIName.endsWith('RecordTypeId') &&
            this.detail.operandType === 'Value' &&
            !SEARCH_TEXT_OPERATOR_TYPES.has(this.detail.operator);
    }

    get targetFieldDefinition () {
        let fieldDefinition;
        if (this.detail.fieldDefinition) {
            fieldDefinition = this.detail.fieldDefinition;
        }
        let labelObjectAPINames = [];
        let fieldAPINames= [];
        if (this.detail.relatedObjectDetails &&
                this.detail.relatedObjectDetails.includes('.')) {
            labelObjectAPINames =
                labelObjectAPINames.concat(this.detail.relatedObjectDetails.split('.'));
        } else if (this.detail.relatedObjectDetails) {
            labelObjectAPINames.push(this.detail.relatedObjectDetails);
        }

        if (this.detail.fieldAPIName && this.detail.fieldAPIName.includes('.')) {
            fieldAPINames = this.detail.fieldAPIName.split('.');
        } else if (this.detail.fieldAPIName) {
            fieldAPINames.push(this.detail.fieldAPIName);
        }
        let fieldDefinitions = {};

        if ( labelObjectAPINames && this.entityFieldDefinitions[
            labelObjectAPINames [ labelObjectAPINames.length - 1]]
        ) {
            fieldDefinitions = this.entityFieldDefinitions[
                labelObjectAPINames [ labelObjectAPINames.length - 1 ]
            ];
            fieldDefinition = fieldDefinitions[
                fieldAPINames[fieldAPINames.length - 1]
            ];
        }
        if (this.detail.sourceObjectName === 'User' && !this.detail.fieldAPIName.includes('.')) {
            fieldDefinitions = this.entityFieldDefinitions.User;
            fieldDefinition = fieldDefinitions[
                fieldAPINames[fieldAPINames.length - 1]
            ];
        }

        if ( fieldDefinition === undefined || fieldDefinition === {}) {
            const error = i18n.invalidReference + this.detail.fieldAPIName + i18n.notValid;
            this.dispatchEvent(new CustomEvent('erroronline',  {
                bubbles: true,
                composed: true,
                detail: {
                    error
                },
            }));
        }

        return fieldDefinition;
    }

    handleDeleteCondition () {
        this.dispatchEvent(
            new CustomEvent('deletecondition', {
                detail: {
                    index: this.index
                }
            })
        );
    }

    handleFieldChange () {
        this.showRelatedPicklistDialog = true;
    }

    handleLiteralFieldChange () {
        if (this.detail.operandType === 'Function' && (this.isUserLiteral
                || (this.isRecordHeaderLiteral && this.headerRecordObject))) {
            if ( this.targetFieldDefinition &&
                Object.keys(this.targetFieldDefinition).length !== 0
            ) {
                this.showLiteralRelatedPicklistDialog = true;
            }
        }
    }

    handleRelatedPicklistSelected (event) {
        const label = event.detail.label;
        this.referenceFieldLabel  = label.includes(':') ?
            label.substring(label.lastIndexOf(':') + 2) : label;
        this.dispatchEvent(
            new CustomEvent('fieldchange', {
                detail: {
                    value: event.detail.fieldDefinition,
                    index: this.index,
                    referenceFieldApiName: event.detail.valueSelected,
                    objectSelected: event.detail.objectSelected,
                    sourceObjectName: event.detail.sourceObjectName,
                    label: event.detail.label
                }
            })
        );
        this.showRelatedPicklistDialog = false;
    }

    handleCancelRelatedPicklist (event) {

        this.dispatchEvent(
            new CustomEvent('fieldchange', {
                detail: {
                    value: event.detail.fieldDefinition,
                    index: this.index,
                    referenceFieldApiName: event.detail.valueSelected,
                    objectSelected: event.detail.objectSelected,
                    label: event.detail.label
                }
            })
        );
        this.showRelatedPicklistDialog = false;

    }

    handleLiteralRelatedPicklistSelected (event) {
        const label = event.detail.label;
        this.literalFieldLabel  = label.includes(':') ?
            label.substring(label.lastIndexOf(':') + 2) : label;
        this.dispatchEvent(
            new CustomEvent('literalfieldchange', {
                detail: {
                    value: event.detail.fieldDefinition,
                    index: this.index,
                    referenceFieldApiName: event.detail.valueSelected,
                    objectSelected: event.detail.objectSelected,
                    label: event.detail.label
                }
            })
        );
        this.showLiteralRelatedPicklistDialog = false;
    }

    handleLiteralCancelRelatedPicklist (event) {

        this.dispatchEvent(
            new CustomEvent('literalfieldchange', {
                detail: {
                    value: event.detail.fieldDefinition,
                    index: this.index,
                    referenceFieldApiName: event.detail.valueSelected,
                    objectSelected: event.detail.objectSelected,
                    label: event.detail.label
                }
            })
        );
        this.showLiteralRelatedPicklistDialog = false;

    }

    handleMouseOver () {
        if (this.showAsTitleTooltip && this.referenceFieldLabel) {
            this.referenceFieldTitle = this.referenceFieldLabel;
        }
        else if (this.referenceFieldLabel) {
            this.showTooltip = true;
        }
    }

    handleMouseOut () {
        this.showTooltip = false;
    }

    handleLiteralMouseOver () {
        if (this.literalFieldLabel === null || this.literalFieldLabel === '') {
            if (this.editMode && !this.headerRecordObject && this.isRecordHeaderLiteral) {
                this.recordHeaderLiteralTooltip = i18n.dataSourceSelectionEnable;
                this.showLiteralTooltip = true;
            }
        }
        else if (this.literalFieldLabel) {
            if (this.editMode && this.isRecordHeaderLiteral) {
                this.recordHeaderLiteralTooltip = this.literalFieldLabel;
            }
            this.showLiteralTooltip = true;
        }
    }

    handleLiteralMouseOut () {
        this.showLiteralTooltip = false;
    }

    handleOperatorChange (event) {
        this.dispatchEvent(
            new CustomEvent('operatorchange', {
                detail: {
                    value: event.detail.value,
                    label: event.detail.label,
                    index: this.index
                }
            })
        );
    }

    handleOperandTypeChange (event) {
        this.dispatchEvent(
            new CustomEvent('operandtypechange', {
                detail: {
                    value: event.detail.value,
                    label: event.detail.label,
                    index: this.index
                }
            })
        );
    }

    handleValueChange (event) {
        this.literalFieldLabel = null;
        if (this.detail.operandType === 'Function' &&
            (event.detail.value === FUNCTION_LITERALS.USER ||
                event.detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER)) {
            this.dispatchEvent(
                new CustomEvent('operandchange', {
                    detail: {
                        value: event.detail.value,
                        label: event.detail.label,
                        index: this.index
                    }
                })
            );
        } else {
            if ( !this.isTypeNumber ) {
                // Debounce the operandChange event for users are typing for performance
                event.stopPropagation();
                window.clearTimeout(this.delayTimeout);
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.delayTimeout = setTimeout(() => {
                    this.dispatchEvent(
                        new CustomEvent('operandchange', {
                            detail: {
                                value: event.detail.value,
                                label: event.detail.label,
                                meta: event.detail.meta,
                                relationshipName: this.detail.fieldDefinition.relationshipName,
                                index: this.index
                            }
                        })
                    );
                }, 300);
            } else {
                this.dispatchEvent(
                    new CustomEvent('operandchange', {
                        detail: {
                            value: event.detail.value,
                            label: event.detail.label,
                            meta: event.detail.meta,
                            relationshipName: this.detail.fieldDefinition.relationshipName,
                            index: this.index
                        }
                    })
                );
            }
        }
    }

    handleRowEdit () {
        this.dispatchEvent(
            new CustomEvent('edittypechange', {
                detail: {
                }
            })
        );
        this.rowEditMode = true;
    }

    toggleEdit () {
        this.dispatchEvent(
            new CustomEvent('toggleedit', {
                detail: {
                    value: this.detail.expressionId
                }
            })
        );
    }

    async fetchObjectFields (objectNames) {
        let result = {};
        if (objectNames.size <= 0) {
            return result;
        }
        const objectApiNameList = [...objectNames];
        try {
            const resp = await getFieldDefinitionsForEntities(objectApiNameList);
            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            const error = parseErrorMessage(err);
            this.dispatchEvent(new CustomEvent('erroronline',  {
                bubbles: true,
                composed: true,
                detail: {
                    error
                },
            }));
        }
        return result;
    }

    getReferenceFieldLabel (relatedObjectDetails, fieldAPIName, objectApiName) {
        let labelObjectAPINames = [];
        let fieldAPINames = [];
        let referenceFieldLabel = '';
        labelObjectAPINames.push(objectApiName);
        if (relatedObjectDetails && relatedObjectDetails.includes('.')) {
            labelObjectAPINames = labelObjectAPINames.concat(relatedObjectDetails.split('.'));
        } else if (relatedObjectDetails) {
            labelObjectAPINames.push(relatedObjectDetails);
        }
        if (fieldAPIName && fieldAPIName.includes('.')) {
            fieldAPINames = fieldAPIName.split('.');
        } else if (fieldAPIName) {
            fieldAPINames.push(fieldAPIName);
        }
        for (let index = 0; index < fieldAPINames.length; index++) {
            let fieldDefinition = {};
            fieldDefinition = this.entityFieldLabels[labelObjectAPINames[index]];
            if ( fieldDefinition ) {
                if ( index !== fieldAPINames.length - 1) {
                    if (fieldAPINames[index].endsWith('__r')) {
                        fieldAPINames[index] = fieldAPINames[index].replace(/__r$/i, '__c');
                    }
                    // Resolve standard field relationship name to field name
                    if (!/__c$/i.test(fieldAPINames[index])) {
                        fieldAPINames[index] += 'Id';
                    }
                    referenceFieldLabel += fieldDefinition[fieldAPINames[index]] + ' >  ';
                }
                else {
                    referenceFieldLabel += fieldDefinition[fieldAPINames[index]];
                }
            }
        }
        if (referenceFieldLabel.includes('undefined') || !referenceFieldLabel) {
            referenceFieldLabel = fieldAPIName;
        }
        return referenceFieldLabel;

    }
}