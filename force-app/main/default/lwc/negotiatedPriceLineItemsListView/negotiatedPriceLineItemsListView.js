import { LightningElement, track, api } from 'lwc';
import getContractPriceLineItems
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.getContractPriceLineItems';
import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    PAGE_ACTION_TYPES,
    sortObjectArray } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelCopyMenuItem from '@salesforce/label/c.Menu_Clone';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelCPLIName from '@salesforce/label/c.Label_CPLIName';
import labelCPLIType from '@salesforce/label/c.Label_CPLIType';
import labelExpenseItems from '@salesforce/label/c.Label_ExpenseItems';
import labelContractUnitPrice from '@salesforce/label/c.Label_ContractUnitPrice';
import labelDiscount from '@salesforce/label/c.Label_Discount';
import labelSurcharge from '@salesforce/label/c.Label_Surcharge';
import labelContractLine from '@salesforce/label/c.Label_ContractLine';
import labelEntitledService from '@salesforce/label/c.Label_EntitledService';
import labelCPLITitle from '@salesforce/label/c.Label_ContractPriceLineItems';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchFor_CPLI';
import labelAddNewPriceLineItem from '@salesforce/label/c.Button_AddPriceLineItem';
import labelPlaceholder from '@salesforce/label/c.Placeholder_SearchList_For_CPLI';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteMessage from '@salesforce/label/c.Label_CPLIDeleteMessage';
import labelDeletePriceLineItem from '@salesforce/label/c.Label_DeletePriceLineItem';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_DeleteConfirmMessage';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelRowCountMessage
    from '@salesforce/label/c.Message_ServiceCountMessageWithoutBrackets';
import CURRENCY from '@salesforce/i18n/currency';

const i18n = {
    noResults: labelNoResults,
    searchPlaceholder: labelSearchPlaceholder,
    loading: labelLoading,
    name: labelCPLIName,
    type: labelCPLIType,
    product: labelProduct,
    productFamily: labelProductFamily,
    expenseItem: labelExpenseItems,
    contractUnitPrice: labelContractUnitPrice,
    discount: labelDiscount,
    surcharge: labelSurcharge,
    contractLine: labelContractLine,
    entitledService: labelEntitledService,
    title: labelCPLITitle,
    newPriceLineItem: labelAddNewPriceLineItem,
    delete: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    copy: labelCopyMenuItem,
    items: labelItemsRowCount,
    placeholder: labelPlaceholder,
    item: labelItemRowCount,
    cancel: labelCancel,
    confirm: labelConfirm,
    msgDeleted: labelDeleteMessage,
    deletePriceLineItem: labelDeletePriceLineItem,
    deleteConfirmMessage: labelDeleteConfirmMessage,
    success: labelSuccess,
    rowCountMessage: labelRowCountMessage,
    currencyCode: CURRENCY,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.copy, name: 'clone' },
    { label: i18n.delete, name: 'delete' },
];
const DELAY = 500;
const DEFAULT_ORDER_FIELD ='Name';
const DEFAULT_ORDER ='DESC';

export default class NegotiatedPriceLineItemsListView extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track cpliRecordList = [];
    @track noRecordsFound;
    @track deleteModalDialogOpen;
    //show spinner while loading the data
    @track apiInProgress= false;
    @track sortBy = 'Name';
    @track sortDirection = 'desc';

    searchKey = '';
    currentRecordCount = 0;
    queryLimit;
    totalRecordCount;
    pendingDeleteRecord;
    lastRecordId;

    //default order is asc on name field.
    sortField = DEFAULT_ORDER_FIELD;
    sortOrder = DEFAULT_ORDER;

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

    init () {

        this.queryLimit = 50;
        this.lastRecordId='';
        this.currentRecordCount = 0;
        this.totalRecordCount = 0;
        this._listViewRecords = [];
        this.cpliRecordList = [];
        this.noRecordsFound = false;
        this.apiInProgress = true;
        this.fetchRecords(false);
    }

    get i18n () {
        return i18n;
    }

    get recordCountInfo () {
        return (this.totalRecordCount > 50) ?
            formatString(i18n.rowCountMessage,
                this.currentRecordCount,
                this.totalRecordCount,
                this.i18n.items)
            : (this.totalRecordCount === 1) ?`${this.totalRecordCount} ${this.i18n.item}`
                : `${this.totalRecordCount} ${this.i18n.items}`;
    }

    getColumns () {
        return [
            {
                label: this.i18n.name,
                type: 'button',
                wrapText: false,
                fieldName: 'Name',
                sortable: true,
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    name: 'view',
                    variant: 'base'
                }
            },
            {
                label: this.i18n.type,
                fieldName: 'SVMXA360__LineType__c',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
            },
            {
                label: this.i18n.product,
                fieldName: 'SVMXA360__ProductId__c',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
            },
            {
                label: this.i18n.productFamily,
                fieldName: 'SVMXA360__ProductFamily__c',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
            },
            {
                label: this.i18n.expenseItem,
                fieldName: 'SVMXA360__ExpenseItem__c',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
            },
            {
                label: this.i18n.contractUnitPrice,
                fieldName: 'SVMXA360__EntitledPrice__c',
                type: 'currency',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: {
                    alignment: 'left'
                },
                typeAttributes: {
                    currencyCode: {
                        fieldName: "CurrencyIsoCode"
                    }
                }
            },
            {
                label: this.i18n.discount,
                fieldName: 'SVMXA360__EntitledDiscount__c',
                type: 'percent',
                hideDefaultActions: true,
                sortable: true,
                wrapText: false,
                cellAttributes: { alignment: 'left' },
                typeAttributes: { maximumFractionDigits: 2 }
            },
            {
                label: this.i18n.surcharge,
                fieldName: 'SVMXA360__Surcharge__c',
                type: 'percent',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: { alignment: 'left' },
                typeAttributes: { maximumFractionDigits: 2 }
            },
            {
                label: this.i18n.contractLine,
                fieldName: 'ContractLineUrl',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'ContractLine'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.entitledService,
                fieldName: 'EntitledServiceUrl',
                sortable: true,
                hideDefaultActions: false,
                wrapText: true,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'EntitledService'
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
        return getContractPriceLineItems({
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
            const contractPriceList = JSON.parse(JSON.stringify(result.data.cpliRecords));
            newData = this.populateListViewData(contractPriceList);
            this._listViewRecords = newData;

            // eslint-disable-next-line max-len
            this.currentRecordCount = isLoadMore ? (this.currentRecordCount + newData.length) : newData.length;

            this.cpliRecordList = JSON.parse(JSON.stringify(this._listViewRecords));
            this.error = undefined;

        })
            .catch(error => {
                this._listViewRecords = [];
                this.cpliRecordList = [];
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
            const currentListViewData = this._listViewRecords;
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

            //show the percentage value 
            row.SVMXA360__EntitledDiscount__c = row.SVMXA360__EntitledDiscount__c/100;
            row.SVMXA360__Surcharge__c = row.SVMXA360__Surcharge__c/100;
            //retrive current record id and Name
            if (row.Name) {
                row.NameUrl = sfdcBaseUrl + row.Id;
            }
            // ContractLine - SVMXA360__Contract_Line__c related data
            if (row.SVMXA360__ContractLineId__c) {
                row.ContractLine = row.SVMXA360__ContractLineId__r.LineItemNumber;
                row.ContractLineUrl = sfdcBaseUrl + row.SVMXA360__ContractLineId__c;
            }
            // EntitledService - SVMXA360__EntitledServiceId__c related data
            if (row.SVMXA360__EntitledServiceId__c) {
                row.EntitledService = row.SVMXA360__EntitledServiceId__r.Name;
                row.EntitledServiceUrl = sfdcBaseUrl + row.SVMXA360__EntitledServiceId__c;
            }
            // SVMXA360__ProductId__c releated data
            if (row.SVMXA360__ProductId__c) {
                row.SVMXA360__ProductId__c = row.SVMXA360__ProductId__r.Name;
            }
            //Update default currency code for single currency org
            if (!row.CurrencyIsoCode) {
                row.CurrencyIsoCode = this.i18n.currencyCode;
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

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        const contractPriceList = JSON.parse(JSON.stringify(this.cpliRecordList));
        const newDataList = this.sortData(contractPriceList);
        this.cpliRecordList = newDataList;
    }


    get listViewRecords () {
        if (this.cpliRecordList && this.cpliRecordList.length > 0) {
            return this.cpliRecordList;
        }
        return null;
    }


    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'view':
                this.openEditModal(row.Id,PAGE_ACTION_TYPES.VIEW);
                break;
            case 'edit':
                this.openEditModal(row.Id,PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.openEditModal(row.Id,PAGE_ACTION_TYPES.CLONE);
                break;
            case 'delete':
                this.openDeleteModal(row);
                break;
            default:
                break;
        }
    }

    handleNewRecord () {
        //calling child component method - handleNewContractPrice
        this.template.querySelector('c-negotiated-price-line-item-detail').
            handleNewContractPrice(this.parentId);
    }

    openEditModal (currentRecordId,actionName) {
        //calling child component method - handleEditContractPrice
        this.template.querySelector('c-negotiated-price-line-item-detail').
            handleEditContractPrice(currentRecordId,actionName);
    }

    handleRefresh () {
        this.init();
    }

    openDeleteModal (currentRecord) {
        this.template.querySelector('c-negotiated-price-line-item-detail').
            handleDeleteCPLI(currentRecord);
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

    sortData (incomingData) {
        let sortByOverride
        if (this.sortBy === "ContractLineUrl") {
            sortByOverride ='ContractLine';
        } else if (this.sortBy === "EntitledServiceUrl") {
            sortByOverride ='EntitledService';
        } else {
            sortByOverride = this.sortBy;
        }
        return sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

}