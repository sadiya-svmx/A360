import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import { parseErrorMessage, formatString, verifyApiResponse, PAGE_ACTION_TYPES }
    from 'c/utils';

//Get object info and Line Type fields info from Contract Price Line Item Plan object
import CONTRACT_PRICE_LINE_ITEM_PLAN_OBJ from '@salesforce/schema/ContractPriceLineItemPlan__c';
import LINE_TYPE_FIELD from '@salesforce/schema/ContractPriceLineItemPlan__c.LineType__c';
import EXPENSE_FIELD from '@salesforce/schema/ContractPriceLineItemPlan__c.ExpenseItem__c';
import CLI_PLAN_NAME_FIELD from '@salesforce/schema/ContractLineItemPlan__c.Name';
import CLI_PLAN_PRODUCT_FIELD from '@salesforce/schema/ContractLineItemPlan__c.ProductId__c';
import CLI_PLAN_PRODUCT_FAMILY_FIELD
    from '@salesforce/schema/ContractLineItemPlan__c.ProductFamily__c';
import ENTITLED_SERVICE_PLAN_NAME_FIELD from '@salesforce/schema/EntitledServicePlan__c.Name';
import PRODUCT_FAMILY_FIELD from '@salesforce/schema/ContractPriceLineItemPlan__c.ProductFamily__c';
import SERVICE_CONTRACT_PLAN_NAME_FIELD from '@salesforce/schema/ServiceContractPlan__c.Name';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';

import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelContractLineItemPlan from '@salesforce/label/c.Label_ContractLineItemPlan';
import labelContractPriceLinePlan from '@salesforce/label/c.Label_Contract_Price_Line_Plan';
import labelCreateMessage from '@salesforce/label/c.Label_CPLICreationMessage';
import labelCurrency from '@salesforce/label/c.Label_Currency';
import labelDiscount from '@salesforce/label/c.Label_Discount';
import labelDiscountError from '@salesforce/label/c.Label_CPLI_Discount_Error';
import labelDuplicateError from '@salesforce/label/c.Label_DuplicateErrorMessage';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelEntitledDiscount from '@salesforce/label/c.Label_EntitledDiscount';
import labelEntitledPrice from '@salesforce/label/c.Label_ContractUnitPrice';
import labelEntitledServicePlan from '@salesforce/label/c.Label_EntitledServicePlan';
import labelExpenseItem from '@salesforce/label/c.Label_ExpenseItem';
import labelLineType from '@salesforce/label/c.Label_CPLIType';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelNewContratPriceLinePlan
    from '@salesforce/label/c.Label_New_Contract_Price_Line_Plan';
import labelNext from '@salesforce/label/c.Button_Next';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelPricing from '@salesforce/label/c.Label_Pricing';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelProductType from '@salesforce/label/c.Label_Product_Type';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelRequiredError from '@salesforce/label/c.Label_RequiredErrorMessage';
import labelContract from '@salesforce/label/c.Label_Contract';
import labelContractLine from '@salesforce/label/c.Label_ContractLine';
import labelEntitledService from '@salesforce/label/c.Label_EntitledService';
import labelContractLineAndEntitledService
    from '@salesforce/label/c.Label_ContractLineAndEntitledService';
import labelSave from '@salesforce/label/c.Button_Save';
import labelSaveAndNew from '@salesforce/label/c.Button_SaveAndNew';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelServiceContractPlan from '@salesforce/label/c.Label_ServiceContractPlan';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelSurcharge from '@salesforce/label/c.Label_Surcharge';
import labelSurchargeError from '@salesforce/label/c.Label_CPLI_Surcharge_Error';
import labelType from '@salesforce/label/c.Label_Type';
import labelUniquenessCheck from '@salesforce/label/c.Label_UniquenessCheck';
import labelUpdateMessage from '@salesforce/label/c.Label_CPLIUpdateMessage';
import labelPricingLevel from '@salesforce/label/c.Label_Pricing_Level';

import getCurrencyCodeValues
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.getCurrencyCodeValues';
import saveContractPriceLineItemPlan
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.saveContractPriceLineItemPlan';
import getServiceContractPlanDetails
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getServiceContractPlan';

const i18n = {
    cancel: labelCancel,
    contractLineitemPlan: labelContractLineItemPlan,
    cpliPlanModalTitle: labelContractPriceLinePlan,
    createdMsg: labelCreateMessage,
    currency: labelCurrency,
    discount: labelDiscount,
    discountError: labelDiscountError,
    duplicate: labelUniquenessCheck,
    duplicateError: labelDuplicateError,
    entitledDiscount: labelEntitledDiscount,
    entitledPrice: labelEntitledPrice,
    entitledServicePlan: labelEntitledServicePlan,
    expenseItem: labelExpenseItem,
    lineType: labelLineType,
    lineTypeModalTitle: labelNewContratPriceLinePlan,
    lineTypeSelection: `${labelSelect} ${labelProductType}`,
    loading: labelLoading,
    next: labelNext,
    outOfRangeNumber: labelOutOfRangeNumber,
    pricing: labelPricing,
    product: labelProduct,
    productFamily: labelProductFamily,
    productTypeSelection: `${labelSelect} ${labelProductType}`,
    reviewError: labelReviewError,
    requiredError: labelRequiredError,
    contract: labelContract,
    contractLine: labelContractLine,
    entitledService: labelEntitledService,
    contractLineAndEntitledService: labelContractLineAndEntitledService,
    save: labelSave,
    saveAndNew: labelSaveAndNew,
    serviceContractPlan: labelServiceContractPlan,
    success: labelSuccess,
    surcharge: labelSurcharge,
    surchargeError: labelSurchargeError,
    type: labelType,
    valueMissing: labelEnterValue,
    updatedMsg: labelUpdateMessage,
    pricingLevel: labelPricingLevel,
}

const PERCENT_MAX_VALUE = 999.99;
const CURRENCY_MAX_VALUE = 9999999999999998.99;
const PRODUCT_OPTION_VALUE = 'Product';
const PRODUCT_FAMILY_OPTION_VALUE = 'Product Family';
const DISCOUNT_OPTION_VALUE = 'Discount';
const PRICING_OPTION_VALUE = 'Pricing';
const SURCHARGE_OPTION_VALUE = 'Surcharge';
const CURRENCY_FORMATTER = 'currency';
const DECIMAL_FORMATTER = 'decimal';
const EXPENSE_SECTION = 'Expense';
const CONTRACT_OPTION_VALUE = 'Contract';
const CONTRACT_LINE_OPTION_VALUE = 'Contract Line';
const ENTITLED_SERVICE_OPTION_VALUE = 'Entitled Service';
const CONTRACTLINE_AND_ENTITLEDSERVICE_OPTION_VALUE = 'Contract Line and Entitled Service';

export default class ContractPriceLineItemPlanDetail extends LightningElement {

    @track recordInfo = {};
    @track selectedPricingLevel;
    apiInProgress = false;
    lineTypeOptions;
    selectedLineType = '';
    selectedProductType = '';
    error = '';
    lineTypeModal = false;
    productFamilyOptions = [];
    contractPriceViewModalOpen = false;
    booleanFalse = false;
    selectedPricingMethod = '';
    isMultiCurrencyEnabled = false;
    currencyCodeOptions = [];
    expenseOptions = [];

    contractLinePlanNameField = [
        CLI_PLAN_NAME_FIELD.fieldApiName,
        CLI_PLAN_PRODUCT_FIELD.fieldApiName,
        CLI_PLAN_PRODUCT_FAMILY_FIELD.fieldApiName
    ].join(',');
    entitledServicePlanNameField = ENTITLED_SERVICE_PLAN_NAME_FIELD.fieldApiName;
    productNameField = PRODUCT_NAME_FIELD.fieldApiName;
    contractPriceLineItemPlan = CONTRACT_PRICE_LINE_ITEM_PLAN_OBJ.objectApiName;
    serviceContractPlanNameField = SERVICE_CONTRACT_PLAN_NAME_FIELD.fieldApiName;

    // object info using wire service
    @wire(getObjectInfo, { objectApiName: CONTRACT_PRICE_LINE_ITEM_PLAN_OBJ })
    objectInfo;

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

    handleLineTypeChange (event) {
        this.selectedLineType = event.detail.value;
        this.recordInfo.lineType = event.detail.value;
    }

    handleProductChange (event) {
        this.selectedProductType = event.detail.value;
    }

    handleLineTypeNext () {
        this.contractPriceViewModalOpen = true;
        this.lineTypeModal = false;
    }

    handleLookupFieldChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const { detail, target } = event;
        if (target.dataset.field === 'serviceContractPlanId' &&
            this.recordInfo.serviceContractPlanId !== detail.value) {
            this.recordInfo.serviceContractPlanId = detail.value;
            this.recordInfo.serviceContractPlanName = detail.label;
        } else if (target.dataset.field === 'contractLineItemPlanId' &&
            this.recordInfo.contractLineItemPlanId !== detail.value) {
            this.recordInfo.contractLineItemPlanId = detail.value;
            this.recordInfo.contractLineItemPlanName = detail.label;
            this.clearRelatedFieldValues();
        } else if (target.dataset.field === 'entitledServicePlan') {
            this.recordInfo.entitledServicePlanId = detail.value;
            this.recordInfo.entitledServicePlanName = detail.label;
        } else if (target.dataset.field === 'productId') {
            this.recordInfo.productId = detail.value;
            this.recordInfo.productName = detail.label;
        }
    }

    clearRelatedFieldValues () {
        if (this.isContractLineAndEntitledService()) {
            delete this.recordInfo.entitledServicePlanId;
            delete this.recordInfo.entitledServicePlanName;
        }
    }

    @api
    handleNewContractPriceLineItemPlan (parentRecordId) {
        this.resetValues();
        this.lineTypeModal = true;
        this.recordInfo.serviceContractPlanId = parentRecordId;
        this.selectedPricingLevel = CONTRACT_OPTION_VALUE;
        getServiceContractPlanDetails({
            masterRecordId: parentRecordId
        })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const resultData = result.data;
                this.defaultCurrencyCode = resultData.currencyIsoCode;
            }).catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    handleNewCancelModal () {
        this.resetValues();
    }

    handleChangeProductType (event) {
        this.selectedProductType = event.detail.value;
        //reset field values in product section
        delete this.recordInfo.productId;
        delete this.recordInfo.productName;
        delete this.recordInfo.productFamily;
    }

    handleChange (event) {
        const targetElement = event.target;
        this.recordInfo[targetElement.dataset.field] = targetElement.value;
    }

    handleChangePricingMethod (event) {

        this.selectedPricingMethod = event.detail.value;
        if (this.isMultiCurrencyEnabled) {
            this.recordInfo.currencyIsoCode = this.defaultCurrencyCode;
        }
        delete this.recordInfo.entitledPrice;
        delete this.recordInfo.surcharge;
        delete this.recordInfo.entitledDiscount;
    }

    handleChangePricingLevel (event) {
        this.selectedPricingLevel = event.detail.value;
        delete this.recordInfo.contractLineItemPlanId;
        delete this.recordInfo.contractLineItemPlanName;
        delete this.recordInfo.entitledServicePlanId;
        delete this.recordInfo.entitledServicePlanName;
    }

    handleSaveAndNew () {
        this.saveRecord(true);
    }

    handleSave () {
        this.saveRecord(false);
    }

    @api
    handleEditContractPriceLineItemPlan (recordInfo, actionName) {
        this.populateContractPriceLineItemInfo(recordInfo);
        this.handleNext();
        if (actionName === PAGE_ACTION_TYPES.CLONE) {
            this.recordInfo.id = null;
        }
    }

    populateContractPriceLineItemInfo (data) {

        this.recordInfo = { ...this.recordInfo, ...data };
        this.selectedLineType = this.recordInfo.lineType;

        //set product type
        if (this.recordInfo.productId) {
            this.selectedProductType = PRODUCT_OPTION_VALUE;
        } else if (this.recordInfo.productFamily) {
            this.selectedProductType = PRODUCT_FAMILY_OPTION_VALUE;
        }

        //set pricing type
        if (this.recordInfo.entitledPrice) {
            this.selectedPricingMethod = PRICING_OPTION_VALUE;
        } else if (this.recordInfo.entitledDiscount) {
            this.selectedPricingMethod = DISCOUNT_OPTION_VALUE;
        } else if (this.recordInfo.surcharge) {
            this.selectedPricingMethod = SURCHARGE_OPTION_VALUE;
        }

        //set Pricing Level
        if (this.recordInfo.contractLineItemPlanId && this.recordInfo.entitledServicePlanId) {
            this.selectedPricingLevel = CONTRACTLINE_AND_ENTITLEDSERVICE_OPTION_VALUE;
        } else if (this.recordInfo.contractLineItemPlanId) {
            this.selectedPricingLevel = CONTRACT_LINE_OPTION_VALUE;
        } else if (this.recordInfo.entitledServicePlanId) {
            this.selectedPricingLevel = ENTITLED_SERVICE_OPTION_VALUE;
        } else {
            this.selectedPricingLevel = CONTRACT_OPTION_VALUE;
        }

    }

    handleNext () {
        this.lineTypeModal = false;
        this.contractPriceViewModalOpen = true;
    }

    saveRecord (isSaveAndNew) {

        if (!this.isValidInput()) return;

        if (this.apiInProgress) return;

        this.apiInProgress = true;
        saveContractPriceLineItemPlan({ requestJson: JSON.stringify(this.recordInfo) })
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
                    this.i18n.updatedMsg : this.i18n.createdMsg}`;

                this.showToast(this.i18n.success, toastMsg, 'success', 'dismissible');
                if (isSaveAndNew) {
                    this.handleCloseAndNew();
                } else {
                    this.handleCloseAndRefresh();
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

    handleCloseAndNew () {
        const serviceContractPlanId = this.recordInfo.serviceContractPlanId;
        this.resetValues();
        this.refreshListView();
        this.lineTypeModal = true;
        this.recordInfo.serviceContractPlanId = serviceContractPlanId;
        this.selectedPricingLevel = CONTRACT_OPTION_VALUE;
    }

    handleCloseAndRefresh () {
        this.resetValues();
        this.refreshListView();
    }

    refreshListView () {
        this.dispatchEvent(
            new CustomEvent('refresh', {
                detail: {
                    value: 'success'
                }
            })
        );
    }

    contractLinePlanWhereClause () {
        return this.recordInfo?.contractLineItemPlanId &&
            `ContractLineItemPlanId__c='${this.recordInfo.contractLineItemPlanId}'`;
    }

    serviceContractPlanWhereClause () {
        return this.recordInfo?.serviceContractPlanId &&
            `ServiceContractPlanId__c='${this.recordInfo.serviceContractPlanId}'`;
    }

    isContractLineAndEntitledService () {
        return (this.selectedPricingLevel === CONTRACTLINE_AND_ENTITLEDSERVICE_OPTION_VALUE);
    }

    resetValues () {
        this.lineTypeModal = false;
        this.contractPriceViewModalOpen = false;
        this.selectedLineType = '';
        this.selectedProductType = '';
        this.recordInfo = {};
        this.selectedPricingMethod = '';
        this.error = null;
    }

    showToast (title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    get i18n () {
        return i18n;
    }

    get isDisableLineTypeNextButton () {
        return (!this.recordInfo.lineType);
    }

    get isDisableProductNextButton () {
        return (!this.selectedProductType);
    }

    get productTypeOptions () {
        return [
            { label: this.i18n.product, value: PRODUCT_OPTION_VALUE },
            { label: this.i18n.productFamily, value: PRODUCT_FAMILY_OPTION_VALUE },
        ];
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

    get showCurrencyCode () {
        return (this.selectedPricingMethod === PRICING_OPTION_VALUE && this.isMultiCurrencyEnabled);
    }

    get pricingTypeOptions () {
        return [
            { label: this.i18n.discount, value: DISCOUNT_OPTION_VALUE },
            { label: this.i18n.pricing, value: PRICING_OPTION_VALUE },
            { label: this.i18n.surcharge, value: SURCHARGE_OPTION_VALUE },
        ];
    }

    get pricingLevelOptions () {
        return [
            { label: this.i18n.contract, value: CONTRACT_OPTION_VALUE },
            { label: this.i18n.contractLine, value: CONTRACT_LINE_OPTION_VALUE },
            { label: this.i18n.entitledService, value: ENTITLED_SERVICE_OPTION_VALUE },
            {
                label: this.i18n.contractLineAndEntitledService,
                value: CONTRACTLINE_AND_ENTITLEDSERVICE_OPTION_VALUE
            },
        ];
    }

    get requestJson () {
        const requestParameters = {
            objectName: this.contractPriceLineItemPlan
        }
        return JSON.stringify(requestParameters);
    }

    get formatterType () {
        return (this.isMultiCurrencyEnabled) ?
            DECIMAL_FORMATTER : CURRENCY_FORMATTER;
    }

    get percentStepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 3, 2);
    }

    get currencyStepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 16, 2);
    }

    get percentMaxValue () {
        return PERCENT_MAX_VALUE;
    }

    get currencyMaxValue () {
        return CURRENCY_MAX_VALUE;
    }

    get isExpenseItemSection () {
        return (this.recordInfo.lineType === EXPENSE_SECTION);
    }

    get entitledServicePlanFilter () {
        return (this.isContractLineAndEntitledService() ?
            this.contractLinePlanWhereClause() : this.serviceContractPlanWhereClause());
    }

    get contractLinePlanFilter () {
        return this.serviceContractPlanWhereClause();
    }

    get showCLIPlan () {
        return (this.isContractLineAndEntitledService() ||
            this.selectedPricingLevel === CONTRACT_LINE_OPTION_VALUE);
    }

    get showESPlan () {
        return (this.isContractLineAndEntitledService() ||
            this.selectedPricingLevel === ENTITLED_SERVICE_OPTION_VALUE);
    }

    get disableESPlan () {
        return (this.isContractLineAndEntitledService() && !this.recordInfo.contractLineItemPlanId);
    }

    get lineTypeLabel () {
        let lineType={};
        if (this.lineTypeOptions && this.lineTypeOptions.length > 0) {
            lineType = this.lineTypeOptions.find(
                item => item.value === this.recordInfo.lineType);
        }
        return lineType?.label ? lineType.label : null;
    }
}