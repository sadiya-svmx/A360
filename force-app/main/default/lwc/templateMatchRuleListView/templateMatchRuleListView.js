/* eslint-disable max-len */
/* eslint-disable no-unused-vars */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getAllMatchRules from '@salesforce/apex/ADM_TechnicalAttribute_LS.getAllMatchRules';
import saveTemplateRulesSequence from '@salesforce/apex/ADM_TechnicalAttribute_LS.saveTemplateRulesSequence';
import deleteMatchRuleRecord from '@salesforce/apex/ADM_TechnicalAttribute_LS.deleteMatchRuleRecord';
import getApplicationSetting from '@salesforce/apex/ADM_ApplicationSettings_LS.getApplicationSetting';
import saveApplicationSettingRecord from '@salesforce/apex/ADM_ApplicationSettings_LS.saveApplicationSettingRecord';
import {
    parseErrorMessage,
    verifyApiResponse,
    sortObjectArray
} from 'c/utils';
import { deleteRecentItemRecords } from 'c/recentItemService';
import ICONS from '@salesforce/resourceUrl/pscIcons';
import labelNewButton from '@salesforce/label/c.Label_NewRule';
import labelMatchRuleHeader from '@salesforce/label/c.Label_MatchRulesHeader';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelDesc from '@salesforce/label/c.Label_Description';
import labelSave from '@salesforce/label/c.Btn_Save'
import labelMatchField from '@salesforce/label/c.Label_MatchRuleMatchField'
import labelMatchFieldMessage from '@salesforce/label/c.Label_MatchRuleMessage'
import labelMatchRuleSubtitle from '@salesforce/label/c.Label_MatchRulePageSubtitle'
import labelNoMatchRuleRecordMsg from '@salesforce/label/c.Label_NoRuleRecordMessage'
import labelSuccess from '@salesforce/label/c.Label_Success'
import labelRuleName from '@salesforce/label/c.Label_MatchRule_RuleName'
import labelModifiedBy from '@salesforce/label/c.Label_LastModifiedBy'
import labelModifiedDate from '@salesforce/label/c.Label_LastModified'
import labelButtonFirst from '@salesforce/label/c.Button_First'
import labelButtonAll from '@salesforce/label/c.Label_All'
import labelPageSuccessMsg from '@salesforce/label/c.Label_MatchRulePage_SuccessMsg'
import labelDeleteTitle from '@salesforce/label/c.Label_Delete_Modal_Title'
import labelDeleteBody from '@salesforce/label/c.Label_Delete_Modal'
import labelMatchRule from '@salesforce/label/c.Label_MatchRule'
import labelDragDrop from '@salesforce/label/c.Label_DragDrop'
import labelTemplateMatchRuleHelpLink from '@salesforce/label/c.Label_TemplateMatchRuleHelpLink';
const i18n = {
    helpLink: labelTemplateMatchRuleHelpLink,
    pageHeader: labelMatchRuleHeader,
    new: labelNewButton,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    help: labelHelp,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    loading: labelLoading,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteSuccess: labelDeletedSuccess,
    description: labelDesc,
    save: labelSave,
    matchField: labelMatchField,
    matchFieldMessage: labelMatchFieldMessage,
    matchRuleSubtitle: labelMatchRuleSubtitle,
    noMatchRuleRecordMsg: labelNoMatchRuleRecordMsg,
    success: labelSuccess,
    ruleName: labelRuleName,
    modifiedDate: labelModifiedDate,
    modifiedBy: labelModifiedBy,
    buttonFirst: labelButtonFirst,
    buttonAll: labelButtonAll,
    successMsg: labelPageSuccessMsg,
    deleteTitle: labelDeleteTitle,
    deleteBody: labelDeleteBody,
    matchRule: labelMatchRule,
    dragDrop: labelDragDrop
};

const MatchRule_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__matchRuleDetailAura'
    }
}
const TA_SettingName = 'Apply_Template';

export default class TemplateMatchRuleListView extends NavigationMixin(LightningElement) {
    selectedItemLabel;
    selectedRecord;
    toggleSwitchFirstVariant ="Brand";
    toggleSwitchAllVariant;
    selectedToggleBtn = "First";
    applicationSettingRec;
    objectIntoConsideration = "Asset";
    disableCancelSaveBtn = true;
    noRecordMessage;
    previousListViewDatastate = [];
    previousToggleBtnState;
    apiInProgress;
    i18n = i18n;
    @track listViewData = [];
	deleteModalDialogOpen = false;
    logoUrl = `${ICONS}/pscIcons/ServiceMax_Logo.svg`;
    currentNavItem;
    init () {
        this.apiInProgress = true;
        return getAllMatchRules({
        }).then(result => {
            this.apiInProgress = false;
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.listViewData = result.data;
            if ( this.listViewData === undefined || this.listViewData.length === 0) {
                this.noRecordMessage = i18n.noMatchRuleRecordMsg;
            } else {
                this.noRecordMessage = '';
                this.previousListViewDatastate = JSON.parse(JSON.stringify(this.listViewData));
            }
            this.loadApplicationSettings();
        }).catch(error => {
            this.error = error;
            this.apiInProgress = false;
        })
    }
    loadApplicationSettings () {
        return getApplicationSetting({
            developerName: TA_SettingName
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.applicationSettingRec = result.data;
                this.setToggleBtnSettings(result.data.settingValue);
                this.previousToggleBtnState = this.selectedToggleBtn;
            }).catch(error => {
                this.error = error;
                this.apiInProgress = false;
            })
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        if (pageRef) {
            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.init();
        }
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](MatchRule_DETAIL_VIEW).then(url => {
            this.timelineConfigDetailUrl = url;
            //this.init();
        });
    }

    onDragStart ( event ) {
        this.dragStart = event.target.dataset.seq;
        event.target.classList.add("drag");
    }

    onDragOver ( event ) {
        event.preventDefault();
        return false;
    }

    // eslint-disable-next-line consistent-return
    onDrop ( event ) {
        event.stopPropagation();
        const currentIndex = this.dragStart;
        const newIndex = event.target.dataset.seq;
        if (currentIndex === newIndex || newIndex === '') {
            return false;
        }
        const tempRecordList = this.listViewData;
        const targetRec = tempRecordList.splice(currentIndex, 1)[0];
        tempRecordList.splice(newIndex, 0, targetRec);
        this.disableCancelSaveBtn = false;
        let count = 1;
        tempRecordList.forEach( rec => {
            rec.sequence = count;
            count++;
        });
        this.listViewData = tempRecordList;
    }

    handleOnselect ( event ) {
        const selectedRecordId = event.target.dataset.name;
        this.selectedRecord = this.listViewData.find(obj => { return obj.id === selectedRecordId })
        this.selectedItemLabel = event.detail.value;
        if ( this.selectedItemLabel === 'edit' ) {
            //call method for edit
            this.navigateToDetailPage ('Edit', selectedRecordId);
        } else if ( this.selectedItemLabel === 'clone' ) {
            //call method for copy
            this.navigateToDetailPage ('Clone', selectedRecordId);
        } else if ( this.selectedItemLabel === 'delete' ) {
            //call method for delete
            this.deleteModalDialogOpen = true;
        }
    }

    handleDelete () {
        this.apiInProgress = true;
        this.deleteModalDialogOpen = false;
        const recentlyViewedRecord = [{
            configurationId: this.selectedRecord.id
        }];
        return deleteMatchRuleRecord({
            "matchRuleId": this.selectedRecord.id
        }).then( result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            deleteRecentItemRecords(recentlyViewedRecord).then(recentItem => {
                if (recentItem && !verifyApiResponse(recentItem)) {
                    this.error = recentItem.message;
                }
            });
            const toastMsg =  `${this.i18n.matchRule} "${this.selectedRecord.ruleName}" ${this.i18n.deleteSuccess}`;
            this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
            this.disableCancelSaveBtn = true;
            this.init();
        })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });

    }

    handleCancelModal ( event ) {
        this.deleteModalDialogOpen = false;
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    ruleNameClick (event) {
        this.navigateToDetailPage ('Edit', event.target.dataset.name);
    }

    handleNewClick (event) {
        this.navigateToDetailPage ('New', null);
    }

    navigateToDetailPage (action, recordId) {
        const navState = {
            c__actionName: action
        }

        if (recordId) {
            navState.c__recordId = recordId;
        }

        if (action === 'Edit') {
            const index = this.listViewData.findIndex(item => {return item.id === recordId});
            navState.c__sequence = this.listViewData[index].sequence;
        } else {
            navState.c__sequence = ( this.listViewData === undefined || this.listViewData.length === 0 ) ? 1 : this.listViewData.length + 1;
        }

        if (this.objectIntoConsideration) {
            navState.c__objectName = this.objectIntoConsideration;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, MatchRule_DETAIL_VIEW);

        detailRef.state = navState;
        this[NavigationMixin.Navigate](detailRef);
    }

    handleCancelButtonClick ( event ) {
        this.listViewData = JSON.parse(JSON.stringify(this.previousListViewDatastate));
        this.setToggleBtnSettings(this.previousToggleBtnState);
        this.disableCancelSaveBtn = true;
    }

    handleSaveButtonclick () {
        this.apiInProgress = true;
        const reqObj = this.listViewData;
        return saveTemplateRulesSequence({
            jsonRequest: JSON.stringify(reqObj)
        }).then(result => {
            this.apiInProgress = false;
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.listViewData = result.data;
            if ( this.listViewData === undefined ) {
                this.noRecordMessage = i18n.noMatchRuleRecordMsg;
            } else {
                this.noRecordMessage = '';
                this.previousListViewDatastate = JSON.parse(JSON.stringify(this.listViewData));
            }
            this.saveApplicationSetting();
            //const toastMsg = 'Changes made have been saved successfully.'
        }).catch(error => {
            this.error = error;
            this.apiInProgress = false;
        })
    }

    saveApplicationSetting () {
        return saveApplicationSettingRecord ({
            jsonRequest: JSON.stringify(this.applicationSettingRec)
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.applicationSettingRec = result.data;
            this.setToggleBtnSettings(result.data.settingValue);
            this.previousToggleBtnState = this.selectedToggleBtn;
            this.showToast('Success', this.i18n.success, this.i18n.successMsg, 'success', 'dismissible');
            this.disableCancelSaveBtn = true;
        }).catch(error => {
            this.error = error;
            this.apiInProgress = false;
        })
    }
    handleToggleSwitch (event) {
        if ( this.selectedToggleBtn !== event.target.dataset.name ) {
            this.setToggleBtnSettings ( event.target.dataset.name );
            this.disableCancelSaveBtn = false;
        }
    }

    setToggleBtnSettings ( selectedBtn) {
        if ( selectedBtn === 'All') {
            this.selectedToggleBtn = "All";
            this.toggleSwitchAllVariant = "Brand";
            this.toggleSwitchFirstVariant = "Neutral"
        } else if ( selectedBtn === 'First') {
            this.selectedToggleBtn = "First";
            this.toggleSwitchAllVariant = "Neutral";
            this.toggleSwitchFirstVariant = "Brand"
        }
        this.applicationSettingRec.settingValue = this.selectedToggleBtn;
    }

    get disableButton (  ) {
        return this.disableCancelSaveBtn;
    }

    get listViewDataGetter ( ) {
        return this.listViewData;
    }

    showToast (type, title, message, variant, mode) {
        const evt = new ShowToastEvent({
            type: type,
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    get getToggleSwitchAllVariant () {
        return this.toggleSwitchAllVariant;
    }

    get getToggleSwitchFirstVariant () {
        return this.toggleSwitchFirstVariant;
    }

}