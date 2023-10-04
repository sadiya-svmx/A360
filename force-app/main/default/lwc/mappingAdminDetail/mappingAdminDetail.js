import { LightningElement, api, track, wire } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_OBJECT from '@salesforce/schema/User';

import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getObjectMappingDetails
    from '@salesforce/apex/ADM_ObjectMappingLightningService.getObjectMappingDetails';
import validateObjectMappingDetails
    from '@salesforce/apex/ADM_ObjectMappingLightningService.validateObjectMappingDetails';
import saveObjectMapping
    from '@salesforce/apex/ADM_ObjectMappingLightningService.saveObjectMapping';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getEntityDefinitions, getFieldDefinitionsForEntities }
    from 'c/metadataService';
import { saveRecentViewItem }
    from 'c/recentItemService';
import { ObjectMappingViewModel } from './objectMappingViewModel';
import {
    parseErrorMessage,
    PAGE_ACTION_TYPES,
    verifyApiResponse,
    normalizeDeveloperName,
    handleMenuSelection,
    TIMEZONE_GMT,
    ICON_NAMES,
    FUNCTION_LITERALS,
    MAPPING_TYPE,
    FIELD_DATA_TYPES,
    ADMIN_MODULES,
    isSalesforceId
} from 'c/utils';

import labelMappingTitle from '@salesforce/label/c.Title_Mappings';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelSave from '@salesforce/label/c.Button_Save';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelMappingName from '@salesforce/label/c.Label_Mapping_Name';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelClear from '@salesforce/label/c.Label_Clear';
import labelClearAll from '@salesforce/label/c.Label_ClearAll';
import labelRefreshMetadata from '@salesforce/label/c.Button_RefreshMetadata';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelSavingMappingRecords from '@salesforce/label/c.AltText_SavingMapping';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelTargetObject from '@salesforce/label/c.Label_TargetObject';
import labelSourceObject from '@salesforce/label/c.Label_SourceObject';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchMappings';
import labelMapping from '@salesforce/label/c.Label_Mapping';
import labelNoMatchingFieldAvailable from '@salesforce/label/c.Message_NoFieldAvailable';
import labelMappingHelp from '@salesforce/label/c.URL_MappingHelp';
import labelGeneralInformation from '@salesforce/label/c.Label_GeneralInformation';
import labelMappingToggle from '@salesforce/label/c.Label_Mapping_Toggle';
import labelOff from '@salesforce/label/c.Label_Off';
import labelOn from '@salesforce/label/c.Label_On';
import messageMappingNameMissing from '@salesforce/label/c.Message_MappingNameMissing';
import placeholderUntitledMapping from '@salesforce/label/c.Placeholder_UntitledMapping';
import messageInvalidValuesAssociated from '@salesforce/label/c.Message_InvalidValuesAssociated';
import messageMultiLevelFieldNotAllowed from
    '@salesforce/label/c.Message_MultiLevelFieldNotAllowed';
import labelDataSourceObject from
    '@salesforce/label/c.Label_DataSourceObject';
import messageHeaderRecordSelectionEnable from
    '@salesforce/label/c.Message_HeaderRecordSelectionEnable';
import messageDataSourceObjectSelection from
    '@salesforce/label/c.Message_DataSourceObjectSelection';
import errorDuplicateDeveloperName from
    '@salesforce/label/c.Error_DuplicateMappingDeveloperName';
import errorLiteralParameterSelection
    from '@salesforce/label/c.Error_LiteralParameterSelection';
import messageConfigureHeaderObject
    from '@salesforce/label/c.Message_ConfigureHeaderObject';
import messageFieldValidationInMapping
    from '@salesforce/label/c.Message_FieldValidationInMapping';
import messageCurrentRecordHeaderNotExist
    from '@salesforce/label/c.Message_CurrentRecordHeaderNotExist';
import messageCurrentRecordHeaderNotExistDetail
    from '@salesforce/label/c.Message_CurrentRecordHeaderNotExistDetail';
import messageValidatingConfiguration
    from '@salesforce/label/c.Message_ValidatingConfiguration';
import messageMappingErrorMessage
    from '@salesforce/label/c.Message_MappingErrorMessage';
import labelWhereUsed from '@salesforce/label/c.Label_WhereUsed';

const i18n = {
    pageHeader: labelMappingTitle,
    cancel: labelCancel,
    help: labelHelp,
    save: labelSave,
    edit: labelEditMenuItem,
    formValidation: labelFormValidation,
    title: labelMappingName,
    developerName: labelDeveloperName,
    description: labelDescription,
    titlePlaceholder: placeholderUntitledMapping,
    toggleActive: labelOn,
    toggleInactive: labelOff,
    toggleLabel: labelMappingToggle,
    clear: labelClear,
    searchPlaceholder: labelSearchPlaceholder,
    clearAll: labelClearAll,
    refreshMetadata: labelRefreshMetadata,
    select: labelSelect,
    titleMissing: messageMappingNameMissing,
    invalidValuesAssociated: messageInvalidValuesAssociated,
    multiLevelFieldNotAllowed: messageMultiLevelFieldNotAllowed,
    enterValueMissing: labelEnterValue,
    developerNameMissing: labelEnterDeveloperName,
    copyOf: labelCopyOf,
    wasSaved: labelWasSaved,
    continue: labelYesContinue,
    goBack: labelNoGoBack,
    savingMappingRecords: labelSavingMappingRecords,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    targetObject: labelTargetObject,
    sourceObject: labelSourceObject,
    mapping: labelMapping,
    noMatchingFieldAvailable: labelNoMatchingFieldAvailable,
    mappingHelpLink: labelMappingHelp,
    generalInfoSection: labelGeneralInformation,
    dataSourceObject: labelDataSourceObject,
    headerRecordSelectionEnable: messageHeaderRecordSelectionEnable,
    dataSourceObjectSelection: messageDataSourceObjectSelection,
    duplicateDeveloperName: errorDuplicateDeveloperName,
    literalParameterSelection: errorLiteralParameterSelection,
    configureHeaderObject: messageConfigureHeaderObject,
    fieldValidationInMapping: messageFieldValidationInMapping,
    currentRecordHeaderNotExist: messageCurrentRecordHeaderNotExist,
    currentRecordHeaderNotExistDetail: messageCurrentRecordHeaderNotExistDetail,
    validatingConfiguration: messageValidatingConfiguration,
    mappingErrorMessage: messageMappingErrorMessage,
    whereUsed: labelWhereUsed
};

const CLONE_NAME_PREFIX = i18n.copyOf;

const FIELD_MAPPING_TYPE = 'Field';
const FUNCTION_MAPPING_TYPE = 'Function';
const NO_SUCH_COLUMN = 'No such column';
const NO_FIELD_ACCESS = 'Insufficient permissions:';

const MAPPING_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__mappingDetail'
    }
};

export default class MappingAdminDetail extends NavigationMixin(LightningElement) {
    mappingType;
    sourceObjectApiName;
    targetObjectApiName;
    searchInputValue;

    currentPageReference;
    currentNavItem;

    @track error;
    @track cancelModalDialogOpen;
    @track viewModel = new ObjectMappingViewModel(null, null, null, null);
    apiInProgress = false;
    @track filteredObjectMappingDetails = [];
    @track clearStateNeeded = false;
    literalObjectAPIName;
    literalObjectLabel;
    exceptionMessage;
    isErrorMessage = false;
    @track recordHeaderOptions = [];
    @track entityOptions = [];
    entityLabelApiName = new Map();
    @track entityFieldLabels = {};
    @track entityFieldDefinitions = {};
    @track headerObjectError;
    @track headerObjectAPIName;

    @track moduleType = '';
    @track configurationId = '';
    @track configDeveloperName = '';
    @track configType = '';
    @track configName = '';
    @track operationType = '';
    @track whereUsedModalDialogOpen = false;
    @track entitiesWithFields = {};

    objectFieldDefinitions = {
        sourceEntity: null,
        targetEntity: null,
        userEntity: null
    };

    _recordId;
    _actionName;

    get i18n () {
        return i18n;
    }

    get developerNameEditable () {
        return (
            this.actionName === PAGE_ACTION_TYPES.CLONE
            || this.actionName === PAGE_ACTION_TYPES.NEW
        );
    }

    get isNew () {
        return this.actionName === PAGE_ACTION_TYPES.NEW ||
            this.actionName === PAGE_ACTION_TYPES.CLONE;
    }

    get timeZoneForGmt () {
        return TIMEZONE_GMT;
    }

    get isDirty () {
        return (this.viewModel) ? this.viewModel.isDirty : false;
    }

    get headerSelectionTooltip () {
        return !this.viewModel.headerObjectAPIName;
    }

    get headerObjectEditable () {
        let isCurrentRecordHeaderDetailAvailable = true;
        let count = 0;
        this.viewModel.objectMappingDetails.forEach ( entity => {
            if (entity.value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
                count++;
            }
        });
        if (count > 0 && this.viewModel.headerObjectAPIName) {
            isCurrentRecordHeaderDetailAvailable = false;
        }
        return isCurrentRecordHeaderDetailAvailable;
    }

    get userLabel () {
        return this.userInfo?.data?.label;
    }

    errorCallback (error) {
        this.error = parseErrorMessage(error);
    }

    renderedCallback () {
        if (this.clearStateNeeded) {
            this.clearStateNeeded = false;
        }
    }

    @api
    get actionName () {
        return this._actionName;
    }
    set actionName (value) {
        this._actionName = value;
    }

    @api
    get recordId () {
        return this._recordId;
    }

    set recordId (value) {
        this._recordId = value;
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    @wire(getObjectInfo, { objectApiName: USER_OBJECT })
    userInfo;

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef && pageRef.state) {
            this.clearState();

            if (pageRef.state.c__recordId) {
                this._recordId = pageRef.state.c__recordId;
            }

            if (pageRef.state.c__actionName) {
                this._actionName = pageRef.state.c__actionName.toLowerCase();
            }

            if (pageRef.state.c__mappingType) {
                this.mappingType = pageRef.state.c__mappingType;
            }

            if (pageRef.state.c__source) {
                this.sourceObjectApiName = pageRef.state.c__source;
            }

            if (pageRef.state.c__target) {
                this.targetObjectApiName = pageRef.state.c__target;
            }

            if (pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.loadView();
        }
    }

    async loadView () {

        this.apiInProgress = true;
        this.headerObjectError = null;
        this.error = null;
        //fetching all entity details to find Current Record Header Object exist in Org.
        const resp = await getEntityDefinitions();
        if (resp && resp.data) {
            this.entityOptions = resp.data.map(entity => {
                return {
                    label: entity.label,
                    value: entity.apiName,
                    secondary: entity.apiName
                };
            });
            this.entityOptions.forEach(entity => {
                this.entityLabelApiName.set(entity.value,entity.label);
            });
            switch (this.actionName) {
                case PAGE_ACTION_TYPES.EDIT:
                case PAGE_ACTION_TYPES.CLONE:
                    this.getExistingRecordDetails();
                    break;
                default:
                    this.getNewRecordDetails();
                    break;
            }
        }
    }

    clearState () {
        this.error = null;
        this._recordId = null;
        this._actionName = null;
        this.mappingType = null;
        this.sourceObjectApiName = null;
        this.targetObjectApiName = null;
        this.viewModel = new ObjectMappingViewModel(null, null, null, null);
        this.filteredObjectMappingDetails = [];
        this.searchInputValue = null;
        this.clearStateNeeded = true;
    }

    getNewRecordDetails () {
        this.getObjectFields(this.sourceObjectApiName, this.targetObjectApiName)
            .then(entitiesWithFields => {
                this.entitiesWithFields = entitiesWithFields;
                this.populateViewModel(null, entitiesWithFields);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    getExistingRecordDetails () {
        getObjectMappingDetails({ requestJson: JSON.stringify({ id: this.recordId }) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    this.apiInProgress = false;
                    return;
                }

                const data = result.data;
                const recentlyViewedRecord = {
                    configurationId: data.id,
                    configurationName: data.name,
                    configurationDeveloperName: data.developerName,
                    configurationType: ADMIN_MODULES.MAPPING
                };
                saveRecentViewItem(recentlyViewedRecord)
                    .then(recentItem => {
                        if (!verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
                this.headerObjectAPIName = this.entityLabelApiName.has(data.headerRecordObject)?
                    data.headerRecordObject : null;
                if (data.headerRecordObject) {
                    this.getTargetObjectFields(data.targetObjectAPIName)
                        .then(headerEntityWithFields => {
                            this.getAllEntities(headerEntityWithFields)
                                .then(recordOptions => {
                                    if (data.headerRecordObject &&
                                    (!this.entityLabelApiName.has(data.headerRecordObject) ||
                                    !recordOptions.includes(data.headerRecordObject))) {
                                        this.headerObjectError = i18n.currentRecordHeaderNotExist +
                                                            ' ' + data.headerRecordObject + ' ' +
                                                            i18n.currentRecordHeaderNotExistDetail;
                                        this.headerObjectAPIName = null;
                                        //if Current Record Header Object doesn't exist and their 
                                        //respective  mapping details are invalid, so adding error 
                                        //icon.
                                        data.objectMappingDetails.forEach(detail => {
                                            if (detail.value ===
                                                    FUNCTION_LITERALS.CURRENTRECORDHEADER) {
                                                detail.hasError = true;
                                            }
                                        });
                                    }
                                    if (data.message && ((data.message).includes(NO_SUCH_COLUMN) ||
                                    (data.message).includes(NO_FIELD_ACCESS))) {
                                        this.exceptionMessage = i18n.validatingConfiguration;
                                        this.isErrorMessage = true;
                                        this.getValidateRecordDetails(data);

                                    } else {
                                        this.getObjectFields(data.sourceObjectAPIName,
                                            data.targetObjectAPIName, this.headerObjectAPIName )
                                            .then(entitiesWithFields => {
                                                this.entitiesWithFields = entitiesWithFields;
                                                this.populateViewModel(data, entitiesWithFields);
                                                this.populateReferenceFieldLabels(
                                                    entitiesWithFields);
                                                this.currentRecordHeaderValidations();
                                            });
                                    }

                                });
                        });
                } else {
                    if (data.message && ((data.message).includes(NO_SUCH_COLUMN) ||
                    (data.message).includes(NO_FIELD_ACCESS))) {
                        this.exceptionMessage = i18n.validatingConfiguration;
                        this.isErrorMessage = true;
                        this.getValidateRecordDetails(data);

                    } else {
                        this.getObjectFields(data.sourceObjectAPIName, data.targetObjectAPIName,
                            this.headerObjectAPIName )
                            .then(entitiesWithFields => {
                                this.entitiesWithFields = entitiesWithFields;
                                this.populateViewModel(data, entitiesWithFields);
                                this.populateReferenceFieldLabels(entitiesWithFields);
                                this.currentRecordHeaderValidations();
                            });
                    }
                }

            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    getValidateRecordDetails ( objectMapping ) {
        validateObjectMappingDetails({ requestJson: JSON.stringify( objectMapping ) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    this.apiInProgress = false;
                    return;
                }
                if (objectMapping.message && ((objectMapping.message).includes(NO_SUCH_COLUMN) ||
                (objectMapping.message).includes(NO_FIELD_ACCESS))) {
                    this.error = i18n.fieldValidationInMapping;
                }
                const data = result.data;
                this.getObjectFields(data.sourceObjectAPIName, data.targetObjectAPIName,
                    this.headerObjectAPIName)
                    .then(entitiesWithFields => {
                        const developerName = data.developerName;
                        const name = data.name;
                        this.entitiesWithFields = entitiesWithFields;
                        this.populateViewModel(data, entitiesWithFields);
                        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
                            this.viewModel.developerName = developerName;
                            this.viewModel.name = name;
                        }
                        this.populateReferenceFieldLabels(entitiesWithFields);
                        this.currentRecordHeaderValidations();
                    });
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    getValidateRecordDetailsBeforeSave ( objectMapping ) {
        validateObjectMappingDetails({ requestJson: JSON.stringify( objectMapping ) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    this.apiInProgress = false;
                    return;
                }
                const data = result.data;
                if (data.message) {
                    this.error = i18n.fieldValidationInMapping;
                    this.isErrorMessage = false;
                    this.exceptionMessage = null;
                    this.getObjectFields(data.sourceObjectAPIName, data.targetObjectAPIName,
                        this.headerObjectAPIName)
                        .then(entitiesWithFields => {
                            const developerName = data.developerName;
                            const name = data.name;
                            this.entitiesWithFields = entitiesWithFields;
                            this.populateViewModel(data, entitiesWithFields);
                            if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
                                this.viewModel.developerName = developerName;
                                this.viewModel.name = name;
                            }
                            this.populateReferenceFieldLabels(entitiesWithFields);
                            this.currentRecordHeaderValidations();
                            this.apiInProgress = false;
                        });
                } else {
                    this.isErrorMessage = false;
                    this.exceptionMessage = null;
                    this.saveAfterValidations(objectMapping);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    populateViewModel (details, entityDefinitionsWithFields) {
        this.sourceAndTargetEntityDefinitions = entityDefinitionsWithFields;
        this.viewModel = new ObjectMappingViewModel(
            details,
            entityDefinitionsWithFields,
            this.mappingType,
            this.userLabel
        );

        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
            this.viewModel.markAsClone(CLONE_NAME_PREFIX);
        }

        this.getMappingToggle().checked = (this.actionName === PAGE_ACTION_TYPES.NEW);
        this.setFilterMappingDetails();
        this.exceptionMessage = '';
        this.isErrorMessage = false;
    }


    getMappingToggle () {
        return this.template.querySelector(".mappingToggle");
    }

    getDeveloperNameInput () {
        return this.template.querySelector('[data-field="developerName"]');
    }

    async getObjectFields (source, target, header) {
        const entities = []
        const result = {
            sourceEntity: null,
            targetEntity: null,
            userEntity: null,
            headerEntity: null
        };

        if (source) {
            entities.push(source);
        }

        if (source !== target && target != null) {
            entities.push(target);
        }

        if (header && !entities.includes(header)) {
            entities.push(header);
        }
        entities.push(FUNCTION_LITERALS.USER);

        if (entities.length === 0) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntities(entities);

            if (resp && resp.data) {
                if (source) {
                    result.sourceEntity = resp.data.find(element => element.apiName === source);
                    this.objectFieldDefinitions.sourceEntity = result.sourceEntity;
                }

                if (target) {
                    result.targetEntity = resp.data.find(element => element.apiName === target);
                    this.objectFieldDefinitions.targetEntity = result.targetEntity;
                    this.getAllEntities(this.objectFieldDefinitions.targetEntity);
                }
                if (header) {
                    result.headerEntity = resp.data.find(element => element.apiName === header);
                    this.objectFieldDefinitions.headerEntity = result.headerEntity;
                }
                result.userEntity = resp.data.find(element =>
                    element.apiName === FUNCTION_LITERALS.USER);
                this.objectFieldDefinitions.userEntity = result.userEntity;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

        return result;
    }

    async getheaderObjectFields (header) {
        this.apiInProgress = true;
        const entities = [];
        let headerEntity;

        if (header) {
            entities.push(header);
        }

        if (entities.length === 0) {
            this.apiInProgress = false;
            return null;
        }

        try {
            const resp = await getFieldDefinitionsForEntities(entities);

            if (resp && resp.data) {

                if (header) {
                    headerEntity = resp.data.find(element => element.apiName === header);
                    this.viewModel.headerObjectLabel = headerEntity.label;
                    this.setFilterMappingDetails();
                }
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
        this.apiInProgress = false;
        return headerEntity;
    }

    async getTargetObjectFields (target) {
        const entities = [];
        let targetEntity;

        if (target) {
            entities.push(target);
        }
        if (entities.length === 0) {
            return null;
        }

        try {
            const resp = await getFieldDefinitionsForEntities(entities);

            if (resp && resp.data) {

                if (target) {
                    targetEntity = resp.data.find(element => element.apiName === target);
                }
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
        return targetEntity;
    }

    handleRowSelection (event) {
        const rowKey = event.currentTarget.getAttribute('data-row-key');
        // disabling tooltip if row is selected when tooltip is enabled
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey)
        objectMappingRecord.showTooltip = false;
        objectMappingRecord.showTooltipForLiteral = false;
        objectMappingRecord.showHeaderSelectionTooltip = false;

        const viewItem = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        );

        // Check if row is already in edit mode.
        if (viewItem.editMode) {
            return;
        }

        if (!this.verifyMappingRowsAreValid()) {
            event.preventDefault();
            return;
        }

        // eslint-disable-next-line no-return-assign
        this.viewModel.objectMappingDetails.forEach(item => item.editMode = false);

        viewItem.editMode = true;

        this.setFilterMappingDetails();
    }

    verifyMappingRowsAreValid () {
        const editFields = this.template.querySelectorAll('[data-line-field]');

        if (editFields) {
            return [...editFields].every(field => field.reportValidity() === true);
        }

        return true;
    }

    handleHelpClick () {
        window.open(i18n.mappingHelpLink, '_blank');
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.searchInputValue = searchKey;
                this.setFilterMappingDetails();
            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    handleNameBlur () {
        if (this.developerNameEditable && !this.viewModel.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.viewModel.developerName =
                normalizeDeveloperName(this.viewModel.name, maxLength, '');
            this.getDeveloperNameInput().value = this.viewModel.developerName;
        }
    }

    handleMappingInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.viewModel[event.currentTarget.dataset.field] = inputVal;
    }

    handleMappingTypeChange (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        const mappingType = event.detail.value;

        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        );

        objectMappingRecord.mappingType = mappingType;
        objectMappingRecord.referenceFieldLabel = '';

        if (objectMappingRecord.mappingType === MAPPING_TYPE.FIELD) {
            objectMappingRecord.showRelatedPicklist = true;
        }

        this.setFilterMappingDetails();
    }

    handleFunctionChange (event) {
        const rowKey = event.target.getAttribute('data-row-key');

        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey);
        objectMappingRecord.value = event.detail.value;
        objectMappingRecord.referenceFieldLabel = '';

        if ( event.detail.value === FUNCTION_LITERALS.USER ||
            event.detail.value === FUNCTION_LITERALS.CURRENTRECORD ||
            event.detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER ) {
            if ( objectMappingRecord.value === FUNCTION_LITERALS.USER) {
                this.literalObjectAPIName = this.viewModel.userObjectAPIName;
                this.literalObjectLabel = this.viewModel.userObjectLabel;
                objectMappingRecord.showRelatedPicklistForLiteral = true;
            } else if ( objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORD ) {
                this.literalObjectAPIName = this.viewModel.targetObjectAPIName;
                this.literalObjectLabel = this.viewModel.targetObjectLabel;
                objectMappingRecord.showRelatedPicklistForLiteral = true;
            } else if ( objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORDHEADER ) {
                this.literalObjectAPIName = this.viewModel.headerObjectAPIName;
                this.literalObjectLabel = this.viewModel.headerObjectLabel;
                if (this.literalObjectAPIName && this.literalObjectLabel) {
                    objectMappingRecord.showRelatedPicklistForLiteral = true;
                }
            }
        }

        this.setFilterMappingDetails();
    }

    handleFieldChange (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey);

        if (!objectMappingRecord.isTargetFieldDeleted) {
            objectMappingRecord.showRelatedPicklist = true;
        }
        this.setFilterMappingDetails();
    }

    handleRecordHeaderChange (event) {

        this.viewModel.headerObjectAPIName = event.detail.value;
        this.headerObjectAPIName = event.detail.value;
        this.viewModel.headerObjectLabel =
            this.getheaderObjectFields(this.viewModel.headerObjectAPIName).label;
        if (this.viewModel.headerObjectAPIName) {
            this.headerObjectError = null;
        }
        this.setFilterMappingDetails();
    }

    handleLiteralChange (event) {
        const rowKey = event.target.getAttribute('data-row-key');

        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        )

        if (!objectMappingRecord.isTargetFieldDeleted) {
            if ( objectMappingRecord.value === FUNCTION_LITERALS.USER) {
                this.literalObjectAPIName = this.viewModel.userObjectAPIName;
                this.literalObjectLabel = this.viewModel.userObjectLabel;
                objectMappingRecord.showRelatedPicklistForLiteral = true;
            } else if ( objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORD ) {
                this.literalObjectAPIName = this.viewModel.targetObjectAPIName;
                this.literalObjectLabel = this.viewModel.targetObjectLabel;
                objectMappingRecord.showRelatedPicklistForLiteral = true;
            } else if ( objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORDHEADER ) {
                this.literalObjectAPIName = this.viewModel.headerObjectAPIName;
                this.literalObjectLabel = this.viewModel.headerObjectLabel;
                if (this.literalObjectAPIName && this.literalObjectLabel) {
                    objectMappingRecord.showRelatedPicklistForLiteral = true;
                }
            }
        }
        this.setFilterMappingDetails();
    }

    handleMouseOverForLiteral (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey);
        objectMappingRecord.showTooltipForLiteral = true;
        if ( objectMappingRecord.value === FUNCTION_LITERALS.USER ||
            objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORD ||
            objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
            objectMappingRecord.literalTooltip = objectMappingRecord.referenceFieldLabel;
        }
        this.setFilterMappingDetails();

    }

    handleCurrentHeaderLiteralMouseOver ( event ) {

        const rowKey = event.target.getAttribute('data-row-key');
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey);
        objectMappingRecord.showHeaderSelectionTooltip = true;
        this.setFilterMappingDetails();

    }

    handleCurrentHeaderLiteralMouseOut (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        ).showHeaderSelectionTooltip = false;
        this.setFilterMappingDetails();

    }

    handleTargetFieldErrorMouseOver ( event ) {

        const rowKey = event.target.getAttribute('data-row-key');
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey);
        objectMappingRecord.showTargetFieldErrorTooltip = true;
        this.setFilterMappingDetails();

    }

    handleTargetFieldErrorMouseOut (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        ).showTargetFieldErrorTooltip = false;
        this.setFilterMappingDetails();

    }

    handleMouseOutForLiteral (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        ).showTooltipForLiteral = false;
        this.setFilterMappingDetails();

    }

    handleMouseOver (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey)
        objectMappingRecord.showTooltip = true;

        if (objectMappingRecord.isFieldMappingType) {
            objectMappingRecord.tooltip = objectMappingRecord.referenceFieldLabel;
        } else if (objectMappingRecord.isValueMappingType) {
            objectMappingRecord.tooltip = objectMappingRecord.valueLabel;
        }
        this.setFilterMappingDetails();

    }

    handleMouseOut (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        ).showTooltip = false;
        this.setFilterMappingDetails();

    }

    handleValueChange (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        const newValue = (event && event.target) ? event.target.value : null;

        const detailItem = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        );

        detailItem.value = (typeof newValue === 'string') ? newValue.trim() : newValue;

        this.setFilterMappingDetails();
    }

    handleClearAll () {
        this.viewModel.clearAllDetailMappings();
        this.getMappingToggle().checked = true;
        this.setFilterMappingDetails();
    }

    handleClearDetail (event) {
        const rowKey = event.target.getAttribute('data-row-key');
        this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        ).reset();

        this.setFilterMappingDetails();
    }

    checkWhereUsed (operationType) {
        this.moduleType = 'Mapping';
        this.configurationId = this.viewModel.id;
        this.configDeveloperName = this.viewModel.developerName;
        this.configType = this.viewModel.mappingType;
        this.configName = this.viewModel.name;
        this.operationType = operationType;
        this.whereUsedModalDialogOpen = true;
    }

    handleWhereUsed () {
        this.checkWhereUsed('whereused');
    }

    handleSave () {
        if (this.actionName === PAGE_ACTION_TYPES.EDIT) {
            this.checkWhereUsed('update');
        } else {
            this.handleWhereUsedSave();
        }
    }

    handleWhereUsedSave () {
        this.whereUsedModalDialogOpen = false;
        this.headerObjectError = null;
        // Validate input
        const allValid = [...this.template.querySelectorAll('[data-field]')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        const allRowsValid = this.verifyMappingRowsAreValid();

        if (!allValid || !allRowsValid) {
            this.error = this.i18n.formValidation;
            return;
        }

        this.currentRecordHeaderValidations();
        if (this.headerObjectError) {
            return;
        }
        const invalidValueTypeRows =
            this.viewModel.validateObjectMappingDetails(this.entitiesWithFields);
        if (invalidValueTypeRows === 0) {
            const recordToSave = this.viewModel.getRecordData();

            recordToSave.objectMappingDetails.forEach(detailItem => {
                if (detailItem.value && detailItem.targetFieldAPIName === 'RecordTypeId' &&
                    detailItem.mappingType === 'Value' && isSalesforceId(detailItem.value)) {
                    detailItem.value = this.formatReference(detailItem.value);
                }
            });
            this.error = null;
            this.apiInProgress = true;

            this.exceptionMessage = i18n.validatingConfiguration;
            this.isErrorMessage = true;
            this.getValidateRecordDetailsBeforeSave(recordToSave);
        } else {
            this.error = this.i18n.invalidValuesAssociated;
        }
    }

    showSaveSuccessNotification (mappingName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.mapping} "${mappingName}" ${this.i18n.wasSaved}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleCancelEdit () {
        if (this.isDirty) {
            this.cancelModalDialogOpen = true;
        } else {
            this.clearState();
            this.navigateToListView();
        }
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;

        this.clearState();
        this.navigateToListView();
    }

    handleCancelDeleteModal () {
        this.whereUsedModalDialogOpen = false;
        this.deleteModalDialogOpen = false;
    }

    handleMappingToggle () {
        this.setFilterMappingDetails();
    }

    filterMappingDetails (showMapped, searchValue) {
        if (!this.viewModel.objectMappingDetails
            || this.viewModel.objectMappingDetails.length === 0) {
            return;
        }

        this.filteredObjectMappingDetails = this.viewModel.objectMappingDetails.filter(item => {
            if (showMapped && searchValue) {
                return (item.isMapped && item.isTargetFieldNameMatch(searchValue));
            } else if (showMapped) {
                return item.isMapped;
            } else if (searchValue) {
                return item.isTargetFieldNameMatch(searchValue);
            }

            return true;
        });
    }

    setFilterMappingDetails () {
        this.filterMappingDetails(!this.getMappingToggle().checked, this.searchInputValue);
    }

    navigateToListView () {
        handleMenuSelection({
            detail: {
                name: "mapping_rules",
                targetType: "LWC",
                targetDeveloperName: "c-mapping-admin-list-view"
            }
        }, this);
    }

    navigateToDetailComponent (recordId, actionName) {
        const navState = {
            c__actionName: actionName,
            c__recordId: recordId
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, MAPPING_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    handleRelatedPicklistSelected (event) {

        const rowKey = event.target.getAttribute('data-row-key');
        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey)

        if (objectMappingRecord.value === FUNCTION_LITERALS.USER ||
            objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORD ||
            objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
            objectMappingRecord.literalParameterAPIName = event.detail.valueSelected;
            objectMappingRecord.showRelatedPicklistForLiteral = false;
        } else {
            objectMappingRecord.sourceFieldAPIName = event.detail.valueSelected;
            objectMappingRecord.showRelatedPicklist = false;
        }
        objectMappingRecord.relatedObjectDetails = event.detail.objectSelected;
        objectMappingRecord.referenceFieldLabel = event.detail.label;

        if (!event.detail.valueSelected) {
            objectMappingRecord.mappingType = '';
        }

        this.setFilterMappingDetails();
    }

    handleCancelRelatedPicklist (event) {

        const rowKey = event.target.getAttribute('data-row-key');

        const objectMappingRecord = this.viewModel.objectMappingDetails.find(item =>
            item.targetFieldAPIName === rowKey
        )

        if (objectMappingRecord.value === FUNCTION_LITERALS.USER ||
            objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORD ||
            objectMappingRecord.value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
            objectMappingRecord.literalParameterAPIName = event.detail.valueSelected;
            objectMappingRecord.showRelatedPicklistForLiteral = false;
        } else {
            objectMappingRecord.sourceFieldAPIName = event.detail.valueSelected;
            objectMappingRecord.showRelatedPicklist = false;
        }
        objectMappingRecord.relatedObjectDetails = event.detail.objectSelected;
        objectMappingRecord.referenceFieldLabel = event.detail.label;

        if (!event.detail.valueSelected) {
            objectMappingRecord.mappingType = '';
        }

        this.setFilterMappingDetails();

    }

    async getAllEntities (headerEntity) {
        const referenceFields = [];
        try {
            const options = [];
            const objectNames = new Set();
            if (headerEntity) {
                headerEntity.fieldDefinitions.forEach(entity => {
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
                    referenceFields.push(entity);
                }
            });
            this.recordHeaderOptions = [...options];
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
        return referenceFields;
    }

    populateReferenceFieldLabels ( entityDefinitionsWithFields ) {
        let objectAPINames = new Set();
        if (this.viewModel.objectMappingDetails) {
            objectAPINames =
                this.getMappingRelatedObjectdetails(this.viewModel.objectMappingDetails);
        }
        if (objectAPINames && objectAPINames.size > 0) {
            if (objectAPINames.has(this.sourceObjectAPIName)) {
                objectAPINames.delete(this.sourceObjectAPIName);
            }
            if (objectAPINames.has(this.targetObjectAPIName)) {
                objectAPINames.delete(this.targetObjectAPIName);
            }
            if (objectAPINames.has(this.viewModel.headerObjectAPIName)) {
                objectAPINames.delete(this.headerObjectAPIName);
            }
            if (objectAPINames.has(this.userObjectAPIName)) {
                objectAPINames.delete(this.userObjectAPIName);
            }
            this.fetchObjectFields(Array.from(objectAPINames)) //fetch object field definitions
                .then(result => {
                    Array.from(result).forEach( item => {
                        const fieldDetails = {};
                        const fieldLabels = {};
                        item.fieldDefinitions.forEach ( entity => {
                            fieldLabels[entity.apiName] = entity.label;
                            fieldDetails[entity.apiName] = entity;
                        });
                        this.entityFieldLabels[item.apiName] = fieldLabels;
                        this.entityFieldDefinitions[item.apiName] = fieldDetails;
                    });
                    if (entityDefinitionsWithFields && Object.values(entityDefinitionsWithFields)) {
                        Object.values(entityDefinitionsWithFields).forEach( item => {
                            const fieldDetails = {};
                            const fieldLabels = {};
                            if (item && item.fieldDefinitions) {
                                item.fieldDefinitions.forEach ( entity => {
                                    fieldLabels[entity.apiName] = entity.label;
                                    fieldDetails[entity.apiName] = entity;
                                });
                                this.entityFieldLabels[item.apiName] = fieldLabels;
                                this.entityFieldDefinitions[item.apiName] = fieldDetails;
                            }
                        });
                    }
                    this.viewModel.objectMappingDetails.forEach(detail => {
                        if (detail.mappingType === FIELD_MAPPING_TYPE) {
                            if (detail.relatedObjectDetails) {
                                detail.referenceFieldLabel = detail.sourceObjectLabel + ': ' +
                                this.getReferenceFieldLabel(detail.relatedObjectDetails,
                                    detail.sourceFieldAPIName, detail.sourceObjectAPIName);
                            } else {
                                detail.referenceFieldLabel = detail.sourceObjectLabel + ': ' +
                                this.getLiteralLabelFromFieldList(detail.value,
                                    detail.sourceFieldAPIName, detail.mappingType);
                            }
                        } else if (detail.mappingType === FUNCTION_MAPPING_TYPE &&
                            detail.value === FUNCTION_LITERALS.USER) {
                            if (detail.relatedObjectDetails) {
                                detail.referenceFieldLabel = this.userLabel + ': ' +
                                this.getReferenceFieldLabel(detail.relatedObjectDetails,
                                    detail.literalParameterAPIName, 'User');
                            } else {
                                detail.referenceFieldLabel = this.userLabel + ': ' +
                                this.getLiteralLabelFromFieldList(detail.value,
                                    detail.literalParameterAPIName, detail.mappingType);
                            }
                        } else if (detail.mappingType === FUNCTION_MAPPING_TYPE &&
                            detail.value === FUNCTION_LITERALS.CURRENTRECORD) {
                            if (detail.relatedObjectDetails) {
                                detail.referenceFieldLabel = detail.targetObjectLabel + ': ' +
                                this.getReferenceFieldLabel(detail.relatedObjectDetails,
                                    detail.literalParameterAPIName, detail.targetObjectAPIName);
                            } else {
                                detail._referenceFieldLabel = detail.targetObjectLabel + ': ' +
                                this.getLiteralLabelFromFieldList(detail.value,
                                    detail.literalParameterAPIName, detail.mappingType);
                            }
                        } else if (detail.mappingType === FUNCTION_MAPPING_TYPE &&
                            detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
                            if (detail.relatedObjectDetails) {
                                detail.referenceFieldLabel = detail.headerObjectLabel + ': ' +
                                this.getReferenceFieldLabel(detail.relatedObjectDetails,
                                    detail.literalParameterAPIName, detail.headerObjectAPIName);
                            } else {
                                detail.referenceFieldLabel = detail.headerObjectLabel + ': ' +
                                this.getLiteralLabelFromFieldList(detail.value,
                                    detail.literalParameterAPIName, detail.mappingType);
                            }
                        }
                    });
                    this.setFilterMappingDetails();
                    this.apiInProgress = false;
                });
        }
        else if (this.viewModel.objectMappingDetails) {
            this.viewModel.objectMappingDetails.forEach(detail => {
                if (detail.mappingType === FIELD_MAPPING_TYPE) {
                    detail.referenceFieldLabel = detail.sourceObjectLabel + ': ' +
                    this.getLiteralLabelFromFieldList(detail._value, detail._sourceFieldAPIName,
                        detail.mappingType);
                } else if (detail.mappingType === FUNCTION_MAPPING_TYPE &&
                    detail.value === FUNCTION_LITERALS.USER) {
                    detail.referenceFieldLabel = 'User: ' +
                    this.getLiteralLabelFromFieldList(detail._value,
                        detail._literalParameterAPIName, detail.mappingType);
                } else if (detail.mappingType === FUNCTION_MAPPING_TYPE &&
                    detail.value === FUNCTION_LITERALS.CURRENTRECORD) {
                    detail.referenceFieldLabel = detail.targetObjectLabel + ': ' +
                    this.getLiteralLabelFromFieldList(detail.value, detail.literalParameterAPIName,
                        detail.mappingType);
                } else if (detail.mappingType === FUNCTION_MAPPING_TYPE &&
                    detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
                    detail.referenceFieldLabel = detail.headerObjectLabel + ': ' +
                    this.getLiteralLabelFromFieldList(detail.value, detail.literalParameterAPIName,
                        detail.mappingType);
                }
            });
            this.setFilterMappingDetails();
            this.apiInProgress = false;
        }
        return this.objectMappingDetails;

    }

    getMappingRelatedObjectdetails ( objectMappingDetails ) {
        const objectDetails = new Set();
        objectMappingDetails.forEach ( detail => {
            if (detail.relatedObjectDetails &&
                detail.relatedObjectDetails.includes('.')) {
                const objDetails = new Set(detail.relatedObjectDetails.split('.'));
                objDetails.forEach(elem => objectDetails.add(elem));
            } else if (detail.relatedObjectDetails) {
                objectDetails.add(detail.relatedObjectDetails);
            }
        });
        return objectDetails;
    }

    async fetchObjectFields (objectNames) {
        let result = {};
        if (objectNames.length <= 0) {
            return result;
        }
        const objectApiNameList = [...objectNames];
        try {
            const resp = await getFieldDefinitionsForEntities(objectApiNameList);
            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
        return result;
    }

    getReferenceFieldLabel (relatedObjectDetails, fieldAPIName, objectApiName) {
        let labelObjectAPINames = [];
        let fieldAPINames = [];
        let referenceFieldLabel = '';
        if (fieldAPIName && objectApiName) {
            labelObjectAPINames.push(objectApiName);
            if (relatedObjectDetails && relatedObjectDetails.includes('.')) {
                labelObjectAPINames = labelObjectAPINames.concat(relatedObjectDetails.split('.'));
            } else if (relatedObjectDetails) {
                labelObjectAPINames.push(relatedObjectDetails);
            }
            if (fieldAPIName && fieldAPIName.includes('.')) {
                fieldAPINames = fieldAPIName.split('.');
            } else if (fieldAPIName) {
                fieldAPINames.push(fieldAPIName);
            }
            for (let index = 0; index < fieldAPINames.length; index++) {
                let fieldDefinition = {};
                fieldDefinition = this.entityFieldLabels[labelObjectAPINames[index]];
                if ( index !== fieldAPINames.length - 1) {
                    if (fieldAPINames[index].endsWith('__r')) {
                        fieldAPINames[index] = fieldAPINames[index].replace(/__r$/i, '__c');
                    }
                    // Resolve standard field relationship name to field name
                    if (!/__c$/i.test(fieldAPINames[index])) {
                        fieldAPINames[index] += 'Id';
                    }
                    if (fieldDefinition) {
                        referenceFieldLabel += fieldDefinition[fieldAPINames[index]] + ' >  ';
                    } else {
                        referenceFieldLabel +=  'undefined >  ';
                    }
                }
                else {
                    if (fieldDefinition) {
                        referenceFieldLabel += fieldDefinition[fieldAPINames[index]];
                    } else {
                        referenceFieldLabel += 'undefined';
                    }
                }
            }
        }
        if (referenceFieldLabel.includes('undefined') || !referenceFieldLabel) {
            referenceFieldLabel = fieldAPIName;
        }
        return referenceFieldLabel;

    }

    getLiteralLabelFromFieldList (value, apiName, mappingType) {
        let label = '';
        let definition;
        if (mappingType === FIELD_MAPPING_TYPE) {
            if (this.viewModel.sourceFields && this.viewModel.sourceFields.length > 0) {
                definition = this.viewModel.sourceFields.find(field => field.apiName === apiName);
            }
        } else if (mappingType === FUNCTION_MAPPING_TYPE && value === FUNCTION_LITERALS.USER) {
            if (this.viewModel.userFields && this.viewModel.userFields.length > 0) {
                definition = this.viewModel.userFields.find(field => field.apiName === apiName);
            }
        } else if (mappingType === FUNCTION_MAPPING_TYPE &&
            value === FUNCTION_LITERALS.CURRENTRECORD) {
            if (this.viewModel.targetFields && this.viewModel.targetFields.length > 0) {
                definition = this.viewModel.targetFields.find(field => field.apiName === apiName);
            }
        } else if (mappingType === FUNCTION_MAPPING_TYPE &&
            value === FUNCTION_LITERALS.CURRENTRECORDHEADER) {
            if (this.viewModel.headerFields && this.viewModel.headerFields.length > 0) {
                definition = this.viewModel.headerFields.find(field => field.apiName === apiName);
            }
        }
        if (definition) {
            label = definition.label;
        } else {
            label = apiName;
        }
        return label;
    }

    currentRecordHeaderValidations () {
        let isCurrentRecordHeaderConfigured = false;
        let unconfiguredLiteralCount = 0;
        if (!this.headerObjectError || this.headerObjectError === '') {
            this.viewModel.objectMappingDetails.forEach(detail => {
                if ( detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER )  {
                    isCurrentRecordHeaderConfigured = true;
                }
                if ( detail.value === FUNCTION_LITERALS.CURRENTRECORDHEADER &&
                !detail.literalParameterAPIName)  {
                    unconfiguredLiteralCount++;
                }
            });
            if ( isCurrentRecordHeaderConfigured && !this.viewModel.headerObjectAPIName) {
                this.headerObjectError = i18n.configureHeaderObject;
            }

            if ( unconfiguredLiteralCount > 0 ) {
                this.headerObjectError = i18n.literalParameterSelection;
            }
            if ( !isCurrentRecordHeaderConfigured && this.viewModel.headerObjectAPIName) {
                this.headerObjectError = i18n.dataSourceObjectSelection;

            }
        }
    }

    saveAfterValidations (recordToSave) {
        saveObjectMapping({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    if (result.message.includes('duplicate value found:')) {
                        this.error = i18n.duplicateDeveloperName;
                    } else {
                        this.error = result.message;
                    }
                    this.apiInProgress = false;
                    return;
                }
                this.showSaveSuccessNotification(this.viewModel.name);

                if (!this.viewModel.id) {
                    this.navigateToDetailComponent(result.data.id,
                        PAGE_ACTION_TYPES.EDIT);
                } else {
                    const savedData = result.data;
                    this.getObjectFields(savedData.sourceObjectAPIName,
                        savedData.targetObjectAPIName, savedData.headerRecordObject)
                        .then(entitiesWithFields => {
                            this.populateViewModel(result.data, entitiesWithFields);
                            this.populateReferenceFieldLabels(entitiesWithFields);
                        });
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    formatReference (recordTypeId) {
        let developerName = '';
        const recordTypeInfos = this.entitiesWithFields.targetEntity.recordTypeInfos;
        if (recordTypeInfos) {
            const selectedRecordType = recordTypeInfos.find(recordType => {
                return recordType.recordTypeId === recordTypeId;
            })
            developerName = selectedRecordType.developerName;
        }
        return developerName;
    }
}