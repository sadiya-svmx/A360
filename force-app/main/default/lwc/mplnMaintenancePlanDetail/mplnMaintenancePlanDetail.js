import { api, wire, LightningElement } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import getAllLocationRelatedAccounts
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getLocationAccounts';
import { formatString , parseErrorMessage , isNotUndefinedOrNull } from 'c/utils';
import WORKTYPE_NAME_FIELD from '@salesforce/schema/WorkType.Name';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import SERVICECONTRACT_NAME_FIELD from '@salesforce/schema/ServiceContract.Name';
import LOCATION_NAME_FIELD from '@salesforce/schema/Location.Name';
import MAINTENANCEPLANTEMPLATE_NAME_FIELD
    from '@salesforce/schema/MaintenancePlanTemplate__c.Name';
import GENERATIONTIMEFRAMETYPE_FIELD
    from '@salesforce/schema/MaintenancePlan.GenerationTimeframeType';
import WORKORDERGENERATIONMETHOD_FIELD
    from '@salesforce/schema/MaintenancePlan.WorkOrderGenerationMethod';
import SVCAPPTGENERATIONMETHOD_FIELD
    from '@salesforce/schema/MaintenancePlan.SvcApptGenerationMethod';
import ASSET_STATUS_FIELD from '@salesforce/schema/Asset.Status';
import { FlowNavigationNextEvent , FlowNavigationBackEvent } from 'lightning/flowSupport';
import MAINTENANCEPLAN_OBJECT from '@salesforce/schema/MaintenancePlan';
import ASSET_OBJECT from '@salesforce/schema/Asset';
//Custom label import
import labelMaintenancePlanDetail from '@salesforce/label/c.Label_MaintenancePlanDetail';
import labelSvcApptGenerationMethodError
    from '@salesforce/label/c.Message_SvcApptGenerationMethodError';
import labelSvcApptGenerationMethodSelectError
    from '@salesforce/label/c.Message_SvcApptGenerationMethodSelectError';
import labelNextSuggestedMaintenanceDateError
    from '@salesforce/label/c.Message_NextSuggestedMaintenanceDateError';
import labelGenerationHorizonError
    from '@salesforce/label/c.Message_GenerationHorizonError';
import labelMaintenanceWindowStartEndDays
    from '@salesforce/label/c.Message_MaintenanceWindowStartEndDaysError';
import labelInvalidDataType from '@salesforce/label/c.Message_InvalidDataError';
import labelMessage_ReviewError from '@salesforce/label/c.Message_ReviewError';
import labelStartDateError from '@salesforce/label/c.Message_StartDateError';
import labelNone from '@salesforce/label/c.Label_NoneValue';
import labelPrevious from '@salesforce/label/c.Button_Previous';
import labelNextButton from '@salesforce/label/c.Button_Next';
import labelGeneralInformation from '@salesforce/label/c.Sec_General_Information';
import labelWorkOrderGeneration from '@salesforce/label/c.Sec_Work_Order_Generation';
import labelRequiredFieldMessage from '@salesforce/label/c.Label_RequiredFieldMessage';
import labelIncludeAssetStatus from '@salesforce/label/c.Label_IncludeAssetStatus';
import labelGenerationTimeFrameNegativeError
    from '@salesforce/label/c.Error_Generation_Timeframe_Negative_Value'
import labelIncludeChildAsset from '@salesforce/label/c.Label_IncludeChildAssets';

const i18n = {
    title: labelMaintenancePlanDetail,
    previous: labelPrevious,
    next: labelNextButton,
    svpAppGenerationMethodError: labelSvcApptGenerationMethodError,
    nextSuggestedMaintenanceDateError: labelNextSuggestedMaintenanceDateError,
    startDateError: labelStartDateError,
    invalidDataType: labelInvalidDataType,
    reviewError: labelMessage_ReviewError,
    none: labelNone,
    generalInformation: labelGeneralInformation,
    workOrderGeneration: labelWorkOrderGeneration,
    requiredFieldMessage: labelRequiredFieldMessage,
    svcApptGenerationMethodSelectError: labelSvcApptGenerationMethodSelectError,
    generationHorizonError: labelGenerationHorizonError,
    maintenanceWindowStartEndDays: labelMaintenanceWindowStartEndDays,
    includeAssetStatus: labelIncludeAssetStatus,
    generationTimeframeError: labelGenerationTimeFrameNegativeError,
    includeChildAssets: labelIncludeChildAsset
}

const fieldApis = {
    workTypeName: WORKTYPE_NAME_FIELD.fieldApiName,
    accountName: ACCOUNT_NAME_FIELD.fieldApiName,
    maintenancePlanTemplateName: MAINTENANCEPLANTEMPLATE_NAME_FIELD.fieldApiName,
    serviceContractName: SERVICECONTRACT_NAME_FIELD.fieldApiName,
    locationName: LOCATION_NAME_FIELD.fieldApiName,
    maintenancePlanTitle: "MaintenancePlanTitle",
    maintenancePlanTemplateId: "SVMXA360__MaintenancePlanTemplateId__c",
    accountId: "AccountId",
    workTypeId: "WorkTypeId",
    serviceContractId: "ServiceContractId",
    locationId: "LocationId",
    generationTimeframe: "GenerationTimeframe",
    generationTimeframeType: "GenerationTimeframeType",
    generationHorizon: "GenerationHorizon",
    startDate: "StartDate",
    endDate: "EndDate",
    nextSuggestedMaintenanceDate: "NextSuggestedMaintenanceDate",
    maintenanceWindowStartDays: "MaintenanceWindowStartDays",
    maintenanceWindowEndDays: "MaintenanceWindowEndDays",
    workOrderGenerationMethod: "WorkOrderGenerationMethod",
    svcApptGenerationMethod: "SvcApptGenerationMethod",
    doesAutoGenerateWorkOrders: "DoesAutoGenerateWorkOrders",
    doesGenerateUponCompletion: "DoesGenerateUponCompletion",
    description: "Description"
}

const LOCATION = 'Location';
const ACCOUNT = 'Account';
const ASSET = 'Asset';
const SERVICE_CONTRACT = 'ServiceContract';

export default class MplnMaintenancePlanDetail extends LightningElement {
    @api maintenancePlanRecord;
    @api recordId;
    @api assetStatus;
    @api includeChildAssets;

    error;
    generationTimeFrameTypePickListOption;
    workOrderGenerationMethodPickListOption;
    svcApptGenerationMethodPickListOption;
    assetStatusOptions = [];
    selectedAssetOption;
    hasFormError = false;
    defaultRecordTypeId;
    //default active sections
    activeSections = ['generalInformation','workOrderGeneration'];
    isSourceLocation = false;
    isSourceAccount = false;
    isSourceAsset = false;
    isSourceSContract = false;
    objectApiName;
    sourceRecordName;
    accountIds = [];
    isDataRetrieved = false;
    // to disable lookup field
    isLocationDisabled = false;
    isAccountDisabled = false;

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View']} )
    sourceRecord ( { error , data } ) {
        if (data) {
            this.sourceRecordName = data.fields.Name.value;
            this.objectApiName = data.apiName;
            switch (this.objectApiName) {
                case LOCATION:
                    this.isSourceLocation = true;
                    break;
                case ACCOUNT:
                    this.isSourceAccount = true;
                    break;
                case ASSET:
                    this.isSourceAsset = true;
                    this.isLocationDisabled = true;
                    this.isAccountDisabled = true;
                    break;
                case SERVICE_CONTRACT:
                    this.isSourceSContract = true;
                    this.isAccountDisabled = true;
                    break;
                default:
                    this.isSourceAccount = true;
            }
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: GENERATIONTIMEFRAMETYPE_FIELD
    })
    generationTimeFrameTypePickList ({ error, data }) {
        if (data) {
            this.generationTimeFrameTypePickListOption = this.setPicklistOption(data);
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: WORKORDERGENERATIONMETHOD_FIELD
    })
    workOrderGenerationMethodPickList ({ error, data }) {
        if (data) {
            this.workOrderGenerationMethodPickListOption = this.setPicklistOption(data);
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: SVCAPPTGENERATIONMETHOD_FIELD
    })
    svcApptGenerationMethodPickList ({ error, data }) {
        if (data) {
            this.svcApptGenerationMethodPickListOption =  this.setPicklistOption(data);
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getObjectInfo , { objectApiName: ASSET_OBJECT })
    assetObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$assetObjectInfo.data.defaultRecordTypeId',
        fieldApiName: ASSET_STATUS_FIELD
    })
    setAssetStatusPickList ( { error, data } ) {
        if (data) {
            this.assetStatusOptions =  data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getObjectInfo , { objectApiName: MAINTENANCEPLAN_OBJECT })
    getMaintenancePlanInfo ({ error, data }) {
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
            // get all the field label
            this.i18n.maintenancePlanTitle = data.fields.MaintenancePlanTitle.label;
            this.i18n.maintenancePlanTemplateId
                = data.fields.SVMXA360__MaintenancePlanTemplateId__c.label;
            this.i18n.accountId = data.fields.AccountId.label;
            this.i18n.workTypeId = data.fields.WorkTypeId.label;
            this.i18n.serviceContractId = data.fields.ServiceContractId.label;
            this.i18n.locationId = data.fields.LocationId.label;
            this.i18n.generationTimeframe = data.fields.GenerationTimeframe.label;
            this.i18n.generationTimeframeType = data.fields.GenerationTimeframeType.label;
            this.i18n.generationHorizon = data.fields.GenerationHorizon.label;
            this.i18n.startDate = data.fields.StartDate.label;
            this.i18n.endDate = data.fields.EndDate.label;
            this.i18n.nextSuggestedMaintenanceDate
                = data.fields.NextSuggestedMaintenanceDate.label;
            this.i18n.maintenanceWindowStartDays = data.fields.MaintenanceWindowStartDays.label;
            this.i18n.maintenanceWindowEndDays = data.fields.MaintenanceWindowEndDays.label;
            this.i18n.workOrderGenerationMethod = data.fields.WorkOrderGenerationMethod.label;
            this.i18n.svcApptGenerationMethod = data.fields.SvcApptGenerationMethod.label;
            this.i18n.doesAutoGenerateWorkOrders = data.fields.DoesAutoGenerateWorkOrders.label;
            this.i18n.doesGenerateUponCompletion = data.fields.DoesGenerateUponCompletion.label;
            this.i18n.description = data.fields.Description.label;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    connectedCallback () {
        this.onLoadAction();
    }
    onLoadAction () {
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.maintenancePlanRecord = this.mapPlanLocalInstanceCreation(this.maintenancePlanRecord);
        if (this.assetStatus) {
            this.selectedAssetOption = this.assetStatus.join(';');
        }
        if (!this.includeChildAssets) {
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.includeChildAssets = false;
        }
    }

    getLocationRelatedAccounts () {
        getAllLocationRelatedAccounts({
            locationId: this.recordId }).then(result => {
            this.accountIds = result.data;
            this.isDataRetrieved = true;
        }).catch(error => {
            this.error = this.error = parseErrorMessage(error);
        })
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
    get accountFilter () {
        if ( this.objectApiName === LOCATION ) {
            return this.accountWhereClause();
        }
        return '';
    }
    get fieldApis () {
        return fieldApis;
    }
    get i18n () {
        return i18n;
    }
    get hasError () {
        return isNotUndefinedOrNull(this.error);
    }
    get popoverErrorMessages () {
        const errorMessages = [];
        const errorMessage = i18n.reviewError;
        if (this. hasFormError) {
            errorMessages.push(formatString(errorMessage));
        }
        return errorMessages.map(message => ({ message }));
    }

    get showFormErrorsIcon () {
        return this.hasFormError;
    }

    handleLookupError (event) {
        const error = event.detail;
        const targetElement = event.target;
        if (targetElement.dataset.fieldname) {
            if (targetElement.dataset.fieldname === 'SVMXA360__MaintenancePlanTemplateId__c' ) {
                this.error = `${parseErrorMessage(error) } : ${event.target.label}`;
            }
            this.maintenancePlanRecord[targetElement.dataset.fieldname] = null;
        }
        event.stopPropagation();
    }

    handleIncludeChildChange (event) {
        const targetElement = event.target;
        if (targetElement) {
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.includeChildAssets = targetElement.checked;
        }
    }

    handleAssetStatusChange ( event ) {
        const selectedValue = event.detail.value;
        this.selectedAssetOption = selectedValue;
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.assetStatus = selectedValue.split(";");
    }
    // handle the field value changes
    handleMaintenancePlanData (event) {
        const targetElement = event.target;
        if (targetElement.dataset.fieldname !== undefined) {
            this.maintenancePlanRecord[targetElement.dataset.fieldname]
                = targetElement.type === 'checkbox'
                    ? targetElement.checked : (targetElement.type === 'number'
                && (targetElement.value && targetElement.value !=="")
                        ? (targetElement.value = Math.round(targetElement.value))
                        : targetElement.value) ;
            if (targetElement.dataset.fieldname === fieldApis.startDate
                    || targetElement.dataset.fieldname
                        === fieldApis.nextSuggestedMaintenanceDate) {
                this.resetReportValidity( fieldApis.startDate );
                this.resetReportValidity(fieldApis.nextSuggestedMaintenanceDate);
            } else if (targetElement.dataset.fieldname === fieldApis.svcApptGenerationMethod
                    || targetElement.dataset.fieldname === fieldApis.workOrderGenerationMethod) {
                this.resetReportValidity( fieldApis.svcApptGenerationMethod);
                this.resetReportValidity(fieldApis.workOrderGenerationMethod);
            } else if (targetElement.dataset.fieldname === fieldApis.generationTimeframeType) {
                this.resetReportValidity(fieldApis.generationTimeframeType);
            } else if (targetElement.dataset.fieldname === fieldApis.maintenanceWindowStartDays ) {
                this.resetReportValidity(fieldApis.maintenanceWindowStartDays );
            } else if (targetElement.dataset.fieldname === fieldApis.maintenanceWindowEndDays) {
                this.resetReportValidity(fieldApis.maintenanceWindowEndDays);
            } else if (targetElement.dataset.fieldname === fieldApis.generationHorizon ) {
                this.resetReportValidity(fieldApis.generationHorizon );
            } else if (targetElement.dataset.fieldname === fieldApis.generationTimeframe ) {
                this.resetReportValidity(fieldApis.generationTimeframe );
            }
        }

    }
    resetReportValidity (fieldName) {
        const selector =  `[data-fieldname="${fieldName}"]`;
        const inputCmp = this.template.querySelector(selector);
        inputCmp.setCustomValidity("");
        inputCmp.reportValidity();
    }

    mapPlanLocalInstanceCreation (maintenancePlanRecord) {
        // default pickList either be null or undefined ,
        // we are setting up as None default if no value
        const tempMaintenancePlanRecord = { ...maintenancePlanRecord };
        tempMaintenancePlanRecord.GenerationTimeframeType
            = this.setPickListValue(tempMaintenancePlanRecord.GenerationTimeframeType);
        tempMaintenancePlanRecord.SvcApptGenerationMethod
            = this.setPickListValue(tempMaintenancePlanRecord.SvcApptGenerationMethod);
        tempMaintenancePlanRecord.WorkOrderGenerationMethod
            = this.setPickListValue(tempMaintenancePlanRecord.WorkOrderGenerationMethod);
        const startDate = tempMaintenancePlanRecord.StartDate;
        tempMaintenancePlanRecord.StartDate
            = this.getFormattedDate(startDate);
        tempMaintenancePlanRecord.EndDate
            = this.getFormattedDate(tempMaintenancePlanRecord.EndDate);
        tempMaintenancePlanRecord.NextSuggestedMaintenanceDate
            = this.getFormattedDate( tempMaintenancePlanRecord.NextSuggestedMaintenanceDate
                && tempMaintenancePlanRecord.NextSuggestedMaintenanceDate !== null
                ? tempMaintenancePlanRecord.NextSuggestedMaintenanceDate
                : startDate );
        return tempMaintenancePlanRecord;
    }
    //set picklist value to none if blank or null
    setPickListValue (value) {
        if (value === null || value === undefined) {
            return 'None';
        }
        return value;
    }
    // get date in yyyy-mm-dd
    getFormattedDate ( actualDate ) {
        if (actualDate === null || actualDate === undefined) {
            return null;
        }
        const date = new Date(actualDate);
        let month = ''+(date.getUTCMonth() + 1);
        let day = ''+(date.getUTCDate());
        const year = ''+(date.getUTCFullYear());
        if (month.length < 2) {
            month = '0'+ month;
        }
        if (day.length < 2) {
            day = '0'+ day;
        }
        return [year, month, day].join('-');
    }
    //set the None for picklist 
    setPicklistOption (data) {
        const options = data.values.map( pickListValue => {
            return {
                label: pickListValue.label,
                value: pickListValue.value
            }
        });
        options.unshift({ label: i18n.none, value: "None" });
        return options;
    }

    // on click next validation
    handleNext () {
        if (this.isAllFieldValid()) {
            this.hasFormError = false;
            this.clearError();
            this.navigateFlowNext();
        } else {
            this.hasFormError = true;
        }
    }

    isAllFieldValid () {
        let isAllValid = true;
        const inputCmps = this.template.querySelectorAll('.inputfield');
        inputCmps.forEach(inputCmp => {
            if (!inputCmp.checkValidity()) {
                inputCmp.reportValidity();
                isAllValid = false;
            }
        });
        if (isAllValid) {
            isAllValid = this.handleCustomvalidation();
        }
        if (this.hasError) {
            isAllValid = false;
        }
        //Only if all error resolved
        if (isAllValid) {
            this.setMaintenancePlanFieldValue();
        }
        return isAllValid;
    }

    clearError () {
        this.error = null;
    }

    // Before handover to next screen replacing blank string to null and
    // if picklist is none to set null. 
    setMaintenancePlanFieldValue () {
        for (const fieldName in this.maintenancePlanRecord ) {
            if (Object.prototype.hasOwnProperty.call(this.maintenancePlanRecord, fieldName)) {
                if (this.maintenancePlanRecord[fieldName] === "") {
                    this.maintenancePlanRecord[fieldName] = null;
                }
                if (this.maintenancePlanRecord[fieldName] === "None"
                    && (fieldName === fieldApis.svcApptGenerationMethod
                        || fieldName === fieldApis.workOrderGenerationMethod
                        || fieldName === fieldApis.generationTimeframeType)) {
                    this.maintenancePlanRecord[fieldName] = null;
                }
            }
        }
    }
    //Handling custom validation
    handleCustomvalidation () {
        let isAllValid = true;
        const { maintenancePlanRecord: { WorkOrderGenerationMethod,
            SvcApptGenerationMethod, MaintenanceWindowStartDays,
            MaintenanceWindowEndDays, GenerationHorizon, StartDate,
            EndDate, NextSuggestedMaintenanceDate, GenerationTimeframeType,
            GenerationTimeframe }} = this;
        if ( ( WorkOrderGenerationMethod === "WorkOrderPerAsset"
                || WorkOrderGenerationMethod === "None"
                || WorkOrderGenerationMethod === null )
                && (SvcApptGenerationMethod === "SvcApptPerWorkOrder"
                || SvcApptGenerationMethod === "SvcApptPerWorkOrderLineItem")) {
            this.reportCustomValidity(fieldApis.svcApptGenerationMethod ,
                `${i18n.svpAppGenerationMethodError} ${i18n.svcApptGenerationMethod}` );
            isAllValid = false;
        } else if ( WorkOrderGenerationMethod
                === "WorkOrderLineItemPerAsset"
                && ( SvcApptGenerationMethod === "None"
                || SvcApptGenerationMethod === null)) {
            this.reportCustomValidity(fieldApis.svcApptGenerationMethod,
                `${i18n.svcApptGenerationMethodSelectError} ${i18n.svcApptGenerationMethod}`);
            isAllValid = false;
        }
        if (MaintenanceWindowStartDays !== ""
            && MaintenanceWindowStartDays !=null && MaintenanceWindowStartDays < 0) {
            this.reportCustomValidity(fieldApis.maintenanceWindowStartDays,
                `${i18n.maintenanceWindowStartEndDays} ${i18n.maintenanceWindowStartDays}`);
            isAllValid = false;
        }
        if (MaintenanceWindowEndDays !== ""
            && MaintenanceWindowEndDays !=null && MaintenanceWindowEndDays < 0) {
            this.reportCustomValidity(fieldApis.maintenanceWindowEndDays,
                `${i18n.maintenanceWindowStartEndDays} ${i18n.maintenanceWindowEndDays}`);
            isAllValid = false;
        }
        if (GenerationHorizon !== ""
            && GenerationHorizon !== null && GenerationHorizon < 0) {
            this.reportCustomValidity(fieldApis.generationHorizon,
                `${i18n.generationHorizonError} ${i18n.generationHorizon}` );
            isAllValid = false;
        }
        if (EndDate !== undefined && EndDate !== null
                && StartDate >  EndDate) {
            if (NextSuggestedMaintenanceDate < StartDate) {
                this.reportCustomValidity(fieldApis.startDate,
                    `${i18n.startDateError} ${i18n.nextSuggestedMaintenanceDateError}`);
            } else {
                this.reportCustomValidity(fieldApis.startDate , `${i18n.startDateError}` );
            }
            isAllValid = false;
        } else if (NextSuggestedMaintenanceDate
                < StartDate) {
            this.reportCustomValidity(fieldApis.startDate,
                `${i18n.nextSuggestedMaintenanceDateError}` );
            isAllValid = false;
        }
        if (GenerationTimeframe <= 0) {
            this.reportCustomValidity(fieldApis.generationTimeframe,
                `${i18n.generationTimeframeError}: ${i18n.generationTimeframe}` );
            isAllValid = false;
        }
        if (GenerationTimeframeType === "None") {
            this.reportCustomValidity(fieldApis.generationTimeframeType,
                `${i18n.requiredFieldMessage}` );
            isAllValid = false;
        }
        return isAllValid ;
    }
    // reporting the validity on custom validation
    reportCustomValidity (fieldName, errorMessage) {
        const selector =  `[data-fieldname="${fieldName}"]`;
        const inputCmp = this.template.querySelector(selector);
        inputCmp.setCustomValidity(errorMessage);
        inputCmp.reportValidity();
    }
    //Navigate to next flow screen
    navigateFlowNext () {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    // navigate to previous flow screen
    handlePrevious () {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
}