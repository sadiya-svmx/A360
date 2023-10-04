import labelCollapseBranch from '@salesforce/label/c.Label_Collapse';
import labelExpandBranch from '@salesforce/label/c.Label_Expand';
import { LightningElement, api, track } from 'lwc';
import { classSet, formatString, normalizeBoolean } from 'c/utils';

const i18n = {
    collapseBranch: labelCollapseBranch,
    expandBranch: labelExpandBranch,
};

export default class PrivateTreeGridCellToggle extends LightningElement {
    @api rowKeyValue;
    @api colKeyValue;
    @api value;
    @track _fetchOnly;

    @track _expanded = false;
    @track _hasChildren = false;

    @track _tabindex = 0;

    get computedButtonClass () {
        return classSet('slds-button slds-button_icon slds-m-right_x-small')
            .add({
                'slds-is-disabled': !this.hasChildren ,
            })
            .toString();
    }

    @api
    get tabIndex () {
        return -1;
    }

    set tabIndex (newValue) {
        this.setAttribute('tabindex', newValue);
        this._tabindex = newValue;
    }

    get buttonTabIndex () {
        return this._tabindex;
    }

    @api
    get fetchOnly () {
        return this._fetchOnly;
    }

    set fetchOnly (value) {
        this._fetchOnly = normalizeBoolean(value);
    }

    @api
    get hasChildren () {
        return this._hasChildren;
    }

    set hasChildren (value) {
        this._hasChildren = normalizeBoolean(value);
    }

    @api
    get isExpanded () {
        return this._expanded;
    }

    set isExpanded (value) {
        this._expanded = normalizeBoolean(value);
    }

    get buttonTitle () {
        if (this.isExpanded) {
            return formatString(i18n.collapseBranch, this.value);
        }
        return formatString(i18n.expandBranch, this.value);
    }

    handleDownloadClick () {
        const customEvent = new CustomEvent('privatetogglecell', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                name: this.rowKeyValue,
                nextState: this.isExpanded ? false : true, // True = expanded, False = collapsed
                fetchOnly: true
            },
        });
        this.dispatchEvent(customEvent);
    }

    handleChevronClick () {
        const customEvent = new CustomEvent('privatetogglecell', {
            bubbles: true,
            composed: true,
            cancelable: true,
            detail: {
                name: this.rowKeyValue,
                nextState: this.isExpanded ? false : true, // True = expanded, False = collapsed
                fetchOnly: false
            },
        });
        this.dispatchEvent(customEvent);
    }

    @api
    focus () {
        this.template.querySelector('button').focus();
    }
}