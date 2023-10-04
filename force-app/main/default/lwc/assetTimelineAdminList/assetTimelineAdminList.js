import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIMEZONE from '@salesforce/i18n/timeZone';

import getTimelineConfigurations from
    '@salesforce/apex/ADM_TimelineConfig_LS.getAllTimelineConfigurations';
import deleteConfig from
    '@salesforce/apex/ADM_TimelineConfig_LS.deleteTimelineConfig';
import { deleteRecentItemRecords }
    from 'c/recentItemService';

import labelTimeline from '@salesforce/label/c.LabelTimeline';
import labelTimelineList from '@salesforce/label/c.Label_TimelineList';
import labelTimelineName from '@salesforce/label/c.Label_TimelineName';
import labelLastModifiedDate from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelDefault from '@salesforce/label/c.Label_Default';
import labelAssetManagement from '@salesforce/label/c.LabelAssetManagement';
import labelRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelNewButton from '@salesforce/label/c.Button_New';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchExpressions';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelAssetTimnelineHelp from '@salesforce/label/c.Label_Asset_Timeline_Help';
import labelHelp from '@salesforce/label/c.Label_Help';



const i18n = {
    timeline: labelTimeline,
    labelTimelineList: labelTimelineList,
    labelTimelineName: labelTimelineName,
    labelAssetManagement: labelAssetManagement,
    labelRowCount: labelRowCount,
    labelNoResults: labelNoResults,
    new: labelNewButton,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    lastModifiedBy: labelLastModifiedBy,
    lastModifiedDate: labelLastModifiedDate,
    default: labelDefault,
    searchPlaceholder: labelSearchPlaceholder,
    items: labelItemsRowCount,
    loading: labelLoading,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    deleteSuccess: labelDeletedSuccess,
    helpLink: labelAssetTimnelineHelp,
    help: labelHelp
};

import {
    parseErrorMessage,
    PAGE_ACTION_TYPES,
    sortObjectArray,
    verifyApiResponse,
    ICON_NAMES
} from 'c/utils';

const TIMELINE_CONFIG_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__timelineConfigDetail'
    }
};

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' }
];

const DEFAULT_ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' }
];




export default class AssetTimelineAdminList extends NavigationMixin(LightningElement) {
    currentPageReference;
    currentNavItem;
    timelineConfigDetailUrl;
    sortBy = 'recordUrl';
    sortDirection = 'asc';
    @track listViewData = {};
    @track filteredListViewData = [];
    apiInProgress = false;
    deleteModalDialogOpen = false;
    error;

    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    iconSize = 'large';

    get columns () {

        return [{
            label: this.i18n.labelTimelineName,
            fieldName: 'recordUrl',
            hideDefaultActions: true,
            sortable: true,
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'name' },
                target: '_self'
            }
        },{
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
        },{
            label: this.i18n.lastModifiedBy,
            fieldName: 'lastModifiedBy',
            hideDefaultActions: true,
            wrapText: false,
            sortable: true
        },
        {
            label: this.i18n.default,
            fieldName: "isDefault",
            type: "boolean",
            hideDefaultActions: true,
            wrapText: false,
            sortable: true
        },
        {
            type: "action",
            typeAttributes: {
                rowActions: { fieldName: 'actions' }
            },
        }];
    }


    get i18n () {
        return i18n;
    }

    get recordCountPhrase () {
        return this.recordCount > 0 ?
            `${this.recordCount} ${this.i18n.items}` : this.i18n.labelNoResults;
    }

    get recordCount () {
        return this.filteredListViewData ? this.filteredListViewData.length : 0;
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](TIMELINE_CONFIG_DETAIL_VIEW).then(url => {
            this.timelineConfigDetailUrl = url;
        });
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.filteredListViewData);
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

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deleteConfig({ timelineConfigId: this.pendingDeleteRecord.id })
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

                this.getInitialListViewData();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
                this.pendingDeleteRecord = undefined;
            });
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
                return nameMatch !== -1;
            });
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef && pageRef.state && pageRef.state.c__currentItem) {
            this.currentNavItem = pageRef.state.c__currentItem;
        }
        this.getInitialListViewData();

    }

    getConfigurations () {
        return getTimelineConfigurations()
            .then(result => {
                if (result.error) {
                    this.error = parseErrorMessage(result.error);
                } else {
                    this.listViewData.data = result.data.map(conf => {
                        const urlParams = [
                            `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                            `c__recordId=${conf.id}`,
                            `c__currentItem=${this.currentNavItem}`].join('&');
                        return {
                            id: conf.id,
                            name: conf.name,
                            lastModifiedDate: conf.lastModifiedDate,
                            lastModifiedBy: conf.lastModifiedBy,
                            isDefault: conf.isDefault,
                            recordUrl: `${this.timelineConfigDetailUrl}?${urlParams}`,
                            actions: conf.isDefault ?
                                DEFAULT_ROW_ACTIONS : ROW_ACTIONS
                        };
                    });
                    this.filteredListViewData = this.listViewData.data;
                }
            });
    }

    handleNewConfig () {
        this.navigateToDetailComponent(null, PAGE_ACTION_TYPES.NEW);
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

        const detailRef = Object.assign({}, TIMELINE_CONFIG_DETAIL_VIEW);

        detailRef.state = navState;
        this[NavigationMixin.Navigate](detailRef);
    }

    getInitialListViewData () {
        this.apiInProgress = true;
        Promise.all([this.getConfigurations()])
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

    populateListView () {
        if (this.timelineConfigDetailUrl && this.listViewData.data) {
            this.listViewData.data.forEach(row => {

                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`].join('&');

                row.recordUrl = `${this.timelineConfigDetailUrl}?${urlParams}`;

                const objectIsDefault = row.isDefault;

                row.actions = objectIsDefault ? DEFAULT_ROW_ACTIONS : ROW_ACTIONS;
            });
            this.filteredListViewData = this.listViewData.data;
            this.sortData(this.listViewData.data);
            this.apiInProgress = false;
        }
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.timeline} "${recordName}" ${this.i18n.deleteSuccess}`,
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

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }



}