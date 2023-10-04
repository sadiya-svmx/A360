import { LightningElement, api } from 'lwc';
import labelDeleteServiceContractConfirm
    from '@salesforce/label/c.Label_DeleteServiceContractConfirm';
import labelDeleteContractAndCoverages
    from '@salesforce/label/c.Label_DeleteContractAndCoverages';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelServiceContractDeleted from '@salesforce/label/c.Label_ServiceContractDeleted';
import labelProgressText from '@salesforce/label/c.Label_ServiceContractDeleteProgressText';
import labelLoading from '@salesforce/label/c.AltText_Loading';

import deleteServiceContract
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.deleteServiceContract';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { parseErrorMessage, verifyApiResponse } from 'c/utils';

const CANCELLED = 'CANCELLED';
const FINISHED = 'FINISHED_SCREEN';

const i18n = {
    deleteServiceContractConfirm: labelDeleteServiceContractConfirm,
    title: labelDeleteContractAndCoverages,
    cancel: labelCancel,
    confirm: labelConfirm,
    serviceContractDeleted: labelServiceContractDeleted,
    deleteProgressText: labelProgressText,
    loading: labelLoading,
}

export default class DeleteServiceContract extends NavigationMixin(LightningElement) {
    apiInProgress = false;
    @api recordId;

    get i18n () {
        return i18n;
    }

    handleConfirmDelete () {
        this.apiInProgress = true;
        deleteServiceContract({ serviceContractId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.showToast(result.message, 'error');
                    return;
                }
                const deletionStatus = result.data.deletionStatus;

                this.apiInProgress = false;
                window.clearTimeout(this.delayTimeout);

                if (deletionStatus === 'In Progress') {
                    this.showToast(i18n.deleteProgressText, 'success');

                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    this.delayTimeout = setTimeout(() => {
                        this.redirectSObjectRecord(this.recordId, FINISHED);
                    }, 200);

                } else if (deletionStatus === 'Completed') {
                    this.showToast(i18n.serviceContractDeleted, 'success');
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    this.delayTimeout = setTimeout(() => {
                        this.handleListViewNavigation();
                    }, 200);
                }
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    showToast (title, variant) {
        const evt = new ShowToastEvent({
            title: title,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleCancelDelete () {
        this.redirectSObjectRecord(this.recordId, CANCELLED);
    }

    handleListViewNavigation () {
        // Navigate to the ServiceContract object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ServiceContract',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    redirectSObjectRecord (targetRecordId, status) {
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
}