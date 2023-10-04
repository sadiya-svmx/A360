import { isSalesforceId, StaticallyComparable } from 'c/utils';

export default class SelectionModelController extends StaticallyComparable {
    _didValueChange = false;

    // === PROPERTY: _valueLDS ===
    _valueLDS;

    // === PROPERTY: _valueApex ===
    _valueApex;

    // === PROPERTY: value ===
    // Lookup's selected record Id
    get value () {
        return this._valueLDS || this._valueApex || null;
    }

    set value (value) {
        this.setValue(value);
    }

    // === METHOD: setValue ===
    setValue (value) {
        // If the supplied value is not a record Id, attempt to resolve it to a record Id
        // by looking for a record in the target object whose target label matches the current value
        if (value && !isSalesforceId(value)) {
            this.mc('utils').resolveLookupRecordByName(value);
        } else {
            // Lookup field initial value is set in many ways, consider all falsy values to be ~=
            this._didValueChange = value !== this.value && (value || this.value);

            // Switch between wire adapters depending on object support availability
            if (this.mc('schema').isTargetObjectUiSupported) {
                this._valueLDS = value;
                this._valueApex = undefined;
            } else {
                this._valueLDS = undefined;
                this._valueApex = value;
            }

            if (!this.value) {
                this.selectionRecord = null;
            }
        }
    }

    setValueMultiAdd (value) {
        if (value && value.length > 0) {
            this.mc('utils').fireChangeEvent(value);
        }
    }


    // === PROPERTY: hasSelectionAndNotReadOnly ===
    _hasSelection = false;
    get hasSelectionAndNotReadOnly () {
        return this._hasSelection && !this.mc('staticConfig').readOnly;
    }

    // === PROPERTY: hasSelectionAndReadOnly ===
    get hasSelectionAndReadOnly () {
        return this._hasSelection && this.mc('staticConfig').readOnly && !this.mc('ui').isInCell;
    }

    // === PROPERTY: hasSelectionAndNotInCell ===
    get hasSelectionAndNotInCell () {
        return this.hasSelectionAndNotReadOnly && !this.mc('ui').isInCell;
    }

    get hasSelectionAndInCell () {
        return this._hasSelection && this.mc('ui').isInCell;
    }

    // === PROPERTY: selectionRecord ===
    // Partial record data of the selected record
    _selectionRecord;
    get selectionRecord () {
        return this._selectionRecord;
    }

    set selectionRecord (value) {
        this._selectionRecord = value;
        if (this.selectionRecord) {
            this.selectionLabel =
                this.mc('utils').generateDisplayLabelForRecord(this.selectionRecord).primary;
            this._hasSelection = true;
        } else {
            this.selectionLabel = '';
            this._hasSelection = false;
        }

        this.mc('ui').closeDropdown();
        if (this._didValueChange) {
            // Notify parent components of newly selected record (after selected
            // record details have been retrieved)
            this.mc('utils').fireChangeEvent(this.value);

            this.mc('ui').reportValidity();
        }
    }

    // === PROPERTY: selectionLabel ===
    _selectionLabel;
    get selectionLabel () {
        return this._selectionLabel;
    }

    set selectionLabel (value) {
        this._selectionLabel = value;
    }
}