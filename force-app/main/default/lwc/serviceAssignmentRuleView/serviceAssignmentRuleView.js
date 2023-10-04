import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ruleModel } from './ruleModel';
import {
    parseErrorMessage,
    verifyApiResponse,
    normalizeDeveloperName,
    populateExpressionDeveloperName,
    PAGE_ACTION_TYPES,
    handleMenuSelection,
    OBJECT_ICONS,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

import { getFieldDefinitionsForEntity } from 'c/metadataService';
import getServiceAssignmentRule
    from '@salesforce/apex/ADM_EntitlementLightningService.getServiceAssignmentRule';
import saveServiceAssignmentRule
    from '@salesforce/apex/ADM_EntitlementLightningService.saveServiceAssignmentRule';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelSave from '@salesforce/label/c.Button_Save';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelServiceAssignmentRule from '@salesforce/label/c.Label_Service_Assignment_Rule';
import labelServiceAssignmentRules from '@salesforce/label/c.Label_Service_Assignment_Rules';
import labelBackToList from '@salesforce/label/c.Button_BackToList';
import labelEntitlementServiceName
    from '@salesforce/label/c.Label_Entitled_Service_Assignment_Rule_Name';
import labelObject from '@salesforce/label/c.Label_Object';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelServiceActive from '@salesforce/label/c.Label_ServiceActive';
import labelEntitledServiceProduct from '@salesforce/label/c.Label_Entitled_Service_Product';
import labelConditions from '@salesforce/label/c.Label_Conditions';
import sectionGeneralInfo from '@salesforce/label/c.Sec_General_Information';
import sectionAssignment from '@salesforce/label/c.Label_Assignment';
import sectionQualifyingCriteria from '@salesforce/label/c.Sec_QualifyingCriteria';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelServiceAssignmenthelpText
    from '@salesforce/label/c.Help_Text_Entitled_Service_Assignment';

import { loadStyle } from 'lightning/platformResourceLoader';

import PRODUCT2_OBJECT from '@salesforce/schema/Product2';

import entitlementRuleResource from '@salesforce/resourceUrl/autoEntitlementRuleView';

const i18n = {
    pageHeader: labelServiceAssignmentRules,
    serviceAssRule: labelServiceAssignmentRule,
    wasSaved: labelWasSaved,
    edit: labelEditMenuItem,
    backToList: labelBackToList,
    ruleName: labelEntitlementServiceName,
    object: labelObject,
    cancel: labelCancel,
    save: labelSave,
    developerName: labelDeveloperName,
    description: labelDescription,
    serviceActive: labelServiceActive,
    entitledServiceProduct: labelEntitledServiceProduct,
    conditions: labelConditions,
    developerNameMissing: labelEnterDeveloperName,
    copyOf: labelCopyOf,
    formValidation: labelFormValidation,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    continue: labelYesContinue,
    goBack: labelNoGoBack,
    generalInfo: sectionGeneralInfo,
    assignment: sectionAssignment,
    qualifyingCriteria: sectionQualifyingCriteria,
    loading: labelLoading,
    required: labelRequired,
    serviceAssignmentHelpText: labelServiceAssignmenthelpText,
}

const CLONE_NAME_PREFIX = i18n.copyOf;

const SERVICE_ASSIGNMENT_RULE_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__serviceAssignmentRuleDetail'
    }
};

const STANDARD_EXP_TYPE = 'Standard Expression';

const EXPRESSION_TYPE = 'EVER-RULE-CRITERIA';

export default class ServiceAssignmentRuleView extends NavigationMixin(LightningElement) {

    _recordId;
    @api
    get recordId () {
        return this._recordId;
    }
    set recordId (newRecordId) {
        this._recordId = newRecordId;
    }

    _actionName;
    @api
    get actionName () {
        return this._actionName;
    }
    set actionName (newActionName) {
        this._actionName = newActionName;
    }

    @track editMode = false;
    @track error;
    @track apiInProgress = false;
    @track objectName;
    @track cancelModalDialogOpen;

    @track rule = { product: {}};
    @track _ruleRecord;

    @track _objectDefinition;
    booleanFalse = false;
    isProductRequired = true;
    productNameField = 'Name';
    productObject = PRODUCT2_OBJECT.objectApiName;
    productIcon = OBJECT_ICONS.product2;

    activeFormSections = ['GeneralInfo', 'QualifyingCriteria', 'Assignment'];
    currentNavItem;

    get i18n () {
        return i18n;
    }

    get developerNameDisabled () {
        return (this._actionName === PAGE_ACTION_TYPES.VIEW ||
            this._actionName === PAGE_ACTION_TYPES.EDIT);
    }

    get isDirty () {
        return (this.rule) ? this.rule.isDirty : false;
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

    disconnectedCallback () {
        clearTimeout(this.loadStylePromise);
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
            this.loadRecord();
        }

    }

    loadRecord () {
        this.apiInProgress = true;

        switch (this._actionName) {
            case PAGE_ACTION_TYPES.VIEW:
                this.getExistingRecordDetails(false);
                break;
            case PAGE_ACTION_TYPES.EDIT:
            case PAGE_ACTION_TYPES.CLONE:
                this.getExistingRecordDetails(true);
                break;
            default:
                this.editMode = true;
                this.getNewRecordDetails();
                break;
        }
    }

    getExistingRecordDetails (editMode) {
        if (!this._recordId) {
            return;
        }
        getServiceAssignmentRule({ serviceAssignmentRuleId: this._recordId })
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
                    configurationType: ADMIN_MODULES.ENTITLEMENT_SERVICE_ASSIGNMENT_RULES,
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
                            .then(objectDefinition => {
                                resultData.qualifyingCriteria = expressionData;
                                this._ruleRecord = resultData;
                                this.mapRuleData(resultData, objectDefinition);
                                this.editMode = editMode;
                            });
                    });

            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    getNewRecordDetails () {
        this.getObjectDefinition(this.objectName)
            .then(objectDefinition => {
                this.mapRuleData(null, objectDefinition);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    mapRuleData (ruleRecord, objectDefinition) {
        this._objectDefinition = objectDefinition;
        if (this._objectDefinition) {
            this.rule = new ruleModel(ruleRecord, this._objectDefinition);
        }

        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
            this.rule.markAsClone(CLONE_NAME_PREFIX);
        }

    }

    async getObjectDefinition (objectAPIName) {
        let objectDefinition = {};
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

    async getExpressionDetails (expressionRecord) {
        let qualifyingCriteria = {};
        if (expressionRecord && expressionRecord.id) {
            try {
                const expressionResponse = await getExpressionWithDetails({
                    expressionId: expressionRecord.id
                });
                if (expressionResponse && expressionResponse.data) {
                    qualifyingCriteria = expressionResponse.data;
                }
            } catch (err) {
                this.error = parseErrorMessage(err);
            }
        }
        return qualifyingCriteria;
    }

    clearState () {
        this.error = null;
        this.objectName = null;
        this.rule = new ruleModel(null, null);
        this._ruleRecord = null;
        this._recordId = null;
        this._actionName = null;
        this._objectDefinition = null;
        this.editMode = false;
        this.apiInProgress = false;
    }


    getServiceActiveToggle () {
        return this.template.querySelector('.svmx-service-assignment_button-toggle');
    }

    setServiceActive () {
        const ruleRecord = this.rule;
        if (ruleRecord) {
            return ruleRecord.active;
        }

        return false;
    }

    handleNameBlur () {
        if (!this.developerNameDisabled && !this.rule.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.rule.developerName = normalizeDeveloperName(
                this.rule.name,
                maxLength,
                ''
            );
            this.getDeveloperNameInput().value = this.rule.developerName;
        }
    }

    handleBackToList () {
        handleMenuSelection({
            detail: {
                name: "service-assignment-rules",
                targetType: "LWC",
                targetDeveloperName: "c-service-assignment-rules"
            }
        }, this);
    }

    handleServiceActiveCheck (event) {
        this.rule.active = event.target.checked;
    }

    getDeveloperNameInput () {
        return this.template.querySelector('[data-field="developerName"]');
    }

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.rule[event.currentTarget.dataset.field] = inputVal;
    }

    handleEdit () {
        this.editMode = true;
    }

    handleCancel () {
        if (this.isDirty) {
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

    handleSave () {
        const allValid = [...this.template.querySelectorAll('.svmx-service-assignment_field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        const expressionBuilder =
            this.template.querySelector('.svmx-service-assignment_expressionBuilder');

        if (expressionBuilder.reportValidity() || !allValid) {
            this.error = this.i18n.formValidation;
            return;
        }

        const recordToSave = this.rule.getRecordData();
        const expressionData = expressionBuilder.expressionData.getRecordData();
        expressionData.name = this.rule.developerName;
        expressionData.developerName = populateExpressionDeveloperName(this.rule.developerName);
        expressionData.objectAPIName = this.objectName;
        expressionData.expressionType = EXPRESSION_TYPE;
        expressionData.type = STANDARD_EXP_TYPE;
        recordToSave.qualifyingCriteria = expressionData;

        this.error = null;
        this.apiInProgress = true;

        saveServiceAssignmentRule({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showSaveSuccessNotification(this.rule.name);

                if (!this.rule.id) {
                    this.navigateToDetailComponent(result.data, PAGE_ACTION_TYPES.VIEW);
                } else {
                    this._ruleRecord = result.data;
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

    showSaveSuccessNotification (ruleName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.serviceAssRule} "${ruleName}" ${this.i18n.wasSaved}`,
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

        const detailRef = Object.assign({}, SERVICE_ASSIGNMENT_RULE_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    toggleEdit (event) {
        if (event) {
            event.stopPropagation();
        }
        this.editMode = !this.editMode;
    }

    handleChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const detail = event.detail;

        if (this.rule.product.id !== detail.value) {
            this.rule.product = { id: detail.value, name: detail.label };
        }
    }
}