import { LightningElement, api, track } from 'lwc';
import {
    normalizeBoolean,
    isEmptyString,
    VARIANT,
    normalizeVariant,
    isElementOverflowingViewport,
    classListMutation,
    IS_MOBILE_DEVICE
} from 'c/utils';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelOptionsSelected from '@salesforce/label/c.Combo_OptionsSelected';
import labelPlaceholder from '@salesforce/label/c.Combo_Placeholder';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelNone from '@salesforce/label/c.Label_None';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import mobileTemplate from './comboboxMobile.html';
import desktopTemplate from './combobox.html';

const i18n = {
    required: labelRequired,
    none: labelNone,
    placeholder: labelPlaceholder,
    optionsSelected: labelOptionsSelected,
    loadingText: labelLoading,
    searchPlaceholder: labelSearchPlaceholder,
    valueMissing: labelEnterValue
};

const MULTIVALUE_SEPARATOR = ';';
const NONE = 'NONE';
const DELAY_ALLOWBLUR_INTERVAL = 400;
const DELAY_BLUR_INTERVAL = 300;

export default class Combobox extends LightningElement {
    static delegatesFocus = true;
    @track _disabled = false;
    @track _readOnly = false;
    @track _dropdownVisible = false;
    @track _fieldLevelHelp = '';
    @track _hasDropdownOpened = false;
    @track _helpMessage;
    @track _multiple = false;
    @track _filterable = false;
    @track _required = false;
    @track _showDropdownActivityIndicator = false;
    @track _variant;
    @track _items = [];
    @track _filteredItems = [];
    @track computedDropDownClass = 'slds-dropdown slds-dropdown_fluid';

    @api nestedPopover = false;

    _connected = false;
    _dropdownCalculated = false;
    _searchInputValue;
    _secondaryValue= '';
    _valueLabel = '';

    connectedCallback () {
        this.classList.add('slds-form-element');
        this._connected = true;
        this.updateClassList();

        this.updateItems(this.items);

        if (this.items) {
            this.updateSelectedItems();
        }
    }

    render () {
        return IS_MOBILE_DEVICE ? mobileTemplate : desktopTemplate;
    }

    disconnectedCallback () {
        this._connected = false;
    }

    renderedCallback () {
        if (!this._dropdownCalculated && this._dropdownVisible) {
            this.getComputedDropdownClass();
            this._dropdownCalculated = true;
        }
    }

    get i18n () {
        return i18n;
    }

    @api hideNoneOption = false;

    @api
    get disabled () {
        return this._disabled || false;
    }

    set disabled (value) {
        this._disabled = normalizeBoolean(value);


        if (this._disabled && this._dropdownVisible) {
            this.closeDropdown();
        }
    }

    @api
    get readOnly () {
        return this._readOnly || false;
    }

    set readOnly (value) {
        this._readOnly = normalizeBoolean(value);


        if (this._readOnly && this._dropdownVisible) {
            this.closeDropdown();
        }
    }

    @api
    get fieldLevelHelp () {
        return this._fieldLevelHelp;
    }

    set fieldLevelHelp (value) {
        this._fieldLevelHelp = value;
    }

    @api
    get filterable () {
        return this._filterable;
    }

    set filterable (value) {
        this._filterable = normalizeBoolean(value);
    }

    @api
    get items () {
        return this._unprocessedItems || [];
    }

    set items (newItems) {
        this.verifyItems(newItems);
        this._unprocessedItems = newItems;

        if (this._connected) {
            this.updateItems(newItems);
            this.updateSelectedItems();

            if (this._hasDropdownOpened) {

                if (this._dropdownVisible) {
                    if (this.isDropdownEmpty) {
                        this.closeDropdown();
                    }
                    else {
                        this.scrollFirstSelectedItemIntoView();
                    }
                }
            }

            if (this.shouldOpenDropDown) {
                this.openDropdownIfNotEmpty();
            }
        }
    }

    @api label;
    @api messageWhenValueMissing;

    @api
    get multiple () {
        return this._multiple;
    }

    set multiple (value) {
        this._multiple = normalizeBoolean(value);
    }

    @api placeholder = i18n.placeholder;

    @api
    checkValidity () {
        return !(!(this.disabled || this.readOnly) && this.required && isEmptyString(this.value));
    }

    @api
    reportValidity () {
        const valid = this.checkValidity();
        this.classList.toggle('combo-has-error', !valid);
        this._helpMessage = (valid)
            ? null
            : (isEmptyString(this.messageWhenValueMissing))
                ? i18n.valueMissing
                : this.messageWhenValueMissing;
        return valid;
    }

    @api
    get required () {
        return this._required;
    }

    set required (value) {
        this._required = normalizeBoolean(value);
    }

    @api showInputActivityIndicator = false;

    @api
    get showDropdownActivityIndicator () {
        return this._showDropdownActivityIndicator;
    }

    set showDropdownActivityIndicator (value) {
        this._showDropdownActivityIndicator = normalizeBoolean(value);

        if (this._connected) {
            if (this._showDropdownActivityIndicator) {
                if (this.shouldOpenDropDown) {
                    this.openDropdownIfNotEmpty();
                }
            } else if (this._dropdownVisible && this.isDropdownEmpty) {
                this.closeDropdown();
            }
        }
    }

    get shouldOpenDropDown () {
        return (
            !this._disabled &&
            this._inputHasFocus &&
            this._requestedDropdownOpen
        );
    }

    @api
    get variant () {
        return this._variant || VARIANT.LABEL_HIDDEN;
    }

    set variant (value) {
        this._variant = normalizeVariant(value);
        this.updateClassList();
    }

    transformSelectedValue () {
        return this.selectedValue === NONE ? null : this.selectedValue;
    }

    @api
    get value () {
        const value = this.transformSelectedValue();
        return value;
    }

    set value (newValue) {
        if (newValue !== this.selectedValue) {
            this.selectedValue = newValue === null ? NONE : newValue;
            if (this._connected && this.items) {
                this.updateSelectedItems();
            }
        }
    }

    @api
    get secondary () {
        return this._secondaryValue;
    }

    @api
    get valueLabel () {
        return this._valueLabel;
    }

    get isLabelHidden () {
        return this.variant === VARIANT.LABEL_HIDDEN;
    }

    get computedInputValue () {

        const selItems = this.selectedItems;

        const count = selItems.length;

        switch (count) {
            case 0:
                return '';
            case 1:
                return selItems[0].label;
            default:
                return count + ' ' + i18n.optionsSelected;
        }
    }

    get computedLabelClass () {
        let css = 'slds-form-element__label';

        if (this.isLabelHidden) {
            css += ' slds-assistive-text';
        }

        return css;
    }

    get computedComboboxClass () {
        return this.nestedPopover?'slds-grid':'';
    }

    getComputedDropdownClass () {
        const dropdownMenu = this.template.querySelector('div[data-dropdown-element]');
        if (dropdownMenu ) {
            dropdownMenu.classList.remove('slds-dropdown_bottom');
            if (isElementOverflowingViewport(dropdownMenu)) {
                dropdownMenu.classList.add('slds-dropdown_bottom');
            }
        }
    }

    get computedDropdownTriggerClass () {
        const cssClasses = [
            'svmx-combobox',
            'slds-combobox',
            'slds-dropdown-trigger',
            'slds-dropdown-trigger_click'
        ];

        if (this._dropdownVisible) {
            cssClasses.push('slds-is-open');
        }

        return cssClasses.join(' ');
    }

    get computedInputClass () {
        const cssClasses = [
            'slds-input',
            'slds-combobox__input',
            'combo-input'
        ];

        if (this.showInputActivityIndicator) {
            cssClasses.push('slds-input-has-icon_group-right');
        }

        return cssClasses.join(' ');
    }

    get computedListBoxClass () {
        const cssClasses = ['listbox-container'];

        if (this._filterable) {
            cssClasses.push('slds-border_top');
        }

        return cssClasses.join(' ');
    }

    get computedAriaExpanded () {
        return this._dropdownVisible ? 'true' : 'false';
    }

    get filteredItems () {
        return this._filteredItems;
    }

    get inputElement () {
        return this.template.querySelector('input[type=text]');
    }

    get isDropdownEmpty () {
        return (
            !this.showDropdownActivityIndicator &&
            (!Array.isArray(this.items) || this.items.length === 0)
        );
    }

    get selectedItems () {
        return this._items.filter(item => item.highlight);
    }

    get selectedPills () {
        const pills = this.selectedItems.map(item => {
            return {
                label: item.label,
                name: item.value
            };
        });
        return pills;
    }

    get showPills () {
        return !IS_MOBILE_DEVICE &&
            this.multiple && (this.selectedPills && this.selectedPills.length > 0);
    }

    get valueAsArray () {
        const selectedValueExists = (this.selectedValue && this.selectedValue.trim().length > 0);

        if (this.multiple && selectedValueExists) {
            return this.selectedValue.split(MULTIVALUE_SEPARATOR);
        }

        if (selectedValueExists) {
            return [this.selectedValue];
        }

        return [];

    }

    resetCancelBlur () {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(()=> {
            this.allowBlur();
        }, DELAY_ALLOWBLUR_INTERVAL);
    }

    allowBlur () {
        this._cancelBlur = false;
    }

    cancelBlur () {
        this._cancelBlur = true;
    }

    clearSelectedItems () {
        // eslint-disable-next-line no-return-assign
        this._items.forEach(item => item.highlight = false);
    }

    closeDropdown () {
        if (!this._dropdownVisible) {
            return;
        }

        this._dropdownVisible = false;

        // We should be dispatching a blur when the dropdown closes
        this.dispatchEvent(
            new CustomEvent('blur', {
                composed: true,
                bubbles: true,
            })
        );
    }

    dispatchCloseEvent () {
        this.dispatchEvent(
            new CustomEvent('close', {
                composed: true,
                bubbles: true,
            })
        );
    }


    fireChangeEvent () {
        const value = this.transformSelectedValue();
        const secondary = this._secondaryValue;
        const valueLabel = this._valueLabel;
        this.dispatchEvent(
            new CustomEvent('change', {
                composed: true,
                bubbles: true,
                detail: {
                    value,
                    secondary,
                    valueLabel
                },
            })
        );
    }

    doBlurAction () {
        if (this._cancelBlur) {
            return;
        }
        this.closeDropdown();
        this.dispatchCloseEvent();
    }

    handleBlur () {
        this._inputHasFocus = false;

        if (this.nestedPopover) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.doBlurAction();
            }, DELAY_BLUR_INTERVAL);
        } else {
            this.doBlurAction();
        }
    }

    handleFocus () {
        this._inputHasFocus = true;
    }

    handleSearchInputFocus (event) {
        this._searchInputHasFocus = true;
        event.stopPropagation();
        this.cancelBlur();
    }

    handleSearchInputBlur (event) {
        this._searchInputHasFocus = false;
        this.allowBlur();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.closeDropdown();
            this._searchInputValue = '';
            this.setFilterItems();
        }, DELAY_BLUR_INTERVAL);
        event.stopPropagation();
    }

    handleInputSelect (event) {
        event.stopPropagation();
    }

    handleListboxScroll (event) {
        event.stopPropagation();
    }

    handleDropdownMouseLeave () {
        if (!this._inputHasFocus && !this._searchInputHasFocus) {
            this.allowBlur();
            this.closeDropdown();
            this.dispatchCloseEvent();
        }
    }

    handleDropdownMouseDown (event) {
        const mainButton = 0;
        if (event.button === mainButton)  {
            this.cancelBlur();
        }
    }

    handleDropdownClick (event) {
        event.stopPropagation();
        event.preventDefault();
    }

    handlePillRemove (event) {
        if (this.disabled || this.readOnly) return;

        // currently only the index is being return
        const indexRemoved = event.detail.index;

        const itemRemoved = this.selectedItems[indexRemoved];

        const itemToUnHighlight = this._items.find(item => item.value === itemRemoved.value);

        if (itemToUnHighlight) {
            itemToUnHighlight.highlight = false;
        }

        this.cancelBlur();
        this.resetCancelBlur();
        this.updateSelectedValue();
        this.updateSelectedItems();
        this.fireChangeEvent();
    }

    handleOptionClick (event) {
        event.stopPropagation();
        event.preventDefault();

        if (event.currentTarget
            && event.currentTarget.getAttribute('data-value')) {

            this.selectItem(event.currentTarget.getAttribute('data-value'));
            this._searchInputValue = '';
            this.setFilterItems();
        }

    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        event.stopPropagation();

        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this._searchInputValue = searchKey;
            this.setFilterItems();
        }, 300);
    }

    handleTriggerClick (event) {
        event.stopPropagation();

        if (this._cancelBlur) return;

        this.allowBlur();

        if (this._disabled) {
            return;
        }

        if (this._dropdownVisible) {
            this.closeDropdown();
        } else {
            this.openDropdownIfNotEmpty();
        }

        this.inputElement.focus();
    }

    openDropdownIfNotEmpty () {
        if (this._dropdownVisible) {
            return;
        }

        // Do not open if there's nothing to show in the dropdown
        if (this.isDropdownEmpty) {
            this._requestedDropdownOpen = true;
            return;
        }

        if (!this._hasDropdownOpened) {
            this._hasDropdownOpened = true;
        }

        this._requestedDropdownOpen = false;
        this._dropdownVisible = true;
        this._dropdownCalculated = false;

        this.scrollFirstSelectedItemIntoView();
    }

    processItem (item, selectedValues) {
        const itemCopy = {};

        // Supported item properties:
        // 'highlight' (boolean): Whether to highlight the item when dropdown opens
        // 'label': text to display
        // 'secondary': sub-text to display
        // 'value': value associated with the option

        itemCopy.label = item.label;
        itemCopy.secondary = item.secondary;
        itemCopy.value = item.value;
        itemCopy.iconName = item.iconName;

        itemCopy.highlight = (selectedValues && selectedValues.includes(item.value));

        let css = 'svmx-picklist_item slds-media slds-listbox__option ';

        if (itemCopy.secondary) {
            css += 'slds-listbox__option_entity slds-media_center';
        } else {
            css += 'slds-listbox__option_plain slds-media_small';
        }

        css += (itemCopy.highlight) ? ' slds-is-selected' : '';

        itemCopy.containerCss = css;

        return itemCopy;
    }

    findItemElementByValue (value) {
        return this.template.querySelector(`[data-value="${value}"]`);
    }

    scrollFirstSelectedItemIntoView () {
        const selectedValues = this.valueAsArray;

        if (selectedValues.length === 0) {
            return;
        }

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        requestAnimationFrame(() => {
            this.scrollIntoViewIfNeeded(this.findItemElementByValue(selectedValues[0]));
        });
    }

    scrollIntoViewIfNeeded (element) {
        if (!element) return;

        const scrollingParent = this.template.querySelector('.listbox-container');

        if (!scrollingParent) return;

        const parentRect = scrollingParent.getBoundingClientRect();
        const findMeRect = element.getBoundingClientRect();
        if (findMeRect.top < parentRect.top) {
            if (element.offsetTop + findMeRect.height < parentRect.height) {
                // If element fits by scrolling to the top, then do that
                scrollingParent.scrollTop = 0;
            } else {
                // Otherwise, top align the element
                scrollingParent.scrollTop = element.offsetTop;
            }
        } else if (findMeRect.bottom > parentRect.bottom) {
            // bottom align the element
            scrollingParent.scrollTop += findMeRect.bottom - parentRect.bottom;
        }

    }

    selectItem (selectedValue) {
        if (!selectedValue || this.isDropdownEmpty) {
            return;
        }

        const selectedItem = this._items.find(item => item.value === selectedValue);
        this._secondaryValue = selectedItem.secondary;
        this._valueLabel = selectedItem.label;

        const itemWasPreviouslySelected = (selectedItem && selectedItem.highlight);

        // ensure only 1 value can be selected if multiple (multi-picklist) mode is disabled.
        if (!this.multiple) {
            this.allowBlur();
            this.closeDropdown();
            this.inputElement.focus();

            this.clearSelectedItems();
            selectedItem.highlight = true;
        } else {
            this.cancelBlur();
            this.resetCancelBlur();
            selectedItem.highlight = !itemWasPreviouslySelected;
        }

        this.updateSelectedValue();
        this.updateSelectedItems();
        this.fireChangeEvent();
        this.reportValidity();
    }

    setFilterItems () {
        const searchValue = this._searchInputValue;

        if (!searchValue) {
            this._filteredItems = [...this._items];
        } else {
            this._filteredItems = this._items.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const labelMatch = (item.label)
                    ? item.label.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const secondaryMatch = (item.secondary)
                    ? item.secondary.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (labelMatch !== -1 || secondaryMatch !== -1);
            });
        }
    }

    updateClassList () {
        classListMutation(this.classList, {
            'slds-form-element_stacked': this.variant === VARIANT.LABEL_STACKED,
            'slds-form-element_readonly': this.readOnly === true,
            'slds-form-element_horizontal':
                this.variant === VARIANT.LABEL_INLINE,
        });
    }

    updateItems (items) {
        if (!items) {
            return;
        }
        const selectedValues = this.valueAsArray;
        const itemsWithNoneOption = this.updateItemsForDisplay(items);

        this._items = itemsWithNoneOption.map(item => {
            return this.processItem(item, selectedValues);
        });
    }

    updateItemsForDisplay (items) {
        let newItems = items;
        if (!this.multiple && !this.required && !this.hideNoneOption) {
            const noneOption = { label: this.i18n.none, value: NONE };
            newItems = JSON.parse(JSON.stringify(items));
            newItems.unshift(noneOption);
        }

        return newItems;
    }

    updateSelectedItems () {
        const selectedValues = this.valueAsArray;

        this.clearSelectedItems();

        if (!this.selectedValue || this.selectedValue.length === 0) {
            this.setFilterItems();
            return;
        }

        selectedValues.forEach(value => {
            const item = this._items.find(el => el.value === value);
            if (item) {
                item.highlight = true;
            }
        });

        this._items = this._items.slice();
        this.setFilterItems();
    }

    updateSelectedValue () {
        this.selectedValue = this.selectedItems
            .reduce((result, item) => {
                if (result.length === 0) return item.value;
                return result + ';' + item.value;
            }, '');
    }

    verifyItems (items) {
        if (!Array.isArray(items)) {
            throw new Error('items must be an array.');
        }

        const isValid = items.every(item =>
            Object.prototype.hasOwnProperty.call(item, 'label')
            && Object.prototype.hasOwnProperty.call(item, 'value')
        );

        if (!isValid) {
            throw new Error('each item in the items property must have a label and value.');
        }
    }
}