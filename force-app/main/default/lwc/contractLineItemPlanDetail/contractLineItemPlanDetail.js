import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    PAGE_ACTION_TYPES,
    isNotUndefinedOrNull
} from 'c/utils';
import { loadStyle } from 'lightning/platformResourceLoader';
import contractLineItemPlanDetailResource
    from '@salesforce/resourceUrl/contractLineItemPlanDetail';
import getProductRecords
    from '@salesforce/apex/CONF_QueryLightningService.queryRecords';
import saveContractLineItemPlan
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.saveContractLineItemPlan';

//Get object info, Product Family and  from Contract Price Line Item object
import CONTRACT_LINE_ITEM_PLAN_OBJ
    from '@salesforce/schema/ContractLineItemPlan__c';
import CLIPLAN_PRODUCT_FAMILY_FIELD
    from '@salesforce/schema/ContractLineItemPlan__c.ProductFamily__c';
import CLIPLAN_UNIT_OF_TIME_FIELD
    from '@salesforce/schema/ContractLineItemPlan__c.ContractLineUnitOfTime__c';

//Get fields and object info from Product2 object
import PRODUCT_OBJ from '@salesforce/schema/Product2';
import PRODUCT_ID_FIELD from '@salesforce/schema/Product2.Id';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';
import PRODUCT_FAMILY_FIELD from '@salesforce/schema/Product2.Family';
import PRODUCT_CODE_FIELD from '@salesforce/schema/Product2.ProductCode';
import PRODUCT_DESCRIPTION_FIELD from '@salesforce/schema/Product2.Description';
import PRODUCT_ISACTIVE_FIELD from '@salesforce/schema/Product2.IsActive';
import PRODUCT_LASTMODIFIED_FIELD from '@salesforce/schema/Product2.LastModifiedDate';

import labelNewContractLineItemPlan from '@salesforce/label/c.Label_NewContractLineItemPlan';
import labelSelectProductType from '@salesforce/label/c.Label_SelectProductType';
import labelSelectProductFamily from '@salesforce/label/c.Label_SelectProductFamily';
import labelPlaceholderForProduct from '@salesforce/label/c.Label_SearchPlaceholderForProduct';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelSelected from '@salesforce/label/c.Label_Selected';
import labelChooseRow from '@salesforce/label/c.Label_ChooseRow';
import labelSerialNumber from '@salesforce/label/c.Label_SerialNumber';
import labelProductCode from '@salesforce/label/c.Label_ProductCode';
import labelProductDescription from '@salesforce/label/c.Label_ProductDescription';
import labelActive from '@salesforce/label/c.Label_Active';
import labelContractLineItemPlanDetail from '@salesforce/label/c.Label_ContractLineItemPlanDetail';
import labelContractLineDuration from '@salesforce/label/c.Label_ContractLineDuration';
import labelContractLineUnitofTime from '@salesforce/label/c.Label_ContractLineUnitofTime';
import labelProductName from '@salesforce/label/c.Label_ProductName';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelNext from '@salesforce/label/c.Button_Next';
import labelBack from '@salesforce/label/c.Button_Back';
import labelSave from '@salesforce/label/c.Button_Save';
import labelDiscount from '@salesforce/label/c.Label_Discount';
import labelRequiredField from '@salesforce/label/c.Label_RequiredFieldMessage';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelDiscountError from '@salesforce/label/c.Label_CPLI_Discount_Error';
import labelDurationError from '@salesforce/label/c.Label_CLIPlanDurationError';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelRequiredError from '@salesforce/label/c.Label_RequiredErrorMessage';
import labelDuplicateError from '@salesforce/label/c.Label_DuplicateErrorMessage';
import labelContractLineItemPlan from '@salesforce/label/c.Label_ContractLineItemPlan';
import labelContractLineItemPlans from '@salesforce/label/c.Label_ContractLineItemPlans';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';

const PRODUCT_OPTION_VALUE = 'Product';
const PRODUCT_FAMILY_OPTION_VALUE = 'Product Family';
const PRODUCT_LIMIT_COUNT = 50000;
const SHOW_ROWS = 50;
const DEFAULT_ORDER ='DESC';

const i18n = {
    title: labelNewContractLineItemPlan,
    productType: labelSelectProductType,
    prouctFamilyTitle: labelSelectProductFamily,
    placeholder: labelPlaceholderForProduct,
    items: labelItemsRowCount,
    selected: labelSelected,
    chooseRow: labelChooseRow,
    serialNumber: labelSerialNumber,
    productName: labelProductName,
    product: labelProduct,
    productFamily: labelProductFamily,
    productCode: labelProductCode,
    productDescription: labelProductDescription,
    active: labelActive,
    editTitle: labelContractLineItemPlanDetail,
    duration: labelContractLineDuration,
    unitTime: labelContractLineUnitofTime,
    discount: labelDiscount,
    next: labelNext,
    back: labelBack,
    save: labelSave,
    cancel: labelCancel,
    requiredFieldMsg: labelRequiredField,
    required: labelRequired,
    success: labelSuccess,
    outOfRangeNumber: labelOutOfRangeNumber,
    valueMissing: labelEnterValue,
    discountError: labelDiscountError,
    durationError: labelDurationError,
    formValidation: labelFormValidation,
    reviewError: labelReviewError,
    requiredError: labelRequiredError,
    duplicateError: labelDuplicateError,
    cliPlan: labelContractLineItemPlan,
    cliPlans: labelContractLineItemPlans,
    saved: labelWasSaved,
    noResults: labelNoResults,
    loading: labelLoading,
}

export default class ContractLineItemPlanDetail extends LightningElement {
    //Properties
    @track parentRecordId;
    @track newContractLinePlanModalOpen = false;
    @track contractLineProductModalOpen = false;
    @track contractLineProductFamilyModalOpen = false;
    @track contractLinePlanModalOpen = false;
    @track fieldsToRetrieve;
    @track selectedCLIProducts = [];
    @track fetchedProductRecords = [];
    @track _productRecords = [];
    @track cliplanRecordInfo = {};
    @track selectedProductType = '';
    @track apiInProgress = false;
    @track actionType;
    @track searchTerm;
    @track selectedProductRecord=[];
    @track error;

    productFamilyOptions = [];
    unitOfTimeOptions = [];
    objectName;
    cliPlanDetails={};

    renderedCallback () {
        loadStyle(this, contractLineItemPlanDetailResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    // object info using wire service
    @wire(getObjectInfo, { objectApiName: CONTRACT_LINE_ITEM_PLAN_OBJ })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: CLIPLAN_PRODUCT_FAMILY_FIELD
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
        fieldApiName: CLIPLAN_UNIT_OF_TIME_FIELD
    })
    setUnitOfTimeOptions ({ error, data }) {
        if (data) {
            this.unitOfTimeOptions = data.values;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @api
    handleNewContractLinePlan (parentRecId) {
        this.parentRecordId = parentRecId;
        this.newContractLinePlanModalOpen = true;
        this.fetchProductRecords();
    }

    @api
    handleEditContractLinePlan (selectedCliPlanRecord, actionName) {
        this.clearValues();
        this.actionType = actionName;
        if (selectedCliPlanRecord && this.actionType === PAGE_ACTION_TYPES.EDIT) {
            this.cliPlanDetails = selectedCliPlanRecord;
            if (selectedCliPlanRecord.productFamily) {
                this.selectedProductType = PRODUCT_FAMILY_OPTION_VALUE;
                this.cliplanRecordInfo.productFamily = selectedCliPlanRecord.productFamily;
            } else if (selectedCliPlanRecord.productId) {
                this.selectedProductType = PRODUCT_OPTION_VALUE;
                this.fetchProductRecords();
            }
            this.selectedCLIProducts.push(selectedCliPlanRecord);
            this.contractLinePlanModalOpen = true;
        }
    }

    fetchProductRecords () {
        this.fieldsToRetrieve = [
            PRODUCT_ID_FIELD.fieldApiName,
            PRODUCT_NAME_FIELD.fieldApiName,
            PRODUCT_FAMILY_FIELD.fieldApiName,
            PRODUCT_CODE_FIELD.fieldApiName,
            PRODUCT_DESCRIPTION_FIELD.fieldApiName,
            PRODUCT_ISACTIVE_FIELD.fieldApiName
        ];
        this.objectName = PRODUCT_OBJ.objectApiName;
        const reqObject ={
            objectName: this.objectName,
            fields: this.fieldsToRetrieve,
            sortField: PRODUCT_LASTMODIFIED_FIELD.fieldApiName,
            sortOrder: DEFAULT_ORDER,
            limitCount: PRODUCT_LIMIT_COUNT
        };
        this.apiInProgress = true;
        getProductRecords({
            requestJson: JSON.stringify(reqObject)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.populateProductRecords(result.data);
            })
            .catch(error => {
                this._productRecords = [];
                this.fetchedProductRecords = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    populateProductRecords (data) {
        if (this.fetchedProductRecords && this.fetchedProductRecords.length > 0) return;

        data.forEach(row => {
            const product ={};
            product.Id = row.Id;
            product.Name = row.Name;
            product.Family = row.Family;
            product.ProductCode = row.ProductCode;
            product.Description = row.Description;
            product.IsActive = row.IsActive;
            if (this.cliPlanDetails && this.cliPlanDetails.productId === row.Id) {
                product.isSelected = true;
                this.selectedProductRecord.push(product);
            } else {
                product.isSelected = false;
            }
            this.fetchedProductRecords.push(product);
        });
        if (this.actionType === PAGE_ACTION_TYPES.EDIT) {
            this._productRecords = this.selectedProductRecord;
        } else {
            this.showRecentModifiedRecords(this.fetchedProductRecords);
        }
    }

    showRecentModifiedRecords (productList) {
        const products = [...productList];
        if (products && products.length > SHOW_ROWS) {
            this._productRecords = products.splice(0,SHOW_ROWS);
        } else {
            this._productRecords = products;
        }
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

    get showNextButton () {
        return (!this.selectedProductType );
    }

    get showNextProductSelection () {
        return (!this.selectedCLIProducts.length >0);
    }

    get showNextProductFamily () {
        return (!this.cliplanRecordInfo.productFamily);
    }

    get isProductType () {
        return (this.selectedProductType === PRODUCT_OPTION_VALUE);
    }

    get productList () {
        return (this._productRecords && this._productRecords.length) ? this._productRecords : null;
    }

    get selectedPills () {
        const pills = this.selectedCLIProducts.map(item => {
            return {
                type: 'icon',
                label: item.productName,
                name: item.productId,
                iconName: 'standard:product',
                alternativeText: item.productName,
            };
        });
        return pills;
    }

    get showPills () {
        return (this.selectedCLIProducts && this.selectedCLIProducts.length > 0);
    }

    get cliPlanRecords () {
        const cliPlans = this.selectedCLIProducts.map((item, index) => {
            return {
                item,
                sNo: index + 1,
            };
        });
        return cliPlans;
    }

    get percentStepMismatchMessage () {
        return formatString(i18n.outOfRangeNumber, 3, 2);
    }

    get selectedProductCountInfo () {
        return `${this.selectedCLIProducts.length} ${this.i18n.items} ${this.i18n.selected}`;
    }

    get noRecordsFound () {
        return (this._productRecords && this._productRecords.length === 0);
    }

    handleChangeProductType (event) {
        this.selectedProductType = event.detail.value;
        this.selectedCLIProducts = [];
    }

    handleChangeProductFamily (event) {
        const productFamily = event.detail.value;
        if (this.actionType === PAGE_ACTION_TYPES.EDIT ) {
            this.cliplanRecordInfo = this.cliPlanDetails;
        }
        this.selectedCLIProducts = [];

        if (!this.cliplanRecordInfo) {
            this.cliplanRecordInfo = {};
        }
        this.cliplanRecordInfo.productFamily = productFamily;
        //Clear Product value
        this.cliplanRecordInfo.productId = null;
        this.addCLIPlanRecord (this.cliplanRecordInfo);
    }

    handleNextProductType () {
        if (this.isProductType) {
            this.contractLineProductModalOpen = true;
        } else {
            this.contractLineProductFamilyModalOpen = true;
        }
        this.newContractLinePlanModalOpen = false;
    }

    handleCancelProductType () {
        this.newContractLinePlanModalOpen = false;
        this.clearValues();
    }

    handleNextProductFamily () {
        this.contractLineProductFamilyModalOpen = false;
        this.contractLinePlanModalOpen = true;
    }

    handleCancelProductFamily () {
        this.contractLineProductFamilyModalOpen = false;
        this.clearValues();
    }

    handleNextProductSelection () {
        //clear search result when we are navigating to create/edit form.
        if (isNotUndefinedOrNull(this.searchTerm)) {
            this.filterListViewData();
        }
        this.contractLineProductModalOpen = false;
        this.contractLinePlanModalOpen = true;
    }

    handleBackProductSelection () {
        this.contractLineProductModalOpen = false;
        this.newContractLinePlanModalOpen = true;
    }

    handleCancelProductSelection () {
        this.contractLineProductModalOpen = false;
        this.clearValues();
    }

    handleBackCLIPlan () {
        this.error='';
        this.contractLinePlanModalOpen = false;
        if (this.isProductType) {
            this.contractLineProductModalOpen = true;
        } else {
            this.contractLineProductFamilyModalOpen = true;
        }
    }

    handleCancelCLIPlan () {
        this.contractLinePlanModalOpen = false;
        this.clearValues();
    }

    handleSelectProduct (event) {
        const isChecked = event.target.checked;
        const productId = event.target.value;
        const productName = event.target.dataset.name;
        //toggle the checkbox
        this.toggleProductSelection (productId,isChecked);

        //Edit - replace product
        if (this.actionType === PAGE_ACTION_TYPES.EDIT ) {
            this.cliplanRecordInfo  = this.cliPlanDetails;
            this.selectedCLIProducts = [];
            this.clearUnSelectedProducts(productId,false);
        } else {
            //New CLI Plan 
            this.cliplanRecordInfo = {};
        }
        //Add or remove products 
        this.cliplanRecordInfo.productId=productId;
        this.cliplanRecordInfo.productName=productName;
        if (isChecked) {
            this.addCLIPlanRecord (this.cliplanRecordInfo);
        } else {
            this.removeCLIPlanRecord(this.cliplanRecordInfo);
        }
    }

    clearUnSelectedProducts (productId,isSelected) {
        this._productRecords.forEach(row => {
            if (row.Id !== productId) {
                row.isSelected = isSelected;
            }
        });

        this.fetchedProductRecords.forEach(row => {
            if (row.Id !== productId) {
                row.isSelected = isSelected;
            }
        });
    }

    addCLIPlanRecord (cliPlanRecord) {
        if (!cliPlanRecord.serviceContractPlanId) {
            cliPlanRecord.serviceContractPlanId = this.parentRecordId;
        }
        this.selectedCLIProducts.push(cliPlanRecord);
    }

    removeCLIPlanRecord (cliPlanRecord) {
        if (cliPlanRecord.productId) {
            this.selectedCLIProducts = this.selectedCLIProducts.filter(
                item => item.productId !== cliPlanRecord.productId);
        }
    }

    toggleProductSelection (productId,isSelected) {
        this._productRecords.forEach(row => {
            if (row.Id === productId) {
                row.isSelected = isSelected;
            }
        });

        this.fetchedProductRecords.forEach(row => {
            if (row.Id === productId) {
                row.isSelected = isSelected;
            }
        });
    }

    handlePillRemove (event) {

        const productId = event.detail.item.name;
        this.cliplanRecordInfo ={};
        this.toggleProductSelection (productId,false);
        this.cliplanRecordInfo.productId =productId;
        this.removeCLIPlanRecord (this.cliplanRecordInfo);
    }

    handleChange (event) {
        const fieldName = event.target.dataset.field;
        const productId = event.target.dataset.id;
        const value = event.target.value;
        let objIndex = 0;
        if (productId) {
            objIndex = this.selectedCLIProducts.findIndex((obj => obj.productId === productId));
        }

        this.selectedCLIProducts[objIndex][fieldName] = value ? value : null;
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;
        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        try {
            window.clearTimeout(this.delayTimeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.searchTerm = searchKey;
                this.filterListViewData(searchKey);

            }, 500);
        } catch (e) {
            this.error = parseErrorMessage(e);
        }
    }

    filterListViewData (searchValue) {
        if (!searchValue) {
            // Restore list when search filter is removed.
            if (this.actionType === PAGE_ACTION_TYPES.EDIT) {
                this._productRecords = this.selectedProductRecord;
            } else {
                this.showRecentModifiedRecords(this.fetchedProductRecords);
            }
        } else {
            const searchRecords  = this.fetchedProductRecords.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const productMatch = (item.Name)
                    ? item.Name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return ( productMatch !== -1);
            });
            this.showRecentModifiedRecords(searchRecords);
        }
    }

    handleSave () {
        if (!this.isValidInput()) return;

        if (this.apiInProgress) return;

        this.apiInProgress = true;
        saveContractLineItemPlan({ requestJson: JSON.stringify(this.selectedCLIProducts) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${result.data.length} ${result.data.length > 1 ?
                    this.i18n.cliPlans : this.i18n.cliPlan} ${this.i18n.saved}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleCancelCLIPlan();
                //dispatch event to refresh the list view
                this.handleCloseAndRefresh();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
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

    isValidInput () {
        let isValid = true;
        this.error = '';
        isValid = [...this.template.querySelectorAll(
            '.required-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);


        if (!isValid) {
            this.error = this.i18n.formValidation;
        }
        return isValid;
    }

    clearValues () {
        this.selectedProductType = '';
        this._productRecords = [];
        this.selectedProductRecord = [];
        this.fetchedProductRecords = [];
        this.selectedCLIProducts = [];
        this.cliplanRecordInfo = {};
        this.cliPlanDetails = {};
        this.error = null;
        this.actionType ='';
        this.searchTerm='';
    }
}