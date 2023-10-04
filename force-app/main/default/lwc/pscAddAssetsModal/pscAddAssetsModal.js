import { LightningElement, api, track } from 'lwc';
import { isEmptyString, parseErrorMessage, verifyApiResponse,
    OBJECT_ICONS, guid } from 'c/utils';

import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelSearch from '@salesforce/label/c.Button_Search';
import labelPlaceholderSearch from '@salesforce/label/c.Placeholder_Search';
import labelProduct from '@salesforce/label/c.Label_Product';
import labelAddAssets from '@salesforce/label/c.Label_AddAssets';
import labelErrorParamMissing from '@salesforce/label/c.Error_MissingParameter';
import labelNoResultsFound from '@salesforce/label/c.Label_NoResultsFound';
import labelAscending from '@salesforce/label/c.Label_Ascending';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelAssets from '@salesforce/label/c.Label_Assets';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';
import PRODUCT_NAME_FIELD from '@salesforce/schema/Product2.Name';
import getAssetRecords from '@salesforce/apex/PSC_ManageResults_LS.getAssetRecords';

const i18n = {
    confirmBtn: labelConfirm,
    cancelBtn: labelCancel,
    searchBtn: labelSearch,
    placeholderSearch: labelPlaceholderSearch,
    labelProduct: labelProduct,
    addAssetsTitle: labelAddAssets,
    errorParamMissingMsg: labelErrorParamMissing,
    noResultsFound: labelNoResultsFound,
    labelAscending: labelAscending,
    labelAsset: labelAsset,
    labelAssets: labelAssets
};

export default class PscAddAssetsModal extends LightningElement {
    @api isModalOpen;
    @api deliveryMethod;
    @api assetColumns;
    @api assetIdList;
    @track assetList;

    dataToInsert = {};
    selectedRows = [];
    searchTerm = '';
    error = '';
    booleanFalse = false;
    isSearchDisabled = true;
    isConfirmDisabled = true;
    apiInProgress = false;
    isEmptyResult = false;

    productNameField = PRODUCT_NAME_FIELD.fieldApiName;
    productObject = PRODUCT2_OBJECT.objectApiName;
    productIcon = OBJECT_ICONS.product2;
    productId;
    sortBy;
    sortDirection;
    placeholderLookup = i18n.placeholderSearch + ' ' + i18n.labelProduct;

    get i18n () {
        return i18n;
    }

    get entityName () {
        return ( this.assetList.length <= 1 ? i18n.labelAsset :  i18n.labelAssets  );
    }

    connectedCallback () {
        if (this.assetColumns.length === 0) {
            this.handleError(i18n.errorParamMissingMsg);
        }
    }

    handleLookupChange (event) {
        if (!event.detail) return;

        event.stopPropagation();
        const detail = event.detail;
        this.productId = detail.value;
        this.enableSearch();
    }

    handleSearchTermChange (event) {
        this.searchTerm = event.target.value.trim();
        this.enableSearch();
    }

    handleSearch () {
        this.assetList = undefined;
        this.isEmptyResult = false;
        this.apiInProgress = true;
        const objRequest = { id: this.productId, searchKeyword: this.searchTerm };

        getAssetRecords({ requestJson: JSON.stringify(objRequest) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.handleError(result.message);
                    return;
                }

                if ( !result.data || result.data.length === 0 ) {
                    this.isEmptyResult = true;
                    this.assetList = undefined;
                    return;
                }
                this.assetList = result.data;
                this.assetList.forEach(asset => {
                    asset.Included = (this.assetIdList.indexOf(asset.Id) === -1) ? 'No' : 'Yes';
                });
            })
            .catch(error => {
                this.assetList = undefined;
                this.handleError(parseErrorMessage(error));
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    enableSearch () {
        this.isSearchDisabled =
            (this.productId && this.searchTerm.length > 2 && isEmptyString(this.error) )
                ? false : true;
    }

    handleCancel () {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    //Function to handle select event on table
    handleRowSelection (event) {
        this.selectedRows = event.detail.selectedRows;
        this.isConfirmDisabled = this.selectedRows.length === 0;
    }

    handleConfirm () {
        const psciMapToDisplay = {};
        this.selectedRows.forEach(row => {
            if ( row.Included === 'Yes' ) return;
            const randomId = guid();
            const psciObj = {
                Id: randomId,
                AssetId: row.Id,
                SVMXA360__DeliveryMethod__c: this.deliveryMethod,
                TempId: randomId,
                Status: 'Draft'
            };
            this.dataToInsert[randomId] = psciObj;

            psciMapToDisplay[randomId] = {
                ...psciObj,
                'Asset.SerialNumber': row.SerialNumber,
                'Asset.LocationId': row.LocationId,
                'Name': row.Name,
                'Asset.Location.Name': row.Location ? row.Location.Name : ''
            };
        });

        this.dispatchEvent(new CustomEvent('confirm', { detail:
            { dataToInsert: this.dataToInsert, mapToDisplay: psciMapToDisplay }
        } ));
    }

    handleError (message) {
        this.error = message;
        this.apiInProgress = false;
    }
}