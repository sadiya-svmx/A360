import { LightningElement, track, api } from 'lwc';
import { cellFormatterByType } from 'c/utils';
import labelButtonCancel from '@salesforce/label/c.Button_Cancel';
import labelApply from '@salesforce/label/c.Button_Apply';
import messageEnterValue from '@salesforce/label/c.Message_EnterValue';
import messageChooseValue from '@salesforce/label/c.Message_ChooseValue';

const i18n = {
    buttonCancel: labelButtonCancel,
    buttonApply: labelApply,
    messageChooseValue,
    messageEnterValue,
};

export default class SvmxCellEditModal extends LightningElement {
    @track modalOpen = false;
    @api initialValue;

    @track error = null;

    // local storage for the value from the dynamic fields; will not get published until Save
    _editValue;
    _label

    _valueObject;
    @api
    get valueObject () {
        return this._valueObject;
    }

    set valueObject (newValueObject) {
        this._valueObject = newValueObject;
    }

    _fieldProps = {};
    @api
    get fieldProps () {
        return this._fieldProps;
    }

    set fieldProps (proxyObject) {
        this._fieldProps = JSON.parse(JSON.stringify(proxyObject));
        const { meta } =  this._fieldProps;
        if (typeof meta === "string") {
            this._meta = JSON.parse(meta);
        } else {
            this._meta = meta;
        }
    }

    get recordTypeId () {
        return this.isTypePicklist && this._fieldProps.recordTypeId;
    }

    get objectFieldApiName () {
        return this.isTypePicklist && `${this._meta.objectApiName}.${this._meta.fieldApiName}`;
    }

    get controllerValue () {
        return this.isTypePicklist && this._fieldProps.controllerValue;
    }

    get controllerFieldName () {
        return this._meta.controllerFieldName;
    }

    get defaultRecordTypeId () {
        return this._meta.defaultRecordTypeId;
    }

    get meta () {
        return this._meta;
    }

    get cellClassnames () {
        const classes = [
            'svmx-cell-edit',
            'slds-cell-edit',
            'slds-grid',
            'slds-grid_align-spread',
        ];
        if (this.isTypeLookupAndHasObject || this.isTypeLookupAndNoObject) {
            classes.push('svmx-cell-edit__lookup-spacing');
        } else {
            classes.push('slds-p-around_x-small');
        }
        return classes.join(' ');
    }

    get formElementClasses () {
        const classes = [
            'slds-form-element',
        ];
        if (this.hasError) {
            classes.push('slds-has-error');
        }
        return classes.join(' ');
    }

    get formattedDisplayValue () {
        return cellFormatterByType(this._fieldProps)(this.initialValue);
    }

    get i18n () {
        return i18n;
    }

    get isEditable () {
        return this.fieldProps.editable;
    }

    get isTypeLookup () {
        return this.fieldProps.type === 'xLookup';
    }

    get isTypeLookupAndHasObject () {
        return this.fieldProps.type === 'xLookup' && typeof this._valueObject === 'object';
    }

    get isTypeLookupAndNoObject () {
        return this.fieldProps.type === 'xLookup' && this.initialValue;
    }

    get isTypePicklist () {
        return this.fieldProps.type === 'xPicklist';
    }

    get isTypeTextarea () {
        return this.fieldProps.type === 'xTextarea';
    }

    get hasError () {
        return (this.error !== null);
    }

    @api
    get editValue () {
        return this._editValue;
    }

    handleChange (event) {
        if (event.detail) {
            this._editValue = event.detail.value;
            this._label = event.detail.label;
        } else if (event.target) {
            this._editValue = event.target.value;
        }

        this.validateModal();
    }

    handleClick () {
        if (this.fieldProps.editable) {
            this.modalOpen = true;
        }
        return false;
    }

    handleModalClose () {
        this.modalOpen = false;
    }

    handleModalSave () {
        if (!this.validateModal()) {
            return;
        }

        // close the modal.
        this.modalOpen = false;

        // notify change to the datatable
        const eventToDispatch = new CustomEvent('dynamicfieldchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                rowId: this._fieldProps.rowId,
                value: this._editValue,
                fieldName: this._fieldProps.fieldName
            }
        });
        this.dispatchEvent(eventToDispatch);
    }

    validateModal () {
        if (this.fieldProps.required && !this._editValue) {
            this.error = this.isTypeTextarea ? i18n.messageEnterValue : i18n.messageChooseValue;
            return false;
        }
        return true;
    }
}