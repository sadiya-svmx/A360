/* eslint-disable no-unused-expressions */
import { LightningElement, api } from 'lwc';
import {
    formatString,
    OPERATOR_VALUE,
    LOOKUP_OPERATOR_OPTIONS,
    IS_MOBILE_DEVICE,
    isUndefinedOrNull,
} from 'c/utils';

import desktopTemplate from './lookupModalSearchBox.html';
import mobileTemplate from './lookupModalSearchBoxMobile.html';

import labelSearch from '@salesforce/label/c.Placeholder_Search';
import labelContextFilter from '@salesforce/label/c.Label_Context_Filter';
import labelTrue from '@salesforce/label/c.Label_True';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelAdd from '@salesforce/label/c.Button_Add';
import labelSave from '@salesforce/label/c.Button_Save';

const i18n = {
    labelSearch: labelSearch,
    labelContextFilter: labelContextFilter,
    labelTrue: labelTrue,
    labelAdd,
    labelCancel,
    labelSave
};

export default class LookupModalSearchBox extends LightningElement {

    _searchTerm = '';
    _filterExpression;
    delayTimeout;

    //Setting applyContextFilter to default true, will be updated in case of overrideLookupContext 
    applyContextFilter = true;

    @api overrideLookupContext;
    @api contextLabel;
    @api contextValue;
    @api contextRecordLabel;
    @api objectApiName;
    @api objectLabel;

    isAddModalOpen = false;

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    get options () {
        return LOOKUP_OPERATOR_OPTIONS;
    }

    get i18n () {
        return i18n;
    }

    @api get searchTerm () {
        return this._searchTerm;
    }

    set searchTerm (value) {
        if (value) {
            this._searchTerm = value;
        }
    }

    @api get filterExpression () {
        return ( this._filterExpression || OPERATOR_VALUE.CONTAINS );
    }

    set filterExpression (value) {
        if (value) {
            this._filterExpression = value;
        }
    }

    @api focus () {
        this.searchInput?.focus();
    }

    get searchInput () {
        return this.template.querySelector('lightning-input.svmx-search-input');
    }

    handleFilterChange (event) {
        if (event.detail.value) {
            this._filterExpression = event.detail.value;
            this.fireSearchEvent();
        }
    }

    handleSearchTermChange (event) {
        this._searchTerm = event.target.value.trim();
        this.fireSearchEvent();
    }

    //Function to handle Context Filter Checkbox change
    handleContextFilterCheckbox (event) {
        this.applyContextFilter = event.target.checked ?? !event.target.selected;
        this.fireSearchEvent();
    }

    //Function to fire the Search event
    fireSearchEvent () {
        const searchReq = {
            filterExpression: this.filterExpression,
            searchTerm: this.searchTerm,
            applyContextFilter: this.applyContextFilter
        };
        // Dispatches the event.
        this.dispatchEvent(new CustomEvent('search', { detail: searchReq }));
    }

    get hasContextFilter () {
        return (this.contextLabel !== undefined && this.contextValue !== undefined);
    }

    get fullContextLabel () {
        const contextDisplayValue = this.contextRecordLabel || this.contextValue;
        let formattedString = formatString(
            i18n.labelContextFilter,
            this.contextLabel,
            contextDisplayValue !== undefined ? contextDisplayValue : 'null'
        );
        if (isUndefinedOrNull(contextDisplayValue)) {
            formattedString = formattedString.replaceAll('"', '');
        }
        return this.hasContextFilter ? formattedString : '';
    }

    get isOverrideContextDisable () {
        return !this.overrideLookupContext;
    }

    get addRecordTitle () {
        return `${i18n.labelAdd} ${this.objectLabel}`;
    }

    get recordCreateForm () {
        return this.template.querySelector('lightning-record-form');
    }

    handleAddModalOpen () {
        this.isAddModalOpen = true;
    }

    handleAddModalCancel () {
        this.isAddModalOpen = false;
    }

    handleAddModalSave () {
        this.recordCreateForm.submit();
    }

    handleAddModalSuccess () {
        this.fireSearchEvent();
        this.isAddModalOpen = false;
    }
}