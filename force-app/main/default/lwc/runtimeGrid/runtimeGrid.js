import { LightningElement, track, api } from 'lwc';
import {
    guid,
    PUBSUB_KEYS,
    deepCopy,
    isUndefinedOrNull,
    filterRecords,
    formatString,
} from 'c/utils';
import {
    registerRuntimeFieldValueChange,
    HEADER,
    getResolvedLookupState,
} from 'c/runtimePubSub';

import { EngineElement }  from 'c/runtimeEngineProvider';
import {
    mungeChildRecordData,
    mungeChildValidationResults,
    mungeChildUpdates
} from 'c/runtimeEngine';
import { setRowSelectionState } from 'c/runtimePubSub';

import { loadStyle } from 'lightning/platformResourceLoader';
import runtimeGridResource from '@salesforce/resourceUrl/runtimeGrid';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelAllowZeroLineError from '@salesforce/label/c.Message_AllowZeroLineError';
import labelAdd from '@salesforce/label/c.Button_Add';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelFilter from '@salesforce/label/c.Label_Search';
import labelItemsFound from '@salesforce/label/c.Label_FilterRecordsFound';
import rowRequiredMultipleErrors
    from '@salesforce/label/c.Message_RuntimeRowRequiredMultipleErrors';
import rowRequiredSingleError from '@salesforce/label/c.Message_RuntimeRowRequiredSingleError';
import labelAddinCatalog from '@salesforce/label/c.Button_AddIn';
import label_Catalog from '@salesforce/label/c.Label_Catalog';

const i18n = {
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    noResults: labelNoResults,
    loading: labelLoading,
    allowZeroLineError: labelAllowZeroLineError,
    add: labelAdd,
    edit: labelEdit,
    addInCatalog: labelAddinCatalog,
    labelCatalog: label_Catalog,
    rowRequiredMultipleErrors,
    rowRequiredSingleError,
    filter: labelFilter,
    itemsFound: labelItemsFound
};

const applyFilter = (tab, keyword, selectedRows, engineId) => {
    const displayFields = (
        tab.columns.filter(column => column.fieldName) || []
    ).map(column => column.fieldName);
    const records = filterRecords(keyword,
        tab.masterData,
        displayFields,
        selectedRows,
        tab.fieldsMetadata,
        getResolvedLookupState(engineId),
    );
    tab.showFilterResults = formatString(i18n.itemsFound, records.length);
    return records;
};

let debounceTimer;
const filterDebounce = (tab, keyword, selectedRows, engineId) => {
    clearTimeout(debounceTimer);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    debounceTimer = setTimeout(() => {
        tab.data = applyFilter(tab, keyword, selectedRows, engineId);
        const filteredRecordIds = tab.data.map(data => data.Id);
        // record to be excluded while user edit or add new line when filter is on
        tab.recordTobeExcluded = tab.masterData
            .filter(data => !filteredRecordIds.includes(data.Id))
            .map(data => data.Id);
    }, 300);
};

const clearFilter = (tab) => {
    clearTimeout(debounceTimer);
    tab.data = tab.masterData;
    tab.showFilterResults = null;
    tab.recordTobeExcluded = [];
}

export default class RuntimeGrid extends EngineElement(LightningElement) {
    isInitialRender = true;

    @track childRecordData;
    @track selectedRows;
    @track lastSavedData;
    @track validationErrors;
    @track deleteModalDialogOpen;
    @track _tabs = [];
    @track loading = true;
    @track _activeTab = '';
    @track extendedEdit = {};
    // prepare output record collection for save action
    _hasSubmit = false;
    IsTransaction = true;

    get i18n () {
        return i18n;
    }

    get relativeToDebugpanel () {
        return this.isDebugEnabled;
    }

    get tabs () {
        return this._tabs;
    }

    set tabs (value) {
        const NUM_OF_TABS = value.length;
        const newTabs = [];
        for (let index = 0; index < NUM_OF_TABS; ++index) {
            const objectApiName = value[index].objectAPIName;
            const childRecordData = this.getChildRecordData(value[index].name, objectApiName);
            const selectedIds = this.selectedRows[value[index].name] || [];
            const lastSavedData = this.lastSavedData[value[index].name] || [];
            const errors = this.validationErrors[value[index].name] || {};
            const columns = value[index].elements;
            const showErrorIndicator = !!Object.keys((errors.rows || {})).length;
            const excludedIds = this._tabs[index] ? this._tabs[index].recordTobeExcluded : [];
            const showResults = this._tabs[index] ? this._tabs[index].showFilterResults : null;
            const multiAddSearchField = value[index].multiAddSearchField;
            const tab = {
                id: value[index].id,
                hideCheckboxColumn: this.IsTransaction ? false : !value[index].selectableGrid,
                inputProp: this.getInputProp(index, value),
                label: value[index].title,
                labelAddItem: `+ ${i18n.add} ${value[index].title}`,
                labelMultiAddItem: formatString(
                    '+ ' + i18n.addInCatalog,
                    value[index].title
                ),
                controllerReferenceField: value[index].controllerReferenceField,
                value: value[index].name,
                objectApiName,
                errors: this._hasSubmit? errors : {},
                columns: columns,
                section: value[index].section,
                masterData: childRecordData,
                showFilterResults: showResults,
                recordTobeExcluded: excludedIds,
                lastSavedData: lastSavedData,
                selectedRows: selectedIds,
                lastDeletedData: [],
                addRow: value[index].addRow,
                deleteRow: value[index].deleteRow,
                fieldsMetadata: value[index].fieldsMetadata,
                defaultRecordTypeId: value[index].defaultRecordTypeId,
                allowZeroLines: value[index].allowZeroLines,
                valueMappingId: value[index].valueMapping,
                enableMultiAdd: multiAddSearchField ? true: false,
                multiAddSearchField,
                showErrorIndicator,
            };
            tab.data = tab.recordTobeExcluded.length
                ? tab.masterData.filter(data => !tab.recordTobeExcluded.includes(data.Id))
                : childRecordData;

            if (tab.enableMultiAdd) {
                columns.forEach(column => {
                    if (column.fieldName === multiAddSearchField) {
                        tab.multiAddConfig = JSON.parse(column?.typeAttributes?.meta || '{}');
                        tab.multiAddConfig.debugLabel = column?.typeAttributes?.label;
                    }
                });
            }
            newTabs.push(tab);
        }

        this._tabs = newTabs;

        return this._tabs;
    }

    sanitizeDataForSave (name, objectApiName) {
        const data = this.childRecordData[name] || [];
        const parsedData = deepCopy(data);
        const sanitizedData = [];

        /**
         * provide an Id to record(s) created on the fly to track row edit
         * E.g. via "Apply Mapping" Apex action
         */
        parsedData.forEach(record => {
            const pattern = /^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$/;
            const isNewRecord = isUndefinedOrNull(record.Id) || pattern.test(record.Id);
            if (isNewRecord) {
                record.isNew = true;
                if (!record.Id) {
                    record.Id = guid();
                }
            }
            // transaction records include record.type.objectApiName and Flow queried records do not
            record.objectApiName = record.type && record.type.objectApiName || objectApiName;
            sanitizedData.push(record);
        });
        return sanitizedData;
    }

    getChildRecordData (name, objectApiName) {
        return this.sanitizeDataForSave(name, objectApiName);
    }

    getInputProp (index) {
        return Object.keys(this.childRecordData)[index];
    }

    _ranInitialValidations = false;
    loadStylePromise;
    renderedCallback () {
        this.loadStylePromise = Promise.all([
            loadStyle(this, runtimeGridResource)
        ])
            .then(() => { })
            .catch(error => {
                console.error('staticresource for runtimeGrid load error', error);
            });

        // If we've got a full set of tabs, validate the data right away.
        if (!this._ranInitialValidations && this._tabs.length > 0) {
            this._activeTab = this._tabs[0].value;
            this._ranInitialValidations = true;
        }
    }

    displayExtendedEdit (tab, record, action) {
        this.extendedEdit.showExtendedEdit = true;
        this.extendedEdit.recordId = { ...record };
        this.extendedEdit.rowIndex = record.Id;
        this.extendedEdit.tabIndex = tab.value;
        this.extendedEdit.title = `${action==='add'?i18n.add : i18n.edit} ${tab.label}`;
        this.extendedEdit.action = action;
    }

    async handleAddItem (event) {
        event.preventDefault();
        const tab = this.getActiveTab();
        const recordId  = await this.props.handleAddTemporaryChildLine(tab.value);
        if (recordId) {
            this.displayExtendedEdit(tab, { Id: recordId }, 'add');
        }
    }

    handleExtendedEditCancel () {
        this.extendedEdit = {};
    }

    handleActive (event) {
        this._activeTab = event.target.value;
        registerRuntimeFieldValueChange({
            engineId: this.engineId,
            whichSection: HEADER,
            fieldName: PUBSUB_KEYS.ACTIVE_TAB,
            value: this.activeTab
        });
    }

    get rowCount () {
        const tab = this.getActiveTab();
        return tab && tab.data ? tab.data.length : 0;
    }

    get activeTab () {
        return (this._activeTab !== '') ? this._activeTab : null;
    }

    handleRowAction (event) {
        const row = event.detail.row;
        const { name } = event.detail.action;
        // eslint-disable-next-line default-case
        switch (name) {
            case 'edit':
                this.editRow(row);
                break;
            case 'clone':
                this.cloneRow(row);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
        }
    }

    async applyMultiSelect (event) {
        event.preventDefault();
        const tab = this.getActiveTab();
        const selectedIds = event.detail.map( selectedRecord => selectedRecord.value);
        await this.props.handleAddMultipleLines(
            tab.value,
            selectedIds,
            tab.multiAddSearchField
        );
    }

    editRow (row) {
        const tab = this.getActiveTab();
        this.props.editTemporaryChildLine(tab.value,row.Id);
        this.displayExtendedEdit(tab, row, 'edit');
    }


    cloneRow (row) {
        const tab = this.getActiveTab();
        this.props.handleCloneChildLine(tab.value,row.Id);
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
        const tab = this.getActiveTab();
        this.props.deleteChildLines(tab.value, this.pendingDeleteRecord.Id);
    }

    updateDraftValues (updateItems) {
        this._tabs.forEach(tab => {
            if (tab.value === this._activeTab) {
                const updatedItems = Array.isArray(updateItems) ? updateItems : [updateItems];
                updatedItems.forEach(updateItem => {
                    Object.keys(updateItem).forEach(keyName => {
                        if (keyName !== 'Id') {
                            this.props.handleChildRecordChange(
                                tab.value,
                                [updateItem.Id],
                                keyName,
                                updateItem[keyName]
                            );
                        }
                    });
                });
            }
        });
    }

    handleCheckboxChange (event) {
        this.updateFieldValues(event);
    }

    handleDynamicFieldChange (event) {
        this.updateFieldValues(event);
    }

    handleRowSelection (event) {
        const { selectedRows } = event.detail;
        const tab = this.getActiveTab();
        const selectedIds = selectedRows.map(record => record.Id);
        this.props.selectedChildLines(tab.value,selectedIds);
        setRowSelectionState(this.engineId, tab.value, selectedIds);
    }

    async updateFieldValues (event) {
        event.stopPropagation();
        const {
            rowId,
            value,
            fieldName
        } = event.detail;

        if (Array.isArray(rowId)) {
            const tab = this.getActiveTab();
            this.props.handleChildRecordChange(
                tab.value,
                rowId,
                fieldName,
                value
            );
        } else {
            this.updateDraftValues({
                Id: rowId,
                [fieldName]: value
            });
        }
    }

    // handler to handle cell changes & update values in draft values
    handleCellChange (event) {
        this.updateDraftValues(event.detail.draftValues);
    }

    @api
    reportGridValidity () {
        this._hasSubmit = true;
    }

    @api
    resetReportValidity () {
        this._hasSubmit = false;
    }

    getActiveTab () {
        const activeTab = this._tabs.filter(tab => tab.value === this._activeTab);
        if (!activeTab.length) return null;
        return activeTab[0];
    }

    handleFilter (event) {
        const filterKeyword = event.target.value.trim();
        const tab = this.getActiveTab();
        const selectedRows = this.selectedRows[this._activeTab] || [];
        if (filterKeyword.length > 1) {
            filterDebounce(tab, filterKeyword, selectedRows, this.engineId);
        } else {
            clearFilter(tab);
        }
    }

    runtimeEngineUpdate (engineProps) {
        this.validationErrors = mungeChildValidationResults(
            engineProps.childValidationResults, i18n
        );
        this.lastSavedData = mungeChildUpdates(
            engineProps.initialChildValues,
            engineProps.childValues,
            engineProps.childUpdates
        );
        this.childRecordData = mungeChildRecordData(
            engineProps.childValues,
            engineProps.childValuesSequence);
        this.selectedRows = engineProps.selectedChildValues;
        this.IsTransaction = engineProps.screenType !== 'Screen' ? true : false;
        this.tabs = engineProps.tabs;
        this.engineId = engineProps.engineId;
        this.loading = engineProps.loadingStatus.LOADING_ENGINE_METADATA;
        this.isDebugEnabled = engineProps.isDebugEnabled;
    }

}