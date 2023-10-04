/* eslint-disable no-unused-expressions */
import { LightningElement, api } from 'lwc';
import {
    normalizeBoolean,
    VARIANT,
    normalizeVariant,
    synchronizeAttrs,
    isEmptyString,
    isEmptyArray,
    getRealDOMId,
    classListMutation,
    InteractingState,
    FieldConstraintApi,
    generateA11yId,
    IS_MOBILE_DEVICE
} from 'c/utils';

import Label_RequiredFieldMessage from '@salesforce/label/c.Label_RequiredFieldMessage';

const i18n = {
    required: Label_RequiredFieldMessage
}

export default class XRadioList extends LightningElement {
    static delegatesFocus = true;

    @api name = generateA11yId();
    @api messageWhenValueMissing;

    @api multiple = false;

    _options;
    @api get options () {
        return this._options;
    }

    set options (value) {
        this._options = value;
        this._updateTransformedOptions();
    }

    _helpMessage;

    _value;
    @api get value () {
        if (!this._value?.length) {
            return null;
        } else if (this._value.length === 1) {
            return this._value[0];
        }
        return this._value;
    }

    set value (value) {
        this._value = value;
        this._updateTransformedOptions();
    }

    _disabled = false;
    @api get disabled () {
        return this._disabled;
    }

    set disabled (value) {
        this._disabled = normalizeBoolean(value);
    }

    _required = false;
    @api get required () {
        return this._required;
    }

    set required (value) {
        this._required = normalizeBoolean(value);
    }

    _variant;
    @api get variant () {
        return this._variant || VARIANT.STANDARD;
    }

    set variant (value) {
        this._variant = normalizeVariant(value);
        this.updateClassList();
    }

    @api get validity () {
        return this._constraint.validity;
    }

    @api
    checkValidity () {
        return this._constraint.checkValidity();
    }

    @api
    reportValidity () {
        return this._constraint.reportValidity(
            message => { this._helpMessage = message }
        );
    }

    @api
    showHelpMessageIfInvalid () {
        this.reportValidity();
    }

    @api
    focus () {
        this.template.querySelector('input')?.focus();
    }

    @api
    blur () {
        this.template.querySelector('input')?.blur();
    }

    get inputType () {
        return this.multiple ? 'checkbox' : 'radio';
    }

    get rootClass () {
        return IS_MOBILE_DEVICE ? 'svmx-mobile' : '';
    }

    get computedUniqueHelpElementId () {
        return getRealDOMId(this.template.querySelector('[data-help-message]'));
    }

    get radioButtonElements () {
        return this.template.querySelectorAll('input');
    }

    get multiSelectButtonElements () {
        return this.template.querySelectorAll('lightning-button-icon-stateful');
    }

    get i18n () {
        return i18n;
    }

    transformedOptions = [];
    _updateTransformedOptions () {
        const { options, _value: value } = this;

        if (Array.isArray(options)) {
            this.transformedOptions = options.map((option, index) => {
                const isChecked = value?.includes(option.value);

                return {
                    label: option.label,
                    hasSecondaryLabel: !!option.secondaryLabel,
                    secondaryLabel: option.secondaryLabel,
                    value: option.value,
                    isChecked,
                    iconName: isChecked ? 'utility:check': 'utility:add',
                    indexId: `radio-${index}`,
                    outerClassList: index === options.length - 1 ?
                        'slds-border_top slds-border_bottom' :
                        'slds-border_top'
                };
            });
        } else {
            this.transformedOptions = [];
        }
    }

    get _constraint () {
        if (!this._constraintApi) {
            this._constraintApi = new FieldConstraintApi(() => this, {
                valueMissing: () => !this.disabled && this.required && (
                    isEmptyString(this.value) || isEmptyArray(this.value)
                )
            });
        }

        return this._constraintApi;
    }

    synchronizeA11y () {
        const inputs = this.template.querySelectorAll('input');
        Array.prototype.slice.call(inputs).forEach((input) => {
            synchronizeAttrs(input, {
                'aria-describedby': this.computedUniqueHelpElementId
            });
        });
    }

    connectedCallback () {
        this.classList.add('slds-form-element');
        this.updateClassList();
        this.interactingState = new InteractingState();
        this.interactingState.onleave(this.showHelpMessageIfInvalid.bind(this));
    }

    updateClassList () {
        classListMutation(this.classList, {
            'slds-form-element_stacked': this.variant === VARIANT.LABEL_STACKED,
            'slds-form-element_horizontal': this.variant === VARIANT.LABEL_INLINE
        });
    }

    renderedCallback () {
        this.synchronizeA11y();
    }

    handleChange (e) {
        e.stopPropagation();

        this.interactingState.interacting();

        const value = Array.from(this.radioButtonElements)
            .filter(radioButton => radioButton.checked)
            .map(radioButton => radioButton.value);

        this._value = value;

        this.dispatchEvent(
            new CustomEvent('change', {
                detail: { value: this.value },
                composed: true,
                bubbles: true,
                cancelable: true
            })
        );

        this._updateTransformedOptions();
    }

    handleMultiSelectClick (e) {
        e.target.selected = !e.target.selected;
        const indexId = e.target.value;
        const checkboxInput = this.template.querySelector(`input[data-index-id='${indexId}']`);
        checkboxInput.click();
    }

    handleFocus () {
        this.interactingState.enter();
        this.dispatchEvent(new CustomEvent('focus'));
    }

    handleBlur () {
        this.interactingState.leave();
        this.dispatchEvent(new CustomEvent('blur'));
    }
}