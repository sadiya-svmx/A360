import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getSearchCriteriaStatus from
    '@salesforce/apex/PSC_SearchCriteria_LS.getSearchCriteriaStatus';
import getResultsPreview from
    '@salesforce/apex/PSC_SearchCriteria_LS.getResultsPreview';
import saveSearchCriteria from
    '@salesforce/apex/PSC_SearchCriteria_LS.saveSearchCriteria';
import initiateSearchResultBatch from
    '@salesforce/apex/PSC_SearchCriteria_LS.initiateSearchResultBatch';

import getResultLineStatus from '@salesforce/apex/PSC_ManageResults_LS.getResultLineStatus';

import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import STATUS_FIELD from '@salesforce/schema/ProductServiceCampaign.Status';
import NAME_FIELD from '@salesforce/schema/ProductServiceCampaign.ProductServiceCampaignName';
import PSC_DELIVERY_METHOD_FIELD from '@salesforce/schema/ProductServiceCampaign.DeliveryMethod__c';
import Product2Id from  '@salesforce/schema/ProductServiceCampaign.Product2Id';
import ASSET_EXPRESSION_SCHEMA
    from '@salesforce/schema/ProductServiceCampaign.AssetExpressionId__c';
import { getFieldDefinitionsForEntity } from 'c/metadataService';
import {
    OBJECT_ICONS,
    OPERATOR_OPTIONS_BY_TYPE,
    DATE_TIME_FUNCTION_LITERALS,
    parseErrorMessage,
    verifyApiResponse,
    FUNCTION_LITERALS,
} from 'c/utils';
import PRODUCT_OBJECT from '@salesforce/schema/Product2';
import ASSET_OBJECT from '@salesforce/schema/Asset';
import review from '@salesforce/label/c.Label_Review';
import edit from '@salesforce/label/c.Menu_Edit';
import openConfirmSearch from '@salesforce/label/c.Label_OpenConfirmSearch';
import search from '@salesforce/label/c.Label_ConfirmSearch';
import saveExpression from '@salesforce/label/c.Btn_Save';
import showPreview from '@salesforce/label/c.Label_ShowPreview';
import cancelExpression from '@salesforce/label/c.Btn_Cancel';
import editModalTitle from '@salesforce/label/c.Label_EditSearchExpressionModalTitle';
import editSearch from '@salesforce/label/c.Label_EditExpressionSearch';
import searchCardTitle from '@salesforce/label/c.Label_PSCSearchCardTitle';
import advanceExpTitle from '@salesforce/label/c.Label_Advanced_Expression';
import searchInProgress from '@salesforce/label/c.Label_SearchInProgress';
import searchForLabel from '@salesforce/label/c.Label_SearchFor';
import editSearchHoverMessage_B from '@salesforce/label/c.Message_EditSearchMessage_B';
import editSearchHoverMessage_A from '@salesforce/label/c.Message_EditSearchMessage_A';
import resultsPreview from '@salesforce/label/c.Label_ResultsPreview';
import estimatedItems from '@salesforce/label/c.Label_ReturnedItems';
import resultLineNotification from '@salesforce/label/c.Message_ResultLineNotification';
import confirmSearchTitle from '@salesforce/label/c.Label_ConfirmSearchTitle';
import location from '@salesforce/label/c.Label_Location';
import serialNumber from '@salesforce/label/c.Label_SerialNumber';
import itemLabel from '@salesforce/label/c.Label_Item';
import reloadLabel from '@salesforce/label/c.Label_Reload';
import searchCriteriaNotDefinedMessage_A
    from '@salesforce/label/c.Message_SearchCriteriaNotDefined_A';
import searchCriteriaNotDefinedMessage_B
    from '@salesforce/label/c.Message_SearchCriteriaNotDefined_B';
import labelToday from '@salesforce/label/c.Picklist_Today';
import labelTomorrow from '@salesforce/label/c.Picklist_Tomorrow';
import labelYesterday from '@salesforce/label/c.Picklist_Yesterday';
import labelNow from '@salesforce/label/c.Picklist_Now';
import maxSearchLineLimitReached
    from '@salesforce/label/c.Label_ExceedMaximumAllowedRecordsOnPreview';
import labelAnyProduct from '@salesforce/label/c.Label_AnyProduct';
import labelSpecificProduct from '@salesforce/label/c.Label_SpecificProduct';
import errorLiteralParameterSelection from
    '@salesforce/label/c.Error_LiteralParameterSelection';
const i18n = {
    runSearchButton: openConfirmSearch,
    confirmSearchButton: search,
    saveExpressionButton: saveExpression,
    showPreviewButton: showPreview,
    cancelExpressionButton: cancelExpression,
    editExpressionModalTitle: editModalTitle,
    editSearchButton: editSearch,
    cancelRunSearch: cancelExpression,
    searchCardTitle,
    advanceExpTitle,
    searchInProgress,
    searchForLabel,
    editSearchHoverMessage_B,
    editSearchHoverMessage_A,
    resultsPreview,
    estimatedItems,
    resultLineNotification,
    confirmSearchTitle,
    location,
    serialNumber,
    itemLabel,
    reloadLabel,
    review,
    edit,
    searchCriteriaNotDefinedMessage_A,
    searchCriteriaNotDefinedMessage_B,
    labelToday,
    labelTomorrow,
    labelYesterday,
    labelNow,
    maxSearchLineLimitReached,
    labelAnyProduct,
    labelSpecificProduct,
    literalParameterSelection: errorLiteralParameterSelection,
}

const PSC_CONSTANTS = {
    expressionType: "Standard Expression",
    objectAPIName: ASSET_OBJECT.objectApiName,
    expressionTypeName: "PSC-SEARCH-EXPRESSION",
};
const MAX_NAME_LENGTH = 40;
const LookupReferenceNameFields = "Name";
const ANY_PRODUCT = 'Any Product';
const SPECIFIC_PRODUCT = 'Specific Product';
const RESULT_LINES_GENERATED = "RESULT_LINES_GENERATED"
const NO_CRITERIA = "NO_CRITERIA";
const RUNNING_SEARCH = "RUNNING_SEARCH";
const RESULT_LINES_DELIVERED = 'RESULT_LINES_DELIVERED';

export default class PscSearchCriteria extends LightningElement {
    entityDefinition;
    //expressionData for the pop-up and expression lines on the card
    expressionData = null;
    modalOpen = false;
    confirmSearchModalOpen = false;
    resultsPreviewSelected = false;
    showSearchProgressBar = false;
    progressCounter = 0;
    anyProductRadioSelected = true;
    _advancedExpression = '';
    _pscName =''
    tableData = null;
    expressionID = null;
    pscRecordId = null;
    isServerCallInProgress = false;
    productIdForPsc = null;
    latestProductIdForPSC = null;
    productForPscLabel = null;
    latestProductLabel= null;
    isEditable = true;
    previewClicked = false;
    isBatchSearchInProgress = false;
    isCriteriaDefined = true;
    wiredServiceRecordData = null;
    error = null;
    /**lookup configuration */
    lookupObjectApiName = PRODUCT_OBJECT.objectApiName;
    referenceNameFields =  LookupReferenceNameFields;
    lookupIcon = OBJECT_ICONS.product2;
    advancedSearchConfig = null;
    operatorOptions = OPERATOR_OPTIONS_BY_TYPE;
    columns = [
        { label: i18n.itemLabel, fieldName: 'item', hideDefaultActions: true },
        { label: i18n.serialNumber, fieldName: 'serialNumber', hideDefaultActions: true },
        { label: i18n.location, fieldName: 'location', hideDefaultActions: true },
    ];
    previewItemsCount = 0;
    radioOptionValue = ANY_PRODUCT;
    currentRadioOptionValue = ANY_PRODUCT;
    isMaxSearchRecordLimitReached = false;
    maxAllowedSearchResults = 0;

    @track
    disableEdit = false;

    @track
    isResultLinesDelivered = false;

    @track
    isSearchDisabled = false;

    get i18n () {
        return i18n;
    }

    get options () {
        return [
            { label: i18n.labelAnyProduct, value: ANY_PRODUCT },
            { label: i18n.labelSpecificProduct, value: SPECIFIC_PRODUCT },
        ];
    }

    get disableSearch () {
        /**
        
         * disableEdit included for cases where
         * progress status is 
         * Canceled, Closed, Completed and Not Completed
         */
        if (this.disableEdit) return true;
        return this.isSearchDisabled;
    }

    get expressionDetailList () {
        if (!this.expressionData) return null;
        const { expressionDetailList } = this.expressionData;
        const expressionItems = expressionDetailList.map( (item, index)  => {
            const { fieldAPIName,operand,operator,literalParameterAPIName } = item;
            const { operatorOptions }  = this;
            const ObjEntries = Object.entries(DATE_TIME_FUNCTION_LITERALS);
            const operandLiteralEntries = ObjEntries.reduce((acc, arrayItem) => {
                acc[arrayItem[1]] = arrayItem[0];
                return acc;
            }, {});
            return ({
                index: (index + 1) ,
                fieldAPIName,
                operator: operatorOptions[operator].label,
                operand: operandLiteralEntries[operand] ||
                    (operand ? (operand + (literalParameterAPIName ?
                        '.' + literalParameterAPIName : '')) : '')
            });
        });
        return expressionItems;
    }

    get advanceExpression () {
        if (!this.expressionData) return null;
        return this._advancedExpression;
    }

    set advanceExpression (advExpression) {
        this._advancedExpression = advExpression;
    }

    get isLookupDisabled () {
        return (this.anyProductRadioSelected || !this.isEditable);
    }

    get isExpressionBlockedForEditing () {
        return !this.isEditable;
    }

    get reviewEditButtonLabel () {
        let label = '';
        if (this.isCriteriaDefined) {
            label = `${i18n.review}/${i18n.edit}`;
        } else {
            label = i18n.edit;
        }
        return label;
    }

    get pscName () {
        let value = this._pscName;
        if (value.length > MAX_NAME_LENGTH ) {
            value = value.substring(0, MAX_NAME_LENGTH);
        }
        return value;
    }

    get disableEditMatrix () {
        return ({
            "Canceled": true,
            "Closed": true,
            "Completed": true,
            "Cannot Complete": true
        });
    }

    get isEditDisabled () {
        return this.disableEdit || this.isResultLinesDelivered;
    }

    get developerName () {
        const  pscName = this.pscName;
        let devName = '';
        if (pscName) {
            const updatedName = pscName.replace(/\s/g, '_');
            const timeStamp = new Date().getTime().toString();
            const adjustChracterCount = (updatedName.length + timeStamp.length) - MAX_NAME_LENGTH;
            if (adjustChracterCount < 0) {
                devName = `${updatedName}${timeStamp}`;
            } else {
                devName =
                    updatedName.slice(0, (updatedName.length - adjustChracterCount)) + timeStamp;
            }
        }
        return devName;
    }

    set pscName (value) {
        if (value) {
            this._pscName = value;
        }
    }

    get warningMessageLabel () {
        return `${i18n.maxSearchLineLimitReached} ${this.maxAllowedSearchResults}`;
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        if ( currentPageReference && currentPageReference.attributes
          && currentPageReference.attributes.recordId) {
            this.pscRecordId = currentPageReference.attributes.recordId;
        }
    }

    @wire(getRecord, {
        recordId: '$pscRecordId',
        fields: [
            NAME_FIELD,
            PSC_DELIVERY_METHOD_FIELD,
            Product2Id,
            ASSET_EXPRESSION_SCHEMA,
            STATUS_FIELD
        ]})
    setRecordData (recordData) {
        const disableEditMatrix = this.disableEditMatrix;
        this.wiredServiceRecordData = recordData;
        this.pscName = (((recordData.data || {}).fields || {})
            .ProductServiceCampaignName ||{}).value;
        const productIdForPsc  = (((recordData.data || {}).fields || {})
            .Product2Id ||{}).value;
        const status = recordData?.data?.fields?.Status?.value;
        if (status && disableEditMatrix[status]) {
            this.disableEdit = true;
        } else {
            this.disableEdit = false;
        }
        if (productIdForPsc) {
            this.radioOptionValue = SPECIFIC_PRODUCT;
            this.currentRadioOptionValue = SPECIFIC_PRODUCT;
            this.anyProductRadioSelected = false;
        }
        this.latestProductIdForPSC = productIdForPsc;
        this.productIdForPsc = productIdForPsc;
    }


    handleRadioChange (event) {
        const radioOptionValue = event.detail.value;
        this.currentRadioOptionValue = radioOptionValue;
        if (radioOptionValue === SPECIFIC_PRODUCT) {
            this.anyProductRadioSelected = false;
            this.latestProductIdForPSC = this.productIdForPsc;
            this.latestProductLabel = this.productForPscLabel;
        } else {
            this.latestProductIdForPSC = null;
            this.anyProductRadioSelected = true;
        }
    }

    handleEditSearchCriteria () {
        this.isEditable = true;
    }

    onLookupChange (event) {
        const { detail: { value, label }} = event;
        this.latestProductIdForPSC = value || null;
        this.latestProductLabel = label
    }

    onModalCloseHandler () {
        this.modalOpen = false;
        this.previewItemsCount = 0;
        this.tableData = [];
        this.isMaxSearchRecordLimitReached = false;
        this.latestProductIdForPSC = this.productIdForPsc;
        if (this.radioOptionValue === SPECIFIC_PRODUCT) {
            this.anyProductRadioSelected = false;
        } else {
            this.anyProductRadioSelected = true;
        }

        this.shouldSearchBeDisabled(( { isDisabled })=>{
            this.isSearchDisabled = isDisabled;
        });
    }

    onModalOpenHandler () {
        this.modalOpen = true;
    }

    async handlePreviewClick () {
        this.resultsPreviewSelected = !this.resultsPreviewSelected;
        this.previewClicked = true;
        this.isServerCallInProgress = true;
        const success = await this.persistExpression();
        if (this.error) {
            this.isServerCallInProgress = false;
            return;
        }
        this.previewClicked = false;
        if (success) {
            const resultsPreviewData = await this.fetchResultsPreview();
            if (!resultsPreviewData) return;
            const { data: {
                resultsPreviewDetails = [],
                recordCount = 0,
                maxAllowedSearchResults = 0,
            } = {}
            } = resultsPreviewData;

            this.isMaxSearchRecordLimitReached =
                (recordCount > maxAllowedSearchResults) || recordCount === 0;
            this.previewItemsCount = recordCount;
            this.maxAllowedSearchResults = maxAllowedSearchResults;
            this.tableData = resultsPreviewDetails.map(listItem => ({
                'item': listItem.item,
                'serialNumber': listItem.serialNumber,
                'location': listItem.location || "--"
            }));
        }
        this.isServerCallInProgress = false;
    }

    onPopupSave () {
        this.persistExpression();
        this.isMaxSearchRecordLimitReached = false;
    }

    async persistExpression () {
        this.error = null;
        const expressionBuilder = this.template.querySelector('.svmx-expression-builder');
        const expressionData = expressionBuilder.expressionData.getRecordData();
        expressionData.expressionDetailList.forEach(entity => {
            if ( (entity.operand === FUNCTION_LITERALS.USER) && !entity.literalParameterAPIName) {
                this.error = i18n.literalParameterSelection;
            }
        });
        if (this.error) {
            return false;
        }
        const { previewClicked } = this;
        let success = false;
        if (expressionBuilder.reportValidity()) {
            return false;
        }
        this.modalOpen = false ||  this.previewClicked;

        if (!this.modalOpen) {
            this.previewItemsCount = 0;
            this.tableData = [];
        }
        this.productIdForPsc = this.latestProductIdForPSC;
        this.productForPscLabel = this.latestProductLabel;
        this.radioOptionValue = this.currentRadioOptionValue;
        if (this.expressionID) {
            success = await this.saveExistingExpression({ expressionData });
        } else {
            success = await this.saveNewRequest({ expressionData });
        }
        if (!previewClicked && !this.error) {
            this.shouldSearchBeDisabled(( { isDisabled })=>{
                this.isSearchDisabled = isDisabled;
            });
        }
        if (!this.error || success) refreshApex(this.wiredServiceRecordData);

        return success;

    }

    showSearchModal () {
        if (!this.isSearchDisabled) {
            this.confirmSearchModalOpen = true;
        } else {
            this.confirmSearchModalOpen = false;
        }
    }

    onSearchModalCloseHandler () {
        this.confirmSearchModalOpen = false;
    }

    async onRunSearch () {
        this.confirmSearchModalOpen = false;
        const resultsPreviewData = await this.fetchResultsPreview();
        if (!resultsPreviewData) return;
        const { data: { recordCount }} = resultsPreviewData;
        let isBatchSearchInitSucess = false;
        /** if zero record count */
        if (!recordCount) {
            return;
        }

        if (!this.isBatchSearchInProgress) {
            const initiateSearchResponse = await this.initiateSearchBatch();
            if (!initiateSearchResponse) return;
            isBatchSearchInitSucess = initiateSearchResponse.success;
        }
        const  runSearchCriteriaStatus = async () => {
            const criteriaStatusResponse = await this.fetchSearchCriteriaStatus();
            if (!criteriaStatusResponse) {
                this.showSearchProgressBar = false;
                return;
            }
            const { data } = criteriaStatusResponse;
            if (data.status === NO_CRITERIA) {
                this.showSearchProgressBar = false;
                return;
            }
            if (data.status === RESULT_LINES_GENERATED) {
                this.progressCounter = 100;
                this.isBatchSearchInProgress = false;
                refreshApex(this.wiredServiceRecordData);

                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.showSearchProgressBar = false;
                    this.progressCounter = 0;
                    this.shouldSearchBeDisabled(( { isDisabled })=>{
                        this.isSearchDisabled = isDisabled;
                    });
                },800);

                /**
                  * below eval is used to refresh the standard components
                  */
                // eslint-disable-next-line  no-new-func
                (new Function("$A.get('e.force:refreshView').fire();"))();
            } else if (data.status === RUNNING_SEARCH ) {
                const { createdRecordCount, expectedRecordCount } = data
                this.progressCounter = Math.floor(createdRecordCount/expectedRecordCount * 100);
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(runSearchCriteriaStatus, 500)
            }
        }
        if (isBatchSearchInitSucess || this.isBatchSearchInProgress) {
            this.showSearchProgressBar = true;
            runSearchCriteriaStatus();
        }
    }

    async saveExistingExpression ({ expressionData }) {
        const {
            name,
            lastModifiedDate,
            lastModifiedBy,
            id,
            developerName,
        } = expressionData;
        const requestObject = {
            'Id': this.pscRecordId,
            'productIdForPsc': this.productIdForPsc,
            'expression': {
                'type': PSC_CONSTANTS.expressionType,
                'objectAPIName': PSC_CONSTANTS.objectAPIName,
                'name': name,
                'lastModifiedDate': lastModifiedDate,
                'lastModifiedBy': lastModifiedBy,
                'id': id,
                'expressionType': PSC_CONSTANTS.expressionTypeName,
                'expressionDetailList': [],
                'developerName': developerName,
                'description': name,
                'advancedExpression': null
            }
        };
        requestObject.expression.expressionDetailList = expressionData.expressionDetailList;
        requestObject.expression.advancedExpression = expressionData.advancedExpression;
        const savedDataResponse = await this.persistSearchCriteria(requestObject);
        if (!savedDataResponse) return false;
        this.isCriteriaDefined = true;
        const {
            data: { expression } = {},
            success = false
        } = savedDataResponse;

        if (success) {
            this.expressionData = expression;
            this.advanceExpression = expression.advancedExpression;
        }

        return  success;

    }

    async saveNewRequest ({
        expressionData
    }) {

        const pscName = this.pscName;
        const requestObject = {
            'Id': this.pscRecordId,
            'productIdForPsc': this.productIdForPsc,
            'expression': {
                'type': PSC_CONSTANTS.expressionType,
                'objectAPIName': PSC_CONSTANTS.objectAPIName,
                'name': pscName,
                'lastModifiedDate': null,
                'lastModifiedBy': null,
                'id': null,
                'expressionType': PSC_CONSTANTS.expressionTypeName,
                'expressionDetailList': [],
                'developerName': this.developerName,
                'description': pscName,
                'advancedExpression': null
            }
        };
        requestObject.expression.expressionDetailList = expressionData.expressionDetailList;
        requestObject.expression.advancedExpression = expressionData.advancedExpression;
        expressionData.expressionDetailList.forEach(listItem => {
            listItem.id = null;
            listItem.name = null;
        });
        const savedDataResponse = await this.persistSearchCriteria(requestObject);
        if (!savedDataResponse) return false;
        this.isCriteriaDefined = true;
        const {
            data: { expression, productIdForPsc } = {},
            success = false
        } = savedDataResponse;
        if ( success ) {
            this.expressionData = expression;
            this.advanceExpression = expression.advancedExpression;
            this.expressionID = expression.id;
            this.productIdForPsc = productIdForPsc;
            this.latestProductIdForPSC = productIdForPsc;
            if (productIdForPsc) {
                this.radioOptionValue = SPECIFIC_PRODUCT;
                this.currentRadioOptionValue = SPECIFIC_PRODUCT;
                this.anyProductRadioSelected = false;
            }
        }
        return  success;
    }

    async connectedCallback () {
        const searchCriteriaResponse = await this.fetchSearchCriteriaStatus();
        if (searchCriteriaResponse) {
            const { data } = searchCriteriaResponse;
            const { expression, status } = data;
            const entityDefinitionPromise = getFieldDefinitionsForEntity('asset');
            entityDefinitionPromise.then(entdef => {
                this.entityDefinition = entdef.data;
            });
            if (expression) {
                this.expressionData = expression;
                this.advanceExpression = expression.advancedExpression;
                this.expressionID = expression.id;
            } else {
                this.expressionData = { expressionDetailList: []};
            }
            if ( status === RUNNING_SEARCH ) {
                this.isBatchSearchInProgress = true;
                this.onRunSearch();
            } else if (status === NO_CRITERIA) {
                this.isCriteriaDefined = false;
            } else if (status === RESULT_LINES_DELIVERED) {
                this.isResultLinesDelivered = true;
            }
            if ( status !== NO_CRITERIA) {
                this.shouldSearchBeDisabled(({ isDisabled })=>{
                    this.isSearchDisabled = isDisabled || this.isResultLinesDelivered ;
                });
            }
        }
        const shouldDisableReviewEdit = await this.checkIfBatchIsRunning();
        this.isResultLinesDelivered = this.isResultLinesDelivered || shouldDisableReviewEdit;
    }


    async shouldSearchBeDisabled (callbackFm) {
        const searchCriteriaResponse = await this.fetchSearchCriteriaStatus();
        if (searchCriteriaResponse) {
            const { data: { status }} = searchCriteriaResponse;
            if (status !== NO_CRITERIA) {
                const resultsPreviewData = await this.fetchResultsPreview();
                this.isEditable = true;
                if (resultsPreviewData && resultsPreviewData.success) {
                    const { data: { recordCount = 0 }} = resultsPreviewData;
                    if ( recordCount === 0 || status === RESULT_LINES_GENERATED) {
                        callbackFm({ isDisabled: true });
                        this.isEditable = recordCount === 0 ? true : false;
                    } else {
                        callbackFm({ isDisabled: false });
                    }
                } else {
                    callbackFm({ isDisabled: true });
                }
            }
        }
    }

    async fetchSearchCriteriaStatus () {
        let result = null;
        try {
            const response = await getSearchCriteriaStatus({ pscRecordId: this.pscRecordId });
            this.error = null;
            if (!verifyApiResponse(response)) {
                throw new Error(response.message);
            }
            result = response;
        } catch (error) {
            this.error = parseErrorMessage(error);
        }
        return result;
    }

    async fetchResultsPreview () {
        let result = null;
        try {
            const resultsPreviewData = await getResultsPreview({ pscRecordId: this.pscRecordId });
            this.error = null;
            if (!verifyApiResponse(resultsPreviewData)) {
                throw new Error(resultsPreviewData.message);
            }
            result = resultsPreviewData;
        } catch (error) {
            this.error = parseErrorMessage(error);
        }
        return result;
    }

    async persistSearchCriteria (requestObject) {
        let result = null;
        try {
            const response =
                await saveSearchCriteria({ requestJson: JSON.stringify(requestObject) });
            this.error = null;
            if (!verifyApiResponse(response)) {
                throw new Error(response.message);
            }
            result = response;
        } catch (error) {
            this.error = parseErrorMessage(error);
        }
        return result;
    }

    async initiateSearchBatch () {
        let result = null;
        try {
            const response =
                await initiateSearchResultBatch({ pscRecordId: this.pscRecordId });
            this.error = null;
            if (!verifyApiResponse(response)) {
                throw new Error(response.message);
            }
            result = response;
        } catch (error) {
            this.error = parseErrorMessage(error);
        }
        return result;
    }

    async checkIfBatchIsRunning () {
        let result = false;
        try {
            const response =
                await getResultLineStatus({ pscRecordId: this.pscRecordId });
            this.error = null;
            if (!verifyApiResponse(response)) {
                throw new Error(response.message);
            }
            const { data: { linesDelivered = 0, isBatchRunning = false } = {}} = response;
            result = linesDelivered > 0 || isBatchRunning;
        } catch (error) {
            this.error = parseErrorMessage(error);
        }
        return result;
    }
}