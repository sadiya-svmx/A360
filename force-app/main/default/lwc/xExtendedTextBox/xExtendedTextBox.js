import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    copyToClipboard,
    isUndefinedOrNull,
    normalizeBoolean } from 'c/utils';
import lblCopytoClipboard from '@salesforce/label/c.Label_CopyToClipboard';
import errorCopyToClipboardUnsupported from '@salesforce/label/c.Error_CopyToClipboardUnsupported';
import copytoClipboardSuccessMsg from '@salesforce/label/c.Message_CopytoClipboardSuccess';

const i18n = {
    lblCopytoClipboard: lblCopytoClipboard,
    errorCopyToClipboardUnsupported: errorCopyToClipboardUnsupported,
    copytoClipboardSuccessMsg: copytoClipboardSuccessMsg
};


export default class xExtendedTextBox extends LightningElement {

    @api
    get editable () {
        return this._editable || false;
    }

    set editable (value) {
        this._editable = normalizeBoolean(value);
    }

    @api
    maxLength () {
        const element = this.querySelector('lightning-input');
        if (element) {
            return element.maxLength;
        }
        return 0;
    }

    @api
    checkValidity () {
        const element = this.querySelector('lightning-input');
        if (element) {
            return element.checkValidity ();
        }
        return false;
    }

    @api
    reportValidity () {
        const element = this.querySelector('lightning-input');
        if (element) {
            return element.reportValidity ();
        }
        return false;
    }

    _value;
    @api
    get value () {
        let valueTobeCopied = this._value;
        if (isUndefinedOrNull(this._value) || this._value ==='' || this.editable) {
            const element = this.querySelector('lightning-input');
            if (element) {
                valueTobeCopied = element.value;
            }
        }
        return valueTobeCopied;
    }

    set value (val) {
        this._value = val;
    }
    get i18n () {
        return i18n;
    }

    get computeSize () {
        return this.editable ? 'large' : 'small';
    }

    get computeClass () {
        return this.editable ?'x-extended-texbox-icon_align' : 'slds-float_right';
    }

    showToastMsg (issuccess) {
        const evt = new ShowToastEvent({
            title: "",
            message: issuccess?i18n.copytoClipboardSuccessMsg:i18n.errorCopyToClipboardUnsupported,
            variant: issuccess?'success':'error',
            mode: "pester"
        });
        this.dispatchEvent(evt);
    }

    handleClick () {
        let valueTobeCopied = this.value;
        if (isUndefinedOrNull(this.value) || this.value ==='') {
            const element = this.querySelector('lightning-input');
            if (element) {
                valueTobeCopied = element.value;
            }
        }
        copyToClipboard(valueTobeCopied).
            then(()=>{this.showToastMsg(true)},
                ()=>{this.showToastMsg(false)});
    }
}