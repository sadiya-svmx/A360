import { LightningElement, track, api } from 'lwc';
import getEntitledServices
    from '@salesforce/apex/EVER_EntitledService_LS.getEntitledServices';
import { parseErrorMessage, verifyApiResponse, PAGE_ACTION_TYPES, sortObjectArray } from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import entitledServicesListView from '@salesforce/resourceUrl/entitledServicesListView';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelCopyMenuItem from '@salesforce/label/c.Menu_Clone';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelEntitledServices from '@salesforce/label/c.Label_Entitled_Services';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search_EntitledService';
import labelAddNewService from '@salesforce/label/c.Button_NewService';
import labelServiceName from '@salesforce/label/c.Label_Service_Name';
import labelContractLine from '@salesforce/label/c.Label_ContractLine';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelTotalService from '@salesforce/label/c.Label_Total_Service';
import labelRemainingService from '@salesforce/label/c.Label_Remaining_Service';
import labelStartDate from '@salesforce/label/c.Label_Start_Date';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelCaseEntitlementProcess from '@salesforce/label/c.Label_Case_EntitlementProcess';
import labelWO_EntitlementProcess from '@salesforce/label/c.Label_WO_EntitlementProcess';
import labelServiceUnit from '@salesforce/label/c.Label_ServiceUnit';
import TIMEZONE from '@salesforce/i18n/timeZone';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';
import labelOperatingHours from '@salesforce/label/c.Label_OperatingHours';

const i18n = {
    noResults: labelNoResults,
    loading: labelLoading,
    delete: labelDeleteMenuItem,
    edit: labelEditMenuItem,
    copy: labelCopyMenuItem,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    title: labelEntitledServices,
    searchPlaceholder: labelSearchPlaceholder,
    newService: labelAddNewService,
    serviceName: labelServiceName,
    contractLine: labelContractLine,
    asset: labelAsset,
    totalService: labelTotalService,
    remainingService: labelRemainingService,
    startDate: labelStartDate,
    endDate: labelEndDate,
    caseProcess: labelCaseEntitlementProcess,
    workOrderProcess: labelWO_EntitlementProcess,
    serviceUnit: labelServiceUnit,
    timeZone: TIMEZONE,
    operatingHours: labelOperatingHours,
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.copy, name: 'clone' },
    { label: i18n.delete, name: 'delete' },
];
const DELAY = 500;
const DEFAULT_ORDER_FIELD ='ID';
const DEFAULT_ORDER ='DESC';
const PAGE_SIZE = 50;
const SERVICE_TYPE_AMOUNT = 'Amount';
export default class EntitledServicesListView extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track esRecordList = [];
    @track noRecordsFound;
    @track sortBy = 'Name';
    @track sortDirection = 'desc';

    //show spinner while loading the data
    @track apiInProgress= false;

    searchKey = '';
    currentRecordCount = 0;
    queryLimit;
    totalRecordCount;
    lastRecordId;
    _listViewTableHeight = 100;
    //default order is desc on ID field.
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

    renderedCallback () {
        loadStyle(this, entitledServicesListView)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });

        const listViewTable = this.template.querySelector(
            '.svmx-entitled-services-list-view_table');
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
        this.esRecordList = [];
        this.noRecordsFound = false;
        this.apiInProgress = true;
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
                label: this.i18n.serviceName,
                type: 'button',
                wrapText: false,
                sortable: true,
                fieldName: 'name',
                typeAttributes: {
                    label: {
                        fieldName: 'name'
                    },
                    name: 'view',
                    variant: 'base'
                }
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
                        fieldName: 'contractLineName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.asset,
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
                label: this.i18n.totalService,
                fieldName: 'totalService',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.i18n.remainingService,
                fieldName: 'remainingService',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: this.i18n.serviceUnit,
                fieldName: 'serviceType',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
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
                label: this.i18n.caseProcess,
                fieldName: 'caseEntitlementProcessName',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
            },
            {
                label: this.i18n.workOrderProcess,
                fieldName: 'workOrderEntitlementProcessName',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
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
        return getEntitledServices({
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
            const entitledServiceList = JSON.parse(
                JSON.stringify(result.data.entitledServiceDetailList));
            newData = this.populateListViewData(entitledServiceList);
            //const newRecords = [...this._listViewRecords, ...newData];
            this._listViewRecords = newData;

            // eslint-disable-next-line max-len
            this.currentRecordCount = isLoadMore ? (this.currentRecordCount + newData.length) : newData.length;
            this.esRecordList = JSON.parse(JSON.stringify(this._listViewRecords));
            this.error = undefined;

        })
            .catch(error => {
                this._listViewRecords = [];
                this.esRecordList = [];
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
            const lastRecId = currentListViewData[currentListViewData.length - 1].id;
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
            if (row.contractLineId) {
                row.ContractLineUrl = sfdcBaseUrl + row.contractLineId;
            }
            if (row.assetId) {
                row.assetUrl = sfdcBaseUrl + row.assetId;
            }
            if (row.serviceType === SERVICE_TYPE_AMOUNT) {
                row.totalService = (row.totalService) ?
                    this.formattedCurrencyValue(row.totalService) :0;
                row.remainingService = (row.remainingService) ?
                    this.formattedCurrencyValue(row.remainingService) :0;
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
        if (this.esRecordList && this.esRecordList.length > 0) {
            return this.esRecordList;
        }
        return null;
    }


    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.VIEW);
                break;
            case 'edit':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.CLONE);
                break;
            case 'delete':
                this.openDeleteModal(row);
                break;
            default:
                break;
        }
    }

    handleNewRecord () {
        this.template.querySelector('c-entitled-service-detail').
            handleNewEntitledService(this.parentId,false);
    }

    openEditModal (currentRecordId,actionName) {
        this.template.querySelector(
            'c-entitled-service-detail').handleEditEntitledService(currentRecordId,actionName);
    }

    openDeleteModal (currentRecord) {
        this.template.querySelector(
            'c-entitled-service-detail').handleDeleteEntitledService(currentRecord);
    }

    handleRefresh () {
        this.init();
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        const newDataList = this.sortData(JSON.parse(JSON.stringify(this.esRecordList)));
        this.esRecordList = newDataList;
    }

    sortData (incomingData) {
        let sortByOverride
        if (this.sortBy === "ContractLineUrl") {
            sortByOverride ='contractLineName';
        } else if (this.sortBy === "assetUrl") {
            sortByOverride ='assetName';
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