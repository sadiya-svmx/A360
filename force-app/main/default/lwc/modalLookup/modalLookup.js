import { LightningElement, api, track } from 'lwc';
import {
    normalizeBoolean,
    isEmptyString,
    isImageFromStaticResource,
    VARIANT,
    normalizeVariant,
    classListMutation
} from 'c/utils';

import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelClose from '@salesforce/label/c.AltText_Close';
import labelView from '@salesforce/label/c.Label_View';

const i18n = {
    required: labelRequired,
    valueMissing: labelEnterValue,
    view: labelView,
    closeAltText: labelClose
};

export default class ModalLookup extends LightningElement {
    @track _disabled = false;
    @track _helpMessage;
    @track _hideViewButton = false;
    @track _required = false;
    @track _variant;
    @track _value;

    /**
     * If present, the input field is disabled and users cannot interact with it.
     * @type {boolean}
     * @default false
     */
    @api
    get disabled () {
        return this._disabled || false;
    }

    set disabled (value) {
        this._disabled = normalizeBoolean(value);
    }

    /**
     * Help text detailing the purpose and function of the input.
     * @type {string}
     *
     */
    @api fieldLevelHelp;

    /**
     * If present, hides the view button when a value is populated.
     */
    @api
    get hideViewButton () {
        return this._hideViewButton;
    }

    set hideViewButton (value) {
        this._hideViewButton = normalizeBoolean(value);
    }

    /**
     * Text label for the component.
     * @type {string}
     * @required
     *
     */
    @api label;

    /**
     * Error message to be displayed when the value is missing.
     * @type {string}
     *
     */
    @api messageWhenValueMissing;

    /**
     * Text that is displayed when the field is empty, to prompt the user for a valid entry.
     * @type {string}
     *
     */
    @api placeholder;

    /**
     * If present, the input field must be filled out before the form is submitted.
     * @type {boolean}
     * @default false
     */
    @api
    get required () {
        return this._required;
    }

    set required (value) {
        this._required = normalizeBoolean(value);
    }

    /**
     * The variant changes the appearance of an input field.
     * Accepted variants include standard, label-inline, label-hidden, and label-stacked.
     * This value defaults to label-hidden, which hides the label.
     * Use label-hidden to hide the label but make it available to assistive technology.
     * Use label-inline to horizontally align the label and input field.
     * Use label-stacked to place the label above the input field.
     * @type {string}
     * @default label-hidden
     */
    @api
    get variant () {
        return this._variant || VARIANT.LABEL_HIDDEN;
    }

    set variant (value) {
        this._variant = normalizeVariant(value);
        this.updateClassList();
    }

    /**
     * Specifies the value of an input element.
     * @type {object}
     */
    @api
    get value () {
        return this._value;
    }

    set value (newValue) {
        if (newValue) {
            this.verifyValueObject(newValue);
        }

        if (newValue !== this._value) {
            this._value = newValue;

            if (this._value) {
                this.reportValidity();
            }
        }
    }

    @api
    checkValidity () {
        return !(!this.disabled && this.required && this.isInvalidValue(this._value));
    }

    @api
    reportValidity () {
        const valid = this.checkValidity();

        this.classList.toggle('slds-has-error', !valid);

        this._helpMessage = (valid)
            ? null
            : (isEmptyString(this.messageWhenValueMissing))
                ? i18n.valueMissing
                : this.messageWhenValueMissing;

        return valid;
    }

    get i18n () {
        return i18n;
    }

    get isCustomIcon () {
        if (this.valueIconName) {
            return isImageFromStaticResource(this.valueIconName);
        }
        return false;
    }

    get valueLabel () {
        if (this._value) {
            return this._value.label;
        }
        return '';
    }

    get computedComboContainerClass () {
        let css = 'slds-combobox_container ';
        if (this._value) {
            css += 'slds-has-selection';
        }

        return css;
    }

    get computedComboElementClass () {
        const cssClasses = [
            'slds-combobox__form-element',
            'slds-input-has-icon'
        ];

        if (this.valueIconName) {
            cssClasses.push('slds-input-has-icon_left-right');
        } else {
            cssClasses.push('slds-input-has-icon_right');
        }

        return cssClasses.join(' ');
    }

    get valueIconName () {
        if (this._value && this._value.iconName) {
            return this._value.iconName;
        }
        return null;
    }

    connectedCallback () {
        this.classList.add('slds-form-element');
        this.updateClassList();
    }

    dispatchViewClickedEvent () {
        this.dispatchEvent(
            new CustomEvent('viewclick', {
                composed: true,
                bubbles: true
            })
        );
    }

    dispatchModalRequest () {
        this.dispatchEvent(
            new CustomEvent('modalrequest', {
                composed: true,
                bubbles: true
            })
        );
    }

    dispatchValueRemoved () {
        this.dispatchEvent(
            new CustomEvent('valueremoved', {
                composed: true,
                bubbles: true
            })
        );
    }

    handleInputChange (event) {
        event.stopPropagation();
    }

    handleInputClick () {
        if (!this._value) {
            this.dispatchModalRequest();
        }
    }

    handleRemove () {
        this._value = null;
        this.dispatchValueRemoved();
    }

    handleInputSelect (event) {
        event.stopPropagation();
    }

    handleViewClick (event) {
        event.stopPropagation();

        this.dispatchViewClickedEvent();
    }

    isInvalidValue (value) {
        return (
            value === undefined ||
            value === null ||
            typeof value !== 'object' ||
            (typeof value === 'object'
                && (!Object.prototype.hasOwnProperty.call(value, 'label')
                || !Object.prototype.hasOwnProperty.call(value, 'value'))
            )
        );
    }

    updateClassList () {
        classListMutation(this.classList, {
            'slds-form-element_stacked': this.variant === VARIANT.LABEL_STACKED,
            'slds-form-element_horizontal':
                this.variant === VARIANT.LABEL_INLINE,
        });
    }

    verifyValueObject (value) {
        const isValid = (typeof value === 'object'
            && Object.prototype.hasOwnProperty.call(value, 'label')
            && Object.prototype.hasOwnProperty.call(value, 'value')
        );

        if (!isValid) {
            throw new Error('The value must be an object and have a label and value properties.');
        }
    }

}