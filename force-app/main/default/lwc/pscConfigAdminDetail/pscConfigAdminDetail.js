import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import {
    parseErrorMessage,
    verifyApiResponse,
    PAGE_ACTION_TYPES,
    handleMenuSelection,
    normalizeDeveloperName,
    formatString,
    ADMIN_MODULES
} from 'c/utils';

import { saveRecentViewItem }
    from 'c/recentItemService';

import getPscTemplate
    from '@salesforce/apex/ADM_ProductServiceCampaign_LS.getConfigTemplateInfo';
import upsertRecord
    from '@salesforce/apex/ADM_ProductServiceCampaign_LS.saveConfigTemplates';
import getMappingDetails
    from '@salesforce/apex/ADM_ProductServiceCampaign_LS.getObjectMappingDetails';
import getListOfMappingDetails
    from '@salesforce/apex/ADM_ObjectMappingLightningService.getObjectMappingsByName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import labelPSC from '@salesforce/label/c.Label_Product_Service_Campaigns';
import labelButtonCancel from '@salesforce/label/c.Button_Cancel';
import labelSave from '@salesforce/label/c.Button_Save';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelActive from '@salesforce/label/c.Label_Active';
import labelTemplateName from '@salesforce/label/c.Label_Template_Name';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelNotificationEmail from '@salesforce/label/c.Label_PSC_Notification_Email';
import PSC_ICONS from '@salesforce/resourceUrl/pscIcons';
import sectionProperties from '@salesforce/label/c.Label_Properties';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelMapping from '@salesforce/label/c.Label_Mapping';
import labelAddMapping from '@salesforce/label/c.Label_Add_Mapping';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDeleteCondition from '@salesforce/label/c.Label_Delete_Condition';
import labelSelect from '@salesforce/label/c.Placeholder_Select';
import labelPscSavedMessage from '@salesforce/label/c.Label_PscSavedMessage';
import lblRecordSaveError from '@salesforce/label/c.Title_AlertError';
import lblMappingName from '@salesforce/label/c.Label_Mapping_Name';
import lblSourceObject from '@salesforce/label/c.Label_SourceObject';
import lblDeliveryObject from '@salesforce/label/c.Label_Delivery_Object';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelMappingEditor from '@salesforce/label/c.Label_Mapping_Editor';
import labelEditorfirstLink from '@salesforce/label/c.Mapping_Editor_Link_1_Label';
import labelEditersecLink from '@salesforce/label/c.Mapping_Editor_Link_2_Label';
import labelWorkOrder from '@salesforce/label/c.Label_WorkOrder';
import labelCase from '@salesforce/label/c.Label_Case';
import labelReturnOrder from '@salesforce/label/c.Label_ReturnOrder';
import labelPSCHeader from '@salesforce/label/c.Label_PSC_Header';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelSectionMapping from '@salesforce/label/c.Label_Duplicate_Mapping';
import labelRequiredMapping from '@salesforce/label/c.Label_Required_Mapping';
import labelIncorrectMapping from '@salesforce/label/c.Label_Incorrect_Mapping';
import labelRequiredValue from '@salesforce/label/c.Label_RequiredErrorMessage';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelOpportunity from '@salesforce/label/c.Label_Opportunity';
import labelOpportunityProduct from '@salesforce/label/c.Label_OpportunityProduct';
import labelAssetNotification from '@salesforce/label/c.Label_AssetNotification';
import labelMissingMapping from '@salesforce/label/c.Label_MissingMapping';
const i18n = {
    pageHeader: labelPSC,
    labelTemplateName: labelTemplateName,
    labelActive: labelActive,
    description: labelDescription,
    labelNotificationEmail: labelNotificationEmail,
    loading: labelLoading,
    generalInfo: sectionProperties,
    wasSaved: labelWasSaved,
    buttonCancel: labelButtonCancel,
    save: labelSave,
    deleteCondition: labelDeleteCondition,
    labelMapping: labelMapping,
    addMapping: labelAddMapping,
    select: labelSelect,
    labelPscSavedMessage: labelPscSavedMessage,
    lblRecordSaveError: lblRecordSaveError,
    lblMappingName: lblMappingName,
    lblSourceObject: lblSourceObject,
    lblDeliveryObject: lblDeliveryObject,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    continue: labelYesContinue,
    goBack: labelNoGoBack,
    developerName: labelDeveloperName,
    labelEditersecLink: labelEditersecLink,
    labelEditorfirstLink: labelEditorfirstLink,
    labelMappingEditor: labelMappingEditor,
    labelWorkOrder: labelWorkOrder,
    labelCase: labelCase,
    labelReturnOrder: labelReturnOrder,
    labelPSCHeader: labelPSCHeader,
    labelAsset: labelAsset,
    labelSectionMapping: labelSectionMapping,
    labelRequiredMapping: labelRequiredMapping,
    labelIncorrectMapping: labelIncorrectMapping,
    labelRequiredValue: labelRequiredValue,
    labelCopyOf: labelCopyOf,
    labelOpportunity: labelOpportunity,
    labelOpportunityProduct: labelOpportunityProduct,
    labelAssetNotification: labelAssetNotification,
    missingMapping: labelMissingMapping

}
const PSC_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__pscConfigurationDetails'
    }
};
export default class PscConfigAdminDetail extends NavigationMixin(LightningElement) {

    _recordId;
    @api
    get recordId () {
        return this._recordId;
    }
    set recordId (newRecordId) {
        this._recordId = newRecordId;
    }

    _actionName;
    @api
    get actionName () {
        return this._actionName;
    }
    set actionName (newActionName) {
        this._actionName = newActionName;
    }
    @api deleteDisabled;
    @track pscTemplateName;
    @track pscDeveloperName;
    @track notificationEmail;
    @track templateDescription;
    @track templateStatus;
    @track mappingJSON;
    @track sourceObject;
    @track targetObject;
    @track objectMappingValue;
    @track cancelModalDialogOpen;
    pscLogoUrl = `${PSC_ICONS}/pscIcons/ServiceMax_Logo.svg`;
    constAsset = 'Asset';
    constCase = 'Case';
    constWorkOrder = 'WorkOrder';
    constReturnOrder = 'ReturnOrder';
    constPSCHeader = 'ProductServiceCampaign';
    constOpportunity = 'Opportunity';
    constOpportunityLineItem = 'OpportunityLineItem';
    constAssetNotification = 'SVMXA360__AssetNotification__c';
    constASSET2CASE = 'ASSET2CASE';
    constASSET2WORD = 'ASSET2WORD';
    constASSET2RORD = 'ASSET2RORD';
    constASSET2OPPNTYPROD = 'ASSET2OPPNTYPROD';
    constASSET2ASSETNOTI ='ASSET2ASSETNOTI';
    constPSC2CASE = 'PSC2CASE';
    constPSC2WORD = 'PSC2WORD';
    constPSC2RORD = 'PSC2RORD';
    constPSC2OPPNTY = 'PSC2OPPNTY';
    constPSC2ASSETNOTI = 'PSC2ASSETNOTI';
    constSource = 'Source';
    constTarget = 'Target';

    @track editMode = false;
    @track error;
    @track apiInProgress = false;

    fieldValue;
    isRecordSaved = false;
    keyIndex = 0;
    get i18n () {
        return i18n;
    }
    get sourceOptions () {
        return [
            { label: i18n.labelPSCHeader, value: 'ProductServiceCampaign' },
            { label: i18n.labelAsset, value: 'Asset' },
        ];
    }
    getDeliveryOptions (sourceObjName) {
        return [
            { label: i18n.labelWorkOrder, value: 'WorkOrder' },
            { label: i18n.labelCase, value: 'Case' },
            { label: i18n.labelReturnOrder, value: 'ReturnOrder' },
            { label: i18n.labelAssetNotification, value: 'SVMXA360__AssetNotification__c' },
            sourceObjName === 'ProductServiceCampaign'
                ? { label: i18n.labelOpportunity, value: 'Opportunity' }
                : { label: i18n.labelOpportunityProduct, value: 'OpportunityLineItem' }
        ];
    }
    @track itemList = [
        {
            id: 0,
            sourceObject: '',
            targetObject: '',
            objectMapping: '',
            mappingOptions: [],
            deliveryOptions: []
        }
    ];
    handleSourceChange (event) {
        const index = this.itemList.findIndex(x => x.id === parseInt(event.target.accessKey, 10));
        this.itemList[index].sourceObject = event.detail.value;
        this.itemList[index].targetObject = '';
        this.itemList[index].mappingOptions = [];
        this.itemList[index].objectMapping = '';
        this.itemList[index].deliveryOptions
        = this.getDeliveryOptions(this.itemList[index].sourceObject);
    }
    handleTargetChange (event) {
        const index = this.itemList.findIndex(x => x.id === parseInt(event.target.accessKey, 10));
        this.itemList[index].targetObject = event.detail.value;
        this.itemList[index].mappingOptions = [];
        this.itemList[index].objectMapping = '';
        this.getTheObjectMappingValue(index,
            this.itemList[index].sourceObject, this.itemList[index].targetObject);
    }
    handleMappingChange (event) {
        const index = this.itemList.findIndex(x => x.id === parseInt(event.target.accessKey, 10));
        this.itemList[index].objectMapping = event.detail.value;
    }
    getTheObjectMappingValue (indexVal, sourceObjectName, targetObjectName) {
        this.apiInProgress = true;
        getMappingDetails({ sourceObject: sourceObjectName, targetObject: targetObjectName })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                if (result.data.length > 0) {
                    result.data.forEach(ele => {
                        const option = {
                            label: ele.value,
                            value: ele.key
                        };
                        this.itemList[indexVal].mappingOptions =
                        [...this.itemList[indexVal].mappingOptions, option];
                    });
                }

            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }
    handleAddCondition () {
        this.keyIndex += 1;
        const newItem = [{ id: this.keyIndex,
            sourceObject: '',
            targetObject: '',
            objectMapping: '',
            mappingOptions: [],
            deliveryOptions: []
        }];
        this.itemList = this.itemList.concat(newItem);
    }
    handleDeleteCondition (event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id, 10) !== parseInt(event.target.accessKey, 10);
            });
        }
    }

    activeFormSections = ['Properties', 'Mapping'];
    currentNavItem;
    isProcesseLoaded = false;

    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {

        if (currentPageReference && currentPageReference.state) {

            if (currentPageReference.state.c__recordId) {
                this._recordId = currentPageReference.state.c__recordId;
            }

            if (currentPageReference.state.c__actionName) {
                this._actionName = currentPageReference.state.c__actionName.toLowerCase();
            }

            if (currentPageReference.state.c__currentItem) {
                this.currentNavItem = currentPageReference.state.c__currentItem;
            }
            if (!this.isProcesseLoaded) {
                this.loadRecord();
            }
        }
    }

    loadRecord () {
        this.isProcesseLoaded = true;
        this.apiInProgress = true;
        this.error = '';
        this.loadDefaultDropDownValue();
        if (this._actionName === PAGE_ACTION_TYPES.NEW) {
            this.editMode = false;
            this.getNewRecordDetails();
        } else if (this._actionName === PAGE_ACTION_TYPES.CLONE) {
            this.editMode = false;
            this.getExistingRecordDetails();
        } else {
            this.editMode = true;
            this.getExistingRecordDetails();
        }
    }

    getExistingRecordDetails () {
        if (this._recordId) {
            getPscTemplate({ requestJson: JSON.stringify({ id: this._recordId }) })
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }
                    const labelCopy = i18n.labelCopyOf+' ';
                    this.pscTemplateName = this._actionName ===
                    PAGE_ACTION_TYPES.CLONE ? labelCopy + result.data[0].name : result.data[0].name;
                    this.notificationEmail = result.data[0].emailId;
                    this.templateDescription = result.data[0].description;
                    this.pscDeveloperName = this._actionName ===
                    PAGE_ACTION_TYPES.CLONE ? labelCopy.split(' ').join('_') +
                    result.data[0].developerName :
                        result.data[0].developerName;
                    if (result.data[0].isActive) {
                        this.templateStatus = true;
                    } else {
                        this.templateStatus = false;
                    }
                    const recentlyViewedRecord = {
                        configurationId: result.data[0].id,
                        configurationName: this.pscTemplateName,
                        configurationDeveloperName: this.pscDeveloperName,
                        configurationType: ADMIN_MODULES.PSC_CONFIGURATION_TEMPLATES
                    };
                    saveRecentViewItem(recentlyViewedRecord)
                        .then(recentItem => {
                            if (!verifyApiResponse(recentItem)) {
                                this.error = recentItem.message;
                            }
                        });
                    const jsonData = JSON.parse(result.data[0].mappingJson.replace('\'', ''));
                    let listSourceObjectIds = '';
                    let listTargetObjectIds = '';
                    for (let i = 0; i < jsonData.length; i++) {
                        listSourceObjectIds += this.getSourceTargetvalue(
                            jsonData[i].targetMappingKey, this.constSource)+',';
                        listTargetObjectIds += this.getSourceTargetvalue(
                            jsonData[i].targetMappingKey, this.constTarget)+',';
                    }
                    const objectMappingMap = new Map();
                    const sourceTargetObjMap = new Map();
                    const sourceUniqueTargetObjMap = new Map();
                    getListOfMappingDetails({ targetObjectAPIName: listTargetObjectIds,
                        sourceObjectAPIName: listSourceObjectIds })
                        .then(listresult => {
                            if (!verifyApiResponse(listresult)) {
                                this.error = listresult.message;
                                return;
                            }
                            if (listresult.data.length > 0) {
                                listresult.data.forEach(ele => {
                                    objectMappingMap.set(ele.developerName, ele.name);
                                    const objectStringKey = this.getPSCObjectMapping(
                                        ele.sourceObjectAPIName, ele.targetObjectAPIName);
                                    if (sourceTargetObjMap.has(objectStringKey)) {
                                        const tempList = sourceTargetObjMap.get(objectStringKey);
                                        tempList.push(ele.developerName);
                                        sourceTargetObjMap.set(objectStringKey, tempList);
                                    } else {
                                        const tempList = [];
                                        tempList.push(ele.developerName);
                                        sourceTargetObjMap.set(objectStringKey, tempList);
                                    }
                                });
                            }
                            let isShowErrorMessage = false;
                            for (let i = 0; i < jsonData.length; i++) {
                                let isConfigurationCorrupt = false;
                                const counter = jsonData[i];

                                let option;
                                if (objectMappingMap.get(counter.targetMappingId)) {
                                    option = {
                                        label: objectMappingMap.get(counter.targetMappingId),
                                        value: counter.targetMappingId
                                    };
                                } else {
                                    isShowErrorMessage = true;
                                    isConfigurationCorrupt = true;
                                }

                                sourceUniqueTargetObjMap.set(counter.targetMappingId,
                                    counter.targetMappingId);
                                if (parseInt(i, 10) > 0) {
                                    this.handleAddCondition();
                                }
                                this.itemList[i].sourceObject
                                    = this.getSourceTargetvalue(
                                        counter.targetMappingKey, this.constSource);
                                this.itemList[i].targetObject
                                    = this.getSourceTargetvalue(
                                        counter.targetMappingKey, this.constTarget);
                                this.itemList[i].objectMapping = !isConfigurationCorrupt
                                    ? counter.targetMappingId : null;
                                if (isConfigurationCorrupt) {
                                    this.itemList[i].mappingOptions
                                        = [...this.itemList[i].mappingOptions];
                                } else {
                                    this.itemList[i].mappingOptions
                                        = [...this.itemList[i].mappingOptions, option];
                                }

                                this.itemList[i].deliveryOptions
                                    = this.getDeliveryOptions(this.itemList[i].sourceObject);
                                if (sourceTargetObjMap.has(counter.targetMappingKey) &&
                                 sourceTargetObjMap.get(counter.targetMappingKey).length >= 1) {
                                    const tempVal = sourceTargetObjMap.get(
                                        counter.targetMappingKey);
                                    tempVal.forEach(ele => {
                                        if (!sourceUniqueTargetObjMap.has(ele)) {
                                            const optionTemp = {
                                                label: objectMappingMap.get(ele),
                                                value: ele
                                            };
                                            this.itemList[i].mappingOptions
                                        = [...this.itemList[i].mappingOptions, optionTemp];
                                        }
                                    });
                                }
                            }
                            this.mappingJSON = result.data[0].mappingJson;
                            if (isShowErrorMessage) {
                                this.showErrorMessage(i18n.missingMapping);
                            }
                        })
                        .catch(error => {
                            this.error = parseErrorMessage(error);
                        })
                        .finally(() => {
                            this.apiInProgress = false;
                        });
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                });
        }

    }

    loadDefaultDropDownValue () {
        this.keyIndex = 0;
        this.itemList = [];
        const newItem = [{
            id: this.keyIndex,
            sourceObject: '',
            targetObject: '',
            objectMapping: '',
            mappingOptions: [],
            deliveryOptions: []
        }];
        this.itemList = this.itemList.concat(newItem);
    }

    getNewRecordDetails () {
        this._recordId = '';
        this.apiInProgress = false;
        this.pscTemplateName = '';
        this.pscDeveloperName = '';
        this.notificationEmail = '';
        this.templateDescription = '';
        this.templateStatus = false;
        this.mappingJSON = '';
        this.keyIndex = 0;
    }

    handleCancel () {
        if (!this.isRecordSaved) {
            this.cancelModalDialogOpen = true;
            this.isRecordSaved = false;
            return;
        }
        this.loadDefaultDropDownValue();
        handleMenuSelection({
            detail: {
                name: "psc_configuration_templates",
                targetType: "LWC",
                targetDeveloperName: "c-psc-config-admin-list-view"
            }
        }, this);
    }

    handleRuleActiveCheck (event) {
        this.templateStatus = event.target.checked;
    }

    handleDescChange (event) {
        this.templateDescription = event.target.value;
    }

    handleEmailChange (event) {
        this.notificationEmail = event.target.value;
    }

    handleNameChange (event) {
        this.pscTemplateName = event.target.value;
    }

    handleDeveloperNameChange (event) {
        this.pscDeveloperName = event.target.value;
    }

    handleNameBlur () {
        if (   ( this._actionName === PAGE_ACTION_TYPES.NEW
            || this._actionName === PAGE_ACTION_TYPES.CLONE )
         && !this.pscDeveloperName ) {
            const maxLength = this.template.querySelector('[data-field="developername"]').maxLength;
            this.pscDeveloperName = normalizeDeveloperName(this.pscTemplateName,
                maxLength,this.pscTemplateName);
        }
    }

    handleMappingEditor () {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'SVMXA360__setupHome'
            },
            state: {
                c__currentItem: 'mapping_rules',
                c__target: 'c-mapping-admin-list-view'
            }
        }).then(url => { window.open(url) });
    }
    getPSCObjectMapping (sourceObj, targetObj) {
        let returnVal = '';
        if (sourceObj === this.constAsset && targetObj === this.constCase) {
            returnVal = this.constASSET2CASE;
        } else if (sourceObj === this.constAsset && targetObj === this.constWorkOrder) {
            returnVal = this.constASSET2WORD;
        } else if (sourceObj === this.constAsset && targetObj === this.constReturnOrder) {
            returnVal = this.constASSET2RORD;
        } else if (sourceObj === this.constAsset && targetObj === this.constAssetNotification) {
            returnVal = this.constASSET2ASSETNOTI;
        } else if (sourceObj === this.constPSCHeader && targetObj === this.constCase) {
            returnVal = this.constPSC2CASE;
        } else if (sourceObj === this.constPSCHeader && targetObj === this.constWorkOrder) {
            returnVal = this.constPSC2WORD;
        } else if (sourceObj === this.constPSCHeader && targetObj === this.constReturnOrder) {
            returnVal = this.constPSC2RORD;
        } else if (sourceObj === this.constPSCHeader && targetObj === this.constAssetNotification) {
            returnVal = this.constPSC2ASSETNOTI;
        } else if (sourceObj === this.constPSCHeader && targetObj === this.constOpportunity) {
            return this.constPSC2OPPNTY;
        } else if (sourceObj === this.constAsset && targetObj === this.constOpportunityLineItem) {
            returnVal = this.constASSET2OPPNTYPROD;
        }
        return returnVal;
    }

    getSourceTargetvalue (mappingKey, reqParam) {
        let returnVal = '';
        if (mappingKey === this.constASSET2CASE) {
            if (reqParam === this.constSource) {
                returnVal = this.constAsset;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constCase;
            }
        } else if (mappingKey === this.constASSET2WORD) {
            if (reqParam === this.constSource) {
                returnVal = this.constAsset;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constWorkOrder;
            }
        } else if (mappingKey === this.constASSET2RORD) {
            if (reqParam === this.constSource) {
                returnVal = this.constAsset;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constReturnOrder;
            }
        } else if (mappingKey === this.constASSET2ASSETNOTI) {
            if (reqParam === this.constSource) {
                returnVal = this.constAsset;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constAssetNotification;
            }
        } else if (mappingKey === this.constPSC2CASE) {
            if (reqParam === this.constSource) {
                returnVal = this.constPSCHeader;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constCase;
            }
        } else if (mappingKey === this.constPSC2WORD) {
            if (reqParam === this.constSource) {
                returnVal = this.constPSCHeader;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constWorkOrder;
            }
        } else if (mappingKey === this.constPSC2RORD) {
            if (reqParam === this.constSource) {
                returnVal = this.constPSCHeader;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constReturnOrder;
            }
        } else if (mappingKey === this.constPSC2ASSETNOTI) {
            if (reqParam === this.constSource) {
                returnVal = this.constPSCHeader;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constAssetNotification;
            }
        } else if (mappingKey === this.constPSC2OPPNTY) {
            if (reqParam === this.constSource) {
                returnVal = this.constPSCHeader;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constOpportunity;
            }
        } else if (mappingKey === this.constASSET2OPPNTYPROD) {
            if (reqParam === this.constSource) {
                returnVal = this.constAsset;
            } else if (reqParam === this.constTarget) {
                returnVal = this.constOpportunityLineItem;
            }
        }
        return returnVal;
    }

    showErrorMessage (messageVar) {
        this.error = messageVar;
    }

    setEditModeForView () {
        if (this._actionName === PAGE_ACTION_TYPES.VIEW ||
            this._actionName === PAGE_ACTION_TYPES.EDIT) {
            this.editMode = true;
        } else {
            this.editMode = false;
        }
    }

    handleSave () {
        if (this.pscTemplateName) {
            this.apiInProgress = true;
            let mapJsonValue = '';
            const sourceTargetObj = [];
            let duplicateMapValue = false;
            let invalidMappingValue = false;
            let noMappingValue = false;
            for (const internalVar in this.itemList) {
                if (this.itemList.length > 0) {
                    if (this.itemList.length > 1 && !this.itemList[internalVar].sourceObject &&
                        !this.itemList[internalVar].targetObject) {
                        invalidMappingValue = true;
                        break;
                    } else if (!this.itemList[internalVar].sourceObject &&
                         !this.itemList[internalVar].targetObject) {
                        noMappingValue = true;
                        break;
                    } else if (!this.itemList[internalVar].sourceObject ||
                        !this.itemList[internalVar].targetObject ||
                        !this.itemList[internalVar].objectMapping) {
                        invalidMappingValue = true;
                        break;
                    }
                    const concatValue = this.itemList[internalVar].sourceObject.concat(
                        this.itemList[internalVar].targetObject);
                    if (sourceTargetObj.includes(concatValue)) {
                        duplicateMapValue = true;
                        break;
                    }
                    sourceTargetObj.push(concatValue);
                    mapJsonValue = mapJsonValue.concat('{').concat('"targetMappingKey":"').
                        concat(this.getPSCObjectMapping(this.itemList[internalVar].sourceObject,
                            this.itemList[internalVar].targetObject)).
                        concat('","targetMappingId":"').
                        concat(this.itemList[internalVar].objectMapping).concat('"},');
                }
            }
            mapJsonValue = '['.concat(mapJsonValue.slice(0, -1)).concat(']');
            if (noMappingValue) {
                this.showErrorMessage(this.i18n.labelRequiredMapping);
                noMappingValue = false;
                this.isRecordSaved = false;
                sourceTargetObj.length = 0;
                this.apiInProgress = false;
                this.setEditModeForView();
            } else if (invalidMappingValue) {
                this.showErrorMessage(this.i18n.labelIncorrectMapping);
                invalidMappingValue = false;
                this.isRecordSaved = false;
                sourceTargetObj.length = 0;
                this.apiInProgress = false;
                this.setEditModeForView();
            } else if (duplicateMapValue) {
                this.showErrorMessage(this.i18n.labelSectionMapping);
                this.isRecordSaved = false;
                duplicateMapValue = false;
                sourceTargetObj.length = 0;
                this.apiInProgress = false;
                this.setEditModeForView();
            } else {
                const recordIdToUpsert = this._actionName === PAGE_ACTION_TYPES.CLONE ? '' :
                    this._recordId;
                upsertRecord({ requestJson: JSON.stringify({ id: recordIdToUpsert,
                    name: this.pscTemplateName,
                    developerName: this.pscDeveloperName,
                    emailId: this.notificationEmail,
                    isActive: this.templateStatus,
                    description: this.templateDescription,
                    mappingJson: mapJsonValue }) })
                    .then(result => {

                        if (!verifyApiResponse(result)) {
                            throw new Error(result.message);
                        }
                        const evt = new ShowToastEvent({
                            title: formatString(i18n.labelPscSavedMessage, this.pscTemplateName),
                            message: result,
                            variant: 'success'
                        });
                        this.dispatchEvent(evt);
                        if (this._actionName === PAGE_ACTION_TYPES.NEW ||
                            this._actionName === PAGE_ACTION_TYPES.CLONE) {
                            this.navigateToDetailComponent(result.data,'view');
                        }
                        this.isRecordSaved = true;
                        this.error = '';
                        this.editMode = true;
                    })
                    .catch(error => {
                        this.error = parseErrorMessage(error);
                        this.isRecordSaved = false;
                        this.setEditModeForView();
                    })
                    .finally(() => {
                        this.apiInProgress = false;
                    });
            }
        } else {
            this.showErrorMessage(this.i18n.labelRequiredValue);
        }
    }

    navigateToDetailComponent (recordId, actionName) {
        const navState = {
            c__actionName: actionName
        }

        if (recordId) {
            navState.c__recordId = recordId;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, PSC_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;
        this.isRecordSaved = true;
        this.handleCancel();
    }

}