import { LightningElement, track, api, wire } from 'lwc';
import { parseErrorMessage, verifyApiResponse, formatDateTimeToApexDateString } from 'c/utils';
import { getRecord } from 'lightning/uiRecordApi';
import { getFieldDefinitionsForEntity } from 'c/metadataService';
import updateServiceContract
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.updateServiceContractStatus';

import labelUpdateContractStatus from '@salesforce/label/c.Title_UpdateContractStatus';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelSave from '@salesforce/label/c.Button_Save';
import labelClose from '@salesforce/label/c.Link_Close';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import errorCanceledOn from '@salesforce/label/c.Error_CanceledOnInFuture';

//Get fields info for Service contract
import CONTRACT_ID_FIELD from '@salesforce/schema/ServiceContract.Id';
import CONTRACT_STATUS_FIELD from '@salesforce/schema/ServiceContract.ContractAuthoringStatus__c';
import CONTRACT_STATUSNOTES_FIELD from '@salesforce/schema/ServiceContract.StatusNotes__c';
import CONTRACT_CANCELEDON_FIELD from '@salesforce/schema/ServiceContract.CanceledOn__c';
import CONTRACT_OBJECT from '@salesforce/schema/ServiceContract';

const i18n = {
    lnkClose: labelClose,
    cancel: labelCancel,
    save: labelSave,
    loading: labelLoading,
    updateContractStatus: labelUpdateContractStatus,
    errorCanceledOn: errorCanceledOn
};

const CANCELLED = 'CANCELLED';
const FINISHED = 'FINISHED_SCREEN';
const canceledLabel = 'Cancel';


export default class UpdateContractAvailabilityStatus extends LightningElement {
    @track cancelContractModalOpen;
    @api recordId;
    @track contractInfo = {};
    @track apiInProgress = false;
    @track isContractCanceled;

    openModal;
    statusLabel;
    statusNotesLabel;
    canceledOnLabel;
    canceledOnMax;
    disableSave = false;

    get i18n () {
        return i18n;
    }

    @wire(getRecord, { recordId: '$recordId',
        fields: [ CONTRACT_ID_FIELD, CONTRACT_STATUS_FIELD, CONTRACT_STATUSNOTES_FIELD,
            CONTRACT_CANCELEDON_FIELD]})
    serviceContractRecord ({ error, data }) {
        if (error) {
            this.error =  parseErrorMessage(error);
        } else if (data) {
            this.contractInfo.Id = this.recordId;
            this.contractInfo.authoringStatus =
                data.fields[CONTRACT_STATUS_FIELD.fieldApiName].value;
            this.contractInfo.statusNotes =
                data.fields[CONTRACT_STATUSNOTES_FIELD.fieldApiName].value;
            this.contractInfo.canceledOn =
                data.fields[CONTRACT_CANCELEDON_FIELD.fieldApiName].value;
            this.isContractCanceled =
                (this.contractInfo.authoringStatus === canceledLabel) ? true : false;
            this.openModal = true;
            this.canceledOnMax = formatDateTimeToApexDateString (new Date(), false);
        }
    }

    contractStatusOptions = [];
    //get all picklist values for Service Unit
    async fetchFieldLabelsAndPicklistValues () {
        const response = await getFieldDefinitionsForEntity( CONTRACT_OBJECT.objectApiName );

        const contractDefinition = response.data;
        if (contractDefinition && contractDefinition.fieldDefinitions) {
            contractDefinition.fieldDefinitions.forEach(field => {
                if (field.apiName === CONTRACT_STATUS_FIELD.fieldApiName) {
                    this.contractStatusOptions = field.picklistValues;
                    this.statusLabel = field.label;
                } else if (field.apiName === CONTRACT_STATUSNOTES_FIELD.fieldApiName) {
                    this.statusNotesLabel = field.label;
                } else if (field.apiName === CONTRACT_CANCELEDON_FIELD.fieldApiName) {
                    this.canceledOnLabel = field.label;
                }
            });
        }
    }

    connectedCallback () {
        this.fetchFieldLabelsAndPicklistValues();
    }

    handleCancel () {
        this.redirectSObjectRecord(this.recordId,CANCELLED);
    }

    redirectSObjectRecord (targetRecordId,status) {
        const redirectEvent = new CustomEvent(
            'statuschange', {
                composed: true,
                bubbles: true,
                detail: {
                    status: status,
                    showToast: false,
                    outputVariables: [
                        {
                            name: 'redirect_recordId',
                            value: targetRecordId
                        } ]
                }
            }
        );
        this.dispatchEvent(redirectEvent);
    }

    handleSave () {
        this.saveContract();
    }

    handleStatusChange (event) {
        const newStatus = event.target.value;
        this.contractInfo.authoringStatus = newStatus;

        if (newStatus === canceledLabel) {
            const todayDate = new Date();
            this.contractInfo.canceledOn =
                formatDateTimeToApexDateString (todayDate, false);
            this.isContractCanceled = true;
        } else {
            this.isContractCanceled = false;
            this.contractInfo.canceledOn = null;
        }
    }

    handleFieldChange (event) {
        this.contractInfo[event.target.name] =  event.target.value;
    }

    handleDateChange (event) {
        this.contractInfo[event.target.name] =  event.target.value;
        if (this.contractInfo.canceledOn) {
            const newDate = new Date(this.contractInfo.canceledOn);
            const today = new Date();
            this.disableSave = newDate > today ? true : false;
        }
        else {
            this.disableSave = true;
        }
    }

    saveContract () {
        this.apiInProgress = true;
        updateServiceContract({
            requestJson: JSON.stringify(this.contractInfo)
        })
            .then(result => {
                this.apiInProgress = false;
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                }
                this.redirectSObjectRecord(this.recordId,FINISHED);
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

}