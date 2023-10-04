import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    parseErrorMessage,
    ICON_NAMES,
    sortObjectArray,
    PAGE_ACTION_TYPES,
    verifyApiResponse
} from 'c/utils';
import { deleteRecentItemRecords } from 'c/recentItemService';
import getProcessList from '@salesforce/apex/ADM_MaintenanceProcess_LS.getProcessList';
import deleteProcess from '@salesforce/apex/ADM_MaintenanceProcess_LS.deleteProcess';
import runProcessEngine from '@salesforce/apex/ADM_MaintenanceProcess_LS.runProcessEngine';

import labelYes from '@salesforce/label/c.Lbl_Yes';
import labelNo from '@salesforce/label/c.Lbl_No';
import labelNewButton from '@salesforce/label/c.Button_New';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelRunNowMenuItem from '@salesforce/label/c.Menu_RunNow';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelDesc from '@salesforce/label/c.Label_Description';
import labelDefault from '@salesforce/label/c.Label_Default';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelActive from '@salesforce/label/c.Label_Active';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchExpressions';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelExpressionHelp from '@salesforce/label/c.URL_ExpressionHelp';
import message_MaintenancePlanProcess from '@salesforce/label/c.Message_MaintenancePlanProcess';
import title_MaintenancePlanProcesses from '@salesforce/label/c.Title_MaintenancePlanProcesses';
import title_MaintenancePlanProcessing from '@salesforce/label/c.Title_MaintenancePlanProcessing';
import label_ProcessName from '@salesforce/label/c.Label_ProcessName';
import labelProcessLastRun from '@salesforce/label/c.Label_ProcessLastRun';
import labelProcessRunStatus from '@salesforce/label/c.Label_ProcessRunStatus';

const i18n = {
    processName: label_ProcessName,
    description: labelDesc,
    active: labelActive,
    new: labelNewButton,
    lastModifiedDate: labelLastModified,
    searchPlaceholder: labelSearchPlaceholder,
    default: labelDefault,
    items: labelItemsRowCount,
    delete: labelDeleteMenuItem,
    deleteSuccess: labelDeletedSuccess,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    runNow: labelRunNowMenuItem,
    yes: labelYes,
    no: labelNo,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    helpLink: labelExpressionHelp,
    cancel: labelCancel,
    confirm: labelConfirm,
    loading: labelLoading,
    noResults: labelNoResults,
    maintenanceProcess: message_MaintenancePlanProcess,
    maintenanceProcesses: title_MaintenancePlanProcesses,
    maintenanceProcessing: title_MaintenancePlanProcessing,
    processLastRan: labelProcessLastRun,
    processRunStatus: labelProcessRunStatus
};

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit', disabled: false },
    { label: i18n.clone, name: 'clone', disabled: false },
    { label: i18n.delete, name: 'delete', disabled: false },
    { label: i18n.runNow, name: 'run', disabled: false }
];

const ADM_MPLNPROCESS_DETAIL = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__adminMPLNProcessDetail'
    }
};

export default class MplnAdminProcessListView extends NavigationMixin(
    LightningElement
) {

    @track mplnDetailUrl;
    @track processListData;
    @track filteredProcessListData;
    @track apiInProgress;
    @track error;
    @track sortBy = 'recordUrl';
    @track sortDirection = 'asc';
    @track deleteModalDialogOpen;

    currentNavItem;

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');

        if (input) {
            input.value = '';
        }
    }

    constructor () {
        super();
        this.columns = this.getColumns();
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](ADM_MPLNPROCESS_DETAIL).then(url => {
            this.mplnDetailUrl = url;
            this.populateListView();
        });
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef) {

            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.clearSearchInputValue();
            this.getProcessListViewData();
        }
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    handleNewProcess () {
        this.navigateToDetailComponent(null, PAGE_ACTION_TYPES.NEW);
    }

    get i18n () {
        return i18n;
    }

    get rowCountPhrase () {
        return ( this.filteredProcessListData ? this.filteredProcessListData.length : 0 )
                 + ' ' + i18n.items;
    }

    getProcessListViewData () {
        this.apiInProgress = true;
        return getProcessList()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.error = null;
                this.processListData = result.data;
                this.populateListView();
            })
            .catch(error => {
                this.processListData = [];
                this.filteredProcessListData = [];
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    getColumns () {
        return [
            {
                label: this.i18n.processName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: '' },
                    target: '_self' }
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                hideDefaultActions: true,
                wrapText: false
            },
            {
                label: this.i18n.active,
                fieldName: 'isActive',
                hideDefaultActions: true,
                initialWidth: 100,
                wrapText: false
            },
            {
                label: this.i18n.lastModifiedDate,
                fieldName: 'lastModifiedDate',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'date',
                typeAttributes: {
                    timeZone: TIMEZONE,
                    month: '2-digit',
                    day: '2-digit',
                    year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric'
                }
            },
            {
                label: this.i18n.default,
                fieldName: 'isDefault',
                hideDefaultActions: true,
                wrapText: false,
                type: 'xCheckbox',
                typeAttributes: {
                    disabled: true
                },
            },
            {
                label: this.i18n.processLastRan,
                fieldName: 'lastRan',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'date',
                typeAttributes: {
                    timeZone: TIMEZONE,
                    month: '2-digit',
                    day: '2-digit',
                    year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric'
                }
            },
            {
                label: this.i18n.processRunStatus,
                fieldName: 'lastRunStatus',
                hideDefaultActions: true,
                wrapText: false
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                }
            }
        ];
    }

    get isListHasRecords () {
        return this.filteredProcessListData?.length > 0;
    }

    populateListView () {
        if (this.mplnDetailUrl && this.processListData) {
            this.processListData.forEach(row => {
                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`].join('&');
                row.recordUrl = `${this.mplnDetailUrl}?${urlParams}`;
                row.actions = ROW_ACTIONS.map(action => {
                    let disabled = false;
                    if (row.lastRunStatus === 'Running' && action.name === 'run') {
                        disabled = true
                    }
                    return {
                        ...action,
                        disabled
                    }
                })
                if (row.isActive) {
                    row.isActive = labelYes;
                } else {
                    row.isActive = labelNo;
                }
            });
            this.sortData(this.processListData);
            this.apiInProgress = false;
        }
    }

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "name" : this.sortBy;
        this.filteredProcessListData = sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;
        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.filterListViewData(searchKey);

            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.filteredProcessListData);
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.navigateToDetailComponent(row.id, PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.navigateToDetailComponent(row.id, PAGE_ACTION_TYPES.CLONE);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
            case 'run':
                this.runEngine(row.id);
                break;
            default:
                break;
        }
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deleteProcess({ processId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.name);
                deleteRecentItemRecords(recentlyViewedRecord)
                    .then(recentItem => {
                        if (recentItem && !verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
                this.getProcessListViewData();
                this.clearSearchInputValue();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
                this.pendingDeleteRecord = undefined;
            });
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    navigateToDetailComponent (recordId, actionName) {
        const navState = {
            c__actionName: actionName
        }

        if (recordId) {
            navState.c__recordId = recordId;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, ADM_MPLNPROCESS_DETAIL);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    runEngine (recordId) {
        runProcessEngine ({ processIds: [recordId]})
            .then(result => {

                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.getProcessListViewData();
                this.clearSearchInputValue();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.maintenanceProcess} "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.sortData(this.processListData);
        } else {
            this.filteredProcessListData = this.processListData.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const nameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (nameMatch !== -1 );
            });
        }
    }

}