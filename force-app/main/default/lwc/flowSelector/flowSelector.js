import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProcessStepTargetsByType
    from '@salesforce/apex/ADM_ProcessWizardLightningService.getProcessStepTargetsByType';
import getEntityDefinitionId
    from '@salesforce/apex/COMM_MetadataManager.getEntityDefinitionId';
import {
    parseErrorMessage,
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    STEP_TYPES,
    ROUTES
} from 'c/utils';

import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelTitle from '@salesforce/label/c.Title_FlowSelector';
import labelFlowApiName from '@salesforce/label/c.Label_FlowApiName';
import labelFlowName from '@salesforce/label/c.Label_FlowName';
import labelNew from '@salesforce/label/c.Button_New';
import labelRefresh from '@salesforce/label/c.Button_Refresh';
import labelFlowDesignerUrl from '@salesforce/label/c.URL_FlowDesigner';

const i18n = {
    apply: labelApply,
    cancel: labelCancel,
    loading: labelLoading,
    searchPlaceholder: labelSearchPlaceholder,
    modalTitle: labelTitle,
    flowApiName: labelFlowApiName,
    flowName: labelFlowName,
    new: labelNew,
    refresh: labelRefresh,
    newFlowUrl: labelFlowDesignerUrl
};

export default class FlowSelector extends LightningElement {
    @api stepTypeName;
    @api stepIconName;
    @api objectApiName;

    columns = [
        { label: i18n.flowName, fieldName: 'label' },
        { label: i18n.flowApiName, fieldName: 'apiName' }
    ]
    data;
    @track filteredData;
    @track error;
    @track _selectorModalOpen = false;
    @track entityDefinitionId;

    _isFetching = false;

    @api
    get selectorModalOpen () {
        return this._selectorModalOpen;
    }
    set selectorModalOpen (newValue) {
        if (newValue === true) {
            this.filterData('');
        }

        this._selectorModalOpen = newValue;
    }

    @wire(getProcessStepTargetsByType, { requestJson: '$requestJson' })
    getStepTargets (value) {
        this.wiredRecords = value;
        const { err, data } = value;
        if (data) {
            this.data = data.data;
            this.filteredData = this.data;
        } else if (err) {
            this.error = err;
        }
        this._isFetching = false;
    }

    @wire(getEntityDefinitionId,{ objectApiName: '$objectApiName' })
    fetchedEntityDefinitionId (value) {
        if (value) {
            this.entityDefinitionId = value.data;
        }
    }

    renderedCallback () {
        this.toggleApplyButton();
    }

    get flowSelectorListBoxElement () {
        return this.template.querySelector(".svmx-flow-selector_list-box");
    }

    get i18n () {
        return i18n;
    }

    get isNewTargetDisabled () {
        return this.stepTypeName === STEP_TYPES.LWC;
    }

    get isLoading () {
        return isUndefinedOrNull(this.filteredData) || this._isFetching;
    }

    get requestJson () {
        const requestParameters = {
            stepTypeName: this.stepTypeName,
            objectApiName: this.objectApiName
        }
        return JSON.stringify(requestParameters);
    }

    /**
     * The main output of the component. 
     * Gives you the flow that was selected via event.detail.value when you 
     * implement an onflowselected handler
    */
    handleApply () {
        const listBox = this.flowSelectorListBoxElement;
        this.dispatchEvent(
            new CustomEvent('flowselected', {
                composed: true,
                bubbles: true,
                detail: {
                    value: listBox.selectedRow
                }
            })
        );
    }

    handleCancelModal () {
        this.dispatchEvent(
            new CustomEvent('flowselectorclosed', {
                composed: true,
                bubbles: true
            })
        );
    }

    handleNewFlow (event) {
        event.preventDefault();
        switch (this.stepTypeName) {
            case STEP_TYPES.FLOW:
                window.open(i18n.newFlowUrl, '_blank');
                break;
            case STEP_TYPES.TRANSACTION:
                window.open(
                    `${ROUTES.TRANSACTION_EDITOR}`,
                    '_blank'
                );
                break;
            case STEP_TYPES.RECORDACTION:
                // eslint-disable-next-line no-case-declarations
                let recordActionUrl = '/lightning/setup/ObjectManager/';
                if (isNotUndefinedOrNull(this.entityDefinitionId)) {
                    recordActionUrl +=`${this.entityDefinitionId}/ButtonsLinksActions/newAction`
                } else {
                    recordActionUrl+='home';
                }
                window.open(recordActionUrl, '_blank' )
                break;
            default:
                window.open(i18n.newFlowUrl, '_blank');
        }
    }

    handleRefresh () {
        const listBox = this.flowSelectorListBoxElement;

        if (listBox) {
            listBox.searchInputValue = null;
        }
        this._isFetching = true;
        this.filterData('');
        refreshApex(this.wiredRecords);
    }

    handleRowSelected (event) {
        event.preventDefault();
        this.toggleApplyButton();
    }

    toggleApplyButton () {
        const applyButton = this.template.querySelector('.svmx-flow-selector_apply-button');
        if (applyButton) {
            applyButton.disabled = !this.isRowSelected();
        }
    }

    isRowSelected () {
        const listBox = this.flowSelectorListBoxElement;

        return (listBox && listBox.selectedRow);
    }

    handleSearchKeyChange (event) {
        const searchKey = event.detail.value;

        if (searchKey && searchKey.length >= 1 && searchKey.length < 3) {
            return;
        }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.filterData(searchKey);
            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    /**
     * Filters the list by the searchValue provided
     * @param {String} searchValue - the string value that is used to search the list
    */
    filterData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.filteredData = this.data;
        } else {
            this.filteredData = this.data.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const labelMatch = item.label
                    ? item.label.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const apiNameMatch = item.apiName
                    ? item.apiName
                        .toLowerCase()
                        .indexOf(loweredSearchValue)
                    : -1;

                return (
                    labelMatch !== -1 ||
                    apiNameMatch !== -1
                );
            });
        }
    }
}