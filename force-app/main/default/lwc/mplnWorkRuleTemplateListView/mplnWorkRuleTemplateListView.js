import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { createMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import APPLICABLE_PRODUCT_OBJ from '@salesforce/schema/ApplicableProduct__c';
import MAIN_WORK_RULE_OBJECT from '@salesforce/schema/MaintenanceWorkRuleTemplate__c';
import WORK_RULE_TYPE_FIELD from '@salesforce/schema/MaintenanceWorkRuleTemplate__c.Type__c';
import TEMPLATE_FIELD from '@salesforce/schema/ApplicableProduct__c.MaintenancePlanTemplateId__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {
    parseErrorMessage,
    verifyApiResponse,
    ROW_ACTION_TYPES
} from 'c/utils';
import getRecordTypeDetails
    from '@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getRecordTypeDetails';
import getAllMaintenanceWorkRuleTemplates
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getAllMaintenanceWorkRuleTemplates';
import getAllApplicableProducts
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.getAllApplicableProducts';
import deleteMaintenanceWorkRuleTemplate
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.deleteMaintenanceWorkRuleTemplate';
import saveMaintenanceWorkRuleTemplate
    from '@salesforce/apex/MPLN_MaintenancePlanTemplate_LS.saveMaintenanceWorkRuleTemplate';
import labelProductInApplicableProduct from '@salesforce/label/c.Label_ProductInApplicableProduct';
import labelProductFamily from '@salesforce/label/c.Label_ProductFamily';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelNext from '@salesforce/label/c.Button_Next';
import labelBack from '@salesforce/label/c.Button_Back';
import labelSelectProductFamily from '@salesforce/label/c.Label_SelectProductFamily';
import labelWorkType from '@salesforce/label/c.Label_WorkType';
import labelSave from '@salesforce/label/c.Button_Save';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelDuplicate from '@salesforce/label/c.Label_Duplicate';
import labelDuplicateError from '@salesforce/label/c.Label_DuplicateError';
import labelUpdateMessage from '@salesforce/label/c.Label_UpdateMessage';
import labelCreatedMessage from '@salesforce/label/c.Label_CreatedMessage';
import labelApplicableProduct from '@salesforce/label/c.Label_ApplicableProduct';
import labelNew from '@salesforce/label/c.Button_New';
import labelWorkRuleTemplateTitle from '@salesforce/label/c.Label_WorkRuleTemplateTitle';
import labelSortOrder from '@salesforce/label/c.Label_SortOrder';
import labelRecurrencePattern from '@salesforce/label/c.Label_RecurrencePattern';
import labelMaintenancePlanTemplate from '@salesforce/label/c.Label_MaintenancePlanTemplate';
import labelSelectApplicableProduct from '@salesforce/label/c.Label_SelectApplicableProduct';
import labelApplicableProductName from '@salesforce/label/c.Label_ApplicableProductName';
import labelQuickFind from '@salesforce/label/c.Label_QuickFind';
import labelWorkRuleTemplate from '@salesforce/label/c.Label_NewWorkRuleTemplate';
import labelDelete from '@salesforce/label/c.Button_Delete';
import labelSaveNew from '@salesforce/label/c.Button_SaveAndNew';
import labelTemplate from '@salesforce/label/c.Label_Template';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelEditWorkRuleTemplate from '@salesforce/label/c.Label_EditWorkRuleTemplate';
import labelChooseRow from '@salesforce/label/c.Placeholder_Choose_a_row_to_select';
import labelSearchTitle from '@salesforce/label/c.Label_SearchTitleWRTemplate';
import labelPlaceholderTitle from '@salesforce/label/c.Label_SearchPlaceholder';
import labelDeleteConfirmMessage from '@salesforce/label/c.Label_DeleteMessageWorkRuleTemplate';
import labelDeleteWRTTitle from '@salesforce/label/c.Label_DeleteWorkRuleTemplate';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelNoApplicableProducts from '@salesforce/label/c.Label_NoApplicableProducts';
import labelInvalidRecurrencePattern from '@salesforce/label/c.Error_Invalid_Recurrence_Pattern';
import labelWorkRuleUpdated from '@salesforce/label/c.Label_WorkRuleTemplateUpdated';
import labelWorkRuleCreated from '@salesforce/label/c.Label_WorkRuleTemplateCreated';
import labelWorkRuleDeleted from '@salesforce/label/c.Label_WorkRuleTemplateDeleted';
import labelSuccess from '@salesforce/label/c.Label_APSuccess';
import labelTextWorkRuleTemplate from '@salesforce/label/c.Label_WorkRuleTemplate';
import labelMaintenanceWorkRuleType from '@salesforce/label/c.Label_MaintenanceWorkRuleType';
import labelRecordsetFilterCriteria from '@salesforce/label/c.Label_RecordsetFilterCriteria';
import refreshListViewChannel from "@salesforce/messageChannel/RefreshListView__c";

const i18n = {
    cancel: labelCancel,
    next: labelNext,
    back: labelBack,
    product: labelProductInApplicableProduct,
    productFamily: labelProductFamily,
    selectProductFamily: labelSelectProductFamily,
    workType: labelWorkType,
    save: labelSave,
    loading: labelLoading,
    duplicate: labelDuplicate,
    duplicateError: labelDuplicateError,
    updatedMsg: labelUpdateMessage,
    createdMsg: labelCreatedMessage,
    placeholder: labelQuickFind,
    labelApplicableProduct,
    labelNew,
    labelWorkRuleTemplateTitle,
    labelSortOrder,
    labelRecurrencePattern,
    labelMaintenancePlanTemplate,
    labelSelectApplicableProduct,
    labelApplicableProductName,
    labelWorkRuleTemplate,
    labelDelete,
    labelSaveNew,
    labelTemplate,
    labelEditMenuItem,
    labelEditWorkRuleTemplate,
    labelChooseRow,
    labelSearchTitle,
    labelDeleteConfirmMessage,
    labelDeleteWRTTitle,
    labelConfirm,
    labelNoApplicableProducts,
    labelInvalidRecurrencePattern,
    labelPlaceholderTitle,
    labelSuccess,
    labelWorkRuleDeleted,
    labelWorkRuleCreated,
    labelWorkRuleUpdated,
    labelTextWorkRuleTemplate,
    workRuleType: labelMaintenanceWorkRuleType,
    recordsetFilterCriteria: labelRecordsetFilterCriteria
};

const RowActions = [
    { label: i18n.labelDelete, name: ROW_ACTION_TYPES.DELETE },
    { label: i18n.labelEditMenuItem, name: ROW_ACTION_TYPES.EDIT },
];

const TEMPLATE_COLUMNS = [
    {   label: i18n.labelWorkRuleTemplateTitle,
        fieldName: 'titleUrl',
        type: 'url',
        typeAttributes: {
            linkify: true,
            label: {
                fieldName: 'title'
            },
            tooltip: {
                fieldName: 'title'
            },
            target: '_blank'
        },
        hideDefaultActions: true,
        wrapText: false
    },
    {
        label: i18n.workRuleType,
        fieldName: 'type',
        type: 'text',
        hideDefaultActions: true,
        typeAttributes: {
            label: {
                fieldName: 'type'
            }
        }
    },
    { label: i18n.labelSortOrder,
        fieldName: 'sortOrder',
        type: 'text',
        typeAttributes: { linkify: true },
        hideDefaultActions: true, },
    {   label: i18n.workType,
        fieldName: 'workTypeUrl',
        type: 'url',
        typeAttributes: {
            linkify: true,
            label: {
                fieldName: 'workType'
            },
            tooltip: {
                fieldName: 'workType'
            },
            target: '_blank'
        },
        hideDefaultActions: true,
        wrapText: false
    },
    {
        label: i18n.labelRecurrencePattern,
        fieldName: 'recurrencePattern',
        type: 'text',
        hideDefaultActions: true,
        typeAttributes: {
            label: {
                fieldName: 'recurrencePattern'
            }
        }
    },
    {
        type: 'action',
        typeAttributes: { rowActions: RowActions },
    },
];

const APPLICABLE_PRODUCT_COLUMNS = [
    {   label: i18n.labelWorkRuleTemplateTitle,
        fieldName: 'titleUrl',
        type: 'url',
        typeAttributes: {
            linkify: true,
            label: {
                fieldName: 'title'
            },
            tooltip: {
                fieldName: 'title'
            },
            target: '_blank'
        },
        hideDefaultActions: true,
        wrapText: false
    },
    {
        label: i18n.workRuleType,
        fieldName: 'type',
        type: 'text',
        hideDefaultActions: true,
        typeAttributes: {
            label: {
                fieldName: 'type'
            }
        }
    },
    {   label: i18n.labelApplicableProduct,
        fieldName: 'productUrl',
        type: 'url',
        typeAttributes: {
            linkify: true,
            label: {
                fieldName: 'productName'
            },
            tooltip: {
                fieldName: 'productName'
            },
            target: '_blank'
        },
        hideDefaultActions: true,
        wrapText: false
    },
    {
        label: i18n.labelSortOrder,
        fieldName: 'sortOrder',
        type: 'text',
        hideDefaultActions: true,
    },
    {   label: i18n.workType,
        fieldName: 'workTypeUrl',
        type: 'url',
        typeAttributes: {
            linkify: true,
            label: {
                fieldName: 'workType'
            },
            tooltip: {
                fieldName: 'workType'
            },
            target: '_blank'
        },
        hideDefaultActions: true,
        wrapText: false
    },
    {
        label: i18n.labelRecurrencePattern,
        fieldName: 'recurrencePattern',
        type: 'text',
        hideDefaultActions: true,
        typeAttributes: {
            label: {
                fieldName: 'recurrencePattern'
            }
        }
    },
    {   label: i18n.recordsetFilterCriteria,
        fieldName: 'recordsetFilterCriteriaUrl',
        type: 'url',
        typeAttributes: {
            linkify: true,
            label: {
                fieldName: 'recordsetFilterCriteriaName'
            },
            tooltip: {
                fieldName: 'recordsetFilterCriteriaName'
            },
            target: '_blank'
        },
        hideDefaultActions: true,
        wrapText: false
    },
    {
        type: 'action',
        typeAttributes: { rowActions: RowActions },
    },
];

const APPLICABLE_COLUMNS = [
    { label: i18n.labelApplicableProductName,
        fieldName: 'productName',
        type: 'text',
        typeAttributes: { linkify: true },
        hideDefaultActions: true,
        wrapText: false },
    { label: i18n.product,
        fieldName: 'product',
        type: 'text',
        typeAttributes: { linkify: true },
        hideDefaultActions: true, },
    { label: i18n.productFamily, fieldName: 'productFamily', hideDefaultActions: true, },
    { label: i18n.workType, fieldName: 'workType', hideDefaultActions: true, },

];

const TEMPLATE_TYPE = {
    APPLICABLE_PRODUCT: 'Applicable Product',
    MAINTENANCE_PLAN_TEMPLATE: 'Maintenance Plan Template'
};

const MAINTENANCE_PLAN_TEMPLATE = 'SVMXA360__MaintenancePlanTemplate__c';
const fields = [TEMPLATE_FIELD];
const nameSchema = "SVMXA360__MaintenancePlanTemplate__c.Name";

export default class MplnWorkRuleTemplateListView extends LightningElement {

    @api recordId;

    @track templateTable = [];
    @track applicableProductTable = [];
    @track isServerCallInProgress = false;
    @track editConfigData = {};
    @track applicableProductListData = [];

    error = null;

    isA360RecordType;
    openA360NewWRTemplate = false;
    selectedProduct;
    rawData = [];
    baseUrl = '';
    selectApplicableProductOpen = false;
    openNewWRTemplate = false;
    templateColumns = TEMPLATE_COLUMNS;
    applicableProductColumns = APPLICABLE_PRODUCT_COLUMNS;
    applicableColumns = APPLICABLE_COLUMNS;
    selectedProductId = null;
    selectedProductName = '';
    maintenancePlanTemplateName = ''
    maintenancePlanTemplateRecord ;
    searchKeyWord = '';
    parentTemplateId = null;
    isNewWorkRule = false;
    workRuleTypeDisplayValues = {};
    applicableProductInfo = {};

    appProductContainerClassNames = ["container", "applicableProductContainer"];

    @track
    deleteWRTConfig = {
        showModal: false,
        deleteId: null,
        deleteName: '',
    };

    /** Message channel context */
    context = createMessageContext();


    @wire(getObjectInfo, { objectApiName: APPLICABLE_PRODUCT_OBJ })
    applicableProductObjectInfo;

    @wire(getRecord, { recordId: '$recordId', fields })
    getParentTemplateIdIfApplicableProductPage (response) {
        const { data } = response;
        if (this.isProductApplicableRecordPage) {
            this.parentTemplateId =
                getFieldValue(data, TEMPLATE_FIELD);
            this.getDataAndPopulateTables();
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [nameSchema]})
    getRecordName ({ data }) {
        if (data) {
            this.maintenancePlanTemplateName = data.fields.Name.value;
            this.maintenancePlanTemplateRecord = data;
        }
    }

    @wire(getObjectInfo, { objectApiName: MAIN_WORK_RULE_OBJECT })
    mWorkRuleObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$mWorkRuleObjectInfo.data.defaultRecordTypeId',
        fieldApiName: WORK_RULE_TYPE_FIELD
    })
    setWorkRuleTypeOptions ({ error, data }) {
        if (data) {
            data.values.forEach(element =>
                (this.workRuleTypeDisplayValues[element.value] = element.label));
        } else if (error) {
            this.error = parseErrorMessage(error);
        }
    }

    constructor () {
        super();
        this.baseUrl = window.location.origin;
    }

    get isProductSelectedNull () {
        return (!this.selectedProductId);
    }

    get workRuleTemplateTitle () {
        if (this.isNewWorkRule === true) {
            return i18n.labelWorkRuleTemplate;
        }
        return i18n.labelEditWorkRuleTemplate;
    }

    get isApplicableProductCountZero () {
        return (this.applicableProductListData.length === 0);
    }

    get appProductContainerCSSClasses () {
        const { isProductApplicableRecordPage } = this;
        if (isProductApplicableRecordPage) {
            this.appProductContainerClassNames.push("appRecordPageOnlyContainer");
        }
        return this.appProductContainerClassNames.join(" ");
    }

    renderedCallback () {
        //start:if recordtype is asset360,render asset summary screen else show workrule template 
        getRecordTypeDetails({ objectAPIName: MAINTENANCE_PLAN_TEMPLATE })
        .then(response=> {
            if (response.data) {
                const recordtypeInfo = response.data.filter( item =>
                    (item.id === this.maintenancePlanTemplateRecord.recordTypeInfo.recordTypeId))
                if (recordtypeInfo && recordtypeInfo.length > 0) {
                    this.isA360RecordType =
                    recordtypeInfo[0].developerName === 'Asset360' ? true : false;
                }
            }
        })
        //end
    }

    async connectedCallback () {

        if (!this.isProductApplicableRecordPage) {
            this.getDataAndPopulateTables();
        }
        this.subscribeToMessageChannel();
    }

    async getDataAndPopulateTables () {
        const { isProductApplicableRecordPage } = this;
        const { data: productList = []} = await this.getAllApplicableProductsList();
        await this.getAllWorkRuleTemplates();
        if (!isProductApplicableRecordPage ) {
            this.populateTemplateTable();
        }
        this.populateApplicableProductTable();
        this.applicableProductListData = productList.map(({
            id,
            name,
            productName,
            productId,
            productFamily,
            workTypeName,
            workTypeId,
        }) => ({
            id,
            productUrl: `${this.baseUrl}\\${id}`,
            productName: name,
            product: productName ? productName : '',
            productNameUrl: productId ? `${this.baseUrl}\\${productId}`: '',
            productFamily,
            workType: workTypeName,
            workTypeUrl: workTypeId ? `${this.baseUrl}\\${workTypeId}`: '',
            isSelected: false,
        }));
    }

    async getAllWorkRuleTemplates () {
        const {
            recordId,
            isProductApplicableRecordPage,
            parentTemplateId

        } = this;
        const response = await getAllMaintenanceWorkRuleTemplates({
            maintenancePlanTemplateId: (isProductApplicableRecordPage ?
                parentTemplateId : recordId) });
        const { data } = response;
        this.rawData = data;
    }

    async getAllApplicableProductsList () {
        const {
            recordId,
            isProductApplicableRecordPage,
            parentTemplateId

        } = this;
        const newData = await getAllApplicableProducts({
            maintenancePlanTemplateId: (isProductApplicableRecordPage ?
                parentTemplateId : recordId)
        });
        return newData;
    }

    populateTemplateTable () {
        const { rawData: data =[]} = this;
        this.templateTable =  data.filter(dataItem =>{
            return dataItem.templateType === TEMPLATE_TYPE.MAINTENANCE_PLAN_TEMPLATE;
        }).map(({
            id,
            name,
            sortOrder,
            recurrencePattern,
            workTypeName,
            workTypeId,
            type
        }) => ({
            id,
            title: name,
            titleUrl: `${this.baseUrl}\\${id}`,
            sortOrder,
            recurrencePattern,
            workTypeUrl: workTypeId ? `${this.baseUrl}\\${workTypeId}`: '',
            workType: workTypeId ? workTypeName: '',
            type: this.workRuleTypeDisplayValues[type] || type,
        })).sort(
            (itemA, itemB) => (parseFloat(itemA.sortOrder) - parseFloat(itemB.sortOrder)));
    }

    populateApplicableProductTable () {
        const { rawData: data = [], isProductApplicableRecordPage, recordId } = this;
        this.applicableProductTable =  data.filter(dataItem =>{
            return dataItem.templateType === TEMPLATE_TYPE.APPLICABLE_PRODUCT;
        }).map(({
            id,
            name,
            applicableProductName,
            applicableProductId,
            sortOrder,
            recurrencePattern,
            workTypeName,
            workTypeId,
            type,
            recordsetFilterCriteriaId,
            recordsetFilterCriteriaName
        }) => ({
            id,
            title: name,
            titleUrl: `${this.baseUrl}\\${id}`,
            productName: applicableProductName,
            productUrl: `${this.baseUrl}\\${applicableProductId}`,
            sortOrder,
            recurrencePattern,
            workType: workTypeId ? workTypeName: '',
            workTypeUrl: workTypeId ? `${this.baseUrl}\\${workTypeId}`: '',
            applicableProductId,
            type: this.workRuleTypeDisplayValues[type] || type,
            recordsetFilterCriteriaUrl: (recordsetFilterCriteriaId && recordsetFilterCriteriaName)
                ? `${this.baseUrl}\\${recordsetFilterCriteriaId}` : '',
            recordsetFilterCriteriaName
        })).sort(
            (itemA, itemB) => (parseFloat(itemA.sortOrder) - parseFloat(itemB.sortOrder)));
        if (isProductApplicableRecordPage) {
            this.applicableProductTable = this.applicableProductTable.filter(
                item => item.applicableProductId === recordId )
        }
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const { id } = event.detail.row;
        switch (actionName) {
            case ROW_ACTION_TYPES.DELETE:
                this.showDeleteModal({ id });
                break;
            case ROW_ACTION_TYPES.EDIT:
                this.editRow(id);
                break;
            default:
        }
    }

    get isProductApplicableRecordPage () {
        const { data: { keyPrefix = '' } = {}} = this.applicableProductObjectInfo;
        const keyLen = keyPrefix.length;
        const recordIdPrefix = (this.recordId || '').substring(0,keyLen);
        return (keyPrefix && recordIdPrefix && keyPrefix === recordIdPrefix);
    }

    get templateTableLabel () {
        return `${i18n.labelTemplate} (${this.templateTable.length})`;
    }

    get applicableProductTableLabel () {
        const { isProductApplicableRecordPage } = this;
        if ( isProductApplicableRecordPage ) {
            return `${i18n.labelTextWorkRuleTemplate} (${this.applicableProductTable.length})`;
        }
        return `${i18n.labelApplicableProduct} (${this.applicableProductTable.length})`;
    }

    get i18n () {
        return i18n;
    }

    async deleteRow (workRuleTemplateId) {
        this.isServerCallInProgress = true;
        const { rawData } = this;
        this.error = false;
        const { success: isDeleted } = await deleteMaintenanceWorkRuleTemplate({
            workRuleTemplateId
        });
        this.isServerCallInProgress = false;
        if (isDeleted) {
            const { name: wrtName ='' } = (
                rawData.filter(item => item.id === workRuleTemplateId)[0] || {});
            await this.getAllWorkRuleTemplates();
            this.populateTemplateTable();
            this.populateApplicableProductTable();

            const  toastMsg = `${i18n.labelWorkRuleDeleted}- ${wrtName}`;
            this.showToast({
                type: 'Success',
                title: i18n.labelSuccess,
                message: toastMsg,
                variant: 'success',
                mode: 'dismissible' });
        }
    }

    editRow ( workRuleTemplateId ) {
        const {
            rawData: data = [],
            applicableProductListData,
            isProductApplicableRecordPage,
        } = this;
        const rowData =  data.filter(item => item.id === workRuleTemplateId);
        this.isNewWorkRule = false;
        if (rowData.length > 0) {

            this.editConfigData = {
                isEdit: true,
                hasApplicableProduct: !!rowData[0].applicableProductId,
                applicableProductName: rowData[0].applicableProductName,
                sortOrder: rowData[0].sortOrder,
                workRuleTitle: rowData[0].name,
                workRuleId: workRuleTemplateId,
                workTypeId: rowData[0].workTypeId,
                recurrencePattern: rowData[0].recurrencePattern,
                workRuleType: rowData[0].type,
                recordsetFilterCriteriaId: rowData[0].recordsetFilterCriteriaName
                    ? rowData[0].recordsetFilterCriteriaId : null
            };
            this.selectedProductName = rowData[0].applicableProductName;
            this.selectedProductId = rowData[0].applicableProductId
            if (this.editConfigData.hasApplicableProduct && !isProductApplicableRecordPage) {
                this.selectApplicableProductOpen = true;
                this.applicableProductListData = applicableProductListData.map( item => {
                    const newItem = { ...item };
                    newItem.isSelected = (rowData[0].applicableProductId === item.id);
                    return newItem;
                });
            } else {
                this.openNewWRTemplate = true;
            }
        }
    }

    handleNewTemplateClick () {
        this.selectApplicableProductOpen = false;
        this.openNewWRTemplate = true;
        this.isNewWorkRule = true;
        this.error = false;
    }

    handleNewApplicableProductClick () {
        const { isProductApplicableRecordPage } = this;
        this.selectApplicableProductOpen = true;
        this.error = false;
        this.isNewWorkRule = true;

        if (isProductApplicableRecordPage) {
            this.selectApplicableProductOpen = false;
            this.selectedProductId = this.recordId;
            const selectedProduct =
            this.applicableProductListData.filter( item => {
                return item.id === this.selectedProductId;} );
            this.selectedProductName = selectedProduct[0].productName;
            this.openNewWRTemplate = true;
        }
    }

    handleNewCancelModal () {
        this.selectApplicableProductOpen = false;
        this.editConfigData = {};
        this.selectedProductName = '';
        this.selectedProductId = null;
        const { applicableProductListData } = this;
        this.applicableProductListData = applicableProductListData.map(item => {
            item.isSelected = false;
            return item;
        });
    }

    handleProductSelection (event) {
        const selectedProductId = event.target.id.split('-')[0];
        const { applicableProductListData } = this;
        this.selectedProductId = selectedProductId;
        const selectedProduct =
            this.applicableProductListData.filter( item => {
                return item.id === selectedProductId;} );
        this.selectedProductName = selectedProduct[0].productName;
        this.applicableProductListData = applicableProductListData.map(item => {
            if (item.id === selectedProductId) {
                this.selectedProduct = item;
                item.isSelected = true;
            } else {
                item.isSelected = false;
            }
            return item;
        });
	this.applicableProductInfo = { show: true,selectedProduct: this.selectedProduct }
    }

    handleNextOfNewAPModal () {
        if (this.isA360RecordType) {
            this.selectApplicableProductOpen = false;
            this.openA360NewWRTemplate = true;
        } else {
            this.selectApplicableProductOpen = false;
            this.openNewWRTemplate = true;
        }
    }

    handleNextOfNewAPModalCancel () {
        this.openNewWRTemplate = false;
        this.openA360NewWRTemplate = false;
        this.editConfigData = {};
        this.selectedProductName = '';
        this.selectedProductId = null;
        const { applicableProductListData } = this;
        this.applicableProductListData = applicableProductListData.map(item => {
            item.isSelected = false;
            return item;
        });
    }

    showDeleteModal ({ id }) {
        const { deleteWRTConfig } = this;
        deleteWRTConfig.showDeleteModal = true;
        deleteWRTConfig.deleteId = id;
    }

    cancelWRTDeleteModal () {
        const { deleteWRTConfig } = this;
        deleteWRTConfig.showDeleteModal = false;
        deleteWRTConfig.deleteId = null;
    }

    async handleWRTDeleteConfirm () {
        const { deleteWRTConfig } = this;
        this. isServerCallInProgress = true;
        deleteWRTConfig.showDeleteModal = false;
        await this.deleteRow(deleteWRTConfig.deleteId);
        deleteWRTConfig.id = null;
        this.isServerCallInProgress = false;
    }

    async onSaveWorkRuleTemplate () {
        this.isServerCallInProgress = true;
        const {
            parentTemplateId,
            isProductApplicableRecordPage,
            recordId,
            i18n: {
                labelInvalidRecurrencePattern: invalidPattern
            }} = this;
        const recurrenceModalNode = this.template.querySelector('c-mpln-work-rule-template-detail');
        const details = recurrenceModalNode.onSave();
        /** Error condition */
        if (details.error) {
            this.isServerCallInProgress = false;
            return;
        }

        const templateDetails = {
            "name": details.workRuleTitle,
            "maintenancePlanTemplateId": (!isProductApplicableRecordPage ? recordId
                : parentTemplateId) ,
            "maintenancePlanTemplateName": this.maintenancePlanTemplateName,
            "applicableProductId": this.selectedProductId,
            "applicableProductName": this.selectedProductName,
            "workTypeId": details.workTypeId,
            "workTypeName": details.workTypeName,
            "templateType": "WorkRuleTemplate",
            "recurrencePattern": details.recurrencePattern,
            "sortOrder": details.sortOrder,
            "type": details.workRuleType,
            "recordsetFilterCriteriaId": details.recordsetFilterCriteriaId
        };

        if (details.workRuleId) {
            templateDetails.id = details.workRuleId;
        }

        /** Case: No workType selected at the scheduling pop up */
        if (!templateDetails.workTypeId) {
            delete templateDetails.workTypeId;
            delete templateDetails.workTypeName;
        }

        /** verifying API response */
        try {

            const apiResponse = await saveMaintenanceWorkRuleTemplate(
                { requestJson: JSON.stringify([templateDetails]) });
            if (!verifyApiResponse(apiResponse)) {
                this.isServerCallInProgress = false;
                if (apiResponse.message === invalidPattern) {
                    const errorMessage = invalidPattern;
                    recurrenceModalNode.recurrencePatternNotValid({ errorMessage });
                } else {
                    this.error = apiResponse.message;
                    this.openNewWRTemplate = false;
                }
                return;
            }
            this.openNewWRTemplate = false;
            let toastMsg = `${i18n.labelWorkRuleCreated}- ${details.workRuleTitle}`;
            if (details.workRuleId) {
                toastMsg = `${i18n.labelWorkRuleUpdated}- ${details.workRuleTitle}`;
            }
            this.showToast({
                type: 'Success',
                title: i18n.labelSuccess,
                message: toastMsg,
                variant: 'success',
                mode: 'dismissible' });

        } catch (error) {
            this.error = parseErrorMessage(error);
            this.isServerCallInProgress = false;
            this.openNewWRTemplate = false;
        }
        await this.getDataAndPopulateTables();
        this.editConfigData = {};
        this.selectedProductId = null;
        this.selectedProductName = '';
        this.isServerCallInProgress = false;
    }

    async handleTemplateTableSearch (event) {
        const searchKeyWord = event.target.value.trim().toLowerCase();
        await this.getAllWorkRuleTemplates();
        this.populateTemplateTable();
        const { templateTable } = this;

        const filteredData = templateTable.filter(dataItem => {
            const { title, workType } = dataItem;
            return (title  && title.toLowerCase().indexOf(searchKeyWord) !== -1
                || workType && workType.toLowerCase().indexOf(searchKeyWord) !== -1);
        });
        this.templateTable = filteredData;
    }

    handleTemplateSummaryTableSearch (event) {
        this.template.querySelector('c-mpln-asset-summary-list-view')
            .handleSearch(event);
    }

    async handleApplicableProductTableSearch (event) {
        const searchKeyWord = event.target.value.trim().toLowerCase();
        await this.getAllWorkRuleTemplates();
        this.populateApplicableProductTable();
        const { applicableProductTable } = this;

        const filteredData = applicableProductTable.filter(dataItem => {
            const { title, workType } = dataItem;
            return (title  && title.toLowerCase().indexOf(searchKeyWord) !== -1
               || workType && workType.toLowerCase().indexOf(searchKeyWord) !== -1);
        });
        this.applicableProductTable = filteredData;
    }

    /** message channel handle */

    subscribeToMessageChannel () {
        this.channel = subscribe(this.context, refreshListViewChannel, async function (event) {
            if (event != null && event.recordId === this.recordId) {
                this.isServerCallInProgress = true;
                await this.getDataAndPopulateTables();
            }
            this.isServerCallInProgress = false;
        }.bind(this));
    }

    disconnectedCallback () {
        unsubscribe(this.channel);
    }

    /** show toast */
    showToast ({ type, title, message, variant, mode }) {
        const evt = new ShowToastEvent({
            type,
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(evt);
    }

    handleSaveWorkRuleInfo (event) {

      this.template.querySelector('c-mpln-asset-summary-list-view')
                        .handleSaveWorkRuleFromTemplate(event,this.selectedProduct);
    }
    closeWorkRuleModal (event) {

        const closeModal = event.detail.value;
        if (!closeModal) {
            this.openA360NewWRTemplate = true;
        } else {
            this.openA360NewWRTemplate = false;
        }
    }

}