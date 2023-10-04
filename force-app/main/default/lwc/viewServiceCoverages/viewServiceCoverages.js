import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { parseErrorMessage, verifyApiResponse, classListMutation,
    formatString, isNotUndefinedOrNull, isUndefinedOrNull, debounce } from 'c/utils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getFieldDefinitionsForEntities } from 'c/metadataService';
import getServiceCoveragesForSettings
    from '@salesforce/apex/EVER_InteractiveEntitlement_LS.getServiceCoveragesForSettings';
import getSourceRecord
    from '@salesforce/apex/CONF_QueryLightningService.queryRecords';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/RecordSelection__c';

import labelServiceCoverage from '@salesforce/label/c.Title_ServiceCoverage';
import labelWarranty from '@salesforce/label/c.Label_Warranty';
import labelCoverage from '@salesforce/label/c.Label_Coverage';
import labelStartDate from '@salesforce/label/c.Label_StartDate';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelTerm from '@salesforce/label/c.Label_Term';
import labelWarrantyType from '@salesforce/label/c.Label_WarrantyType';
import labelCoveredBy from '@salesforce/label/c.Label_CoveredBy';
import labelEntitledService from '@salesforce/label/c.Label_EntitledService';
import labelContract from '@salesforce/label/c.Label_Contract';
import TIMEZONE from '@salesforce/i18n/timeZone';
import labelServiceUtilization from '@salesforce/label/c.Label_ServiceUtilization';
import labelRemainingServiceCountType from '@salesforce/label/c.Label_RemainingServiceCountType';
import labelConsumedServiceCountType from '@salesforce/label/c.Label_ConsumedServiceCountType';
import labelServiceCount from '@salesforce/label/c.Label_ServiceCount';
import labelExpiringSoon from '@salesforce/label/c.Label_ExpiringSoon';
import labelExpiringMessage from '@salesforce/label/c.Message_ExpiringWithoutBrackets';
import labelExpired from '@salesforce/label/c.Label_Expired';
import labelServiceCountMessage from
    '@salesforce/label/c.Message_ServiceCountMessageWithoutBrackets';
import labelNotApplicable from '@salesforce/label/c.Label_NotApplicable';
import labelServiceConsumption from '@salesforce/label/c.Label_ServiceConsumption';
import labelTotal from '@salesforce/label/c.Label_Total';
import labelConsumed from '@salesforce/label/c.Label_Consumed';
import labelRemaining from '@salesforce/label/c.Label_Remaining';
import labelNoDataHeading from '@salesforce/label/c.Message_NoData_Heading';
import labelNoDataBody from '@salesforce/label/c.Message_ViewCoverage_NoData_Body';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelRecordNotExists from '@salesforce/label/c.Error_RecordNotExists';
import labelErrorHeading from '@salesforce/label/c.Message_AssetTimeline_Error_Heading';
import labelErrorBody from '@salesforce/label/c.Message_AssetTimeline_Error_Body';
import labelSidebarError from '@salesforce/label/c.Message_ViewCoverage_Sidebar_Error';
import labelNoCoverageFound from '@salesforce/label/c.Info_NoCoverageFound'
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
import labelOptions from '@salesforce/label/c.Label_Options'
import labelDiscount from '@salesforce/label/c.Label_Discount'
import labelSurcharge from '@salesforce/label/c.Label_Surcharge';
import labelPrice from '@salesforce/label/c.Label_Price';
import labelPricingMessage from '@salesforce/label/c.Message_CPLIPricing';
import labelContractLine from '@salesforce/label/c.Label_ContractLine';


import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CURRENCY from '@salesforce/i18n/currency';
import LOCALE from '@salesforce/i18n/locale';
import ENTITLEMENT_OBJECT from '@salesforce/schema/Entitlement'
import SERVICE_UNIT_FIELD from '@salesforce/schema/Entitlement.ServiceCountType__c';
import lblToastTitleError from '@salesforce/label/c.Title_Toast_Error_in_Warranty';

const i18n = {
    serviceCoverage: labelServiceCoverage,
    warranty: labelWarranty,
    coverage: labelCoverage,
    startDate: labelStartDate,
    endDate: labelEndDate,
    term: labelTerm,
    warrantyType: labelWarrantyType,
    coveredBy: labelCoveredBy,
    entitledService: labelEntitledService,
    contract: labelContract,
    timeZone: TIMEZONE,
    remainingServiceCountType: labelRemainingServiceCountType,
    consumedServiceCountType: labelConsumedServiceCountType,
    serviceCount: labelServiceCount,
    expiringSoon: labelExpiringSoon,
    expiringMessage: labelExpiringMessage,
    expiredMessage: labelExpired,
    serviceCountMessage: labelServiceCountMessage,
    notApplicable: labelNotApplicable,
    serviceConsumption: labelServiceConsumption,
    total: labelTotal,
    consumed: labelConsumed,
    remaining: labelRemaining,
    currencyCode: CURRENCY,
    lblToastTitleError: lblToastTitleError,
    noDataHeading: labelNoDataHeading,
    noDataBody: labelNoDataBody,
    loading: labelLoading,
    recordNotExists: labelRecordNotExists,
    errorHeading: labelErrorHeading,
    errorBody: labelErrorBody,
    sidebarError: labelSidebarError,
    serviceUtilization: labelServiceUtilization,
    noCoverageFound: labelNoCoverageFound,
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
    apply: labelApply,
    options: labelOptions,
    discount: labelDiscount,
    surcharge: labelSurcharge,
    price: labelPrice,
    pricingMessage: labelPricingMessage,
    contractLine: labelContractLine
}

const SHOW_ROWS = 7;
const MAX_ROWS = 14;
const ASSET = 'Asset';
const ACCOUNT = 'Account';
const MIN_WIDTH = 700;

export default class ServiceCoverages extends NavigationMixin (LightningElement) {
    @api recordId;
    @api objectApiName;
    @api appNavigationType;
    @api assetField;
    @api flexipageRegionWidth;
    @api isInCommunity;

    @track error;
    @track apiInProgress = false;
    @track assetId;
    @track showIllustration = false;
    @track showModal = false;
    @track activeSettingData = {};

    @wire(MessageContext)
    messageContext;

    assetName;
    allowDisplay = true;
    activeSections = ['warrantySection', 'contractSection'];
    coverageData = [];
    dispWarrantyList = [];
    dispContractList = [];
    contractCount = 0;
    warrantyCount = 0;
    hasContractData = true;
    hasWarrantyData = true;
    illustrationImageName;
    illustrationHeading;
    illustrationMessage;
    regionIsSmall;
    warrantyStyle = '';
    contractStyle = '';
    _fieldDescribeResult;
    _referenceNameToQuery;
    sourceObjectLabel;
    sourceObjectRecordName;
    sourceObjectRecordId;
    coveredByFieldLabel = '';
    entitlementRecordType;
    _componentWidth = MIN_WIDTH;

    lookupInfo = {
        relationshipName: '',
        referenceNameField: '',
        referenceNameToQuery: ''
    }
    showDatePopver = false;

    popoverData = {
        id: '',
        showPO: '',
        endDatePOStyle: '',
        endDatePOClass: 'slds-hide',
        showEndDatePOHeader: '',
        expiringMessage: '',
        expiringMessageCSS: '',
        endDateIconClass: ''
    }

    thresholdData = {
        id: '',
        popoverClass: 'slds-hide',
        totalCountService: '',
        consumedCountService: '',
        badgeClass: '',
        remainingCountService: '',
        thresholdPOStyle: ''
    }

    @wire (getObjectInfo, {
        objectApiName: ENTITLEMENT_OBJECT
    })
    entitlementInfo;
    serviceUnitOptions = [];

    //get all picklist values
    @wire( getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
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

    get defaultRecordTypeId () {
        this.entitlementRecordType = this.entitlementInfo?.data?.defaultRecordTypeId;
        return this.entitlementRecordType;
    }

    get i18n () {
        return i18n;
    }

    get objectFieldForWire () {
        if (isNotUndefinedOrNull(this.objectApiName) &&
            isNotUndefinedOrNull(this.assetField) &&
            isNotUndefinedOrNull(this.serviceUnitOptions) &&
            this.serviceUnitOptions.length !== 0 ) {
            return `${this.objectApiName}.${this.assetField}`;
        }
        return null;
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$objectFieldForWire' })
    wiredObjectRecord ({ error, data }) {
        if (data) {
            const assetFieldValue = getFieldValue(data, this.objectFieldForWire);
            if (isNotUndefinedOrNull(assetFieldValue)) {
                this.assetId = assetFieldValue;
                this.regionIsSmall = (this.flexipageRegionWidth === 'SMALL') ? true : false ;
                if ( this.regionIsSmall ) {
                    this.error = i18n.sidebarError;
                    return;
                }
                this.resetValues();
                this.setDefaultSettingData( this.assetField );
                this.getListViewData(this.recordId);
            } else {
                this.apiInProgress = true;
                const displayNoData = debounce(() => {
                    try {
                        this.clearState();
                        this.updateIllustrationForDataResponse();
                    }
                    finally {
                        this.apiInProgress = false;
                    }
                }, 300)

                displayNoData();
            }
        } else if (error) {
            this.handleError(error);
        }
    }

    get regionsIsSmall () {
        return ( this.flexipageRegionWidth === 'SMALL' );
    }

    resetValues () {
        this.coverageData = [];
        this.dispWarrantyList = [];
        this.dispContractList = [];
        this.warrantyCount = 0;
        this.contractCount = 0;
        this.error = null;
        this.hasWarrantyData = true;
        this.hasContractData = true;
    }

    handleError (error) {
        this.error = parseErrorMessage(error);

        if (error
            && error.message
            && error.message.trim().toUpperCase() === i18n.recordNotExists.toUpperCase()) {
            this.updateIllustrationForDataResponse();
        } else if (error?.body?.errorCode === 'INVALID_FIELD') {
            this.updateIllustration(
                true,
                'error:page_not_available',
                i18n.errorHeading,
                formatString(i18n.invalidField, this.objectApiName, this.assetField)
            );
        } else {
            this.updateIllustration(
                true,
                'error:page_not_available',
                i18n.errorHeading,
                i18n.errorBody
            );
        }
    }

    connectedCallback () {
        this.subscribeToMessageChannel();
    }

    get canvasEl () {
        return this.template.querySelector('.svmx_view_service_coverage');
    }

    renderedCallback () {
        this._componentWidth = this.canvasEl.getBoundingClientRect().width;
        if ( this.isInCommunity && this._componentWidth < MIN_WIDTH ) {
            this.error = i18n.sidebarError;
        }
    }

    disconnectedCallback () {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel () {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel () {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage (message) {
        if (message.source === 'c/assetHierarchy' &&
            message.recordId !== this.assetId &&
            message.sourceId === this.recordId) {
            this.assetId = message.recordId;
            this.resetValues();
            this.setDefaultSettingData('Id');
            this.getListViewData(this.assetId);
        }
    }

    clearState () {
        this.assetId = undefined;
        this.assetName = undefined;
        this.coverageData = undefined;
    }

    populateAssetRecord () {
        const fieldsToQuery = ['Id', 'Name'];
        const reqObject ={
            objectName: ASSET,
            fields: fieldsToQuery,
            id: this.assetId
        };
        getSourceRecord({
            requestJson: JSON.stringify(reqObject)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                if (result.data.length !== 0) {
                    this.assetName = result.data[0].Name;
                }
            })
            .catch(error => {
                this.coverageData = [];
                this.error = parseErrorMessage(error);
            })
    }

    getListViewData ( srcRecordId ) {
        this.apiInProgress = true;
        Promise.all([this.populateAssetRecord(), this.getCoverages(srcRecordId)])
            .then(() => {
                this.populateCoverageData();
                this.updateIllustrationForDataResponse();
                this.populateReferenceNameField(this.activeSettingData.coveredBy);
                this.populateSourceRecordForAsset();
            })
            .catch(error => {
                this.coverageData = [];
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                if (this.warrantyCount === 0 ) {
                    this.hasWarrantyData = false;
                }
                if (this.contractCount === 0 ) {
                    this.hasContractData = false;
                }
                this.apiInProgress = false;
            });
    }

    getCoverages (srcRecordId) {
        return getServiceCoveragesForSettings({
            sourceRecordId: srcRecordId,
            requestJson: JSON.stringify(this.activeSettingData)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.coverageData = result.data;
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
            this.calculateHeight ();
        }
    }

    populateSourceRecordForAsset () {
        this.sourceObjectRecordId = this.assetId;
        this.sourceObjectRecordName = this.assetName;
    }

    viewSourceObjectRecord (event) {
        this.redirectSObjectRecord(this.activeSettingData.coveredBy,event.target.target);
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

    viewCPLIRecord (event) {
        this.redirectSObjectRecord('SVMXA360__ContractPriceLineItem__c',event.target.target);
    }

    viewAssetRecord (event) {
        this.redirectSObjectRecord('Asset', event.target.target);
    }

    viewAccountRecord (event) {
        this.redirectSObjectRecord('Account', event.target.target);
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
        const warrantyData = [];
        this.coverageData.warrantyList.forEach(warrantyRow => {

            if (warrantyRow.warrantyTerm) {
                warrantyDataRow = this.getWarrantyMappedTermData(warrantyRow);
            } else {
                warrantyDataRow = this.getWarrantyMappedData(warrantyRow);
            }
            this.populateEndDatePopupData(warrantyDataRow);
            warrantyData.push(warrantyDataRow);
        });
        const warranties = [...warrantyData];
        this.warrantyCount = warrantyData.length;
        this.dispWarrantyList = warranties;
    }

    populateContractData () {
        const contracts = this.getContractMappedData(this.coverageData.contractList);
        const contractSetSize = contracts.length;
        const contractData = [];

        let entitlementData;
        contracts.forEach(row => {

            row.setPosition = contracts.indexOf(row) + 1;
            row.setSize = contractSetSize;
            this.populateEndDatePopupData(row);

            if (!row.entitlements) {
                row.iconName = '';
            }
            contractData.push(row);
            if (row.entitlements) {
                const entitlementSetSize = row.entitlements.length;
                entitlementData = [];
                entitlementData = this.getEntitlementMappedData(row.entitlements);
                entitlementData.forEach(entitlementRow => {

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
                            entitlementRow.isExpired = true;
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

                    entitlementRow.setPosition = entitlementData.indexOf(entitlementRow) + 1;
                    entitlementRow.setSize = entitlementSetSize;
                    this.populateEndDatePopupData(entitlementRow);

                    if (!entitlementRow.contractPriceLineItems) {
                        entitlementRow.iconName = '';
                    }

                    contractData.push(entitlementRow);

                    //process CPLI records
                    if ( entitlementRow.contractPriceLineItems) {
                        const cpliSetSize = entitlementRow.contractPriceLineItems.length;
                        let cpliData = [];
                        cpliData = this.getcpliMappedData(entitlementRow.contractPriceLineItems);
                        const expiredEntitlement = entitlementRow.isExpired;

                        cpliData.forEach(cpliRow => {
                            let pricingInfo = '';
                            if (cpliRow.productName ) {
                                pricingInfo = cpliRow.productName;
                            } else if (cpliRow.productFamily) {
                                pricingInfo = cpliRow.productFamily;
                            } else if (cpliRow.expenseItem) {
                                pricingInfo = cpliRow.lineType + ' (' + cpliRow.expenseItem + ')';
                            } else {
                                pricingInfo = cpliRow.lineType;
                            }
                            if (cpliRow.price) {
                                pricingInfo = formatString(i18n.pricingMessage,pricingInfo,
                                    (cpliRow.contractLineItemId != null ? i18n.contractLine+' '+
                                        i18n.price : i18n.price),this.formattedCurrencyValueCPLI(
                                        cpliRow.price,cpliRow.currencyCode) );
                            } else if (cpliRow.discount) {
                                pricingInfo = formatString(i18n.pricingMessage,pricingInfo,
                                    (cpliRow.contractLineItemId != null ? i18n.contractLine+' '+
                                        i18n.discount : i18n.discount),  cpliRow.discount + '%');
                            } else if (cpliRow.surcharge) {
                                pricingInfo = formatString(i18n.pricingMessage,pricingInfo,
                                    (cpliRow.contractLineItemId != null ? i18n.contractLine+' '+
                                    i18n.surcharge : i18n.surcharge),  cpliRow.surcharge + '%' );
                            }
                            cpliRow.displayMessage = pricingInfo;
                            cpliRow.setPosition = cpliData.indexOf(cpliRow) + 1;
                            cpliRow.setSize = cpliSetSize;

                            cpliRow.isExpired = expiredEntitlement;
                            if (expiredEntitlement) {
                                cpliRow.nameStyle += 'color:grey;'
                            }

                            contractData.push(cpliRow);
                        });
                    }

                });
            }
        });

        const contractRecords = [...contractData];
        this.contractCount = contractData.length;
        this.dispContractList = contractRecords;
    }

    formattedCurrencyValue (currencyValue) {
        const formatOptions = {
            style: 'currency',
            currency: this.coverageData.currencyISOCode,
            currencyDisplay: 'symbol'
        }
        return new Intl.NumberFormat(LOCALE, formatOptions).format(currencyValue);
    }

    formattedCurrencyValueCPLI (currencyValue, code) {
        const formatOptions = {
            style: 'currency',
            currency: code, //currencyIsocode
            currencyDisplay: 'symbol'
        }
        return new Intl.NumberFormat(LOCALE, formatOptions).format(currencyValue);
    }

    populateEndDatePopupData (rowData) {

        if (rowData.remainingDays > 90) {
            rowData.showEndDatePopover = false;
            rowData.endDateClass = 'slds-m-left_large';
        }

        else if (rowData.remainingDays <= 0) {
            rowData.expiringMessage = i18n.expiredMessage;
            rowData.showEndDatePOHeader = false;
            rowData.expiringMessageCSS = 'slds-align_absolute-center ' +
                                         'ViewServiceCoverages__remaininghours--font ';
            rowData.isExpired = true;
        }

        else if (rowData.remainingDays < 31) {
            rowData.endDateVariant = 'error';
            rowData.endDateIconClass = 'inverse'
            rowData.endDatePOClass += 'slds-popover_error ';
        }

        else if (rowData.remainingDays < 91) {
            rowData.endDateVariant = 'warning';
            rowData.endDatePOClass += 'slds-popover_warning ';
        }
    }

    get warrantyLabel () {
        return `${this.i18n.warranty} (${this.warrantyCount})`;
    }

    get headerLabel () {
        return `${this.i18n.serviceCoverage} - `;
    }

    get contractLabel () {
        return `${this.i18n.contract} (${this.contractCount})`;
    }

    getWarrantyMappedTermData (row) {

        const warrantyTermRow = {
            entitlementName: null,
            id: row.id,
            name: row.name,
            startDate: row.startDate,
            endDate: row.endDate,
            trackedBy: row.trackedBy,
            termName: row.warrantyTerm.name,
            termId: row.warrantyTerm.id,
            warrantyType: row.warrantyType,
            remainingDays: row.remainingDays,
            endDateVariant: null,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'ViewServiceCoverages__warranty_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            checked: false,
            rowClass: 'slds-hint-parent ',
            assetId: row.assetId,
            accountId: row.accountId
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
            warrantyType: row.warrantyType,
            remainingDays: row.remainingDays,
            endDateVariant: null,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'ViewServiceCoverages__warranty_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            checked: false,
            rowClass: 'slds-hint-parent ',
            assetId: row.assetId,
            accountId: row.accountId

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
            entitlements: row.entitlements,
            serviceContractId: row.serviceContractId,
            remainingDays: row.remainingDays,
            endDateVariant: null,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'ViewServiceCoverages__contract_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            checked: false,
            iconName: 'utility:chevrondown',
            nameStyle: 'margin-left:5px;',
            rowStyle: 'slds-hint-parent ',
            treeLevel: 1,
            setPosition: row.setPosition,
            setSize: row.setSize,
            isExpanded: true,
            assetId: row.assetId,
            accountId: row.accountId,
            isCPLI: false
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
                          'ViewServiceCoverages__servicethreshold--popover ',
            remainingDays: row.remainingDays,
            expiringMessage: formatString(i18n.expiringMessage,row.remainingDays),
            expiringMessageCSS: null,
            endDateVariant: null,
            endDatePOClass: 'slds-popover slds-nubbin_bottom slds-popover_full-width slds-hide ' +
                            'ViewServiceCoverages__contract_enddate--popover ',
            endDateIconClass: null,
            showEndDatePopover: true,
            showEndDatePOHeader: true,
            endDateClass: null,
            showPopoverWarningIcon: false,
            checked: false,
            remainingCountService: row.totalService - row.consumedService,
            consumedCountService: row.consumedService,
            totalCountService: row.totalService,
            nameStyle: 'margin-left:40px;',
            accordianStyle: 'margin-left:35px;',
            rowStyle: 'slds-hint-parent ',
            treeLevel: 2,
            setPosition: row.setPosition,
            setSize: row.setSize,
            isExpanded: true,
            contractLineItemId: row.contractLineItemId,
            assetId: row.assetId,
            accountId: row.accountId,
            contractPriceLineItems: row.contractPriceLineItems,
            isCPLI: false,
            iconName: 'utility:chevrondown',
            isExpired: false
        }});
    }

    getcpliMappedData (data) {
        return data.map(row => {return {
            id: row.id,
            name: row.name,
            contractLineItemId: row.contractLineItemId,
            entitledServiceId: row.entitledServiceId,
            lineType: row.lineType,
            productName: row.productName,
            productFamily: row.productFamily,
            discount: row.entitledDiscount,
            price: row.entitledPrice,
            surcharge: row.surcharge,
            expenseItem: row.expenseItem,
            currencyCode: row.currencyCode,
            isCPLI: true,
            treeLevel: 3,
            setPosition: row.setPosition,
            setSize: row.setSize,
            rowStyle: 'slds-hint-parent ',
            isExpanded: true,
            entitlementName: null,
            nameStyle: 'margin-left:75px;'
        }});
    }

    showOrHideChildrenRows (event) {
        const rowId = event.target.dataset.rowid;
        const isExpanded = event.target.dataset.expanded;
        event.target.dataset.expanded = JSON.stringify(!JSON.parse(isExpanded));
        this.dispContractList = this.dispContractList.map((obj) => {
            if ( obj.entitlementName &&
                    obj.contractLineItemId === rowId && !JSON.parse(isExpanded)) {
                event.target.iconName = JSON.parse(isExpanded) ?
                    "utility:chevronright": "utility:chevrondown";
                obj.rowStyle = "";
                obj.isExpanded = "true";
            }
            if ( (obj.entitlementName &&
                    obj.contractLineItemId === rowId && JSON.parse(isExpanded) ) ||
                    (obj.isCPLI && obj.contractLineItemId === rowId && JSON.parse(isExpanded) )) {
                event.target.iconName = JSON.parse(isExpanded) ?
                    "utility:chevronright": "utility:chevrondown";
                obj.rowStyle = "slds-hide";
                obj.isExpanded = "false";
                obj.iconName = JSON.parse(isExpanded) ?
                    "utility:chevronright": "utility:chevrondown";
            }
            return obj;
        });
    }

    showOrHideCPLIRows (event) {
        const rowId = event.target.dataset.rowid;
        const isExpanded = event.target.dataset.expanded;
        event.target.dataset.expanded = JSON.stringify(!JSON.parse(isExpanded));

        this.dispContractList = this.dispContractList.map((obj) => {
            if (obj.isCPLI &&
                    obj.entitledServiceId === rowId && !JSON.parse(isExpanded)) {
                event.target.iconName = JSON.parse(isExpanded) ?
                    "utility:chevronright": "utility:chevrondown";
                obj.rowStyle = "";
                obj.isExpanded = "true";
            }
            if (obj.isCPLI &&
                    obj.entitledServiceId === rowId && JSON.parse(isExpanded)) {
                event.target.iconName = JSON.parse(isExpanded) ?
                    "utility:chevronright": "utility:chevrondown";
                obj.rowStyle = "slds-hide";
                obj.isExpanded = "false";
            }
            return obj;
        });
    }

    showEndDataPopover (eachRecord) {
        const eachRecordData = {};
        if (eachRecord) {
            eachRecordData.id = eachRecord.id;
            eachRecordData.showPO = eachRecord.showEndDatePopover;
            eachRecordData.endDatePOClass = eachRecord.endDatePOClass;
            eachRecordData.showEndDatePOHeader = eachRecord.showEndDatePOHeader;
            eachRecordData.expiringMessage = eachRecord.expiringMessage;
            eachRecordData.expiringMessageCSS = eachRecord.expiringMessageCSS;
            eachRecordData.endDateIconClass = eachRecord.endDateIconClass;

            //fetch position
            const iconHighlighted =
                this.template.querySelector(`lightning-icon[data-id="${eachRecordData.id}"]`);
            const leftPosition = 30;
            const withHeaderPosition = 50;
            let top = iconHighlighted.getBoundingClientRect().top - (leftPosition + 10) ;
            let left = iconHighlighted.getBoundingClientRect().left - leftPosition;
            if (eachRecordData.showEndDatePOHeader === true) {
                top -= withHeaderPosition;
                left -= withHeaderPosition;
            }
            eachRecordData.endDatePOStyle =`position:fixed;transform:translate(${left}px,${top}px);`
            eachRecordData.endDatePOStyle += 'inset:0px auto auto 0px;width:auto;';
            this.popoverData = eachRecordData;

            const sectionHighlighted =
                this.template.querySelector('section[data-id="svmx-popover-section"]');
            const isHidden = sectionHighlighted.classList.contains('slds-hide');
            classListMutation(sectionHighlighted.classList, {
                'slds-hide': !isHidden,
                'slds-show': isHidden
            });
        }
    }
    warrantyEndDatePopover (event) {
        const targetId = event.currentTarget.getAttribute('data-id');
        const eachRecord = this.dispWarrantyList.find( item => item.id === targetId);
        this.showEndDataPopover (eachRecord);
    }
    contractEndDatePopover (event) {
        const targetId = event.currentTarget.getAttribute('data-id');
        const eachRecord = this.dispContractList.find( item => item.id === targetId);
        this.showEndDataPopover (eachRecord);
    }

    hideEndDatePopover () {
        const sectionHighlighted =
                this.template.querySelector('section[data-id="svmx-popover-section"]');
        const isVisible = sectionHighlighted.classList.contains('slds-show');
        classListMutation(sectionHighlighted.classList, {
            'slds-show': !isVisible,
            'slds-hide': isVisible
        });
    }

    showThresholdPopover (event) {
        const targetId = event.currentTarget.getAttribute('data-contract');
        const eachRecord = this.dispContractList.find( item => item.id === targetId);

        const eachRecordData = {};
        if (eachRecord) {
            eachRecordData.id = eachRecord.id;
            eachRecordData.popoverClass = eachRecord.popoverClass;
            eachRecordData.totalCountService = eachRecord.totalCountService;
            eachRecordData.consumedCountService = eachRecord.consumedCountService;
            eachRecordData.badgeClass = eachRecord.badgeClass;
            eachRecordData.remainingCountService = eachRecord.remainingCountService;

            //fetch position
            const iconHighlighted =
                this.template.querySelector(`lightning-icon[data-contract="${eachRecordData.id}"]`);
            const requiredPosition = 90;
            const requiredTopPosition = 150;
            const top = iconHighlighted.getBoundingClientRect().top - requiredTopPosition;
            const left = iconHighlighted.getBoundingClientRect().left - requiredPosition;
            eachRecordData.thresholdPOStyle
                =`position:fixed;transform:translate(${left}px,${top}px);`
            eachRecordData.thresholdPOStyle += 'inset:0px auto auto 0px;width:auto;';
            this.thresholdData = eachRecordData;

            const sectionHighlighted =
                this.template.querySelector('section[data-id="svmx-threshold-popover-section"]');
            const isHidden = sectionHighlighted.classList.contains('slds-hide');
            classListMutation(sectionHighlighted.classList, {
                'slds-hide': !isHidden,
                'slds-show': isHidden
            });
        }
    }

    hideThresholdPopover () {
        const sectionHighlighted =
                this.template.querySelector('section[data-id="svmx-threshold-popover-section"]');
        const isVisible = sectionHighlighted.classList.contains('slds-show');
        classListMutation(sectionHighlighted.classList, {
            'slds-show': !isVisible,
            'slds-hide': isVisible
        });
    }

    get hasCoverageData () {
        return (this.contractCount > 0 || this.warrantyCount > 0);
    }

    updateIllustration (show, imageName, heading, message) {
        this.showIllustration = show;

        if (imageName) {
            this.illustrationImageName = imageName;
        }

        if (heading) {
            this.illustrationHeading = heading;
        }

        if (message) {
            this.illustrationMessage = message;
        }
    }

    updateIllustrationForDataResponse () {
        if (this.hasCoverageData) {
            this.updateIllustration(false);
        } else {
            this.showNoDataIllustration();
        }
    }

    showNoDataIllustration () {
        this.updateIllustration(
            true,
            'no_data:open_road',
            i18n.noDataHeading,
            i18n.noDataBody
        );
    }

    calculateHeight () {
        let maxheight = 210;
        const rowHeight = 30;
        const halfRowHeight = 20;
        let height = ( SHOW_ROWS * rowHeight );

        this.warrantyStyle = 'height: auto;overflow: auto;max-height:' + maxheight+ 'px;';
        this.contractStyle = 'height: auto;overflow: auto;max-height:'+ maxheight+ 'px;';

        if (this.warrantyCount >= SHOW_ROWS && this.contractCount >= SHOW_ROWS) {
            maxheight += halfRowHeight; //display half of next row
            height = ( this.warrantyCount + 1 ) * rowHeight ;
            this.warrantyStyle = 'height: '+ height;
            this.warrantyStyle += 'px;overflow: auto;max-height:'+ maxheight+ 'px;';
            height = ( this.contractCount + 1 ) * rowHeight ;
            this.contractStyle = 'height: '+ height;
            this.contractStyle += 'px;overflow: auto;max-height:'+ maxheight+ 'px;';
        } else if (this.warrantyCount >= SHOW_ROWS && this.contractCount < SHOW_ROWS) {
            maxheight = ( MAX_ROWS - ( this.contractCount + 1) ) * rowHeight;
            maxheight += halfRowHeight;
            height = (this.warrantyCount + 1) * rowHeight ;
            this.warrantyStyle = 'height: '+ height;
            this.warrantyStyle += 'px;overflow: auto;max-height:'+ maxheight+ 'px;';
        } else if (this.warrantyCount < SHOW_ROWS && this.contractCount >= SHOW_ROWS) {
            maxheight = ( MAX_ROWS - ( this.warrantyCount + 1)) * rowHeight;
            maxheight += halfRowHeight;
            height = ( this.contractCount + 1 ) * rowHeight ;
            this.contractStyle = 'height: '+ height;
            this.contractStyle += 'px;overflow: auto;max-height:'+ maxheight+ 'px;';
        }
    }

    handleFilter () {
        this.showModal = !this.showModal;
    }

    closeModal () {
        this.showModal = false;
    }

    get computedPanelCSS () {
        let css = 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right ';
        css += 'ViewServiceCoverages_filter-panel ';
        if (this.showModal) {
            css += 'slds-is-open';
        }
        return css;
    }

    get coveredByOptions () {
        return [
            { label: i18n.account, value: ACCOUNT },
            { label: i18n.asset, value: ASSET },
        ];
    }

    setDefaultSettingData ( assetFieldToQuery ) {
        this.activeSettingData = {
            "fullyConsumedServices": true,
            "expiredEntitlements": false,
            "futureEntitlements": false,
            "accountAPIName": null,
            "assetAPIName": assetFieldToQuery,
            "coveredBy": "Asset",
            "includeParentAsset": false,
            "includeRootAsset": false,
            "matchAccount": false,
            "objectAPIName": this.objectApiName
        };
        this.getFieldDescribeResults();
    }

    handleValueChange (event) {
        this.activeSettingData[event.target.name] = (event.target.type === 'checkbox')
            ? event.target.checked
            : event.target.value;
    }

    get showComponent () {
        return (this.activeSettingData.coveredBy !== undefined
            && this.activeSettingData.coveredBy === ASSET ) ? true : false;
    }

    get matchAccountLabel () {
        return `${i18n.matchAccount} ${this.sourceObjectLabel}`;
    }

    get showAccount () {
        return (this.activeSettingData.coveredBy === ASSET
            && this.activeSettingData.matchAccount === false ) ? false : true;
    }

    async getFieldDescribeResults () {
        if ( this._fieldDescribeResult === undefined ) {

            const objectNames = [];
            objectNames.push(this.objectApiName);

            try {
                const resp = await getFieldDefinitionsForEntities(objectNames);

                if (resp && resp.data) {

                    const fieldDescribeResult = {};
                    let objectLabel = '';
                    resp.data.forEach( function (item) {
                        fieldDescribeResult[item.apiName] = item;
                        objectLabel = item.label;
                    } );

                    this._fieldDescribeResult = fieldDescribeResult;
                    this.sourceObjectLabel = objectLabel;
                }
            } catch (err) {
                this.error = parseErrorMessage(err);
            }
        }
    }

    getReferenceFieldInfo (referenceFieldName) {

        const referenceFields = [];
        if (this._fieldDescribeResult !== undefined
            && this.activeSettingData.objectAPIName !== undefined) {

            const currentObject = this.activeSettingData.objectAPIName;
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
                } else if (item.dataType === 'ID' && referenceFieldName === currentObject) {
                    referenceFields.push({
                        label: item.label,
                        value: item.apiName,
                    });
                }
            });
        }
        return referenceFields;
    }

    get accountAPINames () {
        return this.getReferenceFieldInfo(ACCOUNT);
    }

    get assetAPINames () {
        return this.getReferenceFieldInfo(ASSET);
    }

    handleApplyFilter () {
        this.apiInProgress = true;
        getServiceCoveragesForSettings({
            sourceRecordId: this.recordId,
            requestJson: JSON.stringify(this.activeSettingData)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.error = null;
                this.resetValues();
                this.populateReferenceNameField(this.activeSettingData.coveredBy);
                this.fetchSourceRecord();
                this.coverageData = result.data;
                this.populateCoverageData();
                this.updateIllustrationForDataResponse();
            })
            .catch( error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                if (this.warrantyCount === 0 ) {
                    this.hasWarrantyData = false;
                }
                if (this.contractCount === 0 ) {
                    this.hasContractData = false;
                }
                this.apiInProgress = false;
            })
    }

    populateReferenceNameField ( referenceToObj ) {
        this.getFieldDescribeResults();

        let _relationshipName = '';
        let _referenceNameField = '';
        let _coveredByFieldLabel = '';
        this.lookupInfo.referenceNameToQuery = '';

        if (this._fieldDescribeResult !== undefined
            && this.activeSettingData.objectAPIName !== undefined) {
            let fieldApiName = '';
            if (  referenceToObj === ASSET
                && this.activeSettingData.assetAPIName !== undefined) {
                fieldApiName = this.activeSettingData.assetAPIName;
            } else if (referenceToObj === ACCOUNT
                && this.activeSettingData.accountAPIName !== undefined) {
                fieldApiName = this.activeSettingData.accountAPIName;
            }
            const coveredByObject = this.activeSettingData.coveredBy;
            const sourceFieldDefinition
                = this._fieldDescribeResult[this.activeSettingData.objectAPIName];
            sourceFieldDefinition.fieldDefinitions.forEach(function (item) {
                if (item.dataType === 'REFERENCE'
                    && item.referenceTo.length !== 0
                    && item.referenceTo[0] === referenceToObj
                    && item.relationshipName
                    && item.referenceNameFields.length !== 0
                    && item.apiName === fieldApiName) {

                    _relationshipName = item.relationshipName;
                    _referenceNameField = item.referenceNameFields[0];
                    _coveredByFieldLabel = item.label;
                } else if (item.dataType === 'ID' && item.apiName === fieldApiName &&
                        coveredByObject === referenceToObj) {
                    _coveredByFieldLabel = item.label;
                    _relationshipName = 'Name';  //When the selected field is Asset/Account Id
                }
            });
            this.lookupInfo.relationshipName = _relationshipName;
            this.lookupInfo.referenceNameField = _referenceNameField;
            if ( _relationshipName !== '' && _referenceNameField !== '') {
                this.lookupInfo.referenceNameToQuery =
                    _relationshipName + '.' + _referenceNameField;
            } else if (_relationshipName !== '') {
                this.lookupInfo.referenceNameToQuery = _relationshipName;
            }
            if  ( _coveredByFieldLabel !== null && _coveredByFieldLabel !== '') {
                this.coveredByFieldLabel = ' (' + _coveredByFieldLabel.replace(' ID','') + ')';
            }
        }
    }

    fetchSourceRecord () {

        const fieldsToQuery = [];
        let coveredByObject;

        if (this.activeSettingData.coveredBy !== undefined) {

            coveredByObject = this.activeSettingData.coveredBy;

            if ( this.activeSettingData.coveredBy === ASSET) {
                fieldsToQuery.push(this.activeSettingData.assetAPIName);
            } else if (this.activeSettingData.coveredBy === ACCOUNT) {
                fieldsToQuery.push(this.activeSettingData.accountAPIName);
            }

            if (this.lookupInfo.referenceNameToQuery !== '' ) {
                fieldsToQuery.push(this.lookupInfo.referenceNameToQuery);
            }
        }

        const reqObject ={
            objectName: this.objectApiName,
            fields: fieldsToQuery,
            id: this.recordId
        };
        getSourceRecord({
            requestJson: JSON.stringify(reqObject)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.populateSourceRecord(result.data, coveredByObject );
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
    }

    populateSourceRecord (data, coveredByObject) {
        if (data.length !== 0 ) {
            if (coveredByObject === ASSET) {
                this.sourceObjectRecordId = data[0][this.activeSettingData.assetAPIName];
            } else if (coveredByObject === ACCOUNT) {
                this.sourceObjectRecordId = data[0][this.activeSettingData.accountAPIName];
            }
            if (this.lookupInfo.relationshipName !== '' &&
                this.lookupInfo.referenceNameField !== '') {
                this.sourceObjectRecordName =
                    data[0][this.lookupInfo.relationshipName][this.lookupInfo.referenceNameField];
            } else if (this.lookupInfo.referenceNameToQuery !== '' ) {
                this.sourceObjectRecordName = data[0][this.lookupInfo.referenceNameToQuery];
            }
        }
    }

    handleResetFilter () {
        Promise.all([ this.setDefaultSettingData( this.assetField ) ])
            .then( () => {
                this.handleApplyFilter();
            })
            .catch(error => {
                this.coverageData = [];
                this.error = parseErrorMessage(error);
            })
    }

    accountFieldRequired () {
        if (this.activeSettingData.coveredBy === ACCOUNT
            || this.activeSettingData.matchAccount === true) {
            return true;
        }
        return false;
    }

    assetFieldRequired () {
        if (this.activeSettingData.coveredBy === ASSET) {
            return true;
        }
        return false;
    }

    get disableButton () {
        if ( ( this.activeSettingData.coveredBy === ASSET &&
            isUndefinedOrNull(this.activeSettingData.assetAPIName) ) ||
            (( this.activeSettingData.coveredBy === ACCOUNT ||
            this.activeSettingData.matchAccount === true ) &&
            isUndefinedOrNull(this.activeSettingData.accountAPIName)
            ) ) {
            return true;
        }
        return false;
    }

    previewWarrantyRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'AssetWarranty',
                event.target, null, event.target.dataset.value);
    }

    previewContractRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'ServiceContract',
                event.target,null, event.target.dataset.value);
    }

    previewEntitlementRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'Entitlement',event.target,null,
                event.target.dataset.value);
    }

    previewCPLIRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'SVMXA360__ContractPriceLineItem__c',
                event.target, null, event.target.dataset.value);
    }

    //show default icon
    previewAssetRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'Asset',event.target,null,event.target.dataset.value);
    }

    previewWarrantyTermRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'WarrantyTerm',event.target,null,
                event.target.dataset.value);
    }

    previewAccountRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (event.target.target,'Account',event.target,null,
                event.target.dataset.value);
    }

    handleMouseOut () {
        this.template.querySelector('c-svmx-record-popover').hidePopover ();
    }

    get computedVariant () {
        let css;
        if (this.showModal) {
            css = 'brand';
        }
        return css;
    }

    get computedColSpan () {
        let colspan;
        if (this.showModal) {
            colspan = 4;
        } else {
            colspan = 5;
        }
        return colspan;
    }
}