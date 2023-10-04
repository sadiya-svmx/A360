import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { parseErrorMessage, verifyApiResponse } from 'c/utils';

import saveApplicableProduct
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.saveApplicableProducts';
import getApplicableProduct
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getApplicableProduct';
import getProductList
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getProductList';

import APPLICABLE_PRODUCT_OBJ from '@salesforce/schema/ApplicableProduct__c';
import PRODUCT_FAMILY_FIELD from '@salesforce/schema/ApplicableProduct__c.ProductFamily__c';
import WORK_TYPE_NAME_FIELD from '@salesforce/schema/WorkType.Name';

import labelCreateNewApplicableProduct from '@salesforce/label/c.Label_CreateNewApplicableProduct';
import labelEditApplicableProduct from '@salesforce/label/c.Label_EditApplicableProduct';
import labelSelectProductType from '@salesforce/label/c.Label_SelectProductType';
import labelProductInApplicableProduct from '@salesforce/label/c.Label_ProductInApplicableProduct';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelNext from '@salesforce/label/c.Button_Next';
import labelBack from '@salesforce/label/c.Button_Back';
import labelSelectProductFamily from '@salesforce/label/c.Label_SelectProductFamily';
import labelWorkType from '@salesforce/label/c.Label_WorkType';
import labelSave from '@salesforce/label/c.Button_Save';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDuplicate from '@salesforce/label/c.Label_Duplicate';
import labelDuplicateError from '@salesforce/label/c.Label_DuplicateError';
import labelUpdateMessage from '@salesforce/label/c.Label_UpdateMessage';
import labelCreatedMessage from '@salesforce/label/c.Label_CreatedMessage';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelPlaceholderForProductSearch
    from '@salesforce/label/c.Label_PlaceholderForProductSearch';
import labelSearch from '@salesforce/label/c.Button_Search';
import labelActive from '@salesforce/label/c.Label_Active';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelItemSelected from '@salesforce/label/c.Label_ItemSelected';
import labelItemsSelected from '@salesforce/label/c.Label_ItemsSelected';

const PRODUCT_OPTION_VALUE = 'Product';
const PRODUCT_FAMILY_OPTION_VALUE = 'Product Family';

const i18n = {
    productTypetitleNew: labelCreateNewApplicableProduct,
    productTypetitleEdit: labelEditApplicableProduct,
    productTypeSelection: labelSelectProductType,
    cancel: labelCancel,
    next: labelNext,
    back: labelBack,
    product: labelProductInApplicableProduct,
    productFamily: labelProductFamily,
    selectProductFamily: labelSelectProductFamily,
    workType: labelWorkType,
    save: labelSave,
    loading: labelLoading,
    duplicate: labelDuplicate,
    duplicateError: labelDuplicateError,
    updatedMsg: labelUpdateMessage,
    createdMsg: labelCreatedMessage,
    noResults: labelNoResults,
    placeholder: labelPlaceholderForProductSearch,
    search: labelSearch,
    active: labelActive,
    description: labelDescription,
    itemSelected: labelItemSelected,
    itemsSelected: labelItemsSelected,
}

export default class MplnApplicableProductDetail extends LightningElement {

    @track productTypetitle;
    @track error;
    @track newApplicableProductModalOpen;
    @track productFamilySelectionModalOpen;
    @track showWorkTypeSelectionModal;
    @track showProductSelectionModal;
    @track recordInfo = {};
    @track apiInProgress = false;
    @track disableBackButtonOfProdFamModal = false;
    @track disableBackButtonOfWTPModal = false;
    @track noRecordsFound = false;
    @track productRecordsList = [];
    @track columns;
    @track disableSearchButton = true;
    @track showProductWorkTypeSelectionModal;
    @track applicableProductRecordList = [];
    @track selectedRowsId = [];

    selectedProductRecords = [];
    searchKeywordForProduct;
    productFamilyOptions = [];
    currentRecordId;
    workTypeNameField = WORK_TYPE_NAME_FIELD.fieldApiName;
    selectedProductType = null;
    _productTableHeight = 100;

    @wire(getObjectInfo, { objectApiName: APPLICABLE_PRODUCT_OBJ })
    objectInfo;

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

    renderedCallback () {
        const productListViewTable = this.template.querySelector(
            '.svmx-product-list-view_table');
        if (productListViewTable) {
            this._productTableHeight = productListViewTable.offsetHeight;
        }
    }

    @api
    handleNewApplicableProduct (parentRecordId) {
        this.parentRecordId = parentRecordId;
        this.recordInfo.maintenancePlanTemplateId = parentRecordId;
        this.newApplicableProductModalOpen = true;
        this.disableBackButtonOfProdFamModal = false;
        this.disableBackButtonOfWTPModal = false;
        this.productTypetitle = i18n.productTypetitleNew;
    }

    @api
    handleEditApplicableProduct (recId) {
        this.currentRecordId = recId;
        this.productTypetitle = i18n.productTypetitleEdit;
        getApplicableProduct({
            applicableProductId: this.currentRecordId
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                if (result.data.productId) {
                    this.populateApplProdInfoForProductPath(result.data);
                } else if (result.data.productFamily) {
                    this.populateApplicableProductInfo(result.data);
                    this.handleNextOfProductFamilyModal();
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.currentRecordId = undefined;
            });
    }

    populateApplicableProductInfo (data) {
        this.recordInfo = { ...this.recordInfo, ...data };
        this.selectedProductType = PRODUCT_FAMILY_OPTION_VALUE;
        this.disableBackButtonOfProdFamModal = true;
        this.recordInfo.productFamilyLabel
            = this.getProductFamilyLabel(this.recordInfo.productFamily);
    }

    populateApplProdInfoForProductPath (data) {
        this.applicableProductRecordList = [{ ...data }];
        this.selectedProductType = PRODUCT_OPTION_VALUE;
        this.selectedRowsId = [data.productId];
        this.showProductWorkTypeSelectionModal = true;
        this.disableBackButtonOfWTPModal = true;
    }

    get productTypeOptions () {
        return [
            { label: i18n.product, value: PRODUCT_OPTION_VALUE },
            { label: i18n.productFamily, value: PRODUCT_FAMILY_OPTION_VALUE },
        ];
    }

    get isDisableNextButtonOfAPModal () {
        return (!this.selectedProductType);
    }

    get isDisableNextButtonOfProdFamModal () {
        return (!this.recordInfo.productFamily);
    }

    get isDisableNextButtonOfProductSearchModal () {
        return this.selectedRowsId.length === 0;
    }

    get i18n () {
        return i18n;
    }

    get getRecordInfo () {
        return this.recordInfo;
    }

    get countOfSelectedRowsString () {
        const rowsCount = this.selectedRowsId.length;
        const countText = rowsCount < 2 ? i18n.itemSelected : i18n.itemsSelected;
        return `${rowsCount} ${countText}`;
    }

    getColumns () {
        return [
            {
                label: this.i18n.product,
                fieldName: 'name',
                hideDefaultActions: true,
                wrapText: true,
                type: 'text',
            },
            {
                label: this.i18n.productFamily,
                fieldName: 'productFamily',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.active,
                fieldName: 'isActive',
                type: 'boolean',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                type: 'text',
                hideDefaultActions: true,
                wrapText: true,
            }
        ];
    }

    getProductFamilyLabel (productFamilyValue) {
        let productFamilyLabel = '';
        for (let i = 0; i < this.productFamilyOptions.length; i++) {
            if (this.productFamilyOptions[i].value === productFamilyValue) {
                productFamilyLabel = this.productFamilyOptions[i].label;
                break;
            }
        }
        return productFamilyLabel;
    }

    handleNextOfNewAPModal () {
        if (this.selectedProductType === PRODUCT_FAMILY_OPTION_VALUE) {
            this.newApplicableProductModalOpen = false;
            this.productFamilySelectionModalOpen = true;
            this.applicableProductRecordList = [];
            this.productRecordsList = [];
            this.selectedRowsId = [];
            this.selectedProductRecords = [];
        } else if (this.selectedProductType === PRODUCT_OPTION_VALUE) {
            this.showProductSelectionModal = true;
            this.newApplicableProductModalOpen = false;
            this.columns = this.getColumns();
            this.recordInfo = {};
        }
    }

    handleNewCancelModal () {
        this.newApplicableProductModalOpen = false;
        this.productFamilySelectionModalOpen = false;
        this.showWorkTypeSelectionModal = false;
        this.showProductSelectionModal = false;
        this.showProductWorkTypeSelectionModal = false;
        this.selectedProductType = null;
        this.currentRecordId = null;
        this.recordInfo = {};
        this.applicableProductRecordList = [];
        this.productRecordsList = [];
        this.selectedRowsId = [];
        this.selectedProductRecords = [];
        this.error = undefined;
        this.noRecordsFound = false;
        this.disableSearchButton = true;
    }

    handleNextOfProductFamilyModal () {
        this.productFamilySelectionModalOpen = false;
        this.showWorkTypeSelectionModal = true;
    }

    handleBackOfProductFamilyModal () {
        this.newApplicableProductModalOpen = true;
        this.productFamilySelectionModalOpen = false;
    }

    handleBackOfWorkTypeModal () {
        this.productFamilySelectionModalOpen = true;
        this.showWorkTypeSelectionModal = false;
        this.error = undefined;
    }

    handleBackOfProductModal () {
        this.newApplicableProductModalOpen = true;
        this.showProductSelectionModal = false;
        this.disableSearchButton = true;
    }

    handleNextOfProductModal () {
        const selectedProductRows = this.template.querySelector(
            'lightning-datatable').getSelectedRows();
        if (selectedProductRows.length > 0) {
            this.selectedProductRecords = [...selectedProductRows];
            const tempApplicableProductRecordList = [];
            const tempSelectedRowsId = [];
            for (let i = 0; i < this.selectedProductRecords.length; i++) {
                const productRecordId = this.selectedProductRecords[i].id;
                const record = {};
                const objIndex = this.applicableProductRecordList.findIndex((
                    obj => obj.productId === productRecordId));
                record.workTypeId = objIndex !== -1 ?
                    this.applicableProductRecordList[objIndex].workTypeId
                    : null;
                record.id = objIndex !== -1 && this.applicableProductRecordList[objIndex].id
                    ? this.applicableProductRecordList[objIndex].id
                    : null;
                record.productId = productRecordId;
                record.productName = this.selectedProductRecords[i].name;
                record.maintenancePlanTemplateId = this.parentRecordId;
                tempApplicableProductRecordList.push(record);
                tempSelectedRowsId.push(productRecordId);
            }
            this.selectedRowsId = tempSelectedRowsId;
            this.applicableProductRecordList = tempApplicableProductRecordList;
            this.showProductSelectionModal = false;
            this.showProductWorkTypeSelectionModal = true;
        }
    }

    handleBackOfProductWorkTypeModal () {
        this.showProductSelectionModal = true;
        this.showProductWorkTypeSelectionModal = false;
        this.disableSearchButton = true;
        this.error = undefined;
    }

    handleRowSelection (event) {
        this.selectedRowsId = event.detail.selectedRows.map(element => {
            return element.id;
        });
        this.selectedProductRecords = event.detail.selectedRows.map(element => {
            return element;
        });
    }

    handleChangeProductType (event) {
        this.selectedProductType = event.detail.value;
    }

    handleChangeProductFamily (event) {
        this.recordInfo.productFamily = event.detail.value;
        this.recordInfo.productFamilyLabel
            = this.getProductFamilyLabel(this.recordInfo.productFamily);
    }

    handleChangeOfSearchBox (event) {
        this.searchKeywordForProduct = event.detail.value.trim();
        if (this.searchKeywordForProduct.length > 2) {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
        }
    }

    handleLookupFieldChange (event) {
        this.recordInfo.workTypeId = event.detail.value;
    }

    handleLookupFieldChangeForProductPath (event) {
        const productId = event.target.dataset.id;
        const value = event.target.value;
        const objIndex = this.applicableProductRecordList.findIndex((
            obj => obj.productId === productId));
        this.applicableProductRecordList[objIndex].workTypeId = value;
    }

    handleSearchButton () {
        if (this.apiInProgress) return;

        this.apiInProgress = true;
        getProductList({
            searchKeyword: this.searchKeywordForProduct
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            if (result.data && result.data.length === 0) {
                this.noRecordsFound = true;
                this.productRecordsList = [...this.selectedProductRecords];
                return;
            }
            this.productRecordsList = this.populateProductRecordsList(result.data);
            this.error = undefined;
            this.noRecordsFound = false;
        }).catch(error => {
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateProductRecordsList (data) {
        const newFilteredData = data.filter(element =>
            this.selectedRowsId.indexOf(element.id) === -1);
        return [...this.selectedProductRecords, ...newFilteredData];
    }

    handleSave () {
        if (this.apiInProgress) return;

        this.apiInProgress = true;
        let request;
        if (this.selectedProductType === PRODUCT_FAMILY_OPTION_VALUE) {
            request = [{ ...this.recordInfo }];
            delete request[0].productFamilyLabel;
        } else if (this.selectedProductType === PRODUCT_OPTION_VALUE) {
            request = this.applicableProductRecordList;
        }
        saveApplicableProduct({ requestJson: JSON.stringify( request ) } )
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

                let toastMsg;
                if (this.selectedProductType === PRODUCT_FAMILY_OPTION_VALUE) {
                    toastMsg = `${this.recordInfo.id ?
                        this.i18n.updatedMsg : this.i18n.createdMsg}`;
                } else if (this.selectedProductType === PRODUCT_OPTION_VALUE) {
                    toastMsg = `${this.applicableProductRecordList[0].id ?
                        this.i18n.updatedMsg : this.i18n.createdMsg}`;
                }
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleNewCancelModal();
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
}