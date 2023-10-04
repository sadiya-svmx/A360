import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getFieldDefinitionsForEntities } from "c/metadataService";
import { verifyApiResponse, parseErrorMessage, ADMIN_MODULES } from 'c/utils';
import { commonSettingModel } from './commonSettingModel';

import { saveRecentViewItem }
    from 'c/recentItemService';

import ENTITLEMENT_SETTING_OBJECT from '@salesforce/schema/CONF_EntitlementSettings__c';
import SERVICE_CONTRACT_OBJECT from '@salesforce/schema/ServiceContract';
import ASSET_WARRANTY_OBJECT from '@salesforce/schema/AssetWarranty';
import DECREMENT_SERVICE_COUNT_OBJECT_FIELD
    from '@salesforce/schema/CONF_EntitlementSettings__c.AdjustVisitCountAssignedObject__c';
import CONTRACT_STACKRANKING_ORDER_OBJECT_FIELD
    from '@salesforce/schema/CONF_EntitlementSettings__c.ContractStackRankingOrder__c';
import WARRANTY_STACKRANKING_ORDER_OBJECT_FIELD
    from '@salesforce/schema/CONF_EntitlementSettings__c.WarrantyStackRankingOrder__c';

import altTextLoading from '@salesforce/label/c.AltText_Loading';
import btnSave from '@salesforce/label/c.Btn_Save';
import helpTextAssignEntitledService from '@salesforce/label/c.Help_Text_Assign_Entitled_Service';
import helpTextAssignPricebook from '@salesforce/label/c.Help_Text_Assign_Pricebook';
import helpTextInheritServiceOnReturnOrder
    from '@salesforce/label/c.Help_Text_Inherit_Service_on_Return_Order';
import helpTextInheritServiceOnWorkOrder
    from '@salesforce/label/c.Help_Text_Inherit_Service_on_Work_Order';
import labelAssignEntitledService from '@salesforce/label/c.Label_Assign_Entitled_Service';
import labelAssignPricebook from '@salesforce/label/c.Label_Assign_Pricebook';
import labelAdjustServiceThreshold from '@salesforce/label/c.Label_Adjust_Service_Threshold';
import labelAdjustVisitCountAssignedObject
    from '@salesforce/label/c.Label_Adjust_Visit_Count_Assigned_Object';
import labelEntitlement from '@salesforce/label/c.Label_Entitlement';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelInheritServiceOnReturnkOrder
    from '@salesforce/label/c.Label_Inherit_Service_on_Return_Order';
import labelInheritServiceOnWorkOrder
    from '@salesforce/label/c.Label_Inherit_Service_on_Work_Order';
import labelSettings from '@salesforce/label/c.Label_Settings';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';

import getCommonEntitlementSettings
    from '@salesforce/apex/ADM_EntitlementLightningService.getCommonEntitlementSetting';
import getUnsupportedStackRankingFields
    from '@salesforce/apex/ADM_EntitlementLightningService.getUnsupportedStackRankingFields';
import saveCommonEntitlementSettings
    from '@salesforce/apex/ADM_EntitlementLightningService.saveCommonEntitlementSettings';

import labelHelp from '@salesforce/label/c.Label_Help';
import labelEntitlementSettingsHelp from '@salesforce/label/c.URL_EntitlementSettingsHelp';
import labelApplyStackRanking from '@salesforce/label/c.Label_ApplyStackRanking';
import labelStackRankingContractField from '@salesforce/label/c.Label_StackRankingContractField';
import labelStackRankingContractSortOrder
    from '@salesforce/label/c.Label_StackRankingContractSortOrder';
import labelStackRankingWarrantyField from '@salesforce/label/c.Label_StackRankingWarrantyField';
import labelStackRankingWarrantySortOrder
    from '@salesforce/label/c.Label_StackRankingWarrantySortOrder';

const i18n = {
    formValidation: labelFormValidation,
    entitlement: labelEntitlement,
    helpTextAssignEntitledService: helpTextAssignEntitledService,
    helpTextAssignPricebook: helpTextAssignPricebook,
    helpTextInheritServiceOnReturnOrder: helpTextInheritServiceOnReturnOrder,
    helpTextInheritServiceOnWorkOrder: helpTextInheritServiceOnWorkOrder,
    labelAssignEntitledService: labelAssignEntitledService,
    labelAssignPricebook: labelAssignPricebook,
    labelAdjustServiceThreshold: labelAdjustServiceThreshold,
    labelAdjustVisitCountAssignedObject: labelAdjustVisitCountAssignedObject,
    labelInheritServiceOnReturnkOrder: labelInheritServiceOnReturnkOrder,
    labelInheritServiceOnWorkOrder: labelInheritServiceOnWorkOrder,
    loading: altTextLoading,
    save: btnSave,
    settings: labelSettings,
    wasSaved: labelWasSaved,
    helpLink: labelEntitlementSettingsHelp,
    help: labelHelp,
    applyStackRanking: labelApplyStackRanking,
    stackRankingContractField: labelStackRankingContractField,
    stackRankingContractSortOrder: labelStackRankingContractSortOrder,
    stackRankingWarrantyField: labelStackRankingWarrantyField,
    stackRankingWarrantySortOrder: labelStackRankingWarrantySortOrder
}

const STACK_RANKING_FIELD_TYPES = [
    "DATETIME",
    "DOUBLE",
    "DATE",
    "PERCENT",
    "CURRENCY",
    "INTEGER"
];

export default class EntitlementCommonSettings extends LightningElement {

    apiInProgress = false;
    error = '';
    commonSetting = {};
    adjustVisitCountAssignedObjectOptions = [];
    contractStackRankingAPINameOptions = [];
    contractStackRankingOrderOptions = [];
    warrantyStackRankingAPINameOptions = [];
    warrantyStackRankingOrderOptions = [];
    unsupportedStackRankingFields = [];
    diableVisitCountAssignedObject = true;
    disableApplyStackRanking = true;
    disableSave = true;
    connectedCallback () {
        this.loadView();
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    async loadView () {
        this.apiInProgress = true;
        await this.getUnsupportedFields();
        await this.formatEntitlementSettingFields()
            .then (() => {
                this.getEntitlementSettings();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });

    }

    async formatEntitlementSettingFields () {

        const objectNames = [
            ENTITLEMENT_SETTING_OBJECT.objectApiName,
            SERVICE_CONTRACT_OBJECT.objectApiName,
            ASSET_WARRANTY_OBJECT.objectApiName
        ];
        try {
            const resp = await getFieldDefinitionsForEntities(objectNames);
            if (resp && resp.data) {
                resp.data.forEach( objectDef => {
                    this.populateObjectFields (objectDef.fieldDefinitions,objectDef.apiName);
                });
            }
        } catch (err) {
            throw parseErrorMessage(err);
        }
    }

    async getUnsupportedFields () {

        try {
            const response = await getUnsupportedStackRankingFields();
            if (response?.data?.length > 0 ) {
                this.unsupportedStackRankingFields = response.data;
            }
        } catch (err) {
            throw parseErrorMessage(err);
        }
    }

    populateObjectFields ( fieldDefinitions, objectName ) {

        fieldDefinitions.forEach( field => {
            const { apiName, label, dataType, picklistValues } = field;

            if (objectName === ENTITLEMENT_SETTING_OBJECT.objectApiName) {
                if (apiName === DECREMENT_SERVICE_COUNT_OBJECT_FIELD.fieldApiName) {
                    this.adjustVisitCountAssignedObjectOptions = picklistValues;
                }
                else if (apiName === CONTRACT_STACKRANKING_ORDER_OBJECT_FIELD.fieldApiName) {
                    this.contractStackRankingOrderOptions = picklistValues;
                }
                else if (apiName === WARRANTY_STACKRANKING_ORDER_OBJECT_FIELD.fieldApiName) {
                    this.warrantyStackRankingOrderOptions = picklistValues;
                }
            }

            else if (STACK_RANKING_FIELD_TYPES.includes(dataType)
                && !this.unsupportedStackRankingFields.includes(apiName)) {
                const fieldWrap = {
                    label: label,
                    value: apiName,
                }
                if (objectName === SERVICE_CONTRACT_OBJECT.objectApiName) {
                    this.contractStackRankingAPINameOptions.push(fieldWrap);
                }
                else if (objectName === ASSET_WARRANTY_OBJECT.objectApiName) {
                    this.warrantyStackRankingAPINameOptions.push(fieldWrap);
                }
            }
        });
    }

    async getEntitlementSettings () {
        const response = await getCommonEntitlementSettings()

        if (!verifyApiResponse(response)) {
            this.error = response.message;
        }

        this.commonSetting = new commonSettingModel(response.data);
        const recentlyViewedRecord = {
            configurationId: this.commonSetting.id,
            configurationName: ADMIN_MODULES.ENTITLEMENT_SETTINGS,
            configurationType: ADMIN_MODULES.ENTITLEMENT_SETTINGS
        };
        saveRecentViewItem(recentlyViewedRecord)
            .then(recentItem => {
                if (!verifyApiResponse(recentItem)) {
                    this.error = recentItem.message;
                }
            });
        this.diableVisitCountAssignedObject = !this.commonSetting.adjustServiceThreshold;
        this.disableApplyStackRanking = !this.commonSetting.applyStackRanking;
    }

    handleSave () {

        if ( !this.commonSetting.applyStackRanking ) {
            this.commonSetting.contractStackRankingAPIName = '';
            this.commonSetting.contractStackRankingOrder = '';
            this.commonSetting.warrantyStackRankingAPIName = '';
            this.commonSetting.warrantyStackRankingOrder = '';
        }
        const allValid =
            [...this.template.querySelectorAll('.svmx-entitlement-common-settings_input-field')]
                .reduce((validSoFar, inputField) => {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }, true);

        if (!allValid) {
            this.error = this.i18n.formValidation;
            return;
        }

        this.updateCommonEntitlementSettings();
    }

    updateCommonEntitlementSettings () {
        this.error = null;
        this.apiInProgress = true;
        const requestJson = JSON.stringify(this.formatRecordData(this.commonSetting));

        saveCommonEntitlementSettings ({ requestJson: requestJson })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.commonSetting = new commonSettingModel(result.data);
                this.showSaveSuccessNotification(`${this.i18n.settings} ${this.i18n.wasSaved}`);
                this.disableSave = true;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            })

    }

    formatRecordData (settingData) {
        return {
            id: settingData.id,
            assignEntitledService: settingData.assignEntitledService,
            assignPricebook: settingData.assignPricebook,
            adjustServiceThreshold: settingData.adjustServiceThreshold,
            adjustVisitCountAssignedObject: settingData.adjustVisitCountAssignedObject,
            inheritServiceOnReturnOrder: settingData.inheritServiceOnReturnOrder,
            inheritServiceOnWorkOrder: settingData.inheritServiceOnWorkOrder,
            applyStackRanking: settingData.applyStackRanking,
            contractStackRankingAPIName: settingData.contractStackRankingAPIName,
            contractStackRankingOrder: settingData.contractStackRankingOrder,
            warrantyStackRankingAPIName: settingData.warrantyStackRankingAPIName,
            warrantyStackRankingOrder: settingData.warrantyStackRankingOrder
        }
    }

    showSaveSuccessNotification (message) {
        const evt = new ShowToastEvent({
            title: message,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleValueChange (event) {
        this.commonSetting[event.target.name] = (event.target.type === 'checkbox')
            ? event.target.checked
            : event.target.value;
        if (event.target.name === 'adjustServiceThreshold') {
            this.diableVisitCountAssignedObject = !event.target.checked;
            if (!event.target.checked) {
                this.commonSetting.adjustVisitCountAssignedObject = '';
            }
        }

        if (event.target.name === 'applyStackRanking') {
            this.disableApplyStackRanking = !event.target.checked;
        }

        this.disableSave = false;
    }

    handleComboboxChange (event) {
        switch ( event.currentTarget.dataset.field ) {
            case 'contractStackRankingAPIName':
                this.commonSetting.contractStackRankingAPIName = event.detail.value;
                break;
            case 'contractStackRankingOrder':
                this.commonSetting.contractStackRankingOrder = event.detail.value;
                break;
            case 'warrantyStackRankingAPIName':
                this.commonSetting.warrantyStackRankingAPIName = event.detail.value;
                break;
            case 'warrantyStackRankingOrder':
                this.commonSetting.warrantyStackRankingOrder = event.detail.value;
                break;
            default:
                this.commonSetting.adjustVisitCountAssignedObject = event.detail.value;
                break;
        }
        this.disableSave = false;
    }

    get i18n () {
        return i18n;
    }

    get disableSaveBtn () {
        return this.disableSave;
    }

}