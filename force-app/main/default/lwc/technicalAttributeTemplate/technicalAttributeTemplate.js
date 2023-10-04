import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labeltechAttrTemplate from
    '@salesforce/label/c.Label_TechnicalAttributeTemplate';
import labelName from '@salesforce/label/c.Label_Template_Name';
import labeldeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labeldeveloperNameMissing from
    '@salesforce/label/c.Label_DeveloperNameMissing';
import labelEnterDescription from
    '@salesforce/label/c.Label_EnterDescription';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelStatus from '@salesforce/label/c.Label_Status';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelNext from '@salesforce/label/c.Button_Next';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelUpdatedTATemp from
    '@salesforce/label/c.Label_UpdatedTechnicalAttributeTemplate';
import labelCreatedTATemp from
    '@salesforce/label/c.Label_CreatedTechnicalAttributeTemplate';
import labelTemplateDeleteMessage from '@salesforce/label/c.Message_TemplateDeleteMessage';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelTemplateDeleteMessageSuccess
    from '@salesforce/label/c.Message_TemplateDeleteMessageSuccess';
import labelDeleteTechnicalAttributeTemplate
    from '@salesforce/label/c.Message_DeleteTechnicalAttributeTemplate';

import saveTechnicalAttributeTemplate
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplate';
import cloneTechnicalAttributeTemplate
    from '@salesforce/apex/TA_TechnicalAttribute_LS.cloneTechnicalAttributeTemplate';
import deleteTechnicalAttributeTemplate
    from '@salesforce/apex/TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplate';
import labelFieldRequired from '@salesforce/label/c.Message_FieldRequired';

import {
    normalizeDeveloperName,
    isEmptyString,
    verifyApiResponse,
    parseErrorMessage,
    PAGE_ACTION_TYPES
} from 'c/utils';

const i18n = {
    techAttrTemplate: labeltechAttrTemplate,
    name: labelName,
    developerName: labeldeveloperName,
    developerNameMissing: labeldeveloperNameMissing,
    enterDescription: labelEnterDescription,
    description: labelDescription,
    status: labelStatus,
    cancel: labelCancel,
    next: labelNext,
    loading: labelLoading,
    updatedTATemp: labelUpdatedTATemp,
    createdTATemp: labelCreatedTATemp,
    templateDeleteMessage: labelTemplateDeleteMessage,
    confirm: labelConfirm,
    templateDeleteMessageSuccess: labelTemplateDeleteMessageSuccess,
    deleteTechnicalAttributeTemplate: labelDeleteTechnicalAttributeTemplate,
    fieldRequired: labelFieldRequired
}
export default class TechnicalAttributeTemplate extends NavigationMixin (LightningElement) {
    @track showTemplateSection = true;
    @track templateRecord = this.initializeTemplateRecord();
    @track apiInProgress = false;
    @track error;

    cloneAction;
    recordId;
    deleteTemplateDialog = false;
    viewUpdateModeVal = false;

    get isNewRecord () {
        return !this.templateRecord || isEmptyString(this.templateRecord.id) || this.recordId;
    }

    get developerNameEditable () {
        return this.isNewRecord;
    }

    get i18n () {
        return i18n;
    }

    // To fetch the record Id in clone
    @wire(CurrentPageReference)
    getStateParameters (currentPageReference) {

        if ( currentPageReference && currentPageReference.state.recordId ) {
            this.recordId = currentPageReference.state.recordId;
            this.handleCloneTemplate();
        }

    }

    handleTextInputChange (fieldName, value) {
        let newValue = value;
        if (newValue) {
            newValue = value.trim();
        }

        this.templateRecord[fieldName] = newValue;
    }

    handleTemplateNameChanged (event) {
        this.handleTextInputChange('name', event.target.value);
    }

    handleTemplateNameBlur () {
        if (this.isNewRecord
            && !this.templateRecord.developerName
            && !isEmptyString(this.templateRecord.name)) {

            const maxLength = this.developerNameInput.maxLength;
            this.developerNameInput.value =
                normalizeDeveloperName(this.templateRecord.name, maxLength, '');
            this.handleTextInputChange('developerName', this.developerNameInput.value);
        }
    }

    handleDeveloperNameChanged (event) {
        this.error = null;
        this.handleTextInputChange('developerName', event.target.value);
    }

    handleDescriptionChanged (event) {
        this.handleTextInputChange('description', event.target.value);
    }

    get developerNameInput () {
        return this.template.querySelector('.svmx-template-detail_developerName');
    }

    get statusToggle () {
        if ( this.templateRecord && this.templateRecord.status === 'Active' ) {
            return true;
        }
        return false;
    }

    handleCloneTemplate () {
        this.apiInProgress = true;
        this.cloneAction = PAGE_ACTION_TYPES.CLONE;
        cloneTechnicalAttributeTemplate({
            templateId: this.recordId
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.templateRecord = JSON.parse(JSON.stringify(result.data));
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    handleSaveTemplate () {
        this.apiInProgress = true;
        this.error = null;
        saveTechnicalAttributeTemplate({
            requestJson: JSON.stringify(this.templateRecord)
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg = `${this.templateRecord.id ?
                    this.i18n.createdTATemp : this.i18n.createdTATemp} - ${result.data.name}`;
                const evt = new ShowToastEvent({
                    title: toastMsg,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.templateRecord = JSON.parse(JSON.stringify(result.data));
                this.showTemplateSection = false;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    handleShowTemplateSection () {
        this.showTemplateSection = true;
    }

    handleCancel () {
        if ( this.templateRecord.id ) {
            this.deleteTemplateDialog = true;
        }
        else {
            this.redirectToTemplateList();
        }
    }

    handleTemplateDeleteCancelModal () {
        this.deleteTemplateDialog = false;
    }

    confirmDeleteTemplate () {
        this.deleteTemplateRecord();
    }

    deleteTemplateRecord () {
        this.apiInProgress = true;
        deleteTechnicalAttributeTemplate({ templateId: this.templateRecord.id })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const evt = new ShowToastEvent({
                    title: i18n.templateDeleteMessageSuccess,
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                this.redirectToTemplateList();
                this.deleteTemplateDialog = false;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    redirectToTemplateList () {
        const pageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SVMXA360__SM_TA_Template__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        };

        this[NavigationMixin.GenerateUrl](pageRef)
            .then(url => { window.open( url, '_self' ); });
    }

    initializeTemplateRecord () {

        return {
            id: null,
            description: null,
            developerName: null,
            name: null,
            status: 'Inactive'
        };

    }

    get disableSave () {
        if ( !this.templateRecord.name || !this.templateRecord.developerName || this.error ) {
            return true;
        }
        return false;
    }
}