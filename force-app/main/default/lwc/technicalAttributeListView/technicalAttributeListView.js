import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    parseErrorMessage,
    verifyApiResponse,
    formatString,
    PAGE_ACTION_TYPES,
    deepCopy,
    isUndefinedOrNull,
} from 'c/utils';
import ICONS from '@salesforce/resourceUrl/pscIcons';
import { loadStyle } from 'lightning/platformResourceLoader';
import contractLineItemPlanDetailResource
    from '@salesforce/resourceUrl/contractLineItemPlanDetail';
import getAllTechnicalAttributes
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getAllTechnicalAttributes';
import deleteCheckOnRelatedTA
    from '@salesforce/apex/TA_TechnicalAttribute_LS.deleteCheckOnRelatedTA';
import deleteTechnicalAttribute
    from '@salesforce/apex/TA_TechnicalAttribute_LS.deleteTechnicalAttribute';
import getWhereUsedDetails
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getWhereUsedDetails';

import getAllUserGroups
    from '@salesforce/apex/TA_TechnicalAttribute_LS.getAllUserGroups';
import saveUserGroupTechnicalAttribute
    from '@salesforce/apex/TA_TechnicalAttribute_LS.saveUserGroupTechnicalAttribute';

import labelAttributeManager from '@salesforce/label/c.Label_TechnicalAttributes';
import labelConfigTemplates from '@salesforce/label/c.Label_Configuration_Templates';
import labelNewButton from '@salesforce/label/c.Label_NewAttribute';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelLoading from '@salesforce/label/c.Label_Loading';
import labelSearchPlaceholder from '@salesforce/label/c.Label_AttributeSearch';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelDeleteModalTitle from '@salesforce/label/c.Label_AttributeDeleteModalTitle';
import labelDeleteModalContent from '@salesforce/label/c.Label_AttributeDeleteModalContent';
import labelAttributeName from '@salesforce/label/c.Label_AttributeName';
import labelDesc from '@salesforce/label/c.Label_Description';
import labelType from '@salesforce/label/c.Label_Type';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelTAHelp from '@salesforce/label/c.Label_PSC_Smart_Help';
import labelActive from '@salesforce/label/c.Label_Active';
import labelYes from '@salesforce/label/c.Lbl_Yes';
import labelNo from '@salesforce/label/c.Lbl_No';
import labelWhereUsed from '@salesforce/label/c.Label_AttributeWhereUsed';
import labelAssetAttributeReference from '@salesforce/label/c.Label_AssetAttributeReference';
import labelAttributeWhereUsedContent from '@salesforce/label/c.Label_AttributeWhereUsedContent';
import labelRowCountMessage
    from '@salesforce/label/c.Message_ServiceCountMessageWithoutBrackets';
import labelAttributeWhereUsedDetails from '@salesforce/label/c.Label_AttributeWhereUsedDetails';
import labelAttributeNotUsed from '@salesforce/label/c.Label_AttributeNotUsed';
import labelOK from '@salesforce/label/c.Button_OK';
import labelTechnicalAttributeTemplates
    from '@salesforce/label/c.Label_TechnicalAttributeTemplates';
import labelUserGroups from '@salesforce/label/c.Label_UserGroups';
import labelSelectedItems from '@salesforce/label/c.Label_SelectedItems';
import labelHideSelectedItems from '@salesforce/label/c.Label_HideSelectedItems';
import labelAddUserGroup from '@salesforce/label/c.Label_AddUserGroup';
import labelApply from '@salesforce/label/c.Button_Apply';
import labelUserGroupName from '@salesforce/label/c.Label_UserGroupName';
import labelUserGroupTAAddedMsg from '@salesforce/label/c.Label_UserGroupTAAddedMsg';
import labelUserGroupAssignmentInfo from '@salesforce/label/c.Label_UserGroupAssignmentInfo';

const i18n = {
    pageHeader: labelAttributeManager,
    configTemplatesLabel: labelConfigTemplates,
    new: labelNewButton,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    whereUsed: labelWhereUsed,
    help: labelHelp,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    loading: labelLoading,
    searchPlaceholder: labelSearchPlaceholder,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteSuccess: labelDeletedSuccess,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    assetAttributeReference: labelAssetAttributeReference,
    attributeWhereUsedContent: labelAttributeWhereUsedContent,
    noResults: labelNoResults,
    attributeName: labelAttributeName,
    description: labelDesc,
    type: labelType,
    helpLink: labelTAHelp,
    labelActive: labelActive,
    yes: labelYes,
    no: labelNo,
    rowCountMessage: labelRowCountMessage,
    attributeWhereUsedDetails: labelAttributeWhereUsedDetails,
    attributeNotUsed: labelAttributeNotUsed,
    ok: labelOK,
    technicalAttributeTemplates: labelTechnicalAttributeTemplates,
    userGroups: labelUserGroups,
    selectedItems: labelSelectedItems,
    hideSelectedItems: labelHideSelectedItems,
    addUserGroup: labelAddUserGroup,
    apply: labelApply,
    userGroupName: labelUserGroupName,
    userGroupTAAddedMsg: labelUserGroupTAAddedMsg,
    userGroupAssignmentInfo: labelUserGroupAssignmentInfo,

};
const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.whereUsed, name: 'whereUsed' },
    { label: i18n.addUserGroup, name: 'addToUserGroup' },
    { label: i18n.delete, name: 'delete' }
];

const DELAY = 500;
const PAGE_SIZE = 50;
const DEFAULT_ORDER_FIELD ='Name';
const DEFAULT_ORDER ='asc';

export default class TechnicalAttributeListView extends NavigationMixin(LightningElement) {

    @track attributeRecords = [];
    @track attributeRecordList = [];
    @track technicalAttributeRecords = [];
    @track technicalAttributeRecordList = [];

    @track displayRecords = [];
    @track attributeReference = {};
    @track apiInProgress = false;
    @track sortBy = 'name';
    @track sortDirection = 'asc';

    @track error;
    @track deleteModalDialogOpen;
    _listViewTableHeight = 100;
    currentNavItem;
    pendingDeleteRecord
    logoUrl = `${ICONS}/pscIcons/ServiceMax_Logo.svg`;

    searchTerm = '';
    totalRecordCount = 0;
    noRecordsFound;
    currentRecordCount = 0;

    startIndex = 0;
    endIndex = PAGE_SIZE;
    sortField = DEFAULT_ORDER_FIELD;
    sortOrder = DEFAULT_ORDER;
    delayTimeout;
    whereUsedModalOpen = false;
    whereUsedModalTitle;
    fromViewModal = false;
    viewRecord;
    baseUrl;

    userGroupModalOpen = false;
    showSelectedItems = false;
    selectedRows = [];
    _selectedRowIds = [];
    _selectedRows = [];
    @track selectedRowList = [];
    @track selectedRowIds = [];
    @track userGroupList = [];

    @track userGroupSortBy = 'name';
    @track userGroupSortDirection = 'asc';
    @track userGroupColumns = [];
    @track attributeRecordDetail = {}

    userGroupSearchText ='';

    constructor () {
        super();
        this.columns = this.getColumns();
        this.userGroupColumns = this.getSelectedRowColumns();
    }

    get i18n () {
        return i18n;
    }

    get computedDataTableHeight () {
        return (this.currentRecordCount > 15) ?
            `height:500px` : `height: calc(100% - ${this._listViewTableHeight}px)`;
    }

    get showDeleteActionNotsupported () {
        return this.attributeReference?.relatedAssetTechnicalAttributes?.length > 0;
    }

    get showRelatedTemplateItems () {
        return this.showDeleteActionNotsupported ? false :
            this.attributeReference?.relatedTemplates?.length > 0;
    }

    get relatedTemplateItems () {
        let relatedTemplates = [];
        if (this.attributeReference?.relatedTemplates?.length > 0) {
            relatedTemplates = this.attributeReference?.relatedTemplates.map((element) => {
                const sfdcBaseUrl = this.baseUrl+'/';
                return {
                    id: element.id,
                    templateName: element.templateName,
                    templateId: element.templateId,
                    value: sfdcBaseUrl + element.templateId,
                };
            });
        }
        return relatedTemplates;
    }

    get relatedUserGroups () {
        let relatedGroups = [];
        if (this.attributeReference?.relatedUserGroups?.length > 0) {
            relatedGroups = this.attributeReference?.relatedUserGroups.map((element) => {
                const sfdcBaseUrl = this.baseUrl+'/';
                return {
                    id: element.id,
                    name: element.name,
                    value: sfdcBaseUrl + element.id,
                };
            });
        }
        return relatedGroups;
    }

    get showDeleteModalContent () {
        return (this.showDeleteActionNotsupported || this.showRelatedTemplateItems) ? false : true ;
    }

    get showWhereUsedDetails () {
        return this.attributeReference?.relatedTemplates?.length > 0;
    }

    get showUserGroups () {
        return this.attributeReference?.relatedUserGroups?.length > 0;
    }

    get attributeUsed () {
        return (this.showUserGroups || this.showWhereUsedDetails);
    }

    get recordCountInfo () {
        return (this.totalRecordCount > 50) ?
            formatString(i18n.rowCountMessage,
                this.currentRecordCount,
                this.totalRecordCount,
                this.i18n.items)
            : (this.totalRecordCount === 1) ?`${this.totalRecordCount} ${this.i18n.item}`
                : `${this.totalRecordCount} ${this.i18n.items}`;
    }

    get listViewRecords () {
        if (this.displayRecords && this.displayRecords.length > 0) {
            return this.displayRecords;
        }
        return null;
    }

    get disableSearchInput () {
        return this.apiInProgress;
    }

    get requestJson () {
        const reqObject ={
            limitCount: 1000,
            searchTerm: this.searchKey,
            sortField: this.sortField,
            sortOrder: this.sortOrder,
            queryOffset: 0,
        };

        return JSON.stringify(reqObject);
    }

    get selectedRecords () {
        return this.selectedRows?.length > 0 ? this.selectedRows : [];
    }

    get selectedItemMessage () {
        return i18n.selectedItems + '(' + this.selectedRows?.length + ')';
    }

    get userGroupRecords () {
        return this.userGroupList?.length> 0 ?
            this.userGroupList : [];
    }

    get noGroups () {
        return !(this.userGroupRecords?.length > 0)
    }

    get noSelectedGroups () {
        return !(this.selectedRowList?.length > 0)
    }

    get disableApplyBtn () {
        return !(this.selectedRows?.length > 0);
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        if (pageRef) {
            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }
            this.clearSearchInputValue();
            this.init();
        }
    }

    connectedCallback () {
        this.baseUrl = window.location.origin;
    }

    renderedCallback () {
        loadStyle(this, contractLineItemPlanDetailResource)
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
        const listViewTable = this.template.querySelector(
            '.svmx-ta-list-view_table');
        if (listViewTable) {
            this._listViewTableHeight = listViewTable.offsetHeight;
        }
    }

    init () {

        this.totalRecordCount = 0;
        this.currentRecordCount = 0;
        this.attributeRecords = [];
        this.attributeRecordList = [];
        this.technicalAttributeRecords = [];
        this.technicalAttributeRecordList = [];
        this.displayRecords = [];
        this.apiInProgress = true;
        this.noRecordsFound = false;
        this.startIndex = 0;
        this.endIndex = PAGE_SIZE;
        this.fetchRecords();
    }

    fetchRecords () {
        let newData;
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
            this.attributeRecords = JSON.parse(JSON.stringify(result.data.technicalAttributeList));
            newData = this.populateListViewData(this.attributeRecords);
            this.attributeRecordList = newData;
            this.error = undefined;
            this.loadDisplayRecords(false);
            if (this.totalRecordCount > this.attributeRecordList.length) {
                this.loadNextSetOfAttributes(this.totalRecordCount);
            }

        }).catch(error => {
            this.attributeRecords = [];
            this.attributeRecordList = [];
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.VIEW);
                break;
            case 'edit':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.openEditModal(row.id,PAGE_ACTION_TYPES.CLONE);
                break;
            case 'whereUsed':
                this.checkWhereUsed(row);
                break;
            case 'addToUserGroup':
                this.openUserGroupModal(row);
                break;
            case 'delete':
                this.deleteRow(row);
                break;

            // comment below for eslint which errors when no default case exists.
            // No Default
        }
    }

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');

        if (input) {
            input.value = '';
        }
        this.searchKey='';
    }

    handleRefresh () {
        this.init();
    }

    handleDeleteAttribute (event) {
        const attributeRecord = event.detail.value;
        if (attributeRecord) {
            this.viewRecord = attributeRecord;
            this.fromViewModal = true;
            this.deleteRow(attributeRecord);
        }
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

    handleSearchKeyChange (event) {
        const searchValue = event.target.value.trim();
        this.userGroupSearchText = searchValue;

        if ((this.userGroupSearchText && this.userGroupSearchText.length > 2) ||
            this.userGroupSearchText.length === 0) {
            window.clearTimeout(this.delayTimeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                try {
                    this._selectedRowIds = deepCopy(this.selectedRowIds);
                    this._selectedRows = deepCopy(this.selectedRows);
                    this.fetchAllUserGroups();
                } catch (e) {
                    this.error = parseErrorMessage(e);
                }
            }, DELAY);
        }
    }

    handleShowSelectedItems () {
        this.selectedRowList = deepCopy(this.selectedRows);
        this.showSelectedItems = true;
    }

    handleHideSelectedItems () {
        this.selectedRowList = [];
        this.showSelectedItems = false;
    }

    getSelectedRowColumns () {
        return [
            {
                label: this.i18n.userGroupName,
                hideDefaultActions: true,
                fieldName: 'name',
                wrapText: false,
                type: 'xTextarea',
                typeAttributes: {
                    label: {
                        fieldName: 'name'
                    },
                    disabled: true
                }
            },
            {
                label: this.i18n.labelActive,
                fieldName: 'active',
                hideDefaultActions: true,
                wrapText: false,
                type: 'xCheckbox',
                typeAttributes: {
                    disabled: true
                },
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                type: 'xTextarea',
                hideDefaultActions: true,
                wrapText: false,
                typeAttributes: {
                    label: {
                        fieldName: 'description'
                    },
                    disabled: true
                }
            }
        ];
    }

    getColumns () {
        return [
            {
                label: this.i18n.attributeName,
                type: 'button',
                hideDefaultActions: true,
                fieldName: 'name',
                sortable: true,
                typeAttributes: {
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: 'nameToolTip' },
                    name: 'view',
                    variant: 'base'
                },
                cellAttributes: {
                    alignment: 'left',
                    class: { fieldName: 'nameClass' },
                }
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                hideDefaultActions: true,
                wrapText: false
            },
            {
                label: this.i18n.type,
                fieldName: 'dataType',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: this.i18n.lastModified,
                fieldName: 'lastModifiedDate',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'date',
                typeAttributes: {
                    timeZone: TIMEZONE,
                    month: '2-digit',
                    day: '2-digit',
                    year: 'numeric',
                    hour: 'numeric',
                    minute: 'numeric'
                }
            },
            {
                label: this.i18n.lastModifiedBy,
                fieldName: 'lastModifiedBy',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                type: 'action',
                fixedWidth: 60,
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                },
            }
        ];
    }

    loadNextSetOfAttributes (totalCount) {
        let newData;
        const reqObject ={
            limitCount: 45000,
            searchTerm: this.searchKey,
            sortField: this.sortField,
            sortOrder: this.sortOrder,
            queryOffset: 1000,
        };
        return getAllTechnicalAttributes({
            requestJson: JSON.stringify(reqObject)
        }).then(result => {
            if (!verifyApiResponse(result)) {
                this.error = result.message;
                return;
            }
            const count = result.data.totalRecordCount;
            if (count === 0 || this.totalRecordCount !== count  ||
                totalCount !== count || result.data.technicalAttributeList?.length === 0 ) {
                return;
            }
            this.totalRecordCount = count;
            this.technicalAttributeRecords = JSON.parse(
                JSON.stringify(result.data.technicalAttributeList));
            newData= this.populateListViewData(this.technicalAttributeRecords);
            this.technicalAttributeRecordList = newData;
            if (this.attributeRecordList?.length > 0 ) {
                this.attributeRecordList = this.attributeRecordList.concat(
                    this.technicalAttributeRecordList );
            }
            this.error = undefined;
        }).catch(error => {
            this.technicalAttributeRecords = [];
            this.technicalAttributeRecordList = [];
            this.error = parseErrorMessage(error);
        });
    }

    handleLoadMore (event) {
        if (this.totalRecordCount === this.currentRecordCount) {
            return;
        }

        const { target } = event;
        //Display a spinner to signal that data is being loaded   
        if (this.totalRecordCount > this.currentRecordCount) {

            this.startIndex = this.startIndex + PAGE_SIZE;
            this.endIndex = this.endIndex + PAGE_SIZE;
            target.isLoading = true;
            window.clearTimeout(this.delayTimeout);

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                try {
                    this.loadDisplayRecords(true);
                    target.isLoading = false;
                } catch (e) {
                    this.error = parseErrorMessage(e);
                }
            }, 100);
        }
    }

    loadDisplayRecords (isLoadMore) {
        const newData = this.attributeRecordList.slice(this.startIndex,this.endIndex);
        this.currentRecordCount = isLoadMore ?
            (this.currentRecordCount + newData?.length) : newData?.length;

        this.displayRecords = this.displayRecords.concat(newData );
    }

    populateListViewData (newData) {
        let listViewData =[];
        newData.forEach(row=>{

            row.actions = ROW_ACTIONS;
            row.nameToolTip = row.description ? `${row.name}\n${row.description}` : row.name;
            row.nameClass = row.name ? 'svmx-attribute_btn slds-truncate' : '';
            listViewData =[...listViewData, { ...row }]
        });
        return listViewData;
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if (this.sortBy === "dataType") {
            this.sortField ='SVMXA360__DataType__c';
        } else if (this.sortBy === "lastModifiedDate") {
            this.sortField ='LastModifiedDate';
        } else if (this.sortBy === "lastModifiedBy") {
            this.sortField ='LastModifiedBy.Name';
        } else {
            this.sortField = 'Name';
        }
        this.sortOrder = this.sortDirection;
        this.init();
    }

    handleSearchCommit (event) {
        const searchValue = event.target.value.trim();
        this.searchKey =searchValue;
        if ((this.searchKey && this.searchKey.length > 2) || this.searchKey.length === 0) {
            window.clearTimeout(this.delayTimeout);

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                try {
                    this.init();

                } catch (e) {
                    this.error = parseErrorMessage(e);
                }
            }, DELAY);
        }
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    handleApply () {
        const userGroupsTA = [];
        this.selectedRows.forEach(row=>{
            const userGroupAttribute ={};
            const userGroupInfo = {};
            userGroupInfo.id =  row.id;
            userGroupAttribute.technicalAttributeId = this.attributeRecordDetail?.id;
            userGroupAttribute.userGroup = userGroupInfo;
            userGroupsTA.push(userGroupAttribute);
        });
        this.apiInProgress = true;
        saveUserGroupTechnicalAttribute({ requestJson: JSON.stringify(userGroupsTA) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.showToast('Success', this.i18n.success,
                    this.i18n.userGroupTAAddedMsg, 'success', 'dismissible');
                this.handleCancelUserGroupModal();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    openUserGroupModal (row) {
        this.attributeRecordDetail = JSON.parse(JSON.stringify(row));
        this.fetchAllUserGroups ();
    }

    handleCancelUserGroupModal () {
        this.showSelectedItems = false;
        this.userGroupModalOpen = false;
        this.userGroupSearchText = '';

        this.selectedRows = [];
        this._selectedRowIds = [];
        this._selectedRows = [];
        this.selectedRowList = [];
        this.selectedRowIds = [];
        this.userGroupList = [];
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
        this.attributeReference = {};
        if (this.fromViewModal) {
            this.openEditModal(this.viewRecord.id,PAGE_ACTION_TYPES.VIEW);
            this.viewRecord= null;
            this.fromViewModal = false;
        }
    }

    fetchAllUserGroups () {
        if (isUndefinedOrNull(this.attributeRecordDetail)) {
            return;
        }
        const attId = this.attributeRecordDetail?.id;
        this.apiInProgress = true;
        this.userGroupList = [];
        this.userGroupModalOpen = true;
        getAllUserGroups({ attributeId: attId, searchTerm: this.userGroupSearchText })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.userGroupList = JSON.parse(JSON.stringify(result.data));

                this.error = undefined;
                if ( this._selectedRowIds &&
                    this._selectedRows && this._selectedRowIds.length > 0 ) {
                    this.selectedRows = deepCopy(this._selectedRows);
                    this.selectedRowIds = deepCopy(this._selectedRowIds);
                    this.populateUserGroupList();
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.userGroupList = [];
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    populateUserGroupList () {

        if ( this.userGroupList?.length > 0 && this.userGroupSearchText?.length !== 0 ) {
            this.selectedRows.forEach(row =>{
                const indexVal = this.getSelectedIndex( row.id, this.userGroupList );
                if ( indexVal > -1 ) {
                    this.userGroupList.splice(indexVal, 1);
                }
            })
        }

        if ( this.userGroupSearchText.length === 0 ) {
            this._selectedRowIds = [];
            this._selectedRows = [];
        }
    }

    getSelectedIndex (inputVal,itemList) {
        return itemList.findIndex(
            itemRec => itemRec.id === inputVal
        );
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

    checkWhereUsed (row) {
        this.attributeReference = {};
        this.apiInProgress = true;
        getWhereUsedDetails({ attributeId: row.id })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.attributeReference = JSON.parse(JSON.stringify(result.data));
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.whereUsedModalTitle = row.name;
                this.apiInProgress = false;
                this.whereUsedModalOpen = true;
            });
    }

    handlewhereUsedCancel () {
        this.whereUsedModalOpen = false;
        this.attributeReference = {};
    }

    handleDelete () {

        this.deleteModalDialogOpen = false;
        this.attributeReference = {};

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        let recordToDelete = {};

        deleteCheckOnRelatedTA({ attributeId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.attributeReference = result.data;
                if (this.attributeReference?.relatedAssetTechnicalAttributes?.length > 0 ||
                    this.attributeReference?.relatedTemplates?.length > 0) {
                    this.deleteModalDialogOpen = true;
                    recordToDelete = JSON.parse(JSON.stringify(this.pendingDeleteRecord))
                    return;
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.name);
                this.handleRefresh();
                this.clearSearchInputValue();

            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
                this.pendingDeleteRecord = recordToDelete;
            });
    }

    handleDeleteConfirmModal () {

        this.deleteModalDialogOpen = false;
        this.attributeReference = {};
        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        deleteTechnicalAttribute({ attributeId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.name);
                this.handleRefresh();
                this.clearSearchInputValue();

            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
                this.pendingDeleteRecord = undefined;
            });
    }

    handleNewRecord () {
        this.template.querySelector('c-technical-attribute-detail').handleNewAttribute();
    }

    openEditModal (currentRecordId,actionName) {
        this.template.querySelector(
            'c-technical-attribute-detail').handleEditAttribute(currentRecordId,actionName);
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `Technical Attribute "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}