import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import saveTechnicalAttribute
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveTechnicalAttribute';
import getTechnicalAttribute
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getTechnicalAttributeWithDetails';



import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    normalizeDeveloperName,
    isUndefinedOrNull,
    isEmptyString,
    PAGE_ACTION_TYPES
} from 'c/utils';

//Get objinfo from SM_TA_TechnicalAttribute__c object
import TECHNICALATTRIBUTE_OBJ from '@salesforce/schema/SM_TA_TechnicalAttribute__c';
//Get unit info field from SM_TA_TechnicalAttribute__c object
import UNIT_FIELD from '@salesforce/schema/SM_TA_TechnicalAttribute__c.Unit__c';
import DATATYPE_FIELD from '@salesforce/schema/SM_TA_TechnicalAttribute__c.DataType__c';

import labelNewAttribute from '@salesforce/label/c.Label_NewAttribute';
import labelName from '@salesforce/label/c.Label_Name';
import labelUnits from '@salesforce/label/c.Label_Units';
import labelType from '@salesforce/label/c.Label_Type';

import labelDefaultValue from '@salesforce/label/c.Label_DefaultValue';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelMinimumValue from '@salesforce/label/c.Label_MinimumValue';
import labelMaximumValue from '@salesforce/label/c.Label_MaximumValue';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelHelpText from '@salesforce/label/c.Label_HelpText';
import labelWarningText from '@salesforce/label/c.Label_WarningText';
import labelPicklistValues from '@salesforce/label/c.Label_PicklistValues';
import labelAddValue from '@salesforce/label/c.Label_AddValue';
import buttonSaveAndNew from '@salesforce/label/c.Button_SaveAndNew';
import labelDeveloperNamePlaceholder from '@salesforce/label/c.Label_DeveloperNamePlaceholder';
import labelAttributeCreatedMsg from '@salesforce/label/c.Label_AttributeCreatedMsg';
import labelAttributeUpdatedMsg from '@salesforce/label/c.Label_AttributeUpdatedMsg';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelSave from '@salesforce/label/c.Button_Save';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelClone from '@salesforce/label/c.Menu_Clone';
import labelSaveAndClone from '@salesforce/label/c.Button_SaveAndClone';
import labelAttributeErrMsg from '@salesforce/label/c.Label_AttributeErrMsg';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelUniquenessCheck from '@salesforce/label/c.Label_UniquenessCheck';
import labelAttributeUniqueError from '@salesforce/label/c.Label_AttributeUniqueError';
import labelAttributeMinimumValueError
    from '@salesforce/label/c.Label_AttributeMinimumValueError';
import labelDefaultAndMinValueValidation
    from '@salesforce/label/c.Label_DefaultAndMinValueValidation';
import labelDefaultAndMaxValueValidation
    from '@salesforce/label/c.Label_DefaultAndMaxValueValidation';
import TIMEZONE from '@salesforce/i18n/timeZone';

const i18n = {
    newAttribute: labelNewAttribute,
    name: labelName,
    units: labelUnits,
    type: labelType,
    defaultValue: labelDefaultValue,
    developerName: labelDeveloperName,
    minimumValue: labelMinimumValue,
    maximumValue: labelMaximumValue,
    description: labelDescription,
    helpText: labelHelpText,
    warningText: labelWarningText,
    picklistValues: labelPicklistValues,
    addValue: labelAddValue,
    saveAndNew: buttonSaveAndNew,
    developerNamePlaceholder: labelDeveloperNamePlaceholder,
    valueMissing: labelEnterValue,
    tooLong: labelMaxLength,
    badInputDate: labelBadInputDate,
    shortDateFormat: shortDateFormat,
    cancel: labelCancel,
    confirm: labelConfirm,
    delete: labelDelete,
    edit: labelEdit,
    save: labelSave,
    createdMsg: labelAttributeCreatedMsg,
    updatedMsg: labelAttributeUpdatedMsg,
    success: labelSuccess,
    outOfRangeNumber: labelOutOfRangeNumber,
    formValidation: labelFormValidation,
    reviewError: labelReviewError,
    clone: labelClone,
    saveAndClone: labelSaveAndClone,
    attributeErrMsg: labelAttributeErrMsg,
    copyOf: labelCopyOf,
    duplicate: labelUniquenessCheck,
    attributeUniqueError: labelAttributeUniqueError,
    attributeMinimumValueError: labelAttributeMinimumValueError,
    defaultAndMinValueValidation: labelDefaultAndMinValueValidation,
    defaultAndMaxValueValidation: labelDefaultAndMaxValueValidation,
    timeZone: TIMEZONE,
}

const MAX_TEXT_LENGTH = 80;
const DASH = ' - ';
const NUMBER_DATATYPE_VALUE = 'Number';
const PICKLIST_DATATYPE_VALUE = 'Picklist';
const TEXT_DATATYPE_VALUE = 'Text';
const DATE_DATATYPE_VALUE = 'Date';
const DATETIME_DATATYPE_VALUE = 'Datetime';
const BOOLEAN_DATATYPE_VALUE = 'Boolean';
const MODULENAME = 'Technical Attribute';
const CLONE_NAME_PREFIX = i18n.copyOf;

export default class TechnicalAttributeDetail extends LightningElement {


    @track recordInfo = {};
    @track editMode = false;
    @track viewModalOpened = false;
    @track error;
    @track apiInProgress = false;

    @track attributeModalOpen = false;
    @track unitOptions = [];
    @track unitPicklistOptions = [];
    @track dataTypeOptions = [];
    @track picklistValues = [];
    @track dragStartIndex;
    picklistValue='';
    currentRecordId;
    actionName;

    @wire(getObjectInfo, { objectApiName: TECHNICALATTRIBUTE_OBJ })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: UNIT_FIELD
    })
    setUnitOptions ({ error, data }) {
        if (data) {
            if (data.values?.length > 0 ) {
                data.values.forEach(row => {
                    const option = {
                        label: row.label+DASH+row.value,
                        value: row.value
                    }
                    this.unitOptions.push(option);
                });
                this.unitPicklistOptions = data.values;
            }
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: DATATYPE_FIELD
    })
    setDataTypeOptions ({ error, data }) {
        if (data) {
            this.dataTypeOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    handleEdit () {
        this.editMode = true;
    }

    get i18n () {
        return i18n;
    }

    get maxLength () {
        return MAX_TEXT_LENGTH;
    }

    get badInputMessage () {
        return formatString(i18n.badInputDate, i18n.shortDateFormat);
    }

    get stepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 14, 4);
    }

    get tooLongMessage () {
        return formatString(i18n.tooLong, MAX_TEXT_LENGTH);
    }

    get viewMode () {
        return (!this.editMode);
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

    get picklistValeusAsPills () {
        const pills = this.picklistValues.map(item => {
            return {
                type: 'icon',
                label: item,
                name: item,
                alternativeText: item,
            };
        });
        return pills;
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

    get developerNameDisabled () {
        return (this.actionName === PAGE_ACTION_TYPES.VIEW ||
            this.actionName === PAGE_ACTION_TYPES.EDIT);
    }

    get detailModalTitle () {
        return this.developerNameDisabled ?
            this.recordInfo.name :  i18n.newAttribute;
    }

    get unitLabel () {
        return this.getPicklistValueLabel(this.unitPicklistOptions,this.recordInfo.unit);
    }

    get dataTypeLabel () {
        return this.getPicklistValueLabel(this.dataTypeOptions,this.recordInfo.dataType);
    }

    @api
    handleNewAttribute () {
        this.actionName = PAGE_ACTION_TYPES.NEW;
        this.editMode = true;
        this.attributeModalOpen = true;
        this.recordInfo.dataType = TEXT_DATATYPE_VALUE;
    }

    @api
    handleEditAttribute (attributeRecordId,action) {
        this.currentRecordId = attributeRecordId;
        this.actionName = action;
        if (this.actionName === PAGE_ACTION_TYPES.VIEW) {
            this.editMode = false;
            this.viewModalOpened = true;
        } else {
            this.editMode = true;
        }
        getTechnicalAttribute({ attributeId: this.currentRecordId })
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
                this.attributeModalOpen = true;
                this.currentRecordId = undefined;
            });
    }

    populateAttributeRecordInfo (data) {
        this.recordInfo = { ...this.recordInfo, ...data };
        if (data.dataType === PICKLIST_DATATYPE_VALUE) {
            this.picklistValues = data?.picklistDefinition?.values?.split(';');
        }
        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
            this.markAsClone(CLONE_NAME_PREFIX);
        }
    }

    getPicklistValueLabel (picklistOptions,value) {
        let picklistOption={};
        if (picklistOptions?.length > 0 && value) {
            picklistOption = picklistOptions.find(
                item => item.value === value);
        }
        return picklistOption?.label ? picklistOption.label : null;
    }

    markAsClone (namePrefix) {
        this.recordInfo.name = namePrefix + ' ' + this.recordInfo.name;
        this.recordInfo.id = null;
        if (this.isPicklistType) {
            this.recordInfo.picklistDefinition.id = null;
        }
        this.recordInfo.developerName = null;
        this.handleOnBlur();
    }

    handleClone () {
        this.actionName = PAGE_ACTION_TYPES.CLONE;
        this.markAsClone(CLONE_NAME_PREFIX);
        this.handleEdit();
    }

    handleChange (event) {
        const targetElement = event.target;
        this.recordInfo[targetElement.dataset.field] = ( targetElement.type === 'checkbox' )?
            targetElement.checked : targetElement.value;
        if (targetElement.label === this.i18n.developerName) {
            const devNameInput = this.template.querySelector(
                '.svmx-technical-attribute-detail_developerName');
            devNameInput.setCustomValidity('');
            devNameInput.reportValidity();
        }
    }

    handleTypeChange (event) {
        this.recordInfo.dataType = event.detail.value;
        this.recordInfo.defaultValue = null;
    }

    handleOnBlur () {
        if (!this.recordInfo.developerName && this.recordInfo.dataType) {
            let devName ='';
            if (this.recordInfo.name) {
                devName = this.recordInfo.name;
            }
            devName = devName+' '+this.recordInfo.dataType;
            if (this.recordInfo.unit) {
                devName = devName+' '+this.recordInfo.unit;
            }
            this.recordInfo.developerName = normalizeDeveloperName(
                devName.trim(),
                MAX_TEXT_LENGTH,
                ''
            );
        }
    }

    handleCommitPicklist (event) {
        const value = event.target.value.trim();
        if (!value) {
            return;
        }
        this.picklistValues = this.picklistValues.concat(value);
        this.picklistValue = null;

        this.template.querySelectorAll('.addValueInput').forEach(each => {each.value = '';});
        if (this.picklistValues?.length > 0 ) {
            const addValueInputInput = this.template.querySelector('.addValueInput');
            addValueInputInput.setCustomValidity('');
            addValueInputInput.reportValidity();
        }
    }

    handlePillRemove (event) {
        const value = event.detail.name;
        if (value) {
            this.picklistValues = this.picklistValues.filter(
                item => item !== value);
        }
    }

    handleDragStart (event) {
        const index = event.target.dataset.seq;
        this.dragStartIndex = index;
        event.target.classList.add("drag");
    }

    handleDragOver (event) {
        event.preventDefault();
        return false;
    }

    handleDrop (event) {
        const index = event.target.dataset.seq;
        const dropValName = index;
        const dragValName = this.dragStartIndex;
        if (dragValName === dropValName) {
            return;
        }
        const currentIndex = dragValName;
        const newIndex = dropValName;
        const values = JSON.parse(JSON.stringify(this.picklistValues));
        const removedTargetValue = values.splice(currentIndex, 1)[0];
        values.splice(newIndex, 0, removedTargetValue);

        this.picklistValues = values;
    }

    handleSave (event) {
        if (!this.isValidInput()) return;

        if (this.apiInProgress) return;

        const saveActionName = event.target.dataset.name;
        this.apiInProgress = true;
        if (this.isPicklistType) {
            this.populatePicklistDefinition(this.recordInfo);
        }
        this.recordInfo.defaultValue = this.recordInfo.defaultValue?
            this.recordInfo.defaultValue.toString() : '';
        saveTechnicalAttribute({ requestJson: JSON.stringify(this.recordInfo) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    const message = result.message.toLowerCase();
                    if (message.indexOf(this.i18n.duplicate.toLowerCase()) >= 0) {
                        this.error = this.i18n.formValidation;
                        const devNameInput = this.template.querySelector(
                            '.svmx-technical-attribute-detail_developerName');
                        devNameInput.setCustomValidity(this.i18n.attributeUniqueError);
                        devNameInput.reportValidity();
                    } else {
                        this.error = message;
                    }
                    return;
                }
                //dispatch event to refresh the list view
                const attributeRecord = JSON.parse(JSON.stringify(result.data));
                this.handleCloseAndRefresh(attributeRecord);
                const toastMsg = `${this.recordInfo.id ?
                    this.i18n.updatedMsg : this.i18n.createdMsg} - ${result.data.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleTechnicalAttributeCancel();

                if (saveActionName === 'saveAndNew') {

                    window.clearTimeout(this.delayTimeout);
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    this.delayTimeout = setTimeout(() => {
                        //call new Technical Attribute function for save and new action
                        this.handleNewAttribute ();
                    }, 1000);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    populatePicklistDefinition (data) {
        const picklistDef = {};
        const valueSet = this.picklistValues?.length > 0 ? this.picklistValues.join(';') : '';
        picklistDef.id = data?.picklistDefinition?.id;
        picklistDef.name = data.name;
        picklistDef.developerName = data.developerName;
        picklistDef.description = data.description;
        picklistDef.type = MODULENAME;
        picklistDef.values = valueSet;
        picklistDef.defaultValue = data.defaultValue;
        this.recordInfo.picklistDefinition = picklistDef;
    }

    isValidInput () {
        let isValid = true;
        this.error = '';
        if (this.isPicklistType) {
            const addValueInputInput = this.template.querySelector('.addValueInput');
            if (this.picklistValues?.length === 0) {
                addValueInputInput.setCustomValidity(this.i18n.attributeErrMsg);
                isValid = false;
            } else {
                addValueInputInput.setCustomValidity('');
            }
            addValueInputInput.reportValidity();
        }

        isValid = this.validateNumberInput();

        isValid = [...this.template.querySelectorAll(
            '.svmx-technical-attribute-detail_input-field')]
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
            this.recordInfo.minimumValue = isEmptyString(this.recordInfo.minimumValue) ? null :
                parseFloat(this.recordInfo.minimumValue);
            this.recordInfo.maximumValue = isEmptyString(this.recordInfo.maximumValue) ? null :
                parseFloat(this.recordInfo.maximumValue);
            this.recordInfo.defaultValue = isEmptyString(this.recordInfo.defaultValue) ? null :
                parseFloat(this.recordInfo.defaultValue);

            const minValueInput = this.template.querySelector(
                '.svmx-technical-attribute-detail_minimumValue');
            const defaultValueInput = this.template.querySelector(
                '.svmx-technical-attribute-detail_default-value');

            if ( (this.recordInfo.minimumValue && this.recordInfo.maximumValue) &&
                ( this.recordInfo.minimumValue >= this.recordInfo.maximumValue )) {
                minValueInput.setCustomValidity(this.i18n.attributeMinimumValueError);
                isValid = false;
            } else {
                minValueInput.setCustomValidity('');
            }
            minValueInput.reportValidity();
            if (isValid) {
                if ( (this.recordInfo.defaultValue && this.recordInfo.minimumValue ) &&
                    (this.recordInfo.defaultValue < this.recordInfo.minimumValue ) ) {
                    defaultValueInput.setCustomValidity(this.i18n.defaultAndMinValueValidation);
                    isValid = false;
                } else if ((this.recordInfo.defaultValue && this.recordInfo.maximumValue) &&
                    (this.recordInfo.defaultValue > this.recordInfo.maximumValue)) {
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

    handleCloseAndRefresh (attributeRecord) {
        this.dispatchEvent(
            new CustomEvent('closeandrefreshpage', {
                detail: {
                    value: 'success',
                    technicalAttribute: attributeRecord
                }
            })
        );
    }

    handleDelete () {
        this.dispatchEvent(
            new CustomEvent('deleterecord', {
                detail: {
                    value: this.recordInfo,
                }
            })
        );
        this.handleTechnicalAttributeCancel();
    }

    handleTechnicalAttributeCancel () {
        this.attributeModalOpen = false;
        this.viewModalOpened = false;
        this.clearValues();
    }

    clearValues () {
        this.editMode = false;
        this.recordInfo = {};
        this.picklistValues = [];
        this.error = null;
        this.actionName='';
    }

    showToast (type, title, message, variant, mode) {
        const evt = new ShowToastEvent({
            type: type,
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}