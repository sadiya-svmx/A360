import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { parseErrorMessage, verifyApiResponse }  from 'c/utils';

import getMaintenancePlanTemplates
    from '@salesforce/apex/CONF_QueryLightningService.queryRecords';
import saveOfferedMPT
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.saveOfferedMPT';

//Get fields and object info from Maintenance Plan template object
import MPT_OBJ from '@salesforce/schema/MaintenancePlanTemplate__c';
import MPT_ID_FIELD from '@salesforce/schema/MaintenancePlanTemplate__c.Id';
import MPT_NAME_FIELD from '@salesforce/schema/MaintenancePlanTemplate__c.Name';
import MPT_DESCRIPTION_FIELD from '@salesforce/schema/MaintenancePlanTemplate__c.Description__c';
import MPT_ISACTIVE_FIELD from '@salesforce/schema/MaintenancePlanTemplate__c.IsActive__c';
import MPT_LASTMODIFIED_FIELD from '@salesforce/schema/MaintenancePlanTemplate__c.LastModifiedDate';


import labelAddOfferedMPT from '@salesforce/label/c.Button_AddOfferedMPT';
import labelOfferedMPTName from '@salesforce/label/c.Label_OfferedMaintenancePlanTemplateName';
import labelPlaceholderForMPT from '@salesforce/label/c.Placeholder_Search_MaintenacePlanTemplate';
import labelChooseRow from '@salesforce/label/c.Label_ChooseRow';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelActive from '@salesforce/label/c.Label_Active';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelAdd from '@salesforce/label/c.Button_Add';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelOfferdMPT from '@salesforce/label/c.Label_OfferedMaintenancePlanTemplate';
import labelOfferdMPTs from '@salesforce/label/c.Label_OfferedMaintenancePlanTemplates';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelItemSelected from '@salesforce/label/c.Label_ItemSelected';
import labelItemsSelected from '@salesforce/label/c.Label_ItemsSelected';

const MPT_LIMIT_COUNT = 50000;
const DEFAULT_ORDER ='DESC';

const i18n = {
    title: labelAddOfferedMPT,
    mptName: labelOfferedMPTName,
    placeholder: labelPlaceholderForMPT,
    chooseRow: labelChooseRow,
    description: labelDescription,
    active: labelActive,
    add: labelAdd,
    cancel: labelCancel,
    success: labelSuccess,
    reviewError: labelReviewError,
    offeredMPT: labelOfferdMPT,
    offeredMPTs: labelOfferdMPTs,
    saved: labelWasSaved,
    noResults: labelNoResults,
    loading: labelLoading,
    itemSelected: labelItemSelected,
    itemsSelected: labelItemsSelected,
}
export default class OfferedMaintenancePlanTemplateDetail extends LightningElement {

    //Properties
    @track parentRecordId;
    @track offeredMPTInfo = {};
    @track selectedMPTRecords = [];
    @track fetchedMPTRecords = [];
    @track listViewRecords = [];
    @track offeredMPTModalOpen = false;
    @track fieldsToRetrieve;
    @track apiInProgress = false;
    @track error;

    @api
    handleNewOfferedMPT (parentRecId) {
        this.fetchMaintenaceTemplates();
        this.parentRecordId = parentRecId;
        this.offeredMPTModalOpen = true;
    }

    fetchMaintenaceTemplates () {
        this.fieldsToRetrieve = [
            MPT_ID_FIELD.fieldApiName,
            MPT_NAME_FIELD.fieldApiName,
            MPT_DESCRIPTION_FIELD.fieldApiName,
            MPT_ISACTIVE_FIELD.fieldApiName
        ];
        this.objectName = MPT_OBJ.objectApiName;
        const reqObject ={
            objectName: this.objectName,
            fields: this.fieldsToRetrieve,
            sortField: MPT_LASTMODIFIED_FIELD.fieldApiName,
            sortOrder: DEFAULT_ORDER,
            limitCount: MPT_LIMIT_COUNT
        };
        this.apiInProgress = true;
        getMaintenancePlanTemplates({
            requestJson: JSON.stringify(reqObject)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.populateMPTRecords(result.data);
            })
            .catch(error => {
                this.fetchedMPTRecords = [];
                this.listViewRecords = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    populateMPTRecords (data) {
        data.forEach(row => {
            const mptRecord ={};
            mptRecord.id = row.Id;
            mptRecord.name = row.Name;
            mptRecord.description = row.SVMXA360__Description__c;
            mptRecord.isActive = row.SVMXA360__IsActive__c;
            mptRecord.isSelected = false;
            this.fetchedMPTRecords.push(mptRecord);
            this.listViewRecords = this.fetchedMPTRecords;
        });
    }

    get i18n () {
        return i18n;
    }

    get disableAddTemplate () {
        return (!this.selectedMPTRecords.length >0);
    }

    get maintenancePlanTemplates () {
        return (this.fetchedMPTRecords && this.fetchedMPTRecords.length) ?
            this.fetchedMPTRecords : null;
    }

    get selectedProductCountInfo () {
        const rowsCount = this.selectedMPTRecords.length;
        const countText = rowsCount < 2 ? i18n.itemSelected : i18n.itemsSelected;
        return `${rowsCount} ${countText}`;
    }

    get noRecordsFound () {
        return (this.fetchedMPTRecords && this.fetchedMPTRecords.length === 0);
    }


    handleCancelOfferedMPTModal () {
        this.offeredMPTModalOpen = false;
        this.clearValues();
    }


    handleSelectMPT (event) {
        const isChecked = event.target.checked;
        const mptRecordId = event.target.value;
        const mptRecordName = event.target.dataset.name;

        this.offeredMPTInfo = {};
        //Add or remove MPT Records 
        this.offeredMPTInfo.maintenancePlanTemplateId=mptRecordId;
        this.offeredMPTInfo.maintenancePlanTemplateName=mptRecordName;
        if (isChecked) {
            this.addMPTRecord (this.offeredMPTInfo);
        } else {
            this.removeMPTRecord(this.offeredMPTInfo);
        }
    }

    addMPTRecord (offeredMPTRecord) {
        if (!offeredMPTRecord.serviceContractPlanId) {
            offeredMPTRecord.serviceContractPlanId = this.parentRecordId;
        }
        this.selectedMPTRecords.push(offeredMPTRecord);
    }

    removeMPTRecord (offeredMPTRecord) {
        const mptId = offeredMPTRecord.maintenancePlanTemplateId;
        if (mptId) {
            this.selectedMPTRecords = this.selectedMPTRecords.filter(
                item => item.maintenancePlanTemplateId !== mptId);
        }
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value.trim();
        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }
        try {
            this.filterListViewData(searchKey);
        } catch (e) {
            this.error = parseErrorMessage(e);
        }
    }

    filterListViewData (searchValue) {
        if (!searchValue) {
            this.fetchedMPTRecords = [];
            this.fetchedMPTRecords = this.listViewRecords;
        } else {
            this.fetchedMPTRecords  = this.listViewRecords.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const mptNameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return ( mptNameMatch !== -1);
            });
        }
    }

    handleAddTemplate () {

        if (this.apiInProgress) return;

        this.apiInProgress = true;
        saveOfferedMPT({ requestJson: JSON.stringify(this.selectedMPTRecords) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${result.data.length} ${result.data.length > 1 ?
                    this.i18n.offeredMPTs : this.i18n.offeredMPT} ${this.i18n.saved}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleCancelOfferedMPTModal();
                //dispatch event to refresh the list view
                this.handleCloseAndRefresh();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    handleCloseAndRefresh () {
        this.dispatchEvent(
            new CustomEvent('refresh', {
                detail: {
                    value: 'success'
                }
            })
        );
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

    clearValues () {
        this.selectedMPTRecords = [];
        this.fetchedMPTRecords = [];
        this.listViewRecords = [];
        this.offeredMPTInfo = {};
        this.error = '';
    }
}