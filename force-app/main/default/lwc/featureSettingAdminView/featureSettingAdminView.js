import { LightningElement, wire, track } from 'lwc';
import title_featureSettings from '@salesforce/label/c.Title_FeatureSettingAdmin';
import labelHelp from '@salesforce/label/c.Label_Help';
import label_enableUsageTrackingTitle from '@salesforce/label/c.Label_EnableUsageTrackingTitle';
import label_enabledText from '@salesforce/label/c.Label_Enabled';
import label_disabledText from '@salesforce/label/c.Label_Disabled';
import labelFeatureSettingHelp from '@salesforce/label/c.URL_FeatureSettingHelp';
import lbl_featureSettingUpdateSuccess from
    '@salesforce/label/c.Label_FeatureSettingUpdateSuccess';
import label_featureSettingUpdateFailure from
    '@salesforce/label/c.Label_FeatureSettingUpdateError';
import setApplicationUsageTracker from
    '@salesforce/apex/CONF_CustomSettingsService_LS.setApplicationUsageTracker';
import getApplicationUsageTracker from
    '@salesforce/apex/CONF_CustomSettingsService_LS.getApplicationUsageTracker';
import { ICON_NAMES, ADMIN_MODULES, verifyApiResponse } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { saveRecentViewItem }
    from 'c/recentItemService';

const i18n = {
    label_featureSettings: title_featureSettings,
    label_applicationConfiguration: 'Setup',
    help: labelHelp,
    label_enableUsageTrackingTitle: label_enableUsageTrackingTitle,
    lbl_featureSettingUpdateSuccess: lbl_featureSettingUpdateSuccess,
    label_featureSettingUpdateFailure: label_featureSettingUpdateFailure,
    label_enabledText: label_enabledText,
    label_disabledText: label_disabledText,
    helpLink: labelFeatureSettingHelp,
};
export default class FeatureSettingAdminView extends LightningElement {

    enableTracking;
    errorMessage;
    errorFlag=false;
    iconSize = 'large';
    _variantSuccess= 'success';
    _variantError= 'error';
    @track appUsageObject;

    get i18n () {
        return i18n;
    }

    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }

    @wire(getApplicationUsageTracker)
    getAppUsageTracker ( value ) {
        this.appUsageObject = value;
        const { error, data } = value;
        if (data) {
            this.enableTracking = data?.data?.value === "true";
            const recentlyViewedRecord = {
                configurationId: data?.data?.id,
                configurationName: ADMIN_MODULES.USAGE_STATISTICS,
                configurationType: ADMIN_MODULES.USAGE_STATISTICS
            };
            saveRecentViewItem(recentlyViewedRecord)
                .then(recentItem => {
                    if (!verifyApiResponse(recentItem)) {
                        this.errorMessage = recentItem.message;
                    }
                });
        } else if (error) {
            this.errorFlag=true;
            this.errorMessage = error.body.message;
        }
    }

    handleChange ( event ) {
        const flagInBool = event.target.checked;
        this.enableTracking = flagInBool;
        const flagInString = flagInBool ? "true" : "false";

        setApplicationUsageTracker( { enableFlag: flagInString } )
            .then(result=>{
                if (!result.success) {
                    this.resetToggle(!flagInBool, result?.message);
                } else {
                    this.showNotification(lbl_featureSettingUpdateSuccess,
                        '',
                        this._variantSuccess);
                    refreshApex(this.appUsageObject);
                }
            }).catch(error=>{
                this.resetToggle(!flagInBool, error.body.message);
            });
    }

    resetToggle (status, message) {
        this.errorFlag = true;
        this.errorMessage = message;
        this.enableTracking = status;
        this.showNotification(label_featureSettingUpdateFailure, '', this._variantError);
    }

    showNotification (title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }
}