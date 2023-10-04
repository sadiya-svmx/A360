import { LightningElement, track, api } from 'lwc';
import getContractPriceLineItemPlans
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getContractPriceLineItemPlans';
import deleteContractPriceLinePlan
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.deleteContractPriceLinePlan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { parseErrorMessage, verifyApiResponse, PAGE_ACTION_TYPES } from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import { createMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import refreshListViewChannel from "@salesforce/messageChannel/RefreshListView__c";

import contractPriceLineItemsPlanListView
    from '@salesforce/resourceUrl/contractPriceLineItemsPlanListView';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelCPLIPlanTitle from '@salesforce/label/c.Title_ContractPriceLineItemPlans';
import labelRecordNumber from '@salesforce/label/c.Label_RecordNumber';
import labelContractLineItemPlan from '@salesforce/label/c.Label_ContractLineItemPlan';
import labelEntitledServicePlan from '@salesforce/label/c.Label_EntitledServicePlan';
import labelCPLIType from '@salesforce/label/c.Label_CPLIType';
import labelLineLevel from '@salesforce/label/c.Label_Line_Level';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelExpenseItem from '@salesforce/label/c.Label_ExpenseItem';
import labelContractUnitPrice from '@salesforce/label/c.Label_ContractUnitPrice';
import labelEntitledDiscount from '@salesforce/label/c.Label_EntitledDiscount';
import labelSurcharge from '@salesforce/label/c.Label_Surcharge';
import labelPlaceholderCPLIPlan from '@salesforce/label/c.Placeholder_Search_CPLI_Plan';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelNewPlan from '@salesforce/label/c.Button_NewContractPriceLinePlan';
import CURRENCY from '@salesforce/i18n/currency';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_DeleteCPLIPlanConfirmMessage';
import labelDeleteCPLIPlan from '@salesforce/label/c.Label_DeleteCPLIPlan';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteMessage from '@salesforce/label/c.Label_CPLIPlanDeleteMessage';
import labelSuccess from '@salesforce/label/c.Label_Success';

const i18n = {
    noResults: labelNoResults,
    loading: labelLoading,
    product: labelProduct,
    productFamily: labelProductFamily,
    title: labelCPLIPlanTitle,
    recordNumber: labelRecordNumber,
    contractLineItemPlan: labelContractLineItemPlan,
    entitledServicePlan: labelEntitledServicePlan,
    lineType: labelCPLIType,
    lineLevel: labelLineLevel,
    expenseItem: labelExpenseItem,
    entitledPrice: labelContractUnitPrice,
    entitledDiscount: labelEntitledDiscount,
    surcharge: labelSurcharge,
    placeholderCPLIPlan: labelPlaceholderCPLIPlan,
    newPlan: labelNewPlan,
    delete: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    currencyCode: CURRENCY,
    cancel: labelCancel,
    confirm: labelConfirm,
    deletePriceLineItemPlan: labelDeleteCPLIPlan,
    deleteConfirmMessage: labelDeleteConfirmMessage,
    msgDeleted: labelDeleteMessage,
    success: labelSuccess,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.delete, name: 'delete' },
];


export default class ContractPriceLineItemsPlanListView extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track cpliPlanRecords = [];
    @track fetchedCpliPlanRecords = [];
    @track apiInProgress= false;
    @track deleteModalDialogOpen;
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
        this.handleSubscribe();
    }

    renderedCallback () {
        loadStyle(this, contractPriceLineItemsPlanListView)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        const listViewTable = this.template.querySelector(
            '.svmx-contract-price-line-item-plans-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    disconnectedCallback () {
        unsubscribe(this.channel);
    }

    init () {
        this._listViewRecords = [];
        this.cpliPlanRecords = [];
        this.fetchedCpliPlanRecords = [];
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
                label: this.i18n.contractLineItemPlan,
                fieldName: 'contractLineItemPlanUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'contractLineItemPlanName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.entitledServicePlan,
                fieldName: 'entitledServicePlanUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'entitledServicePlanName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.lineLevel,
                fieldName: 'planType',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.lineType,
                fieldName: 'lineType',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
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
                label: this.i18n.expenseItem,
                fieldName: 'expenseItem',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.entitledPrice,
                fieldName: 'entitledPrice',
                type: 'currency',
                hideDefaultActions: true,
                wrapText: false,
                cellAttributes: {
                    alignment: 'left'
                },
                typeAttributes: {
                    currencyCode: {
                        fieldName: "currencyIsoCode"
                    }
                }
            },
            {
                label: this.i18n.entitledDiscount,
                fieldName: 'entitledDiscount',
                type: 'percent',
                hideDefaultActions: true,
                wrapText: false,
                cellAttributes: { alignment: 'left' },
                typeAttributes: { maximumFractionDigits: 2 }
            },
            {
                label: this.i18n.surcharge,
                fieldName: 'surcharge',
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

    handleSubscribe () {
        this.channel = subscribe(this.context, refreshListViewChannel, function (event) {
            if (event != null && event.recordId === this.parentId) {
                this.init();
            }
        }.bind(this));
    }

    fetchRecords () {
        let newData;
        return getContractPriceLineItemPlans({
            masterRecordId: this.parentId
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.currentRecordCount = result.data.length;
            if (this.currentRecordCount === 0) {
                return;
            }
            this.fetchedCpliPlanRecords = JSON.parse(JSON.stringify(result.data));
            newData = this.populateListViewData(JSON.parse(JSON.stringify(result.data)));
            const newRecords = [...this._listViewRecords, ...newData];
            this._listViewRecords = newRecords;
            this.cpliPlanRecords = this._listViewRecords;
            this.error = undefined;
        })
            .catch(error => {
                this._listViewRecords = [];
                this.cpliPlanRecords = [];
                this.fetchedCpliPlanRecords = [];
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
            row.entitledDiscount = row.entitledDiscount/100;
            row.surcharge = row.surcharge/100;
            //retrive current record id and Name
            if (row.name) {
                row.nameUrl = sfdcBaseUrl + row.id;
            }
            // SVMXA360__ProductId__c releated data
            if (row.productId) {
                row.productUrl = sfdcBaseUrl + row.productId;
            }
            // SVMXA360__ContractLineItemPlanId__c releated data
            if (row.contractLineItemPlanId) {
                row.contractLineItemPlanUrl = sfdcBaseUrl + row.contractLineItemPlanId;
            }
            // SVMXA360__EntitledServicePlanId__c releated data
            if (row.entitledServicePlanId) {
                row.entitledServicePlanUrl = sfdcBaseUrl + row.entitledServicePlanId;
            }
            //Update default currency code for single currency org
            if (!row.currencyIsoCode) {
                row.currencyIsoCode = this.i18n.currencyCode;
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
        //Search Type,Product,Product Family,Applicable Contract Line Product, Entitled Service Plan
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this._listViewRecords = [];
            this.cpliPlanRecords = [];
            this.fetchRecords();
        } else {
            this._listViewRecords = this.cpliPlanRecords.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const typeMatch = (item.lineType)
                    ? item.lineType.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const productMatch = (item.productName)
                    ? item.productName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const productFamilyMatch = (item.productFamily)
                    ? item.productFamily.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const contractLinePlanNameMatch = (item.contractLineItemPlanName)
                    ? item.contractLineItemPlanName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const entitledServicePlanNameMatch = (item.entitledServicePlanName)
                    ? item.entitledServicePlanName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (typeMatch !== -1 || productMatch !== -1  || productFamilyMatch !== -1  ||
                        contractLinePlanNameMatch !== -1 || entitledServicePlanNameMatch !== -1 );
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
                this.openEditModal(row.id, PAGE_ACTION_TYPES.EDIT);
                break;
            case 'delete':
                this.openDeleteModal(row);
                break;
            default:
                break;
        }
    }

    handleNewRecord () {
        const cpliPlanCmp = this.template.querySelector('c-contract-price-line-item-plan-detail');
        if (cpliPlanCmp) {
            cpliPlanCmp.handleNewContractPriceLineItemPlan(this.parentId);
        }
    }

    handleRefresh () {
        this.init();
    }

    openEditModal (selectedRecordId, actionName) {

        if (selectedRecordId
            && this.fetchedCpliPlanRecords
            && this.fetchedCpliPlanRecords.length > 0) {

            this.fetchedCpliPlanRecords.forEach(cpliPlanRecord => {
                if (cpliPlanRecord.id === selectedRecordId) {
                    const cpliPlanCmp = this.template.querySelector(
                        'c-contract-price-line-item-plan-detail'
                    );
                    if (cpliPlanCmp) {
                        cpliPlanCmp.handleEditContractPriceLineItemPlan(cpliPlanRecord, actionName);
                    }
                }
            });
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

        deleteContractPriceLinePlan({
            contractPriceLinePlanId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${this.i18n.msgDeleted}- ${this.pendingDeleteRecord.name}`;
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

}