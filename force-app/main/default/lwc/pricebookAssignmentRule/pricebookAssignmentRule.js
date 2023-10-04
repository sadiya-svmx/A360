import { LightningElement, wire } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import WORK_ORDER_OBJECT from '@salesforce/schema/WorkOrder';

import labelPriceBookAssignmentRules from '@salesforce/label/c.Label_Pricebook_Assignment_Rules';
import labelPriceBookAssignmentRuleName
    from '@salesforce/label/c.Label_Pricebook_Assignment_Rule_Name';
import btnBackToList from '@salesforce/label/c.Button_BackToList';
import btnEdit from '@salesforce/label/c.Button_Edit';
import secGeneralInformation from '@salesforce/label/c.Sec_General_Information';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelContinueConfirmation from '@salesforce/label/c.Label_ContinueConfirmation';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelSave from '@salesforce/label/c.Button_Save';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelObject from '@salesforce/label/c.Label_Object';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelRuleActive from '@salesforce/label/c.Label_RuleActive';
import labelPricebook from '@salesforce/label/c.Label_Pricebook';
import labelPricebookAssignment from '@salesforce/label/c.Label_Pricebook_Assignment';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelEntitlementTitle from '@salesforce/label/c.Label_Entitlement';
import msgSelectAnObject from '@salesforce/label/c.Message_Select_An_Object';
import sectionQualifyingCriteria from '@salesforce/label/c.Sec_QualifyingCriteria';
import sectionAssignment from '@salesforce/label/c.Sec_Assignment';
import helpTextPricebookAssignment from '@salesforce/label/c.Help_Text_Pricebook_Assignment';

import {
    getFieldDefinitionsForEntity,
} from 'c/metadataService';
import {
    parseErrorMessage,
    isEmptyString,
    verifyApiResponse,
    PAGE_ACTION_TYPES,
    handleMenuSelection,
    normalizeDeveloperName,
    populateExpressionDeveloperName,
    EXPRESSION,
    ADMIN_MODULES
} from 'c/utils';
import { RuleModel } from './ruleModel'

import { saveRecentViewItem }
    from 'c/recentItemService';

import entitlementRuleResource from '@salesforce/resourceUrl/autoEntitlementRuleView';
import getExistingRule
    from '@salesforce/apex/ADM_EntitlementLightningService.getPricebookAssignmentRule';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import savePricebookAssignmentRule
    from '@salesforce/apex/ADM_EntitlementLightningService.savePricebookAssignmentRule';

const i18n = {
    pageHeader: labelEntitlementTitle,
    labelPriceBookAssignmentRules: labelPriceBookAssignmentRules,
    pricebookAssignmentRuleName: labelPriceBookAssignmentRuleName,
    btnBackToList: btnBackToList,
    btnEdit: btnEdit,
    generalInfoSection: secGeneralInformation,
    edit: labelEditMenuItem,
    continueConfirmation: labelContinueConfirmation,
    cancelModalContent: labelCancelModal,
    goBack: labelNoGoBack,
    continue: labelYesContinue,
    copyOf: labelCopyOf,
    formValidation: labelFormValidation,
    wasSaved: labelWasSaved,
    cancel: labelCancel,
    save: labelSave,
    object: labelObject,
    developerName: labelDeveloperName,
    selectAnObject: msgSelectAnObject,
    ruleActive: labelRuleActive,
    description: labelDescription,
    qualifyingCriteria: sectionQualifyingCriteria,
    pricebook: labelPricebook,
    pricebookAssignment: labelPricebookAssignment,
    assignment: sectionAssignment,
    pricebookAssignmentHelpText: helpTextPricebookAssignment,
}

const CLONE_NAME_PREFIX = i18n.copyOf;

const PRICEBOOK_ASSIGNMENT_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__pricebookAssignmentRuleDetail'
    }
}

export default class PricebookAssignmentRule extends NavigationMixin(LightningElement) {

    _recordId = '';
    _newObjectChangeValue = '';
    _ruleRecord;
    error;
    editMode = false;
    apiInProgress = false;
    entityDefinition;
    entityOptions = [];
    changeObjectModalDialogOpen = false;
    pricebookNameField = 'Name';
    booleanFalse = false;
    cancelModalDialogOpen = false;
    rule = { pricebook: {}};

    get i18n () {
        return i18n;
    }

    get developerNameDisabled () {
        return (this._actionName === PAGE_ACTION_TYPES.VIEW);
    }

    renderedCallback () {
        this.loadStylePromise = Promise.all([
            loadStyle(this, entitlementRuleResource)
        ])
            .then(() => {})
            .catch(error => {
                console.error('static resource loadStylePromise error', error);
            });
    }

    @wire(getObjectInfo, { objectApiName: WORK_ORDER_OBJECT })
    setEntityOptions ({ error, data }) {
        if (data) {
            this.entityOptions.push({ value: data.apiName, label: data.label });
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            this.clearState();

            if (currentPageReference.state.c__recordId) {
                this._recordId = currentPageReference.state.c__recordId;
            }

            if (currentPageReference.state.c__actionName) {
                this._actionName = currentPageReference.state.c__actionName.toLowerCase();
            }

            if (currentPageReference.state.c__objectName) {
                this.objectName = currentPageReference.state.c__objectName;
            }

            if (currentPageReference.state.c__currentItem) {
                this.currentNavItem = currentPageReference.state.c__currentItem;
            }

            this.loadView();
        }
    }

    loadView () {
        this.apiInProgress = true;
        switch (this._actionName) {
            case PAGE_ACTION_TYPES.VIEW:
                this.editMode = false;
                this.getExistingRecordDetails();
                break;
            case PAGE_ACTION_TYPES.EDIT:
            case PAGE_ACTION_TYPES.CLONE:
                this.editMode = true;
                this.getExistingRecordDetails();
                break;
            default:
                this.getNewRecordDetails();
                break;
        }
    }

    clearState () {
        this.error = null;
        this.rule = new RuleModel(null, this.entityOptions[0]);
        this._recordId = null;
        this._ruleRecord = null;
        this._actionName = null;
        this._objectDefinition = null;
        this.editMode = false;
        this.apiInProgress = false;
    }

    getNewRecordDetails () {
        let objectAPIName = this.objectName;
        if (!this.objectAPIName) {
            objectAPIName = 'WorkOrder';
        }
        this.getObjectDefinition(objectAPIName)
            .then(objectDefintion => {
                this._objectDefinition = objectDefintion;
                const ruleRecord = { active: true, objectAPIName: objectAPIName };
                this.mapRuleData(ruleRecord, objectDefintion);
            })
            .finally(() => {
                this.editMode = true;
                this.apiInProgress = false;
            })
    }

    getExistingRecordDetails () {
        if (this._recordId) {
            getExistingRule({ pricebookAssignmentRuleId: this._recordId })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }
                    const resultData = result.data;

                    const recentlyViewedRecord = {
                        configurationId: resultData.id,
                        configurationName: resultData.name,
                        configurationDeveloperName: resultData.developerName,
                        configurationType: ADMIN_MODULES.PRICEBOOK_ASSIGNMENT_RULES,
                        objectApiName: resultData.objectAPIName
                    };
                    saveRecentViewItem(recentlyViewedRecord)
                        .then(recentItem => {
                            if (!verifyApiResponse(recentItem)) {
                                this.error = recentItem.message;
                            }
                        });

                    this.getExpressionDetails(resultData.qualifyingCriteria)
                        .then(expressionData => {

                            this.getObjectDefinition(resultData.objectAPIName)
                                .then(objectDefintion => {
                                    resultData.qualifyingCriteria = expressionData;
                                    this._objectDefinition = objectDefintion;
                                    this.mapRuleData(resultData, objectDefintion);
                                });
                        })
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                });
        }
    }

    mapRuleData (ruleRecord, entityDefinitionWithFields) {
        this._ruleRecord = ruleRecord;
        this.entityDefinition = entityDefinitionWithFields;
        if (this.entityDefinition) {
            this.rule = new RuleModel(ruleRecord, this.entityOptions[0]);
        }

        if (this._actionName === PAGE_ACTION_TYPES.CLONE) {
            this.rule.markAsClone(CLONE_NAME_PREFIX);
        }
    }

    async getExpressionDetails (expressionRecord) {
        let expression = {};
        if (expressionRecord && expressionRecord.id) {
            try {
                const expressionResponse = await getExpressionWithDetails({
                    expressionId: expressionRecord.id
                });
                if (expressionResponse && expressionResponse.data) {
                    expression = expressionResponse.data;
                }
            } catch (err) {
                this.error = parseErrorMessage(err);
            }
        }
        return expression;
    }

    async getObjectDefinition (objectApiName) {
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

    handleObjectChange (event) {
        if (this._objectDefinition
            && this._objectDefinition.apiName
            && this._objectDefinition.apiName !== event.target.value) {
            this.changeObjectModalDialogOpen = true;
            this._newObjectChangeValue = event.target.value;
        } else {
            this.apiInProgress = true;
            this.getObjectDefinition(event.target.value)
                .then(result => {
                    this._objectDefinition = result;
                    this.rule.qualifyingCriteria = [{}];
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                    this.changeObjectModalDialogOpen = false;
                })
        }
    }

    handleChangeObjectCancelModal () {
        this._newObjectChangeValue = undefined;
        this.changeObjectModalDialogOpen = false;
        this.rule.objectAPIName = this._objectDefinition.apiName;
    }

    handleChangeObjectConfirmModal () {
        this.apiInProgress = true;
        this.getObjectDefinition(this._newObjectChangeValue)
            .then(result => {
                this._objectDefinition = result;
                this.rule.objectAPIName = this._newObjectChangeValue;
                this.rule.qualifyingCriteria = [{}];
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
                this.changeObjectModalDialogOpen = false;
            });
    }

    handleEdit () {
        this.editMode = true;
    }

    toggleEdit (event) {
        if (event) {
            event.stopPropagation();
        }
        this.editMode = !this.editMode;
    }

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.rule[event.currentTarget.dataset.field] = inputVal;
    }

    handleRuleActiveChange (event) {
        this.rule.isRuleActive = event.target.checked;
    }

    handleNameCommit () {
        if (!this.rule.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.rule.developerName = normalizeDeveloperName(
                this.rule.name,
                maxLength,
                ''
            );
            this.getDeveloperNameInput().value = this.rule.developerName;
        }
    }

    handleCancel () {
        if (this.rule.isDirty) {
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
        if (this._actionName === PAGE_ACTION_TYPES.NEW
            || this.actionName === PAGE_ACTION_TYPES.CLONE) {
            this.handleBackToList();
        } else {
            this.mapRuleData(this._ruleRecord, this._objectDefinition);
            this.editMode = false;
        }
    }

    handleBackToList () {
        handleMenuSelection({
            detail: {
                name: "pricebook_assignment_rules",
                targetType: "LWC",
                targetDeveloperName: "c-pricebook-assignment-list-view"
            }
        }, this);
    }

    handleSave () {
        if (this.reportValidity()) {
            const expressionBuilder = this.template.querySelector('.svmx-expression-builder');
            const recordToSave = this.rule.getRecordData();
            const expressionData = expressionBuilder.expressionData.getRecordData();
            expressionData.name = this.rule.developerName;
            expressionData.developerName = populateExpressionDeveloperName(this.rule.developerName);
            expressionData.objectAPIName = this.rule.objectAPIName;
            expressionData.expressionType = EXPRESSION.EXPRESSION_TYPE;
            expressionData.type = EXPRESSION.TYPE;
            recordToSave.qualifyingCriteria = expressionData;

            this.error = null;
            this.apiInProgress = true;

            savePricebookAssignmentRule({ requestJson: JSON.stringify(recordToSave) })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }

                    this.showSaveSuccessNotification(this.rule.name);

                    if (!this.rule.id) {
                        this.navigateToDetailComponent(result.data, PAGE_ACTION_TYPES.VIEW);
                    } else {
                        this.mapRuleData(result.data, this._objectDefinition);
                        this.editMode = false;
                    }
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                });
        }
    }

    handlePricebookChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const detail = event.detail;

        if (this.rule.pricebook.id !== detail.value) {
            this.rule.pricebook = { id: detail.value, name: detail.label };
        }
    }

    handleExpressionItemChanged () {
        this.rule.isDirty = true;
    }

    reportValidity () {
        const allValid =
            [...this.template.querySelectorAll('.svmx-pricebook-assignment_input-field')]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true);

        const expressionBuilder = this.template.querySelector('.svmx-expression-builder');

        if (expressionBuilder.reportValidity() || !allValid) {
            this.error = this.i18n.formValidation;
            return false;
        }
        return true;
    }

    showSaveSuccessNotification (ruleName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.pricebookAssignment} "${ruleName}" ${this.i18n.wasSaved}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    navigateToDetailComponent (ruleRecord, actionName) {
        const navState = {
            c__actionName: actionName,
            c__recordId: ruleRecord.id,
            c__objectName: ruleRecord.objectAPIName
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, PRICEBOOK_ASSIGNMENT_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    getDeveloperNameInput () {
        return this.template.querySelector('.svmx-pricebook-assignment_developer-name-input');
    }
}