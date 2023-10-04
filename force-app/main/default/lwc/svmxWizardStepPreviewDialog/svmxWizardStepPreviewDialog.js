import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import {
    STEP_PARAMETER_TYPES,
    isSalesforceId,
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    populateAttributeForLaunchingWizardStep,
    computeStepIconName
} from 'c/utils';

import Button_CancelModal from '@salesforce/label/c.Btn_Cancel';
import Button_RunPreview from '@salesforce/label/c.Button_RunPreview';
import Label_recordID from '@salesforce/label/c.Label_RecordId';
import Message_RunPreview from '@salesforce/label/c.Message_RunPreview';
import Title_PreviewStep from '@salesforce/label/c.Title_PreviewStep';
import Label_RequiredFieldMessage from '@salesforce/label/c.Label_RequiredFieldMessage';
import recordIdHelpText from '@salesforce/label/c.Help_Text_RecordId';
import invalidRecordId from '@salesforce/label/c.Error_RecordIdNotValid';

const i18n = {
    cancel: Button_CancelModal,
    runPreview: Button_RunPreview,
    msg_RunPreview: Message_RunPreview,
    recordLabel: Label_recordID,
    previewStepTitle: Title_PreviewStep,
    requiredFieldMessage: Label_RequiredFieldMessage,
    recordIdHelpText: recordIdHelpText,
    invalidRecordId: invalidRecordId
}
export default class SvmxWizardStepPreviewDialog extends LightningElement {

    @track recordId;
    @track fields = [];
    @track currRecord;
    @track paramMapping;
    @track _objectApiName;
    @track _processStepRecord;
    @track disablerunpreview = "disabled";
    @track error;
    @api isOpen;
    @api
    get objectApiName () {
        return this._objectApiName;
    }
    set objectApiName (value) {
        this._objectApiName = value;
    }

    get i18n () {
        return i18n;
    }

    get parameterList () {
        return [];
    }

    @api
    get processStepRecord () {
        return this._processStepRecord;
    }

    set processStepRecord (value) {
        this._processStepRecord =  JSON.parse(JSON.stringify(value));
        if (this._processStepRecord
            && this._processStepRecord.stepParameters
            && this._processStepRecord.stepParameters.length > 0) {
            this._processStepRecord.stepParameters.forEach(parameter => {
                parameter.editable = (parameter.valueType !== STEP_PARAMETER_TYPES.FIELD_NAME);
                parameter.value = (parameter.valueType !== STEP_PARAMETER_TYPES.FIELD_NAME)
                    ? parameter.parameterValue : '';
            });
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: '$fields'
    })
    fetchedRecord ({ error, data }) {
        if (data) {
            this.error = null;
            this.currRecord = data;
            if (this._processStepRecord
                && this.processStepRecord.stepParameters
                && this.processStepRecord.stepParameters.length > 0) {
                this.processStepRecord.stepParameters.forEach(parameter => {
                    if (parameter.valueType === STEP_PARAMETER_TYPES.FIELD_NAME) {
                        parameter.value = this.currRecord.fields[parameter.parameterValue].value;
                    }
                });
            }
            this.disablerunpreview = false;
        }
        if (error) {
            this.error = error.body.message;
        }
    }

    handleCloseModalClick () {
        const selectedEvent = new CustomEvent('modalclosed',
            {
                detail: true
            });
        this.dispatchEvent(selectedEvent);
    }

    handleRunPreview () {
        if (isUndefinedOrNull(this.recordId)) {
            return;
        }
        if (this.error && this.error !== i18n.invalidRecordId) {
            return;
        }
        if (!isSalesforceId (this.recordId) || this.recordId.length !== 18) {
            this.error = i18n.invalidRecordId;
            return;
        }
        this.error = null;
        this.prepareMapping();
        const attributes = populateAttributeForLaunchingWizardStep(
            this._processStepRecord,
            this.paramMapping,
            this.currRecord,
            true
        );
        let uri='/lightning/cmp/SVMXA360__SvmxFlowLauncher?';
        uri += Object.keys(attributes).map(key => {
            return `${key}=${encodeURIComponent(attributes[key])}`;
        }).join('&');
        window.open(uri,'_blank');
    }

    get computedIconName () {
        return computeStepIconName(this.processStepRecord.iconName, this.processStepRecord.type);
    }

    get hasParameters () {
        return this.processStepRecord &&
            this.processStepRecord.stepParameters
            && this.processStepRecord.stepParameters.length > 0;
    }

    handleRecordIdChange (event) {
        const value = event.detail.value;
        if (value.length === 18
            && isSalesforceId (value)) {
            this.recordId = value;
            const fieldArr = [];
            fieldArr.push (`${this.objectApiName}.Id`);
            if (this._processStepRecord
                && this.processStepRecord.stepParameters
                && this.processStepRecord.stepParameters.length > 0) {
                this.processStepRecord.stepParameters.forEach(parameter => {
                    if (parameter.valueType === STEP_PARAMETER_TYPES.FIELD_NAME) {
                        fieldArr.push (`${this.objectApiName}.${parameter.parameterValue}`);
                    }
                });
            }
            const urlPathKeys = this._processStepRecord.target.match(/{\w*\.?\w*}/gm);
            if (urlPathKeys && urlPathKeys.length >0) {
                urlPathKeys.forEach(field =>{
                    const fieldApiName = field.replace('{','').replace('}','');
                    if (fieldApiName.toLowerCase() !== 'ID') {
                        fieldArr.push(`${this.objectApiName}.${fieldApiName}`);
                    }
                });
            }
            if (fieldArr.length > 0) {
                this.fields = [...fieldArr];
            }
        } else {
            this.disablerunpreview = 'disabled';
        }
    }

    prepareMapping () {
        this.paramMapping = {};
        const params = this.template.querySelectorAll(".svmx-wizard-step-preview-param");
        if (isNotUndefinedOrNull(params)) {
            params.forEach(paramElement => {
                this.paramMapping[paramElement.name] = paramElement.value;
            });
        }
    }
}