import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import retreiveSettingInfo from
    '@salesforce/apex/ADM_SPMSettings_LS.retreiveSettingInfo';
import saveSettingInfo from
    '@salesforce/apex/ADM_SPMSettings_LS.saveSettingInfo';
import btnSave from '@salesforce/label/c.Btn_Save';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelDebugTransaction from '@salesforce/label/c.Label_DebugTransactions';
import labelAllowDebugTransctions from '@salesforce/label/c.Label_AllowDebug';
import labelSPMSettingHelp from '@salesforce/label/c.URL_SPMSettingHelp';
import labelDebugProfileSelection from '@salesforce/label/c.Label_DebugProfileSelection';
import saveSuccess from '@salesforce/label/c.Message_SaveSuccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { saveRecentViewItem }
    from 'c/recentItemService';

import {
    parseErrorMessage,
    verifyApiResponse,
    ADMIN_MODULES
} from 'c/utils';

const i18n = {
    labelAppConfig: 'Setup',
    save: btnSave,
    debugTransaction: labelDebugTransaction,
    help: labelHelp,
    allowDebug: labelAllowDebugTransctions,
    profileSelectionLabel: labelDebugProfileSelection,
    helpLink: labelSPMSettingHelp,
    saveSuccess
}

const ENABLE_DEBUG_MODE = 'ENABLE_DEBUG_MODE';

export default class SpmCommonSettings extends LightningElement {
    error = '';
    _isDirty = false;
    allowDebug = false;
    assignedProfileIds = [];
    selectedProfileIds = [];
    showProfileSelector = false;
    apiInProgress = false;

    get i18n () {
        return i18n;
    }

    get disableSaveBtn () {
        return !this._isDirty;
    }

    @wire(CurrentPageReference)
    currPageRef (pageref) {
        if (pageref && pageref.state &&
            pageref.state.c__currentItem === 'debug_transactions') {
            this.getDebugSettingInfo();
        }
    }

    getDebugSettingInfo () {
        this.apiInProgress = true;
        retreiveSettingInfo({ settingKey: ENABLE_DEBUG_MODE })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.processResponseData(result);
            })
            .catch( error => {
                this.error = parseErrorMessage(error)
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    processResponseData ( response ) {
        if (response.data) {
            const responseData = response.data;
            this.selectedProfileIds = responseData.selectedProfileIds;
            this.allowDebug = responseData.enableDebugMode;
        }
        this.showHideProfileSelector();
        this.apiInProgress = false;
    }

    handleToggleChange ( event ) {
        if (this.allowDebug !== event.target.checked ) {
            this.allowDebug = event.target.checked;
            this._isDirty = true;
        }

        this.showHideProfileSelector();
    }

    showHideProfileSelector () {
        this.showProfileSelector = false;
        if (this.allowDebug === true) {
            this.showProfileSelector = true;
        } else {
            this.selectedProfileIds = [];
        }
    }

    handleProfileSelected (event) {
        this.selectedProfileIds = event.detail.value;
        this._isDirty = true;
    }

    handleSave () {
        this.error = null;
        this.apiInProgress = true;
        const saveRequest = {
            name: ENABLE_DEBUG_MODE,
            enableDebugMode: this.allowDebug,
            selectedProfileIds: this.selectedProfileIds
        }
        saveSettingInfo({ requestJson: JSON.stringify(saveRequest) })
            .then( result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const recentlyViewedRecord = {
                    configurationId: result?.data?.id,
                    configurationName: ADMIN_MODULES.DEBUG_TRANSACTIONS,
                    configurationType: ADMIN_MODULES.DEBUG_TRANSACTIONS
                };
                saveRecentViewItem(recentlyViewedRecord)
                    .then(recentItem => {
                        if (!verifyApiResponse(recentItem)) {
                            this.error = recentItem.message;
                        }
                    });
                const evt = new ShowToastEvent({
                    title: `${this.i18n.saveSuccess}`,
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this._isDirty = false;
                this.apiInProgress = false;
            });
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }
}