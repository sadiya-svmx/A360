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
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

import { getFieldDefinitionsForEntity } from 'c/metadataService';
import getEntitlementRule
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementRule';
import saveEntitlementRule
    from '@salesforce/apex/ADM_EntitlementLightningService.saveEntitlementRule';
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
import labelAutomaticRules from '@salesforce/label/c.Label_Automatic_Rules';
import labelAutomaticRule from '@salesforce/label/c.Label_AutomaticRule';
import labelBackToList from '@salesforce/label/c.Button_BackToList';
import labelRuleName from '@salesforce/label/c.Label_RuleName';
import labelObject from '@salesforce/label/c.Label_Object';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelCoveredBy from '@salesforce/label/c.Label_CoveredBy';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelRuleActive from '@salesforce/label/c.Label_RuleActive';
import labelWhatToCheck from '@salesforce/label/c.Label_WhatToCheck';
import labelWarranties from '@salesforce/label/c.Label_Warranties';
import labelMatchAccount from '@salesforce/label/c.Label_MatchAccount';
import labelAccountAPIName from '@salesforce/label/c.Label_AccountAPIName';
import labelAssetAPIName from '@salesforce/label/c.Label_AssetAPIName';
import labelIncludeRootAsset from '@salesforce/label/c.Label_IncludeRootAsset';
import labelIncludeParentAsset from '@salesforce/label/c.Label_IncludeParentAsset';
import labelServiceContracts from '@salesforce/label/c.Label_ServiceContracts';
import labelMultipleContractsFound from '@salesforce/label/c.Label_MultipleContractsFound';
import labelMultipleContractsFoundHelpText
    from '@salesforce/label/c.Label_MultipleContractsFoundHelpText';
import labelConditions from '@salesforce/label/c.Label_Conditions';
import labelAlsoCheckEntitlement from '@salesforce/label/c.Label_AlsoCheckEntitlement';
import labelExcludeWarrantyType from '@salesforce/label/c.Label_ExcludeWarrantyType';
import sectionGeneralInfo from '@salesforce/label/c.Sec_General_Information';
import sectionRules from '@salesforce/label/c.Label_Rules';
import sectionQualifyingCriteria from '@salesforce/label/c.Sec_QualifyingCriteria';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelSelectBillingType from '@salesforce/label/c.Label_Select_Default_Billing_Type';

import { loadStyle } from 'lightning/platformResourceLoader';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COVERED_BY_FIELD from '@salesforce/schema/CONF_EntitlementRule__c.CoveredBy__c';
import RESOLUTION_METHOD_FIELD
    from '@salesforce/schema/CONF_EntitlementRule__c.ResolutionMethod__c';
import DEFAULT_BILLING_TYPE_FIELD
    from '@salesforce/schema/CONF_EntitlementRule__c.DefaultBillingType__c';
import WARRANTY_TYPES_FIELD from '@salesforce/schema/CONF_EntitlementRule__c.WarrantyTypes__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ENTITLEMENT_RULE_OBJECT from '@salesforce/schema/CONF_EntitlementRule__c';

import entitlementRuleResource from '@salesforce/resourceUrl/autoEntitlementRuleView';

const i18n = {
    pageHeader: labelAutomaticRules,
    automaticRule: labelAutomaticRule,
    wasSaved: labelWasSaved,
    edit: labelEditMenuItem,
    backToList: labelBackToList,
    ruleName: labelRuleName,
    object: labelObject,
    cancel: labelCancel,
    save: labelSave,
    developerName: labelDeveloperName,
    coveredBy: labelCoveredBy,
    description: labelDescription,
    ruleActive: labelRuleActive,
    whatToCheck: labelWhatToCheck,
    checkWarranties: labelWarranties,
    accountOnCase: labelMatchAccount,
    accountFieldOnCase: labelAccountAPIName,
    assetFieldOnCase: labelAssetAPIName,
    includeRootAsset: labelIncludeRootAsset,
    includeParentAsset: labelIncludeParentAsset,
    checkContracts: labelServiceContracts,
    resolutionMethod: labelMultipleContractsFound,
    resolutionMethodHelpText: labelMultipleContractsFoundHelpText,
    conditions: labelConditions,
    alsoCheckFor: labelAlsoCheckEntitlement,
    developerNameMissing: labelEnterDeveloperName,
    copyOf: labelCopyOf,
    formValidation: labelFormValidation,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    continue: labelYesContinue,
    goBack: labelNoGoBack,
    generalInfo: sectionGeneralInfo,
    rules: sectionRules,
    qualifyingCriteria: sectionQualifyingCriteria,
    warrantyTypes: labelExcludeWarrantyType,
    loading: labelLoading,
    required: labelRequired,
    selectDefaultBillingType: labelSelectBillingType,
}

const CLONE_NAME_PREFIX = i18n.copyOf;

const ENTITLEMENT_RULE_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__entitlementRuleDetail'
    }
};

const TYPE = 'Standard Expression';

const EXPRESSION_TYPE = 'EVER-RULE-CRITERIA';

export default class AutoEntitlementRuleView extends NavigationMixin(LightningElement) {

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

    resolutionFieldOptions = [];

    @track editMode = false;
    @track renderAccountFields = false;
    @track error;
    @track coveredByOptions;
    @track isCoveredByAccount;
    @track resolutionMethodOptions;
    @track accountFields = [];
    @track assetFields = [];
    @track apiInProgress = false;
    @track objectName;
    @track resolutionMethodLabel;
    @track selectedAccountLabel;
    @track selectedAssetLabel;
    @track cancelModalDialogOpen;
    @track warrantyTypeOptions = [];
    @track warrantyChecked = false;
    @track contractChecked = false;
    get whatToCheckOptions () {
        return [
            { label: i18n.checkWarranties, value: 'warranty' },
            { label: i18n.checkContracts, value: 'contract' }
        ];
    }

    @track rule = {};
    @track _ruleRecord;

    @track _objectDefintion;

    activeFormSections = ['GeneralInfo','QualifyingCriteria','Rules'];
    currentNavItem;
    defaultBillingTypeOptions = [];

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

    get matchAccountLabel () {
        return `${i18n.accountOnCase} ${this.rule.objectLabel}`;
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

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: COVERED_BY_FIELD
    })
    setCoveredByOptions ({ error, data }) {
        if (data) {
            this.coveredByOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: RESOLUTION_METHOD_FIELD
    })
    setResolutionMethodOptions ({ error, data }) {
        if (data) {
            this.resolutionFieldOptions = data.values;
            this.resolutionMethodOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: WARRANTY_TYPES_FIELD
    })
    setWarrantyTypeOptions ({ error, data }) {
        if (data) {
            this.warrantyTypeOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: DEFAULT_BILLING_TYPE_FIELD
    })
    setDefaultBillingTypeOptions ({ error, data }) {
        if (data) {
            this.defaultBillingTypeOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: ENTITLEMENT_RULE_OBJECT })
    objectInfo;

    loadRecord () {
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
                this.editMode = true;
                this.getNewRecordDetails();
                break;
        }
    }

    getExistingRecordDetails () {
        if (this._recordId) {
            getEntitlementRule({ entitlementRuleId: this._recordId })
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
                        configurationType: ADMIN_MODULES.AUTOMATIC_RULES,
                        objectApiName: resultData.objectAPIName
                    };
                    saveRecentViewItem(recentlyViewedRecord)
                        .then(recentItem => {
                            if (!verifyApiResponse(recentItem)) {
                                this.error = recentItem.message;
                            }
                        });
                    this.getExpressionDetails(resultData.expression)
                        .then(expressionData => {

                            this.getObjectDefinition(resultData.objectAPIName)
                                .then(objectDefintion => {
                                    resultData.expression = expressionData;
                                    this.mapRuleData(resultData, objectDefintion);
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

    }

    getNewRecordDetails () {
        this.getObjectDefinition(this.objectName)
            .then(objectDefintion => {
                this.mapRuleData(null, objectDefintion);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    mapRuleData (ruleRecord, objectDefintion) {

        this._objectDefintion = objectDefintion;
        if (this._objectDefintion) {
            this.rule = new ruleModel(ruleRecord, this._objectDefintion);
            this.setLookupFieldOptions(this._objectDefintion.fieldDefinitions);
        }

        if (ruleRecord) {
            this._ruleRecord = ruleRecord;
            this.resolutionMethodLabel = this.getResolutionMethodLabel(ruleRecord.resolutionMethod);
            this.selectedAccountLabel = this.getAccountFieldLabel(ruleRecord.accountAPIName);
            this.selectedAssetLabel = this.getAssetFieldLabel(ruleRecord.assetAPIName);
        }

        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
            this.rule.markAsClone(CLONE_NAME_PREFIX);
        }

        this.setCoveredByAccount(this.rule.coveredBy);
        this.setWhatToCheck();
        this.setResolutionValues();
        this.setRenderAccountFields();
    }

    getResolutionMethodLabel (resolutionMethodValue) {
        let resolutionMethodLabel = '';
        const resolutionMethodOption = this.resolutionFieldOptions.find(item =>
            item.value === resolutionMethodValue
        );

        if (resolutionMethodOption) {
            resolutionMethodLabel = resolutionMethodOption.label;
        }

        return resolutionMethodLabel;
    }

    getAccountFieldLabel (accountAPIName) {
        let accountFieldLabel = '';
        const fieldOption = this.accountFields.find( item => item.value === accountAPIName);

        if (fieldOption) {
            accountFieldLabel = fieldOption.label;
        }

        return accountFieldLabel;
    }

    getAssetFieldLabel (assetAPIName) {
        let assetFieldLabel = '';
        const fieldOption = this.assetFields.find( item => item.value === assetAPIName);

        if (fieldOption) {
            assetFieldLabel = fieldOption.label;
        }

        return assetFieldLabel;
    }

    setLookupFieldOptions (objectFields) {
        const objectFieldsLength = objectFields.length;
        this.accountFields = [];
        this.assetFields = [];
        for (let fieldIndex = 0; fieldIndex < objectFieldsLength; fieldIndex += 1) {
            const fieldConfig = objectFields[fieldIndex];
            const {
                apiName,
                custom,
                dataType,
                label,
                referenceTo,
            } = fieldConfig;

            if (dataType === 'REFERENCE') {
                referenceTo.forEach(lookupObject => {
                    const pickValue = {
                        label,
                        value: apiName
                    };

                    switch (lookupObject) {
                        case 'Account':
                            this.accountFields.push(pickValue);
                            if ( this._actionName === PAGE_ACTION_TYPES.NEW && !custom ) {
                                this.rule.accountAPIName = apiName;
                            }
                            break;
                        case 'Asset':
                            this.assetFields.push(pickValue);
                            if ( this._actionName === PAGE_ACTION_TYPES.NEW && !custom ) {
                                this.rule.assetAPIName = apiName;
                            }
                            break;
                        default:
                            break;
                    }
                });
            }
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

    clearState () {
        this.error = null;
        this.objectName = null;
        this.rule = new ruleModel(null, null);
        this._ruleRecord = null;
        this._recordId = null;
        this._actionName = null;
        this._objectDefintion = null;
        this.editMode = false;
        this.apiInProgress = false;
        this.resolutionMethodLabel = null;
        this.selectedAccountLabel = null;
        this.selectedAssetLabel = null;
    }


    getRuleActiveToggle () {
        return this.template.querySelector('.ruleActiveToggle');
    }

    setRuleActive () {
        const ruleRecord = this.rule;
        if (ruleRecord) {
            return ruleRecord.ruleActive;
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
                name: "automatic_rules",
                targetType: "LWC",
                targetDeveloperName: "c-automatic-rules"
            }
        }, this);
    }

    handleRuleActiveCheck (event) {
        this.rule.isActive = event.target.checked;
    }

    handleAccOnCaseCheck (event) {
        this.rule.matchAccount = event.target.checked;
        this.setRenderAccountFields();
    }

    setRenderAccountFields () {
        this.renderAccountFields = false;
        if (this.rule.matchAccount) {
            this.renderAccountFields = true;
        }
    }

    setResolutionValues () {
        this.resolutionMethodOptions = [];
        this.resolutionFieldOptions.forEach(pickvalue => {
            const pickOption = this.filterResolutionValues(pickvalue);
            if (pickOption) {
                this.resolutionMethodOptions.push(pickOption);
            }
        });
    }

    setWhatToCheck () {
        const whatToCheckValues = this.rule.whatToCheck || [];
        this.warrantyChecked = false;
        this.contractChecked = false;
        if (whatToCheckValues.includes('warranty')) {
            this.warrantyChecked = true;
        }
        if (whatToCheckValues.includes('contract')) {
            this.contractChecked = true;
        }
    }

    getDeveloperNameInput () {
        return this.template.querySelector('[data-field="developerName"]');
    }

    filterResolutionValues (pickvalue) {
        const whatToCheckValues = this.rule.whatToCheck || [];
        if (whatToCheckValues.includes('warranty') && whatToCheckValues.includes('contract')
            || (whatToCheckValues.includes('warranty') && pickvalue.value !== 'USE-CONTRACT')
            || (whatToCheckValues.includes('contract') && pickvalue.value !== 'USE-WARRANTY')) {
            return pickvalue;
        }
        return null;
    }

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.rule[event.currentTarget.dataset.field] = inputVal;
    }

    handleWhatTocheck (event) {
        this.rule.whatToCheck = event.detail.value;
        this.rule.resolutionMethod = null;
        this.setWhatToCheck();
        this.setResolutionValues();
    }

    handleParentAssetCheck (event) {
        this.rule.includeParentAsset = event.target.checked;
    }

    handleRootAssetCheck (event) {
        this.rule.includeRootAsset = event.target.checked;
    }

    handleCoveredByChange (event) {
        const selectedValue = event.detail.value;
        this.rule.coveredBy = selectedValue;
        this.setCoveredByAccount(selectedValue);
    }

    handleWarrantyTypeChange (event) {
        const selectedValue = event.detail.value;
        this.rule.warrantyTypes = selectedValue;
    }

    handleDefaultBillingTypeChange (event) {
        const selectedValue = event.detail.value;
        this.rule.defaultBillingType = selectedValue;
    }

    setCoveredByAccount (selectedValue) {
        this.isCoveredByAccount = false;
        if (selectedValue === 'Account') {
            this.isCoveredByAccount = true;
        }
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
            this.mapRuleData(this._ruleRecord, this._objectDefintion);
            this.editMode = false;
        }
    }

    handleSave () {
        const allValid = [...this.template.querySelectorAll('[data-field]')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        const expressionBuilder = this.template.querySelector('.svmx-expression-builder');

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
        expressionData.type = TYPE;
        recordToSave.expression = expressionData;

        this.error = null;
        this.apiInProgress = true;

        saveEntitlementRule({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showSaveSuccessNotification(this.rule.name);

                if (!this.rule.id) {
                    this.navigateToDetailComponent(result.data, PAGE_ACTION_TYPES.VIEW);
                } else {
                    this.mapRuleData(result.data, this._objectDefintion);
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
            title: `${this.i18n.automaticRule} "${ruleName}" ${this.i18n.wasSaved}`,
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

        const detailRef = Object.assign({}, ENTITLEMENT_RULE_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    toggleEdit (e) {
        if (e) {
            e.stopPropagation();
        }
        this.editMode = !this.editMode;
    }
}