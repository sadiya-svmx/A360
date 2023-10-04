import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import {
    ICON_NAMES,
    verifyApiResponse,
    parseErrorMessage
} from 'c/utils';

import invokeConfig from '@salesforce/apex/ADM_AutoConfiguratorService_LS.invokeAutoConfigurator';
import getGlobalProperty from '@salesforce/apex/CONF_CustomSettingsService_LS.getGlobalProperty';

import labelAutoConfigurationPageText1 from '@salesforce/label/c.Label_AutoConfigurationPageText1';
import labelAutoConfigurationPageText2 from '@salesforce/label/c.Label_AutoConfigurationPageText2';
import labelAutoConfigurationPageText3 from '@salesforce/label/c.Label_AutoConfigurationPageText3';
import labelAutoConfigurationButton from '@salesforce/label/c.Label_AutoConfigurationButton';
import autoConfigHelpLink from '@salesforce/label/c.URL_AutoConfigurationHelp';
import labelApplicationConfiguration from '@salesforce/label/c.Label_application_configuration';
import labelAutoConfiguration from '@salesforce/label/c.Label_AutoConfiguration';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelAutoConfigurationCompleted from '@salesforce/label/c.Label_AutoConfigurationCompleted';
import labelHelp from '@salesforce/label/c.Label_Help';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const i18n = {
    autoConfigText1: labelAutoConfigurationPageText1,
    autoConfigText2: labelAutoConfigurationPageText2,
    autoConfigText3: labelAutoConfigurationPageText3,
    autoConfigurationButton: labelAutoConfigurationButton,
    helpLink: autoConfigHelpLink,
    appConfig: labelApplicationConfiguration,
    autoConfig: labelAutoConfiguration,
    successMessage: labelAutoConfigurationCompleted,
    loading: labelLoading,
    help: labelHelp
};

export default class AutoConfiguration extends NavigationMixin(LightningElement) {
    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }

    @api iconSize = 'large';

    apiInProgress = false;
    autoConfigUrl;
    error;
    statusAutoConfig;

    connectedCallback () {
        const pageRefObj = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'SVMXA360__setupHome'
            },
            state: {
                c__currentItem: 'setup_home',
                c__target: 'c-admin-welcome',
            }
        };

        this[NavigationMixin.GenerateUrl](pageRefObj).then(url => {
            this.autoConfigUrl = url;
        });
    }

    navigateToAutoUrl (autoConfigStatus) {
        if (autoConfigStatus === 'COMPLETED') {
            const event = new ShowToastEvent({
                title: '',
                variant: 'success',
                message: i18n.successMessage,
            });
            this.dispatchEvent(event);
        }

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": this.autoConfigUrl
            }
        });
    }

    async handleClick () {
        this.apiInProgress = true;

        const result = await invokeConfig();

        if (!verifyApiResponse(result)) {
            this.apiInProgress = false;
            this.error = result.message;
            return;
        }

        await this.getAutoConfigSettings();
        this.error = undefined;
    }

    get i18n () {
        return i18n;
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    async getAutoConfigSettings () {
        try {
            this.error = undefined;
            const resultForGP801 = await getGlobalProperty({ name: 'GP801' });
            if ( verifyApiResponse(resultForGP801)) {
                this.statusAutoConfig = resultForGP801.data.value;
                if (this.statusAutoConfig === 'COMPLETED' ||
                    this.statusAutoConfig === 'FAILED'
                ) {
                    this.navigateToAutoUrl(this.statusAutoConfig);
                    this.apiInProgress = false;
                } else {
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    setTimeout( () => { this.getAutoConfigSettings() }, 2000);
                }
            }
            else {
                this.apiInProgress = false;
                this.error = resultForGP801.message;
            }
        } catch (error) {
            this.apiInProgress = false;
            this.error = parseErrorMessage(error);
        }
    }
}