import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { parseErrorMessage } from 'c/utils';
import {
    OBJECT_ICONS,
} from 'c/utils';

import RecurrencePatternModel,
{
    ENUM_YearScheduleOptions,
    ENUM_SubOptionKeyNames,
    ENUM_MonthScheduleOptions,
    ENUM_WeekDayOptions,
    ENUM_endScheduleOptions,
    ENUM_FrequencyOptions,
} from "./recurrencePatternModel";

import WORK_TYPE_OBJECT from '@salesforce/schema/WorkType';
import RECORDSET_FILTER_CRITERIA_OBJECT from '@salesforce/schema/RecordsetFilterCriteria';
import MAIN_WORK_RULE_OBJECT from '@salesforce/schema/MaintenanceWorkRuleTemplate__c';
import WORK_RULE_TYPE_FIELD from '@salesforce/schema/MaintenanceWorkRuleTemplate__c.Type__c';
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
import labelError from '@salesforce/label/c.Error_ReviewErrors';
import labelGeneralInformation from '@salesforce/label/c.Label_GeneralInformation';
import labelEndSchedule from '@salesforce/label/c.Label_EndSchedule';
import labelOccurences from '@salesforce/label/c.Label_Occurences';
import labelOn from '@salesforce/label/c.Label_On';
import labelOnThe from '@salesforce/label/c.Label_OnThe';
import labelOnDay from '@salesforce/label/c.Label_OnDay';
import labelOf from '@salesforce/label/c.Label_Of';
import labelScheduleEvery from '@salesforce/label/c.Label_ScheduleEvery';
import First from '@salesforce/label/c.Label_First';
import MONTHS from '@salesforce/label/c.Label_enumMONTHS';
import WEEKS from '@salesforce/label/c.Label_enumWEEKS';
import YEARS from '@salesforce/label/c.Label_enumYEARS';
import DAYS from '@salesforce/label/c.Label_enumDAYS';
import labelAfter from '@salesforce/label/c.Label_AfterRadio';
import labelNever from '@salesforce/label/c.Label_NeverRadio';
import sunday from '@salesforce/label/c.Label_Sunday';
import january from '@salesforce/label/c.Label_January';
import missingScheduleErrorMessage from '@salesforce/label/c.Label_MissingFrequencySelectionError';
import labelErrorLowNumber from '@salesforce/label/c.Error_TheNumberIsLow';
import labelNotValidNumber from '@salesforce/label/c.Message_BadInputNumber';
import labelBlankDateValue from '@salesforce/label/c.Label_BlankDateValue';
import labelMaintenanceWorkRuleType from '@salesforce/label/c.Label_MaintenanceWorkRuleType';
import labelCriteriaDefinition from '@salesforce/label/c.Label_CriteriaDefinition';
import labelRecordsetFilterCriteria from '@salesforce/label/c.Label_RecordsetFilterCriteria';
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
    labelOn: labelOn.toLowerCase(),
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
    labelError,
    labelGeneralInformation,
    labelEndSchedule,
    labelOccurences,
    labelOnThe,
    labelOnDay,
    labelOf,
    labelScheduleEvery,
    labelAfter,
    labelNever,
    missingScheduleErrorMessage,
    sunday,
    january,
    labelErrorLowNumber,
    labelBlankDateValue,
    workRuleType: labelMaintenanceWorkRuleType,
    criteriaDefinition: labelCriteriaDefinition,
    recordsetFilterCriteria: labelRecordsetFilterCriteria,
};

const WEEK_DAYS = Object.keys(ENUM_WeekDayOptions).map( key => ({
    weekDay: key, selected: false, label: key.slice(0,3)  }));

const ICON_OPEN =  "utility:chevrondown";
const ICON_CLOSED = "utility:chevronright";

const INITIALIZE_STATE_PATTERNS = [
    'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=1;COUNT=1',
    'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYSETPOS=1;BYDAY=SU;BYMONTH=1',
    'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYMONTH=1;BYMONTHDAY=1',
    'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYMONTH=1;BYSETPOS=1;BYDAY=SU'
];
const DEFAULT_STATE = 'FREQ=MONTHLY;INTERVAL=1;BYSETPOS=1;BYDAY=SU';
const CALENDAR_VALUE = 'Calendar';
const CRITERIA_VALUE = 'CriteriaValue';

export default class MplnWorkRuleTemplateDetail extends LightningElement {

    @api
    selectedProductName = ''

    @api
    isEdit = false;

    @api
    workRuleData = { workRuleId: '' };

    filterCriteriaApiName = RECORDSET_FILTER_CRITERIA_OBJECT.objectApiName;
    valueFilterCriteria = '';
    lookupIconForRFC = OBJECT_ICONS.recordsetfiltercriteria;
    refFieldRFC = "Name";

    apiNameWorkType = WORK_TYPE_OBJECT.objectApiName;
    advancedSearchConfig = false;
    valueWorkType = '';
    workTypeName = ''
    sortOrder = '';
    workRuleTitle = ''
    workRuleType = null;
    editFrequencyValue = ENUM_FrequencyOptions[MONTHS];
    refFieldWorkType = "Name";
    lookupIcon = OBJECT_ICONS.worktype;
    subOptionKeyNames = ENUM_SubOptionKeyNames;
    workRuleTypeOption = [];
    value = '';

    recModelManager = null;
    isFrequencyDay = false;

    isFrequencyWeek = false;
    weekControlOptions = null;

    enumWeekDayValues = { ...ENUM_WeekDayOptions };
    weekSelectedList = {};


    isFrequencyMonth = true;
    monthControlOptions = null;
    enumMonthRadioValues = ENUM_MonthScheduleOptions;

    isFrequencyYear = false;
    enumYearRadioValues = ENUM_YearScheduleOptions;


    enumEndScheduleOptions = ENUM_endScheduleOptions;
    detailError = null;

    showGeneralInformation = true;
    generalInformationIcon = ICON_OPEN;
    showRecurrenceSection = true;
    recurrenceSectionIcon = ICON_OPEN;
    showCriteriaDefinition = false;
    criteriaDefinitionIcon = ICON_CLOSED;

    criteriaSectionButtonDisabled = true;
    recurrencPattSectionButtonDisabled = false;

    @wire(getObjectInfo, { objectApiName: MAIN_WORK_RULE_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: WORK_RULE_TYPE_FIELD
    })
    setWorkRuleTypeOptions ({ error, data }) {
        if (data) {
            this.workRuleTypeOption = data.values;
        } else if (error) {
            this.detailError = parseErrorMessage(error);
        }
    }

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

    @track
    interval = null;

    @track
    endScheduleValues = {
        on: '' ,
        after: 1
    };

    @track
    onEditData = {};



    @api
    onSave () {

        if (this.isError) {
            this.detailError = i18n.labelError;
            const inputList = this.template.querySelectorAll('lightning-input');
            inputList.forEach(inputItem => inputItem.reportValidity());
            if (!this.valueFilterCriteria && this.workRuleType === CRITERIA_VALUE) {
                const rfcInput = this.template.querySelector(
                    '.svmx-recordset-filter-criteria'
                );
                rfcInput.reportValidity();
            }
            return { error: true };
        }
        const { isEdit, workRuleData } = this;
        const dataToSave = {
            workTypeId: this.valueWorkType,
            workTypeName: this.workTypeName,
            sortOrder: this.sortOrder,
            workRuleTitle: this.workRuleTitle,
            workRuleType: this.workRuleType,
        };
        if (this.workRuleType === CALENDAR_VALUE) {
            dataToSave.recurrencePattern = this.recModelManager.getRecurrenceString();
            dataToSave.recordsetFilterCriteriaId = null;
        } else if (this.workRuleType === CRITERIA_VALUE) {
            dataToSave.recurrencePattern = null;
            dataToSave.recordsetFilterCriteriaId = this.valueFilterCriteria;
        }
        if (isEdit) {
            dataToSave.workRuleId = workRuleData.workRuleId;
        }
        return dataToSave;
    }

    @api recurrencePatternNotValid ({ errorMessage }) {
        this.detailError = errorMessage;
    }

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


    connectedCallback () {
        const { isEdit, workRuleData } = this;
        if (isEdit) {
            const { recurrencePattern } = workRuleData;
            this.onEditData = { ...workRuleData };
            this.valueWorkType = workRuleData.workTypeId;
            this.workRuleTitle = workRuleData.workRuleTitle;
            this.sortOrder = workRuleData.sortOrder;
            this.valueWorkType = workRuleData.workTypeId;
            this.workRuleType = workRuleData.workRuleType;
            this.valueFilterCriteria = workRuleData.recordsetFilterCriteriaId;
            if (recurrencePattern) {
                this.recModelManager.parseRecPatternToState(recurrencePattern);
                this.setupBeforeEdit();
                this.enableRecurrenceSection();
            } else {
                this.enableCriteriaSection();
            }
        } else {
            this.onEditData = {
                workRuleId: ''
            };
            this.workRuleType = CALENDAR_VALUE;
        }
    }

    renderedCallback () {
        if (this.workRuleType === CALENDAR_VALUE) {
            this.greyOutCriteriaSection();
        } else if (this.workRuleType === CRITERIA_VALUE) {
            this.greyOutRecurrenceSection();
        }
    }

    get isSelectedProduct () {
        return !!this.selectedProductName;
    }

    get isCriteriaBasedDisabled () {
        return !this.selectedProductName;
    }

    get rfcFilter () {
        return `SourceObject = 'MaintenanceWorkRule' AND
        FilteredObject = 'Asset' AND IsActive = true`;
    }

    onIntervalChange (event) {
        const { intervalManager } = this;
        const { detail: { value }} = event;
        this.interval = parseFloat(value);
        intervalManager.setInterval(value);
        this.recModelManager.logInnerDataModel();
    }

    onLookupChange (event) {
        const { detail: { label, value }} = event;
        this.valueWorkType = value;
        this.workTypeName = label;
    }

    onLookupChangeRFC (event) {
        const { detail: { value }} = event;
        this.valueFilterCriteria = value;
    }

    onSortOrderChange (event) {
        const { detail: { value }} = event;
        const intValue = parseInt(value,10);
        if (intValue) {
            this.onEditData.sortOrder = intValue;
            this.sortOrder = intValue;
        } else {
            this.sortOrder = value;
        }
    }

    onTemplateTitleChange (event) {
        const { detail: { value }} = event;
        this.workRuleTitle = value;
    }

    get i18n () {
        return i18n;
    }

    get frequencyOptions () {
        const { frequencyManager } = this;
        return frequencyManager.getFrequencyOptions();
    }

    handleFrequencyChange (event) {
        const { detail: { value }} = event;
        this.setFrequency(value);
    }

    handleWorkRuleTypeChange (event) {
        const { detail: { value }} = event;
        this.workRuleType = value;
        if (value === CALENDAR_VALUE) {
            this.enableRecurrenceSection();
            this.greyOutCriteriaSection();
        } else if (value === CRITERIA_VALUE) {
            this.enableCriteriaSection();
            this.greyOutRecurrenceSection();
        }
    }

    enableRecurrenceSection () {
        this.showCriteriaDefinition = false;
        this.criteriaDefinitionIcon = ICON_CLOSED;
        this.showRecurrenceSection = true;
        this.recurrenceSectionIcon = ICON_OPEN;
        this.criteriaSectionButtonDisabled = true;
        this.recurrencPattSectionButtonDisabled = false;
    }

    enableCriteriaSection () {
        this.showCriteriaDefinition = true;
        this.criteriaDefinitionIcon = ICON_OPEN;
        this.showRecurrenceSection = false;
        this.recurrenceSectionIcon = ICON_CLOSED;
        this.criteriaSectionButtonDisabled = false;
        this.recurrencPattSectionButtonDisabled = true;
    }

    greyOutRecurrenceSection () {
        const elementCriteria = this.template.querySelector('.svmx-criteria-title');
        if (elementCriteria) {
            elementCriteria.classList.remove('svmx-section-title-disabled');
        }
        const elementRecurrence = this.template.querySelector('.svmx-recurrence-title');
        if (elementRecurrence) {
            elementRecurrence.classList.add('svmx-section-title-disabled');
        }
    }

    greyOutCriteriaSection () {
        const elementCriteria = this.template.querySelector('.svmx-criteria-title');
        if (elementCriteria) {
            elementCriteria.classList.add('svmx-section-title-disabled');
        }
        const elementRecurrence = this.template.querySelector('.svmx-recurrence-title');
        if (elementRecurrence) {
            elementRecurrence.classList.remove('svmx-section-title-disabled');
        }
    }

    handleClickGeneralInformationSection () {
        this.showGeneralInformation = !this.showGeneralInformation;
        this.generalInformationIcon = (
            this.showGeneralInformation ? ICON_OPEN : ICON_CLOSED);
    }

    handleClickCriteriaDefinitionSection () {
        this.showCriteriaDefinition = !this.showCriteriaDefinition;
        this.criteriaDefinitionIcon =
            this.showCriteriaDefinition ? ICON_OPEN : ICON_CLOSED;
    }

    handleClickRecurrenceSection () {
        this.showRecurrenceSection = !this.showRecurrenceSection;
        this.recurrenceSectionIcon = (
            this.showRecurrenceSection ? ICON_OPEN : ICON_CLOSED);
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
            endScheduleRadioSelection.disableOccurence = (selection === enumEndScheduleOptions.on);
            endScheduleRadioSelection.disableDate = (selection === enumEndScheduleOptions.after);
            endScheduleRadioButton.on = !endScheduleRadioSelection.disableDate;
            endScheduleRadioButton.after = !endScheduleRadioSelection.disableOccurence;
            endScheduleRadioButton.never = false;
        } else {
            endScheduleRadioButton.never = true;
            endScheduleRadioSelection.disableDate = true;
            endScheduleRadioSelection.disableOccurence = true;
        }
    }

    /**
     * ========= Error Handling ===========
     */

    get isError () {
        let result;
        if (this.workRuleType === CALENDAR_VALUE) {
            const {
                workRuleTitle,
                sortOrder,
                interval,
                endScheduleRadioButton: { on: isDateSelected, after: isOccurenceSelected }
            } = this;
            const dateInputEndSched = this.template.querySelector('.endScheduleDate');
            const isIntervalNonZeroPositive = interval > 0;
            const qryOccurenceInput = this.template.querySelector('.qryOccurences');
            let isDateValid = true;
            if (isDateSelected) {
                const isBlank = !dateInputEndSched.value;
                isDateValid = dateInputEndSched.validity.valid;
                if (isBlank && isDateValid) {
                    isDateValid= false;
                    dateInputEndSched.setCustomValidity(labelBlankDateValue);
                }
            }
            let isOccurenceValid = true;
            if (isOccurenceSelected) {
                isOccurenceValid = qryOccurenceInput.validity.valid;
                const occurenceValue = this.endScheduleValues.after;
                if (!occurenceValue) {
                    qryOccurenceInput.setCustomValidity(labelNotValidNumber);
                    isOccurenceValid = false;
                } else {
                    qryOccurenceInput.setCustomValidity("");
                    isOccurenceValid = true;
                }
            }
            const isSortOrderValid = this.template.querySelector('.sortOrderInput').validity.valid;
            result = (!(workRuleTitle && sortOrder )
            || !isIntervalNonZeroPositive
            || !isDateValid
            || !isOccurenceValid
            || !isSortOrderValid);
        } else if (this.workRuleType === CRITERIA_VALUE) {
            const {
                workRuleTitle,
                sortOrder,
                valueFilterCriteria
            } = this;
            result = (!(workRuleTitle && sortOrder )
            || !valueFilterCriteria);
        }
        return result;
    }
}