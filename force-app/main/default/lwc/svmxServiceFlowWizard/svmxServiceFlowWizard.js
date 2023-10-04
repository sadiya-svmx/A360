/* eslint-disable max-len */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { SvmxExpressionValidator } from 'c/svmxExpressionValidator';
import {  CurrentPageReference } from 'lightning/navigation';
import {
    FIELD_DATA_TYPES,
    parseErrorMessage,
    STEP_TYPES,
    ICON_NAMES,
    IS_MOBILE_DEVICE,
    convertToQualifiedFieldFormat,
    getNameFieldsWithPreferredFirst,
    getUiRecordName
} from 'c/utils';
import getAllActiveWizards
    from '@salesforce/apex/ADM_ProcessWizardLightningService.getActiveProcessWizardDetailsByObject';
import getAllActiveExpressions
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionsWithDetails';
import getObjectAPIName
    from '@salesforce/apex/COMM_DatabaseUtils.getObjectAPIFromRecordId';
import getUsageTracking
    from '@salesforce/apex/ADM_ProcessWizardComponent_LS.getApplicationUsageTracker';
import getWizardStepUsageLog
    from '@salesforce/apex/COMM_ProcessWizardService_LS.getStepUsageLogBySourceRecordId';
import { getFieldDefinitionsForEntities } from 'c/metadataService';
import { normalizeBoolean } from 'c/utils';
import { refreshApex } from '@salesforce/apex';

import desktopTemplate from './svmxServiceFlowWizard.html';
import mobileTemplate from './svmxServiceFlowWizardMobile.html';

import lblShowMore from '@salesforce/label/c.Link_ShowMore';
import lblShowLess from '@salesforce/label/c.Link_ShowLess';
import titlesfm from '@salesforce/label/c.Title_WizardRuntime';
import messageQCNotValid from '@salesforce/label/c.Message_QCNotValid';
import messageNoServiceWizard from '@salesforce/label/c.Message_NoServiceWizardFound';
import fieldAccessErrorMessage from '@salesforce/label/c.ERROR_NoAccessToField';
import USER_ID from "@salesforce/user/Id";

const i18n = {
    lblShowMore: lblShowMore,
    lblShowLess: lblShowLess,
    titlesfm: titlesfm,
    messageQCNotValid: messageQCNotValid,
    messageNoServiceWizard: messageNoServiceWizard,
    fieldAccessErrorMessage: fieldAccessErrorMessage
};
export default class SvmxServiceFlowWizard extends LightningElement {
    @track fields = [];
    @track wizards = [];
    @track filteredWizardView = [];
    @track displayMore = i18n.lblShowMore;
    @track iconMore = 'utility:jump_to_bottom';
    @track title = i18n.titlesfm;
    @track showDisplayMore = false;
    @track toggleDisplay = false;
    @track objRec;
    objectDefinition;
    objectNameFields;
    recordName;
    @track expressions = [];
    @track wizardAvailable = true;
    @track isDataRefreshed = false;
    @track dynamicHeight = false;
    @track _objectApiName;
    @track currentPageRef;
    @track fieldSchema = {};
    @track userFieldSchema = {};
    @track error = [];
    @track multilevelField=[];
    @track userFields = [];
    @track userRec;
    @track userId = USER_ID;
    @track isTrackingOn;
    @track stepUsageLog = [];
    @track stepUsageResult;
    @track isExpressionAvailable = false;
    @track isExpressionRetrive = false;
    validator = new SvmxExpressionValidator();
    @api recordId;
    @api showIcons;

    @api maxHeight;
    @api flexipageRegionWidth;

    _isInCommunity = false;
    _refreshWizardSteps = false;
    _expandedSections = [];

    @api
    get isInCommunity () {
        return this._isInCommunity;
    }

    set isInCommunity (value) {
        if (value !== this._isInCommunity) {
            this._isInCommunity = normalizeBoolean(value);
        }
    }
    @api
    get objectApiName () {
        return this._objectApiName;
    }

    set objectApiName (value) {
        this._objectApiName = value;
    }

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    get wizardIconName () {
        return ICON_NAMES.SPMWIZARD;
    }

    get hasFieldAccessError () {
        return this.error.length > 0 ;
    }

    get activeSections () {
        if (this._expandedSections.length === 0) {
            this._expandedSections = this.filteredWizardView.map(wizard=>wizard.name);
        }
        return this._expandedSections;
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$fields',
        optionalFields: '$objectNameFields'
    })
    assetRec ({ error, data }) {
        if (data) {
            this.objRec = data;
            this.populateRecordName();
            this.populateWizard();
        }

        if (error) {
            this.processRecordAccessError (error);
        }
    }

    @wire(getObjectInfo, {
        objectApiName: '$objectApiName'
    })
    handleContextObjectInfo ({ error, data }) {
        if (data) {
            this.objectDefinition = data;
            this.objectNameFields = convertToQualifiedFieldFormat(
                this.objectDefinition.apiName,
                getNameFieldsWithPreferredFirst(
                    Array.isArray(data.nameFields) ? data.nameFields : [data.nameFields]
                )
            );
            this.populateRecordName();
        }

        if (error) {
            this.processRecordAccessError(error);
        }
    }

    @wire(getRecord, {
        recordId: '$userId',
        fields: '$userFields'
    })
    userInfo ({ error, data }) {
        if (data) {
            this.userRec = data;
            this.populateWizard();
        }
        if (error) {
            this.processRecordAccessError (error);
        }
    }

    @wire(CurrentPageReference)
    currPageRef (pageref) {
        if (pageref && this.recordId) {
            this.currentPageRef = pageref;
            if (this.isInCommunity) {
                getRecordNotifyChange([{ recordId: this.recordId }]);
            } else {
                // eslint-disable-next-line no-eval
                this.dispatchEvent(
                    new CustomEvent('refreshview', {
                        composed: true,
                        bubbles: true,
                    })
                );
            }
        }
    }

    @wire(getUsageTracking)
    getUsageTracking ({ error, data }) {
        if (data) {
            this.isTrackingOn = data?.data?.value === 'true' ? true : false;
        } else if (error) {
            this.isTrackingOn = false;
        }
    }

    @wire(getWizardStepUsageLog, { sourceRecordId: '$recordId' })
    wizardStepUsageLog ( response ) {
        this.stepUsageResult = response;
        const { data, error } = response;
        if (data) {
            this.stepUsageLog = this.stepUsageResult.data;
            this.refreshWizardLog();
        }
        if (error) {
            this.processRecordAccessError (error);
        }
    }

    async refreshWizardLog () {
        this._refreshWizardSteps = false;
        await refreshApex(this.stepUsageResult);
        this.populateWizard();
    }

    processRecordAccessError (error) {
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            if (error.body.errorCode ==='INVALID_FIELD') {
                this.multilevelField.forEach(fieldApiName =>{
                    const fieldArr = fieldApiName.split(".");
                    if (fieldArr.length >= 2) {
                        if (error.body.message.indexOf(fieldApiName) > -1) {
                            this.error.push(`${this.objectApiName}.${fieldApiName}`);
                        } else {
                            fieldArr.forEach((field,index)=>{
                                if (index !== fieldArr.length-1 && index !== 0) {
                                    if (error.body.message.indexOf(field) > -1 ) {
                                        if (field.endsWith('__r')) {
                                            this.error.push(
                                                `${this.objectApiName}.${fieldApiName}`
                                            );
                                        } else {
                                            const fieldn = fieldArr.splice(0,index+1).join(".");
                                            if (error.body.message.indexOf(fieldn)>-1) {
                                                this.error.push(`${this.objectApiName}.${fieldApiName}`);
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                });
            } else {
                this.error = error.body.message;
            }
        }
    }

    connectedCallback () {
        if (this.isInCommunity) {
            getObjectAPIName({ objectId: this.recordId })
                .then(result => {
                    if (result && result.data) {
                        this._objectApiName = result.data;
                        this.getFieldDefinition();
                        this.dynamicHeight = this.maxHeight;
                    }
                });
        } else {
            this.getFieldDefinition();
            this.dynamicHeight = this.maxHeight;
        }
    }

    async getFieldDefinition () {
        try {
            const resp = await getFieldDefinitionsForEntities([this.objectApiName, 'User']);
            if (resp && resp.data
                && Object.keys(resp.data).length > 0) {
                resp.data.forEach(item => {
                    const isUserObj = item?.apiName === 'User';
                    if (item.fieldDefinitions) {
                        item.fieldDefinitions.forEach(fieldDefinition => {
                            if (isUserObj) {
                                this.userFieldSchema[fieldDefinition.apiName] = fieldDefinition;
                            } else {
                                this.fieldSchema[fieldDefinition.apiName] = fieldDefinition;
                            }
                        });
                    }
                });
                this.fetchAllActiveWizards();
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    get i18n () {
        return i18n;
    }

    renderedCallback () {
        if (this.displayMore !== i18n.lblShowLess || this.isDataRefreshed) {
            const element = this.template.querySelector('[data-id="sfmBody"]');
            this.showDisplayMore =
                element && element.offsetHeight <= element.scrollHeight;
            if (this.isDataRefreshed && !this.showDisplayMore) {
                this.displayMore = i18n.lblShowMore;
                this.iconMore = 'utility:jump_to_bottom';
                this.dynamicHeight = this.maxHeight;
            }
            this.isDataRefreshed = false;
        }
        if (this._refreshWizardSteps) {
            this.refreshWizardLog();
        }
    }

    fetchAllActiveWizards () {
        const wizardObj = {
            active: null,
            description: null,
            developerName: null,
            id: null,
            lastModifiedDate: null,
            lastModifiedBy: null,
            name: null,
            scope: null,
            sequence: null,
            expressionId: null,
            expressionName: null,
            referenceId: null,
            steps: null,
            access: null,
            isVisible: null,
            objectAPIName: this.objectApiName
        };
        const wizardJson = JSON.stringify(wizardObj);
        getAllActiveWizards({ requestJson: wizardJson }).then(result => {
            if (result.data) {
                this.wizards = result.data;
                const expressionIds = new Set();
                const fieldset = new Set();
                const userFieldSet = new Set();
                this.wizards.forEach(wizard => {
                    if (wizard.expressionId) {
                        expressionIds.add(wizard.expressionId);
                    }
                    if (wizard.steps && Array.isArray(wizard.steps)) {
                        wizard.steps.forEach(wizardItem => {
                            if (wizardItem.expressionId) {
                                expressionIds.add(wizardItem.expressionId);
                            }
                            if (wizardItem.stepParameters ) {
                                wizardItem.stepParameters.forEach(param =>{
                                    if (param.valueType ==='Field' ) {
                                        if ((this.fieldSchema
                                            && this.fieldSchema[param.parameterValue])
                                            || !this.fieldSchema) {
                                            fieldset.add(`${this.objectApiName}.${param.parameterValue}`);
                                        } else {
                                            this.error.push(`${this.objectApiName}.${param.parameterValue}`);
                                        }
                                    }
                                });
                            }

                            if (wizardItem.type === STEP_TYPES.URL) {
                                const urlPathKeys = wizardItem.target.match(/{\w*\.?\w*}/gm);
                                if (urlPathKeys && urlPathKeys.length >0) {
                                    urlPathKeys.forEach(field =>{
                                        const fieldApiName = field.replace('{','').replace('}','');
                                        if ((this.fieldSchema
                                            && this.fieldSchema[fieldApiName])
                                            || !this.fieldSchema) {
                                            fieldset.add(`${this.objectApiName}.${fieldApiName}`);
                                        } else {
                                            this.error.push(`${this.objectApiName}.${fieldApiName}`);
                                        }
                                    });
                                }
                            }
                        });
                    }
                });

                if (expressionIds.size > 0) {
                    this.isExpressionAvailable = true;
                    getAllActiveExpressions({
                        expressionIds: [...expressionIds],
                        objectAPIName: this.objectApiName
                    }).then(result2 => {
                        this.expressions = result2.data;
                        this.isExpressionRetrive = true;
                        Object.keys(result2.data).forEach(key => {
                            const expression = result2.data[key];
                            if (expression.expressionDetailList) {
                                expression.expressionDetailList.forEach(
                                    detail => {
                                        const userLiteralCheck = detail?.operandType?.toLowerCase() === 'function'
                                                                    && detail?.operand?.toLowerCase() === 'user';
                                        if (detail.operator) {
                                            if (detail.fieldType === FIELD_DATA_TYPES.REFERENCE &&
                                                !userLiteralCheck) {
                                                if (detail.relationshipName && detail.relationshipFieldAPIName) {
                                                    if (detail.sourceObjectName && detail.sourceObjectName.toLowerCase() === 'user') {
                                                        userFieldSet.add(`${detail.sourceObjectName}.${detail.relationshipName}.${detail.relationshipFieldAPIName}`);
                                                        this.multilevelField.push(`${detail?.sourceObjectName}.${detail.relationshipName}.${detail.relationshipFieldAPIName}`);
                                                    } else {
                                                        fieldset.add(`${this.objectApiName}.${detail.relationshipName}.${detail.relationshipFieldAPIName}`);
                                                        this.multilevelField.push(`${this.objectApiName}.${detail.relationshipName}.${detail.relationshipFieldAPIName}`);
                                                    }
                                                }
                                            } else if (detail.fieldAPIName) {
                                                if (detail.sourceObjectName && detail.sourceObjectName.toLowerCase() === 'user') {
                                                    if ((this.userFieldSchema
                                                        && this.userFieldSchema[detail.fieldAPIName])
                                                        || !this.userFieldSchema
                                                        || detail.fieldAPIName.includes(".")) {
                                                        userFieldSet.add(`${detail.sourceObjectName}.${detail.fieldAPIName}`);
                                                        if (detail.fieldAPIName.includes(".")) {
                                                            this.multilevelField.push(detail.fieldAPIName);
                                                        }
                                                    } else {
                                                        this.error.push(`${detail.sourceObjectName}.${detail.fieldAPIName}`);
                                                    }
                                                } else {
                                                    if ((this.fieldSchema
                                                        && this.fieldSchema[detail.fieldAPIName])
                                                        || !this.fieldSchema
                                                        || detail.fieldAPIName.includes(".")) {
                                                        fieldset.add(`${this.objectApiName}.${detail.fieldAPIName}`);
                                                        if (detail.fieldAPIName.includes(".")) {
                                                            this.multilevelField
                                                                .push(detail.fieldAPIName);
                                                        }
                                                    } else {
                                                        this.error.push(`${this.objectApiName}.${detail.fieldAPIName}`);
                                                    }
                                                }
                                            }
                                        }
                                        if (userLiteralCheck) {
                                            if ((this.userFieldSchema
                                                && this.userFieldSchema[detail.literalParameterAPIName])
                                                || !this.userFieldSchema
                                                || detail.literalParameterAPIName.includes(".")) {
                                                userFieldSet.add(`${detail.operand}.${detail.literalParameterAPIName}`);
                                                if (detail.literalParameterAPIName.includes(".")) {
                                                    this.multilevelField
                                                        .push(detail.literalParameterAPIName);
                                                }
                                            } else {
                                                this.error.push(`${detail.operand}.${detail.literalParameterAPIName}`);
                                            }
                                        }
                                    }
                                );
                            }
                        });
                        this.validator.loadExpressions(this.expressions);
                        if (fieldset.size > 0) {
                            if (userFieldSet.size > 0) {
                                this.userFields = [...userFieldSet];
                            }
                            this.fields = [...fieldset];
                        } else if (fieldset.size === 0 && userFieldSet.size > 0) {
                            this.userFields = [...userFieldSet];
                        } else {
                            this.populateWizard();
                        }
                    });
                } else if (fieldset.size > 0) {
                    if (userFieldSet.size > 0) {
                        this.userFields = [...userFieldSet];
                    }
                    this.fields = [...fieldset];
                } else if (fieldset.size === 0 && userFieldSet.size > 0) {
                    this.userFields = [...userFieldSet];
                } else {
                    this.populateWizard();
                }
            }
        });
    }

    handleClick (event) {
        event.preventDefault();
        if (this.displayMore === i18n.lblShowMore) {
            this.displayMore = i18n.lblShowLess;
            this.iconMore = 'utility:jump_to_top';
            this.dynamicHeight = '';
        } else {
            this.displayMore = i18n.lblShowMore;
            this.iconMore = 'utility:jump_to_bottom';
            this.dynamicHeight = this.maxHeight;
        }
    }

    populateWizard () {
        const userDataCheck = this.userFields.length === 0 || (this.userFields.length > 0 && this.userRec);
        const objDataCheck = this.fields.length === 0 || (this.fields.length > 0 && this.objRec);
        if (this.wizards && this.expressions && userDataCheck && objDataCheck &&
            ((this.isExpressionAvailable && this.isExpressionRetrive) || !this.isExpressionAvailable)) {
            this.filteredWizardView = [];
            this.wizards.forEach(wizard => {
                const expressionDecision = wizard.expressionId
                    ? this.validator.validateExpression(
                        this.objRec,
                        wizard.expressionId,
                        this.userRec
                    )
                    : true;
                if (expressionDecision == null || expressionDecision === true) {
                    const filteredWizard = JSON.parse(JSON.stringify(wizard));
                    if (expressionDecision == null
                        || typeof expressionDecision !== 'boolean') {
                        filteredWizard.showQCError = true;
                    } else {
                        filteredWizard.showQCError = false;
                    }
                    if (filteredWizard.steps) {
                        let visibleWizardsCount = 0;
                        filteredWizard.steps.forEach(wizardItem => {
                            if (filteredWizard.showQCError) {
                                wizardItem.isVisible = false;
                                wizardItem.showQCError = true;
                            } else {
                                wizardItem.showQCError = wizard.showQCError;
                                wizardItem.isVisible = wizardItem.expressionId
                                    ? this.validator.validateExpression(
                                        this.objRec,
                                        wizardItem.expressionId,
                                        this.userRec
                                    )
                                    : true;

                                if (wizardItem.isVisible == null
                                    || typeof wizardItem.isVisible !== 'boolean') {
                                    wizardItem.isVisible = false;
                                    wizardItem.showQCError = true;
                                }
                                if (wizardItem.stepParameters ) {
                                    wizardItem.stepParameters.forEach(param =>{
                                        if (param.valueType ==='Field' ) {
                                            if (!((this.fieldSchema
                                            && this.fieldSchema[param.parameterValue])
                                            || !this.fieldSchema)) {
                                                wizardItem.showQCError = true;
                                                wizardItem.isVisible = false;
                                            }
                                        }
                                    });
                                }

                                if (filteredWizard.stepDependencyType === 'Checklist') {
                                    const stepUsageData = this.stepUsageLog.data;
                                    if (wizardItem.dependentSteps) {
                                        wizardItem.dependentSteps.forEach(depStep => {
                                            const depStepId = depStep?.dependentStepId;
                                            if (stepUsageData && !stepUsageData.some(step => step.stepId === depStepId)) {
                                                wizardItem.pendingDependentSteps = true;
                                            }
                                        });
                                    }
                                    if (stepUsageData && stepUsageData.some(step => step.stepId === wizardItem.id)) {
                                        wizardItem.stepCompleted = true;
                                    }
                                }
                                if (this.isInCommunity) {
                                    wizardItem.openAsModal = true;
                                }
                            }
                            if (wizardItem.showQCError) {
                                wizardItem.iconName = 'utility:error';
                                if (wizardItem.name.length > 30) {
                                    wizardItem.name = `${wizardItem.name.substring(0,30)}...`;
                                }
                            }
                            if (wizardItem.isVisible
                                || wizardItem.criteriaAction === 'Disable Step'
                                || wizardItem.showQCError) {
                                visibleWizardsCount ++;
                            }
                        });
                        if (visibleWizardsCount > 0) {
                            this.filteredWizardView.push(filteredWizard);
                        }
                    }
                }
            });
            this.wizardAvailable = this.filteredWizardView.length > 0;
            this.isDataRefreshed = true;
        }
    }

    populateRecordName () {
        if (this.objRec && this.objectDefinition) {
            const nameFieldValues = getUiRecordName(this.objRec, this.objectDefinition);
            if (nameFieldValues?.length) {
                this.recordName = nameFieldValues.join(' • ');
            }
        }
    }

    handleActionLaunch (event) {
        const eventmsg = event.detail;
        if (eventmsg && eventmsg.c__objectRecordId && eventmsg.c__actionName) {
            this._refreshWizardSteps = true;
            const selectedEvent = new CustomEvent('launchaction', { detail: { eventmsg }});
            this.dispatchEvent(selectedEvent);
        }
    }

    async handleCompletionStatusChange () {
        await refreshApex(this.stepUsageResult);
        this.populateWizard();
    }

    handleBackClick () {
        this.dispatchEvent(new CustomEvent('closeaction'));
    }
}