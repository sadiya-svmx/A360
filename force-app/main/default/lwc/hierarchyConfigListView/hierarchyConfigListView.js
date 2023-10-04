import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import {
    isEmptyString,
    parseErrorMessage,
    PAGE_ACTION_TYPES,
    sortObjectArray,
    verifyApiResponse,
    ICON_NAMES
} from 'c/utils';

import getAllHierarchyConfigurations
    from '@salesforce/apex/ADM_HierarchyConfig_LS.getAllHierarchyConfigurations';
import deleteHierarchyConfig
    from '@salesforce/apex/ADM_HierarchyConfig_LS.deleteHierarchyConfig';

import { deleteRecentItemRecords } from 'c/recentItemService';

import labelAssetManagement from '@salesforce/label/c.LabelAssetManagement';
import labelHierarchy from '@salesforce/label/c.LabelHierarchy';
import labelNewButton from '@salesforce/label/c.Button_New';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import Label_Default from '@salesforce/label/c.Label_Default';
import labelHierarchyName from '@salesforce/label/c.Label_HierarchyName';
import errorSelectOption from '@salesforce/label/c.Error_SelectOption';
import labelAssetHierarchyHelp from '@salesforce/label/c.Label_Asset_Hierarchy_Help';

const i18n = {
    pageHeader: labelAssetManagement,
    hierarchy: labelHierarchy,
    new: labelNewButton,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    help: labelHelp,
    items: labelItemsRowCount,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    loading: labelLoading,
    searchPlaceholder: labelSearchPlaceholder,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    deleteSuccess: labelDeletedSuccess,
    hierarchyName: labelHierarchyName,
    defaultName: Label_Default,
    errorOptionMustSelected: errorSelectOption,
    helpLink: labelAssetHierarchyHelp
};

const DISABLED_DELETE_ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' }
];

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' },
];

const ASSET_HIERARCHY_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__hierarchyConfigDetail'
    }
};

export default class HierarchyConfigListView extends NavigationMixin(
    LightningElement
) {
    @track assetHierarchyDetailUrl;
    @track apiInProgress = false;
    @track error;
    @track deleteModalDialogOpen;
    @track sortBy = 'recordUrl';
    @track sortDirection = 'asc';

    @track assetHierarchies = [];
    @track listViewData = [];
    @track assetHierarchyListViewData = [];

    currentNavItem;
    _listViewHeaderHeight = 100;

    constructor () {
        super();
        this.columns = this.getColumns();
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](ASSET_HIERARCHY_DETAIL_VIEW).then(url => {
            this.assetHierarchyDetailUrl = url;
        });
    }

    renderedCallback () {
        const listViewHeader = this.template.querySelector('.list-view-header');

        if (listViewHeader) {
            this._listViewHeaderHeight = listViewHeader.offsetHeight;
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef) {

            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.clearSearchInputValue();
            this.getAllHierarchies();
        }
    }

    get rowCount () {
        return this.listViewData ? this.listViewData.length : 0;
    }

    get rowCountPhrase () {
        return ( this.listViewData ? this.listViewData.length : 0 )
                 + ' ' + i18n.items;
    }

    get i18n () {
        return i18n;
    }

    get computedDataTableHeight () {
        return `height: calc(100% - ${this._listViewHeaderHeight}px)`;
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    getColumns () {
        return [
            {
                label: this.i18n.hierarchyName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: 'name' },
                    target: '_self'
                }
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
                label: this.i18n.lastModifiedBy,
                fieldName: 'lastModifiedBy',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: this.i18n.defaultName,
                fieldName: 'defaultConfiguration',
                hideDefaultActions: true,
                wrapText: false,
                type: 'xCheckbox',
                typeAttributes: {
                    disabled: true
                },
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                },
            }
        ];
    }

    getAllHierarchies () {
        this.apiInProgress = true;
        getAllHierarchyConfigurations()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.error = null;
                this.assetHierarchies = result.data;
                this.populateListView();
            })
            .catch(error => {
                this.assetHierarchies = [];
                this.listViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.listViewData);
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        this.apiInProgress = true;
        deleteHierarchyConfig({ hierarchyConfigId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.name);
                deleteRecentItemRecords(recentlyViewedRecord).then(recentItem => {
                    if (recentItem && !verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });

                this.getAllHierarchies();
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

    handleNewHirearchyConfig () {
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
        if (isEmptyString(searchValue)) {
            // Restore list when search filter is removed.
            this.sortData(this.assetHierarchyListViewData);
        } else {
            this.listViewData = this.assetHierarchyListViewData.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const nameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (nameMatch !== -1);
            });
        }
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

        const detailRef = Object.assign({}, ASSET_HIERARCHY_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    populateListView () {
        this.listViewData = [];
        if (this.assetHierarchyDetailUrl && this.assetHierarchies) {
            this.assetHierarchies.forEach(row => {

                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`].join('&');
                row.actions = (row.defaultConfiguration) ?
                    DISABLED_DELETE_ROW_ACTIONS : ROW_ACTIONS;
                row.recordUrl = `${this.assetHierarchyDetailUrl}?${urlParams}`;
                this.listViewData.push(row);
            });
            this.sortData(this.listViewData);
            this.assetHierarchyListViewData = this.listViewData;
        }
    }

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');

        if (input) {
            input.value = '';
        }
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.hierarchy} "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "name" : this.sortBy;

        this.listViewData = sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

}