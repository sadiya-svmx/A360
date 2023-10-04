import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import {
    FIELD_DATA_TYPES,
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    isEmptyString,
    isNotUndefinedOrNull,
    IS_MOBILE_DEVICE,
    IS_PHONE_DEVICE,
    isElementOverflowingViewport,
    debounce
} from 'c/utils';
import fetchAttributesForAsset
    from '@salesforce/apex/TA_TechnicalAttribute_LS.fetchAttributesForAsset';
import saveAttributeRecords
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveAttributeRecords';
import fetchCurrentLoggedInUser
    from '@salesforce/apex/TA_TechnicalAttribute_LS.fetchCurrentLoggedInUser';
import { loadStyle } from 'lightning/platformResourceLoader';
import contractLineItemsListViewResource from '@salesforce/resourceUrl/contractLineItemsListView';

import ASSET_OBJ from '@salesforce/schema/Asset';
import WORKORDER_OBJ from '@salesforce/schema/WorkOrder';

import ASSET_ID_FIELD from '@salesforce/schema/Asset.Id';
import ASSET_NAME_FIELD from '@salesforce/schema/Asset.Name';

import TECHNICALATTRIBUTE_OBJ from '@salesforce/schema/SM_TA_TechnicalAttribute__c';
import UNIT_FIELD from '@salesforce/schema/SM_TA_TechnicalAttribute__c.Unit__c';

import labelNoDataHeading from '@salesforce/label/c.Message_NoResults';
import labelNoDataBody from '@salesforce/label/c.MessageTechnicalAttribute_NoDataBody';
import labelErrorOccurred from '@salesforce/label/c.Label_ErrorOccurred';
import labelErrorHeading from '@salesforce/label/c.Message_AssetTimeline_Error_Heading';
import labelErrorBody from '@salesforce/label/c.Message_AssetTimeline_Error_Body';
import labelRecordNotExists from '@salesforce/label/c.Error_RecordNotExists';
import labelSidebarError from '@salesforce/label/c.Message_ViewCoverage_Sidebar_Error';
import labelDetailView from '@salesforce/label/c.Atrribute_DetailView';
import labelUpdateValues from '@salesforce/label/c.Atrribute_UpdateValues';
import labelTemplate from '@salesforce/label/c.Label_Template';
import labelSectionDescription from '@salesforce/label/c.Atrribute_sectionDescription';
import labelInfo from '@salesforce/label/c.Title_AlertInfo';
import labelWarningTitle from '@salesforce/label/c.Atrribute_WarningTitle';
import labelThresholdMessage from '@salesforce/label/c.Atrribute_ThresholdMessage';
import labelSuccessMessage from '@salesforce/label/c.Atrribute_SuccessMessage';
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
import labelReset from '@salesforce/label/c.Menu_Reset';
import labelSaveupdatesonly from '@salesforce/label/c.Button_Saveupdatesonly';
import labelSaveInfo from '@salesforce/label/c.Button_SaveInfo';
import labelSaveupdatesonlyInfo from '@salesforce/label/c.Button_SaveupdatesonlyInfo';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelMaxLength from '@salesforce/label/c.Message_ExceedsMaxLength';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import shortDateTimeFormat from '@salesforce/i18n/dateTime.shortDateTimeFormat';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import labelBadInputNumber from '@salesforce/label/c.Message_BadInputNumber';
import labelBadInputDateTime from '@salesforce/label/c.Message_BadInputDateTime';
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
    badInputNumber: labelBadInputNumber,
    badInputDateTime: labelBadInputDateTime,
    shortDateFormat: shortDateFormat,
    shortDateTimeFormat: shortDateTimeFormat,
    cancel: labelCancel,
    confirm: labelConfirm,
    delete: labelDelete,
    edit: labelEdit,
    save: labelSave,
    reset: labelReset,
    saveupdatesonly: labelSaveupdatesonly,
    saveInfo: labelSaveInfo,
    saveupdatesonlyInfo: labelSaveupdatesonlyInfo,
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
    noDataHeading: labelNoDataHeading,
    noDataBody: labelNoDataBody,
    errorOccurred: labelErrorOccurred,
    errorHeading: labelErrorHeading,
    errorBody: labelErrorBody,
    recordNotExists: labelRecordNotExists,
    sidebarError: labelSidebarError,
    info: labelInfo,
    warningTitle: labelWarningTitle,
    thresholdMessage: labelThresholdMessage,
    successMessage: labelSuccessMessage,
    detailView: labelDetailView,
    updateValues: labelUpdateValues,
    template: labelTemplate,
    sectionDescription: labelSectionDescription,
    timezone: TIMEZONE,
}

const ASSET_FIELDS = [ASSET_ID_FIELD, ASSET_NAME_FIELD];
//const USER_FIELDS = [USER_NAME_FIELD, USER_TYPE_FIELD];

const MAX_TEXT_LENGTH = 255;
const NUMBER_DATATYPE_VALUE = 'number';
const PICKLIST_DATATYPE_VALUE = 'picklist';
const TEXT_DATATYPE_VALUE = 'text';
const DATE_DATATYPE_VALUE = 'date';
const DATETIME_DATATYPE_VALUE = 'datetime';
const BOOLEAN_DATATYPE_VALUE = 'boolean';

const MOBILE_SOURCE = 'Mobile';
const DEFAULT_SOURCE = 'Web';

export default class ViewAssetAttributes extends NavigationMixin (LightningElement) {

    @api recordId;
    @api assetField;
    @api objectApiName;
    @api showRecordName;
    @api title;
    @api flexipageRegionWidth;
    @api viewAttributeDetailsPageName;
    @track error;
    @track recordInfo = {};
    @track techAttributes = [];
    @track attributeCategories = [];
    @track matchingTemplateCategories = [];
    @track oldMatchingTemplateCategories = [];
    @track oldTargetAttributeRecords = [];
    @track targetAttributeRecords = [];
    @track templateItemList= [];
    @track unitPicklistOptions=[];
    @track apiInProgress = false;
    @track timezone = TIMEZONE;
    @track assetId;
    @track userInfo;
    assetName;
    regionIsSmall;
    showIllustration = false;
    illustrationImageName;
    illustrationHeading;
    illustrationMessage;
    editMode = false;
    showNumberWarning = false;
    showTooltip = true;
    isMouseOver = false;

    waringFieldCount = 0;

    @track sectionInfo = {
        popoverClass: 'slds-hide',
    }

    connectedCallback () {
        fetchCurrentLoggedInUser ()
        .then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.userInfo = result.data;
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
            this.apiInProgress = false;
        })
    }

    renderedCallback () {
        loadStyle(this, contractLineItemsListViewResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$objectFieldsForWire' })
    wireSourceRecord ({ error, data }) {
        if (data) {
            const assetFieldValue = data.fields[this.assetField]?.value;
            if (isNotUndefinedOrNull(assetFieldValue)) {
                this.assetId = assetFieldValue;
                this.getMatchingTemplateCategories(this.assetId);
            }
            else {
                this.apiInProgress = true;
                const displayNoData = debounce(() => {
                    try {
                        this.updateIllustrationForDataResponse();
                    }
                    finally {
                        this.apiInProgress = false;
                    }
                }, 300)
                displayNoData();
            }
        } else if (error) {
            this.handleError(error);
        }
    }

    @wire(getRecord, { recordId: '$assetRecordId', fields: '$assetRecordFields' })
    wireAssetRecord ({ error, data }) {
        if (data) {
            this.assetId = getFieldValue(data, ASSET_ID_FIELD);
            this.assetName = getFieldValue(data, ASSET_NAME_FIELD);
        } else if (error) {
            this.handleError(error);
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: TECHNICALATTRIBUTE_OBJ })
    objectInfo;

    //get all picklist values
    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: UNIT_FIELD
    })
    setUnitOptions ({ error, data }) {
        if (data) {
            if (data.values?.length > 0 ) {
                this.unitPicklistOptions = data.values;
            }
        } else if (error) {
            console.error(error);
        }
    }

    get i18n () {
        return i18n;
    }

    get defaultRecordTypeId () {
        return !isEmptyString(this.assetField) ? this.objectInfo?.data?.defaultRecordTypeId : null;
    }

    get isAssetObject () {
        return (this.objectApiName === ASSET_OBJ.objectApiName);
    }

    get isWorkorderObject () {
        return (this.objectApiName === WORKORDER_OBJ.objectApiName);
    }

    get assetAttributeTitle () {
        return this.title;
    }

    get assetRecordName () {
        return (this.showRecordName && isNotUndefinedOrNull(this.assetName)) ?
            this.assetName : null;
    }

    get attributeDetailView () {
        return `${this.assetAttributeTitle} ${this.i18n.detailView}`
    }

    get showWarnings () {
        let templateItems = [];
        if (this.matchingTemplateCategories?.length > 0) {
            this.matchingTemplateCategories.forEach(section => {
                const items = section.technicalAttributeTemplateItems;
                if (items?.length > 0) {
                    templateItems = templateItems.concat(items);
                }
            })
        }
        if (templateItems?.length > 0) {
            const warningFields = templateItems.filter(
                field => field.showWarning === true);
            if (warningFields?.length > 0 ) {
                return formatString(i18n.warningTitle,warningFields.length);
            }
        }
        return null;
    }

    get layoutItemSize () {
        const columns = (IS_MOBILE_DEVICE || this.flexipageRegionWidth === 'SMALL') ? 1 : 2;
        return 12 / columns;
    }

    get isMobile () {
        return IS_MOBILE_DEVICE ;
    }

    get layoutItemCSS () {
        return this.viewMode ? ' attribute-title-view' : '';
    }

    get viewMode () {
        return (!this.editMode);
    }

    get objectFieldsForWire () {
        const fields = [];
        if (!isEmptyString(this.objectApiName) && !isEmptyString(this.assetField) ) {
            fields.push(`${this.objectApiName}.${this.assetField}`);
        }
        return fields;
    }

    get tooLongMessage () {
        return formatString(i18n.tooLong, MAX_TEXT_LENGTH);
    }

    get badInputMessage () {
        // eslint-disable-next-line default-case
        switch (this.fieldDataType) {
            case FIELD_DATA_TYPES.DATE:
                return formatString(i18n.badInputDate, i18n.shortDateFormat);
            case FIELD_DATA_TYPES.DATETIME:
                return formatString(i18n.badInputDateTime, i18n.shortDateTimeFormat);
        }

        return null;
    }

    get stepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 14, 4);
    }

    get textMaxLength () {
        return MAX_TEXT_LENGTH;
    }

    get assetRecordId () {
        return isNotUndefinedOrNull(this.assetId) ? this.assetId : null;
    }

    get assetRecordFields () {
        return isNotUndefinedOrNull(this.assetId) ? ASSET_FIELDS : null;
    }

    get isSmallDevice () {
        return (IS_MOBILE_DEVICE || IS_PHONE_DEVICE() || this.flexipageRegionWidth === 'SMALL');
    }

    get templateCategories () {

        let categories = [];

        if (this.matchingTemplateCategories?.length > 0) {
            categories = this.matchingTemplateCategories.map((element) => {
                return {
                    categoryName: element.name,
                    categoryId: element.id,
                    templateName: element.templateName,
                    isCollapsed: element.isCollapsed,
                    categoryDesc: element.description,
                    attributes: this.getAttributesForSection(element.id,element.showOldValue),
                }
            });
        }
        return categories;
    }

    get hasMatchingTemplate () {
        return (this.matchingTemplateCategories?.length > 0);
    }

    get footerBtnAlign () {
        return this.isMobile ? 'left' :'center';
    }

    handleChange (event) {
        const targetElement = event.target;
        const templateItemId = targetElement.dataset.templateitemid;
        const sectionId = targetElement.dataset.categoryid;
        const attributeType = targetElement.dataset.datatype.toLowerCase();
        const value = ( targetElement.type === 'checkbox' )?
            targetElement.checked : targetElement.value;
        const targetRecordIndex = this.targetAttributeRecords.findIndex(
            (record => record.categoryId === sectionId &&
                record.templateItemId === templateItemId ));
        const stringValue = !isEmptyString(value)? value.toString() :  '';
        this.targetAttributeRecords[targetRecordIndex].value = stringValue;

        // eslint-disable-next-line default-case
        switch (attributeType) {
            case NUMBER_DATATYPE_VALUE:
                this.targetAttributeRecords[targetRecordIndex].numberValue =
                    isEmptyString(value) ? null : parseFloat(value);
                this.validateNumberWarning(templateItemId,sectionId,value,attributeType);
                break;
            case BOOLEAN_DATATYPE_VALUE:
                this.targetAttributeRecords[targetRecordIndex].booleanValue = value;
                break;
            case DATE_DATATYPE_VALUE:
                this.targetAttributeRecords[targetRecordIndex].dateValue = value;
                break;
            case DATETIME_DATATYPE_VALUE:
                this.targetAttributeRecords[targetRecordIndex].datetimeValue = value;
                break;
            case PICKLIST_DATATYPE_VALUE:
                this.showHighlightedBox(templateItemId,sectionId,value,attributeType);
                break;
        }
    }

    handleCommit (event) {
        const targetElement = event.target;
        const templateItemId = targetElement.dataset.templateitemid;
        const sectionId = targetElement.dataset.categoryid;
        const attributeType = targetElement.dataset.datatype.toLowerCase();
        const value = ( targetElement.type === 'checkbox' )?
            targetElement.checked : targetElement.value;

        this.showHighlightedBox(templateItemId,sectionId,value,attributeType);
    }

    validateNumberWarning (templateItemId,categoryId,value,attributeType) {
        const numberValue = isEmptyString(value) ? null : parseFloat(value);
        const numberInput = this.template.querySelector(
            `lightning-input[data-templateitemid="${templateItemId}"]`);
        if (Object.values(numberInput.classList).includes('slds-has-error') &&
            Object.values(numberInput.classList).includes('svmx-input-warning')) {
            numberInput.classList.remove('svmx-input-warning');
        }

        const templateItems = this.matchingTemplateCategories.find(
            item => item.id === categoryId)?.technicalAttributeTemplateItems;
        if (templateItems?.length > 0) {
            const templateItemIndex = templateItems.findIndex(
                (record => record.id === templateItemId && record.categoryId === categoryId));

            const minimumValue = templateItems[templateItemIndex].minimumValue;
            const maximumValue = templateItems[templateItemIndex].maximumValue;
            if (numberInput ) {
                if (numberValue > maximumValue ||
                    numberValue < minimumValue) {
                    numberInput.classList.add('svmx-input-warning');
                    const message = templateItems[templateItemIndex].message;
                    const unitValue = templateItems[templateItemIndex].technicalAttribute?.unit;
                    const unit =this.getPicklistValueLabel(
                        this.unitPicklistOptions,unitValue);
                    const minValueText = `${minimumValue} ${!isEmptyString(unit) ?unit : ''}`;
                    const maxValueText = `${maximumValue} ${!isEmptyString(unit) ?unit : ''}`;
                    const warningMmessage = !isEmptyString(message)? message :
                        formatString(i18n.thresholdMessage,minValueText,maxValueText);
                    templateItems[templateItemIndex].warningText = warningMmessage;
                    templateItems[templateItemIndex].showWarning = true;
                } else {
                    numberInput.classList.remove('svmx-input-warning');
                    templateItems[templateItemIndex].showWarning = false;
                }
            }
        }
        this.showHighlightedBox(templateItemId,categoryId,numberValue,attributeType);
    }

    hanldeOnBlur (event) {
        const targetElement = event.target;
        const templateItemId = targetElement.dataset.templateitemid;
        const sectionId = targetElement.dataset.categoryid;
        const value = ( targetElement.type === 'checkbox' )?
            targetElement.checked : targetElement.value;
        const attributeType = targetElement.dataset.datatype.toLowerCase();
        this.showHighlightedBox(templateItemId,sectionId,value,attributeType);
    }

    showHighlightedBox ( templateItemId, sectionId, value, type ) {

        const inputEl = this.template.querySelector(
            `lightning-layout-item[data-templateitemid="${templateItemId}"]`);
        const oldtargetRecordIndex = this.oldTargetAttributeRecords.findIndex(
            (record => record.categoryId === sectionId &&
                record.templateItemId === templateItemId ));
        const targetRecordId = this.oldTargetAttributeRecords[oldtargetRecordIndex].id;
        const oldValue = this.oldTargetAttributeRecords[oldtargetRecordIndex].value;
        const templateItems = this.matchingTemplateCategories.find(
            item => item.id === sectionId)?.technicalAttributeTemplateItems;
        let attributeValue;
        let isChanged = false;
        if (templateItems?.length > 0) {
            const templateItemIndex = templateItems.findIndex(
                (record => record.id === templateItemId && record.categoryId === sectionId));
            attributeValue = templateItems[templateItemIndex].defaultValue;
        }
        let currentValue;
        let previousValue;
        let templateItemValue;
        if (type === NUMBER_DATATYPE_VALUE) {
            previousValue = isEmptyString(oldValue) ? null : parseFloat(oldValue);
            currentValue = isEmptyString(value) ? null : parseFloat(value);
            templateItemValue = isEmptyString(attributeValue) ? null : parseFloat(attributeValue);
        } else if (type === BOOLEAN_DATATYPE_VALUE) {
            previousValue = isEmptyString(oldValue) ? 'false' : oldValue.toString() ;
            currentValue = isEmptyString(value) ? 'false' : value.toString() ;
            templateItemValue = isEmptyString(attributeValue) ?
                'false' : attributeValue.toString() ;
        } else {
            currentValue = value;
            previousValue = oldValue;
            templateItemValue = attributeValue;
        }
        isChanged = isEmptyString(targetRecordId) ?
            (templateItemValue !== currentValue) : (previousValue !== currentValue);
        if (isChanged) {
            inputEl.classList.add('svmx-attribute-highlight');
        } else {
            inputEl.classList.remove('svmx-attribute-highlight');
        }
    }

    getAttributesForSection (sectionId,showOldValue) {
        if (isEmptyString(sectionId))  return '';
        const attributeList = [];
        const templateItems = this.matchingTemplateCategories.find(
            item => item.id === sectionId)?.technicalAttributeTemplateItems;
        if (templateItems?.length > 0 ) {
            templateItems.forEach(row => {
                const attribute = {};
                attribute.templateItemId = row.id;
                attribute.sectionId = sectionId;
                attribute.attributeId = row.attributeId;
                attribute.assetTechnicalAttributeId = row?.attributeRecord?.id;
                attribute.name = row.technicalAttribute?.name;
                attribute.dataType = row.technicalAttribute?.dataType;
                attribute.unit =this.getPicklistValueLabel(
                    this.unitPicklistOptions,row.technicalAttribute?.unit);
                const targetAttributeRecord = row?.attributeRecord ? row.attributeRecord : null;
                let value;
                if (showOldValue) {
                    const oldtargetAttributeRecord = this.oldTargetAttributeRecords.find(
                        record => record.id === row?.attributeRecord?.id);
                    value = oldtargetAttributeRecord?.value;
                } else {
                    value = this.getTargetAttributeValue(targetAttributeRecord?.id);
                }
                if (attribute.dataType.toLowerCase() === PICKLIST_DATATYPE_VALUE) {
                    const valueSet =
                        row.technicalAttribute?.picklistDefinition?.values.length > 0 ?
                        row.technicalAttribute?.picklistDefinition?.values.split(';') : '';
                    attribute.picklistValues = valueSet;
                    attribute.picklistOptions = this.getPicklistOptions(valueSet);
                    attribute.isTypePicklist = true;
                }
                if (isNotUndefinedOrNull(targetAttributeRecord) &&
                    !isEmptyString(targetAttributeRecord?.id)) {
                    attribute.defaultValue = value;
                } else {
                    attribute.defaultValue = isEmptyString(value) ? row.defaultValue  : value ;
                }
                attribute.isReadOnly = row.isReadOnly;
                attribute.isRequired = row.isRequired;
                attribute.minimumValue = row.minimumValue;
                attribute.maximumValue = row.maximumValue;
                attribute.helpText = row.helpText;
                attribute.isTypeNumber =
                    (attribute.dataType.toLowerCase() === NUMBER_DATATYPE_VALUE) ? true : false;
                attribute.isTypeText =
                    (attribute.dataType.toLowerCase() === TEXT_DATATYPE_VALUE) ? true : false;
                attribute.isTypeCheckbox =
                    (attribute.dataType.toLowerCase() === BOOLEAN_DATATYPE_VALUE) ? true : false;
                attribute.isTypeDate =
                    (attribute.dataType.toLowerCase() === DATE_DATATYPE_VALUE) ? true : false;
                attribute.isTypeDateTime =
                    (attribute.dataType.toLowerCase() === DATETIME_DATATYPE_VALUE) ? true : false;

                attribute.capturedOn = this.getTargetAttributeCapturedOn(targetAttributeRecord?.id);
                if (attribute.isTypeNumber) {
                    attribute.showWarning = row.showWarning;
                    attribute.warningText = row.warningText;
                }
                if (attribute.isTypeCheckbox) {
                    const booleanValue = isEmptyString(attribute.defaultValue) ?
                        false : attribute.defaultValue.toLowerCase();
                    attribute.isChecked = (booleanValue === 'true');
                }
                attribute.borderCSS = 'attribute-title-view slds-p-top_x-small';
                attributeList.push(attribute);
            });
        }
        return attributeList;
    }

    getTargetAttributeValue (attributeRecordId) {
        if (isEmptyString(attributeRecordId)) {return ''; }
        const value = this.targetAttributeRecords.find(
            record => record.id === attributeRecordId)?.value;
        return value;
    }

    getTargetAttributeCapturedOn (attributeRecordId) {
        if (isEmptyString(attributeRecordId)) {return null; }

        const capturedOn = this.targetAttributeRecords.find(
            record => record.id === attributeRecordId)?.capturedOn;
        return capturedOn;
    }

    getPicklistOptions (picklistValues) {
        let options =[]
        if (picklistValues?.length > 0 ) {
            options = picklistValues.map(item => {
                return {
                    label: item,
                    value: item
                };
            });
        }
        return options;
    }

    getPicklistValueLabel (picklistOptions,value) {
        let picklistOption={};
        if (picklistOptions && picklistOptions.length > 0 && value) {
            picklistOption = picklistOptions.find(
                item => item.value === value);
        }
        return picklistOption?.label ? picklistOption.label : null;
    }

    handleSectionShowPopover (event) {
        if (IS_MOBILE_DEVICE) { return; }
        const sectionId = event.detail.value;
        const eachRecordData = {};
        this.showTooltip = true;
        this.isMouseOver = true;
        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {

            try {
                if (sectionId) {
                    const sectionRecord = this.matchingTemplateCategories.find(
                        row => row.id === sectionId);
                    const templateItemRecord = this.templateItemList.find(
                        row => row.categoryId === sectionId);
                    eachRecordData.id = sectionId;
                    eachRecordData.templateName = templateItemRecord?.templateName;
                    eachRecordData.description = sectionRecord?.description;
                    eachRecordData.popoverClass = 'slds-popover slds-hide ';
                    //fetch position
                    const iconHighlighted =
                        this.template.querySelector(`div[data-sectionid="${sectionId}"]`);
                    const requiredPosition = this.isSmallDevice ? 11 : 21;
                    const requiredTopPosition = 160;
                    const top = iconHighlighted.getBoundingClientRect().top - requiredTopPosition;
                    const left = iconHighlighted.getBoundingClientRect().left + requiredPosition;
                    eachRecordData.thresholdPOStyle
                        =`position:fixed;transform:translate(${left}px,${top}px);`
                    eachRecordData.thresholdPOStyle += 'inset:0px auto auto 0px;';
                    eachRecordData.thresholdPOStyle += this.isSmallDevice ?
                         'width:20%;' : 'width:25%';
                    eachRecordData.bodyStyle = 'height: 150px;';
                    this.sectionInfo = eachRecordData;

                    if (!this.isMouseOver) {return;}
                    this.showPopover();
                }
            }
            finally {
                this.apiInProgress = false;
            }
        }, 800);
    }

    handleSectionHidePopover () {
        this.isMouseOver = false;
        if (IS_MOBILE_DEVICE) { return; }
        this.hidePopover();
    }

    handleClose () {
        this.showTooltip = false;
        this.isMouseOver = false;
    }

    handleTooltipMouseEnter () {
        if (IS_MOBILE_DEVICE) { return; }
        this.showPopover();
    }

    handleTooltipMouseLeave () {
        this.isMouseOver = false;
        if (IS_MOBILE_DEVICE) { return; }
        this.hidePopover();
    }

    showPopover () {
        const sectionHighlighted =
            this.template.querySelector('section[data-id="svmx-threshold-popover-section"]');
        if (isElementOverflowingViewport(sectionHighlighted)) {
            sectionHighlighted.classList.add('slds-nubbin_top');
            sectionHighlighted.classList.remove('slds-nubbin_bottom');
        } else {
            sectionHighlighted.classList.add('slds-nubbin_bottom');
            sectionHighlighted.classList.remove('slds-nubbin_top');
        }
        sectionHighlighted.classList.remove('slds-hide');
        sectionHighlighted.classList.add('slds-show');
    }

    hidePopover () {
        const sectionHighlighted =
                this.template.querySelector('section[data-id="svmx-threshold-popover-section"]');

        sectionHighlighted.classList.add('slds-hide');
        sectionHighlighted.classList.remove('slds-show');
    }

    handleEdit () {
        this.editMode = true;
    }

    handleSaveChanges () {

        if (!this.isValidInput()) {
            return;
        }

        const targetAttributes = this.prepareTargetRecords(this.targetAttributeRecords);

        this.saveTechnicalAttributeRecords(targetAttributes);
    }

    handleSave () {
        if (!this.isValidInput()) {
            return;
        }
        const targetAttributes = this.prepareAllTargetRecords(this.targetAttributeRecords);

        this.saveTechnicalAttributeRecords(targetAttributes);
    }

    saveTechnicalAttributeRecords (targetAttributes) {
        if (targetAttributes?.length > 0) {
            const recordsToSave = {};
            recordsToSave.requestSource = IS_MOBILE_DEVICE ? MOBILE_SOURCE : DEFAULT_SOURCE;
            recordsToSave.sourceObjectName = ASSET_OBJ.objectApiName;
            recordsToSave.attributeRecords = targetAttributes;
            this.saveAttributes(recordsToSave);
        } else {
            this.handleCancel();
        }
    }

    handleRefresh (event) {
        const attributeRecord = event.detail.value;
        const targetAttributes = [];
        if (isNotUndefinedOrNull(attributeRecord)) {
            targetAttributes.push(this.updateIndividualRecord(attributeRecord));
        }
        this.saveTechnicalAttributeRecords(targetAttributes);
    }

    updateIndividualRecord (record) {
        const attributeRecord = JSON.parse(JSON.stringify(record));
        let recordToUpdate = {};
        delete attributeRecord.categoryId;
        if (!isEmptyString(attributeRecord.id)) {
            const oldRecord = this.oldTargetAttributeRecords.find(
                row => row.id === attributeRecord.id);
            recordToUpdate = this.populatePreviousValues(attributeRecord,oldRecord);
        } else {
            recordToUpdate = attributeRecord;
        }
        return recordToUpdate;
    }

    saveAttributes (data) {
        if (this.apiInProgress) return;

        this.apiInProgress = true;

        saveAttributeRecords({ requestJson: JSON.stringify(data) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.editMode = false;
                this.showToast(
                    'Success',
                    this.i18n.success,
                    this.i18n.successMessage,
                    'success', 'dismissible');
                //reload the form with udpated details.
                this.getMatchingTemplateCategories(this.assetId);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    handleCancel () {
        this.clearWarnings();
        this.loadMatchingTemplates(this.oldMatchingTemplateCategories,false);
        this.editMode = false;
    }

    handleReset () {
        this.apiInProgress = true;
        this.editMode = false;
        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.clearWarnings();
                const prevRecords = JSON.parse(JSON.stringify(this.oldMatchingTemplateCategories));
                this.loadMatchingTemplates(prevRecords,true);
            } catch (e) {
                this.error = parseErrorMessage(e);
            } finally {
                this.apiInProgress = false;
                this.editMode = true;
            }
        }, 300);
    }

    clearWarnings () {
        this.error = null;
        const inputEls = this.template.querySelectorAll(
            `lightning-layout-item`);

        const numberInputEls = this.template.querySelectorAll(
            'lightning-input');
        if (numberInputEls?.length > 0) {
            numberInputEls.forEach(ele => {
                ele.classList.remove('svmx-input-warning');
            })
        }
        if (inputEls?.length > 0 ) {
            inputEls.forEach(ele => {
                ele.classList.remove('svmx-attribute-highlight');
            })
        }

        if (this.matchingTemplateCategories?.length > 0) {
            this.matchingTemplateCategories.forEach(section => {
                const items = section.technicalAttributeTemplateItems;
                if (items?.length > 0) {
                    items.forEach(item=>{
                        item.showWarning = false;
                    })
                }
            })
        }
    }

    isValidInput () {
        let isValid = true;
        this.error = '';
        isValid = [...this.template.querySelectorAll(
            '.svmx-attribute-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (!isValid) {
            let errorCount = 0;
            const allInputFields = this.template.querySelectorAll(
                '.svmx-attribute-input');
            allInputFields.forEach(inputEl =>{
                if (!inputEl.checkValidity()) {
                    errorCount++;
                }
            })
            this.error = `${errorCount} error(s) found`
            this.matchingTemplateCategories.forEach(section=>{
                section.isCollapsed = false;
            });
        }
        return isValid;
    }

    prepareAllTargetRecords (data) {
        const records = JSON.parse(JSON.stringify(data));
        const targetRecords =[];
        records.forEach( record =>{
            delete record.categoryId;
            if (!isEmptyString(record.id)) {
                const oldRecord = this.oldTargetAttributeRecords.find( row => row.id === record.id);
                if (oldRecord && oldRecord.value !== record.value) {
                    const recordToUpdate = this.populatePreviousValues(record,oldRecord);
                    targetRecords.push(recordToUpdate);
                } else {
                    targetRecords.push(record);
                }
            } else {
                targetRecords.push(record);
            }
        });
        return targetRecords;
    }

    prepareTargetRecords (data) {
        const records = JSON.parse(JSON.stringify(data));
        const targetRecords =[];
        records.forEach( record =>{
            delete record.categoryId;
            if (!isEmptyString(record.id)) {
                const oldRecord = this.oldTargetAttributeRecords.find( row => row.id === record.id);
                if (oldRecord && oldRecord.value !== record.value) {
                    const recordToUpdate = this.populatePreviousValues(record,oldRecord);
                    targetRecords.push(recordToUpdate);
                }
            } else {
                const oldTargetRecord = this.oldTargetAttributeRecords.find(
                    row => row.attributeId === record.attributeId);
                if (oldTargetRecord && oldTargetRecord.value !== record.value) {
                    targetRecords.push(record);
                }
            }
        });
        return targetRecords;
    }

    populatePreviousValues (record,oldRecord) {
        record.previousValue = oldRecord.value;
        record.previousCapturedBy = oldRecord.capturedBy;
        record.previousCapturedOn = oldRecord.capturedOn;
        const type = record.attributeDataType.toLowerCase();
        if ( type === NUMBER_DATATYPE_VALUE) {
            record.previousNumberValue = oldRecord.numberValue;
        } else if ( type === BOOLEAN_DATATYPE_VALUE) {
            record.previousBooleanValue = oldRecord.booleanValue;
        } else if ( type === DATE_DATATYPE_VALUE) {
            record.previousDateValue = oldRecord.dateValue;
        } else if ( type === DATETIME_DATATYPE_VALUE) {
            record.previousDatetimeValue = oldRecord.datetimeValue;
        }
        return record;
    }


    async getMatchingTemplateCategories (assetRecordId) {
        this.matchingTemplateCategories =[];
        this.oldMatchingTemplateCategories =[];
        const sectionList = await this.fetchMatchingTemplateCategories(assetRecordId);
        if (sectionList?.length > 0 ) {
            this.oldMatchingTemplateCategories = JSON.parse(JSON.stringify(sectionList));
            this.loadMatchingTemplates(sectionList,false);
        }
        this.updateIllustrationForDataResponse();
    }

    async fetchMatchingTemplateCategories (assetId) {
        this.apiInProgress = true;
        const matchingTemplateSections =
            await fetchAttributesForAsset({ parentRecordId: assetId })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        this.handleError(this.error);
                        return [];
                    }
                    if (result?.data) {
                        const resp = JSON.parse(JSON.stringify(result.data));
                        return this.processCategoryList(resp)
                    }
                    return [];
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                    this.handleError(this.error);
                })
                .finally( () => {
                    this.apiInProgress = false;
                });
        return matchingTemplateSections;
    }

    processCategoryList (data) {
        if (data?.length === 0 ) { return []; }
        const templateCategoriesMap = {};
        let categoryList = [];
        data.forEach(row=>{
            templateCategoriesMap[row.templateId] = templateCategoriesMap[row.templateId] || [];
            templateCategoriesMap[row.templateId].push(row);
        })
        Object.keys(templateCategoriesMap).forEach(templateId =>{
            const sections = this.sortArraysBySequence(templateCategoriesMap[templateId]);
            if (sections?.length > 0) {
                sections.forEach(section =>{
                    section.technicalAttributeTemplateItems =
                        this.sortArraysBySequence(section.technicalAttributeTemplateItems);
                })
            }
            categoryList = categoryList.concat(sections);
        })
        return categoryList;
    }

    sortArraysBySequence (data) {
        return data.sort((a, b) => parseFloat(a.sequence) - parseFloat(b.sequence));
    }

    loadMatchingTemplates (data,renderOldValue) {
        const categoryList = JSON.parse(JSON.stringify(data));
        this.matchingTemplateCategories = [];
        if (categoryList?.length > 0) {
            this.matchingTemplateCategories = categoryList;
            this.matchingTemplateCategories.forEach(eachCategory =>{
                eachCategory.showOldValue = renderOldValue;
                eachCategory.isCollapsed = false;
            })
            this.populateTargetAttributes(this.matchingTemplateCategories);
        }
    }

    populateTargetAttributes (data) {
        this.targetAttributeRecords = [];
        this.oldTargetAttributeRecords = [];
        this.templateItemList = [];
        if (data?.length > 0 ) {
            data.forEach(section => {
                if (section?.technicalAttributeTemplateItems?.length >0) {
                    const templateItems = section?.technicalAttributeTemplateItems;
                    templateItems.forEach(templateItem => {
                        const attributeRecord ={};
                        const targetRecord = (templateItem?.attributeRecord ) ?
                            templateItem?.attributeRecord : null;
                        attributeRecord.id = targetRecord?.id ? targetRecord?.id : null;
                        attributeRecord.parentRecordId = this.assetId;
                        attributeRecord.templateItemId = templateItem.id;
                        attributeRecord.attributeId = templateItem.attributeId;
                        attributeRecord.categoryId = templateItem.categoryId;
                        attributeRecord.attributeDataType =
                            templateItem?.technicalAttribute?.dataType;
                        if ( isNotUndefinedOrNull(targetRecord) &&
                            !isEmptyString(targetRecord?.id)) {
                            attributeRecord.value = targetRecord?.value ?
                                targetRecord?.value : null;
                        } else {
                            attributeRecord.value = isEmptyString(templateItem.defaultValue) ?
                                null : templateItem.defaultValue;
                        }
                        attributeRecord.previousValue = ( targetRecord?.previousValue ) ?
                            targetRecord.previousValue : null;
                        attributeRecord.capturedOn = ( targetRecord?.capturedOn ) ?
                            targetRecord.capturedOn : null;
                        attributeRecord.capturedBy = ( targetRecord?.capturedBy ) ?
                            targetRecord.capturedBy : null;
                        attributeRecord.previousCapturedOn = ( targetRecord?.previousCapturedOn ) ?
                            targetRecord.previousCapturedOn : null;
                        attributeRecord.previousCapturedBy = ( targetRecord?.previousCapturedBy ) ?
                            targetRecord.previousCapturedBy : null;
                        attributeRecord.booleanValue = ( targetRecord?.booleanValue ) ?
                            targetRecord.booleanValue : false;
                        attributeRecord.previousBooleanValue =
                            ( targetRecord?.previousBooleanValue ) ?
                                targetRecord.previousBooleanValue : false;
                        attributeRecord.numberValue = ( targetRecord?.numberValue ) ?
                            targetRecord.numberValue : null;
                        attributeRecord.previousNumberValue =
                            ( targetRecord?.previousNumberValue ) ?
                                targetRecord.previousNumberValue : null;
                        attributeRecord.dateValue = ( targetRecord?.dateValue ) ?
                            targetRecord.dateValue : null;
                        attributeRecord.previousDateValue = ( targetRecord?.previousDateValue ) ?
                            targetRecord.previousDateValue : null;
                        attributeRecord.datetimeValue = ( targetRecord?.datetimeValue ) ?
                            targetRecord.datetimeValue : null;
                        attributeRecord.previousDatetimeValue =
                            ( targetRecord?.previousDatetimeValue ) ?
                                targetRecord.previousDatetimeValue : null;
                        attributeRecord.sourceRecordId = this.recordId;
                        attributeRecord.workorderId = (this.isWorkorderObject)? this.recordId: null;
                        this.targetAttributeRecords.push(attributeRecord);
                        this.templateItemList.push(templateItem);
                    })
                }
            })
        }
        this.oldTargetAttributeRecords = JSON.parse(JSON.stringify(this.targetAttributeRecords));
    }

    viewAssetAttributeHistories (event) {
        const targetElement = event.target;
        const name = targetElement.dataset.name;
        const attributeUnit = targetElement.dataset.unit;
        const templateItemId = targetElement.dataset.templateitemid;
        let attributeRecord = {};
        let templateItemRecord = {};
        if (!isEmptyString(templateItemId)) {
            const attributes = JSON.parse(JSON.stringify(this.targetAttributeRecords));
            attributeRecord = attributes.find(
                item => item.templateItemId === templateItemId);

            const templateItems = JSON.parse(JSON.stringify(this.templateItemList));
            templateItemRecord = templateItems.find(
                item => item.id === templateItemId);
            templateItemRecord.unit = attributeUnit;
            templateItemRecord.attributeName = name;
        }
        this.template.querySelector('c-attribute-history-view').
            handleViewAttributeHistory(attributeRecord, templateItemRecord);
    }

    viewAttributeDetail () {
        if (this.userInfo.userType !== 'Standard' && this.userInfo.userType !== 'CsnOnly') {
            const pageRefPortal = {
                type: 'comm__namedPage',
                attributes: {
                    name: this.viewAttributeDetailsPageName,
                },
                state: {
                    c__recordId: this.assetId,
                    c__objectAPIName: ASSET_OBJ.objectApiName,
                    c__userInfo: JSON.stringify(this.userInfo)
                }
            };
            this[NavigationMixin.Navigate](pageRefPortal);
        } else {
            const pageRef = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'SVMXA360__AttributesHistory',
            },
            state: {
                c__recordId: this.assetId,
                c__objectAPIName: ASSET_OBJ.objectApiName, //c__objectAPIName: this.objectApiName,
                c__userInfo: JSON.stringify(this.userInfo)
                }
            };
            if (IS_MOBILE_DEVICE) {
                this[NavigationMixin.Navigate](pageRef);
            } else {
                this[NavigationMixin.GenerateUrl](pageRef)
                    .then(url => { window.open(url, "_blank"); });
            }
        }
    }

    handleError (error) {
        this.error = parseErrorMessage(error);

        if (error
            && error.message
            && error.message.trim().toUpperCase() === i18n.recordNotExists.toUpperCase()) {
            this.updateIllustrationForDataResponse();
        } else if (error?.body?.errorCode === 'INVALID_FIELD') {
            this.updateIllustration(
                true,
                'error:page_not_available',
                i18n.errorHeading,
                formatString(i18n.invalidField, this.objectApiName, this.assetField)
            );
        } else {
            this.updateIllustration(
                true,
                'error:page_not_available',
                i18n.errorHeading,
                this.error
            );
        }
    }

    updateIllustrationForDataResponse () {
        if (!isEmptyString(this.error)) {
            this.showNoAccessIllustration();
        }
        else if (this.hasMatchingTemplate) {
            this.updateIllustration(false);
        } else {
            this.showNoDataIllustration();
        }
    }

    showNoAccessIllustration () {
        this.updateIllustration(
            true,
            'error:no_access',
            `${i18n.errorOccurred} ${i18n.errorBody}`,
            this.error
        );
    }

    showNoDataIllustration () {
        this.updateIllustration(
            true,
            'no_data:open_road',
            i18n.noDataHeading,
            i18n.noDataBody
        );
    }

    updateIllustration (show, imageName, heading, message) {
        this.showIllustration = show;

        if (imageName) {
            this.illustrationImageName = imageName;
        }

        if (heading) {
            this.illustrationHeading = heading;
        }

        if (message) {
            this.illustrationMessage = message;
        }
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