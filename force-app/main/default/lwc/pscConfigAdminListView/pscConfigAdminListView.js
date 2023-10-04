import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    parseErrorMessage,
    PAGE_ACTION_TYPES,
    sortObjectArray,
    verifyApiResponse
} from 'c/utils';
import PSC_ICONS from '@salesforce/resourceUrl/pscIcons';
import getPSCTemplate from '@salesforce/apex/ADM_ProductServiceCampaign_LS.getAllConfigTemplates';
import deletePSCTemplate from '@salesforce/apex/ADM_ProductServiceCampaign_LS.deleteConfigTemplate';
import { deleteRecentItemRecords } from 'c/recentItemService';

import labelPSCName from '@salesforce/label/c.Label_Product_Service_Campaigns';
import labelConfigTemplates from '@salesforce/label/c.Label_Configuration_Templates';
import labelNewButton from '@salesforce/label/c.Label_New_PSC_Configuration_Template';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchExpressions';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelConfigTemplateName from '@salesforce/label/c.Label_Template_Name';
import labelDesc from '@salesforce/label/c.Label_Description';
import labelPSCHelp from '@salesforce/label/c.Label_PSC_Smart_Help';
import labelActive from '@salesforce/label/c.Label_Active';
import labelYes from '@salesforce/label/c.Lbl_Yes';
import labelNo from '@salesforce/label/c.Lbl_No';

const i18n = {
    pageHeader: labelPSCName,
    configTemplatesLabel: labelConfigTemplates,
    new: labelNewButton,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    help: labelHelp,
    items: labelItemsRowCount,
    lastModified: labelLastModified,
    loading: labelLoading,
    searchPlaceholder: labelSearchPlaceholder,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteSuccess: labelDeletedSuccess,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    configTemplateName: labelConfigTemplateName,
    description: labelDesc,
    helpLink: labelPSCHelp,
    labelActive: labelActive,
    yes: labelYes,
    no: labelNo
};
const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' }
];

const PSC_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__pscConfigurationDetails'
    }
};
export default class PscConfigAdminListView extends NavigationMixin(LightningElement) {
    @track expressionDetailUrl;
    @track listViewData = {};
    @track filteredListViewData;
    @track apiInProgress;
    @track error;
    @track sortBy = 'recordUrl';
    @track sortDirection = 'asc';
    @track deleteModalDialogOpen;
    _listViewHeaderHeight = 100;
    currentNavItem;
    pscLogoUrl = `${PSC_ICONS}/pscIcons/ServiceMax_Logo.svg`;

    constructor () {
        super();
        this.columns = this.getColumns();
    }

    get rowCount () {
        return this.filteredListViewData ? this.filteredListViewData.length : 0;
    }

    get i18n () {
        return i18n;
    }

    get computedDataTableHeight () {
        return `height: calc(100% - ${this._listViewHeaderHeight}px)`;
    }

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');

        if (input) {
            input.value = '';
        }
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](PSC_DETAIL_VIEW).then(url => {
            this.expressionDetailUrl = url;
            this.populateListView();
        });
    }

    renderedCallback () {
        const listViewHeader = this.template.querySelector('.list-view-header');

        if (listViewHeader) {
            this._listViewHeaderHeight = listViewHeader.offsetHeight;
        }
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.filteredListViewData);
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        if (pageRef) {
            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.clearSearchInputValue();
            this.getTemplates();
        }
    }
    getColumns () {
        return [
            {
                label: this.i18n.configTemplateName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'xUrl',
                typeAttributes: {
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: 'nameToolTip' },
                    target: '_self'
                }
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: this.i18n.labelActive,
                fieldName: 'isActive',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: this.i18n.lastModified,
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
                type: 'action',
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                },
            }
        ];
    }

    getTemplates () {
        this.apiInProgress = true;
        return getPSCTemplate()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.error = null;
                this.listViewData.data = result.data;
                this.filteredListViewData = this.listViewData.data;
                this.populateListView();
            })
            .catch(error => {
                this.entityOptions = [];
                this.listViewData.data = [];
                this.filteredListViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
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

            // comment below for eslint which errors when no default case exists.
            // No Default
        }
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
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

        deletePSCTemplate({ requestJson: JSON.stringify({ id: this.pendingDeleteRecord.id }) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.name);

                deleteRecentItemRecords(recentlyViewedRecord).then(recentItem => {
                    if (recentItem && !verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });

                this.getTemplates();
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

    handleNewExpression () {
        this.navigateToDetailComponent(null, PAGE_ACTION_TYPES.NEW);
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

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.sortData(this.listViewData.data);
        } else {
            this.filteredListViewData = this.listViewData.data.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const nameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const descNameMatch = (item.description)
                    ? item.description.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (nameMatch !== -1 || descNameMatch !== -1 );
            });
        }
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

        const detailRef = Object.assign({}, PSC_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    populateListView () {
        if (this.expressionDetailUrl && this.listViewData.data) {
            this.listViewData.data.forEach(row => {
                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`].join('&');
                row.recordUrl = `${this.expressionDetailUrl}?${urlParams}`;
                row.actions = ROW_ACTIONS;
                const tooltip = row.description ? `${row.name}\n${row.description}` : row.name;
                row.nameToolTip = tooltip;
                if (row.isActive) {
                    row.isActive = labelYes;
                } else {
                    row.isActive = labelNo;
                }
            });
            this.sortData(this.listViewData.data);
            this.apiInProgress = false;
        }
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.configTemplateName} "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "name" : this.sortBy;
        this.filteredListViewData = sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

}