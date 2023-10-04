import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import saveContractPriceLineItem
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.saveContractPriceLineItem';
import getContractPriceLineItemDetails
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.getContractPriceLineItemDetails';
import getParentRecordValues
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.getParentRecordValues';
import getCurrencyCodeValues
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.getCurrencyCodeValues';
import deleteContractPriceLineItem
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.deleteContractPriceLineItem';

import { parseErrorMessage, verifyApiResponse, formatString, PAGE_ACTION_TYPES } from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import negotiatedPriceItemResource from '@salesforce/resourceUrl/negotiatedPriceLineItemDetail';

//Get objinfo and fields from Entitlement object
import ENTITLEMENT_NAME_FIELD from '@salesforce/schema/Entitlement.Name';

//Get fields and object info from Contract Line object
import LINE_ITEM_NUMBER_FIELD from '@salesforce/schema/ContractLineItem.LineItemNumber';
import ASSET_NAME_FIELD from '@salesforce/schema/ContractLineItem.Asset.Name';

//Get ServiceContract Name field from ServiceContract object
import SERVICE_CONTRACT_NAME_FIELD from '@salesforce/schema/ServiceContract.Name';

//Get object info, Expense and Line Type fields info from Contract Price Line Item object
import CONTRACT_PRICE_LINE_ITEM_OBJ from '@salesforce/schema/ContractPriceLineItem__c';
import LINE_TYPE_FIELD from '@salesforce/schema/ContractPriceLineItem__c.LineType__c';
import EXPENSE_FIELD from '@salesforce/schema/ContractPriceLineItem__c.ExpenseItem__c';
import PRODUCT_FAMILY_FIELD from '@salesforce/schema/ContractPriceLineItem__c.ProductFamily__c';

import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';


import labelAddPriceLineItem from '@salesforce/label/c.Label_AddPriceLineItem';
import labelType from '@salesforce/label/c.Label_Type';
import labelSelectLineType from '@salesforce/label/c.Label_Select_Line_Type';
import labelContractPriceLineItem from '@salesforce/label/c.Label_ContractPriceLineItem';
import labelPricing from '@salesforce/label/c.Label_Pricing';
import labelDisabledField from '@salesforce/label/c.Label_DisabledFieldMessage';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelRequiredError from '@salesforce/label/c.Label_RequiredErrorMessage';
import labelDuplicateError from '@salesforce/label/c.Label_DuplicateErrorMessage';
import labelCreateMessage from '@salesforce/label/c.Label_CPLICreationMessage';
import labelUpdateMessage from '@salesforce/label/c.Label_CPLIUpdateMessage';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelNext from '@salesforce/label/c.Button_Next';
import labelSave from '@salesforce/label/c.Button_Save';
import labelDiscount from '@salesforce/label/c.Label_Discount';
import labelSurcharge from '@salesforce/label/c.Label_Surcharge';
import labelExpense from '@salesforce/label/c.Label_Expense';
import labelExpenseItem from '@salesforce/label/c.Label_ExpenseItem';
import labelUniquenessCheck from '@salesforce/label/c.Label_UniquenessCheck';
import labelRequiredField from '@salesforce/label/c.Label_RequiredFieldMessage';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelServiceContract from '@salesforce/label/c.Label_ServiceContract';
import labelContractLine from '@salesforce/label/c.Label_ContractLine';
import labelEntitledService from '@salesforce/label/c.Label_EntitledService';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelCurrency from '@salesforce/label/c.Label_Currency';
import labelDiscountError from '@salesforce/label/c.Label_CPLI_Discount_Error';
import labelSurchargeError from '@salesforce/label/c.Label_CPLI_Surcharge_Error';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelDeleteMessage from '@salesforce/label/c.Label_CPLIDeleteMessage';
import labelDeletePriceLineItem from '@salesforce/label/c.Label_DeletePriceLineItem';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_DeleteConfirmMessage';
import labelClone from '@salesforce/label/c.Menu_Clone';
import labelSaveAndClone from '@salesforce/label/c.Button_SaveAndClone';

const PERCENT_MAX_VALUE = 999.99;
const CURRENCY_MAX_VALUE = 9999999999999998.99;
const PRODUCT_OPTION_VALUE = 'Product';
const PRODUCT_FAMILY_OPTION_VALUE = 'Product Family';
const DISCOUNT_OPTION_VALUE = 'Discount';
const PRICING_OPTION_VALUE = 'Pricing';
const SURCHARGE_OPTION_VALUE = 'Surcharge';

const RECORD_TYPE_ENTITLED_SERVICE = 'EntitledServices';
const CURRENCY_FORMATTER = 'currency';
const DECIMAL_FORMATTER = 'decimal';
const EXPENSE_SECTION = 'Expense';

const i18n = {
    lineTypetitle: labelAddPriceLineItem,
    type: labelType,
    lineTypeSelection: labelSelectLineType,
    cpliTitle: labelContractPriceLineItem,
    pricing: labelPricing,
    labelDisabled: labelDisabledField,
    reviewError: labelReviewError,
    requiredError: labelRequiredError,
    duplicateError: labelDuplicateError,
    createdMsg: labelCreateMessage,
    updatedMsg: labelUpdateMessage,
    product: labelProduct,
    productFamily: labelProductFamily,
    discount: labelDiscount,
    surcharge: labelSurcharge,
    next: labelNext,
    save: labelSave,
    edit: labelEdit,
    delete: labelDelete,
    cancel: labelCancel,
    confirm: labelConfirm,
    expense: labelExpense,
    expenseItem: labelExpenseItem,
    duplicate: labelUniquenessCheck,
    requiredFieldMsg: labelRequiredField,
    required: labelRequired,
    success: labelSuccess,
    outOfRangeNumber: labelOutOfRangeNumber,
    valueMissing: labelEnterValue,
    entitledService: labelEntitledService,
    contractLine: labelContractLine,
    serviceContract: labelServiceContract,
    currency: labelCurrency,
    discountError: labelDiscountError,
    surchargeError: labelSurchargeError,
    deletePriceLineItem: labelDeletePriceLineItem,
    deleteConfirmMessage: labelDeleteConfirmMessage,
    msgDeleted: labelDeleteMessage,
    clone: labelClone,
    saveAndClone: labelSaveAndClone,
}
export default class NegotiatedPriceLineItemDetail extends LightningElement {

    @api recordId;
    @api objectApiName;

    @track sourceRecordId;
    @track currentRecordId;
    @track fieldsToRetrieve;
    @track parentObjectName;

    //Properties
    @track newContractPriceModalOpen;
    @track contractPriceViewModalOpen;
    @track expenseOptions = [];
    @track lineTypeOptions;
    @track productFamilyOptions = [];
    @track currencyCodeOptions = [];

    @track selectedProductType = '';
    @track selectedPricingMethod = '';

    @track recordInfo = {};
    @track apiInProgress = false;
    @track isMultiCurrencyEnabled = false;
    @track editMode = false;
    @track deleteModalDialogOpen;
    @track viewModalOpened = false;
    @track contractPriceLineItem = CONTRACT_PRICE_LINE_ITEM_OBJ.objectApiName;

    serviceContractNameField = SERVICE_CONTRACT_NAME_FIELD.fieldApiName;
    entitledServiceNameField = ENTITLEMENT_NAME_FIELD.fieldApiName;
    productNameField = PRODUCT_NAME_FIELD.fieldApiName;
    contractLineNameField =
        `${LINE_ITEM_NUMBER_FIELD.fieldApiName},${ASSET_NAME_FIELD.fieldApiName}`;

    booleanFalse = false;
    booleanTrue = true;
    objectName;
    defaultCurrencyCode;
    pendingDeleteRecord;

    @track error;

    renderedCallback () {
        loadStyle(this, negotiatedPriceItemResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    // Getting Line Type Picklist values using wire service
    @wire(getPicklistValues,
        { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: LINE_TYPE_FIELD })
    typePicklistValues ({ error, data }) {
        if (data) {
            this.lineTypeOptions = data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getCurrencyCodeValues, { requestJson: '$requestJson' })
    currencyPicklistValues ({ data,error }) {
        if (data) {
            const currencyCodeValues = data.data;
            if (currencyCodeValues && currencyCodeValues.length > 0) {
                this.isMultiCurrencyEnabled = true;
                this.currencyCodeOptions = currencyCodeValues;
            }
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    // object info using wire service
    @wire(getObjectInfo, { objectApiName: CONTRACT_PRICE_LINE_ITEM_OBJ })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: EXPENSE_FIELD
    })
    setExpenseOptions ({ error, data }) {
        if (data) {
            this.expenseOptions = data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PRODUCT_FAMILY_FIELD
    })
    setProductFamilyOptions ({ error, data }) {
        if (data) {
            this.productFamilyOptions = data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @api
    handleNewContractPrice (parentRecordId) {
        this.parentRecordId = parentRecordId;
        this.editMode = true;
        getParentRecordValues({
            requestJson: JSON.stringify({ parentId: this.parentRecordId })
        })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.recordInfo = { ...this.recordInfo, ...result.data };
                this.defaultCurrencyCode = this.recordInfo.currencyIsoCode;
                this.newContractPriceModalOpen = true;
            }).catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.parentRecordId = undefined;
            });
    }

    @api
    handleEditContractPrice (recId,actionName) {

        this.currentRecordId = recId;
        if (actionName === PAGE_ACTION_TYPES.VIEW) {
            this.editMode = false;
            this.viewModalOpened = true;
        } else {
            this.editMode = true;
        }
        getContractPriceLineItemDetails({
            requestJson: JSON.stringify({ id: this.currentRecordId })
        })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.populateContractPriceLineInfo (result.data);
                this.handleNext();
                if (actionName === PAGE_ACTION_TYPES.CLONE) {
                    this.recordInfo.id = null;
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.currentRecordId = undefined;
            });
    }

    @api
    handleDeleteCPLI (record) {
        this.pendingDeleteRecord = record;
        this.deleteModalDialogOpen = true;
    }

    get requestJson () {
        const requestParameters = {
            objectName: this.contractPriceLineItem
        }
        return JSON.stringify(requestParameters);
    }

    get showCurrencyCode () {
        return (this.selectedPricingMethod === PRICING_OPTION_VALUE && this.isMultiCurrencyEnabled);
    }

    get formatterType () {
        return (this.isMultiCurrencyEnabled) ?
            DECIMAL_FORMATTER : CURRENCY_FORMATTER;
    }

    get entitledServiceFilter () {
        const conditions = [
            `RecordType.DeveloperName = '${RECORD_TYPE_ENTITLED_SERVICE}'`
        ];

        const serviceContractWhere = this.serviceContractWhereClause();
        if (serviceContractWhere) {
            conditions.push(serviceContractWhere);
        }

        return conditions.join(' and ');
    }

    get contractLineFilter () {
        return this.serviceContractWhereClause();
    }

    serviceContractWhereClause () {
        return this.recordInfo?.serviceContractId &&
            `ServiceContractId='${this.recordInfo.serviceContractId}'`;
    }

    get i18n () {
        return i18n;
    }

    get productTypeOptions () {
        return [
            { label: this.i18n.product, value: PRODUCT_OPTION_VALUE },
            { label: this.i18n.productFamily, value: PRODUCT_FAMILY_OPTION_VALUE },
        ];
    }

    get pricingTypeOptions () {
        return [
            { label: this.i18n.discount, value: DISCOUNT_OPTION_VALUE },
            { label: this.i18n.pricing, value: PRICING_OPTION_VALUE },
            { label: this.i18n.surcharge, value: SURCHARGE_OPTION_VALUE },
        ];
    }

    get isDisableNextButton () {
        return (!this.recordInfo.lineType);
    }

    get isExpenseItemSection () {
        return (this.recordInfo.lineType === EXPENSE_SECTION);
    }

    get isDisabledProductField () {
        return (!this.selectedProductType);
    }

    get isDisabledPriceField () {
        return (!this.selectedPricingMethod);
    }

    get isProductVisible () {
        return this.selectedProductType === PRODUCT_OPTION_VALUE;
    }

    get isProductFamilyVisible () {
        return this.selectedProductType === PRODUCT_FAMILY_OPTION_VALUE;
    }

    get isDiscountVisible () {
        return this.selectedPricingMethod === DISCOUNT_OPTION_VALUE;
    }

    get isPricingVisible () {
        return this.selectedPricingMethod === PRICING_OPTION_VALUE;
    }

    get isSurchargeVisible () {
        return this.selectedPricingMethod === SURCHARGE_OPTION_VALUE;
    }

    get contractPriceTitle () {
        const lineTypeLabel = this.getPicklistValueLabel(
            this.lineTypeOptions,this.recordInfo.lineType);
        return `${this.i18n.cpliTitle} (${lineTypeLabel})`
    }

    get percentMaxValue () {
        return PERCENT_MAX_VALUE;
    }

    get currencyMaxValue () {
        return CURRENCY_MAX_VALUE;
    }

    get percentStepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 3, 2);

    }

    get currencyStepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 16, 2);
    }

    get viewMode () {
        return (!this.editMode);
    }

    get productTypeLabel () {
        return this.getPicklistValueLabel(this.productTypeOptions,this.selectedProductType);
    }

    get productFamilyLabel () {
        return this.getPicklistValueLabel(this.productFamilyOptions,this.recordInfo.productFamily);
    }

    get expenseLabel () {
        return this.getPicklistValueLabel(this.expenseOptions,this.recordInfo.expenseItem);
    }

    get pricingTypeLabel () {
        return this.getPicklistValueLabel(this.pricingTypeOptions,this.selectedPricingMethod);
    }

    get currencyCodeLabel () {
        return this.getPicklistValueLabel(this.currencyCodeOptions,this.recordInfo.currencyIsoCode);
    }

    getPicklistValueLabel (picklistOptions,value) {
        let picklistOption={};
        if (picklistOptions && picklistOptions.length > 0 && value) {
            picklistOption = picklistOptions.find(
                item => item.value === value);
        }
        return picklistOption?.label ? picklistOption.label : null;
    }

    populateContractPriceLineInfo (data) {

        this.recordInfo = { ...this.recordInfo, ...data };

        //set product type
        if (this.recordInfo.productId) {
            this.selectedProductType = PRODUCT_OPTION_VALUE;
        } else if (this.recordInfo.productFamily) {
            this.selectedProductType = PRODUCT_FAMILY_OPTION_VALUE;
        }

        //set pricing type
        if (this.recordInfo.price) {
            this.selectedPricingMethod = PRICING_OPTION_VALUE;
        } else if (this.recordInfo.discount) {
            this.selectedPricingMethod = DISCOUNT_OPTION_VALUE;
        } else {
            this.selectedPricingMethod = SURCHARGE_OPTION_VALUE;
        }
    }

    handleChangeProductType (event) {

        this.selectedProductType = event.detail.value;
        //reset field values in product section
        this.recordInfo.productId = '';
        this.recordInfo.productName = '';
        this.recordInfo.productFamily = '';
    }

    handleChangePricingMethod (event) {

        this.selectedPricingMethod = event.detail.value;
        //reset field values in pricing section
        if (this.isMultiCurrencyEnabled) {
            this.recordInfo.currencyIsoCode = this.defaultCurrencyCode;
        }
        this.recordInfo.price = '';
        this.recordInfo.surcharge = '';
        this.recordInfo.discount = '';
    }

    handleChangeLineType (event) {
        this.recordInfo.lineType = event.detail.value;
    }

    handleNext () {
        this.newContractPriceModalOpen = false;
        this.contractPriceViewModalOpen = true;
    }

    handleChange (event) {
        const targetElement = event.target;
        this.recordInfo[targetElement.dataset.field] = targetElement.value;
    }

    handleLookupFieldChange (event) {

        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const { detail, target } = event;
        if (target.dataset.field === 'ServiceContract' &&
            this.recordInfo.serviceContractId !== detail.value) {
            this.clearRelatedFieldValues();
            this.recordInfo.serviceContractId = detail.value;
            this.recordInfo.serviceContractName = detail.label;
        } else if (target.dataset.field === 'EntitledService') {
            this.recordInfo.entitledServiceId = detail.value;
            this.recordInfo.entitledServiceName = detail.label;
        } else if (target.dataset.field === 'ContractLine') {
            this.recordInfo.contractLineId = detail.value;
            this.recordInfo.contractLineName = detail.label;
        } else if (target.dataset.field === 'Product') {
            this.recordInfo.productId = detail.value;
            this.recordInfo.productName = detail.label;
        }
    }

    clearRelatedFieldValues () {
        this.recordInfo.entitledServiceId = null;
        this.recordInfo.entitledServiceName = null;
        this.recordInfo.contractLineId = null;
        this.recordInfo.contractLineName = null;
    }

    handleEdit () {
        this.editMode = true;
    }

    handleSave (event) {

        if (!this.isValidInput()) return;

        if (this.apiInProgress) return;
        const actionName = event.target.dataset.name;
        this.apiInProgress = true;
        saveContractPriceLineItem({ requestJson: JSON.stringify(this.recordInfo) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    const message = result.message.toLowerCase();
                    if (message.indexOf(this.i18n.duplicate.toLowerCase()) >= 0) {
                        this.error = this.i18n.duplicateError;
                    } else {
                        this.error = message;
                    }
                    return;
                }

                const toastMsg = `${this.recordInfo.id ?
                    this.i18n.updatedMsg : this.i18n.createdMsg} - ${result.data.name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleContractPriceViewCancel();
                //dispatch event to refresh the list view
                this.handleCloseAndRefresh();
                if (actionName === 'saveAndClone') {
                    //call edit function for clone
                    this.handleEditContractPrice (result.data.id,PAGE_ACTION_TYPES.CLONE);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    isValidInput () {

        let isValid = true;
        this.error = '';
        isValid = [...this.template.querySelectorAll('.required-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (!isValid) {
            this.error = this.i18n.requiredError;
        }
        return isValid;
    }


    handleCloseAndRefresh () {
        this.dispatchEvent(
            new CustomEvent('closeandrefreshpage', {
                detail: {
                    value: 'success'
                }
            })
        );
    }

    handleNewCancelModal () {
        this.newContractPriceModalOpen = false;
        this.recordInfo = {};
        this.clearValues();
    }

    handleContractPriceViewCancel () {
        this.contractPriceViewModalOpen = false;
        this.recordInfo = {};
        this.clearValues();
    }

    clearValues () {
        this.sourceRecordId = null;
        this.fieldsToRetrieve = null;
        this.selectedPricingMethod = '';
        this.selectedProductType = '';
        this.error = null;
        this.editMode = false;
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

    handleClone () {
        this.recordInfo.id = null;
        this.handleEdit();
    }

    handleDeleteModal () {
        const currentCPLIRecord = JSON.parse(JSON.stringify(this.recordInfo));
        currentCPLIRecord.Id = this.recordInfo.id;
        currentCPLIRecord.Name = this.recordInfo.name;
        this.handleDeleteCPLI(currentCPLIRecord);
        this.contractPriceViewModalOpen = false;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();
        if (!this.pendingDeleteRecord) return;

        deleteContractPriceLineItem({
            requestJson: JSON.stringify({ id: this.pendingDeleteRecord.Id }) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                const toastMsg = `${this.i18n.msgDeleted}- ${this.pendingDeleteRecord.Name}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleCloseAndRefresh();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.pendingDeleteRecord = undefined;
            });
    }
}