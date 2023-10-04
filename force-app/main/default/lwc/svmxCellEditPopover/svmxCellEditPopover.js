import { LightningElement, track, api } from 'lwc';
import { cellFormatterByType, keyCodes, formatString, FocusState } from 'c/utils';
import { getRowSelectionIds } from 'c/runtimePubSub';

import labelButtonCancel from '@salesforce/label/c.Button_Cancel';
import labelButtonSave from '@salesforce/label/c.Button_Save';
import labelButtonApply from '@salesforce/label/c.Button_Apply';
import labelUpdateSelectedItems from '@salesforce/label/c.Message_UpdateSelectedItems';
import messageEnterValue from '@salesforce/label/c.Message_EnterValue';
import messageChooseValue from '@salesforce/label/c.Message_ChooseValue';

const i18n = {
    buttonCancel: labelButtonCancel,
    buttonSave: labelButtonSave,
    buttonApply: labelButtonApply,
    updateSelectedItems: labelUpdateSelectedItems,
    messageChooseValue,
    messageEnterValue,
};

const DELAY_UI_UPDATE = 200;

export default class SvmxCellEditPopover extends LightningElement {
    @track popoverOpen = false;

    @track error = null;

    _advModalOpen = false;
    _selectedRowIds;
    _updateMultiple = false;

    _initialValue;
    @api get initialValue () {
        return this._initialValue;
    }

    set initialValue (value) {
        this._initialValue = value;
        this._editValue = value;
    }

    // local storage for the value from the dynamic fields; will not get published until Save
    _editValue;
    _lastEditValue;
    @api get editValue () {
        return this._editValue;
    }

    updateEditValue (newValue) {
        this._lastEditValue = this._editValue;
        this._editValue = newValue;
    }

    fetchSelectedRowIds () {
        return getRowSelectionIds(this._meta.engineId, this._meta.childId)
    }

    get didValueChange () {
        return this._editValue !== this._initialValue && (this._initialValue || this._editValue);
    }

    get didValueChangeFromLast () {
        return this._editValue !== this._lastEditValue && (this._lastEditValue || this._editValue);
    }
    get isMultiEditEnabled () {
        this._selectedRowIds = this.fetchSelectedRowIds();
        return this._selectedRowIds && this._selectedRowIds.includes(this._fieldProps.rowId) &&
                this._selectedRowIds.length > 1 || false;
    }
    get numberOfSelectedRows () {
        return this._selectedRowIds.length;
    }

    _fieldProps = {};
    @api get fieldProps () {
        return this._fieldProps;
    }

    set fieldProps (proxyObject) {
        this._fieldProps = JSON.parse(JSON.stringify(proxyObject));
        const { meta, label } =  this._fieldProps;
        if (typeof meta === 'string') {
            this._meta = JSON.parse(meta);
        } else {
            this._meta = meta;
        }

        if (this._meta) {
            this._meta.debugLabel = label;
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
        return this._meta || {};
    }

    get cellClassnames () {
        const classes = [
            'svmx-cell-edit',
            'slds-cell-edit',
            'slds-grid',
            'slds-grid_align-spread',
        ];
        if (this.isTypeLookup) {
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

    get isReadOnly () {
        return !this.fieldProps.editable;
    }

    get isTypeLookup () {
        return this.fieldProps.type === 'xLookup';
    }

    get isTypeLookupAndHasValue () {
        return this.isTypeLookup && this.initialValue;
    }

    get isPlainCell () {
        return this.fieldProps.type !== 'xLookup' ||
            (this.fieldProps.type === 'xLookup' && !this.initialValue);
    }

    get isTypePicklist () {
        return this.fieldProps.type === 'xPicklist';
    }

    get isTypePicklistAndNotMultiPicklist () {
        return this.isTypePicklist && !this.meta.multiple;
    }

    get isTypeMultiPicklist () {
        return this.isTypePicklist && this.meta.multiple;
    }

    get isTypeTextarea () {
        return this.fieldProps.type === 'xTextarea';
    }

    get hasError () {
        return (this.error !== null);
    }

    get popoverStyle () {
        const top = this.template.querySelector("span").getBoundingClientRect().top;
        let left = this.template.querySelector("span").getBoundingClientRect().left;
        const right = this.template.querySelector("span").getBoundingClientRect().right;
        const popoverWidth = 320;
        const requiredPositionX = left + popoverWidth;

        if (
            requiredPositionX >
            (window.innerWidth || document.documentElement.clientWidth)
        ) {
            left = right - popoverWidth;
        }

        return `position:fixed;left:${left}px;top:${top}px;`;
    }

    get massEditCheckboxLabel () {
        return formatString(i18n.updateSelectedItems, this.numberOfSelectedRows);
    }

    focusState;
    connectedCallback () {
        this.focusState = new FocusState(DELAY_UI_UPDATE);
        this.focusState.onBlur(() => {
            this.respondToValueChange();
        });
    }

    handleChange (event) {
        let newValue, newLabel;
        if (event.detail) {
            newValue = event.detail.value;
            newLabel = event.detail.label;
        } else if (event.target) {
            newValue = event.target.value;
        }
        this.updateEditValue(newValue);
        this._editLabel = newLabel;

        this.validateModal();
    }

    handleItemSelect (event) {
        this.handleChange(event);

        if (this.didValueChangeFromLast && this._editValue != null) {
            if (!this.isTypeMultiPicklist && !this.isMultiEditEnabled) {
                this.respondToValueChange();
            }
        }
    }

    handleBlur () {
        if (!this.isMultiEditEnabled) {
            this.focusState.blur();
        }
    }

    handleFocus () {
        this.focusState.focus();
    }

    handleAdvanceModal (event) {
        if (event.detail) {
            this._advModalOpen = event.detail.value;
        }
    }

    handleClick () {
        if (this.fieldProps.editable) {
            this.popoverOpen = true;
        }

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.focusInputElement();
        }, 0);

        return false;
    }

    focusInputElement () {
        const inputElement = this.template.querySelector('lightning-textarea');
        if (inputElement) {
            inputElement.focus();
        }

        const inputLookupElement = this.template.querySelector('c-svmx-lookup');
        if (inputLookupElement && !this._editValue) {
            inputLookupElement.focus();
        }

        const inputPicklistElement = this.template.querySelector('c-combobox-by-record-type');
        if (inputPicklistElement) {
            inputPicklistElement.focus();
        }
    }

    closePopover () {
        this.popoverOpen = false;
    }

    finalizeValue () {
        if (!this.validateModal() || this.isMultiEditEnabled) {
            return;
        }

        // notify change to the datatable
        this.dispatchFieldChangeEvent(this._editValue, this._editLabel);
    }

    respondToValueChange () {
        if (this.didValueChange) {
            this.finalizeValue();
        }
        if (!this._advModalOpen)
            this.closePopover();
    }

    dispatchFieldChangeEvent (value, label, rowIds) {
        const eventToDispatch = new CustomEvent('dynamicfieldchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                rowId: rowIds || this._fieldProps.rowId,
                fieldName: this._fieldProps.fieldName,
                value,
                label
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

    handleApplyClick () {
        if (this._updateMultiple) {
            this.dispatchFieldChangeEvent(this._editValue, this._editLabel, this._selectedRowIds);
        } else {
            this.dispatchFieldChangeEvent(this._editValue, this._editLabel);
        }
        this._updateMultiple = false;
        this.closePopover();
    }

    handleKeyDown (event) {
        if (this._advModalOpen) {
            return;
        }

        if (event.keyCode === keyCodes.escape) {
            if (this.didValueChange) {
                this.dispatchFieldChangeEvent(this._editValue, this._editLabel);
            }

            this.closePopover();
        } else if (
            (this.isTypePicklist || this.isTypeLookup) &&
            (event.keyCode === keyCodes.enter || event.keyCode === keyCodes.tab)
        ) {
            this.closePopover();
        } else if (this.isTypeTextarea &&
                ((event.shiftKey && event.keyCode === keyCodes.enter) ||
                 event.keyCode === keyCodes.tab)) {
            this.finalizeValue();
            this.closePopover();
        }
    }

    handleCancelClick () {
        this.closePopover();
    }

    handleMassCheckboxChange (event) {
        this._updateMultiple = event.detail.checked;
    }
}