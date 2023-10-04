import { LightningElement, track } from 'lwc';
import getDepotFinderRule from '@salesforce/apex/DPOT_ManageDepotRule_LS.getDepotFinderRule';
import getLocationServicesFields
    from '@salesforce/apex/DPOT_ManageDepotRule_LS.getLocationServicesFields';
import getSourceObjectFields from '@salesforce/apex/DPOT_ManageDepotRule_LS.getSourceObjectFields';
import getObjectMappings from '@salesforce/apex/DPOT_ManageDepotRule_LS.getObjectMappings';
import updateDepotRuleRecord from '@salesforce/apex/DPOT_ManageDepotRule_LS.updateDepotRuleRecord';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import btnEdit from '@salesforce/label/c.Btn_Edit';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnSave from '@salesforce/label/c.Btn_Save';
import lblYes from '@salesforce/label/c.Lbl_Yes';
import lblNo from '@salesforce/label/c.Lbl_No';
import lblNotSet from '@salesforce/label/c.Lbl_Not_set';
import titleDepotManagement from '@salesforce/label/c.Title_DepotFinder';
import titleSetting from '@salesforce/label/c.Label_Settings';
import secDepotSettings from '@salesforce/label/c.Sec_DepotFinder_DepotSettings';
import lblEnableDepotLocator from '@salesforce/label/c.Label_DepotFinder_EnableDepot';
import secMatchSettings from '@salesforce/label/c.Sec_DepotFinder_MatchSettings';
import lblProductFamilyMatch from '@salesforce/label/c.Label_DepotFinder_ProductFamilyMatch';
import lblKeyMatch from '@salesforce/label/c.Label_DepotFinder_KeyMatch';
import lblLocationServicesKey from '@salesforce/label/c.Label_DepotFinder_LocationServices';
import lblKeySearchOnSource from '@salesforce/label/c.Label_DepotFinder_Key_Search_Source';
import lblMapping from '@salesforce/label/c.Label_DepotFinder_ObjectMapping';
import msgRecordSaved from '@salesforce/label/c.Message_DepotFinder_Save';
import msgRecordSaveError from '@salesforce/label/c.Message_DepotFinder_Error';
import msgEnableDepotValidationError
    from '@salesforce/label/c.Message_DepotFinder_Validation_EnableDepot';
import msgDepotKeyMatchValidationError
    from '@salesforce/label/c.Message_DepotFinder_Validation_Key';
import labelLoading from '@salesforce/label/c.AltText_LoadingDepotManagementSettings';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelDepotSettingsHelp from '@salesforce/label/c.URL_DepotSettingsHelp';

import {
    ICON_NAMES,
    verifyApiResponse,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

const i18n = {
    titleDepotManagement: titleDepotManagement,
    titleSetting: titleSetting,
    btnEdit: btnEdit,
    btnCancel: btnCancel,
    btnSave: btnSave,
    secDepotSettings: secDepotSettings,
    lblEnableDepotLocator: lblEnableDepotLocator,
    secMatchSettings: secMatchSettings,
    lblProductFamilyMatch: lblProductFamilyMatch,
    lblKeyMatch: lblKeyMatch,
    lblLocationServicesKey: lblLocationServicesKey,
    lblKeySearchOnSource: lblKeySearchOnSource,
    lblMapping: lblMapping,
    lblYes: lblYes,
    lblNo: lblNo,
    lblNotSet: lblNotSet,
    msgRecordSaved: msgRecordSaved,
    msgRecordSaveError: msgRecordSaveError,
    msgEnableDepotValidationError: msgEnableDepotValidationError,
    msgDepotKeyMatchValidationError: msgDepotKeyMatchValidationError,
    loading: labelLoading,
    helpLink: labelDepotSettingsHelp,
    help: labelHelp
};

export default class DepotFinderRule extends LightningElement {
    editMode = false;
    depotFinderRuleRecord;
    isDepotFinder;
    isProductFamilyMatch;
    isKeyMatch;
    locationServiceFieldLabelName;
    locationServiceFieldAPIName;
    sourceFieldLabelName;
    sourceFieldAPIName;
    objectMappingLabel;
    objectMapping;
    @track objectMappingOptions = [];
    @track sourceObjectFieldOptions = [];
    @track locationServicesFieldOptions = [];
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

    connectedCallback () {
        this.apiInProgress = true;
        getDepotFinderRule().then(result => {
            this.depotFinderRuleRecord = JSON.stringify(result.data);
            this.populateDepotFinderRulesData(result.data);
            const recentlyViewedRecord = {
                configurationId: result.data.Id,
                configurationName: ADMIN_MODULES.DEPOT_SETTINGS,
                configurationType: ADMIN_MODULES.DEPOT_SETTINGS
            };
            saveRecentViewItem(recentlyViewedRecord)
                .then(recentItem => {
                    if (!verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });
        });
    }

    populateDepotFinderRulesData (data) {
        if (data) {
            if (typeof data.SVMXA360__EnableDepotFinder__c != 'undefined') {
                this.isDepotFinder = data.SVMXA360__EnableDepotFinder__c;
            }
            if (typeof data.SVMXA360__MatchProductAndFamily__c != 'undefined') {
                this.isProductFamilyMatch = data.SVMXA360__MatchProductAndFamily__c;
            }
            if (typeof data.SVMXA360__LocationServiceFieldAPIName__c != 'undefined') {
                this.locationServiceFieldAPIName = data.SVMXA360__LocationServiceFieldAPIName__c;
            }
            this.populateLocationServiceFields();

            if (typeof data.SVMXA360__SourceFieldAPIName__c != 'undefined') {
                this.sourceFieldAPIName = data.SVMXA360__SourceFieldAPIName__c;
            }
            this.populateSourceObjectFields();

            if (this.locationServiceFieldAPIName && this.sourceFieldAPIName) {
                this.isKeyMatch = true;
            }
            if (typeof data.SVMXA360__ObjectMapping__c != 'undefined') {
                this.objectMapping = data.SVMXA360__ObjectMapping__c;
            }
            this.populateObjectMappings();
        }
        this.apiInProgress = false;
    }

    populateLocationServiceFields () {
        getLocationServicesFields().then(result => {
            if (result.data && this.locationServicesFieldOptions.length <= 0) {
                for (const key in result.data) {
                    if (Object.prototype.hasOwnProperty.call(result.data, key)) {
                        this.locationServicesFieldOptions.push(
                            { label: result.data[key], value: key }
                        );
                    }
                }
            }
            const matchingLocationField = this.locationServicesFieldOptions.find(
                eachField => eachField.value === this.locationServiceFieldAPIName
            );
            if (matchingLocationField) {
                this.locationServiceFieldLabelName = matchingLocationField.label;
            }
        });
    }

    populateSourceObjectFields () {
        getSourceObjectFields().then(result => {
            if (result.data && this.sourceObjectFieldOptions.length <= 0) {
                for (const key in result.data) {
                    if (Object.prototype.hasOwnProperty.call(result.data, key)) {
                        this.sourceObjectFieldOptions.push({ label: result.data[key], value: key });
                    }
                }
            }
            const matchingSourceField = this.sourceObjectFieldOptions.find(
                eachField => eachField.value === this.sourceFieldAPIName
            );
            if (matchingSourceField) {
                this.sourceFieldLabelName = matchingSourceField.label;
            }
        });
    }

    populateObjectMappings () {
        getObjectMappings().then(result => {
            if (result.data && this.objectMappingOptions.length <= 0) {
                for (const key in result.data) {
                    if (Object.prototype.hasOwnProperty.call(result.data, key)) {
                        this.objectMappingOptions.push({ label: result.data[key], value: key });
                    }
                }
            }
            const matchingObjectMapping = this.objectMappingOptions.find(
                eachMapping => eachMapping.value === this.objectMapping
            );
            if (matchingObjectMapping) {
                this.objectMappingLabel = matchingObjectMapping.label;
            }
        });
    }

    handleEnableDepotLocator (event) {
        this.isDepotFinder = event.target.checked;
    }

    handleProductFamilyMatch (event) {
        this.isProductFamilyMatch = event.target.checked;
    }

    handleCancel () {
        this.editMode = false;
    }

    handleKeyMatch (event) {
        this.isKeyMatch = event.target.checked;
    }

    handleLocationFieldChange (event) {
        this.locationServiceFieldAPIName = event.target.value;
    }

    handleSourceFieldChange (event) {
        this.sourceFieldAPIName = event.target.value;
    }

    handleMappingChange (event) {
        this.objectMapping = event.target.value;
    }

    handleEdit () {
        this.editMode = true;
    }

    handleSave () {
        let depotFinderRuleRecordToSave = {};
        if (this.depotFinderRuleRecord) {
            depotFinderRuleRecordToSave = JSON.parse(this.depotFinderRuleRecord);
        } else {
            depotFinderRuleRecordToSave = {
                sobjectType: 'SVMXA360__CONF_DepotFinderRule__c'
            };
            depotFinderRuleRecordToSave.SVMXA360__RuleScope__c = 'Global';
        }

        if (this.isDepotFinder) {
            if (!this.isProductFamilyMatch && !this.isKeyMatch) {
                const evt = new ShowToastEvent({
                    title: this.i18n.msgRecordSaveError,
                    message: this.i18n.msgEnableDepotValidationError,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                return;
            } else if (this.isKeyMatch &&
                !(this.locationServiceFieldAPIName && this.sourceFieldAPIName)) {
                const evt = new ShowToastEvent({
                    title: this.i18n.msgRecordSaveError,
                    message: this.i18n.msgDepotKeyMatchValidationError,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                return;
            }
        } else {
            this.isProductFamilyMatch = false;
            this.locationServiceFieldAPIName = '';
            this.sourceFieldAPIName = '';
            this.objectMapping = '';
        }

        if (!this.isKeyMatch) {
            this.locationServiceFieldAPIName = '';
            this.sourceFieldAPIName = '';
        }
        depotFinderRuleRecordToSave.SVMXA360__EnableDepotFinder__c = this.isDepotFinder;
        depotFinderRuleRecordToSave.SVMXA360__MatchProductAndFamily__c = this.isProductFamilyMatch;
        depotFinderRuleRecordToSave.SVMXA360__LocationServiceFieldAPIName__c =
        this.locationServiceFieldAPIName;
        depotFinderRuleRecordToSave.SVMXA360__SourceFieldAPIName__c = this.sourceFieldAPIName;
        depotFinderRuleRecordToSave.SVMXA360__ObjectMapping__c = this.objectMapping;

        updateDepotRuleRecord({ recordToUpdate: depotFinderRuleRecordToSave })
            .then(result => {
                this.populateDepotFinderRulesData(result);
                const evt = new ShowToastEvent({
                    title: this.i18n.msgRecordSaved,
                    message: result,
                    variant: 'success'
                });
                this.editMode = false;
                this.dispatchEvent(evt);
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: this.i18n.msgRecordSaveError,
                    message: error,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            });
    }
}