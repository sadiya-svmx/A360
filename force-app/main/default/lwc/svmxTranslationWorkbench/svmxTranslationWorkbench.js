import { LightningElement, track, wire } from 'lwc';
import title_translationWorkbench from '@salesforce/label/c.Title_TranslationWorkbench';
import title_manageLanguage from '@salesforce/label/c.Title_ManageLanguages';
import title_editLanguage from '@salesforce/label/c.Title_EditLanguages';
import button_manageTranslation from '@salesforce/label/c.Button_ManageTranslation';
import button_cancel from '@salesforce/label/c.Button_Cancel';
import button_update from '@salesforce/label/c.Button_Update';
import button_save from '@salesforce/label/c.Button_Save';
import label_context from '@salesforce/label/c.Label_Context';
import label_targetLanguage from '@salesforce/label/c.Label_TargetLanguage';
import label_masterText from '@salesforce/label/c.Label_MasterText';
import label_manageLanguage from '@salesforce/label/c.Title_ManageLanguages';
import label_translation from '@salesforce/label/c.Label_translation';
import placeholder_search from '@salesforce/label/c.Placeholder_Search';
import message_editLanguage from '@salesforce/label/c.Message_EditLanguage';
import message_selectLanguage from '@salesforce/label/c.Error_SelectLanguage';
import message_success from '@salesforce/label/c.Messge_TranslationSaved';
import message_unsavedChanges from '@salesforce/label/c.Messge_UnsavedChanges';
import title_editingItem from '@salesforce/label/c.Title_EditingItems';
import title_confirmUnsavedChanges from '@salesforce/label/c.Messge_UnsavedChangesConfirm';
import button_stayOnList from '@salesforce/label/c.Button_StayOnList';
import button_discardChanges from '@salesforce/label/c.Button_DiscardChanges';
import label_edit from '@salesforce/label/c.Menu_Edit';
import label_reset from '@salesforce/label/c.Menu_Reset';
import labelTranslationsHelp from '@salesforce/label/c.URL_TranslationsHelp';
import labelHelp from '@salesforce/label/c.Label_Help';
import {
    isUndefinedOrNull,
    isNotUndefinedOrNull,
    ICON_NAMES, isEmptyString,
    verifyApiResponse,
    parseErrorMessage,
    sortObjectArray,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTranslations
    from '@salesforce/apex/ADM_Translation_LS.getTranslations';
import getTranslationContexts
    from '@salesforce/apex/ADM_Translation_LS.getTranslationContexts';
import getSupportedLanguages
    from '@salesforce/apex/ADM_Translation_LS.getSupportedLanguages';
import upsertTranslatedTags
    from '@salesforce/apex/ADM_Translation_LS.upsertTranslatedTags';
import getTagDetails
    from '@salesforce/apex/ADM_Translation_LS.getTagDetails';
import { refreshApex } from '@salesforce/apex';

const MAX_ROWS = 200;
const i18n = {
    title_translationWorkbench: title_translationWorkbench,
    title_manageLanguage: title_manageLanguage,
    title_editLanguage: title_editLanguage,
    button_manageTranslation: button_manageTranslation,
    button_cancel: button_cancel,
    button_update: button_update,
    button_save: button_save,
    label_context: label_context,
    label_targetLanguage: label_targetLanguage,
    label_masterText: label_masterText,
    label_manageLanguage: label_manageLanguage,
    placeholder_search: placeholder_search,
    message_editLanguage: message_editLanguage,
    message_selectLanguage: message_selectLanguage,
    message_success: message_success,
    label_applicationConfiguration: 'Setup',
    label_translation: label_translation,
    message_unsavedChanges: message_unsavedChanges,
    title_editingItem: title_editingItem,
    title_confirmUnsavedChanges: title_confirmUnsavedChanges,
    button_stayOnList: button_stayOnList,
    button_discardChanges: button_discardChanges,
    label_edit: label_edit,
    label_reset: label_reset,
    help: labelHelp,
    helpLink: labelTranslationsHelp,
};

const DELAY = 500;
export default class SvmxTranslationWorkbench extends LightningElement {

    @track filteredListViewData = [];
    @track count =0;
    @track max=MAX_ROWS;

    @track draftValues = [];
    @track currDraftValues = [];
    @track data = [];
    @track defaultLanguage;
    @track defaultLanguageLabel ='';
    @track context = 'all';
    @track tempList = [];
    @track showLoading = true;
    @track searchVal;
    @track showManageLanguage;
    @track showEditTranslations;
    @track editedMasterText="this is master text";
    @track sortDirection = "asc";
    @track translatedList =[];
    @track translationContexts = [];
    @track langoptions = [];
    @track filteredLangoptions = [];
    @track languages =[];
    @track error;
    @track iconSize = 'large';
    @track showConfirmation=false;
    @track currentEditedrow;
    @track resultData;
    @track visitedLanguages = new Set();
    @track filteredData =  [];

    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }

    @wire(getTranslations,{ language: '$defaultLanguage' })
    fetchedData (result) {
        this.resultData = result;
        if (result.error) {
            this.showLoading = false
        }
        if (result.data) {
            this.filteredListViewData = [];
            this.filteredData = [];
            this.data = result.data;
            this.populateData().then(()=>{
                this.showLoading = false;
            });
            const recentlyViewedRecord = {
                configurationId: this.data.id,
                configurationName: ADMIN_MODULES.TRANSLATIONS,
                configurationType: ADMIN_MODULES.TRANSLATIONS
            };
            saveRecentViewItem(recentlyViewedRecord)
                .then(recentItem => {
                    if (!verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });
        }
    }

    @wire(getTranslationContexts,{})
    fetchedContexts ({ data }) {
        if (data) {
            this.translationContexts = data;
        }
    }
    @wire(getSupportedLanguages,{})
    fetchedLanguages ({ data }) {
        if (data) {
            this.langoptions =data;
            this.filteredLangoptions = JSON.parse(JSON.stringify(data));
            if (this.filteredLangoptions && this.filteredLangoptions.length ===0) {
                this.showLoading = false;
            }
            this.languages = data;
            this.langoptions.forEach(option => {
                if (option.isDefault) {
                    this.defaultLanguage = option.value;
                    this.defaultLanguageLabel = option.label;
                    this.showLoading =true;
                }
            });
            if (isUndefinedOrNull(this.defaultLanguage)
                && isNotUndefinedOrNull (this.langoptions)
                && this.langoptions.length > 0) {
                this.defaultLanguage = this.langoptions[0].value;
                this.defaultLanguageLabel = this.langoptions[0].label;
                this.showLoading =true;
            }
            this.visitedLanguages.add (this.defaultLanguage);
        }
    }

    get i18n () {
        return i18n;
    }

    get columns () {
        return [
            {
                label: i18n.label_context,
                fieldName: 'contextLabel',
                hideDefaultActions: true,
                sortable: true,
            },
            {
                label: i18n.label_masterText,
                fieldName: 'masterText',
                hideDefaultActions: true,
            },
            {
                label: this.translatedLabel,
                fieldName: 'translatedValue',
                hideDefaultActions: true,
                editable: 'true'
            },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                },
            }
        ];
    }

    get translatedLabel () {
        return isEmptyString(this.defaultLanguageLabel)
            ?  i18n.label_translation
            : `${i18n.label_translation} - ${this.defaultLanguageLabel}`;
    }

    loadMoreData (event) {
        event.target.isLoading = true;
        const dataTable = this.template.querySelector("c-x-datatable");
        this.currDraftValues = JSON.parse(JSON.stringify(dataTable.draftValues));
        this.populateData().then((hasmoreData)=>{
            const element = this.template.querySelector("c-x-datatable");
            dataTable.draftValues = this.currDraftValues;
            element.isLoading = false;
            if (!hasmoreData) {
                element.enableInfiniteLoading = hasmoreData;
            }
        });
    }

    handleLangChange (event) {
        this.defaultLanguage = event.target.value;
        this.defaultLanguageLabel = this.filteredLangoptions
            .find(langOption => langOption.value ===this.defaultLanguage).label;
        this.count = 0;
        this.max = MAX_ROWS;
        this.filteredListViewData = [];
        this.filteredData = [];
        this.showLoading = true;
        if (this.visitedLanguages.has (this.defaultLanguage)) {
            window.clearTimeout(this.delayTimeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                refreshApex(this.resultData);
            }, 300);
        } else {
            this.visitedLanguages.add (this.defaultLanguage);
        }
    }

    handleContextChange (event) {
        this.context = event.target.value;
        this.count = 0;
        this.max = MAX_ROWS;
        this.filteredListViewData = [];
        this.filteredData = [];
        this.showLoading = true;
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.populateData().then(() => {
                this.showLoading = false;
            });
        }, 50);
    }

    handleCellChange (event) {
        const data = event.detail.draftValues[0];
        const found = this.filteredListViewData.find(element => element.key === data.key);
        if (isNotUndefinedOrNull(found.translatedValue)
             || !isEmptyString(data.translatedValue)) {
            found.isChanged = true;
            found.changedValue = data.translatedValue;
            found.actions.find(element => element.name === 'Reset').disabled = false;
        } else {
            const dataTable = this.template.querySelector("c-x-datatable");
            const draftValue = dataTable.draftValues;
            const index = draftValue.findIndex(element => element.key === found.key);
            draftValue.splice(index,1);
            dataTable.draftValues = draftValue;
        }
    }

    getSlicedData () {
        const length = this.filteredData.length;
        if (length < (this.max + MAX_ROWS) && length > (this.count + MAX_ROWS)) {
            const slicedData = this.filteredData.slice(this.count, length);
            this.count = this.max;
            this.max += MAX_ROWS;
            return slicedData;
        } else if (length > this.max) {
            const slicedData = this.filteredData.slice(this.count, this.max);
            this.count = this.max;
            this.max += MAX_ROWS;
            return slicedData;
        } else if (length > this.max && this.count !== 0) {
            const slicedData = this.filteredData.slice(this.count, length);
            this.count = this.max;
            this.max += MAX_ROWS;
            return slicedData;
        }
        return this.filteredData;
    }

    async populateData () {
        if (this.filteredData.length === 0) {
            this.filteredData = this.data.filter(row => {
                return row.language === this.defaultLanguage
                && (this.context === 'all'
                    ? true
                    : row.context === this.context)
                && (this.searchVal
                    ? row.masterText.toLowerCase().indexOf (this.searchVal) > -1
                    : true);
            });
        }

        const slicedata = this.getSlicedData (this.filteredData);

        const newDataSet = slicedata.map(row => {
            return {
                key: row.tagId,
                context: row.context,
                contextLabel: row.contextLabel,
                masterText: row.masterText,
                translatedValue: row.translatedValue,
                changedValue: row.translatedValue,
                oldValue: row.translatedValue,
                isChanged: false,
                actions: [
                    { label: i18n.label_edit, name: 'edit' },
                    { label: i18n.label_reset, name: 'Reset',disabled: true }
                ]
            }
        });
        this.filteredListViewData = [...this.filteredListViewData, ...newDataSet];
        this.sortRows ();
        const element = this.template.querySelector("c-x-datatable");
        const diff = this.max - this.filteredData.length;
        if (element) {
            element.enableInfiniteLoading = (this.filteredData.length > this.max)
                || diff > MAX_ROWS ;
        }
        return (this.filteredData.length > this.max)
                || diff > MAX_ROWS ;
    }

    sortRows () {
        this.filteredListViewData = sortObjectArray (
            this.filteredListViewData,
            'contextLabel',
            this.sortDirection
        );
    }

    filterData (row) {
        return row.language === this.defaultLanguage
            && (this.context === 'All'
                ? true
                : row.SVMXA360__Context__c === this.context)
            && (this.searchVal
                ?row.SVMXA360__MasterText__c.toLowerCase().indexOf(this.searchVal) !==-1
                :true);
    }

    handleKeyUpForSearch (event) {
        window.clearTimeout(this.delayTimeout);
        const searchVal = event.target.value.trim().toLowerCase();
        if (searchVal && (searchVal.length >= 1 && searchVal.length < 3)) {
            return;
        }
        if ( searchVal.length === 0) {
            this.showLoading = true;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.searchVal = null;
                this.filteredListViewData = [];
                this.filteredData = [];
                this.count = 0;
                this.max = MAX_ROWS;
                this.populateData ().then(()=>{
                    this.showLoading = false;
                });
            }, DELAY);
        } else if (searchVal && searchVal.length > 2) {
            this.searchVal = searchVal;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.filteredListViewData = [];
                this.filteredData = [];
                this.count = 0;
                this.max = MAX_ROWS;
                this.showLoading = true;
                this.populateData ().then(()=>{
                    this.showLoading = false;
                });
            }, DELAY);
        }
    }

    handleRowAction (event) {
        const action = event.detail.action;
        this.currentEditedrow = event.detail.row;
        const draftValue = JSON.parse(JSON.stringify(event.target.draftValues));
        const index = draftValue.findIndex(element => element.key === this.currentEditedrow.key);
        const found = this.filteredListViewData
            .find(element => element.key === this.currentEditedrow.key);
        switch (action.name) {
            case 'edit':
                // eslint-disable-next-line no-case-declarations
                this.draftValues = this.template.querySelector("c-x-datatable").draftValues;
                if (isNotUndefinedOrNull(this.draftValues) && this.draftValues.length>0) {
                    this.showConfirmation = true;
                } else {
                    this.handleEditLanguages(event);
                }

                break;
            case 'Reset':
                found.isChanged = false;
                found.actions.find(element => element.name === 'Reset').disabled = true;
                found.translatedValue = found.oldValue;
                found.changedValue =  found.translatedValue;
                if (index > -1) {
                    draftValue.splice (index,1);
                    this.template.querySelector("c-x-datatable").draftValues = draftValue;
                }
                break;
            default:
                break;
        }
    }

    handleSortRows (event) {
        this.sortDirection = event.detail.sortDirection;
        this.sortRows ();
    }

    handleManageLanguage () {
        this.error = null;
        this.showManageLanguage = true;
    }

    handleCloseModalClick () {
        this.showManageLanguage = false;

    }

    handleUpdateLanguages () {
        const langElementList = this.template.querySelectorAll('.svmx-manage-language-list');
        const updatedLangSet = [...langElementList].map(element => {
            return {
                label: element.dataset.label,
                value: element.name,
                selected: element.checked,
                isDefault: element.disabled
            };
        });
        if (updatedLangSet.findIndex(lang => lang.selected) < 0) {
            this.error = message_selectLanguage;
        } else {
            this.languages = updatedLangSet;
            this.filteredLangoptions = this.languages.filter(language => language.selected);
            if (isUndefinedOrNull(this.filteredLangoptions
                .find(lang => lang.value === this.defaultLanguage))) {
                let updatedDefaultLanguage = false;
                this.filteredLangoptions.forEach(option => {
                    if (option.isDefault) {
                        this.defaultLanguage = option.value;
                        this.defaultLanguageLabel = option.label;
                        updatedDefaultLanguage = true;
                        this.showLoading =true;
                    }
                });
                if (!updatedDefaultLanguage
                    && this.defaultLanguage !== this.filteredLangoptions[0].value) {
                    this.defaultLanguage = this.filteredLangoptions[0].value;
                    this.defaultLanguageLabel = this.filteredLangoptions[0].label;
                    this.showLoading =true;
                }
            }
            this.showManageLanguage = false;
        }
    }

    handleSave (event) {
        const saveDraftValues = event.detail.draftValues;
        const tags = [];
        if (isNotUndefinedOrNull(saveDraftValues)  && saveDraftValues.length >0) {
            saveDraftValues.forEach(draftValue =>{
                const found = this.filteredListViewData
                    .find(element => element.key === draftValue.key);
                tags.push({
                    language: this.defaultLanguage,
                    context: found.context,
                    masterText: found.masterText,
                    translatedValue: draftValue.translatedValue,
                    tagId: found.key
                });
            });
        }
        this.showLoading = true;
        upsertTranslatedTags({ requestJson: JSON.stringify(tags) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                } else {
                    this.filteredListViewData.forEach(data =>{
                        data.translatedValue = data.changedValue;
                        data.oldValue = data.translatedValue;
                    });
                    this.count = 0;
                    this.max -= MAX_ROWS;
                    if (this.max <= 0) {
                        this.max = MAX_ROWS;
                    }
                    refreshApex(this.resultData);
                    this.showLoading = false;
                    const evt = new ShowToastEvent({
                        type: 'success',
                        message: i18n.message_success,
                        variant: 'success',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(evt);
                    this.template.querySelector("c-x-datatable").draftValues = [];
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.showLoading = false;
            });
    }

    handleCloseEditModalClick () {
        this.showEditTranslations = false;
    }

    handleSaveModal () {
        const tags = [];
        const saveDraftValues = [...this.template
            .querySelectorAll('.svmx-edit-multiple-languages')];
        if (isNotUndefinedOrNull(saveDraftValues)  && saveDraftValues.length >0) {
            saveDraftValues.forEach(draftValue =>{
                const found = this.filteredListViewData
                    .find(element => element.key === this.currentEditedrow.key);
                tags.push({
                    language: draftValue.dataset.name,
                    context: found.context,
                    masterText: found.masterText,
                    translatedValue: draftValue.value,
                    tagId: this.currentEditedrow.key
                });
            });
        }
        this.showLoading = true;
        upsertTranslatedTags({ requestJson: JSON.stringify(tags) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                } else {
                    this.count = 0;
                    this.max = MAX_ROWS;
                    refreshApex(this.resultData);
                    this.showLoading = false;
                    const evt = new ShowToastEvent({
                        type: 'success',
                        message: i18n.message_success,
                        variant: 'success',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.showLoading = false;
            });
        this.showEditTranslations = false;
    }

    handleCloseConfirmationClick () {
        this.template.querySelector("c-x-datatable").draftValues = this.draftValues;
        this.showConfirmation = false;
    }

    handleEditLanguages () {
        this.template.querySelector("c-x-datatable").draftValues = [];
        this.draftValues = [];
        if (isNotUndefinedOrNull(this.currentEditedrow)) {
            const found = this.filteredListViewData
                .find(element => element.key === this.currentEditedrow.key);
            this.showConfirmation = false;
            this.showLoading = true;
            getTagDetails({ translationTagId: found.key }).then(data => {
                this.translatedList = this.filteredLangoptions.map(lang => {
                    const langval = data.find(val => val.language === lang.value);
                    return {
                        label: lang.label,
                        name: lang.value,
                        value: langval?langval.translatedValue:null
                    };
                });
                this.editedMasterText = found.masterText;
                this.showLoading=false;

                this.showEditTranslations = true;
            });
        }
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

}