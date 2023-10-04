import { LightningElement, api, track } from 'lwc';
import {
    FIELD_DATA_TYPES,
    VALUE_INPUT_FIELD_CONTEXT,
    VARIANT,
    UNSUPPORTED_FIELD_TYPES,
    formatString,
    PHONE_REGEXP_STRING,
    TEXT_REGEXP_STRING,
    getLookupReferenceToObject,
    OBJECT_ICONS,
    OBJECT_DEFAULT_ICON,
    SEARCH_TEXT_OPERATOR_TYPES,
    IS_MOBILE_DEVICE,
    isNotUndefinedOrNull,
} from 'c/utils';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import shortDateTimeFormat from '@salesforce/i18n/dateTime.shortDateTimeFormat';
import shortTimeFormat from '@salesforce/i18n/dateTime.shortTimeFormat';
import labelTrue from '@salesforce/label/c.Label_True';
import labelFalse from '@salesforce/label/c.Label_False';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import labelEmailMismatch from '@salesforce/label/c.Message_EmailTypeMismatch';
import labelUrlMismatch from '@salesforce/label/c.Message_UrlTypeMismatch';
import labelBadInputTime from '@salesforce/label/c.Message_BadInputTime';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import labelBadInputDateTime from '@salesforce/label/c.Message_BadInputDateTime';
import labelBadInputNumber from '@salesforce/label/c.Message_BadInputNumber';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelPhoneMismatch from '@salesforce/label/c.Message_PhonePatternMismatch';
import labelNotSupported from '@salesforce/label/c.Error_UnsupportedType';
import labelLongitudeRange from '@salesforce/label/c.Error_LongitudeRange';
import labelLatitudeRange from '@salesforce/label/c.Error_LatitudeRange';

import TIMEZONE from '@salesforce/i18n/timeZone';

const NUMBER_TYPES = [
    FIELD_DATA_TYPES.LONG,
    FIELD_DATA_TYPES.INTEGER,
    FIELD_DATA_TYPES.PERCENT,
    FIELD_DATA_TYPES.CURRENCY,
    FIELD_DATA_TYPES.DOUBLE,
];

const MAX_TEXTAREA_LENGTH = 255;

const i18n = {
    trueLabel: labelTrue,
    falseLabel: labelFalse,
    valueMissing: labelEnterValue,
    tooLong: labelMaxLength,
    urlMismatch: labelUrlMismatch,
    emailMismatch: labelEmailMismatch,
    phoneMismatch: labelPhoneMismatch,
    badInputDate: labelBadInputDate,
    badInputDateTime: labelBadInputDateTime,
    badInputTime: labelBadInputTime,
    badInputNumber: labelBadInputNumber,
    outOfRangeNumber: labelOutOfRangeNumber,
    shortDateFormat: shortDateFormat,
    shortDateTimeFormat: shortDateTimeFormat,
    shortTimeFormat: shortTimeFormat,
    notSupported: labelNotSupported,
    latitudeErrorMessage: labelLatitudeRange,
    longitudeErrorMessage: labelLongitudeRange
};

export default class ValueInput extends LightningElement {
    @api fieldDefinition;
    @api operator;
    @api required;
    @api variant;
    @api disabled = false;
    @api readOnly = false;
    @api meta;
    @api fieldId;
    @api timezone = TIMEZONE;
    @api placeholder = '';
    @api messageWhenValueMissing = this.i18n.valueMissing;
    @api messageWhenTooLong = this.i18n.tooLong;
    @api messageWhenPatternMismatch = this.i18n.valueMissing;

    @track internalValue;

    isDirty = false;
    _context = VALUE_INPUT_FIELD_CONTEXT.ADMIN;

    connectedCallback () {
        this.classList.add('slds-form-element');
    }

    renderedCallback () {
        if (this.getInputComponent()) {
            this.dispatchValidity();
        }
    }

    get i18n () {
        return i18n;
    }

    get isTypeBoolean () {
        return (FIELD_DATA_TYPES.BOOLEAN === this.fieldDataType &&
            ( VALUE_INPUT_FIELD_CONTEXT.ADMIN === this.context
                || VALUE_INPUT_FIELD_CONTEXT.EXPRESSION_ADMIN === this.context )
        );
    }

    get isTypeCheckbox () {
        return (
            FIELD_DATA_TYPES.BOOLEAN === this.fieldDataType &&
            VALUE_INPUT_FIELD_CONTEXT.RUNTIME === this.context
        );
    }

    get isTypeDate () {
        return FIELD_DATA_TYPES.DATE === this.fieldDataType;
    }

    get isTypeDateTime () {
        return FIELD_DATA_TYPES.DATETIME === this.fieldDataType;
    }

    get isTypeEmail () {
        return FIELD_DATA_TYPES.EMAIL === this.fieldDataType
                && !this.operator !== undefined
                && !SEARCH_TEXT_OPERATOR_TYPES.has(this.operator);
    }

    get dateTimeInternalValue () {
        if ( isNotUndefinedOrNull(this.internalValue) && IS_MOBILE_DEVICE ) {
            return this.internalValue.split('.')[0]+'.000Z';
        }
        return this.internalValue;
    }

    get isTypeMultiPicklist () {
        return FIELD_DATA_TYPES.MULTIPICKLIST === this.fieldDataType;
    }

    get isTypeNumber () {
        return NUMBER_TYPES.includes(this.fieldDataType);
    }

    get isTypePhone () {
        return FIELD_DATA_TYPES.PHONE === this.fieldDataType;
    }

    get isTypePicklist () {
        return FIELD_DATA_TYPES.PICKLIST === this.fieldDataType
            && !this.operator !== undefined
            && !SEARCH_TEXT_OPERATOR_TYPES.has(this.operator);
    }

    get isTypeReference () {
        return FIELD_DATA_TYPES.REFERENCE === this.fieldDataType
            && !this.operator !== undefined
            && !SEARCH_TEXT_OPERATOR_TYPES.has(this.operator);
    }

    get isTypeText () {
        return (
            !this.isTypeBoolean &&
            !this.isTypeCheckbox &&
            !this.isTypeDate &&
            !this.isTypeDateTime &&
            !this.isTypeEmail &&
            !this.isTypeMultiPicklist &&
            !this.isTypeNumber &&
            !this.isTypePhone &&
            !this.isTypePicklist &&
            !this.isTypeReference &&
            !this.isTypeTextArea &&
            !this.isTypeTime &&
            !this.isTypeUrl &&
            !this.isTypeUnsupported
        );
    }

    get isTypeTextArea () {
        return FIELD_DATA_TYPES.TEXTAREA === this.fieldDataType;
    }

    get isTypeTime () {
        return FIELD_DATA_TYPES.TIME === this.fieldDataType;
    }

    get isTypeUnsupported () {
        return UNSUPPORTED_FIELD_TYPES.has(this.fieldDataType);
    }

    get isTypeUrl () {
        return FIELD_DATA_TYPES.URL === this.fieldDataType
                && !this.operator !== undefined
                && !this.isTypeUrlOnRuntimeContext
                && !SEARCH_TEXT_OPERATOR_TYPES.has(this.operator);
    }

    get isTypeUrlOnRuntimeContext () {
        return (
            FIELD_DATA_TYPES.URL === this.fieldDataType &&
            VALUE_INPUT_FIELD_CONTEXT.RUNTIME === this.context
        );
    }

    get fieldDataType () {
        if (this.fieldDefinition && this.fieldDefinition.dataType) {
            return this.fieldDefinition.dataType;
        }

        return null;
    }

    get booleanOptions () {
        return [
            { label: i18n.falseLabel, value: 'false' },
            { label: i18n.trueLabel, value: 'true' }
        ]
    }

    get picklistOptions () {
        if (this.fieldDefinition
            && this.fieldDefinition.picklistValues
            && this.fieldDefinition.picklistValues.length > 0) {
            return this.fieldDefinition.picklistValues;
        }

        return [];
    }

    get fieldLabel () {
        if (this.fieldDefinition
            && this.fieldDefinition.label) {
            return this.fieldDefinition.label
        }
        return '';
    }

    get fieldApiName () {
        if (this.fieldDefinition
            && this.fieldDefinition.apiName) {
            return this.fieldDefinition.apiName
        }
        return '';
    }

    get objectFieldApiName () {
        if (this.fieldDefinition
            && this.fieldDefinition.apiName && this.fieldDefinition.objectApiName) {
            return `${this.fieldDefinition.objectApiName}.${this.fieldDefinition.apiName}`;
        }
        return null;
    }

    get recordTypeId () {
        if ((this.isTypePicklist || this.isTypeMultiPicklist)
            && this.fieldDefinition
            && this.fieldDefinition.recordTypeId) {
            return this.fieldDefinition.recordTypeId
        }
        return null;
    }

    get defaultRecordTypeId () {
        return this.fieldDefinition.defaultRecordTypeId;
    }

    get lookupIcon () {
        if (this.isTypeReference) {
            let objectIconName =
                OBJECT_ICONS[getLookupReferenceToObject(this.fieldDefinition).toLowerCase()];

            if (!objectIconName) {
                objectIconName = OBJECT_DEFAULT_ICON;
            }

            return objectIconName;
        }
        return null;
    }

    get badInputMessage () {
        // eslint-disable-next-line default-case
        switch (this.fieldDataType) {
            case FIELD_DATA_TYPES.DATE:
                return formatString(i18n.badInputDate, i18n.shortDateFormat);
            case FIELD_DATA_TYPES.DATETIME:
                return formatString(i18n.badInputDateTime, i18n.shortDateTimeFormat);
            case FIELD_DATA_TYPES.TIME:
                return formatString(i18n.badInputTime, i18n.shortTimeFormat);
        }

        if (this.isTypeNumber) {
            return i18n.badInputNumber;
        }

        return null;
    }

    get numberStepMismatchMessage () {
        if (this.fieldDefinition && this.isTypeNumber) {
            const scale = this.fieldDefinition.scale;
            const wholeNumAllowed = this.fieldDefinition.precision - scale;

            return formatString(i18n.outOfRangeNumber, wholeNumAllowed, scale);
        }

        return null;
    }

    get tooLongMessage () {
        return formatString(this.messageWhenTooLong, this.inputMaxLength);
    }

    get patternMismatchMessage () {
        if (this.isTypePhone && this.messageWhenPatternMismatch === this.i18n.valueMissing) {
            return this.i18n.phoneMismatch;
        }
        return this.messageWhenPatternMismatch;
    }

    get inputMaxLength () {
        if (this.isTypeTextArea) {
            return (this.fieldDefinition && this.fieldDefinition.length)
                ? this.fieldDefinition.length
                : MAX_TEXTAREA_LENGTH;
        }

        return (this.fieldDefinition && this.fieldDefinition.length)
            ? this.fieldDefinition.length
            : 0;
    }

    get inputVariant () {
        /**
         * Consumers of this component requiring a label should provide a variant
         *     e.g. variant="label-stacked", variant="label-inline" etc.,
         * Otherwise, it defaults to a field with no label (variant="label-hidden")
         */
        if (this.variant) {
            return this.variant;
        }
        return VARIANT.LABEL_HIDDEN;
    }

    get numberStep () {
        switch (this.fieldDataType) {
            case FIELD_DATA_TYPES.CURRENCY:
            case FIELD_DATA_TYPES.PERCENT:
            case FIELD_DATA_TYPES.DOUBLE:
                return this.scaleToDecimalPlaces(this.fieldDefinition.scale);
            default:
                return 1;
        }
    }

    get textPattern () {
        return (this.required) ? TEXT_REGEXP_STRING : null;
    }

    get phonePattern () {
        return PHONE_REGEXP_STRING;
    }

    get controllerValue () {
        return this.fieldDefinition.controllerValue;
    }

    get controllerFieldName () {
        return this.fieldDefinition.controllerFieldName;
    }

    @api engineId;

    @api
    get value () {
        return this.internalValue;
    }
    set value (val) {
        if (val !== undefined) {
            this.internalValue = val;
            this.isDirty = true;
        }
    }

    @api
    checkValidity () {
        return this.getInputComponent().checkValidity();
    }

    @api
    get dirty () {
        return this.isDirty;
    }

    @api
    reportValidity () {
        const input = this.getInputComponent();
        if (input) {
            return input.reportValidity();
        }
        return true;
    }

    @api
    reset () {
        this.isDirty = false;
        this.internalValue = null;
    }

    @api
    get context () {
        return this._context;
    }

    set context (value) {
        if (value !== null) {
            this._context = value;
        }
    }

    checkNumberRangeValidity () {
        let isValid = true;

        const scale = this.fieldDefinition.scale;
        const wholeNumAllowed = FIELD_DATA_TYPES.INTEGER !== this.fieldDataType
            ? this.fieldDefinition.precision - scale
            : this.fieldDefinition.digits;

        const numberAsStr = this.value;

        const [wholeNumberPart = '', scalePart = ''] = numberAsStr.split('.');
        const wholeNumberLength = wholeNumberPart.length;
        const scalePartLength = scalePart.length;

        const isDigitsOutOfRange = wholeNumberLength > wholeNumAllowed;
        const isScaleOutOfRange = scalePartLength > scale;

        if (isDigitsOutOfRange || isScaleOutOfRange) {
            const formattedString = formatString(i18n.outOfRangeNumber, wholeNumAllowed, scale);
            this.getInputComponent().setCustomValidity(formattedString);
            isValid = false;
        }

        if (this.fieldDefinition.compoundFieldName && this.fieldDefinition.localName) {
            const fieldLocalName = this.fieldDefinition.localName;
            if ((fieldLocalName === 'Latitude' || fieldLocalName.endsWith('Latitude__s')) &&
                !(numberAsStr <= 90 && numberAsStr >= -90)) {
                this.getInputComponent().setCustomValidity(i18n.latitudeErrorMessage);
                isValid = false;
            }
            if ((fieldLocalName === 'Longitude' || fieldLocalName.endsWith('Longitude__s')) &&
                !(numberAsStr <= 180 && numberAsStr >= -180)) {
                this.getInputComponent().setCustomValidity(i18n.longitudeErrorMessage);
                isValid = false;
            }
        }

        if (!isValid) {
            this.reportValidity();
        }

        return isValid;
    }

    handleChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const { detail, target } = event;

        const newValue = target.type === 'checkbox' ? detail.checked: detail.value;
        if (this.value !== newValue) {
            this.internalValue = newValue;
            this.isDirty = true;

            if (!this.isTypeNumber) {
                this.dispatchChangeEvent({
                    value: this.value,
                    label: event.detail.label,
                    meta: this.meta
                });
            }
        }
    }

    handleNumberCommit (event) {
        event.stopPropagation();

        this.getInputComponent().setCustomValidity('');

        if (this.checkNumberRangeValidity() && this.reportValidity()) {
            this.dispatchChangeEvent({ value: this.value });
        }

        this.dispatchValidity();
    }

    dispatchChangeEvent (detail) {
        this.dispatchEvent(
            new CustomEvent('valueinputchange', {
                composed: true,
                bubbles: true,
                detail,
            })
        );
    }

    handleCommit () {
        this.dispatchValidity();
    }

    dispatchValidity () {
        this.dispatchEvent(
            new CustomEvent('inputvalidity', {
                composed: true,
                bubbles: true,
                detail: {
                    fieldId: this.fieldId,
                    name: this.fieldApiName,
                    required: this.required,
                    validity: this.checkValidity(),
                    value: this.value,
                },
            })
        );
    }

    isFormulaField () {
        if (!this.fieldDefinition) return false;

        return this.fieldDefinition.calculated;
    }

    getInputComponent () {
        let inputSelector;
        if (this.isTypeReference) {
            inputSelector = 'c-svmx-lookup';
        } else if (this.isTypePicklist || this.isTypeMultiPicklist) {
            inputSelector = 'c-combobox-by-record-type';
        } else if (this.isTypeBoolean) {
            inputSelector = 'c-combobox';
        }
        else {
            inputSelector = [
                'lightning-input',
                'lightning-textarea',
            ].join(',');
        }
        return this.template.querySelector(inputSelector);
    }

    scaleToDecimalPlaces (scale) {
        const resultAsString = Math.pow(10, -parseInt(scale, 10)).toFixed(scale);
        return parseFloat(resultAsString);
    }

    @api
    getValidityReport () {
        return {
            fieldId: this.fieldId,
            name: this.fieldApiName,
            required: this.required,
            validity: this.checkValidity(),
            value: this.value,
        };
    }

}