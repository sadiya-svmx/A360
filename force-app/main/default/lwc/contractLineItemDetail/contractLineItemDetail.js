import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    isNotUndefinedOrNull,
    isEmptyString,
    PAGE_ACTION_TYPES
} from 'c/utils';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import CURRENCY from '@salesforce/i18n/currency';
import contractLineItemPlanDetailResource
    from '@salesforce/resourceUrl/contractLineItemPlanDetail';
import queryRecords
    from '@salesforce/apex/CONF_QueryLightningService.queryRecords';
import getCurrencyCodeValues
    from '@salesforce/apex/PCAL_ContractPriceLineItem_LS.getCurrencyCodeValues';
import saveContractLineItem
    from '@salesforce/apex/CLI_ContractLines_LS.saveContractLineItem';

//Get fields and object info from respective object
import PRODUCT_OBJ from '@salesforce/schema/Product2';
import PRICE_BOOK_OBJ from '@salesforce/schema/Pricebook2';
import PRICE_BOOK_ENTRY_OBJ from '@salesforce/schema/PricebookEntry';
import CONTRACT_LINE_ITEM_OBJ from '@salesforce/schema/ContractLineItem';
import SC_ID_FIELD from '@salesforce/schema/ServiceContract.Id';
import PBE_ID_FIELD from '@salesforce/schema/PricebookEntry.Id';
import PB_ID_FIELD from '@salesforce/schema/Pricebook2.Id';
import PB_NAME_FIELD from '@salesforce/schema/Pricebook2.Name';
import PBE_PRODUCT_ID_FIELD from '@salesforce/schema/PricebookEntry.Product2Id';
import PBE_LAST_MODIFIED_FIELD from '@salesforce/schema/PricebookEntry.LastModifiedDate';
import PBE_PRICE_BOOK_ID_FIELD from '@salesforce/schema/PricebookEntry.Pricebook2Id';
import PBE_LIST_PRICE_FIELD from '@salesforce/schema/PricebookEntry.UnitPrice';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';
import PRODUCT_FAMILY_FIELD from '@salesforce/schema/Product2.Family';
import PRODUCT_CODE_FIELD from '@salesforce/schema/Product2.ProductCode';
import PRODUCT_DESCRIPTION_FIELD from '@salesforce/schema/Product2.Description';
import SC_PRICE_BOOK_ID_FIELD from '@salesforce/schema/ServiceContract.Pricebook2Id';
import SC_START_DATE_FIELD from '@salesforce/schema/ServiceContract.StartDate';
import SC_END_DATE_FIELD from '@salesforce/schema/ServiceContract.EndDate';
import ASSET_NAME_FIELD from '@salesforce/schema/Asset.Name';

import labelNewContractLineItem from '@salesforce/label/c.Button_NewContractLineItems';
import labelPlaceholderForProduct from '@salesforce/label/c.Label_SearchPlaceholderForProduct';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelSelected from '@salesforce/label/c.Label_Selected';
import labelChooseRow from '@salesforce/label/c.Label_ChooseRow';
import labelSerialNumber from '@salesforce/label/c.Label_SerialNumber';
import labelProductCode from '@salesforce/label/c.Label_ProductCode';
import labelProductDescription from '@salesforce/label/c.Label_ProductDescription';
import labelContractLineItemDetailEdit from '@salesforce/label/c.Label_ContractLineItemDetailEdit';
import labelAssetName from '@salesforce/label/c.Label_assetName';
import labelProduct from '@salesforce/label/c.Label_ProductName';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelListPrice from '@salesforce/label/c.Label_ListPrice';
import labelSalesPrice from '@salesforce/label/c.Label_SalesPrice';
import labelQuantity from '@salesforce/label/c.Label_Quantity';
import labelStartDate from '@salesforce/label/c.Label_StartDate';
import labelEndDate from '@salesforce/label/c.Label_EndDate';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelNext from '@salesforce/label/c.Button_Next';
import labelBack from '@salesforce/label/c.Button_Back';
import labelSave from '@salesforce/label/c.Button_Save';
import labelDiscount from '@salesforce/label/c.Label_Discount';
import labelSuccess from '@salesforce/label/c.Label_Success';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelOutOfRangeNumber from '@salesforce/label/c.Message_OutOfRangeNumber';
import labelDiscountError from '@salesforce/label/c.Label_CPLI_Discount_Error';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelContractLineItem from '@salesforce/label/c.Label_ContractLineItem';
import labelContractLineItems from '@salesforce/label/c.Label_ContractLineItems';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import shortDateFormat from '@salesforce/i18n/dateTime.shortDateFormat';
import labelBadInputDate from '@salesforce/label/c.Message_BadInputDate';
import labelPriceBook from '@salesforce/label/c.Label_Pricebook';
import labelChoosePriceBook from '@salesforce/label/c.Label_ChoosePriceBook';
import labelChoosePriceBookOnSC from '@salesforce/label/c.Label_ChoosePriceBookOnSC';
import label_None from '@salesforce/label/c.Label_None';

const CURRENCY_MAX_VALUE = 9999999999999998.99;
const PRICE_BOOK_LIMIT_COUNT = 50000;
const SHOW_ROWS = 50;
const DEFAULT_ORDER ='DESC';
const CURRENCY_FORMATTER = 'currency';
const DECIMAL_FORMATTER = 'decimal';

const fieldsToRetrieve = [
    PBE_ID_FIELD.fieldApiName,
    PBE_PRODUCT_ID_FIELD.fieldApiName,
    PBE_LIST_PRICE_FIELD.fieldApiName,
    `${PRODUCT_OBJ.objectApiName}.${PRODUCT_NAME_FIELD.fieldApiName}`,
    `${PRODUCT_OBJ.objectApiName}.${PRODUCT_FAMILY_FIELD.fieldApiName}`,
    `${PRODUCT_OBJ.objectApiName}.${PRODUCT_CODE_FIELD.fieldApiName}`,
    `${PRODUCT_OBJ.objectApiName}.${PRODUCT_DESCRIPTION_FIELD.fieldApiName}`,
];

const fieldsToRetrievePB = [
    PB_ID_FIELD.fieldApiName,
    PB_NAME_FIELD.fieldApiName
];

const i18n = {
    title: labelNewContractLineItem,
    placeholder: labelPlaceholderForProduct,
    items: labelItemsRowCount,
    selected: labelSelected,
    chooseRow: labelChooseRow,
    serialNumber: labelSerialNumber,
    product: labelProduct,
    assetName: labelAssetName,
    productFamily: labelProductFamily,
    productCode: labelProductCode,
    productDescription: labelProductDescription,
    listPrice: labelListPrice,
    salesPrice: labelSalesPrice,
    quantity: labelQuantity,
    discount: labelDiscount,
    startDate: labelStartDate,
    endDate: labelEndDate,
    badInputDate: labelBadInputDate,
    shortDateFormat: shortDateFormat,
    editTitle: labelContractLineItemDetailEdit,
    next: labelNext,
    back: labelBack,
    save: labelSave,
    cancel: labelCancel,
    success: labelSuccess,
    outOfRangeNumber: labelOutOfRangeNumber,
    valueMissing: labelEnterValue,
    discountError: labelDiscountError,
    formValidation: labelFormValidation,
    reviewError: labelReviewError,
    cli: labelContractLineItem,
    clis: labelContractLineItems,
    saved: labelWasSaved,
    noResults: labelNoResults,
    loading: labelLoading,
    currencyCode: CURRENCY,
    priceBook: labelPriceBook,
    choosePriceBookTitle: labelChoosePriceBook,
    choosePriceBookOnSC: labelChoosePriceBookOnSC,
    labelNone: label_None
}

export default class ContractLineItemDetail extends LightningElement {
    parentRecordId;
    priceBookId;
    scStartDate;
    scEndDate;
    apiInProgress = false;
    priceBookSelectionModalOpen = false;
    contractLineProductModalOpen = false;
    contractLineModalOpen = false;
    isMultiCurrencyEnabled = false;
    @track selectedCLIProducts = [];
    @track fetchedProductRecords = [];
    @track cliRecordInfo = {};
    @track _pBERecords = [];
    @track currencyCodeOptions = [];
    @track error;
    @track pbOptions = [];
    selectedPBId = '';
    assetNameField = ASSET_NAME_FIELD.fieldApiName;

    cliDetails = {};

    renderedCallback () {
        loadStyle(this, contractLineItemPlanDetailResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    @wire(getRecord, { recordId: '$parentRecordId',
        fields: [SC_PRICE_BOOK_ID_FIELD, SC_START_DATE_FIELD, SC_END_DATE_FIELD]})
    serviceContractResult ({ error, data }) {
        if (error) {
            this.error =  parseErrorMessage(error);
        } else if (data) {
            this.scStartDate = data.fields.StartDate.value;
            this.scEndDate = data.fields.EndDate.value;

            if (data.fields.Pricebook2Id.value) {
                this.priceBookId = data.fields.Pricebook2Id.value;

                if (this.actionType !== PAGE_ACTION_TYPES.EDIT && !this.contractLineModalOpen) {
                    this.priceBookSelectionModalOpen = false;
                    this.contractLineProductModalOpen = true;
                }
            } else {
                this.populatePriceBookLogic();
            }
        }
    }

    populatePriceBookLogic () {
        const requestJsonObj = JSON.stringify({
            objectName: PRICE_BOOK_OBJ.objectApiName,
            fields: fieldsToRetrievePB,
            whereClause: 'ISActive = TRUE',
            sortField: PB_NAME_FIELD.fieldApiName,
            sortOrder: DEFAULT_ORDER
        });
        queryRecords({ requestJson: requestJsonObj })
            .then(result => {
                if (result.data.length === 1) {
                    this.selectedPBId = result.data[0].Id;
                    this.priceBookId = result.data[0].Id;
                    this.contractLineProductModalOpen = true;
                    return;
                }
                this.priceBookSelectionModalOpen = true;
                const options = [{ value: '', label: i18n.labelNone }];
                result.data.forEach(row => {
                    const pbOption = { value: row.Id, label: row.Name };
                    options.push(pbOption);
                    this.selectedPBId = row.Id;
                });
                this.pbOptions = options;
            })
            .catch(error => {
                this.error = error;
            });
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

    @api
    handleNewContractLine (parentRecId) {
        this.apiInProgress = true;
        this.parentRecordId = parentRecId;
    }

    @api
    handleEditContractLine (parentRecId, selectedCliRecord, actionName) {

        this.clearValues();
        this.actionType = actionName;

        if (!parentRecId
        || !selectedCliRecord
        || this.actionType !== PAGE_ACTION_TYPES.EDIT) {
            return;
        }

        this.parentRecordId = parentRecId;
        this.cliDetails = selectedCliRecord;
        this.selectedCLIProducts.push(selectedCliRecord);
        this.contractLineModalOpen = true;
    }

    @wire(queryRecords, { requestJson: '$fetchProductRequestObj' })
    fetchProductRecords ({ data, error }) {
        if (data) {
            this.apiInProgress = true;
            if (!verifyApiResponse(data)) {
                this.error = data.message;
                return;
            }

            this.populateProductRecords(data.data);
        } else if (error) {
            this._pBERecords = [];
            this.fetchedProductRecords = [];
            this.error = parseErrorMessage(error);
        }
    }

    populateProductRecords (data) {
        if (this.fetchedProductRecords && this.fetchedProductRecords.length > 0) return;

        data.forEach(row => {
            const priceBookEntry = {};
            priceBookEntry.Id = row.Id;
            priceBookEntry.UnitPrice = row.UnitPrice;
            priceBookEntry.Name = row.Product2.Name;
            priceBookEntry.Family = row.Product2.Family;
            priceBookEntry.ProductCode = row.Product2.ProductCode;
            priceBookEntry.Description = row.Product2.Description;
            priceBookEntry.ProductId = row.Product2Id;
            if (this.cliDetails && this.cliDetails.priceBookEntryId === row.Id) {
                priceBookEntry.isSelected = true;
                this.selectedProductRecord.push(priceBookEntry);
            } else {
                priceBookEntry.isSelected = false;
            }
            this.fetchedProductRecords.push(priceBookEntry);
        });

        this.showRecentModifiedRecords(this.fetchedProductRecords);

    }

    showRecentModifiedRecords (pBEList) {
        const products = [...pBEList];
        if (products && products.length > SHOW_ROWS) {
            this._pBERecords = products.splice(0,SHOW_ROWS);
        } else {
            this._pBERecords = products;
        }
        this.apiInProgress = false;
    }

    get i18n () {
        return i18n;
    }

    get showNextProductSelection () {
        return (!this.selectedCLIProducts.length >0);
    }

    get pBEList () {
        return (this._pBERecords && this._pBERecords.length) ? this._pBERecords : null;
    }

    get selectedPills () {
        const pills = this.selectedCLIProducts.map(item => {
            return {
                type: 'icon',
                label: item.productName,
                name: item.priceBookEntryId,
                iconName: 'standard:product',
                alternativeText: item.productName,
            };
        });
        return pills;
    }

    get showPills () {
        return (this.selectedCLIProducts && this.selectedCLIProducts.length > 0);
    }

    get cliRecords () {
        const cli = this.selectedCLIProducts.map((item, index) => {
            return {
                item,
                sNo: index + 1,
                filterString: `Product2Id = '${item.productId}'`
            };
        });
        return cli;
    }

    get requestJson () {
        const requestParameters = {
            objectName: CONTRACT_LINE_ITEM_OBJ.objectApiName
        }
        return JSON.stringify(requestParameters);
    }

    get fetchProductRequestObj () {
        if (!this.priceBookId) {
            return undefined;
        }
        return JSON.stringify({
            objectName: PRICE_BOOK_ENTRY_OBJ.objectApiName,
            fields: fieldsToRetrieve,
            whereClause: `${PBE_PRICE_BOOK_ID_FIELD.fieldApiName} ='${this.priceBookId}'`,
            sortField: PBE_LAST_MODIFIED_FIELD.fieldApiName,
            sortOrder: DEFAULT_ORDER,
            limitCount: PRICE_BOOK_LIMIT_COUNT
        });
    }

    get formatterType () {
        return (this.isMultiCurrencyEnabled) ?
            DECIMAL_FORMATTER : CURRENCY_FORMATTER;
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

    get badInputMessage () {
        return formatString(i18n.badInputDate, i18n.shortDateFormat);
    }

    get selectedProductCountInfo () {
        return `${this.selectedCLIProducts.length} ${this.i18n.items} ${this.i18n.selected}`;
    }

    get noRecordsFound () {
        return (this._pBERecords && this._pBERecords.length === 0);
    }

    handleNextProductSelection () {
        //clear search result when we are navigating to create/edit form.
        if (isNotUndefinedOrNull(this.searchTerm)) {
            this.filterListViewData();
        }
        this.contractLineProductModalOpen = false;
        this.contractLineModalOpen = true;
    }

    handleSelectProduct (event) {
        const isChecked = event.target.checked;
        const priceBookEntryId = event.target.value;
        const productName = event.target.dataset.name;

        //toggle the checkbox
        this.toggleProductSelection (priceBookEntryId, isChecked);

        //Edit - replace product
        if (this.actionType === PAGE_ACTION_TYPES.EDIT ) {
            this.cliRecordInfo  = JSON.parse(JSON.stringify(this.cliDetails));

            if ( priceBookEntryId !== this.cliDetails.priceBookEntryId ) {
                this.cliRecordInfo.assetId = null;
                this.cliRecordInfo.unitPrice = '';
            }

            this.selectedCLIProducts = [];
            this.clearUnSelectedProducts(priceBookEntryId, false);

        } else {
            //New CLI Plan 
            this.cliRecordInfo = {};
        }

        //Add or remove products 
        this.cliRecordInfo.priceBookEntryId = priceBookEntryId;
        this.cliRecordInfo.productName = productName;
        this.cliRecordInfo.listPrice = event.target.dataset.unitPrice;
        this.cliRecordInfo.productId = event.target.dataset.productId;

        if (isChecked) {
            this.addCLIRecord (this.cliRecordInfo);
        } else {
            this.removeCLIRecord(this.cliRecordInfo);
        }
    }

    handleBackCLI () {
        this.error = '';
        this.contractLineModalOpen = false;
        this.contractLineProductModalOpen = true;
    }

    clearUnSelectedProducts (priceBookEntryId, isSelected) {
        this._pBERecords.forEach(row => {
            if (row.Id !== priceBookEntryId) {
                row.isSelected = isSelected;
            }
        });

        this.fetchedProductRecords.forEach(row => {
            if (row.Id !== priceBookEntryId) {
                row.isSelected = isSelected;
            }
        });
    }

    addCLIRecord (cliRecord) {
        if (!cliRecord.serviceContractId) {
            cliRecord.serviceContractId = this.parentRecordId;
        }
        this.selectedCLIProducts.push(cliRecord);
    }

    removeCLIRecord (cliRecord) {
        if (cliRecord.priceBookEntryId) {
            this.selectedCLIProducts = this.selectedCLIProducts.filter(
                item => item.priceBookEntryId !== cliRecord.priceBookEntryId);
        }
    }

    toggleProductSelection (priceBookEntryId,isSelected) {
        this._pBERecords.forEach(row => {
            if (row.Id === priceBookEntryId) {
                row.isSelected = isSelected;
            }
        });

        this.fetchedProductRecords.forEach(row => {
            if (row.Id === priceBookEntryId) {
                row.isSelected = isSelected;
            }
        });
    }

    handlePillRemove (event) {
        const priceBookEntryId = event.detail.item.name;
        this.cliRecordInfo = {};
        this.toggleProductSelection (priceBookEntryId,false);
        this.cliRecordInfo.priceBookEntryId =priceBookEntryId;
        this.removeCLIRecord (this.cliRecordInfo);
    }

    handlePBChange (event) {
        this.selectedPBId = event.detail.value;
    }

    handleChange (event) {
        const fieldName = event.target.dataset.field;
        const priceBookEntryId = event.target.dataset.id;
        const value = event.target.value;
        let objIndex = 0;
        if (priceBookEntryId) {
            objIndex = this.selectedCLIProducts.findIndex(
                (obj => obj.priceBookEntryId === priceBookEntryId));
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
            this.showRecentModifiedRecords(this.fetchedProductRecords);
            return;
        }

        const searchRecords  = this.fetchedProductRecords.filter(item => {
            const loweredSearchValue = searchValue.toLowerCase();
            const productMatch = (item.Name)
                ? item.Name.toLowerCase().indexOf(loweredSearchValue)
                : -1;

            return ( productMatch !== -1);
        });
        this.showRecentModifiedRecords(searchRecords);

    }

    async saveServiceContract () {
        const fields = {};
        fields[SC_ID_FIELD.fieldApiName] = this.parentRecordId;
        fields[SC_PRICE_BOOK_ID_FIELD.fieldApiName] = this.selectedPBId;
        const recordInput = { fields };

        return updateRecord(recordInput)
            .then(() => {
                if (!this.priceBookId) {
                    this.priceBookId = this.selectedPBId;
                }
                this.selectedPBId = '';
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    async saveCLI () {
        return saveContractLineItem({ requestJson: JSON.stringify(this.selectedCLIProducts) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${result.data.length} ${result.data.length > 1 ?
                    this.i18n.clis : this.i18n.cli} ${this.i18n.saved}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.clearValues();
                //dispatch event to refresh the list view
                this.handleCloseAndRefresh();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    async handleSavePB () {
        if (isEmptyString(this.selectedPBId)) {
            this.clearValues();
            return;
        }
        this.apiInProgress = true;
        await this.saveServiceContract();
    }

    async handleSave () {
        if (!this.isValidInput()) return;
        if (this.apiInProgress) return;
        this.apiInProgress = true;

        //In case of single pricebook record, needs to save service contract object with PBId.
        if (!isEmptyString(this.selectedPBId)) {
            this.selectedPBId = await this.saveServiceContract();
        }
        await this.saveCLI();
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
        this._pBERecords = [];
        this.selectedProductRecord = [];
        this.fetchedProductRecords = [];
        this.selectedCLIProducts = [];
        this.pbOptions = [];
        this.cliRecordInfo = {};
        this.cliDetails = {};
        this.error = null;
        this.searchTerm = '';
        this.actionType = '';
        this.priceBookId = undefined;
        this.parentRecordId = undefined;
        this.contractLineProductModalOpen = false;
        this.priceBookSelectionModalOpen = false;
        this.contractLineModalOpen = false;
    }

}