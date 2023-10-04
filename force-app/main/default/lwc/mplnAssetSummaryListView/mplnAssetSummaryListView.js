import { LightningElement, track, api } from 'lwc';
import { parseErrorMessage,
        isUndefinedOrNull } from 'c/utils';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getWorkRulesFromMaintenanceTemplate from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getWorkRulesFromMaintenanceTemplate';
import deleteWorkRules from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.deleteWorkRules';

import getWorkRulesFromTemplate from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getWorkRulesFromTemplate';
import saveWorkRuleTemplate from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.saveWorkRuleTemplate';
import getWorkRulesFromPlan from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getWorkRulesFromPlan';

import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelItemRowCount from '@salesforce/label/c.Label_ItemRowCount';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelRemoveMenuItem from '@salesforce/label/c.Menu_Remove';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelSearch from '@salesforce/label/c.Button_Search';
import labelItemSelected from '@salesforce/label/c.Label_ItemSelected';
import labelItemsSelected from '@salesforce/label/c.Label_ItemsSelected';
import labelManageMaintenanceAssets from '@salesforce/label/c.Label_ManageMaintenanceAssets';
import placeholderMaintenanceAssets from '@salesforce/label/c.Placeholder_SearchMaintenanceAssets';
import labelManageWorkRule from '@salesforce/label/c.Label_ManageWorkRule';
import labelRemoveMaintenanceAsset from '@salesforce/label/c.Label_RemoveMaintenanceAsset';
import messageRemoveConfirm from '@salesforce/label/c.Message_RemoveConfirm';
import labelAddMaintenanceAssets from '@salesforce/label/c.Label_AddMaintenanceAssets';
import placeholderSearchAssets from '@salesforce/label/c.Placeholder_SearchAssets';
import labelActions from '@salesforce/label/c.Button_Actions';
import labelAddAssets from '@salesforce/label/c.MenuItem_AddAssets';
import labelRemoveAssets from '@salesforce/label/c.MenuItem_RemoveAssets';
import labelPrevious from '@salesforce/label/c.Button_Previous';
import labelCreateMaintenancePlan from '@salesforce/label/c.Label_CreateMaintenancePlan';
import labelPlaceholderSearch from '@salesforce/label/c.Placeholder_Search';
import labelPleaseReviewErrorMessage from '@salesforce/label/c.Label_PleaseReviewErrorMessage';
import labelError from '@salesforce/label/c.Label_Error';
import labelErrors from '@salesforce/label/c.Label_Errors';
import labelResolve1Error from '@salesforce/label/c.Label_Resolve1Error';
import labelDateOfFirstWoError from '@salesforce/label/c.Label_DateOfFirstWoError';
import labelDays from '@salesforce/label/c.Label_Days';
import labelOnThe from '@salesforce/label/c.Label_OnThe';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelYes from '@salesforce/label/c.Lbl_Yes';
import labelNo from '@salesforce/label/c.Lbl_No';
import labelRecordsDeletedSuccessfully
    from '@salesforce/label/c.Message_RecordsDeletedSuccessfully';
import labelRecordsSaveSuccessfully from '@salesforce/label/c.Message_RecordsSaveSuccessfully';
import labelPlaceholderTitle from '@salesforce/label/c.Label_SearchPlaceholder';
import labelSortOrderCannotBeDuplicate from '@salesforce/label/c.Label_SortorderCannotBeDuplicate';

import labelWorkRuleTitle from '@salesforce/label/c.Label_WorkRuleTitle';
import labelWorkType from '@salesforce/label/c.Label_WorkType';
import labelSortOrder from '@salesforce/label/c.Label_SortOrder';
import labelAdvancedExpression from '@salesforce/label/c.Label_AdvancedExpression';
import labelAddWorkToAsset from '@salesforce/label/c.Label_AddWorkRuleToAsset';
import labelDeleteWorkRules from '@salesforce/label/c.Label_DeleteWorkRules';
import labelEdit from '@salesforce/label/c.Menu_Edit';
import labelDelete from '@salesforce/label/c.Menu_Delete';
import labelConditionType from '@salesforce/label/c.Label_ConditionType';
import labelConditionDefinition from '@salesforce/label/c.Label_ConditionDefinition';
import labelMaintenanceAssets from '@salesforce/label/c.Label_MaintenanceAssets';
import labelWorkRules from '@salesforce/label/c.Label_WorkRules';
import labelOk from '@salesforce/label/c.Button_OK';
import labelSelectWorkRules from '@salesforce/label/c.Message_SelectWorkRules';
import labelTitleSelectWorkRule from '@salesforce/label/c.ModalTitle_SelectWorkRule';
import labelWhen from '@salesforce/label/c.Label_When';
import labelBasedOna from '@salesforce/label/c.Label_Basedona';
import labelThreshold from '@salesforce/label/c.Label_Threshold';
import labelOccurences from '@salesforce/label/c.Label_Occurences';
import labelEvery from '@salesforce/label/c.Label_Every';
import labelEndingAfter from '@salesforce/label/c.Label_EndingAfter';
import labelWithNoEndDate from '@salesforce/label/c.Label_WithNoEndDate';
import labelEndingOn from '@salesforce/label/c.Label_EndingOn';
import labelOnDay from '@salesforce/label/c.Label_OnDay';
import WEEKS from '@salesforce/label/c.Label_enumWEEKS';
import MONTHS from '@salesforce/label/c.Label_enumMONTHS';
import YEARS from '@salesforce/label/c.Label_enumYEARS';
import labelEveryDecrement from '@salesforce/label/c.Label_EveryDecrement';
import labelEverytime from '@salesforce/label/c.Label_Everytime';
import labelReaches from '@salesforce/label/c.Label_Reaches';
import labelEquals from '@salesforce/label/c.Label_Equals';
import labelGreaterThan from '@salesforce/label/c.Label_GreaterThan';
import labelLessThan from '@salesforce/label/c.Label_LessThan';

import Sunday from '@salesforce/label/c.Label_Sunday';
import Monday from '@salesforce/label/c.Label_Monday';
import Tuesday from '@salesforce/label/c.Label_Tuesday';
import Wednesday from '@salesforce/label/c.Label_Wednesday';
import Thursday from '@salesforce/label/c.Label_Thursday';
import Friday from '@salesforce/label/c.Label_Friday';
import Saturday from '@salesforce/label/c.Label_Saturday';
import January from '@salesforce/label/c.Label_January';
import February from '@salesforce/label/c.Label_February';
import March from '@salesforce/label/c.Label_March';
import April from '@salesforce/label/c.Label_April';
import May from '@salesforce/label/c.Label_May';
import June from '@salesforce/label/c.Label_June';
import July from '@salesforce/label/c.Label_July';
import August from '@salesforce/label/c.Label_August';
import September from '@salesforce/label/c.Label_September';
import October from '@salesforce/label/c.Label_October';
import November from '@salesforce/label/c.Label_November';
import December from '@salesforce/label/c.Label_December';
import Fourth from '@salesforce/label/c.Label_Fourth';
import First from '@salesforce/label/c.Label_First';
import Second from '@salesforce/label/c.Label_Second';
import Third from '@salesforce/label/c.Label_Third';
import Last from '@salesforce/label/c.Label_Last';
import labelIn from '@salesforce/label/c.Label_In';
import labelSave from '@salesforce/label/c.Btn_Save';

const i18n = {
    title: labelManageMaintenanceAssets,
    placeholder: placeholderMaintenanceAssets,
    items: labelItemsRowCount,
    item: labelItemRowCount,
    loading: labelLoading,
    noResults: labelNoResults,
    remove: labelRemoveMenuItem,
    removeMaintenanceAsset: labelRemoveMaintenanceAsset,
    removeConfirmMessage: messageRemoveConfirm,
    cancel: labelCancel,
    confirm: labelConfirm,
    addAssetTitle: labelAddMaintenanceAssets,
    placeholderForAssetSearch: placeholderSearchAssets,
    search: labelSearch,
    itemSelected: labelItemSelected,
    itemsSelected: labelItemsSelected,
    actions: labelActions,
    addAssets: labelAddAssets,
    removeAssets: labelRemoveAssets,
    previous: labelPrevious,
    createMaintenancePlan: labelCreateMaintenancePlan,
    placeholderSearch: labelPlaceholderSearch,
    pleaseReviewErrorMessage: labelPleaseReviewErrorMessage,
    error: labelError,
    errors: labelErrors,
    resolve1Error: labelResolve1Error,
    dateOfFirstWoError: labelDateOfFirstWoError,
    manageWorkRule: labelManageWorkRule,
    workRuleTitle: labelWorkRuleTitle,
    workType: labelWorkType,
    sortOrder: labelSortOrder,
    advancedExpression: labelAdvancedExpression,
    edit: labelEdit,
    delete: labelDelete,
    ok: labelOk,
    yes: labelYes,
    no: labelNo,
    placeholderTitle: labelPlaceholderTitle,
    save: labelSave
}
const FREQUENCY = 'Frequency';
const CRITERIA = 'Criteria';

const SETPOSITIONS = {
    '1': First,
    '2': Second,
    '3': Third,
    '4': Fourth,
    '-1': Last
}
const WEEK_OPTIONS = {
    'SU': Sunday,
    'MO': Monday,
    'TU': Tuesday,
    'WE': Wednesday,
    'TH': Thursday,
    'FR': Friday,
    'SA': Saturday
}
const MONTH_OPTIONS = {
    1: January,
    2: February,
    3: March,
    4: April,
    5: May,
    6: June,
    7: July,
    8: August,
    9: September,
    10: October,
    11: November,
    12: December,
}

export default class MplnAssetSummaryListView extends LightningElement {

    @api maintenanceAssetRecords = [];
    @api templateId;
    @api mode = 'CREATE'; // TEMPLATE, EDIT
    @track localMaintenanceAssetRecords =[];
    @track assetSummaryList =[];
    @api maintenanceAssetRequest;
    @track originalAssetSummaryList =[];
    @track defaultExpandedRows = [];
    @track selectedRows = [];
    @track error;
    @track apiInProgress = false;
    @api mplnRecord;
    isTemplate = false;
    selectedProduct;//selected product from applicable product

    workRuleToEdit= {};
    originalRecords = [];
    //variable to send data to database
    rowsTobeInsertUpdated = [];

    showAddWorkRuleModal=false;
    openConfirmationModal = false;
    openDeleteModal = false;
    rowTobeDeleted;
    searchkeyword;

    selectedAssetId;
    action = '';
    modalBody = '';
    modalTitle = '';
    saveTitle = i18n.createMaintenancePlan;

    get i18n () {
        return i18n;
    }
    //Maintenance Asset Count
    get assetCount () {

        let assetCount = 0;
        this.assetSummaryList.forEach(item=> {
            //if showAssetHeader is true then only count the asset else ignore for count
            if (item.showAssetHeader === true) {
                assetCount++;
            }
        })

        return assetCount +' '+labelMaintenanceAssets;
    }
    //Work Rule Count
    get workRulesCount () {

        let workRuleCount = 0 ;
        if (this.assetSummaryList) {
            this.assetSummaryList.forEach(item => {
                workRuleCount = workRuleCount + ( item.workRules ? item.workRules.length : 0);
            })
        }
        workRuleCount = workRuleCount +' ' + labelWorkRules;
        return workRuleCount;
    }

    connectedCallback () {
        switch (this.mode) {
            case 'CREATE':
                this.fetchMatchingWorkRulesFromTemplate();
                break;
            case 'EDIT':
                this.fetchWorkRulesFromPlan();
                break;
            case 'TEMPLATE':
                this.fetchWorkRulesFromTemplate();
                break;
            default:
                break;
        }
    }

    fetchWorkRulesFromTemplate () {
        this.isTemplate = true;
        this.assetSummaryList = [];
        this.apiInProgress = true;

        getWorkRulesFromMaintenanceTemplate({
            requestJson: JSON.stringify({ templateId: this.mplnRecord.id })
        })
        .then(result => {

            if (result.data) {
                const response = result.data;
                    response.forEach((item) => {
                        const assetRec ={};
                        assetRec.assetId = item.productId;
                        assetRec.assetName = item.productName;
                        assetRec.productId = assetRec.assetId;
                        assetRec.applicableProduct = item.applicableProduct;
                        const rowId = assetRec.assetId;
                        assetRec.showHeader = ( item.workRuleInformation.length > 0) ? true : false;
                        //show/hide asset accordion
                        assetRec.showAssetHeader =
                            this.isTemplate === true && item.workRuleInformation.length === 0 ?
                                                false : true;

                        this.formWorkRuleWrapper(item,rowId,assetRec);
                    });

                this.originalAssetSummaryList = [...this.assetSummaryList];
            }
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    fetchWorkRulesFromPlan () {
        this.apiInProgress = true;
        this.saveTitle = i18n.save;
        this.localMaintenanceAssetRecords = JSON.parse(
            JSON.stringify(this.maintenanceAssetRecords)
        );
        this.originalRecords = [...this.localMaintenanceAssetRecords];
        this.assetSummaryList = [];
        const maintenanceAssetIds = [];
        this.originalRecords.forEach(item=>{
            if (isUndefinedOrNull(item.id)) {
                const assetRec = {
                    assetId: item.assetId,
                    assetName: item.assetName,
                    productId: item.productId,
                };
                const rowId = assetRec.assetId;
                assetRec.showHeader =
                  item.workRuleInformation &&
                  item.workRuleInformation.length > 0
                    ? true
                    : false;
                this.formWorkRuleWrapper(item, rowId, assetRec);
            } else {
                maintenanceAssetIds.push(item.id);
            }
        });

        getWorkRulesFromPlan({ maintenanceAssetIds: maintenanceAssetIds })
        .then(result => {
            if (result.data) {
                const response = result.data;
                    response.forEach((item) => {
                        const assetRec = {};
                        assetRec.assetId = item.productId;
                        assetRec.assetName = item.productName;
                        assetRec.productId = item.productId;
                        const rowId = assetRec.assetId;
                        assetRec.showHeader = item.workRuleInformation.length > 0 ? true : false;
                        this.formWorkRuleWrapper(item, rowId, assetRec);
                    });

                this.originalAssetSummaryList = [...this.assetSummaryList];
            }
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    formWorkRuleWrapper (item,rowId,assetRec) {

            const workRules = [];
            let assetWorkRuleMenu = [];

            if ( item.workRuleInformation && item.workRuleInformation !== null ) {
                let index = 1;
                item.workRuleInformation.forEach( workRule=> {

                    assetWorkRuleMenu = [];
                    const tempWorkRule =
                    this.populateWorRuleInfo(workRule,rowId,index);
                    index++;
                    workRules.push(Object.assign({},tempWorkRule));

assetWorkRuleMenu.push({ label: labelAddWorkToAsset, value: 'add', id: rowId },
                { label: labelDeleteWorkRules, value: 'delete', id: rowId });

                })
            } else {
                assetWorkRuleMenu.push({ label: labelAddWorkToAsset, value: 'add', id: rowId },
                { label: labelDeleteWorkRules, value: 'delete', id: rowId });
            }
            assetRec.workRuleMenuItems = assetWorkRuleMenu;
            assetRec.workRules = workRules;
            // eslint-disable-next-line @lwc/lwc/no-api-reassignments
            this.assetSummaryList = [...this.assetSummaryList,assetRec];
    }

    handlePrevious () {

        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    //WorkRule Columns
    get columns () {

        return [
            {
            type: "text",
            hideDefaultActions: true,
            typeAttributes: {
            label: { fieldName: "workRuleTitle" },
            tooltip: { fieldName: "workRuleTitle" },
            target: { fieldName: "id" },
            showPopover: true,
            isInConsole: false
            },
            fieldName: "workRuleTitle",
            label: labelWorkRuleTitle,
            wrapText: false,
            initialWidth: 325
            },
            {
            type: "text",
            hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: "workType" },
                tooltip: { fieldName: "workType" },
                target: { fieldName: "id" } ,
                showPopover: true,
                isInConsole: false
            },
            fieldName: "workType",
            label: labelWorkType,
            wrapText: false,
            initialWidth: 325
            },
            {
            type: "number",
            hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: "sortOrder" },
                tooltip: { fieldName: "sortOrder" },
                target: { fieldName: "id" },
                showPopover: true,
                isInConsole: false
            },
            fieldName: "sortOrder",
            label: labelSortOrder,
            wrapText: false,
            cellAttributes: {
                alignment: 'left'
            },
            alignment: "left",
            initialWidth: 325
            },
            {
            type: "text",
            hideDefaultActions: true,
            typeAttributes: {
                label: { fieldName: "advancedExpression" },
                tooltip: { fieldName: "advancedExpression" },
                target: { fieldName: "id" },
                showPopover: true,
                isInConsole: false
            },
            fieldName: "advancedExpression",
            label: labelAdvancedExpression,
            wrapText: false,
            initialWidth: 325
            },
            {
                type: "action",
                alignment: "right",
                typeAttributes: {
                   rowActions: [
                      {
                         label: labelEdit,
                         name: "edit"
                      },
                      {
                         label: labelDelete,
                         name: "delete"
                      }
                   ],
                   menuAlignment: "auto"
                },
                initialWidth: 50
             }
        ];
    }

    //Condtion Types Columns
    get conditionTypeColumns () {
        return [
        {
            type: "text",
            hideDefaultActions: true,
            typeAttributes: {
            label: {
                fieldName: "conditionType"
            },
            tooltip: {
                fieldName: "conditionType"
            },
            target: {
                fieldName: "id"
            },
            showPopover: true,
            isInConsole: false
            },
            fieldName: "conditionType",
            label: labelConditionType,
            wrapText: false,
            initialWidth: 300
        },
        {
            type: "text",
            hideDefaultActions: true,
            typeAttributes: {
            label: {
                fieldName: "conditionDefination"
            },
            tooltip: {
                fieldName: "conditionDefination"
            },
            target: {
                fieldName: "id"
            },
            showPopover: true,
            isInConsole: false
            },
            fieldName: "conditionDefination",
            label: labelConditionDefinition,
            wrapText: false,
            initialWidth: 500
        }]
    }

    hideTableHeader = false;
    highlightedRows = [];
    //detail grid config for condition types
    get detailGridConfig () {
        let detailGridConfig = {};

            detailGridConfig = {
                keyField: "id",
                columns: this.conditionTypeColumns,
                hideTableHeader: false,
                hideCheckboxColumn: true,
                tableClass: !this.hideTableHeader
                    ? 'slds-table_bordered'
                    : '',
                expandedRows: [],
                highlightedRows: [],
                selectedRows: []
            }
        return detailGridConfig;
    }

    fetchMatchingWorkRulesFromTemplate () {
        this.apiInProgress = true;
        this.localMaintenanceAssetRecords = JSON.parse(
            JSON.stringify(this.maintenanceAssetRecords)
        );
        this.originalRecords = [...this.localMaintenanceAssetRecords];
        this.assetSummaryList = [];
        const productIdAssetMap = new Map();
        this.originalRecords.forEach(item=>{
            productIdAssetMap.set(item.productId,
                                { assetId: item.assetId,assetName: item.assetName });
        });

        getWorkRulesFromTemplate({ requestJson: JSON.stringify({ templateId: this.templateId,
                                    productIds: [...productIdAssetMap.keys()]}) })
        .then(result => {

            if (result.data) {
                const response = result.data;
                this.originalRecords.filter((row)=>{
                    return response.some((item) => {
                        if ( row.productId === item.productId ) {

                            const assetRec ={};
                            assetRec.assetId = row.assetId;
                            assetRec.assetName = row.assetName;
                            assetRec.productId = item.productId;
                            assetRec.workTypeId = row.workTypeId;
                            assetRec.showHeader = (item.workRuleInformation !=null &&
                                item.workRuleInformation.length > 0) ? true : false;
                            assetRec.showAssetHeader = true
                            this.formWorkRuleWrapper(item,assetRec.assetId,assetRec);

                        }
                        return '';
                    });
                });
                this.originalAssetSummaryList = [...this.assetSummaryList];
            }
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    populateWorRuleInfo (workRule,assetId,index) {

        workRule.expandByDefault = false;
        workRule.enableFetch = false;
        workRule.assetId = assetId;
        workRule.index = index;
        const conditionTypeData = [];
        if (workRule.detail) {
            workRule.detail.forEach(condition => {
                const conditionTypeInfo = {};
                conditionTypeInfo.id = condition.id;
                conditionTypeInfo.conditionType = condition.conditionType;
                conditionTypeInfo.sequence = condition.sequence;
                if (conditionTypeInfo.conditionType === FREQUENCY && condition.frequency) {

                    conditionTypeInfo.frequency =  condition.frequency;
                    conditionTypeInfo.conditionDefination =
                    this.formConditionDefination(condition.conditionType,condition.frequency);
                }
                else if (conditionTypeInfo.conditionType === CRITERIA && condition.criteria) {

                    conditionTypeInfo.criteria =  condition.criteria;
                    conditionTypeInfo.conditionDefination =
                    this.formConditionDefination(condition.conditionType,condition.criteria);
                } else {

                    conditionTypeInfo.recurrenceRule =  condition.recurrenceRule;
                    conditionTypeInfo.conditionDefination =
                    this.formConditionDefination(condition.conditionType,condition.recurrenceRule);
                }
                conditionTypeInfo.expandByDefault = false;
                conditionTypeInfo.enableFetch =false;
                conditionTypeInfo.expandedRows = [workRule.workRuleTitle];
                conditionTypeData.push(conditionTypeInfo);
            });
        workRule.detail = conditionTypeData;
        }
        workRule.id = workRule.workRuleTitle;
        return workRule;
    }

    formConditionDefination (conditionType,condition) {

        let conditionDefination = '';
        if ( conditionType === FREQUENCY ||
            conditionType === CRITERIA ) {

                condition.operator = isUndefinedOrNull(condition.operator) ? '' :
                                                                    condition.operator;
                condition.attributeValue = isUndefinedOrNull(condition.attributeValue)
                                            ? '' : condition.attributeValue;
                condition.attributeName = isUndefinedOrNull(condition.attributeName)
                                            ? '' : condition.attributeName;
                condition.threshold = isUndefinedOrNull(condition.threshold) ? 0 :
                                                                condition.threshold;

                if (conditionType === FREQUENCY) {
                /********************************************
                When Operator/Operand is “Every”:
                Every time <attribute> reaches <attribute value>, based on  a <threshold value> % 
                threshold.
                When Operator/Operand is “Every Decrement”
                Every time <attribute> reaches <attribute value>, based on a <threshold value> % 
                threshold
                ***********************************************/
                    if (condition.operator === labelEvery ||
                                        condition.operator === labelEveryDecrement) {
                        conditionDefination = labelEverytime +' ' + condition.attributeName
                                                +' '+ labelReaches +' '+ condition.attributeValue
                                                +' '+labelBasedOna +' ' +condition.threshold
                                                +'% '+labelThreshold;
                    } else {
                        conditionDefination = this.formEqualsExpression(condition);
                    }
                }
                else if (conditionType === CRITERIA) {

                    conditionDefination = this.formEqualsExpression(condition);
                }
        } else {
            //Every <Frequency + Recurrence period> on <date OR day operator + 
            //day of week field> ending <Never OR “After” + 
            //After Occurences Value + Reccurence Period OR “After” + Date>

            if (condition) {
                const temp = condition.split(';');
				const conditionObj = {};
				for (let j = 0 ; j < temp.length ; j++) {
					const tempStr = temp[j].split('=');
					let i =0;
					while (i < tempStr.length) {
                        conditionObj[tempStr[i]] = tempStr[i+1];
                        i +=2;
					}
                }
                const conditionInfo = conditionObj;
				switch (conditionInfo.FREQ) {
                    case 'DAILY' :
                        conditionDefination = this.formDailyExpression(conditionInfo,
                                                conditionDefination);
                        return conditionDefination;
                    case 'WEEKLY' :
                    conditionDefination = this.formWeeklyExpression(conditionInfo,
                                            conditionDefination);
                    return conditionDefination;
                    case 'MONTHLY' :
                    conditionDefination = this.formMonthlyExpression(conditionInfo,
                                            conditionDefination);
                    return conditionDefination;
                    case 'YEARLY' :
                    conditionDefination = this.formYearlyExpression(conditionInfo,
                                            conditionDefination);
                    return conditionDefination;
                    default :
                    break;
                }
            }
        }

        return conditionDefination;
    }

    /*****
     * When <attribute> is <operator> <attribute value>, based on a <threshold value> % threshold
     */
    formEqualsExpression (condition) {

        let conditionDef = '';
        const attributeValue = condition.attributeDatatype === 'Reference' ?
                                    condition.attributeLookUpLabel : condition.attributeValue;
        //form Condition Defination                            
        conditionDef = labelWhen +' '+condition.attributeName +' is';
                    let operator = '';
                    if (condition.operator === 'gt') {
                        operator = labelGreaterThan.toLowerCase()
                    } else if (condition.operator === 'lt') {
                        operator = labelLessThan.toLowerCase()
                    } else {
                        operator = labelEquals.toLowerCase();
                    }
                    conditionDef = conditionDef
                                        +' '+ operator
                                        + ' '+ attributeValue
                                        +', '+ labelBasedOna+' '+ condition.threshold
                                        +'% '+ labelThreshold;
        return conditionDef;
    }

    formDateExpression (dateString) {

        const date = dateString.split('T')[0];
        if (date) {

            const year = date.substring(0,4);
            let month = parseInt(date.substring(4,6),10);
            month = MONTH_OPTIONS[month];
            const day = date.substring(6,8);
            const formattedDate = month+' '+day+', '+year;
            return formattedDate;
        }
        return '';
    }
    //Conition definition for daily
    formDailyExpression (condition,conditionDefination) {

        let conditionDef = conditionDefination;
        let endClause = ' '+labelWithNoEndDate;
        conditionDef = labelEvery+' '+ condition.INTERVAL +' '+labelDays;
        if (condition.COUNT) {
            endClause = ' '+ labelEndingAfter+' '+ condition.COUNT +' '+labelOccurences;
        }
        if (condition.UNTIL) {

            endClause = this.formDateExpression(condition.UNTIL);
            conditionDef += ' '+ labelEndingOn;
        }
        conditionDef += ' '+endClause;
        return conditionDef;
    }

    //Conition definition for Weekly
    formWeeklyExpression (condition,conditionDefination) {

        let conditionDef = conditionDefination;
        let endClause = labelWithNoEndDate;
        conditionDef = labelEvery+' '+ condition.INTERVAL +' '+WEEKS;
        let daysSelected = '';
        if (condition.BYDAY) {
            const days = condition.BYDAY.split(',');
            let dayValue = '';
            days.forEach(day => {
                dayValue = dayValue +' '+WEEK_OPTIONS[day]
            })
            daysSelected = ' '+ labelOnThe+' '+ dayValue;
            endClause = daysSelected+' '+endClause;
        }
        //if occourences is entered 
        if (condition.COUNT) {
            endClause = daysSelected+' '+labelEndingAfter+' '+condition.COUNT +' '+labelOccurences;
        }
        //if Date is entered
        if (condition.UNTIL) {
            endClause = daysSelected+' '+labelEndingOn +' '+
                            this.formDateExpression(condition.UNTIL);
        }
        conditionDef += ' '+endClause
        return conditionDef;
    }

    //Conition definition for Monthly
    formMonthlyExpression (condition,conditionDefination) {

        let conditionDef = conditionDefination;
        let endClause = labelWithNoEndDate;
        conditionDef = labelEvery+' '+ condition.INTERVAL +' '+MONTHS ;
        if (condition.BYMONTHDAY) {
            conditionDef += ' '+labelOnDay +' '+condition.BYMONTHDAY;
        }
        if (condition.BYSETPOS && condition.BYDAY) {
            //if BYDAY ='DAY', then we need to split all day by comma and show as  
            //Last Sunday Last Monday Last Tuesday .... 
            const days = condition.BYDAY.split(',');
            if (days.length > 1) {
                let daysPosition ='';
                days.forEach( day=>{
                    daysPosition = daysPosition + SETPOSITIONS[condition.BYSETPOS.toString()]
                    +' '+WEEK_OPTIONS[day];
                });
                conditionDef +=  ' '+labelOnThe + ' '+ daysPosition;
            } else {
                conditionDef +=  ' '+labelOnThe + ' '+ SETPOSITIONS[condition.BYSETPOS.toString()]
                            +' '+WEEK_OPTIONS[condition.BYDAY];
            }
        }
        if (condition.COUNT) {
            endClause = ' '+ labelEndingAfter+' '+ condition.COUNT+' ' +labelOccurences;
        }
        if (condition.UNTIL) {
            endClause = this.formDateExpression(condition.UNTIL);
        }
        conditionDef += ' '+ endClause;
        return conditionDef;
    }

    //Conition definition for Yearly
    formYearlyExpression (condition,conditionDefination) {
        let conditionDef = conditionDefination;
        let endClause = labelWithNoEndDate;
        const month = parseInt(condition.BYMONTH,10);
        conditionDef = labelEvery+' '+ condition.INTERVAL +' '+YEARS;
        if (condition.BYMONTHDAY && condition.BYMONTH) {
            conditionDef += ' '+ MONTH_OPTIONS[month]+' '+ condition.BYMONTHDAY ;
        }
        if (condition.BYDAY && condition.BYMONTH && condition.BYSETPOS) {
            //if BYDAY ='DAY', then we need to split all day by comma and show as  
            //Last Sunday Last Monday Last Tuesday .... 
            let daysPosition = '';
            const days = condition.BYDAY.split(',');
            if (days.length > 1) {
                let dayPosition ='';
                days.forEach( day=>{
                    dayPosition = dayPosition +' '+SETPOSITIONS[condition.BYSETPOS.toString()]
                    +' '+WEEK_OPTIONS[day];
                });
                daysPosition =  ' '+labelOnThe + ' '+ dayPosition;
            } else {
                daysPosition =  ' '+labelOnThe + ' '+ SETPOSITIONS[condition.BYSETPOS.toString()]
                            +' '+WEEK_OPTIONS[condition.BYDAY];
            }

            conditionDef += ' '+ labelIn+' '+ MONTH_OPTIONS[month]+' '+daysPosition;
        }
        if (condition.COUNT) {
            endClause = ' '+ labelEndingAfter+' '+ condition.COUNT+' ' +labelOccurences;
        }
        if (condition.UNTIL) {
            endClause = this.formDateExpression(condition.UNTIL);
        }
        conditionDef += ' '+ endClause;
        return conditionDef;
    }

    @api
    handleSearch (event) {

        this.searchkeyword = event.target.value.trim();
        this.assetSummaryList
            = this.filterRecords(this.originalAssetSummaryList, this.searchkeyword);
        //if no record in search then hide the workrule table header
        if (this.assetSummaryList) {
            this.assetSummaryList.forEach(item => {
                item.showHeader = item.workRules.length > 0 ? true : false;
            })
        }
    }

    filterRecords (allRecords, searchkeyword) {
        let filteredRecords = [];
        if (searchkeyword && searchkeyword.length > 0) {
            const lowerValue = searchkeyword.toLowerCase();
            filteredRecords = allRecords.map(dataItem => {
                return ( { ...dataItem,
                            workRules: dataItem.workRules.filter((subElement) =>{
                            if (subElement.workRuleTitle.toLowerCase().indexOf(lowerValue) !== -1) {
                                return subElement;
                            }
                            if (subElement.workType) {
                                if (subElement.workType.toLowerCase().indexOf(lowerValue) !== -1) {
                                    return subElement;
                                }
                            }
                            return '';
                        })
                    })
            });
        } else {
            filteredRecords = allRecords;
        }

        return filteredRecords;
    }

    handleWorkRuleSelectMenu ( event ) {

        const action = event.detail.value;
        this.action = action.value;
        this.selectedAssetId = action.id;
        switch (action.value) {
            case 'add' : this.handleAddWorkRules();
            break;
            case 'delete' : this.handleDeleteWorkRules();
            break;
            default :
                break;
        }
    }

    handleAddWorkRules () {

        this.showAddWorkRuleModal = true;
    }

    handleDeleteWorkRules () {

        if (this.selectedRows.length === 0) {
            this.openConfirmationModal = true;
            this.modalBody = labelSelectWorkRules;
            this.modalTitle = labelTitleSelectWorkRule;
        }
        else {
            this.modalBody = labelDeleteModalTitle;
            this.modalTitle = labelDeleteModalTitle;
            this.openDeleteModal = true;
        }
    }

    handleSelectedRows (event) {
        this.selectedRows = [];
        event.detail.selectedRows.forEach(item => {
            this.selectedRows.push(item);
        });
    }

    handleRowAction (event) {

        const action = event.detail.action.name;
        this.action = action;
        const row = event.detail.row;
        this.selectedAssetId = event.currentTarget.dataset.field;
        switch (action) {
            case 'edit' : this.handleEditWorkRule(row);
            break;
            case 'delete' : this.handleDeleteWorkRule(row);
            break;
            default :
                break;
        }
    }

    handleEditWorkRule (row) {
        this.showAddWorkRuleModal = true;
        this.workRuleToEdit = row;
    }

    handleDeleteWorkRule (row) {
        this.modalTitle = labelDeleteModalTitle;
        this.modalBody = labelDeleteModalTitle;
        this.rowTobeDeleted = row;
        this.openDeleteModal = true;
    }

    //On Confirmation delete the row
    handleConfirmDeleteRow () {
        const workRuleIds = [];
        //if rows are selected then execute if loop,
        //if user performs row action without selecting row, then else loop to delete individual row
        if (this.selectedRows && this.selectedRows.length > 0) {

            this.assetSummaryList.forEach(item => {
                if (item.assetId === this.selectedAssetId) {
                    for (let j = 0 ; j < item.workRules.length ; j++) {
                        const workRule = item.workRules[j];

                        this.selectedRows.forEach(row => {

                            if (row.posInSet === workRule.index) {
                                item.workRules.splice(j,1);
                                workRuleIds.push(workRule.workRuleId);
                                j--;
                            }
                        })
                    }
                    item.workRules = [...item.workRules];
                    item.showHeader = (item.workRules.length > 0) ? true : false;
                    item.showAssetHeader = (this.isTemplate === true && item.workRules.length)
                                            === 0 ? false : true;
                }
            })
        } else {
            this.assetSummaryList.filter((item) => {

                if ( item.assetId === this.selectedAssetId ) {
                    const spliceIndex = this.rowTobeDeleted.posInSet-1;
                    const workRuleTObeDeleted = item.workRules[spliceIndex];
                    workRuleIds.push(workRuleTObeDeleted.workRuleId);
                    item.workRules.splice(spliceIndex,1);
                    item.workRules = [...item.workRules] ;
                }
                item.showHeader = (item.workRules.length > 0) ? true : false;
                item.showAssetHeader = this.isTemplate === true && item.workRules.length === 0 ?
                                        false : true;
                return item;
            });
        }

        //If workrules are deleted from template screen, then delete from database also.
        if (this.isTemplate === true && workRuleIds && workRuleIds.length > 0) {
            deleteWorkRules({ workRuleIdList: JSON.stringify(workRuleIds) })
            .then(response=>{
                if (response.success === true) {

                    this.showToast('',labelRecordsDeletedSuccessfully,'success');
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
        }
        this.openDeleteModal = false;
    }

    @api
    handleSaveWorkRuleFromTemplate (event,selectedProductRec) {
        this.selectedProduct = selectedProductRec;
        this.handleSaveWorkRule(event);
    }

    isSortOrderValidated (workRules,workRule) {

        let isSortOrderValidated = true;
        workRules.forEach(item => {
            if (parseInt(item.sortOrder,10) === parseInt(workRule.sortOrder,10) &&
            item.index !== workRule.index) {
                isSortOrderValidated = false;
            }
        })
        return isSortOrderValidated;
    }

    handleSaveWorkRule (event) {
        this.apiInProgress = true;
        const workrule = event.detail.value;
        this.action = event.detail.action;
        this.rowsTobeInsertUpdated = [];
        let isValid = true;

        //if action is 'addWorkRuleTemplate', then we need to create
        // new work rule template else add workrule to existing asset
        if ( this.action === 'addWorkRuleTemplate' ) {
            const assetRec = {};
            const assetWorkRuleMenu = [];
            const workRules = [];
            const tempWorkRule = this.populateWorRuleInfo(workrule,assetRec.assetId,1);
            workRules.push(Object.assign({},tempWorkRule));

            assetWorkRuleMenu.push(
                { label: labelAddWorkToAsset, value: 'add', id: assetRec.assetId },
                { label: labelDeleteWorkRules, value: 'delete', id: assetRec.assetId });
            assetRec.assetId = this.selectedProduct.productId;
            assetRec.assetName = this.selectedProduct.productFamily === undefined ?
            this.selectedProduct.product : this.selectedProduct.productFamily;
            assetRec.applicableProduct = this.selectedProduct.id;
            assetRec.workRuleMenuItems = assetWorkRuleMenu;
            assetRec.workRules = workRules;
            assetRec.showHeader = workRules.length > 0 ? true : false;

            if (this.assetSummaryList) {
                this.assetSummaryList.forEach(item=> {
                    if ( item.applicableProduct === this.selectedProduct.id ) {
                        const index = item.workRules.length === undefined ?
                                                    0 : item.workRules.length;
                        workrule.index = index + 1;
                        isValid = this.isSortOrderValidated(item.workRules,workrule);
                        if (isValid) {
                            item.workRules = [...item.workRules,workrule]
                        }
                    }
                })
            }

            //If sort order is not valid then run the event to avoid addworkrulemodal close
            if (!isValid) {
                this.showToast('',labelSortOrderCannotBeDuplicate,'error')
                this.dispatchEvent(new CustomEvent("closeaddworkrulemodal", { detail:
                    { value: false }
                }));
                return;
            }
             //If sort order is valid then run the event to close addworkrulemodal close
            this.dispatchEvent(new CustomEvent("closeaddworkrulemodal", { detail:
                    { value: true }
            }));
            this.rowsTobeInsertUpdated = this.sanitizeAssetWrapper(assetRec);
        } else {
            workrule.assetId = this.selectedAssetId;
            this.assetSummaryList.forEach(item => {

                if ( item.assetId === workrule.assetId ) {
                    isValid = this.isSortOrderValidated(item.workRules,workrule);
                    if (isValid === true) {
                        //start: setting values to updated to database
                        const assetRec = {};
                        assetRec.assetId = workrule.assetId;
                        assetRec.applicableProduct = item.applicableProduct;
                        //endhere
                        if (this.action === 'add' )
                        {
                            const index = item.workRules !== null ? (item.workRules.length + 1) : 1;
                            const workRuleInfo = this.populateWorRuleInfo(workrule,item.id,index);
                            item.workRules =  [...item.workRules,workRuleInfo] ;
                            assetRec.workRules = [workRuleInfo];
                            item.showHeader = item.workRules.length > 0 ? true : false;
                            this.rowsTobeInsertUpdated = this.isTemplate === true ?
                                this.sanitizeAssetWrapper(assetRec) : null;
                        } else {

                            let i = 1;
                            const workRuleInfo = this.populateWorRuleInfo(workrule,item.id,i);
                            item.showHeader = item.workRules.length > 0 ? true : false;
                            const newarray = item.workRules.map(element => {
                                let tempElement = element;
                            if (workRuleInfo.posInSet === i) {
                                    tempElement = { ...workRuleInfo };
                                    assetRec.workRules = [workRuleInfo];
                                    this.rowsTobeInsertUpdated = this.isTemplate === true ?
                                        this.sanitizeAssetWrapper(assetRec) : null;
                                }
                                i++;
                                return tempElement;
                            });
                            item.workRules = [...newarray]
                        }
                    }
                }
            });
        }

        if (!isValid) {
            this.showToast('',labelSortOrderCannotBeDuplicate,'error')
            return;
        }

        //if location is from tempalte then save workrules
        if ( this.isTemplate === true && this.rowsTobeInsertUpdated) {
            saveWorkRuleTemplate({ maintenanceAssetsJSON:
                                    JSON.stringify(this.rowsTobeInsertUpdated) })
            .then(response => {
                if (response.success === true) {
                    this.fetchWorkRulesFromTemplate();
                    this.showToast('',labelRecordsSaveSuccessfully,'success');
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
                this.showToast('',this.error,'error');
            }).finally( () => {
                this.handleWorkTypeModalClose();
                this.apiInProgress = false;
            });
        } else {
            this.handleWorkTypeModalClose();
        }
    }

    handleWorkTypeModalClose () {
        this.apiInProgress = false;
        this.showAddWorkRuleModal = false;
        this.openConfirmationModal = false;
        this.openDeleteModal = false;
    }

    handleNext () {
        const sanitizedSummaryList = [];
        this.assetSummaryList.forEach(row => {
            if (row != null) {
                sanitizedSummaryList.push(this.sanitizeAssetWrapper(row));
            }
        })
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.maintenanceAssetRequest = JSON.stringify(sanitizedSummaryList);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    showToast (title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    //method to remove unwanted objects and santize the object as per apex wrapper class
    sanitizeAssetWrapper (assetRec) {

        if (assetRec) {
            const workRules = [];
            assetRec.workRules.forEach(item => {
                const workRule = {};
                workRule.workRuleId = item.workRuleId;
                workRule.workRuleTitle = item.workRuleTitle;
                workRule.workTypeId = item.workTypeId;
                workRule.sortOrder = parseInt(item.sortOrder,10);
                workRule.advancedExpression = item.advancedExpression;
                workRule.attributeTemplate = item.attributeTemplate;
                if (item.detail) {
                    const workRuleDetails = [];
                    item.detail.forEach(detailRow => {
                        const detail = {};
                        detail.id = detailRow.id === undefined ? null : detailRow.id;
                        detail.conditionType = detailRow.conditionType;
                        detail.conditionDefination = detailRow.conditionDefination;
                        detail.sequence = detailRow.sequence;

                        if (detailRow.criteria) {
                            const criteria = {};
                            criteria.operator = detailRow.criteria.operator;
                            criteria.attribute = detailRow.criteria.attribute;
                            criteria.attributeValue = detailRow.criteria.attributeValue;
                            criteria.attributeCategory = detailRow.criteria.attributeCategory;
                            criteria.threshold = detailRow.criteria.threshold === undefined ?
                                            null : parseInt(detailRow.criteria.threshold,10);
                            detail.criteria = criteria;
                        }
                        if (detailRow.frequency) {

                            const frequency = {};
                            frequency.operator = detailRow.frequency.operator;
                            frequency.attribute = detailRow.frequency.attribute;
                            frequency.attributeValue = detailRow.frequency.attributeValue;
                            frequency.attributeCategory = detailRow.frequency.attributeCategory;
                            frequency.threshold = detailRow.frequency.threshold === undefined ?
                                            null : parseInt(detailRow.frequency.threshold,10);
                            frequency.startAt = detailRow.frequency.startAt === undefined ?
                                             null : detailRow.frequency.startAt;
                            frequency.stopAt = detailRow.frequency.stopAt === undefined ?
                                             null : detailRow.frequency.stopAt;
                            detail.frequency = frequency;
                        }
                        if (detailRow.recurrenceRule) {
                            const recurrenceRule = detailRow.recurrenceRule;
                            detail.recurrenceRule = recurrenceRule;
                        }
                        workRuleDetails.push(detail);
                    })
                    workRule.detail = workRuleDetails;
                }
                workRules.push(workRule);
            })
            //finalRecord To Save
            let recordToSave = {};
            if ( this.isTemplate === true) {
                recordToSave = {
                    mplnTemplateId: this.mplnRecord.id === undefined ? null : this.mplnRecord.id,
                    applicableProduct: assetRec.applicableProduct === undefined ?
                                            null : assetRec.applicableProduct ,
                    workRules: workRules
                }
            } else {
                recordToSave = {
                    assetId: assetRec.assetId,
                    workTypeId: assetRec.workTypeId,
                    workRules: workRules
                }
            }
            return recordToSave;
        }
        return null;
    }
}