import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getApplicationSetting from
    '@salesforce/apex/ADM_ApplicationSettings_LS.getApplicationSetting';
import saveApplicationSettingRecord from
    '@salesforce/apex/ADM_ApplicationSettings_LS.saveApplicationSettingRecord';

import { verifyApiResponse, parseErrorMessage, ADMIN_MODULES } from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';
import altTextLoading from '@salesforce/label/c.AltText_Loading';
import btnSave from '@salesforce/label/c.Btn_Save';
import labelTechnicalAttributes from '@salesforce/label/c.Label_TechnicalAttributes';
import labelUserGroupAssignment from '@salesforce/label/c.Label_UserGroupAssignment';
import labelRespectUserGroupAssignment
    from '@salesforce/label/c.Label_RespectUserGroupAssignment';
import labelUserGroupAssignmentDesc
    from '@salesforce/label/c.Label_UserGroupAssignmentDesc';
import labelSettings from '@salesforce/label/c.Label_Settings';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';

const i18n = {
    technicalAttributes: labelTechnicalAttributes,
    userGroupAssignment: labelUserGroupAssignment,
    respectUserGroupAssignment: labelRespectUserGroupAssignment,
    userGroupAssignmentDesc: labelUserGroupAssignmentDesc,
    loading: altTextLoading,
    save: btnSave,
    settings: labelSettings,
    wasSaved: labelWasSaved,
}

const TA_UserGroupSettingName = 'User_Group';

export default class TechnicalAttributeSettings extends LightningElement {

    apiInProgress = false;
    error = '';
    disableSave = true;

    @track applicationSettingRec = {};

    connectedCallback () {
        this.loadApplicationSettings();
    }

    loadApplicationSettings () {
        this.apiInProgress = true;
        return getApplicationSetting({
            developerName: TA_UserGroupSettingName
        })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.applicationSettingRec = result.data;
                const recentlyViewedRecord = {
                    configurationId: result.data.id,
                    configurationName: ADMIN_MODULES.TECHNICAL_ATTRIBUTE_SETTINGS,
                    configurationDeveloperName: result.data.developerName,
                    configurationType: ADMIN_MODULES.TECHNICAL_ATTRIBUTE_SETTINGS
                };
                saveRecentViewItem(recentlyViewedRecord)
                    .then(recentItem => {
                        if (!verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
            }).catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            })
    }

    handleSave () {
        this.error = null;
        this.apiInProgress = true;
        return saveApplicationSettingRecord ({
            jsonRequest: JSON.stringify(this.applicationSettingRec)
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.applicationSettingRec = result.data;
            this.showToast('Success', 'Success', 'Settings was saved', 'success', 'dismissible');
            this.disableSave = true;
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        })
        .finally(() => {
            this.apiInProgress = false;
        })
    }

    handleValueChange (event) {
        const value = (event.target.type === 'checkbox')
            ? event.target.checked
            : event.target.value;
        this.applicationSettingRec.settingValue = value.toString();
        this.disableSave = false;
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

    get i18n () {
        return i18n;
    }

    get disableSaveBtn () {
        return this.disableSave;
    }

    get applyUserGroupAssignment () {
        return (this.applicationSettingRec?.settingValue === 'true');
    }

}