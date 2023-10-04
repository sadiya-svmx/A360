/* eslint-disable no-unused-expressions */
import { loadStyle } from 'lightning/platformResourceLoader';
import svmxLookupResource from '@salesforce/resourceUrl/svmxLookup';

import { pullRuntimeFieldValueChange, HEADER } from 'c/runtimePubSub';
import {
    PUBSUB_KEYS, VARIANT, isElementOverflowingViewport, StaticallyComparable,
    classSet, FocusState
} from 'c/utils';

import labelRequired from '@salesforce/label/c.AltText_Required';
import labelContains from '@salesforce/label/c.Label_Contains';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelContextName from '@salesforce/label/c.Label_ContextName';

import errorLabelInvalidFieldApi from '@salesforce/label/c.Error_InvalidFieldApi';
import errorLabelFieldIsNotAReference from '@salesforce/label/c.Error_FieldIsNotAReference';
import errorLabelNoRecordWithFieldEqualTo from '@salesforce/label/c.Error_NoRecordWithFieldEqualTo';
import errorLabelMessageNoUserFieldPermission from
    '@salesforce/label/c.Message_NoUserFieldPermission';

const i18n = {
    required: labelRequired,
    contains: labelContains,
    valueMissing: labelEnterValue,
    searchPlaceholder: labelSearchPlaceholder,
    contextName: labelContextName,
    invalidFieldApi: errorLabelInvalidFieldApi,
    notAReference: errorLabelFieldIsNotAReference,
    noRecordWithFieldEqualTo: errorLabelNoRecordWithFieldEqualTo,
    noUserFieldPermission: errorLabelMessageNoUserFieldPermission
};

const DELAY_UI_UPDATE = 300;

export default class UiModelController extends StaticallyComparable {
    // === PROPERTY: isInCell ===
    isInCell = false;

    // === PROPERTY: isConnected ===
    isConnected = false;

    // === PROPERTY: apiInProgress ===
    apiInProgress = false;

    // === PROPERTY: i18n ===
    get i18n () {
        return i18n;
    }

    // === PROPERTY: _helpMessage ===
    _helpMessage = null;

    // === PROPERTY: _inputHasFocus ===
    _inputHasFocus = false;

    // === PROPERTY: _lookupSearch ===
    _lookupSearch = false;

    // === PROPERTY: _cancelBlur ===
    _cancelBlur = false;

    // === PROPERTY: loadStylePromise ===
    loadStylePromise;

    // === PROPERTY: hasHelpMessage ===
    get hasHelpMessage () {
        return this._helpMessage !== null && !this.mc('results')._dropdownVisible;
    }

    // === PROPERTY: helpMessage ===
    get helpMessage () {
        return this._helpMessage;
    }

    // === METHOD: searchInputElem ===
    getSearchInputElem () {
        return this.getComponent().template.querySelector('.svmx-lookup_search-input');
    }

    // === METHOD: focusSearchInput ===
    focusSearchInput () {
        this.getSearchInputElem()?.focus();
    }

    // === METHOD: clickSearchInput ===
    clickSearchInput () {
        this.getSearchInputElem()?.click();
    }

    // === METHOD: blurSearchInput ===
    blurSearchInput () {
        this.getSearchInputElem()?.blur();
    }

    // === METHOD: getAdvancedSearchModal ===
    getAdvancedSearchModal () {
        return this.getComponent().template.querySelector('c-lookup-advanced-search-modal');
    }

    // === METHOD: focusAdvancedSearchModal ===
    focusAdvancedSearchModal () {
        this.getAdvancedSearchModal()?.focus();
    }

    // === PROPERTY: allowInput ===
    get allowInput () {
        return !this.isInCell && !this.mc('selection')._hasSelection;
    }

    // === PROPERTY: computedFormClass ===
    get computedFormClass () {
        return classSet({
            'svmx-lookup-element': true,
            'slds-form-element': true,
            'svmx-lookup_form-element': true,
            'slds-form-element_stacked': !this.mc('staticConfig').multiple &&
                this.mc('staticConfig').variant !== VARIANT.LABEL_HIDDEN,
            'svmx-lookup_multiple': this.mc('staticConfig').multiple,
            'slds-has-error': this.hasHelpMessage
        }).toString();
    }

    // === PROPERTY: computedLabelClass ===
    get computedLabelClass () {
        const classes = [
            'slds-form-element__label',
        ];

        if (this.mc('staticConfig').variant === VARIANT.LABEL_HIDDEN) {
            classes.push('slds-assistive-text');
        }

        return classes.join(' ');
    }

    // === PROPERTY: computedTriggerClass ===
    get computedTriggerClass () {
        const classes = [
            'svmx-lookup',
            'slds-combobox',
            'slds-dropdown-trigger',
            'slds-dropdown-trigger_click',
            'slds-has-focus'
        ];

        if (this.mc('results')._dropdownVisible) {
            classes.push('slds-is-open');
        }

        if (this.mc('staticConfig').nestedPopover) {
            classes.unshift('svmx-lookup_popover');
        }

        return classes.join(' ');
    }

    // === PROPERTY: computedPillClass ===
    get computedPillClass () {
        const classes = ['svmx-lookup_selection', 'slds-pill_container'];

        if (this.mc('staticConfig').disabled) {
            classes.push('svmx-lookup_selection_disabled');
        }

        return classes.join(' ');
    }

    // === PROPERTY: computedDropDownListClass ===
    get computedDropDownListClass () {
        const classes = ['slds-dropdown'];

        if (this.mc('staticConfig').nestedPopover) {
            classes.unshift('svmx-dropdown');
        }

        classes.push('slds-dropdown_length-with-icon-5');

        if (!this.mc('staticConfig').nestedPopover) {
            classes.push('slds-dropdown_fluid');
        }

        return classes.join(' ');
    }

    // === METHOD: handleComponentConnected ===
    handleComponentConnected () {
        this.mc('utils').componentGetter = () => this.getComponent();
        this.mc('debug').initializeDebugger();
        this.isConnected = true;
        this.mc('staticConfig')._tabName = this.mc('staticConfig')._tabName ||
            pullRuntimeFieldValueChange({
                engineId: this.mc('staticConfig').engineId,
                whichSection: HEADER,
                fieldName: PUBSUB_KEYS.ACTIVE_TAB
            });

        this.focusState = new FocusState(DELAY_UI_UPDATE);
        this.focusState.onFocus(() => {
            this.clickSearchInput();
        });

        this.focusState.onBlur(() => {
            this._inputHasFocus = false;
            this.mc('utils').dispatchCloseEvent();
            this.mc('ui').closeDropdown();
        });
    }

    // === METHOD: handleComponentDisconnected ===
    handleComponentDisconnected () {
        this.mc('utils').componentGetter = () => null;
        this.mc('debug').unsubscribeFromDebugModeUpdates();
        this.isConnected = false;
    }

    // === METHOD: handleComponentRendered ===
    handleComponentRendered () {
        if (this.mc('staticConfig').nestedPopover) {
            const inputElement =
                this.getComponent().template.querySelector('.svmx-pill');
            if (inputElement && !inputElement.focused) {
                inputElement.focus();
            }

            if (this.mc('results')._dropdownVisible) {
                this.getComputedDropdownClass();
            }
        }

        Promise.all([loadStyle(this.getComponent(), svmxLookupResource)])
            .then(() => {})
            .catch(error => {
                console.error('staticresource for svmxLookup load error', error);
            });
    }

    // === METHOD: checkValidity ===
    checkValidity () {
        const requiredButNoValue = (
            !this.mc('staticConfig').disabled
            && this.mc('staticConfig').required
            && !this.mc('selection').value
        );
        return requiredButNoValue ? false : true;
    }

    // === METHOD: reportValidity ===
    reportValidity () {
        const valid = this.checkValidity();
        this._helpMessage = valid ? null : this.i18n.valueMissing;
        return valid;
    }

    // === METHOD: getComputedDropdownClass ===
    getComputedDropdownClass () {
        const dropdownMenu =
            this.getComponent().template.querySelector('div[data-dropdown-element]');

        const lookupElement =
            this.getComponent().template.querySelector('.svmx-lookup-element');

        if (dropdownMenu && lookupElement) {
            const left = lookupElement.getBoundingClientRect().left || 0;
            dropdownMenu.style.setProperty('--svmx-dropdown-transformLeft', left + 'px');

            if (isElementOverflowingViewport(dropdownMenu) ||
                this.mc('results')._dropdownBottomUp
            ) {
                this.mc('results')._dropdownBottomUp = true;
                const top = lookupElement.getBoundingClientRect().top || 0;
                const height = dropdownMenu.offsetHeight;

                dropdownMenu.style.setProperty('--svmx-dropdown-transformTop', top-height-5 + 'px');
            } else {
                const bottom = lookupElement.getBoundingClientRect().bottom || 0;
                dropdownMenu.style.setProperty('--svmx-dropdown-transformTop', bottom + 'px');
            }
        }
    }

    // === METHOD: computedListboxOptionClass ===
    computedListboxOptionClass (option = {}) {
        const classes = [
            'slds-media',
            'slds-listbox__option',
            'slds-listbox__option_entity',
            'slds-listbox__option_has-meta'
        ];

        if (!option.secondaryLabel && !option.relatedLabel) {
            classes.push('slds-media_center');
        }

        return classes.join(' ');
    }

    // === METHOD: handleSearchTermClick ===
    handleSearchTermClick () {
        if (this.mc('staticConfig').disabled) return;
        this.mc('results')._dropdownVisible = true;
        this.mc('search').resetSearchRequest();
        this.mc('results').refreshSearchResults();
    }

    // === METHOD: handleSearchTermChange ===
    handleSearchTermChange (event) {
        this.mc('search').searchTerm = event.target.value;
    }

    // === METHOD: handleMobileSearchCommit ===
    handleMobileSearchCommit (event) {
        if (!event.target.value) {
            // Value was just cleared
            this.handleRemovePill();
        } else {
            this.handleSearchTermChange(event);
        }
    }

    // === METHOD: handleDropdownMouseLeave ===
    handleDropdownMouseLeave () {
        if (!this._inputHasFocus) {
            this.closeDropdown();
        }
    }

    // === METHOD: handleDropdownMouseDown ===
    handleDropdownMouseDown (event) {
        const mainButton = 0;
        if (event.button === mainButton) {
            this._lookupSearch = true;
        }
    }

    // === METHOD: handleRootBlur ===
    handleRootBlur () {
        this.focusState.blur();
    }

    // === METHOD: handleRootFocus ===
    handleRootFocus () {
        this.focusState.focus();
    }

    // === METHOD: handlePillFocus ===
    handlePillFocus () {

    }

    // === METHOD: handleBlur ===
    handleBlur () {

    }

    // === METHOD: handleFocus ===
    handleFocus () {
        this._inputHasFocus = true;
        this.mc('advancedSearch').setAdvanceSearchModal(false);
    }

    // === METHOD: closeDropdown ===
    closeDropdown () {
        this.mc('results')._dropdownVisible = false;
    }

    // === METHOD: handleSelect ===
    handleSelect (event) {
        this.mc('selection').setValue(event.currentTarget.dataset.id);
    }

    // === METHOD: handleRemovePill ===
    handleRemovePill () {
        if (this.mc('staticConfig').disabled) return;
        this.mc('search').searchTerm = '';
        this.mc('selection').setValue('');

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.focusSearchInput();
            this.clickSearchInput();
        }, 0);
    }
}