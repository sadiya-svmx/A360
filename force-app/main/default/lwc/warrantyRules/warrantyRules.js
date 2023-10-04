import { LightningElement, track, wire } from 'lwc';
import getWarrantyConfigurationRecord from
    '@salesforce/apex/WARR_ManageWarranty_LS.getWarrantyConfigurationRecord';
import getCoverageValuesOfWarrantyTerm from
    '@salesforce/apex/WARR_ManageWarranty_LS.getCoverageValuesOfWarrantyTerm';
import getDateFieldsOfAsset from '@salesforce/apex/WARR_ManageWarranty_LS.getDateFieldsOfAsset';
import getObjectMappings from '@salesforce/apex/WARR_ManageWarranty_LS.getObjectMappings';
import updateRecord from '@salesforce/apex/WARR_ManageWarranty_LS.updateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { MAPPING_TYPES, PAGE_ACTION_TYPES } from 'c/utils';

import titleWarrantyManagement from '@salesforce/label/c.Title_Warranty_Management';
import titleSetting from '@salesforce/label/c.Label_Settings';
import btnEdit from '@salesforce/label/c.Btn_Edit';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnSave from '@salesforce/label/c.Btn_Save';
import secGeneralInformation from '@salesforce/label/c.Sec_General_Information';
import secDateMapping from '@salesforce/label/c.Sec_Date_Mapping';
import lblAutoCreate from
    '@salesforce/label/c.Label_Create_Asset_Warranty_Automatically_when_New_Asset_Created';
import lblTemplateMapping from '@salesforce/label/c.Label_Warranty_Term_Template_Mapping';
import lblAutoUpdate from
    '@salesforce/label/c.Label_Create_Asset_Warranty_Automatically_when_New_Asset_Updated';
import lblWarrantyTerm from '@salesforce/label/c.Label_Warranty_Term';
import lblSourceAssetField from '@salesforce/label/c.Label_Source_Asset_Field';
import lblYes from '@salesforce/label/c.Lbl_Yes';
import lblNo from '@salesforce/label/c.Lbl_No';
import lblNotSet from '@salesforce/label/c.Lbl_Not_set';
import lblRecordSaved from '@salesforce/label/c.Message_WarrantyRule_Saved';
import lblRecordSaveError from '@salesforce/label/c.Message_WarrantyRule_SaveError';
import lblNewMapping from '@salesforce/label/c.Label_NewMapping';
import lblClear from '@salesforce/label/c.Label_Clear';
import lblLoading from '@salesforce/label/c.AltText_LoadingWarrantyManagementSetting';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelWarrantyRuleHelp from '@salesforce/label/c.URL_WarrantyRuleHelp';

import {
    ICON_NAMES,
    verifyApiResponse,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

const i18n = {
    titleWarrantyManagement: titleWarrantyManagement,
    titleSetting: titleSetting,
    btnEdit: btnEdit,
    btnCancel: btnCancel,
    btnSave: btnSave,
    btnClear: lblClear,
    secGeneralInformation: secGeneralInformation,
    secDateMapping: secDateMapping,
    lblAutoCreate: lblAutoCreate,
    lblTemplateMapping: lblTemplateMapping,
    lblAutoUpdate: lblAutoUpdate,
    lblWarrantyTerm: lblWarrantyTerm,
    lblSourceAssetField: lblSourceAssetField,
    lblYes: lblYes,
    lblNo: lblNo,
    lblNotSet: lblNotSet,
    lblRecordSaved: lblRecordSaved,
    lblRecordSaveError: lblRecordSaveError,
    lblNewMapping: lblNewMapping,
    loading: lblLoading,
    helpLink: labelWarrantyRuleHelp,
    help: labelHelp
};

export default class WarrantyRules extends NavigationMixin(LightningElement) {
    @track editMode = false;
    @track isAutoWarrOnCreate;
    @track isAutoWarrOnCreateNewVal;
    @track isAutoWarrOnUpdate;
    @track isAutoWarrOnUpdateNewVal;
    @track objectMapping;
    @track editObjectMapping;
    @track editObjectMappingNewVal;
    @track dateMapping = [];
    @track dateMappingNewVal = [];
    @track assetFieldOptions = [];
    @track objectMappingOptions = [];
    @track warrConfigRecord;
    @track warrConfigRecordToRefresh;
    @track currentPageReference;
    apiInProgress = false;

    get iconName () {
        return ICON_NAMES.SVMXLOGO;
    }

    get i18n () {
        return i18n;
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    @wire(CurrentPageReference)
    currPageRef (pageref) {
        if (pageref && pageref.state &&
            pageref.state.c__currentItem === 'warranty_management_rules') {
            this.getCoverageValuesForWarrantyTerm();
        }
    }

    getCoverageValuesForWarrantyTerm () {
        this.apiInProgress = true;
        getCoverageValuesOfWarrantyTerm().then(result => {
            this.mapcoveragePicklistValues = result;
            getDateFieldsOfAsset().then(value => {
                this.mapDateFieldsOfAsset = value;
                getObjectMappings().then(returnVal => {
                    this.mapObjectMapping = returnVal;
                    getWarrantyConfigurationRecord().then(data => {
                        const recentlyViewedRecord = {
                            configurationId: data.Id,
                            configurationName: ADMIN_MODULES.WARRANTY_MANAGEMENT_SETTINGS,
                            configurationType: ADMIN_MODULES.WARRANTY_MANAGEMENT_SETTINGS
                        };
                        saveRecentViewItem(recentlyViewedRecord)
                            .then(recentItem => {
                                if (!verifyApiResponse(recentItem)) {
                                    this.error = recentItem.message;
                                }
                            });
                        this.populateWarrantyRulesData(data);
                    });
                });
            });
        });
    }

    populateWarrantyRulesData (data) {
        this.warrConfigRecordToRefresh = data;
        if (data) {
            this.dateMapping.splice(0, this.dateMapping.length);
            this.warrConfigRecord = JSON.stringify(data);

            if (
                data.SVMXA360__EffectiveFromConfig__c &&
                this.mapcoveragePicklistValues
            ) {
                const mapPicklistValueLabel = this.mapcoveragePicklistValues;
                const configuredCoverage = JSON.parse(
                    data.SVMXA360__EffectiveFromConfig__c
                );
                for (const key in mapPicklistValueLabel) {
                    if (
                        Object.prototype.hasOwnProperty.call(
                            mapPicklistValueLabel,
                            key
                        )
                    ) {
                        const mappedValue = this.mapDateFieldsOfAsset[
                            configuredCoverage[key]
                        ];
                        const valueLabel = mappedValue
                            ? mappedValue
                            : i18n.lblNotSet;
                        this.dateMapping.push({
                            key: key,
                            keyLabel: mapPicklistValueLabel[key],
                            value: configuredCoverage[key],
                            valueLabel: valueLabel
                        });
                    }
                }
            }
            if (typeof data.SVMXA360__AutoWarrOnCreateAsset__c != 'undefined') {
                this.isAutoWarrOnCreate =
                    data.SVMXA360__AutoWarrOnCreateAsset__c;
            }
            if (typeof data.SVMXA360__AutoWarrOnUpdateAsset__c != 'undefined') {
                this.isAutoWarrOnUpdate =
                    data.SVMXA360__AutoWarrOnUpdateAsset__c;
            }
            if (data.SVMXA360__ObjectMapping__c) {
                for (const key in this.mapObjectMapping) {
                    if (key === data.SVMXA360__ObjectMapping__c) {
                        this.objectMapping = this.mapObjectMapping[key];
                        this.editObjectMapping = key;
                    }
                }
            }

            this.loadView();
        } else {
            this.loadView();
        }
        this.apiInProgress = false;
    }
    loadView () {
        this.loadDefaultObjectMappingValues();
        this.loadDefaultFieldMappingValues();
    }

    loadDefaultFieldMappingValues () {
        if (this.dateMapping.length <= 0) {
            for (const key in this.mapcoveragePicklistValues) {
                if (
                    Object.prototype.hasOwnProperty.call(
                        this.mapcoveragePicklistValues,
                        key
                    )
                ) {
                    this.dateMapping.push({
                        key: key,
                        keyLabel: this.mapcoveragePicklistValues[key],
                        value: '',
                        valueLabel: i18n.lblNotSet
                    });
                }
            }
        }
    }

    loadDefaultObjectMappingValues () {
        if (this.objectMappingOptions.length <= 0) {
            for (const key in this.mapObjectMapping) {
                if (
                    Object.prototype.hasOwnProperty.call(
                        this.mapObjectMapping,
                        key
                    )
                ) {
                    const option = {
                        label: this.mapObjectMapping[key],
                        value: key
                    };
                    this.objectMappingOptions = [
                        ...this.objectMappingOptions,
                        option
                    ];
                }
            }
        }
    }

    handleOnCreateCheckbox (event) {
        this.isAutoWarrOnCreateNewVal = event.target.checked;
    }

    handleOnUpdateCheckbox (event) {
        this.isAutoWarrOnUpdateNewVal = event.target.checked;
    }

    handleCancel () {
        this.editMode = false;
    }

    handleMappingChange (event) {
        this.editObjectMappingNewVal = event.target.value;
    }

    handleChangeAssetField (event) {
        event.preventDefault();
        this.updateDataMapping(
            event.target.getAttribute('data-row-key'),
            event.detail.value
        );
    }

    handleClearDetail (event) {
        event.preventDefault();
        this.updateDataMapping(event.target.getAttribute('data-row-key'), null);
    }

    updateDataMapping (keyName, value) {
        const itemIndex = this.dateMappingNewVal.findIndex(
            item => item.key === keyName
        );
        if (itemIndex > -1) {
            this.dateMappingNewVal[itemIndex].value = value;
        }
    }

    handleEdit () {
        if (this.assetFieldOptions.length <= 0) {
            for (const key in this.mapDateFieldsOfAsset) {
                if (
                    Object.prototype.hasOwnProperty.call(
                        this.mapDateFieldsOfAsset,
                        key
                    )
                ) {
                    const option = {
                        label: this.mapDateFieldsOfAsset[key],
                        value: key
                    };
                    this.assetFieldOptions = [
                        ...this.assetFieldOptions,
                        option
                    ];
                }
            }
        }
        this.isAutoWarrOnCreateNewVal = this.isAutoWarrOnCreate;
        this.isAutoWarrOnUpdateNewVal = this.isAutoWarrOnUpdate;
        this.editObjectMappingNewVal = this.editObjectMapping;
        this.dateMappingNewVal = JSON.parse(JSON.stringify(this.dateMapping));
        this.editMode = true;
    }

    handleSave () {
        const allRows = this.template.querySelectorAll('li');
        const fieldMapping = {};
        allRows.forEach(eachRow => {
            if (eachRow.id) {
                const coverageField = eachRow.querySelector(
                    'lightning-layout lightning-layout-item div.key'
                );

                const assetField = eachRow.querySelector(
                    'lightning-layout lightning-layout-item lightning-combobox.value'
                );

                if (assetField) {
                    fieldMapping[coverageField.title] = assetField.value;
                }
            }
        });

        let warrConfigRecordToSave = {};
        if (this.warrConfigRecord) {
            warrConfigRecordToSave = JSON.parse(this.warrConfigRecord);
        } else {
            warrConfigRecordToSave = {
                sobjectType: 'SVMXA360__CONF_WarrantyConfig__c'
            };
            warrConfigRecordToSave.SVMXA360__RuleScope__c = 'Global';
        }

        warrConfigRecordToSave.SVMXA360__AutoWarrOnCreateAsset__c = this.isAutoWarrOnCreateNewVal;
        warrConfigRecordToSave.SVMXA360__AutoWarrOnUpdateAsset__c = this.isAutoWarrOnUpdateNewVal;
        warrConfigRecordToSave.SVMXA360__ObjectMapping__c = this.editObjectMappingNewVal;
        warrConfigRecordToSave.SVMXA360__EffectiveFromConfig__c = JSON.stringify(
            fieldMapping
        );

        updateRecord({ recordToUpdate: warrConfigRecordToSave })
            .then(result => {
                this.populateWarrantyRulesData(result);
                const evt = new ShowToastEvent({
                    title: this.i18n.lblRecordSaved,
                    message: result,
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: this.i18n.lblRecordSaveError,
                    message: error,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            });
        this.editMode = false;
    }

    handleCreateMapping (event) {
        event.preventDefault();
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__component',
            attributes: {
                componentName: 'SVMXA360__mappingDetail'
            },
            state: {
                c__actionName: PAGE_ACTION_TYPES.NEW,
                c__mappingType: MAPPING_TYPES.FIELD,
                c__source: 'WarrantyTerm',
                c__target: 'AssetWarranty'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}