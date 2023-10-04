import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import {
    parseErrorMessage,
    PAGE_ACTION_TYPES,
    isEmptyString,
    isNotUndefinedOrNull,
    verifyApiResponse
} from 'c/utils';
import { getFieldDefinitionsForEntity } from 'c/metadataService';

import getAllExpressions from '@salesforce/apex/ADM_ExpressionLightningService.getAllExpressions';
import getExpressions from '@salesforce/apex/ADM_ExpressionLightningService.getExpressions';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import saveExpression from '@salesforce/apex/ADM_ExpressionLightningService.saveExpression';

import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelExpression from '@salesforce/label/c.Label_Expression';
import labelEditExpression from '@salesforce/label/c.Button_EditExpression';
import labelExpressionName from '@salesforce/label/c.Label_ExpressionName';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelLess from '@salesforce/label/c.Button_Less';
import labelMore from '@salesforce/label/c.Button_More';
import labelNewExpression from '@salesforce/label/c.Label_New_Expression';
import labelRefresh from '@salesforce/label/c.Button_Refresh';
import labelSave from '@salesforce/label/c.Button_Save';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchExpressions';
import labelSelectorModalTitle from '@salesforce/label/c.Label_SelectorModalTitle';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelLoading from '@salesforce/label/c.Label_Loading';

const i18n = {
    apply: labelApply,
    cancel: labelCancel,
    developerName: labelDeveloperName,
    editExpression: labelEditExpression,
    expressionName: labelExpressionName,
    expression: labelExpression,
    items: labelItemsRowCount,
    less: labelLess,
    more: labelMore,
    new: labelNewExpression,
    refresh: labelRefresh,
    save: labelSave,
    searchPlaceholder: labelSearchPlaceholder,
    selectorModalTitle: labelSelectorModalTitle,
    wasSaved: labelWasSaved,
    loading: labelLoading,
};

const EXPRESSION_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__expressionDetail'
    }
};

export default class ExpressionSelector extends NavigationMixin(
    LightningElement
) {
    @api objectApiName;
    @api currRecordId;
    @api pageMode;
    @api selectorModalTitle = i18n.selectorModalTitle;
    @api modalSize = 'SMALL_FIXED';

    @track listViewData = {};
    @track filteredListViewData;
    @track error;
    @track _selectorModalOpen;

    rowCount = 0;
    searchString;

    @api
    get selectorModalOpen () {
        return this._selectorModalOpen;
    }
    set selectorModalOpen (val) {
        if (val === true) {
            this.getInitialListViewData();
            this.searchString = '';
        }
        this._selectorModalOpen = val;
    }

    get hasFilteredListViewData () {
        return isNotUndefinedOrNull(this.filteredListViewData);
    }

    get isEditable () {
        let editable = true;
        if (this.pageMode && this.pageMode === 'read') {
            editable = false;
        }
        return editable;
    }

    get i18n () {
        return i18n;
    }

    renderedCallback () {
        this.toggleApplyButton();
    }

    /**
     * Gets the initial list view data.
     */
    getInitialListViewData () {
        if (this.objectApiName && this.objectApiName !== '') {
            getExpressions({ requestJson: JSON.stringify({ objectAPIName: this.objectApiName }) })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }

                    this.error = null;
                    this.setListViewData(result.data);
                });
        } else {
            getAllExpressions()
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }

                    this.error = null;
                    this.setListViewData(result.data);
                });
        }
    }

    setListViewData (data) {
        this.listViewData.data = data;
        this.listViewData.data.forEach(item => {
            item.selected = item.selected ? item.selected : false;
            item.expanded = item.expanded ? item.expanded : false;
            if (this.currRecordId && item.id === this.currRecordId) {
                item.selected = true;
            }

            item.computedItemCss = this.computeItemCss(item);
        });

        this.filteredListViewData = this.listViewData.data;

        this.rowCount =
            this.listViewData && this.listViewData.data
                ? this.listViewData.data.length
                : 0;
    }

    computeItemCss (expressionRecord) {
        const cssClasses = ['svmx-expression_option', 'slds-border_top'];

        if (expressionRecord.expanded) {
            cssClasses.push('slds-theme_shade');
        }

        return cssClasses.join(' ');
    }

    getSelectedRow () {
        if (!this.filteredListViewData) return null;

        return this.filteredListViewData.find(item => item.selected);
    }

    /**
     * The main output of the component.
     * Gives you the expression that was selected via event.detail.value when you
     * implement an onexpressionselected handler
     */
    handleApply () {
        const selectedExpressionRecord = this.getSelectedRow();

        if (selectedExpressionRecord) {
            this.dispatchEvent(
                new CustomEvent('expressionselected', {
                    composed: true,
                    bubbles: true,
                    detail: {
                        value: selectedExpressionRecord
                    }
                })
            );
        }
    }

    handleCancelEdit (event) {
        const expressionRecord = this.listViewData.data.find(
            item => item.id === event.target.dataset.rowId
        );
        this.getExistingRecordDetails(expressionRecord.id).finally(() => {
            expressionRecord.editMode = false;
        });
    }

    handleCancelModal () {
        this.dispatchEvent(
            new CustomEvent('expressionselectorclosed', {
                composed: true,
                bubbles: true
            })
        );
    }

    handleNewExpression () {
        this.navigateToDetailComponent(PAGE_ACTION_TYPES.NEW);
    }

    handleExpandItem (event) {
        event.preventDefault();

        const rowId = event.currentTarget.dataset.rowId

        const expressionRecord
            = this.filteredListViewData.find(item => item.id === rowId);

        if (expressionRecord.fetched) {
            expressionRecord.expanded = !expressionRecord.expanded;
            expressionRecord.computedItemCss = this.computeItemCss(expressionRecord);
        } else {
            this.getExistingRecordDetails(expressionRecord.id).finally(() => {
                expressionRecord.expanded = !expressionRecord.expanded;
                expressionRecord.computedItemCss = this.computeItemCss(expressionRecord);
            });
        }
    }

    handleEdit (event) {
        const rowId = event.target.dataset.rowId
            ? event.target.dataset.rowId
            : event.detail.value;
        const expressionRecord = this.filteredListViewData.find(
            item => item.id === rowId
        );
        expressionRecord.editMode = true;
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && searchKey.length >= 1 && searchKey.length < 3) {
            return;
        }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.searchString = searchKey;
                this.filterListViewData(searchKey);
            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    handleRefresh () {
        this.getInitialListViewData();
        this.searchString = '';
    }

    handleSave (event) {
        const expressionRecord = this.listViewData.data.find(
            item => item.id === event.target.dataset.rowId
        );

        const expressionBuilder = this.template.querySelector(
            `c-expression-builder[data-row-id=${expressionRecord.id}]`
        );

        if (expressionBuilder.reportValidity()) {
            return;
        }

        const builderData = expressionBuilder.expressionData.getRecordData();

        this.error = null;

        this.apiInProgress = true;

        saveExpression({ requestJson: JSON.stringify(builderData) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                expressionRecord.editMode = false;
                this.showSaveSuccessNotification(expressionRecord.name);
                this.getExistingRecordDetails(expressionRecord.id);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    handleSelect (event) {
        this.listViewData.data.forEach(item => {
            item.selected = false;
        });
        const expressionRecord = this.listViewData.data.find(
            item => item.id === event.target.dataset.rowId
        );
        expressionRecord.selected = true;
    }

    /**
     * Filters the list by the searchValue provided
     * @param {String} searchValue - the string value that is used to search the list
     */
    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.filteredListViewData = [...this.listViewData.data]
        } else {
            this.filteredListViewData = this.listViewData.data.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const nameMatch = item.name
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const developerNameMatch = item.developerName
                    ? item.developerName
                        .toLowerCase()
                        .indexOf(loweredSearchValue)
                    : -1;
                const apiNameMatch = item.objectApiName
                    ? item.objectApiName
                        .toLowerCase()
                        .indexOf(loweredSearchValue)
                    : -1;

                return (
                    nameMatch !== -1 ||
                    developerNameMatch !== -1 ||
                    apiNameMatch !== -1
                );
            });
        }
        this.rowCount = this.filteredListViewData
            ? this.filteredListViewData.length
            : 0;
    }

    /**
     * Generates the URL for the Expression Detail component,
     * and opens in a new tab.
     * @param {String} actionName - PAGE_ACTION_TYPE
     */
    navigateToDetailComponent (actionName) {
        const navState = {
            c__actionName: actionName
        };

        if (actionName === PAGE_ACTION_TYPES.NEW) {
            navState.c__objectName = this.objectApiName;
        }

        const detailRef = Object.assign({}, EXPRESSION_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.GenerateUrl](detailRef).then(url => {
            window.open(url, '_blank');
        });
    }

    /**
     * Get the details for a record when it is expanded
     * @param {String} recordId - the record Id of the expression
     */
    async getExistingRecordDetails (recordId) {
        const expressionRecord = this.filteredListViewData.find(
            item => item.id === recordId
        );
        expressionRecord.apiInProgress = true;
        getExpressionWithDetails({ expressionId: recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                expressionRecord.selectedRecord = result.data;
                this.getObjectFields(result.data.objectAPIName)
                    .then(
                        entityWithFields => {
                            expressionRecord.selectedEntityDefinition = entityWithFields;
                            expressionRecord.editMode = false;
                            expressionRecord.fetched = true;
                        }
                    )
                    .catch(error => {
                        this.error = parseErrorMessage(error);
                    })
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                expressionRecord.apiInProgress = false;
            });
    }

    /**
     * Gets the field definitions for the supplied Object API Name
     * @param {String} objectApiName - API Name of the object
     */
    async getObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            throw new Error(parseErrorMessage(err));
        }

        return result;
    }

    /**
     * Emits a toast to let the user know the save action was a success
     * @param {String} expressionName - Name of the expression that was saved
     */
    showSaveSuccessNotification (expressionName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.expression} "${expressionName}" ${this.i18n.wasSaved}`,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    toggleApplyButton () {
        const applyButton = this.template.querySelector('.svmx-expression_button-apply');
        if (applyButton) {
            const selectedExpression = this.getSelectedRow();
            applyButton.disabled = selectedExpression === null || selectedExpression === undefined;
        }
    }
}