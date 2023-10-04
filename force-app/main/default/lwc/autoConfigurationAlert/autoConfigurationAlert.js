import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import labelAutoConfiguration from '@salesforce/label/c.Label_AutoConfigurationIsRequired';
import labelMoreInformation from '@salesforce/label/c.Label_MoreInformation';
import labelAutoConfigurationCompleted from '@salesforce/label/c.Label_AutoConfigurationCompleted';
import labelAutoConfigurationFailed from '@salesforce/label/c.Label_AutoConfigurationFailed';
import label_TryAgain from '@salesforce/label/c.Label_TryAgain';
import getGlobalProperty from '@salesforce/apex/CONF_CustomSettingsService_LS.getGlobalProperty';

import { verifyApiResponse } from 'c/utils';

const i18n = {
    warningMessage: labelAutoConfiguration,
    moreInformationButton: labelMoreInformation,
    successMessage: labelAutoConfigurationCompleted,
    failedMessage: labelAutoConfigurationFailed,
    tryAgain: label_TryAgain
};

export default class AutoConfigurationAlert extends NavigationMixin(LightningElement) {
    theme = 'slds-notify slds-notify_toast slds-theme_';
    autoConfigUrl;
    error;
    showAutoConfig;
    statusAutoConfig;
    showAlertInProgress = false;

    connectedCallback () {
        const state = {
            c__currentItem: 'auto_configuration',
            c__target: 'c-auto-configuration',
        }
        const pageRefObj = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'SVMXA360__setupHome'
            },
            state
        };

        this[NavigationMixin.GenerateUrl](pageRefObj).then(url => {
            this.autoConfigUrl = url;
        });
        this.getAutoConfigSettings();
    }

    get showWarningOrFail () {
        if ( this.showAutoConfig && this.statusAutoConfig === 'FAILED' ) {
            return {
                message: i18n.failedMessage,
                variant: 'ERROR',
                buttonLabel: i18n.tryAgain,
                icon: 'utility:error',
                class: this.theme + "error"
            };
        } else if (this.showWarning) {
            return {
                message: i18n.warningMessage,
                variant: 'WARNING',
                icon: 'utility:warning',
                buttonLabel: i18n.moreInformationButton,
                class: this.theme + "warning"
            };
        }
        return undefined;
    }

    get i18n () {
        return i18n;
    }

    handleClick () {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.autoConfigUrl
            }
        });
    }

    handleClose () {
        this.showAutoConfig = false;
    }

    get showWarning () {
        if ( this.showAutoConfig &&
            ( this.statusAutoConfig === 'TODO' || this.showAlertInProgress )
        ) {
            return true;
        }
        return false;
    }

    timeDefference (thresholdTime) {
        return (Date.now() - Number(this.timeOfUpdation)) > thresholdTime;
    }

    async getAutoConfigSettings () {
        try {
            const result = await getGlobalProperty({ name: 'GP800' });
            if (verifyApiResponse(result) && result.data.value === 'true') {
                this.showAutoConfig = (result.data.value === "true");
                const resultForGP801 = await getGlobalProperty({ name: 'GP801' });
                if ( verifyApiResponse(resultForGP801)) {
                    this.statusAutoConfig = resultForGP801.data.value;
                    if ( this.statusAutoConfig === 'INPROGRESS' ) {
                        const gp802 = await getGlobalProperty({ name: 'GP802' });
                        if (verifyApiResponse(gp802)) {
                            this.timeOfUpdation = gp802.data.value;
                            this.showAlertInProgress = this.timeDefference(30000)
                        }
                        else {
                            this.error = gp802?.message;
                        }
                    }
                }
                else {
                    this.error = resultForGP801?.message;
                }
            }
            else {
                this.error = result?.message;
            }
        } catch (error) {
            this.error = error;
        }
    }
}