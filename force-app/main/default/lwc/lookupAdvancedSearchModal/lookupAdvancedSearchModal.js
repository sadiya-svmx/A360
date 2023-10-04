/* eslint-disable no-unused-expressions */
import { LightningElement, api } from 'lwc';
import { sortObjectArray, OPERATOR_VALUE, IS_MOBILE_DEVICE } from 'c/utils';

import desktopTemplate from './lookupAdvancedSearchModal.html';
import mobileTemplate from './lookupAdvancedSearchModalMobile.html';

import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelApply from '@salesforce/label/c.Button_Apply';
import labelResults from '@salesforce/label/c.Label_Results';
import labelNoResults from '@salesforce/label/c.Label_No_Results_Lookup';
import labelAscending from '@salesforce/label/c.Label_Ascending';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelErrorParamMissing from '@salesforce/label/c.Error_MissingParameter';
import labelErrorFieldNotExist from '@salesforce/label/c.Error_FieldNotExists';
import labelUnsupportedObjectDisplay from '@salesforce/label/c.Message_Unsupported_Object';
import labelSelect from '@salesforce/label/c.Placeholder_Select';

const i18n = {
    buttonCancel: labelCancel,
    buttonApply: labelApply,
    labelResults: labelResults,
    labelResultsSM: labelResults.toLowerCase(),
    labelNoResults: labelNoResults,
    labelAscending: labelAscending,
    labelLoading: labelLoading,
    labelErrorParamMissing: labelErrorParamMissing,
    labelErrorFieldNotExist: labelErrorFieldNotExist,
    labelUnsupportedObjectDisplay: labelUnsupportedObjectDisplay,
    labelSelect
};

export default class LookupAdvancedSearchModal extends LightningElement {
    @api searchTerm;
    @api contextLabel;
    @api contextValue;
    @api contextRecordLabel;
    @api objectApiName;
    @api objectLabel;
    @api objectPluralLabel;
    @api overrideLookupContext;
    @api apiInProgress = false;
    @api multiple = false;
    @api isDebuggingEnabled = false;
    @api isEmbedded = false;

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    _results;
    @api get results () {
        return this._results || [];
    }

    set results (value) {
        this._results = value;
    }

    get hasResults () {
        return this.results.length;
    }

    get relativeToDebugpanel () {
        return this.isDebuggingEnabled;
    }

    get modalSize () {
        return this.isEmbedded ? 'X_SMALL' : 'MEDIUM';
    }

    sortResults () {
        this._results = sortObjectArray(this.results, this.sortBy, this.sortDirection)
    }

    _columns;
    @api get columns () {
        return this._columns;
    }
    set columns (value) {
        this._columns = value;
        this._resolveColumns();
    }

    _columnDefinitions = [];
    _resolveColumns () {
        this._columnDefinitions = this.columns.map(column => ({
            fieldName: column.fieldName,
            label: column.label,
            type: 'text',
            disabled: true,
            hideDefaultActions: true,
            sortable: true
        }));
    }

    @api error;

    @api nestedModal = false;

    focus () {
        this.searchBox?.focus();
    }

    get maxRowSelection () {
        return this.multiple ? 100 : 1;
    }

    isModalOpen = true;

    sortBy;
    sortDirection;

    selectedRows = [];
    hasEmptySelectedId = true;

    selectedId;
    selectedRecords = [];
    selectedRecordLabel;

    filterExpression = OPERATOR_VALUE.CONTAINS;

    get i18n () {
        return i18n;
    }

    get searchBox () {
        return this.template.querySelector('c-lookup-modal-search-box');
    }

    isFirstRender = true;
    disconnectedCallback () {
        this.isFirstRender = true;
    }

    renderedCallback () {
        if (this.isFirstRender) {
            this.focus();
            this.isFirstRender = false;
        }
    }

    //Function to notify change to the parent component
    fireLookupSelectedEvent (selectedId = '') {
        this.dispatchEvent(
            new CustomEvent('modallookupselect', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    id: selectedId,
                    fieldName: this.fieldName,
                    label: this.selectedRecordLabel
                }
            })
        );
    }

    //Function to handle cancel modal event
    handleCancel () {
        this.isModalOpen = false;
        this.hasEmptySelectedId = true;
        this.dispatchEvent( new CustomEvent('cancel') );
    }

    //Function to handle Search On Modal
    handleSearchEvent (searchReq) {
        if (!searchReq) {
            return;
        }

        this.selectedId = undefined;
        this.hasEmptySelectedId = true;

        this.dispatchEvent(new CustomEvent('search', { detail: searchReq.detail }));
    }

    // Handles selection event when in table mode (desktop)
    handleRowSelection (event) {
        this.hasEmptySelectedId = true;
        this.selectedRecords = [];
        if (event.detail.selectedRows.length > 0) {
            this.selectedRecords = event.detail.selectedRows;
            if (!this.multiple) {
                this.selectedId = this.selectedRecords[0].Id;
            }

            this.hasEmptySelectedId = false;
        }
    }

    // Handles selection event when in radio-list mode (mobile)
    handleSearchResultOptionsSelected (event) {
        let selectedRecordIds = event.detail.value;
        if (selectedRecordIds != null && !Array.isArray(selectedRecordIds)) {
            selectedRecordIds = [selectedRecordIds];
        }

        if (selectedRecordIds?.length > 0) {
            this.selectedRecords = this.results.filter(
                result => selectedRecordIds.includes(result.Id)
            );

            if (!this.multiple) {
                this.selectedId = this.selectedRecords[0].Id;
            }

            this.hasEmptySelectedId = false;
        }
    }

    //Function to handle Apply click on table
    handleApply () {
        if (this.multiple) {
            this.fireLookupSelectedEvent(this.selectedRecords);
        } else {
            this.fireLookupSelectedEvent(this.selectedId);
        }
        this.isModalOpen = false;
        this.hasEmptySelectedId = true;
    }

    handleSortData (event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;

        // calling sortData function to sort the data based on direction and selected field 
        //set the sorted data to data table data
        this.sortResults();
    }

    get titleModal () {
        return IS_MOBILE_DEVICE ?
            `${i18n.labelSelect} ${this.objectLabel}` :
            `${this.objectLabel}  ${i18n.labelResults}`;
    }

    get messageNoResults () {
        return i18n.labelNoResults;
    }

    get labelPlural () {
        return this.objectPluralLabel;
    }

    hasContextFilter () {
        return !!this.contactLabel;
    }
}