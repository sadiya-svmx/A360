import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import saveEntitledServicePlan
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.saveEntitledServicePlan';

import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    PAGE_ACTION_TYPES
} from 'c/utils';

//Get objinfo from EntitledServicePlan object
import ENTITLED_SERVICE_PLAN__OBJ from '@salesforce/schema/EntitledServicePlan__c';
//Get service unit type info field from entitlement object
import SERVICE_UNIT_FIELD
    from '@salesforce/schema/EntitledServicePlan__c.ServiceUnit__c';
import SERVICE_UNIT_TIME
    from '@salesforce/schema/EntitledServicePlan__c.EntitledServiceUnitOfTime__c'

import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';
import ENTITLEMENT_PROCESS_NAME_FIELD from '@salesforce/schema/SlaProcess.Name';

import CLI_PLAN_NAME_FIELD from '@salesforce/schema/ContractLineItemPlan__c.Name';
import CLI_PLAN_PRODUCT_FIELD from '@salesforce/schema/ContractLineItemPlan__c.ProductId__c';
import CLI_PLAN_PRODUCT_FAMILY_FIELD
    from '@salesforce/schema/ContractLineItemPlan__c.ProductFamily__c';

import labelNewEntitledServicePlan from '@salesforce/label/c.Button_NewServicePlan';
import labelEntitledServicePlanName from '@salesforce/label/c.Label_EntitledServicePlanName';
import labelEntitledService_Product from '@salesforce/label/c.Label_EntitledServiceProduct';
import labelContractLineItemPlan from '@salesforce/label/c.Label_ContractLineItemPlan';
import labelServiceThresholds from '@salesforce/label/c.Label_ServiceThresholds';
import labelServiceUnitOfTime from '@salesforce/label/c.Label_EntitledServiceUnitOfTime';
import labelServiceUnit from '@salesforce/label/c.Label_ServiceUnit';
import labelServiceDuration from '@salesforce/label/c.Label_EntitledServiceDuration';
import labelOperatingHours from '@salesforce/label/c.Label_OperatingHours';
import labelServiceContractPlan from '@salesforce/label/c.Label_ServiceContractPlan';
import labelEntitlementProcesses from '@salesforce/label/c.Label_EntitlementProcesses';
import labelCaseEntitlementProcess from '@salesforce/label/c.Label_Case_EntitlementProcess';
import labelWO_EntitlementProcess from '@salesforce/label/c.Label_WO_EntitlementProcess';
import labelTotalServiceVisit from '@salesforce/label/c.Label_TotalServiceVisit';
import labelVisitAlertThreshold from '@salesforce/label/c.Label_VisitAlertThreshold';
import labelVisitRemaining from '@salesforce/label/c.Label_VisitRemaining';
import labelTotalServiceHours from '@salesforce/label/c.Label_TotalServiceHours';
import labelHoursAlertThreshold from '@salesforce/label/c.Label_HoursAlertThreshold';
import labelHoursRemaining from '@salesforce/label/c.Label_HoursRemaining';
import labelTotalServiceAmount from '@salesforce/label/c.Label_TotalServiceAmount';
import labelAmountAlertThreshold from '@salesforce/label/c.Label_AmountAlertThreshold';
import labelAmountRemaining from '@salesforce/label/c.Label_AmountRemaining';
import labelTotalServiceCredit from '@salesforce/label/c.Label_TotalServiceCredit';
import labelCreditAlertThreshold from '@salesforce/label/c.Label_CreditAlertThreshold';
import labelCreditRemaining from '@salesforce/label/c.Label_CreditRemaining';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelES_CreationMessage from '@salesforce/label/c.Label_ES_CreationMessage';
import labelES_UpdateMessage from '@salesforce/label/c.Label_ES_UpdateMessage';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelSave from '@salesforce/label/c.Button_Save';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelClone from '@salesforce/label/c.Menu_Clone';
import labelSaveAndNew from '@salesforce/label/c.Button_SaveAndNew';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';

const i18n = {
    newEntitledServicePlan: labelNewEntitledServicePlan,
    entitledServicePlanName: labelEntitledServicePlanName,
    serviceContractPlan: labelServiceContractPlan,
    entitledServiceProduct: labelEntitledService_Product,
    contractLineItemPlan: labelContractLineItemPlan,
    serviceThresholds: labelServiceThresholds,
    serviceUnitOfTime: labelServiceUnitOfTime,
    serviceDuration: labelServiceDuration,
    serviceUnit: labelServiceUnit,
    operatingHours: labelOperatingHours,
    entitlementProcesses: labelEntitlementProcesses,
    caseProcess: labelCaseEntitlementProcess,
    workOrderProcess: labelWO_EntitlementProcess,
    totalServiceVisit: labelTotalServiceVisit,
    visitAlertThreshold: labelVisitAlertThreshold,
    visitRemaining: labelVisitRemaining,
    totalServiceHours: labelTotalServiceHours,
    hoursAlertThreshold: labelHoursAlertThreshold,
    hoursRemaining: labelHoursRemaining,
    totalServiceAmount: labelTotalServiceAmount,
    amountAlertThreshold: labelAmountAlertThreshold,
    amountRemaining: labelAmountRemaining,
    totalServiceCredit: labelTotalServiceCredit,
    creditAlertThreshold: labelCreditAlertThreshold,
    creditRemaining: labelCreditRemaining,
    tooLong: labelMaxLength,
    cancel: labelCancel,
    confirm: labelConfirm,
    delete: labelDelete,
    edit: labelEdit,
    save: labelSave,
    valueMissing: labelEnterValue,
    clone: labelClone,
    saveAndNew: labelSaveAndNew,
    reviewError: labelReviewError,
    formValidation: labelFormValidation,
    success: labelSuccess,
    createdMsg: labelES_CreationMessage,
    updatedMsg: labelES_UpdateMessage
}

const MAX_TEXT_LENGTH = 255;
const SERVICE_TYPE_AMOUNT = 'Amount';
const SERVICE_TYPE_VISITS = 'Visits';
const SERVICE_TYPE_HOURS = 'Hours';
const SERVICE_TYPE_CREDITS = 'Credits';

export default class EntitledServicePlanDetail extends LightningElement {
    @track entitledServicePlanModalOpen;

    @track recordInfo = {};
    @track editMode = true;
    @track viewModalOpened = false;
    @track error;
    @track apiInProgress = false;
    @track serviceUnitOptions = [];
    @track serviceUnitTimeOptions = [];

    booleanFalse = false;
    booleanTrue = true;
    productNameField = PRODUCT_NAME_FIELD.fieldApiName;
    contractLineNameField = [
        CLI_PLAN_NAME_FIELD.fieldApiName,
        CLI_PLAN_PRODUCT_FIELD.fieldApiName,
        CLI_PLAN_PRODUCT_FAMILY_FIELD.fieldApiName
    ].join(',');
    entitlementProcessName = ENTITLEMENT_PROCESS_NAME_FIELD.fieldApiName;
    whereClauseCase = "SobjectType = 'Case' and IsActive =true";
    whereClauseWO = "SobjectType = 'WorkOrder' and IsActive =true";
    currencyFormatter = 'currency';
    decimalFormatter = 'decimal';

    @wire(getObjectInfo, { objectApiName: ENTITLED_SERVICE_PLAN__OBJ })
    objectInfo;


    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SERVICE_UNIT_FIELD
    })
    setServiceUnitOptions ({ error, data }) {
        if (data) {
            this.serviceUnitOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SERVICE_UNIT_TIME
    })
    setServiceUnitOfTime ({ error, data }) {
        if (data) {
            this.serviceUnitTimeOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    get i18n () {
        return i18n;
    }

    get tooLongMessage () {
        return formatString(i18n.tooLong, MAX_TEXT_LENGTH);
    }

    get totalServiceLabel () {
        switch (this.recordInfo.serviceUnit) {
            case SERVICE_TYPE_AMOUNT:
                return this.i18n.totalServiceAmount;
            case SERVICE_TYPE_VISITS:
                return this.i18n.totalServiceVisit;
            case SERVICE_TYPE_HOURS:
                return this.i18n.totalServiceHours;
            case SERVICE_TYPE_CREDITS:
                return this.i18n.totalServiceCredit;
            default:
                return '';
        }
    }

    get serviceAlertThresholdLabel () {
        switch (this.recordInfo.serviceUnit) {
            case SERVICE_TYPE_AMOUNT:
                return this.i18n.amountAlertThreshold;
            case SERVICE_TYPE_VISITS:
                return this.i18n.visitAlertThreshold;
            case SERVICE_TYPE_HOURS:
                return this.i18n.hoursAlertThreshold;
            case SERVICE_TYPE_CREDITS:
                return this.i18n.creditAlertThreshold;
            default:
                return '';
        }
    }

    get viewMode () {
        return (!this.editMode);
    }

    get isServiceUnitSection () {
        return (this.recordInfo.serviceUnit);
    }

    get contractLineItemPlanFilter () {
        return this.recordInfo.serviceContractPlanId &&
            `ServiceContractPlanId__c='${this.recordInfo.serviceContractPlanId}'`;
    }

    get formatterType () {
        return (this.recordInfo.serviceUnit === SERVICE_TYPE_AMOUNT) ?
            this.currencyFormatter : this.decimalFormatter;
    }

    @api
    handleNewEntitledServicePlan (recId) {
        this.recordInfo.serviceContractPlanId = recId;
        this.editMode = true;
        this.entitledServicePlanModalOpen = true;
    }

    @api
    handleEditEntitledServicePlan (recordToUpdate, actionName) {
        if (recordToUpdate && actionName === PAGE_ACTION_TYPES.EDIT) {
            this.clearValues();
            this.currentRecordId = recordToUpdate.id;
            this.recordInfo = recordToUpdate;
            this.editMode = true;
            this.entitledServicePlanModalOpen = true;
        }
    }

    handleServiceUnitChange (event) {
        this.recordInfo.serviceUnit = event.detail.value;
        //reset field values in service unit section
        this.recordInfo.totalService = null;
        this.recordInfo.serviceAlertThreshold = null;
    }

    handleLookupFieldChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const { detail, target } = event;

        switch (target.dataset.field) {
            case 'ServiceContractPlan':
                this.recordInfo.serviceContractPlanId = detail.value;
                this.recordInfo.serviceContractPlanName = detail.label;
                break;
            case 'ContractLineItemPlan':
                this.recordInfo.contractLineItemPlanId = detail.value;
                this.recordInfo.contractLineItemPlanName = detail.label;
                break;
            case 'Product':
                this.recordInfo.serviceProductId = detail.value;
                this.recordInfo.serviceProductName = detail.label;
                break;
            case 'OperatingHours':
                this.recordInfo.operatingHoursId = detail.value;
                this.recordInfo.operatingHoursName = detail.label;
                break;
            case 'CaseEntitlement':
                this.recordInfo.caseEntitlementProcessId = detail.value;
                this.recordInfo.caseEntitlementProcessName = detail.label;
                break;
            case 'WOEntitlement':
                this.recordInfo.workOrderEntitlementProcessId = detail.value;
                this.recordInfo.workOrderEntitlementProcessName = detail.label;
                break;
            default:
                break;
        }
    }

    handleChange (event) {
        const targetElement = event.target;
        this.recordInfo[targetElement.dataset.field] = targetElement.value
            ? targetElement.value : null;
    }

    handleSave (event) {
        if (!this.isValidInput()) return;

        if (this.apiInProgress) return;

        const actionName = event.target.dataset.name;
        this.apiInProgress = true;
        saveEntitledServicePlan({ requestJson: JSON.stringify(this.recordInfo) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                //dispatch event to refresh the list view
                this.handleCloseAndRefresh();

                const toastMsg = `${this.recordInfo.id ?
                    this.i18n.updatedMsg : this.i18n.createdMsg} - ${result.data.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleEntitledServicePlanCancel();
                if (actionName === 'saveAndNew') {

                    window.clearTimeout(this.delayTimeout);
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    this.delayTimeout = setTimeout(() => {
                        //call new Entitled Service function for save and new action
                        this.handleNewEntitledServicePlan(result.data.serviceContractPlanId);
                    }, 500);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    handleEntitledServicePlanCancel () {
        this.entitledServicePlanModalOpen = false;
        this.viewModalOpened = false;
        this.clearValues();
    }

    isValidInput () {
        let isValid = true;
        this.error = '';

        isValid = [...this.template.querySelectorAll(
            '.svmx-entitled-service-plan-detail_input-field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (!isValid) {
            this.error = this.i18n.formValidation;
        }

        return isValid;
    }

    handleCloseAndRefresh () {
        this.dispatchEvent(
            new CustomEvent('closeandrefreshpage', {
                detail: {
                    value: 'success'
                }
            })
        );
    }

    clearValues () {
        this.editMode = false;
        this.recordInfo = {};
        this.error = null;
    }

    showToast (type, title, message, variant, mode) {
        const evt = new ShowToastEvent({
            type: type,
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

}