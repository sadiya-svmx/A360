import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import getTaskEventObjectDetails
    from '@salesforce/apex/COMM_MetadataLightningService.getEntityDefinitions';
import saveExpression from '@salesforce/apex/ADM_ExpressionLightningService.saveExpression';
import deleteExpression from '@salesforce/apex/ADM_ExpressionLightningService.deleteExpression';
import { deleteRecentItemRecords } from 'c/recentItemService';

import {
    getEntityDefinitions,
    getFieldDefinitionsForEntity
} from 'c/metadataService';
import { saveRecentViewItem }
    from 'c/recentItemService';

import { ExpressionViewModel } from 'c/viewModels';
import {
    parseErrorMessage,
    PAGE_ACTION_TYPES,
    isEmptyString,
    verifyApiResponse,
    normalizeDeveloperName,
    handleMenuSelection,
    ICON_NAMES,
    FIELD_DATA_TYPES,
    FUNCTION_LITERALS,
    EXPRESSION,
    ADMIN_MODULES,
    OPERATION_TYPES
} from 'c/utils';

import labelExpressionBuilder from '@salesforce/label/c.Label_Expression_Builder';
import labelObject from '@salesforce/label/c.Label_Object';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelSave from '@salesforce/label/c.Button_Save';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelBackToList from '@salesforce/label/c.Button_BackToList';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelTitle from '@salesforce/label/c.Label_Title';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelRefreshMetadata from '@salesforce/label/c.Button_RefreshMetadata';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelSavingRecords from '@salesforce/label/c.AltText_SavingExpression';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchMappings';
import labelExpression from '@salesforce/label/c.Label_Expression';
import labelExpressionName from '@salesforce/label/c.Label_ExpressionName';
import labelExpressionHelp from '@salesforce/label/c.URL_ExpressionHelp';
import labelConditionsAndLogic from '@salesforce/label/c.Label_Conditions_Logic';
import labelGeneralInformation from '@salesforce/label/c.Label_GeneralInformation';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelContinueConfirmation from '@salesforce/label/c.Label_ContinueConfirmation';
import messageExpressionNameMissing from '@salesforce/label/c.Message_ExpressionNameMissing';
import placeholderUntitledExpression from '@salesforce/label/c.Placeholder_UntitledExpression';
import messageEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import titleObjectSelector from '@salesforce/label/c.Title_ObjectSelector';
import messageEnterExpressionName from '@salesforce/label/c.Message_EnterExpressionName';
import messageDataSourceObjectSelection from
    '@salesforce/label/c.Message_DataSourceObjectSelection';
import errorDuplicateDeveloperName from
    '@salesforce/label/c.Error_DuplicateExpressionDeveloperName';
import errorLiteralParameterSelection from
    '@salesforce/label/c.Error_LiteralParameterSelection';
import labelDataSourceObject from
    '@salesforce/label/c.Label_DataSourceObject';
import labelButtonDelete from '@salesforce/label/c.Button_Delete';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelWhereUsed from '@salesforce/label/c.Label_WhereUsed';

const i18n = {
    pageHeader: labelExpressionBuilder,
    cancel: labelCancel,
    help: labelHelp,
    save: labelSave,
    edit: labelEdit,
    backToList: labelBackToList,
    formValidation: labelFormValidation,
    title: labelTitle,
    developerName: labelDeveloperName,
    description: labelDescription,
    object: labelObject,
    titlePlaceholder: placeholderUntitledExpression,
    enterDeveloperName: messageEnterDeveloperName,
    objectSelector: titleObjectSelector,
    enterExpressionName: messageEnterExpressionName,
    searchPlaceholder: labelSearchPlaceholder,
    refreshMetadata: labelRefreshMetadata,
    select: labelSelect,
    titleMissing: messageExpressionNameMissing,
    enterValueMissing: labelEnterValue,
    developerNameMissing: labelEnterDeveloperName,
    copyOf: labelCopyOf,
    wasSaved: labelWasSaved,
    continue: labelYesContinue,
    goBack: labelNoGoBack,
    savingRecords: labelSavingRecords,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    expression: labelExpression,
    expressionName: labelExpressionName,
    helpLink: labelExpressionHelp,
    generalInfoSection: labelGeneralInformation,
    conditionsSection: labelConditionsAndLogic,
    required: labelRequired,
    continueConfirmation: labelContinueConfirmation,
    duplicateDeveloperName: errorDuplicateDeveloperName,
    dataSourceObject: labelDataSourceObject,
    literalParameterSelection: errorLiteralParameterSelection,
    dataSourceObjectSelection: messageDataSourceObjectSelection,
    buttonDelete: labelButtonDelete,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    confirm: labelConfirm,
    deleteSuccess: labelDeletedSuccess,
    whereused: labelWhereUsed
};

const EXPRESSION_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__expressionDetail'
    }
};

const { VISIBILITY_RULE_CRITERIA } = EXPRESSION;
const { CONFIGURATION_FILTER } = EXPRESSION;

const CLONE_NAME_PREFIX = i18n.copyOf;

export default class ExpressionAdminDetail extends NavigationMixin(
    LightningElement
) {
    currentPageReference;
    currentNavItem;
    @track error;
    @track cancelModalDialogOpen;
    @track changeObjectModalDialogOpen;
    @track changeHeaderRecordModalDialogOpen;
    @track viewModel = {};
    @track viewModelUnwrapped;
    @track apiInProgress = false;
    @track entityOptions = [];
    @track editMode = false;
    @track entityDefinition;
    @track clearStateNeeded = false;
    @track recordHeaderOptions = [];
    @track expressionType;
    @track deleteModalDialogOpen;
    @track isVisibilityCriteria = false;
    @track isConfigurationFilter= false;
    entityLabelApiName = new Map();

    @track moduleType = '';
    @track configurationId = '';
    @track configDeveloperName = '';
    @track configName = '';
    @track launchModule = '';
    @track operationType = '';
    @track whereUsedModalDialogOpen = false;

    _recordId;
    _actionName;
    _recordData;
    _newObjectChangeValue;
    _newHeaderRecordObjectChangeValue;
    _recordName;
    _countOfExpressionItems;

    errorCallback (error) {
        console.error('errorCallback', error);
        this.error = parseErrorMessage(error);
    }

    renderedCallback () {
        if (this.clearStateNeeded) {
            this.clearStateNeeded = false;
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        this._newObjectChangeValue = undefined;

        if (pageRef && pageRef.state) {
            this.clearState();

            if (pageRef.state.c__recordId) {
                this._recordId = pageRef.state.c__recordId;
            }

            if (pageRef.state.c__actionName) {
                this._actionName = pageRef.state.c__actionName.toLowerCase();
                if (this._actionName === PAGE_ACTION_TYPES.EDIT
                    || this._actionName === PAGE_ACTION_TYPES.CLONE) {
                    this.editMode = true;
                } else if (this._actionName === PAGE_ACTION_TYPES.VIEW) {
                    this.editMode = false;
                }
            }

            if (pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            if (pageRef.state.c__objectName) {
                this._newObjectChangeValue = pageRef.state.c__objectName;
                this.handleChangeObjectConfirmModal();
            }
            if (pageRef.state.c__expressionType) {
                this.expressionType = pageRef.state.c__expressionType
            }

            this.loadView();
        }
    }

    @api
    get recordId () {
        return this._recordId;
    }
    set recordId (value) {
        this._recordId = value;
    }

    @api
    get actionName () {
        return this._actionName;
    }
    set actionName (value) {
        this._actionName = value;
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    get i18n () {
        return i18n;
    }

    get isDirty () {
        return this.viewModel ? this.viewModel.isDirty : false;
    }

    get computedFormLabel () {
        let css = 'slds-form-element slds-form-element_stacked';

        if (this.editMode) {
            css += ' slds-is-editing';
        } else {
            css +=
                ' slds-form-element_edit slds-form-element_readonly slds-hint-parent';
        }

        return css;
    }

    get developerNameEditable () {
        return (
            this.editMode &&
            (this.actionName === PAGE_ACTION_TYPES.CLONE ||
                this.actionName === PAGE_ACTION_TYPES.NEW)
        );
    }

    get isWhereUsedDisabled () {
        return this.actionName === PAGE_ACTION_TYPES.NEW || this.isConfigurationFilter ||
            this.actionName === PAGE_ACTION_TYPES.CLONE;
    }

    get objectEditable () {
        return (this.actionName === PAGE_ACTION_TYPES.NEW
            && this.expressionType !== 'visibility_criteria' &&
                this.expressionType !== 'configuration_filter') && this.editMode;
    }

    get objectAPIName () {
        return this._newObjectChangeValue;
    }

    clearState () {
        this.error = null;
        this._recordId = null;
        this._actionName = null;
        this._recordData = null;
        this.viewModel = new ExpressionViewModel(null, null, false);
        this.viewModelUnwrapped = null;
        this.entityDefinition = null;
        this.editMode = false;
        this.entityOptions = [];
        this.recordHeaderOptions =[];
        this.apiInProgress = false;
        this.clearStateNeeded = true;
        this.expressionType = null;
        this.isVisibilityCriteria = false;
        this.isConfigurationFilter = false;
    }

    loadView () {
        this.apiInProgress = true;
        switch (this.actionName) {
            case PAGE_ACTION_TYPES.VIEW:
            case PAGE_ACTION_TYPES.EDIT:
            case PAGE_ACTION_TYPES.CLONE:
                this.getExistingRecordDetails();
                break;
            default:
                this.getNewRecordDetails();
                break;
        }
    }

    getNewRecordDetails () {
        this.getAllEntities()
            .then(this.populateViewModel(null, null))
            .finally(() => {
                this.apiInProgress = false;
            });
        this.isVisibilityCriteria = this.expressionType === 'visibility_criteria' ? true : false;
        this.isConfigurationFilter = this.expressionType === 'configuration_filter';
    }

    getExistingRecordDetails () {
        getExpressionWithDetails({ expressionId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this._recordName = result.data.name;
                const recentlyViewedRecord = {
                    configurationId: result.data.id,
                    configurationName: result.data.name,
                    configurationDeveloperName: result.data.developerName,
                    configurationType: ADMIN_MODULES.EXPRESSION
                };
                saveRecentViewItem(recentlyViewedRecord)
                    .then(recentItem => {
                        if (!verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
                this.isVisibilityCriteria = result.data.expressionType === VISIBILITY_RULE_CRITERIA;
                this.isConfigurationFilter = result.data.expressionType === CONFIGURATION_FILTER;
                this.getObjectFields(result.data.objectAPIName).then(
                    entityWithFields => {
                        this.populateViewModel(result.data, entityWithFields);
                        this.getAllEntities()
                    }
                );
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally(() => {
                this.apiInProgress = false;
            });
    }

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
            this.error = parseErrorMessage(err);
        }

        return result;
    }

    async getAllEntities () {
        try {
            const resp = await getEntityDefinitions();
            let extraEntityOptions = [];
            if (resp && resp.data) {
                this.entityOptions = resp.data.map(entity => {
                    return {
                        label: entity.label,
                        value: entity.apiName,
                        secondary: entity.apiName
                    };
                });
                const objectNames = [];
                objectNames.push({ apiName: 'Event' });
                objectNames.push({ apiName: 'Task' });
                if (this.expressionType === CONFIGURATION_FILTER) {
                    objectNames.push({ apiName: 'SVMXA360__CONF_Layout__c' });
                }
                const respEventTaskObject = await getTaskEventObjectDetails(
                    { requestJson: JSON.stringify(objectNames) });
                if (respEventTaskObject && respEventTaskObject.data) {
                    extraEntityOptions = respEventTaskObject.data.map(entity => {
                        return {
                            label: entity.label,
                            value: entity.apiName,
                            secondary: entity.apiName
                        };
                    });
                }
                this.entityOptions = [ ...this.entityOptions, ...extraEntityOptions ];
                this.entityOptions.sort(this.compareLabel);
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    getDeveloperNameInput () {
        return this.template.querySelector('[data-field="developerName"]');
    }

    populateViewModel (details, entityDefinitionWithFields) {
        if (details) {
            this._recordData = details;
        }

        this.entityDefinition = entityDefinitionWithFields;
        this.viewModel = new ExpressionViewModel(
            details,
            entityDefinitionWithFields,
            false
        );

        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
            this.viewModel.markAsClone(CLONE_NAME_PREFIX);
        }

        if (this.actionName === PAGE_ACTION_TYPES.NEW) {
            this.editMode = true;
        }
        this.viewModelUnwrapped = this.viewModel.getRecordData();
        this._countOfExpressionItems = this.viewModelUnwrapped?.expressionDetailList?.length;
    }

    handleLoading (event) {
        event.stopPropagation();
        if (event.detail.loading === false) {
            this._countOfExpressionItems = this._countOfExpressionItems - 1;
        }

        if ( this._countOfExpressionItems === 0 ) {
            this.apiInProgress = false;
        }
    }

    handleBackToList () {
        this.navigateToListView();
    }

    handleCancelEdit () {
        if (this.isDirty) {
            this.cancelModalDialogOpen = true;
        } else {
            this.toggleEdit();
        }
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleDelete () {
        this.deleteModalDialogOpen = true;
    }

    checkWhereUsedForDelete () {
        this.moduleType = 'Expression';
        this.configurationId = this.viewModel.id;
        this.configDeveloperName = this.viewModel.developerName;
        this.configName = this.viewModel.name;
        this.operationType = 'delete';
        this.launchModule = this.isVisibilityCriteria ? 'Visibility Criteria' : '';
        this.whereUsedModalDialogOpen = true;
    }

    handleDeleteModal () {
        this.whereUsedModalDialogOpen =  false;
        this.handleDelete();
    }

    handleCancelDeleteModal () {
        this.whereUsedModalDialogOpen = false;
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.handleCancelDeleteModal();
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.recordId
        }];
        deleteExpression({ requestJson: JSON.stringify({ id: this.recordId }) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.showDeletionSuccessNotification(this._recordName);

                deleteRecentItemRecords(recentlyViewedRecord).then(recentItem => {
                    if (recentItem && !verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });
                this.handleBackToList();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.expression} "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;
        if (this.recordId) {
            // Reset View Model back to original source
            this.populateViewModel(this._recordData, this.entityDefinition);
            this.error = null;
            this.toggleEdit();
        } else {
            this.navigateToListView();
        }
    }

    handleChangeObjectCancelModal () {
        this.changeObjectModalDialogOpen = false;

        const expressionBuilder = this.template.querySelector(
            '.svmx-expression-builder'
        );

        const builderData = expressionBuilder.expressionData.getRecordData();
        const headerData = this.viewModel.getRecordData();

        headerData.expressionDetailList = builderData.expressionDetailList;
        this.populateViewModel(headerData, this.entityDefinition);

        this.viewModel.isDirty = true;
        this._newObjectChangeValue = this.viewModelUnwrapped.objectAPIName;
    }

    handleChangeObjectConfirmModal () {
        this.getObjectFields(this._newObjectChangeValue)
            .then(result => {
                this.populateViewModel(null, result);
                this.viewModel.isDirty = true;
                this.entityDefinition = result;
                this.getRecordHeaderOptions();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.changeObjectModalDialogOpen = false;
            });
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    handleItemChanged () {
        this.error = '';
        this.viewModel.isDirty = true;
    }

    handleMappingInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.viewModel[event.currentTarget.dataset.field] = inputVal;
    }

    handleMenuSelection (event) {
        handleMenuSelection(event, this);
    }

    handleNameBlur () {
        if (this.developerNameEditable && !this.viewModel.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.viewModel.developerName = normalizeDeveloperName(
                this.viewModel.name,
                maxLength,
                this.viewModel.name
            );
            this.getDeveloperNameInput().value = this.viewModel.developerName;
        }
    }

    handleObjectChange (event) {
        if (this.entityDefinition && this.entityDefinition.apiName !== event.detail.value) {
            this.changeObjectModalDialogOpen = true;
            this._newObjectChangeValue = event.detail.value;
        } else {
            this.getObjectFields(event.detail.value)
                .then(result => {
                    this.viewModel.entityDefinition = result;
                    this.viewModel.isDirty = true;
                    this.entityDefinition = result;
                    this.getRecordHeaderOptions();
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                });
        }
    }

    checkWhereUsed (operationType) {

        this.moduleType = 'Expression';
        this.configurationId = this.viewModel.id;
        this.configDeveloperName = this.viewModel.developerName;
        this.configName = this.viewModel.name;
        this.operationType = operationType;
        this.whereUsedModalDialogOpen = true;
    }

    handleWhereUsed () {
        this.checkWhereUsed(OPERATION_TYPES.WHEREUSED);
    }

    handleSave () {

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => { this.saveButtonClick() }, 300 );

        [...this.getElementsByClassName('dataField')].forEach(
            inputField => {  inputField.blur(); }
        );
    }

    handleSaveAfterChecks () {

        const expressionBuilder = this.template.querySelector(
            '.svmx-expression-builder'
        );

        this.whereUsedModalDialogOpen = false;

        const builderData = expressionBuilder.expressionData.getRecordData();
        const headerData = this.viewModel.getRecordData();

        let isThereCurrentHeaderRecord =  false;
        builderData.expressionDetailList.forEach(entity => {
            if ( (entity.operand === FUNCTION_LITERALS.CURRENTRECORDHEADER ||
                    entity.operand === FUNCTION_LITERALS.USER) && !entity.literalParameterAPIName
                    && entity.operandType === 'Function') {
                this.error = i18n.literalParameterSelection;
            }
            if ( entity.operand === FUNCTION_LITERALS.CURRENTRECORDHEADER ) {
                isThereCurrentHeaderRecord = true;
            }
        });
        if (this.error) {
            return;
        }
        if (!isThereCurrentHeaderRecord && headerData.headerRecordObject) {
            this.error = i18n.dataSourceObjectSelection;
            return;
        }

        const recordToSave = headerData;
        recordToSave.advancedExpression = builderData.advancedExpression
            ? builderData.advancedExpression
            : expressionBuilder.expressionData.defaultAdvancedExpression;
        recordToSave.selectedTagsValue = builderData.selectedTagsValue;
        recordToSave.expressionDetailList = builderData.expressionDetailList;
        if (this.expressionType === 'visibility_criteria') {
            recordToSave.expressionType = VISIBILITY_RULE_CRITERIA;
        } else if (this.expressionType === 'configuration_filter') {
            recordToSave.expressionType = CONFIGURATION_FILTER;
        } else {
            recordToSave.expressionType = builderData.expressionType;
        }
        this.error = null;

        this.apiInProgress = true;

        saveExpression({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    if (result.message.includes('duplicate value found:')) {
                        this.error = i18n.duplicateDeveloperName;
                    } else {
                        this.error = result.message;
                    }
                    return;
                }

                this.toggleEdit();
                this.showSaveSuccessNotification(this.viewModel.name);

                if (!this.viewModel.id) {
                    this.navigateToDetailComponent(
                        result.data.id,
                        PAGE_ACTION_TYPES.VIEW
                    );
                } else {
                    this.populateViewModel(result.data, this.entityDefinition);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    handleError (event) {
        event.stopPropagation();
        this.error = event.detail?.error;
    }

    saveButtonClick () {
        this.error = null;
        // Validate Header Lines
        const allValid = [...this.getElementsByClassName('dataField')].reduce(
            (validSoFar, inputField) => {
                if (inputField.reportValidity) {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }
                return validSoFar;
            },
            true
        );

        // Validate input
        const expressionBuilder = this.template.querySelector(
            '.svmx-expression-builder'
        );
        if (expressionBuilder.reportValidity() || !allValid) {
            this.error = this.i18n.formValidation;
            return;
        }
        if (this.actionName === PAGE_ACTION_TYPES.EDIT ||
            this.actionName === PAGE_ACTION_TYPES.VIEW) {
            this.checkWhereUsed(OPERATION_TYPES.UPDATE);
        } else {
            this.handleSaveAfterChecks();
        }
    }

    navigateToListView () {
        handleMenuSelection({
            detail: {
                name: "expression_builder",
                targetType: "LWC",
                targetDeveloperName: "c-expression-admin-list-view"
            }
        }, this);
    }

    navigateToDetailComponent (recordId, actionName) {
        const navState = {
            c__actionName: actionName,
            c__recordId: recordId
        };

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, EXPRESSION_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    showSaveSuccessNotification (expressionName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.expression} "${expressionName}" ${this.i18n.wasSaved}`,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    toggleEdit (e) {
        if (e) {
            e.stopPropagation();
        }
        this.editMode = !this.editMode;
    }

    compareLabel ( a, b) {
        const fa = a.label.toLowerCase(),
            fb = b.label.toLowerCase();
        if (fa < fb) {
            return -1;
        }
        if (fa > fb) {
            return 1;
        }
        return 0;
    }

    getRecordHeaderOptions () {
        const options = [];
        this.entityOptions.forEach(entity => {
            this.entityLabelApiName.set(entity.value,entity.label);
        });
        const objectNames = new Set();
        if (this.entityDefinition != null) {
            this.entityDefinition.fieldDefinitions.forEach(entity => {
                if ( entity.dataType === FIELD_DATA_TYPES.REFERENCE ) {
                    objectNames.add(entity.referenceTo[0]);
                }
            });
        }
        objectNames.forEach(entity => {
            if (this.entityLabelApiName.get(entity)) {
                options.push({
                    label: this.entityLabelApiName.get(entity),
                    value: entity,
                    secondary: entity
                });
                this.recordHeaderOptions = [...options];
            }
        });
    }
}