import { LightningElement, track, api } from 'lwc';

import getTechnicalAttribute
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getTechnicalAttributeWithDetails';

import labelEditTemplateItem from '@salesforce/label/c.Label_EditTemplateItem';
import labelTechnicalAttribute from '@salesforce/label/c.Label_TechnicalAttribute';
import labelDefaultValue from '@salesforce/label/c.Label_DefaultValue';
import labelIsReadOnly from '@salesforce/label/c.Label_IsReadOnly';
import labelIsRequired from '@salesforce/label/c.Label_IsRequired';
import labelMaximumValue from '@salesforce/label/c.Label_MaximumValue';
import labelMinimumValue from '@salesforce/label/c.Label_MinimumValue';
import labelMessage from '@salesforce/label/c.Label_Message';
import labelHelpText from '@salesforce/label/c.Label_HelpText';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelDefaultAndMinValueValidation
    from '@salesforce/label/c.Label_DefaultAndMinValueValidation';
import labelDefaultAndMaxValueValidation
    from '@salesforce/label/c.Label_DefaultAndMaxValueValidation';
import labelAttributeMinimumValueError
    from '@salesforce/label/c.Label_AttributeMinimumValueError';
import TIMEZONE from '@salesforce/i18n/timeZone';

import {
    deepCopy,
    verifyApiResponse,
    parseErrorMessage,
    isUndefinedOrNull,
    formatString,
    isEmptyString
} from 'c/utils';

const i18n = {
    editTemplateItem: labelEditTemplateItem,
    technicalAttribute: labelTechnicalAttribute,
    defaultValue: labelDefaultValue,
    isReadOnly: labelIsReadOnly,
    isRequired: labelIsRequired,
    maximumValue: labelMaximumValue,
    minimumValue: labelMinimumValue,
    message: labelMessage,
    helpText: labelHelpText,
    cancel: labelCancel,
    valueMissing: labelEnterValue,
    tooLong: labelMaxLength,
    badInputDate: labelBadInputDate,
    shortDateFormat: shortDateFormat,
    outOfRangeNumber: labelOutOfRangeNumber,
    formValidation: labelFormValidation,
    defaultAndMinValueValidation: labelDefaultAndMinValueValidation,
    defaultAndMaxValueValidation: labelDefaultAndMaxValueValidation,
    attributeMinimumValueError: labelAttributeMinimumValueError,
    confirm: labelConfirm,
    timeZone: TIMEZONE
}

const NUMBER_DATATYPE_VALUE = 'Number';
const PICKLIST_DATATYPE_VALUE = 'Picklist';
const TEXT_DATATYPE_VALUE = 'Text';
const DATE_DATATYPE_VALUE = 'Date';
const DATETIME_DATATYPE_VALUE = 'Datetime';
const BOOLEAN_DATATYPE_VALUE = 'Boolean';
const MAX_TEXT_LENGTH = 80;

export default class TemplateItemDetail extends LightningElement {

    @track _templateItem = this.initializeTemplateItemRecord();
    @track _modalOpen = false;
    @track error;
    @track recordInfo = {};
    @track picklistValues = [];
    @track hideRequiredField = false;
    @track hideReadOnlyField = false;

    /**
    * If present, displays the step configuration dialog
    * @type {boolean}
    * @default false
    */
    @api
    get modalOpen () {
        return this._modalOpen;
    }
    set modalOpen (newValue) {
        this._modalOpen = newValue;
    }

    /**
    * This value represents a record from the Template Item object.
    * @type {object}
    */
    @api
    get templateItemRecord () {
        if (!this._templateItem) {
            this._templateItem = this.initializeTemplateItemRecord();
        }

        return this._templateItem;
    }
    set templateItemRecord (newValue) {
        if (!newValue) {
            this._templateItem = null;
            return;
        }

        this._templateItem = deepCopy(newValue);
        if ( this._templateItem.isReadOnly ) {
            this.hideRequiredField = true;
        } else if ( this._templateItem.isRequired ) {
            this.hideReadOnlyField = true;
        }
    }

    get i18n () {
        return i18n;
    }

    @api fetchAttributeDetails (techAttributeId) {
        getTechnicalAttribute({ attributeId: techAttributeId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const attributeDetails = JSON.parse(JSON.stringify(result.data));
                this.populateAttributeRecordInfo(attributeDetails);
            }).catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.error = null;
            });
    }

    populateAttributeRecordInfo (data) {
        this.recordInfo = { ...this.recordInfo, ...data };
        if (data.dataType === PICKLIST_DATATYPE_VALUE) {
            this.picklistValues = data?.picklistDefinition?.values?.split(';');
        }
    }

    get picklistOptions () {
        const options = this.picklistValues.map(item => {
            return {
                label: item,
                value: item
            };
        });
        return options;
    }

    get isNumberType () {
        return this.recordInfo.dataType === NUMBER_DATATYPE_VALUE;
    }

    get isPicklistType () {
        return this.recordInfo.dataType === PICKLIST_DATATYPE_VALUE;
    }

    get isBooleanType () {
        return this.recordInfo.dataType === BOOLEAN_DATATYPE_VALUE;
    }

    get isDateType () {
        return this.recordInfo.dataType === DATE_DATATYPE_VALUE;
    }

    get isDateTimeType () {
        return this.recordInfo.dataType === DATETIME_DATATYPE_VALUE;
    }

    get isTextType () {
        return (isUndefinedOrNull(this.recordInfo.dataType) ||
            this.recordInfo.dataType === TEXT_DATATYPE_VALUE );
    }

    get tooLongMessage () {
        return formatString(i18n.tooLong, MAX_TEXT_LENGTH);
    }

    get stepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 14, 4);
    }

    handleDefaultValueChanged (event) {
        const targetElement = event.target;
        if ( targetElement.type === 'checkbox' ) {
            this._templateItem.defaultValue = event.target.checked;
        } else {
            this._templateItem.defaultValue = event.target.value;
        }
    }

    handleMessageChanged (event) {
        this.handleTextInputChange('message', event.target.value);
    }

    handlehelpTextChanged (event) {
        this.handleTextInputChange('helpText', event.target.value);
    }

    handleReadOnlyChanged (event) {
        this._templateItem.isReadOnly = event.target.checked;
        this.hideRequiredField = false;
        if ( this._templateItem.isReadOnly ) {
            this.hideRequiredField = true;
        }
    }

    handleRequiredChanged (event) {
        this._templateItem.isRequired = event.target.checked;
        this.hideReadOnlyField = false;
        if ( this._templateItem.isRequired ) {
            this.hideReadOnlyField = true;
        }
    }

    handleMaximumValueChanged (event) {
        this._templateItem.maximumValue = event.target.value;
    }

    handleMinimumValueChanged (event) {
        this._templateItem.minimumValue = event.target.value;
    }

    handleTextInputChange (fieldName, value) {
        let newValue = value;
        if (newValue) {
            newValue = value.trim();
        }

        this._templateItem[fieldName] = newValue;
    }

    get isNumber () {
        if ( this._templateItem.dataType === 'Number' ) {
            return true;
        }
        return false;
    }

    get badInputMessage () {
        return formatString(i18n.badInputDate, i18n.shortDateFormat);
    }

    handleCancelModal () {
        this.clearState();
        this.dispatchEvent(
            new CustomEvent('templateitemclosed')
        );
    }

    handleSave () {
        if (!this.isValidInput()) return;
        this._templateItem.defaultValue = this._templateItem.defaultValue?
            this._templateItem.defaultValue.toString() : '';
        this.dispatchChangeEvent(Object.assign({}, this._templateItem));
        this.clearState();
    }

    isValidInput () {
        let isValid = true;
        this.error = '';

        isValid = this.validateNumberInput();

        isValid = [...this.template.querySelectorAll(
            '.svmx-technical-item-detail_input-field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);


        if (!isValid) {
            this.error = this.i18n.formValidation;
        }
        return isValid;
    }

    validateNumberInput () {
        let isValid = true;
        if (this.isNumberType) {
            this._templateItem.minimumValue =
                isEmptyString(this._templateItem.minimumValue) ? null :
                parseFloat(this._templateItem.minimumValue);
            this._templateItem.maximumValue =
                isEmptyString(this._templateItem.maximumValue) ? null :
                parseFloat(this._templateItem.maximumValue);
            this._templateItem.defaultValue =
                isEmptyString(this._templateItem.defaultValue) ? null :
                parseFloat(this._templateItem.defaultValue);

            const minValueInput = this.template.querySelector(
                '.item-minimum');
            const defaultValueInput = this.template.querySelector(
                '.svmx-technical-item-detail_default-value');

            if ( (this._templateItem.minimumValue && this._templateItem.maximumValue) &&
                ( this._templateItem.minimumValue >= this._templateItem.maximumValue )) {
                minValueInput.setCustomValidity(this.i18n.attributeMinimumValueError);
                isValid = false;
            } else {
                minValueInput.setCustomValidity('');
            }
            minValueInput.reportValidity();
            if (isValid) {
                if ( (this._templateItem.defaultValue && this._templateItem.minimumValue ) &&
                    (this._templateItem.defaultValue < this._templateItem.minimumValue ) ) {
                    defaultValueInput.setCustomValidity(this.i18n.defaultAndMinValueValidation);
                    isValid = false;
                } else if ((this._templateItem.defaultValue && this._templateItem.maximumValue) &&
                    (this._templateItem.defaultValue > this._templateItem.maximumValue)) {
                    defaultValueInput.setCustomValidity(this.i18n.defaultAndMaxValueValidation);
                    isValid = false;
                } else {
                    defaultValueInput.setCustomValidity('');
                }
                defaultValueInput.reportValidity();
            }
        }
        return isValid;
    }

    clearState () {
        this.hideRequiredField = false;
        this.hideReadOnlyField = false;
        this._templateItem = this.initializeTemplateItemRecord();
    }

    dispatchChangeEvent (changedValue) {
        this.dispatchEvent(
            new CustomEvent('templateitemchanged', {
                detail: {
                    value: changedValue
                }
            })
        );
    }

    initializeTemplateItemRecord () {
        return {
            attributeId: null,
            attributeName: null,
            categoryId: null,
            defaultValue: null,
            developerName: null,
            helpText: null,
            isReadOnly: false,
            isRequired: false,
            maximumValue: null,
            minimumValue: null,
            status: null,
            templateId: null,
            dataType: null,
            sequence: null,
            message: null,
            name: null
        };
    }

}