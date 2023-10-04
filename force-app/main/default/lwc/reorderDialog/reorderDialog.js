import { LightningElement, api, track } from 'lwc';
import { normalizeBoolean } from 'c/utils';

import labelOK from '@salesforce/label/c.Button_OK';

const i18n = {
    ok: labelOK,
};

export default class ReorderDialog extends LightningElement {
    @track _modalOpen = false;
    @track _options = [];

    /**
     * If present, displays the reorder dialog
     * @type {boolean}
     * @default false
     */
    @api
    get modalOpen () {
        return this._modalOpen;
    }
    set modalOpen (newValue) {
        this._modalOpen = normalizeBoolean(newValue);
    }

    /**
     * A list of options that are available for selection.
     * @type {object[]}
     * @required
     */
    @api
    get options () {
        return this._options || [];
    }

    set options (newOptions) {
        this._options = newOptions;
    }

    /**
     * Title for the modal dialog
     * @type {string}
     * @required
     */
    @api dialogTitle;

    get i18n () {
        return i18n;
    }

    get reorderListBoxElement () {
        return this.template.querySelector('c-reorder-list-box');
    }

    dispatchChangeEvent (changedValue) {
        this.dispatchEvent(
            new CustomEvent('change', {
                composed: true,
                bubbles: true,
                detail: {
                    value: changedValue
                }
            })
        );
    }

    dispatchModalClosedEvent () {
        this.dispatchEvent(
            new CustomEvent('reordermodalclosed', {
                composed: true,
                bubbles: true
            })
        );
    }

    handleCancelModal () {
        this.dispatchModalClosedEvent();
    }

    handleChange (event) {
        event.stopImmediatePropagation();
    }

    handleOk () {
        this.dispatchChangeEvent(this.reorderListBoxElement.value);
    }
}