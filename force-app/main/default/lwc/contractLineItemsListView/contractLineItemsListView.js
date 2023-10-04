/* eslint-disable default-case */
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContractLines
    from '@salesforce/apex/CLI_ContractLines_LS.getContractLines';
import deleteCLIRecord
    from '@salesforce/apex/CLI_ContractLines_LS.deleteCLIRecord';
import { parseErrorMessage, verifyApiResponse, PAGE_ACTION_TYPES, sortObjectArray } from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import contractLineItemsListViewResource from '@salesforce/resourceUrl/contractLineItemsListView';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelContractLineITems from '@salesforce/label/c.Label_ContractLineItems';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search_CLI';
import labelAddNewLineItems from '@salesforce/label/c.Button_NewContractLineItems';
import labelLineItemNumber from '@salesforce/label/c.Label_ContractLine';
import labelProductName from '@salesforce/label/c.Label_ProductName';
import labelAssetName from '@salesforce/label/c.Label_assetName';
import labelStartDate from '@salesforce/label/c.Label_Start_Date';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelStatus from '@salesforce/label/c.Label_Status';
import labelContractLineItem from '@salesforce/label/c.Label_ContractLineItem';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelDeleteCLITitle from '@salesforce/label/c.Label_DeleteCLI_Title';
import labelCLI_DeleteConfirmMessage from '@salesforce/label/c.Label_CLI_DeleteConfirmMessage';
import label_DeleteSuccessMessage from '@salesforce/label/c.Label_CLI_DeleteSuccessMessage';
import messageDeleteErrorHeader from '@salesforce/label/c.Message_DeleteErrorHeader';

const i18n = {
    noResults: labelNoResults,
    loading: labelLoading,
    deleteMenu: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    title: labelContractLineITems,
    searchPlaceholder: labelSearchPlaceholder,
    newLineItem: labelAddNewLineItems,
    lineItemNumber: labelLineItemNumber,
    productName: labelProductName,
    assetName: labelAssetName,
    startDate: labelStartDate,
    endDate: labelEndDate,
    status: labelStatus,
    contractLineItem: labelContractLineItem,
    cancel: labelCancel,
    confirm: labelConfirm,
    delete: labelDelete,
    deleteTitle: labelDeleteCLITitle,
    deleteConfirmMessage: labelCLI_DeleteConfirmMessage,
    deleteSuccess: label_DeleteSuccessMessage,
    success: labelSuccess,
    deleteErrorHeader: messageDeleteErrorHeader,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.deleteMenu, name: 'delete' },
];
const DELAY = 500;
const DEFAULT_ORDER_FIELD ='ID';
const DEFAULT_ORDER ='DESC';
const PAGE_SIZE = 50;
export default class ContractLineItemsListView extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track clRecordList = [];
    @track noRecordsFound;
    @track sortBy = '';
    @track sortDirection = 'desc';

    //show spinner while loading the data
    @track apiInProgress= false;

    contractLinesList = [];
    searchKey = '';
    currentRecordCount = 0;
    queryLimit;
    totalRecordCount;
    lastRecordId;
    _listViewTableHeight = 100;
    //default order is desc on ID field.
    sortField = DEFAULT_ORDER_FIELD;
    sortOrder = DEFAULT_ORDER;

    deleteErrorMsg;
    deleteErrorMessageOpen = false ;
    @track deleteModalDialogOpen;
    @track pendingDeleteRecord;
    @track apiInProgress = false;
    //sfdc base url to redirect to detail page from list view
    baseUrl;

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
        loadStyle(this, contractLineItemsListViewResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });

        const listViewTable = this.template.querySelector(
            '.svmx-contract-lines-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    init () {
        this.queryLimit = PAGE_SIZE;
        this.lastRecordId='';
        this.currentRecordCount = 0;
        this.totalRecordCount = 0;
        this._listViewRecords = [];
        this.clRecordList = [];
        this.noRecordsFound = false;
        this.apiInProgress = true;
        this.contractLinesList = [];
        this.fetchRecords(false);
    }

    get i18n () {
        return i18n;
    }

    get recordCountInfo () {
        return (this.currentRecordCount > 1)?`${this.currentRecordCount} ${this.i18n.items}`
            : `${this.currentRecordCount} ${this.i18n.item}`;
    }

    get computedDataTableHeight () {
        return (this.currentRecordCount > 10) ?
            `height:400px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    getColumns () {
        return [
            {
                label: this.i18n.lineItemNumber,
                type: 'url',
                wrapText: false,
                sortable: true,
                fieldName: 'lineItemNumberUrl',
                typeAttributes: {
                    label: {
                        fieldName: 'lineItemNumber'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.assetName,
                fieldName: 'assetUrl',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'assetName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.productName,
                fieldName: 'productUrl',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'productName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.startDate,
                fieldName: 'startDate',
                type: "date",
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                typeAttributes: {
                    month: "numeric",
                    day: "numeric",
                    year: "numeric",
                    timeZone: "UTC"
                }
            },
            {
                label: this.i18n.endDate,
                fieldName: 'endDate',
                type: "date",
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                typeAttributes: {
                    month: "numeric",
                    day: "numeric",
                    year: "numeric",
                    timeZone: "UTC"
                }
            },
            {
                label: this.i18n.status,
                fieldName: 'status',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                type: 'action',
                fixedWidth: 60,
                typeAttributes: { rowActions: ROW_ACTIONS },
            },
        ];
    }

    fetchRecords (isLoadMore) {
        let newData;
        //add parameters in reqObj
        const reqObject ={
            parentId: this.parentId,
            limitCount: this.queryLimit,
            searchTerm: this.searchKey,
            sortField: this.sortField,
            sortOrder: this.sortOrder,
            id: this.lastRecordId
        };
        return getContractLines({
            requestJson: JSON.stringify(reqObject)
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.totalRecordCount = result.data.totalRecordCount;
            if (this.totalRecordCount === 0) {
                this.noRecordsFound = true;
                return;
            }
            this.contractLinesList = JSON.parse(
                JSON.stringify(result.data.cliRecords));
            newData = this.populateListViewData(this.contractLinesList);
            this._listViewRecords = newData;

            // eslint-disable-next-line max-len
            this.currentRecordCount = isLoadMore ? (this.currentRecordCount + newData.length) : newData.length;
            this.clRecordList = JSON.parse(JSON.stringify(this._listViewRecords));
            this.error = undefined;

        })
            .catch(error => {
                this.contractLinesList = [];
                this._listViewRecords = [];
                this.clRecordList = [];
                this.error = parseErrorMessage(error);

            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    handleLoadMore (event) {

        if (this.totalRecordCount === this.currentRecordCount) {
            return;
        }

        const { target } = event;
        //Display a spinner to signal that data is being loaded
        if (this.totalRecordCount > this.currentRecordCount) {
            target.isLoading = true;
            const currentListViewData = JSON.parse(JSON.stringify(this._listViewRecords));
            const lastRecId = currentListViewData[currentListViewData.length - 1].Id;
            this.lastRecordId = lastRecId;
            this.fetchRecords(true)
                .then(() => {
                    target.isLoading = false;
                });
        }
    }

    populateListViewData (newData) {

        const sfdcBaseUrl = this.baseUrl+'/';
        let listViewData =[];
        newData.forEach(row=>{
            if (row.assetId) {
                row.assetUrl = sfdcBaseUrl + row.assetId;
            }
            if (row.lineItemNumber) {
                row.lineItemNumberUrl = sfdcBaseUrl + row.id;
            }
            if (row.productId) {
                row.productUrl = sfdcBaseUrl + row.productId;
            }
            listViewData =[...listViewData, { ...row }]
        });
        return listViewData;
    }

    handleSearch (event) {
        const searchVal = event.target.value.trim();
        this.searchKey = '';
        if (searchVal && (searchVal.length >= 1 && searchVal.length < 3)) {
            return;
        }

        if ((searchVal && searchVal.length > 2) || searchVal.length === 0) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.searchKey = searchVal;
                this.init();

            }, DELAY);

        }

    }


    get listViewRecords () {
        if (this.clRecordList && this.clRecordList.length > 0) {
            return this.clRecordList;
        }
        return null;
    }


    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.openEditModal(row.id, PAGE_ACTION_TYPES.EDIT);
                break;
            case 'delete':
                this.openDeleteModal(row);
                break;
        }
    }

    handleNewRecord () {
        //calling child component method - handleNewContractLine
        this.template.querySelector(
            'c-contract-line-item-detail').handleNewContractLine(this.parentId);
    }

    openEditModal (currentRecordId, actionName) {
        const cliCmp = this.template.querySelector("c-contract-line-item-detail");

        if (cliCmp && currentRecordId && actionName) {

            const selectedRecords = this.contractLinesList.filter(cli => {
                return (cli && cli.id === currentRecordId);
            })

            if (selectedRecords && selectedRecords.length > 0) {
                cliCmp.handleEditContractLine(this.parentId, selectedRecords[0], actionName);
            }
        }
    }

    openDeleteModal (currentRecord) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = currentRecord;
    }

    handleRefresh () {
        this.init();
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        const newDataList = this.sortData(JSON.parse(JSON.stringify(this.clRecordList)));
        this.clRecordList = newDataList;
    }

    sortData (incomingData) {
        let sortByOverride
        if (this.sortBy === "Product2Url") {
            sortByOverride ='Product2.Name';
        } else if (this.sortBy === "assetUrl") {
            sortByOverride ='assetName';
        } else if (this.sortBy === "status") {
            sortByOverride ='status';
        }  else if (this.sortBy === "startDate") {
            sortByOverride ='startDate';
        }  else if (this.sortBy === "endDate") {
            sortByOverride ='endDate';
        } else {
            sortByOverride = this.sortBy;
        }
        return sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

    handleDeleteConfirmModal () {
        if (!this.pendingDeleteRecord) return;

        if (this.apiInProgress) return;

        this.apiInProgress = true;
        deleteCLIRecord({
            requestJson: JSON.stringify({ id: this.pendingDeleteRecord.id }) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.deleteModalDialogOpen = false;
                    this.deleteErrorMessageOpen = true;
                    this.deleteErrorMsg = result.message;
                    return;
                }

                this.handleCancelModal();
                // eslint-disable-next-line max-len
                const toastMsg = `${this.i18n.deleteSuccess}- ${this.pendingDeleteRecord.lineItemNumber}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleRefresh();
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

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
        this.deleteErrorMessageOpen = false;
    }

}