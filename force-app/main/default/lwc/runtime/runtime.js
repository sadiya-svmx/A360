/**
 * The base runtime that abstracts layout header & children fields parsing/implementation and
 * data-mapping that leverages user interaction of various field types and iniline editable
 * datatable supports CRUD operation on the header and children record collections and is
 * responsible for dispatching the updated/created/deleted record collection to flow container for
 * further handling of data.
 */
import { LightningElement, api, track, wire } from 'lwc';
import {
    ApplicationMixin, InitApplication, RegisterApplication, setHeightOffset
} from 'c/xApplication';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getPageLayoutDetails
    from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getPageLayoutDetails';
import getRecordTypeDetails
    from '@salesforce/apex/CONF_PageLayoutRunTime_LS.getRecordTypeDetails';
import getObjectMappingDetails
    from '@salesforce/apex/ADM_ObjectMappingLightningService.getObjectMappingDetails';
import getObjectMappingsWithDetailsByIds
    from '@salesforce/apex/ADM_ObjectMappingLightningService.getObjectMappingsWithDetailsByIds';
import executeAction from '@salesforce/apex/CONF_CustomAction.executeAction';
import getUserInfo
    from '@salesforce/apex/ADM_PageLayoutLightningService.getUserInfo';
import getExpressionCriteriaDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionCriteriaDetails';
import setWizardStepUsageLog
    from '@salesforce/apex/COMM_ProcessWizardService_LS.setWizardStepUsageLog';
import uiRecordApi_getRecord from '@salesforce/apex/COMM_UiApi.uiRecordApi_getRecord';
import generateTransactionUsageAnalytics
    from '@salesforce/apex/COMM_UsageAnalytics_LS.generateTransactionUsageAnalytics';
import { getFieldDefinitionsForEntities } from 'c/metadataService';
import { savePageDataForLayout } from 'c/pagedataService';
import {
    createEngineStore,
    createEngine,
    bindEngineIdToStore,
    deleteEngine
} from 'c/runtimeEngine';
import {
    RUNTIME_CONTEXT,
    TRANSACTION_TYPE,
    formatString,
    isNotUndefinedOrNull,
    parseErrorMessage,
    guid,
    isFlowContext,
    transformRecordTypes,
    deepCopy,
    IS_MOBILE_DEVICE,
    isObjectSupportedByUiApi
} from 'c/utils';

import {
    clearPubSubCache,
    enableDebugging,
    disableDebugging
} from 'c/runtimePubSub';

import labelLoading from '@salesforce/label/c.AltText_Loading';
import messageRuntimeTotalError from '@salesforce/label/c.Message_RuntimeTotalError';
import messageRuntimeInvalidFlowError from '@salesforce/label/c.Message_RuntimeInvalidFlowError';
import labelResolveError from '@salesforce/label/c.AltText_ResolveError';
import labelNextButton from '@salesforce/label/c.Button_Next';
import labelNextPrevious from '@salesforce/label/c.Button_Previous';
import labelSaveButton from '@salesforce/label/c.Button_Save';
import labelCancelButton from '@salesforce/label/c.Button_Cancel';
import messageRuntimeResolveErrors from '@salesforce/label/c.Message_RuntimeResolveErrors';
import messageRuntimeFieldsMissing from '@salesforce/label/c.Message_RequiredFieldMissing';
import messageTransactionSaved from '@salesforce/label/c.Messge_TransactionSaved';
import labelError from '@salesforce/label/c.Label_Error';
import labelErrors from '@salesforce/label/c.Label_Errors';
import labelAutofillMapping from '@salesforce/label/c.Label_Autofill_Mapping';
import labelExpressionFieldNotFound from '@salesforce/label/c.Label_Expression_Field_Not_Found';
import labelPageloutFieldNotFound from '@salesforce/label/c.Label_Pagelayout_Field_Not_Found';
import labelValueMapping from '@salesforce/label/c.Label_ValueMapping';
import cellRequired from '@salesforce/label/c.Message_RuntimeCellRequiredError';
import allowZeroLineError from '@salesforce/label/c.Message_AllowZeroLineError';
import labelDetails from '@salesforce/label/c.Label_Details';
import labelHeader from '@salesforce/label/c.Title_Header';
import { loadScript } from 'lightning/platformResourceLoader';
import runtimedependencies from '@salesforce/resourceUrl/runtimedependencies';
import runtimeTemplate from './runtime.html';
import runtimeMobileTemplate from './runtimeMobile.html';

const i18n = {
    loading: labelLoading,
    messageRuntimeTotalError,
    messageResolveErrors: messageRuntimeResolveErrors,
    resolveErrorAltText: labelResolveError,
    next: labelNextButton,
    previous: labelNextPrevious,
    save: labelSaveButton,
    cancel: labelCancelButton,
    error: labelError,
    errors: labelErrors,
    allowZeroLineError,
    cellRequired,
    labelAutofillMapping,
    labelValueMapping,
    labelExpressionFieldNotFound,
    labelPageloutFieldNotFound,
    labelDetails,
    labelHeader,
    errorFieldsMissing: messageRuntimeFieldsMissing,
};

const DELAY_UI_UPDATE = 50;

export default class Runtime extends ApplicationMixin(NavigationMixin(LightningElement)) {

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        this.currentPageReference = currentPageReference;
    }
    @api
    get getCurrentPageReference () {
        return {
            startTime: this.currentPageReference?.state?.c__startTime,
            stepId: this.currentPageReference?.state?.c__stepId,
            flowRecordId: this.currentPageReference?.state?.c__objectRecordId
        }
    }
    @api startTimeFromPageReference = 0;
    // Pagelayout to retrieve
    @api developerName = '';
    @api sourceRecordId;
    @api context = RUNTIME_CONTEXT.SCREEN_FLOW;
    @api isInModal;
    @api title;
    @api iconName;
    @api recordPageDisplay;
    @api stepId;
    @api stepComplete = false;
    @api stepCompletionEnabled = false;

    // Flow actions
    @api showPrevious = false;
    @api showNext = false;

    @track apiInProgress = false;
    @track loading = true;
    @track hasFormError = false;
    @track zeroLineErrors = [];
    @track transactionType;
    @track saveDisabled = true;

    @track recordTypeObjectName;
    @track recordTypeId;
    @track showFooterError = false;
    prevScreenDevName = '';
    handOverTime;
    transactionLoadTime;
    saveStartTime;
    noOfRecordsInChildTab = "";
    noOfRecordsAcrossChildren = 0;
    _showFooterPopover = false;
    _showConsole = false;
    _error = null;
    _transactionName = null;
    _nameValue = null;
    _transactionNameHidden = null;

    _headerRecordData = {};
    _pageDataConfig = {};
    _childRecordData = {};
    _showHeaderOnly = false;
    _showChildOnly = false;
    _hasSubmit = false;
    _resolveRecordCallBack;
    _resolveRecordTypeCallBack;
    _unsubscribe = null;
    _engineId = null;
    _stepComplete = false;

    _resolveRecordId;
    _resolveRecordFields;
    @wire(getRecord, {
        recordId: '$_resolveRecordId',
        fields: '$_resolveRecordFields',
    }) wireResolveGetRecord ({
        error,
        data
    }) {
        if (data) {
            this.resolveGetRecord(data);
        }
        else if (error) {
            this.setError(error);
            this.resolveGetRecord();
        }
    }

    _resolveApexRecordId;
    @wire(uiRecordApi_getRecord, {
        recordId: '$_resolveApexRecordId',
        fields: '$_resolveRecordFields',
        wireId: 'wiredRecordApex'
    })
    wiredRecordApex ({
        error,
        data
    }) {
        if (data) {
            this.resolveGetRecord(data);
        }
        else if (error) {
            this.setError(error);
            this.resolveGetRecord();
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: '$recordTypeObjectName',
        recordTypeId: '$recordTypeId',
    })
    getPicklistValuesByRecordTypeValues ({ error, data }) {
        if (data) {
            this.resolveRecordTypes(data);
        } else if (error) {
            this.setError(error);
            this.resolveRecordTypes();
        }
    }

    resolveGetRecord (data) {
        if (this._resolveRecordCallBack) this._resolveRecordCallBack(data);
        this._resolveRecordCallBack = null;
    }

    resolveRecordTypes (data) {
        const recordTypes =  data ? transformRecordTypes(data) : data;
        if (this._resolveRecordTypeCallBack) this._resolveRecordTypeCallBack(recordTypes);
        this._resolveRecordTypeCallBack = null;
    }

    connectedCallback () {
        this[InitApplication]();
        this._stepComplete = this.stepComplete;
        const startTimeFromPageReference = this.getCurrentPageReference.startTime;
        if (this.loading && startTimeFromPageReference) {
            const endDate = new Date().getTime();
            this.handOverTime = (endDate - startTimeFromPageReference) / 1000;
        }
        const storedDeveloperName = localStorage.getItem('prevScreenDevName');
        if (storedDeveloperName) {
            this.prevScreenDevName = storedDeveloperName;
        }
    }

    renderedCallback () {
        const endDate   = new Date().getTime();
        const startTimeFromPageReference = this.getCurrentPageReference.startTime;
        if (startTimeFromPageReference && !this.loading && !this._hasSubmit
            && !this.transactionLoadTime) {
            this.transactionLoadTime = (endDate - startTimeFromPageReference) / 1000;
        }
    }

    disconnectedCallback () {
        // Resetting errors on subsequnt calls to runtime.
        if (this._unsubscribe) {
            this._unsubscribe();
        }
        if (this._engineId) {
            deleteEngine(this._engineId);
        }
        clearPubSubCache(this._engineId);
    }

    render () {
        return IS_MOBILE_DEVICE ? runtimeMobileTemplate : runtimeTemplate;
    }

    get hasError () {
        return isNotUndefinedOrNull(this.error);
    }

    @api
    get error () {
        return this._error;
    }

    set error (value) {
        this.setError(value);
    }

    @api
    get showHeaderOnly () {
        return this._showHeaderOnly;
    }

    set showHeaderOnly (value) {
        this._showHeaderOnly = value;
    }

    @api
    get showChildOnly () {
        return this._showChildOnly;
    }

    set showChildOnly (value) {
        this._showChildOnly = value;
    }

    // Header record data
    @api
    get headerRecordData () {
        return this._headerRecordData;
    }

    set headerRecordData (value) {
        // Header with single record data
        const parsedHeaderRecord = deepCopy(value);
        this._headerRecordData = parsedHeaderRecord[0] || {};
    }

    // Header record data
    @api
    get pageDataConfig () {
        return this._pageDataConfig;
    }

    set pageDataConfig (value) {
        // Header with single record data
        this._pageDataConfig = value || {};
    }

    // Child(ren) record data - object map from its parent
    @api
    get childRecordData () {
        return this._childRecordData;
    }

    set childRecordData (newValue) {
        this._childRecordData = { ...newValue };
    }

    get i18n () {
        return i18n;
    }

    asyncGetRecordTypes (objectName, recordTypeId) {
        return new Promise (resolve => {
            this.recordTypeId = recordTypeId;
            this.recordTypeObjectName = objectName;
            this._resolveRecordTypeCallBack = resolve;
        });
    }

    clearError () {
        this._error = null;
    }

    setError (error) {
        this._error = error ? parseErrorMessage(error) : this._error;
    }

    handleError (e) {
        const { detail: error } = e;
        this.setError(error);

        e.stopPropagation();
        e.preventDefault();
    }

    get runtimeGridClasses () {
        return this._showFooterPopover ? 'svmx-runtime-grid_publish-error' : '';
    }

    hasFormErrors () {
        return this.hasFormError;
    }

    get showFormErrorsIcon () {
        return this._hasSubmit && this.hasFormErrors();
    }

    get showActionBar () {
        return this.context === RUNTIME_CONTEXT.TRANSACTION ||
            this.context === RUNTIME_CONTEXT.TRANSACTION_RECORDPAGE;
    }

    get showMarkAsComplete () {
        return this.stepCompletionEnabled !== 'false' &&
            this.stepCompletionEnabled !== false &&
            !!this.stepCompletionEnabled;
    }

    handleStepComplete (event) {
        const { value } = event.detail;
        this._stepComplete = value;
    }

    saveWizardStepComplete () {
        const stepCompletionObj = {
            stepId: this.stepId,
            sourceRecordId: this.sourceRecordId,
            enabled: this._stepComplete,
        };
        return setWizardStepUsageLog({
            requestJson: JSON.stringify( stepCompletionObj )
        }).then (result => {
            if (!result.success) {
                this.setError(result.message);
            }
        }).catch(error => {
            this.setError(error);
        });
    }

    get popoverErrorMessages () {
        let errorMessages = [];
        const totalErrors = this.errorCount;

        if (totalErrors > 0) {
            errorMessages.push(formatString(
                i18n.messageRuntimeTotalError,
                totalErrors,
                totalErrors === 1? i18n.error : i18n.errors,
            ));
            errorMessages = [ ...errorMessages, ...this.zeroLineErrors];
        }
        return errorMessages.map(message => ({ message, id: guid() }));
    }

    get shouldSaveDisabled () {
        return this.recordPageDisplay ? this.saveDisabled : false;
    }

    get pageTitle () {
        return this.recordPageDisplay ? this._transactionName : this.title;
    }

    get subTitle () {
        // name field value as sub-title
        return this._nameValue;
    }

    isStandaloneEdit () {
        return this.transactionType === TRANSACTION_TYPE.STANDALONE_EDIT;
    }

    navigateFlowNext () {
        // Always navigate to the flow next screen.
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    navigateFlowFinish () {
        // Always navigate to the flow finish screen.
        const navigateFinishEvent = new FlowNavigationFinishEvent();
        this.dispatchEvent(navigateFinishEvent);
    }

    handlePrevious () {
        // Always navigate to the flow previous screen.
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    generateTransactionUsageAnalytics (recordId) {
        const endDate = new Date().getTime();
        const saveTime = (endDate - this.saveStartTime) / 1000;
        const isFirstScreen =
        this.prevScreenDevName === '' || this.developerName === this.prevScreenDevName;
        const usageAnalyticsRequest = {
            layoutDeveloperName: this.developerName,
            wizardHandOverTime: isFirstScreen ? this.handOverTime : undefined,
            layoutLoadTime: isFirstScreen ? this.transactionLoadTime : undefined,
            layoutUsageType: this.context,
            layoutSaveTime: this.context === RUNTIME_CONTEXT.SCREEN_FLOW ? undefined  : saveTime,
            numberOfRecordsInChildTab: this.noOfRecordsInChildTab,
            numberOfRecordsAcrossChildren: this.noOfRecordsAcrossChildren,
            recordId: recordId || this.getCurrentPageReference.flowRecordId,
            wizardStepId: this.stepId || this.getCurrentPageReference.stepId
        };
        return generateTransactionUsageAnalytics({
            requestJson: JSON.stringify(usageAnalyticsRequest)
        });
    }

    handleTransactionSave () {
        this.engine.saveData()
            .then(async result => {
                const { success, recordId } = result;
                if (!this.hasFormError && success) {
                    this.generateTransactionUsageAnalytics(recordId);
                }
                if (!success) {
                    this._showFooterPopover = true;
                    if ((this.hasFormError || this.zeroLineErrors.length) && IS_MOBILE_DEVICE) {
                        let errorMessage = this.hasFormError ? i18n.errorFieldsMissing : '';
                        (this.zeroLineErrors || []).forEach(message => {
                            errorMessage += errorMessage.length ? ', ' : '' ;
                            errorMessage += message;
                        });

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: errorMessage,
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                    }
                    return;
                }
                this.resetReportValidity();
                if (this.showMarkAsComplete) {
                    await this.saveWizardStepComplete();
                }
                if (this.context === RUNTIME_CONTEXT.TRANSACTION_FLOW) {
                    if (this.prevScreenDevName !== this.developerName) {
                        localStorage.setItem('prevScreenDevName', this.developerName);
                    }
                    await this.engine.dispatchFlowRecords();
                    if (this.showNext) {
                        this.navigateFlowNext();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: messageTransactionSaved,
                                variant: 'success'
                            })
                        );
                    } else {
                        this.navigateFlowFinish();
                    }
                } else {
                    if (this.recordPageDisplay) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: messageTransactionSaved,
                                variant: 'success'
                            })
                        );
                    }
                    /* Navigation is handled in SPM wizard runtime */
                    this.dispatchEvent(
                        new CustomEvent('statuschange', {
                            composed: true,
                            bubbles: true,
                            detail: {
                                status: this.isStandaloneEdit()
                                    ? 'FINISHED_SCREEN'
                                    : 'FINISHED',
                                outputVariables: [
                                    {
                                        name: 'redirect_recordId',
                                        value: recordId
                                    } ],
                                showToast: true
                            }
                        })
                    );
                }
            })
            .catch(() => {
                this.scrollToError();
            });
    }

    scrollToError () {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const alert = this.template.querySelector("c-alert");
            //eslint-disable-next-line no-unused-expressions
            alert && alert.scrollIntoView();
            window.scrollTo({
                left: 0,
                top: 0,
            });
        }, DELAY_UI_UPDATE);
    }

    handleSave () {
        this.saveStartTime = new Date().getTime();
        this._hasSubmit = true;
        this.clearError();
        this.reportAllValidity();
        this.handleTransactionSave();
    }

    async handleNext () {
        this._hasSubmit = true;
        this.clearError();
        this.reportAllValidity();
        this.saveStartTime = new Date().getTime();
        if (this.context === RUNTIME_CONTEXT.SCREEN_FLOW) {
            const result = await this.engine.dispatchFlowRecords();
            const { success } = result;
            if (this.prevScreenDevName !== this.developerName) {
                localStorage.setItem('prevScreenDevName', this.developerName);
            }
            if (this.popoverErrorMessages.length === 0 && success) {
                this.generateTransactionUsageAnalytics();
            }
            if (!success) {
                this._showFooterPopover = true;
                return;
            }
            if (this.showNext) {
                this.navigateFlowNext();
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: messageRuntimeInvalidFlowError,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            }
        } else {
            this.handleTransactionSave();
        }
    }

    handleCancel () {
        if (this.recordPageDisplay) {
            this.engine.resetEngineState();
        }

        this.dispatchEvent(
            new CustomEvent('statuschange', {
                composed: true,
                bubbles: true,
                detail: {
                    status: 'CANCELLED',
                    showToast: false
                }
            })
        );
    }

    handleShowConsole () {
        enableDebugging(this._engineId);
        this._showConsole = true;
    }

    handleHideConsole () {
        disableDebugging(this._engineId);
        this._showConsole = false;
    }

    get computedLayoutClass () {
        const cssClasses = [
            'slds-col',
            'slds-size_1-of-1',
            'combo-input'
        ];

        if (this._showConsole) {
            cssClasses.push(`slds-large-size_8-of-12 svmx-runtime_scrollable`);
        } else {
            cssClasses.push(`slds-large-size_12-of-12`);
        }

        return cssClasses.join(' ');
    }

    reportAllValidity () {
        // Ensure that all fields have reported errors.
        this.template.querySelectorAll('c-runtime-header').forEach(header => {
            header.reportAllValidity();
        });

        // Ensure that all fields in the grid have reported errors.
        this.template.querySelectorAll('c-runtime-grid').forEach(grid => {
            grid.reportGridValidity();
        });
    }

    reportValidity = () => {
        this._hasSubmit = true;
        this._showFooterPopover = true;
        this.reportAllValidity();
        return this.hasFormErrors();
    }

    resetReportValidity () {
        this._hasSubmit = false;
        this.template.querySelectorAll('c-runtime-grid').forEach(grid => {
            grid.resetReportValidity();
        });
    }

    get showPageHeader () {
        return ((
            this.context === RUNTIME_CONTEXT.TRANSACTION ||
            this.context === RUNTIME_CONTEXT.TRANSACTION_RECORDPAGE
        ) &&
            !this.isTransactionNameHidden
        );
    }

    get showActionsInline () {
        return (!this.showPageHeader || this.isInModal || this.isTransactionNameHidden);
    }

    get footerButtonAlignment () {
        return (this.isInModal || isFlowContext(this.context)) ? 'right' : 'center';
    }

    get isFlowContext () {
        return isFlowContext(this.context);
    }

    get isTransactionNameHidden () {
        return this._transactionNameHidden;
    }

    getComponentValiditionResults () {
        let headerResult;
        if (IS_MOBILE_DEVICE) {
            const headerEl = this.template.querySelector('c-runtime-mobile');
            headerResult = headerEl.reportHeaderValidity()
        } else {
            this.template.querySelectorAll('c-runtime-header').forEach(header => {
                headerResult = header.reportAllValidity();
            });
        }

        return headerResult;
    }

    handleStoreInit (event) {
        event.stopPropagation();
        this._engineId = guid();
        clearPubSubCache(this._engineId);
        const store = createEngineStore();
        this.store = bindEngineIdToStore(store, this._engineId);
        this._unsubscribe = this.store && this.store.subscribe(this.handleStoreChange.bind(this));
        this.engine = createEngine(
            this._engineId,
            this.store,
            this.apis,
            this.developerName,
            this.headerRecordData,
            this.pageDataConfig,
            this.childRecordData,
            this.context,
        );
        this[RegisterApplication](this._engineId);
    }

    getPageLayoutDetail (developerName) {
        return getPageLayoutDetails({
            requestJson: developerName
        });
    }

    getObjectDescribe (objectAPINames) {
        return getFieldDefinitionsForEntities(objectAPINames);
    }

    getRecords (recordId, fields) {
        return new Promise((resolve) => {
            const objectApiName = fields[0].split('.')[0];
            this._resolveRecordFields = Array.isArray(fields) ? fields: [fields];
            if (!isObjectSupportedByUiApi(objectApiName)) {
                this._resolveApexRecordId = recordId;
            } else {
                this._resolveRecordId = recordId;
            }
            this._resolveRecordCallBack = resolve;
        });
    }

    getRecordTypeDetails (objectName) {
        return getRecordTypeDetails({
            requestJson: objectName
        });
    }

    saveRecords (payload) {
        const pageDetailDataList = payload.pageDetails;
        for (let i = 0; i < pageDetailDataList.length; i++) {
            const key = pageDetailDataList[i].uniqueKey;
            const length = pageDetailDataList[i].detailRecords.length;
            this.noOfRecordsInChildTab += `${key} - ${length}; `;
            this.noOfRecordsAcrossChildren += length;
        }
        return savePageDataForLayout(payload);
    }

    flowRecords (propertyName, payload, childRecord) {
        if (childRecord !== undefined) {
            const recordsInChildTab = childRecord.map(obj =>
                `${obj.name}: ${obj.length}`).join('; ');
            const RecordsAcrossChildren = childRecord.reduce((acc, obj) => acc + obj.length, 0);
            this.noOfRecordsInChildTab = recordsInChildTab;
            this.noOfRecordsAcrossChildren = RecordsAcrossChildren;
         }
        this.dispatchEvent(
            new FlowAttributeChangeEvent(
                propertyName,
                payload,
            ));
    }

    geti18n () {
        return i18n;
    }

    getObjectMappingDetails (mappingId) {
        return getObjectMappingDetails({ requestJson: JSON.stringify({ id: mappingId }) });
    }

    getObjectMappingsWithDetailsByIds (mappingIds) {
        return getObjectMappingsWithDetailsByIds({ mappingIds: mappingIds });
    }

    getUserInfo () {
        return getUserInfo({ requestJson: '' });
    }

    executeCustomAction (actionRequest) {
        return executeAction({
            requestJson: JSON.stringify(actionRequest)
        });
    }

    async loadStaticResources () {
        if (!window.acorn || !window.moment) {
            await Promise.all([
                loadScript(this, runtimedependencies)
            ]);
        }
    }

    getExpressionDetails (expressionIds) {
        return getExpressionCriteriaDetails({ expressionIds });
    }


    get showSpinner () {
        return this.apiInProgress || this.loading;
    }

    get apis () {
        return  {
            getPageLayoutDetails: this.getPageLayoutDetail.bind(this),
            getObjectDescribe: this.getObjectDescribe.bind(this),
            getRecordTypes: this.asyncGetRecordTypes.bind(this),
            getRecords: this.getRecords.bind(this),
            saveRecords: this.saveRecords.bind(this),
            flowRecords: this.flowRecords.bind(this),
            getComponentValiditionResults: this.getComponentValiditionResults.bind(this),
            geti18n: this.geti18n.bind(this),
            getObjectMappingDetails: this.getObjectMappingDetails.bind(this),
            getObjectMappingsWithDetailsByIds: this.getObjectMappingsWithDetailsByIds.bind(this),
            getUserInfo: this.getUserInfo.bind(this),
            executeCustomAction: this.executeCustomAction.bind(this),
            getExpressionDetails: this.getExpressionDetails.bind(this),
            loadStaticResources: this.loadStaticResources.bind(this),
            getRecordTypeDetails: this.getRecordTypeDetails.bind(this)
        };
    }

    handleStoreChange () {
        const state = this.store.getState();
        if (!state) {
            return;
        }
        this.setError(state.engineError);
        this.hasFormError = state.hasError;
        this.errorCount = state.errorCount;
        this.zeroLineErrors = state.zeroLineErrors;
        this.transactionType = state.transactionType;
        this.apiInProgress = state.blockApplication;
        this._showHeaderOnly = state.tabs.length === 0;
        this._showChildOnly = state.sections.length === 0;
        this.saveDisabled = !state.hasUserChanges;
        this._transactionName = state.name;
        this._nameValue = state.nameValue;
        this._transactionNameHidden = state.hideName;
        this.loading = (state.loadingStatus || {}).LOADING_ENGINE_METADATA;

        if (!this.loading) {
            if (this.isFlowContext) {
                setHeightOffset(this._engineId, '10vh');
            }
        }
    }
}