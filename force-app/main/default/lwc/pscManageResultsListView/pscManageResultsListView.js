import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { parseErrorMessage, formatString, verifyApiResponse, sortObjectArray,
    castFieldToSupportType, FIELD_DATA_TYPES, getNameFieldFromFieldMetadata,
    getObjectNameFromFieldMetadata, CUSTOM_FIELD_DATA_TYPES, isEmptyString } from 'c/utils';
import { getFieldDefinitionsForEntities } from 'c/metadataService';

import labelManageResultLines from '@salesforce/label/c.Label_ManageResultLines';
import labelButtonBackToCampaignDetail from '@salesforce/label/c.Button_BackToCampaignDetail';
import labelAddItemsManually from '@salesforce/label/c.Label_AddItemsManually';
import labelItemsFound from '@salesforce/label/c.Label_ItemsFound';
import labelDeliver from '@salesforce/label/c.Label_Deliver';
import labelSaveAndDeliver from '@salesforce/label/c.Label_SaveAndDeliver';
import labelDeliveryConfirmation from '@salesforce/label/c.Label_DeliveryConfirmation';
import labelDeliveryConfirmationMsg from '@salesforce/label/c.Message_DeliveryConfirmationMsg';
import labelDeliveryMethod from '@salesforce/label/c.Label_DeliveryMethod';
import labelChangeDeliveryMethod from '@salesforce/label/c.Label_ChangeDeliveryMethod';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelPlaceholderSearch from '@salesforce/label/c.Placeholder_Search';
import labelAscending from '@salesforce/label/c.Label_Ascending';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelChangeDeliveryMsg from '@salesforce/label/c.Label_ChangeDeliveryMsg';
import labelAddAssets from '@salesforce/label/c.Label_AddAssets';
import labelExitConfirmation from '@salesforce/label/c.Message_ExitConfirmation';
import labelBtnExitWithoutSave from '@salesforce/label/c.Button_ExitWithoutSave';
import labelBtnSaveAndExit from '@salesforce/label/c.Button_SaveAndExit';
import labelErrorMissingParam from '@salesforce/label/c.Error_MissingParameter';
import labelItemsGenerated from '@salesforce/label/c.Message_ItemsGenerated';
import labelPSCI from '@salesforce/label/c.Label_Product_Service_Campaign_Item';
import labelPSCIs from '@salesforce/label/c.Label_Product_Service_Campaign_Items';
import getResultLines from '@salesforce/apex/PSC_ManageResults_LS.getResultLines';
import getAddAssetColumns from '@salesforce/apex/PSC_ManageResults_LS.getAddAssetColumns';
import insertUpdatePsciRecords from '@salesforce/apex/PSC_ManageResults_LS.insertUpdatePsciRecords';
import initiateGenerateOutputBatch from
    '@salesforce/apex/PSC_ManageResults_LS.initiateGenerateOutputBatch';

import NAME_FIELD from '@salesforce/schema/ProductServiceCampaign.ProductServiceCampaignName';
import PSC_DELIVERY_METHOD_FIELD from '@salesforce/schema/ProductServiceCampaign.DeliveryMethod__c';
import PRODUCT_SERVICE_CAMPAIGN_OBJECT from '@salesforce/schema/ProductServiceCampaign';
import PRODUCT_SERVICE_CAMPAIGN_ITEM_OBJECT from '@salesforce/schema/ProductServiceCampaignItem';
import PSCI_STATUS_FIELD from '@salesforce/schema/ProductServiceCampaignItem.Status';

const i18n = {
    manageResultLines: labelManageResultLines,
    backButton: labelButtonBackToCampaignDetail,
    addItemsManuallyButton: labelAddItemsManually,
    itemsFoundMsg: labelItemsFound,
    deliverButton: labelDeliver,
    saveDeliverButton: labelSaveAndDeliver,
    deliveryConfirmationTitle: labelDeliveryConfirmation,
    deliveryConfirmationMsg: labelDeliveryConfirmationMsg,
    deliveryMethodButton: labelDeliveryMethod,
    changeDeliveryMethodTitle: labelChangeDeliveryMethod,
    confirmBtn: labelConfirm,
    cancelBtn: labelCancel,
    labelSearch: labelPlaceholderSearch,
    labelAscending: labelAscending,
    labelLoading: labelLoading,
    changeDeliveryMsg: labelChangeDeliveryMsg,
    addAssetsTitle: labelAddAssets,
    exitConfirmationMsg: labelExitConfirmation,
    btnExitWithoutSave: labelBtnExitWithoutSave,
    btnSaveAndExit: labelBtnSaveAndExit,
    errorMissingParam: labelErrorMissingParam,
    itemsGeneratedMsg: labelItemsGenerated,
    labelPSCI: labelPSCI,
    labelPSCIs: labelPSCIs
}

const psciColumnListToFilter = [
    'Asset.Name',
    'Asset.SerialNumber',
    'Asset.Location.Name',
    'Status',
    'SVMXA360__DeliveryMethod__c'
];

const psciColumnListToDisplayMap = {
    'Asset.Name': null,
    'Asset.SerialNumber': null,
    'Asset.LocationId': null,
    'Status': null,
    'SVMXA360__DeliveryMethod__c': null,
};

const psciColumnList = [
    'Id',
    'AssetId',
    'Asset.Location.Name',
    ...Object.keys(psciColumnListToDisplayMap)
];

const ROW_ACTIONS = [
    { label: i18n.deliveryMethodButton, name: 'changeDelivery' }
];

const ROW_ACTIONS_DISABLED = [
    { label: i18n.deliveryMethodButton, name: 'changeDelivery', disabled: true }
];

const PSCI_DELIVERY_METHOD_FIELD = 'SVMXA360__DeliveryMethod__c';
const DRAFT = 'Draft';
const NO_DELIVERY = 'NoDelivery';
const OUTPUT_GENERATED = 'OutputGenerated';
const CONSOLE = 'Console';
const LookupReferenceNameMap = {};
const FIELD_NAME_CONSTANT = "Name";
const ASSET_NAME_CONSTANT = "Asset.Name";

export default class PscManageResultsListView extends NavigationMixin(LightningElement) {
    pscId;
    pscName;
    defaultDeliveryMethod;
    sortBy = ASSET_NAME_CONSTANT;
    sortDirection;
    modalTitle;
    classSize = '';
    latestSearchKey = '';
    deliveryMethodToSet = null;
    itemsToGenerate = 0;
    psciCount = formatString(i18n.itemsFoundMsg, '0');

    openModal = false;
    showChangeDeliveryContent = false;
    showExitContent = false;
    showDeliveryConfirmationContent = false;
    showAddItem = false;
    hasNoneSelected = true;
    apiInProgress = true;
    isEmptyDeliveryMethod = true;
    isEmptyDeliverLines = true;

    deliveryOptions;
    dataToUpdate = {};
    dataToInsert = {};
    objectWiseFields = {};
    psciMap = {};
    selectedRows = [];

    @track filterPsciList;
    @track psciColumns = [];
    @track assetColumns = [];
    @track assetIdList = [];
    @track updatedSelectedRows = [];

    deliveryMethodMap = {};
    statusMap = {};
    appNavigationType;

    get i18n () {
        return i18n;
    }

    get entityName () {
        return ( this.filterPsciList.length <= 1 ? i18n.labelPSCI :  i18n.labelPSCIs  );
    }

    connectedCallback () {
        this.fetchAssetColumns();
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        if ( currentPageReference && currentPageReference.state
          && currentPageReference.state.c__pscId) {
            this.pscId = currentPageReference.state.c__pscId;
            this.appNavigationType = currentPageReference.state.c__type;
            this.initializePSCDetails();
        } else {
            this.handleError(i18n.errorMissingParam);
        }
    }

    @wire(getRecord, { recordId: '$pscId', fields: [NAME_FIELD, PSC_DELIVERY_METHOD_FIELD]})
    productServiceCampaignResult ({ error, data }) {
        if (error) {
            this.handleError( parseErrorMessage(error) );
        } else if (data) {
            this.pscName = data.fields.ProductServiceCampaignName.value;
            this.defaultDeliveryMethod = data.fields.SVMXA360__DeliveryMethod__c.value;
        }
    }

    async initializePSCDetails () {
        this.objectWiseFieldsSegregation();
        if (!this.objectWiseFields) return;

        const objectDefinitionMap = await this.getObjectDefinitions();
        Object.entries(this.objectWiseFields).forEach(([objectName, displayFields]) => {

            if (objectName === PRODUCT_SERVICE_CAMPAIGN_ITEM_OBJECT.objectApiName) {
                this.deliveryOptions = objectDefinitionMap[objectName].
                    fields[PSCI_DELIVERY_METHOD_FIELD].picklistValues;

                const statusOptions = objectDefinitionMap[objectName].
                    fields[PSCI_STATUS_FIELD.fieldApiName].picklistValues;

                this.setPicklistMap(this.deliveryOptions, this.deliveryMethodMap);
                this.setPicklistMap(statusOptions, this.statusMap);

                this.constructColumnMetaData(
                    objectDefinitionMap[objectName], displayFields);
            } else {
                this.constructColumnMetaData(
                    objectDefinitionMap[objectName], displayFields, objectName);
            }
        });
        psciColumnListToDisplayMap.RowAction = {
            type: 'action',
            typeAttributes: {
                rowActions: { fieldName: 'actions' }
            },
        };

        this.psciColumns = Object.values(psciColumnListToDisplayMap);
        await this.fetchResultLine();
        this.performSort();
    }

    setPicklistMap (picklistValueList, picklistMap) {
        picklistValueList.forEach(row => {
            picklistMap[row.value] = row.label;
        });
    }

    async getObjectDefinitions () {
        const objectDefinitionMap = {};
        const objectDefinitionList =
            await getFieldDefinitionsForEntities(Object.keys(this.objectWiseFields))
                .then( result => {
                    if (!verifyApiResponse(result)) {
                        this.handleError( parseErrorMessage(result.message) );
                        return null;
                    }
                    this.error = null;
                    return result.data;
                })
                .catch(error => {
                    this.handleError( parseErrorMessage(error) );
                    return null;
                });

        objectDefinitionList.forEach(objectDef => {
            const objectDefinition = Object.assign({}, objectDef);
            objectDefinition.nameFields = [];
            objectDefinition.fields = {};

            objectDefinition.fieldDefinitions.forEach(entity => {
                objectDefinition.fields[entity.apiName] = { ...entity };
                const entityDef = objectDefinition.fields[entity.apiName];
                if (entity.nameField) {
                    objectDefinition.nameFields.push(entity.apiName);
                }

                if (entity.dataType.toUpperCase() === FIELD_DATA_TYPES.REFERENCE) {
                    entityDef.referenceToInfos = [
                        { apiName: entity.referenceTo[0], nameFields: entity.referenceNameFields }
                    ];
                    entityDef.relatedObjectName = getObjectNameFromFieldMetadata(entityDef);
                    entityDef.relatedNameField = getNameFieldFromFieldMetadata(entityDef);
                }
            });
            objectDefinitionMap[objectDefinition.apiName] = objectDefinition;
        })
        // eslint-disable-next-line consistent-return
        return objectDefinitionMap;
    }

    objectWiseFieldsSegregation () {
        const psciColumnListToDisplay = Object.keys(psciColumnListToDisplayMap);
        psciColumnListToDisplay.forEach(field => {
            if ( field.includes('.') ) {
                const fieldArray = field.split('.');
                this.objectWiseFields[fieldArray[0]] = this.objectWiseFields[fieldArray[0]] || [];
                this.objectWiseFields[fieldArray[0]].push(fieldArray[1]);
            } else {
                this.objectWiseFields[PRODUCT_SERVICE_CAMPAIGN_ITEM_OBJECT.objectApiName] =
                    this.objectWiseFields[PRODUCT_SERVICE_CAMPAIGN_ITEM_OBJECT.objectApiName] || [];
                this.objectWiseFields[
                    PRODUCT_SERVICE_CAMPAIGN_ITEM_OBJECT.objectApiName].push(field);
            }
        });
    }

    constructColumnMetaData ( objectDefinition, columnListToDisplay, parentName ) {
        columnListToDisplay.forEach(field => {
            if ( !objectDefinition.fields[field] ) return;
            psciColumnListToDisplayMap[this.getFieldFullName(parentName, field)] =
                this.getColumns(objectDefinition.fields[field], parentName);
        });
    }

    getFieldFullName (parentName, field) {
        return parentName ? parentName + '.' + field : field;
    }

    getColumns (columnDetail, parentName) {
        const dataType = columnDetail.dataType.toLowerCase();
        const columnDef = {
            fieldName: this.getFieldFullName(parentName, columnDetail.apiName),
            type: castFieldToSupportType(dataType),
            label: columnDetail.label,
            hideDefaultActions: true,
            sortable: true
        };
        columnDef.typeAttributes = {
            ...columnDef,
            disabled: true,
            fieldType: dataType
        };

        if (columnDef.type === CUSTOM_FIELD_DATA_TYPES.X_LOOKUP) {
            LookupReferenceNameMap[columnDef.fieldName] =  this.getFieldFullName(parentName,
                (`${columnDetail.relatedObjectName}.${columnDetail.relatedNameField}`));
            columnDef.typeAttributes.disabled = true;
            columnDef.typeAttributes.meta = JSON.stringify({
                object: columnDetail.relatedObjectName,
                referenceNameFields: columnDetail.relatedNameField
            });
        }
        return columnDef;
    }

    fetchResultLine () {
        const requestObject = { id: this.pscId, fieldApiNames: psciColumnList };
        return getResultLines( { requestJson: JSON.stringify(requestObject) } )
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.handleError( result.message );
                    return;
                }
                if (!result.data || result.data.length <= 0) {
                    this.apiInProgress = false;
                    return;
                }

                this.psciMap = this.updatePicklistLabel(result.data);
                result.data = Object.values(this.psciMap);
                this.filterPsciList = result.data;

                this.psciCount = formatString(i18n.itemsFoundMsg, this.filterPsciList.length);
                this.updateAddedAssetIdList(this.filterPsciList);
                this.apiInProgress = false;

            })
            .catch(error => {
                this.handleError(parseErrorMessage(error));
            });
    }

    updatePicklistLabel (dataList) {
        const dataMap = {};
        dataList.forEach(row => {
            dataMap[row.Id] = row;

            if ( row.Status && row.Status in this.statusMap ) {
                row.StatusAPI = row.Status;
                row.Status = this.statusMap[row.Status];
            }

            if ( row.SVMXA360__DeliveryMethod__c
                && row.SVMXA360__DeliveryMethod__c in this.deliveryMethodMap ) {
                row.DeliveryMethodAPI = row.SVMXA360__DeliveryMethod__c;
                row.SVMXA360__DeliveryMethod__c =
                    this.deliveryMethodMap[row.SVMXA360__DeliveryMethod__c];
            }

            row.actions = row.StatusAPI === OUTPUT_GENERATED ?
                ROW_ACTIONS_DISABLED : ROW_ACTIONS;
        });
        return dataMap;
    }

    handleError (message) {
        this.error = message;
        this.apiInProgress = false;
    }

    handleBack () {
        this.openModal = true;
        this.showExitContent = true;
        this.modalTitle = i18n.backButton;
        this.classSize = '';
    }

    savePSCIRecords () {
        const psciListToUpsert = Object.values(this.dataToUpdate);

        Object.values(this.dataToInsert).forEach(dataObj => {
            delete dataObj.Id;
            delete dataObj.TempId;
            delete dataObj.Included;
            dataObj.ProductServiceCampaignId = this.pscId;
            psciListToUpsert.push(dataObj);
        });

        if ( !psciListToUpsert || psciListToUpsert.length === 0 ) {
            this.apiInProgress = false;
            return { success: true };
        }

        return insertUpdatePsciRecords({ requestJson: JSON.stringify(psciListToUpsert) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.handleError( parseErrorMessage(result.message) );
                    return null;
                }
                this.dataToUpdate = {};
                this.dataToInsert = {};
                return result;
            })
            .catch(error => {
                this.assetColumns = {};
                this.handleError( parseErrorMessage(error) );
            });
    }

    openDeliverRecordsConfirmation () {
        this.showDeliveryConfirmationContent = true;
        this.modalTitle = i18n.deliveryConfirmationTitle;
        this.openModal = true;
        this.itemsToGenerate = 0;
        Object.values(this.psciMap).forEach(row => {
            if ( row.Status === DRAFT
             && row.DeliveryMethodAPI !== NO_DELIVERY ) {
                this.itemsToGenerate++;
            }
        });
        this.isEmptyDeliverLines = this.itemsToGenerate === 0;
    }

    async handleSaveAndDeliver () {
        this.apiInProgress = true;

        const result = await this.savePSCIRecords();
        if ( !result || !result.success ) return;
        await this.fetchResultLine();
        this.openDeliverRecordsConfirmation();
        this.apiInProgress = false;
    }

    handleDeliveryMethodChange () {
        this.deliveryMethodToSet = null;
        this.isEmptyDeliveryMethod = true;
        this.openModal = true;
        this.showChangeDeliveryContent = true;
        this.modalTitle = i18n.changeDeliveryMethodTitle;
        this.classSize = 'MIN_HEIGHT';
    }

    handleChangeDeliverConfirm () {
        if (!this.deliveryMethodToSet) return;
        this.selectedRows.forEach(rowRecord => {
            const row = { ...rowRecord };
            if (row.StatusAPI === OUTPUT_GENERATED) return;

            row.DeliveryMethodAPI = this.deliveryMethodToSet;
            row[PSCI_DELIVERY_METHOD_FIELD] = this.deliveryMethodMap[this.deliveryMethodToSet];
            if (row.TempId === row.Id) {
                this.dataToInsert[row.Id].SVMXA360__DeliveryMethod__c = this.deliveryMethodToSet;
            } else {
                this.dataToUpdate[row.Id] =
                    { Id: row.Id, SVMXA360__DeliveryMethod__c: this.deliveryMethodToSet };
            }

            this.psciMap[row.Id] = row;
        });

        this.updatedSelectedRows = [];
        this.filterPsciList = Object.values(this.psciMap);
        this.openModal = false;
        this.showChangeDeliveryContent = false;
        this.hasNoneSelected = true;
    }

    async handleSaveExit () {
        this.apiInProgress = true;
        const result = await this.savePSCIRecords();
        if ( !result || !result.success ) return;

        this.apiInProgress = false;
        this.handleExit();
    }

    handleExit () {
        this.showExitContent = false;
        this.openModal = false;
        const navigationObj = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.pscId,
                objectApiName: PRODUCT_SERVICE_CAMPAIGN_OBJECT,
                actionName: 'view'
            }
        };

        if ( this.appNavigationType === CONSOLE ) {
            this[NavigationMixin.GenerateUrl](navigationObj)
                .then(generatedUrl => {
                    window.location.replace(generatedUrl);
                });
        } else {
            this[NavigationMixin.Navigate](navigationObj);
        }
    }

    handleFormInputChange (event) {
        this.deliveryMethodToSet = event.detail.value;
        this.isEmptyDeliveryMethod = isEmptyString(this.deliveryMethodToSet);
    }

    handleCancel () {
        this.showChangeDeliveryContent = false;
        this.showExitContent = false;
        this.showAddItem = false;
        this.showDeliveryConfirmationContent = false;
        this.openModal = false;
    }

    handleDeliver () {
        this.apiInProgress = true;
        this.showDeliveryConfirmationContent = false;
        this.openModal = false;

        initiateGenerateOutputBatch( { pscRecordId: this.pscId } )
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.handleError( parseErrorMessage(result.message) );
                    return;
                }
                this.handleExit();
            })
            .catch(error => {
                this.handleError(parseErrorMessage(error));
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    performSort () {
        let { filterPsciList } = this;

        if (!filterPsciList) return ;

        const sortField = (LookupReferenceNameMap[this.sortBy]) || this.sortBy;
        filterPsciList = filterPsciList.map( item => {
            if (item[FIELD_NAME_CONSTANT]) {
                item[ASSET_NAME_CONSTANT] = item[FIELD_NAME_CONSTANT];
            }
            return item;
        });
        this.filterPsciList = sortObjectArray(filterPsciList, sortField, this.sortDirection);
    }

    //Function to handle select event on table
    handleRowSelection (event) {
        if (event.detail.selectedRows.length > 0) {
            this.hasNoneSelected = false;
            this.selectedRows = event.detail.selectedRows;
        } else {
            this.hasNoneSelected = true;
        }
    }

    fetchAssetColumns () {
        getAddAssetColumns()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.handleError( parseErrorMessage(result.message) );
                    return;
                }

                result.data.forEach(columnDetail => {
                    this.assetColumns.push(this.getColumns(columnDetail));
                });
                this.assetColumns.push(this.getColumns(
                    { apiName: 'Included', dataType: 'text', label: 'Included' }));
            })
            .catch(error => {
                this.assetColumns = {};
                this.handleError( parseErrorMessage(error) );
            });
    }

    updateAddedAssetIdList  (psciList) {
        psciList.forEach(psci => {
            if (psci.AssetId && this.assetIdList.indexOf(psci.AssetId) === -1) {
                this.assetIdList.push(psci.AssetId);
            }
        });
        this.assetIdList = JSON.parse(JSON.stringify(this.assetIdList));
    }

    handleSearchTermChange (event) {
        const searchKey = event.target.value;
        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }
        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.latestSearchKey = searchKey;
                this.filterListViewData(searchKey);
            } catch (e) {
                this.handleError( parseErrorMessage(e) );
            }
        }, 300);
    }

    filterListViewData (searchValue) {
        const psciList = Object.values(this.psciMap);
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.sortBy = this.sortBy || ASSET_NAME_CONSTANT;
            this.sortDirection = this.sortDirection || 'asc';
            this.filterPsciList = psciList;
        } else {
            this.filterPsciList = psciList.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                let hasMatch = false;
                psciColumnListToFilter.forEach(column => {
                    if (hasMatch) return;
                    hasMatch = ( item[column]
                        && (item[column].toLowerCase().indexOf(loweredSearchValue) !== -1 ) ) ?
                        true : false;
                });
                return hasMatch;
            });
        }
        this.performSort();
        this.psciCount = formatString(i18n.itemsFoundMsg, this.filterPsciList.length);
    }

    handleAddItemsManually () {
        this.showAddItem = true;
    }

    handleConfirmAdd (dataAddRequest) {
        const dataToInsertRequest = JSON.parse(JSON.stringify(dataAddRequest.detail.dataToInsert));
        this.dataToInsert = { ...this.dataToInsert, ...dataToInsertRequest };

        let mapToDisplayRequest =
            JSON.parse(JSON.stringify(dataAddRequest.detail.mapToDisplay));

        const listToDisplayRequest = Object.values(mapToDisplayRequest);
        mapToDisplayRequest
            = this.updatePicklistLabel(listToDisplayRequest);
        this.psciMap = { ...this.psciMap, ...mapToDisplayRequest };
        this.filterListViewData(this.latestSearchKey);
        this.updateAddedAssetIdList(listToDisplayRequest);
        this.showAddItem = false;
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'changeDelivery':
                this.selectedRows = [row];
                this.handleDeliveryMethodChange();
                break;
            default:
                break;
        }
    }
}