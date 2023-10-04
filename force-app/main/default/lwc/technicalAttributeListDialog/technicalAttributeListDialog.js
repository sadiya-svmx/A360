import { LightningElement, api, track } from 'lwc';

import getAllTechnicalAttributes
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getAllTechnicalAttributes';

import labelAddAttribute from '@salesforce/label/c.Label_SelectAttributes';
import labelNewAttribute from '@salesforce/label/c.Label_NewAttribute';
import labelSelectedItems from '@salesforce/label/c.Label_SelectedItems';
import labelHideSelectedItems from '@salesforce/label/c.Label_HideSelectedItems';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelCancel from '@salesforce/label/c.Btn_Cancel';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelDuplicateAttributeFound from
    '@salesforce/label/c.Message_DuplicateAttributeFound';

import {
    deepCopy,
    parseErrorMessage,
    verifyApiResponse,
    guid
} from 'c/utils';

const DEFAULT_ORDER_FIELD ='Name';
const DEFAULT_ORDER ='asc';
const DELAY = 500;

const i18n = {
    addAttribute: labelAddAttribute,
    newAttribute: labelNewAttribute,
    selectedItems: labelSelectedItems,
    hideSelectedItems: labelHideSelectedItems,
    loading: labelLoading,
    cancel: labelCancel,
    save: labelSave,
    duplicateAttributeFound: labelDuplicateAttributeFound
}

export default class TechnicalAttributeListDialog extends LightningElement {

    @track _modalOpen = false;
    @track error;
    @track apiInProgress = false;
    @track technicalAttributeRecordList = [];
    @track sortBy = 'name';
    @track sortDirection = 'asc';
    @track _categoryRecord;
    @track selectedRowIds = [];
    @track showSelectedItems = false;

    @api categories = [];

    sortField = DEFAULT_ORDER_FIELD;
    sortOrder = DEFAULT_ORDER;
    searchKey;
    selectedRows = [];
    searchTerm = '';
    totalRecordCount = 0;
    noRecordsFound;
    currentRecordCount = 0;
    hasEmptySelectedId = false;
    templateId;
    delayTimeout;
    templateDevName = null;
    _selectedRowIds = [];
    _selectedRows = [];
    selectedRowList = [];

    constructor () {
        super();
        this.columns = this.getColumns();
        this.selectedRowColumns = this.getSelectedRowColumns();
    }

    /**
    * If present, displays the step configuration dialog
    * @type {boolean}
    * @default false
    */
    @api
    get modalOpen () {
        return this._modalOpen;
    }
    set modalOpen (newValue) {
        this._modalOpen = newValue;
    }

    /**
     * This value represents a record from the SVMXA360__SM_TA_Category__c object.
     * @type {object}
     */
    @api
    get categoryRecord () {
        return this._categoryRecord;
    }
    set categoryRecord (newValue) {
        if (!newValue) {
            this._categoryRecord = null;
            return;
        }

        this._categoryRecord = deepCopy(newValue);
    }

    /**
    * This value represents template Id.
    * @type {object}
    */
    @api
    get templateRecordId () {
        return this.templateId;
    }
    set templateRecordId (newValue) {
        if (!newValue) {
            this.templateId = null;
            return;
        }

        this.templateId = deepCopy(newValue);
    }

    /**
    * This value represents template Developer Name.
    * @type {object}
    */
    @api
    get templateDeveloperName () {
        return this.templateDevName;
    }
    set templateDeveloperName (newValue) {
        if (!newValue) {
            this.templateDevName = null;
            return;
        }

        this.templateDevName = deepCopy(newValue);
    }

    get i18n () {
        return i18n;
    }

    get technicalAttributeRecords () {
        return this.technicalAttributeRecordList?.length> 0 ?
            this.technicalAttributeRecordList : [];
    }

    get selectedRecords () {
        return this.selectedRows?.length > 0 ? this.selectedRows : [];
    }

    get selectedItemMessage () {
        return i18n.selectedItems + '(' + this.selectedRows.length + ')';
    }

    handleSearchKeyChange (event) {
        const searchValue = event.target.value.trim();
        this.searchKey =searchValue;
        if ((this.searchKey && this.searchKey.length > 2) || this.searchKey.length === 0) {
            window.clearTimeout(this.delayTimeout);

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                try {
                    this._selectedRowIds = deepCopy(this.selectedRowIds);
                    this._selectedRows = deepCopy(this.selectedRows);
                    this.fetchRecords();
                } catch (e) {
                    this.error = parseErrorMessage(e);
                }
            }, DELAY);
        }
    }

    handleCancelModal () {
        this.searchKey = null;
        this.error = null;
        this.dispatchEvent(
            new CustomEvent('categoryconfigclosed')
        );
    }

    handleShowSelectedItems () {
        this.selectedRowList = deepCopy(this.selectedRows);
        this.showSelectedItems = true;
    }

    handleHideSelectedItems () {
        this.selectedRowList = [];
        this.showSelectedItems = false;
    }

    /**
    * This fetches technical attribute records exposed as API method.
    *
    */
    @api fetchRecords () {
        this.apiInProgress = true;
        this.technicalAttributeRecordList = [];
        this.totalRecordCount = 0;
        getAllTechnicalAttributes({
            requestJson: this.requestJson
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            this.totalRecordCount = result.data.totalRecordCount;
            if (this.totalRecordCount === 0) {
                this.noRecordsFound = true;
                return;
            }
            this.technicalAttributeRecordList =
                JSON.parse(JSON.stringify(result.data.technicalAttributeList));
            this.error = undefined;
            if ( this._selectedRowIds && this._selectedRows && this._selectedRowIds.length > 0 ) {
                this.selectedRows = deepCopy(this._selectedRows);
                this.selectedRowIds = deepCopy(this._selectedRowIds);
                this.populateTechAttributeList();
            }

        }).catch(error => {
            this.technicalAttributeRecordList = [];
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateTechAttributeList () {

        if ( this.technicalAttributeRecordList.length > 0 && this.searchKey.length !== 0 ) {
            this.selectedRows.forEach(row =>{
                const indexVal = this.getSelectedIndex( row.id, this.technicalAttributeRecordList );
                if ( indexVal > -1 ) {
                    this.technicalAttributeRecordList.splice(indexVal, 1);
                }
            })
        }

        if ( this.searchKey.length === 0 ) {
            this._selectedRowIds = [];
            this._selectedRows = [];
        }
    }

    getSelectedIndex (inputVal,itemList) {
        return itemList.findIndex(
            itemRec => itemRec.id === inputVal
        );
    }

    get disableSearchInput () {
        return this.apiInProgress;
    }

    handleRowSelection (event) {
        this.selectedRows = [];
        this.selectedRowIds = [];

        if (event.detail.selectedRows.length > 0) {
            event.detail.selectedRows.forEach(row =>{
                this.selectedRowIds.push(row.id);
                this.selectedRows.push(row);
            })

            if ( this._selectedRows.length > 0 ) {
                this._selectedRows.forEach(selRow =>{
                    this.selectedRowIds.push(selRow.id);
                    this.selectedRows.push(selRow);
                })
            }
        }
    }

    get requestJson () {
        const reqObject ={
            limitCount: 200,
            searchTerm: this.searchKey,
            sortField: this.sortField,
            sortOrder: this.sortOrder,
            queryOffset: 0,
        };

        return JSON.stringify(reqObject);
    }

    getItemIndexByAttribute (inputVal,itemList) {
        return itemList.findIndex(
            itemRec => itemRec.attributeId === inputVal
        );
    }

    handleSave () {

        try {
            this.error = null;
            let templateItems = [];
            templateItems = this._categoryRecord?.technicalAttributeTemplateItems;
            let sequenceCount = templateItems.length + 1;
            let templateItem;

            const existingTemplateItems = [];
            this.categories.forEach(categoryRecord =>{
                if ( categoryRecord.technicalAttributeTemplateItems
                        && categoryRecord.technicalAttributeTemplateItems.length > 0 ) {
                            categoryRecord.technicalAttributeTemplateItems.forEach(tempItem =>{
                                existingTemplateItems.push(tempItem);
                            })
                }
            })

            this.selectedRows.forEach(row =>{
                if ( existingTemplateItems ) {
                    const indexVal = this.getItemIndexByAttribute(row.id,existingTemplateItems);
                    if ( indexVal > -1 ) {
                        this.error = i18n.duplicateAttributeFound + ' - ' + row.name;
                        throw this.error;
                    }
                }
            })

            if (!this.error) {
                this.selectedRows.forEach(row =>{
                    const devName = this.templateDevName + this._categoryRecord.developerName
                    + row.developerName;
                    const truncDevName = devName.slice(0,45);
                    const uniqueId = guid();
                    const truncUniqueId = uniqueId.substring(0,34);
                    const itemDeveloperName = truncDevName + '-' + truncUniqueId;
                    templateItem = this.populateTemplateItem(row,sequenceCount,itemDeveloperName);
                    templateItems.push(templateItem);
                    sequenceCount = sequenceCount + 1;
                })
                this._categoryRecord.technicalAttributeTemplateItems = templateItems;
                this.selectedRows = [];
                this.selectedRowIds = [];
                this.searchKey = null;
                this.dispatchChangeEvent(Object.assign({}, this._categoryRecord));
            }

        } catch (error) {
            this.error = parseErrorMessage(error);
        }
    }

    dispatchChangeEvent (changedValue) {
        this.dispatchEvent(
            new CustomEvent('categoryconfigchanged', {
                detail: {
                    value: changedValue
                }
            })
        );
    }

    populateTemplateItem (row, sequenceCount, itemDeveloperName) {
        const templateItemRec = {
            attributeId: row.id,
            categoryId: this._categoryRecord.id,
            defaultValue: row.defaultValue,
            developerName: itemDeveloperName,
            helpText: row.helptext,
            isReadOnly: false,
            isRequired: false,
            maximumValue: row.maximumValue,
            minimumValue: row.minimumValue,
            status: null,
            templateId: this.templateId,
            dataType: row.dataType,
            sequence: sequenceCount,
            message: row.message,
            name: row.name,
            attributeName: row.name
        }
        return templateItemRec;
    }

    handleNewAttributeRecord () {
        this.template.querySelector('c-technical-attribute-detail').handleNewAttribute();
    }

    handleAttributeCreation (event) {
        const newAttributeRecord = JSON.parse(JSON.stringify(event.detail.technicalAttribute));
        const technicalAttributes = deepCopy(this.technicalAttributeRecordList);
        const selectedIds = deepCopy(this.selectedRowIds);
        this.selectedRowIds = [];
        this.technicalAttributeRecordList = [];
        this.technicalAttributeRecordList = JSON.parse(JSON.stringify(technicalAttributes));
        this.technicalAttributeRecordList.unshift(newAttributeRecord);
        this.selectedRowIds = selectedIds;
        this.selectedRowIds.push(newAttributeRecord.id);
        this.selectedRows.push(newAttributeRecord);
    }

    getColumns () {
        return [
            {
                label: 'Attribute Name',
                hideDefaultActions: true,
                fieldName: 'name',
                wrapText: false
            },
            {
                label: 'Developer Name',
                fieldName: 'developerName',
                hideDefaultActions: true,
                wrapText: false
            },
            {
                label: 'Type',
                fieldName: 'dataType',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: 'Description',
                fieldName: 'description',
                hideDefaultActions: true,
                wrapText: false
            }
        ];
    }

    getSelectedRowColumns () {
        return [
            {
                label: 'Name',
                hideDefaultActions: true,
                fieldName: 'name',
                wrapText: false
            },
            {
                label: 'Developer Name',
                fieldName: 'developerName',
                hideDefaultActions: true,
                wrapText: false
            },
            {
                label: 'Type',
                fieldName: 'dataType',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            }
        ];
    }

}