import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getEntitlementPerformed
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementPerformed';
import getEntitlementHistory
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementVerficationHistory';
import updateSourceRecord
    from '@salesforce/apex/ADM_EntitlementLightningService.updateSourceRecord';
import getAppNavigationType
    from '@salesforce/apex/COMM_DatabaseUtils.fetchApplicationNavigationType';
import { parseErrorMessage, verifyApiResponse, formatString } from 'c/utils';
import labelServiceCoverage from '@salesforce/label/c.Title_ServiceCoverage';
import labelEntitledService from '@salesforce/label/c.Label_EntitledService';
import labelCoverageEnds from '@salesforce/label/c.Label_CoverageEnds';
import labelSelectServiceCoverage from '@salesforce/label/c.Button_SelectServiceCoverage';
import labelCoveredByWarranty from '@salesforce/label/c.Label_CoveredByWarranty';
import labelCoveredByContract from '@salesforce/label/c.Label_CoveredByContract';
import labelcoveredByEntitlement from '@salesforce/label/c.Label_CoveredByEntitlement';
import labelMultipleCoveragesFound from '@salesforce/label/c.Label_MultipleCoveragesFound';
import labelMultipleEntitlementFound from '@salesforce/label/c.Label_MultipleEntitlementFound';
import labelNoResultsFound from '@salesforce/label/c.Label_NoResultsFound';
import labelNoCurrentCoverage from '@salesforce/label/c.Message_NoCurrentCoverage';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelSelectService from '@salesforce/label/c.Message_SelectService';
import labelServiceCountMessage from '@salesforce/label/c.Message_ServiceCountMessage';
import labelExpiringMessage from '@salesforce/label/c.Message_Expiring';
import labelExpiredMessage from '@salesforce/label/c.Label_Expired';
import TIMEZONE from '@salesforce/i18n/timeZone';
import CURRENCY from '@salesforce/i18n/currency';
import SERVICE_UNIT_FIELD from '@salesforce/schema/Entitlement.ServiceCountType__c';
import ENTITLEMENT_OBJECT from '@salesforce/schema/Entitlement';
import { getFieldDefinitionsForEntity } from 'c/metadataService';


const i18n = {
    serviceCoverage: labelServiceCoverage,
    entitledService: labelEntitledService + ':',
    coverageEnds: labelCoverageEnds,
    selectServiceCoverage: labelSelectServiceCoverage,
    coveredByWarranty: labelCoveredByWarranty,
    coveredByContract: labelCoveredByContract,
    coveredByEntitlement: labelcoveredByEntitlement,
    multipleCoveragesFound: labelMultipleCoveragesFound,
    multipleEntitlementFound: labelMultipleEntitlementFound,
    noResultsFound: labelNoResultsFound,
    noCurrentCoverage: labelNoCurrentCoverage,
    loading: labelLoading,
    selectService: labelSelectService,
    serviceCountMessage: labelServiceCountMessage,
    expiringMessage: labelExpiringMessage,
    expiredMessage: '('+labelExpiredMessage+')',
    timeZone: TIMEZONE,
    currencyCode: CURRENCY
}

const DASH = ' - ';
const RETURNORDER = 'ReturnOrder';

export default class AutoEntitlementEngineResult extends NavigationMixin (LightningElement) {
    @api recordId;
    @api objectApiName;
    @api showCoverageButton;
    entitlementPerformedData;
    entitlementHistoryData;
    recordName;
    recordObject;
    resultRecordId;
    coveredBy;
    serviceName;
    serviceId;
    serviceCSS = null;
    errorMessage;
    endDate;
    coverageFound = false;
    warrantyFound = false;
    multipleCoveragesFound = false;
    serviceContractWarning = false;
    isSelectCoverageScreen = false;
    noResultFound = false;
    entitlementNotFound = true;
    selectedRecordId;
    accountInfo;
    assetInfo;
    notes;
    appNavigationType;
    serviceCount;
    remainingHoursCSS = 'AutoEntitlementEngineResult__widget-labels--color';
    remainingHours;
    billingType;


    serviceUnitOptions = [];
    //get all picklist values for Service Unit
    async fetchServiceUnitPicklistLabels () {
        const response = await getFieldDefinitionsForEntity( ENTITLEMENT_OBJECT.objectApiName );

        const entitlementDefinition = response.data;
        if (entitlementDefinition && entitlementDefinition.fieldDefinitions) {
            entitlementDefinition.fieldDefinitions.forEach(field => {
                if (field.apiName === SERVICE_UNIT_FIELD.fieldApiName) {
                    this.serviceUnitOptions = field.picklistValues;
                }
            });
        }
    }

    @track apiInProgress = false;

    connectedCallback () {

        this.fetchServiceUnitPicklistLabels();

        getAppNavigationType()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                if (result) {
                    this.appNavigationType = result.data;
                }
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            });

        this.addEventListener('modalcloseAndRefresh', () => {
            this.handleCloseCoverageScreen();
            this.updateSourceObjectRecord();
        });

        this.addEventListener('modalclosed', () => {
            this.handleCloseCoverageScreen();
        });
    }

    updateSourceObjectRecord () {
        this.apiInProgress = true;

        updateSourceRecord({ sourceRecordId: this.recordId })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                if (result) {
                    const record = {
                        fields: {
                            Id: this.recordId
                        },
                    };
                    updateRecord(record)
                        .catch(error => {
                            this.errorMessage = parseErrorMessage(error);
                        });
                }

            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View']})
    wiredRecord ({ error, data }) {
        if (error) {
            this.errorMessage = parseErrorMessage(error);
        } else if (data) {
            this.resetValues();
            this.checkEntitlementPerformed();
        }
    }

    get i18n () {
        return i18n;
    }

    resetValues () {
        this.coverageFound = false;
        this.warrantyFound = false;
        this.multipleCoveragesFound = false;
        this.serviceContractWarning = false;
        this.isSelectCoverageScreen = false;
        this.noResultFound = false;
        this.entitlementNotFound = true;
        this.errorMessage = null;
        this.selectedRecordId = null;
        this.recordObject = null;
        this.resultRecordId = null;
        this.recordName = null;
        this.endDate = null;
        this.serviceName = null;
        this.serviceId = null;
        this.notes = null;
        this.serviceCSS = null;
        this.serviceCount = null;
        this.remainingHours = null;
        this.remainingHoursCSS = 'AutoEntitlementEngineResult__widget-labels--color';
    }

    handleCloseCoverageScreen () {
        this.isSelectCoverageScreen = false;
    }

    checkEntitlementPerformed () {
        this.apiInProgress = true;
        this.entitlementHistoryData = [];
        getEntitlementPerformed({ recordId: this.recordId })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.entitlementPerformedData = result.data;
                this.populateAccountAssetInfo();

                if (this.entitlementPerformedData.SVMXA360__IsEntitlementPerformed__c) {
                    this.getEntitlementHistoryData();
                } else {
                    this.populateNoResultsData();
                }

            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    populateAccountAssetInfo () {

        if (this.entitlementPerformedData.Account) {
            this.accountInfo = this.entitlementPerformedData.Account;
        }

        if (this.objectApiName === RETURNORDER) {
            if (this.entitlementPerformedData.SVMXA360__AssetId__r) {
                this.assetInfo = this.entitlementPerformedData.SVMXA360__AssetId__r;
            }
        } else {
            if (this.entitlementPerformedData.Asset) {
                this.assetInfo = this.entitlementPerformedData.Asset;
            }
        }

        if (this.entitlementPerformedData.SVMXA360__EntitlementNotes__c) {
            this.notes = this.entitlementPerformedData.SVMXA360__EntitlementNotes__c;
        }
    }

    getEntitlementHistoryData () {
        this.apiInProgress = true;
        getEntitlementHistory({ recordId: this.recordId })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.entitlementHistoryData = result.data;
                if (this.entitlementHistoryData.billingType) {
                    this.billingType = this.entitlementHistoryData.billingType;
                }
                this.evaluateEntitlementHistoryConditions();
            })
            .catch(error => {
                this.entitlementHistoryData = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    evaluateEntitlementHistoryConditions () {

        if (this.entitlementHistoryData.multipleCoverages) {
            this.populateMultipleCoverageData();
            return;
        }

        if (this.entitlementHistoryData.assetWarrantyId != null) {
            this.populateWarrantyData();
            return;
        }

        if (this.entitlementHistoryData.serviceContractId != null) {
            if (this.entitlementHistoryData.entitledServiceId != null) {
                this.populateEntitlementData();
            } else {
                this.populateContractData();
            }
            return;
        }

        this.populateNoResultsData();
    }

    populateWarrantyData () {
        this.coverageFound = true;
        this.warrantyFound = true;
        if (this.entitlementHistoryData.warrantyTerm.name) {
            this.recordName = this.entitlementHistoryData.assetWarrantyName + DASH
                + this.entitlementHistoryData.warrantyTerm.name;
        } else {
            this.recordName = this.entitlementHistoryData.assetWarrantyName;
        }
        this.recordObject = 'AssetWarranty';
        this.resultRecordId = this.entitlementHistoryData.assetWarrantyId;
        this.coveredBy = this.i18n.coveredByWarranty;
        this.populateEndDate(this.entitlementHistoryData.endDate);
        this.selectedRecordId = this.entitlementHistoryData.assetWarrantyId;
    }

    populateContractData () {
        this.serviceContractWarning = true;
        this.recordName = this.entitlementHistoryData.serviceContractName;
        this.resultRecordId = this.entitlementHistoryData.serviceContractId;
        this.recordObject = 'ServiceContract';
        this.coveredBy = this.i18n.coveredByContract;
        this.populateEndDate(this.entitlementHistoryData.endDate);
        this.serviceName = this.i18n.selectService;
        this.selectedRecordId = this.entitlementHistoryData.serviceContractId;
        this.serviceCSS = 'slds-text-color_error';
    }

    populateEntitlementData () {
        this.coverageFound = true;
        this.recordName = this.entitlementHistoryData.serviceContractName;
        this.resultRecordId = this.entitlementHistoryData.serviceContractId;
        this.recordObject = 'ServiceContract';
        this.coveredBy = this.i18n.coveredByContract;
        this.populateEndDate(this.entitlementHistoryData.endDate);
        this.serviceName = this.entitlementHistoryData.entitledServiceName;
        this.serviceId = this.entitlementHistoryData.entitledServiceId;
        this.entitlementNotFound = false;
        this.selectedRecordId = this.entitlementHistoryData.entitledServiceId;

        let currencyCode = i18n.currencyCode;
        if (this.entitlementHistoryData.currencyISOCode !== null ) {
            currencyCode = this.entitlementHistoryData.currencyISOCode;
        }

        if (this.entitlementHistoryData.serviceCountType &&
            this.entitlementHistoryData.totalService) {
            if (this.entitlementHistoryData.serviceCountType === 'Amount') {
                this.serviceCount = formatString(i18n.serviceCountMessage,
                    (this.entitlementHistoryData.totalService -
                        this.entitlementHistoryData.consumedService),
                    this.entitlementHistoryData.totalService,currencyCode);
            } else {
                const serviceType = this.serviceUnitOptions.find(item =>
                    item.value === this.entitlementHistoryData.serviceCountType);
                this.serviceCount = formatString(i18n.serviceCountMessage,
                    (this.entitlementHistoryData.totalService -
                        this.entitlementHistoryData.consumedService),
                    this.entitlementHistoryData.totalService,
                    serviceType.label);

            }
        }
    }

    populateMultipleCoverageData () {
        this.coveredBy = this.i18n.multipleCoveragesFound;
        this.multipleCoveragesFound = true;
    }

    populateNoResultsData () {
        this.noResultFound = true;
        this.coveredBy = this.i18n.noResultsFound;
        this.errorMessage = this.i18n.noCurrentCoverage;
        if (this.entitlementHistoryData.entitlementNotes) {
            this.errorMessage = this.entitlementHistoryData.entitlementNotes;
        }
    }

    populateEndDate (endDateValue) {
        this.endDate = endDateValue;

        if (this.entitlementHistoryData.remainingHours &&
            this.entitlementHistoryData.remainingHours < 91) {

            this.remainingHours = formatString(i18n.expiringMessage,
                this.entitlementHistoryData.remainingHours);
            this.remainingHoursCSS = 'slds-m-left_xx-small ';

            if (this.entitlementHistoryData.remainingHours < 1) {
                this.remainingHoursCSS += 'AutoEntitlementEngineResult__remaininghours--font ' +
                                         'AutoEntitlementEngineResult__widget-labels--color';
                this.remainingHours = i18n.expiredMessage;
            }
            else if (this.entitlementHistoryData.remainingHours < 31 ) {
                this.remainingHoursCSS += 'slds-text-color_error';
            }
            else if (this.entitlementHistoryData.remainingHours < 91) {
                this.remainingHoursCSS += 'AutoEntitlementEngineResult__text--warning';
            }
        }
    }

    handleCoverageSection () {
        const everInteractiveEl = this.template.querySelector('c-ever-interactive-entitlement');
        this.isSelectCoverageScreen = true;
        if (everInteractiveEl) {
            everInteractiveEl.performCoverageLoad();
        }
    }

    viewSObjectRecord () {
        const everInteractiveEl = this.template.querySelector('c-ever-interactive-entitlement');
        if (everInteractiveEl) {
            everInteractiveEl.redirectSObjectRecord(this.recordObject,this.resultRecordId);
        }
    }

    viewEntitlementRecord () {
        const everInteractiveEl = this.template.querySelector('c-ever-interactive-entitlement');
        if (everInteractiveEl) {
            everInteractiveEl.redirectSObjectRecord('Entitlement',this.serviceId);
        }
    }

    get computedPanelCSS () {
        const cssClasses = [
            'slds-panel',
            'slds-size_medium',
            'slds-panel_docked',
            'slds-panel_docked-right'
        ];
        if (this.panelOpen) {
            cssClasses.push('slds-is-open');
        }
        return cssClasses.join(' ');
    }

    previewRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (this.resultRecordId,this.recordObject,
                event.target, null, event.target.title);
    }

    previewEntitlementRecord (event) {
        this.template.querySelector('c-svmx-record-popover')
            .showPopover (this.serviceId,'Entitlement',
                event.target, null, event.target.title);
    }

    handleMouseOut () {
        this.template.querySelector('c-svmx-record-popover').hidePopover ();
    }

}