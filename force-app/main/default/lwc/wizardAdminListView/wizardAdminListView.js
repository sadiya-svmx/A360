import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import TIMEZONE from '@salesforce/i18n/timeZone';
import {
    isEmptyString,
    PAGE_ACTION_TYPES,
    parseErrorMessage,
    sortObjectArray,
    verifyApiResponse,
    ICON_NAMES
} from 'c/utils';

import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';
import getProcessWizardSummary
    from '@salesforce/apex/ADM_ProcessWizardLightningService.getProcessWizardSummary';

import labelServiceProcessManager from '@salesforce/label/c.Label_Service_Process_Manager';
import labelWizards from '@salesforce/label/c.Label_Wizards';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelItemsRowCount from '@salesforce/label/c.Label_ItemsRowCount';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelObjectName from '@salesforce/label/c.Label_ObjectName';
import labelActiveWizards from '@salesforce/label/c.Label_ActiveWizards';
import labelInActiveWizards from '@salesforce/label/c.Label_InactiveWizards';
import labelLastModified from '@salesforce/label/c.Label_LastModified';
import labelLastModifiedBy from '@salesforce/label/c.Label_LastModifiedBy';
import labelDeveloperName from '@salesforce/label/c.Label_DeveloperName';
import labelWizardHelp from '@salesforce/label/c.URL_WizardHelp';
import labelAddObject from '@salesforce/label/c.Button_AddObject';
import labelSelect from '@salesforce/label/c.Button_Select';
import labelSelectObjectTitle from '@salesforce/label/c.Title_ObjectSelector';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelObjectSelectorCount from '@salesforce/label/c.Label_ObjectsFound';
import labelApiName from '@salesforce/label/c.Label_APIName';
import labelInvalidObjectMultipleWizards
    from '@salesforce/label/c.Message_InvalidObject_WizardMultiple';
import labelInvalidObjectSingleWizard
    from '@salesforce/label/c.Message_InvalidObject_WizardSingle';

const i18n = {
    activeWizards: labelActiveWizards,
    addObject: labelAddObject,
    apiName: labelApiName,
    cancel: labelCancel,
    developerName: labelDeveloperName,
    help: labelHelp,
    helpLink: labelWizardHelp,
    inactiveWizards: labelInActiveWizards,
    items: labelItemsRowCount,
    lastModified: labelLastModified,
    lastModifiedBy: labelLastModifiedBy,
    loading: labelLoading,
    noResults: labelNoResults,
    objectName: labelObjectName,
    objectSelectorCountLabel: labelObjectSelectorCount,
    pageHeader: labelServiceProcessManager,
    searchPlaceholder: labelSearchPlaceholder,
    select: labelSelect,
    selectObjectTitle: labelSelectObjectTitle,
    wizards: labelWizards,
    invalidObjectForMultipleWizards: labelInvalidObjectMultipleWizards,
    invalidObjectForSingleWizard: labelInvalidObjectSingleWizard
};

const WIZARD_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__wizardDetail'
    }
}
export default class WizardAdminListView extends NavigationMixin(LightningElement) {
    @track apiInProgress = false;
    @track columns;
    @track error;
    @track listViewData;
    @track selectObjectDialogOpen;
    @track sortBy = 'recordUrl';
    @track sortDirection = 'asc';
    @track wizardDetailUrl;
    @track entityOptions = [];

    @track objectSelectorData;
    @track objectSelectorError;
    @track objectSelectorColumns = [
        { label: i18n.objectName, fieldName: 'label' },
        { label: i18n.apiName, fieldName: 'value' }
    ]

    currentNavItem;
    listViewHeaderHeight = 100;
    wizardData;

    constructor () {
        super();
        this.columns = this.getColumns();
    }

    get i18n () {
        return i18n;
    }

    get rowCount () {
        return (this.listViewData) ? this.listViewData.length : 0;
    }

    get rowCountPhrase () {
        return ( this.listViewData ? this.listViewData.length : 0 )
                 + ' ' + i18n.items;
    }

    get computedDataTableHeight () {
        if (this.rowCount > 0) {
            return `height: calc(100% - ${this.listViewHeaderHeight}px)`;
        }

        return '';
    }

    get objectSelectorListBoxElement () {
        return this.template.querySelector(".objectSelectorListBox");
    }

    @api
    get srcIconName () {
        return ICON_NAMES.SVMXLOGO;
    }
    @api iconSize = 'large';

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
        this[NavigationMixin.GenerateUrl](WIZARD_DETAIL_VIEW)
            .then(url => {
                this.wizardDetailUrl = url;
                this.populateListView();
            });
    }

    renderedCallback () {
        const listViewHeader = this.template.querySelector('.list-view-header');

        if (listViewHeader) {
            this.listViewHeaderHeight = listViewHeader.offsetHeight;
        }

        this.toggleSelectorModalButton();
    }

    clearObjectSelectorSearchValue () {
        const listBox = this.objectSelectorListBoxElement;

        if (listBox) {
            listBox.searchInputValue = null;
        }

    }

    clearSearchInputValue () {
        const input = this.template.querySelector('.search-input');

        if (input) {
            input.value = '';
        }
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.sortData(this.wizardData);
        } else {
            this.listViewData = this.wizardData.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();

                const objectLabelMatch = (item.objectLabel)
                    ? item.objectLabel.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                const objectAPINameMatch = (item.objectAPIName)
                    ? item.objectAPIName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;

                return (
                    objectLabelMatch !== -1
                    || objectAPINameMatch !== -1
                );
            });
        }
    }

    getColumns () {
        return [
            {
                label: this.i18n.objectName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'xUrl',
                typeAttributes: {
                    disabled: { fieldName: 'navigationDisabled' },
                    label: { fieldName: 'objectLabel' },
                    tooltip: { fieldName: 'objectToolTip' },
                    target: '_self'
                },
                cellAttributes: {
                    class: { fieldName: 'objectClass' },
                }
            },
            {
                label: this.i18n.activeWizards,
                fieldName: 'activeWizards',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: this.i18n.inactiveWizards,
                fieldName: 'inactiveWizards',
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
                    };
                });
            });
    }

    getWizardViewData () {
        return getProcessWizardSummary()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }

                this.error = null;
                this.wizardData = result.data;
            });
    }

    getListViewData () {
        this.apiInProgress = true;
        Promise.all([this.getEntityDefinitions(), this.getWizardViewData()])
            .then(() => {
                this.populateListView();
            })
            .catch(error => {
                this.entityOptions = [];
                this.listViewData = [];
                this.wizardData = []
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    handleCancelModal () {
        this.clearObjectSelectorSearchValue();
        this.populateObjectSelectorData();
        this.selectObjectDialogOpen = false;
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.listViewData);
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    handleNewObject (event) {
        event.preventDefault();

        this.selectObjectDialogOpen = true;
    }

    handleObjectSelect (event) {
        event.preventDefault();

        this.selectObjectDialogOpen = false;

        const listBox = this.objectSelectorListBoxElement;

        if (listBox && listBox.selectedRow) {
            const hasCells = (listBox.selectedRow.cells && listBox.selectedRow.cells.length > 0);
            const objectLabel = hasCells ? listBox.selectedRow.cells[0].value : '';
            const objectApiName = listBox.selectedRow.value;
            this.navigateToDetailComponent(PAGE_ACTION_TYPES.NEW, objectApiName, objectLabel);
        }
    }

    handleRowSelected (event) {
        event.preventDefault();
        this.toggleSelectorModalButton();
    }

    handleListSearchKeyChange (event) {
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

    handleObjectSelectorSearchKeyChange (event) {
        const searchKey = event.detail.value;

        if (searchKey && searchKey.length >= 1 && searchKey.length < 3) {
            return;
        }

        window.clearTimeout(this.delayTimeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            try {
                this.populateObjectSelectorData(searchKey);
                this.objectSelectorError = null;
            } catch (e) {
                this.objectSelectorError = parseErrorMessage(e);
            }
        }, 300);
    }

    toggleSelectorModalButton () {
        if (!this.selectObjectDialogOpen) return;

        const selectButton = this.template.querySelector('.objectSelectButton');
        if (selectButton) {
            selectButton.disabled = !this.isObjectSelectorRowSelected();
        }
    }

    isObjectSelectorRowSelected () {
        const listBox = this.objectSelectorListBoxElement;

        if (listBox && listBox.selectedRow) {
            return true;
        }

        return false;
    }

    navigateToDetailComponent (actionName, objectApiName, objectLabel) {
        const navState = {
            c__actionName: actionName
        }

        if (objectApiName) {
            navState.c__objectName = objectApiName;
        }

        if (objectLabel) {
            navState.c__objectLabel = objectLabel;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, WIZARD_DETAIL_VIEW);
        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    populateListView () {
        if (this.wizardDetailUrl
            && (this.entityOptions && this.entityOptions.length > 0)
            && this.wizardData) {


            this.wizardData.forEach(row => {
                const objectLabel = this.getLabelFromEntityList(row.objectAPIName);
                const objectInvalid = isEmptyString(objectLabel);

                row.navigationDisabled = objectInvalid;
                row.objectLabel = objectInvalid ? row.objectAPIName : objectLabel;
                row.objectClass = objectInvalid ? 'slds-text-color_error' : '';

                const urlParams = [
                    `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                    `c__objectName=${row.objectAPIName}`,
                    `c__objectLabel=${row.objectLabel}`,
                    `c__currentItem=${this.currentNavItem}`].join('&');

                row.recordUrl = `${this.wizardDetailUrl}?${urlParams}`;

                const wizardCount = row.activeWizards + row.inactiveWizards;
                const errorTooltip = wizardCount > 1
                    ? i18n.invalidObjectForMultipleWizards : i18n.invalidObjectForSingleWizard;

                const tooltip = objectInvalid
                    ? errorTooltip : `${row.objectLabel}\n${row.objectAPIName}`;

                row.objectToolTip = tooltip;
            });

            this.sortData(this.wizardData);

            this.populateObjectSelectorData();

            this.apiInProgress = false;
        }
    }

    populateObjectSelectorData (searchValue) {
        const uniqueObjectNames = this.getUniqueObjectNames();

        const filteredEntityOptions = this.entityOptions.filter(item =>
            !uniqueObjectNames.includes(item.value)
        );

        this.objectSelectorData = filteredEntityOptions.filter(item => {

            if (!searchValue || searchValue.length === 0 ) {
                return true;
            }

            const loweredSearchValue = searchValue.toLowerCase();

            const labelMatch = item.label
                ? item.label.toLowerCase().indexOf(loweredSearchValue)
                : -1;

            const apiNameMatch = item.value
                ? item.value
                    .toLowerCase()
                    .indexOf(loweredSearchValue)
                : -1;

            return (
                labelMatch !== -1 ||
                apiNameMatch !== -1
            );
        });
    }

    getUniqueObjectNames () {
        if (this.listViewData) {
            return this.listViewData.map(row => row.objectAPIName);
        }

        return [];
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

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "objectLabel" : this.sortBy;

        this.listViewData = sortObjectArray(incomingData, sortByOverride, this.sortDirection);
    }
}