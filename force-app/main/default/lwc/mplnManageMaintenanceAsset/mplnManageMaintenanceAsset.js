import { LightningElement, track, api, wire } from 'lwc';
import { parseErrorMessage, verifyApiResponse, ROW_ACTION_TYPES,
    deepCopy, formatString } from 'c/utils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { FlowNavigationNextEvent , FlowNavigationBackEvent } from 'lightning/flowSupport';
import MAINTENANCE_ASSET_OBJECT from '@salesforce/schema/MaintenanceAsset';
import ASSET_OBJECT from '@salesforce/schema/Asset';

import getAssetList
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getAssetList';
import getMaintenanceAssets
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getMaintenanceAssets';

import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelRemoveMenuItem from '@salesforce/label/c.Menu_Remove';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelSearch from '@salesforce/label/c.Button_Search';
import labelItemSelected from '@salesforce/label/c.Label_ItemSelected';
import labelItemsSelected from '@salesforce/label/c.Label_ItemsSelected';
import labelManageMaintenanceAssets from '@salesforce/label/c.Label_ManageMaintenanceAssets';
import placeholderMaintenanceAssets from '@salesforce/label/c.Placeholder_SearchMaintenanceAssets';
import labelRemoveMaintenanceAsset from '@salesforce/label/c.Label_RemoveMaintenanceAsset';
import messageRemoveConfirm from '@salesforce/label/c.Message_RemoveConfirm';
import labelAddMaintenanceAssets from '@salesforce/label/c.Label_AddMaintenanceAssets';
import placeholderSearchAssets from '@salesforce/label/c.Placeholder_SearchAssets';
import labelActions from '@salesforce/label/c.Button_Actions';
import labelAddAssets from '@salesforce/label/c.MenuItem_AddAssets';
import labelRemoveAssets from '@salesforce/label/c.MenuItem_RemoveAssets';
import labelPrevious from '@salesforce/label/c.Button_Previous';
import labelCreateMaintenancePlan from '@salesforce/label/c.Label_CreateMaintenancePlan';
import labelPlaceholderSearch from '@salesforce/label/c.Placeholder_Search';
import labelPleaseReviewErrorMessage from '@salesforce/label/c.Label_PleaseReviewErrorMessage';
import labelError from '@salesforce/label/c.Label_Error';
import labelErrors from '@salesforce/label/c.Label_Errors';
import labelResolve1Error from '@salesforce/label/c.Label_Resolve1Error';
import labelDateOfFirstWoError from '@salesforce/label/c.Label_DateOfFirstWoError';

const i18n = {
    title: labelManageMaintenanceAssets,
    placeholder: placeholderMaintenanceAssets,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    loading: labelLoading,
    noResults: labelNoResults,
    remove: labelRemoveMenuItem,
    removeMaintenanceAsset: labelRemoveMaintenanceAsset,
    removeConfirmMessage: messageRemoveConfirm,
    cancel: labelCancel,
    confirm: labelConfirm,
    addAssetTitle: labelAddMaintenanceAssets,
    placeholderForAssetSearch: placeholderSearchAssets,
    search: labelSearch,
    itemSelected: labelItemSelected,
    itemsSelected: labelItemsSelected,
    actions: labelActions,
    addAssets: labelAddAssets,
    removeAssets: labelRemoveAssets,
    previous: labelPrevious,
    createMaintenancePlan: labelCreateMaintenancePlan,
    placeholderSearch: labelPlaceholderSearch,
    pleaseReviewErrorMessage: labelPleaseReviewErrorMessage,
    error: labelError,
    errors: labelErrors,
    resolve1Error: labelResolve1Error,
    dateOfFirstWoError: labelDateOfFirstWoError,
}

const ROW_ACTIONS = [
    { label: i18n.remove, name: ROW_ACTION_TYPES.DELETE }
];

const metaForWorkTypeColumn = {
    filters: "",
    formFillMappingId: null,
    icon: "standard:work_type",
    object: "WorkType",
    placeholder: i18n.placeholderSearch,
    referenceNameFields: "Name"
}

export default class MplnManageMaintenanceAsset extends LightningElement {
    // cool stuff to be done here

    @api maintenancePlanRecord;
    @api maintenanceAssetRecords;
    @api templateId;
    @api recordId;
    @api assetStatus;
    @api includeChildAssets;

    @track localMaintenanceAssetRecords = [];
    @track error;
    @track errorForAssetModal;
    @track disableDeleteMenu = true;
    @track apiInProgress = false;
    @track noRecordsFound;
    @track noRecordsFoundForAsset;
    @track columns;
    @track deleteModalDialogOpen;
    @track showAssetSelectionModal;
    @track disableSearchButton = true;
    @track selectedRowsId = [];
    @track assetRecordsList = [];
    @track assetColumns;
    @track draftValues = [];
    @track errors = {};
    @track hasErrors = false;
    @track bottomErrorMessage;

    nextSuggestedMaintenanceDateValue;
    loadedAssetIds = [];
    pendingDeleteRowId;
    originalRecords = [];
    searchkeyword;
    searchKeywordForAsset;
    _assetTableHeight = 100;
    baseUrl;
    mAssetSelectedRows = [];
    loadedAssetIdWorkTypeId = {};
    errorCollection = {};

    @wire(getObjectInfo, { objectApiName: MAINTENANCE_ASSET_OBJECT })
    objectInfoMaintenanceAsset ({ error, data }) {
        if (error) {
            this.error = parseErrorMessage(error);
        } else if (data && data.apiName === 'MaintenanceAsset') {
            this.columns = this.getColumns(data);
        }
    }

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfoAsset ({ error, data }) {
        if (error) {
            this.error = parseErrorMessage(error);
        } else if (data && data.apiName === 'Asset') {
            this.assetColumns = this.getAssetColumns(data);
        }
    }

    connectedCallback () {
        this.baseUrl = window.location.origin;
        this.apiInProgress = true;
        this.nextSuggestedMaintenanceDateValue
            = this.maintenancePlanRecord.NextSuggestedMaintenanceDate;
        this.fetchRecords();
    }

    renderedCallback () {
        const assetListViewTable = this.template.querySelector(
            '.svmx-asset-list-view_table');
        if (assetListViewTable) {
            this._assetTableHeight = assetListViewTable.offsetHeight;
        }
    }

    fetchRecords () {
        return getMaintenanceAssets({
            requestJson: JSON.stringify({
                templateId: this.templateId,
                sourceRecordId: this.recordId,
                assetStatusValues: this.assetStatus,
                includeChildAssets: this.includeChildAssets
            })
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            if (result.data.length === 0) {
                this.noRecordsFound = true;
                return;
            }
            this.populateMaintenanceAssetList(result.data);
            this.error = undefined;

        }).catch(error => {
            this.localMaintenanceAssetRecords = [];
            this.originalRecords = [];
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.maintenanceAssetRecords = [];
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateMaintenanceAssetList (data) {
        const sfdcBaseUrl = this.baseUrl+'/';
        const assetIds = [];
        const tempLocalMaintenanceAssetRecords = [];
        const tempMaintenanceAssetRecords = [];
        for (let i = 0; i < data.length; i++) {
            assetIds.push(data[i].assetId);
            tempLocalMaintenanceAssetRecords.push({
                ...data[i],
                'nextSuggestedMaintenanceDate': this.nextSuggestedMaintenanceDateValue,
                'assetNameUrl': data[i].assetId ? sfdcBaseUrl + data[i].assetId : null
            });
            tempMaintenanceAssetRecords.push({
                'AssetId': data[i].assetId,
                'WorkTypeId': data[i].workTypeId,
                'NextSuggestedMaintenanceDate': this.nextSuggestedMaintenanceDateValue
            });
            if (data[i].workTypeId && !this.loadedAssetIdWorkTypeId[data[i].assetId]) {
                this.loadedAssetIdWorkTypeId[data[i].assetId] = {
                    'workTypeId': data[i].workTypeId,
                    'workTypeName': data[i].workTypeName,
                };
            }
        }
        this.loadedAssetIds = assetIds;
        this.localMaintenanceAssetRecords = tempLocalMaintenanceAssetRecords;
        this.originalRecords = [...this.localMaintenanceAssetRecords];
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.maintenanceAssetRecords = tempMaintenanceAssetRecords;
    }

    get i18n () {
        return i18n;
    }

    get recordCountInfo () {
        return (this.localMaintenanceAssetRecords.length > 1)
            ? `${this.localMaintenanceAssetRecords.length} ${this.i18n.items}`
            : `${this.localMaintenanceAssetRecords.length} ${this.i18n.item}`;
    }

    get getLocalMaintenanceAssetRecords () {
        return this.localMaintenanceAssetRecords.length > 0;
    }

    get countOfSelectedRowsString () {
        const rowsCount = this.selectedRowsId.length;
        const countText = rowsCount < 2 ? i18n.itemSelected : i18n.itemsSelected;
        return `${rowsCount} ${countText}`;
    }

    get isDisableConfirmButtonOfAssetModal () {
        return this.selectedRowsId.length === 0;
    }

    get isListHasRecords () {
        return this.localMaintenanceAssetRecords.length > 0;
    }

    get isMaintenanceAssetListEmpty () {
        return this.originalRecords.length === 0;
    }

    getColumns (objectInfo) {
        const { fields: { AssetId: { label, relationshipName }}} = objectInfo;
        return [
            {
                label: label,
                fieldName: 'assetNameUrl',
                type: 'xUrl',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'assetName'
                    },
                    tooltip: {
                        fieldName: 'assetName'
                    },
                    showPopover: true,
                    objectApiName: relationshipName,
                    target: { fieldName: 'assetId' }
                }
            },
            {
                label: objectInfo.fields.WorkTypeId.label,
                fieldName: 'workTypeId',
                editable: true,
                type: "xLookup",
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    editable: true,
                    fieldName: 'workTypeId',
                    fieldType: "reference",
                    label: objectInfo.fields.WorkTypeId.label,
                    type: "xLookup",
                    rowId: {
                        fieldName: "assetId"
                    },
                    meta: JSON.stringify(metaForWorkTypeColumn),
                }
            },
            {
                label: objectInfo.fields.NextSuggestedMaintenanceDate.label,
                fieldName: 'nextSuggestedMaintenanceDate',
                type: "date-local",
                hideDefaultActions: true,
                wrapText: false,
                editable: true,
                typeAttributes: {
                    day: "2-digit",
                    disabled: false,
                    editable: true,
                    fieldName: "nextSuggestedMaintenanceDate",
                    fieldType: "date",
                    label: objectInfo.fields.NextSuggestedMaintenanceDate.label,
                    month: "2-digit",
                    required: false,
                    type: "date-local",
                    year: "numeric"
                }
            },
            {
                type: 'action',
                fixedWidth: 60,
                typeAttributes: { rowActions: ROW_ACTIONS },
            }
        ];
    }

    handleCellChange (event) {
        const assetId = event.detail.draftValues[0].assetId;
        const value = event.detail.draftValues[0].nextSuggestedMaintenanceDate;
        this.updateRecordList(
            assetId, 'nextSuggestedMaintenanceDate', 'NextSuggestedMaintenanceDate', value, null
        );
        this.updateDraftValues(assetId, 'nextSuggestedMaintenanceDate', value);
        this.updateErrorObject(assetId, value, 'nextSuggestedMaintenanceDate');
    }

    updateErrorObject (assetId, mAssetDateValue, fieldName) {
        const mPlanStartDate = this.maintenancePlanRecord.StartDate;
        const isDateInvalid = new Date(mAssetDateValue) < new Date(mPlanStartDate);
        let errorCollectionTemp = this.errorCollection ? this.errorCollection : {};
        if (isDateInvalid) {
            // Add error info if not exist in the error object
            errorCollectionTemp.rows = errorCollectionTemp.rows ? errorCollectionTemp.rows : {};
            if (!Object.keys(errorCollectionTemp.rows).includes(assetId)) {
                errorCollectionTemp.rows[assetId] = {
                    title: i18n.resolve1Error,
                    messages: [i18n.dateOfFirstWoError],
                    fieldNames: [fieldName]
                };
            }
        } else if (errorCollectionTemp.rows &&
            Object.keys(errorCollectionTemp.rows).includes(assetId)) {
            // Remove error info from error object if exist
            delete errorCollectionTemp.rows[assetId];

            // If we deleted the last entry then we will remove rows key as well
            if (Object.keys(errorCollectionTemp.rows).length === 0) {
                errorCollectionTemp = {};
            }
        }
        this.errorCollection = errorCollectionTemp;
    }

    handleDynamicFieldChange (event) {
        const { rowId: assetId, value, label } = event.detail;
        this.updateRecordList(assetId, 'workTypeId', 'WorkTypeId', value, label);
        this.updateDraftValues(assetId, 'workTypeId', value);
    }

    updateRecordList (assetIdValue, fieldKey, fieldApiName, fieldValue, label) {
        for (let i = 0; i < this.localMaintenanceAssetRecords.length; i++) {
            if (this.localMaintenanceAssetRecords[i].assetId === assetIdValue) {
                this.localMaintenanceAssetRecords[i][fieldKey] = fieldValue;
                if (fieldKey === 'workTypeId') {
                    this.localMaintenanceAssetRecords[i].workTypeName = label;
                }
                break;
            }
        }
        for (let i = 0; i < this.maintenanceAssetRecords.length; i++) {
            if (this.maintenanceAssetRecords[i].AssetId === assetIdValue) {
                this.maintenanceAssetRecords[i][fieldApiName] = fieldValue;
                break;
            }
        }
    }

    updateDraftValues (assetId, fieldName, value) {
        const record = this.draftValues.filter(item => item.assetId === assetId);
        if (!record.length) {
            this.draftValues = [...this.draftValues, {
                assetId,
                [fieldName]: value
            }]
        } else {
            const updateRecord = record[0];
            updateRecord[fieldName] = value;
            this.draftValues = [...this.draftValues];
        }
    }

    getAssetColumns (objectInfo) {
        return [
            {
                label: objectInfo.fields.Name.label,
                fieldName: 'nameUrl',
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'name'
                    },
                    tooltip: {
                        fieldName: 'name'
                    },
                    target: '_blank'
                }
            },
            {
                label: objectInfo.fields.AccountId.label,
                fieldName: 'accountUrl',
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'accountName'
                    },
                    tooltip: {
                        fieldName: 'accountName'
                    },
                    target: '_blank'
                }
            },
            {
                label: objectInfo.fields.SerialNumber.label,
                fieldName: 'serialNumber',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: objectInfo.fields.Status.label,
                fieldName: 'status',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            }
        ];
    }

    handleRowSelection (event) {
        this.mAssetSelectedRows = event.detail.selectedRows;
        if (event.detail.selectedRows.length > 0) {
            this.disableDeleteMenu = false;
        } else {
            this.disableDeleteMenu = true;
        }
    }

    handleSearch (event) {
        this.searchkeyword = event.target.value.trim();
        this.localMaintenanceAssetRecords
            = this.filterRecords(this.originalRecords, this.searchkeyword);
    }

    filterRecords (allRecords, searchkeyword) {
        let filteredRecords = [];
        if (searchkeyword && searchkeyword.length > 0) {
            const lowerValue = searchkeyword.toLowerCase();
            filteredRecords = allRecords.filter(dataItem => {
                const { assetName, workTypeName } = dataItem;
                return (assetName  && assetName.toLowerCase().indexOf(lowerValue) !== -1
                    || workTypeName && workTypeName.toLowerCase().indexOf(lowerValue) !== -1);
            });
        } else {
            filteredRecords = allRecords;
        }
        return filteredRecords;
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case ROW_ACTION_TYPES.DELETE:
                this.openDeleteModal(row.assetId);
                break;
            default:
                break;
        }
    }

    handleActions (event) {
        const actionName = event.detail.value;
        switch (actionName) {
            case 'addAssets':
                this.handleAddAsset();
                break;
            case 'deleteAssets':
                this.openDeleteModal(null);
                break;
            default:
                break;
        }
    }

    handleAddAsset () {
        this.showAssetSelectionModal = true;
    }

    handleCancelOfAssetModal () {
        this.showAssetSelectionModal = false;
        this.disableSearchButton = true;
        this.noRecordsFoundForAsset = false;
        this.assetRecordsList = [];
        this.searchKeywordForAsset = null;
        this.selectedRowsId = [];
        this.errorForAssetModal = undefined;
    }

    handleChangeOfSearchBox (event) {
        this.searchKeywordForAsset = event.detail.value.trim();
        if (this.searchKeywordForAsset.length > 2) {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
        }
    }

    handleAssetRowSelection (event) {
        this.selectedRowsId = event.detail.selectedRows.map(element => {
            return element.id;
        });
    }

    handleSearchButton () {
        if (this.apiInProgress) return;
        this.apiInProgress = true;
        getAssetList({
            searchKeyword: this.searchKeywordForAsset,
            assetStatusValues: this.assetStatus,
            loadedRowsIds: this.loadedAssetIds,
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.errorForAssetModal = result.message;
                return;
            }
            if (result.data && result.data.length === 0) {
                this.noRecordsFoundForAsset = true;
                this.assetRecordsList = [];
                return;
            }
            this.assetRecordsList = this.populateAssetRecordsList(result.data);
            this.errorForAssetModal = undefined;
            this.noRecordsFoundForAsset = false;
        }).catch(error => {
            this.errorForAssetModal = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateAssetRecordsList (data) {
        const sfdcBaseUrl = this.baseUrl+'/';
        const assetListViewData = [];
        data.forEach(row=>{
            if (row.name) {
                row.nameUrl = sfdcBaseUrl + row.id;
            }
            if (row.accountId) {
                row.accountUrl = sfdcBaseUrl + row.accountId;
            }
            assetListViewData.push({ ...row });
        });
        return assetListViewData;
    }

    handleConfirmOfAssetModal () {
        const selectedRows = this.template.querySelector(
            '.svmx-asset-list-view_table').getSelectedRows();
        const newMaintenanceAssets = selectedRows.map(element => {
            let workTypeIdValue = null;
            let workTypeNameValue = null;
            if (this.loadedAssetIdWorkTypeId[element.id]) {
                workTypeIdValue = this.loadedAssetIdWorkTypeId[element.id].workTypeId;
                workTypeNameValue = this.loadedAssetIdWorkTypeId[element.id].workTypeName;
            }
            return {
                'assetId': element.id,
                'assetName': element.name,
                'workTypeId': workTypeIdValue,
                'workTypeName': workTypeNameValue,
                'nextSuggestedMaintenanceDate': this.nextSuggestedMaintenanceDateValue
            };
        });
        this.populateMaintenanceAssetList([...newMaintenanceAssets, ...this.originalRecords]);
        this.handleCancelOfAssetModal();
    }

    openDeleteModal (selectedRowId) {
        this.pendingDeleteRowId = selectedRowId;
        this.deleteModalDialogOpen = true;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
        this.pendingDeleteRowId = null;
    }

    handleDeleteConfirmModal () {
        let selectedRowsIds;
        if (this.pendingDeleteRowId) {
            selectedRowsIds = [this.pendingDeleteRowId];
            this.disableDeleteMenu = true;
        } else {
            selectedRowsIds = this.mAssetSelectedRows.map(element => element.assetId);
        }

        this.originalRecords= this.originalRecords.filter(element =>
            selectedRowsIds.indexOf(element.assetId) === -1);

        this.loadedAssetIds = this.loadedAssetIds.filter(element =>
            selectedRowsIds.indexOf(element) === -1);

        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.maintenanceAssetRecords = this.maintenanceAssetRecords.filter(element =>
            selectedRowsIds.indexOf(element.AssetId) === -1);

        this.draftValues = this.draftValues.filter(element =>
            selectedRowsIds.indexOf(element.assetId) === -1);

        let errorCollectionTemp = this.errorCollection;
        if (errorCollectionTemp && errorCollectionTemp.rows) {

            // Remove the deleted row's asset id from errorCollection
            selectedRowsIds.map(item => Reflect.deleteProperty(errorCollectionTemp.rows, item));

            // If all the errors are resolved then don't show error message
            if (Object.keys(errorCollectionTemp.rows).length === 0) {
                errorCollectionTemp = {};
                this.errors = {};
                if (this.hasErrors) {
                    this.hasErrors = false;
                    this.bottomErrorMessage = null;
                }
            } else {
                // If errors are present and its already 
                // displayted then update errors and error message
                if (this.hasErrors) {
                    this.errors = deepCopy(errorCollectionTemp);
                    const errorCount = Object.keys(errorCollectionTemp.rows).length;
                    this.bottomErrorMessage = [{
                        message: formatString(i18n.pleaseReviewErrorMessage,
                            errorCount,
                            errorCount === 1 ? i18n.error : i18n.errors
                        )
                    }]
                }
            }
        }
        this.errorCollection = errorCollectionTemp;

        if (this.searchkeyword) {
            this.localMaintenanceAssetRecords
                = this.filterRecords(this.originalRecords, this.searchkeyword);
        } else {
            this.localMaintenanceAssetRecords = this.originalRecords;
        }
        if (this.localMaintenanceAssetRecords.length === 0) {
            this.disableDeleteMenu = true;
        }
        this.handleCancelModal();
    }

    handlePrevious () {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    handleNext () {
        // On click of next show the errors (if present) at row level and bottom 
        this.errors = deepCopy(this.errorCollection);
        if (this.errors && this.errors.rows && Object.keys(this.errors.rows).length) {
            this.hasErrors = true;
            const errorCount = Object.keys(this.errors.rows).length;
            this.bottomErrorMessage = [{
                message: formatString(i18n.pleaseReviewErrorMessage,
                    errorCount,
                    errorCount === 1 ? i18n.error : i18n.errors
                )
            }]
            return;
        }
        this.hasErrors = false;
        this.bottomErrorMessage = null;
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}