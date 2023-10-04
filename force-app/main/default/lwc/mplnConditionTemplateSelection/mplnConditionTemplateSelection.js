import { LightningElement, api, wire } from 'lwc';
import { formatString, parseErrorMessage, isNotUndefinedOrNull, isUndefinedOrNull } from 'c/utils';
import labelMaintenancePlanDetail from '@salesforce/label/c.Label_MaintenancePlanDetail';
import labelNextButton from '@salesforce/label/c.Button_Next';
import labelMessage_ReviewError from '@salesforce/label/c.Message_ReviewError';

import A360MAINTENANCEPLAN_OBJECT from '@salesforce/schema/SM_MaintenancePlan__c';

import { getRecord } from 'lightning/uiRecordApi';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import MPLANTEMPDURATION_FIELD
    from '@salesforce/schema/MaintenancePlanTemplate__c.MaintenancePlanDuration__c';
import MPLANTEMPUNIT_FIELD
    from '@salesforce/schema/MaintenancePlanTemplate__c.MaintenancePlanUnitOfTime__c';
import MPLANTEMPPROCESS_FIELD
    from '@salesforce/schema/MaintenancePlanTemplate__c.MaintenancePlanProcessId__c';

import getAllLocationRelatedAccounts
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getLocationAccounts';
import calculateEnddate
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.calculateEndDate';


const i18n = {
    title: labelMaintenancePlanDetail,
    next: labelNextButton,
    reviewError: labelMessage_ReviewError
}

const MPLANTEMPLATE_FIELDS = [
    MPLANTEMPDURATION_FIELD,
    MPLANTEMPUNIT_FIELD,
    MPLANTEMPPROCESS_FIELD
]
const LOCATION = 'Location';
const ACCOUNT = 'Account';
const ASSET = 'Asset';
const SERVICE_CONTRACT = 'ServiceContract';
export default class MplnConditionTemplateSelection extends LightningElement {
    @api recordId;
    @api maintenancePlanRecord;

    renderLocationAPI;
    renderAccountAPI;
    renderAssetAPI;
    renderSContractAPI;
    mplanTemplateTitle;
    accountIds = [];
    isDataRetrieved = false;
    hasFormError = false;
    objectApiName;
    error;
    mPlanTemplateRecordId;
    mPlanTemplateRecord = {};
    locationName;
    accountName;
    serviceContractName;
    isLookupDataDeleted = true;

    get i18n () {
        return i18n;
    }

    get popoverErrorMessages () {
        const errorMessages = [];
        const errorMessage = i18n.reviewError;
        if (this.hasFormError) {
            errorMessages.push(formatString(errorMessage));
        }
        return errorMessages.map(message => ({ message }));
    }

    @wire(getObjectInfo , { objectApiName: A360MAINTENANCEPLAN_OBJECT })
    getMaintenancePlanInfo ({ error, data }) {
        if (data) {
            // get all the field label
            this.i18n.labelMplanTitle = data.fields.Name.label;
            this.i18n.labelMplanTemplate
                = data.fields.SVMXA360__MaintenancePlanTemplate__c.label;
            this.i18n.labelAccount = data.fields.SVMXA360__Account__c.label;
            this.i18n.labelServiceContract = data.fields.SVMXA360__ServiceContract__c.label;
            this.i18n.labelLocation = data.fields.SVMXA360__Location__c.label;
            this.i18n.labelStartDate = data.fields.SVMXA360__StartDate__c.label;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getRecord,  { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View']} )
    sourceRecord ({ data, error }) {
        if (data) {
            this.objectApiName = data.apiName;
            if ( this.objectApiName === LOCATION ) {
                this.renderLocationAPI = true;
                if ( data.fields.Name ) {
                    this.locationName = data.fields.Name.value;
                }
                this.maintenancePlanRecord.SVMXA360__Location__c = this.recordId;
            } else if ( this.objectApiName === ACCOUNT ) {
                this.renderAccountAPI = true;
                if ( data.fields.Name ) {
                    this.accountName = data.fields.Name.value;
                }
                this.maintenancePlanRecord.SVMXA360__Account__c = this.recordId;
            } else if ( this.objectApiName === ASSET ) {
                if ( data.fields.Location && data.fields.Location.value ) {
                    this.locationName = data.fields.Location.value.fields.Name.value;
                    this.maintenancePlanRecord.SVMXA360__Location__c =
                    data.fields.Location.value.fields.Id.value;
                }
                if ( data.fields.Account && data.fields.Account.value ) {
                    this.accountName = data.fields.Account.value.fields.Name.value;
                    this.maintenancePlanRecord.SVMXA360__Account__c =
                    data.fields.Account.value.fields.Id.value;
                }
                this.renderAssetAPI = true;
            } else if ( this.objectApiName === SERVICE_CONTRACT ) {
                this.renderSContractAPI = true;
                if ( data.fields.Name ) {
                    this.serviceContractName = data.fields.Name.value;
                }
                if ( data.fields.Account && data.fields.Account.value ) {
                    this.maintenancePlanRecord.SVMXA360__Account__c =
                    data.fields.Account.value.fields.Id.value;
                }
                this.maintenancePlanRecord.SVMXA360__ServiceContract__c = this.recordId;
            }
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getRecord,  { recordId: '$mPlanTemplateRecordId', fields: MPLANTEMPLATE_FIELDS } )
    mplanRecord ({ data, error }) {
        if (data && data.apiName === 'SVMXA360__MaintenancePlanTemplate__c') {
            this.mPlanTemplateRecord.SVMXA360__MaintenancePlanDuration__c
             = data.fields.SVMXA360__MaintenancePlanDuration__c.value;
            this.mPlanTemplateRecord.SVMXA360__MaintenancePlanUnitOfTime__c
             = data.fields.SVMXA360__MaintenancePlanUnitOfTime__c.value;
            this.maintenancePlanRecord.SVMXA360__MaintenancePlanProcessId__c
             = data.fields.SVMXA360__MaintenancePlanProcessId__c.value;
            if (this.maintenancePlanRecord.SVMXA360__StartDate__c
                && isNotUndefinedOrNull(data.fields.SVMXA360__MaintenancePlanDuration__c.value)
                && isNotUndefinedOrNull(data.fields.SVMXA360__MaintenancePlanUnitOfTime__c.value)) {
                this.calculateEnddate(this.maintenancePlanRecord.SVMXA360__StartDate__c,
                    data.fields.SVMXA360__MaintenancePlanDuration__c.value,
                    data.fields.SVMXA360__MaintenancePlanUnitOfTime__c.value);
            }
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    connectedCallback () {
        if (this.maintenancePlanRecord) {
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.maintenancePlanRecord = { ...this.maintenancePlanRecord };
        } else {
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.maintenancePlanRecord = {};
        }
    }

    async calculateEnddate (startdate, duration, unitoftime) {
        const { data } = await calculateEnddate({
            startDate: startdate, duration: duration, unitOfTime: unitoftime });
        this.maintenancePlanRecord.SVMXA360__EndDate__c = new Date(data);
    }

    async getLocationRelatedAccounts () {
        const { data } = await getAllLocationRelatedAccounts({
            locationId: this.recordId });
        this.accountIds = data;
        this.isDataRetrieved = true;
    }

    handleFieldChange (event) {
        const targetElement = event.target;
        if ( targetElement.dataset.fieldname !== undefined ) {
            this.maintenancePlanRecord[targetElement.dataset.fieldname] = targetElement.value;
            if ( targetElement.dataset.fieldname === 'SVMXA360__MaintenancePlanTemplate__c') {
                this.mPlanTemplateRecordId = targetElement.value;
                this.isLookupDataDeleted = true;
                this.maintenancePlanRecord.SVMXA360__EndDate__c = null;
            } else if ( targetElement.dataset.fieldname === 'SVMXA360__StartDate__c'
             && this.mPlanTemplateRecordId
             && this.mPlanTemplateRecord.SVMXA360__MaintenancePlanDuration__c
             && this.mPlanTemplateRecord.SVMXA360__MaintenancePlanUnitOfTime__c) {
                this.maintenancePlanRecord.SVMXA360__EndDate__c = null;
                const startDate = this.maintenancePlanRecord.SVMXA360__StartDate__c;
                this.calculateEnddate(startDate,
                    this.mPlanTemplateRecord.SVMXA360__MaintenancePlanDuration__c,
                    this.mPlanTemplateRecord.SVMXA360__MaintenancePlanUnitOfTime__c);
                    this.maintenancePlanRecord.SVMXA360__StartDate__c = new Date(startDate);
            }
        }
    }

    accountWhereClause () {
        if (!this.isDataRetrieved) {
            this.getLocationRelatedAccounts();
        }
        if (this.accountIds && this.accountIds.length > 0) {
            const mappedAccountIdList = this.accountIds.map(item => (`'${item}'`));
            const acc = mappedAccountIdList.join(',');
            return `ID IN (${acc})`;
        }
        return `ID = '${this.recordId}'`;
    }

    idsWhereClause () {
        if (this.recordId) {
            return `Id='${this.recordId}'`;
        }
        return '';
    }

    handleLookupError (event) {
        const error = event.detail;
        const targetElement = event.target;
        if ( isNotUndefinedOrNull(targetElement.dataset.fieldname) ) {
            if ( targetElement.dataset.fieldname === 'SVMXA360__MaintenancePlanTemplate__c' ) {
                this.maintenancePlanRecord.SVMXA360__MaintenancePlanTemplate__c = '';
            }
            this.error = `${parseErrorMessage(error) } : ${event.target.label}`;
        }
        event.stopPropagation();
    }

    get accountFilter () {
        if ( this.objectApiName === LOCATION ) {
            return this.accountWhereClause();
        } else if ( this.objectApiName === ACCOUNT ) {
            return this.idsWhereClause();
        }
        return '';
    }

    get mplanTemplateFilter () {
        return `SVMXA360__IsActive__c= true AND RecordType.DeveloperName = 'Asset360'`;
    }
    // on click next validation
    handleNext () {
        if (this.isAllFieldValid() && this.isLookupDataDeleted) {
            this.hasFormError = false;
            if ( isUndefinedOrNull(this.maintenancePlanRecord.SVMXA360__EndDate__c) &&
             isNotUndefinedOrNull(this.mPlanTemplateRecord.SVMXA360__MaintenancePlanDuration__c) &&
             isNotUndefinedOrNull(
                 this.mPlanTemplateRecord.SVMXA360__MaintenancePlanUnitOfTime__c)) {
                this.calculateEnddate(this.maintenancePlanRecord.SVMXA360__StartDate__c,
                    this.mPlanTemplateRecord.SVMXA360__MaintenancePlanDuration__c,
                    this.mPlanTemplateRecord.SVMXA360__MaintenancePlanUnitOfTime__c).then(() => {
                    this.navigateFlowNext();
                });
            } else if ( isNotUndefinedOrNull(this.maintenancePlanRecord.SVMXA360__EndDate__c) ) {
                this.navigateFlowNext();
            } else if (isUndefinedOrNull(this.maintenancePlanRecord.SVMXA360__EndDate__c) &&
            isUndefinedOrNull(this.mPlanTemplateRecord.SVMXA360__MaintenancePlanDuration__c) &&
             isUndefinedOrNull(this.mPlanTemplateRecord.SVMXA360__MaintenancePlanUnitOfTime__c)) {
                this.maintenancePlanRecord.SVMXA360__EndDate__c = null;
                this.navigateFlowNext();
            }
        } else {
            this.hasFormError = true;
        }
    }

    isAllFieldValid () {
        const isInputsCorrect = [...this.template.querySelectorAll('.inputfield')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        return isInputsCorrect;
    }

    //Navigate to next flow screen
    navigateFlowNext () {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}