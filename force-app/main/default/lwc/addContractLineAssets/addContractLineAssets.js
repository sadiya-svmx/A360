import { LightningElement, track, api, wire } from 'lwc';
import { parseErrorMessage, verifyApiResponse } from 'c/utils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ASSET_OBJECT from '@salesforce/schema/Asset';

import { loadStyle } from 'lightning/platformResourceLoader';
import addContractLineAssetsResource
    from '@salesforce/resourceUrl/addContractLineAssets';
import getAssetList
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getAssetList';

import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelSearch from '@salesforce/label/c.Button_Search';
import labelItemSelected from '@salesforce/label/c.Label_ItemSelected';
import labelItemsSelected from '@salesforce/label/c.Label_ItemsSelected';
import labelAddContractLineAssets from '@salesforce/label/c.Title_AddContractLineAssets';
import placeholderMaintenanceAssets from '@salesforce/label/c.Placeholder_SearchMaintenanceAssets';
import placeholderSearchAssets from '@salesforce/label/c.Placeholder_SearchAssets';
import labelPlaceholderSearch from '@salesforce/label/c.Placeholder_Search';


const i18n = {
    title: labelAddContractLineAssets,
    placeholder: placeholderMaintenanceAssets,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    loading: labelLoading,
    noResults: labelNoResults,
    cancel: labelCancel,
    confirm: labelConfirm,
    placeholderForAssetSearch: placeholderSearchAssets,
    search: labelSearch,
    itemSelected: labelItemSelected,
    itemsSelected: labelItemsSelected,
    placeholderSearch: labelPlaceholderSearch,
}

export default class AddContractLineAssets extends LightningElement {

    @track errorForAssetModal;
    @track apiInProgress = false;
    @track noRecordsFoundForAsset = false;
    @track showAssetSelectionModal = false;
    @track disableSearchButton = true;
    @track selectedRows = [];
    @track assetRecordsList = [];
    @track loadedAssetIds = [];
    @track assetColumns;
    @track accountRecordId;

    searchKeywordForAsset;
    _assetTableHeight = 100;
    baseUrl;
    countInterval = 1;

    renderedCallback () {
        loadStyle(this, addContractLineAssetsResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        this.baseUrl = window.location.origin;
        const assetListViewTable = this.template.querySelector(
            '.svmx-asset-list-view_table');
        if (assetListViewTable) {
            this._assetTableHeight = assetListViewTable.offsetHeight;
        }
    }

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    objectInfoAsset ({ error, data }) {
        if (error) {
            this.errorForAssetModal = parseErrorMessage(error);
        } else if (data && data.apiName === 'Asset') {
            this.assetColumns = this.getAssetColumns(data);
        }
    }

    @api
    handleAddAssets (accountRecId,loadedRowsIds) {
        this.accountRecordId = accountRecId;
        this.loadedAssetIds = JSON.parse(JSON.stringify(loadedRowsIds));
        this.showAssetSelectionModal = true;
    }

    get i18n () {
        return i18n;
    }

    get computedAssetDataTableHeightWidth () {
        return (this.assetRecordsList.length > 10) ?
            `width:1140px; height:420px;` :
            `width:1140px; height: calc(100% - ${this._assetTableHeight}px);`;
    }

    get isDisableConfirmButtonOfAssetModal () {
        return this.selectedRows.length === 0;
    }

    get assetListHasRecords () {
        return this.assetRecordsList?.length > 0;
    }

    getAssetColumns (objectInfo) {
        return [
            {
                label: objectInfo.fields.Name.label,
                fieldName: 'nameUrl',
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'Name'
                    },
                    tooltip: {
                        fieldName: 'Name'
                    },
                    target: '_blank'
                }
            },
            {
                label: objectInfo.fields.AccountId.label,
                fieldName: 'accountUrl',
                type: 'url',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'accountName'
                    },
                    tooltip: {
                        fieldName: 'accountName'
                    },
                    target: '_blank'
                }
            },
            {
                label: objectInfo.fields.SerialNumber.label,
                fieldName: 'SerialNumber',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            },
            {
                label: objectInfo.fields.Status.label,
                fieldName: 'Status',
                type: 'text',
                hideDefaultActions: true,
                wrapText: false,
            }
        ];
    }


    handleCancelOfAssetModal () {
        this.showAssetSelectionModal = false;
        this.disableSearchButton = true;
        this.noRecordsFoundForAsset = false;
        this.assetRecordsList = [];
        this.searchKeywordForAsset = null;
        this.selectedRows = [];
        this.errorForAssetModal = undefined;
    }

    handleChangeOfSearchBox (event) {
        this.searchKeywordForAsset = event.detail.value.trim();
        if (this.searchKeywordForAsset.length > 2) {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
        }
    }

    handleAssetRowSelection (event) {
        this.selectedRows  = [];
        if (event.detail.selectedRows.length > 0) {
            this.selectedRows = event.detail.selectedRows;
        }
    }

    handleSearchButton () {
        if (this.apiInProgress) return;
        this.apiInProgress = true;
        getAssetList({
            accountId: this.accountRecordId,
            searchKeyword: this.searchKeywordForAsset,
            loadedRowsIds: this.loadedAssetIds,
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.errorForAssetModal = result.message;
                return;
            }
            if (result.data && result.data.length === 0) {
                this.noRecordsFoundForAsset = true;
                this.assetRecordsList = [];
                return;
            }
            this.assetRecordsList = this.populateAssetRecordsList(result.data);
            this.errorForAssetModal = undefined;
            this.noRecordsFoundForAsset = false;
        }).catch(error => {
            this.errorForAssetModal = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateAssetRecordsList (data) {
        const sfdcBaseUrl = this.baseUrl+'/';
        const assetListViewData = [];
        data.forEach(row=>{
            if (row.Name) {
                row.nameUrl = sfdcBaseUrl + row.Id;
            }
            if (row.AccountId) {
                row.accountUrl = sfdcBaseUrl + row.AccountId;
                row.accountName = row.Account.Name;
            }
            assetListViewData.push({ ...row });
        });
        return assetListViewData;
    }

    handleConfirmOfAssetModal () {
        if (!this.selectedRows || this.selectedRows.length === 0) {
            return;
        }

        const selectedAssets = this.selectedRows.map(element => {
            return {
                Id: element.Id,
                Name: element.Name,
                serviceContractPlanId: null,
                startDate: null
            };
        });
        this.dispatchEvent(
            new CustomEvent('refresh', {
                detail: {
                    value: selectedAssets
                }
            })
        );
        this.handleCancelOfAssetModal();
    }
}