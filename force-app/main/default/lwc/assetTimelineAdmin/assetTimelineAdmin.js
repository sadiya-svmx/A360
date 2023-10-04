import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import TASK_OBJECT from '@salesforce/schema/Task';
import EVENT_OBJECT from '@salesforce/schema/Event';
import ASSET_OBJECT from '@salesforce/schema/Asset';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTimelineConfigWithDetails
    from '@salesforce/apex/ADM_TimelineConfig_LS.getTimelineConfigurationWithDetails';
import getTimelineCategories
    from '@salesforce/apex/AMGT_TimeLine_LS.getTimelineCategories';
import upsertTranslatedTagsByContextAndMasterText
    from '@salesforce/apex/ADM_Translation_LS.upsertTranslatedTagsByContextAndMasterText';
import saveTimelineConfiguration from
    '@salesforce/apex/ADM_TimelineConfig_LS.saveTimelineConfiguration';
import getAllAssignedProfileDetails from
    '@salesforce/apex/ADM_TimelineConfig_LS.getAllAssignedProfileDetails';
import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';
import getTaskEventObjectDetails
    from '@salesforce/apex/COMM_MetadataLightningService.getEntityDefinitions';
import { refreshApex } from '@salesforce/apex';

import closeButton from '@salesforce/label/c.Button_Close';
import saveButton from '@salesforce/label/c.Button_Save';
import pageHeader from '@salesforce/label/c.LabelAssetManagement';
import timelineConfigHeader from '@salesforce/label/c.LabelTimeline';
import labelName from '@salesforce/label/c.Label_Name';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelSetAsDefault from '@salesforce/label/c.Label_SetAsDefault';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelAddObject from '@salesforce/label/c.Button_AddObject';
import labelObjectSelection from '@salesforce/label/c.Label_ObjectSelection';
import labelProfileAssignment from '@salesforce/label/c.Label_ProfileAssignment';
import labelAvailableProfiles from '@salesforce/label/c.Label_AvailableProfiles';
import labelSelectedProfiles from '@salesforce/label/c.Label_SelectedProfiles';
import objectProperties from '@salesforce/label/c.Label_ObjectProperties';
import copyOf from '@salesforce/label/c.Label_CopyOf';
import save from '@salesforce/label/c.Button_Save';
import cancel from '@salesforce/label/c.Button_Cancel';
import object from '@salesforce/label/c.Label_Object';
import enterValueMissing from '@salesforce/label/c.Message_EnterValue';
import selectorModalTitle from '@salesforce/label/c.Label_SelectorModalTitle';
import displayField from '@salesforce/label/c.Label_DisplayField';
import sourceField from '@salesforce/label/c.Label_SourceField';
import startDate from '@salesforce/label/c.Label_StartDate';
import endDate from '@salesforce/label/c.Label_EndDate';
import displayIcon from '@salesforce/label/c.Label_DisplayIcon';
import criteriaToShowRecord from '@salesforce/label/c.Label_CriteriaToShowRecord';
import showMatchingRecords from '@salesforce/label/c.Label_ShowMatchingRecords';
import timeline from '@salesforce/label/c.LabelTimeline';
import wasSaved from '@salesforce/label/c.Label_WasSaved';
import labelYesContinue from '@salesforce/label/c.Button_YesContinue';
import labelNoGoBack from '@salesforce/label/c.Button_NoGoBack';
import labelCancelModal from '@salesforce/label/c.Label_CancelModal';
import labelCancelModalTitle from '@salesforce/label/c.Label_CancelModalTitle';
import saveSuccess from '@salesforce/label/c.Message_SaveSuccess';
import labelReassignProfile from '@salesforce/label/c.Label_ReassignProfile';
import labelReassignProfileContent from
    '@salesforce/label/c.Message_ReassignTimelineProfileContent';
import messageMatchModalContent from '@salesforce/label/c.Message_ShowMatchModalContent';
import labelOK from '@salesforce/label/c.Button_OK';
import labelCompleteField from '@salesforce/label/c.Label_RequiredFieldMessage';
import labelShowMenuAltText from '@salesforce/label/c.AltText_ShowMenu';
import labelMenuEdit from '@salesforce/label/c.Menu_Edit';
import labelMenuRemove from '@salesforce/label/c.Menu_Remove';
import labelReOrder from '@salesforce/label/c.Label_ReOrderObjects';
import labelReName from '@salesforce/label/c.Label_RenameTitle';
import labelTitleName from '@salesforce/label/c.Label_TitleName';
import labelUpdateTitle from '@salesforce/label/c.Title_UpdateTitle';
import labelereorderobjects from '@salesforce/label/c.Title_TimelineCategoryReOrderObjects';
import labelTo from '@salesforce/label/c.Label_ToDate';
import errorSaveMsg from '@salesforce/label/c.Error_DuplicateTimelineConfig';
import datesInvalidError from '@salesforce/label/c.Error_DatesInvalidError';
import {
    getFieldDefinitionsForEntity
} from 'c/metadataService';

import { saveRecentViewItem }
    from 'c/recentItemService';

import {
    parseErrorMessage,
    isEmptyString,
    normalizeDeveloperName,
    handleMenuSelection,
    isNotUndefinedOrNull,
    verifyApiResponse,
    PAGE_ACTION_TYPES,
    ADMIN_MODULES,
    raf,
    sortObjectArray,
    formatString
} from 'c/utils';

const CLONE_NAME_PREFIX = copyOf;
const DASH = '  -  ';
const TRANSLATION_CONTEXT = 'TimelineCategory';
const CONFIG_INPUT_FIELD_CLASS = '.svmx-timeline-config_input-field';
const DETAIL_INPUT_FIELD_CLASS = '.svmx-timeline-config-detail_input-field';
const FIELD_SELECTION_FIELD_CLASS = '.svmx-timeline-config-field-selection_input-field';
const GOOG_BLUE = '#4285F4';
const DISPLAY_FIELD_TYPES = [
    "REFERENCE",
    "PICKLIST",
    "STRING",
    "EMAIL",
    "PHONE",
    "TEXTAREA",
    "MULTIPICKLIST",
    "URL"
];

export default class AssetTimelineAdmin extends NavigationMixin(LightningElement) {
    currentNavItem;
    _recordId = '';

    i18n = {
        closeButton,
        saveButton,
        pageHeader,
        timelineConfigHeader,
        labelName,
        labelDeveloperName,
        labelSetAsDefault,
        labelDescription,
        labelAddObject,
        labelObjectSelection,
        labelProfileAssignment,
        labelAvailableProfiles,
        labelSelectedProfiles,
        objectProperties,
        save,
        cancel,
        object,
        copyOf,
        enterValueMissing,
        selectorModalTitle,
        displayField,
        sourceField,
        startDate,
        endDate,
        displayIcon,
        criteriaToShowRecord,
        showMatchingRecords,
        timeline,
        wasSaved,
        goBack: labelNoGoBack,
        continue: labelYesContinue,
        cancelModalTitle: labelCancelModalTitle,
        cancelModalContent: labelCancelModal,
        saveSuccess,
        reassignProfile: labelReassignProfile,
        reassignProfileContent: labelReassignProfileContent,
        matchModalContent: messageMatchModalContent,
        ok: labelOK,
        completeField: labelCompleteField,
        menuAltText: labelShowMenuAltText,
        editAction: labelMenuEdit,
        removeAction: labelMenuRemove,
        labelReOrder,
        labelReName,
        labelTitleName,
        labelUpdateTitle,
        labelereorderobjects,
        labelTo,
        errorSaveMsg,
        datesInvalidError
    }

    @track availableObjects = [];
    @track availableFields = [];
    @track dateFields = [];
    @track sourceFields = [];
    @track reAssignedProfileDetails=[];
    @track assignedProfileIds=[];
    @track selectedProfileIds=[];
    sequence;
    selectedObject;
    selectedDisplayFieldApiName;
    selectedSourceFieldApiName;
    selectedStartDateFieldApiName;
    selectedEndDateFieldApiName;
    selectedExpressionId;
    selectedExpressionName = '';
    iconName = '';
    showMatchingRecords = true;
    selectedColor = GOOG_BLUE;
    focused;
    @track selectedExpression;
    @track recordInfo = {};
    apiInProgress = false;
    @track timelineConfigDetails = [];
    @track timelineConfigAccess = [];
    profileSearchString = '';
    @track previouslyAssignedProfiles = [];
    error;
    isDirty = false;
    booleanTrue = true;
    missingFieldMessage = this.i18n.completeField;
    showConfigDetails = false;
    hasRecordId = false;
    reorderStepsOpen = false;
    showRenameTitle = false;
    @track timelineCategories = [];

    cancelModalDialogOpen = false;
    reAssignModalDialogOpen = false;
    objectPropertiesModalDialogOpen = false;
    selectorModalOpen = false;
    showConfigObjectIconPickerModal = false;
    matchModalDialogOpen = false;

    showProfileSelector = false;
    objectPropertyChanged = false;
    showNoAssetRefError = false;
    showColorBar = true;
    assetDateFields = [];
    disableObjectField = false;
    disableSourceFieldApi = false;
    saveError;
    showEndDateInvalid = false;
    showStartDateInvalid = false;

    objectRowActions = [
        {
            label: this.i18n.editAction,
            value: "edit"
        },
        {
            label: this.i18n.removeAction,
            value: "remove"
        }
    ];

    @wire(getTimelineCategories, { developerName: '$configDeveloperName' })
    timelineCategoriesResponse (value) {
        this.timelineCategoriesResp = value;
        const { error, data } = value;
        if (data) {
            this.populateAssetDateFields().then(()=>{});
            this.updatedBandLabel = undefined;
            this.updatedEventsLabel = undefined;
            this.updatedMilestonesLabel = undefined;
            this.timelineCategories = [...data];
        }
        if (error) {
            this.error = error;
        }
    }

    get configDeveloperName () {
        return this.recordInfo.developerName
            ?? (this._actionName === PAGE_ACTION_TYPES.NEW ? 'newConfig':'');
    }

    get bandLabel () {
        // eslint-disable-next-line max-len
        return this.updatedBandLabel??this.timelineCategories[this.timelineCategories.findIndex(item => item.categoryType === 'Bands')]?.label;
    }

    get eventsLabel () {
        // eslint-disable-next-line max-len
        return this.updatedEventsLabel??this.timelineCategories[this.timelineCategories.findIndex(item => item.categoryType === 'Events')]?.label;
    }

    get milestonesLabel () {
        // eslint-disable-next-line max-len
        return this.updatedMilestonesLabel??this.timelineCategories[this.timelineCategories.findIndex(item => item.categoryType === 'Milestones')]?.label;
    }

    get reorderTitle () {
        let label = '';
        switch (this.selectedTypeVal) {
            case 'reorderBands':
                label = this.bandLabel;
                break;
            case 'reorderEvents':
                label = this.eventsLabel;
                break;
            case 'reorderMilestones':
                label = this.milestonesLabel;
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
        return formatString(labelereorderobjects,label);
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.clearState();
        this.apiInProgress = true;

        this.currentPageReference = pageRef;

        if (pageRef && pageRef.state) {
            if (pageRef.state.c__recordId) {
                this._recordId = pageRef.state.c__recordId;
            }

            if (pageRef.state.c__actionName) {
                this._actionName = pageRef.state.c__actionName.toLowerCase();
            }

            if (pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }
        }

        this.loadView();
        this.loadPreviouslyAssignedProfiles();
        this.getAllEntities();
        this.apiInProgress = false;

    }

    loadPreviouslyAssignedProfiles () {
        getAllAssignedProfileDetails()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.previouslyAssignedProfiles = result.data;
                this.getSelectedProfileIds();
                this.getAssignedProfileIds();
                this.showProfileSelector = true;
            })
            .catch( error => {
                this.error = parseErrorMessage(error)
            });
    }

    @api
    get recordId () {
        return this._recordId;
    }
    set recordId (value) {
        this._recordId = value;
    }

    get hasTimelineConfigDetails () {
        return this.timelineConfigDetails?.length > 0;
    }

    get menuItemsForBands () {
        return [
            {
                id: 'item-1',
                label: this.i18n.labelReName,
                value: 'renameBands'
            },
            {
                id: 'item-2',
                label: this.i18n.labelReOrder,
                value: 'reorderBands'
            }
        ];
    }
    get menuItemsForEvents () {
        return [
            {
                id: 'item-1',
                label: this.i18n.labelReName,
                value: 'renameEvents'
            },
            {
                id: 'item-2',
                label: this.i18n.labelReOrder,
                value: 'reorderEvents'
            }
        ];
    }
    get menuItemsForMilestones () {
        return [
            {
                id: 'item-1',
                label: this.i18n.labelReName,
                value: 'renameMilestones'
            },
            {
                id: 'item-2',
                label: this.i18n.labelReOrder,
                value: 'reorderMilestones'
            }
        ];
    }

    get activeSections () {
        const sections = [];
        if (this.hasTimespanEvents) {
            sections.push('bands');
        }
        if (this.hasEvents) {
            sections.push('events');
        }
        if (this.hasMilestones) {
            sections.push('milestones');
        }
        return sections;
    }

    get hasTimespanEvents () {
        return this.objectsConfiguredAsBands.length >0;
    }

    get objectsConfiguredAsBands () {
        let retData  = [];
        if (this.hasTimelineConfigDetails) {
            // eslint-disable-next-line max-len
            retData = [...this.timelineConfigDetails.filter(det => !isEmptyString(det.endDateFieldAPIName)  && det.objectAPIName.toLowerCase() !== 'asset')];
        }
        return sortObjectArray(
            retData,
            'sequence',
            'asc'
        );
    }

    get hasEvents () {
        return this.objectsConfiguredAsEvents.length >0;
    }

    get objectsConfiguredAsEvents () {
        let retData  = [];
        if (this.hasTimelineConfigDetails) {
            // eslint-disable-next-line max-len
            retData = [...this.timelineConfigDetails.filter(det => isEmptyString(det.endDateFieldAPIName) && det.objectAPIName.toLowerCase() !== 'asset')];
        }
        return sortObjectArray(
            retData,
            'sequence',
            'asc'
        );
    }

    get hasMilestones () {
        return this.objectsConfiguredAsMilestones.length >0;
    }

    get objectsConfiguredAsMilestones () {
        let retData  = [];
        if (this.hasTimelineConfigDetails) {
            // eslint-disable-next-line max-len
            retData = [...this.timelineConfigDetails.filter(det =>  det.objectAPIName.toLowerCase() === 'asset')];
        }
        return sortObjectArray(
            retData,
            'sequence',
            'asc'
        );
    }

    get sourceRecordId () {
        const recordId =(this._actionName === PAGE_ACTION_TYPES.CLONE ||
            isEmptyString(this._recordId) ) ? '' : this._recordId;
        return recordId;
    }

    get isDisableDisplayField () {
        return isEmptyString(this.selectedSourceFieldApiName)
            || !this.isDisplayFieldRequired;
    }

    get isDisplayFieldRequired () {
        return this.selectedObject?.toLowerCase() !== 'asset';
    }

    get selectedObjectLabel () {
        if (!isEmptyString(this.selectedObject)) {
            const index = this.availableObjects.findIndex(obj => obj.value === this.selectedObject);
            return index > -1 ? this.availableObjects[index].label : '';
        }
        return '';
    }

    get computedCardClass () {
        let css = 'slds-card slds-card_boundary step-card';

        if (this.focused) {
            css += ' step-card-is-focused';
        }

        return css;
    }

    get profileAndConfigInfo () {

        let reAssignedProfileConfig = [];
        if (this.reAssignedProfileDetails && this.reAssignedProfileDetails.length > 0) {
            reAssignedProfileConfig = this.reAssignedProfileDetails.map((element) => {
                const configNames = ( element.timelineConfigNames &&
                    element.timelineConfigNames.length > 0 )?
                    element.timelineConfigNames.join(',') : '';
                return {
                    profileName: element.profileName,
                    timelineConfigName: configNames,
                    profileConfigInfo: `${element.profileName} ${DASH} ${configNames}`,
                };
            });
        }
        return reAssignedProfileConfig;
    }

    getAssignedProfileIds () {
        this.assignedProfileIds = [];
        if (this.previouslyAssignedProfiles && this.previouslyAssignedProfiles.length > 0) {
            this.previouslyAssignedProfiles.forEach(row => {
                if (this.timelineConfigAccess && this.timelineConfigAccess.length > 0) {
                    let assignedToCurrentConfig = false;
                    this.timelineConfigAccess.forEach( access => {
                        if (row.profileId === access.profileId) {
                            assignedToCurrentConfig = true;
                        }
                    });
                    if (!assignedToCurrentConfig) {
                        this.assignedProfileIds.push(row.profileId);
                    }
                } else {
                    this.assignedProfileIds.push(row.profileId);
                }
            });
        }
    }

    getSelectedProfileIds () {
        this.selectedProfileIds = [];
        if (this.timelineConfigAccess) {
            this.timelineConfigAccess.forEach(row => {
                this.selectedProfileIds.push(row.profileId);
            });
        }
        if (this.selectedProfileIds.length > 0) {
            this.previouslyAssignedProfiles = this.previouslyAssignedProfiles.filter(profile => {
                return !this.selectedProfileIds.includes(profile.profileId);
            });
        }
    }

    getDeveloperNameInput () {
        return this.template.querySelector('.svmx-timeline-config_developer-name-input');
    }

    loadView () {
        switch (this._actionName) {
            case PAGE_ACTION_TYPES.NEW:
                this.hasRecordId = false;
                break;
            case PAGE_ACTION_TYPES.VIEW:
            case PAGE_ACTION_TYPES.EDIT:
                this.getExistingRecordDetails();
                break;
            case PAGE_ACTION_TYPES.CLONE:
                this.getExistingRecordDetails();
                this.hasRecordId = false;
                break;
            default:
                break;
        }
        this.showConfigDetails = true;
    }

    handleRowAction (event) {
        const detailElement =
            Number(event.target.closest('lightning-tile').getAttribute('data-index'));
        switch (event.detail.value) {
            case "edit":
                this.loadObject(
                    this.timelineConfigDetails[this.timelineConfigDetails
                        .findIndex(det => det.sequence === detailElement)]);
                break;
            case "remove":
                this.removeTimelineDetail(this.timelineConfigDetails
                    .findIndex(det => det.sequence === detailElement));
                this.isDirty = true;
                break;
            default:
                break;
        }
    }

    removeTimelineDetail ( arrayIndex ) {
        this.timelineConfigDetails.splice(arrayIndex, 1);
    }

    async loadObject (detailObject) {
        this.handleOpenObjectPropertiesModal();
        this.detailId = detailObject.id;
        this.sequence = detailObject.sequence;
        this.selectedObject = detailObject.objectAPIName;
        await this.loadFieldDefinitions();
        if (isEmptyString(detailObject.qualifyingCriteria)) {
            this.selectedExpression = null;
        } else {
            this.selectedExpression = {
                label: detailObject.qualifyingCriteriaName,
                value: detailObject.qualifyingCriteria
            };
        }
        if (isEmptyString(detailObject.iconName)) {
            this.icon = null;
        } else {
            this.icon = {
                label: detailObject.iconName,
                value: detailObject.iconName
            };
        }
        this.selectedExpressionId = detailObject.qualifyingCriteria || null;
        this.selectedExpressionName = detailObject.qualifyingCriteriaName || null;
        this.selectedDisplayFieldApiName = detailObject.displayFieldAPIName;
        this.selectedSourceFieldApiName = detailObject.sourceFieldAPIName;
        this.iconName = detailObject.iconName || null;
        this.selectedStartDateFieldApiName = detailObject.startDateFieldAPIName;
        this.selectedEndDateFieldApiName = detailObject.endDateFieldAPIName;
        this.selectedColor = detailObject.backgroundColor;
        this.showMatchingRecords = (Boolean(detailObject.showMatchingOnLoad) === true);
    }

    getExistingRecordDetails () {
        if (isEmptyString(this._recordId)) return;
        this.hasRecordId = true;
        getTimelineConfigWithDetails({ timelineConfigId: this.recordId })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                if (result && result.data) {
                    this.saveRecentItems(result.data);
                    this.populateRecordDetails (result.data);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    populateRecordDetails (config) {
        this.recordInfo = { ...this.recordInfo, ...config };
        this.timelineConfigAccess = this.recordInfo.timelineConfigAccessList;
        this.timelineConfigDetails = JSON.parse(
            JSON.stringify(this.recordInfo.timelineConfigDetailList));
        this.timelineConfigDetails.forEach(item => {
            const uniqueNameVal = item.objectAPIName+
            (item.qualifyingCriteria??'')+
            (item.objectAPIName.toLowerCase() === 'asset'
                ? item.startDateFieldAPIName
                : !isEmptyString(item.startDateFieldAPIName))+
            (item.objectAPIName.toLowerCase() === 'asset'
                ? (item.endDateFieldAPIName ?? '')
                : !isEmptyString(item.endDateFieldAPIName));
            item.uniqueName = uniqueNameVal;
        });
        if (this.timelineConfigAccess && this.timelineConfigAccess.length > 0) {
            this.timelineConfigAccess.forEach(row => {
                row.id = null;
            });
        }

        if (this._actionName === PAGE_ACTION_TYPES.CLONE) {
            this.markAsClone(CLONE_NAME_PREFIX);
        }
    }

    markAsClone (namePrefix) {
        const recordName = namePrefix + ' ' + this.recordInfo.name;
        this.recordInfo.name = (recordName.length > 80) ? recordName.substring(0, 80) : recordName;
        this.recordInfo.id = null;
        this.timelineConfigAccess = [];
        this.recordInfo.developerName = normalizeDeveloperName(this.recordInfo.name);
        if (this.timelineConfigDetails && this.timelineConfigDetails.length > 0) {
            this.timelineConfigDetails.forEach(row => {
                row.id = null;
            });
        }
    }

    isAssetLookup (field) {
        return field.dataType === "REFERENCE"
            && field.referenceTo.includes(ASSET_OBJECT.objectApiName);
    }

    async getAllEntities () {
        try {
            const additionalObjects = [TASK_OBJECT, EVENT_OBJECT];
            const additionalEntityRequest = additionalObjects.map(entity => ({
                apiName: entity.objectApiName
            }));
            const resp = await getAllEntityDefinitions();
            const additionalResponse = await getTaskEventObjectDetails({
                requestJson: JSON.stringify(additionalEntityRequest) });
            const availableEntityDefinitions = [...resp.data, ...additionalResponse.data];
            if (availableEntityDefinitions && availableEntityDefinitions.length) {
                const validObjects = [];
                const includedObjects = [];
                // eslint-disable-next-line no-unused-expressions
                availableEntityDefinitions?.forEach(entity => {
                    if (!includedObjects.includes(entity.apiName)) {
                        includedObjects.push(entity.apiName);
                        validObjects.push(entity);
                    }
                });
                let allAvailableObjects = validObjects.map(entity => {
                    return {
                        label: entity.label,
                        value: entity.apiName,
                        secondary: entity.apiName
                    };
                });
                allAvailableObjects = allAvailableObjects.sort((entity1, entity2) => {
                    if (entity1.label < entity2.label) {
                        return -1;
                    } else if (entity1.label > entity2.label) {
                        return 1;
                    }
                    return 0;
                });
                this.availableObjects = allAvailableObjects;
            }
        } catch (err) {
            this.error = parseErrorMessage(err);
        }
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

    async populateAssetDateFields () {
        const fieldData = await this.getObjectFields(ASSET_OBJECT.objectApiName);
        this.assetDateFields = [];
        if (fieldData.fieldDefinitions === undefined) {
            return;
        }
        fieldData.fieldDefinitions.forEach(field => {
            if (field.dataType === "DATETIME" || field.dataType === "DATE") {
                this.assetDateFields[field.apiName] = field.label;
            }
        });
        this.sourceFields = [];
        fieldData.fieldDefinitions.forEach(field => {
            if (this.selectedObject?.toUpperCase() === 'ASSET'
                && field.dataType.toUpperCase() === "ID") {
                this.sourceFields.push({
                    label: field.label,
                    value: field.apiName,
                    secondary: field.apiName
                });
            }
            if (this.selectedObject?.toUpperCase() !== 'ASSET'
                && this.isAssetLookup(field)) {
                this.sourceFields.push({
                    label: field.label,
                    value: field.apiName,
                    secondary: field.apiName
                });
            }
        });
        this.showNoAssetRefError = this.sourceFields.length === 0;
    }

    async loadFieldDefinitions () {
        const fieldData = await this.getObjectFields(this.selectedObject);
        this.availableFields = [];
        fieldData.fieldDefinitions.forEach(field => {
            if (DISPLAY_FIELD_TYPES.includes(field.dataType)) {
                const fieldOption = {
                    label: field.label,
                    secondary: field.apiName
                };
                fieldOption.value = (field.dataType === "REFERENCE") ?
                    `${field.relationshipName}.${field.referenceNameFields[0]}` : field.apiName;
                this.availableFields.push(fieldOption);
            }
        });
        this.dateFields = [];
        fieldData.fieldDefinitions.forEach(field => {
            if (field.dataType === "DATETIME" || field.dataType === "DATE") {
                this.dateFields.push({
                    label: field.label,
                    value: field.apiName,
                    secondary: field.apiName
                });
            }
        });
        this.sourceFields = [];
        fieldData.fieldDefinitions.forEach(field => {
            if (this.selectedObject?.toUpperCase() === 'ASSET'
                && field.dataType.toUpperCase() === "ID") {
                this.sourceFields.push({
                    label: field.label,
                    value: field.apiName,
                    secondary: field.apiName
                });
            }
            if (this.selectedObject?.toUpperCase() !== 'ASSET'
                && this.isAssetLookup(field)) {
                this.sourceFields.push({
                    label: field.label,
                    value: field.apiName,
                    secondary: field.apiName
                });
            }
        });
        this.showNoAssetRefError = this.sourceFields.length === 0;
    }

    handleExpressionSelected (event) {
        this.selectedExpression = {
            label: event.detail.value.name,
            value: event.detail.value.id
        };
        this.selectedExpressionId = event.detail.value.id;
        this.selectedExpressionName = event.detail.value.name;
        this.objectPropertyChanged = true;
        this.handleCloseModal();
    }

    handleCriteriaRemoved () {
        this.selectedExpression = null;
        this.selectedExpressionId = null;
        this.selectedExpressionName = null;
        this.objectPropertyChanged = true;
    }

    handleIconRemoved () {
        this.icon = null;
        this.iconName = null;
        this.objectPropertyChanged = true;
    }

    handleFormInputChange (event) {
        let inputVal = event.target.value;

        if (inputVal) {
            inputVal = inputVal.trim();
        }
        this.recordInfo[event.currentTarget.dataset.field] =
            (event.target.type === "checkbox") ? event.target.checked : inputVal;
        this.isDirty = true;
    }

    handleNameCommit () {
        if (!this.recordInfo.developerName) {
            const maxLength = this.getDeveloperNameInput().maxLength;
            this.recordInfo.developerName = normalizeDeveloperName(
                this.recordInfo.name,
                maxLength,
                ''
            );
            this.getDeveloperNameInput().value = this.recordInfo.developerName;
        }
    }

    handleDisplayFieldChange (event) {
        this.selectedDisplayFieldApiName = event.target.value;
        this.objectPropertyChanged = true;
    }

    handleSourceFieldChange (event) {
        this.selectedSourceFieldApiName = event.target.value;
        this.objectPropertyChanged = true;
    }

    handleStartDateChange (event) {
        if (this.selectedStartDateFieldApiName === event.target.value) return;
        this.selectedStartDateFieldApiName = event.target.value;
        this.objectPropertyChanged = true;
        this.showStartDateInvalid =
                this.selectedEndDateFieldApiName === this.selectedStartDateFieldApiName;
        if (!this.showStartDateInvalid) {
            this.showEndDateInvalid = false;
        }
    }

    handleEndDateChange (event) {
        if (this.selectedEndDateFieldApiName === event.target.value) return;
        this.selectedEndDateFieldApiName = event.target.value;
        this.objectPropertyChanged = true;
        this.showEndDateInvalid =
                this.selectedEndDateFieldApiName === this.selectedStartDateFieldApiName;
        if (!this.showEndDateInvalid) {
            this.showStartDateInvalid = false;
        }
    }

    handleOpenObjectPropertiesModal () {
        this.clearObjectModal();
        this.objectPropertiesModalDialogOpen = true;
    }

    handleOpenObjectPropertiesModalForMilestone () {
        this.clearObjectModal ();
        this.selectedObject = 'Asset';
        this.clearFieldSelections();
        this.loadFieldDefinitions();
        this.disableObjectField = true;
        this.selectedSourceFieldApiName = 'Id';
        this.disableSourceFieldApi = true;
        this.objectPropertiesModalDialogOpen = true;
    }
    handleOpenSelector () {
        this.selectorModalOpen = true;
    }

    handleShowObjectIconPickerModal () {
        this.showConfigObjectIconPickerModal = true;
    }

    handleConfigObjectIconPickerApply (event) {
        this.icon = {
            label: event.detail.value,
            value: event.detail.value
        }
        this.iconName = event.detail.value;
        this.isDirty = true;
        this.handleConfigObjectIconPickerClose();
    }

    handleObjectChange (event) {
        this.isDirty = true;
        this.selectedObject = event.target.value;
        this.clearFieldSelections();
        this.loadFieldDefinitions();
        if (this.selectedObject.toLowerCase() === 'asset') {
            this.selectedSourceFieldApiName = 'Id';
            this.objectPropertyChanged = true;
        }
    }

    clearFieldSelections () {
        const fieldSelections = this.template.querySelectorAll(FIELD_SELECTION_FIELD_CLASS);
        fieldSelections.forEach(field => {
            if (field.dataset.field === "qualifying-criteria") {
                this.selectedExpressionId = '';
                this.selectedExpressionName = '';
            }
            this.selectedSourceFieldApiName = '';
            field.value = '';
        });
        this.selectedStartDateFieldApiName = '';
        this.selectedEndDateFieldApiName = '';
        this.selectedDisplayFieldApiName = '';
    }
    get uniqueNameVal () {
        let uniqueNameVal;
        if (this.selectedObject.toLowerCase() === 'asset') {
            uniqueNameVal = this.selectedObject+
                (this.selectedExpressionId??'')+
                (this.selectedStartDateFieldApiName)+
                (this.selectedEndDateFieldApiName ?? '');
        } else {
            uniqueNameVal = this.selectedObject+
                (this.selectedExpressionId??'')+
                !isEmptyString(this.selectedStartDateFieldApiName)+
                !isEmptyString(this.selectedEndDateFieldApiName);
        }
        return uniqueNameVal;
    }
    hasDuplicate () {
        const dupCheckIndex = this.timelineConfigDetails
                .findIndex(detail => detail.uniqueName === this.uniqueNameVal);
        let duplicateFound = false;
        if (dupCheckIndex >-1
            && this.sequence !== this.timelineConfigDetails[dupCheckIndex].sequence) {
            this.saveError = this.i18n.errorSaveMsg;
            duplicateFound = true;
        }
        return duplicateFound;
    }

    handleSaveObjectModal () {
        if (!this.isValidInput(DETAIL_INPUT_FIELD_CLASS)
            || this.hasDuplicate()
            || this.showEndDateInvalid
            || this.showStartDateInvalid) {
                return;
        }
        this.saveError = undefined;
        const objectRow = {
            sequence: (this.sequence !== undefined
                && this.sequence != null
                && Number(this.sequence) > -1) ?
                this.sequence : this.timelineConfigDetails.length+1,
            objectAPIName: this.selectedObject,
            objectLabel: this.selectedObjectLabel,
            qualifyingCriteria: (isEmptyString(this.selectedExpressionId)) ?
                null : this.selectedExpressionId,
            qualifyingCriteriaName: (isEmptyString(this.selectedExpressionName)) ?
                null : this.selectedExpressionName,
            displayFieldAPIName: this.selectedDisplayFieldApiName,
            sourceFieldAPIName: this.selectedSourceFieldApiName,
            iconName: this.iconName,
            startDateFieldAPIName: this.selectedStartDateFieldApiName,
            startDateFieldLabel: this.assetDateFields[this.selectedStartDateFieldApiName],
            endDateFieldAPIName: this.selectedEndDateFieldApiName,
            endDateFieldLabel: this.selectedEndDateFieldApiName
                ? this.assetDateFields[this.selectedEndDateFieldApiName]
                : undefined,
            backgroundColor: this.selectedColor,
            showMatchingOnLoad:
                this.template.querySelector('[data-field="showMatchingRecords"]').checked,
            uniqueName: this.uniqueNameVal
        }
        let index = -1;
        if (this.detailId) {
            objectRow.id = this.detailId;
            index = this.timelineConfigDetails
                .findIndex(detail =>  detail.id === this.detailId);
        } else if (Number (this.sequence) > -1) {
            index = this.timelineConfigDetails
                .findIndex(detail => detail.sequence === this.sequence);
        }
        if (index === -1) {
            this.timelineConfigDetails = [...this.timelineConfigDetails, objectRow];
        } else {
            this.timelineConfigDetails.splice(index,1,objectRow);
        }
        this.isDirty = this.objectPropertyChanged;
        this.clearObjectModal();
        this.handleCancelObjectModal();
    }

    handleReassignModalModal () {
        this.reAssignModalDialogOpen = false;
    }

    handleReassignConfirmModal () {
        this.reAssignModalDialogOpen = false;
        this.saveConfigRecord();
    }

    clearObjectModal () {
        this.detailId = '';
        this.selectedObject = '';
        this.selectedExpression = null
        this.selectedExpressionId = null;
        this.selectedExpressionName = null;
        this.selectedDisplayFieldApiName = '';
        this.selectedSourceFieldApiName = '';
        this.iconName = null;
        this.icon = null;
        this.selectedStartDateFieldApiName = '';
        this.selectedEndDateFieldApiName = '';
        this.selectedColor = GOOG_BLUE;
        this.showMatchingRecords = true;
        this.sequence = null;
        this.objectPropertyChanged = false;
        this.showNoAssetRefError = false;
        this.disableObjectField = false;
        this.disableSourceFieldApi = false;
    }

    handleSelectedColor (event) {
        this.selectedColor = event.target.value;
        this.objectPropertyChanged = true;
        const colorBar = this.template.querySelector('.svmx-colorbar');
        if (colorBar) {
            colorBar.classList.remove('colorBar');
        }
    }

    handleProfileSelected (event) {
        this.timelineConfigAccess = event.detail.value.map(element => {
            return {
                profileId: element,
                timelineConfigId: this.recordId
            };
        });
        this.objectPropertyChanged = true;
        this.isDirty = this.objectPropertyChanged;
    }

    handleSave () {
        if (!this.isValidInput(CONFIG_INPUT_FIELD_CLASS)) return;
        this.reAssignedProfileDetails = [];
        this.timelineConfigAccess.forEach(newProfile => {
            const profileAssignmentInfo =  this.previouslyAssignedProfiles.find(
                prev => prev.profileId === newProfile.profileId);
            if (isNotUndefinedOrNull(profileAssignmentInfo)) {
                this.reAssignedProfileDetails.push(profileAssignmentInfo);
            }
        });
        let showMatch = false;
        this.timelineConfigDetails = [
            ...this.objectsConfiguredAsBands,
            ...this.objectsConfiguredAsEvents,
            ...this.objectsConfiguredAsMilestones
        ];
        this.timelineConfigDetails.forEach((newDetail,index) => {
            if ( Boolean(newDetail.showMatchingOnLoad) === true ) {
                showMatch = true;
            }
            newDetail.sequence = index+1;
        });
        if ( !showMatch ) {
            this.matchModalDialogOpen = true;
        } else if (this.reAssignedProfileDetails && this.reAssignedProfileDetails.length > 0 ) {
            this.reAssignModalDialogOpen = true;
        } else {
            this.saveConfigRecord();
        }
    }


    saveConfigRecord () {
        this.error = null;
        this.apiInProgress = true;

        this.recordInfo.timelineConfigAccessList = this.timelineConfigAccess;
        this.recordInfo.timelineConfigDetailList = this.timelineConfigDetails.map(item =>  {
            const displayFieldVal = (isEmptyString(item.displayFieldAPIName)
                ? 'none'
                : item.displayFieldAPIName);
            return {
                sequence: item.sequence,
                objectAPIName: item.objectAPIName,
                objectLabel: item.objectLabel,
                qualifyingCriteria: item.qualifyingCriteria,
                qualifyingCriteriaName: item.qualifyingCriteriaName,
                displayFieldAPIName: displayFieldVal,
                sourceFieldAPIName: item.sourceFieldAPIName,
                iconName: item.iconName,
                startDateFieldAPIName: item.startDateFieldAPIName,
                startDateFieldLabel: item.startDateFieldLabel,
                endDateFieldAPIName: item.endDateFieldAPIName,
                endDateFieldLabel: item.endDateFieldLabel,
                backgroundColor: item.backgroundColor,
                showMatchingOnLoad: item.showMatchingOnLoad
            }
        });

        this.reAssignedProfileDetails = [];
        const tags = [];
        if (this.updatedBandLabel) {
            tags.push({
                language: 'en_US',
                context: TRANSLATION_CONTEXT,
                masterText: `${this.recordInfo.developerName}-Bands`,
                translatedValue: this.updatedBandLabel,
                tagId: 'none'
            });
        }
        if (this.updatedEventsLabel) {
            tags.push({
                language: 'en_US',
                context: TRANSLATION_CONTEXT,
                masterText: `${this.recordInfo.developerName}-Events`,
                translatedValue: this.updatedEventsLabel,
                tagId: 'none'
            });
        }
        if (this.updatedMilestonesLabel) {
            tags.push({
                language: 'en_US',
                context: TRANSLATION_CONTEXT,
                masterText: `${this.recordInfo.developerName}-Milestones`,
                translatedValue: this.updatedMilestonesLabel,
                tagId: 'none'
            });
        }
        saveTimelineConfiguration({ requestJson: JSON.stringify(this.recordInfo) })
            .then(result => {
                this._recordId = result.Id;
                if (tags.length >0) {
                    upsertTranslatedTagsByContextAndMasterText({
                        requestJson: JSON.stringify(tags)
                    })
                    .then(translationresult => {
                        if (!verifyApiResponse(translationresult)) {
                            this.error = result.message;
                        } else {
                            refreshApex(this.timelineCategoriesResp);
                            this.showSaveSuccessNotification();
                            this.saveRecentItems(result.data);
                        }
                    })
                    .catch(error => {
                        this.error = parseErrorMessage(error);
                    })
                    .finally(() => {
                        this.showLoading = false;
                        this.isDirty = false;
                    });
                } else {
                    this.showLoading = false;
                    this.isDirty = false;
                    this.showSaveSuccessNotification();
                    this.saveRecentItems(result.data);
                }
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            });
    }

    showSaveSuccessNotification () {
        const evt = new ShowToastEvent({
            title: `${this.i18n.saveSuccess}`,
            variant: 'success'
        });
        this.dispatchEvent(evt);
        this.navigateToListView();
    }

    handleMenuSelection (event) {
        handleMenuSelection(event, this);
    }

    navigateToListView () {
        this.clearState();
        handleMenuSelection({
            detail: {
                name: "timeline",
                targetType: "LWC",
                targetDeveloperName: "c-asset-timeline-admin-list"
            }
        }, this);
    }

    saveRecentItems (data) {

        const recentlyViewedRecord = {
            configurationId: data.id,
            configurationName: data.name,
            configurationDeveloperName: data.developerName,
            configurationType: ADMIN_MODULES.ASSET_TIMELINE
        };
        saveRecentViewItem(recentlyViewedRecord)
            .then(recentItem => {
                if (!verifyApiResponse(recentItem)) {
                    this.error = recentItem.message;
                }
            });

    }

    handleCancel () {
        if (this.isDirty) {
            this.cancelModalDialogOpen = true;
        } else {
            this.navigateToListView();
        }
    }

    handleCancelModal () {
        this.cancelModalDialogOpen = false;
    }

    handleCancelConfirmModal () {
        this.cancelModalDialogOpen = false;
        this.navigateToListView();
    }

    handleCancelObjectModal () {
        this.saveError = undefined;
        this.objectPropertiesModalDialogOpen = false;
    }

    handleMatchModal () {
        this.matchModalDialogOpen = false;
    }

    handleCloseModal () {
        this.selectorModalOpen = false;
    }

    handleConfigObjectIconPickerClose () {
        this.showConfigObjectIconPickerModal = false;
    }

    clearState () {
        this.error = null;
        this._actionName = null;
        this.recordInfo = {};
        this.timelineConfigDetails = [];
        this.timelineConfigAccess = [];
        this.reAssignedProfileDetails = [];
        this.previouslyAssignedProfiles = [];
        this.apiInProgress = false;
        this.isDirty = false;
        this.showProfileSelector = false;
        this.showConfigDetails = false;
        this.updatedBandLabel = undefined;
        this.updatedEventsLabel = undefined;
        this.updatedMilestonesLabel = undefined;
    }

    isValidInput (inputFieldClass) {

        this.error = '';
        const isValid = [...this.template.querySelectorAll(
            inputFieldClass)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (!isValid) {
            this.error = this.i18n.formValidation;
        }
        return isValid;
    }

    handleShowMatchingRecordsChange () {
        this.objectPropertyChanged = true;
    }

    handleColorBarMouseLeave () {
        this.showColorBar = false;
        raf(() => {
            this.showColorBar = true;
        }).call(this);
        const colorBar = this.template.querySelector('.svmx-colorbar');
        if (colorBar) {
            colorBar.classList.remove('colorBar');
        }
    }

    handleColorBarMouseEnter () {
        const colorBar = this.template.querySelector('.svmx-colorbar');
        if (colorBar) {
            colorBar.classList.add('colorBar');
        }
    }

    handleStepOrderClosed () {
        this.reorderStepsOpen = false;
    }

    handleStepOrderChange (event) {
        const orderedObjectValues = event.detail.value;
        let count = 0;
        switch (this.selectedTypeVal) {
            case 'reorderBands':
                this.sortObjects(
                    orderedObjectValues,
                    this.timelineConfigDetails.filter(
                        det => !isEmptyString(det.endDateFieldAPIName)
                        && det.objectAPIName.toLowerCase() !== 'asset'),
                    count);
                this.isDirty = true;
                break;
            case 'reorderEvents':
                count = this.objectsConfiguredAsBands.length;
                this.sortObjects(orderedObjectValues,
                    this.timelineConfigDetails.filter(
                        det => isEmptyString(det.endDateFieldAPIName)
                        && det.objectAPIName.toLowerCase() !== 'asset'),
                    count);
                this.isDirty = true;
                break;
            case 'reorderMilestones':
                count = this.objectsConfiguredAsBands.length+this.objectsConfiguredAsEvents.length;
                this.sortObjects(
                    orderedObjectValues,
                    this.timelineConfigDetails.filter(
                        det => det.objectAPIName.toLowerCase() === 'asset'),
                    count);
                this.isDirty = true;
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
        this.handleStepOrderClosed();
    }

    sortObjects (orderedObjectValues,sortedSteps,count) {
        if (orderedObjectValues) {
            for (let i = 0; i < orderedObjectValues.length; i++) {
                const dataIndex = sortedSteps.findIndex(
                    step => this.getObjOrderVal(step) === orderedObjectValues[i]);
                if (dataIndex > -1) {
                    // eslint-disable-next-line no-param-reassign
                    sortedSteps[dataIndex].sequence = ++count;
                }
            }
        } else {
            sortedSteps.forEach(
                step => {
                    // eslint-disable-next-line no-param-reassign
                    step.sequence = ++count;
                });
        }
        return sortedSteps;
    }

    getObjOrderVal (step) {
        let labelVal = step.objectAPIName;
        if (labelVal.toLowerCase() === 'asset') {
            labelVal+= ' ('+step.startDateFieldAPIName;
            if (step.endDateFieldAPIName) {
                labelVal+=' - '+step.endDateFieldAPIName;
            }
            labelVal+=')';
        }
        if (step.qualifyingCriteriaName) {
            labelVal+= ' - '+step.qualifyingCriteriaName;
        }
        // eslint-disable-next-line max-len
        return labelVal+'-'+step.startDateFieldAPIName+'-'+step.endDateFieldAPIName+'-'+step.displayFieldAPIName;
    }

    handleCancelTitleCategory () {
        this.showRenameTitle = false;
    }

    handleSaveTitleCategorytModal () {
        const textVal = this.template.querySelector('.titleClass').value;
        if (textVal.trim() === '') {
            return;
        }
        switch (this.selectedTypeVal) {
            case 'renameBands':
                if (this.updatedBandLabel !== textVal) {
                    this.isDirty = true;
                }
                this.updatedBandLabel = textVal;
                break;
            case 'renameEvents':
                if (this.updatedEventsLabel !== textVal) {
                    this.isDirty = true;
                }
                this.updatedEventsLabel = textVal;
                break;
            case 'renameMilestones':
                if (this.updatedMilestonesLabel !== textVal) {
                    this.isDirty = true;
                }
                this.updatedMilestonesLabel = textVal;
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
        this.handleCancelTitleCategory();
    }

    handleSettingsMenuSelect (event) {
        let sortedSteps = [];
        this.selectedTypeVal = event.detail.value;
        switch (this.selectedTypeVal) {
            case 'reorderBands':
                sortedSteps = this.objectsConfiguredAsBands;
                break;
            case 'reorderEvents':
                sortedSteps = this.objectsConfiguredAsEvents;
                break;
            case 'reorderMilestones':
                sortedSteps = this.objectsConfiguredAsMilestones;
                break;
            // comment below for eslint which errors when no default case exists.
            // No Default
        }
        if (this.selectedTypeVal.startsWith('reorder')) {
            this.objectSeqOptions = sortedSteps.map(step => {
                let labelVal = step.objectAPIName;
                if (labelVal.toLowerCase() === 'asset') {
                    labelVal+= ' ('+step.startDateFieldAPIName;
                    if (step.endDateFieldAPIName) {
                        labelVal+=' - '+step.endDateFieldAPIName;
                    }
                    labelVal+=')';
                }
                if (step.qualifyingCriteriaName) {
                    labelVal+= ' - '+step.qualifyingCriteriaName;
                }
                // eslint-disable-next-line max-len
                const value = this.getObjOrderVal(step);
                return {
                    label: labelVal,
                    value: value
                };
            });
            this.reorderStepsOpen = true;
        } else if (this.selectedTypeVal.startsWith('rename')) {
            switch (this.selectedTypeVal) {
                case 'renameBands':
                    this.currTitleName = this.bandLabel;
                    break;
                case 'renameEvents':
                    this.currTitleName = this.eventsLabel;
                    break;
                case 'renameMilestones':
                    this.currTitleName = this.milestonesLabel;
                    break;
                // comment below for eslint which errors when no default case exists.
                // No Default
            }
            this.showRenameTitle = true;
        }
    }
}