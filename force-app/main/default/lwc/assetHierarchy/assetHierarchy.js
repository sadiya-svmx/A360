import { LightningElement, api, track, wire } from "lwc";
import { getRecord, deleteRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfos } from "lightning/uiObjectInfoApi";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
    publish,
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from "lightning/messageService";
import { loadStyle } from 'lightning/platformResourceLoader';
import svmxAssetHierarchyCss from '@salesforce/resourceUrl/svmxAssetHierarchyCss';
import recordSelected from "@salesforce/messageChannel/RecordSelection__c";
import TIMEZONE from "@salesforce/i18n/timeZone";

import getObjectAPIName from "@salesforce/apex/COMM_DatabaseUtils.getObjectAPIFromRecordId";
import { getFieldDefinitionsForEntities } from "c/metadataService";
import getAppNavigationType
    from '@salesforce/apex/COMM_DatabaseUtils.fetchApplicationNavigationType';

import getHierarchyConfiguration
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.getHierarchyConfiguration";
import getRootId from "@salesforce/apex/AMGT_AssetHierarchy_LS.getRootId";
import getAssetNodesForHierarchyRaw
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.getAssetNodesForHierarchyRaw";
import getFirstSetOfAccounts
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.fetchFirstFiveLevelAccountsRaw";
import getLastSetOfAccounts
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.fetchfinalFiveLevelAccountsRaw";
import { refreshApex } from '@salesforce/apex';
import getHierarchyNodesNotification
    from "@salesforce/apex/AMGT_AssetHierarchy_LS.getHierarchyNodesNotification";
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import { getFieldDefinitionsForEntity } from 'c/metadataService';
import LightningAlert from 'lightning/alert';
import getHierarchyNodesRaw from "@salesforce/apex/AMGT_AssetHierarchy_LS.getHierarchyNodesRaw";

import {
    ASSET_HIERARCHY_ORDER,
    FIELD_DATA_TYPES,
    classSet,
    deepCopy,
    parseErrorMessage,
    isNotUndefinedOrNull,
    raf,
    asyncGetItemFromCache,
    asyncSetItemIntoCache,
    flattenById,
    arrayToTree,
    isEmptyString,
    ASSET_HIERARCHY_LOCALSTORAGE,
    isUndefinedOrNull,
    requestAnimationFrameAsPromise,
    asyncRemoveItemFromCache,
    formatString,
} from 'c/utils';
import {
    i18n,
    assignNotificationRecord,
    populateResult,
    populateResultRaw,
    loadData,
    OBJECTAPIMAP
} from "./assetHierarchyHelper";

import { createRecord } from 'lightning/uiRecordApi';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import LOCATION_OBJECT from '@salesforce/schema/Location';
import ASSET_OBJECT from '@salesforce/schema/Asset';
import { AssetHierarchySearchHandler } from "./assetHierarchySearchHandler";
import { AssetHierarchyFilterHandler } from "./assetHierarchyFilterHandler";


const defaultRecordActions = [
    { label: i18n.edit, name: "edit" },
    { label: i18n.clone, name: "clone" },
    { label: i18n.delete, name: "delete" },
];

const launchSPMWizardAction = { label: i18n.launchSPMWizards, name: "launch" };

const manageChildAssetsAction =  { label: i18n.childAssets, name: "childassets" };

const objectToLabelName = {
    account: i18n.accountName,
    asset: i18n.assetName,
    location: i18n.locationName,
};

const SEARCHABLE_FIELDS = ["STRING", "PICKLIST", "REFERENCE"];

const CHILDASSETS = "ChildAssets";

export default class AssetHierarchy extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api flexipageRegionWidth;
    @api label;
    @api order;
    @api hierarchyField;
    @api displayIcon;
    @api maxHeight;
    @api isInCommunity;
    @api plotHierarchyField;

    @track data = [];
    @track viewData;
    @track defaultHierarchyConfig = {
        data: undefined,
        error: undefined
    };
    @track hierarchyConfig = {
        data: undefined,
        error: undefined
    };
    @track selectedFields = {
        location: [],
        asset: [],
        account: []
    }
    @track rowAction = {};
    @track defaultExpandedRows = [];
    @track highlightedRows = [];
    @track selectedRows = [];
    @track allKeys = new Set();
    @track availableLocationFields = [];
    @track availableAssetFields = [];
    @track availableAccountFields = [];
    @track allLocationFields = [];
    @track allAssetFields = [];
    @track allAccountFields = [];
    @track splitMode = false;
    @track _splitViewExpanded = true;
    @track wizardModalDialogOpen = false;
    @track accountFieldsDialogOpen = false;
    @track locationFieldsDialogOpen = false;
    @track assetFieldsDialogOpen = false;
    @track deleteModalDialogOpen = false;
    @track accountBasedHierarchy = false;
    @track locationBasedHierarchy = false;
    @track showIllustration = false;
    @track expandAll = false;
    @track refreshing = false;
    @track primaryRecordId;
    @track pageRecord = {
        data: undefined,
        error: undefined
    }
    @track rowToBeDeleted;
    @track showExpandAll = true;
    @track showEditRecordModal;
    @track editRecordId;
    @track editRecordObjectApiName;
    @track editActionTitle;
    @track childAssetRecordId;
    @track searchResults = [];
    blurTimeout;
    isSearchResultHasInvalidNode = false;

    selectedListId;
    @track locationSearchableFields = [];
    @track locationReferencedFields = [];
    @track assetSearchableFields = [];
    @track assetReferencedFields = [];
    @track accountSearchableFields = [];
    @track accountReferencedFields = [];
    error;
    objectInfoByApiName = new Map();
    flattenedData;
    @track cachedLocationColsWidth = [];
    @track cachedAssetColsWidth = [];
    @track cachedAccountColsWidth = [];
    @track isInConsole = false;
    searchHandler = new AssetHierarchySearchHandler(this);
    searchFilter = new AssetHierarchyFilterHandler(this);
    _targetRecord = {
        id: undefined,
        objectApiName: undefined
    }
    illustrationImageName;
    illustrationHeading;
    illustrationMessage;
    rootId;
    scrollEventListener = false;
    handleAutoEnableScrollBarEvent = false;
    fieldSelectError;
    @track showCloneRecordModal = false;
    @track rootIdResult;
    @track originalPrimaryRecordId;
    serverSearchInitiatedTimeStamp;
    @track isSeverSideSearch = false;

    @wire(MessageContext)
    messageContext;
    cloneError;
    notificationByAssetId = new Map();
    filterSelected = false;
    filterValuesChanged = false;
    selectorModalOpen = false;
    assetObjectApiName = ASSET_OBJECT.objectApiName;
    editMode = false;
    editModeType = 'read';
    assetEntityDefinition;
    assetCriteriaExpression;
    accountEntityDefinition;
    accountCriteriaExpression;
    locationEntityDefinition;
    locationCriteriaExpression;
    showAddFilterModal= false;
    newObjectTypeExpression = {};
    newFilterEntityDefinition;

    @track assetClientFilter = [];
    @track locationClientFilter = [];
    @track accountClientFilter = [];

    assetAdminfilterEnabled = true;
    accountAdminfilterEnabled = true;
    locationAdminfilterEnabled = true;

    filterValidationError;
    isCloning = false;
    showChildAssetModal = false;
    showchilds = false;

    get accountLabel () {
        return  this.accountEntityDefinition?.label;
    }

    get assetLabel () {
        return  this.assetEntityDefinition?.label;
    }

    get locationLabel () {
        return  this.locationEntityDefinition?.label;
    }

    get filterModalTitleVal () {
        return formatString(
            i18n.filterModalTitle,
            this.newFilterEntityDefinition?.label
        );
    }

    get assetColumnsCacheName () {
        // eslint-disable-next-line max-len
        return `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${ASSET_OBJECT.objectApiName.toLowerCase()}${this.label}`;
    }

    get disableAssetAddFilter () {
        return this.assetClientFilter?.length > 1;
    }


    get disableLocationAddFilter () {
        return this.locationClientFilter?.length > 1;
    }


    get disableAccountAddFilter () {
        return this.accountClientFilter?.length > 1;
    }

    get disableAssetRemoveFilter () {
        return this.assetClientFilter?.length === 0;
    }

    get disableAccountRemoveFilter () {
        return this.accountClientFilter?.length === 0;
    }

    get disableLocationRemoveFilter () {
        return this.locationClientFilter?.length === 0;
    }

    get showAccountFilter () {
        return this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET;
    }

    get showLocationFilter () {
        return this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET;
    }

    get isDataAvailable () {
        return this.viewData && this.viewData.length > 0;
    }


    get actionModalTitle () {
        return i18n.serviceProcessFor + ` ${this.rowAction.name}`;
    }

    get qualifiedHierarchyField () {
        return `${this.objectApiName}.${this.hierarchyField}`;
    }

    get columns () {
        let columns = [];
        if (isNotUndefinedOrNull(this.hierarchyConfig.data)) {
            const rootObjectApiName = this.data?.[0]?.objectApiName?.toLowerCase();
            if (this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET &&
                    rootObjectApiName !== ASSET_OBJECT.objectApiName?.toLowerCase()) {
                columns = this.getObjectColumns(LOCATION_OBJECT.objectApiName);
            } else if (this.order === ASSET_HIERARCHY_ORDER.ASSET_ONLY ||
                    rootObjectApiName === ASSET_OBJECT.objectApiName?.toLowerCase()) {
                columns = this.getObjectColumns(ASSET_OBJECT.objectApiName);
            } else if (this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET &&
                    rootObjectApiName !== ASSET_OBJECT.objectApiName?.toLowerCase()) {
                columns = this.getObjectColumns(ACCOUNT_OBJECT.objectApiName);
            }
        }
        return columns;
    }

    get computedAriaExpanded () {
        return (this._splitViewExpanded) ? 'true' : 'false';
    }

    get computedSplitterClass () {
        return classSet('slds-split-view_container')
            .add('slds-col')
            .add({
                'slds-size_2-of-6 slds-is-open': this._splitViewExpanded,
                'slds-size_0-of-6 slds-is-closed': !this._splitViewExpanded,
            }).toString();
    }

    get computedSplitterButtonClass () {
        return classSet('splitter-button')
            .add('slds-split-view__toggle-button')
            .add({
                'slds-is-open': this._splitViewExpanded,
                'slds-is-closed': !this._splitViewExpanded,
            }).toString();
    }

    get computedSwitchIcon () {
        return this.splitMode ? 'utility:list' : 'utility:side_list';
    }

    get detailGridConfig () {
        const expandedRows = this.defaultExpandedRows;
        const highlightedRows = this.highlightedRows;
        const selectedRows = this.selectedRows;
        let detailGridConfig;
        if ((this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET
            || ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET)
            && isNotUndefinedOrNull(this.hierarchyConfig.data)) {
            detailGridConfig = {
                keyField: "id",
                columns: this.getObjectColumns(ASSET_OBJECT.objectApiName),
                hideTableHeader: this.hideTableHeader,
                hideCheckboxColumn: true,
                tableClass: !this.hideTableHeader
                    ? 'slds-table_bordered'
                    : '',
                expandedRows: expandedRows,
                highlightedRows: highlightedRows,
                selectedRows: selectedRows,
                onheaderaction: (event) => this.handleHeaderAction(event),
                onrowaction: (event) => this.handleRowAction(event)
            }
        }
        return detailGridConfig;
    }

    get expandCollapseIcon () {
        return this.expandAll ? 'utility:collapse_all' : 'utility:expand';
    }

    get expandCollapseAltText () {
        return this.expandAll ? i18n.collapseAll : i18n.expandAll;
    }

    get hideTableHeader () {
        return this.splitMode || this.flexipageRegionWidth === 'SMALL';
    }

    get hierarchyConfigData () {
        return this.hierarchyConfig?.data ? JSON.stringify(this.hierarchyConfig.data) : null;
    }

    get i18n () {
        return i18n;
    }

    get isLoading () {
        return !this.data && !this.error || this.refreshing;
    }

    get maxHeightStyle () {
        return this.maxHeight ? `max-height: ${this.maxHeight}px` : '';
    }

    get primaryObjectApiName () {
        if (this.hierarchyField === 'Id') {
            return this.pageRecord?.data?.apiName;
        }
        let refField = this.hierarchyField?.replace(/Id/g, '');
        refField = refField?.replace(/__c/g, '__r');
        return this.pageRecord?.data?.fields?.[refField]?.value?.apiName;
    }

    get regionsIsNotSmall () {
        return this.flexipageRegionWidth !== 'SMALL' ;
    }

    get splitterButtonAltText () {
        return (this._splitViewExpanded) ? i18n.closeSplitView : i18n.openSplitView;
    }

    get targetIsAccount () {
        return this.targetRecord?.objectApiName === ACCOUNT_OBJECT.objectApiName;
    }

    get targetIsLocation () {
        return this.targetRecord?.objectApiName === LOCATION_OBJECT.objectApiName;
    }

    get targetIsAsset () {
        return this.targetRecord?.objectApiName === ASSET_OBJECT.objectApiName;
    }

    get targetRecord () {
        if (this._targetRecord?.id && this._targetRecord?.objectApiName) {
            return this._targetRecord;
        }
        return {
            id: this.primaryRecordId,
            objectApiName: this.primaryObjectApiName
        }
    }

    set targetRecord (value) {
        this._targetRecord = value;
    }

    renderedCallback () {
        if (!this.init && !window.svmxahtyleLoaded) {
            this.loadStylePromise = Promise.all([
                loadStyle(this, svmxAssetHierarchyCss)
            ]).then(() => {
                this.init = true;
                window.svmxahtyleLoaded = true;
            })
                .catch(error => {
                    this.init = true;
                    console.error('static resource loadStylePromise error', error);
                });
        }
    }

    @wire(getObjectInfos, { objectApiNames: [ ACCOUNT_OBJECT, LOCATION_OBJECT, ASSET_OBJECT ]})
    objectInfosWire ({ error, data }) {
        if (data) {
            data.results.forEach(item => {
                this.objectInfoByApiName.set(item.result.apiName, item.result);
            });
            this.getLocalStorageCacheForColsWidth();
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        layoutTypes: ['Full'],
        modes: 'View',
        optionalFields: '$qualifiedHierarchyField'
    })
    pageRecordWire ({ error, data }) {
        this.locationSearchableFields = [];
        this.assetSearchableFields = [];
        this.accountSearchableFields = [];
        this.getFieldsDescribeResults();
        if (data) {
            if (isNotUndefinedOrNull(this.order)
                && isUndefinedOrNull(this.plotHierarchyField)) {
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this.plotHierarchyField = false;
            }
            if (this.hierarchyField === 'Id') {
                if (this.primaryRecordId === this.recordId) {
                    this.primaryRecordId = null;
                    raf(() => {
                        this.primaryRecordId = this.recordId;
                    }).call(this);
                } else {
                    this.primaryRecordId = this.recordId;
                }
                this.originalPrimaryRecordId = this.recordId;
                this.pageRecord.data = data;
                this.pageRecord.error = error;
                this.updateIllustration(false);
                return;
            }
            if (!getFieldValue(data, this.qualifiedHierarchyField)) {
                if ((this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET ||
                    this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET)
                    && this.plotHierarchyField &&
                    this.targetRecord.objectApiName ===  ASSET_OBJECT.objectApiName) {
                    this.error = i18n.incorrectPlotHierarchyField;
                } else {
                    this.viewData = [];
                    this.data = [];
                    this.showNoDataIllustration();
                }
            } else {
                this.updateIllustration(false);
            }
            const fieldVal = getFieldValue(data, this.qualifiedHierarchyField);
            if (this.primaryRecordId === fieldVal) {
                this.primaryRecordId = null;
                raf(() => {
                    this.primaryRecordId = fieldVal;
                }).call(this);
            } else {
                this.primaryRecordId = fieldVal;
            }
            this.originalPrimaryRecordId = this.primaryRecordId;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
        this.pageRecord.data = data;
        this.pageRecord.error = error;
    }

    @wire(getHierarchyConfiguration)
    async hierarchyConfigWire (value) {
        const { error, data }  = value;
        if (data) {
            if (isNotUndefinedOrNull(this.order)
                && isUndefinedOrNull(this.plotHierarchyField)) {
                // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                this.plotHierarchyField = false;
            }
            if (!this.isInCommunity) {
                getAppNavigationType()
                    .then(result => {
                        if (result && result.data) {
                            if (result.data === 'Console') {
                                this.isInConsole = true;
                            }
                        }
                    });
            }
            this.defaultHierarchyConfig.data = data;
            this.defaultHierarchyConfig.error = undefined;
            let updatedConfig = { data: JSON.parse(JSON.stringify(data)) };
            this.editMode = false;
            this.editModeType = 'read';
            this.assetEntityDefinition = await this.getObjectFields(
                ASSET_OBJECT.objectApiName.toLowerCase());
            this.accountEntityDefinition = await this.getObjectFields(
                ACCOUNT_OBJECT.objectApiName.toLowerCase());
            this.locationEntityDefinition = await this.getObjectFields(
                LOCATION_OBJECT.objectApiName.toLowerCase());

            const expressionResult = await getExpressionWithDetails(
                { expressionId: updatedConfig?.data?.asset?.qualifyingCriteria });

            this.assetCriteriaExpression = expressionResult.data;
            if (this.showAccountFilter) {
                const expressionResult1 = await getExpressionWithDetails(
                    { expressionId: updatedConfig?.data?.account?.qualifyingCriteria });
                this.accountCriteriaExpression = expressionResult1.data;
            }

            if (this.showLocationFilter) {
                const expressionResult2 = await getExpressionWithDetails(
                    { expressionId: updatedConfig?.data?.location?.qualifyingCriteria });
                this.locationCriteriaExpression = expressionResult2.data;
            }
            const getAccountFields =
            await asyncGetItemFromCache(
                `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}`+
                `${this.objectApiName}${ACCOUNT_OBJECT.objectApiName.toLowerCase()}${this.label}`);
            if (getAccountFields && getAccountFields.length >= 0) {
                updatedConfig =
                 this.userSelectedColumns (
                     updatedConfig,
                     ACCOUNT_OBJECT.objectApiName.toLowerCase(),
                     getAccountFields);
            }
            const getAssetFields =
            await asyncGetItemFromCache(
                `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}`+
                `${this.objectApiName}${ASSET_OBJECT.objectApiName.toLowerCase()}${this.label}`);
            if (getAssetFields && getAssetFields.length >= 0) {
                updatedConfig =
                 this.userSelectedColumns (
                     updatedConfig,
                     ASSET_OBJECT.objectApiName.toLowerCase(),
                     getAssetFields);
            }
            const getLocationFields =
            await asyncGetItemFromCache(
                `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}`+
                `${this.objectApiName}${LOCATION_OBJECT.objectApiName.toLowerCase()}${this.label}`);
            if (getLocationFields && getLocationFields.length >= 0) {
                updatedConfig =
                 this.userSelectedColumns (
                     updatedConfig,
                     LOCATION_OBJECT.objectApiName.toLowerCase(),
                     getLocationFields);
            }
            this.selectedFields.location = updatedConfig.data?.location?.fields.map(field =>
            {
                return field.fieldApiName
            });
            this.selectedFields.asset = updatedConfig.data?.asset?.fields.map(field => {
                return field.fieldApiName
            });
            this.selectedFields.account = updatedConfig.data?.account?.fields.map(field => {
                return field.fieldApiName
            });
            await this.getLocalStorageCacheFilters();
            const assetFilter = this.assetClientFilter
                ? [...this.assetClientFilter.filter( item => item.active)]
                : [];
            if (this.assetCriteriaExpression && this.assetAdminfilterEnabled) {
                assetFilter.push(this.assetCriteriaExpression);
            }
            updatedConfig.data.asset.expressions = assetFilter;
            if (this.showLocationFilter) {
                const locationFilter = this.locationClientFilter
                    ? [...this.locationClientFilter.filter( item => item.active)]
                    : [];
                if (this.locationCriteriaExpression && this.locationAdminfilterEnabled) {
                    locationFilter.push(this.locationCriteriaExpression);
                }
                updatedConfig.data.location.expressions = locationFilter;
            }
            if (this.showAccountFilter) {
                const accountFilter = this.accountClientFilter
                    ? [...this.accountClientFilter.filter( item => item.active)]
                    : [];
                if (this.accountCriteriaExpression && this.accountAdminfilterEnabled) {
                    accountFilter.push(this.accountCriteriaExpression);
                }
                updatedConfig.data.account.expressions = accountFilter;
            }
            this.hierarchyConfig.data = updatedConfig.data;
            this.hierarchyConfig.error = undefined;
        } else if (error) {
            this.defaultHierarchyConfig.error = error;
            this.defaultHierarchyConfig.data = undefined;
            this.hierarchyConfig.error = error;
            this.error = parseErrorMessage(error);
            this.hierarchyConfig.data = undefined;
        }
    }

    userSelectedColumns (data,objectApiName,selectedFields) {
        const mutableConfig = deepCopy(data);
        mutableConfig.data[objectApiName].fields = selectedFields.map(
            (field, index) => {
                return {
                    fieldApiName: field,
                    sequence: index+1
                }
            });
        return mutableConfig;
    }

    @wire(getRootId, {
        primaryRecordId: '$primaryRecordId',
        order: '$order',
        config: '$hierarchyConfigData',
        record: '$pageRecord',
        plotHierarchyField: '$plotHierarchyField'
    })
    rootLocationWire (value) {
        this.rootIdResult = value;
        const { error, data } = value;
        if (data) {
            this.rootId = data;
            if (this.hierarchyConfig?.data) {
                this.refreshing = true;
                const rootIdVal = this.rootId;
                this.getHierarchy([rootIdVal]).then(result => {
                    this.flattenedData = flattenById(result);
                    if (result.length > 0) {
                        this.updateIllustration(false);
                        this.data = result;
                        const path = this.searchTreeByProperty(this.primaryRecordId,false, '.id');
                        this.moveToTop(path);
                        this.viewData = result;
                        this.expandToPrimary(path, this.plotHierarchyField || this.showchilds);
                        this.showchilds = false;
                        this.highlightedRows = [this.primaryRecordId];
                        this.refreshing = false;
                        if (this.order === ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                            this.getAssetNotification([rootIdVal]);
                        } else if (this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET
                                || this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET ) {
                            this.getAssetNotification([this.primaryRecordId]);
                        }
                    } else {
                        this.showNoDataIllustration();
                        this.refreshing = false;
                    }
                }).finally(() => {});
            }
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }


    async getAssetNotification (recordIds) {

        const results = await getHierarchyNodesNotification({
            recordIds: recordIds,
            order: this.order,
            config: this.hierarchyConfigData,
        })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        if (results) {
            results.forEach(item => {
                this.notificationByAssetId.set(item.assetId, item.assetNotifications);
            });
            if (this.notificationByAssetId.size !== 0) {
                this.data = assignNotificationRecord(this.data,this.notificationByAssetId);
                this.viewData = JSON.parse(JSON.stringify(this.data));
            }
        }
        return results;
    }


    connectedCallback () {
        if (!this.order) {
            this.showNoDataIllustration();
        } else {
            if ( this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET ) {
                this.accountBasedHierarchy = true;
                this.showExpandAll = false;
            } else if ( this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET ) {
                this.locationBasedHierarchy = true;
                this.showExpandAll = false;
            }
        }
        this.getHierarchyView();
        this.subscribeToMessageChannel();
        const that = this;
        window.addEventListener('scroll', function hideResultListItems () {
            const searchList = that.template.querySelector(`[data-searchbox="searchbox"]`);
            const searchinputBox = that.template.querySelector(`[data-inputbox="search"]`);
            if (searchList) {
                searchList.classList.remove("slds-is-open");
                if (searchinputBox) {
                    searchinputBox.blur();
                }
            }
        });
    }

    async getHierarchyView () {
        const hierarchyMode =
            await asyncGetItemFromCache(`${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}`+
            `${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}`+
            `${this.objectApiName}${ASSET_HIERARCHY_LOCALSTORAGE.APP_MODE}${this.label}`);
        if (hierarchyMode && this.flexipageRegionWidth !== 'SMALL') {
            this.splitMode = hierarchyMode;
        }
    }

    disconnectedCallback () {
        this.unsubscribeToMessageChannel();
    }

    getObjectColumns (objectApiName) {
        const apiName = objectApiName.toLowerCase();
        const iconCellAttributes = {};
        if (this.displayIcon) {
            if ( this.hierarchyConfig?.data?.[apiName]?.displayIconName
                && !this.hierarchyConfig.data[apiName].displayIconName.includes(":")) {
                iconCellAttributes.iconName = {
                    fieldName: this.hierarchyConfig.data[apiName].displayIconName
                };
            } else {
                iconCellAttributes.iconName = this.hierarchyConfig?.data?.[apiName]
                    ?.displayIconName;
            }
        }
        let rowActions = [];
        if (this.hierarchyConfig?.data?.[apiName]?.defaultRecordActions) {
            rowActions = rowActions.concat(defaultRecordActions);
        }
        if ( apiName === ASSET_OBJECT.objectApiName?.toLowerCase() &&
            this.hierarchyConfig?.data?.[apiName]?.allowManagingChildAssets) {
            rowActions.push(manageChildAssetsAction);
        }
        if (this.hierarchyConfig?.data?.[apiName]?.enableSPMWizards) {
            rowActions.push(launchSPMWizardAction);
        }
        const firstColumn = {
            type: 'xUrl',
            hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: 'name' },
                tooltip: { fieldName: 'name' },
                target: { fieldName: 'id' },
                showPopover: true,
                isInConsole: this.isInConsole,
                objectApiName: objectApiName,
            },
            cellAttributes: iconCellAttributes,
            fieldName: 'url',
            label: objectToLabelName[apiName],
            wrapText: this.splitMode
        };
        if (this.splitMode) {
            const container = this.template.querySelector('lightning-card');
            if (container) {
                firstColumn.initialWidth = ((container.getBoundingClientRect().width / 6) * 2);
            }
            firstColumn.typeAttributes.rowActions = rowActions;
        }
        const headerActions = [
            { label: i18n.showAll, checked: false, name: 'showAll' },
            { label: i18n.collapseAll, checked: false, name: 'collapseAll' }
        ]
        const actionsColumn  = {
            type: 'action',
            alignment: 'right',
            typeAttributes: { rowActions: rowActions, menuAlignment: 'auto' },
            actions: objectApiName === ASSET_OBJECT.objectApiName
                && this.order !== ASSET_HIERARCHY_ORDER.ASSET_ONLY
                ? headerActions
                : undefined,
            initialWidth: 50
        };
        const objectInfo = this.objectInfoByApiName.get(objectApiName);
        const configFields = this.hierarchyConfig?.data?.[apiName]?.fields;
        const fieldColumns = this.mapConfigToColumns(objectInfo, configFields);
        const result = this.splitMode || this.flexipageRegionWidth === 'SMALL'
            ? [firstColumn]
            :  [
                firstColumn,
                ...fieldColumns
            ];
        if (!(this.splitMode || this.flexipageRegionWidth === 'SMALL')) {
            let colWidth = [];
            if (objectInfo?.apiName === ACCOUNT_OBJECT.objectApiName) {
                colWidth = this.cachedAccountColsWidth;
            } else if (objectInfo?.apiName === ASSET_OBJECT.objectApiName) {
                colWidth = this.cachedAssetColsWidth;
            } else if (objectInfo?.apiName === LOCATION_OBJECT.objectApiName) {
                colWidth = this.cachedLocationColsWidth;
            }
            result.forEach ((column,index) =>{
                if (colWidth && colWidth.length > 0) {
                    column.initialWidth =  colWidth[index];
                }
            });
        }
        if (this.hierarchyConfig?.data?.[apiName]?.defaultRecordActions ||
            this.hierarchyConfig?.data?.[apiName]?.enableSPMWizards ||
            this.hierarchyConfig?.data?.[apiName]?.allowManagingChildAssets ) {
            result.push(actionsColumn);
        }
        return result;
    }

    mapConfigToColumns (objectInfo, configFields) {
        return configFields?.map(field => {
            const type = objectInfo?.fields[field.fieldApiName]?.dataType.toLowerCase();
            const columnDef = {
                type: this.castFieldToSupportType(objectInfo?.fields[field.fieldApiName]),
                fieldName: type === FIELD_DATA_TYPES.REFERENCE.toLowerCase()
                    ? this.getUrl(field.fieldApiName)
                    : field.fieldApiName,
                label: objectInfo?.fields?.[field.fieldApiName]?.label,
                fieldType: type,
                hideDefaultActions: true,
                typeAttributes: this.getTypeAttributesByType(type, field, objectInfo)
            }
            return columnDef;
        });
    }

    handleCancelModal () {
        this.wizardModalDialogOpen = false;
        this.locationFieldsDialogOpen = false;
        this.assetFieldsDialogOpen = false;
        this.accountFieldsDialogOpen = false;
        this.deleteModalDialogOpen = false;
        this.rowToBeDeleted = undefined;
        this.fieldSelectError = false;
    }

    handleChange (event) {
        const targetElement = event.target;
        const objectApiName = targetElement.dataset.object;
        this.selectedFields[objectApiName] = event.detail.value.map(
            (element)=> {
                return element
            });
    }

    handleExpandCollapseAll () {
        this.expandAll = !this.expandAll;

        if (this.expandAll) {
            this.handleRefresh(Array.from(this.allKeys));
        } else {
            const expandedRows = [];
            this.handleRefresh(expandedRows);
        }
    }

    handleHeaderAction (event) {
        // Retrieves the name of the selected filter
        const actionName = event.detail.action.name;
        const treeGrid = event.currentTarget;
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'showAll':
                treeGrid.expandAll();
                break;
            case 'collapseAll':
                treeGrid.collapseAll();
                break;
        }
    }

    handleSaveFields (event) {
        const targetElement = event.target;
        const objectApiName = targetElement.dataset.object;
        const selectedFields = this.selectedFields?.[objectApiName];
        const mutableConfig = deepCopy(this.hierarchyConfig);
        this.fieldSelectError = false;
        if ( selectedFields.length > 0 ) {
            mutableConfig.data[objectApiName].fields = selectedFields.map(
                (field, index) => {
                    return {
                        fieldApiName: field,
                        sequence: index+1
                    }
                });
            this.hierarchyConfig = mutableConfig;
            this.setLocalStorageValue (objectApiName,selectedFields);
            this.handleRefresh();
            this.handleCancelModal();
        } else {
            this.fieldSelectError = i18n.selectAtLeastOneField;
        }
    }

    setLocalStorageValue (sectionObjectName,selectedFields) {
        const localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}`+
        `${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}`+
        `${this.objectApiName}${sectionObjectName}${this.label}`;
        asyncSetItemIntoCache (localStorageKey,selectedFields);
    }

    handleRestoreDefaultsModal (event) {
        const targetElement = event.target;
        const objectApiName = targetElement.dataset.object;
        this.selectedFields[objectApiName] =
         this.defaultHierarchyConfig.data?.[objectApiName]?.fields.map(field =>
         {
             return field.fieldApiName
         });
    }

    handleShowAll () {
        const detail = this.template.querySelector('c-x-detail-tree-grid');
        detail.expandAll();
    }

    handleCollapseAll () {
        const detail = this.template.querySelector('c-x-detail-tree-grid');
        detail.collapseAll();
    }

    handleLaunchAction (event) {
        const selectedEvent = new CustomEvent('launchaction', { detail: event.detail });
        this.dispatchEvent(selectedEvent);
        this.wizardModalDialogOpen = false;
    }

    handleOpenLocationFields () {
        this.locationFieldsDialogOpen = true;
    }

    handleOpenAssetFields () {
        this.assetFieldsDialogOpen = true;
    }

    handleOpenAccountFields () {
        this.accountFieldsDialogOpen = true;
    }

    async handleRefreshClick () {
        this.searchResults = [];
        this.selectedRows = [];
        this.error = false;
        this.allKeys.clear();
        this.targetRecord = {
            id: undefined,
            objectApiName: undefined
        }
        this.notificationByAssetId = new Map();
        await this.getLocalStorageCacheFilters();
        const updatedConfig = JSON.parse (JSON.stringify (this.hierarchyConfig));
        const assetFilter = this.assetClientFilter
            ? [...this.assetClientFilter.filter( item => item.active)]
            : [];
        if (this.assetCriteriaExpression && this.assetAdminfilterEnabled) {
            assetFilter.push(this.assetCriteriaExpression);
        }
        updatedConfig.data.asset.expressions = assetFilter;
        if (this.showLocationFilter) {
            const locationFilter = [...this.locationClientFilter.filter ( item => item.active)];
            if (this.locationCriteriaExpression && this.locationAdminfilterEnabled) {
                locationFilter.push(this.locationCriteriaExpression);
            }
            updatedConfig.data.location.expressions = locationFilter;
        }
        if (this.showAccountFilter) {
            const accountFilter = [...this.accountClientFilter.filter ( item => item.active)];
            if (this.accountCriteriaExpression && this.accountAdminfilterEnabled) {
                accountFilter.push(this.accountCriteriaExpression);
            }
            updatedConfig.data.account.expressions = accountFilter;
        }
        this.hierarchyConfig = updatedConfig;
        this.refreshRootId();
    }

    async handleResetColumnWidths () {
        // eslint-disable-next-line max-len
        let localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${LOCATION_OBJECT.objectApiName}`;
        // eslint-disable-next-line no-unused-vars
        await asyncRemoveItemFromCache (localStorageKey);
        this.cachedLocationColsWidth = [];
        // eslint-disable-next-line max-len
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${ASSET_OBJECT.objectApiName}`;
        // eslint-disable-next-line no-unused-vars
        await asyncRemoveItemFromCache (localStorageKey);
        this.cachedAssetColsWidth = [];
        // eslint-disable-next-line max-len
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${ACCOUNT_OBJECT.objectApiName}`;
        // eslint-disable-next-line no-unused-vars
        await asyncRemoveItemFromCache (localStorageKey);
        this.cachedAccountColsWidth = [];
    }

    refreshRootId () {
        if (isUndefinedOrNull(this.originalPrimaryRecordId)) {
            this.showNoDataIllustration();
            return;
        }
        this.searchKey = '';
        this.searchResults = [];
        this.primaryRecordId = this.originalPrimaryRecordId;
        this.handleRefreshRootId();
    }

    async handleRefreshRootId () {
        await refreshApex(this.rootIdResult);
    }

    handleRefresh (expandedRows, highlightedRows, searchKey) {
        this.refreshing = true;
        this.searchKey = searchKey;
        const rootIdVal = this.rootId;
        this.getHierarchy(rootIdVal)
            .then(result => {
                if (result.length > 0) {
                    raf(() => {
                        this.flattenedData = flattenById(result);
                        this.data = result;
                        const path = this.searchTreeByProperty(this.primaryRecordId,false, '.id');
                        this.moveToTop(path);
                        this.viewData = result;
                        if (isNotUndefinedOrNull(expandedRows)) {
                            this.defaultExpandedRows = expandedRows;
                        } else {
                            this.expandToPrimary(path, this.plotHierarchyField || this.showchilds);
                            this.showchilds = false;
                        }
                        if (isNotUndefinedOrNull(highlightedRows)) {
                            this.highlightedRows = highlightedRows;
                        } else {
                            this.highlightedRows = [this.primaryRecordId];
                        }
                        if (this.order === ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                            this.getAssetNotification([rootIdVal]);
                        } else if (this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET
                                || this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET ) {
                            this.getAssetNotification([this.primaryRecordId]);
                        }
                        this.updateIllustration(false);
                    }).call(this);
                } else {
                    this.showNoDataIllustration();
                }
            }).finally(() => {
                this.refreshing = false;
            })
    }

    handleRowAction (event) {
        const row = event.detail.row;
        const { name } = event.detail.action;
        this.rowAction = row;
        // eslint-disable-next-line default-case
        switch (name) {
            case 'edit':
                this.editRow(row);
                break;
            case 'clone':
                this.cloneRow(row);
                break;
            case 'delete':
                this.deleteModalDialogOpen = true;
                this.rowToBeDeleted = row;
                break;
            case 'launch':
                this.wizardModalDialogOpen = true;
                break;
            case 'childassets':
                this.manageChildAssetRow(row);
                break;
        }
    }

    handleRowClick (event) {
        let { row } = event.detail;
        if (!row) {
            row = event.detail;
        }
        const objectApiName = row.objectApiName?.toLowerCase();
        const targetRecord = {}
        if (objectApiName === ASSET_OBJECT.objectApiName?.toLowerCase()) {
            const payload = {
                recordId: row.id,
                sourceId: this.recordId,
                source: "c/assetHierarchy"
            };
            publish(this.messageContext, recordSelected, payload);
            targetRecord.id = row.id;
            targetRecord.objectApiName = ASSET_OBJECT.objectApiName;
        } else if (objectApiName === LOCATION_OBJECT.objectApiName?.toLowerCase()) {
            targetRecord.id = row.id;
            targetRecord.objectApiName = LOCATION_OBJECT.objectApiName;
        } else if (objectApiName === ACCOUNT_OBJECT.objectApiName?.toLowerCase()) {
            targetRecord.id = row.id;
            targetRecord.objectApiName = ACCOUNT_OBJECT.objectApiName;
        }
        this.targetRecord = targetRecord;
        this.selectedRows = [row.id];
    }

    handleDeleteConfirmModal () {
        this.deleteRow(this.rowToBeDeleted);
        this.deleteModalDialogOpen = false;
    }

    async handleSwitch () {
        await this.getLocalStorageCacheForColsWidth ();
        this.splitMode = !this.splitMode;
        const localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}`+
        `${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}`+
        `${ASSET_HIERARCHY_LOCALSTORAGE.APP_MODE}${this.label}`;
        asyncSetItemIntoCache (localStorageKey,this.splitMode);
    }

    handleSplitterClick (event) {
        event.stopPropagation();

        this._splitViewExpanded = !this._splitViewExpanded;
    }

    editRow (row) {
        this.editActionTitle = row.name;
        this.editRecordId = row.id;
        const objectApiName = row.objectApiName??'';
        if (objectApiName.toLowerCase()
            === ASSET_OBJECT.objectApiName?.toLowerCase()) {
            this.editRecordObjectApiName = ASSET_OBJECT.objectApiName;
        } else if ( objectApiName.toLowerCase()
            === ACCOUNT_OBJECT.objectApiName?.toLowerCase()) {
            this.editRecordObjectApiName = ACCOUNT_OBJECT.objectApiName;
        } else if ( objectApiName.toLowerCase()
            === LOCATION_OBJECT.objectApiName?.toLowerCase()) {
            this.editRecordObjectApiName = LOCATION_OBJECT.objectApiName;
        }
        this.showEditRecordModal = true;
    }

    handleCancelRecordModal () {
        this.showEditRecordModal = false;
        this.editRecordId = null;
        this.editRecordObjectApiName = null;
        this.error = false;
    }

    handleCancelChildAssetModal () {
        this.showChildAssetModal = false;
        this.highlightNewlyCreatedRecord(this.childAssetRecordId, true);
    }

    manageChildAssetRow (row) {
        this.childAssetTitle = row.name;
        this.childAssetRecordId = row.id;
        this.showChildAssetModal = true;
        this.initiatedTime = Date.now()+'';
    }

    handleSaveRecordModal () {
        this.showEditRecordModal = false;
        this.editRecordId = null;
        this.editRecordObjectApiName = null;
        this.dispatchEvent(
            new ShowToastEvent({
                message: i18n.transactionSuccess,
                variant: 'success'
            })
        );
    }

    handleCloneCancelRecordModal () {
        this.showCloneRecordModal = false;
        this.editRecordId = null;
        this.editRecordObjectApiName = null;
        this.cloneError = false;
    }

    filterCloneFields (apiName, fields) {
        const allAccountFields = this.allAccountFields;
        const allLocationFields = this.allLocationFields;
        const allAssetFields = this.allAssetFields;
        Object.keys(fields).forEach(function (key) {
            if (apiName === ACCOUNT_OBJECT.objectApiName) {
                if (allAccountFields.findIndex(
                    item => item.value === key
                ) === -1) {
                    delete fields[key];
                }
            } else if (apiName === ASSET_OBJECT.objectApiName) {
                if (allAssetFields.findIndex(
                    item => item.value === key
                ) === -1) {
                    delete fields[key];
                }
            } else {
                if (allLocationFields.findIndex(
                    item => item.value === key
                ) === -1) {
                    delete fields[key];
                }
            }
        });
        return fields;
    }

    handleCloneSubmitModal (event) {
        event.preventDefault();       // stop the form from submitting
        this.isCloning = true;
        const allPreFilterFields = event.detail.fields;
        const fields = this.filterCloneFields(this.editRecordObjectApiName,allPreFilterFields);
        const objRecordInput = { 'apiName': this.editRecordObjectApiName, fields };
        createRecord(objRecordInput).then(response => {
            this.isCloning = false;
            this.showCloneRecordModal = false;
            this.editRecordId = null;
            this.editRecordObjectApiName = null;
            this.dispatchEvent(
                new ShowToastEvent({
                    message: i18n.transactionSuccess,
                    variant: 'success'
                })
            );
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: response.id,
                    actionName: 'view',
                },
            }).then(url => {
                const detail = this.template.querySelector('c-x-detail-tree-grid');
                const keys = detail.expandedAllRows();
                this.handleRefresh(Array.from(keys));
                window.open(url);
            });
        }).catch(error => {
            this.isCloning = false;
            this.cloneError = error.body.message;
        })
    }

    cloneRow (row) {
        this.editActionTitle = row.name;
        this.editRecordId = row.id;
        const objectApiName = row.objectApiName??'';
        if (objectApiName.toLowerCase()
            === ASSET_OBJECT.objectApiName?.toLowerCase()) {
            this.editRecordObjectApiName = ASSET_OBJECT.objectApiName;
        } else if ( objectApiName.toLowerCase()
            === ACCOUNT_OBJECT.objectApiName?.toLowerCase()) {
            this.editRecordObjectApiName = ACCOUNT_OBJECT.objectApiName;
        } else if ( objectApiName.toLowerCase()
            === LOCATION_OBJECT.objectApiName?.toLowerCase()) {
            this.editRecordObjectApiName = LOCATION_OBJECT.objectApiName;
        }
        this.showCloneRecordModal = true;
    }

    deleteRow (row) {
        deleteRecord(row.id)
            .then(() => {
                this.handleRefreshClick();
            })
            .catch(error => {
                this.error = JSON.stringify(error);
            })
    }

    moveToTop (path) {
        if (path && path.length >0) {
            const path1 = path[0].split('.');
            path1.pop();
            this.rearrangeDataToTop (this.data ,path1);
        }
    }

    rearrangeDataToTop (data, row) {
        const rowitem = row.shift();
        const index = data.findIndex(item =>  item.id === rowitem);
        if (index  === -1) {
            return;
        }
        const zeroindex = 0;
        data.unshift(data.splice(index,1)[0]);
        if (data[zeroindex]?.children?.length > 0  && row?.length >0) {
            this.rearrangeDataToTop(data[zeroindex].children,deepCopy(row));
        }
        if (data[zeroindex]?.detail?.length > 0  && row?.length >0) {
            this.rearrangeDataToTop(data[zeroindex].detail,deepCopy(row));
        }
    }

    highlightRow (wrappedRow) {
        requestAnimationFrameAsPromise().then(() => {
            const expandedRows = [];
            wrappedRow.result.forEach(item => {
                expandedRows.push(item);
            });
            this.viewData = this.data;
            this.data = this.viewData;
            this.defaultExpandedRows = expandedRows;
            this.highlightedRows = [wrappedRow.recordId];
            if (this.splitMode) {
                const eventObj = {
                    detail: {
                        id: wrappedRow.recordId,
                        objectApiName: wrappedRow.objectAPIName
                    }
                };
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout (() => {
                    requestAnimationFrameAsPromise().then(() => {
                        this.handleRowClick (eventObj);
                    });
                }, 200);
            }
        });
    }

    searchTreeByProperty (searchKey, searchAllProperty, property = '.name') {
        if (isUndefinedOrNull(searchKey)) {
            // eslint-disable-next-line no-param-reassign
            searchKey = '';
        }
        const searchResult =[];
        const duplicateChecker = new Set();
        if (isUndefinedOrNull(this.flattenedData)) {
            return searchResult;
        }
        Object.keys(this.flattenedData).forEach(key => {
            const loweredSearchValue = searchKey.toLowerCase();
            const propertyParts = key.split('.');
            const propertyKey = propertyParts.pop();
            const pathWithoutKey = propertyParts.join('.');
            if (!duplicateChecker.has(pathWithoutKey)) {
                if (searchAllProperty) {
                    const objectApiName = this.flattenedData[`${pathWithoutKey}.objectApiName`];
                    if (objectApiName === LOCATION_OBJECT.objectApiName.toLowerCase()
                        && this.locationSearchableFields.includes(propertyKey)
                        && this.flattenedData[key]?.toLowerCase()?.indexOf(loweredSearchValue) > -1
                    ) {
                        searchResult.push (key);
                        duplicateChecker.add(pathWithoutKey);
                    } else if (objectApiName === ASSET_OBJECT.objectApiName.toLowerCase()
                        && this.assetSearchableFields.includes(propertyKey)
                        && this.flattenedData[key]?.toLowerCase()?.indexOf(loweredSearchValue) > -1
                    ) {
                        searchResult.push (key);
                        duplicateChecker.add(pathWithoutKey);
                    } else if ( this.accountSearchableFields.includes(propertyKey)
                        && this.flattenedData[key]?.toLowerCase()?.indexOf(loweredSearchValue) > -1
                    ) {
                        searchResult.push (key);
                        duplicateChecker.add(pathWithoutKey);
                    }
                }
                if (key.toLowerCase().indexOf(property.toLowerCase()) !== -1
                    && this.flattenedData[key]?.indexOf('<img') === -1) {
                    if (this.flattenedData[key]?.toLowerCase()?.indexOf(loweredSearchValue) > -1) {
                        searchResult.push (key);
                        duplicateChecker.add(pathWithoutKey);
                    }
                }
            }
        });
        return searchResult;
    }

    expandToPrimary (
        path = this.searchTreeByProperty(this.primaryRecordId,false, '.id'),
        expandMatchRow = false) {
        if (this.primaryRecordId) {
            const expandedRows = new Set();
            path.forEach(result => {
                const parsedResult = result.split('.');
                // eslint-disable-next-line no-unused-vars
                const property = parsedResult.pop();
                if (!expandMatchRow) {
                    // eslint-disable-next-line no-unused-vars
                    const matchedRowId = parsedResult.pop();
                }
                parsedResult.forEach(item => {
                    expandedRows.add(item);
                });
            });
            this.defaultExpandedRows = Array.from(expandedRows);
        }
    }

    async getAssetNodesH (recordIds,fetchChildrenOnly = false) {
        const results = await getAssetNodesForHierarchyRaw({
            recordIds: recordIds,
            config: this.hierarchyConfigData,
            primaryRecordId: this.primaryRecordId,
            order: this.order,
            fetchOnlyChildren: fetchChildrenOnly
        })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        return results;
    }

    isAssetDataTobeMassaged () {
        if ( this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET) {
            return (
                !(this.hierarchyField.toLowerCase() === 'id'
                || this.hierarchyField.toLowerCase() === 'parentid' )
                || this.objectApiName.toLowerCase() === ASSET_OBJECT.objectApiName.toLowerCase()
            )
        } else if ( this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET) {
            return (
                !(this.hierarchyField.toLowerCase() === 'id'
                || this.hierarchyField.toLowerCase() === 'parentlocationid'
                || this.hierarchyField.toLowerCase() === 'rootlocationid' )
                || this.objectApiName.toLowerCase() === ASSET_OBJECT.objectApiName.toLowerCase()
            )
        }
        return false;
    }

    async getHierarchy (recordIds) {
        const records = [];
        let results;
        if (this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET) {
            const results_part1 = await getFirstSetOfAccounts({
                rootId: this.rootId,
                config: this.hierarchyConfigData
            }).catch(error => {
                this.error = parseErrorMessage(error);
            });
            const results_part2 = await getLastSetOfAccounts({
                rootId: this.rootId,
                config: this.hierarchyConfigData
            }).catch(error => {
                this.error = parseErrorMessage(error);
            });
            results = results_part1?.concat(results_part2);
        } else {
            results = await getHierarchyNodesRaw({
                recordIds: recordIds,
                config: this.hierarchyConfigData,
                primaryRecordId: this.primaryRecordId,
                order: this.order
            })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                });
        }
        if (results) {
            if (this.order === ASSET_HIERARCHY_ORDER.ASSET_ONLY) {
                this.assetResults = results;
                const apiName = ASSET_OBJECT.objectApiName.toLowerCase();
                let displayIconName;
                if ( this.hierarchyConfig?.data?.[apiName]?.displayIconName
                    && !this.hierarchyConfig?.data[apiName].displayIconName.includes(":")) {
                        displayIconName = this.hierarchyConfig?.data[apiName].displayIconName;
                }
                records.push(...arrayToTree(results.map(item => {
                    const currentResult = {};
                    currentResult.id = item.Id;
                    currentResult.parentId = item.ParentId??item.ParentLocationId;
                    currentResult.objectApiName = ASSET_OBJECT.objectApiName.toLowerCase();
                    currentResult.expandByDefault = false;
                    currentResult.name = item.Name;
                    currentResult.url = '/' + item.Id;
                    currentResult.fields = this.hierarchyConfig?.data?.asset?.fields;
                    currentResult.record = JSON.stringify(item);
                    currentResult.enableFetch = false;
                    const record = item;
                    this.allKeys.add(record.Id);
                    currentResult.fields.forEach((field) => {
                        if (this.assetReferencedFields.includes(field.fieldApiName)) {
                            const fieldName = field.fieldApiName;
                            let sObjRecord;
                            if (isNotUndefinedOrNull(fieldName) && fieldName.endsWith("Id")) {
                                const relatedRecord = fieldName.replace("Id", "");
                                sObjRecord = record[relatedRecord];
                            } else if (isNotUndefinedOrNull(fieldName)
                                        && fieldName.endsWith("__c")) {
                                const relatedRecord = fieldName.replace("__c", "__r");
                                sObjRecord = record[relatedRecord];
                            }
                            if (isNotUndefinedOrNull(sObjRecord)) {
                                currentResult[field.fieldApiName] = sObjRecord.Id;
                                currentResult[`${field.fieldApiName}Name`] = sObjRecord.Name;
                                if (fieldName === 'RecordTypeId') {
                                    currentResult[`${field.fieldApiName}Url`] = sObjRecord.Name;
                                } else {
                                    currentResult[`${field.fieldApiName}Url`] = '/' + sObjRecord.Id;
                                }
                            }
                        }
                        else {
                            currentResult[field.fieldApiName] = record[field.fieldApiName];
                        }
                        if (field.fieldApiName === 'ParentLocationId') {
                            currentResult.parentId = currentResult[field];
                        }
                    });
                    if (isNotUndefinedOrNull(displayIconName)
                        && isEmptyString(currentResult[displayIconName])) {
                            currentResult[displayIconName] = record[displayIconName];
                        }
                    return currentResult;
                })));
            } else if (this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET
                    || this.order === ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET ) {
                const assetList = await this.getAssetNodesH ([this.primaryRecordId]);
                const assetListLength = assetList?.length;
                records.push(...arrayToTree(results.map(item => {
                    let enableFetchValueSet = false;
                    const currentResult = {};
                    currentResult.id = item.Id;
                    const objectId = item.Id;
                    const hierarchyConfigData = this.hierarchyConfig?.data;
                    if (OBJECTAPIMAP[objectId.substring(0, 3)] === ASSET_OBJECT.objectApiName) {
                        currentResult.objectApiName = ASSET_OBJECT.objectApiName.toLowerCase();
                        currentResult.parentId = item.ParentId;
                        currentResult.fields = hierarchyConfigData?.asset?.fields;
                    } else if (OBJECTAPIMAP[objectId.substring(0, 3)]
                                                 === LOCATION_OBJECT.objectApiName) {
                        currentResult.objectApiName = LOCATION_OBJECT.objectApiName.toLowerCase();
                        currentResult.parentId = item.ParentLocationId;
                        currentResult.fields = hierarchyConfigData?.location?.fields;
                    } else {
                        currentResult.objectApiName = ACCOUNT_OBJECT.objectApiName.toLowerCase();
                        currentResult.parentId = item.ParentId;
                        currentResult.fields = hierarchyConfigData?.account?.fields;
                    }
                    let displayIconName;
                    if ( hierarchyConfigData?.[currentResult.objectApiName]?.displayIconName
                        && !hierarchyConfigData[currentResult.objectApiName]
                            .displayIconName.includes(":")) {
                            displayIconName = hierarchyConfigData[currentResult.objectApiName]
                                .displayIconName;
                    }
                    currentResult.expandByDefault = false;
                    currentResult.name = item.Name;
                    currentResult.url = '/' + item.Id;
                    currentResult.record = JSON.stringify(item);
                    const record = item;
                    if (record[CHILDASSETS]) {
                        currentResult.children = record[CHILDASSETS];
                    }
                    if ( currentResult.children && currentResult.children.length > 0) {
                        currentResult.enableFetch = false;
                        // eslint-disable-next-line max-len
                        currentResult.children = populateResultRaw(
                            currentResult.children,
                            this.hierarchyConfig?.data,
                            this.assetReferencedFields,
                            this.allKeys,
                            true);
                    } else {
                        currentResult.enableFetch = true;
                    }
                    if ((assetListLength > 0
                            && currentResult.id === assetList[0].id)) {
                        if (assetListLength > 0
                            && assetList[0].detail
                            && assetList[0].detail.length > 0) {
                            if (this.isAssetDataTobeMassaged()) {
                                // eslint-disable-next-line max-len
                                currentResult.detail = arrayToTree(populateResult(assetList[0].detail, this.allKeys,true));
                                currentResult.enableFetch = enableFetchValueSet =true;
                            } else {
                                currentResult.detail = populateResult(
                                    assetList[0].detail,
                                    this.allKeys,
                                    true);
                            }
                        }
                        if (assetListLength
                            && assetList[0].children
                            && assetList[0].children.length > 0) {
                            currentResult.children =
                                populateResult(
                                    assetList[0].children,
                                    this.allKeys,
                                    true);
                        }
                        if (!enableFetchValueSet) {
                            currentResult.enableFetch = false;
                        }
                    }
                    if ((assetListLength > 0
                        && currentResult.id === this.primaryRecordId)) {
                        currentResult.detail = arrayToTree(populateResultRaw(
                            assetList,
                            this.hierarchyConfig?.data,
                            this.assetReferencedFields,
                            this.allKeys,
                            true));
                        currentResult.enableFetch = enableFetchValueSet = false;
                    }
                    this.allKeys.add(currentResult.id );
                    let referenceFields = [];
                    if (this.order === ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET) {
                        referenceFields = this.locationReferencedFields;
                    } else {
                        referenceFields = this.accountReferencedFields;
                    }
                    currentResult.fields.forEach((field) => {
                        if (referenceFields.includes(field.fieldApiName)) {
                            const fieldName = field.fieldApiName;
                            let sObjRecord;
                            if (isNotUndefinedOrNull(fieldName) && fieldName.endsWith("Id")) {
                                const relatedRecord = fieldName.replace("Id", "");
                                sObjRecord = record[relatedRecord];
                            } else if (isNotUndefinedOrNull(fieldName)
                                        && fieldName.endsWith("__c")) {
                                const relatedRecord = fieldName.replace("__c", "__r");
                                sObjRecord = record[relatedRecord];
                            }
                            if (isNotUndefinedOrNull(sObjRecord)) {
                                currentResult[field.fieldApiName] = sObjRecord.Id;
                                currentResult[`${field.fieldApiName}Name`] = sObjRecord.Name;
                                if (fieldName === 'RecordTypeId') {
                                    currentResult[`${field.fieldApiName}Url`] = sObjRecord.Name;
                                } else {
                                    currentResult[`${field.fieldApiName}Url`] = '/' + sObjRecord.Id;
                                }                            }
                        }
                        else {
                            currentResult[field.fieldApiName] = record[field.fieldApiName];
                        }
                    });
                    if (isNotUndefinedOrNull(displayIconName)
                        && isEmptyString(currentResult[displayIconName])) {
                        currentResult[displayIconName] = record[displayIconName];
                    }
                    return currentResult;
                })));
            }
        }
        if (this.plotHierarchyField) {
            const updatedRecords = [];
            this.trimHierarchyToSelectedRecord (records,updatedRecords);
            return updatedRecords;
        }
        return records;
    }

    trimHierarchyToSelectedRecord (records,updatedRecord) {
        if (records && records.length >0) {
            const retRecord =  records.filter( rec => rec.id === this.primaryRecordId);
            if (retRecord && retRecord.length >0) {
                updatedRecord.push(...retRecord);
                return;
            }
            for (let index = 0; index < records.length; index ++) {
                this.trimHierarchyToSelectedRecord (records[index].children,updatedRecord);
            }
        }
    }

    async getFieldsDescribeResults () {

        const objectNames = [
            LOCATION_OBJECT.objectApiName,
            ASSET_OBJECT.objectApiName,
            ACCOUNT_OBJECT.objectApiName
        ];
        try {
            const resp = await getFieldDefinitionsForEntities(objectNames);
            if (resp && resp.data) {
                resp.data.forEach( objectDef => {
                    this.populateObjectFields (objectDef.fieldDefinitions,objectDef.apiName);
                });
                this.apiInProgress = false;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    populateObjectFields (fieldDefinitions,objectName) {
        fieldDefinitions.forEach( field => {
            const { apiName, label, dataType } = field;
            if ( apiName !== 'Name' && dataType !== 'LOCATION' && dataType !== 'ADDRESS' &&
                 dataType !== 'BASE64' && dataType !== 'ENCRYPTEDSTRING' &&
                 dataType !== 'TEXTAREA' && apiName !== 'LogoId' && apiName !== 'Id') {
                const fieldWrap = {
                    label,
                    value: apiName,
                    secondary: apiName
                }
                if (objectName === LOCATION_OBJECT.objectApiName) {
                    if (this.availableLocationFields.findIndex(
                        item => item.value === fieldWrap.value
                    ) === -1) {
                        this.availableLocationFields.push(fieldWrap);
                    }
                } else if (objectName === ASSET_OBJECT.objectApiName) {
                    if (this.availableAssetFields.findIndex(
                        item => item.value === fieldWrap.value
                    ) === -1) {
                        this.availableAssetFields.push(fieldWrap);
                    }
                } else {
                    if (this.availableAccountFields.findIndex(
                        item => item.value === fieldWrap.value
                    ) === -1) {
                        this.availableAccountFields.push(fieldWrap);
                    }
                }
            }
            const allFieldWrap = {
                label,
                value: apiName,
                secondary: apiName
            }
            if (objectName === LOCATION_OBJECT.objectApiName) {
                if (this.allLocationFields.findIndex(
                    item => item.value === allFieldWrap.value
                ) === -1) {
                    this.allLocationFields.push(allFieldWrap);
                }
            } else if (objectName === ASSET_OBJECT.objectApiName) {
                if (this.allAssetFields.findIndex(
                    item => item.value === allFieldWrap.value
                ) === -1) {
                    this.allAssetFields.push(allFieldWrap);
                }
            } else {
                if (this.allAccountFields.findIndex(
                    item => item.value === allFieldWrap.value
                ) === -1) {
                    this.allAccountFields.push(allFieldWrap);
                }
            }
            if (SEARCHABLE_FIELDS.includes(dataType) && apiName !== 'Name' ) {
                if (objectName === LOCATION_OBJECT.objectApiName) {
                    if (dataType === 'REFERENCE') {
                        this.locationSearchableFields.push(this.getReference(apiName));
                        this.locationReferencedFields.push(apiName);
                    } else {
                        this.locationSearchableFields.push(apiName);
                    }
                } else if (objectName === ASSET_OBJECT.objectApiName) {
                    if (dataType === 'REFERENCE') {
                        this.assetSearchableFields.push(this.getReference(apiName));
                        this.assetReferencedFields.push(apiName);
                    } else {
                        this.assetSearchableFields.push(apiName);
                    }
                } else {
                    if (dataType === 'REFERENCE') {
                        this.accountSearchableFields.push(this.getReference(apiName));
                        this.accountReferencedFields.push(apiName);
                    } else {
                        this.accountSearchableFields.push(apiName);
                    }
                }
            }
        });
    }

    subscribeToMessageChannel () {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel () {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    highlightNewlyCreatedRecord (recordId,showChilds = false) {
        this.showchilds = showChilds;
        if (recordId === this.recordId) {
            this.handleRefresh();
        } else {
            getRootId ({
                primaryRecordId: recordId,
                order: this.order,
                config: this.hierarchyConfigData,
                record: this.pageRecord
            }).then(result => {
                if (result) {
                    if (this.rootId === result) {
                        this.primaryRecordId = recordId;
                    }
                }
            }).catch(error => {
                this.error = parseErrorMessage(error);
            });
        }
    }

    handleMessage (message) {
        if (message.source === 'SVMXA360:SvmxFlowLauncher') {
            if (message.sourceId === this.recordId) {
                this.handleRefresh();
            } else {
                getObjectAPIName({ objectId: message.sourceId })
                    .then(result => {
                        if (result && result.data) {
                            switch (result.data) {
                                case ASSET_OBJECT.objectApiName:
                                    this.highlightNewlyCreatedRecord (message.sourceId);
                                    break;
                                case LOCATION_OBJECT.objectApiName:
                                    if (ASSET_HIERARCHY_ORDER.LOCATION_THEN_ASSET === this.order) {
                                        this.highlightNewlyCreatedRecord (message.sourceId);
                                    }
                                    break;
                                case ACCOUNT_OBJECT.objectApiName:
                                    if (ASSET_HIERARCHY_ORDER.ACCOUNT_THEN_ASSET === this.order) {
                                        this.highlightNewlyCreatedRecord (message.sourceId);
                                    }
                                    break;
                                default:
                                    break;
                            }
                        }
                    });
            }
        }
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

    showNoDataIllustration () {
        this.updateIllustration(
            true,
            'no_data:open_road',
            i18n.noDataHeading,
            i18n.noDataBody
        );
    }

    showNoDataSearchIllustration () {
        this.updateIllustration(
            true,
            'no_data:open_road',
            i18n.noDataHeading,
            ''
        );
    }

    castFieldToSupportType = (fieldDef) => {
        let type = '';
        const fieldType = fieldDef?.dataType.toLowerCase();
        switch (fieldType) {
            // standard types
            case 'date':
                type = 'date-local';
                break;
            case 'datetime':
                type = 'date';
                break;
            case 'time':
                type = 'xTime';
                break;
            case 'percent':
            case 'double':
            case 'int':
                type = 'number';
                break;
            // always readonly as its salesforce system field
            case 'ID':
                type = 'text';
                break;
            case 'string':
                //type = 'text';
                type = fieldDef?.calculated ? 'xRichText' : 'text';
                break;
            case 'reference':
                type = 'xUrl';
                break;
            case 'textarea':
                type = 'xTextarea';
                break;
            case 'picklist':
            case 'multipicklist':
                type = 'xPicklist';
                break;
            default:
                type = fieldType;
        }

        if (fieldDef?.apiName === 'RecordTypeId') {
            type = 'text';
        }
        return type;
    }

    getTypeAttributesByType (type, field, objectInfo) {
        const typeAttributesByType = new Map([
            [
                "reference",
                {
                    label: { fieldName: this.getReference(field.fieldApiName) },
                    tooltip: {
                        fieldName: this.getReference(field.fieldApiName),
                    },
                    target: { fieldName: field.fieldApiName },
                    showPopover: true,
                    isInConsole: this.isInConsole,
                    objectApiName:
                        objectInfo?.fields?.[field.fieldApiName]
                            ?.referenceToInfos?.[0]?.apiName,
                },
            ],
            ['datetime', {
                timeZone: TIMEZONE,
                month: '2-digit',
                day: '2-digit',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric'
            }]
        ]);
        return typeAttributesByType.get(type) ?? {};
    }

    getReference (fieldName) {
        let result = "";
        if (fieldName.endsWith("Id")) {
            result = fieldName + "Name";
        } else {
            result = fieldName.replace("__c", "__cName");
        }
        return result;
    }

    getUrl (fieldName) {
        let result = "";
        if (fieldName.endsWith("Id")) {
            result = fieldName + "Url";
        } else {
            result = fieldName.replace("__c", "__cUrl");
        }
        return result;
    }

    handleResize (event) {
        if (event?.detail?.isUserTriggered) {
            // eslint-disable-next-line max-len
            const localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${event?.detail?.columnWidths?.objectType}`;
            asyncSetItemIntoCache (localStorageKey,event?.detail?.columnWidths?.columnWidth);
            switch (event?.detail?.columnWidths?.objectType) {
                case LOCATION_OBJECT.objectApiName:
                    this.cachedLocationColsWidth = event?.detail?.columnWidths?.columnWidth;
                    break;
                case ASSET_OBJECT.objectApiName:
                    this.cachedAssetColsWidth = event?.detail?.columnWidths?.columnWidth;
                    break;
                case ACCOUNT_OBJECT.objectApiName:
                    this.cachedLocationColsWidth = event?.detail?.columnWidths?.columnWidth;
                    break;
                default:
            }
        }
    }

    async handleFetchData (event) {
        event.preventDefault();
        event.stopPropagation();
        this.refreshing = true;
        const { name, expandedRows } = event.detail;
        const assetData = await this.getAssetNodesH (name, true);
        const path = this.searchTreeByProperty(name,false, '.id');
        if (path && path.length >0 ) {
            const path1 = path[0].split('.');
            path1.pop();
            loadData (
                path1,
                assetData,
                this.data,
                this.allKeys,
                this.hierarchyConfig?.data,
                this.assetReferencedFields);
        }
        this.viewData = JSON.parse(JSON.stringify(this.data));
        this.data = this.viewData;
        this.flattenedData = flattenById(this.data);
        path.forEach(result => {
            const parsedResult = result.split('.');
            // eslint-disable-next-line no-unused-vars
            const property = parsedResult.pop();
            parsedResult.forEach(item => {
                if (!expandedRows.includes(item)) {
                    expandedRows.push(item);
                }
            });
        });
        this.defaultExpandedRows = Array.from(expandedRows);
        this.refreshing = false;
        this.getAssetNotification(name);
    }

    get filterPanelEl () {
        return this.template.querySelector('.svmx-asset-hierarchy_filter-panel');
    }

    get filterPanelContentEl () {
        return this.template.querySelector('.svmx-asset-hierarchy_filter-panel-body');
    }

    get filterPanelHeaderEl () {
        return this.template.querySelector('.svmx-asset-hierarchy_filter-panel-header');
    }

    async getLocalStorageCacheForColsWidth () {
        // eslint-disable-next-line max-len
        let localStorageWidthKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${LOCATION_OBJECT.objectApiName}`;
        this.cachedLocationColsWidth = await asyncGetItemFromCache (localStorageWidthKey);
        // eslint-disable-next-line max-len
        localStorageWidthKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${ASSET_OBJECT.objectApiName}`;
        this.cachedAssetColsWidth = await asyncGetItemFromCache (localStorageWidthKey);
        // eslint-disable-next-line max-len
        localStorageWidthKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.objectApiName}${ACCOUNT_OBJECT.objectApiName}`;
        this.cachedAccountColsWidth = await asyncGetItemFromCache (localStorageWidthKey);
    }

    async getLocalStorageCacheFilters () {
        /* eslint-disable max-len */
        let localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.CACHE_KEY}${LOCATION_OBJECT.objectApiName}`;
        const cachedlocationClientFilter = await asyncGetItemFromCache (localStorageKey, true);
        if (cachedlocationClientFilter ) {
            this.locationClientFilter = JSON.parse(JSON.stringify(cachedlocationClientFilter));
        } else {
            this.locationClientFilter = [];
        }
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.CACHE_KEY}${ASSET_OBJECT.objectApiName}`;
        const cachedassetClientFilter = await asyncGetItemFromCache (localStorageKey, true);
        if (cachedassetClientFilter ) {
            this.assetClientFilter = JSON.parse(JSON.stringify(cachedassetClientFilter));
        } else {
            this.assetClientFilter = [];
        }
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.CACHE_KEY}${ACCOUNT_OBJECT.objectApiName}`;
        const cachedaccountClientFilter = await asyncGetItemFromCache (localStorageKey, true);
        if (cachedaccountClientFilter ) {
            this.accountClientFilter = JSON.parse(JSON.stringify(cachedaccountClientFilter));
        } else {
            this.accountClientFilter = [];
        }
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.ADMIN_CACHE_KEY}${LOCATION_OBJECT.objectApiName}`;
        const cachedlocationAdminfilterEnabled = await asyncGetItemFromCache (localStorageKey, true);
        if (isNotUndefinedOrNull(cachedlocationAdminfilterEnabled)) {
            this.locationAdminfilterEnabled = JSON.parse(JSON.stringify(cachedlocationAdminfilterEnabled));
        } else {
            this.locationAdminfilterEnabled = true;
        }
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.ADMIN_CACHE_KEY}${ASSET_OBJECT.objectApiName}`;
        const cachedassetAdminfilterEnabled = await asyncGetItemFromCache (localStorageKey, true);
        if (isNotUndefinedOrNull(cachedassetAdminfilterEnabled)) {
            this.assetAdminfilterEnabled = JSON.parse(JSON.stringify(cachedassetAdminfilterEnabled));
        } else {
            this.assetAdminfilterEnabled = true;
        }
        /* eslint-disable max-len */
        localStorageKey = `${ASSET_HIERARCHY_LOCALSTORAGE.APP_NAME}${ASSET_HIERARCHY_LOCALSTORAGE.APP_KEY}${this.order}${ASSET_HIERARCHY_LOCALSTORAGE.ADMIN_CACHE_KEY}${ACCOUNT_OBJECT.objectApiName}`;
        const cachedaccountAdminfilterEnabled = await asyncGetItemFromCache (localStorageKey, true);
        if (isNotUndefinedOrNull(cachedaccountAdminfilterEnabled)) {
            this.accountAdminfilterEnabled = JSON.parse(JSON.stringify(cachedaccountAdminfilterEnabled));
        } else {
            this.accountAdminfilterEnabled = true;
        }
    }

    /**
     * Gets the field definitions for the supplied Object API Name
     * @param {String} objectApiName - API Name of the object
     */
    async getObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: i18n.title_toast_error,
                    message: err,
                    variant: 'error'
                })
            );
        }

        return result;
    }

    updateFilterHeight () {
        raf(() => {
            const height = this.filterPanelContentEl.scrollHeight
                + this.filterPanelHeaderEl.scrollHeight
                + 10;
            if (this.filterSelected && height <= 500) {
                this.filterPanelEl.style.maxHeight = height + 'px';
                this.filterPanelEl.style.height = height + 'px';
            } else {
                this.filterPanelEl.style.maxHeight = '500px';
                this.filterPanelEl.style.height = '500px';
            }
        }).call(this);
    }


    scrollAssetHierarchy () {
        window.dispatchEvent(new Event('scroll'));
    }

    async handleErrMsgClick () {
        LightningAlert.open({
            message: i18n.searchedInvalidHierarchyNode,
            variant: "headerless",
        });
    }
}