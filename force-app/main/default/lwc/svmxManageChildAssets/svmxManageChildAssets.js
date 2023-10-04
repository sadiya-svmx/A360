import { LightningElement,api,track,wire } from 'lwc';
import getChildAssetNodesRaw from "@salesforce/apex/AMGT_AssetHierarchy_LS.fetchChildAssetsRaw";
import getAssetsNodesForGivenParent
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.fetchAssetsForGivenParentRaw";
import getHierarchyConfiguration
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.getHierarchyConfiguration";
import updateRecords
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.updateAssetRecords";
import { getFieldDefinitionsForEntities } from "c/metadataService";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import ASSET_OBJECT from '@salesforce/schema/Asset';
import getObjectAPIName from "@salesforce/apex/COMM_DatabaseUtils.getObjectAPIFromRecordId";
import {
    clearPubSubCache,
    setRowSelectionState
} from 'c/runtimePubSub';
import {
    parseErrorMessage,
    formatString,
    getAssetDisplayColumns,
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    chunk,
    asyncGetItemFromCache,
    deepCopy } from 'c/utils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from 'lightning/platformResourceLoader';
import runtimeGridResource from '@salesforce/resourceUrl/runtimeGrid';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelManageChildAssets from '@salesforce/label/c.Label_ManageChildAssets';
import labelButtonBackToHierarchy from '@salesforce/label/c.Button_BackToHierarchy';
import labelItemsFound from '@salesforce/label/c.Label_ItemsFound';
import labelPlaceholderSearch from '@salesforce/label/c.Placeholder_Search';
import labelAddChildAssets from '@salesforce/label/c.Label_AddChildAssets';
import labelDeleteAssets from '@salesforce/label/c.MenuItem_DeleteAssets';
import labelSaveAssets from '@salesforce/label/c.Btn_Save';
import labelRemoveAssetTitle from '@salesforce/label/c.Label_RemoveCLIAsset';
import labelRemoveAssetConfirmMsg from '@salesforce/label/c.Message_RemoveChildAsset';
import labelRemoveAssetConfirmTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelRemoveConfirmMsg from '@salesforce/label/c.Label_Delete_Modal'
import labelSave from '@salesforce/label/c.Label_Save';
import labelProcessing from '@salesforce/label/c.Label_Processing';
import Label_errorRecords from '@salesforce/label/c.Label_errorRecords';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import Label_ShowErrorRecords from '@salesforce/label/c.Label_ShowErrorRecords';
import Label_Batchnumber from '@salesforce/label/c.Label_Batchnumber';
import labelConfirmLeave from '@salesforce/label/c.Info_ConfirmManageAssetLeave';
import Label_changesSavedSuccessfully from '@salesforce/label/c.Label_changesSavedSuccessfully'
import labelTransactonSavedMessage from '@salesforce/label/c.Messge_TransactionSaved';
import labelAddAssetWithRecordType from '@salesforce/label/c.Label_AddRecordWithRecordType';
import labelAddAsset from '@salesforce/label/c.Label_AddRecord';
import { createRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';

const i18n = {
    manageChildAssets: labelManageChildAssets,
    backButton: labelButtonBackToHierarchy,
    itemsFoundMsg: labelItemsFound,
    labelSearch: labelPlaceholderSearch,
    addChildAssetsButton: labelAddChildAssets,
    deleteAssetsButton: labelDeleteAssets,
    save: labelSaveAssets,
    removeAssetTitle: labelRemoveAssetTitle,
    removeConfirmMessage: labelRemoveAssetConfirmMsg,
    removeConfirmTitle: labelRemoveAssetConfirmTitle,
    labelRemoveConfirmMsg: labelRemoveConfirmMsg,
    cancel: labelCancel,
    confirm: labelConfirm,
    clone: labelCloneMenuItem,
    delete: labelDeleteMenuItem,
    labelConfirmLeave: labelConfirmLeave,
    transactionSuccess: labelTransactonSavedMessage,
    labelSave: labelSave,
    labelProcessing: labelProcessing,
    LabelErrorRecords: Label_errorRecords,
    labelShowErrorRecords: Label_ShowErrorRecords,
    labelBatchNumber: Label_Batchnumber,
    Label_changesSavedSuccessfully: Label_changesSavedSuccessfully,
    labelAddAssetWithRecordType: labelAddAssetWithRecordType,
    labelAddAsset: labelAddAsset
}
const BATCH_COUNT = 50;
const CHILD_ROW_ACTIONS = [
    { label: i18n.clone, name: "clone" },
    { label: i18n.delete, name: "delete" },
];

export default class SvmxManageChildAssets extends LightningElement {

    @api childAssetTitle;
    @api childAssetRecordId;
    @api columnCacheName;
    @api parentId;
    @api childRelationshipName;
    _initiatedTime;
    @api
    get initiatedTime () {
        if (isUndefinedOrNull (this._initiatedTime)) {
            this._initiatedTime = Date.now()+'';
        }
        return this._initiatedTime;
    }
    set initiatedTime (value) {
        this._initiatedTime = value;
    }

    get engineId () {
        return `${this.childAssetRecordId??this.parentId}-${this.initiatedTime}`;
    }

    @track hierarchyConfig;
    @track assetRecords = [];
    @track assetRecordsView ;
    @track childAssetsResults;
    @track error;
    @track objectInfo;
    @track hasNoneSelected = true;
    @track selectedRows = [];
    @track deleteModalDialogOpen;
    @track editRecordId;
    @track editRecordObjectApiName;
    @track editActionTitle;
    @track showCloneRecordModal = false;
    @track cloneError;
    @track isCloning = false;
    @track latestSearchKey = '';
    @track addActionTitle;
    @track showAddRecordModal = false;
    @track assetPrefillValues = {};
    @track draftValues = [];
    showConfirmLeave = false;
    showSpinner =false;
    parentObjectAPIName;
    parentObjectInfo;
    @track batches = [];
    currentBatch = 1;
    @track erroredResult = [];
    @track tableErrors = {};
    @track addAssetModalSize = "SMALL";
    @track objectAPIName = ASSET_OBJECT;


    renderedCallback () {
        if (!window.svmxManageChildStyleLoaded && this.isShowDataTable) {
            this.loadStylePromise = Promise.all([
                loadStyle(this, runtimeGridResource)
            ]).then(() => {
                window.svmxManageChildStyleLoaded = true;
            })
                .catch(error => {
                    this.init = true;
                    console.error('static resource loadStylePromise error', error);
                });
        }
    }
    get hierarchyConfigData () {
        return this.hierarchyConfig?.data ? JSON.stringify(this.hierarchyConfig.data) : undefined;
    }

    childAssetColumns =  [];
    get displayColumns () {
        if (this.objectInfo
            && this.hierarchyConfig
            && this.childAssetColumns.length === 0) {
            this.childAssetColumns =  [{
                label: this.objectInfo?.fields?.Name?.label,
                fieldName: 'Name',
                type: 'xUrl',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                typeAttributes: {
                    label: { fieldName: 'Name' },
                    tooltip: { fieldName: 'Name' },
                    target: { fieldName: 'Id' },
                    showPopover: true,
                    objectApiName: 'Asset',
                    rowId: {
                        fieldName: "Id"
                    },
                    "fieldName": "Name",
                    "type": "xUrl",
                    "hideDefaultActions": true,
                    "sortable": true,
                    "disabled": false,
                    "fieldType": "string"
                }
            }];
            this.childAssetColumns = this.childAssetColumns.concat(getAssetDisplayColumns(
                ASSET_OBJECT.objectApiName.toLowerCase(),
                this.hierarchyConfig,
                this.objectInfo,
                this.engineId,
                'ManageChildAsset'));
            const childActions ={
                type: 'action',
                fixedWidth: 60,
                typeAttributes: { rowActions: CHILD_ROW_ACTIONS },
            };
            this.childAssetColumns = this.childAssetColumns.concat(childActions);
        }
        return this.childAssetColumns;
    }

    get isDirty () {
        return this.draftValues.length >0;
    }

    get isShowDataTable () {
        return this.assetRecordsView && this.displayColumns.length >0
    }

    get saveErrorMessage () {
        return formatString(
            i18n.LabelErrorRecords,
            this.errorCount
        );
    }
    @wire(getObjectAPIName, { objectId: '$parentId' })
    parentObjectName ({ error, data }) {
        if (data) {
            this.parentObjectAPIName = data.data;
            this.error = undefined;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    async getFieldsDescribeResults (data) {
        const objectNames = [
            ASSET_OBJECT.objectApiName,
        ];
        try {
            const resp = await getFieldDefinitionsForEntities(objectNames);
            if (resp && resp.data) {
                // eslint-disable-next-line no-param-reassign
                data = JSON.parse(JSON.stringify(data));
                resp.data.forEach( objectDef => {
                    objectDef.fieldDefinitions.forEach(fieldDef =>{
                        if (fieldDef.picklistValues) {
                            data.fields[fieldDef.apiName].picklistValues = fieldDef.picklistValues;
                        }
                    });
                });
                this.objectInfo = data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    @wire(getObjectInfo, { objectApiName: '$parentObjectAPIName'  })
    objectInfosWireParent ({ error, data }) {
        if (data) {
            this.parentObjectInfo = data;
            this.error = undefined;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfosWire ({ error, data }) {
        if (data) {
            this.error = undefined;
            this.getFieldsDescribeResults(data);
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getHierarchyConfiguration)
    async hierarchyConfigWire (value) {
        const { error, data }  = value;
        if (data) {
            this.error = undefined;
            let updatedConfig = value;
            if (this.columnCacheName) {
                const assetColumns = await asyncGetItemFromCache(this.columnCacheName);
                if (assetColumns && assetColumns.length >= 0) {
                    updatedConfig =
                    this.userSelectedColumns (
                        updatedConfig,
                        ASSET_OBJECT.objectApiName.toLowerCase(),
                        assetColumns);
                }
            }
            this.hierarchyConfig = updatedConfig;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getAssetsNodesForGivenParent,{
        parentId: '$parentId',
        childRelationshipName: '$childRelationshipName',
        config: '$hierarchyConfigData',
        initiatedTime: '$initiatedTime'
    })
    assetsResponseWire (value) {
        this.processAssetResponse (value);
    }

    @wire(getChildAssetNodesRaw, {
        childAssetRecordId: '$childAssetRecordId',
        config: '$hierarchyConfigData',
        initiatedTime: '$initiatedTime'
    })
    childAssetsWire (value) {
        this.processAssetResponse (value);
    }

    processAssetResponse (value) {
        this.childAssetsResults = value;
        const { error, data } = value;
        if (data) {
            this.error = undefined;
            this.assetRecords = JSON.parse(JSON.stringify(data));
            this.assetRecordsView = this.assetRecords;
            this.dataLoaded = true;
            if (this.erroredResult.length > 0 ) {
                this.handleShowErrorRecords (true);
            }
        } else if (error) {
            this.dataLoaded = true;
            this.error = parseErrorMessage(error);
        }
    }

    get i18n () {
        return i18n;
    }

    userSelectedColumns (data,objectApiName,selectedFields) {
        const mutableConfig = deepCopy(data);
        mutableConfig.data[objectApiName].fields = selectedFields.map(
            (field, index) => {
                return {
                    fieldApiName: field,
                    sequence: index+1
                }
            });
        return mutableConfig;
    }

    handleBack () {
        this.showConfirmLeave = this.isDirty;
        if (!this.showConfirmLeave) {
            this.handleConfirmLeave();
        }
    }

    handleConfirmLeave () {
        clearPubSubCache(this.engineId);
        this.dispatchEvent(
            new CustomEvent('modalclosed')
        );
        this.dispatchEvent(
            new CustomEvent('statuschange', {
                composed: true,
                bubbles: true,
                detail: {
                    status: 'FINISHED_SCREEN',
                    showToast: false
                }
            })
        );
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'delete':
                this.selectedRows = [row];
                this.openDeleteModal();
                break;
            case 'clone':
                this.cloneRow(row);
                break;

        }
    }

    cloneRow (row) {
        this.editActionTitle = row.Name;
        this.editRecordId = row.Id;
        this.editRecordObjectApiName = ASSET_OBJECT.objectApiName;
        this.showCloneRecordModal = true;
    }

    handleCloneCancelRecordModal () {
        this.showCloneRecordModal = false;
        this.editRecordId = null;
        this.editRecordObjectApiName = null;
        this.cloneError = false;
    }

    handleAddChildAssets () {
        this.editRecordObjectApiName = ASSET_OBJECT.objectApiName;
        if (this.childAssetRecordId) {
            this.assetPrefillValues.ParentId = this.childAssetRecordId;
        } else if (this.parentId && this.parentObjectInfo) {
            // eslint-disable-next-line max-len
            const foundRelationShipname = this.parentObjectInfo.childRelationships.filter(relationShip => relationShip.relationshipName === this.childRelationshipName);
            if (foundRelationShipname.length === 1) {
                this.assetPrefillValues[foundRelationShipname[0].fieldName] = this.parentId;
            }
        }
        this.showAddRecordModal = true;
        this.addActionTitle = formatString (i18n.labelAddAsset, this.objectInfo?.label);
    }

    handleAddCancelRecordModal () {
        this.showAddRecordModal = false;
        this.editRecordObjectApiName = null;
        this.cloneError = false;
    }

    handleSuccess () {
        this.showAddRecordModal = false;
        this.editRecordObjectApiName = null;
        this.cloneError = false;
        this.showAddRecordModal = false;
        refreshApex(this.childAssetsResults);
    }

    handleCloneSubmitModal (event) {
        event.preventDefault();       // stop the form from submitting
        this.isCloning = true;
        const fields = event.detail.fields;
        const objRecordInput = { 'apiName': this.editRecordObjectApiName, fields };
        // eslint-disable-next-line no-unused-vars
        createRecord(objRecordInput).then(response => {
            this.isCloning = false;
            this.showCloneRecordModal = false;
            this.editRecordId = null;
            this.editRecordObjectApiName = null;
            refreshApex(this.childAssetsResults);
        }).catch(error => {
            this.isCloning = false;
            this.cloneError = error.body.message;
        })
    }

    openDeleteModal () {
        this.deleteModalDialogOpen = true;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
        this.showConfirmLeave = false;
    }

    get removeAssetConfirmMessage () {
        return formatString(i18n.removeConfirmMessage, this.selectedRows.length);
    }

    async handleDeleteConfirmModal () {
        this.handleCancelModal();
        this.showSpinner = true;
        this.erroredResult = [];
        for (let index = 0; index < this.selectedRows.length; index ++) {
            try {
                // eslint-disable-next-line no-await-in-loop
                await deleteRecord(this.selectedRows[index].Id);
            } catch (ex) {
                const messages = ex.body.output?.errors?.map(error => error.message);
                this.erroredResult.push({
                    id: this.selectedRows[index].Id,
                    error: messages
                });
            }
        }
        refreshApex(this.childAssetsResults);
        if (this.erroredResult.length > 0) {
            this.handleShowErrorRecords(true);
        }
        this.selectedRows = [];
        this.showSpinner = false;
    }

    handleRowSelection (event) {
        let selectedIds = [];
        if (event.detail.selectedRows.length > 0) {
            this.hasNoneSelected = false;
            this.selectedRows = event.detail.selectedRows;
            selectedIds = this.selectedRows.map(record => record.Id);
        } else {
            this.hasNoneSelected = true;
        }
        setRowSelectionState(this.engineId, 'ManageChildAsset', selectedIds);
    }

    handleSearchTermChange (event) {
        const searchKey = event.target.value;
        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }
        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.latestSearchKey = searchKey;
                this.filterListViewData(searchKey);
            } catch (e) {
                this.handleError( parseErrorMessage(e) );
            }
        }, 300);
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            this.assetRecordsView = this.assetRecords;
        } else {
            const loweredSearchTerm = searchValue.toLowerCase();
            this.assetRecordsView = this.assetRecords.filter(
                item => item.Name.toLowerCase().includes(loweredSearchTerm));
        }
    }

    handleCellChange (event) {
        if (event?.detail?.draftValues
            && event.detail.draftValues.length > 0) {
            for (let index = 0; index < event.detail.draftValues.length; index++) {
                const draftValue = event.detail.draftValues[index];
                const fieldName = Object.keys(draftValue)[
                    Object.keys(draftValue).findIndex( key => key !== 'Id')];
                this.updateDraftValues (draftValue.Id,fieldName,draftValue[fieldName])
            }
        }
    }

    handleDynamicFieldChange (event) {
        const { rowId: assetId, value, fieldName } = event.detail;
        this.updateDraftValues(assetId, fieldName, value);
    }

    updateDraftValues (assetId, fieldName, value) {
        const updatedValue = value;
        const fieldAPIName =`${fieldName}apiVal`;
        let assetIdArray =[];
        if (Array.isArray(assetId)) {
            assetIdArray = [...assetId];
        } else {
            assetIdArray = [assetId];
        }
        const record = this.draftValues.filter(item => assetIdArray.includes(item.Id));
        if (record.length === 0) {
            const draftRecords = assetIdArray.map(assetRecId => {
                return {
                'Id': assetRecId,
                [fieldName]: updatedValue,
                [fieldAPIName]: value
            }});
            this.draftValues = [...this.draftValues, ...draftRecords];
        } else {
            record.forEach(rec => {
                rec[fieldName] = updatedValue;
                rec[fieldAPIName] = value;
            });
            this.draftValues = [...this.draftValues];
        }
    }

    get hasBatches () {
        return this.draftValues.length >0 && Math.ceil(this.draftValues.length/BATCH_COUNT);
    }

    async handleUpdateInlineEdit () {
        if (this.hasBatches) {
            const batchCount = Math.ceil(this.draftValues.length/BATCH_COUNT);
            this.batches = [];
            for (let index = 1; index <= batchCount; index++) {
                this.batches.push ({
                    label: formatString (i18n.labelBatchNumber,index),
                    index: index
                });
            }
        }
        this.showUpdateProgress = true;
        const chunks = chunk(this.draftValues.map(chunkrec => {
            const retRec = { 'Id': chunkrec.Id };
            Object.keys(chunkrec).forEach( key => {
                if (key !== 'Id' && !key.endsWith('apiVal')) {
                    retRec [key] = chunkrec[key+'apiVal'];
                }
            })
            return retRec;
        }), BATCH_COUNT);
        this.erroredResult = [];
        this.tableErrors = {};
        for (let index = 0; index < chunks.length; index ++) {
            // eslint-disable-next-line no-await-in-loop
            const result = await updateRecords ({
                records: JSON.stringify(chunks[index])
            });
            if (result ) {
                result.forEach(status => {
                    if (!status.success) {
                        this.erroredResult.push(status);
                    } else {
                        this.draftValues.splice(
                            this.draftValues.findIndex(value => value.Id === status.id),
                            1);
                    }
                });
                this.currentBatch++;
            }
        }
        this.draftValues = [...this.draftValues];
        this.showUpdateProgress = this.hasError;
        setRowSelectionState(this.engineId, 'ManageChildAsset', []);
        if (this.erroredResult.length === 0) {
            this.handleResetInlineEdit ();
            this.dispatchEvent(
                new ShowToastEvent({
                    message: i18n.Label_changesSavedSuccessfully,
                    variant: 'success'
                })
            );
        }
    }

    get hasError () {
        return this.erroredResult && this.erroredResult.length > 0;
    }

    get errorCount () {
        return this.erroredResult.length;
    }

    handleResetInlineEdit () {
        this.assetRecords = JSON.parse(JSON.stringify(this.childAssetsResults.data));
        this.assetRecordsView = [...this.assetRecords];
        this.tableErrors = {};
        setRowSelectionState(this.engineId, 'ManageChildAsset', []);
        refreshApex(this.childAssetsResults);
        this.draftValues = [];
        this.erroredResult = [];
        this.selectedRows = [];
        this.hasNoneSelected = true;
    }

    handleIngoreError () {
        this.handleResetInlineEdit ();
        this.showUpdateProgress = false;
    }

    handleDisplayErrors () {
        this.handleShowErrorRecords ();
    }

    handleShowErrorRecords (showAll=false) {
        this.selectedRows = [];
        this.hasNoneSelected = true;
        if (!showAll) {
            const erroredIDs = this.erroredResult.map(result => result.id);
            this.assetRecordsView = this.assetRecords.filter(
                item => erroredIDs.includes(item.Id));
        }
        const rowErrors = {};
        this.erroredResult.forEach(error => {
            rowErrors[error.id] = {
                title: 'We found errors.',
                messages: error.error,
                fieldNames: error.errorFields
            }
        });
        this.tableErrors = {
            rows: rowErrors
        };
        this.showUpdateProgress = false;
    }

    handleOnRecordTypeSelected (event) {
        const recordTypeLabel = event.detail.value;
        if (isNotUndefinedOrNull(recordTypeLabel)) {
            this.addActionTitle = formatString(
                i18n.labelAddAssetWithRecordType,
                this.objectInfo?.label,
                recordTypeLabel
            );
            this.addAssetModalSize = "LARGE";
        }
    }
}