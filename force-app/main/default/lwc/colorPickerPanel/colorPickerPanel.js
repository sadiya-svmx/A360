import labelCancelButton from '@salesforce/label/c.Btn_Cancel';
import labelCustomTab from '@salesforce/label/c.Label_Custom';
import labelDefaultTab from '@salesforce/label/c.Label_Default';
import labelDoneButton from '@salesforce/label/c.Button_Done';
import { LightningElement, api, track } from 'lwc';
import { classSet, keyCodes } from 'c/utils';

const i18n = {
    cancelButton: labelCancelButton,
    customTab: labelCustomTab,
    defaultTab: labelDefaultTab,
    doneButton: labelDoneButton,
};

const DEFAULT_COLOR = '#000000';
export default class LightningColorPickerPanel extends LightningElement {
    @api currentColor;

    @track _isCustomTabActive = false;
    @track _selectedColor = null;

    connectedCallback () {
        this._selectedColor = this.currentColor || DEFAULT_COLOR;
    }

    get i18n () {
        return i18n;
    }

    get computedClassDefault () {
        return classSet({
            'slds-tabs_default__item': true,
            'slds-is-active': !this._isCustomTabActive,
        }).toString();
    }

    get computedClassCustom () {
        return classSet({
            'slds-tabs_default__item': true,
            'slds-is-active': this._isCustomTabActive,
        }).toString();
    }

    get ariaSelectedDefault () {
        return !this._isCustomTabActive.toString();
    }

    get ariaSelectedCustom () {
        return this._isCustomTabActive.toString();
    }

    handleTabChange (event) {
        event.preventDefault();
        const tabElement = event.currentTarget;
        if (tabElement.classList.contains('slds-is-active')) {
            return;
        }
        this._isCustomTabActive = tabElement.title !== i18n.defaultTab;
    }

    handleUpdateSelectedColor (event) {
        this._selectedColor = event.detail.color;
    }

    dispatchUpdateColorEventWithColor (color) {
        this.dispatchEvent(
            new CustomEvent('updatecolor', {
                composed: true,
                bubbles: true,
                detail: { color },
            })
        );
    }

    handleDoneClick () {
        this.dispatchUpdateColorEventWithColor(this._selectedColor);
    }

    handleCancelClick () {
        this.dispatchUpdateColorEventWithColor(this.currentColor);
    }

    handleKeydown (event) {
        if (event.keyCode === keyCodes.escape) {
            event.preventDefault();
            this.dispatchUpdateColorEventWithColor(this.currentColor);
        } else if (
            event.shiftKey &&
            event.keyCode === keyCodes.tab &&
            event.srcElement.dataset.id === 'color-anchor'
        ) {
            event.preventDefault();
            this.template.querySelector('button[name="done"]').focus();
        } else if (
            !event.shiftKey &&
            event.keyCode === keyCodes.tab &&
            event.srcElement.name === 'done'
        ) {
            event.preventDefault();
            this.template
                .querySelector('lightning-color-picker-custom')
                .focus();
        }
    }
}