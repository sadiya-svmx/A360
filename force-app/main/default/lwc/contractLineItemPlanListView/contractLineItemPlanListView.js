import { LightningElement, track, api } from 'lwc';
import getContractLineItemPlans
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getContractLineItemPlans';
import deleteContractLineItemPlan
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.deleteContractLineItemPlan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import message service features required for publishing and the message channel
import { publish, createMessageContext } from 'lightning/messageService';

import { parseErrorMessage, verifyApiResponse, PAGE_ACTION_TYPES } from 'c/utils';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelCLIPlanTitle from '@salesforce/label/c.Label_ContractLineItemPlans';
import labelRecordNumber from '@salesforce/label/c.Label_RecordNumber';
import labelServiceContractPlan from '@salesforce/label/c.Label_ServiceContractPlan';
import labelContractLineDuration from '@salesforce/label/c.Label_ContractLineDuration';
import labelContractLineUnitofTime from '@salesforce/label/c.Label_ContractLineUnitofTime';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelDiscount from '@salesforce/label/c.Label_Discount';
import labelNewPlan from '@salesforce/label/c.Button_NewContractLinePlan';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelPlaceholderCLIPlan from '@salesforce/label/c.Placeholder_Search_CLI_Plan';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteCPLIPlan from '@salesforce/label/c.Label_DeleteCLIPlan';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_DeleteCLIPlanConfirmMessage';
import labelDeleteMessage from '@salesforce/label/c.Label_CLIPlanDeleteMessage';
import labelSuccess from '@salesforce/label/c.Label_Success';

import refreshListViewChannel from "@salesforce/messageChannel/RefreshListView__c";

const i18n = {
    noResults: labelNoResults,
    loading: labelLoading,
    product: labelProduct,
    productFamily: labelProductFamily,
    discount: labelDiscount,
    title: labelCLIPlanTitle,
    recordNumber: labelRecordNumber,
    serviceContractPlan: labelServiceContractPlan,
    contractLineDuration: labelContractLineDuration,
    contractLineUnitofTime: labelContractLineUnitofTime,
    newPlan: labelNewPlan,
    delete: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    placeholderCLIPlan: labelPlaceholderCLIPlan,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteContractLineItemPlan: labelDeleteCPLIPlan,
    deleteConfirmMessage: labelDeleteConfirmMessage,
    msgDeleted: labelDeleteMessage,
    success: labelSuccess,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.delete, name: 'delete' },
];

export default class ContractLineItemPlansListView extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track cliPlanRecords = [];
    @track apiInProgress= false;
    @track deleteModalDialogOpen;
    @track cliPlanFetchedRecords = [];
    pendingDeleteRecord;
    currentRecordCount = 0;
    _listViewTableHeight = 100;
    //sfdc base url to redirect to detail page from list view
    baseUrl;
    context = createMessageContext();

    constructor () {
        super();
        this.columns = this.getColumns();
    }


    connectedCallback () {

        this.baseUrl = window.location.origin;
        this.parentId = this.recordId;
        this.init();
    }

    renderedCallback () {
        const listViewTable = this.template.querySelector(
            '.svmx-contract-line-item-plans-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    init () {

        this._listViewRecords = [];
        this.cliPlanRecords = [];
        this.cliPlanFetchedRecords = [];
        this.apiInProgress = true;
        this.fetchRecords();
    }

    get i18n () {
        return i18n;
    }

    get recordCountInfo () {
        return (this._listViewRecords.length > 1)
            ? `${this._listViewRecords.length} ${this.i18n.items}`
            : `${this._listViewRecords.length} ${this.i18n.item}`;
    }

    get noRecordsFound () {
        return (this._listViewRecords.length === 0);
    }

    get computedDataTableHeight () {
        return (this.currentRecordCount > 10) ?
            `height:400px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    getColumns () {
        return [
            {
                label: this.i18n.recordNumber,
                fieldName: 'nameUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'name'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.product,
                fieldName: 'productUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'productName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.productFamily,
                fieldName: 'productFamily',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.contractLineDuration,
                fieldName: 'duration',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.contractLineUnitofTime,
                fieldName: 'unitOfTime',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.discount,
                fieldName: 'discount',
                type: 'percent',
                hideDefaultActions: true,
                wrapText: false,
                cellAttributes: { alignment: 'left' },
                typeAttributes: { maximumFractionDigits: 2 }
            },
            {
                type: 'action',
                fixedWidth: 60,
                typeAttributes: { rowActions: ROW_ACTIONS },
            },
        ];
    }

    fetchRecords () {
        let newData;
        return getContractLineItemPlans({
            serviceContractId: this.parentId
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.currentRecordCount = result.data.length;
            if (this.currentRecordCount === 0) {
                return;
            }
            this.cliPlanFetchedRecords = JSON.parse(JSON.stringify(result.data));
            newData = this.populateListViewData(JSON.parse(JSON.stringify(result.data)));
            const newRecords = [...this._listViewRecords, ...newData];
            this._listViewRecords = newRecords;
            this.cliPlanRecords = this._listViewRecords;
            this.error = undefined;
        })
            .catch(error => {
                this._listViewRecords = [];
                this.cliPlanRecords = [];
                this.cliPlanFetchedRecords = [];
                this.error = parseErrorMessage(error);

            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }


    populateListViewData (newData) {
        const sfdcBaseUrl = this.baseUrl+'/';
        let listViewData =[];
        newData.forEach(row=>{
            //show the percentage value 
            row.discount = row.discount/100;
            //retrive current record id and Name
            if (row.name) {
                row.nameUrl = sfdcBaseUrl + row.id;
            }
            // SVMXA360__ProductId__c releated data
            if (row.productId) {
                row.productUrl = sfdcBaseUrl + row.productId;
            }
            // SVMXA360__ServiceContractPlanId__c releated data
            if (row.serviceContractPlanId) {
                row.serviceContractPlanUrl = sfdcBaseUrl + row.serviceContractPlanId;
            }
            listViewData =[...listViewData, { ...row }]
        });
        return listViewData;
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        try {
            this.filterListViewData(searchKey);
        } catch (e) {
            this.error = parseErrorMessage(e);
        }
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this._listViewRecords = [];
            this.cliPlanRecords = [];
            this.fetchRecords();
        } else {
            this._listViewRecords = this.cliPlanRecords.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const productFamilyMatch = (item.productFamily)
                    ? item.productFamily.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const productMatch = (item.productName)
                    ? item.productName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (productFamilyMatch !== -1 || productMatch !== -1);
            });
        }
    }


    get listViewRecords () {
        // eslint-disable-next-line max-len
        return (this._listViewRecords && this._listViewRecords.length) ? this._listViewRecords : null;
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.EDIT);
                break;
            case 'delete':
                this.openDeleteModal(row);
                break;
            default:
                break;
        }
    }

    handleNewRecord () {
        //calling child component method - handleNewContractLinePlan
        this.template.querySelector(
            'c-contract-line-item-plan-detail').handleNewContractLinePlan(this.parentId);
    }

    openEditModal (currentRecordId, actionName) {
        const cliPlancmp = this.template.querySelector("c-contract-line-item-plan-detail");
        if (cliPlancmp && currentRecordId && actionName) {
            const selectedRecords = this.cliPlanFetchedRecords.filter(cliPlan => {
                return (cliPlan && cliPlan.id === currentRecordId);
            })

            if (selectedRecords && selectedRecords.length > 0) {
                cliPlancmp.handleEditContractLinePlan(selectedRecords[0], actionName);
            }
        }
    }

    openDeleteModal (currentRecord) {
        this.pendingDeleteRecord = currentRecord;
        this.deleteModalDialogOpen = true;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();
        if (!this.pendingDeleteRecord) return;

        deleteContractLineItemPlan({
            contractLineItemPlanId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${this.i18n.msgDeleted}- ${this.pendingDeleteRecord.name}`;
                this.refreshEntitledService();
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.init();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.pendingDeleteRecord = undefined;
            });
    }

    refreshEntitledService () {
        const payload = {
            recordId: this.recordId,
        };

        publish(this.context, refreshListViewChannel, payload);
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
    handleRefresh () {
        this.init();
    }

}