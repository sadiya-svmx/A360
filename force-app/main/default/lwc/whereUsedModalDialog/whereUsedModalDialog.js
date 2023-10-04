import { LightningElement, api, track } from 'lwc';

import getWhereUsedDetails
    from '@salesforce/apex/ADM_WhereUsedLightningService.getWhereUsedDetails';

import {
    verifyApiResponse,
    parseErrorMessage,
    ADMIN_MODULES,
    ROUTES,
    NAVIGATION_ITEMS,
    PAGE_ACTION_TYPES,
    OPERATION_TYPES
} from 'c/utils';

import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelExpressionDeleteHeader from '@salesforce/label/c.Label_WhereUsedExpressionDeleteHeader';
import labelExpressionUpdateHeader from '@salesforce/label/c.Label_WhereUsedExpressionUpdateHeader';
import labelExpressionMessage from '@salesforce/label/c.Label_WhereUsedExpressionMessage';
import labelLookupDeleteHeader from '@salesforce/label/c.Label_WhereUsedLookupDeleteHeader';
import labelLookupUpdateHeader from '@salesforce/label/c.Label_WhereUsedLookupUpdateHeader';
import labelLookupMessage from '@salesforce/label/c.Label_WhereUsedLookupMessage';
import labelMappingDeleteHeader from '@salesforce/label/c.Label_WhereUsedMappingDeleteHeader';
import labelMappingUpdateHeader from '@salesforce/label/c.Label_WhereUsedMappingUpdateHeader';
import labelMappingMessage from '@salesforce/label/c.Label_WhereUsedMappingMessage';
import labelServiceProcessManager from '@salesforce/label/c.Label_Service_Process_Manager';
import labelWhereUsedHeaderMapping from '@salesforce/label/c.Label_WhereUsedHeaderMapping';
import labelWhereUsedConditionalDefaultMapping
    from '@salesforce/label/c.Label_WhereUsedConditionalDefaultMapping';
import buttonClose from '@salesforce/label/c.Button_Close';
import labelExpressionDeleteMessage from
    '@salesforce/label/c.Label_WhereUsedExpressionDeleteMessage';
import labelExpressionUpdateMessage from
    '@salesforce/label/c.Label_WhereUsedExpressionUpdateMessage';
import labelLookupDeleteMessage from
    '@salesforce/label/c.Label_WhereUsedLookupDeleteMessage';
import labelLookupUpdateMessage from
    '@salesforce/label/c.Label_WhereUsedLookupUpdateMessage';
import labelMappingDeleteMessage from
    '@salesforce/label/c.Label_WhereUsedMappingDeleteMessage';
import labelMappingUpdateMessage from
    '@salesforce/label/c.Label_WhereUsedMappingUpdateMessage';
import messageNoWhereUsed from
    '@salesforce/label/c.Message_NoWhereUsed';

import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';

const i18n = {
    confirm: labelConfirm,
    cancel: labelCancel,
    delete: labelDelete,
    save: labelSave,
    expressionDeleteHeader: labelExpressionDeleteHeader,
    expressionUpdateHeader: labelExpressionUpdateHeader,
    expressionMessage: labelExpressionMessage,
    expressionDeleteMessage: labelExpressionDeleteMessage,
    expressionUpdateMessage: labelExpressionUpdateMessage,
    lookupDeleteHeader: labelLookupDeleteHeader,
    lookupUpdateHeader: labelLookupUpdateHeader,
    lookupMessage: labelLookupMessage,
    lookupDeleteMessage: labelLookupDeleteMessage,
    lookupUpdateMessage: labelLookupUpdateMessage,
    mappingDeleteHeader: labelMappingDeleteHeader,
    mappingUpdateHeader: labelMappingUpdateHeader,
    mappingMessage: labelMappingMessage,
    mappingDeleteMessage: labelMappingDeleteMessage,
    mappingUpdateMessage: labelMappingUpdateMessage,
    serviceProcessManager: labelServiceProcessManager,
    whereUsedHeaderMapping: labelWhereUsedHeaderMapping,
    whereUsedConditionalDefaultMapping: labelWhereUsedConditionalDefaultMapping,
    close: buttonClose,
    noWhereUsed: messageNoWhereUsed
}

export default class WhereUsedModalDialog extends LightningElement {

    @api moduleType = '';
    @api configType = '';
    @api configurationId = '';
    @api configDeveloperName = '';
    @api configName = '';
    @api operationType = '';
    @api launchModule = '';
    @track whereUsedDetails = [];
    @track error;
    @track header = '';
    @track headerMessage = '';
    @track footerMessage = '';
    whereUsedModalDialogOpen;
    @api row;

    @track objectDetails = new Map();
    @track moduleDisplay = new Map();
    @track enableDelete = false;

    get i18n () {
        return i18n;
    }

    get isUpdate () {
        return this.operationType === OPERATION_TYPES.UPDATE;
    }

    get isDelete () {
        return this.operationType === OPERATION_TYPES.DELETE;
    }

    get isWhereUsed () {
        return this.operationType === OPERATION_TYPES.WHEREUSED;
    }

    get isExpression () {
        return this.moduleType === ADMIN_MODULES.EXPRESSION;
    }

    connectedCallback () {
        this.apiInProgress = true;
        Promise.all([this.getWhereUsedRecordDetails(), this.getEntityDefinitions()])
            .then(() => {
                this.getUrlData();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    getWhereUsedRecordDetails () {
        const requestJsonObj = JSON.stringify({
            moduleType: this.moduleType,
            configurationId: this.configurationId,
            configDeveloperName: this.configDeveloperName,
            configType: this.configType
        });
        return getWhereUsedDetails({ requestJson: requestJsonObj })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.whereUsedDetails = JSON.parse(JSON.stringify(result.data));
                if (this.whereUsedDetails.length <= 0) {
                    if (this.operationType === OPERATION_TYPES.DELETE) {
                        this.dispatchEvent(
                            new CustomEvent('deletemodal' ,{
                                detail: {
                                    row: this.row
                                }
                            })
                        );
                    } else if (this.operationType === OPERATION_TYPES.UPDATE) {
                        this.dispatchEvent(
                            new CustomEvent('savemodal')
                        );
                    } else if (this.operationType === OPERATION_TYPES.WHEREUSED) {
                        this.header = this.configName;
                        this.headerMessage = i18n.noWhereUsed;
                        this.whereUsedModalDialogOpen = true;
                    }

                } else {
                    this.whereUsedModalDialogOpen = true;
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    getEntityDefinitions () {
        return getAllEntityDefinitions()
            .then (result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }
                this.error = null;
                result.data.forEach(entity => {
                    this.objectDetails[entity.apiName] = entity.label;
                });
            });

    }

    getUrlData () {
        if (this.moduleType === ADMIN_MODULES.EXPRESSION &&
            this.operationType === OPERATION_TYPES.DELETE) {
            this.header = i18n.expressionDeleteHeader + ' ' + this.configName;
            this.headerMessage = i18n.expressionDeleteMessage;
        } else if (this.moduleType === ADMIN_MODULES.EXPRESSION &&
            this.operationType === OPERATION_TYPES.UPDATE) {
            this.header = i18n.expressionUpdateHeader + ' ' + this.configName;
            this.headerMessage = i18n.expressionUpdateMessage;
        }  else if (this.moduleType === ADMIN_MODULES.EXPRESSION &&
            this.operationType === OPERATION_TYPES.WHEREUSED &&
            this.whereUsedDetails.length !== 0) {
            this.header = this.configName;
            this.headerMessage = i18n.expressionMessage;
        } else if (this.moduleType === ADMIN_MODULES.MAPPING &&
            this.operationType === OPERATION_TYPES.DELETE) {
            this.header = i18n.mappingDeleteHeader + ' ' + this.configName;
            this.headerMessage = i18n.mappingDeleteMessage;
        } else if (this.moduleType === ADMIN_MODULES.MAPPING &&
            this.operationType === OPERATION_TYPES.UPDATE) {
            this.header = i18n.mappingUpdateHeader + ' ' + this.configName;
            this.headerMessage = i18n.mappingUpdateMessage;
        }  else if (this.moduleType === ADMIN_MODULES.MAPPING &&
            this.operationType === OPERATION_TYPES.WHEREUSED &&
            this.whereUsedDetails.length !== 0) {
            this.header = this.configName;
            this.headerMessage = i18n.mappingMessage;
        } else if (this.moduleType === ADMIN_MODULES.LOOKUP_FILTER &&
            this.operationType === OPERATION_TYPES.DELETE) {
            this.header = i18n.lookupDeleteHeader + ' ' + this.configName;
            this.headerMessage = i18n.lookupDeleteMessage;
        } else if (this.moduleType === ADMIN_MODULES.LOOKUP_FILTER &&
            this.operationType === OPERATION_TYPES.UPDATE) {
            this.header = i18n.lookupUpdateHeader + ' ' + this.configName;
            this.headerMessage = i18n.lookupUpdateMessage;
        }

        if ((this.launchModule === ADMIN_MODULES.VISIBILITY_CRITERIA ||
            this.launchModule === ADMIN_MODULES.LOOKUP_FILTER) &&
            this.whereUsedDetails != null &&
            this.whereUsedDetails.length === 1 &&
            this.whereUsedDetails[0].configurationTemplates != null &&
            this.whereUsedDetails[0].configurationTemplates.length === 1) {
            this.enableDelete = true;
        }
        this.whereUsedDetails.forEach( whereUsed => {
            if (!this.moduleDisplay[whereUsed.moduleNameValue]) {
                this.moduleDisplay[whereUsed.moduleNameValue] = true;
                whereUsed.moduleDisplay = true;
            } else {
                whereUsed.moduleDisplay = false;
            }
            whereUsed.configurationTemplates.forEach ( config => {
                let currentNavItem = '';
                let urlParams = [];
                if (whereUsed.subModuleNameValue === ADMIN_MODULES.TRANSACTION) {
                    config.url = `${ROUTES.TRANSACTION_EDITOR}#/editor/${config.configurationId}`;
                } else if (whereUsed.subModuleNameValue === ADMIN_MODULES.SCREEN) {
                    config.url = `${ROUTES.LAYOUT_EDITOR}#/editor/${config.configurationId}`;
                } else if (whereUsed.subModuleNameValue === ADMIN_MODULES.WIZARD) {
                    currentNavItem = NAVIGATION_ITEMS.WIZARD_DETAIL_VIEW;
                    const objectLabel = this.objectDetails[config.configurationObject];
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__objectLabel=${objectLabel}`,
                        `c__objectName=${config.configurationObject}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    const url = ROUTES.WIZARD_DETAIL_VIEW
                    config.url = `${url}?${urlParams}`;
                } else if (whereUsed.moduleNameValue === ADMIN_MODULES.WARRANTY_MANAGEMENT) {
                    currentNavItem = NAVIGATION_ITEMS.WARRANTY_RULE_VIEW;
                    const target = 'c-warranty-rules';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    const detailUrl = ROUTES.SETUP_HOME;
                    config.url = `${detailUrl}?${urlParams}`;
                } else if (whereUsed.moduleNameValue === ADMIN_MODULES.DEPOT) {
                    currentNavItem = NAVIGATION_ITEMS.DEPOT_SETTINGS;
                    const target = 'c-depot-finder-rule';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    const detailUrl = ROUTES.SETUP_HOME;
                    config.url = `${detailUrl}?${urlParams}`;
                } else if (whereUsed.subModuleNameValue === ADMIN_MODULES.CONFIGURATION_TEMPLATES) {
                    currentNavItem = NAVIGATION_ITEMS.PSC_CONFIGURATION_TEMPLATES;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__recordId=${config.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    const detailUrl = ROUTES.PSC_CONFIGURATION_TEMPLATES;
                    config.url = `${detailUrl}?${urlParams}`;
                } else if (whereUsed.subModuleNameValue === ADMIN_MODULES.ASSET_HIERARCHY) {
                    currentNavItem = NAVIGATION_ITEMS.ASSET_HIERARCHY_DETAIL_VIEW;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__recordId=${config.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    const detailUrl = ROUTES.ASSET_HIERARCHY_DETAIL_VIEW;
                    config.url = `${detailUrl}?${urlParams}`;
                }  else if (whereUsed.subModuleNameValue === ADMIN_MODULES.ASSET_TIMELINE) {
                    currentNavItem = NAVIGATION_ITEMS.ASSET_TIMELINE_DETAIL_VIEW;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                        `c__recordId=${config.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    const detailUrl = ROUTES.ASSET_TIMELINE_DETAIL_VIEW;
                    config.url = `${detailUrl}?${urlParams}`;
                }
                if (config.sectionTemplates) {
                    config.sectionTemplates.forEach( section => {
                        if (whereUsed.subModuleNameValue === ADMIN_MODULES.TRANSACTION &&
                            (this.moduleType === ADMIN_MODULES.MAPPING ||
                                this.moduleType === ADMIN_MODULES.EXPRESSION) &&
                            section.sectionType !== null &&
                            (section.sectionType === i18n.whereUsedHeaderMapping ||
                            section.sectionType === i18n.whereUsedConditionalDefaultMapping))
                        {
                            section.isMappingAtHeaderSection = true;
                        }
                    })
                }

            })

        });
        this.apiInProgress = false;
    }

    handleCancelModal () {
        this.dispatchEvent(
            new CustomEvent('cancelwhereusedmodal')
        );
    }

    handleCloseModal () {
        this.dispatchEvent(
            new CustomEvent('cancelwhereusedmodal')
        );
    }

    handleDeleteModal () {
        this.dispatchEvent(
            new CustomEvent('deletemodal')
        );
    }

    handleSaveModal () {
        this.dispatchEvent(
            new CustomEvent('savemodal')
        );
    }

}