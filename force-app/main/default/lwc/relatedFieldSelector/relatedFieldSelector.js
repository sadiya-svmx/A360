import { LightningElement, track, api } from "lwc";
import {
    parseErrorMessage,
    isEmptyString,
    DATA_TYPE_ICONS,
    getCompatibleFieldsForFieldMapping,
    FIELD_DATA_TYPES,
    UNSUPPORTED_FIELD_TYPES,
    UNSUPPORTED_EVENT_FIELDS,
    SUPPORTED_USER_FIELDS,
    SUPPORTED_TRANSACTION_FIELDS,
    TRANSACTION_API_NAME
} from 'c/utils';
import {
    getFieldDefinitionsForEntities,
    getEntityDetails
} from 'c/metadataService';

import labelLoading from '@salesforce/label/c.Label_Loading';
import errorNotValid from '@salesforce/label/c.Error_NotValid';
import labelNoMatchingFieldAvailable from '@salesforce/label/c.Message_NoFieldAvailable';
import labelTarget from '@salesforce/label/c.Label_Target';
import messageSelectedField from '@salesforce/label/c.Message_SelectedField';
import messageInvalidReference from '@salesforce/label/c.Message_InvalidReference';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import label_SelectRelatedField from '@salesforce/label/c.Label_SelectRelatedField';
import btn_Cancel from '@salesforce/label/c.Btn_Cancel';
import Button_Apply from '@salesforce/label/c.Button_Apply';

const MAXLEVEL = 4;
const REFERENCE_INDICATOR = ' >';
const USER_API_NAME = 'User';

const i18n = {
    loading: labelLoading,
    noMatchingFieldAvailable: labelNoMatchingFieldAvailable,
    notValid: errorNotValid,
    target: labelTarget,
    selectedField: messageSelectedField,
    invalidReference: messageInvalidReference,
    select: labelSelect,
    title: label_SelectRelatedField,
    cancel: btn_Cancel,
    apply: Button_Apply

};
export default class RelatedFieldSelector extends LightningElement {
    @api fieldValue = '';
    @api relatedObjectDetails = '';
    @api targetField = '';
    @api objectApiName = '';
    @api objectLabelName = '';
    @api isCompatibilityFieldsRequired = false;
    @api isExpressionSelection = false;
    @api referenceLabel = '';
    @api isHeaderRecordSelected = false;
    @api sourceObjectName;
    @api removeUserObject = false;

    objectApiOptions = [];
    objectSet;
    assignedfieldValue = '';
    referenceFieldApiName = '';
    selectorModalOpen = true;
    referenceFieldLabel = '';
    error;
    _selectedObject = '';
    @track fieldsList = [];
    count = 1;
    apiInProgress = false;
    entityFieldDefinitions = {};
    options = [];
    isFieldSelected = false;
    fieldDescribeResult = {};
    compatibleFieldOptionsEmpty;
    isApplyButtondisabled = true;
    objectDetails = new Map();

    get i18n () {
        return i18n;
    }

    get targetFieldLabel () {
        return this.targetField ? this.targetField.label : '';
    }

    connectedCallback () {
        this.objectDetails[this.objectApiName] = this.objectLabelName;
        if ( this.objectApiName !== USER_API_NAME) {
            this.objectDetails.User = USER_API_NAME;
        }

        this._selectedObject = ( this.sourceObjectName ?
            this.sourceObjectName : this.objectApiName
        );

        // stores to different variable to preserve the original value
        //Emptying fieldValue when there is no object in label
        if (this.referenceLabel && this.referenceLabel.startsWith(':')) {
            this.assignedfieldValue  = '';
        } else {
            this.assignedfieldValue = this.fieldValue;
        }
        if (this.assignedfieldValue) {  //changing existing reference value 
            this.fetchObjectDetails();
        } else { //selecting new reference value 
            this.mapObjectFields([this.objectApiName, USER_API_NAME]);
            this.populateFirstReferenceLevel(this.objectApiName);
        }
    }

    async mapObjectFields (objectAPINames) {
        this.apiInProgress = true;
        let fieldDefinitions = [];
        this.fetchObjectFields(objectAPINames) //fetch object field definitions
            .then(result => {
                Array.from(result).forEach( item => {
                    let fieldDetails = [];
                    const filteredFieldDetails = [];
                    const referenceFieldDetails = [];
                    this.fieldDescribeResult[item.apiName] = item;
                    if (item.apiName === USER_API_NAME) {
                        fieldDefinitions =
                            this.getSupportedFieldsofUserObject(item.fieldDefinitions);
                    } else if (item.apiName === TRANSACTION_API_NAME) {
                        fieldDefinitions =
                            this.getSupportedFieldsofTransactionObject(item.fieldDefinitions);
                    } else {
                        fieldDefinitions = item.fieldDefinitions;
                    }
                    let referenceValue = '';
                    let referenceLabel = '';
                    //check to display only compatibility field for given target field
                    if (this.isCompatibilityFieldsRequired || this.isExpressionSelection) {
                        //reference fields of specific object to select next level and 
                        //ignoring polymorphic fields
                        fieldDefinitions.forEach ( entity => {
                            if (entity.dataType === 'REFERENCE' && entity.referenceTo.length <= 1
                                && entity.apiName !== 'OwnerId') {
                                referenceLabel = (entity.label).concat(REFERENCE_INDICATOR) ;
                                referenceValue = (entity.apiName).concat(REFERENCE_INDICATOR) ;
                                referenceFieldDetails.push({
                                    label: referenceLabel,
                                    originalLabel: entity.label,
                                    value: referenceValue,
                                    originalValue: entity.apiName,
                                    secondary: entity.apiName,
                                    iconName: DATA_TYPE_ICONS[entity.dataType],
                                    datatype: entity.dataType,
                                    referenceTo: (entity.referenceTo &&
                                        entity.referenceTo[0] !== null) ?
                                        entity.referenceTo[0] : null,
                                });
                            }
                        });
                        // Compatibility fields for specific object
                        let availableFields = [];
                        if (this.isCompatibilityFieldsRequired ||
                                (this.isExpressionSelection && this.isHeaderRecordSelected)) {
                            availableFields = getCompatibleFieldsForFieldMapping(
                                this.getEntityFields(this.fieldDescribeResult, item.apiName),
                                this.targetField,
                                item.apiName
                            );
                        }
                        if (this.isExpressionSelection && !this.isHeaderRecordSelected) {
                            availableFields = this.getCompatibleFieldsForExpression(
                                this.getEntityFields(this.fieldDescribeResult, item.apiName));
                        }
                        if (availableFields) {
                            availableFields.forEach( field => {
                                if ((item.apiName !== USER_API_NAME &&
                                        item.apiName !== TRANSACTION_API_NAME) ||
                                    (item.apiName === TRANSACTION_API_NAME &&
                                        (SUPPORTED_TRANSACTION_FIELDS.includes(field.apiName))) ||
                                    (item.apiName === USER_API_NAME
                                    && (SUPPORTED_USER_FIELDS.includes(field.apiName) ||
                                    field.apiName.endsWith('__c') ||
                                    field.apiName.endsWith('__s')))) {
                                //Compatible non reference field
                                    if (field.dataType !== 'REFERENCE') {
                                        fieldDetails.push({
                                            label: field.label,
                                            originalLabel: field.label,
                                            value: field.apiName,
                                            originalValue: field.apiName,
                                            secondary: field.apiName,
                                            iconName: DATA_TYPE_ICONS[field.dataType],
                                            datatype: field.dataType,
                                            referenceTo: (field.referenceTo &&
                                            field.referenceTo[0] !== null) ?
                                                field.referenceTo[0] : null,
                                        });
                                    } else {
                                    //Compatible reference field Ids and it shouldnot allow for 
                                    //next level so changing datatype to ID
                                        referenceLabel = (field.label).concat(REFERENCE_INDICATOR) ;
                                        referenceValue =
                                            (field.apiName).concat(REFERENCE_INDICATOR);
                                        const fieldDataType = "ID";
                                        fieldDetails.push({
                                            label: field.label,
                                            originalLabel: field.label,
                                            value: field.apiName,
                                            originalValue: field.apiName,
                                            secondary: field.apiName,
                                            iconName: DATA_TYPE_ICONS[fieldDataType],
                                            datatype: fieldDataType,
                                            referenceTo: null,
                                        });
                                    }
                                }

                            });
                        }
                        fieldDetails = [...referenceFieldDetails, ...fieldDetails];
                        fieldDetails.sort(this.compareLabel);
                    } else { //Displays all fields of specific object
                        fieldDefinitions.forEach ( entity => {
                            //reference fields of specific object to select next level and 
                            //ignoring polymorphic fields
                            if (entity.dataType === 'REFERENCE' && entity.referenceTo.length <= 1
                                && entity.apiName !== 'OwnerId') {
                                referenceLabel = (entity.label).concat(REFERENCE_INDICATOR) ;
                                referenceValue = (entity.apiName).concat(REFERENCE_INDICATOR) ;
                                fieldDetails.push({
                                    label: referenceLabel,
                                    originalLabel: entity.label,
                                    value: referenceValue,
                                    originalValue: entity.apiName,
                                    secondary: entity.apiName,
                                    iconName: DATA_TYPE_ICONS[entity.dataType],
                                    datatype: entity.dataType,
                                    referenceTo: (entity.referenceTo &&
                                        entity.referenceTo[0] !== null) ?
                                        entity.referenceTo[0] : null,
                                });
                                //reference field Ids and it shouldnot allow for next level 
                                //so changing datatype to ID
                                const fieldDataType = "ID";
                                fieldDetails.push({
                                    label: entity.label,
                                    originalLabel: entity.label,
                                    value: entity.apiName,
                                    originalValue: entity.apiName,
                                    secondary: entity.apiName,
                                    iconName: DATA_TYPE_ICONS[fieldDataType],
                                    datatype: fieldDataType,
                                    referenceTo: null,
                                });
                            } else if (entity.dataType !== 'REFERENCE') { //Non reference fields
                                fieldDetails.push({
                                    label: entity.label,
                                    originalLabel: entity.label,
                                    value: entity.apiName,
                                    originalValue: entity.apiName,
                                    secondary: entity.apiName,
                                    iconName: DATA_TYPE_ICONS[entity.dataType],
                                    datatype: entity.dataType,
                                    referenceTo: (entity.referenceTo &&
                                        entity.referenceTo[0] !== null) ?
                                        entity.referenceTo[0] : null,
                                });

                            }
                        });
                    }
                    //removing all polymorphic fields in case on Event and Task object
                    //removing Subject field which is of type COMBOBOX currently not supporting
                    if (item.apiName === 'Event' || item.apiName === 'Task') {
                        fieldDetails.forEach(field => {
                            if (!isEmptyString(field.originalValue) &&
                                !UNSUPPORTED_EVENT_FIELDS.includes(field.originalValue)) {
                                filteredFieldDetails.push(field);
                            }
                        });
                    } else  {
                        fieldDetails.forEach(field => {
                            if (!isEmptyString(field.originalLabel)) {
                                filteredFieldDetails.push(field);
                            }
                        });
                    }
                    this.entityFieldDefinitions[item.apiName] = filteredFieldDetails;
                    if (!this.assignedfieldValue) {
                        this.populateOptions(); //populate options for new reference field select
                        this.populateObjectApiOptions();
                    }
                });
                if (this.assignedfieldValue) {
                    //populate reference level for existing reference value
                    this.populateReferenceLevels();
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    async fetchObjectFields (objectNames) {
        let result = {};

        if (objectNames.size <= 0) {
            return result;
        }
        this.apiInProgress = true;
        const objectApiNameList = [...objectNames];
        try {
            const resp = await getFieldDefinitionsForEntities(objectApiNameList);
            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

        return result;
    }

    async fetchObjectDetails () { //Method to check existing reference field object are valid or not
        let result = {};
        this.apiInProgress = true;
        try {
            const resp = await getEntityDetails();
            if (resp && resp.data) {
                result = resp.data;
                result.forEach ( item => {
                    this.objectDetails[item.objectAPIName] = item.objectLabel;
                });
            }
            this.objectSet = isEmptyString(this.relatedObjectDetails) ?
                new Set() : new Set(this.relatedObjectDetails.split('.'));
            this.objectSet.add(this.objectApiName);

            if (this.objectApiName !== USER_API_NAME ) {
                this.objectSet.add(USER_API_NAME);
            }

            const invalidObject = [];
            this.objectSet.forEach( item => {
                if ( !this.objectDetails[item] ) {
                    invalidObject.push(item);
                }
            });
            if (invalidObject.length !== 0) {
                this.assignedfieldValue = '';
                this.mapObjectFields([this.objectApiName]);
                this.populateFirstReferenceLevel(this.objectApiName);
                this.error = i18n.invalidReference + this.fieldValue + i18n.notValid;
            } else {
                this.mapObjectFields(this.objectSet);
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

        return result;
    }

    handleChange (event) {
        event.preventDefault();
        this.reset();
        const value = event.target.value;
        const optionDetails = this.options.filter(item => item.value === value);

        const label = optionDetails[0].label.endsWith(REFERENCE_INDICATOR) ?
            optionDetails[0].label.replace(REFERENCE_INDICATOR, '') : optionDetails[0].label;

        if ( this.count <= MAXLEVEL) {
            this.fieldsList.push( { label: label,
                apiName: optionDetails[0].originalValue,
                name: `${this.count}`,
                id: `${this.count}`,
                referenceTo: optionDetails[0].referenceTo });
            event.target.value='';
            let objectAPIName;
            this.options = [];
            if (optionDetails[0].datatype === 'REFERENCE') {
                objectAPIName = optionDetails[0].referenceTo;
                this.options = this.entityFieldDefinitions[objectAPIName] ?
                    this.entityFieldDefinitions[objectAPIName] : [];
                if ( this.count === MAXLEVEL  && this.options ) {
                    this.removeReferenceField();
                }
                if (this.options.length === 0) {
                    this.mapObjectFields([objectAPIName]);
                }
            }
            else {
                this.isFieldSelected = true;
                this.isApplyButtondisabled = false;
                this.populateReferenceFieldApiName();
                this.populateReferenceFieldLabel();
                this.populateRelatedObjectDetails();
            }
            this.count++;
        } else if (this.count === MAXLEVEL + 1) {
            this.fieldsList.push( { label: label,
                apiName: optionDetails[0].originalValue,
                name: `${this.count}`,
                id: `${this.count}`,
                referenceTo: optionDetails[0].referenceTo });
            this.isFieldSelected = true;
            this.isApplyButtondisabled = false;
            this.populateReferenceFieldApiName();
            this.populateReferenceFieldLabel();
            this.populateRelatedObjectDetails();
        }
    }

    handleObjectChange (event) {
        event.preventDefault();
        this.reset();
        this.fieldsList = [];
        const value = event.target.value;
        const optionDetails = this.objectApiOptions.filter(item => item.value === value);
        if ( optionDetails && optionDetails.length > 0 ) {
            this.populateFirstReferenceLevel(optionDetails[0].value);
            this._selectedObject = optionDetails[0].value;

            const value1 = this.fieldsList[0].referenceTo;
            this.options = [];
            this.options = this.entityFieldDefinitions[value1] ?
                this.entityFieldDefinitions[value1] : [];
            if (this.options.length === 0) {
                this.mapObjectFields([value1]);
            } else {
                if ( MAXLEVEL === 0 ) {
                    this.removeReferenceField();
                }
                this.compatibleFieldOptionsEmpty = (this.options.length === 0 &&
                    !this.isFieldSelected);
            }

            this.populateReferenceFieldApiName();
            this.populateReferenceFieldLabel();
            this.populateRelatedObjectDetails();
        }
    }

    handleNavigateTo (event) {
        // prevent default navigation by href
        event.preventDefault();
        this.reset();

        const name = event.target.name;
        if (name > 0) {
            this.fieldsList = this.fieldsList.slice(0,name);
            this.count = Number(name);
        } else if (name === '0' && !this.isCompatibilityFieldsRequired) {
            this.fieldsList = [];
            this.count = 1;
        } else {
            this.fieldsList =this.fieldsList.slice(0,1);
            this.count = 1;
        }
        const fieldListLength = this.fieldsList.length;
        if ( fieldListLength !== 0 ) {
            const value = this.fieldsList[fieldListLength - 1].referenceTo;
            this.options = [];
            this.options = this.entityFieldDefinitions[value] ?
                this.entityFieldDefinitions[value] : [];
            if (this.options.length === 0) {
                this.mapObjectFields([value]);
            } else {
                if ( fieldListLength - 1 === MAXLEVEL ) {
                    this.removeReferenceField();
                }
                this.compatibleFieldOptionsEmpty = (this.options.length === 0
                    && !this.isFieldSelected);
            }
        }
        else {
            this.populateObjectApiOptions();
        }
    }

    get isFieldsListEmpty () {
        return this.fieldsList && this.fieldsList.length > 0 ? false : true;
    }

    populateOptions () {
        const fieldListLength = this.fieldsList.length;
        const value = this.fieldsList[fieldListLength - 1].referenceTo;

        this.options = this.entityFieldDefinitions[value] ? this.entityFieldDefinitions[value] : [];
        if ( fieldListLength - 1 === MAXLEVEL) {
            this.removeReferenceField();
        }
        this.compatibleFieldOptionsEmpty = this.options.length === 0 && !this.isFieldSelected;
    }

    populateObjectApiOptions () {
        this.objectApiOptions = [{ label: this.objectLabelName, value: this.objectApiName }];
        // eslint-disable-next-line max-len  
        if ( !this.removeUserObject && this.objectApiName !== USER_API_NAME && this.objectApiName !== TRANSACTION_API_NAME) {
            this.objectApiOptions = [...this.objectApiOptions,
                { label: USER_API_NAME, value: USER_API_NAME }];
        }

    }

    populateReferenceLevels () {
        const referenceFieldArray = this.assignedfieldValue.includes('.') ?
            this.assignedfieldValue.split('.') : [this.assignedfieldValue];
        referenceFieldArray.splice(0, 0, this._selectedObject)
        this.populateFirstReferenceLevel(this._selectedObject);
        this.isFieldSelected = true;
        for (let index = 1; index < referenceFieldArray.length; index++) {
            if ( index !== referenceFieldArray.length - 1) {
                if (referenceFieldArray[index].endsWith('__r')) {
                    referenceFieldArray[index] = referenceFieldArray[index].replace(/__r$/i, '__c');
                }

                // Resolve standard field relationship name to field name
                if (!/__c$/i.test(referenceFieldArray[index])) {
                    referenceFieldArray[index] += 'Id';
                }
                referenceFieldArray[index] += REFERENCE_INDICATOR;
            }
            let isFieldFound = false;
            this.entityFieldDefinitions[this.fieldsList[index-1].referenceTo].forEach(fieldkey => {
                if (fieldkey.value === referenceFieldArray[index]) {
                    this.fieldsList.push( { label: fieldkey.originalLabel,
                        apiName: fieldkey.originalValue ,
                        name: `${this.count}`,
                        id: `${this.count}`,
                        referenceTo: fieldkey.referenceTo });
                    this.count++;
                    isFieldFound = true;
                }
            });
            if (!isFieldFound) {
                let relatedField = referenceFieldArray[index].endsWith(REFERENCE_INDICATOR) ?
                    referenceFieldArray[index].substring(0, referenceFieldArray[index].length - 1) :
                    referenceFieldArray[index];
                relatedField = relatedField.endsWith('Id') ?
                    relatedField.replace('Id','') : relatedField;
                this.error = i18n.invalidReference + this.fieldValue + i18n.notValid;
                this.populateOptions();
                this.populateObjectApiOptions();
                this.isFieldSelected = false;
                this.isApplyButtondisabled = true;
                break;
            }
        }
        this.referenceFieldApiName = this.assignedfieldValue;
        this.populateReferenceFieldLabel();
        this.assignedfieldValue = '';
    }

    populateFirstReferenceLevel (parentObjectString) {
        this.fieldsList.push( { label: this.objectDetails[parentObjectString],
            apiName: parentObjectString,
            name: `0`,
            id: `0`,
            referenceTo: parentObjectString });
    }

    populateReferenceFieldApiName () {
        this.referenceFieldApiName = '';
        if (this.fieldsList && this.fieldsList.length > 0) {
            for (let index = 1; index < this.fieldsList.length; index++) {
                if ( index !== this.fieldsList.length - 1 ) {
                    if (this.fieldsList[index].apiName.endsWith('__c')) {
                        this.referenceFieldApiName = this.referenceFieldApiName.concat(
                            this.fieldsList[index].apiName.replace(/__c$/i, '__r'),'.');
                    // Resolve standard field relationship name to field name
                    } else if (this.fieldsList[index].apiName.endsWith('Id')) {
                        this.referenceFieldApiName = this.referenceFieldApiName.concat(
                            this.fieldsList[index].apiName.replace(/Id$/i, ''),'.');
                    } else {
                        this.referenceFieldApiName = this.referenceFieldApiName.concat(
                            this.fieldsList[index].apiName,'.');
                    }
                }
                else {
                    this.referenceFieldApiName = this.referenceFieldApiName.concat(
                        this.fieldsList[index].apiName);
                }
            }
        }
    }

    populateReferenceFieldLabel () {
        const objectLabel = this.objectDetails[this._selectedObject] + ': ';
        this.referenceFieldLabel = objectLabel;
        if (this.fieldsList && this.fieldsList.length > 0) {
            for (let index = 1; index < this.fieldsList.length; index++) {
                if ( index !== this.fieldsList.length - 1 ) {
                    this.referenceFieldLabel += this.fieldsList[index].label + ' > ';
                }
                else {
                    this.referenceFieldLabel += this.fieldsList[index].label;
                }
            }
        }
    }

    populateRelatedObjectDetails () {
        this.targetRelatedObjectDetails = '';
        if (this.fieldsList && this.fieldsList.length > 0) {
            for (let index = 1; index < this.fieldsList.length-1; index++) {
                if ( index !== this.fieldsList.length - 2 ) {
                    this.targetRelatedObjectDetails =
                    this.targetRelatedObjectDetails.concat(this.fieldsList[index].referenceTo,'.');
                } else {
                    this.targetRelatedObjectDetails =
                    this.targetRelatedObjectDetails.concat(this.fieldsList[index].referenceTo);
                }
            }
        }
    }

    removeReferenceField () {
        const options = [];
        this.options.forEach((item) => {
            if ( this.isExpressionSelection && item.datatype !== 'REFERENCE' &&
                item.datatype !== 'ID' ) {
                options.push(item);
            } else if ( !this.isExpressionSelection && item.datatype !== 'REFERENCE') {
                options.push(item);
            }
        });
        this.options = [];
        this.options = options;
    }

    handleCancelModal () {
        const objectList = this.relatedObjectDetails ? this.relatedObjectDetails.split(".") :
            new Array(this.objectApiName);
        let fieldList = [];
        if (this.fieldValue) {
            fieldList = this.fieldValue.includes(".") ? this.fieldValue.split(".") :
                new Array(this.fieldValue);
        }
        let fieldDefinitionsList = [];
        if (objectList.length > 1 && this.fieldDescribeResult[objectList[objectList.length - 1]]) {
            fieldDefinitionsList =
                this.fieldDescribeResult[objectList[objectList.length - 1]].fieldDefinitions;
        } else if (objectList.length === 1 && this.fieldDescribeResult[objectList[0]]) {
            fieldDefinitionsList = this.fieldDescribeResult[objectList[0]].fieldDefinitions;
        }
        let fieldDefinition;
        if (fieldDefinitionsList.length > 0 && fieldList.length > 0) {
            fieldDefinition = fieldDefinitionsList.find(
                sourceField => sourceField.apiName === fieldList[fieldList.length - 1]
            );
        }
        this.dispatchEvent(
            new CustomEvent('cancelmodal', {
                composed: true,
                bubbles: true,
                detail: {
                    valueSelected: this.fieldValue,
                    objectSelected: this.relatedObjectDetails,
                    fieldDefinition: fieldDefinition,
                    label: this.referenceLabel
                }
            })
        );
        this.selectorModalOpen = false;
    }

    handleApply () {
        const sourceObjectName = (
            this._selectedObject && this._selectedObject === this.objectApiName ?
                '' : this._selectedObject);
        const objectList = this.targetRelatedObjectDetails ?
            this.targetRelatedObjectDetails.split(".") : new Array(this._selectedObject);
        const fieldList = this.referenceFieldApiName.includes(".") ?
            this.referenceFieldApiName.split(".") : new Array(this.referenceFieldApiName);
        let fieldDefinitionsList;
        if ( objectList.length > 1) {
            fieldDefinitionsList =
                this.fieldDescribeResult[objectList[objectList.length - 1]].fieldDefinitions;
        } else if (objectList.length === 1 ) {
            fieldDefinitionsList = this.fieldDescribeResult[objectList[0]].fieldDefinitions;
        }
        const fieldDefinition = fieldDefinitionsList.find(
            sourceField => sourceField.apiName === fieldList[fieldList.length - 1]
        );
        this.dispatchEvent(
            new CustomEvent('relatedpicklistselected', {
                composed: true,
                bubbles: true,
                detail: {
                    valueSelected: this.referenceFieldApiName,
                    objectSelected: this.targetRelatedObjectDetails,
                    sourceObjectName: sourceObjectName,
                    fieldDefinition: fieldDefinition,
                    label: this.referenceFieldLabel
                }
            })
        );
        this.selectorModalOpen = false;
    }

    getEntityFields (entityDefinitions, propertyName) {
        if (entityDefinitions && Reflect.has(entityDefinitions, propertyName)) {
            const entity = Reflect.get(entityDefinitions, propertyName);
            const fieldDefinitionsPropertyName = 'fieldDefinitions';
            if (entity && Reflect.has(entity, fieldDefinitionsPropertyName)) {
                return Reflect.get(entity, fieldDefinitionsPropertyName);
            }
        }

        return [];
    }

    reset () {
        this.isFieldSelected = false;
        this.isApplyButtondisabled = true;
        this.compatibleFieldOptionsEmpty = false;
        this.error = '';
        this.referenceFieldApiName = '';
        this.targetRelatedObjectDetails ='';
    }

    compareLabel ( a, b) {
        const fa = a.label.toLowerCase(),
            fb = b.label.toLowerCase();
        if (fa < fb) {
            return -1;
        }
        if (fa > fb) {
            return 1;
        }
        return 0;

    }

    getCompatibleFieldsForExpression (fieldDefinitionList) {
        const fieldList = [];
        const removedfieldList = [];
        fieldDefinitionList.forEach(field => {
            if (field.filterable &&
                field.apiName.toLowerCase() !== 'id' &&
                !(UNSUPPORTED_FIELD_TYPES.has(field.dataType)) &&
                !(field.dataType === FIELD_DATA_TYPES.REFERENCE
                    && field.referenceTo.length === 0
                    && field.apiName !== 'RecordTypeId') &&
                    (field.dataType !== FIELD_DATA_TYPES.TIME)) {
                fieldList.push(field);
            }
            else {
                removedfieldList.push(field);
            }
        });
        return fieldList;
    }

    getSupportedFieldsofUserObject (userFieldDefinitions) {
        const fieldDefinitions = [];
        userFieldDefinitions.forEach(item => {
            if (SUPPORTED_USER_FIELDS.includes(item.apiName)) {
                fieldDefinitions.push (item);
            }
        });
        return fieldDefinitions;
    }
    getSupportedFieldsofTransactionObject (transFieldDefinitions) {
        const fieldDefinitions = [];
        transFieldDefinitions.forEach(item => {
            if (SUPPORTED_TRANSACTION_FIELDS.includes(item.apiName)) {
                fieldDefinitions.push (item);
            }
        });
        return fieldDefinitions;
    }
}