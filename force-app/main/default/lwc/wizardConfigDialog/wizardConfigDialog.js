import { LightningElement, api, track } from 'lwc';
import {
    deepCopy,
    formatString,
    isEmptyString,
    guid,
    normalizeDeveloperName,
    parseErrorMessage,
    verifyApiResponse
} from 'c/utils';

import isDeveloperNameAvailable
    from '@salesforce/apex/ADM_DeveloperNameLightningService.isDeveloperNameAvailable';

import labelApply from '@salesforce/label/c.Button_Apply';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelCriteriaWizard from '@salesforce/label/c.Label_CriteriaWizard';
import labelWizardProperties from '@salesforce/label/c.Title_WizardProperties';
import labelWizardNameMissing from '@salesforce/label/c.Message_WizardNameMissing';
import labelSelectCriteriaPlaceholder from '@salesforce/label/c.Placeholder_SelectCriteria';
import labelPlaceholderWizardName from '@salesforce/label/c.Placeholder_WizardName';
import labelWizardName from '@salesforce/label/c.Label_WizardName';
import labelTooltipHelp from '@salesforce/label/c.Label_TooltipHelp';
import labelView from '@salesforce/label/c.Label_View';
import labelFlowDesignerUrl from '@salesforce/label/c.URL_FlowDesigner';
import labelEnterDeveloperName from '@salesforce/label/c.Message_EnterDeveloperName';
import labelSelectExpression from '@salesforce/label/c.Title_SelectExpression';
import labelWizardDeveloperNameExists from '@salesforce/label/c.Message_WizardDeveloperNameExists';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelWarningTitle from '@salesforce/label/c.Warning_Title';
import labelStepCompTypeWarningTitle from '@salesforce/label/c.Step_Comp_Type_Warning_Title';
import labelStepDependencyType from '@salesforce/label/c.Label_StepDependencyType';
import labelStepDepTooltip from '@salesforce/label/c.Label_StepDependencyTooltip';

const i18n = {
    apply: labelApply,
    cancel: labelCancel,
    criteria: labelCriteriaWizard,
    description: labelDescription,
    developerName: labelDeveloperName,
    flowDesignerUrl: labelFlowDesignerUrl,
    formValidation: labelFormValidation,
    modalTitle: labelWizardProperties,
    nameMissing: labelWizardNameMissing,
    developerNameMissing: labelEnterDeveloperName,
    selectCriteria: labelSelectCriteriaPlaceholder,
    selectExpression: labelSelectExpression,
    wizardName: labelWizardName,
    wizardNamePlaceholder: labelPlaceholderWizardName,
    tooltip: labelTooltipHelp,
    view: labelView,
    developerNameExists: labelWizardDeveloperNameExists,
    confirm: labelConfirm,
    warningTitle: labelWarningTitle,
    stepCompTypeWarningTitle: labelStepCompTypeWarningTitle,
    stepDependencyType: labelStepDependencyType,
    stepDepTooltip: labelStepDepTooltip
};

const DEFAULT_SCOPE = 'Object';
const CHECKLIST = 'Checklist';
const STANDARD = 'Standard';

export default class WizardConfigDialog extends LightningElement {
    @track error;
    @track showExpressionSelector = false;
    @track showExpressionViewModal = false;
    @track _modalOpen = false;
    @track _wizardRecord = this.initializeWizardRecord();
    @track _objectApiName;
    openStepDependencyConfirm = false;
    stepSwitchWarningMessageItems=[];

    @api wizards = [];

    /**
     * If true, specifies the wizard is active.
     * @type {boolean}
     */
    @api
    get active () {
        return this._wizardRecord ? this._wizardRecord.active : undefined;
    }

    set active (newValue) {
        if (this._wizardRecord) {
            this._wizardRecord.active = newValue;
        }
    }

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

    /**
     * This value is used to filter expressions for a specific Salesforce Object
     * @type {string}
     */
    @api
    get objectApiName () {
        return this._objectApiName;
    }
    set objectApiName (newValue) {
        this._objectApiName = newValue;

        if (this._wizardRecord) {
            this._wizardRecord.objectAPIName = newValue;
        }
    }

    /**
     * This value represents a record from the CONF_ProcessWizard__c object.
     * @type {object}
     */
    @api
    get wizardRecord () {
        if (!this._wizardRecord) {
            this._wizardRecord = this.initializeWizardRecord();
        }

        return this._wizardRecord;
    }
    set wizardRecord (newValue) {
        if (!newValue) {
            this._wizardRecord = null;
            return;
        }

        this._wizardRecord = deepCopy(newValue);
    }

    /**
     * This value represents how wizards are ordered when displayed among other wizards.
     * @type {number}
     */
    @api
    get sequence () {
        return this._wizardRecord ? this._wizardRecord.sequence : undefined;
    }

    set sequence (newValue) {
        if (this._wizardRecord) {
            this._wizardRecord.sequence = newValue;
        }
    }

    get criteriaLookupValue () {
        if (
            this._wizardRecord &&
            this._wizardRecord.expressionId &&
            this._wizardRecord.expressionName
        ) {
            return {
                label: this._wizardRecord.expressionName,
                value: this._wizardRecord.expressionId,
                iconName: 'utility:filterList'
            };
        }

        return null;
    }

    get developerNameEditable () {
        return this.isNewRecord;
    }

    get developerNameInput () {
        return this.template.querySelector('.developer-name');
    }

    get expressionId () {
        if (this._wizardRecord &&
            this._wizardRecord.expressionId
        ) {
            return this._wizardRecord.expressionId;
        }

        return null;
    }

    get i18n () {
        return i18n;
    }

    get isNewRecord () {
        return !this._wizardRecord || isEmptyString(this._wizardRecord.id);
    }

    get selectedProfiles () {
        if (this._wizardRecord && this._wizardRecord.access) {
            return this._wizardRecord.access.map(element => element.profileId);
        }

        return [];
    }

    get stepTypeDepOptions () {
        return [
            { label: STANDARD, value: STANDARD },
            { label: CHECKLIST, value: CHECKLIST },
        ];
    }

    get existingStepDependencyType () {
        return this._wizardRecord.stepDependencyType;
    }

    get stepDependencyTypeFlag () {
        return this._wizardRecord.stepDependencyType === CHECKLIST;
    }

    async checkDeveloperNameValidity () {
        if (!this.developerNameEditable) {
            return true;
        }

        let validityMessage = '';

        // Check for developer name uniqueness.
        if (this._wizardRecord
            && !isEmptyString(this._wizardRecord.developerName))
        {
            const nameExists = await this.developerNameExists();

            if (nameExists) {
                const formattedMessage = formatString(
                    i18n.developerNameExists,
                    this._wizardRecord.developerName
                );

                validityMessage = formattedMessage;
            }
        }

        this.developerNameInput.setCustomValidity(validityMessage);
        return this.developerNameInput.reportValidity();
    }

    clearState () {
        this._wizardRecord = this.initializeWizardRecord();
        this.error = null;
    }

    developerNameExists () {
        return this.developerNameExistsInLocalCollection()
            .then( nameExistsWithinLocalCollection => {
                if (nameExistsWithinLocalCollection) {
                    return true;
                }

                return isDeveloperNameAvailable({
                    application: 'ProcessWizard',
                    developerName: this._wizardRecord.developerName
                });
            })
            .then ( result => {
                if (typeof result === 'boolean') {
                    return result;
                }

                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                return !result.data;
            })
    }

    async developerNameExistsInLocalCollection () {
        let nameExists = false;

        if (this.wizards && this.wizards.length > 0) {
            const filteredWizards = this.wizards
                .filter(wizard => wizard.referenceId !== this._wizardRecord.referenceId);

            nameExists = filteredWizards
                .some(wizard => wizard.developerName === this._wizardRecord.developerName);
        }

        return nameExists;
    }

    dispatchChangeEvent (changedValue) {
        this.dispatchEvent(
            new CustomEvent('wizardconfigchanged', {
                detail: {
                    value: changedValue
                }
            })
        );
    }

    dispatchModalClosedEvent () {
        this.dispatchEvent(
            new CustomEvent('wizardconfigclosed')
        );
    }

    getNewDeveloperName (wizardName, maxLength) {
        let developerName = normalizeDeveloperName(wizardName, maxLength, '');

        const matchingWizards = (this.wizards && this.wizards.length > 0) ?
            this.wizards.filter(wizard =>
                wizard.developerName.startsWith(developerName)
                && wizard.referenceId !== this._wizardRecord.referenceId
            ) : [];

        if (matchingWizards && matchingWizards.length > 0) {
            const matchCount = matchingWizards.length + 1;

            const adjustedMaxLength =
                maxLength - matchCount.toString().length;

            developerName = developerName
                .substring(0, adjustedMaxLength)
                .concat(matchCount);
        }
        return developerName;
    }

    async handleApply () {
        try {
            const uiValid = await this.checkUIValidity();
            if (!uiValid) {
                this.error = this.i18n.formValidation;
                return;
            }
            this.reconcileStepDependency();
            this.error = null;
            this.dispatchChangeEvent(Object.assign({}, this._wizardRecord));
            this.clearState();

        } catch (error) {
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

    handleCancelModal () {
        this.dispatchModalClosedEvent();
        this.clearState();
    }

    handleCriteriaModalRequest () {
        this.showExpressionSelector = true;
    }

    handleCriteriaRemoved () {
        this._wizardRecord = Object.assign({}, this._wizardRecord, {
            expressionId: null,
            expressionName: null
        });
    }

    handleDeveloperNameChanged (event) {
        this.handleTextInputChange('developerName', event.target.value);
    }

    handleExpressionModalClosed () {
        this.showExpressionSelector = false;
    }

    handleExpressionSelected (event) {
        const criteriaExpression = event.detail.value;

        this.showExpressionSelector = false;
        this._wizardRecord.expressionId = criteriaExpression.id;
        this._wizardRecord.expressionName = criteriaExpression.name;
    }

    handleExpressionViewModalClosed () {
        this.showExpressionViewModal = false;
    }

    handleProfileSelected (event) {
        this._wizardRecord.access = event.detail.value.map(element => {
            return {
                profileId: element,
                isModified: true
            };
        });
    }

    handleTextInputChange (fieldName, value) {
        let newValue = value;
        if (newValue) {
            newValue = value.trim();
        }

        this._wizardRecord[fieldName] = newValue;
    }

    handleViewCriteriaClick () {
        this.showExpressionViewModal = true;
    }

    handleWizardDescriptionChanged (event) {
        this.handleTextInputChange('description', event.target.value);
    }

    handleWizardNameBlur () {
        if (this.isNewRecord
            && !this._wizardRecord.developerName
            && !isEmptyString(this._wizardRecord.name)) {
            const maxLength = this.developerNameInput.maxLength;

            this._wizardRecord.developerName = this.getNewDeveloperName(
                this._wizardRecord.name,
                maxLength
            );

            this.developerNameInput.value = this._wizardRecord.developerName;
        }
    }

    handleWizardNameChanged (event) {
        this.handleTextInputChange('name', event.target.value);
    }

    handleStepDependencyTypeChange (event) {
        const stepDependencyValue = event.target.checked ? CHECKLIST : STANDARD;
        if (stepDependencyValue === CHECKLIST) {
            this.handleTextInputChange('stepDependencyType', stepDependencyValue);
        } else {
            const depStepArray = this.buildStepDependencyWarningMessage();
            if (depStepArray.length > 0) {
                this.stepSwitchWarningMessageItems = depStepArray;
                this.openStepDependencyConfirm = true;
            } else {
                this.handleTextInputChange('stepDependencyType', stepDependencyValue);
            }
        }
        this.handleTextInputChange('stepDependencyType', stepDependencyValue);
    }

    initializeWizardRecord () {
        return {
            id: null,
            active: true,
            isVisible: true,
            description: null,
            developerName: null,
            lastModifiedDate: null,
            lastModifiedBy: null,
            name: null,
            objectAPIName: null,
            scope: DEFAULT_SCOPE,
            sequence: null,
            expressionId: null,
            expressionName: null,
            referenceId: guid(),
            stepDependencyType: null,
            steps: [],
            access: []
        };
    }

    buildStepDependencyWarningMessage () {
        const depStepWarningArray = []; let i=0;
        // eslint-disable-next-line no-unused-expressions
        this._wizardRecord?.steps?.forEach(step => {
            if (step.dependentSteps) {
                step.dependentSteps.forEach(depStep => {
                    depStepWarningArray.push({ "id": i,
                        "step": step.name,
                        "depStep": depStep.dependentStepName
                    });
                    i++;
                });
            }
        });
        return depStepWarningArray;
    }

    reconcileStepDependency () {
        // eslint-disable-next-line no-unused-expressions
        this._wizardRecord?.steps?.forEach(step => {
            if (step.removeStepDependency) {
                delete step.dependentSteps;
            }
            delete step.removeStepDependency;
        });
    }

    markStepDependencyForDeletion () {
        this._wizardRecord.steps.forEach(step => {
            // eslint-disable-next-line no-prototype-builtins
            if (step.hasOwnProperty('dependentSteps')) {
                step.removeStepDependency = true;
            }
        });
    }

    handleStepDepCancel () {
        this.openStepDependencyConfirm = false;
        this.handleTextInputChange('stepDependencyType', CHECKLIST);
    }

    handleStepDepConfirm () {
        this.openStepDependencyConfirm = false;
        this.markStepDependencyForDeletion ();
        this.handleTextInputChange('stepDependencyType', STANDARD);
    }
}