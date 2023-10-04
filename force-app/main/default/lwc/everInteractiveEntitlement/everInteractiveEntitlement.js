import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceCoverages
    from '@salesforce/apex/EVER_InteractiveEntitlement_LS.getServiceCoverages';
import saveServiceCoverage
    from '@salesforce/apex/EVER_InteractiveEntitlement_LS.saveServiceCoverage';
import getEntitlementSettings
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementSettings';
import getServiceCoveragesForSettings
    from '@salesforce/apex/EVER_InteractiveEntitlement_LS.getServiceCoveragesForSettings';
import { parseErrorMessage, verifyApiResponse, classListMutation, formatString  } from 'c/utils';
import { getFieldDefinitionsForEntities } from 'c/metadataService';

import labelSelectServiceCoverage from '@salesforce/label/c.Button_SelectServiceCoverage';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelClose from '@salesforce/label/c.Button_Close';
import labelSelectCoverage from '@salesforce/label/c.Message_PleaseSelectCoverage';
import labelWarranty from '@salesforce/label/c.Label_Warranty';
import labelCoverage from '@salesforce/label/c.Label_Coverage';
import labelStartDate from '@salesforce/label/c.Label_StartDate';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelTerm from '@salesforce/label/c.Label_Term';
import labelWarrantyType from '@salesforce/label/c.Label_WarrantyType';
import labelCoveredBy from '@salesforce/label/c.Label_CoveredBy';
import labelViewAll from '@salesforce/label/c.Label_ViewAll';
import labelNoCoverage from '@salesforce/label/c.Label_NoCoverage';
import labelEntitledService from '@salesforce/label/c.Label_EntitledService';
import labelChooseRow from '@salesforce/label/c.Label_ChooseRow';
import labelNotes from '@salesforce/label/c.Label_EntitlementNotes';
import labelFutureEntitlements from '@salesforce/label/c.Label_FutureEntitlements';
import labelExpiredEntitlements from '@salesforce/label/c.Label_ExpiredEntitlements';
import labelFullyConsumedServices from '@salesforce/label/c.Label_IncludeFullyConsumedServices';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelAccount from '@salesforce/label/c.Label_Account';
import labelMatchAccount from '@salesforce/label/c.Label_MatchAccount';
import labelAccountAPIName from '@salesforce/label/c.Label_AccountAPIName';
import labelAssetAPIName from '@salesforce/label/c.Label_AssetAPIName';
import labelIncludeRootAsset from '@salesforce/label/c.Label_IncludeRootAsset';
import labelIncludeParentAsset from '@salesforce/label/c.Label_IncludeParentAsset';
import labelApply from '@salesforce/label/c.Button_Apply';
import labellnkClose from '@salesforce/label/c.Link_Close';
import labelFilter from '@salesforce/label/c.Label_Filter';
import labelIncident from '@salesforce/label/c.Label_IncidentNotCovered';
import labelContract from '@salesforce/label/c.Label_Contract';
import labelRecordUpdated from '@salesforce/label/c.Label_RecordUpdatedSuccessfully';
import labelWorkOrder from '@salesforce/label/c.Label_WorkOrder';
import labelReturnOrder from '@salesforce/label/c.Label_ReturnOrder';
import TIMEZONE from '@salesforce/i18n/timeZone';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelServiceThreshold from '@salesforce/label/c.Label_ServiceThreshold';
import labelRemainingServiceCountType from '@salesforce/label/c.Label_RemainingServiceCountType';
import labelConsumedServiceCountType from '@salesforce/label/c.Label_ConsumedServiceCountType';
import labelServiceCount from '@salesforce/label/c.Label_ServiceCount';
import labelExpiringSoon from '@salesforce/label/c.Label_ExpiringSoon';
import labelExpiringMessage from '@salesforce/label/c.Message_ExpiringWithoutBrackets';
import labelExpired from '@salesforce/label/c.Label_Expired';
import labelServiceCountMessage from
    '@salesforce/label/c.Message_ServiceCountMessageWithoutBrackets';
import labelSelectBillingType from '@salesforce/label/c.Label_SelectBillingType';
import labelChange from '@salesforce/label/c.Label_Change';
import labelBillingType from '@salesforce/label/c.Label_BillingType';
import labelNotApplicable from '@salesforce/label/c.Label_NotApplicable';
import labelServiceConsumption from '@salesforce/label/c.Label_ServiceConsumption';
import labelTotal from '@salesforce/label/c.Label_Total';
import labelConsumed from '@salesforce/label/c.Label_Consumed';
import labelRemaining from '@salesforce/label/c.Label_Remaining';
import labelExpiringToday from '@salesforce/label/c.Label_ExpiringToday';
import labelOnHoldEntitlements from '@salesforce/label/c.Label_On_Hold_Entitlements';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ENTITLEMENT_VERIFICATION_HISTORY_OBJECT
    from '@salesforce/schema/EntitlementVerificationHistory__c';
import BILLING_TYPE_FIELD from
    '@salesforce/schema/EntitlementVerificationHistory__c.BillingType__c';
import LOCALE from '@salesforce/i18n/locale';
import ENTITLEMENT_OBJECT from '@salesforce/schema/Entitlement'
import SERVICE_UNIT_FIELD from '@salesforce/schema/Entitlement.ServiceCountType__c';

const i18n = {
    selectServiceCoverage: labelSelectServiceCoverage,
    cancel: labelCancel,
    save: labelSave,
    close: labelClose,
    selectCoverage: labelSelectCoverage,
    warranty: labelWarranty,
    coverage: labelCoverage,
    startDate: labelStartDate,
    endDate: labelEndDate,
    term: labelTerm,
    warrantyType: labelWarrantyType,
    coveredBy: labelCoveredBy,
    viewAll: labelViewAll,
    noCoverage: labelNoCoverage,
    entitledService: labelEntitledService,
    chooseRow: labelChooseRow,
    notes: labelNotes,
    incidentNotcovered: labelIncident,
    futureEntitlements: labelFutureEntitlements,
    expiredEntitlements: labelExpiredEntitlements,
    fullyConsumedServices: labelFullyConsumedServices,
    asset: labelAsset,
    account: labelAccount,
    matchAccount: labelMatchAccount,
    accountAPIName: labelAccountAPIName,
    assetAPIName: labelAssetAPIName,
    includeRootAsset: labelIncludeRootAsset,
    includeParentAsset: labelIncludeParentAsset,
    lnkClose: labellnkClose,
    apply: labelApply,
    filter: labelFilter,
    contract: labelContract,
    updateSuccess: labelRecordUpdated,
    workOrder: labelWorkOrder,
    returnOrder: labelReturnOrder,
    timeZone: TIMEZONE,
    loading: labelLoading,
    serviceThreshold: labelServiceThreshold,
    remainingServiceCountType: labelRemainingServiceCountType,
    consumedServiceCountType: labelConsumedServiceCountType,
    serviceCount: labelServiceCount,
    expiringSoon: labelExpiringSoon,
    expiringMessage: labelExpiringMessage,
    expiredMessage: labelExpired,
    serviceCountMessage: labelServiceCountMessage,
    selectBillingType: labelSelectBillingType,
    change: labelChange,
    billingType: labelBillingType+':',
    notApplicable: labelNotApplicable,
    serviceConsumption: labelServiceConsumption,
    total: labelTotal,
    consumed: labelConsumed,
    remaining: labelRemaining,
    expiringToday: labelExpiringToday,
    onHoldEntitlements: labelOnHoldEntitlements,
}

const SHOW_ROWS = 6;
const ASSET = 'Asset';
const ACCOUNT = 'Account';

export default class EverInteractiveEntitlement extends NavigationMixin (LightningElement) {
    @api isOpen;
    @api sourceRecordId;
    @api sourceObjectName;
    @api accountInfo;
    @api assetInfo;
    @api entitlementNotes;
    @api appNavigationType;
    @api billingType;
    @api noModal = false;
    @api selectedRecordId;

    _selectedRecordId;

    get computeOpenInModal () {
        return this.noModal ? "slds-modal_large" : "slds-modal slds-fade-in-open slds-modal_large";
    }

    @track error;
    @track apiInProgress = false;
    @track panelOpen = false;
    @track activeSettingData = {};
    @track viewMode = true;
    @track billingTypeOptions;
    @track billingTypeModalOpen;
    @track _billingTypeValue;

    activeSections = ['warrantySection', 'contractSection'];
    coverageData;
    dispWarrantyList = [];
    showWarrantyViewAll = false;
    contractData = [];
    warrantyData = [];
    dispContractList = [];
    contractCount = 0;
    warrantyCount = 0;
    showContractViewAll = false;
    noCoverageSelected = true;
    _fieldDescribeResult;
    coverageSaved = false;
    sourceObjectRecordId;
    sourceObjectRecordName;
    showChangeBillingType = true;
    billingTypeValue;
    noCoverageSelectedClass = 'slds-hint-parent slds-is-selected';

    @wire (getObjectInfo, {
        objectApiName: ENTITLEMENT_OBJECT
    })
    entitlementInfo;
    serviceUnitOptions = [];
    //get all picklist values
    @wire( getPicklistValues, {
        recordTypeId: '$entitlementInfo.data.defaultRecordTypeId',
        fieldApiName: SERVICE_UNIT_FIELD
    })
    setServiceUnitValues ( { error, data } ) {
        if (data) {
            this.serviceUnitOptions = data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    getServiceUnitLabel (serviceUnitLValue) {
        //fetch the label associated with this picklist value
        let serviceUnitLabel = '';
        for (let i = 0; i < this.serviceUnitOptions.length; i++) {
            if (this.serviceUnitOptions[i].value === serviceUnitLValue) {
                serviceUnitLabel = this.serviceUnitOptions[i].label;
                break;
            }
        }
        return serviceUnitLabel;
    }


    @wire(getObjectInfo, { objectApiName: ENTITLEMENT_VERIFICATION_HISTORY_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: BILLING_TYPE_FIELD
    })
    billingTypePicklistValues ({ error, data }) {
        if (data) {
            this.billingTypeOptions = data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    get i18n () {
        return i18n;
    }

    @api performCoverageLoad () {
        this.resetValues();
        this._selectedRecordId = this.selectedRecordId;
        this.getListViewData();
        this.billingTypeValue = this.billingType;
        if (this.billingType == null) {
            this.showChangeBillingType = true;
        }
    }

    handleCancel () {

        if (this.coverageSaved) {
            this.dispatchEvent(
                new CustomEvent("modalcloseAndRefresh", { bubbles: true, composed: true })
            );
        } else {
            this.dispatchEvent(
                new CustomEvent("modalclosed", { bubbles: true, composed: true })
            );
        }

    }

    getSettings () {

        return getEntitlementSettings({ objectName: this.sourceObjectName })
            .then (result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }
                this.activeSettingData = result.data;
                this.populateSourceRecord();
                if (this.activeSettingData.allowOverrideSettings) {
                    this.getFieldDescribeResults();
                }
            });

    }

    async getFieldDescribeResults () {

        if ( this._fieldDescribeResult === undefined ) {

            const objectNames = [];
            objectNames.push(this.sourceObjectName);

            try {
                const resp = await getFieldDefinitionsForEntities(objectNames);

                if (resp && resp.data) {

                    const fieldDescribeResult = {};
                    resp.data.forEach( function (item) {
                        fieldDescribeResult[item.apiName] = item;
                    } );

                    this._fieldDescribeResult = fieldDescribeResult;
                }
            } catch (err) {
                this.error = parseErrorMessage(err);
            }
        }
    }

    populateSourceRecord () {
        this.sourceObjectRecordName = this.getSourceRecordName(this.activeSettingData.coveredBy);
        this.sourceObjectRecordId = this.getSourceObjectRecordId(this.activeSettingData.coveredBy);
    }

    getReferenceFieldInfo (referenceFieldName) {

        const referenceFields = [];
        if (this._fieldDescribeResult !== undefined
            && this.activeSettingData.objectAPIName !== undefined) {

            const sourceFieldDefinition
                = this._fieldDescribeResult[this.activeSettingData.objectAPIName];
            sourceFieldDefinition.fieldDefinitions.forEach(function (item) {
                if (item.dataType === 'REFERENCE'
                    && item.referenceTo.length !== 0
                    && item.referenceTo[0] === referenceFieldName ) {
                    referenceFields.push({
                        label: item.label,
                        value: item.apiName,
                    });
                }
            });
        }
        return referenceFields;
    }

    getCoverages () {
        return getServiceCoverages({ sourceRecordId: this.sourceRecordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.coverageData = result.data;
            });
    }

    getListViewData () {

        this.apiInProgress = true;
        Promise.all([this.getSettings(), this.getCoverages()])
            .then(() => {
                this.populateCoverageData();
            })
            .catch(error => {
                this.coverageData = [];
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    populateCoverageData () {

        if (this.coverageData) {
            if (this.coverageData.warrantyList) {
                this.populateWarrantyData();
            }
            if (this.coverageData.contractList) {
                this.populateContractData();
            }
        }

    }

    get notes () {
        return this.entitlementNotes;
    }

    viewWarrantyRecord (event) {
        this.redirectSObjectRecord('AssetWarranty',event.target.target);
    }

    viewTermRecord (event) {
        this.redirectSObjectRecord('WarrantyTerm',event.target.target);
    }

    viewContractRecord (event) {
        this.redirectSObjectRecord('ServiceContract',event.target.target);
    }

    viewEntitlementRecord (event) {
        this.redirectSObjectRecord('Entitlement',event.target.target);
    }

    viewSourceObjectRecord (event) {
        this.redirectSObjectRecord(this.activeSettingData.coveredBy,event.target.target);
    }

    @api
    redirectSObjectRecord (objectName,targetRecordId) {
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: targetRecordId,
                objectApiName: objectName,
                actionName: 'view' },
        };

        if (this.appNavigationType === 'Console') {
            this[NavigationMixin.Navigate](pageRef);
        } else {
            this[NavigationMixin.GenerateUrl](pageRef)
                .then(url => { window.open(url); });
        }
    }

    populateWarrantyData () {

        let warrantyDataRow;
        this.coverageData.warrantyList.forEach(warrantyRow => {

            if (warrantyRow.warrantyTerm) {
                warrantyDataRow = this.getWarrantyMappedTermData(warrantyRow);
            } else {
                warrantyDataRow = this.getWarrantyMappedData(warrantyRow);
            }

            if (warrantyDataRow.id === this._selectedRecordId) {
                warrantyDataRow.checked = true;
                this.noCoverageSelected = false;
                this.noCoverageSelectedClass = 'slds-hint-parent ';
                warrantyDataRow.rowClass += 'slds-is-selected';
                if (warrantyDataRow.remainingDays > 0) {
                    this.showChangeBillingType = false;
                }
            }

            this.populateEndDatePopupData(warrantyDataRow);

            this.warrantyData.push(warrantyDataRow);
        });
        const warranties = [...this.warrantyData];
        this.warrantyCount = this.warrantyData.length;
        this.populateWarrantyList(warranties);

    }

    populateContractData () {

        const contracts = this.getContractMappedData(this.coverageData.contractList);
        let entitlementData;
        contracts.forEach(row => {

            if (row.serviceContractId === this._selectedRecordId) {
                row.checked = true;
                this.showChangeBillingType = false;
                this.noCoverageSelected = false;
                this.noCoverageSelectedClass = 'slds-hint-parent ';
                row.rowClass += 'slds-is-selected';
                if (row.remainingDays > 0) {
                    this.showChangeBillingType = false;
                }
            }

            this.populateEndDatePopupData(row);

            this.contractData.push(row);
            if (row.entitlements) {
                entitlementData = [];
                entitlementData = this.getEntitlementMappedData(row.entitlements);
                entitlementData.forEach(entitlementRow => {

                    if (entitlementRow.id === this._selectedRecordId) {
                        entitlementRow.checked = true;
                        this.noCoverageSelected = false;
                        this.noCoverageSelectedClass = 'slds-hint-parent ';
                        entitlementRow.rowClass += 'slds-is-selected';
                        if (entitlementRow.totalService > entitlementRow.consumedCount &&
                            entitlementRow.remainingDays > 0) {
                            this.showChangeBillingType = false;
                        }
                    }

                    if (entitlementRow.serviceType && entitlementRow.totalService) {
                        entitlementRow.showServiceThreshold = true;
                        if ( entitlementRow.serviceType === 'Amount') {
                            entitlementRow.remainingCountService =
                                this.formattedCurrencyValue(entitlementRow.remainingCount);
                            entitlementRow.consumedCountService =
                                this.formattedCurrencyValue(entitlementRow.consumedCount);
                            entitlementRow.totalCountService =
                                this.formattedCurrencyValue(entitlementRow.totalService);
                            entitlementRow.serviceThreshold =
                                formatString(i18n.serviceCountMessage,
                                    entitlementRow.remainingCountService,
                                    entitlementRow.totalCountService,'');

                        } else {

                            const serviceTypeLabel =
                                    this.getServiceUnitLabel(entitlementRow.serviceType);
                            entitlementRow.serviceThreshold = formatString(i18n.serviceCountMessage,
                                entitlementRow.remainingCount,
                                entitlementRow.totalService,
                                serviceTypeLabel);

                            entitlementRow.remainingCountService =
                                `${entitlementRow.remainingCount} ${serviceTypeLabel}`;
                            entitlementRow.consumedCountService =
                                `${entitlementRow.consumedCount} ${serviceTypeLabel}`;
                            entitlementRow.totalCountService =
                                `${entitlementRow.totalService} ${serviceTypeLabel}`;
                        }
                        if (entitlementRow.consumedCount >= entitlementRow.totalService) {
                            entitlementRow.badgeClass += 'slds-theme_error';
                            entitlementRow.serviceThresholdIcon = 'utility:error';
                            entitlementRow.serviceThresholdIconVariant = 'error';
                        } else if ( entitlementRow.serviceAlertThreshold &&
                            entitlementRow.serviceAlertThreshold <= entitlementRow.consumedCount) {
                            entitlementRow.badgeClass += 'slds-theme_warning';
                            entitlementRow.serviceThresholdIcon = 'utility:warning';
                            entitlementRow.serviceThresholdIconVariant = 'warning';
                        } else {
                            entitlementRow.badgeClass += 'slds-theme_success';
                            entitlementRow.serviceThresholdIcon = 'utility:info_alt';
                            entitlementRow.serviceThresholdIconVariant = '';
                        }
                    } else {
                        entitlementRow.serviceThreshold = i18n.notApplicable;
                    }
                    this.populateEndDatePopupData(entitlementRow);

                    this.contractData.push(entitlementRow);
                });
            }
        });

        const contractRecords = [...this.contractData];
        this.contractCount = this.contractData.length;
        this.populateDisplayContractList(contractRecords);

    }

    formattedCurrencyValue (currencyValue) {
        const formatOptions = {
            style: 'currency',
            currency: this.coverageData.currencyISOCode,
            currencyDisplay: 'symbol'
        }
        return new Intl.NumberFormat(LOCALE, formatOptions).format(currencyValue);
    }

    populateEndDatePopupData (rowData) {

        if (rowData.remainingDays > 90) {
            rowData.showEndDatePopover = false;
            rowData.endDateClass = 'slds-m-left_large';
        }

        else if (rowData.remainingDays === 0) {
            rowData.expiringMessage = i18n.expiringToday;
            rowData.showEndDatePOHeader = false;
            rowData.expiringMessageCSS = 'slds-align_absolute-center ' +
                                         'EverInteractiveEntitlement__remaininghours--font';
        }

        else if (rowData.remainingDays < 0) {
            rowData.expiringMessage = i18n.expiredMessage;
            rowData.showEndDatePOHeader = false;
            rowData.expiringMessageCSS = 'slds-align_absolute-center ' +
                                         'EverInteractiveEntitlement__remaininghours--font';
        }

        else if (rowData.remainingDays < 31) {
            rowData.endDateVariant = 'error';
            rowData.endDateIconClass = 'inverse'
            rowData.endDatePOClass += 'slds-popover_error';
        }

        else if (rowData.remainingDays < 91) {
            rowData.endDateVariant = 'warning';
            rowData.endDatePOClass += 'slds-popover_warning';
        }
    }

    populateWarrantyList (warranties) {
        if (warranties.length > SHOW_ROWS) {
            this.dispWarrantyList = warranties.splice(0,SHOW_ROWS);
            this.showWarrantyViewAll = true;
        } else {
            this.dispWarrantyList = warranties;
            this.warrantyCount = warranties.length;
            this.showWarrantyViewAll = false;
        }
    }

    get warrantyLabel () {
        return `${this.i18n.warranty} (${this.warrantyCount})`;
    }

    populateDisplayContractList (contractRecords) {

        if (contractRecords.length > SHOW_ROWS) {
            this.dispContractList = contractRecords.splice(0,SHOW_ROWS);
            this.showContractViewAll = true;
        } else {
            this.dispContractList = contractRecords;
            this.contractCount = contractRecords.length;
            this.showContractViewAll = false;
        }
    }

    get contractLabel () {
        return `${this.i18n.contract} (${this.contractCount})`;
    }

    selectedCoverage (recordId) {
        if (recordId === this._selectedRecordId) {
            return true;
        }
        return false;
    }

    getWarrantyMappedTermData (row) {

        const warrantyTermRow = {
            entitlementName: null,
            id: row.id,
            name: row.name,
            startDate: row.startDate,
            endDate: row.endDate,
            trackedBy: row.trackedBy,
            trackedByLabel: row.trackedByLabel,
            termName: row.warrantyTerm.name,
            termId: row.warrantyTerm.id,
            warrantyType: row.warrantyType,
            remainingDays: row.remainingDays,
            endDateVariant: null,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'EverInteractiveEntitlement__warranty_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            checked: false,
            rowClass: 'slds-hint-parent '
        }
        return warrantyTermRow;

    }

    getWarrantyMappedData (row) {

        const warrantyRow = {
            entitlementName: null,
            id: row.id,
            name: row.name,
            startDate: row.startDate,
            endDate: row.endDate,
            trackedBy: row.trackedBy,
            trackedByLabel: row.trackedByLabel,
            warrantyType: row.warrantyType,
            remainingDays: row.remainingDays,
            endDateVariant: null,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'EverInteractiveEntitlement__warranty_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            checked: false,
            rowClass: 'slds-hint-parent '

        }
        return warrantyRow;

    }

    getContractMappedData (data) {
        return data.map(row => {return {
            entitlementName: null,
            id: row.id,
            name: row.name,
            startDate: row.startDate,
            endDate: row.endDate,
            trackedBy: row.trackedBy,
            trackedByLabel: row.trackedByLabel,
            entitlements: row.entitlements,
            serviceContractId: row.serviceContractId,
            remainingDays: row.remainingDays,
            endDateVariant: null,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'EverInteractiveEntitlement__contract_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            checked: false,
            rowClass: 'slds-hint-parent '
        }});
    }

    getEntitlementMappedData (data) {
        return data.map(row => {return {
            entitlementName: row.name,
            id: row.id,
            name: null,
            startDate: row.startDate,
            endDate: row.endDate,
            trackedBy: row.trackedBy,
            trackedByLabel: row.trackedByLabel,
            serviceType: row.serviceType,
            remainingCount: row.totalService - row.consumedService,
            consumedCount: row.consumedService,
            totalService: row.totalService,
            remainingCountMessage: formatString(i18n.remainingServiceCountType,row.serviceType),
            consumedCountMessage: formatString(i18n.consumedServiceCountType,row.serviceType),
            serviceAlertThreshold: row.serviceAlertThreshold,
            badgeClass: 'slds-truncate slds-badge ',
            serviceThresholdIcon: null,
            serviceThresholdIconVariant: null,
            showServiceThreshold: false,
            popoverClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                          'EverInteractiveEntitlement__servicethreshold--popover ',
            remainingDays: row.remainingDays,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDateVariant: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'EverInteractiveEntitlement__contract_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            showPopoverWarningIcon: false,
            checked: false,
            remainingCountService: row.totalService - row.consumedService,
            consumedCountService: row.consumedService,
            totalCountService: row.totalService,
            rowClass: 'slds-hint-parent '
        }});
    }

    viewAllWarranties () {
        this.dispWarrantyList = this.warrantyData;
        this.warrantyCount = this.warrantyData.length;
        this.showMatchedViewAll = false;
        this.warrantyLabel = `${this.i18n.warranty} (${this.warrantyCount})`;
    }

    viewAllContracts () {
        this.dispContractList = this.contractData;
        this.contractCount = this.contractData.length;
        this.showContractViewAll = false;
    }

    handleSave () {
        let coverageSaveData = null;
        let selectedCoverageRecord = i18n.incidentNotcovered;
        if (this._selectedRecordId !== i18n.incidentNotcovered) {
            selectedCoverageRecord = this.getCoverageRecord(this._selectedRecordId);
            coverageSaveData = this.getSaveCoverageData(selectedCoverageRecord);
            this.saveSelectedCoverage(coverageSaveData);
        } else {
            coverageSaveData = this.getSaveNoIncidentCoveredData(selectedCoverageRecord);
            this.saveSelectedCoverage(coverageSaveData);
        }

    }

    performRowChecked () {

        const selectedRows = this.template.querySelectorAll("input");
        const selectedId = this.getSelectedId(selectedRows);
        this._selectedRecordId = selectedId;
        this.showChangeBillingType = true;
        this.noCoverageSelected = false;
        this.noCoverageSelectedClass = 'slds-hint-parent ';

        if (selectedId !== i18n.incidentNotcovered) {
            this.dispContractList.forEach(row => {
                row.checked = false;
                row.rowClass = 'slds-hint-parent ';
                if (row.id === this._selectedRecordId) {
                    row.checked = true;
                    row.rowClass += 'slds-is-selected';
                    this.populateContractBillingType(row);
                    if (row.entitlementName && row.totalService &&
                        (row.totalService > row.consumedCount && row.remainingDays > 0)) {
                        this.showChangeBillingType = false;
                    } else if (row.entitlementName == null && row.remainingDays > 0) {
                        this.showChangeBillingType = false;
                    }
                }
            });
            this.dispWarrantyList.forEach(row => {
                row.checked = false;
                row.rowClass = 'slds-hint-parent ';
                if (row.id === this._selectedRecordId) {
                    row.checked = true;
                    row.rowClass += 'slds-is-selected';
                    this.populateWarrantyBillingType(row);
                    if (row.remainingDays > 0) {
                        this.showChangeBillingType = false;
                    }
                }
            });
        } else {
            this.dispContractList.forEach(row => {
                row.checked = false;
                row.rowClass = 'slds-hint-parent ';
            });
            this.dispWarrantyList.forEach(row => {
                row.checked = false;
                row.rowClass = 'slds-hint-parent ';
            });
            this.noCoverageSelected = true;
            this.noCoverageSelectedClass += 'slds-is-selected';
            this.billingTypeValue = this.activeSettingData.defaultBillingType;
        }
    }

    getSelectedId (selectedRows) {

        let foundRow;
        selectedRows.forEach(row => {
            if (row.checked) {
                foundRow = row.value;
            }
        });
        if (foundRow) {
            return foundRow;
        }
        return null;

    }

    getCoverageRecord (selectedId) {
        if (this.coverageData.warrantyList) {
            const foundWarranty = this.coverageData.warrantyList.find(eachTerm =>
                eachTerm.id === selectedId);
            if (foundWarranty) {
                delete foundWarranty.stackRankingFieldValue;
                return foundWarranty;
            }
        }

        if (this.coverageData.contractList) {
            let foundEntitlement;
            this.coverageData.contractList.forEach(eachTerm => {
                if (eachTerm.entitlements) {
                    eachTerm.entitlements.forEach(entitlementRow => {
                        if (entitlementRow.id === selectedId) {
                            foundEntitlement = entitlementRow;
                        }
                    })
                }
                if (eachTerm.id === selectedId) {
                    foundEntitlement = eachTerm;
                }
            });
            if (foundEntitlement) {
                return foundEntitlement;
            }
        }

        return null;
    }

    getSaveCoverageData (selectedCoverageRecord) {
        const notes = this.template.querySelector("lightning-textarea");
        return {
            coveredBy: this.coverageData.coveredBy,
            selectedCoverage: selectedCoverageRecord,
            entitlementNotes: notes.value,
            billingType: this.billingTypeValue
        }
    }

    getSaveNoIncidentCoveredData () {
        const entNotes = this.template.querySelector("lightning-textarea");
        return {
            entitlementNotes: entNotes.value,
            billingType: this.billingTypeValue
        }
    }

    saveSelectedCoverage (coverageSaveData) {
        this.apiInProgress = true;
        saveServiceCoverage({
            sourceRecordId: this.sourceRecordId,
            requestJson: JSON.stringify(coverageSaveData)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const evt = new ShowToastEvent({
                    title: this.i18n.updateSuccess,
                    variant: 'success',
                });
                this.coverageSaved = true;
                this.dispatchEvent(evt);
                this.handleCancel();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    handleFilter () {
        this.panelOpen = !this.panelOpen;
    }

    handleValueChange (event) {
        this.activeSettingData[event.target.name] = (event.target.type === 'checkbox')
            ? event.target.checked
            : event.target.value;
    }

    handleApplyFilter () {
        this.apiInProgress = true;
        getServiceCoveragesForSettings({
            sourceRecordId: this.sourceRecordId,
            requestJson: JSON.stringify(this.activeSettingData)
        })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.error = null;
                this.resetValues();
                this.populateSourceRecord();
                this.coverageData = result.data;
                this.populateCoverageData();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    resetValues () {
        this.coverageData = [];
        this.warrantyData = [];
        this.contractData = [];
        this.dispWarrantyList = [];
        this.dispContractList = [];
        this.noCoverageSelected = true;
        this.showChangeBillingType = true;
        this.showContractViewAll = false;
        this.showWarrantyViewAll = false;
        this.warrantyCount = 0;
        this.contractCount = 0;
        this.coverageSaved = false;
        this.noCoverageSelectedClass = 'slds-hint-parent slds-is-selected';
        this.error = null;
    }

    showPopover (event) {
        const targetId = event.currentTarget.getAttribute('data-id');
        const sectionHighlighted = this.template.querySelector(`section[data-id="${targetId}"]`);
        const isHidden = sectionHighlighted.classList.contains('slds-hide');
        classListMutation(sectionHighlighted.classList, {
            'slds-hide': !isHidden,
            'slds-show': isHidden
        });
    }

    showEndDataPopover (event) {
        const targetId = event.currentTarget.getAttribute('data-contract');
        const sectionHighlighted =
            this.template.querySelector(`section[data-contract="${targetId}"]`);
        const isHidden = sectionHighlighted.classList.contains('slds-hide');
        classListMutation(sectionHighlighted.classList, {
            'slds-hide': !isHidden,
            'slds-show': isHidden
        });
    }

    hidePopover (event) {
        const targetId = event.currentTarget.getAttribute('data-id');
        const sectionHighlighted = this.template.querySelector(`section[data-id="${targetId}"]`);
        const isVisible = sectionHighlighted.classList.contains('slds-show');
        classListMutation(sectionHighlighted.classList, {
            'slds-show': !isVisible,
            'slds-hide': isVisible
        });
    }

    hideEndDatePopover (event) {
        const targetId = event.currentTarget.getAttribute('data-contract');
        const sectionHighlighted =
            this.template.querySelector(`section[data-contract="${targetId}"]`);
        const isVisible = sectionHighlighted.classList.contains('slds-show');
        classListMutation(sectionHighlighted.classList, {
            'slds-show': !isVisible,
            'slds-hide': isVisible
        });
    }

    handleCancelModal () {
        this._billingTypeValue = this.billingTypeValue;
        this.billingTypeModalOpen = false;
    }

    openBillingTypeModal () {
        this._billingTypeValue = this.billingTypeValue;
        this.billingTypeModalOpen = true;
    }

    handleUpdateBillingModal () {
        this.billingTypeValue = this._billingTypeValue;
        this.billingTypeModalOpen = false;
    }

    handleBillingTypeChange (event) {
        this._billingTypeValue = event.detail.value;
    }

    populateWarrantyBillingType (rowData) {
        this.billingTypeValue = 'Warranty';
        this._billingTypeValue = this.billingTypeValue;
        this.populateDefaultBillingTye(rowData);
    }

    populateContractBillingType (rowData) {
        this.billingTypeValue = 'Contract';
        this._billingTypeValue = this.billingTypeValue;
        this.populateDefaultBillingTye(rowData);
    }

    populateDefaultBillingTye (rowData) {
        if (rowData.remainingDays <= 0) {
            this.billingTypeValue = this.activeSettingData.defaultBillingType;
            this._billingTypeValue = this.billingTypeValue;
        }
    }

    get computedPanelCSS () {
        let css = 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right ';
        if (this.panelOpen) {
            css += 'slds-is-open';
        }
        return css;
    }

    get computedVariant () {
        let css;
        if (this.panelOpen) {
            css = 'brand';
        }
        return css;
    }

    get coveredByOptions () {
        return [
            { label: i18n.account, value: ACCOUNT },
            { label: i18n.asset, value: ASSET },
        ];
    }

    get matchAccountLabel () {
        let matchAccountVal = `${i18n.matchAccount} ${this.activeSettingData.objectAPIName}`;
        if (this.activeSettingData.objectAPIName === 'WorkOrder') {
            matchAccountVal =  `${i18n.matchAccount} ${i18n.workOrder}`;
        } else if (this.activeSettingData.objectAPIName === 'ReturnOrder') {
            matchAccountVal = `${i18n.matchAccount} ${i18n.returnOrder}`;
        }
        return matchAccountVal;
    }

    get accountAPINames () {
        return this.getReferenceFieldInfo(ACCOUNT);
    }

    get showAccount () {
        return (this.activeSettingData.coveredBy === ASSET
            && this.activeSettingData.matchAccount === false ) ? false : true;
    }

    get showComponent () {
        return (this.activeSettingData.coveredBy !== undefined
            && this.activeSettingData.coveredBy === ASSET ) ? true : false;
    }

    getSourceObjectRecordId (coveredByObject) {
        let recordId;

        if (coveredByObject) {
            if (coveredByObject === ASSET && this.assetInfo) {
                recordId = this.assetInfo.Id;
            } else if (coveredByObject === ACCOUNT && this.accountInfo) {
                recordId = this.accountInfo.Id;
            }
        }

        return recordId;
    }

    getSourceRecordName (coveredByObject) {
        let recordName;

        if (coveredByObject) {
            if (coveredByObject === ASSET && this.assetInfo) {
                recordName = this.assetInfo.Name;
            } else if (coveredByObject === ACCOUNT && this.accountInfo) {
                recordName = this.accountInfo.Name;
            }
        }

        return recordName;
    }

    get assetAPINames () {
        return this.getReferenceFieldInfo(ASSET);
    }

    get showFilter () {
        return this.activeSettingData.allowOverrideSettings;
    }

    previewWarrantyRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'AssetWarranty',
                event.target, null, event.target.title);
    }

    previewContractRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'ServiceContract',
                event.target,null, event.target.title);
    }

    previewEntitlementRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'Entitlement',event.target,null, event.target.title);
    }

    previewWarrantyTermRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'WarrantyTerm',event.target,null, event.target.title);
    }

    previewSourceRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,this.activeSettingData.coveredBy,
                event.target,null, event.target.title);
    }

    handleMouseOut () {
        this.template.querySelector('c-svmx-record-popover').hidePopover ();
    }
}