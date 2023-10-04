import { LightningElement, api, track } from 'lwc';
import { normalizeBoolean, VARIANT, normalizeVariant, classListMutation } from 'c/utils';
import { handleKeyDownOnOption } from './keyboard';

import labelMoveTop from '@salesforce/label/c.AltText_ReorderMoveTop';
import labelMoveUp from '@salesforce/label/c.AltText_ReorderMoveUp';
import labelMoveDown from '@salesforce/label/c.AltText_ReorderMoveDown';
import labelMoveBottom from '@salesforce/label/c.AltText_ReorderMoveBottom';

const i18n = {
    topButtonLabel: labelMoveTop,
    upButtonLabel: labelMoveUp,
    downButtonLabel: labelMoveDown,
    bottomButtonLabel: labelMoveBottom
};

const MOVE_TYPE = {
    TOP: 'top',
    UP: 'up',
    DOWN: 'down',
    BOTTOM: 'bottom',
};

export default class ReorderListBox extends LightningElement {
    @track _disabled;
    @track _variant;
    @track _size;
    @track _highlightedOptions = [];
    @track _options = [];
    @track _orderedValues = [];

    _connected = false;
    _isFocusOnList = false;

    /**
     * If present, the listbox is disabled and users cannot interact with it.
     * @type {string} 
     */
    @api
    get disabled () {
        return this._disabled || false;
    }

    set disabled (value) {
        this._disabled = normalizeBoolean(value);
    }

    /**
     * Help text detailing the purpose and function of the listbox.
     * @type {string}
     */
    @api fieldLevelHelp;

    /**
     * Label for the listbox.
     * @type {string}
     * @required
     */
    @api label;

    /**
     * A list of options that are available for selection.
     * Each option has the following attributes: label and value.
     * @type {object[]}
     * @required
     */
    @api
    get options () {
        return this._options || [];
    }

    set options (newOptions) {
        this.verifyOptions(newOptions);
        this._options = newOptions;

        if (this.value && this.value.length === 0) {
            this.setInitialValueFromOptions(newOptions);
        }
    }

    /**
     * Number of items that display in the listbox before vertical scrollbars are displayed.
     * Determines the vertical size of the listbox.
     * @type {number}
     * @default
     */
    @api
    get size () {
        return this._size;
    }

    set size (value) {
        this._size = value;
    }

    /**
     * The variant changes the appearance of the listbox.
     * Accepted variants include standard, label-hidden, label-inline, and label-stacked.
     * This value defaults to standard.
     * Use label-hidden to hide the label but make it available to assistive technology.
     * Use label-inline to horizontally align the label and listbox.
     * Use label-stacked to place the label above the listbox.
     * @type {string}
     */
    @api
    get variant () {
        return this._variant || VARIANT.STANDARD;
    }

    set variant (value) {
        this._variant = normalizeVariant(value);
        this.updateClassList();
    }

    /**
     * A list of ordered option values as displayed in the listbox component.
     * This list is populated with values from the options attribute.
     * @type {list}
     */
    @api
    get value () {
        return this._orderedValues || [];
    }

    get ariaDisabled () {
        return String(this.disabled);
    }

    get computedColumnStyle () {
        if (this.isNumber(this.size)) {
            // From the SLDS page: lightningdesignsystem.com/components/dueling-picklist/#Responsive
            const newHeight = parseInt(this.size, 10) * 2.25 + 1;
            return `height:${newHeight}rem`;
        }
        return '';
    }

    get computedGroupLabelClass () {
        let css = 'slds-form-element__label slds-form-element__legend';

        if (this.isLabelHidden) {
            css += ' slds-assistive-text';
        }
        return css;
    }

    get computedListboxContainerClass () {
        let css = 'listbox__options';

        if (this.disabled) {
            css += ' listbox-is-disabled';
        }
        return css;
    }

    get computedOptions () {
        let orderedOptions = [];

        if (this.options && this.options.length > 0) {
            const focusValue = (this.optionToFocus) ? this.optionToFocus : this.options[0].value;

            const _options = this.options.map(item => {
                return this.processOption(item, focusValue);
            });

            if (this.value && this.value.length === 0) {
                orderedOptions = _options;
            } else {
                this.value.forEach(optionValue => {
                    const option = _options.find(opt => opt.value === optionValue);
                    if (option) {
                        orderedOptions.push(option);
                    }
                });
            }
        }

        return orderedOptions;
    }

    get i18n () {
        return i18n;
    }

    get isLabelHidden () {
        return this.variant === VARIANT.LABEL_HIDDEN;
    }

    connectedCallback () {
        this.classList.add('slds-form-element');
        this.updateClassList();

        this.keyboardInterface = this.selectKeyboardInterface();
    }

    renderedCallback () {
        if (this.disabled) {
            return;
        }

        if (this.optionToFocus) {
            const option = this.getOptionByValue(this.optionToFocus);
            if (option) {
                this._isFocusOnList = true;
                option.focus();
            }
        }

        if (this.optionToScrollTo) {
            const option = this.getOptionByValue(this.optionToScrollTo);
            if (option) {
                this.scrollIntoViewIfNeeded(option);
            }

            this.optionToScrollTo = null;
        }
    }

    changeOptionsOrder (moveType) {
        const values = this.computedOptions.map(option => option.value);

        const toMove = values.filter(
            option => this._highlightedOptions.indexOf(option) > -1
        );

        const inValidSelection = toMove.length === 0;
        if (inValidSelection) {
            return;
        }

        const moveUp = (moveType === MOVE_TYPE.UP);
        const moveDown = (moveType === MOVE_TYPE.DOWN);
        const moveTop = (moveType === MOVE_TYPE.TOP);
        const moveBottom = (moveType === MOVE_TYPE.BOTTOM);

        let start = (moveUp || moveBottom) ? 0 : toMove.length - 1;
        let index = values.indexOf(toMove[start]);

        const lastValueToMove = toMove[toMove.length - 1];

        const inValidMove = (moveUp && index === 0) || (moveDown && index === values.length - 1);
        if (inValidMove) {
            return;
        }

        switch (true) {
            case moveUp:
                while (start < toMove.length) {
                    index = values.indexOf(toMove[start]);
                    this.swapOptions(index, index - 1, values);
                    start++;
                }
                break;
            case moveDown:
                while (start > -1) {
                    index = values.indexOf(toMove[start]);
                    this.swapOptions(index, index + 1, values);
                    start--;
                }
                break;
            case moveTop:
                while (start > -1) {
                    index = values.indexOf(toMove[start]);
                    this.moveOptions(0, index, values);
                    start--;
                }
                break;
            case moveBottom:
                while (start < toMove.length) {
                    index = values.indexOf(toMove[start]);
                    this.moveOptions(values.length - 1, index, values);
                    start++;
                }
                break;
            default:
                // no default
        }

        this._orderedValues = values;
        this.optionToFocus = null;
        this.dispatchChangeEvent(values);
        this.optionToScrollTo = lastValueToMove;
    }

    dispatchChangeEvent (values) {
        this.dispatchEvent(
            new CustomEvent('change', {
                composed: true,
                bubbles: true,
                detail: { value: values },
            })
        );
    }

    getElementsOfListBox () {
        const elements = this.template.querySelectorAll(`div[role='option']`);
        return elements ? elements : [];
    }

    getOptionByValue (optionValue) {
        return this.template.querySelector(`div[data-value='${optionValue.replace(/'/g, "\\'")}']`);
    }

    getOptionIndex (optionElement) {
        return parseInt(optionElement.getAttribute('data-index'), 10);
    }

    handleFocus (event) {
        // select the focused option if entering a listbox
        const element = event.target;
        if (element.role === 'option') {
            if (!this._isFocusOnList) {
                this._isFocusOnList = true;
                this.updateSelectedOptions(element, true, false);
            }
        }
    }

    handleBlur (event) {
        const element = event.target;
        if (element.role !== 'option') {
            this._isFocusOnList = false;
        }
    }

    handleTopButtonClick () {
        this.changeOptionsOrder(MOVE_TYPE.TOP);
    }

    handleUpButtonClick () {
        this.changeOptionsOrder(MOVE_TYPE.UP);
    }

    handleDownButtonClick () {
        this.changeOptionsOrder(MOVE_TYPE.DOWN);
    }

    handleBottomButtonClick () {
        this.changeOptionsOrder(MOVE_TYPE.BOTTOM);
    }

    handleOptionClick (event) {
        if (this.disabled) {
            return;
        }

        const selectMultiple = event.metaKey || event.ctrlKey || event.shiftKey;
        const option = event.currentTarget;
        if (event.shiftKey) {
            this.selectAllFromLastSelectedToOption(option, false);
            return;
        }
        const selected = selectMultiple && option.getAttribute('aria-selected') === 'true';
        this.updateSelectedOptions(option, !selected, selectMultiple);
        this.shiftIndex = -1;

    }

    handleOptionKeyDown (event) {
        if (this.disabled) {
            return;
        }

        handleKeyDownOnOption(event, this.keyboardInterface);
    }

    isNumber (value) {
        return value !== '' && value !== null && isFinite(value);
    }

    processOption (opt, focusableValue) {
        const itemCopy = {};

        itemCopy.label = opt.label;
        itemCopy.value = opt.value;

        const isSelected = this._highlightedOptions.indexOf(opt.value) > -1;

        const cssClasses = [
            'slds-listbox__option',
            'slds-listbox__option_plain',
            'slds-media',
            'slds-media_small',
            'slds-media_inline'
        ];
        if (isSelected) {
            cssClasses.push('slds-is-selected');
        }

        itemCopy.classList = cssClasses.join(' ');
        itemCopy.selected = isSelected ? 'true' : 'false';
        itemCopy.tabIndex = opt.value === focusableValue ? '0' : '-1';

        return itemCopy;
    }

    scrollIntoViewIfNeeded (element) {
        if (!element) return;

        const scrollingParent = this.template.querySelector('.listbox__options');

        if (!scrollingParent) return;

        const parentRect = scrollingParent.getBoundingClientRect();
        const findMeRect = element.getBoundingClientRect();
        if (findMeRect.top < parentRect.top) {
            if (element.offsetTop + findMeRect.height < parentRect.height) {
                scrollingParent.scrollTop = 0;
            } else {
                scrollingParent.scrollTop = element.offsetTop;
            }
        } else if (findMeRect.bottom > parentRect.bottom) {
            scrollingParent.scrollTop += findMeRect.bottom - parentRect.bottom;
        }

    }

    selectAllFromLastSelectedToOption (option, all) {
        const options = this.getElementsOfListBox();
        const end = all ? 0 : this.getOptionIndex(option);
        this.lastSelected = this.lastSelected < 0 ? end : this.lastSelected;
        const start = all ? options.length : this.lastSelected;
        let val, select;
        this._highlightedOptions = [];
        for (let i = 0; i < options.length; i++) {
            select = (i - start) * (i - end) <= 0;
            if (select) {
                val = options[i].getAttribute('data-value');
                this._highlightedOptions.push(val);
            }
        }
    }

    selectKeyboardInterface () {
        const that = this;
        that.shiftIndex = -1;
        that.lastShift = null;
        return {
            getShiftIndex () {
                return that.shiftIndex;
            },
            setShiftIndex (value) {
                that.shiftIndex = value;
            },
            getLastShift () {
                return that.lastShift;
            },
            setLastShift (value) {
                that.lastShift = value;
            },
            getElementsOfList () {
                return that.getElementsOfListBox();
            },
            selectAllOptions (option) {
                that.selectAllFromLastSelectedToOption(option, true);
            },
            updateSelectedOptions (option, select, isMultiple) {
                that.updateSelectedOptions(option, select, isMultiple);
            },
        };
    }

    setInitialValueFromOptions (options) {
        this._orderedValues = options.map(option => option.value);
    }

    moveOptions (newIndex, oldIndex, array) {
        array.splice(newIndex, 0, array.splice(oldIndex, 1)[0]);
    }

    swapOptions (i, j, array) {
        const temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }

    updateClassList () {
        classListMutation(this.classList, {
            'slds-form-element_stacked': this.variant === VARIANT.LABEL_STACKED,
            'slds-form-element_horizontal':
                this.variant === VARIANT.LABEL_INLINE,
        });
    }

    updateSelectedOptions (option, select, isMultiple) {
        const value = option.getAttribute('data-value');
        const optionIndex = this.getOptionIndex(option);

        if (!isMultiple) {
            this._highlightedOptions = [];
            this.lastSelected = -1;
        }

        if (select) {
            if (this._highlightedOptions.indexOf(value) === -1) {
                this._highlightedOptions.push(value);
            }
        } else {
            this._highlightedOptions.splice(this._highlightedOptions.indexOf(value), 1);
        }

        this.optionToFocus = value;
        this.lastSelected = optionIndex;
    }

    verifyOptions (options) {
        if (!Array.isArray(options)) {
            throw new Error('items must be an array.');
        }

        const isValid = options.every(item =>
            Object.prototype.hasOwnProperty.call(item, 'label')
            && Object.prototype.hasOwnProperty.call(item, 'value')
        );

        if (!isValid) {
            throw new Error('each item in the options property must have a label and value.');
        }
    }
}