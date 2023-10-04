import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import getEntitledServiceRecordTypeId
    from '@salesforce/apex/EVER_EntitledService_LS.getEntitledServiceRecordTypeId';
import getParentRecordValues
    from '@salesforce/apex/EVER_EntitledService_LS.getParentRecordValues';
import getEntitledServiceDetails
    from '@salesforce/apex/EVER_EntitledService_LS.getEntitledServiceDetails';
import deleteEntitledService
    from '@salesforce/apex/EVER_EntitledService_LS.deleteEntitledService';
import saveEntitledService
    from '@salesforce/apex/EVER_EntitledService_LS.saveEntitledService';
import getLookupConfigRecords
    from '@salesforce/apex/CONF_QueryLightningService.queryRecords';

import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    isEmptyString,
    PAGE_ACTION_TYPES
} from 'c/utils';

//Get service unit type info field from entitlement object
import SERVICE_UNIT_FIELD from '@salesforce/schema/Entitlement.ServiceCountType__c';
//Get fields and object info from LookupConfiguration object
import LOOKUP_CONFIG_OBJ from '@salesforce/schema/CONF_LookupConfiguration__c';
import LOOKUP_CONFIG_ID_FIELD from '@salesforce/schema/CONF_LookupConfiguration__c.Id';
import LOOKUP_CONFIG_NAME_FIELD from '@salesforce/schema/CONF_LookupConfiguration__c.Name';
import LOOKUP_CONFIG_DEVELOPER_NAME_FIELD
    from '@salesforce/schema/CONF_LookupConfiguration__c.DeveloperName__c';

import SERVICE_CONTRACT_NAME_FIELD from '@salesforce/schema/ServiceContract.Name';
import CONTRACT_LINE_NUMBER_FIELD from '@salesforce/schema/ContractLineItem.LineItemNumber';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';
import ASSET_NAME_FIELD from '@salesforce/schema/Asset.Name';
import ENTITLEMENT_PROCESS_NAME_FIELD from '@salesforce/schema/SlaProcess.Name';

//Get fields from Contract Line object
import CONTRACT_LINE_ASSET_ID_FIELD from '@salesforce/schema/ContractLineItem.AssetId';

import labelEntitledServiceDetail from '@salesforce/label/c.Label_EntitledServiceDetail';
import labelEntitledServiceName from '@salesforce/label/c.Label_EntitledServiceName';
import labelServiceContract from '@salesforce/label/c.Label_ServiceContract';
import labelService_Product from '@salesforce/label/c.Label_Service_Product';
import labelContractLineItem from '@salesforce/label/c.Label_ContractLineItem';
import labelStatus from '@salesforce/label/c.Label_Status';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelStartDate from '@salesforce/label/c.Label_Start_Date';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelServiceThresholds from '@salesforce/label/c.Label_ServiceThresholds';
import labelServiceUnit from '@salesforce/label/c.Label_ServiceUnit';
import labelEntitlementProcesses from '@salesforce/label/c.Label_EntitlementProcesses';
import labelCaseEntitlementProcess from '@salesforce/label/c.Label_Case_EntitlementProcess';
import labelWO_EntitlementProcess from '@salesforce/label/c.Label_WO_EntitlementProcess';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelSave from '@salesforce/label/c.Button_Save';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelDeleteEntitledService from '@salesforce/label/c.Label_DeleteEntitledService';
import labelES_DeleteConfirmMessage from '@salesforce/label/c.Label_ES_DeleteConfirmMessage';
import labelES_DeleteSuccessMessage from '@salesforce/label/c.Label_ES_DeleteSuccessMessage';
import labelES_CreationMessage from '@salesforce/label/c.Label_ES_CreationMessage';
import labelES_UpdateMessage from '@salesforce/label/c.Label_ES_UpdateMessage';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
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
import labelEndDateErrorMessage from '@salesforce/label/c.Label_EndDateErrorMessage';
import labelStartDateErrorMessage from '@salesforce/label/c.Label_StartDateErrorMessage';
import labelClone from '@salesforce/label/c.Menu_Clone';
import labelSaveAndClone from '@salesforce/label/c.Button_SaveAndClone';
import TIMEZONE from '@salesforce/i18n/timeZone';
import labelOperatingHours from '@salesforce/label/c.Label_OperatingHours';
import messageDeleteErrorHeader from '@salesforce/label/c.Message_DeleteErrorHeader';

const i18n = {
    entitledServiceDetail: labelEntitledServiceDetail,
    entitledServiceName: labelEntitledServiceName,
    serviceContract: labelServiceContract,
    serviceProduct: labelService_Product,
    contractLineItem: labelContractLineItem,
    status: labelStatus,
    asset: labelAsset,
    startDate: labelStartDate,
    endDate: labelEndDate,
    serviceThresholds: labelServiceThresholds,
    serviceUnit: labelServiceUnit,
    entitlementProcesses: labelEntitlementProcesses,
    caseProcess: labelCaseEntitlementProcess,
    workOrderProcess: labelWO_EntitlementProcess,
    valueMissing: labelEnterValue,
    tooLong: labelMaxLength,
    badInputDate: labelBadInputDate,
    shortDateFormat: shortDateFormat,
    cancel: labelCancel,
    confirm: labelConfirm,
    delete: labelDelete,
    edit: labelEdit,
    save: labelSave,
    deleteTitle: labelDeleteEntitledService,
    deleteConfirmMessage: labelES_DeleteConfirmMessage,
    deleteSuccess: labelES_DeleteSuccessMessage,
    createdMsg: labelES_CreationMessage,
    updatedMsg: labelES_UpdateMessage,
    success: labelSuccess,
    outOfRangeNumber: labelOutOfRangeNumber,
    formValidation: labelFormValidation,
    reviewError: labelReviewError,
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
    endDateInvalidError: labelEndDateErrorMessage,
    endDateError: labelStartDateErrorMessage,
    clone: labelClone,
    saveAndClone: labelSaveAndClone,
    timeZone: TIMEZONE,
    operatingHours: labelOperatingHours,
    deleteErrorHeader: messageDeleteErrorHeader
}

const DEFAULT_STATUS = 'Inactive';
const CONTRACT_LINE_CONFIG = 'Contract_Line_Lookup_Filter';
const MAX_TEXT_LENGTH = 255;
const MAX_VALUE = 9999999999999998.99;
const SERVICE_TYPE_AMOUNT = 'Amount';
const SERVICE_TYPE_VISITS = 'Visits';
const SERVICE_TYPE_HOURS = 'Hours';
const SERVICE_TYPE_CREDITS = 'Credits';

export default class EntitledServiceDetail extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track currentRecordId;
    @track fieldsToRetrieve;
    @track entitledServiceModalOpen;
    @track deleteModalDialogOpen;

    @track recordInfo = {};
    @track parentDateInfo = {};
    @track editMode = false;
    @track viewModalOpened = false;
    @track error;
    @track apiInProgress = false;
    @track serviceUnitOptions = [];
    @track contractLineConfig = {};
    deleteErrorMsg;
    deleteErrorMessageOpen = false ;

    developerNames = [CONTRACT_LINE_CONFIG];
    objectName;
    entitledServiceRecordTypeId;
    defaultRecordTypeId;
    pendingDeleteRecord;
    parentRecordId;
    booleanFalse = false;
    booleanTrue = true;

    currencyFormatter = 'currency';
    decimalFormatter = 'decimal';
    serviceContractNameField = SERVICE_CONTRACT_NAME_FIELD.fieldApiName;
    contractLineNameField = [
        CONTRACT_LINE_NUMBER_FIELD.fieldApiName,
        CONTRACT_LINE_ASSET_ID_FIELD.fieldApiName
    ].join(',');
    productNameField = PRODUCT_NAME_FIELD.fieldApiName;
    assetNameField = ASSET_NAME_FIELD.fieldApiName;
    entitlementProcessName = ENTITLEMENT_PROCESS_NAME_FIELD.fieldApiName;
    whereClauseCase = "SobjectType = 'Case' and IsActive =true";
    whereClauseWO = "SobjectType = 'WorkOrder' and IsActive =true";

    connectedCallback () {
        getEntitledServiceRecordTypeId ()
        .then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.entitledServiceRecordTypeId = result.data;
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        })
    }

    renderedCallback () {
        this.fetchlookupConfigRecords();
    }

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: SERVICE_UNIT_FIELD
    })
    setServiceUnitOptions ({ error, data }) {
        if (data) {
            this.serviceUnitOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    fetchlookupConfigRecords () {
        if (this.contractLineConfig.lookupConfigId) return;

        this.fieldsToRetrieve = [
            LOOKUP_CONFIG_ID_FIELD.fieldApiName,
            LOOKUP_CONFIG_NAME_FIELD.fieldApiName,
            LOOKUP_CONFIG_DEVELOPER_NAME_FIELD.fieldApiName
        ];
        this.objectName = LOOKUP_CONFIG_OBJ.objectApiName;
        const reqObject ={
            objectName: this.objectName,
            fields: this.fieldsToRetrieve,
            developerNames: this.developerNames
        };
        getLookupConfigRecords({
            requestJson: JSON.stringify(reqObject)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.populateLookupConfigId(result.data);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    populateLookupConfigId (data) {
        const contractLineLookup = data.find(
            element => element.SVMXA360__DeveloperName__c === CONTRACT_LINE_CONFIG);
        if (contractLineLookup) {
            this.contractLineConfig.lookupConfigId = contractLineLookup.Id;
        }
    }

    handleEdit () {
        this.editMode = true;
    }

    get i18n () {
        return i18n;
    }

    get recordTypeId () {
        return isEmptyString(this.entitledServiceRecordTypeId) ?
            null : this.entitledServiceRecordTypeId;
    }

    get badInputMessage () {
        return formatString(i18n.badInputDate, i18n.shortDateFormat);
    }

    get maxValue () {
        return MAX_VALUE;
    }

    get stepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 16, 2);
    }

    get tooLongMessage () {
        return formatString(i18n.tooLong, MAX_TEXT_LENGTH);
    }

    get entitledServiceStatus () {
        return (this.recordInfo.status) ? this.recordInfo.status : DEFAULT_STATUS;
    }

    get totalServiceLabel () {
        switch (this.recordInfo.serviceType) {
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
        switch (this.recordInfo.serviceType) {
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

    get remainingServiceLabel () {
        switch (this.recordInfo.serviceType) {
            case SERVICE_TYPE_AMOUNT:
                return this.i18n.amountRemaining;
            case SERVICE_TYPE_VISITS:
                return this.i18n.visitRemaining;
            case SERVICE_TYPE_HOURS:
                return this.i18n.hoursRemaining;
            case SERVICE_TYPE_CREDITS:
                return this.i18n.creditRemaining;
            default:
                return '';
        }
    }

    get viewMode () {
        return (!this.editMode);
    }

    get isServiceUnitSection () {
        return (this.recordInfo.serviceType);
    }

    get formatterType () {
        return (this.recordInfo.serviceType === SERVICE_TYPE_AMOUNT) ?
            this.currencyFormatter : this.decimalFormatter;
    }

    get contractLineFilter () {
        return this.recordInfo.serviceContractId &&
            `ServiceContractId='${this.recordInfo.serviceContractId}'`;
    }

    @api
    handleNewEntitledService (recId,isCLIChanged) {
        this.parentRecordId = recId;
        this.editMode = true;
        getParentRecordValues({
            requestJson: JSON.stringify({ parentId: this.parentRecordId })
        })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                if (isCLIChanged) {
                    this.populateParentDateInfo(result.data);
                } else {
                    this.populateEntitledServiceInfo(result.data);
                }
            }).catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.entitledServiceModalOpen = true;
                this.parentRecordId = undefined;
            });
    }

    @api
    handleEditEntitledService (recId,actionName) {
        this.currentRecordId = recId;
        if (actionName === PAGE_ACTION_TYPES.VIEW) {
            this.editMode = false;
            this.viewModalOpened = true;
        } else {
            this.editMode = true;
        }
        getEntitledServiceDetails({
            requestJson: JSON.stringify({ id: this.currentRecordId })
        })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.populateEntitledServiceInfo(result.data);
                if (actionName === PAGE_ACTION_TYPES.CLONE) {
                    this.recordInfo.id = null;
                }
            }).catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.entitledServiceModalOpen = true;
                this.currentRecordId = undefined;
            });
    }

    @api
    handleDeleteEntitledService (record) {
        this.pendingDeleteRecord = record;
        this.deleteModalDialogOpen = true;
    }

    populateEntitledServiceInfo (data) {
        this.recordInfo = { ...this.recordInfo, ...data };
        this.parentDateInfo.startDate = this.recordInfo.startDate;
        this.parentDateInfo.endDate = this.recordInfo.endDate;
    }

    populateParentDateInfo (resultData) {
        this.recordInfo.startDate = resultData.startDate;
        this.recordInfo.endDate = resultData.endDate;
    }

    handleServiceUnitChange (event) {
        this.recordInfo.serviceType = event.detail.value;
        //reset field values in service unit section
        this.recordInfo.totalService = null;
        this.recordInfo.serviceAlertThreshold = null;
        this.recordInfo.remainingService = null;
    }

    handleLookupFieldChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const { detail, target } = event;
        switch (target.dataset.field) {
            case 'ServiceContract':
                this.recordInfo.serviceContractId = detail.value;
                this.recordInfo.serviceContractName = detail.label;
                break;
            case 'ContractLine':
                if ( this.recordInfo.contractLineId !== detail.value) {
                    this.recordInfo.contractLineId = detail.value;
                    this.recordInfo.contractLineName = detail.label;
                    if (this.recordInfo.contractLineId) {
                        this.handleNewEntitledService (this.recordInfo.contractLineId,true);
                    } else {
                        this.recordInfo.startDate = this.parentDateInfo.startDate;
                        this.recordInfo.endDate = this.parentDateInfo.endDate;
                    }
                }
                break;
            case 'Product':
                this.recordInfo.serviceProductId = detail.value;
                this.recordInfo.serviceProductName = detail.label;
                break;
            case 'Asset':
                this.recordInfo.assetId = detail.value;
                this.recordInfo.assetName = detail.label;
                break;
            case 'CaseEntitlement':
                this.recordInfo.caseEntitlementProcessId = detail.value;
                this.recordInfo.caseEntitlementProcessName = detail.label;
                break;
            case 'WOEntitlement':
                this.recordInfo.workOrderEntitlementProcessId = detail.value;
                this.recordInfo.workOrderEntitlementProcessName = detail.label;
                break;
            case 'OperatingHours':
                this.recordInfo.operatingHoursId = detail.value;
                this.recordInfo.operatingHoursName = detail.label;
                break;
            default:
                break;
        }
    }

    handleChange (event) {
        const targetElement = event.target;
        this.recordInfo[targetElement.dataset.field] = targetElement.value;
    }

    handleDeleteModal () {
        this.handleDeleteEntitledService(this.recordInfo);
        this.entitledServiceModalOpen = false;
    }

    handleSave (event) {
        if (!this.isValidInput()) return;

        if (this.apiInProgress) return;

        const actionName = event.target.dataset.name;
        this.apiInProgress = true;
        saveEntitledService({ requestJson: JSON.stringify(this.recordInfo) })
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
                this.handleEntitledServiceCancel();
                if (actionName === 'saveAndClone') {
                    //call edit function for clone
                    this.handleEditEntitledService (result.data.id,PAGE_ACTION_TYPES.CLONE);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    handleClone () {
        this.recordInfo.id = null;
        this.handleEdit();
    }

    isValidInput () {

        let isValid = true;
        this.error = '';
        const startDateInput = this.template.querySelector(
            '.svmx-entitled-service-detail_start-date'
        );

        if (startDateInput) {
            if (this.recordInfo.endDate < this.recordInfo.startDate) {
                startDateInput.setCustomValidity(this.i18n.endDateInvalidError);
                isValid = false;
            } else if (this.recordInfo.endDate && !this.recordInfo.startDate) {
                startDateInput.setCustomValidity(this.i18n.endDateError);
                isValid = false;
            } else {
                startDateInput.setCustomValidity('');
            }
            startDateInput.reportValidity();
        }

        isValid = [...this.template.querySelectorAll(
            '.svmx-entitled-service-detail_input-field')]
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

    handleEntitledServiceCancel () {
        this.entitledServiceModalOpen = false;
        this.viewModalOpened = false;
        this.clearValues();
    }

    clearValues () {
        this.editMode = false;
        this.recordInfo = {};
        this.error = null;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
        this.deleteErrorMessageOpen = false;
        if (this.viewModalOpened ) {
            this.entitledServiceModalOpen = true;
        }
    }

    handleDeleteConfirmModal () {
        if (!this.pendingDeleteRecord) return;

        if (this.apiInProgress) return;

        this.apiInProgress = true;
        deleteEntitledService({
            requestJson: JSON.stringify({ id: this.pendingDeleteRecord.id }) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.deleteModalDialogOpen = false;
                    this.deleteErrorMessageOpen = true;
                    this.deleteErrorMsg = result.message;
                    return;
                }

                this.handleEntitledServiceCancel();
                this.handleCancelModal();
                const toastMsg = `${this.i18n.deleteSuccess}- ${this.pendingDeleteRecord.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleCloseAndRefresh();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.pendingDeleteRecord = undefined;
                this.apiInProgress = false;
            });
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