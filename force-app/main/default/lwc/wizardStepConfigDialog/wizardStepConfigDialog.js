import { LightningElement, api, track, wire } from 'lwc';
import {
    getObjectInfo,
    getPicklistValuesByRecordType
} from 'lightning/uiObjectInfoApi';
import PROCESS_STEP_OBJECT from '@salesforce/schema/CONF_ProcessWizardStep__c';
import CRITERIA_ACTION_FIELD from '@salesforce/schema/CONF_ProcessWizardStep__c.CriteriaAction__c';
import {
    DATA_TYPE_ICONS,
    STEP_TYPES,
    STEP_PARAMETER_TYPES,
    STEP_TYPE_ICONS,
    ROUTES,
    UNSUPPORTED_FIELD_TYPES,
    deepCopy,
    guid,
    isEmptyString,
    parseErrorMessage,
    isNotUndefinedOrNull,
    isUndefinedOrNull,
    verifyApiResponse,
    ADMIN_MODULES,
    normalizeDeveloperName,
    ICON_NAMES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

import getProcessStepTargetsByApiName
    from '@salesforce/apex/ADM_ProcessWizardLightningService.getProcessStepTargetsByApiName';
import isDeveloperNameAvailable
    from '@salesforce/apex/ADM_DeveloperNameLightningService.isDeveloperNameAvailable';
import { getFieldDefinitionsForEntities } from 'c/metadataService';

import labelAddRow from '@salesforce/label/c.Label_AddRow';
import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelDeleteParameter from '@salesforce/label/c.Label_Delete_Parameter';
import labelEnterValue from '@salesforce/label/c.Message_EnterValue';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelChooseStepType from '@salesforce/label/c.Message_ChooseStepType';
import labelCriteriaStep from '@salesforce/label/c.Label_CriteriaStep';
import labelCriteriaAction from '@salesforce/label/c.Label_CriteriaAction';
import labelCriteriaActionHelpText from '@salesforce/label/c.Label_CriteriaActionHelpText';
import labelFieldName from '@salesforce/label/c.Label_FieldName';
import labelIconName from '@salesforce/label/c.Label_IconName';
import labelNext from '@salesforce/label/c.Button_Next';
import labelNoParameters from '@salesforce/label/c.Message_NoStepParameters';
import labelOpenAsModal from '@salesforce/label/c.Label_Open_As_Modal';
import labelParameters from '@salesforce/label/c.Label_Parameters';
import labelParameterName from '@salesforce/label/c.Label_ParameterName';
import labelStepProperties from '@salesforce/label/c.Title_StepProperties';
import labelStepNameMissing from '@salesforce/label/c.Message_StepNameMissing';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelSelectStep from '@salesforce/label/c.Message_SelectStep';
import labelSelectCriteriaPlaceholder from '@salesforce/label/c.Placeholder_SelectCriteria';
import labelStepName from '@salesforce/label/c.Label_StepName';
import labelStepNamePlaceholder from '@salesforce/label/c.Placeholder_StepName';
import labelStepType from '@salesforce/label/c.Label_StepType';
import labelTooltipHelp from '@salesforce/label/c.Label_TooltipHelp';
import labelView from '@salesforce/label/c.Label_View';
import labelFlowDesignerUrl from '@salesforce/label/c.URL_FlowDesigner';
import labelSelectExpression from '@salesforce/label/c.Title_SelectExpression';
import labelValue from '@salesforce/label/c.Picklist_Value';
import labelValueType from '@salesforce/label/c.Label_ValueType';
import messageOpenAsModalHelpText from '@salesforce/label/c.Message_OpenAsModalHelpText';
import messageStepTypeInvalid from '@salesforce/label/c.Message_StepTypeInvalid';
import labelStepTypeLWC from '@salesforce/label/c.Label_StepTypeLWC';
import labelStepTypeTransaction from '@salesforce/label/c.Label_StepTypeTransaction';
import labelStepTypeFlow from '@salesforce/label/c.Label_StepTypeFlow';
import labelStepTypeURL from '@salesforce/label/c.Label_StepTypeURL';
import noSpaceAllowed from '@salesforce/label/c.Message_NoSpaceAllowed';
import buttonTest from '@salesforce/label/c.Button_Preview';
import urlStepMissing from '@salesforce/label/c.Message_SelectStepURL';
import invalidArgs from '@salesforce/label/c.Error_InvalidArgument';
import labelSelectFlow from '@salesforce/label/c.Label_SelectFlow';
import labelSelectLWC from '@salesforce/label/c.Label_SelectLWC';
import labelSelectTransaction from '@salesforce/label/c.Label_SelectTransaction';
import labelSelectURL from '@salesforce/label/c.Label_SelectUrl';
import labelSelectRecordAction from '@salesforce/label/c.Label_SelectRecordAction';
import labelDependentStepList from '@salesforce/label/c.Label_DependentStepList';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import labelDuplicateName from '@salesforce/label/c.Error_Duplicate_Wizard_Step_Developer_Name';
import descSelectFromLibraryComponents from '@salesforce/label/c.Desc_SelectFromLibraryComponents';
import labelServiceMaxTransaction from '@salesforce/label/c.Label_ServiceMaxTransaction';
import labelFormsServiceExecution from '@salesforce/label/c.Label_FormsServiceExecution';
import descFlowsConfiguredForBusiness from '@salesforce/label/c.Desc_FlowsConfiguredForBusiness';
import descToWebPageOrService from '@salesforce/label/c.Desc_ToWebPageOrService';
import titleLink from '@salesforce/label/c.Title_Link';

const i18n = {
    addRow: labelAddRow,
    apply: labelApply,
    cancel: labelCancel,
    chooseStepType: labelChooseStepType,
    criteria: labelCriteriaStep,
    criteriaAction: labelCriteriaAction,
    criteriaActionHelpText: labelCriteriaActionHelpText,
    deleteParameter: labelDeleteParameter,
    enterValue: labelEnterValue,
    fieldName: labelFieldName,
    flowDesignerUrl: labelFlowDesignerUrl,
    formValidation: labelFormValidation,
    iconName: labelIconName,
    invalidStepType: messageStepTypeInvalid,
    modalTitle: labelStepProperties,
    nameMissing: labelStepNameMissing,
    noParameters: labelNoParameters,
    openAsModal: labelOpenAsModal,
    parameters: labelParameters,
    parameterName: labelParameterName,
    next: labelNext,
    openModalHelpText: messageOpenAsModalHelpText,
    select: labelSelect,
    stepMissing: labelSelectStep,
    selectCriteria: labelSelectCriteriaPlaceholder,
    selectExpression: labelSelectExpression,
    stepName: labelStepName,
    stepNamePlaceholder: labelStepNamePlaceholder,
    stepType: labelStepType,
    tooltip: labelTooltipHelp,
    view: labelView,
    value: labelValue,
    valueType: labelValueType,
    URLStep: labelStepTypeURL,
    noSpaceAllowed: noSpaceAllowed,
    buttonTest: buttonTest,
    urlStepMissing: urlStepMissing,
    invalidArgs: invalidArgs,
    labelSelectFlow: labelSelectFlow,
    labelSelectLWC: labelSelectLWC,
    labelSelectTransaction: labelSelectTransaction,
    labelSelectURL: labelSelectURL,
    labelSelectRecordAction: labelSelectRecordAction,
    labelDependentStepList: labelDependentStepList,
    developerName: labelDeveloperName,
    developerNameMissing: labelEnterDeveloperName,
    developerNameExists: labelDuplicateName,
    labelStepTypeLWC: labelStepTypeLWC,
    descSelectFromLibraryComponents: descSelectFromLibraryComponents,
    labelServiceMaxTransaction: labelServiceMaxTransaction,
    labelFormsServiceExecution: labelFormsServiceExecution,
    labelStepTypeFlow: labelStepTypeFlow,
    descFlowsConfiguredForBusiness: descFlowsConfiguredForBusiness,
    descToWebPageOrService: descToWebPageOrService,
    titleLink: titleLink
};

const DISABLE_STEP_VALUE = 'Disable Step';
const TRANSACTION_STEP_TYPE = 'SPM Transaction';


const STEP_TYPE_LABELS = {
    [STEP_TYPES.FLOW]: labelStepTypeFlow,
    [STEP_TYPES.LWC]: labelStepTypeLWC,
    [STEP_TYPES.TRANSACTION]: labelStepTypeTransaction,
    [STEP_TYPES.URL]: labelStepTypeURL
}

const PREVIEW_MODE_SUPPORTED_TYPES = [
    STEP_TYPES.LWC,
    STEP_TYPES.URL,
    STEP_TYPES.FLOW,
    STEP_TYPES.TRANSACTION
];

export default class WizardStepConfigDialog extends LightningElement {
    @api entityDefinition;

    @track defaultRecordTypeId;
    @track criteriaActionOptions = [];
    @track fieldSchema = {};
    @track error;
    @track showExpressionSelector = false;
    @track showStepSelector = false;
    @track showExpressionViewModal = false;
    @track showIconPickerModal = false;
    @track showPreviewModal = false;

    @track _modalOpen = false;
    @track _processStepRecord = this.initializeProcessStepRecord();
    @track _objectApiName;
    @track selectStepProperties = false;

    @api showDependentStepFlag;
    @api wizardDevName;
    @api wizardStepDevNames = [];

    criteriaActionDefaultValue;
    stepTargetRequestJson = '';
    wiredTarget;

    /**
     * If present, displays the step configuration dialog
     * @type {boolean}
     * @default false
     */
    @api
    get modalOpen () {
        return this._modalOpen;
    }
    set modalOpen (newValue) {
        this._modalOpen = newValue;
    }

    @api
    get dependentStepsList () {
        return this._dependentStepsList;
    }

    set dependentStepsList ( value ) {
        this._dependentStepsList = value;
    }

    /**
     * This value is used to filter expressions for a specific Salesforce Object
     * @type {string}
     */
    @api
    get objectApiName () {
        return this._objectApiName;
    }
    set objectApiName (newValue) {
        if (this._objectApiName !== newValue) {
            this._objectApiName = newValue;
            this.getFieldDefinition();
        }
    }

    /**
     * This value represents a record from the CONF_ProcessWizardStep__c object.
     * @type {object}
     */
    @api
    get processStepRecord () {
        if (!this._processStepRecord) {
            this._processStepRecord = this.initializeProcessStepRecord();
        }

        return this._processStepRecord;
    }
    set processStepRecord (newValue) {
        if (!newValue) {
            this._processStepRecord = null;
            return;
        }

        const processStepRecord = deepCopy(newValue);
        // Calculate isFieldMappingType for stepParameters.
        if (processStepRecord.stepParameters) {
            processStepRecord.stepParameters.forEach((item) => {
                item.isFieldMappingType = item.valueType === STEP_PARAMETER_TYPES.FIELD_NAME;
            })
        }
        this._processStepRecord = processStepRecord;
        const recentlyViewedRecord = {
            configurationId: this._processStepRecord.id,
            configurationName: this._processStepRecord.name,
            configurationType: ADMIN_MODULES.WIZARD,
            objectApiName: this.objectApiName
        };
        saveRecentViewItem(recentlyViewedRecord)
            .then(recentItem => {
                if (!verifyApiResponse(recentItem)) {
                    this.error = recentItem.message;
                }
            });
        this.selectStepProperties = true;
        if (!newValue.targetLabel) {
            const stepTargetRequestJson = JSON.stringify({
                stepTypeName: newValue.type,
                targetApiName: newValue.target,
                objectApiName: this.objectApiName
            });
            getProcessStepTargetsByApiName({ requestJson: stepTargetRequestJson })
                .then((result) => {
                    if (!verifyApiResponse(result)) {
                        this.error = parseErrorMessage(result);
                        return;
                    }
                    if (result.data) {
                        this._processStepRecord = Object.assign(
                            {},
                            this._processStepRecord,
                            {
                                targetLabel: result.data.label,
                                targetId: result.data.id
                            }
                        );

                        if (this.showAsPlainText) {
                            this.setWizardStepDeveloperName();
                        }
                    }
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
        }
    }

    /**
     * This value represents a record from the CONF_ProcessWizardStep__c object.
     * @type {object}
     */
    @api
    get wizardReferenceId () {
        return this._processStepRecord.wizardReferenceId;
    }
    set wizardReferenceId (newValue) {
        this._processStepRecord.wizardReferenceId = newValue;
    }

    @api
    get sequence () {
        return this._processStepRecord
            ? this._processStepRecord.sequence
            : undefined;
    }

    set sequence (newValue) {
        if (this._processStepRecord) {
            this._processStepRecord.sequence = newValue;
        }
    }

    get stepTypeOptions () {

        const stepTypeOptions = Object.keys(STEP_TYPE_LABELS).map(obj =>
        { const rObj = {}; rObj.label = STEP_TYPE_LABELS[obj]; rObj.value = obj; return rObj });
        return stepTypeOptions;
    }

    get showAsPlainText () {
        return this._processStepRecord && this._processStepRecord.type === STEP_TYPES.URL;
    }

    get showOpenAsModal () {
        if (this._processStepRecord
            && this._processStepRecord.type
            && this._processStepRecord.type === STEP_TYPES.URL ) {
            return false
        }
        return true;

    }

    steptypesdata = [
        {
            icon: ICON_NAMES.TRANSACTIONGENERIC,
            label: i18n.labelServiceMaxTransaction,
            value: 'SPM Transaction',
            desc: i18n.labelFormsServiceExecution,
            checkedStatus: true
        },
        {
            icon: ICON_NAMES.TRANSACTIONFLOW,
            label: i18n.labelStepTypeFlow,
            value: 'Flow',
            desc: i18n.descFlowsConfiguredForBusiness,
            checkedStatus: false
        },
        {
            icon: ICON_NAMES.TRANSACTIONLWC,
            label: i18n.labelStepTypeLWC,
            value: 'Lightning Web Component',
            desc: i18n.descSelectFromLibraryComponents,
            checkedStatus: false
        },
        {
            icon: ICON_NAMES.TRANSACTIONLINK,
            label: i18n.titleLink,
            value: 'url',
            desc: i18n.descToWebPageOrService,
            checkedStatus: false
        }
    ];

    get selectedDependencyValue () {
        const selectArray = [];
        // eslint-disable-next-line no-unused-expressions
        this._processStepRecord?.dependentSteps?.forEach(dependentStep => {
            selectArray.push(dependentStep.referenceId);
        });
        return selectArray.length > 0 ? selectArray.join(';') : '';
    }

    get showDependentStepDropDown () {
        return this.showDependentStepFlag && this._processStepRecord.sequence !== 1;
    }

    get developerNameEditable () {
        return this.isNewRecord;
    }

    get stepDeveloperNameInput () {
        return this.template.querySelector('.step-developer-name');
    }

    clearState () {
        this._processStepRecord = this.initializeProcessStepRecord();
        this.selectStepProperties = false;
        this.error = null;
    }

    initializeProcessStepRecord () {
        return {
            id: null,
            lastModifiedDate: null,
            lastModifiedBy: null,
            name: null,
            namespace: null,
            target: null,
            type: TRANSACTION_STEP_TYPE,
            expressionId: null,
            expressionName: null,
            processWizardId: '',
            wizardReferenceId: '',
            referenceId: guid(),
            helpText: null,
            sequence: null,
            criteriaAction: null,
            criteriaActionHelpText: null,
            iconName: null,
            openAsModal: false,
            isVisible: true,
            stepDependencyFlag: false,
            developerName: null,
        };
    }

    get i18n () {
        return Object.assign(
            {},
            i18n,
            {
                selectStep: `${this.selectedStepLabel}`
            }
        )
    }

    get selectedStepLabel () {
        let selectedStepLabel;
        switch (this._processStepRecord.type) {
            case STEP_TYPES.FLOW:
                selectedStepLabel = i18n.labelSelectFlow;
                break;
            case STEP_TYPES.TRANSACTION:
                selectedStepLabel = i18n.labelSelectTransaction;
                break;
            case STEP_TYPES.LWC:
                selectedStepLabel = i18n.labelSelectLWC;
                break;
            case STEP_TYPES.URL:
                selectedStepLabel = i18n.labelSelectURL;
                break;
            case STEP_TYPES.RECORDACTION:
                selectedStepLabel = i18n.labelSelectRecordAction;
                break;
            default:
                selectedStepLabel = i18n.select;
        }
        return selectedStepLabel;
    }

    get isCriteriaActionRequired () {
        return this._processStepRecord.expressionId != null;
    }

    get isNewRecord () {
        return (
            !this._processStepRecord ||
            isEmptyString(this._processStepRecord.id)
        );
    }

    get isTypeParameterized () {
        return this._processStepRecord &&
            this._processStepRecord.type &&
            this._processStepRecord.type !== STEP_TYPES.TRANSACTION &&
            this._processStepRecord.type !== STEP_TYPES.FLOW
    }

    get criteriaLookupValue () {
        if (
            this._processStepRecord &&
            this._processStepRecord.expressionId &&
            this._processStepRecord.expressionName
        ) {
            return {
                label: this._processStepRecord.expressionName,
                value: this._processStepRecord.expressionId,
                iconName: 'utility:filterList'
            };
        }

        return null;
    }

    get expressionId () {
        if (this._processStepRecord &&
            this._processStepRecord.expressionId
        ) {
            return this._processStepRecord.expressionId;
        }

        return null;
    }

    get hasParameters () {
        return this._processStepRecord &&
            this._processStepRecord.stepParameters
            && this._processStepRecord.stepParameters.length > 0;
    }

    get fieldOptions () {
        return this.entityDefinition && this.entityDefinition.fieldDefinitions
            ? this.entityDefinition.fieldDefinitions
                .filter((sourceField => {
                    return !UNSUPPORTED_FIELD_TYPES.has(sourceField.dataType);
                }))
                .map(sourceField => ({
                    label: sourceField.label,
                    value: sourceField.apiName,
                    secondary: sourceField.apiName,
                    iconName: DATA_TYPE_ICONS[sourceField.dataType]
                }))
            : [];
    }

    get modalTitle () {
        return this.selectStepProperties
            ? `${this.i18n.modalTitle} - ${STEP_TYPE_LABELS[this._processStepRecord.type]}`
            : this.i18n.chooseStepType;
    }

    get nextButtonDisabled () {
        return isUndefinedOrNull(this._processStepRecord.type) || isNotUndefinedOrNull(this.error);
    }

    get computedCriteriaAction () {
        const classSet = 'criteria-action-combo';
        return this.isCriteriaActionRequired
            ? `${classSet} required-field`
            : classSet
    }

    get showCriteriaActionHelpText () {
        return (
            this._processStepRecord &&
            this._processStepRecord.criteriaAction === DISABLE_STEP_VALUE
        );
    }

    get stepLookupValue () {
        if (
            this._processStepRecord &&
            this._processStepRecord.target &&
            this._processStepRecord.targetLabel
        ) {
            if ( isUndefinedOrNull (this._processStepRecord.name) ) {
                this._processStepRecord.name = this._processStepRecord.targetLabel;
            }
            if ( isUndefinedOrNull (this._processStepRecord.developerName) ) {
                this.setWizardStepDeveloperName();
            }
            return {
                label: this._processStepRecord.targetLabel,
                value: this._processStepRecord.target,
                iconName: this._processStepRecord.iconName
                    ? this._processStepRecord.iconName
                    : STEP_TYPE_ICONS[this._processStepRecord.type]
            };
        }
        return null;
    }

    get iconLookupValue () {
        if (
            this._processStepRecord &&
            this._processStepRecord.iconName
        )
            return {
                label: this._processStepRecord.iconName,
                value: this._processStepRecord.iconName,
                iconName: this._processStepRecord.iconName
                    ? this._processStepRecord.iconName
                    : STEP_TYPE_ICONS[this._processStepRecord.type]
            };

        return null;
    }

    get valueTypeOptions () {
        return [
            { label: i18n.fieldName, value: STEP_PARAMETER_TYPES.FIELD_NAME },
            { label: i18n.value, value: STEP_PARAMETER_TYPES.VALUE }
        ];
    }

    @wire(getObjectInfo, { objectApiName: PROCESS_STEP_OBJECT })
    getDefaultRecordTypeInfo (value) {
        const { data, error } = value;
        if (data) {
            this.defaultRecordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: PROCESS_STEP_OBJECT,
        recordTypeId: '$defaultRecordTypeId'
    })
    setPicklistOptions ({ error, data }) {
        if (data) {
            if (!data.picklistFieldValues) return;

            const criteriaActionPickList =
                data.picklistFieldValues[CRITERIA_ACTION_FIELD.fieldApiName];
            this.criteriaActionOptions = criteriaActionPickList.values;

            if (criteriaActionPickList.defaultValue) {
                this.criteriaActionDefaultValue =
                    criteriaActionPickList.defaultValue.value;
            }

            this._processStepRecord.type = STEP_TYPES.TRANSACTION;

        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    async checkUIValidity () {
        const developerNameValid = await this.checkDeveloperNameValidity();

        const requiredFieldsValid = [
            ...this.template.querySelectorAll('.required-field')
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        return requiredFieldsValid && developerNameValid;
    }

    async checkDeveloperNameValidity () {
        if (!this.isNewRecord) {
            return true;
        }

        const nameExists = await this.developerNameExists();
        let validityMessage = '';

        if (nameExists) {
            if (this._processStepRecord.developerName) {
                validityMessage = i18n.developerNameExists;
            }
        }

        this.stepDeveloperNameInput.setCustomValidity(validityMessage);
        return this.stepDeveloperNameInput.reportValidity();
    }

    async developerNameExists () {
        let nameExists = false;

        this.wizardStepDevNames.forEach(stepDevObj => {
            if (stepDevObj?.stepDevName
                && stepDevObj?.stepDevName?.toUpperCase().startsWith(
                    this._processStepRecord.developerName?.toUpperCase()
                )
                && stepDevObj.stepReferenceId !== this._processStepRecord.referenceId) {
                nameExists = true;
            }
        });

        if (!nameExists) {
            const developerNameAvailable = await isDeveloperNameAvailable({
                application: 'ProcessWizardStep',
                developerName: this._processStepRecord.developerName
            });
            if (developerNameAvailable.success && !developerNameAvailable.data) {
                nameExists = true;
            }
        }
        return nameExists;
    }

    dispatchChangeEvent (changedValue) {
        this.dispatchEvent(
            new CustomEvent('stepconfigchanged', {
                detail: {
                    value: changedValue
                }
            })
        );
    }

    dispatchModalClosedEvent () {
        this.dispatchEvent(
            new CustomEvent('stepconfigclosed')
        );
    }

    handleNext () {
        this.selectStepProperties = true;
    }

    handleAddParameter () {

        const stepParameters = this._processStepRecord.stepParameters
            ? deepCopy(this._processStepRecord.stepParameters)
            : [];
        stepParameters.push({
            id: null,
            referenceId: guid(),
            parameterKey: null,
            parameterValue: null,
            valueType: STEP_PARAMETER_TYPES.FIELD_NAME,
            isFieldMappingType: true,
            isModified: true,
            processWizardStepId: this._processStepRecord.id,
        })

        this._processStepRecord = Object.assign({}, this._processStepRecord, {
            stepParameters: stepParameters
        });
    }

    async handleApply () {
        if (!await this.checkUIValidity()) {
            this.error = this.i18n.formValidation;
            return;
        }
        if ((this._processStepRecord.type === STEP_TYPES.URL
            || this._processStepRecord.type === STEP_TYPES.RECORDACTION)
            && !this.validateFieldAPIName()) {
            return;
        }
        this.reconcileStepDependency();

        this.error = null;

        this.dispatchChangeEvent(Object.assign({}, this._processStepRecord));
        this.clearState();
    }

    handleCancelModal () {
        this.dispatchModalClosedEvent();
        this.clearState();
    }

    handleCriteriaActionChange (event) {
        const newStepRecord = Object.assign({}, this._processStepRecord, {
            criteriaAction: event.detail.value
        });

        if (newStepRecord.criteriaAction !== DISABLE_STEP_VALUE) {
            newStepRecord.criteriaActionHelpText = null;
        }

        this._processStepRecord = newStepRecord;
    }

    handleCriteriaActionHelpTextChanged (event) {
        this.handleTextInputChange(
            'criteriaActionHelpText',
            event.target.value
        );
    }

    handleCriteriaModalRequest () {
        this.showExpressionSelector = true;
    }

    handleCriteriaRemoved () {
        this._processStepRecord = Object.assign({}, this._processStepRecord, {
            expressionId: null,
            expressionName: null,
            criteriaAction: null,
            criteriaActionHelpText: null
        });
    }

    handleDeleteParameter (event) {
        const stepParameters = this._processStepRecord.stepParameters
            ? deepCopy(this._processStepRecord.stepParameters)
            : [];
        const rowKey = event.currentTarget.getAttribute('data-row-key');
        const itemIdx = stepParameters.findIndex(item =>
            item.referenceId === rowKey
        );

        stepParameters.splice(itemIdx, 1);

        this._processStepRecord = Object.assign({}, this._processStepRecord, {
            stepParameters: stepParameters
        });
    }

    handleExpressionModalClosed () {
        this.showExpressionSelector = false;
    }

    handleExpressionSelected (event) {
        const criteriaExpression = event.detail.value;

        this.showExpressionSelector = false;
        this._processStepRecord.expressionId = criteriaExpression.id;
        this._processStepRecord.expressionName = criteriaExpression.name;

        if (isEmptyString(this._processStepRecord.criteriaAction)) {
            this._processStepRecord.criteriaAction = this.criteriaActionDefaultValue;
        }
    }

    handleExpressionViewModalClosed () {
        this.showExpressionViewModal = false;
    }

    handleIconPickerApply (event) {
        this._processStepRecord.iconName = event.detail.value;
        this.showIconPickerModal = false;
    }

    handleIconPickerClose () {
        this.showIconPickerModal = false;
    }

    handleIconPickerOpen () {
        this.showIconPickerModal = true;
    }

    handleIconRemoved () {
        this._processStepRecord.iconName = null;
    }

    handleStepTargetSelected (event) {
        const selectedTarget = event.detail.value;

        this._processStepRecord.target = selectedTarget.apiName;
        this._processStepRecord.namespace = selectedTarget.namespacePrefix;
        this._processStepRecord.targetLabel = selectedTarget.label;
        this._processStepRecord.targetId = selectedTarget.id;

        this.showStepSelector = false;
    }

    handleStepModalClosed () {
        this.showStepSelector = false;
    }

    handleStepModalRequest () {
        this.showStepSelector = true;
    }

    handleStepNameChanged (event) {
        this.handleTextInputChange('name', event.detail.value);
    }

    handleStepTargetChanged (event) {
        this.handleTextInputChange('target', event.detail.value);
    }

    handleStepTypeChange (event) {
        const stepTypeSet = new Set(Object.values(STEP_TYPES));
        if (stepTypeSet.has(event.detail.value)) {
            this._processStepRecord.type = event.detail.value;
            if (this.error === i18n.invalidStepType) {
                this.error = null;
            }
        } else {
            this.error = i18n.invalidStepType;
        }
    }

    handleOpenModalChanged () {
        this._processStepRecord.openAsModal = !this._processStepRecord.openAsModal;
    }

    handleStepIconNameChanged (event) {
        this.handleTextInputChange('iconName', event.detail.value);
    }


    handleStepParameterChange (event) {
        const rowKey = event.currentTarget.getAttribute('data-row-key');
        const field = event.currentTarget.getAttribute('data-field');

        const stepParameters = this.processStepRecord.stepParameters.map(item => {
            if (item.referenceId === rowKey) {
                item[field] = event.detail.value;
                item.isModified = true;
                item.isFieldMappingType = item.valueType === STEP_PARAMETER_TYPES.FIELD_NAME;
                if (field === 'valueType') {
                    item.parameterValue = null;
                }
            }
            return item;
        });

        this._processStepRecord = Object.assign({}, this._processStepRecord, {
            stepParameters: stepParameters
        });
    }

    handleStepRemoved () {
        this._processStepRecord.target = null;
        this._processStepRecord.namespace = null;
        this._processStepRecord.targetLabel = null;
        this._processStepRecord.targetId = null;
    }

    handleTooltipChanged (event) {
        this.handleTextInputChange('helpText', event.target.value);
    }

    handleStepDependencyValueSelect (event) {
        const selectedValue = event.detail.value;
        if (selectedValue) {
            this._processStepRecord.removeStepDependency = false;
            const availableItems = event.target.items;
            const selectedValueArray = selectedValue.split(';');
            const dependencyArray = selectedValueArray.map(item => {
                return {
                    id: null,
                    isModified: true,
                    dependentStepId: null,
                    referenceId: item,
                    dependentStepName: availableItems.find(opt => opt.value === item)?.label
                }
            });
            this._processStepRecord = Object.assign({}, this._processStepRecord, {
                dependentSteps: dependencyArray
            });
            this._processStepRecord.stepDependencyFlag = true;
        } else {
            this._processStepRecord.removeStepDependency = true;
        }
    }

    handleTextInputChange (fieldName, value) {
        let newValue = value;
        if (newValue) {
            newValue = value.trim();
        }

        this._processStepRecord[fieldName] = newValue;
    }

    handleViewCriteriaClick () {
        this.showExpressionViewModal = true;
    }

    handleViewStepClick (event) {
        event.preventDefault();

        if (this._processStepRecord) {
            let uri = '';
            const lwcUrl = `/lightning/setup/LightningComponentBundles/page?address=%2F`;
            switch (this._processStepRecord.type) {
                case STEP_TYPES.FLOW:
                    uri  = `${i18n.flowDesignerUrl}${this._processStepRecord.targetId}`;
                    break;
                case STEP_TYPES.TRANSACTION:
                    // eslint-disable-next-line max-len
                    uri = `${ROUTES.TRANSACTION_EDITOR}#/editor/${this._processStepRecord.targetId}`;
                    break;
                case STEP_TYPES.LWC:
                    uri = `${lwcUrl}${this._processStepRecord.targetId}`;
                    break;
                default:
                    uri = `/${this._processStepRecord.targetId}`
            }
            window.open(uri, '_blank');
        }
    }

    handlePreviewModalClose () {
        this.showPreviewModal = false;
    }

    handlePreviewWizardStep () {
        if (!this.checkUIValidity()) {
            this.error = this.i18n.formValidation;
            return;
        }
        if ((this._processStepRecord.type === STEP_TYPES.URL
            || this._processStepRecord.type === STEP_TYPES.RECORDACTION)
            && !this.validateFieldAPIName()) {
            return;
        }
        this.error = null;
        this.showPreviewModal = true;
    }

    get showPreviewMode () {
        return this.selectStepProperties && (this._processStepRecord
            && this._processStepRecord.type
            && (PREVIEW_MODE_SUPPORTED_TYPES.includes(this._processStepRecord.type)));
    }

    validateFieldAPIName () {
        const urlPathKeys = this._processStepRecord.target.match(/{\w*\.?\w*}/gm);
        const erroredFieldNames = [];
        if (urlPathKeys && urlPathKeys.length > 0) {
            urlPathKeys.forEach(field => {
                const fieldApiName = field.replace('{','').replace('}','');
                if (isNotUndefinedOrNull( this.fieldSchema[fieldApiName.toUpperCase()])) {
                    this._processStepRecord.target = this._processStepRecord.target.replace(
                        fieldApiName,
                        this.fieldSchema[fieldApiName.toUpperCase()]);
                } else if (!fieldApiName.includes(".")) {
                    erroredFieldNames.push (fieldApiName);
                }
            });
        }

        if (this._processStepRecord.type === STEP_TYPES.RECORDACTION
            && this.processStepRecord.stepParameters) {
            this.processStepRecord.stepParameters.forEach(parameter => {
                if (isNotUndefinedOrNull( this.fieldSchema[parameter.parameterKey.toUpperCase()])) {
                    parameter.parameterKey = this.fieldSchema[parameter.parameterKey.toUpperCase()];
                } else {
                    erroredFieldNames.push (parameter.parameterKey);
                }
            });
        }
        this.error = `${invalidArgs} ${erroredFieldNames.join(',')}`;
        return erroredFieldNames.length === 0;
    }

    async getFieldDefinition () {
        try {
            const resp = await getFieldDefinitionsForEntities([this.objectApiName]);
            if (resp && resp.data
                && Object.keys(resp.data).length > 0
                && resp.data[0].fieldDefinitions) {
                resp.data[0].fieldDefinitions.forEach(fieldDefinition => {
                    this.fieldSchema[fieldDefinition.apiName.toUpperCase()]
                        = fieldDefinition.apiName;
                });
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    reconcileStepDependency () {
        if (this._processStepRecord.removeStepDependency) {
            delete this._processStepRecord.dependentSteps;
        }
        delete this._processStepRecord.removeStepDependency;
    }

    handleDeveloperNameChanged (event) {
        this.handleTextInputChange('developerName', event.target.value);
    }

    setWizardStepDeveloperName () {
        if (!this._processStepRecord.developerName
            && !isEmptyString(this._processStepRecord.name)
            && this.wizardDevName) {
            const maxLength = 140;
            const stepDevRawString = this.wizardDevName + ' ' + this._processStepRecord.name;
            this._processStepRecord.developerName = this.getNewDeveloperName(
                stepDevRawString,
                maxLength
            );
        }
    }

    getNewDeveloperName (stepName, maxLength) {
        let developerName = normalizeDeveloperName(stepName, maxLength, '');
        /* const matchingWizards = (this.wizard.steps && this.wizard.steps.length > 0) ?
            this.wizard.steps.filter(step =>
                step?.developerName?.startsWith(developerName) &&
                step.referenceId !== this._processStepRecord.referenceId
            ) : []; */
        const matchingWizards = [];
        this.wizardStepDevNames.forEach(stepDevObj => {
            if (stepDevObj.stepDevName
                && stepDevObj.stepDevName.startsWith(developerName)
                && stepDevObj.stepReferenceId !== this._processStepRecord.referenceId) {
                matchingWizards.push(stepDevObj.stepDevName);
            }
        });
        if (matchingWizards && matchingWizards.length > 0) {
            const matchCount = matchingWizards.length;
            const adjustedMaxLength = maxLength - matchCount.toString().length;
            developerName = developerName.substring(0, adjustedMaxLength).concat(matchCount);
        }

        return developerName;
    }

    updateUrlStepDevName () {
        if (this.showAsPlainText) {
            this.setWizardStepDeveloperName();
        }
    }
}