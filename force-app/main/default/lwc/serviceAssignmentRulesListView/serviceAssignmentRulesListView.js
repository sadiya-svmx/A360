import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceAssignmentRules
    from '@salesforce/apex/ADM_EntitlementLightningService.getServiceAssignmentRules';
import deleteServiceAssignmentRule
    from '@salesforce/apex/ADM_EntitlementLightningService.deleteServiceAssignmentRule';
import { deleteRecentItemRecords } from 'c/recentItemService';

import updateServiceAssignmentSequence
    from '@salesforce/apex/ADM_EntitlementLightningService.updateServiceAssignmentRulesSequence';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelShowInactive from '@salesforce/label/c.Label_Show_Inactive';
import labelReOrder from '@salesforce/label/c.Label_ReOrder';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelOrder from '@salesforce/label/c.Label_Order';
import labelServiceName from '@salesforce/label/c.Label_ServiceName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelActive from '@salesforce/label/c.Label_Active';
import labelServiceAssignmentRule from '@salesforce/label/c.Label_Service_Assignment_Rule';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelRuleExecutionOrder from '@salesforce/label/c.Label_RuleExecutionOrder';
import labelRulesProcessed from '@salesforce/label/c.Message_RulesProcessed';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelSequencesUpdated from '@salesforce/label/c.Message_SequencesUpdated';
import labelYes from '@salesforce/label/c.Lbl_Yes';
import labelNo from '@salesforce/label/c.Lbl_No';
import { parseErrorMessage, verifyApiResponse, PAGE_ACTION_TYPES } from 'c/utils';

const i18n = {
    noResults: labelNoResults,
    searchPlaceholder: labelSearchPlaceholder,
    showInactive: labelShowInactive,
    reOrderButton: labelReOrder,
    loading: labelLoading,
    order: labelOrder,
    serviceName: labelServiceName,
    description: labelDescription,
    active: labelActive,
    serviceAssignmentRule: labelServiceAssignmentRule,
    deleteSuccess: labelDeletedSuccess,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    delete: labelDeleteMenuItem,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    cancel: labelCancel,
    confirm: labelConfirm,
    reorderingTitle: labelRuleExecutionOrder,
    reorderingHeader: labelRulesProcessed,
    save: labelSave,
    updateSuccess: labelSequencesUpdated,
    yes: labelYes,
    no: labelNo
}

const DASH = '-';

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' },
];

const SERVICE_ASSIGNMENT_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__serviceAssignmentRuleDetail'
    }
}

export default class ServiceAssignmentRulesListView extends NavigationMixin(LightningElement) {

    toggleChecked = false;
    serviceAssignmentData;
    options = [];
    currentNavItem;

    @track listViewData;
    @track columns;
    @track apiInProgress = false;
    @track error;
    @track serviceAssignmentDetailUrl;
    @track deleteModalDialogOpen;
    @track reorderModalDialogOpen;
    @track serviceAssignmentListViewData;

    @api objectName;

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

            this.getListViewData();
        }
    }

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](SERVICE_ASSIGNMENT_DETAIL_VIEW).then(url => {
            this.serviceAssignmentDetailUrl = url;
            this.populateListView();
        });
    }

    get i18n () {
        return i18n;
    }

    get rowCount () {
        return (this.listViewData) ? this.listViewData.length : 0;
    }

    getColumns () {
        return [
            {
                label: this.i18n.order,
                fieldName: 'order',
                hideDefaultActions: true,
                initialWidth: 100,
                wrapText: false
            },
            {
                label: this.i18n.serviceName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                initialWidth: 350,
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'name' },
                    tooltip: { fieldName: 'serviceToolTip' },
                    target: '_self' }
            },
            {
                label: this.i18n.description,
                fieldName: 'description',
                hideDefaultActions: true,
                wrapText: false
            },
            {
                label: this.i18n.active,
                fieldName: 'activeVal',
                hideDefaultActions: true,
                initialWidth: 100,
                wrapText: false
            },
            {
                type: 'action',
                typeAttributes: { rowActions: ROW_ACTIONS },
            }
        ];
    }

    handleToggleChange (event) {
        this.toggleChecked = event.target.checked;
        this.populateListView();
    }

    getListViewData () {
        this.apiInProgress = true;
        getServiceAssignmentRules({ objectName: this.objectName })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.serviceAssignmentData = this.getMappedData(result.data);

                this.populateListView();
            })
            .catch(error => {
                this.serviceAssignmentData = [];
                this.listViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    getMappedData (data) {
        return data.map(row => {
            return {
                name: row.name,
                id: row.id,
                description: row.description,
                active: row.active,
                activeVal: null,
                recordUrl: '',
                sequence: row.sequence,
                serviceToolTip: row.name + '\n' + ((row.description) ? '\n' + row.description : '')
            }
        });
    }

    populateListView () {
        if (this.serviceAssignmentData) {
            let activeCount  = 0;
            this.listViewData = [];
            this.serviceAssignmentData.forEach(row => {
                const urlParams = [
                    'c__actionName=view',
                    `c__objectName=${this.objectName}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`
                ];

                row.recordUrl = `${this.serviceAssignmentDetailUrl}?${urlParams.join('&')}`;
                if ( row.active ) {
                    row.activeVal = this.i18n.yes;
                    activeCount += 1;
                    row.order = activeCount.toString();
                    this.listViewData.push(row);
                } else if (this.toggleChecked) {
                    row.activeVal = this.i18n.no;
                    row.order = DASH;
                    this.listViewData.push(row);
                }
            });
        }
        this.serviceAssignmentListViewData = this.listViewData;
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) {
            return;
        }

        try {
            this.filterListViewData(searchKey);
        } catch (e) {
            this.error = parseErrorMessage(e);
        }
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.populateListView();
        } else {
            this.listViewData = this.serviceAssignmentListViewData.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const nameMatch = (item.name)
                    ? item.name.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                return (nameMatch !== -1);
            });
        }
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
                this.deleteRow(row);
                break;
            default:
                break;
        }
    }

    navigateToDetailComponent (recordId, actionName) {
        const navState = {
            c__actionName: actionName
        }

        if (recordId) {
            navState.c__recordId = recordId;
        }

        if (this.objectName) {
            navState.c__objectName = this.objectName;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, SERVICE_ASSIGNMENT_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    get listBoxOptions () {
        return this.options;
    }

    handleReorder () {
        this.options = [];
        if (this.listViewData) {
            this.listViewData.forEach(row => {
                if (row.active) {
                    this.options.push({ label: row.name, value: row.id })
                }
            });
        }
        this.reorderModalDialogOpen = true;

    }

    handleReorderCancelModal () {
        this.reorderModalDialogOpen = false;
    }

    getReorderedData (data) {
        return data.map(row => {return {
            name: row.name,
            id: row.id,
            sequence: row.sequence,
            active: row.active
        }});
    }

    handleReorderSaveModal () {

        const cmp = this.template.querySelector('c-reorder-list-box');
        const newOrderedValues = cmp.value;
        let order = 1;
        const reorderedList = [];
        const listviewRecs = this.getReorderedData(this.listViewData);
        newOrderedValues.forEach(row => {
            this.listViewData.forEach(serviceAssignmentRow => {
                if (serviceAssignmentRow.order === order.toString()) {
                    if (serviceAssignmentRow.id  === row) {
                        reorderedList.push(serviceAssignmentRow);
                    } else {
                        listviewRecs.forEach(entRow => {
                            if (entRow.id  === row) {
                                entRow.sequence =  serviceAssignmentRow.sequence;
                                reorderedList.push(entRow);
                            }
                        });
                    }
                }
            });
            order += 1;
        });

        const saveData =  this.getReorderedData(reorderedList);
        if (saveData) {
            this.updateRulesSequence(saveData);
        }
    }

    updateRulesSequence (saveData) {
        this.apiInProgress = true;
        updateServiceAssignmentSequence({ requestJson: JSON.stringify(saveData) })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                const evt = new ShowToastEvent({
                    title: this.i18n.updateSuccess,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.getListViewData();
                this.handleReorderCancelModal();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deleteServiceAssignmentRule({
            serviceAssignmentRuleId: this.pendingDeleteRecord.id
        })
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
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
                this.pendingDeleteRecord = undefined;
            });
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.serviceAssignmentRule} "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }
}