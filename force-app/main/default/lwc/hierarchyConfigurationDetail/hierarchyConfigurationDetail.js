import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LOCATION_OBJECT from '@salesforce/schema/Location';
import ASSET_OBJECT from '@salesforce/schema/Asset';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

import hierarchyConfigResource
    from '@salesforce/resourceUrl/hierarchyConfig';

import labelAssetManagement from '@salesforce/label/c.LabelAssetManagement';
import labelHierarchy from '@salesforce/label/c.LabelHierarchy';
import labelName from '@salesforce/label/c.Label_Name';
import labelSetAsDefault from '@salesforce/label/c.Label_SetAsDefault';
import labelObjectSelection from '@salesforce/label/c.Label_ObjectSelection';
import labelIconPickForDisplay from '@salesforce/label/c.Title_IconPickForDisplay';
import labelDefaultRecordAccess from '@salesforce/label/c.Label_DefaultRecordAccess';
import labelEnableSPMWizards from '@salesforce/label/c.Label_EnableSPMWizards';
import labelAvailableFields from '@salesforce/label/c.Label_Available_Fields';
import labelFieldstoDisplay from '@salesforce/label/c.Label_SelectFieldstoDisplay';
import labelProfileAssignment from '@salesforce/label/c.Label_ProfileAssignment';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import btnBackToList from '@salesforce/label/c.Button_BackToList';
import btnEdit from '@salesforce/label/c.Button_Edit';
import secGeneralInformation from '@salesforce/label/c.Sec_General_Information';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelContinueConfirmation from '@salesforce/label/c.Label_ContinueConfirmation';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelSave from '@salesforce/label/c.Button_Save';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelLocation from '@salesforce/label/c.Label_Location';
import labelAccount from '@salesforce/label/c.Label_Account';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelReassignProfile from '@salesforce/label/c.Label_ReassignProfile';
import labelReassignProfileContent from '@salesforce/label/c.Label_ReassignProfileContent';
import labelFieldsLimit from '@salesforce/label/c.Message_FieldsLimitDisplay';
import selectFieldsForDisplay from '@salesforce/label/c.Label_SelectFieldsForDisplay';
import selectoption from '@salesforce/label/c.Error_SelectOption';
import labelFieldForDisplayIconName from '@salesforce/label/c.Label_FieldForDisplayIconName';
import labelSelectorModalTitle from '@salesforce/label/c.Label_SelectorModalTitle';
import labelCriteriaToShowRecord from '@salesforce/label/c.Label_FieldForDisplayExpression'
import labelEnableAssetNotification from '@salesforce/label/c.Label_EnableAssetNotification';
import labelCriteriaToShowNotificationRecord
    from '@salesforce/label/c.Label_FieldForNotificationExpression';
import labelAllowManagingChildAssets from '@salesforce/label/c.Label_AllowManagingChildAssets';


import { getFieldDefinitionsForEntities } from 'c/metadataService';
import {
    parseErrorMessage,
    verifyApiResponse,
    PAGE_ACTION_TYPES,
    isEmptyString,
    isNotUndefinedOrNull,
    handleMenuSelection,
    normalizeDeveloperName,
    ICON_NAMES,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

import getAssignedProfileDetails
    from '@salesforce/apex/ADM_HierarchyConfig_LS.getAssignedProfileDetails';
import getHierarchyConfigDetails
    from '@salesforce/apex/ADM_HierarchyConfig_LS.getHierarchyConfigurationWithDetails';
import saveHierarchyConfiguration
    from '@salesforce/apex/ADM_HierarchyConfig_LS.saveHierarchyConfiguration';

const i18n = {
    pageHeader: labelAssetManagement,
    hierarchy: labelHierarchy,
    hierarchyName: labelName,
    setAsDefault: labelSetAsDefault,
    objectSelection: labelObjectSelection,
    iconTitle: labelIconPickForDisplay,
    defaultRecordAccess: labelDefaultRecordAccess,
    enableSPMWizards: labelEnableSPMWizards,
    availableFields: labelAvailableFields,
    fieldstoDisplay: labelFieldstoDisplay,
    profileAssignment: labelProfileAssignment,
    cancelModalTitle: labelCancelModalTitle,
    btnBackToList: btnBackToList,
    btnEdit: btnEdit,
    generalInfoSection: secGeneralInformation,
    edit: labelEditMenuItem,
    continueConfirmation: labelContinueConfirmation,
    cancelModalContent: labelCancelModal,
    goBack: labelNoGoBack,
    continue: labelYesContinue,
    copyOf: labelCopyOf,
    formValidation: labelFormValidation,
    wasSaved: labelWasSaved,
    cancel: labelCancel,
    save: labelSave,
    developerName: labelDeveloperName,
    description: labelDescription,
    location: labelLocation,
    account: labelAccount,
    asset: labelAsset,
    reassignProfile: labelReassignProfile,
    reassignProfileContent: labelReassignProfileContent,
    fieldsLimit: labelFieldsLimit,
    selectFieldsForDisplay: selectFieldsForDisplay,
    selectoption: selectoption,
    fieldForDisplayIconName: labelFieldForDisplayIconName,
    criteriaToShowRecord: labelCriteriaToShowRecord,
    selectorModalTitle: labelSelectorModalTitle,
    enableAssetNotification: labelEnableAssetNotification,
    criteriaToShowNotificationRecord: labelCriteriaToShowNotificationRecord,
    allowManagingChildAssets: labelAllowManagingChildAssets
}

const CLONE_NAME_PREFIX = i18n.copyOf;
const DASH = '  -  ';
const OBJECT_LABELS = [
    { label: i18n.location, name: LOCATION_OBJECT.objectApiName },
    { label: i18n.asset, name: ASSET_OBJECT.objectApiName },
    { label: i18n.account, name: ACCOUNT_OBJECT.objectApiName },
];

export default class HierarchyConfigurationDetail extends NavigationMixin(LightningElement) {

    @track locationObj = LOCATION_OBJECT.objectApiName;
    @track assetObj = ASSET_OBJECT.objectApiName;
    @track accountObj = ACCOUNT_OBJECT.objectApiName;
    @track availableLocationFields=[];
    @track availableAssetFields=[];
    @track availableAccountFields=[];
    @track recordInfo = {};
    @track hierarchyConfigAccess=[];
    @track hierarchyConfigDetails=[];
    @track previouslyAssignedProfiles = [];
    @track reAssignedProfileDetails=[];
    @track apiInProgress = false;
    @track booleanFalse = false;
    @track booleanTrue = true;
    @track clearStateNeeded = false;
    @track error;

    @track hierarchyConfigObjects = this.initializeConfigObjects();
    @track showIconModalForObjects = this.initializeIconVisibilityForObjects();

    _recordId = '';
    _actionName;
    currentNavItem;
    isDirty= false;
    cancelModalDialogOpen = false;
    reAssignModalDialogOpen = false;
    showProfileSelector = false;
    selectorModalOpen = false;
    selectedObject;
    selectedNotificationParent;

    get i18n () {
        return i18n;
    }

    get developerNameDisabled () {
        return (this._actionName === PAGE_ACTION_TYPES.VIEW ||
            this._actionName === PAGE_ACTION_TYPES.EDIT);
    }

    get selectedProfileIds () {
        const profileIds = [];
        if (this.hierarchyConfigAccess) {
            this.hierarchyConfigAccess.forEach(row => {
                profileIds.push(row.profileId);
            });
        }
        return profileIds;
    }

    get assignedProfileIds () {
        const assignedProfileIds = [];
        if (this.previouslyAssignedProfiles && this.previouslyAssignedProfiles.length > 0) {
            this.previouslyAssignedProfiles.forEach(row => {
                assignedProfileIds.push(row.profileId);
            });
        }
        return assignedProfileIds;
    }

    get hierarchyConfigObjectDetails () {
        let objectDetails = [];
        if (this.hierarchyConfigObjects && this.hierarchyConfigObjects.length > 0) {
            objectDetails = this.hierarchyConfigObjects.map((element) => {
                return {
                    objDetail: element,
                    objLabel: this.getObjectLabel(element.objectAPIName),
                    objectAPIName: element.objectAPIName,
                    showIconPickerModal: this.showIconModal(element.objectAPIName),
                    iconLookupValue: this.getIconLookupValueForObject(element.objectAPIName),
                    displayIconName: this.getDisplayIconName(element.objectAPIName),
                    fieldForDisplayIconName: element.fieldForDisplayIconName,
                    fieldForDisplayIconNameOptions:
                        this.getAvailableFormulaFieldsForObject(element.objectAPIName),
                    defaultRecordActions: element.defaultRecordActions ?
                        element.defaultRecordActions: false,
                    enableSPMWizards: element.enableSPMWizards ? element.enableSPMWizards : false,
                    availableFields: this.getAvailableFieldsForObject(element.objectAPIName),
                    selectedFields: this.getSelectedFieldsForObject(element.objectAPIName),
                    selectedExpression: this.getExpressionValueForObject(element.objectAPIName),
                    qualifyingCriteria: element.qualifyingCriteria,
                    qualifyingCriteriaName: element.qualifyingCriteriaName,
                    hasAssetNotificationFields: element.objectAPIName === this.assetObj,
                    enableNotifications:
                     element.enableNotifications ? element.enableNotifications : false,
                    notificationCriteria: element.notificationCriteria,
                    notificationCriteriaName: element.notificationCriteriaName,
                    selectedNotificationsExpression:
                     this.getNotificationExpressionValueForObject(element.objectAPIName),
                    enableNotificationExpression:
                     element.enableNotifications ? false : true,
                    allowManagingChildAssets: element.allowManagingChildAssets,
                    hasAllowManagingChildAssets: element.objectAPIName === this.assetObj,
                    enableManagingChildAssets: false,
                };
            });
        }
        return objectDetails;
    }

    get sourceRecordId () {
        const recordId =(this._actionName === PAGE_ACTION_TYPES.CLONE ||
            isEmptyString(this._recordId) ) ? '' : this._recordId;
        return recordId;
    }

    get profileAndConfigInfo () {

        let reAssignedProfileConfig = [];
        if (this.reAssignedProfileDetails && this.reAssignedProfileDetails.length > 0) {
            reAssignedProfileConfig = this.reAssignedProfileDetails.map((element) => {
                const configNames = ( element.hierarchyConfigNames &&
                    element.hierarchyConfigNames.length > 0 )?
                    element.hierarchyConfigNames.join(',') : '';
                return {
                    profileName: element.profileName,
                    hierarchyConfigName: configNames,
                    profileConfigInfo: `${element.profileName} ${DASH} ${configNames}`,
                };
            });
        }
        return reAssignedProfileConfig;
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    renderedCallback () {
        loadStyle(this, hierarchyConfigResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        if (this.clearStateNeeded) {
            this.clearStateNeeded = false;
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        if (currentPageReference && currentPageReference.state) {
            this.clearState();
            this.apiInProgress = true;
            if (currentPageReference.state.c__recordId) {
                this._recordId = currentPageReference.state.c__recordId;
            }

            if (currentPageReference.state.c__actionName) {
                this._actionName = currentPageReference.state.c__actionName.toLowerCase();
            }

            if (currentPageReference.state.c__objectName) {
                this.objectName = currentPageReference.state.c__objectName;
            }

            if (currentPageReference.state.c__currentItem) {
                this.currentNavItem = currentPageReference.state.c__currentItem;
            }
            this.loadView();
            this.loadAssignedProfileDetails();
            this.getFieldsDescribeResults();
            this.apiInProgress = false;
        }
    }

    loadView () {
        switch (this._actionName) {
            case PAGE_ACTION_TYPES.VIEW:
            case PAGE_ACTION_TYPES.EDIT:
            case PAGE_ACTION_TYPES.CLONE:
                this.getExistingRecordDetails();
                break;
            default:
                break;
        }
    }

    clearState () {
        this.error = null;
        this._actionName = null;
        this.recordInfo = {};
        this.availableAccountFields = [];
        this.availableLocationFields = [];
        this.availableAssetFields = [];
        this.hierarchyConfigObjects = this.initializeConfigObjects();
        this.hierarchyConfigAccess = [];
        this.reAssignedProfileDetails = [];
        this.previouslyAssignedProfiles = [];
        this.apiInProgress = false;
        this.isDirty = false;
        this.clearStateNeeded = true;
        this.showProfileSelector = false;
    }

    loadAssignedProfileDetails () {
        getAssignedProfileDetails({ hierarchyConfigId: this.sourceRecordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.previouslyAssignedProfiles = result.data;
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.showProfileSelector = true;
                this.apiInProgress = false;
            });
    }

    getExistingRecordDetails () {
        if (isEmptyString(this._recordId)) return;

        getHierarchyConfigDetails({ hierarchyConfigId: this._recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const resultData = result.data;
                this.saveRecentItem(resultData);
                this.populateRecordInfo (resultData);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    populateRecordInfo (data) {
        this.recordInfo = { ...this.recordInfo, ...data };
        this.hierarchyConfigAccess = this.recordInfo.hierarchyConfigAccessList;
        this.hierarchyConfigObjects = this.recordInfo.hierarchyConfigDetailList;
        if (this.hierarchyConfigAccess && this.hierarchyConfigAccess.length > 0) {
            this.hierarchyConfigAccess.forEach(row => {
                row.id = null;
            });
        }
        if (this.hierarchyConfigObjects && this.hierarchyConfigObjects.length > 0) {
            this.hierarchyConfigObjects.forEach(row => {
                row.hierarchyConfigFieldList.forEach(field => {
                    field.id = null;
                });
            });
        }
        if (this._actionName === PAGE_ACTION_TYPES.CLONE) {
            this.markAsClone(CLONE_NAME_PREFIX);
        }
    }

    markAsClone (namePrefix) {
        this.recordInfo.name = namePrefix + ' ' + this.recordInfo.name;
        this.recordInfo.id = null;
        this.hierarchyConfigAccess =[];
        this.recordInfo.developerName = normalizeDeveloperName(this.recordInfo.name);
        if (this.hierarchyConfigObjects && this.hierarchyConfigObjects.length > 0) {
            this.hierarchyConfigObjects.forEach(row => {
                row.id = null;
            });
        }
    }

    initializeConfigObjects () {
        return [
            { objectAPIName: this.locationObj,
                defaultRecordActions: true,
                enableSPMWizards: false },
            { objectAPIName: this.assetObj,
                defaultRecordActions: true,
                enableSPMWizards: false,
                allowManagingChildAssets: true },
            { objectAPIName: this.accountObj,
                defaultRecordActions: true,
                enableSPMWizards: false }];
    }

    initializeIconVisibilityForObjects () {
        return [ { objectAPIName: this.locationObj,isVisible: false },
            { objectAPIName: this.assetObj,isVisible: false },
            { objectAPIName: this.accountObj,isVisible: false }];
    }

    getObjectLabel (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const objectLabel = OBJECT_LABELS.find(item => item.name === objectApiName).label;
        return objectLabel;
    }

    showIconModal (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        return this.showIconModalForObjects.find(
            item => item.objectAPIName === objectApiName).isVisible;
    }

    getIconLookupValueForObject (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const iconLabel = this.hierarchyConfigObjects.find(
            item => item.objectAPIName === objectApiName);
        if (iconLabel && iconLabel.displayIconName)
            return {
                label: iconLabel.displayIconName,
                value: iconLabel.displayIconName,
                iconName: iconLabel.displayIconName
            };

        return null;
    }

    getNotificationExpressionValueForObject (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const expressionLabel = this.hierarchyConfigObjects.find(
            item => item.objectAPIName === objectApiName);
        if (expressionLabel && expressionLabel.notificationCriteriaName)
            return {
                label: expressionLabel.notificationCriteriaName,
                value: expressionLabel.notificationCriteria
            };

        return null;
    }

    getExpressionValueForObject (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const expressionLabel = this.hierarchyConfigObjects.find(
            item => item.objectAPIName === objectApiName);
        if (expressionLabel && expressionLabel.qualifyingCriteriaName)
            return {
                label: expressionLabel.qualifyingCriteriaName,
                value: expressionLabel.qualifyingCriteria
            };

        return null;
    }

    getDisplayIconName (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const iconName = this.getIconLookupValueForObject (objectApiName);
        return iconName && iconName.value ? iconName.value : '';
    }

    getAvailableFieldsForObject (objectName) {
        if (isEmptyString(objectName))  return '';
        if (objectName === LOCATION_OBJECT.objectApiName) {
            return this.availableLocationFields;
        } else if (objectName === ASSET_OBJECT.objectApiName) {
            return this.availableAssetFields;
        }
        return this.availableAccountFields;
    }

    getAvailableFormulaFieldsForObject (objectName) {
        if (isEmptyString(objectName))  return '';
        let availableFormulaFields = [
            { label: '', value: '' },
        ];
        if (objectName === LOCATION_OBJECT.objectApiName) {
            availableFormulaFields = availableFormulaFields.concat (this.availableLocationFields
                .filter(field => field.dataType === "STRING" && field.isFormula));
        } else if (objectName === ASSET_OBJECT.objectApiName) {
            availableFormulaFields = availableFormulaFields.concat ( this.availableAssetFields
                .filter(field => field.dataType === "STRING" && field.isFormula));
        } else {
            availableFormulaFields = availableFormulaFields.concat ( this.availableAccountFields
                .filter(field => field.dataType === "STRING" && field.isFormula));
        }
        if (availableFormulaFields.length > 1) {
            return availableFormulaFields;
        }
        return null;
    }

    handleFieldForDisplayIconChange (event) {
        const objectApiname = event.target.dataset.object;
        const value = event.target.value;
        const fieldName = event.target.dataset.field;
        let objIndex = 0;
        if (objectApiname) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === objectApiname));
            if (isEmptyString(value)) {
                this.hierarchyConfigObjects[objIndex][fieldName] = null;
                event.target.value = null;
            } else {
                this.hierarchyConfigObjects[objIndex][fieldName] = value;
            }
            this.isDirty = true;
        }
    }


    getSelectedFieldsForObject (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const objDetail = this.hierarchyConfigObjects.find(
            item => item.objectAPIName === objectApiName);
        const selectedFields = [];
        if (objDetail && objDetail.hierarchyConfigFieldList) {
            objDetail.hierarchyConfigFieldList.forEach(row => {
                selectedFields.push(row.fieldAPIName);
            });
        }
        return selectedFields;
    }

    async getFieldsDescribeResults () {

        const objectNames = [this.locationObj,this.assetObj,this.accountObj];
        try {
            const resp = await getFieldDefinitionsForEntities(objectNames);
            if (resp && resp.data) {
                resp.data.forEach( objectDef => {
                    this.populateObjectFields (objectDef.fieldDefinitions,objectDef.apiName);
                });
                this.apiInProgress = false;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    populateObjectFields (fieldDefinitions,objectName) {
        fieldDefinitions.forEach( field => {
            const { apiName, label, dataType, calculated } = field;
            if ( apiName !== 'Name' && dataType !== 'LOCATION' && dataType !== 'ADDRESS' &&
                 dataType !== 'BASE64' && dataType !== 'ENCRYPTEDSTRING' &&
                 dataType !== 'TEXTAREA' && apiName !== 'LogoId' && apiName !== 'Id') {
                const fieldWrap = {
                    label,
                    value: apiName,
                    secondary: apiName,
                    dataType: dataType,
                    isFormula: calculated
                }
                if (objectName === this.locationObj) {
                    this.availableLocationFields.push(fieldWrap);
                } else if (objectName === this.assetObj) {
                    this.availableAssetFields.push(fieldWrap);
                } else {
                    this.availableAccountFields.push(fieldWrap);
                }
            }
        });
    }

    handleIconPickerOpen (event) {
        const targetElement = event.target;
        const objName = targetElement.dataset.object;
        let objIndex = 0;
        if (objName) {
            objIndex = this.showIconModalForObjects.findIndex(
                (obj => obj.objectAPIName === objName));
        }
        this.showIconModalForObjects[objIndex].isVisible = true;
    }

    handleIconRemoved (event) {
        const targetElement = event.target;
        const objName = targetElement.dataset.object;
        const fieldName = targetElement.dataset.field;
        let objIndex = 0;
        if (objName) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === objName));
        }
        this.hierarchyConfigObjects[objIndex][fieldName] = null;
        this.isDirty = true;
    }

    handleIconPickerClose (event) {
        const targetElement = event.target;
        const objName = targetElement.dataset.object;
        let objIndex = 0;
        if (objName) {
            objIndex = this.showIconModalForObjects.findIndex(
                (obj => obj.objectAPIName === objName));
        }
        this.showIconModalForObjects[objIndex].isVisible = false;
    }

    handleIconPickerApply (event) {
        const targetElement = event.target;
        const objName = targetElement.dataset.object;
        const fieldName = targetElement.dataset.field;
        let objIndex = 0;
        if (objName) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === objName));
        }
        this.hierarchyConfigObjects[objIndex][fieldName] = event.detail.value;
        this.showIconModalForObjects.forEach(row => {
            row.isVisible = false;
        });
        this.isDirty = true;
    }

    handleChange (event) {
        const targetElement = event.target;
        const objName = targetElement.dataset.object;
        const fieldName = targetElement.dataset.field;
        let objIndex = 0;
        if (objName) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === objName));
        }
        if (fieldName === 'hierarchyConfigFieldList') {
            this.hierarchyConfigObjects[objIndex][fieldName] = event.detail.value.map(
                (element, index)=> {
                    return {
                        fieldAPIName: element,
                        id: element.id,
                        sequence: index+1
                    };
                });
        } else {
            this.hierarchyConfigObjects[objIndex][fieldName] =
                ( targetElement.type === 'checkbox' )? targetElement.checked : event.detail.value;
        }
        this.isDirty = true;
    }

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.recordInfo[event.currentTarget.dataset.field] = inputVal;
        this.isDirty = true;
    }

    handleDefaultConfigChange (event) {
        this.recordInfo.defaultConfiguration = event.target.checked;
        this.isDirty = true;
    }

    handleNameCommit () {
        if (!this.recordInfo.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.recordInfo.developerName = normalizeDeveloperName(
                this.recordInfo.name,
                maxLength,
                ''
            );
            this.getDeveloperNameInput().value = this.recordInfo.developerName;
        }
    }

    handleProfileSelected (event) {
        this.hierarchyConfigAccess = event.detail.value.map(element => {
            return {
                profileId: element,
                hierarchyConfigId: this.recordInfo.id
            };
        });
        this.isDirty = true;
    }

    handleCancel () {
        if (this.isDirty) {
            this.cancelModalDialogOpen = true;
        } else {
            this.navigateBack();
        }
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;
        this.navigateBack();
    }

    navigateBack () {
        this.clearState();
        this.handleBackToList();
    }

    handleBackToList () {
        handleMenuSelection({
            detail: {
                name: "hierarchy",
                targetType: "LWC",
                targetDeveloperName: "c-hierarchy-config-list-view"
            }
        }, this);
    }

    handleReassignModalModal () {
        this.reAssignModalDialogOpen = false;
    }

    handleReassignConfirmModal () {
        this.reAssignModalDialogOpen = false;
        this.saveConfigRecord();
    }

    handleSave () {

        if (!this.isValidInput()) return;
        this.reAssignedProfileDetails = [];
        this.hierarchyConfigAccess.forEach(newProfile => {
            const profileAssignmentInfo =  this.previouslyAssignedProfiles.find(
                prev => prev.profileId === newProfile.profileId);
            if (isNotUndefinedOrNull(profileAssignmentInfo)) {
                this.reAssignedProfileDetails.push(profileAssignmentInfo);
            }
        });
        if (this.reAssignedProfileDetails && this.reAssignedProfileDetails.length > 0 ) {
            this.reAssignModalDialogOpen = true;
        } else {
            this.saveConfigRecord();
        }
    }

    saveConfigRecord () {
        this.error = null;
        this.apiInProgress = true;

        this.recordInfo.hierarchyConfigAccessList = this.hierarchyConfigAccess;
        this.recordInfo.hierarchyConfigDetailList = this.hierarchyConfigObjects;
        const recordName = this.recordInfo.name;

        saveHierarchyConfiguration({ requestJson: JSON.stringify(this.recordInfo) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.saveRecentItem(result.data);
                this.navigateBack ();
                this.showSaveSuccessNotification(recordName);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }


    isValidInput () {

        this.error = '';
        const isValid = [...this.template.querySelectorAll(
            '.svmx-hierarchy-config_input-field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (!isValid) {
            this.error = this.i18n.formValidation;
        }
        return isValid;
    }

    showSaveSuccessNotification (hierarchyName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.hierarchy} "${hierarchyName}" ${this.i18n.wasSaved}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    getDeveloperNameInput () {
        return this.template.querySelector('.svmx-hierarchy-config_developer-name-input');
    }

    handleOpenSelector (event) {
        const targetElement = event.target;
        const objName = targetElement.dataset.object;
        const objNotificationParent = targetElement.dataset.notificationparent;
        this.selectedObject = objName;
        this.selectedNotificationParent = objNotificationParent;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(()=>{
            this.selectorModalOpen = true;
        },1);
    }

    handleCriteriaRemoved (event) {
        const targetElement = event.target;
        const objNotificationParent = targetElement.dataset.notificationparent;
        const fieldCriteria = targetElement.dataset.field;
        const fieldCriteriaName = targetElement.dataset.fieldname;
        let objIndex = 0;
        if (objNotificationParent) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === objNotificationParent));
            this.hierarchyConfigObjects[objIndex][fieldCriteria] = null;
            this.hierarchyConfigObjects[objIndex][fieldCriteriaName] = null;
        }
    }

    saveRecentItem (data) {
        const recentlyViewedRecord = {
            configurationId: data.id,
            configurationName: data.name,
            configurationDeveloperName: data.developerName,
            configurationType: ADMIN_MODULES.ASSET_HIERARCHY
        };
        saveRecentViewItem(recentlyViewedRecord)
            .then(recentItem => {
                if (!verifyApiResponse(recentItem)) {
                    this.error = recentItem.message;
                }
            });

    }

    handleCloseModal () {
        this.selectorModalOpen = false;
    }

    handleExpressionSelected (event) {
        let objIndex = 0;
        const fieldCriteria = event.target.dataset.field;
        const fieldCriteriaName = event.target.dataset.fieldname;
        const notificationFieldCriteria = event.target.dataset.notificationfield;
        const notificationFieldCriteriaName = event.target.dataset.notificationfieldname;

        if (this.selectedObject && this.selectedObject === this.selectedNotificationParent) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === this.selectedObject));
            if (isEmptyString(event.detail.value.name)) {
                this.hierarchyConfigObjects[objIndex][fieldCriteria] = null;
                this.hierarchyConfigObjects[objIndex][fieldCriteriaName] = null;
            } else {
                this.hierarchyConfigObjects[objIndex][fieldCriteria] = event.detail.value.id;
                this.hierarchyConfigObjects[objIndex][fieldCriteriaName] =
                 event.detail.value.name;
            }
        } else if (this.selectedObject && this.selectedObject !== this.selectedNotificationParent) {
            objIndex = this.hierarchyConfigObjects.findIndex(
                (obj => obj.objectAPIName === this.selectedNotificationParent));
            if (isEmptyString(event.detail.value.name)) {
                this.hierarchyConfigObjects[objIndex][notificationFieldCriteria] = null;
                this.hierarchyConfigObjects[objIndex][notificationFieldCriteriaName] = null;
            } else {
                this.hierarchyConfigObjects[objIndex][notificationFieldCriteria] =
                 event.detail.value.id;
                this.hierarchyConfigObjects[objIndex][notificationFieldCriteriaName] =
                 event.detail.value.name;
            }
        }
        this.isDirty = true;
        this.handleCloseModal();
    }
}