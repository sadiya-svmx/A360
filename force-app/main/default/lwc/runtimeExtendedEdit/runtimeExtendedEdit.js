import { LightningElement, api, track } from "lwc";
import {
    isNotUndefinedOrNull,
    deepCopy,
    parseErrorMessage,
    IS_MOBILE_DEVICE
} from "c/utils";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { EngineElement }  from 'c/runtimeEngineProvider';

import labelButtonCancel from "@salesforce/label/c.Button_Cancel";
import labelApply from "@salesforce/label/c.Button_Apply";
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelRemove from '@salesforce/label/c.Button_Remove';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import runtimeExtendedEditTemplate from './runtimeExtendedEdit.html';
import runtimeExtendedEditMobileTemplate from './runtimeExtendedEditMobile.html';
import messageRuntimeFieldsMissing from '@salesforce/label/c.Message_RequiredFieldMissing';

const i18n = {
    loading: labelLoading,
    buttonCancel: labelButtonCancel,
    buttonApply: labelApply,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    cancel: labelCancel,
    confirm: labelConfirm,
    remove: labelRemove,
    errorFieldsMissing: messageRuntimeFieldsMissing,
};

export default class RuntimeExtendedEdit extends EngineElement(LightningElement) {
    @track apiInProgress;
    @track error;
    @track engineId;
    @track _sections = [];
    @track deleteModalDialogOpen = false;
    @api title;
    @api rowIndex;
    @api tabIndex;
    @api editRecord = false;
    @api firstRecord = false;
    @api lastRecord = false;
    @api applyNext = () => ({});
    @api applyPrevious = () => ({});
    @api applyClone = () => ({});
    @api applyDelete = () => ({});
    @track tab = {};

    set sections (value) {
        this._sections = deepCopy(value);
    }

    get sections () {
        return this._sections;
    }

    get i18n () {
        return i18n;
    }

    get relativeToDebugpanel () {
        return this.isDebugEnabled;
    }

    render () {
        return IS_MOBILE_DEVICE ? runtimeExtendedEditMobileTemplate : runtimeExtendedEditTemplate;
    }

    get modalSize () {
        const section = this._sections[0];
        return section && section.columns === 2 ? "MEDIUM" : "";
    }

    async handleRecordModified (event) {
        event.stopPropagation();
        const { field } = event.detail;
        try {
            const fieldName = Object.keys(field || {})[0];
            const value = field[fieldName];

            this.apiInProgress = true;
            // waitiing here to show progress bar in the extedned edit, otherwise it not required
            await this.props.handleTemporaryChildRecordChange(
                this.tabIndex,
                this.rowIndex,
                fieldName,
                value
            );
            this.apiInProgress = false;
        } catch (e) {
            this.setError(e);
            this.apiInProgress = false;
        }
    }

    handleError (event) {
        const error = event.detail.error || event.detail;
        this.setError(error);

        event.stopPropagation();
    }

    handleModalSave () {
        if (IS_MOBILE_DEVICE) {
            const sections = [];
            this.template.querySelectorAll('c-runtime-section').forEach(section => {
                sections.push(section.reportAllValidity());
            });
            const validity = (sections[0] || []).findIndex(e => !e.validity && e.required);
            if (validity !== -1) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: i18n.errorFieldsMissing,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                return;
            }
        }
        this.props.handleCommitTemporaryChildLine(this.tabIndex,this.rowIndex);
        this.dispatchEvent(new CustomEvent("extendededitcancel"));
    }

    handleModalClose () {
        this.props.discardTemporaryChildLine(this.tabIndex,this.rowIndex);
        this.dispatchEvent(new CustomEvent("extendededitcancel"));
    }

    get hasError () {
        return isNotUndefinedOrNull(this.error);
    }

    handleDelete = () => {
        this.deleteModalDialogOpen = true;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.deleteModalDialogOpen = false;
        this.applyDelete();
    }

    get previousButtonColor () {
        return this.firstRecord ? '#d3d3d3' : '#1589EE'
    }

    get nextButtonColor () {
        return this.lastRecord ? '#d3d3d3' : '#1589EE'
    }

    get removeItemLabel () {
        const section =  this._sections[0];
        return `${i18n.remove} ${(section || {}).title}?`;
    }

    setError (error) {
        this.error = error && parseErrorMessage(error);
    }

    runtimeEngineUpdate (engineProps) {
        const tabs = engineProps.tabs;
        const tabFilter = (tabs || []).filter(t => t.name === this.tabIndex);
        if (tabFilter.length) {
            this.tab = tabFilter[0];
        }
        this.sections = engineProps.temporaryChildSections[this.tabIndex] || [];
        this.engineId = engineProps.engineId;
        this.isDebugEnabled = engineProps.isDebugEnabled;
    }
}