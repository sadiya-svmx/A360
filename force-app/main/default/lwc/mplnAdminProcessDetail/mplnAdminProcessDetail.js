import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TimeZoneSidKey from '@salesforce/schema/User.TimeZoneSidKey';
import UserTimeZone from '@salesforce/i18n/timeZone';

import {
    isEmptyString,
    PAGE_ACTION_TYPES,
    ADMIN_MODULES,
    parseErrorMessage,
    normalizeDeveloperName,
    ICON_NAMES,
    handleMenuSelection,
    verifyApiResponse
} from 'c/utils';
import RecurrencePatternModel,
{
    ENUM_YearScheduleOptions,
    ENUM_SubOptionKeyNames,
    ENUM_MonthScheduleOptions,
    ENUM_WeekDayOptions,
    ENUM_FrequencyOptions,
    ENUM_TimeOptions
} from './recurrencePatternModel';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelFormValidation from '@salesforce/label/c.Message_GenericFormValidationError';
import labelSave from '@salesforce/label/c.Button_Save';
import labelErrorLowNumber from '@salesforce/label/c.Error_TheNumberIsLow';
import title_MaintenancePlanProcessing from '@salesforce/label/c.Title_MaintenancePlanProcessing';
import labelMappingEditor from '@salesforce/label/c.Label_Mapping_Editor';
import labelEditorfirstLink from '@salesforce/label/c.Mapping_Editor_Link_1_Label';
import labelEditersecLink from '@salesforce/label/c.Mapping_Editor_Link_2_Label';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelScheduleEvery from '@salesforce/label/c.Label_ScheduleEvery';
import labelOnDay from '@salesforce/label/c.Label_OnDay';
import labelOnThe from '@salesforce/label/c.Label_OnThe';
import labelCopyOf from '@salesforce/label/c.Label_CopyOf';
import labelOn from '@salesforce/label/c.Label_On';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelWasSaved from '@salesforce/label/c.Label_WasSaved';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelMplanProcess from '@salesforce/label/c.Message_MaintenancePlanProcess';
import labelProperties from '@salesforce/label/c.Label_Properties';
import labelProcessName from '@salesforce/label/c.Label_ProcessName';
import labelErrorProcessName from '@salesforce/label/c.Error_EnterProcessName';
import labelActive from '@salesforce/label/c.Label_Active';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelDeveloperNameMissing from '@salesforce/label/c.Message_EnterDeveloperName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelDefault from '@salesforce/label/c.Label_Default';
import labelMappingRules from '@salesforce/label/c.Label_Mapping_Rules';
import labelSourceObject from '@salesforce/label/c.Label_SourceObject';
import labelTargetObject from '@salesforce/label/c.Label_TargetObject';
import labelMappingName from '@salesforce/label/c.Label_Mapping_Name';
import labelAssignmentRules from '@salesforce/label/c.Title_AssignmentRules';
import labelAssignWOTo from '@salesforce/label/c.Label_AssignWOTo';
import labelUser from '@salesforce/label/c.Label_User';
import labelQueue from '@salesforce/label/c.Label_Queue';
import labelLoggingConfig from '@salesforce/label/c.Label_LoggingConfiguration';
import labelEnableLogNotification from '@salesforce/label/c.Label_EnableLoggingNotifications';
import labelSendSuccessNotificationTo from '@salesforce/label/c.Label_SendSuccessNotification';
import labelSendFailureNotificationTo from '@salesforce/label/c.Label_SendFailureNotification';
import titleProcessScheduling from '@salesforce/label/c.Title_ProcessScheduling';
import labelProcessScheduleDescription from '@salesforce/label/c.Label_ProcessScheduleDescription';
import labelProcessLastRun from '@salesforce/label/c.Label_ProcessLastRun';
import labelProcessRunStatus from '@salesforce/label/c.Label_ProcessRunStatus';
import labelOf from '@salesforce/label/c.Label_Of';
import labelAt from '@salesforce/label/c.Label_At';
import labelAsset from '@salesforce/label/c.Label_Asset';
import labelObject from '@salesforce/label/c.Label_Object';
import labelDaysInAdvance from '@salesforce/label/c.Label_DaysInAdvance';
import labelHelpTextLoggingNotification from '@salesforce/label/c.HelpText_LoggingNotification';
import labelHelpTextAdvanceWOGeneration from
        '@salesforce/label/c.HelpText_AdvanceWOGeneration';
import DAYS from '@salesforce/label/c.Label_enumDAYS';
import MONTHS from '@salesforce/label/c.Label_enumMONTHS';
import WEEKS from '@salesforce/label/c.Label_enumWEEKS';
import YEARS from '@salesforce/label/c.Label_enumYEARS';
import First from '@salesforce/label/c.Label_First';
import sunday from '@salesforce/label/c.Label_Sunday';
import january from '@salesforce/label/c.Label_January';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import ASSIGN_TO_FIELD from '@salesforce/schema/SM_MaintenancePlanProcess__c.SM_AssignTo__c';
import { getFieldDefinitionsForEntity } from 'c/metadataService';
import getSObjectSupportedQueues
    from '@salesforce/apex/ADM_MaintenanceProcess_LS.getSObjectSupportedQueues';
import getMappingDetails
    from '@salesforce/apex/ADM_ObjectMappingLightningService.getMappingsForObjectList';
import { saveRecentViewItem } from 'c/recentItemService';
import getProcessDetails
    from '@salesforce/apex/ADM_MaintenanceProcess_LS.getProcessDetails';
import saveProcessDetails
    from '@salesforce/apex/ADM_MaintenanceProcess_LS.saveProcessDetails';
import MAINTENANCE_PROCESS_OBJECT from '@salesforce/schema/SM_MaintenancePlanProcess__c';
import USER_OBJECT from '@salesforce/schema/User';

import ASSET_OBJECT from '@salesforce/schema/Asset';
import MAINTENANCEPLAN_OBJECT from '@salesforce/schema/SM_MaintenancePlan__c';

const i18n = {
    save: labelSave,
    cancel: labelCancel,
    cancelModalTitle: labelCancelModalTitle,
    cancelModalContent: labelCancelModal,
    goBack: labelNoGoBack,
    continue: labelYesContinue,
    maintenanceProcessing: title_MaintenancePlanProcessing,
    maintenanacePlanProcess: labelMplanProcess,
    properties: labelProperties,
    processName: labelProcessName,
    enterProcessName: labelErrorProcessName,
    isActive: labelActive,
    developerName: labelDeveloperName,
    developerNameMissing: labelDeveloperNameMissing,
    description: labelDescription,
    isDefault: labelDefault,
    mappingRules: labelMappingRules,
    labelMappingEditor,
    srcObject: labelSourceObject,
    targetObject: labelTargetObject,
    labelMappingName,
    labelEditorfirstLink,
    labelEditersecLink,
    formValidation: labelFormValidation,
    assignmentRules: labelAssignmentRules,
    loading: labelLoading,
    assignWOTo: labelAssignWOTo,
    user: labelUser,
    queue: labelQueue,
    loggingConfig: labelLoggingConfig,
    copyOf: labelCopyOf,
    detailLogNotification: labelEnableLogNotification,
    sendSuccessNotification: labelSendSuccessNotificationTo,
    sendFailureNotification: labelSendFailureNotificationTo,
    processSchedule: titleProcessScheduling,
    processRunDesc: labelProcessScheduleDescription,
    labelErrorLowNumber,
    labelScheduleEvery,
    labelOnDay,
    labelOnThe,
    labelOn,
    labelOf,
    labelAt,
    labelObject,
    labelAsset,
    labelDaysInAdvance,
    sunday,
    january,
    labelHelpTextLoggingNotification,
    labelHelpTextAdvanceWOGeneration,
    wasSaved: labelWasSaved,
    processLastRun: labelProcessLastRun,
    lastRunStatus: labelProcessRunStatus,
    timeZone: UserTimeZone
};

const WEEK_DAYS = Object.keys(ENUM_WeekDayOptions).map( key => ({
    weekDay: key, selected: false, label: key.slice(0,3)  }));

const INITIALIZE_STATE_PATTERNS = [
        'FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=1;COUNT=1',
        'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYSETPOS=1;BYDAY=SU;BYMONTH=1',
        'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYMONTH=1;BYMONTHDAY=1',
        'FREQ=YEARLY;INTERVAL=1;COUNT=1;BYMONTH=1;BYSETPOS=1;BYDAY=SU'
];
const DEFAULT_STATE = 'FREQ=MONTHLY;INTERVAL=1;BYSETPOS=1;BYDAY=SU';

const MAPPINGSOURCEOBJECTS = [
        MAINTENANCEPLAN_OBJECT.objectApiName,
        ASSET_OBJECT.objectApiName
];

const MAPPINGTARGETOBJECTS = [
    'WORKORDER'
];

export default class MplnAdminProcessDetail extends NavigationMixin(
    LightningElement
) {
    currentPageReference
    @track editMode = false;
    @track error;
    @track processRecord = {};
    @track isConfigurableField = false;
    @track isUserAssignment = false;
    @track isQueueAssignment = false;
    @track configurableFieldOptions;
    @track apiInProgress = false;
    @track groupFilter = '';
    @track interval = null;
    @track cancelModalDialogOpen;
    @track itemList = [
        {
            id: 0,
            sourceObject: 'A360 Maintenance Plan',
            targetObject: 'Work Order',
            sourceObjectAPIName: MAINTENANCEPLAN_OBJECT.objectApiName,
            mappingOptions: []
        },
        {
            id: 1,
            sourceObject: 'Asset',
            targetObject: 'Work Order',
            sourceObjectAPIName: 'Asset',
            mappingOptions: []
        }
    ];

    @track
    monthRadioButton = {
        monthDay: false,
        dayPosition: false,
    };

    @track
    monthSubOptionValues = {
        weekDay: i18n.sunday,
        setPos: First,
        monthDay: "1",
    };

    @track
    monthRadioSelection = {
        disableMonthDay: true,
        disableDayPosition: true,
    }

    @track
    yearRadioButton = {
        monthDay: false,
        monthWeekDay: false
    };

    @track
    yearRadioSelection = {
        disableMonthDay: true,
        disableMonthWeekDay: true
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

    _recordId;
    _actionName;
    recModelManager = null;
    editFrequencyValue = ENUM_FrequencyOptions[MONTHS];
    isFrequencyDay = false;
    isFrequencyWeek = false;
    isFrequencyMonth = true;
    enumMonthRadioValues = ENUM_MonthScheduleOptions;
    subOptionKeyNames = ENUM_SubOptionKeyNames;
    isFrequencyYear = false;
    enumYearRadioValues = ENUM_YearScheduleOptions;
    weekControlOptions = null;
    enumWeekDayValues = { ...ENUM_WeekDayOptions };
    weekSelectedList = {};
    showProcessDetail = false;

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        if (pageRef && pageRef.state) {
            this.clearState();
            if (pageRef.state.c__recordId) {
                this._recordId = pageRef.state.c__recordId;
            }

            if (pageRef.state.c__actionName) {
                this._actionName = pageRef.state.c__actionName.toLowerCase();
                this.getMappingRulesInfo();
                this.showProcessDetail = true;
                if (this._actionName === PAGE_ACTION_TYPES.EDIT ||
                    this._actionName === PAGE_ACTION_TYPES.CLONE ) {
                    this.editMode = true;
                    this.getExistingProcessDetails();
                }
            }

            if (pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

        }
    }

    get i18n () {
        return i18n;
    }

    get developerNameDisabled () {
        return this._actionName === PAGE_ACTION_TYPES.EDIT;
    }

    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }

    get timeOptions () {
        return Object.entries(ENUM_TimeOptions).map(([value, label]) => ({ value, label }));
    }

    get assignToObjectOptions () {
        return [
            { label: 'Account' , value: 'Account' },
            { label: i18n.labelAsset , value: 'Asset' },
            { label: 'A360 Maintenance Plan' , value: 'SM_MaintenancePlan__c' }
        ];
    }

    iconSize = 'large';

    @wire(getObjectInfo, { objectApiName: MAINTENANCE_PROCESS_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ASSIGN_TO_FIELD
    })
    setAssignToOptions ({ error, data }) {
        if (data) {
            this.assignToOptions = data.values;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getObjectInfo, { objectApiName: USER_OBJECT })
    userObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: TimeZoneSidKey })
    setTimeZonePicklistValue ({ error, data }) {
        if (data) {
            this.timeZonePicklistValues = data.values;
            this.processRecord.timeZone = UserTimeZone;
        } else if (error) {
            this.error = error;
        }
    }

    constructor () {
        super();
        this.recModelManager = new RecurrencePatternModel();
        this.intervalManager = this.recModelManager.getIntervalManager();
        this.frequencyManager = this.recModelManager.getFrequencyManager();
        this.weekManager = this.recModelManager.getWeekManager();
        this.monthManager = this.recModelManager.getMonthManager();
        this.yearManager = this.recModelManager.getYearManager();

        this.monthControlOptions = this.monthManager.getSubOptions();
        this.weekControlOptions = this.weekManager.getOptions();
        this.yearControlOptions = this.yearManager.getSubOptions();

        this.frequencyManager.setFrequency(ENUM_FrequencyOptions[DAYS]);
        INITIALIZE_STATE_PATTERNS.forEach( reccStr =>
            this.recModelManager.parseRecPatternToState(reccStr));
        this.recModelManager.parseRecPatternToState(DEFAULT_STATE);
        this.monthManager.setSelectedOption(ENUM_MonthScheduleOptions.noOption);
        this.yearManager.setYearSelectedOption(ENUM_YearScheduleOptions.noOption);
    }

    clearState () {
        this.error = null;
        this.showProcessDetail = false;
        this.processRecord = {
            runAt: '0',
            timeZone: UserTimeZone
        };
        this.isConfigurableField = false;
        this.isUserAssignment = false;
        this.isQueueAssignment = false;
        this._recordId = null;
        this._actionName = null;
        this.editMode = false;
        this.apiInProgress = false;
        this.configurableFieldOptions = null;
        this.initializeScheduleToDefaults();
        this.resetMappingOptions();
    }

    resetMappingOptions () {
        this.itemList.forEach(item => {
            item.mappingOptions = [];
            item.objectMapping = null;
        });
    }

    initializeScheduleToDefaults () {
        this.editFrequencyValue = ENUM_FrequencyOptions[MONTHS];
        this.isFrequencyDay = false;
        this.isFrequencyWeek = false;
        this.isFrequencyMonth = true;
        this.interval = null;
        this.isFrequencyYear = false;
        this.weekSelectedList = {};
        this.monthRadioButton = {
            monthDay: false,
            dayPosition: false,
        };
        this.monthSubOptionValues = {
            weekDay: i18n.sunday,
            setPos: First,
            monthDay: "1",
        };
        this.monthRadioSelection = {
            disableMonthDay: true,
            disableDayPosition: true,
        }

        this.yearRadioButton = {
            monthDay: false,
            monthWeekDay: false
        };

        this.yearRadioSelection = {
            disableMonthDay: true,
            disableMonthWeekDay: true
        };

        this.yearSubOptionValues = {
            weekDay: i18n.sunday,
            setPos: First,
            day: '1',
            month: i18n.january,
            monthDayMonth: i18n.january
        };

        this.weekDayNameList = JSON.parse(JSON.stringify(WEEK_DAYS));
    }

    handleNameBlur () {
        if (!this.developerNameDisabled && !this.processRecord.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.processRecord.developerName = normalizeDeveloperName(
                this.processRecord.name,
                maxLength,
                ''
            );
            this.getDeveloperNameInput().value = this.processRecord.developerName;
        }
    }

    handleAssignToChange (event) {
        const selectedValue = event.detail.value;
        this.applyAssignToWorkOrder(selectedValue, null);
    }

    handleAssignToObjectChange (event) {
        const selectedValue = event.detail.value;
        this.processRecord.assignToObject = selectedValue;
        this.getConfigurableUserFields(selectedValue);
    }

    handleTimeChange (event) {
        const selectedValue = event.detail.value;
        this.processRecord.runAt = selectedValue;
    }

    handleTimeZoneChange (event) {
        const selectedValue = event.detail.value;
        this.processRecord.timeZone = selectedValue;
    }

    applyAssignToWorkOrder (selectedValue, assignToObject) {
        this.isConfigurableField = false;
        this.isUserAssignment = false;
        this.isQueueAssignment = false;
        this.processRecord.assignTo = selectedValue;
        if (selectedValue) {
            if (selectedValue === 'Configurable User Field') {
                this.isConfigurableField = true;
                this.getConfigurableUserFields(assignToObject);
            } else if (selectedValue === 'User') {
                this.isUserAssignment = true;
            } else if (selectedValue === 'Queue') {
                this.isQueueAssignment = true;
                this.getQueueForSObject();
            }
        }
    }

    handleFrequencyChange (event) {
        const { detail: { value }} = event;
        this.setFrequency(value);
    }

    handleDefaultCheck (event) {
        this.processRecord.isDefault = event.target.checked;
    }

    handleActiveCheck (event) {
        this.processRecord.isActive = event.target.checked;
    }

    handleDetailLogCheck (event) {
        this.processRecord.detailLogNotification = event.target.checked;
    }

    handleSave () {
        const allValid = [...this.template.querySelectorAll('[data-field]')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (!allValid) {
            this.error = this.i18n.formValidation;
            return;
        }

        this.processRecord.recurrencePattern = this.recModelManager.getRecurrenceString();
        this.setMappingRulesInfo();
        this.error = null;
        this.apiInProgress = true;
        const recordId = this._actionName === PAGE_ACTION_TYPES.CLONE
        ? null : this.processRecord.id;
        const recordToSave =
        {
            ...this.processRecord,
            isActive: this.processRecord.isActive || false,
            isDefault: this.processRecord.isDefault || false,
            detailLogNotification: this.processRecord.detailLogNotification || false,
            nDaysBefore: this.processRecord.nDaysBefore || 0,
            id: recordId
        };
        saveProcessDetails({ requestJson: JSON.stringify(recordToSave) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showSaveSuccessNotification(recordToSave.name);
                this.processRecord.id = result.data.id;
                this.saveRecentItems(result.data);
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    handleLookupChange (event) {
        const value = event.target.value;
        this.processRecord.assignToValue = value;
    }

    handleMappingChange (event) {
        const index = this.itemList.findIndex(x => x.id === parseInt(event.target.accessKey, 10));
        this.itemList[index].objectMapping = event.detail.value;
    }

    handleCancel () {
        this.cancelModalDialogOpen = true;
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;
        this.handleBackToList();
    }

    handleBackToList () {
        this.clearState();
        handleMenuSelection({
            detail: {
                name: "mplan_processes",
                targetType: "LWC",
                targetDeveloperName: "c-mpln-admin-process-list-view"
            }
        }, this);
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

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }

        this.processRecord[event.currentTarget.dataset.field] = inputVal;
    }

    getConfigurableUserFields (objectApiName) {
        if (objectApiName) {
            this.apiInProgress = true;
            this.getObjectFields(objectApiName)
                .then(result => {
                    this.setConfigurableFieldOptions(result);
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                });
        }
    }

    getDeveloperNameInput () {
        return this.template.querySelector('[data-field="developerName"]');
    }

    getExistingProcessDetails () {
        this.apiInProgress = true;
        if (this._recordId) {
            getProcessDetails ( { processId: this._recordId } )
                .then(result => {
                    if (!verifyApiResponse(result)) {
                        this.error = result.message;
                        return;
                    }

                    const resultData = result.data;
                    this.populateProcessData(resultData);
                    if (this.processRecord.recurrencePattern) {
                        this.recModelManager.parseRecPatternToState(
                            this.processRecord.recurrencePattern
                            );
                        this.setupBeforeEdit();
                    }
                    this.saveRecentItems(result.data);
                })
                .catch(error => {
                    this.error = parseErrorMessage(error);
                })
                .finally(() => {
                    this.apiInProgress = false;
                });
        }
    }

    get frequencyOptions () {
        const { frequencyManager } = this;
        return frequencyManager.getFrequencyOptions();
    }

    async getMappingRulesInfo () {
        try {
            const mappingResponse = await getMappingDetails({
                targetObjects: MAPPINGTARGETOBJECTS,
                sourceObjects: MAPPINGSOURCEOBJECTS
            });

            if (mappingResponse && mappingResponse.data) {
                this.setMappingOptions(mappingResponse.data);
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

    }

    populateProcessData (processData) {
        this.processRecord = processData;
        if (this._actionName === PAGE_ACTION_TYPES.CLONE) {
            this.processRecord.name = i18n.copyOf + ' ' + this.processRecord.name
        }
        this.applyAssignToWorkOrder(this.processRecord.assignTo, this.processRecord.assignToObject);
        this.itemList.forEach(item => {
            const selectedMapping = item.mappingOptions.find(
                mappingOption => mappingOption.value === processData.assetToWOMappingId
                || mappingOption.value === processData.mPlanToWOMappingId
            );
            if (selectedMapping) {
                item.objectMapping = selectedMapping.value;
            }
        });
    }

    setMappingOptions (mappingDetailArr) {
        mappingDetailArr.forEach(mappingDetail => {
            const itemIndex = this.itemList
            .findIndex(item =>
                item.sourceObjectAPIName === mappingDetail.sourceObjectAPIName
            );
            if (itemIndex !== -1) {
                const option = {
                    label: mappingDetail.name,
                    value: mappingDetail.id
                };
                this.itemList[itemIndex].mappingOptions =
                [...this.itemList[itemIndex].mappingOptions, option];
            }
        });
    }

    setMappingRulesInfo () {
        this.itemList.forEach (item => {
            if (item.sourceObjectAPIName === MAINTENANCEPLAN_OBJECT.objectApiName) {
                this.processRecord.mPlanToWOMappingId = item.objectMapping;
            }
            if (item.sourceObjectAPIName === 'Asset') {
                this.processRecord.assetToWOMappingId = item.objectMapping;
            }
        });
    }


    saveRecentItems (data) {
        const recentlyViewedRecord = {
            configurationId: data.id,
            configurationName: data.name,
            configurationDeveloperName: data.developerName,
            configurationType: ADMIN_MODULES.MAINTENANCE_PLAN_PROCESS
        };
        saveRecentViewItem(recentlyViewedRecord)
            .then(recentItem => {
                if (!verifyApiResponse(recentItem)) {
                    this.error = recentItem.message;
                }
            });
    }

    onIntervalChange (event) {
        const { intervalManager } = this;
        const { detail: { value }} = event;
        this.interval = parseFloat(value);
        intervalManager.setInterval(value);
        this.recModelManager.logInnerDataModel();
    }

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

    setConfigurableFieldOptions (entityDefinition) {
        if (entityDefinition && entityDefinition.fieldDefinitions) {
            const objectFields = entityDefinition.fieldDefinitions;
            this.configurableFieldOptions = [];
            for (let fieldIndex = 0; fieldIndex < objectFields.length; fieldIndex += 1) {
                const fieldConfig = objectFields[fieldIndex];
                const {
                    apiName: value,
                    dataType,
                    label,
                    referenceTo,
                } = fieldConfig;

                if (dataType === 'REFERENCE') {
                    referenceTo.forEach(lookupObject => {
                        if (lookupObject === 'User') {
                            this.configurableFieldOptions.push({ label, value });
                        }
                    });

                }
            }
        }
    }

    setQueueLookupFilter (queueIds) {
        this.groupFilter = queueIds ?`ID IN (${queueIds})`:'ID=null';
    }

    setFrequency (value) {
        const { frequencyManager } = this;
        frequencyManager.setFrequency(value);
        this.isFrequencyDay = frequencyManager.isDaySelected;
        this.isFrequencyWeek = frequencyManager.isWeekSelected;
        this.isFrequencyMonth = frequencyManager.isMonthSelected;
        this.isFrequencyYear = frequencyManager.isYearSelected;
    }

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

    showSaveSuccessNotification (processName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.maintenanacePlanProcess} "${processName}" ${this.i18n.wasSaved}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.handleBackToList();
    }

    getQueueForSObject () {
        const objectName = 'Workorder';
        this.apiInProgress = true;
        getSObjectSupportedQueues({ objectAPIName: objectName })
        .then(result => {
            if (result && result.data) {
                const queueIds = this.getCommaSeparatedIds(result.data);
                this.setQueueLookupFilter(queueIds);
            }
        })
        .catch(error => {
            this.error = parseErrorMessage(error);
        })
        .finally(() => {
            this.apiInProgress = false;
        });
    }

    getCommaSeparatedIds (listOfIds) {
        const idList = listOfIds;
        const mappedIdList = idList.map(item => (`'${item}'`));
        return mappedIdList.join(',');
    }

    async getObjectFields (objectApiName) {
        let result = {};

        if (isEmptyString(objectApiName)) {
            return result;
        }

        try {
            const resp = await getFieldDefinitionsForEntity(objectApiName);

            if (resp && resp.data) {
                result = resp.data;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }

        return result;
    }
}