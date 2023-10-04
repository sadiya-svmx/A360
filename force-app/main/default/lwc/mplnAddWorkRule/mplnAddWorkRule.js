import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    OBJECT_ICONS,
    parseErrorMessage,
    validateExpression,
    isValidInput
} from 'c/utils';

import WORK_TYPE_OBJECT from '@salesforce/schema/WorkType';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import getAttributeTemplates from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getAttributeTemplates';
import getAttributeCategories from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getAttributeCategories';
import getAttributes from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getAttributes';
import getAssetFields from
'@salesforce/apex/MPLN_ConditionBasedMPlan_LS.getAssetFields';

import ASSETCONDITION_OBJECT from '@salesforce/schema/SM_Condition__c';
import CONDITIONTYPE_FIELD from '@salesforce/schema/SM_Condition__c.ConditionType__c';

import messageInvalidException from '@salesforce/label/c.Message_InvalidExpressionError';
import labelAddWorkToAsset from '@salesforce/label/c.Label_AddWorkRuleToAssetTitle';
import labelWorkRuleTemplateTitle from '@salesforce/label/c.Label_WorkRuleTemplateTitle';
import labelWorkType from '@salesforce/label/c.Label_WorkType';
import labelRequiredFieldMsg from '@salesforce/label/c.Label_RequiredFieldMsg';
import labelMaintenanceWorkOrderType from '@salesforce/label/c.Label_MaintenanceWorkOrderType';
import labelAttributeTemplate from '@salesforce/label/c.Label_AttributeTemplate';
import labelAttributeCategory from '@salesforce/label/c.Label_AttributeCategory';
import labelAttribute from '@salesforce/label/c.Label_Attribute';
import labelAttributeValue from '@salesforce/label/c.Label_AttributeValue';
import labelStartAt from '@salesforce/label/c.Label_StartAt';
import labelStopAt from '@salesforce/label/c.Label_StopAt';
import labelSortOrder from '@salesforce/label/c.Label_SortOrder';
import labelConditionDefinition from '@salesforce/label/c.Label_ConditionDefinition';
import labelConditionType from '@salesforce/label/c.Label_ConditionType';
import labelOperator from '@salesforce/label/c.Label_Operator';
import labelThreshold from '@salesforce/label/c.Label_Threshold';
import labelAdvancedExpression from '@salesforce/label/c.Label_Advanced_Expression_Edit';
import labelSave from '@salesforce/label/c.Label_Save';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelAddCondition from '@salesforce/label/c.Label_Add_Condition';
import labelEquals from '@salesforce/label/c.Label_Equals';
import labelEvery from '@salesforce/label/c.Label_Every';
import labelEveryDecrement from '@salesforce/label/c.Label_EveryDecrement';
import labelGreaterThan from '@salesforce/label/c.Label_GreaterThan';
import labelLessThan from '@salesforce/label/c.Label_LessThan';
import labelConditionBased from '@salesforce/label/c.Label_ConditionBased';
import labelApplicableProduct from '@salesforce/label/c.Label_ApplicableProduct';
import labelAddConditionTypeToWorkRule from '@salesforce/label/c.Message_AddConditionType';
import labelNewWorkRuleTemplate from '@salesforce/label/c.Label_NewWorkRuleTemplate';
import labelAssetFields from '@salesforce/label/c.Label_AssetFields';
import labelAttributeTemplateHelpText from '@salesforce/label/c.HelpText_AttributeTemplate';
import labelConditionTypeHelpText from '@salesforce/label/c.HelpText_ConditionType';
import labelCategoryHelpText from '@salesforce/label/c.HelpText_Category';
import labelAttributeHelpText from '@salesforce/label/c.HelpText_Attribute';
import labelFrequency from '@salesforce/label/c.Label_Frequency';
import labelTime from '@salesforce/label/c.Label_Time';
import labelCriteria from '@salesforce/label/c.Label_Criteria';

import labelScheduleEvery from '@salesforce/label/c.Label_ScheduleEvery';
import labelErrorLowNumber from '@salesforce/label/c.Error_TheNumberIsLow';
import labelOn from '@salesforce/label/c.Label_On';
import labelOnThe from '@salesforce/label/c.Label_OnThe';
import labelOnDay from '@salesforce/label/c.Label_OnDay';
import labelOf from '@salesforce/label/c.Label_Of';
import labelOccurences from '@salesforce/label/c.Label_Occurences';
import labelAfter from '@salesforce/label/c.Label_AfterRadio';
import labelNever from '@salesforce/label/c.Label_NeverRadio';
import labelEndSchedule from '@salesforce/label/c.Label_EndSchedule';
import First from '@salesforce/label/c.Label_First';
import MONTHS from '@salesforce/label/c.Label_enumMONTHS';
import DAYS from '@salesforce/label/c.Label_enumDAYS';
import WEEKS from '@salesforce/label/c.Label_enumWEEKS';
import YEARS from '@salesforce/label/c.Label_enumYEARS';

import RecurrencePatternModel,
{
    ENUM_YearScheduleOptions,
    ENUM_SubOptionKeyNames,
    ENUM_MonthScheduleOptions,
    ENUM_WeekDayOptions,
    ENUM_endScheduleOptions,
    ENUM_FrequencyOptions,
} from "./recurrencePatternModel";

const i18n = {
    addWorkToAssetTitle: labelAddWorkToAsset,
    workRuleTemplateTitle: labelWorkRuleTemplateTitle,
    requiredFieldMsg: labelRequiredFieldMsg,
    workType: labelWorkType,
    maintenanceWorkOrderType: labelMaintenanceWorkOrderType,
    attributeTemplate: labelAttributeTemplate,
    attributeCategory: labelAttributeCategory,
    attribute: labelAttribute,
    attributeValue: labelAttributeValue,
    startAt: labelStartAt,
    stopAt: labelStopAt,
    sortOrder: labelSortOrder,
    conditionDefinition: labelConditionDefinition,
    conditionType: labelConditionType,
    operator: labelOperator,
    threshold: labelThreshold,
    advancedExpression: labelAdvancedExpression,
    addCondition: labelAddCondition,
    conditionBased: labelConditionBased,
    applicableProduct: labelApplicableProduct,
    attributeTemplateHelpText: labelAttributeTemplateHelpText,
    conditionTypeHelpText: labelConditionTypeHelpText,
    categoryHelpText: labelCategoryHelpText,
    attributeHelpText: labelAttributeHelpText,
    save: labelSave,
    cancel: labelCancel,
    labelScheduleEvery,
    labelErrorLowNumber,
    labelOn,
    labelOnThe,
    labelOnDay,
    labelOf,
    labelOccurences,
    labelAfter,
    labelNever,
    labelEndSchedule

}

const FREQUENCY = labelFrequency;
const CRITERIA = labelCriteria;
const TIME = labelTime;
const ASSET = 'ASSET';

const WEEK_DAYS = Object.keys(ENUM_WeekDayOptions).map( key => ({
    weekDay: key, selected: false, label: key.slice(0,3)  }));

const INITIALIZE_STATE_PATTERNS = [
    'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=1;COUNT=1',
    'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYSETPOS=1;BYDAY=SU;BYMONTH=1',
    'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYMONTH=1;BYMONTHDAY=1',
    'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYMONTH=1;BYSETPOS=1;BYDAY=SU'
];
const DEFAULT_STATE = 'FREQ=MONTHLY;INTERVAL=1;BYSETPOS=1;BYDAY=SU';

const WORKRULE_INPUT_FIELD_CLASS = '.svmx-required-inputfld';

//supported Technical attribute datatype for frequency condition type 
const FREQUENCY_TA_SUPPORTED_DATATYPES = ['number','date'];
//supported Technical attribute datatype for criteria condition type
const CRITERIA_TA_SUPPORTED_DATATYPES = ['text','number','picklist','boolean','date','datetime'];
//supported Asset datatypes for frequency condition type 
const FREQUENCY_ASSET_SUPPORTED_DATATYPES = ['double','integer'];
//supported Asset datatypes for criteria condition type 
const CRITERIA_ASSET_SUPPORTED_DATATYPES =
                            ['string','date','picklist','reference','double','integer'];

//Operator matrix for frequecny
const FREQUENCY_OPERATOR_MATRIX = {
                            'Number': [{ label: labelEvery,value: labelEvery },
                                    { label: labelEveryDecrement,value: labelEveryDecrement }],
                            'Double': [{ label: labelEvery,value: labelEvery },
                                { label: labelEveryDecrement,value: labelEveryDecrement }],
                            'Integer': [{ label: labelEvery,value: labelEvery },
                                    { label: labelEveryDecrement,value: labelEveryDecrement }],
                            'Date': [{ label: labelEvery,value: labelEvery },
                                    { label: labelEveryDecrement,value: labelEveryDecrement }]
                           }
//Operator matrix for criteria
const CRITERIA_OPERATOR_MATRIX = { 'Text': [{ label: labelEquals,value: 'eq' }],
                        'Number': [{ label: labelEquals,value: 'eq' },
                                { label: labelGreaterThan,value: 'gt' },
                                { label: labelLessThan,value: 'lt' }],
                        'Boolean': [{ label: labelEquals,value: 'eq' }],
                        'Picklist': [{ label: labelEquals,value: 'eq' }],
                        'Date': [{ label: labelEquals,value: 'eq' },
                                        { label: labelGreaterThan,value: 'gt' },
                                        { label: labelLessThan,value: 'lt' }],
                        'Datetime': [{ label: labelEquals,value: 'eq' },
                                        { label: labelGreaterThan,value: 'gt' },
                                        { label: labelLessThan,value: 'lt' }],
                        'Reference': [{ label: labelEquals,value: 'eq' }],
                        'Integer': [{ label: labelEquals,value: 'eq' }],
                        'String': [{ label: labelEquals,value: 'eq' }],
                        'Double': [{ label: labelEquals,value: 'eq' },
                                    { label: labelGreaterThan,value: 'gt' },
                                    { label: labelLessThan,value: 'lt' }]
                    }


export default class MplnAddWorkRule extends LightningElement {

    @api showWorkRuleModal;
    @api workRuleInfo;
    @api rowAction;
    @api applicableProductInfo

    @track workRule = {};
    @track conditionDefinitions = [];

    attibuteTemplates = [];
    attributeCategoryDetails = [];
    attributeCategories = [{
        label: labelAssetFields,
        value: ASSET
    }];
    conditionTypeValues = [];
    originalConditionTypes = [];

    errorMessage ='';
    workRuleTitle ='';

    apiNameWorkType = WORK_TYPE_OBJECT.objectApiName;
    lookupIcon = OBJECT_ICONS.worktype;
    advancedSearchConfig = false;
    apiInProgress = false;

    editFrequencyValue = ENUM_FrequencyOptions[MONTHS];

    addConditionType = false;
    recModelManager = null;
    isFrequencyDay = false;

    isFrequencyWeek = false;
    weekControlOptions = null;

    enumWeekDayValues = { ...ENUM_WeekDayOptions };
    weekSelectedList = {};
    dataTypeMap = new Map();

    isFrequencyMonth = true;
    monthControlOptions = null;
    enumMonthRadioValues = ENUM_MonthScheduleOptions;

    isFrequencyYear = false;
    enumYearRadioValues = ENUM_YearScheduleOptions;

    enumEndScheduleOptions = ENUM_endScheduleOptions;

    subOptionKeyNames = ENUM_SubOptionKeyNames;

    @track
    yearRadioSelection = {
        disableMonthDay: true,
        disableMonthWeekDay: true
    };

    @track
    yearRadioButton = {
        monthDay: false,
        monthWeekDay: false
    };

    @track
    monthRadioSelection = {
        disableMonthDay: true,
        disableDayPosition: true,
    }

    @track
    monthRadioButton = {
        monthDay: false,
        dayPosition: false,
    };

    @track
    endScheduleRadioSelection = {
        disableOccurence: true,
        disableDate: true
    }

    @track
    endScheduleValues = {
        on: '' ,
        after: 1
    };

    @track
    endScheduleRadioButton = {
        on: false,
        after: false,
        never: true
    }

    @track
    monthSubOptionValues = {
        weekDay: i18n.sunday,
        setPos: First,
        monthDay: "1",
    };

    @track
    yearSubOptionValues = {
        weekDay: i18n.sunday,
        setPos: First,
        day: '1',
        month: i18n.january,
        monthDayMonth: i18n.january

    };

    @track
    weekDayNameList = JSON.parse(JSON.stringify(WEEK_DAYS));

    @wire(getObjectInfo, { objectApiName: ASSETCONDITION_OBJECT })
    assetCondtionMetadata;

    // get the ConditionType picklist values
    @wire(getPicklistValues,
        {
            recordTypeId: '$assetCondtionMetadata.data.defaultRecordTypeId',
            fieldApiName: CONDITIONTYPE_FIELD
        }
    )
    condtionTypePicklist ({ data }) {
        if (data) {
            if (data.values) {

                this.conditionTypeValues = data.values.map(type=>{ return type});
                this.originalConditionTypes = this.conditionTypeValues.map(type=>{ return type});
            }
        }
    }


    editWorkRule (workRuleInfo) {

        for (const key in workRuleInfo) {
            if (Object.prototype.hasOwnProperty.call(workRuleInfo,key)) {
                this.workRule[key] = workRuleInfo[key];
                if (key === 'attributeTemplate') {
                    const request = { requestJson: JSON.stringify(
                        { id: workRuleInfo[key] }
                        ) };

                    this.handleAttributeCategories(request);
                }
            }
        }

        //if work rule has details, add index
        if (this.workRule.detail) {
            this.conditionDefinitions = JSON.parse(JSON.stringify(this.workRule.detail));

            for (let i = 0 ; i < this.conditionDefinitions.length ; i++) {
                const item = this.conditionDefinitions[i];
                item.index = i+1;
                this.toggleFrequencyChange('conditionType',
                item.conditionType,this.conditionDefinitions,i);

                if (item.frequency || item.criteria) {

                    item.conditionTypes = [{ label: FREQUENCY,value: FREQUENCY },
                                            { label: CRITERIA,value: CRITERIA }];
                    const patternInfo = item.frequency ? item.frequency :
                                    item.criteria

                    if (patternInfo.attributeCategory !== ASSET) {
                        const request = { requestJson: JSON.stringify(
                            { id: patternInfo.attributeCategory }
                            ) };
                            //get attributes for the saved attribute category
                            this.handleAttributes(request,i,item.conditionType);
                            this.toggleAttributeChange(patternInfo.attributeDatatype,
                                                    this.conditionDefinitions,i);
                            //get operators for saved dtatype
                            if (patternInfo.attributeDatatype) {
                                //since for boolean we need to assign true/false instead json string
                                if (patternInfo.attributeDatatype === 'Boolean') {
                                    patternInfo.attributeValue =
                                        patternInfo.attributeValue === 'true' ? true : false;
                                }
                                this.getOperators(patternInfo.attributeDatatype,
                                                    item.conditionType,i);
                            }
                    } else {
                        patternInfo.attributeCategory = ASSET;
                        this.handleAssetAttributes(i,item.conditionType);
                    }
                }
                //if condition type is time, then get recurrence pattren to default values
                else if (item.conditionType === TIME) {
                    //if time is there then add time condtiontype
                    item.conditionTypes = [{ label: FREQUENCY,value: FREQUENCY },
                                           { label: TIME,value: TIME },
                                           { label: CRITERIA,value: CRITERIA }];
                    if (this.conditionDefinitions[i].recurrenceRule) {
                        this.recModelManager.parseRecPatternToState(
                            this.conditionDefinitions[i].recurrenceRule
                            );
                        this.setupBeforeEdit();
                    }
                }
            }
        }
    }

    get i18n () {
        return i18n;
    }
/*========CONSTRUCTOR===========*/
    constructor () {
        super();
        this.recModelManager = new RecurrencePatternModel();
        this.intervalManager = this.recModelManager.getIntervalManager();
        this.frequencyManager = this.recModelManager.getFrequencyManager();
        this.weekManager = this.recModelManager.getWeekManager();
        this.monthManager = this.recModelManager.getMonthManager();
        this.yearManager = this.recModelManager.getYearManager();
        this.endScheduleManager = this.recModelManager.getEndScheduleManager();

        this.monthControlOptions = this.monthManager.getSubOptions();
        this.weekControlOptions = this.weekManager.getOptions();
        this.yearControlOptions = this.yearManager.getSubOptions();

        /** setting Defaults */
        this.frequencyManager.setFrequency(ENUM_FrequencyOptions[DAYS]);

        /** Initialize State defaults */
        INITIALIZE_STATE_PATTERNS.forEach( reccStr =>
            this.recModelManager.parseRecPatternToState(reccStr));
        this.recModelManager.parseRecPatternToState(DEFAULT_STATE);
        this.monthManager.setSelectedOption(ENUM_MonthScheduleOptions.noOption);
        this.yearManager.setYearSelectedOption(ENUM_YearScheduleOptions.noOption);
    }

    get frequencyOptions () {
        const { frequencyManager } = this;
        return frequencyManager.getFrequencyOptions();
    }

    handleWorkRuleInputChange (event) {

        const fieldName = event.currentTarget.dataset.field;
        const fieldValue = event.target.value;
        this.workRule[fieldName] = fieldValue;
        if ( fieldName === 'workType' ) {
            const { detail: { label,value }} = event;
            this.workRule[fieldName] = label;
            this.workRule[fieldName+'Id'] = value;
        }
    }

    connectedCallback () {

        this.apiInProgress = true;
        this.workRuleTitle = this.rowAction === 'addWorkRuleTemplate' ?
                            labelNewWorkRuleTemplate : labelAddWorkToAsset;
        this.loadData();
        if (this.rowAction === 'edit') {
            this.editWorkRule(this.workRuleInfo);
        }
    }

    loadData () {
        getAttributeTemplates()
        .then(result => {
            if (result.data) {

                const attibuteTemplates = [];
                result.data.forEach(item=> {
                    attibuteTemplates.push({
                        label: item.name,
                        value: item.id
                    });
                });
                this.attibuteTemplates = [...attibuteTemplates];
            }
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        }).finally( () => {
            this.apiInProgress = false;
        });
    }

    handleAttributeTemplateChange (event) {
        const fieldName = event.currentTarget.dataset.field;
        const fieldValue = event.target.value;
        this.resetAttributeCategories();
        if (fieldValue) {
            this.workRule[fieldName] = fieldValue;
            const request = { requestJson: JSON.stringify({ id: fieldValue }) };
            this.handleAttributeCategories(request);
        }
    }

    resetAttributeCategories () {
        //if tempalte is set to null, then reset categories/attributevalues/operators
        this.conditionDefinitions.forEach(item => {
            if (item.frequency) {
                if (item.frequency.attributeCategory !== ASSET) {
                    this.attributeCategories = [{
                        label: labelAssetFields,
                        value: ASSET
                    }];
                    item.frequency.attributes = [];
                    item.frequency.operators = [];
                    item.frequency.attributeCategory = null;
                    item.frequency.attributeValue = null;
                    item.frequency.operator = null;
                    this.toggleAttributeChange(undefined,
                        this.conditionDefinitions,item.index-1);
                }
            } else if (item.criteria) {
                if (item.criteria.attributeCategory !== ASSET) {
                    this.attributeCategories = [{
                        label: labelAssetFields,
                        value: ASSET
                    }];
                    item.criteria.attributes = [];
                    item.criteria.operators = [];
                    item.criteria.attributeCategory = null;
                    item.criteria.operator = null;
                    item.criteria.attributeValue = null;
                    this.toggleAttributeChange(undefined,
                        this.conditionDefinitions,item.index-1);
                }
            }
        })
    }

    handleAttributeCategories (request) {
        this.attributeCategories = []
        getAttributeCategories(request)
            .then( result=> {

                if (result.data) {
                    this.attributeCategoryDetails = result.data;
                    const attributeCategories = [];
                    result.data.forEach(item=> {
                        attributeCategories.push({
                            label: item.name,
                            value: item.id
                        })
                    })
                    attributeCategories.push({
                        label: labelAssetFields,
                        value: ASSET
                    })
                    this.attributeCategories = [...attributeCategories];
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    handleAttributeCategoryChange (event,rowIndex,conditionType) {

        const fieldValue = event.target.value;
        if (fieldValue === ASSET) {
            this.handleAssetAttributes(rowIndex,conditionType);
        } else {
            const request = { requestJson: JSON.stringify({ id: fieldValue }) };
            this.handleAttributes(request,rowIndex,conditionType);
        }
        //when category is changed, set attribute type to false,to hide previously selected field 
        this.toggleAttributeChange(undefined,
            this.conditionDefinitions,rowIndex);
    }

    handleAttributes (request,rowIndex,conditionType) {

        getAttributes(request)
            .then( result=> {
                if (result.data) {
                    const attributes = [];
                    const supportedDataTypes =
                                conditionType.toLowerCase() === FREQUENCY.toLowerCase() ?
                                FREQUENCY_TA_SUPPORTED_DATATYPES : CRITERIA_TA_SUPPORTED_DATATYPES;
                    result.data.forEach(attribute => {
                        if (supportedDataTypes.includes(attribute.dataType.toLowerCase())) {
                            attributes.push({
                                label: attribute.name,
                                value: attribute.id,
                                secondary: attribute.dataType
                            })
            //if selected datatype is picklist, then load picklist values from picklist definition
                            const picklistValues = attribute.picklistValues?.map(item=>{
                                return { label: item,value: item }
                            })
                            const key = attribute.id;
                            this.dataTypeMap.set(key,
                                                { defaultValue: attribute.defaultValue,
                                                    picklistValues: picklistValues
                                                })
                        }
                    })
                    if (conditionType.toLowerCase() === FREQUENCY.toLowerCase()) {
                        this.conditionDefinitions[rowIndex].frequency =
                        { ...this.conditionDefinitions[rowIndex].frequency,attributes };
                        this.getPicklistValuesForAttributes(conditionType,
                                                        this.conditionDefinitions,rowIndex);
                    } else if (conditionType.toLowerCase() === CRITERIA.toLowerCase()) {
                        this.conditionDefinitions[rowIndex].criteria =
                        { ...this.conditionDefinitions[rowIndex].criteria,attributes };
                        this.getPicklistValuesForAttributes(conditionType,
                                                    this.conditionDefinitions,rowIndex);
                    }
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            }).finally( () => {
                this.apiInProgress = false;
            });
    }

    handleAssetAttributes (rowIndex,conditionType) {

        getAssetFields({ objectAPIName: ASSET })
            .then(result => {
                if (result.data) {
                    const attributes = [];
                    const fieldDefinations = result.data.fieldDefinitions;
                    const supportedDataTypes =
                        conditionType.toLowerCase() === FREQUENCY.toLowerCase() ?
                        FREQUENCY_ASSET_SUPPORTED_DATATYPES : CRITERIA_ASSET_SUPPORTED_DATATYPES;
                    fieldDefinations.forEach(field=>{
                        const fldDataType = field.dataType.toLowerCase();
                        const camelCaseFldDataType =
                                fldDataType.charAt(0).toUpperCase() + fldDataType.slice(1);
                        if (supportedDataTypes.includes(fldDataType)) {
                            attributes.push({
                                label: field.label,
                                value: field.apiName,
                                secondary: camelCaseFldDataType
                            })
                        }

                        this.dataTypeMap.set(field.apiName,
                            { defaultValue: field.defaultValue === undefined ?
                                                                null : field.defaultValue,
                                picklistValues: field.picklistValues === undefined ?
                                                                    null : field.picklistValues,
                                referenceTo: field.referenceTo === undefined ?
                                                                    null : field.referenceTo[0],
                                dataType: camelCaseFldDataType
                            })
                    });
                    let patternInfo;
                    if (conditionType.toLowerCase() === FREQUENCY.toLowerCase()) {
                        patternInfo = this.conditionDefinitions[rowIndex].frequency;
                        this.conditionDefinitions[rowIndex].frequency =
                                    { ...this.conditionDefinitions[rowIndex].frequency,attributes };
                    } else if (conditionType.toLowerCase() === CRITERIA.toLowerCase()) {
                        patternInfo = this.conditionDefinitions[rowIndex].criteria;
                        this.conditionDefinitions[rowIndex].criteria =
                                    { ...this.conditionDefinitions[rowIndex].criteria,attributes };
                    }
                    this.getPicklistValuesForAttributes(conditionType,
                                        this.conditionDefinitions,rowIndex);

                    if (this.rowAction === 'edit') {

                        const datatype = patternInfo.attribute === undefined ? undefined :
                                        this.dataTypeMap.get(patternInfo.attribute).dataType;
                        this.toggleAttributeChange(datatype,
                                    this.conditionDefinitions,rowIndex);

                        this.getOperators(datatype,conditionType,rowIndex);
                    }
                }
            })
    }

    getPicklistValuesForAttributes (conditionType,conditionDefinitions,rowIndex) {


        conditionDefinitions.forEach(condition => {

            const index = condition.index-1;
            if (rowIndex === index) {

                if (conditionType.toLowerCase() === FREQUENCY.toLowerCase()) {
                    const key = condition.frequency.attribute;

                    const picklistValues = this.dataTypeMap.get(key) === undefined ?
                                                null : this.dataTypeMap.get(key).picklistValues;
                    const referenceTo = this.dataTypeMap.get(key) === undefined ?
                                                null : this.dataTypeMap.get(key).referenceTo;

                    conditionDefinitions[index].frequency =
                        { ...conditionDefinitions[index].frequency,picklistValues };
                    conditionDefinitions[index].frequency =
                        { ...conditionDefinitions[index].frequency,referenceTo };

                } else if (conditionType.toLowerCase() === CRITERIA.toLowerCase()) {
                    const key = condition.criteria.attribute;

                    const picklistValues = this.dataTypeMap.get(key) === undefined ?
                                                null : this.dataTypeMap.get(key).picklistValues;
                    const referenceTo = this.dataTypeMap.get(key) === undefined ?
                                                null : this.dataTypeMap.get(key).referenceTo;
                    conditionDefinitions[index].criteria =
                                    { ...conditionDefinitions[index].criteria,picklistValues };
                    conditionDefinitions[index].criteria =
                                    { ...conditionDefinitions[index].criteria,referenceTo };
                }
            }
        })
    }

    validateAdvancedExpression () {

        const inputFld = this.template.querySelector('.advancedExpression');
        const value = inputFld.value === '' ? null : inputFld.value;
        let isValid = false;
         if (!validateExpression(this.conditionDefinitions.length, value)) {
            isValid = false
            inputFld.setCustomValidity(messageInvalidException);
            inputFld.reportValidity();
        } else {
            isValid = true;
            inputFld.setCustomValidity('');
            inputFld.reportValidity();
        }

        return isValid;
    }

    handleInputChange (event) {

        const fieldName = event.currentTarget.dataset.field;
        const fieldValue = event.target.value;
        const index = event.currentTarget.dataset.id;

        for (let i = 0; i < this.conditionDefinitions.length; i++) {

            if (this.conditionDefinitions[i].index === parseInt(index,10)) {
                const data = {};
                this.toggleFrequencyChange(fieldName,fieldValue,this.conditionDefinitions,i);

                if (fieldName === 'conditionType') {
                    this.conditionDefinitions[i].conditionType = fieldValue;
                }
                if (this.conditionDefinitions[i].isFrequency === true) {
                    if (fieldName !== 'conditionType')
                        data[fieldName] = fieldValue;
                    //for boolean fields we need to check for event.target.cheked
                    if (fieldName === 'attributeValue') {
                        if (this.conditionDefinitions[i].frequency.attributeDatatype
                                                                            === 'Boolean') {
                            data[fieldName] = event.target.checked;
                        }
                        //if selected attribute is referecne, then get corresponsing lookup label 
                        //to show on condition definition
                        if (this.conditionDefinitions[i].frequency.attributeDatatype
                                                                            === 'Reference') {
                            data.attributeLookUpLabel = event.detail.label;
                        }
                    }
                    this.attributeHandler(event,fieldName,data,this.conditionDefinitions,
                                        i,this.conditionDefinitions[i].conditionType);
                    this.conditionDefinitions[i].frequency =
                        { ...this.conditionDefinitions[i].frequency,...data };
                }
                //since if it is criteria, we need to add to criteria wrapper variable 
                //we added else if cond
                else if (this.conditionDefinitions[i].isCriteria === true) {
                    if (fieldName !== 'conditionType')
                        data[fieldName] = fieldValue;

                    //for boolean fields we need to check for event.target.cheked    
                    if (fieldName === 'attributeValue' ) {

                        if (this.conditionDefinitions[i].criteria.attributeDatatype === 'Boolean') {
                            data[fieldName] = event.target.checked;
                        }
                        //if selected attribute is referecne, then get corresponsing lookup label
                        //to show on condition definition
                        if (this.conditionDefinitions[i].criteria.attributeDatatype
                                                                        === 'Reference') {
                            data.attributeLookUpLabel = event.detail.label;
                        }
                    }

                    this.attributeHandler(event,fieldName,data,this.conditionDefinitions,
                                            i,this.conditionDefinitions[i].conditionType);
                    this.conditionDefinitions[i].criteria =
                    { ...this.conditionDefinitions[i].criteria,...data };
                } else {
                    //timepart
                    this.conditionDefinitions[i].recurrenceRule = this.recModelManager;
                }
            }
        }
    }

    attributeHandler (event,fieldName,data,conditionDefinitions,rowIndex,conditionType) {

        if (fieldName === 'attributeCategory') {
            this.handleAttributeCategoryChange(event,rowIndex,conditionType);
            data.operator = null; //set oprator to null when category is changed
        }
        if (fieldName === 'attribute') {
            const dataType = event.detail.secondary;
            const attribute = event.detail.value;
            this.toggleAttributeChange(dataType,conditionDefinitions,rowIndex);
            data.attributeName = event.target.valueLabel;
            data.attributeDatatype = dataType;
            this.populateDefaultValue(attribute,conditionDefinitions,rowIndex,conditionType);
            this.getOperators(dataType,conditionType,rowIndex);
        }
        return data;
    }

    //populate default value and load picklist values
    populateDefaultValue (attribute,conditionDefinitions,rowIndex,conditionType) {

        const key = attribute;
        const data = this.dataTypeMap.get(key) === undefined ? null :
                                    this.dataTypeMap.get(key);

        if (conditionType.toLowerCase() === FREQUENCY.toLowerCase()) {
            conditionDefinitions[rowIndex].frequency.attributeValue = data === null ?
                                                                     null : data.defaultValue;
            conditionDefinitions[rowIndex].frequency.picklistValues = data === null ?
                                                                     null : data.picklistValues;
            conditionDefinitions[rowIndex].frequency.referenceTo = data === null ?
                                                                     null : data.referenceTo;
        } else if (conditionType.toLowerCase() === CRITERIA.toLowerCase()) {
            conditionDefinitions[rowIndex].criteria.attributeValue = data === null ?
                                                                     null : data.defaultValue;
            conditionDefinitions[rowIndex].criteria.picklistValues = data === null ?
                                                                     null : data.picklistValues;
            conditionDefinitions[rowIndex].criteria.referenceTo = data === null ?
                                                                     null : data.referenceTo;
        }
    }

    getOperators (dataType,conditionType,rowIndex) {

        const operatorMatrix = conditionType === FREQUENCY ?
                            FREQUENCY_OPERATOR_MATRIX : CRITERIA_OPERATOR_MATRIX;
        for (const operator in operatorMatrix) {
            if (Object.prototype.hasOwnProperty.call(operatorMatrix,operator)) {

                if (dataType !== undefined && (operator.toLowerCase() === dataType.toLowerCase())) {
                    const operators = [];
                    operatorMatrix[operator].forEach(item=>{
                        operators.push({
                            label: item.label,
                            value: item.value
                        });
                    });

                    if (conditionType.toLowerCase() === FREQUENCY.toLowerCase()) {
                        this.conditionDefinitions[rowIndex].frequency =
                        { ...this.conditionDefinitions[rowIndex].frequency,operators };
                    } else if (conditionType.toLowerCase() === CRITERIA.toLowerCase()) {
                        this.conditionDefinitions[rowIndex].criteria =
                        { ...this.conditionDefinitions[rowIndex].criteria,operators };
                    }
                }
            }
        }
    }

    toggleFrequencyChange (fieldName,value,conditionDefinitions,rowIndex) {

        if (fieldName === 'conditionType' && value === FREQUENCY) {
            conditionDefinitions[rowIndex].isFrequency = true;
            conditionDefinitions[rowIndex].isTime = false;
            conditionDefinitions[rowIndex].isCriteria = false;
        } else if (fieldName === 'conditionType' && value === TIME) {
            conditionDefinitions[rowIndex].isFrequency = false;
            conditionDefinitions[rowIndex].isTime = true;
            conditionDefinitions[rowIndex].isCriteria = false;
        } else if (fieldName === 'conditionType' && value === CRITERIA) {
            conditionDefinitions[rowIndex].isFrequency = false;
            conditionDefinitions[rowIndex].isTime = false;
            conditionDefinitions[rowIndex].isCriteria = true;
        }
    }
    //==============Toogle the attribute field based on selected attribute datatype============//
    toggleAttributeChange (dataType,conditionDefinitions,rowIndex) {

        const datatype = dataType !== undefined ? dataType.toLowerCase() : null;

        if (datatype === 'text' || datatype === 'string') {
            conditionDefinitions[rowIndex].isText = true;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = false;
        } else if (datatype === 'number' || datatype === 'currency' || datatype === 'double'
            || datatype === 'integer') {
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = true;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = false;
        } else if (datatype === 'boolean') {
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = true;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = false;
        } else if (datatype === 'date') {
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = true;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = false;
        } else if (datatype === 'datetime') {
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = true;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = false;
        }
        else if (datatype === 'picklist') {
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = true;
            conditionDefinitions[rowIndex].isReference = false;
        } else if (datatype === 'reference') {
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = true;
        } else {
            //when datatype is null, set all types of fields to false
            conditionDefinitions[rowIndex].isText = false;
            conditionDefinitions[rowIndex].isBoolean = false;
            conditionDefinitions[rowIndex].isDate = false;
            conditionDefinitions[rowIndex].isDatetime = false;
            conditionDefinitions[rowIndex].isNumber = false;
            conditionDefinitions[rowIndex].isPicklist = false;
            conditionDefinitions[rowIndex].isReference = false;
        }
  }

    onIntervalChange (event) {
        const { intervalManager } = this;
        const { detail: { value }} = event;
        this.interval = parseFloat(value);
        intervalManager.setInterval(value);
        this.recModelManager.logInnerDataModel();

    }

    handleFrequencyChange (event) {
        const { detail: { value }} = event;
        this.setFrequency(value);

    }

    setFrequency (value) {

        const { frequencyManager } = this;
        frequencyManager.setFrequency(value);
        this.isFrequencyDay = frequencyManager.isDaySelected;
        this.isFrequencyWeek = frequencyManager.isWeekSelected;
        this.isFrequencyMonth = frequencyManager.isMonthSelected;
        this.isFrequencyYear = frequencyManager.isYearSelected;
    }

    /**
     * =========== end schedule Control======================
     */
    onEndScheduleRadioChange ( event ) {
        const { endScheduleManager,
            enumEndScheduleOptions,
            endScheduleRadioSelection,
            endScheduleRadioButton,
        } = this;
        const valueSelected = event.srcElement.value;
        endScheduleManager.setSelection(valueSelected);
        if (valueSelected === enumEndScheduleOptions.on) {
            endScheduleRadioSelection.disableOccurence = true;
            endScheduleRadioSelection.disableDate = false;
            endScheduleRadioButton.on = true;
            endScheduleRadioButton.after = false;
            endScheduleRadioButton.never = false;
        } else if (valueSelected === enumEndScheduleOptions.after) {
            endScheduleRadioSelection.disableDate = true;
            endScheduleRadioSelection.disableOccurence = false;
            endScheduleRadioButton.on = false;
            endScheduleRadioButton.after = true;
            endScheduleRadioButton.never = false;
        } else {
            endScheduleRadioSelection.disableDate = true;
            endScheduleRadioSelection.disableOccurence = true;
            endScheduleRadioButton.on = false;
            endScheduleRadioButton.after = false;
            endScheduleRadioButton.never = true;
        }

    }

    onEndScheduleChange (event) {
        const { detail: { value }} = event;
        const {
            endScheduleManager,
            endScheduleValues,
            endScheduleRadioButton
        } = this;
        const qryOccurenceInput = this.template.querySelector('.qryOccurences');
        const dateInputEndSched = this.template.querySelector('.endScheduleDate');
        if (endScheduleRadioButton.on) {
            endScheduleValues.on = value;
            dateInputEndSched.setCustomValidity('');
        } else if (endScheduleRadioButton.after) {
            endScheduleValues.after = parseFloat(value);
            qryOccurenceInput.setCustomValidity('');
            qryOccurenceInput.reportValidity();

        }
        endScheduleManager.setEndScheduleValue(value);
        this.recModelManager.logInnerDataModel();

    }

    /**
   * ========================= Week Control===========================
   */
    onWeekChange ( event ) {
        const { value: weekSelectedValue } = event.srcElement;
        const { weekManager, weekSelectedList, weekDayNameList } = this;
        weekSelectedList[weekSelectedValue] = !weekSelectedList[weekSelectedValue];
        weekManager.setSelectedOption(weekSelectedList);
        this.recModelManager.logInnerDataModel();
        this.weekDayNameList = weekDayNameList.map( item => {
            if (item.weekDay === weekSelectedValue) {
                item.selected = weekSelectedList[weekSelectedValue];
            }
            return item;
        });
    }

    /**
     * =========================month control=======================
     */
    onRadioChangeForMonthSelection (event) {
        const {
            monthRadioSelection,
            enumMonthRadioValues,
            monthManager,
            monthRadioButton,
        } = this;
        const valueSelected = event.srcElement.value;
        if (valueSelected === enumMonthRadioValues.monthDay) {
            monthRadioSelection.disableMonthDay = false;
            monthRadioSelection.disableDayPosition = true;
            monthRadioButton.dayPosition = false;
            monthRadioButton.monthDay = true;
        } else {
            monthRadioSelection.disableMonthDay = true;
            monthRadioSelection.disableDayPosition = false;
            monthRadioButton.dayPosition = true;
            monthRadioButton.monthDay = false;
        }
        monthManager.setSelectedOption(valueSelected);
        this.recModelManager.logInnerDataModel();
    }

    onMonthComboboxChange (event) {
        const { monthManager } = this;
        const { value: selectionValue } = event.detail;
        const subOptionKey = event.srcElement.name;
        this.monthSubOptionValues[subOptionKey] = selectionValue;
        monthManager.setSelectedSubOption({ [subOptionKey]: selectionValue });
        this.recModelManager.logInnerDataModel();
    }

    /**
     * 
     * ========================year control================ 
     */

    onradioChangeForYearSection (event) {
        const {
            yearRadioSelection,
            enumYearRadioValues,
            yearManager,
            yearRadioButton,
        } = this;
        const valueSelected = event.srcElement.value;
        if (valueSelected === enumYearRadioValues.monthAndDay) {
            yearRadioSelection.disableMonthDay = false;
            yearRadioSelection.disableMonthWeekDay = true;
            yearRadioButton.monthDay = true;
            yearRadioButton.monthWeekDay = false;
        } else {
            yearRadioSelection.disableMonthDay = true;
            yearRadioSelection.disableMonthWeekDay = false;
            yearRadioButton.monthDay = false;
            yearRadioButton.monthWeekDay = true;
        }
        yearManager.setYearSelectedOption(valueSelected);
        this.recModelManager.logInnerDataModel();
    }

    onYearComboboxChange (event) {
        const { yearManager } = this;
        const { value: selectionValue } = event.detail;
        const subOptionKey = event.srcElement.name;
        yearManager.setYearSubOption({ [subOptionKey]: selectionValue });
        this.recModelManager.logInnerDataModel();
    }

    /**
     * Adds new condition type
     */
    createRow (conditionDefinitions) {
        const conditionType = {}

        if (conditionDefinitions.length > 0) {
            conditionType.index = conditionDefinitions[conditionDefinitions.length - 1].index + 1;
        } else {
            conditionType.index = 1;
        }

        conditionDefinitions.push(conditionType);
        this.conditionDefinitions.detail = conditionDefinitions;
        //add condition types for each row, to identify for time and frequecny/criteria types
        this.toggleTimeConditionType(conditionType);
    }

    /*************************************************************
    if time conditiontype is added once, then remove time 
    conditiontype for rest of the conditions
    ************************************************************/
    toggleTimeConditionType (conditionType) {

        const rowIndex = conditionType.index - 1;
        if (this.conditionDefinitions) {

            const numberOfTimeConditionType =
                        this.conditionDefinitions.filter((item) => (item.conditionType === TIME));
            if (numberOfTimeConditionType.length === 1) {
                const timeIndex = this.conditionTypeValues.findIndex(item => item.value === TIME)
                //if time index found,then remove time condtiontype
                if (timeIndex !== -1) {
                    this.conditionTypeValues.splice(timeIndex,1);
                    this.conditionDefinitions[rowIndex].conditionTypes = this.conditionTypeValues;
                } else {
                    this.conditionDefinitions[rowIndex].conditionTypes = this.conditionTypeValues;
                }
            } else {
                this.conditionDefinitions[rowIndex].conditionTypes = this.originalConditionTypes;
            }
        }
        return this.conditionDefinitions[rowIndex].conditionTypes;
    }

    /**
     * Removes the condition type
     */
    handleDelete (event) {

        const toBeDeletedRowIndex = event.currentTarget.dataset.id;
        const conditionDefinitions = [];
        for (let i = 0; i < this.conditionDefinitions.length; i++) {
            const clonedRecord = Object.assign({}, this.conditionDefinitions[i]); //cloning object
            if (parseInt(clonedRecord.index,10) !== parseInt(toBeDeletedRowIndex,10)) {
                conditionDefinitions.push(clonedRecord);
            }
        }

        for (let i = 0; i < conditionDefinitions.length; i++) {
            conditionDefinitions[i].index = i + 1;
        }
        this.conditionDefinitions = conditionDefinitions;
    }

    handleAddConditionType () {

        this.createRow(this.conditionDefinitions);
    }

    handleCancel () {
        this.conditionDefinitions = [];
        this.dispatchEvent(new CustomEvent("closemodal"));
    }

    buildAdvancedExpressionCriteria () {

        if (this.workRule.advancedExpression === undefined ||
            this.workRule.advancedExpression === '' ) {
            if (this.conditionDefinitions.length > 1) {
                const conditionDefinationCnt = this.conditionDefinitions.length;
                let advancedCondition = '';
                for (let i = 1 ; i <= conditionDefinationCnt ; i++) {
                    advancedCondition = advancedCondition + i + ' AND ';
                }
                advancedCondition = advancedCondition.slice(0, -5);
                this.workRule.advancedExpression = advancedCondition;
            } else {
                this.workRule.advancedExpression = '1';
            }
        }
    }

    //Save
    handleSave () {
        this.apiInProgress = true;
        const componentList = this.template.querySelectorAll(WORKRULE_INPUT_FIELD_CLASS);
        if (!isValidInput(componentList)) {
            return;
        }
        if (!this.validateAdvancedExpression()) {
            return;
        }

        this.buildAdvancedExpressionCriteria();

        if (this.conditionDefinitions && this.conditionDefinitions.length > 0) {
            //if recurrence pattren is selected, then update the pattren string
            this.conditionDefinitions.forEach(item => {
                if (item.conditionType === TIME) {
                    const recurrencePattrenString = this.recModelManager.getRecurrenceString();
                    item.recurrenceRule = recurrencePattrenString;
                }
                //set sequence as per the index
                item.sequence = item.index;
            });
            this.workRule.detail = this.conditionDefinitions;
            this.apiInProgress = false;
            this.dispatchEvent(new CustomEvent("saveworkrule", { detail:
                { value: this.workRule,action: this.rowAction }
            }));
        } else {
            this.apiInProgress = false;
            this.showToast('',labelAddConditionTypeToWorkRule,'error')
        }
    }

    //show Toast Message if any errors/success
    showToast (title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

     /*
        =================== Edit Workrule Template Init Setup ============
    */
        setupBeforeEdit () {

            const state = this.recModelManager.selectedState;
            const { frequencyManager } = this;
            this.isFrequencyDay = frequencyManager.isDaySelected;
            this.isFrequencyWeek = frequencyManager.isWeekSelected;
            this.isFrequencyMonth = frequencyManager.isMonthSelected;
            this.isFrequencyYear = frequencyManager.isYearSelected;

            this.editFrequencyValue = state.frequency;
            if (state.frequency === ENUM_FrequencyOptions[MONTHS]) {
                this._editSetupForMonth();
            } else if (state.frequency === ENUM_FrequencyOptions[YEARS]) {
                this._editSetupForYear();
            } else if (state.frequency === ENUM_FrequencyOptions[WEEKS]) {
                this._editSetupForWeek();
            }
            this._editSetupForInterval()
            this._editSetupForEndSchedule();
        }

        _editSetupForMonth () {
            const { monthRadioButton } = this;
            const state = this.recModelManager.selectedState;
            const { selectedSubOption: { subSelection }} = state;
            this.monthRadioSelection.disableDayPosition = !(
                subSelection === ENUM_MonthScheduleOptions.dayPosition);
            this.monthRadioSelection.disableMonthDay = !(
                subSelection === ENUM_MonthScheduleOptions.monthDay);
            const { subKeys } = state.selectedSubOption;
            if (subKeys) {
                subKeys.forEach(key => {
                    this.monthSubOptionValues[key] = state.selectedSubOption[key];
                });
            }
            monthRadioButton.dayPosition = !this.monthRadioSelection.disableDayPosition;
            monthRadioButton.monthDay = !this.monthRadioSelection.disableMonthDay;
        }

        _editSetupForYear () {
            const { yearRadioButton } = this;
            const state = this.recModelManager.selectedState;
            this.yearRadioSelection.disableMonthDay = !(
                state.selectedSubOption.subSelection === ENUM_YearScheduleOptions.monthAndDay);
            this.yearRadioSelection.disableMonthWeekDay = !(
                state.selectedSubOption.subSelection ===
                ENUM_YearScheduleOptions.monthAndWeekdayAndPos);
            const isMonthDayDisabled = this.yearRadioSelection.disableMonthDay;
            const { subKeys } = state.selectedSubOption;
            if (subKeys) {
                subKeys.forEach(key => {
                    this.yearSubOptionValues[key] = state.selectedSubOption[key];
                });
            }
            const monthValue = this.yearSubOptionValues.month;
            if (isMonthDayDisabled) {
                this.yearSubOptionValues.monthDayMonth = i18n.january;
            } else {
                this.yearSubOptionValues.month = i18n.january;
                this.yearSubOptionValues.monthDayMonth = monthValue;
            }
            yearRadioButton.monthDay = !this.yearRadioSelection.disableMonthDay;
            yearRadioButton.monthWeekDay = !this.yearRadioSelection.disableMonthWeekDay;
        }

        _editSetupForWeek () {
            const state = this.recModelManager.selectedState;
            const dayCollection = state.selection;
            this.weekSelectedList = { ...dayCollection };
            this.weekDayNameList = this.weekDayNameList.map(item => {
                return {
                    weekDay: item.weekDay,
                    selected: !!dayCollection[item.weekDay],
                    label: item.weekDay.slice(0,3)
                };
            });
        }

        _editSetupForInterval () {
            const state = this.recModelManager.selectedState;
            const { interval } = state;
            this.interval = interval;
        }

        _editSetupForEndSchedule () {
            const { enumEndScheduleOptions,
                endScheduleRadioSelection,
                endScheduleRadioButton } = this;
            const state = this.recModelManager.selectedState;
            const { endSchedule: { selection, value } = {}} = state;
            if (selection && selection !== enumEndScheduleOptions.never ) {
                this.endScheduleValues[selection] = value;
                endScheduleRadioSelection.disableOccurence =
                (selection === enumEndScheduleOptions.on);
                endScheduleRadioSelection.disableDate =
                (selection === enumEndScheduleOptions.after);
                endScheduleRadioButton.on = !endScheduleRadioSelection.disableDate;
                endScheduleRadioButton.after = !endScheduleRadioSelection.disableOccurence;
                endScheduleRadioButton.never = false;
            } else {
                endScheduleRadioButton.never = true;
                endScheduleRadioSelection.disableDate = true;
                endScheduleRadioSelection.disableOccurence = true;
            }
        }
}