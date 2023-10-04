import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ENTITLEMENT_SETTING_OBJECT from '@salesforce/schema/CONF_EntitlementSettings__c';
import DEFAULT_BILLING_TYPE_FIELD
    from '@salesforce/schema/CONF_EntitlementSettings__c.DefaultBillingType__c';
import getAllEntitlementSettings
    from '@salesforce/apex/ADM_EntitlementLightningService.getAllEntitlementSettings';
import saveEntitlementSettings
    from '@salesforce/apex/ADM_EntitlementLightningService.saveEntitlementSettings';

import { verifyApiResponse, parseErrorMessage, ADMIN_MODULES } from 'c/utils';
import { getFieldDefinitionsForEntities } from 'c/metadataService';
import { saveRecentViewItem }
    from 'c/recentItemService';

import labelSave from '@salesforce/label/c.Button_Save';
import labelEdit from '@salesforce/label/c.Menu_Edit';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelCoveredBy from '@salesforce/label/c.Label_CoveredBy';
import labelFutureEntitlements from '@salesforce/label/c.Label_FutureEntitlements';
import labelExpiredEntitlements from '@salesforce/label/c.Label_ExpiredEntitlements';
import labelFullyConsumedServices from '@salesforce/label/c.Label_IncludeFullyConsumedServices';
import labelIncludeRootAsset from '@salesforce/label/c.Label_IncludeRootAsset';
import labelIncludeParentAsset from '@salesforce/label/c.Label_IncludeParentAsset';
import labelMatchAccount from '@salesforce/label/c.Label_MatchAccount';
import labelAssetAPIName from '@salesforce/label/c.Label_AssetAPIName';
import labelAccountAPIName from '@salesforce/label/c.Label_AccountAPIName';
import labelTabCase from '@salesforce/label/c.Tab_Case';
import labelTabWorkOrder from '@salesforce/label/c.Tab_WorkOrder';
import labelTabReturnOrder from '@salesforce/label/c.Tab_ReturnOrder';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelAccount from '@salesforce/label/c.Label_Account';
import labelAllowSettingsOverride from '@salesforce/label/c.Label_OverrideEntitlementSettings';
import labelEntitlementHeader from '@salesforce/label/c.Title_Entitlement';
import labelLoadingEntitlementSettings
    from '@salesforce/label/c.AltText_LoadingEntitlementSettings';
import labelEntitlementSettingsSaved
    from '@salesforce/label/c.AltText_EntitlementSettingsSaved';
import labelSelectBillingType from '@salesforce/label/c.Label_Select_Default_Billing_Type';
import labelNumberOfMonthsShownExpiredEntitlements
    from '@salesforce/label/c.Label_NumberOfMonthsShownExpiredEntitlements';
import labelNumberOfMonthsShownFutureEntitlements
    from '@salesforce/label/c.Label_NumberOfMonthsShownFutureEntitlements';

import labelTitleInteractiveEntitlementSettings
    from '@salesforce/label/c.Title_InteractiveEntitlementSettings';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelInteractiveEntitlementRulesHelp
    from '@salesforce/label/c.URL_InteractiveEntitlementRulesHelp';
import labelOnHoldEntitlements
    from '@salesforce/label/c.Label_On_Hold_Entitlements';
import labelDurationRangeOverflowErrorMessage
    from '@salesforce/label/c.Label_DurationRangeOverflowErrorMessage';

const i18n = {
    loading: labelLoadingEntitlementSettings,
    saveTost: labelEntitlementSettingsSaved,
    pageHeader: labelEntitlementHeader,
    allowOverrideSettings: labelAllowSettingsOverride,
    title: labelTitleInteractiveEntitlementSettings,
    coveredBy: labelCoveredBy,
    futureEntitlements: labelFutureEntitlements,
    expiredEntitlements: labelExpiredEntitlements,
    fullyConsumedServices: labelFullyConsumedServices,
    includeRootAsset: labelIncludeRootAsset,
    includeParentAsset: labelIncludeParentAsset,
    matchAccount: labelMatchAccount,
    assetAPIName: labelAssetAPIName,
    accountAPIName: labelAccountAPIName,
    tabLabelCase: labelTabCase,
    tabLabelWorkOrder: labelTabWorkOrder,
    tabLabelReturnOrder: labelTabReturnOrder,
    edit: labelEdit,
    cancel: labelCancel,
    save: labelSave,
    goBack: labelNoGoBack,
    continue: labelYesContinue,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    asset: labelAsset,
    account: labelAccount,
    selectDefaultBillingType: labelSelectBillingType,
    helpLink: labelInteractiveEntitlementRulesHelp,
    help: labelHelp,
    numberOfMonthsShownExpiredEntitlements: labelNumberOfMonthsShownExpiredEntitlements,
    numberOfMonthsShownFutureEntitlements: labelNumberOfMonthsShownFutureEntitlements,
    onHoldEntitlements: labelOnHoldEntitlements,
    durationRangeOverflowErrorMessage: labelDurationRangeOverflowErrorMessage,
};

const ENTITLEMENT_SETTINGS_TABS = [
    { label: i18n.tabLabelCase, value: 'Case' },
    { label: i18n.tabLabelWorkOrder, value: 'WorkOrder' },
    { label: i18n.tabLabelReturnOrder, value: 'ReturnOrder' }
];

export default class EntitlementSettings extends LightningElement {

    @track error;
    @track viewMode = true;
    @track apiInProgress = false;
    @track activeSettingData = {};
    @track cancelModalDialogOpen = false;
    @track defaultBillingTypeOptions = [];

    _isDirty;
    _fieldDescribeResult;
    _currentPageReference;
    _entitlementSettingsData;

    get i18n () {
        return i18n;
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    get coveredBy () {

        return [
            { label: i18n.account, value: 'Account' },
            { label: i18n.asset, value: 'Asset' },
        ];
    }

    get matchAccountLabel () {
        const objectName = this.activeSettingData.objectAPIName === 'WorkOrder'
            ? i18n.tabLabelWorkOrder
            : this.activeSettingData.objectAPIName === 'ReturnOrder'
                ? i18n.tabLabelReturnOrder
                : this.activeSettingData.objectAPIName;
        return `${i18n.matchAccount} ${objectName}`;
    }
    get accountAPINames () {
        return this.getReferenceFieldInfo('Account');
    }

    get assetAPINames () {
        return this.getReferenceFieldInfo('Asset');
    }

    get showComponent () {
        return (this.activeSettingData.coveredBy !== undefined
            && this.activeSettingData.coveredBy === 'Asset') ? true : false;
    }

    get showAccount () {
        return ( this.activeSettingData.coveredBy === 'Asset'
            && this.activeSettingData.matchAccount === false) ? false : true;
    }

    get isFutureMonthDisable () {
        return !( this.activeSettingData.futureEntitlements === true );
    }

    get isExpiredMonthDisable () {
        return !( this.activeSettingData.expiredEntitlements === true );
    }

    get accountLabel () {
        const account = this.getReferenceFieldInfo('Account').filter(item =>
            this.activeSettingData.accountAPIName === item.value
        );
        return account.length > 0 ? account[0].label : '';
    }

    get assetLabel () {
        const asset = this.getReferenceFieldInfo('Asset').filter(item =>
            this.activeSettingData.assetAPIName === item.value
        );
        return asset.length > 0 ? asset[0].label : '';
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageReference) {
        this._currentPageReference = pageReference;

        if (pageReference && this._entitlementSettingsData === undefined) {
            this.getFieldDescribeResults();
            this.getEntitlementSettings();
        }
    }

    async getFieldDescribeResults () {

        if (this._fieldDescribeResult === undefined) {

            const objectNames = [];
            ENTITLEMENT_SETTINGS_TABS.forEach( function (item) {
                objectNames.push(item.value);
            });
            objectNames.push(ENTITLEMENT_SETTING_OBJECT.objectApiName);
            try {
                const resp = await getFieldDefinitionsForEntities(objectNames);

                if (resp && resp.data) {

                    const fieldDescribeResult = {};
                    resp.data.forEach( function (item) {
                        fieldDescribeResult[item.apiName] = item;
                    } );

                    this._fieldDescribeResult = fieldDescribeResult;
                    this.formatEntitlementSettingObjectFields();
                }
            } catch (err) {
                this.error = parseErrorMessage(err);
            }
        }
    }

    formatEntitlementSettingObjectFields () {
        if (this._fieldDescribeResult) {
            const entitlementSettingDefinition =
                this._fieldDescribeResult[ENTITLEMENT_SETTING_OBJECT.objectApiName];

            if (entitlementSettingDefinition) {
                entitlementSettingDefinition.fieldDefinitions.forEach( field => {
                    if (field.apiName === DEFAULT_BILLING_TYPE_FIELD.fieldApiName) {
                        this.defaultBillingTypeOptions = field.picklistValues;
                    }
                });
            }
        }
    }

    getReferenceFieldInfo (referenceFieldName) {
        const referenceFields = [];
        if (this._fieldDescribeResult !== undefined
            && this.activeSettingData.objectAPIName !== undefined) {

            const sourceFieldDefinition
                = this._fieldDescribeResult[this.activeSettingData.objectAPIName];
            sourceFieldDefinition.fieldDefinitions.forEach(function (item) {
                if (item.dataType === 'REFERENCE'
                    && item.referenceTo.length !== 0
                    && item.referenceTo[0] === referenceFieldName) {
                    referenceFields.push({
                        label: item.label,
                        value: item.apiName,
                    });
                }
            });
        }
        return referenceFields;
    }

    getEntitlementSettings () {
        this.error = null;
        this.apiInProgress = true;

        return getAllEntitlementSettings().then(result => {

            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }

            const data = {};
            result.data.forEach( function (item) {
                data[item.objectAPIName] = item;
            });

            const recentlyViewedRecord = {
                configurationId: data[result.data[0].objectAPIName].id,
                configurationName: ADMIN_MODULES.INTERACTIVE_ENTITLEMENT,
                configurationType: ADMIN_MODULES.INTERACTIVE_ENTITLEMENT
            };
            saveRecentViewItem(recentlyViewedRecord)
                .then(recentItem => {
                    if (!verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });

            this._entitlementSettingsData = data;
            this.activeSettingData = { ...this._entitlementSettingsData.Case };
        }).catch(error => {
            this.error = parseErrorMessage(error);
        })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    checkValidity () {
        const allValid = [...this.template.querySelectorAll('.interactive-input')].reduce(
            (validSoFar, inputField) => {
                if (inputField.reportValidity) {
                    inputField.reportValidity();
                    return validSoFar && inputField.checkValidity();
                }
                return validSoFar;
            },
            true
        );
        return allValid;
    }

    handleSave () {
        this.error = null;

        if (!this.checkValidity()) {
            return;
        }

        this.apiInProgress = true;

        saveEntitlementSettings({ requestJson: JSON.stringify(this.activeSettingData) })
            .then(() => {
                this._isDirty = false;
                this.viewMode = true;
                this._entitlementSettingsData[this.activeSettingData.objectAPIName]
                    = this.activeSettingData;
                const objectName = this.activeSettingData.objectAPIName === 'WorkOrder'
                    ? i18n.tabLabelWorkOrder
                    : this.activeSettingData.objectAPIName === 'ReturnOrder'
                        ? i18n.tabLabelReturnOrder
                        : this.activeSettingData.objectAPIName === 'Case'
                            ? i18n.tabLabelCase
                            : this.activeSettingData.objectAPIName
                this.showSaveSuccessNotification(objectName);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    showSaveSuccessNotification (sourceObject) {
        const evt = new ShowToastEvent({
            title: `"${sourceObject}" ${i18n.saveTost}` ,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    get tabs () {
        let tabList = ENTITLEMENT_SETTINGS_TABS;
        if (this.viewMode === false && this.activeSettingData.objectAPIName !== undefined) {
            tabList = ENTITLEMENT_SETTINGS_TABS.filter(item =>
                item.value === this.activeSettingData.objectAPIName
            );
        }
        return tabList;
    }

    handleValueChange (event) {
        this._isDirty = false;
        this.activeSettingData[event.target.name] = (event.target.type === 'checkbox')
            ? event.target.checked
            : event.target.value;

        if ( event.target.name === 'futureEntitlements' && !event.target.checked ) {
            this.activeSettingData.futureEntitlementDuration = null;
        } else if ( event.target.name === 'expiredEntitlements' && !event.target.checked ) {

            this.activeSettingData.expiredEntitlementDuration = null;
        }
        this.verifyDataUpdation();
    }

    verifyDataUpdation () {
        const activeSettings = this._entitlementSettingsData[this.activeSettingData.objectAPIName];

        Object.keys(activeSettings).forEach(key => {
            if ( this.activeSettingData[key] !== activeSettings[key]) {
                this._isDirty = true;
            }
        });
    }

    handleDefaultBillingTypeChange (event) {
        const selectedValue = event.detail.value;
        this.activeSettingData.defaultBillingType = selectedValue;
        this.verifyDataUpdation();
    }

    handleActiveTab (event) {
        this.activeSettingData = (this._entitlementSettingsData !== undefined)
            ? { ...this._entitlementSettingsData[event.target.value] }
            : {};
    }

    handleCancelEdit () {
        if (this._isDirty) {
            this.cancelModalDialogOpen = true;
        } else {
            this.viewMode = true;
        }
    }

    handleCancelModal () {
        this.viewMode = false;
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this._isDirty = false;
        this.viewMode = true;
        this.cancelModalDialogOpen = false;
        this.activeSettingData = (this._entitlementSettingsData !== undefined)
            ? { ...this._entitlementSettingsData[this.activeSettingData.objectAPIName] }
            : {};
    }

    handleEditView () {
        this.viewMode = false;
    }
}