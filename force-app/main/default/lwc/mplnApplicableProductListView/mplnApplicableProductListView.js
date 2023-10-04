import { LightningElement, track, api } from 'lwc';
import deleteApplicableProduct
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.deleteApplicableProduct';
import { parseErrorMessage, verifyApiResponse } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { publish, createMessageContext } from 'lightning/messageService';
import refreshListViewChannel from "@salesforce/messageChannel/RefreshListView__c";

import getDataModel from './mplnApplicableProductDataModel';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelApplicableProduct from '@salesforce/label/c.Label_ApplicableProduct';
import labelProduct from '@salesforce/label/c.Label_ProductInApplicableProduct';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelWorkType from '@salesforce/label/c.Label_WorkType';
import labelNewApplicableProduct from '@salesforce/label/c.Button_NewApplicableProduct';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelSuccess from '@salesforce/label/c.Label_APSuccess';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_APDeleteConfirmMessage';
import labelDeleteMessage from '@salesforce/label/c.Label_APDeleteMessage';
import labelDeleteApplicableProduct from '@salesforce/label/c.Label_DeleteApplicableProduct';
import labelPlaceholder from '@salesforce/label/c.Placeholder_SearchListApplicableProduct';
import labelSearchTitle from '@salesforce/label/c.Title_SearchListApplicableProduct';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';

const i18n = {
    title: labelApplicableProduct,
    edit: labelEditMenuItem,
    delete: labelDeleteMenuItem,
    cancel: labelCancel,
    confirm: labelConfirm,
    name: labelApplicableProduct,
    product: labelProduct,
    productFamily: labelProductFamily,
    workType: labelWorkType,
    newApplicableProduct: labelNewApplicableProduct,
    loading: labelLoading,
    noResults: labelNoResults,
    deleteApplicableProduct: labelDeleteApplicableProduct,
    msgDeleted: labelDeleteMessage,
    success: labelSuccess,
    deleteConfirmMessage: labelDeleteConfirmMessage,
    placeholder: labelPlaceholder,
    searchTitle: labelSearchTitle,
    items: labelItemsRowCount,
    item: labelItemRowCount,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.delete, name: 'delete' },
];

const SUCCESS = 'success';

export default class MplnApplicableProductListView extends LightningElement {

    @api recordId;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track noRecordsFound;
    @track deleteModalDialogOpen;
    @track apiInProgress= false;

    /** context for message channel */
    context = createMessageContext();

    pendingDeleteRecord;
    baseUrl;
    originalRecords = [];
    fieldListForSearch = ['productName', 'productFamily', 'workTypeName'];
    searchkeyword = '';
    _listViewTableHeight = 100;
    currentRecordCount = 0;

    constructor () {
        super();
        this.columns = this.getColumns();
        this.dataModel = getDataModel();
    }

    connectedCallback () {
        this.baseUrl = window.location.origin;
        this.parentId = this.recordId;
        this.init();
    }

    renderedCallback () {
        const listViewTable = this.template.querySelector(
            '.svmx-applicable-product-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    init () {
        this._listViewRecords = [];
        this.noRecordsFound = false;
        this.apiInProgress = true;
        this.fetchRecords();
    }

    get i18n () {
        return i18n;
    }

    getColumns () {
        return [
            {
                label: this.i18n.name,
                fieldName: 'NameUrl',
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
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
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
                label: this.i18n.workType,
                fieldName: 'workTypeUrl',
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'workTypeName'
                    },
                    target: '_blank'
                }
            },
            {
                type: 'action',
                fixedWidth: 60,
                typeAttributes: { rowActions: ROW_ACTIONS },
            },
        ];
    }

    async fetchRecords () {
        const { dataModel } = this;
        const dataConfig = await dataModel.getAllApplicableProducts({
            onErrorCallback: (error) => {
                this.error = error;
            },
            onNetworkErrorCallback: (error) => {
                this._listViewRecords = [];
                this.originalRecords = [];
                this.error = parseErrorMessage(error);
            }
        },{
            maintenancePlanTemplateId: this.parentId
        });
        this.currentRecordCount = dataConfig.recordCount;
        if (this.currentRecordCount === 0) {
            this.noRecordsFound = true;
        }
        this.apiInProgress = false;
        if (this.searchkeyword && this.searchkeyword.length > 0) {
            this._listViewRecords = dataModel.getFilteredRecords({ searchKey: this.searchkeyword });
        } else {
            this._listViewRecords = dataModel.getListViewData();
        }
    }

    get listViewRecords () {
        return (this._listViewRecords && this._listViewRecords.length) ? this._listViewRecords:null;
    }

    get recordCountInfo () {
        return (this._listViewRecords.length > 1)
            ? `${this._listViewRecords.length} ${this.i18n.items}`
            : `${this._listViewRecords.length} ${this.i18n.item}`;
    }

    get computedDataTableHeight () {
        return (this.currentRecordCount > 10) ?
            `height:400px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    handleSearch (event) {
        this.searchkeyword = event.target.value.trim();
        const { dataModel } = this;
        this._listViewRecords = dataModel.getFilteredRecords({ searchKey: this.searchkeyword });
    }

    handleRefresh (event) {
        const { detail: { value }} = event;
        const { recordId } = this;
        this.init();
        /** informing the service channel that product addition was successfull */
        if (value === SUCCESS ) {
            this.refreshWorkRuleTemplate({
                recordId
            });
        }
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.openEditModal(row.id);
                break;
            case 'delete':
                this.openDeleteModal(row);
                break;
            default:
                break;
        }
    }

    openEditModal (currentRecordId) {
        this.template.querySelector('c-mpln-applicable-product-detail').
            handleEditApplicableProduct(currentRecordId);
    }

    handleNewRecord () {
        this.template.querySelector('c-mpln-applicable-product-detail').
            handleNewApplicableProduct(this.parentId);
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

        this.apiInProgress = true;
        deleteApplicableProduct({
            applicableProductId: this.pendingDeleteRecord.id })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                const toastMsg = `${this.i18n.msgDeleted}- ${this.pendingDeleteRecord.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.refreshWorkRuleTemplate({ recordId: this.recordId });
                this.init();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.pendingDeleteRecord = undefined;
                this.apiInProgress = false;
            });
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

    /** Publishing to message channel */
    refreshWorkRuleTemplate ({ recordId }) {
        const payload = {
            recordId,
        };

        publish(this.context, refreshListViewChannel, payload);
    }

}