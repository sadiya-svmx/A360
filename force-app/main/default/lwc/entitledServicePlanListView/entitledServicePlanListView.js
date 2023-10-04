import { LightningElement, track, api } from 'lwc';
import getEntitledServices
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getEntitledServicePlans';
import deleteEntitledServicePlan
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.deleteEntitledServicePlan';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { parseErrorMessage, verifyApiResponse, PAGE_ACTION_TYPES } from 'c/utils';
import { publish, createMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import refreshListViewChannel from "@salesforce/messageChannel/RefreshListView__c";

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelEntitledServicePlans from '@salesforce/label/c.Label_EntitledServicePlans';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search_EntitledServicePlan';
import labelAddNewServicePlan from '@salesforce/label/c.Button_NewServicePlan';
import labelEntitledServiceTitle from '@salesforce/label/c.Label_EntitledServiceTitle';
import labelContractLineItemPlan from '@salesforce/label/c.Label_ContractLineItemPlan';
import labelEntitledServiceDuration from '@salesforce/label/c.Label_EntitledServiceDuration';
import labelEntitledServiceUnitOfTime from '@salesforce/label/c.Label_EntitledServiceUnitOfTime';
import labelEntitledServiceProduct from '@salesforce/label/c.Label_EntitledServiceProduct';
import labelTotalService from '@salesforce/label/c.Label_Total_Service';
import labelCaseEntitlementProcess from '@salesforce/label/c.Label_Case_EntitlementProcess';
import labelWO_EntitlementProcess from '@salesforce/label/c.Label_WO_EntitlementProcess';
import labelServiceUnit from '@salesforce/label/c.Label_ServiceUnit';
import labelOperatingHours from '@salesforce/label/c.Label_OperatingHours';
import labelPlanType from '@salesforce/label/c.Label_EntitledServicePlanType';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_DeleteESPlanConfirmMessage';
import labelDeleteESPlan from '@salesforce/label/c.Label_DeleteESPlan';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteMessage from '@salesforce/label/c.Label_ESPlanDeleteMessage';
import labelSuccess from '@salesforce/label/c.Label_Success';

const i18n = {
    noResults: labelNoResults,
    loading: labelLoading,
    delete: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    title: labelEntitledServicePlans,
    searchPlaceholder: labelSearchPlaceholder,
    newServicePlan: labelAddNewServicePlan,
    servicePlanTitle: labelEntitledServiceTitle,
    contractLineItemPlan: labelContractLineItemPlan,
    entitledServiceDuration: labelEntitledServiceDuration,
    entitledServiceUnitOfTime: labelEntitledServiceUnitOfTime,
    product: labelEntitledServiceProduct,
    caseProcess: labelCaseEntitlementProcess,
    workOrderProcess: labelWO_EntitlementProcess,
    serviceUnit: labelServiceUnit,
    operatingHours: labelOperatingHours,
    totalService: labelTotalService,
    planType: labelPlanType,
    deleteEntitledServicePlan: labelDeleteESPlan,
    deleteConfirmMessage: labelDeleteConfirmMessage,
    msgDeleted: labelDeleteMessage,
    success: labelSuccess,
    cancel: labelCancel,
    confirm: labelConfirm,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.delete, name: 'delete' },
];

const SERVICE_UNIT_AMOUNT = 'Amount';

export default class entitledServicePlansListView extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track servicePlanRecords = [];
    @track entitledServiceFetchedRecords = [];
    @track apiInProgress= false;
    @track deleteModalDialogOpen;

    pendingDeleteRecord;
    totalRecordCount;
    _listViewTableHeight = 100;
    channel;
    context = createMessageContext();


    //sfdc base url to redirect to detail page from list view
    baseUrl;
    constructor () {
        super();
        this.columns = this.getColumns();
    }


    connectedCallback () {

        this.baseUrl = window.location.origin;
        this.parentId = this.recordId;
        this.fetchRecords();
        this.handleSubscribe();
    }

    renderedCallback () {
        const listViewTable = this.template.querySelector(
            '.svmx-entitled-service-plans-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    disconnectedCallback () {
        unsubscribe(this.channel);
    }

    handleSubscribe () {
        this.channel = subscribe(this.context, refreshListViewChannel, function (event) {
            if (event != null && event.recordId === this.recordId) {
                this.init();
            }
        }.bind(this));
    }

    init () {
        this._listViewRecords = [];
        this.entitledServiceFetchedRecords = [];
        this.servicePlanRecords = [];
        this.fetchRecords();
    }

    get i18n () {
        return i18n;
    }

    get noRecordsFound () {
        return (this._listViewRecords.length === 0);
    }

    get recordCountInfo () {
        return (this.totalRecordCount > 1)?`${this.totalRecordCount} ${this.i18n.items}`
            : `${this.totalRecordCount} ${this.i18n.item}`;
    }

    get computedDataTableHeight () {
        return (this.totalRecordCount > 10) ?
            `height:400px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    getColumns () {
        return [
            {
                label: this.i18n.servicePlanTitle,
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
                label: this.i18n.contractLineItemPlan,
                fieldName: 'ContractLineItemPlanUrl',
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
                label: this.i18n.entitledServiceDuration,
                fieldName: 'duration',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.i18n.entitledServiceUnitOfTime,
                fieldName: 'unitOfTime',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.i18n.product,
                fieldName: 'serviceProductUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'serviceProductName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.totalService,
                fieldName: 'totalService',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.i18n.serviceUnit,
                fieldName: 'serviceUnit',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.caseProcess,
                fieldName: 'caseEntitlementProcessName',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.workOrderProcess,
                fieldName: 'workOrderEntitlementProcessName',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.operatingHours,
                fieldName: 'operatingHoursUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'operatingHoursName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.planType,
                fieldName: 'planType',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
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
        this.apiInProgress = true;
        return getEntitledServices({
            masterRecordId: this.recordId
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.totalRecordCount = result.data.length;
            if (this.totalRecordCount === 0) {
                return;
            }
            this.entitledServiceFetchedRecords = JSON.parse(JSON.stringify(result.data));
            const entitledServiceList = JSON.parse(JSON.stringify(result.data));
            newData = this.populateListViewData(entitledServiceList);
            const newRecords = [...this._listViewRecords, ...newData];
            this._listViewRecords = newRecords;
            this.servicePlanRecords = this._listViewRecords;

            this.error = undefined;

        })
            .catch(error => {
                this._listViewRecords = [];
                this.servicePlanRecords = [];
                this.entitledServiceFetchedRecords = [];
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
            if (row.name) {
                row.NameUrl = sfdcBaseUrl + row.id;
            }
            if (row.contractLineItemPlanId) {
                row.ContractLineItemPlanUrl = sfdcBaseUrl + row.contractLineItemPlanId;
            }
            if (row.serviceProductId) {
                row.serviceProductUrl = sfdcBaseUrl + row.serviceProductId;
            }
            if (row.serviceUnit === SERVICE_UNIT_AMOUNT) {
                row.totalService = (row.totalService) ?
                    this.formattedCurrencyValue(row.totalService) :0;
            }
            if (row.operatingHoursId) {
                row.operatingHoursUrl = sfdcBaseUrl + row.operatingHoursId;
            }
            listViewData =[...listViewData, { ...row }]
        });
        return listViewData;
    }

    formattedCurrencyValue (currencyValue) {
        const formatOptions = {
            style: 'currency',
            currency: CURRENCY,
            currencyDisplay: 'symbol'
        }
        return new Intl.NumberFormat(LOCALE, formatOptions).format(currencyValue);
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

    refreshCPLIPlanListView () {
        const payload = {
            recordId: this.recordId,
        };

        publish(this.context, refreshListViewChannel, payload);
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this._listViewRecords = [];
            this.servicePlanRecords = [];
            this.fetchRecords();
        } else {
            this._listViewRecords = this.servicePlanRecords.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const nameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const contractLinePlanNameMatch = (item.contractLineItemPlanName)
                    ? item.contractLineItemPlanName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const productMatch = (item.serviceProductName)
                    ? item.serviceProductName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (nameMatch !== -1 || contractLinePlanNameMatch !== -1 ||
                        productMatch !== -1);
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
        this.template.querySelector('c-entitled-service-plan-detail').
            handleNewEntitledServicePlan(this.parentId);
    }

    openEditModal (currentRecordId, actionName) {
        const entitledServicePlanCmp =
            this.template.querySelector('c-entitled-service-plan-detail');
        if (entitledServicePlanCmp && currentRecordId && actionName) {

            const selectedRecords = this.entitledServiceFetchedRecords.filter(
                entitledServicePlan => {
                    return (entitledServicePlan && entitledServicePlan.id === currentRecordId);
                }
            );

            if (selectedRecords) {
                entitledServicePlanCmp.handleEditEntitledServicePlan(
                    selectedRecords[0],
                    actionName
                );
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

        deleteEntitledServicePlan({
            entitledServicePlanId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${this.i18n.msgDeleted}- ${this.pendingDeleteRecord.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.refreshCPLIPlanListView();
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

    handleRefresh () {
        this.init();
    }
}