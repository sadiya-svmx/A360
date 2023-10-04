import { LightningElement, api, track } from 'lwc';
import getOfferedMPTs
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getOfferedMPTs';
import deleteOfferedMPT
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.deleteOfferedMPT';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { parseErrorMessage, verifyApiResponse } from 'c/utils';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search_MaintenacePlanTemplate';
import labelMaintenancePlanTemplate from '@salesforce/label/c.Label_MaintenancePlanTemplate';
import labelAddMaintenancePlan
    from '@salesforce/label/c.Button_AddOfferedMPT';
import labelOfferedMaintenancePlanTemplateName
    from '@salesforce/label/c.Label_OfferedMaintenancePlanTemplateName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelActive from '@salesforce/label/c.Label_Active';
import labelDeleteOfferedMPT from '@salesforce/label/c.Label_DeleteOfferedMPT';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelOfferedMPTDeleteMessage
    from '@salesforce/label/c.Label_OfferedMPTDeleteMessage';
import labelDeleteOfferedMPTConfirmMessage
    from '@salesforce/label/c.Label_DeleteOfferedMPTConfirmMessage';

const i18n = {
    noResults: labelNoResults,
    loading: labelLoading,
    delete: labelDeleteMenuItem,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    title: labelMaintenancePlanTemplate,
    searchPlaceholder: labelSearchPlaceholder,
    addMaintenancePlan: labelAddMaintenancePlan,
    offeredMaintenancePlanTemplateName: labelOfferedMaintenancePlanTemplateName,
    description: labelDescription,
    active: labelActive,
    deleteMPT: labelDeleteOfferedMPT,
    cancel: labelCancel,
    confirm: labelConfirm,
    offeredMPTDeleteMessage: labelOfferedMPTDeleteMessage,
    deleteOfferedMPTConfirmMessage: labelDeleteOfferedMPTConfirmMessage
}

const ROW_ACTIONS = [
    { label: i18n.delete, name: 'delete' },
];

export default class OfferedMaintenancePlanTemplateListView extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track columns;
    @track parentId;
    @track error;
    @track _listViewRecords = [];
    @track maintenancePlanRecords = [];
    @track maintenancePlanFetchedRecords = [];
    @track apiInProgress= false;
    @track deleteModalDialogOpen;

    pendingDeleteRecord;
    totalRecordCount;
    _listViewTableHeight = 100;

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
    }

    renderedCallback () {
        const listViewTable = this.template.querySelector(
            '.svmx-maintenance-plans-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
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
                label: this.i18n.offeredMaintenancePlanTemplateName,
                fieldName: 'maintenancePlanTemplateUrl',
                hideDefaultActions: true,
                wrapText: false,
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'maintenancePlanTemplateName'
                    },
                    target: '_blank'
                }
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                hideDefaultActions: true,
                wrapText: true,
                type: 'text',
            },
            {
                label: this.i18n.active,
                fieldName: 'isActive',
                hideDefaultActions: true,
                type: 'boolean',
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
        return getOfferedMPTs({
            masterRecordId: this.recordId
        }).then(result => {
            this._listViewRecords = [];
            this.maintenancePlanRecords = [];
            this.maintenancePlanFetchedRecords = [];
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.totalRecordCount = result.data.length;
            if (this.totalRecordCount === 0) {
                return;
            }

            this.maintenancePlanFetchedRecords = JSON.parse(JSON.stringify(result.data));
            const maintenancePlanList = JSON.parse(JSON.stringify(result.data));
            newData = this.populateListViewData(maintenancePlanList);
            const newRecords = [...this._listViewRecords, ...newData];
            this._listViewRecords = newRecords;
            this.maintenancePlanRecords = this._listViewRecords;

            this.error = undefined;

        })
            .catch(error => {
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
            if (row.maintenancePlanTemplateId) {
                row.maintenancePlanTemplateUrl = sfdcBaseUrl + row.maintenancePlanTemplateId;
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
            this.maintenancePlanRecords = [];
            this.fetchRecords();
        } else {
            this._listViewRecords = this.maintenancePlanRecords.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const nameMatch = (item.maintenancePlanTemplateName)
                    ? item.maintenancePlanTemplateName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (nameMatch !== -1);
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
            case 'delete':
                this.openDeleteModal(row);
                break;
            default:
                break;
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

        deleteOfferedMPT({
            offeredMPTId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg
                    = `${this.i18n.offeredMPTDeleteMessage}- ${this.pendingDeleteRecord.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.fetchRecords();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.pendingDeleteRecord = undefined;
            });
    }

    handleAddTemplate () {
        const offeredMPTCmp = this.template.querySelector(
            'c-offered-maintenance-plan-template-detail');
        if (offeredMPTCmp) {
            offeredMPTCmp.handleNewOfferedMPT(this.parentId);
        }
    }

    handleRefresh () {
        this.fetchRecords();
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