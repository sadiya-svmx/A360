import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import {
    getFieldDefinitionsForEntities
} from 'c/metadataService';

import {
    parseErrorMessage,
    isEmptyString,
    normalizeDeveloperName,
    deepCopy,
    FIELD_DATA_TYPES,
    FUNCTION_LITERALS,
    populateExpressionDeveloperName
} from 'c/utils';

import { lookupModel } from './lookupModel';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labelObject from '@salesforce/label/c.Label_Object';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelSave from '@salesforce/label/c.Button_Save';
import labelEdit from '@salesforce/label/c.Button_Edit';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelSaveAs from '@salesforce/label/c.Button_SaveAs';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelTitle from '@salesforce/label/c.Label_Title';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelSearchAgainstFields
    from '@salesforce/label/c.Label_Search_Will_Run_Against_Selected_Fields';
import labelSearchAvailableFields
    from '@salesforce/label/c.Placeholder_Search_Available_Fields';
import labelDisplaySelectedFields
    from '@salesforce/label/c.Label_Search_results_will_display_selected_fields';
import labelLookup from '@salesforce/label/c.Label_Lookup';

import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelDeletedSuccessfully from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelSavingRecords from '@salesforce/label/c.AltText_SavingExpression';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelAddSearchFields from '@salesforce/label/c.Label_Add_Search_Fields';
import labelSelectSearchFields from '@salesforce/label/c.Label_Select_Search_Fields';
import labelAddDisplayFields from '@salesforce/label/c.Label_Add_Display_Fields';
import labelSelectDisplayFields from '@salesforce/label/c.Label_Select_Display_Fields';

import labelExpression from '@salesforce/label/c.Label_Expression';

import labelUntitledLookupConfiguration
    from '@salesforce/label/c.Label_UntitledLookupConfiguration';
import labelLookupConfigurationNameMissing
    from '@salesforce/label/c.Message_LookupConfigurationNameMissing';

import labelLookupConfig from '@salesforce/label/c.Label_Lookup_Configuration';
import labelConfigName from '@salesforce/label/c.Label_Configuration_Name';
import labelExpressionName from '@salesforce/label/c.Label_ExpressionName';
import labelLookupEditorHelp from '@salesforce/label/c.URL_LookupEditorHelp';

import labelConditionsAndLogic from '@salesforce/label/c.Label_Conditions_Logic';
import secGeneralInformation from '@salesforce/label/c.Sec_General_Information';
import secSearchFields from '@salesforce/label/c.Sec_Search_Fields';
import secDisplayFields from '@salesforce/label/c.Sec_Display_Fields';
import labelRequired from '@salesforce/label/c.AltText_Required';
import labelNoOfRecordsToReturn from '@salesforce/label/c.Label_No_Of_Records_To_Return';
import labelNoOfRecordsToReturnMissing
    from '@salesforce/label/c.Label_No_Of_Records_To_Return_Missing';
import labelFieldToReturn from '@salesforce/label/c.Label_Field_To_Return';
import labelSelectedFields from '@salesforce/label/c.Label_Selected_Fields';
import labelAvailableFields from '@salesforce/label/c.Label_Available_Fields';
import secConditionAndLogic from '@salesforce/label/c.Label_Conditions_Logic';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelShowMenu from '@salesforce/label/c.AltText_ShowMenu';
import labelUseSearchFields from '@salesforce/label/c.Label_UseSearchFields';
import errorLiteralParameterSelection from
    '@salesforce/label/c.Error_LiteralParameterSelection';

import getLookupConfigDetail
    from '@salesforce/apex/ADM_LookupConfigLightningService.getLookupConfigDetail';
import saveLookupConfig
    from '@salesforce/apex/ADM_LookupConfigLightningService.saveLookupConfig';
import deleteLookupConfig
    from '@salesforce/apex/ADM_LookupConfigLightningService.deleteLookupConfig';
import getExpressionWithDetails
    from '@salesforce/apex/ADM_ExpressionLightningService.getExpressionWithDetails';
import labelDataSourceObject from
    '@salesforce/label/c.Label_DataSourceObject';
import errorDuplicateDeveloperName from
    '@salesforce/label/c.Error_DuplicateLookupDeveloperName';

const i18n = {
    pageHeader: labelLookupConfig,
    cancel: labelCancel,
    help: labelHelp,
    save: labelSave,
    edit: labelEdit,
    select: labelSelect,
    delete: labelDelete,
    confirm: labelConfirm,
    saveAs: labelSaveAs,
    formValidation: labelFormValidation,
    title: labelTitle,
    developerName: labelDeveloperName,
    description: labelDescription,
    object: labelObject,
    titlePlaceholder: labelUntitledLookupConfiguration,
    searchPlaceholder: labelSearchPlaceholder,
    searchAgainstSelectedFields: labelSearchAgainstFields,
    searchAvailableFieldsPlaceholder: labelSearchAvailableFields,
    labelDisplaySelectedFields: labelDisplaySelectedFields,
    titleMissing: labelLookupConfigurationNameMissing,
    enterValueMissing: labelEnterValue,
    developerNameMissing: labelEnterDeveloperName,
    noOfRecordsToReturn: labelNoOfRecordsToReturn,
    noOfRecordsToReturnMissing: labelNoOfRecordsToReturnMissing,
    fieldToReturn: labelFieldToReturn,
    addSearchFields: labelAddSearchFields,
    selectSearchFields: labelSelectSearchFields,
    addDisplayFields: labelAddDisplayFields,
    selectDisplayFields: labelSelectDisplayFields,
    selectedFields: labelSelectedFields,
    availableFields: labelAvailableFields,
    copyOf: labelCopyOf,
    wasSaved: labelWasSaved,
    continue: labelYesContinue,
    goBack: labelNoGoBack,
    savingRecords: labelSavingRecords,
    expression: labelExpression,
    expressionName: labelExpressionName,
    lookupName: labelConfigName,
    helpLink: labelLookupEditorHelp,
    generalInfoSection: secGeneralInformation,
    searchFieldsSection: secSearchFields,
    displayFieldsSection: secDisplayFields,
    conditionsSection: labelConditionsAndLogic,
    required: labelRequired,
    lookup: labelLookup,
    conditionsAndLogicSection: secConditionAndLogic,
    deletedSuccessfully: labelDeletedSuccessfully,
    loading: labelLoading,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    deleteSuccess: labelDeletedSuccess,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    showMenuAltText: labelShowMenu,
    useSearchFields: labelUseSearchFields,
    literalParameterSelection: errorLiteralParameterSelection,
    dataSourceObject: labelDataSourceObject,
    duplicateDeveloperName: errorDuplicateDeveloperName,
};

const EXPRESSION_TYPE = 'LOOKUP-EXPRESSION';

export default class LookupEditor extends NavigationMixin(LightningElement) {
    @track error;
    @track apiInProgress = false;
    @track editMode = true;
    @track isAdvancedExpressionRequired =false;
    @track developerNameEditable = true;
    @track numberOfRecords = [
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' },
        { label: '100', value: '100' }
    ];
    @track activeSections = ['generalSection', 'searchFields', 'displayFields', 'basicFilter'];
    @track checkbox;
    @track lookupRecord = {};
    @track allDisplayFieldList = [];
    @track allSearchableFieldList = [];
    @track seachableFields = [];
    @track displayFields = [];
    @track objectList = [];
    @track objectAPIName = '';
    @track headerObjectAPIName = '';
    @track basicFilter = [{}];
    @track disableDisplayDualingList = false;
    @track displayFieldSearchString;
    @track lookupConfigId = '';
    @track fieldDetails;
    @track displayHeaderObjectLabel = false;
    @track isHeaderObjectField = 'false';
    @track defaultValueLookUp = [];

    @track moduleType = '';
    @track configurationId = '';
    @track configDeveloperName = '';
    @track configName = '';
    @track operationType = '';
    @track deleteWhereUsedModalDialogOpen = false;
    @track launchModule = '';

    hasEmptyId = true;
    isDelete;
    isCancel;
    modalTitle;
    modalContent;
    showConfirmationModal;
    objectLabel = '';
    objectNameField = '';
    @track headerObjectLabel = '';

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {

        if (currentPageReference && currentPageReference.state) {
            if (currentPageReference.state.c__objectName) {
                this.objectAPIName = currentPageReference.state.c__objectName;
            }
            if (currentPageReference.state.c__recordId) {
                this.lookupConfigId = currentPageReference.state.c__recordId;
            }
            if (currentPageReference.state.c__headerObjectAPIName) {
                this.headerObjectAPIName = currentPageReference.state.c__headerObjectAPIName;
            }
            if (currentPageReference.state.c__isHeaderObjectField) {
                this.isHeaderObjectField = currentPageReference.state.c__isHeaderObjectField;
            }
        }

        this.loadView();
        if (this.lookupConfigId) {
            this.headerObjectAPIName = '';
            this.getLookupConfigData();
            this.hasEmptyId = false;
        } else {
            if (this.isHeaderObjectField === 'true') {
                this.headerObjectAPIName = '';
            }
            this.mapRecordData(null, null);
        }
    }

    get i18n () {
        return i18n;
    }

    loadView () {
        this.apiInProgress = true;
        this.getNewRecordDetails();
    }

    getNewRecordDetails () {
        this.mapObjectFields(this.objectAPIName)
            .then()
            .finally(() => {
                this.apiInProgress = false;
                this.fireOnLoadCompleteEvent();
            });
    }

    setDefaultValues () {
        if (!this.lookupConfigId) {
            this.lookupRecord.numberOfRecords = '50';
        }
        this.lookupRecord.fieldToReturn = this.objectNameField;
        if (this.lookupRecord.displayFields && this.lookupRecord.displayFields.length > 0) {
            this.defaultValueLookUp = this.lookupRecord.displayFields;
        }
        else {
            this.defaultValueLookUp = [...this.requiredDisplayFields];
            this.lookupRecord.displayFields = [...this.requiredDisplayFields];
        }
    }

    get requiredDisplayFields () {
        const { objectNameField } = this;
        return [ objectNameField ];
    }

    mapRecordData (existingRecord, objectFields) {
        this.lookupRecord = new lookupModel(existingRecord, objectFields);
        if (existingRecord) {
            if (this.lookupRecord && this.lookupRecord.id) {
                this.developerNameEditable = false;
                this.lookupConfigId = this.lookupRecord.id;
                this.lookupRecord.headerRecordObject = existingRecord.headerRecordObject;
            } else {
                this.developerNameEditable = true;
            }

        } else {
            this.lookupConfigId = null;
        }
        this.lookupRecord.fieldDetails = deepCopy(this.fieldDetails);
    }

    formatObjectFields (fieldDefinitions, objectAPIName) {
        if (fieldDefinitions) {
            const searchableFieldList = [];
            const displayFieldList = [];
            const { COMBOBOX, EMAIL, PICKLIST, STRING, TEXTAREA, URL, ID, ENCRYPTEDSTRING, LOCATION,
                ADDRESS, BASE64 }
                = FIELD_DATA_TYPES;

            fieldDefinitions.forEach( field => {
                const { apiName, label, dataType, length, htmlFormatted, nameField } = field;
                if (dataType !== ENCRYPTEDSTRING) {
                    const fieldWrap = {
                        label,
                        value: apiName,
                        secondary: apiName
                    }

                    if ( dataType !==  LOCATION && dataType !==  ADDRESS && dataType !==  BASE64) {
                        displayFieldList.push(fieldWrap);
                    }

                    if (dataType === COMBOBOX || dataType === EMAIL || dataType === ID ||
                        dataType === URL || dataType === PICKLIST || dataType === STRING ||
                        (dataType === TEXTAREA && length < 256 && !htmlFormatted) ) {
                        searchableFieldList.push(fieldWrap);
                    }
                }

                if (objectAPIName === 'Account' && apiName === 'Name') {
                    this.objectNameField = apiName;
                } else if (objectAPIName !== 'Account' && nameField) {
                    this.objectNameField = apiName;
                }
            });
            this.allSearchableFieldList = searchableFieldList;
            this.seachableFields = searchableFieldList;
            this.allDisplayFieldList = displayFieldList;
            this.displayFields = displayFieldList;
            this.setDefaultValues();
        }
    }

    async mapObjectFields (objectAPIName) {
        this.fetchObjectFields(objectAPIName)
            .then(result => {
                if (result) {
                    Array.from(result).forEach(entity => {
                        if (entity.apiName === this.objectAPIName) {
                            const { fieldDefinitions, label } = entity;
                            this.objectLabel = label;
                            this.fieldDetails = entity;
                            this.lookupRecord.fieldDetails = deepCopy(entity);
                            this.formatObjectFields(fieldDefinitions, objectAPIName);
                        } else if (entity.apiName === this.headerObjectAPIName) {
                            this.headerObjectLabel = entity.label;
                        }
                    });
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    async fetchObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }
        this.apiInProgress = true;
        const objectNames = [];
        objectNames.push(objectApiName);
        if (this.headerObjectAPIName && !this.lookupConfigId) {
            objectNames.push(this.headerObjectAPIName);
        }
        try {
            const resp = await getFieldDefinitionsForEntities(objectNames);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        } finally {
            this.apiInProgress = false;
            this.fireOnLoadCompleteEvent();
        }
        return result;
    }

    getLookupConfigData () {
        if (this.lookupConfigId) {
            this.apiInProgress = true;
            getLookupConfigDetail({ lookupConfigId: this.lookupConfigId })
                .then(result =>{
                    if (result.success) {
                        this.mapRecordData(result.data, null);
                        if (this.lookupRecord.headerRecordObject) {
                            this.displayHeaderObjectLabel = true;
                        }
                        if (this.lookupConfigId) {
                            this.headerObjectAPIName = this.lookupRecord.headerRecordObject;
                        }
                        this.mapObjectFields(this.headerObjectAPIName);
                        this.getExpressionDetails(this.lookupRecord.expressionId);
                        this.setDefaultValues();
                    } else {
                        this.error = result.message;
                    }
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                    this.fireOnLoadCompleteEvent();
                });
        }
    }

    async getExpressionDetails (expressionRecordId) {

        if (expressionRecordId) {
            this.apiInProgress = true;
            try {
                const expressionResponse = await getExpressionWithDetails({
                    expressionId: expressionRecordId
                });

                if (expressionResponse && expressionResponse.success === true) {
                    if (expressionResponse.data) {
                        this.basicFilter = expressionResponse.data;
                    }
                } else {
                    this.error = expressionResponse.message;
                }
                this.apiInProgress = false;
                this.fireOnLoadCompleteEvent();
            } catch (err) {
                this.apiInProgress = false;
                this.fireOnLoadCompleteEvent();
                this.error = parseErrorMessage(err);
            }
        } else {
            this.apiInProgress = false;
            this.fireOnLoadCompleteEvent();
        }
    }

    getDeveloperNameInput () {
        return this.template.querySelector('[data-field="developerName"]');
    }

    handleNameBlur () {
        if (this.developerNameEditable && !this.lookupRecord.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.lookupRecord.developerName =
                normalizeDeveloperName(this.lookupRecord.lookupName,maxLength,
                    'AutomaticRule1');
            this.getDeveloperNameInput().value = this.lookupRecord.developerName;
        }
    }

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.lookupRecord[event.currentTarget.dataset.field] = inputVal;
    }

    handleItemChanged () {
        if (!this.lookupConfigId) {
            let isHeaderRecordConfigured = false;
            const expressionBuilder = this.template.querySelector('.svmx-expression-builder');
            const expressionData = expressionBuilder.expressionData;
            if (expressionData && expressionData.expressionDetails) {
                expressionData.expressionDetails.forEach( item => {
                    if (item.operand === 'Current Record Header') {
                        isHeaderRecordConfigured = true;
                    }
                });
            }
            this.displayHeaderObjectLabel = isHeaderRecordConfigured;
        }

    }

    handleDuelListChange (event) {
        const { objectNameField } = this;
        const selectedOptionsList = event.detail.value;
        if ( event.target.name === 'displayFields') {
            if (selectedOptionsList[0] !== objectNameField) {
                this.defaultValueLookUp = [...this.defaultValueLookUp];
                event.preventDefault();
                return;
            }
            this.defaultValueLookUp = [...selectedOptionsList];
        }

        this.lookupRecord[event.currentTarget.dataset.field] = selectedOptionsList;
        if (this.disableDisplayDualingList) {
            this.lookupRecord.displayFields = this.lookupRecord.searchFields;
        }
    }

    filterObjectFields (event) {
        let inputVal = event.target.value;
        const selectedValueMaping = {
            searchSearchFields: this.lookupRecord.searchFields,
            searchDisplayFields: this.lookupRecord.displayFields
        };

        if (inputVal) {
            inputVal = inputVal.trim();
        }
        const fieldName = event.currentTarget.dataset.field;
        if (!isEmptyString(inputVal)) {
            const stringToBeSearched= inputVal.toLowerCase();

            if (fieldName) {
                const selectedValues = selectedValueMaping[fieldName];

                const formattedFieldList = fieldName === "searchDisplayFields"
                    ? this.allDisplayFieldList
                    : this.allSearchableFieldList;

                const searchedFields = formattedFieldList.filter( item => {
                    const nameMatch = item.value
                        ? item.value.toLowerCase().indexOf(stringToBeSearched)
                        : -1;

                    const selectedOptionIndex = selectedValues
                        ? selectedValues.indexOf(item.value)
                        : -1;

                    return nameMatch !== -1 || selectedOptionIndex > -1;
                });

                if (fieldName === 'searchDisplayFields') {
                    this.displayFields = searchedFields || [];
                } else {
                    this.seachableFields = searchedFields || [];
                }
            } else {
                this.displayFields = [];
                this.seachableFields = [];
            }
        } else {
            if (fieldName === 'searchDisplayFields') {
                this.displayFields = this.allDisplayFieldList;
            } else {
                this.seachableFields = this.allSearchableFieldList;
            }
        }
    }

    onUseSearchFieldsCheckboxHandler () {
        if (!this.disableDisplayDualingList) {
            this.lookupRecord.displayFields = this.lookupRecord.searchFields;
            this.defaultValueLookUp = this.lookupRecord.searchFields;
        }
        this.displayFieldSearchString  = '';
        this.displayFields = this.allDisplayFieldList;
        this.disableDisplayDualingList = !this.disableDisplayDualingList;
    }

    handleSaveAs () {
        if (!this.lookupConfigId) return;
        const lookupConfigData = this.fetchLookupConfig();
        if (!this.error) {
            this.alterDataForClone(lookupConfigData);
        }
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    alterDataForClone (lookupConfigInfo) {
        const lookupConfigData = JSON.parse(JSON.stringify(lookupConfigInfo));

        this.lookupConfigId = this.lookupRecord.id = undefined;
        this.lookupRecord.lookupName =
            `${this.i18n.copyOf} ${this.lookupRecord.lookupName}`;
        this.lookupRecord.developerName = !isEmptyString(this.i18n.copyOf)
            ? `${this.i18n.copyOf.replace(' ', '_')}_${this.lookupRecord.developerName}`
            : `_${this.lookupRecord.developerName}`;

        if ( lookupConfigData.basicFilter ) {
            lookupConfigData.basicFilter.id = undefined;
            lookupConfigData.basicFilter.developerName = undefined;
            lookupConfigData.basicFilter.name = '';
            if (lookupConfigData.basicFilter.expressionDetailList) {
                lookupConfigData.basicFilter.expressionDetailList.forEach(expressionDetail => {
                    expressionDetail.id = undefined;
                })
            }
        }
        this.basicFilter = lookupConfigData.basicFilter ? lookupConfigData.basicFilter : [{}];

        this.developerNameEditable = true;
        this.hasEmptyId = true;
        this.apiInProgress = false;
        this.fireOnLoadCompleteEvent();
    }

    validateAdvancedExpression () {
        const expressionBuilder = this.template.querySelector('.svmx-expression-builder');
        return expressionBuilder ? !expressionBuilder.reportValidity() : true;
    }

    saveLookupConfiguration () {
        let isValid = true;
        const inpCmpList = this.template.querySelectorAll(".requiredInput");
        if (inpCmpList) {
            inpCmpList.forEach(inpCmp => {
                inpCmp.reportValidity();
                isValid = inpCmp.checkValidity() && isValid;
            })
        }

        isValid = this.validateAdvancedExpression() && isValid;

        if (isValid) {
            this.error = null;
            this.saveLookupConfigurationData();
        } else {
            this.error = this.i18n.formValidation;
        }
    }

    fetchLookupConfig () {
        this.apiInProgress = true;
        const expressionBuilder = this.template.querySelector('.svmx-expression-builder');
        const expressionData = expressionBuilder.expressionData.getRecordData();
        if (expressionData && expressionData.expressionDetailList) {
            expressionData.expressionDetailList.forEach(entity => {
                if ( (entity.operand === FUNCTION_LITERALS.CURRENTRECORDHEADER ||
                    entity.operand === FUNCTION_LITERALS.USER) && !entity.literalParameterAPIName
                    && entity.operandType === 'Function') {
                    this.error = i18n.literalParameterSelection;
                }
            });
        }
        let lookupConfigData;
        if (!this.error) {
            if (expressionData) {
                if (isEmptyString(expressionData.name)) {
                    expressionData.name = `${this.lookupRecord.lookupName}`;
                }
                expressionData.objectAPIName = this.objectAPIName;
                expressionData.expressionType = EXPRESSION_TYPE;
            }
            lookupConfigData = this.lookupRecord.recordData;
            lookupConfigData.basicFilter = expressionData;
            lookupConfigData.objectAPIName = this.objectAPIName;
        }
        else {
            this.apiInProgress = false;
            this.fireOnLoadCompleteEvent();
        }

        return lookupConfigData;
    }

    saveLookupConfigurationData () {
        const lookupConfigData = this.fetchLookupConfig();
        if (lookupConfigData) {
            if (!this.lookupConfigId) {
                let isHeaderRecordConfigured = false;
                const expressionBuilder = this.template.querySelector('.svmx-expression-builder');
                const expressionData = expressionBuilder.expressionData;
                if (expressionData && expressionData.expressionDetails) {
                    expressionData.expressionDetails.forEach( item => {
                        if (item.operand === 'Current Record Header') {
                            isHeaderRecordConfigured = true;
                        }
                    });
                }
                if (isHeaderRecordConfigured) {
                    lookupConfigData.basicFilter.headerRecordObject = this.headerObjectAPIName;
                    lookupConfigData.headerRecordObject = this.headerObjectAPIName;
                }
            } else {
                if (lookupConfigData.basicFilter) {
                    lookupConfigData.basicFilter.headerRecordObject = this.headerObjectAPIName;
                }
                lookupConfigData.headerRecordObject = this.headerObjectAPIName;
            }

            if (lookupConfigData.basicFilter && !lookupConfigData.basicFilter.developerName) {
                lookupConfigData.basicFilter.developerName =
                populateExpressionDeveloperName(lookupConfigData.developerName);
            }
            if (!this.error) {
                saveLookupConfig({ requestJson: JSON.stringify(lookupConfigData) })
                    .then(result => {

                        if (result.success) {
                            const { pageHeader,  wasSaved } = this.i18n;
                            const successMessage =
                            `${pageHeader} ${this.lookupRecord.lookupName} ${wasSaved}`;
                            this.showSuccessNotification(successMessage);
                            this.mapRecordData(result.data, null);
                            //avoid changing header object after saving lookup configuration
                            this.basicFilter =
                                result.data.basicFilter ? result.data.basicFilter : [{}];
                            if (result.data && result.data.headerRecordObject) {
                                this.displayHeaderObjectLabel = true;
                            }
                            if (result.data && result.data.id && result.data.headerRecordObject) {
                                this.headerObjectAPIName = result.data.headerRecordObject;
                                this.mapObjectFields(this.headerObjectAPIName);
                            } else {
                                this.headerObjectAPIName = '';
                            }
                            this.hasEmptyId = false;
                        } else {
                            if (result.message.includes('duplicate value found:')) {
                                this.error = i18n.duplicateDeveloperName;
                            } else {
                                this.error = result.message;
                            }
                        }
                    })
                    .catch(error => {
                        this.error = parseErrorMessage(error);
                    })
                    .finally(() => {
                        this.apiInProgress = false;
                        this.fireOnLoadCompleteEvent();
                    });
            }
        }
    }

    deleteLookupConfiguration () {
        this.apiInProgress = true;
        deleteLookupConfig({ lookupConfigId: this.lookupConfigId })
            .then(result => {
                if (result.success) {
                    const { pageHeader,  deletedSuccessfully } = this.i18n;
                    const successMsg =
                        `${pageHeader} ${this.lookupRecord.lookupName} ${deletedSuccessfully}`;

                    this.showSuccessNotification(successMsg);
                    this.mapRecordData(null, null);
                    this.showConfirmationModal = false;
                    this.navigateToAssetAdminTab();
                } else {
                    this.error = result.message;
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
                this.fireOnLoadCompleteEvent();
            });
    }

    showSuccessNotification (successMsg) {
        const evt = new ShowToastEvent({
            title: successMsg,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    navigateToAssetAdminTab () {
        this [ NavigationMixin.Navigate ]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'SVMXA360__setupHome'
            },
            state: {
                SVMXA360__isLookupEditor: true
            }
        });
    }

    setModalAttributes (eventName, title, content, cancel) {
        this.eventName = eventName;
        this.modalTitle = title;
        this.modalContent = content;
        this.modalCancel = cancel;
    }

    handleConfirmationCancel () {
        this.showConfirmationModal = false;
        this.isCancel = false;
        this.isDelete = false;
    }

    handleCancel () {
        this.setModalAttributes(i18n.cancel, i18n.cancelModalTitle,
            i18n.cancelModalContent, i18n.goBack);
        this.showConfirmationModal = true;
        this.isCancel = true;
    }

    handleDelete () {
        if (!this.lookupConfigId) return;
        this.setModalAttributes(i18n.delete, i18n.deleteModalTitle,
            i18n.deleteModalContent, i18n.cancel);
        this.showConfirmationModal = true;
        this.isDelete = true;
    }

    checkWhereUsedForDelete () {
        if (!this.lookupConfigId) return;
        this.moduleType = 'Lookup Filter';
        this.configurationId = this.lookupRecord.id;
        this.configDeveloperName = this.lookupRecord.developerName;
        this.configName = this.lookupRecord.lookupName;
        this.operationType = 'delete';
        this.launchModule = 'Lookup Filter';
        this.deleteWhereUsedModalDialogOpen = true;
    }

    checkWhereUsedForUpdate () {
        if (!this.lookupConfigId) {
            this.saveLookupConfiguration();
        } else {
            this.moduleType = 'Lookup Filter';
            this.configurationId = this.lookupRecord.id;
            this.configDeveloperName = this.lookupRecord.developerName;
            this.configName = this.lookupRecord.lookupName;
            this.operationType = 'update';
            this.deleteWhereUsedModalDialogOpen = true;

        }
    }

    handleCancelWhereUsedModal () {
        this.deleteWhereUsedModalDialogOpen =  false;
    }

    handleDeleteModal () {
        this.deleteWhereUsedModalDialogOpen =  false;
        this.handleDelete();
    }

    handleWhereUsedSave () {
        this.deleteWhereUsedModalDialogOpen =  false;
        this.saveLookupConfiguration()
    }

    handleModalCancel () {
        this.showConfirmationModal = false;
        this.navigateToAssetAdminTab();
    }

    handleModalDelete () {
        this.deleteLookupConfiguration();
    }

    fireOnLoadCompleteEvent () {
        this.dispatchEvent(new CustomEvent('loadcomplete', { bubbles: true, composed: true }));
    }
}