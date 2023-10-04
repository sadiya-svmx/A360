import { LightningElement,api } from 'lwc';
import getEntitlementPerformed
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementPerformed';
import getAppNavigationType
    from '@salesforce/apex/COMM_DatabaseUtils.fetchApplicationNavigationType';
import getEntitlementHistory
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementVerficationHistory';
import { parseErrorMessage, verifyApiResponse, isUndefinedOrNull } from 'c/utils';
import RETURN_ORDER_OBJECT from '@salesforce/schema/ReturnOrder';
import getObjectAPIName
    from '@salesforce/apex/COMM_DatabaseUtils.getObjectAPIFromRecordId';

export default class InteractiveEntitlementWrapper extends LightningElement {

    accountInfo;
    assetInfo;
    entitlementPerformedData;
    entitlementHistoryData;
    notes;
    appNavigationType;
    selectedRecordId;
    _objectApiName;
    billingType;
    isDataLoaded = false;
    error;
    hasError = false;
    modalCloseAndRefreshHandler;
    modalclosedHandler;
    isSelectCoverageScreen = false;
    @api recordId;
    @api
    get objectApiName () {
        return this._objectApiName;
    }

    set objectApiName (value) {
        this._objectApiName = value;
    }

    connectedCallback () {
        getAppNavigationType()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    this.hasError = true;
                    return;
                }
                if (result) {
                    this.appNavigationType = result.data;
                    if (isUndefinedOrNull (this.objectApiName)) {
                        getObjectAPIName({ objectId: this.recordId })
                            .then(objectApiResult => {
                                if (objectApiResult && objectApiResult.data) {
                                    this._objectApiName = objectApiResult.data;
                                }
                            });
                    }
                    getEntitlementPerformed({ recordId: this.recordId })
                        .then(entitlementResult => {

                            if (!verifyApiResponse(entitlementResult)) {
                                this.error = entitlementResult.message;
                                this.hasError = true;
                                return;
                            }

                            this.entitlementPerformedData = entitlementResult.data;
                            this.populateAccountAssetInfo();
                            if (this.entitlementPerformedData.SVMXA360__IsEntitlementPerformed__c) {
                                this.getEntitlementHistoryData();
                            }
                            this.isSelectCoverageScreen =true;

                        })
                        .catch(error => {
                            this.error = parseErrorMessage(error);
                            this.hasError = true;
                        })
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.hasError = true;
            });
        this.modalCloseAndRefreshHandler = () => {
            this.navigateToOriginatedRecord('FINISHED_SCREEN');
        }

        this.modalclosedHandler = () => {
            this.navigateToOriginatedRecord('CANCELLED');
        }

        window.addEventListener('modalcloseAndRefresh', this.modalCloseAndRefreshHandler);

        window.addEventListener('modalclosed', this.modalclosedHandler);
    }

    renderedCallback () {
        const everInteractiveEl = this.template.querySelector('c-ever-interactive-entitlement');
        if (everInteractiveEl && !this.isDataLoaded && this.isSelectCoverageScreen) {
            everInteractiveEl.performCoverageLoad();
            this.isDataLoaded = true;
        }
    }

    disconnectedCallback () {
        window.removeEventListener('modalcloseAndRefresh', this.modalCloseAndRefreshHandler);
        window.removeEventListener('modalclosed', this.modalclosedHandler);
    }

    populateAccountAssetInfo () {

        if (this.entitlementPerformedData.Account) {
            this.accountInfo = this.entitlementPerformedData.Account;
        }

        if (this.objectApiName === RETURN_ORDER_OBJECT.objectApiName) {
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

    navigateToOriginatedRecord (status) {
        this.dispatchEvent(
            new CustomEvent('statuschange', {
                composed: true,
                bubbles: true,
                detail: {
                    status: status,
                    showToast: false
                }
            })
        );
    }


    getEntitlementHistoryData () {
        this.apiInProgress = true;
        getEntitlementHistory({ recordId: this.recordId })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    this.hasError = true;
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
        if (this.entitlementHistoryData.assetWarrantyId != null
            && !this.entitlementHistoryData.multipleCoverages) {
            this.selectedRecordId = this.entitlementHistoryData.assetWarrantyId;
        } else if (this.entitlementHistoryData.serviceContractId != null
            && !this.entitlementHistoryData.multipleCoverages) {
            if (this.entitlementHistoryData.entitledServiceId != null) {
                this.selectedRecordId = this.entitlementHistoryData.entitledServiceId;
            } else {
                this.selectedRecordId = this.entitlementHistoryData.serviceContractId;
            }
        }
    }
}