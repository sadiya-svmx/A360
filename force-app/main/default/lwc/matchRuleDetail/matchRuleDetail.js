/* eslint-disable max-len */
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import getTechnicalAttributeTemplateRuleDetail from '@salesforce/apex/ADM_TechnicalAttribute_LS.getTechnicalAttributeTemplateRuleDetail';
// eslint-disable-next-line max-len
import saveTechnicalAttributeTemplateRule from '@salesforce/apex/ADM_TechnicalAttribute_LS.saveTechnicalAttributeTemplateRule';
import AdvancedCriteriaType_FIELD from '@salesforce/schema/CONF_TA_TemplateMatchRule__c.AdvancedCriteriaType__c';
import TEMPLATEMATCHRULE_OBJ from '@salesforce/schema/CONF_TA_TemplateMatchRule__c';
import {
    parseErrorMessage,
    verifyApiResponse,
    handleMenuSelection,
    normalizeDeveloperName,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';
import ICONS from '@salesforce/resourceUrl/pscIcons';
import { getFieldDefinitionsForEntity } from 'c/metadataService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelRuleName from '@salesforce/label/c.Label_RuleName';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelObject from '@salesforce/label/c.Label_Object';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelTemplateFieldMatching from '@salesforce/label/c.Label_TemplateFieldMatching';
import labelDropDownMenu1 from '@salesforce/label/c.Label_NewTemplateDropDownMenu1';
import labelDropDownMenu2 from '@salesforce/label/c.Label_NewTemplateDropDownMenu2';
import labelDropDownMenu3 from '@salesforce/label/c.Label_NewTemplateDropDownMenu3';
import labelTemplateRuleTitle from '@salesforce/label/c.Label_TemplateRules';
import labelMatchRuleDetailSubtitle from '@salesforce/label/c.Label_MatchRuleDetailSubTitle';
import labelTemplateField from '@salesforce/label/c.Label_TemplateAssociationField';
import labelAssetField from '@salesforce/label/c.Label_MatchRuleDetailAssetField';
import labelEnterValueMissing from '@salesforce/label/c.Message_EnterValue';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNewTemplateAccordianMsg from '@salesforce/label/c.Label_NewTemplateAccordianMsg';
import labelDisplayTemplateWhen from '@salesforce/label/c.Label_NewTemplateConditionDropDown';
import labelAddMacthBtn from '@salesforce/label/c.Label_AddMatchBtnLabel';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelAdvancedExpressionEdit from '@salesforce/label/c.Label_Advanced_Expression_Edit';
import messageInvalidException from '@salesforce/label/c.Message_InvalidExpressionError';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import matchRule from '@salesforce/label/c.Label_MatchRule';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelDuplicateMatchRule from '@salesforce/label/c.Error_DuplicateMatchRuleDeveloperName';
const i18n = {
    wasSaved: labelWasSaved,
    matchRule: matchRule,
    ruleName: labelRuleName,
    enterValueMsg: labelEnterValue,
    object: labelObject,
    description: labelDescription,
    templateFieldMatching: labelTemplateFieldMatching,
    dropDownMenu1: labelDropDownMenu1,
    dropDownMenu2: labelDropDownMenu2,
    dropDownMenu3: labelDropDownMenu3,
    templateRuleTitle: labelTemplateRuleTitle,
    matchRuleDetailSubtitle: labelMatchRuleDetailSubtitle,
    templateField: labelTemplateField,
    assetField: labelAssetField,
    enterValueMissing: labelEnterValueMissing,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    goBack: labelNoGoBack,
    continue: labelYesContinue,
    newTemplateAccordianMsg: labelNewTemplateAccordianMsg,
    displayTemplateWhen: labelDisplayTemplateWhen,
    addMacthBtn: labelAddMacthBtn,
    cancel: labelCancel,
    save: labelSave,
    select: labelSelect,
    advancedExpressionEdit: labelAdvancedExpressionEdit,
    messageInvalidException: messageInvalidException,
    formValidation: labelFormValidation,
    developerName: labelDeveloperName,
    duplicateMatchRule: labelDuplicateMatchRule
}
export default class MatchRuleDetail extends NavigationMixin(LightningElement) {
    i18n = i18n;
    objectAPIName = 'Asset';
    recordId;
    showCustomLogicField = false;
    action;
    cancelModalDialogOpen = false;
    logoUrl = `${ICONS}/pscIcons/ServiceMax_Logo.svg`;
    selectedRowIndex;
    apiInProgress = false;
    currentNavItem;
    showTooltip = false;
    masterSequence;
    dataChanged = false;
    editMode = false;
    removeUserObjectFromRelatedField = true;
    @track error;
    @track detailRecordList = [];
    @track availableTemplateFields = [];
    @track masterRecordData = {};
    @track objectDetails = {}
    @track recordsRemoved = [];
    @track objectMetaDetails;
    @track options;
    @track clearStateNeeded = false;

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        this.apiInProgress = true;
        if (currentPageReference && currentPageReference.state) {
            this.clearState();
            if (currentPageReference.state.c__recordId) {
                this.recordId = currentPageReference.state.c__recordId;
            }

            if (currentPageReference.state.c__objectName) {
                this.objectAPIName = currentPageReference.state.c__objectName;
            }

            if (currentPageReference.state.c__actionName) {
                this.action = currentPageReference.state.c__actionName;
            }

            if (currentPageReference.state.c__currentItem) {
                this.currentNavItem = currentPageReference.state.c__currentItem;
            }

            if (currentPageReference.state.c__sequence) {
                this.masterSequence = currentPageReference.state.c__sequence;
            }
            this.editMode = this.action === 'Edit' ? true : false;
            if (this.action === 'Edit' || this.action === 'Clone') {
                this.loadRecord();
            }

            if ( this.action === 'New' ) {
                this.apiInProgress = true;
                this.masterRecordData.ruleName = '';
                this.masterRecordData.description = '';
                this.masterRecordData.selectionCondition = 'AllConditionsMet';
                this.masterRecordData.advancedCriteria = '';
                this.masterRecordData.sequence = this.masterSequence;
                this.loadTemplateAssocFieldDefinitions();
                this.objectMetaDetails = this.getObjectDefinition(this.objectAPIName);
                this.handleAddRow();
                this.dataChanged = false;
                this.apiInProgress = false;
            }
        }
    }

    loadRecord () {
        this.apiInProgress = true;
        getTechnicalAttributeTemplateRuleDetail ({ matchRuleId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.loadTemplateAssocFieldDefinitions(); //template association
                this.objectMetaDetails = this.getObjectDefinition(this.objectAPIName); //asset
                this.masterRecordData = result.data;
                const recentlyViewedRecord = {
                    configurationId: result.data.id,
                    configurationName: result.data.ruleName,
                    configurationDeveloperName: result.data.developerName,
                    configurationType: ADMIN_MODULES.TEMPLATE_RULES
                };
                saveRecentViewItem(recentlyViewedRecord)
                    .then(recentItem => {
                        if (!verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
                if (this.action === 'Clone') {
                    this.masterRecordData.id = null;
                    this.masterRecordData.ruleName = 'CopyOf_' + this.masterRecordData.ruleName;
                    this.masterRecordData.developerName = 'CopyOf_' + this.masterRecordData.developerName;
                }
                this.masterRecordData.sequence = this.masterSequence;
                this.detailRecordList = result.data.matchRuleDetails;
                this.detailRecordList.forEach(rec => {
                    rec.showRelatedPicklistDialog = false;
                })
                if (this.masterRecordData.selectionCondition === 'CustomLogicMet') {
                    this.showCustomLogicField = true;
                } else {
                    this.showCustomLogicField = false;
                }
                this.apiInProgress = false;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.apiInProgress = false;
            })
    }

    handleAddRow () {
        const newRow = {};
        newRow.operandFieldAPIName = '';
        newRow.operator = 'Equals';
        newRow.objectFieldAPIName = '';
        newRow.relatedObjectDetails = '';
        newRow.referenceFieldLabel = '';
        newRow.objectAPIName = this.objectAPIName;
        newRow.sequence = (this.detailRecordList.length === undefined || this.detailRecordList.length === 0) ? 1 : this.detailRecordList.length + 1;
        newRow.id = 'newRow'+newRow.sequence;
        newRow.operandObjectAPIName = 'SVMXA360__SM_TA_TemplateAssociation__c';
        newRow.showRelatedPicklistDialog = false;
        this.detailRecordList.push(newRow);
        if (this.masterRecordData.selectionCondition === 'CustomLogicMet') {
            this.setCustomValidityOnExpression(this.masterRecordData.advancedCriteria);
        }
        this.dataChanged = true;
    }

    handleRemoveRow (event) {
        const recordIdToRemove = event.target.dataset.name;
        const index = this.findIndexOfChild('id', recordIdToRemove);
        this.detailRecordList.splice(index, 1);
        if ( recordIdToRemove.indexOf('newRow') === -1)
            this.recordsRemoved.push(recordIdToRemove);
        let count = 1;
        this.detailRecordList.forEach(rec => {
            rec.sequence = count++;
            if (rec.id.includes('newRow')) {
                rec.id = 'newRow'+rec.sequence;
            }
        } )
        if (this.masterRecordData.selectionCondition === 'CustomLogicMet') {
            this.setCustomValidityOnExpression(this.masterRecordData.advancedCriteria);
        }
        this.dataChanged = true;
    }

    setCustomValidityOnExpression (expressionInput) {
        const advancedExp = this.template.querySelector('.advancedExpressionInput');
        if (this.detailRecordList === undefined || (this.detailRecordList !== undefined && !this.validateExpression(this.detailRecordList.length, expressionInput))) {
            advancedExp.setCustomValidity(this.i18n.messageInvalidException);
        } else {
            advancedExp.setCustomValidity('');
        }
        advancedExp.reportValidity();
    }

    handleAdvancedValidation (event) {
        this.setCustomValidityOnExpression(event.target.value);
        this.dataChanged = true;
    }

    handleFieldChange (event) {
        this.selectedRowIndex = this.findIndexOfChild('id', event.target.dataset.name);
        this.detailRecordList[this.selectedRowIndex].showRelatedPicklistDialog = true;
    }

    handleRelatedPicklistSelected (event) {
        const label = event.detail.label;
        const referenceFieldLabel  = label.includes(':') ?
            label.substring(label.lastIndexOf(':') + 2) : label;
        this.detailRecordList[this.selectedRowIndex].objectFieldAPIName = event.detail.valueSelected;
        this.detailRecordList[this.selectedRowIndex].relatedObjectDetails = event.detail.objectSelected;
        this.detailRecordList[this.selectedRowIndex].referenceFieldLabel = referenceFieldLabel;
        this.detailRecordList[this.selectedRowIndex].fieldType = event.detail.fieldDefinition?.dataType;
        this.detailRecordList[this.selectedRowIndex].showRelatedPicklistDialog = false;
        this.dataChanged = true;
    }

    handleCancelRelatedPicklist () {
        this.detailRecordList[this.selectedRowIndex].showRelatedPicklistDialog = false;
    }

    handleOnselect (event) {
        if (event.detail.value === 'CustomLogicMet') {
            this.showCustomLogicField = true;
        } else {
            this.showCustomLogicField = false;
        }
        this.masterRecordData.selectionCondition = event.detail.value;
        this.dataChanged = true;
    }

    handleMasterDataChange (event) {
        const targetElement = event.target;
        this.masterRecordData[targetElement.dataset.field] = targetElement.value;
        this.dataChanged = true;
    }

    handleRuleNameCommit () {
        if (!this.masterRecordData.developerName) {
            const developerNameField = this.template.querySelector('.svmx-developerName');
            const maxLength = developerNameField.maxLength;
            this.masterRecordData.developerName = normalizeDeveloperName(
                this.masterRecordData.ruleName,
                maxLength,
                ''
            );
        }
    }

    handleDetailChange (event) {
        const index = this.findIndexOfChild('id', event.target.dataset.field);
        this.detailRecordList[index].operandFieldAPIName = event.target.value;
        this.dataChanged = true;
    }

    setExpressionFieldNonCustomOption (conditionSelected) {
        let binaryOperator;
        if (conditionSelected === 'AllConditionsMet')
            binaryOperator = 'AND';
        else
            binaryOperator = 'OR';

        let buildCriteria = '1';
        for (let i = 2; i <= this.detailRecordList.length; i++) {
            buildCriteria = buildCriteria + ' ' + binaryOperator +' '+ i;
        }
        this.masterRecordData.advancedCriteria = buildCriteria;
    }

    renderedCallback () {
        if (this.clearStateNeeded) {
            this.clearStateNeeded = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: TEMPLATEMATCHRULE_OBJ })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: AdvancedCriteriaType_FIELD
    })
    setOptions ({ error, data }) {
        this.apiInProgress = true;
        if (data) {
            this.options = [];
            if (data.values?.length > 0 ) {
                data.values.forEach(row => {
                    const option = {
                        label: row.label,
                        value: row.value
                    }
                    this.options.push(option);
                });
            }
        } else if (error) {
            this.error = error;
        }
        this.apiInProgress = false;
    }

    findIndexOfChild (key, compareWith) {
        return this.detailRecordList.findIndex(item => {return item[key] === compareWith});
    }

    async loadTemplateAssocFieldDefinitions () {
        const fieldData = await this.getObjectDefinition('SVMXA360__SM_TA_TemplateAssociation__c');
        fieldData.fieldDefinitions.forEach(field => {
            if (field.apiName.endsWith('__c') ) {
                const fieldOption = {
                    label: field.label,
                    secondary: field.apiName
                };
                this.availableTemplateFields.push(fieldOption);
                fieldOption.value = field.apiName;
            }
        });
    }

    /* Gets the details about the object like all fields, related fields etc*/
    async getObjectDefinition (objectAPIName) {
        let objectDefinition;
        if (objectAPIName) {
            objectDefinition = await getFieldDefinitionsForEntity(objectAPIName)
                .then( result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return {};
                    }
                    this.error = null;
                    return result.data;
                });
        }
        return objectDefinition;
    }

    handleSaveButtonclick () {
        this.apiInProgress = true;
        if (this.masterRecordData.selectionCondition !== 'CustomLogicMet') {
            this.setExpressionFieldNonCustomOption(this.masterRecordData.selectionCondition);
        } else {
            this.setCustomValidityOnExpression(this.masterRecordData.advancedCriteria);
        }
        const allValid = [...this.template.querySelectorAll('[data-field]')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        // eslint-disable-next-line max-len
        if (!allValid || this.detailRecordList === undefined || this.detailRecordList.length === 0) {
            this.error = this.i18n.formValidation;
            this.apiInProgress = false;
            return;
        }
        this.error = '';
        this.masterRecordData.matchRuleDetails = this.detailRecordList.map(({ showRelatedPicklistDialog, ...rest }) => {
            return rest;
          });
        saveTechnicalAttributeTemplateRule ({ jsonRequest: JSON.stringify(this.masterRecordData) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    if (result.message.includes('duplicate value found:')) {
                        this.error = i18n.duplicateMatchRule;
                    } else {
                        this.error = result.message;
                    }
                    return;
                }
                this.masterRecordData = result.data;
                const recentlyViewedRecord = {
                    configurationId: result.data.id,
                    configurationName: result.data.ruleName,
                    configurationDeveloperName: result.data.developerName,
                    configurationType: ADMIN_MODULES.TEMPLATE_RULES
                };
                saveRecentViewItem(recentlyViewedRecord)
                    .then(recentItem => {
                        if (!verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
                this.showSaveSuccessNotification(this.masterRecordData.ruleName);
                this.detailRecordList = result.data.matchRuleDetails;
                this.detailRecordList.forEach(rec => {
                    rec.showRelatedPicklistDialog = false;
                })
                this.dataChanged = false;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                if (this.options !== undefined) {
                    this.apiInProgress = false;
                }
            });

    }

    validateExpression (totalNumberOfRows, value) {
        // eslint-disable-next-line max-len
        if (!value) { return true;} // Blank expressions will get defaulted to 1 AND 2 AND etc . . . 
        // Create three stacks, one for parens, one for conditions, one for the integer values
        const openParenStack = [];
        const closedParenStack = [];
        const conditionStack = [];
        const valueStack = [];

        // Put the value to lower case so we ignore case (also using the i flag), and split an capture
        // the parts of the Expression using a Regex
        const regxToSplit = new RegExp(/(or|and)(?!\\w)|([()])|(\d+)/gi);
        const copyOfValue = value.toLowerCase();
        const tokenizedValues = copyOfValue.split(regxToSplit);

        // Iterate through the tokens, and put them on their correct stack. 
        // Fail if invalid order or token is found.
        let invalidTokenFound = false;
        let invalidTokenOrder = false;
        let invalidTautology = false;
        let invalidMixedOperatorsWithNoParens = false;
        let hasAndOperators = false;
        let hasOrOperators = false;
        let previousValidToken;
        let previousValidValue;
        tokenizedValues.forEach(token => {
            const trimToken = token ? token.trim() : token;
            // Push open parens and closed parens on to stacks, and then validate they are balanced.
            if (trimToken === '(') {
                openParenStack.push(trimToken);
                previousValidToken = trimToken;
            } else if (trimToken === ')') {
                closedParenStack.push(trimToken);
                if (previousValidToken !== undefined) {
                    if (previousValidToken === '(') {
                        invalidTokenOrder = true;
                        return;
                    }
                }
                previousValidToken = trimToken;
            } else if (trimToken === 'and' || trimToken === 'or') {
                conditionStack.push(trimToken);
                if (trimToken === 'and') {
                    hasAndOperators = true;
                } else if (trimToken === 'or') {
                    hasOrOperators = true;
                }
                if (previousValidToken !== undefined) {
                    if (isNaN(Number(previousValidToken) ||
                    previousValidToken !== '(' ||
                    previousValidToken !== ')')) {
                        invalidTokenOrder = true;
                        return;
                    }
                }
                previousValidToken = trimToken;
            } else if (trimToken === "" || trimToken === " " || trimToken === undefined) {
                // ignore these tokens
            } else if (!isNaN(Number(trimToken))) {
                valueStack.push(Number(trimToken));
                if (previousValidToken !== undefined) {
                    if (previousValidToken !== 'and' &&
                    previousValidToken !== 'or' &&
                    previousValidToken !== '(' &&
                    previousValidToken !== ')') {
                        invalidTokenOrder = true;
                        return;
                    }
                }
                if (previousValidValue !== undefined) {
                    if (previousValidValue === trimToken &&
                        (previousValidToken !== undefined &&
                            (previousValidToken === 'and' || previousValidToken === 'or'))) {
                        invalidTautology = true;
                        return;
                    }
                }
                previousValidToken = trimToken;
                previousValidValue = trimToken;
            } else {
                invalidTokenFound = true;
            }
        });

        if (hasAndOperators
            && hasOrOperators
            && openParenStack.length === 0
            && closedParenStack.length === 0) {
            invalidMixedOperatorsWithNoParens = true;
        }

        // Check to make sure that all rows are being used.
        const maxValue = Math.max(...valueStack);
        const allValuesUsed = maxValue === totalNumberOfRows;

        // Check to make sure that there is a condition for every pair of Integer values
        const validAmountOfConditions = conditionStack.length > 0
            ? conditionStack.length === valueStack.length - 1
            : valueStack.length === 1;

        // Finally, check to make sure that every row is utilized in the expression.
        let valueValidation = valueStack;
        for (let i = 1; i <= totalNumberOfRows; i++) {
            valueValidation = valueValidation.filter(numberToken => numberToken !== i);
        }

        return !invalidTokenFound
            && openParenStack.length === closedParenStack.length
            && valueValidation.length === 0
            && allValuesUsed
            && validAmountOfConditions
            && !invalidTautology
            && !invalidTokenOrder
            && !invalidMixedOperatorsWithNoParens;
    }


    handleCancelButtonClick () {
        if (this.dataChanged) {
            this.cancelModalDialogOpen = true;
        } else {
            this.navigateBack();
        }
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;
        this.navigateBack();
    }

    navigateBack () {
        this.clearState();
        this.handleBackToList();
    }

    handleBackToList () {
        handleMenuSelection({
            detail: {
                name: "template_rules",
                targetType: "LWC",
                targetDeveloperName: "c-template-match-rule-list-view"
            }
        }, this);
    }

    showSaveSuccessNotification (ruleName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.matchRule} "${ruleName}" ${this.i18n.wasSaved}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    get getMasterRecordData () {
        return this.masterRecordData;
    }

    get getAvailableTemplateFields () {
        return JSON.parse(JSON.stringify(this.availableTemplateFields));
    }

    get getDeleteDisabled () {
        return this.detailRecordList.length === 1 ? true : false;
    }

    get disableSave () {
        return !this.dataChanged;
    }

    clearState () {
        this.error = null;
        //this.currentNavItem = null;
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.masterRecordData = {};
        this.detailRecordList = [];
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.recordsRemoved = [];
        this.objectDetails = {};
        this.objectMetaDetails = {};
        this.availableTemplateFields = [];
        this.showCustomLogicField = false;
        this.cancelModalDialogOpen = false;
        this.dataChanged = false;
        this.clearStateNeeded = true;
    }

}