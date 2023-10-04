import { LightningElement, api, track, wire } from 'lwc';
import {  NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    parseErrorMessage,
    verifyApiResponse,
    PAGE_ACTION_TYPES,
    isNotUndefinedOrNull,
    getLookupReferenceToObject,
    getLookupReferenceNameFields,
    FIELD_DATA_TYPES,
    isEmptyString
} from 'c/utils';
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import templateAssociationResource from '@salesforce/resourceUrl/templateAssociationListView';
import getAllTemplateAssociations
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getAllTemplateAssociations';
import saveTechnicalAttributeTemplateAssociation
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveTechnicalAttributeTemplateAssociation';
import deleteTechnicalAttributeTemplateAssociation
    from '@salesforce/apex/TA_TechnicalAttribute_LS.deleteTechnicalAttributeTemplateAssociation';
import {
    getFieldDefinitionsForEntity
} from 'c/metadataService';

import MATCH_VALUE_OBJ from '@salesforce/schema/SM_TA_TemplateAssociation__c';
import TEMPLATE_OBJ from '@salesforce/schema/SM_TA_Template__c';
import TEMPLATE_FIELD from '@salesforce/schema/SM_TA_TemplateAssociation__c.TemplateId__c';

import labelAddMatchValue from '@salesforce/label/c.Label_AddMatchValue';
import labelTemplateMatchValues from '@salesforce/label/c.Label_TemplateMatchValues';
import labelMatchValueTitle from '@salesforce/label/c.Label_MatchValueTitle';
import labelMatchValueDeleteTitle from '@salesforce/label/c.Label_MatchValueDeleteTitle';
import labelActionCannotBeUndone from '@salesforce/label/c.Label_ActionCannotBeUndone';
import labelSelectTableColumns from '@salesforce/label/c.Label_SelectTableColumns';
import labelSelectTenColumns from '@salesforce/label/c.Label_SelectTenColumns';
import labelTableFieldMaxError from '@salesforce/label/c.Label_TableFieldMaxError';
import labelTableFieldMinError from '@salesforce/label/c.Label_TableFieldMinError';
import labelTemplateMatchValueDeleted from '@salesforce/label/c.Label_TemplateMatchValueDeleted';
import labelTemplateMatchValueCreated from '@salesforce/label/c.Label_TemplateMatchValueCreated';
import labelTemplateMatchValueUpdated from '@salesforce/label/c.Label_TemplateMatchValueUpdated';
import labelTemplateMatchFieldValueErr from '@salesforce/label/c.Label_TemplateMatchFieldValueErr';
import labelAdd from '@salesforce/label/c.Button_Add';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelAvailableFields from '@salesforce/label/c.Label_Available_Fields';
import labelSelectedFields from '@salesforce/label/c.Label_Selected_Fields';
import labelApply from '@salesforce/label/c.Button_Apply';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_SearchExpressions';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDesc from '@salesforce/label/c.Label_Description';
import labelType from '@salesforce/label/c.Label_Type';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelNo from '@salesforce/label/c.Lbl_No';
import labelRowCountMessage
    from '@salesforce/label/c.Message_ServiceCountMessageWithoutBrackets';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelReviewError from '@salesforce/label/c.Label_ReviewErrorMessage';
import labelSetting from '@salesforce/label/c.Label_SelectTableColumns';

const i18n = {
    addMatchValue: labelAddMatchValue,
    templateMatchValues: labelTemplateMatchValues,
    matchValueTitle: labelMatchValueTitle,
    matchValueDeleteTitle: labelMatchValueDeleteTitle,
    actionCannotBeUndone: labelActionCannotBeUndone,
    selectTableColumns: labelSelectTableColumns,
    selectTenColumns: labelSelectTenColumns,
    tableFieldMaxError: labelTableFieldMaxError,
    tableFieldMinError: labelTableFieldMinError,
    templateMatchValueDeleted: labelTemplateMatchValueDeleted,
    templateMatchValueCreated: labelTemplateMatchValueCreated,
    templateMatchValueUpdated: labelTemplateMatchValueUpdated,
    templateMatchFieldValueErr: labelTemplateMatchFieldValueErr,
    add: labelAdd,
    save: labelSave,
    availableFields: labelAvailableFields,
    selectedFields: labelSelectedFields,
    apply: labelApply,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    help: labelHelp,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    loading: labelLoading,
    searchPlaceholder: labelSearchPlaceholder,
    cancel: labelCancel,
    confirm: labelConfirm,
    noResults: labelNoResults,
    description: labelDesc,
    type: labelType,
    no: labelNo,
    rowCountMessage: labelRowCountMessage,
    formValidation: labelFormValidation,
    reviewError: labelReviewError,
    setting: labelSetting,
};
const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' }
];
const DEFAULT_FIELDS = [
    'SVMXA360__TemplateId__c',
    'SVMXA360__ProductFamily__c',
    'SVMXA360__ProductId__c',
];
const actions ={
    type: 'action',
    fixedWidth: 60,
    typeAttributes: { rowActions: ROW_ACTIONS },
};
const sldsCategories =[
    'standard',
    'custom',
    'utility',
    'doctype',
    'action'
];
//const DELAY = 500;

export default class TemplateAssociations extends NavigationMixin(LightningElement) {

    @api recordId;
    @api fromFlow = false;
    @api actionType;

    @track selectedFields = [];
    @track displayFieldColumns = [];
    @track availableTemplateAssociationFields = [];
    @track customTemplateAssociationFields = [];
    @track objectIconList = [];
    @track referenceObjectList = [];
    @track matchValueList = [];
    @track listViewRecords = [];
    @track templateAssociationList = [];
    @track recordInfo = {};
    @track error;
    @track errorMsg;
    apiInProgress = false;
    deleteModalDialogOpen;

    _listViewTableHeight = 100;
    pendingDeleteRecord;
    totalRecordCount = 0;
    noRecordsFound;
    delayTimeout;
    templateRecordId;
    actionName;
    addMatchValueModalOpen = false;
    configColumnsModalOpen = false;
    booleanFalse = false;
    baseUrl;

    get i18n () {
        return i18n;
    }

    get matchValueColumns () {
        return this.displayFieldColumns?.length > 0 ? this.displayFieldColumns : null;
    }

    get computedDataTableHeight () {
        return (this.matchValueList?.length > 15) ?
            `height:400px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    get recordCountInfo () {
        return (this.matchValueList?.length > 1)?`${this.matchValueList?.length} ${this.i18n.items}`
            : `${this.matchValueList?.length} ${this.i18n.item}`;
    }

    get isFromFlow () {
        return this.fromFlow;
    }

    get isCloneTemplateAction () {
        return (this.actionType === PAGE_ACTION_TYPES.CLONE);
    }

    get matchValueRecords () {
        return this.matchValueList?.length > 0 ? this.matchValueList : null;
    }

    /*get disableSearchInput () {
        return this.apiInProgress;
    }*/

    get availableFieldOptions () {
        let availableOptions = [];
        if (this.availableTemplateAssociationFields?.length > 0) {
            availableOptions = this.availableTemplateAssociationFields.map((field) => {
                return {
                    label: field.label,
                    value: field.apiName,
                };
            });
        }
        return availableOptions;
    }

    get selectedFieldOptions () {
        const selectedOptions = [];
        if (this.selectedFields?.length > 0) {
            this.selectedFields.forEach(field => {
                selectedOptions.push(field.apiName);
            });
        }
        return selectedOptions;
    }

    get disableApplyBtn () {
        return (this.selectedFields?.length < 3 || this.selectedFields?.length > 10);
    }

    get hideAddBtn () {
        return this.actionName === PAGE_ACTION_TYPES.EDIT;
    }

    get objectNames () {
        return this.referenceObjectList?.length > 0 ? this.referenceObjectList : null;
    }

    get templateIcon () {
        return this.getLookupIconByObject(TEMPLATE_OBJ.objectApiName)
    }

    get templateFieldLabel () {
        let templateField;
        if (TEMPLATE_FIELD.fieldApiName) {
            templateField = this.getFieldDef(TEMPLATE_FIELD.fieldApiName);
        }
        return templateField?.label ? templateField?.label : '';
    }

    get fieldList () {
        let customFields = [];
        if (this.customTemplateAssociationFields?.length > 0) {
            customFields = this.customTemplateAssociationFields.map((field) => {
                return {
                    def: field,
                    apiName: field.apiName,
                    meta: this.getMeta(field),
                    value: this.recordInfo[field.apiName] ?
                        this.recordInfo[field.apiName] : '',
                    id: this.getRecordIndex()
                };
            });
        }
        return customFields;
    }

    @wire(getObjectInfos, { objectApiNames: '$objectNames' })
    objectInfosWire ({ error, data }) {
        if (data) {
            data.results.forEach(item => {
                const objectIcon = {};
                objectIcon.objectName = item?.result?.apiName;
                const iconurl = item?.result?.themeInfo?.iconUrl;
                if (isNotUndefinedOrNull (iconurl)) {
                    const iconNames = iconurl.split('/');//'/custom:custom12/'
                    const sldsnames = iconNames.pop().split('_');
                    sldsnames.pop();
                    const sldscategory = iconNames.pop();
                    if (sldsCategories.includes(sldscategory)) {
                        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                        objectIcon.iconName = `${sldscategory}:${sldsnames.join('_')}`;
                    } else {
                        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                        objectIcon.iconName = 'custom:custom12';
                    }
                } else {
                    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
                    objectIcon.iconName = 'custom:custom12';
                }
                this.objectIconList.push(objectIcon);
            });
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    async connectedCallback () {
        this.templateRecordId = this.recordId;
        this.baseUrl = window.location.origin;
        await this.getObjectFields(MATCH_VALUE_OBJ.objectApiName);
        this.loadDefaultColumns(this.selectedFields);
        this.clearSearchInputValue();
        this.init();
    }

    renderedCallback () {
        loadStyle(this, templateAssociationResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        const listViewTable = this.template.querySelector(
            '.svmx-match-values-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    init () {
        this.matchValueList = [];
        this.templateAssociationList = [];
        this.listViewRecords = [];
        if (!this.fromFlow || this.isCloneTemplateAction) {
            this.getTemplateAssociations(this.templateRecordId);
        }
    }

    getTemplateAssociations (templateId) {
        const reqObject ={
            parentId: templateId
        };
        this.apiInProgress = true;
        getAllTemplateAssociations({ requestJson: JSON.stringify(reqObject) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.totalRecordCount = result?.data?.length;
                if (this.totalRecordCount === 0) {
                    this.noRecordsFound = true;
                    return;
                }
                const listViewData = JSON.parse(
                    JSON.stringify(result.data));
                this.templateAssociationList = this.populateListViewData(listViewData);
                this.matchValueList = this.matchValueList.concat(this.templateAssociationList);
                this.listViewRecords = JSON.parse(JSON.stringify(this.matchValueList));
                this.dispatchAssociationRecord(this.matchValueList,'addassociation');
            })
            .catch(error => {
                this.matchValueList = [];
                this.templateAssociationList = [];
                this.listViewRecords = [];
                this.error = parseErrorMessage(error);

            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    populateListViewData (newData) {
        const sfdcBaseUrl = this.baseUrl+'/';
        const listViewData =[];
        let seq = 1;
        newData.forEach(row=>{
            const currentResult = {};
            Object.keys(row).forEach(field => {
                const fieldName = field;
                let relatedRecord;
                if (this.isLookupField(fieldName)) {
                    if (fieldName.endsWith("Id")) {
                        const relatedFieldName = fieldName.replace("Id", "");
                        relatedRecord = row[relatedFieldName];
                    } else if (fieldName.endsWith("__c")) {
                        const relatedFieldName = fieldName.replace("__c", "__r");
                        relatedRecord = row[relatedFieldName];
                    }
                    if (isNotUndefinedOrNull(relatedRecord)) {
                        currentResult[field] = relatedRecord.Id;
                        currentResult[`${field}Name`] = relatedRecord.Name;
                        currentResult[`${field}Url`] = sfdcBaseUrl + relatedRecord.Id;
                    }

                } else if (!fieldName.endsWith("__r")) {
                    currentResult[fieldName] = row[fieldName];
                }
            })
            currentResult.sequence = seq;
            seq++;
            listViewData.push(currentResult);
        });
        return listViewData;
    }

    handleRowAction (event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        // eslint-disable-next-line default-case
        switch (action) {
            case 'edit':
                this.handleEdit(row,PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.handleEdit(row,PAGE_ACTION_TYPES.CLONE);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
        }
    }

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');
        if (input) {
            input.value = '';
        }
    }

    async getObjectFields (objectApiName) {
        if (isEmptyString(objectApiName)) {
            return;
        }
        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);
            if (resp && resp.data) {
                const result = resp.data;
                this.populateAvailableFields(result.fieldDefinitions);
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
    }

    populateAvailableFields (fieldDefinitions) {
        fieldDefinitions.forEach( field => {
            const apiName = field.apiName;
            const dataType = field.dataType;
            if ( dataType !== 'LOCATION' && dataType !== 'ADDRESS' &&
                dataType !== 'BASE64' && dataType !== 'ENCRYPTEDSTRING' &&
                apiName !== 'LogoId' && apiName !== 'Id' && apiName !== 'Name' &&
                apiName !== 'IsDeleted' && apiName !== 'SystemModstamp') {
                this.availableTemplateAssociationFields.push(field);
                if (DEFAULT_FIELDS.includes(apiName)) {
                    this.selectedFields.push(field);
                }
            }
            if (apiName.endsWith("__c") && apiName !== TEMPLATE_FIELD.fieldApiName) {
                this.customTemplateAssociationFields.push(field);
            }
            if (dataType === FIELD_DATA_TYPES.REFERENCE && !isEmptyString(field.referenceTo[0]) &&
                !this.referenceObjectList.includes(field.referenceTo[0])) {
                this.referenceObjectList.push(field.referenceTo[0]);
            }
        });
    }

    loadDefaultColumns (fields) {
        const fieldColumns = this.mapConfigToColumns(fields);
        if (fieldColumns?.length > 0) {
            this.displayFieldColumns = fieldColumns.concat(actions);
        }
    }

    /*handleSearchCommit (event) {
        const searchValue = event.target.value.trim();
        if ((searchValue && searchValue.length > 2) || searchValue.length === 0) {
            window.clearTimeout(this.delayTimeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                try {
                    this.filterListViewData(searchValue);
                } catch (e) {
                    this.error = parseErrorMessage(e);
                }
            }, DELAY);
        }
    }*/

    filterListViewData (searchValue) {
        const templateAssociations = JSON.parse(JSON.stringify(this.listViewRecords))
        if (isEmptyString(searchValue)) {
            this.matchValueList = templateAssociations;
        } else {
            const searchFields = this.getSearchFields();
            this.matchValueList = templateAssociations.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                let hasMatch = false;
                searchFields.forEach(column => {
                    if (hasMatch) return;
                    hasMatch = ( item[column]
                        && (item[column].toLowerCase().indexOf(loweredSearchValue) !== -1 ) ) ?
                        true : false;
                });
                return hasMatch;
            });
        }
    }

    getSearchFields () {
        const searchFields = [];
        this.selectedFields.forEach(field => {
            if (this.isLookupField(field.apiName)) {
                searchFields.push(this.getReference(field.apiName));
            } else {
                searchFields.push(field.apiName);
            }
        });
        return searchFields;
    }

    handleValueChange (event) {
        const fieldApiname = event.target.getAttribute('data-field-apiname');
        if (this.isLookupField(fieldApiname)) {
            this.resolveLookupField (fieldApiname,event.detail);
        } else {
            const dynamicField = { [fieldApiname]: event.detail.value };
            this.recordInfo = Object.assign(this.recordInfo, dynamicField);
        }
    }

    handleLookupFieldChange (event) {
        if (!event.detail) {
            return;
        }
        event.stopPropagation();
        const { detail, target } = event;
        this.resolveLookupField(target.dataset.field,detail);
    }

    handleChangeFields (event) {
        const fields = [];
        this.selectedFields = [];
        if (event.detail?.value?.length > 0) {
            event.detail.value.forEach(field => {
                fields.push(this.getFieldDef(field))
            });
        }
        this.selectedFields = fields;
    }

    resolveLookupField (fieldName, detail) {
        this.recordInfo[fieldName] = detail?.value;
        this.recordInfo[this.getUrl(fieldName)] = detail?.value ?
            this.getRecordUrl(detail.value) : null;
        this.recordInfo[this.getReference(fieldName)] = detail?.label;
    }

    isLookupField (fieldName) {
        let isReferenceField = false;
        this.availableTemplateAssociationFields.forEach(row => {

            if (row.apiName === fieldName && row.dataType === FIELD_DATA_TYPES.REFERENCE) {
                isReferenceField = true;
            }
        });
        return isReferenceField;
    }

    getReference (fieldName) {
        let result = "";
        if (fieldName.endsWith("Id")) {
            result = fieldName + "Name";
        } else {
            result = fieldName.replace("__c", "__cName");
        }
        return result;
    }

    getUrl (fieldName) {
        let result = "";
        if (fieldName.endsWith("Id")) {
            result = fieldName + "Url";
        } else {
            result = fieldName.replace("__c", "__cUrl");
        }
        return result;
    }

    getRecordUrl (recordId) {
        return  `${this.baseUrl}/${recordId}`;
    }

    mapConfigToColumns (configFields) {
        let configColumns = [];
        if (configFields?.length > 0) {
            configColumns = configFields?.map(field => {
                const type = field.dataType.toLowerCase();
                const columnDef = {
                    type: this.castFieldToSupportType(field),
                    fieldName: this.isLookupField(field.apiName) ?
                        this.getUrl(field.apiName) : field.apiName,
                    label: field.label,
                    hideDefaultActions: true,
                    typeAttributes: this.getTypeAttributesByType(type, field)
                }
                return columnDef;
            });
        }
        return configColumns;
    }

    getRecordIndex () {
        let index;
        if (!this.fromFlow) {
            index =  this.recordInfo?.Id ? this.recordInfo.Id : null;
        } else {
            index =  this.recordInfo?.sequence ? this.recordInfo.sequence : 0;
        }
        return index;
    }

    getFieldDef (fieldName) {
        const fieldDef =  this.availableTemplateAssociationFields.find(
            field => field.apiName === fieldName);

        return fieldDef;
    }

    castFieldToSupportType = (fieldDef) => {
        let type = '';
        const fieldType = fieldDef?.dataType.toLowerCase();
        switch (fieldType) {
            // standard types
            case 'date':
                type = 'date-local';
                break;
            case 'datetime':
                type = 'date';
                break;
            case 'time':
                type = 'xTime';
                break;
            case 'percent':
            case 'double':
            case 'int':
                type = 'number';
                break;
            // always readonly as its salesforce system field
            case 'ID':
                type = 'text';
                break;
            case 'string':
                //type = 'text';
                type = fieldDef?.calculated ? 'xRichText' : 'text';
                break;
            case 'reference':
                type = 'xUrl';
                break;
            case 'textarea':
                type = 'xTextarea';
                break;
            case 'picklist':
            case 'multipicklist':
                type = 'xPicklist';
                break;
            default:
                type = fieldType;
        }

        if (fieldDef?.apiName === 'RecordTypeId') {
            type = 'text';
        }
        return type;
    }

    getTypeAttributesByType (type, field) {
        const typeAttributesByType = new Map([
            [
                "reference",
                {
                    label: { fieldName: this.getReference(field.apiName) },
                    tooltip: {
                        fieldName: this.getReference(field.apiName),
                    },
                    target: { fieldName: field.apiName },
                },
            ],
            ['datetime', {
                timeZone: TIMEZONE,
                month: '2-digit',
                day: '2-digit',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric'
            }]
        ]);
        return typeAttributesByType.get(type) ?? {};
    }

    handleConfigColumns () {
        this.configColumnsModalOpen = true;
    }

    handleConfigColumnCancel () {
        this.configColumnsModalOpen = false;
    }

    handleApplyColumn () {
        this.handleConfigColumnCancel();
        this.loadDefaultColumns(this.selectedFields);
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleDelete () {

        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        if (!this.fromFlow || ( this.isCloneTemplateAction &&
                !isEmptyString(this.pendingDeleteRecord.id))) {
            this.deleteTemplateAssociation();
        } else {
            try {
                this.deleteMatchValue(this.pendingDeleteRecord);
            }
            catch (err) {
                this.error = parseErrorMessage(err);
            } finally {
                this.pendingDeleteRecord = undefined
            }
        }
    }

    deleteMatchValue (record) {
        const deleteRecord = JSON.parse(JSON.stringify(record));
        this.matchValueList = this.matchValueList.filter(
            row => row.sequence !== deleteRecord.sequence);
        //update the sequence
        let index = 1;
        this.matchValueList.forEach(row=> {
            row.sequence = index;
            index++;
        });
        this.listViewRecords = JSON.parse(JSON.stringify(this.matchValueList));
        const toastMsg = `${this.i18n.templateMatchValueDeleted}`;
        this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
        this.dispatchAssociationRecord(this.matchValueList,'removeassociation');
    }

    deleteTemplateAssociation () {
        deleteTechnicalAttributeTemplateAssociation({
            templateAssociation: this.pendingDeleteRecord.Id })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const toastMsg =
                    `${this.i18n.templateMatchValueDeleted}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.pendingDeleteRecord.Id = null;
                this.deleteMatchValue(this.pendingDeleteRecord);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.pendingDeleteRecord = undefined;
            });
    }

    handleEdit (record, action) {
        this.recordInfo = {};
        this.recordInfo = JSON.parse(JSON.stringify(record));
        this.actionName = action;
        this.recordInfo.SVMXA360__TemplateId__c = this.templateRecordId;
        if (this.actionName === PAGE_ACTION_TYPES.CLONE) {
            if (!this.fromFlow) {
                this.recordInfo.Id = null;
            } else {
                this.recordInfo.Id = null;
                this.recordInfo.sequence = null;
            }
        }
        this.addMatchValueModalOpen = true;
    }

    handleNewMatchValue () {
        this.addMatchValueModalOpen = true;
        this.recordInfo = {};
        this.recordInfo.SVMXA360__TemplateId__c = this.templateRecordId;
    }

    handleAddValueCancel () {
        this.addMatchValueModalOpen = false;
        this.recordInfo = {};
        this.actionName=null;
        this.error = null;
        this.errorMsg = null;
    }

    handleAddMatchValue () {

        if (!this.isValidInput()) return;
        if (!this.fromFlow) {
            if (this.actionName === PAGE_ACTION_TYPES.EDIT) {
                delete this.recordInfo.SVMXA360__TemplateId__c;
            }
            this.saveTemplateAssociation(this.recordInfo);
        } else {
            this.listViewRecords = JSON.parse(JSON.stringify(this.matchValueList));
            if (this.recordInfo.sequence) {
                const recordIndex = this.listViewRecords.findIndex(
                    (row => row.sequence === this.recordInfo.sequence));
                this.listViewRecords[recordIndex] = this.recordInfo;
            } else {
                this.recordInfo.sequence = this.listViewRecords.length+1;
                this.listViewRecords = this.listViewRecords.concat(this.recordInfo);
            }
            this.matchValueList = this.listViewRecords;
            this.dispatchAssociationRecord(this.matchValueList,'addassociation');
            this.handleAddValueCancel();
        }
    }

    saveTemplateAssociation (data) {
        const recordToSave = this.prepareRequestJSON(data);
        this.apiInProgress = true;
        saveTechnicalAttributeTemplateAssociation({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.errorMsg = result.message;
                    return;
                }
                const toastMsg = `${this.recordInfo.Id ?
                    this.i18n.templateMatchValueUpdated :
                    this.i18n.templateMatchValueCreated}`;
                this.showToast('Success', this.i18n.success, toastMsg, 'success', 'dismissible');
                this.handleAddValueCancel();
                this.init();
            })
            .catch(error => {
                this.errorMsg = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    prepareRequestJSON (record) {
        const fieldValueMap = {};
        const requestJson = {};
        Object.keys(record).forEach(field => {
            const fieldName = field.toLowerCase();
            if (fieldName === 'id' || fieldName.endsWith("__c")) {
                fieldValueMap[field] = record[field];
            }
        });
        requestJson.customFieldValueMap = fieldValueMap;
        return requestJson;
    }

    dispatchAssociationRecord (records,eventName) {
        const associationRecords = JSON.parse(JSON.stringify(records));
        this.dispatchEvent(
            new CustomEvent(eventName, {
                detail: {
                    associations: associationRecords,
                }
            })
        );
    }

    isValidInput () {
        let isValid = true;
        this.errorMsg = '';
        const customFields = [];
        Object.keys(this.recordInfo).forEach(field => {
            const fieldName = field;
            const fieldValue = this.recordInfo[fieldName];
            if (fieldName !== TEMPLATE_FIELD.fieldApiName && fieldName.endsWith("__c") &&
                !isEmptyString(fieldValue)) {
                customFields.push(fieldName)
            }
        });
        if (customFields.length === 0) {
            this.errorMsg = this.i18n.templateMatchFieldValueErr;
            return false;
        }
        isValid = [...this.template.querySelectorAll(
            '.svmx-ta-input_field')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (!isValid) {
            this.errorMsg = this.i18n.formValidation;
        }
        return isValid;
    }

    getMeta (fieldDef) {
        if ( fieldDef.dataType === FIELD_DATA_TYPES.REFERENCE ) {
            return this.getLookupConfig(fieldDef);
        }
        return null;
    }

    getLookupConfig (fieldDefinition) {
        const objectApiName = getLookupReferenceToObject(fieldDefinition);

        return fieldDefinition
                    && (fieldDefinition.referenceTo
                    || fieldDefinition.referenceNameFields)
            ? {
                filters: "",
                icon: this.getLookupIconByObject(objectApiName),
                objectApiName: objectApiName,
                fieldApiName: fieldDefinition.apiName,
                placeholder: 'Search',
                referenceNameFields: getLookupReferenceNameFields(fieldDefinition),
                enableAdvancedSearch: false,
            }
            : undefined;
    }

    getLookupIconByObject (objectApiName) {
        if (isEmptyString(objectApiName))  return '';
        const iconName = this.objectIconList.filter(
            item => item.objectName === objectApiName).iconName;
        return iconName;
    }

    showToast (type, title, message, variant, mode) {
        const evt = new ShowToastEvent({
            type: type,
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}