import { LightningElement, track, api } from 'lwc';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import ASSET_NAME_FIELD from '@salesforce/schema/Asset.Name';
import LOCATION_NAME_FIELD from '@salesforce/schema/Location.Name';
import SERVICE_CONTRACT_PLAN_NAME_FIELD from '@salesforce/schema/ServiceContractPlan__c.Name';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createServiceContract
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.createServiceContract';
import fetchAccountDetails
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.fetchAccountDetails';
import getLocationRelatedAccounts
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getLocationAccounts';
import fetchMatchingContractPlans
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.fetchMatchingContractPlans';
import getQualifiedAssets
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getQualifiedAssets';
import getSCONAuthoringLogs
    from '@salesforce/apex/SCON_ServiceContractPlan_LS.getSCONAuthoringLogs';

import { parseErrorMessage, verifyApiResponse, ROW_ACTION_TYPES, formatString,
    isNotUndefinedOrNull, isUndefinedOrNull } from 'c/utils';
import labelServiceContractAuthoringError
    from '@salesforce/label/c.Label_ServiceContractAuthoringError';
import labelServiceContractCreated from '@salesforce/label/c.Message_ServiceContractCreatedSuccess';
import labelCreateServiceContract from '@salesforce/label/c.Label_CreateServiceContract';
import labelAccount from '@salesforce/label/c.Label_Account';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelLocation from '@salesforce/label/c.Label_Location';
import labelSconPlan from '@salesforce/label/c.Label_ServiceContractPlan';
import labelSconName from '@salesforce/label/c.Label_ServiceContractName';
import labelSconDescription from '@salesforce/label/c.Label_ServiceContractDescription';
import labelSconStartDate from '@salesforce/label/c.Label_ServiceContractStartDate';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelCreateContractForParentAndChildAssets
    from '@salesforce/label/c.Label_CreateContractForParentAndChildAssets';
import labelPlaceholderSearch from '@salesforce/label/c.Label_SearchPlaceholderForAsset';
import labelShowMenu from '@salesforce/label/c.AltText_ShowMenu';
import labelRemoveMenuItem from '@salesforce/label/c.Menu_Remove';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelManageContractLineAssets from '@salesforce/label/c.Label_ManageContractLineAssets';
import labelMenuItemAddAssets from '@salesforce/label/c.MenuItem_AddAssets';
import labelMenuItemRemoveAssets from '@salesforce/label/c.MenuItem_RemoveAssets';
import labelButtonNext from '@salesforce/label/c.Button_Next';
import labelButtonPrevious from '@salesforce/label/c.Button_Previous';
import labelRemoveAssetTitle from '@salesforce/label/c.Label_RemoveCLIAsset';
import labelRemoveAssetConfirmMsg from '@salesforce/label/c.Message_RemoveConfirmCLIAsset';
import labelServiceContractCreation from '@salesforce/label/c.Title_ServiceContractProgress';
import LabelProgressBarText from '@salesforce/label/c.Label_ServiceContractProgressBarText';
import labelActions from '@salesforce/label/c.Button_Actions';
import labelErrorQAssetMoreThan15K from '@salesforce/label/c.Error_QualifiedAssetMoreThan15K';
// eslint-disable-next-line max-len
import labelServiceContractProgressView from '@salesforce/label/c.Label_ServiceContractProgressView';

const i18n = {
    createSuccess: labelServiceContractCreated,
    createServiceContract: labelCreateServiceContract,
    account: labelAccount,
    asset: labelAsset,
    location: labelLocation,
    sconPlan: labelSconPlan,
    cancel: labelCancel,
    confirm: labelConfirm,
    loading: labelLoading,
    sconName: labelSconName,
    sconDescription: labelSconDescription,
    sconStartDate: labelSconStartDate,
    formValidation: labelFormValidation,
    sconCreateContractForChildAssets: labelCreateContractForParentAndChildAssets,
    labelSearch: labelPlaceholderSearch,
    showMenuAltText: labelShowMenu,
    remove: labelRemoveMenuItem,
    noResults: labelNoResults.Name,
    manageContractLineAssets: labelManageContractLineAssets,
    menuItemAddAssets: labelMenuItemAddAssets,
    menuItemRemoveAssets: labelMenuItemRemoveAssets,
    buttonNext: labelButtonNext,
    buttonPrevious: labelButtonPrevious,
    removeAssetTitle: labelRemoveAssetTitle,
    removeConfirmMessage: labelRemoveAssetConfirmMsg,
    actions: labelActions,
    sconCreationTitle: labelServiceContractCreation,
    sconProgress: LabelProgressBarText,
    sconServiceContractProgressView: labelServiceContractProgressView,
    label_ServiceContractAuthoringError: labelServiceContractAuthoringError
}

const ACTION_ITEMS = [
    { id: '1', label: i18n.menuItemAddAssets, value: 'addAssets', disabled: false },
    { id: '2', label: i18n.menuItemRemoveAssets, value: 'removeAssets', disabled: true }
];

const CANCELLED = 'CANCELLED';
const FINISHED = 'FINISHED_SCREEN';

const metaForSCPColumn = {
    filters: "",
    formFillMappingId: null,
    icon: "standard:service_contract",
    object: "SVMXA360__ServiceContractPlan__c",
    placeholder: i18n.placeholderSearch,
    referenceNameFields: "Name",
    enableEventPropertyInterface: true,
}

const ROW_ACTIONS = [
    { label: i18n.remove, name: ROW_ACTION_TYPES.DELETE }
];

const assetColumnListToFilter = [
    'Name',
    'serviceContractPlanName'
];

export default class CreateServiceContract extends NavigationMixin (LightningElement) {
    @api objectApiName;
    @api recordId;

    @track recordInfo = {};
    @track parentLogInfo = {};
    @track fromAsset = false;
    @track fromLocation = false;
    @track errorMessage;
    @track apiInProgress = false;
    @track launchScreen = true;
    @track viewAssetScreen = false;
    @track actionItems = ACTION_ITEMS;
    @track qualifiedAssetList = [];
    @track deleteModalDialogOpen;
    @track servicePlanFilter = '';
    @track assetColumns = [];
    @track draftValues = [];
    newServiceContractRecord= {} ;
    qualifiedAssetMap = {};
    localQualifiedAssetMap = {};
    assetIdVsPlanIdsMap = {};
    recordInfoServiceContractPlanName = '';
    selectedRows = [];
    latestSearchKey = '';

    progressCounter = 0;
    totalRecordCount = 0;
    recordsPerContractLine = 0;
    booleanFalse = false;
    accountId;
    accountIds;
    planIds;
    accountNameField = ACCOUNT_NAME_FIELD.fieldApiName;
    serviceContractPlanNameField = SERVICE_CONTRACT_PLAN_NAME_FIELD.fieldApiName;
    assetNameField = ASSET_NAME_FIELD.fieldApiName;
    locationNameField = LOCATION_NAME_FIELD.fieldApiName;
    baseUrl;
    title = i18n.createServiceContract;

    connectedCallback () {

        if (this.objectApiName === 'Account') {
            this.recordInfo.sourceRecordId = this.recordId;
            this.accountId = this.recordId;
            this.recordInfo.locationId = null;
            this.recordInfo.evaluateForChildAssets = false;
            this.servicePlanFilter = this.buildServicePlanFilter(false, null)
        }

        else if (this.objectApiName === 'Location') {
            this.fromLocation = true;
            this.recordInfo.locationId = this.recordId;
            this.recordInfo.evaluateForChildAssets = false;
            this.fetchRelatedAccounts();
            this.servicePlanFilter = this.buildServicePlanFilter(false, null)
        }

        else if (this.objectApiName === 'Asset') {
            this.fromAsset = true;
            this.recordInfo.sourceRecordId = this.recordId;
            this.recordInfo.locationId = null;
            this.recordInfo.evaluateForChildAssets = false
            this.populateAccountDetails();
        }

        this.baseUrl = window.location.origin;
        this.recordInfo.createBulkContractLines = false;
    }

    async populateAccountDetails () {
        this.apiInProgress = true;
        fetchAccountDetails({ assetId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                if (result) {
                    this.accountId = result.data;
                }
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });

        this.planIds = await this.fetchRelatedContractPlans(this.recordId);
        this.servicePlanFilter = this.buildServicePlanFilter(this.fromAsset, this.planIds);
    }

    fetchRelatedAccounts () {
        this.apiInProgress = true;
        getLocationRelatedAccounts({ locationId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                if (result) {
                    this.accountIds = this.fetchCommaSeparatedIds(result.data);
                }
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    async fetchRelatedContractPlans (assetId) {
        this.apiInProgress = true;
        const planIds = await fetchMatchingContractPlans({ assetId: assetId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return [];
                }
                if (result) {
                    return this.fetchCommaSeparatedIds(result.data);
                }
                return [];
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
        this.assetIdVsPlanIdsMap[assetId] = planIds;
        return planIds;
    }

    fetchCommaSeparatedIds (listOfIds) {
        const idList = listOfIds;
        const mappedIdList = idList.map(item => (`'${item}'`));
        return mappedIdList.join(',');
    }

    get i18n () {
        return i18n;
    }

    handleChange (event) {
        const targetElement = event.target;
        this.recordInfo[targetElement.dataset.field] = (targetElement.type === 'checkbox')
            ? targetElement.checked : targetElement.value;
    }

    handleLookupFieldChange (event) {

        if (!event.detail) {
            return;
        }

        const { detail, target } = event;

        if (target.dataset.field === 'serviceContractPlanId') {
            this.recordInfo.serviceContractPlanId = detail.value;
            this.recordInfoServiceContractPlanName = detail.label;
        } else {
            this.recordInfo.sourceRecordId = detail.value;
            this.accountId = this.recordInfo.sourceRecordId;
        }

    }

    buildServicePlanFilter (filterAsset, planIds) {
        const queryClause = 'SVMXA360__IsActive__c=true';
        if (filterAsset) {
            return planIds?`${queryClause} AND ID IN (${planIds})`:
                `${queryClause} AND ID=null`;
        }
        return `${queryClause}`;
    }

    get locationFilter () {
        return this.accountIds?`ID IN (${this.accountIds})`:'ID=null';
    }

    saveContract () {
        if (!this.isValidInput()) return;
        this.apiInProgress = true;

        const assetIdSconPlanIdMap = {};
        const assetList = Object.values(this.localQualifiedAssetMap);
        if (assetList?.length > 0) {
            assetList.forEach(row => {
                assetIdSconPlanIdMap[row.Id] = row.serviceContractPlanId;
            });
        }
        this.recordInfo.createBulkContractLines = this.checkAuthoringMode();
        this.recordInfo.assetServiceContractPlanIdMap = assetIdSconPlanIdMap;
        this.viewAssetScreen = !this.recordInfo.createBulkContractLines;
        createServiceContract({
            requestJson: JSON.stringify(this.recordInfo)
        })
            .then(result => {
                this.apiInProgress = false;
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                const serviceContractId = result.data.serviceContractRecord.Id;
                const parentLogRecord = result.data.parentAuthoringLog;
                // eslint-disable-next-line max-len
                this.newServiceContractRecord = result.data.serviceContractRecord;
                if (this.recordInfo.createBulkContractLines) {
                    this.getSCONLogDetails(parentLogRecord,serviceContractId);
                } else {
                    this.redirectToSCON(serviceContractId,'Success');
                }
            })
            .catch(error => {
                this.errorMessage = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    getSCONLogDetails (parentLogRecord,serviceContractId) {
        getSCONAuthoringLogs({ sourceRecordId: parentLogRecord.Id })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMessage = result.message;
                    return;
                }
                const parentLogDetails = result?.data?.length > 0 ? result.data[0] : null;
                const childSconLogs = parentLogDetails?.SVMXA360__SCON_Authoring_Logs__r ?
                    parentLogDetails.SVMXA360__SCON_Authoring_Logs__r : null;
                if (childSconLogs?.length > 0) {
                    const totalBatchCompleted = childSconLogs.length;
                    this.progressCounter = Math.floor(
                        totalBatchCompleted/parentLogDetails.SVMXA360__TotalNumberOfBatches__c *
                        100);
                    if (this.progressCounter === 100 ||
                        childSconLogs.length ===
                            parentLogDetails.SVMXA360__TotalNumberOfBatches__c) {
                        // eslint-disable-next-line max-len
                        this.redirectToSCON(serviceContractId, parentLogDetails.SVMXA360__Status__c);
                        return;
                    }
                }
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    try {
                        this.getSCONLogDetails(parentLogRecord,serviceContractId);
                    } catch (error) {
                        this.errorMessage = parseErrorMessage(error);
                    }
                }, 5000);
            }).catch(error => {
                this.errorMessage = parseErrorMessage(error);
            });
    }

    redirectToSCON (serviceContractId, status) {
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if ( status === 'Failed' ) {
                const evt = new ShowToastEvent({
                    title: this.i18n.label_ServiceContractAuthoringError,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: this.i18n.createSuccess,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }
            this.redirectSObjectRecord(serviceContractId,FINISHED);

        }, 200);
    }

    checkAuthoringMode () {
        return this.totalRecordCount > 5000;
    }

    handleCancel () {
        this.redirectSObjectRecord(this.recordId,CANCELLED);
    }

    redirectSObjectRecord (targetRecordId,status) {
        const redirectEvent = new CustomEvent(
            'statuschange', {
                composed: true,
                bubbles: true,
                detail: {
                    status: status,
                    showToast: false,
                    outputVariables: [
                        {
                            name: 'redirect_recordId',
                            value: targetRecordId
                        } ]
                }
            }
        );
        this.dispatchEvent(redirectEvent);
    }

    handleClickViewSconProgress (event) {
        this.redirectSObjectRecordOnNewTab ('ServiceContract', event.currentTarget.dataset.id);
    }

    redirectSObjectRecordOnNewTab (objectName,targetRecordId) {
        const pageRef = {
            type: 'standard__recordPage',
            attributes: {
                recordId: targetRecordId,
                objectApiName: objectName,
                actionName: 'view' },
        };

        this[NavigationMixin.GenerateUrl](pageRef)
            .then(url => { window.open(url); });
    }

    isValidInput () {
        this.errorMessage = '';
        const isValid = [...this.template.querySelectorAll(
            '.dataField')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (!isValid) {
            this.errorMessage = this.i18n.formValidation;
        }
        return isValid;
    }

    handleNext () {
        if (!this.isValidInput()) {
            return;
        }
        this.title = i18n.manageContractLineAssets;
        this.launchScreen = false;
        this.viewAssetScreen = true;
        this.assetColumns = this.populateAssetColumns();
        this.qualifiedAssetMap = {};
        this.localQualifiedAssetMap = {};
        this.qualifiedAssetList = [];
        this.draftValues = [];
        this.apiInProgress = true;
        // eslint-disable-next-line consistent-return
        return getQualifiedAssets({
            requestJson: JSON.stringify(this.recordInfo)
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.errorMessage = result.message;
                return;
            }
            this.totalRecordCount = result.data.recordCount;
            this.populateAssetList(result.data.qualifiedAssetList);
            this.recordsPerContractLine = this.getChildRecordsCount(result.data.qualifiedAssetList);
            this.errorMessage = undefined;

        }).catch(error => {
            this.qualifiedAssetMap = {};
            this.localQualifiedAssetMap = {};
            this.errorMessage = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateAssetList (data) {
        const sfdcBaseUrl = this.baseUrl+'/';
        if (data?.length > 0) {
            data.forEach(newAsset => {
                if (!Object.keys(this.localQualifiedAssetMap).includes(newAsset.Id)) {
                    newAsset.assetNameUrl = newAsset.Id ? sfdcBaseUrl + newAsset.Id : null;
                    newAsset.serviceContractPlanId = this.recordInfo.serviceContractPlanId;
                    newAsset.serviceContractPlanName = this.recordInfoServiceContractPlanName;
                    newAsset.startDate = this.recordInfo.serviceContractStartDate;
                    this.localQualifiedAssetMap[newAsset.Id] = newAsset;
                    this.qualifiedAssetMap[newAsset.Id] = newAsset;
                }
            });
        }
        this.qualifiedAssetList = Object.values(this.localQualifiedAssetMap);
    }

    getChildRecordsCount (data) {
        let childLinesCount = 0;
        if (data?.length > 0 && this.totalRecordCount > 0) {
            childLinesCount =  Math.floor(this.totalRecordCount / data.length);
        }
        return childLinesCount;
    }

    handlePrevious () {
        this.title = i18n.createServiceContract;
        this.launchScreen = true;
        this.viewAssetScreen = false;
        this.errorMessage = '';
    }

    async handleLookupSelectInGrid (event) {
        const { rowId: assetId, value, fieldApiName } = event.detail;
        if (isUndefinedOrNull(value) && assetId) {

            const { setFilters: setLookupFilters } = event.detail.propertyInterface;
            if ( fieldApiName === 'serviceContractPlanId' ) {
                const planIds = this.assetIdVsPlanIdsMap[assetId] != null ?
                    this.assetIdVsPlanIdsMap[assetId] :
                    await this.fetchRelatedContractPlans(assetId);

                const filterString = this.buildServicePlanFilter(true, planIds);
                setLookupFilters(filterString);
            }
        }
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
        const assetList = Object.values(this.localQualifiedAssetMap);
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.qualifiedAssetList = assetList;
        } else {
            this.qualifiedAssetList = assetList.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                let hasMatch = false;
                assetColumnListToFilter.forEach(column => {
                    if (hasMatch) return;
                    hasMatch = ( item[column]
                        && (item[column].toLowerCase().indexOf(loweredSearchValue) !== -1 ) ) ?
                        true : false;
                });
                return hasMatch;
            });
        }
    }

    populateAssetColumns () {
        metaForSCPColumn.filters = this.buildServicePlanFilter(true, null);
        return [
            {
                label: this.i18n.asset,
                fieldName: 'assetNameUrl',
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
                label: this.i18n.sconPlan,
                fieldName: 'serviceContractPlanId',
                editable: true,
                type: "xLookup",
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    editable: true,
                    fieldName: 'serviceContractPlanId',
                    fieldType: "reference",
                    label: "Service Contract Plan",
                    type: "xLookup",
                    required: true,
                    rowId: {
                        fieldName: "Id"
                    },
                    meta: JSON.stringify(metaForSCPColumn),
                }
            },
            {
                label: this.i18n.sconStartDate,
                fieldName: 'startDate',
                type: "date-local",
                hideDefaultActions: true,
                wrapText: false,
                editable: false,
                typeAttributes: {
                    day: "2-digit",
                    disabled: false,
                    editable: true,
                    fieldName: "startDate",
                    fieldType: "date",
                    label: "Start Date",
                    month: "2-digit",
                    required: false,
                    type: "date-local",
                    year: "numeric"
                }
            },
            {
                type: 'action',
                fixedWidth: 60,
                typeAttributes: { rowActions: ROW_ACTIONS },
            }
        ];
    }

    async handleDynamicFieldChange (event) {
        const { rowId: assetId, value, fieldName, label } = event.detail;

        let nameFieldLookup;
        if ( fieldName === 'serviceContractPlanId' ) {
            nameFieldLookup = 'serviceContractPlanName';
        }

        this.updateRecordList(assetId, fieldName, value, label, nameFieldLookup);
        this.updateDraftValues(assetId, fieldName, value);
    }

    updateRecordList (assetIdValue, fieldApiName, fieldValue, label, nameFieldLookup) {
        this.localQualifiedAssetMap[assetIdValue][fieldApiName] = fieldValue;
        this.localQualifiedAssetMap[assetIdValue][nameFieldLookup] = label;
        this.qualifiedAssetList = Object.values(this.localQualifiedAssetMap);
    }

    updateDraftValues (assetId, fieldName, value) {
        const record = this.draftValues.filter(item => item.Id === assetId);

        if (!record.length) {
            this.draftValues = [...this.draftValues, {
                'Id': assetId,
                [fieldName]: value
            }];
        } else {
            const updateRecord = record[0];
            updateRecord[fieldName] = value;
            this.draftValues = [...this.draftValues];
        }
    }

    handleNewAction (event) {
        // eslint-disable-next-line default-case
        switch (event.detail.value) {
            case 'addAssets':
                this.handleAddAssets();
                break;
            case 'removeAssets':
                this.openDeleteModal();
                break;
        }
    }

    handleRowSelection (event) {
        this.selectedRows  = [];
        if (event.detail.selectedRows.length > 0) {
            this.selectedRows = event.detail.selectedRows;
            this.actionItems[1].disabled = false;
        } else {
            this.actionItems[1].disabled = true;
        }
    }

    handleAddAssets () {
        const loadedAssetIds = Object.keys(this.localQualifiedAssetMap);
        this.template.querySelector(
            'c-add-contract-line-assets').handleAddAssets(this.accountId,loadedAssetIds);
    }

    handleRefresh (event) {
        const dataToInsertRequest = JSON.parse(JSON.stringify(event.detail.value));
        if (dataToInsertRequest?.length > 0) {
            this.populateAssetList(dataToInsertRequest);
            this.totalRecordCount += (dataToInsertRequest.length * this.recordsPerContractLine);
        }
    }

    handleDeleteConfirmModal () {
        const selectedRowsIds = [];
        this.selectedRows.forEach( row => {
            selectedRowsIds.push(row.Id);
            delete this.localQualifiedAssetMap[row.Id];
        });
        this.qualifiedAssetList = Object.values(this.localQualifiedAssetMap);
        this.totalRecordCount -= (this.selectedRows.length * this.recordsPerContractLine);

        this.draftValues = this.draftValues.filter(element =>
            selectedRowsIds.indexOf(element.Id) === -1);
        this.filterListViewData(this.latestSearchKey);
        this.handleCancelModal();
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        // eslint-disable-next-line default-case
        switch (actionName) {
            case ROW_ACTION_TYPES.DELETE:
                this.selectedRows = [row];
                this.openDeleteModal();
                break;

        }
    }

    get createButtonDisabled () {
        if (Object.values (this.localQualifiedAssetMap)?.length > 15000) {
            this.errorMessage = labelErrorQAssetMoreThan15K;
            return true;
        }
        if (isNotUndefinedOrNull(this.errorMessage)
            && this.errorMessage === labelErrorQAssetMoreThan15K) {
            this.errorMessage = null;
        }
        return false;
    }

    get launchMode () {
        return (this.launchScreen);
    }

    get isBulkCreationMode () {
        return (this.recordInfo.createBulkContractLines);
    }

    get showAssetScreen () {
        return (this.viewAssetScreen);
    }

    get assetListHasRecords () {
        return this.qualifiedAssetList.length > 0;
    }

    get removeAssetConfirmMessage () {
        return formatString(i18n.removeConfirmMessage, this.selectedRows.length);
    }

    openDeleteModal () {
        this.deleteModalDialogOpen = true;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }
}