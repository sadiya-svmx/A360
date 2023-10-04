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

import { deleteRecentItemRecords } from 'c/recentItemService';

import getAllExpressions from '@salesforce/apex/ADM_ExpressionLightningService.getAllExpressions';
import deleteExpression from '@salesforce/apex/ADM_ExpressionLightningService.deleteExpression';
import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';
import getTaskEventObjectDetails
    from '@salesforce/apex/COMM_MetadataLightningService.getEntityDefinitions';

import labelExpressionBuilder from '@salesforce/label/c.Label_Expression_Builder';
import labelExpressionList from '@salesforce/label/c.Label_ExpressionList';
import labelNewButton from '@salesforce/label/c.Button_NewExpression';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchExpressions';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelExpression from '@salesforce/label/c.Label_Expression';
import labelExpressionName from '@salesforce/label/c.Label_ExpressionName';
import labelObject from '@salesforce/label/c.Label_Object';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelExpressionHelp from '@salesforce/label/c.URL_ExpressionHelp';
import labelInvalidObject from '@salesforce/label/c.Message_InvalidObject_Expression';
import labelWhereUsed from '@salesforce/label/c.Label_WhereUsed';

const i18n = {
    pageHeader: labelExpressionBuilder,
    expressionList: labelExpressionList,
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
    expression: labelExpression,
    expressionName: labelExpressionName,
    object: labelObject,
    developerName: labelDeveloperName,
    helpLink: labelExpressionHelp,
    invalidObject: labelInvalidObject,
    whereUsed: labelWhereUsed
};

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.whereUsed, name: 'whereused' },
    { label: i18n.delete, name: 'delete' }
];

const DISABLED_ROW_ACTIONS = [
    { label: i18n.delete, name: 'delete' }
];

const EXPRESSION_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__expressionDetail'
    }
};

export default class ExpressionAdminListView extends NavigationMixin(
    LightningElement
) {
    @track expressionDetailUrl;
    @track listViewData = {};
    @track filteredListViewData;
    @track apiInProgress;
    @track error;
    @track deleteModalDialogOpen;
    @track sortBy = 'recordUrl';
    @track sortDirection = 'asc';
    @track entityOptions = [];
    @track moduleType = '';
    @track configurationId = '';
    @track configDeveloperName = '';
    @track configName = '';
    @track operationType = '';
    @track deleteWhereUsedModalDialogOpen = false;
    @track row;

    currentNavItem;
    _listViewHeaderHeight = 100;

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
        this[NavigationMixin.GenerateUrl](EXPRESSION_DETAIL_VIEW).then(url => {
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

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef) {

            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.clearSearchInputValue();
            this.getInitialListViewData();
        }
    }

    get rowCount () {
        return this.filteredListViewData ? this.filteredListViewData.length : 0;
    }

    get rowCountPhrase () {
        return ( this.filteredListViewData ? this.filteredListViewData.length : 0 )
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
                label: this.i18n.expressionName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'xUrl',
                typeAttributes: {
                    disabled: { fieldName: 'navigationDisabled' },
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: 'nameToolTip' },
                    target: '_self'
                },
                cellAttributes: {
                    class: { fieldName: 'objectClass' },
                }
            },
            {
                label: this.i18n.object,
                fieldName: 'objectLabel',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: {
                    class: { fieldName: 'objectClass' },
                }
            },
            {
                label: this.i18n.developerName,
                fieldName: 'developerName',
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
                label: this.i18n.lastModifiedBy,
                fieldName: 'lastModifiedBy',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                },
            }
        ];
    }

    getEntityDefinitions () {
        return getAllEntityDefinitions()
            .then (result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }
                this.error = null;
                this.entityOptions = result.data.map(entity => {
                    return {
                        label: entity.label,
                        value: entity.apiName,
                        secondary: entity.apiName
                    }
                });
            });

    }

    getEntityDefinitionForSpecificObjects () {
        const objectNames = [];
        objectNames.push({ apiName: 'Event' });
        objectNames.push({ apiName: 'Task' });
        let entityOptions = [];
        getTaskEventObjectDetails({ requestJson: JSON.stringify(objectNames) })
            .then (result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }
                this.error = null;
                entityOptions = result.data.map(entity => {
                    return {
                        label: entity.label,
                        value: entity.apiName,
                        secondary: entity.apiName
                    }
                });
                this.entityOptions = [ ...this.entityOptions, ...entityOptions ];
            });
    }

    getExpressions () {
        return getAllExpressions()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.error = null;
                this.listViewData.data = result.data;
                this.filteredListViewData = this.listViewData.data;
            });
    }

    getInitialListViewData () {
        this.apiInProgress = true;
        Promise.all([this.getEntityDefinitions(), this.getExpressions(),
            this.getEntityDefinitionForSpecificObjects()])
            .then(() => {
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

    getLabelFromEntityList (apiName) {
        let label = '';

        if (this.entityOptions && this.entityOptions.length > 0) {
            const entityOpt = this.entityOptions.find(opt => opt.value === apiName);

            if (entityOpt) {
                label = entityOpt.label;
            }
        }

        return label;
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    checkWhereUsed (row, operationType) {
        this.moduleType = 'Expression';
        this.configurationId = row.id;
        this.configDeveloperName = row.developerName;
        this.configName = row.name;
        this.operationType = operationType;
        this.deleteWhereUsedModalDialogOpen = true;
        this.row = row;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.filteredListViewData);
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deleteExpression({ requestJson: JSON.stringify({ id: this.pendingDeleteRecord.id }) })
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
                this.getInitialListViewData();
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
                const developerNameMatch = (item.developerName)
                    ? item.developerName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const apiNameMatch = (item.objectAPIName)
                    ? item.objectAPIName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (nameMatch !== -1 || developerNameMatch !== -1 || apiNameMatch !== -1);
            });
        }
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
                this.checkWhereUsed(row,'delete');
                break;
            case 'whereused':
                this.checkWhereUsed(row, 'whereused');
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
    }

    handleCancelWhereUsedModal () {
        this.deleteWhereUsedModalDialogOpen =  false;
    }

    handleDeleteModal (event) {
        this.deleteWhereUsedModalDialogOpen =  false;
        this.deleteRow(event.detail.row);
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

        const detailRef = Object.assign({}, EXPRESSION_DETAIL_VIEW);

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

                const objectLabel = this.getLabelFromEntityList(row.objectAPIName);
                const objectInvalid = isEmptyString(objectLabel);

                row.navigationDisabled = objectInvalid;
                row.objectClass = objectInvalid ? 'slds-text-color_error' : '';
                row.objectLabel = objectInvalid ? row.objectAPIName : objectLabel;
                row.actions = objectInvalid ? DISABLED_ROW_ACTIONS : ROW_ACTIONS;

                const tooltip = row.description ? `${row.name}\n${row.description}` : row.name;
                row.nameToolTip = objectInvalid ? i18n.invalidObject : tooltip;
            });

            this.sortData(this.listViewData.data);

            this.apiInProgress = false;
        }
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.expression} "${recordName}" ${this.i18n.deleteSuccess}`,
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