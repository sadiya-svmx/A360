import { LightningElement, track, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import labelServiceContractAuthoringSummary
    from '@salesforce/label/c.Label_ServiceContractAuthoringSummary';
import labelServiceContractAuthoringDescription
    from '@salesforce/label/c.Label_ServiceContractAuthoringDescription';
import labelViewAll from '@salesforce/label/c.Label_ViewAll';
import labelSuccessMsg from '@salesforce/label/c.Message_ServiceContractCreatedSuccess';
import labelLoading from '@salesforce/label/c.AltText_Loading';

import label_total_batches_executed from '@salesforce/label/c.Label_total_batches_executed';
import label_batchesInProgress from '@salesforce/label/c.Label_batchesInProgress';
import label_totalNumberOfBatches from '@salesforce/label/c.Label_totalNumberOfBatches';
import { formatString, parseErrorMessage, verifyApiResponse } from 'c/utils';
import getAuthoringSummary
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getAuthoringSummary';

const i18n = {
    serviceContractAuthoringSummaryTitle: labelServiceContractAuthoringSummary,
    serviceContractAuthoringDescription: labelServiceContractAuthoringDescription,
    viewAll: labelViewAll,
    successMsg: labelSuccessMsg,
    loading: labelLoading,
    label_total_batches_executed: label_total_batches_executed,
    label_batchesInProgress: label_batchesInProgress,
    label_totalNumberOfBatches: label_totalNumberOfBatches
}

const SHOW_ROWS = 2;

export default class ServiceContractAuthoring extends LightningElement {
    countSuccess = 0;
    failedBatches = [];
    noErrorRecordsFound = false;
    showBatchViewAll = true;
    apiInProgress = false;
    @api recordId;
    @track displayFailedBatch = [];
    @track totalNumberOfBatches;
    @track totalNumberOfBatchesCompleted;
    columns = [
        {
            label: 'Batch',
            fieldName: 'nameUrl',
            hideDefaultActions: true,
            wrapText: false,
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_blank'
            }
        }
    ];

    get i18n () {
        return i18n;
    }

    get isBatchExecutionCompleted () {
        return this.totalNumberOfBatches === this.totalNumberOfBatchesCompleted;
    }

    connectedCallback () {
        this.baseUrl = window.location.origin;
        this.fetchAuthoringSummary (this.recordId);
    }

    fetchAuthoringSummary ( serviceContractId ) {
        this.apiInProgress = true;
        return getAuthoringSummary({ serviceContractId: serviceContractId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.totalNumberOfBatches = result.data.totalNumberOfBatches;
                this.totalNumberOfBatchesCompleted = result.data.totalNumberOfBatchesExecuted;
                this.countSuccess = result.data.totalNumberOfBatchesExecuted;
                this.failedBatches = result.data.authoringLogOfFailedBatches;
                this.displayFailedBatch = [].concat(this.failedBatches);

                this.displayFailedBatch =
                    this.populateListViewData(this.displayFailedBatch.splice(0,SHOW_ROWS));

                if ( this.totalNumberOfBatches === this.totalNumberOfBatchesCompleted ) {
                    if ( this.failedBatches.length === 0 ) {
                        this.noErrorRecordsFound = true;
                    }
                    // Refresh LDS cache and wires
                    getRecordNotifyChange([{ recordId: serviceContractId }]);
                    this.apiInProgress = false;
                    return;
                }

                this.error = undefined;
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    try {
                        this.fetchAuthoringSummary( serviceContractId );
                    } catch (error) {
                        this.error = parseErrorMessage(error);
                    }
                }, 5000);
            })
            .catch(error => {
                this.displayFailedBatch = [];
                this.failedBatches = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.showBatchViewAll = this.failedBatches?.length > SHOW_ROWS;
                this.apiInProgress = false;
            });
    }

    populateListViewData (newData) {
        const sfdcBaseUrl = this.baseUrl+'/';
        let listViewData =[];

        newData.forEach( row => {
            if (row.Name) {
                row.nameUrl = sfdcBaseUrl + row.Id;
            }
            listViewData = [...listViewData, { ...row }]
        });
        return listViewData;
    }

    get authoringDescription () {
        return formatString(i18n.serviceContractAuthoringDescription, this.countSuccess);
    }

    viewAllBatches () {
        this.displayFailedBatch = this.populateListViewData(this.failedBatches);
        this.showBatchViewAll = false;
    }
}