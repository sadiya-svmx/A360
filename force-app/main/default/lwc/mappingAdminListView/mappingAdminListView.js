import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import getAllObjectMappings
    from '@salesforce/apex/ADM_ObjectMappingLightningService.getAllObjectMappings';
import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';
import deleteObjectMapping
    from '@salesforce/apex/ADM_ObjectMappingLightningService.deleteObjectMapping';
import { deleteRecentItemRecords } from 'c/recentItemService';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    isEmptyString,
    MAPPING_TYPES,
    PAGE_ACTION_TYPES,
    parseErrorMessage,
    sortObjectArray,
    verifyApiResponse,
    ICON_NAMES
} from 'c/utils';

import labelMappingTitle from '@salesforce/label/c.Title_Mappings';
import labelMappingName from '@salesforce/label/c.Label_Mapping_Name';
import labelTargetObject from '@salesforce/label/c.Label_TargetObject';
import labelSourceObject from '@salesforce/label/c.Label_SourceObject';
import labelWhereUsed from '@salesforce/label/c.Label_WhereUsed';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelAllMappingsMenuItem from '@salesforce/label/c.Menu_AllMappings';
import labelFieldMappingsMenuItem from '@salesforce/label/c.Menu_FieldMappings';
import labelValueMappingsMenuItem from '@salesforce/label/c.Menu_ValueMappings';
import labelNewMappingButton from '@salesforce/label/c.Button_NewMapping';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelLoadingMappings from '@salesforce/label/c.AltText_LoadingMappings';
import labelNewModalTitle from '@salesforce/label/c.Label_New_Record_Modal_Title';
import labelModalFieldMappingType from '@salesforce/label/c.Label_FieldMappingType';
import labelModalFieldMappingExplanation from '@salesforce/label/c.Label_FieldMappingExplanation';
import labelModalFieldMappingExample from '@salesforce/label/c.Label_FieldMappingExample';
import labelModalSourceObject from '@salesforce/label/c.Label_SourceObjectNewMapping';
import labelModalTargetObject from '@salesforce/label/c.Label_TargetObjectNewMapping';
import labelSelectSourceObject from '@salesforce/label/c.Label_SelectSourceObject';
import labelSelectTargetObject from '@salesforce/label/c.Label_SelectTargetObject';
import labelModalValueMappingType from '@salesforce/label/c.Label_ValueMappingType';
import labelSelectPlaceholder from '@salesforce/label/c.Placeholder_Select';
import labelComboPlaceholder from '@salesforce/label/c.Combo_Placeholder';
import labelObject from '@salesforce/label/c.Label_Object';
import labelModalValueMappingExplanation from '@salesforce/label/c.Label_ValueMappingExplanation';
import labelModalValueMappingExample from '@salesforce/label/c.Label_ValueMappingExample';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelMapping from '@salesforce/label/c.Label_Mapping';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelMappingHelp from '@salesforce/label/c.URL_MappingHelp';
import labelInvalidObjectSourceAndTarget
    from '@salesforce/label/c.Message_InvalidObject_MappingBoth';
import labelInvalidObjectSource
    from '@salesforce/label/c.Message_InvalidObject_MappingSource';
import labelInvalidObjectTarget
    from '@salesforce/label/c.Message_InvalidObject_MappingTarget';

const i18n = {
    pageHeader: labelMappingTitle,
    allMappingsMenuItem: labelAllMappingsMenuItem,
    fieldMappingsMenuItem: labelFieldMappingsMenuItem,
    valueMappingsMenuItem: labelValueMappingsMenuItem,
    new: labelNewMappingButton,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    items: labelItemsRowCount,
    searchPlaceholder: labelSearchPlaceholder,
    help: labelHelp,
    loading: labelLoadingMappings,
    newModalTitle: labelNewModalTitle,
    fieldMappingType: labelModalFieldMappingType,
    fieldMappingExplanation: labelModalFieldMappingExplanation,
    fieldMappingExample: labelModalFieldMappingExample,
    selectSource: labelSelectSourceObject,
    selectTarget: labelSelectTargetObject,
    select: labelSelectPlaceholder,
    sourceComboLabel: labelModalSourceObject,
    targetComboLabel: labelModalTargetObject,
    objectComboLabel: labelObject,
    comboPlaceholder: labelComboPlaceholder,
    valueMappingType: labelModalValueMappingType,
    valueMappingExplanation: labelModalValueMappingExplanation,
    valueMappingExample: labelModalValueMappingExample,
    cancel: labelCancel,
    confirm: labelConfirm,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    mapping: labelMapping,
    mappingName: labelMappingName,
    deleteSuccess: labelDeletedSuccess,
    targetObject: labelTargetObject,
    sourceObject: labelSourceObject,
    whereUsed: labelWhereUsed,
    developerName: labelDeveloperName,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    noResults: labelNoResults,
    mappingHelpLink: labelMappingHelp,
    invalidSourceObject: labelInvalidObjectSource,
    invalidTargetObject: labelInvalidObjectTarget,
    invalidSourceAndTarget: labelInvalidObjectSourceAndTarget,
};

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.whereUsed, name: 'whereused' },
    { label: i18n.delete, name: 'delete' }
];

const DISABLED_ROW_ACTIONS = [
    { label: i18n.delete, name: 'delete' }
];

const VIEW_FILTER_MENU_ITEMS = [
    { id: '1', label: i18n.allMappingsMenuItem, value: 'All', checked: true },
    { id: '2', label: i18n.fieldMappingsMenuItem, value: MAPPING_TYPES.FIELD },
    { id: '3', label: i18n.valueMappingsMenuItem, value: MAPPING_TYPES.VALUE }
];

const MAPPING_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__mappingDetail'
    }
}

export default class MappingAdminListView extends NavigationMixin(LightningElement) {

    objectMappingData;
    objectMappingWire;
    pendingDeleteRecord;
    currentPageReference;
    currentNavItem;

    @track mappingDetailUrl;
    @track listViewData;
    @track columns;
    @track sortBy = 'recordUrl';
    @track sortDirection = 'asc';
    @track newModalDialog;
    @track deleteModalDialogOpen;
    @track entityOptions = [];
    @track error;
    @track viewFilterMenuItems = VIEW_FILTER_MENU_ITEMS;
    @track selectedFilterView = i18n.allMappingsMenuItem;
    @track apiInProgress = false;
    @track newMappingType = MAPPING_TYPES.FIELD;

    @track moduleType = '';
    @track configurationId = '';
    @track configDeveloperName = '';
    @track configName = '';
    @track operationType = '';
    @track deleteWhereUsedModalDialogOpen = false;
    @track row;

    _listViewHeaderHeight = 100;

    get rowCount () {
        return (this.listViewData) ? this.listViewData.length : 0;
    }

    get rowCountPhrase () {
        return ( this.listViewData ? this.listViewData.length : 0 )
                 + ' ' + i18n.items;
    }

    get i18n () {
        return i18n;
    }

    get mappingTypes () {
        return MAPPING_TYPES;
    }

    get computedDataTableHeight () {
        return `height: calc(100% - ${this._listViewHeaderHeight}px)`;
    }

    get newMappingModalElement () {
        return this.template.querySelector(".new-mapping-modal");
    }

    get fieldMappingSourceComboElement () {
        const newMappingModal = this.newMappingModalElement;

        return newMappingModal.querySelector('.field-mapping-source-object');
    }

    get fieldMappingTargetComboElement () {
        const newMappingModal = this.newMappingModalElement;

        return newMappingModal.querySelector('.field-mapping-target-object');
    }

    get valueMappingSourceComboElement () {
        const newMappingModal = this.newMappingModalElement;

        return newMappingModal.querySelector('.value-mapping-source-object');
    }

    get newMappingConfirmButton () {
        const newMappingModal = this.newMappingModalElement;
        return newMappingModal.querySelector('.confirmButton');
    }

    get fieldMappingChecked () {
        return this.newMappingType === MAPPING_TYPES.FIELD;
    }

    get valueMappingChecked () {
        return this.newMappingType === MAPPING_TYPES.VALUE;
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

    constructor () {
        super();
        this.columns = this.getColumns();
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef) {

            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.clearSearchInputValue();
            this.getListViewData();
        }
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](MAPPING_DETAIL_VIEW)
            .then(url => {
                this.mappingDetailUrl = url;
                this.populateListView();
            });
    }

    renderedCallback () {
        const listViewHeader = this.template.querySelector('.list-view-header');

        if (listViewHeader) {
            this._listViewHeaderHeight = listViewHeader.offsetHeight;
        }
    }

    getColumns () {
        return [
            {
                label: this.i18n.mappingName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'xUrl',
                typeAttributes: {
                    disabled: { fieldName: 'navigationDisabled' },
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: 'mappingToolTip' },
                    target: '_self'
                },
                cellAttributes: {
                    class: { fieldName: 'mappingNameClass' },
                }
            },
            {
                label: this.i18n.sourceObject,
                fieldName: 'sourceObjectName',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: {
                    class: { fieldName: 'sourceObjectClass' },
                }
            },
            {
                label: this.i18n.targetObject,
                fieldName: 'targetObjectName',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                cellAttributes: {
                    class: { fieldName: 'targetObjectClass' },
                }
            },
            {
                label: this.i18n.developerName,
                fieldName: 'developerName',
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
                type: "date",
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
                typeAttributes: {
                    rowActions: { fieldName: 'actions' }
                },
            }
        ];
    }

    getEntityDefinitions () {
        return getAllEntityDefinitions()
            .then (result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }
                this.error = null;
                this.entityOptions = result.data.map(entity => {
                    return {
                        label: entity.label,
                        value: entity.apiName,
                        secondary: entity.apiName
                    }
                });
            });

    }

    getObjectMappings () {
        return getAllObjectMappings()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.error = null;
                this.objectMappingData = this.getMappedData(result.data);
            });
    }

    getListViewData () {
        this.apiInProgress = true;
        Promise.all([this.getEntityDefinitions(), this.getObjectMappings()])
            .then(() => {
                this.populateListView();
            })
            .catch(error => {
                this.entityOptions = [];
                this.objectMappingData = [];
                this.listViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    populateListView () {
        if (this.mappingDetailUrl
            && (this.entityOptions && this.entityOptions.length > 0)
            && this.objectMappingData) {

            this.objectMappingData.forEach(row => {
                row.targetObjectName = this.getLabelFromEntityList(row.targetObjectAPIName);
                row.sourceObjectName = this.getLabelFromEntityList(row.sourceObjectAPIName);
                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`].join('&');

                row.recordUrl = `${this.mappingDetailUrl}?${urlParams}`;

                const sourceInvalid = !isEmptyString(row.sourceObjectAPIName)
                    && isEmptyString(row.sourceObjectName);

                const targetInvalid = isEmptyString(row.targetObjectName);

                if (targetInvalid) {
                    row.targetObjectName = row.targetObjectAPIName;
                    row.targetObjectClass = 'slds-text-color_error';
                }

                if (sourceInvalid) {
                    row.sourceObjectName = row.sourceObjectAPIName;
                    row.sourceObjectClass = 'slds-text-color_error';
                }

                row.navigationDisabled = sourceInvalid || targetInvalid;

                if (row.navigationDisabled) {
                    let errorTooltip;

                    if (sourceInvalid && targetInvalid) {
                        errorTooltip = i18n.invalidSourceAndTarget
                    } else if (sourceInvalid) {
                        errorTooltip = i18n.invalidSourceObject;
                    } else {
                        errorTooltip = i18n.invalidTargetObject;
                    }

                    row.mappingToolTip = errorTooltip;
                }

                row.mappingNameClass = (row.navigationDisabled) ? 'slds-text-color_error' : null;
                row.actions = (row.navigationDisabled) ? DISABLED_ROW_ACTIONS : ROW_ACTIONS;
            });

            this.sortData(this.objectMappingData);

            this.apiInProgress = false;
        }
    }

    getLabelFromEntityList (apiName) {
        let label = '';

        if (this.entityOptions && this.entityOptions.length > 0) {
            const entityOpt = this.entityOptions.find(opt => opt.value === apiName);

            if (entityOpt) {
                label = entityOpt.label;
            }
        }

        return label;
    }

    getMappedData (data) {
        return data.map(row => {
            const mappingTooltipRows = [
                row.name,
                row.developerName
            ];
            if (row.description) {
                mappingTooltipRows.push(row.description);
            }
            return {
                targetObjectAPIName: row.targetObjectAPIName,
                targetObjectName: '',
                sourceObjectAPIName: row.sourceObjectAPIName,
                sourceObjectName: '',
                objectMappingDetails: row.objectMappingDetails,
                mappingType: row.mappingType,
                lastModifiedDate: row.lastModifiedDate,
                lastModifiedBy: row.lastModifiedBy,
                name: row.name,
                developerName: row.developerName,
                id: row.id,
                description: row.description,
                recordUrl: '',
                navigationDisabled: false,
                sourceObjectClass: null,
                targetObjectClass: null,
                mappingNameClass: null,
                actions: [],
                mappingToolTip: mappingTooltipRows.join('\n ')
            }
        });
    }

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "name" : this.sortBy;

        this.listViewData = sortObjectArray(incomingData, sortByOverride, this.sortDirection);
    }

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');

        if (input) {
            input.value = '';
        }
    }

    handleHelpClick () {
        window.open(i18n.mappingHelpLink, '_blank');
    }

    handleViewFilter (event) {
        const selectedItemValue = event.detail.value;

        // Clear Search Value.
        this.clearSearchInputValue();

        // Check the selected Menu Item.
        // eslint-disable-next-line no-return-assign
        this.viewFilterMenuItems.forEach(item => item.checked = false);

        const menuItem = this.viewFilterMenuItems.find(item => item.value === selectedItemValue);
        menuItem.checked = true;
        this.selectedFilterView = menuItem.label;

        // Filter the list view data.
        this.filterListViewDataByView(selectedItemValue);
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.listViewData);
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.filterListViewData(searchKey);

            } catch (e) {
                this.error = parseErrorMessage(e);
            }
        }, 300);
    }

    filterListViewData (searchValue) {
        let listViewDataToBeFiltered;
        if (this.selectedFilterView === i18n.allMappingsMenuItem) {
            listViewDataToBeFiltered = this.objectMappingData;
        } else if (this.selectedFilterView === i18n.fieldMappingsMenuItem) {
            this.filterListViewDataByView(MAPPING_TYPES.FIELD);
            listViewDataToBeFiltered = this.listViewData;
        } else if (this.selectedFilterView === i18n.valueMappingsMenuItem) {
            this.filterListViewDataByView(MAPPING_TYPES.VALUE);
            listViewDataToBeFiltered = this.listViewData;
        }
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.sortData(listViewDataToBeFiltered);
        } else {
            this.listViewData = listViewDataToBeFiltered.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const targetMatch = (item.targetObjectName)
                    ? item.targetObjectName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const sourceMatch = (item.sourceObjectName)
                    ? item.sourceObjectName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const nameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const developerNameMatch = (item.developerName)
                    ? item.developerName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (
                    targetMatch !== -1
                    || sourceMatch !== -1
                    || nameMatch !== -1
                    || developerNameMatch !== -1
                );
            });
        }
    }

    filterListViewDataByView (viewFilter) {
        let filteredData = this.objectMappingData;

        if (viewFilter !== 'All') {
            filteredData = filteredData.filter(item => item.mappingType === viewFilter);
        }

        this.sortData(filteredData);
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.navigateToDetailComponent(row.id, PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.navigateToDetailComponent(row.id, PAGE_ACTION_TYPES.CLONE);
                break;
            case 'delete':
                this.checkWhereUsed(row, 'delete');
                break;
            case 'whereused':
                this.checkWhereUsed(row, 'whereused');
                break;

            // comment below for eslint which errors when no default case exists.
            // No Default
        }
    }

    handleCancelWhereUsedModal () {
        this.deleteWhereUsedModalDialogOpen =  false;
    }

    handleDeleteModal (event) {
        this.deleteWhereUsedModalDialogOpen =  false;
        this.deleteRow(event.detail.row);
    }

    navigateToDetailComponent (recordId, actionName, mappingType, source, target) {
        const navState = {
            c__actionName: actionName
        }

        if (recordId) {
            navState.c__recordId = recordId;
        }

        if (mappingType) {
            navState.c__mappingType = mappingType;
        }

        if (source) {
            navState.c__source = source;
        }

        if (target) {
            navState.c__target = target;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, MAPPING_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;

    }

    checkWhereUsed (row, operationType) {
        this.moduleType = 'Mapping';
        this.configurationId = row.id;
        this.configDeveloperName = row.developerName;
        this.configType = row.mappingType;
        this.configName = row.name;
        this.operationType = operationType;
        this.deleteWhereUsedModalDialogOpen = true;
        this.row = row;
    }

    handleCancelModal () {
        this.newModalDialog = false;
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deleteObjectMapping({ requestJson: JSON.stringify({ id: this.pendingDeleteRecord.id }) })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.name);

                deleteRecentItemRecords(recentlyViewedRecord).then(recentItem => {
                    if (recentItem && !verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });

                this.getListViewData();
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

    showDeletionSuccessNotification (mappingName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.mapping} "${mappingName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleConfirmModal () {
        const mappingType = (this.fieldMappingChecked) ? MAPPING_TYPES.FIELD : MAPPING_TYPES.VALUE;
        const sourceObjectApiName = (this.fieldMappingChecked)
            ? this.fieldMappingSourceComboElement.value
            : '' ;
        const targetObjectApiName = (this.fieldMappingChecked)
            ? this.fieldMappingTargetComboElement.value
            : this.valueMappingSourceComboElement.value;

        this.resetNewMappingComboValues();

        this.newModalDialog = false;
        this.newMappingType = MAPPING_TYPES.FIELD;

        this.navigateToDetailComponent(
            null,
            PAGE_ACTION_TYPES.NEW,
            mappingType,
            sourceObjectApiName,
            targetObjectApiName
        );
    }

    handleNewMapping () {
        this.newModalDialog = true;
    }

    handleModalComboChange (event) {
        const comboSelectedValue = event.detail.value;
        let confirmButtonEnabled = false;

        if (comboSelectedValue) {

            if (this.fieldMappingChecked) {
                const fieldSourceCombo = this.fieldMappingSourceComboElement;
                const fieldTargetCombo = this.fieldMappingTargetComboElement;
                // Check Source and Target Comboboxes
                confirmButtonEnabled = (fieldSourceCombo.value && fieldTargetCombo.value);

            } else {
                const valueCombo = this.valueMappingSourceComboElement;
                // Only Target is visible, so check for a value in Target Combo only
                confirmButtonEnabled = (valueCombo.value);
            }
        }

        this.newMappingConfirmButton.disabled = !confirmButtonEnabled;
    }

    handleMappingTypeChange (event) {
        this.newMappingType = event.target.value;

        this.resetNewMappingComboValues();

        this.newMappingConfirmButton.disabled = true;
    }

    resetNewMappingComboValues () {
        const fieldSourceCombo = this.fieldMappingSourceComboElement;
        const fieldTargetCombo = this.fieldMappingTargetComboElement;
        const valueCombo = this.valueMappingSourceComboElement;

        if (fieldSourceCombo) {
            fieldSourceCombo.value = undefined;
        }

        if (fieldTargetCombo) {
            fieldTargetCombo.value = undefined;
        }

        if (valueCombo) {
            valueCombo.value = undefined;
        }
    }
}