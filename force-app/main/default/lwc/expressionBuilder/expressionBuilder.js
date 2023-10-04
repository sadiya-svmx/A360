import { LightningElement, api, track, wire } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_OBJECT from '@salesforce/schema/User';

import { NavigationMixin } from 'lightning/navigation';
import { ExpressionViewModel, ExpressionDetailViewModel } from 'c/viewModels';
import {
    deepCopy,
    FUNCTION_LITERALS,
    FIELD_DATA_TYPES,
    SEARCH_TEXT_OPERATOR_TYPES,
    getLookupReferenceNameFields,
    isNotUndefinedOrNull,
    isEmptyString,
    parseErrorMessage,
    verifyApiResponse
} from 'c/utils';

import {
    getFieldDefinitionsForEntities
} from 'c/metadataService';
import getAllTags from '@salesforce/apex/ADM_PageLayoutLightningService.getAllTags';

import getObjectRecordTypeDetails
    from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getObjectRecordTypeDetails';

import labelAddCondition from '@salesforce/label/c.Label_Add_Condition';
import labelAdvancedExpression from '@salesforce/label/c.Label_Advanced_Expression';
import labelAdvancedExpressionEdit from '@salesforce/label/c.Label_Advanced_Expression_Edit';
import messageMaxFiveRulesVC from '@salesforce/label/c.Message_MaxFiveRulesVC';
import labelTags from '@salesforce/label/c.Label_Tags';

const i18n = {
    addCondition: labelAddCondition,
    advancedExpression: labelAdvancedExpression,
    advancedExpressionEdit: labelAdvancedExpressionEdit,
    maxFiveRulesInVC: messageMaxFiveRulesVC,
    tags: labelTags
};

export default class ExpressionBuilder extends NavigationMixin(
    LightningElement
) {
    @api optional = false;
    @api headerObjectLabel;
    @api headerRecordObject = '';
    @api isLookupCriteria = false;
    @api isVisibilityCriteria;
    @api isConfigurationFilter;
    @api showAsTitleTooltip;

    @track _editMode;
    @track _editModeType;
    @track _expressionData;
    @track _expressionDataUnwrapped;
    @track newExpressionDetail;
    @track disableAddConditionButton;
    @track objectApiNameList;
    @track objectApiNameRecorcTypeList;
    @track filteredTagOptions = '';
    @track tagOptions = [];

    fetchObjectField;
    objectApiField;
    recordTypeObjectDetails;
    actionName;
    _recordData;
    _entityDefinition;
    apiInProgress = false;
    _expressionDataForItem;

    get i18n () {
        return i18n;
    }

    get hasMoreThanOneExpressionDetail () {
        return (
            this._expressionDataForItem.expressionDetails &&
            this._expressionDataForItem.expressionDetails.length > 1 &&
            isNotUndefinedOrNull(this._expressionDataForItem._advancedExpression)
        );
    }

    get hasOneExpressionDetail () {
        return (
            !this.optional &&
            this._expressionDataForItem.expressionDetails &&
            this._expressionDataForItem.expressionDetails.length === 1
        );
    }

    get showAdvancedExpression () {
        return (
            this.optional
                ? this._expressionDataForItem.expressionDetails
                    && this._expressionDataForItem.expressionDetails.length > 0
                : true
        );
    }

    get showTags () {
        return this.isConfigurationFilter;
    }

    @api
    get editMode () {
        return this._editMode;
    }

    set editMode (value) {
        this._editMode = value;
    }

    @api
    get editModeType () {
        return this._editModeType;
    }

    set editModeType (value) {
        this._editModeType = value;
    }

    @api
    get expressionData () {
        return this._expressionData
            ? new ExpressionViewModel(
                this._expressionData.getRecordData(),
                this._entityDefinition,
                this.optional
            )
            : undefined;
    }

    set expressionData (value) {
        this._recordData = value;
        this._expressionData = undefined;
        this._expressionDataUnwrapped = undefined;
        if (value && this.entityDefinition) {
            this._expressionData = new ExpressionViewModel(
                value,
                this.entityDefinition
            );
            this._expressionDataUnwrapped = deepCopy(this._expressionData);
            this.getObjectApiNameFromItems();
            if (this.isVisibilityCriteria) {
                this.disableAddConditionButton = this._expressionData.expressionDetails.length >= 5;
            }
        }
    }

    @api
    checkValidity () {
        const needValidityCheck = this.optional
            ? this._expressionData.isExpressionValidityRequired()
            : true;

        if (needValidityCheck) {
            const allValid =
                [...this.template.querySelectorAll('.svmx-expression-builder_item')].reduce(
                    (validSoFar, expressionBuilderItem) => {
                        if (expressionBuilderItem.reportValidity) {
                            expressionBuilderItem.reportValidity();
                            return validSoFar && expressionBuilderItem.checkValidity();
                        }
                        return validSoFar;
                    },
                    true
                );
            const invalidAdvancedExpression = this.validateAdvancedExpression();
            return !(allValid && !invalidAdvancedExpression);
        }
        return false;
    }

    @api
    reportValidity () {
        const valid = this.checkValidity();
        return valid;
    }

    @api
    validateAdvancedExpression () {
        const validation = this._expressionData.validateAdvancedExpression();
        const advancedExpressionInput = this.template.querySelector(
            '.advancedExpressionInput'
        );
        if (advancedExpressionInput) {
            if (validation.error) {
                advancedExpressionInput.setCustomValidity(validation.message);
            } else {
                advancedExpressionInput.setCustomValidity('');
            }
            advancedExpressionInput.reportValidity();
        }
        return validation.error;
    }

    @api
    get entityDefinition () {
        return this._entityDefinition;
    }

    set entityDefinition (value) {
        this._entityDefinition = value;
        this._expressionData = undefined;
        this._expressionDataUnwrapped = undefined;
        if (value && this._recordData) {
            this._expressionData = new ExpressionViewModel(
                this._recordData,
                this.entityDefinition,
                this.optional
            );
            this._expressionDataUnwrapped = deepCopy(this._expressionData);
            this.getObjectApiNameFromItems();
        }
    }

    connectedCallback () {
        this.apiInProgress = true;
        this.filteredTagOptions = '';
        getAllTags()
            .then(result => {
                const deSerializedResult = JSON.parse(result);
                if (!verifyApiResponse(deSerializedResult)) {
                    this.error = deSerializedResult.message;
                    return;
                }
                if (deSerializedResult && deSerializedResult.data) {
                    deSerializedResult.data.forEach((element) => {
                        this.tagOptions.push({ label: element, value: element })
                    });
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    @wire(getObjectInfo, { objectApiName: USER_OBJECT })
    userInfo;

    get hasDetails () {
        return this._expressionDataForItem && this._expressionDataForItem.expressionDetails
            ? this._expressionDataForItem.expressionDetails.length > 0
            : false;
    }

    get userLabel () {
        return this.userInfo?.data?.label;
    }

    handleAddCondition () {
        this._expressionData.expressionDetails.push(
            new ExpressionDetailViewModel(
                null,
                this.entityDefinition.fieldDefinitions,
                this._expressionData.expressionDetails.length + 1
            )
        );
        if (this.isVisibilityCriteria) {
            this.disableAddConditionButton = this._expressionData.expressionDetails.length >= 5;
        }
        const mutable = deepCopy(this._expressionData);
        this._expressionDataForItem = mutable;
    }

    handleDeleteCondition (event) {
        this._expressionData.expressionDetails.splice(event.detail.index, 1);
        if (this._expressionData.expressionDetails.length === 0 &&
            !isEmptyString(this._expressionData.advancedExpression)) {
            this.updateExpressionData('');
        }

        for (
            let i = 0;
            i < this._expressionData.expressionDetails.length;
            i++
        ) {
            this._expressionData.expressionDetails[i].sequence = i + 1;
            if (this.isVisibilityCriteria) {
                this.disableAddConditionButton = this._expressionData.expressionDetails.length >= 5;
            }
        }

        const mutable = deepCopy(this._expressionData);
        this._expressionDataForItem = mutable;
        this.dispatchItemChangedEvent();
    }

    handleFieldChange (event) {
        const {
            value,
            index,
            objectSelected,
            referenceFieldApiName,
            label,
            sourceObjectName
        } = event.detail;
        const expressionDetail = this._expressionData.expressionDetails[index];
        if (value && expressionDetail.fieldAPIName !== referenceFieldApiName) {
            expressionDetail.fieldAPIName = referenceFieldApiName;
            expressionDetail.fieldLabel = label;
            expressionDetail.referenceFieldLabel = label.includes(':') ?
                label.substring(label.lastIndexOf(':') + 2) : label;
            expressionDetail.fieldType = value.dataType;
            expressionDetail.fieldDefinition = value;
            expressionDetail.operator = null;
            expressionDetail.operand = null;
            expressionDetail.operandType = null;
            expressionDetail.relatedObjectDetails = objectSelected;
            expressionDetail.sourceObjectName = sourceObjectName;
            expressionDetail.literalParameterAPIName = null;
            expressionDetail.literalFieldLabel = null;
            expressionDetail.literalRelatedObjectDetails = null;
            if (value.dataType === FIELD_DATA_TYPES.REFERENCE) {
                if (referenceFieldApiName && referenceFieldApiName.includes(".")) {
                    expressionDetail.relationshipName =
                        referenceFieldApiName.substring(0, referenceFieldApiName.lastIndexOf('.'))
                        + '.' + value.relationshipName;
                    expressionDetail.relationshipFieldAPIName = getLookupReferenceNameFields(value);
                } else {
                    expressionDetail.relationshipName = value ? value.relationshipName : '';
                    expressionDetail.relationshipFieldAPIName = value ?
                        getLookupReferenceNameFields(value) : '';
                }
            } else {
                expressionDetail.relationshipName = '';
                expressionDetail.relationshipFieldAPIName = '';
            }
            const mutable = deepCopy(this._expressionData);
            this._expressionDataForItem = mutable;
            this.dispatchItemChangedEvent();
        }
    }

    handleLiteralFieldChange (event) {
        const { value, index, objectSelected, referenceFieldApiName, label } = event.detail;
        const expressionDetail = this._expressionData.expressionDetails[index];
        if (value && expressionDetail.literalParameterAPIName !== referenceFieldApiName) {
            expressionDetail.literalParameterAPIName = referenceFieldApiName;
            expressionDetail.literalFieldLabel = label.includes(':') ?
                label.substring(label.lastIndexOf(':') + 2) : label;
            expressionDetail.literalRelatedObjectDetails = objectSelected;
            const mutable = deepCopy(this._expressionData);
            this._expressionDataForItem = mutable;
            this.dispatchItemChangedEvent();
        }
    }

    handleOperatorChange (event) {
        const { value, index, label } = event.detail;
        const expressionDetail = this._expressionData.expressionDetails[index];
        if (expressionDetail !== value) {
            expressionDetail.operator = value;
            expressionDetail.operatorLabel = label;
            expressionDetail.operandType = 'Value';
            expressionDetail.operand = null;
            expressionDetail.literalParameterAPIName = null;
            expressionDetail.literalFieldLabel = null;
            expressionDetail.literalRelatedObjectDetails = null;
            const mutable = deepCopy(this._expressionData);
            this._expressionDataForItem = mutable;
            this.dispatchItemChangedEvent();
        }
    }

    handleEditTypeChange () {

        const mutable = deepCopy(this._expressionData);
        this._expressionDataForItem = mutable;
        this.dispatchItemChangedEvent();

    }

    handleOperandChange (event) {
        const expressionDetail = this._expressionData.expressionDetails[event.detail.index];
        if (expressionDetail !== event.detail.value) {
            if (expressionDetail._fieldType === FIELD_DATA_TYPES.REFERENCE
                && event.detail.meta
                && isNotUndefinedOrNull(expressionDetail.operator)
                && !SEARCH_TEXT_OPERATOR_TYPES.has(expressionDetail.operator)) {
                expressionDetail.operand = event.detail.value === ''
                    ? event.detail.value
                    : event.detail.label;
            } else {
                expressionDetail.operand = event.detail.value;
            }
            expressionDetail.literalParameterAPIName = null;
            expressionDetail.literalFieldLabel = null;
            expressionDetail.literalRelatedObjectDetails = null;
            const mutable = deepCopy(this._expressionData);
            this._expressionDataForItem = mutable;
            this.dispatchItemChangedEvent();
        }
    }

    handleOperandTypeChange (event) {
        const expressionDetail = this._expressionData.expressionDetails[event.detail.index];
        if (expressionDetail !== event.detail.value) {
            expressionDetail.operandType = event.detail.value;
            expressionDetail.operand = null;
            expressionDetail.literalParameterAPIName = null;
            expressionDetail.literalFieldLabel = null;
            expressionDetail.literalRelatedObjectDetails = null;
            const mutable = deepCopy(this._expressionData);
            this._expressionDataForItem = mutable;
            this.dispatchItemChangedEvent();
        }
    }

    handleToggleEdit (event) {
        const { detail } = event;
        this.dispatchEvent(
            new CustomEvent('toggleedit', {
                detail
            })
        );
    }

    handleValueChange (event) {
        if (this._expressionData.advancedExpression !== event.detail.value) {
            this.updateExpressionData(event.detail.value);
        }
    }

    updateExpressionData (advancedExpression) {
        this._expressionData.advancedExpression = advancedExpression;
        const mutable = deepCopy(this._expressionData);
        this._expressionDataForItem = mutable;
        this.dispatchItemChangedEvent();
    }

    handleAdvancedValidation () {
        this.validateAdvancedExpression();
    }

    dispatchItemChangedEvent () {
        this.dispatchEvent(
            new CustomEvent('itemchanged')
        );
    }

    getRecords () {
        this.apiInProgress = true;
        this._expressionDataForItem = [];
        Promise.all([this.fetchObjectFields(this.objectApiNameList),
            this.fetchRecordTypeDetails(this.objectApiNameRecorcTypeList)])
            .then(() => {
                this._expressionDataForItem = this._expressionDataUnwrapped;
            }).catch( error => {
                this.error = parseErrorMessage(error);
            }).finally(() => {
                this.apiInProgress = false;
            });
    }

    getObjectApiNameFromItems () {
        this.apiInProgress = true;
        this.objectApiNameList = new Set();
        this.objectApiNameRecorcTypeList = new Set();
        this.objectApiNameRecorcTypeList.add(this._expressionDataUnwrapped.objectAPIName);
        if (this._expressionDataUnwrapped.expressionDetails) {
            this._expressionDataUnwrapped.expressionDetails.forEach((expressiondetail) => {
                const detail = expressiondetail;
                if (!detail.fieldLabel ||
                    this.getIsUserLiteral(detail) ||
                    this.getIsRecordHeaderLiteral(detail)
                ) {
                    let expressionObjectAPINames = new Set();
                    let literalObjectAPINames = new Set();
                    if (detail.relatedObjectDetails &&
                            detail.relatedObjectDetails.includes('.')) {
                        expressionObjectAPINames = new Set(detail.relatedObjectDetails.split('.'));
                    } else if (detail.relatedObjectDetails) {
                        expressionObjectAPINames.add(detail.relatedObjectDetails);
                    }
                    if (detail.literalRelatedObjectDetails &&
                            detail.literalRelatedObjectDetails.includes('.')) {
                        // eslint-disable-next-line max-len
                        literalObjectAPINames = new Set(detail.literalRelatedObjectDetails.split('.'));
                    } else if (detail.literalRelatedObjectDetails) {
                        literalObjectAPINames.add(detail.literalRelatedObjectDetails);
                    }

                    expressionObjectAPINames.forEach(elem => this.objectApiNameList.add(elem));
                    literalObjectAPINames.forEach(elem => this.objectApiNameList.add(elem));
                    this.objectApiNameList.add(this._expressionDataUnwrapped.objectAPIName);
                    if (this.headerRecordObject) {
                        this.objectApiNameList.add(this.headerRecordObject);
                    }
                    this.objectApiNameList.add('User');
                }

                if (expressiondetail.relatedObjectDetails &&
                    expressiondetail.relatedObjectDetails.includes('.')) {
                    const splittedString = expressiondetail.relatedObjectDetails.split('.');
                    this.objectApiNameRecorcTypeList.add(splittedString[splittedString.length - 1]);
                } else if (expressiondetail.relatedObjectDetails) {
                    this.objectApiNameRecorcTypeList.add(expressiondetail.relatedObjectDetails);
                }
            });
            this.getRecords();
        }
    }

    getIsUserLiteral (detail) {
        return detail && (detail.operand === FUNCTION_LITERALS.USER);
    }

    getIsRecordHeaderLiteral (detail) {
        return detail && (detail.operand === FUNCTION_LITERALS.CURRENTRECORDHEADER);
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
            this.error = parseErrorMessage(err);
        }
        this.objectApiField = result;
        return result;
    }

    async fetchRecordTypeDetails (objectNames) {
        let recordTypeMap = new Map();
        if (objectNames.length <= 0) {
            return recordTypeMap;
        }
        const objectApiNameList = [...objectNames];
        try {
            const result = await getObjectRecordTypeDetails({
                objectAPINames: objectApiNameList
            });
            if (result) {
                recordTypeMap = new Map(Object.entries(JSON.parse(result).data));
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
        this.recordTypeObjectDetails = recordTypeMap;
        return recordTypeMap;
    }


    handleTagChange (event) {
        const selectedValue = event.detail.value;
        this.filteredTagOptions = selectedValue;
        this._expressionData.selectedTagsValue = selectedValue;
        this._expressionDataForItem = deepCopy(this._expressionData);
        this.dispatchItemChangedEvent();
    }
}