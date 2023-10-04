import { LightningElement, wire, track } from 'lwc';

import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelPriceBookAssignmentRules from '@salesforce/label/c.Label_Pricebook_Assignment_Rules';
import labelEntitlementTitle from '@salesforce/label/c.Label_Entitlement';
import labelNewRule from '@salesforce/label/c.Button_NewRule';
import labelDeleteModalTitle from '@salesforce/label/c.Label_Delete_Modal_Title';
import labelDeleteModalContent from '@salesforce/label/c.Label_Delete_Modal';
import labelDeleteMenuItem from '@salesforce/label/c.Menu_Delete';
import labelDeletedSuccess from '@salesforce/label/c.Label_DeletedSuccessfully';
import labelCancel from '@salesforce/label/c.Button_Cancel';
import labelConfirm from '@salesforce/label/c.Button_Confirm';
import labelCloneMenuItem from '@salesforce/label/c.Menu_Clone';
import labelEditMenuItem from '@salesforce/label/c.Menu_Edit';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelPricebookName from '@salesforce/label/c.Label_Pricebook_Name';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelActive from '@salesforce/label/c.Label_Active';
import labelYes from '@salesforce/label/c.Lbl_Yes';
import labelNo from '@salesforce/label/c.Lbl_No';
import labelOrder from '@salesforce/label/c.Label_Order';
import labelShowInactive from '@salesforce/label/c.Label_Show_Inactive';
import labelReOrder from '@salesforce/label/c.Label_ReOrder';
import labelRuleExecutionOrder from '@salesforce/label/c.Label_RuleExecutionOrder';
import labelSave from '@salesforce/label/c.Btn_Save';
import labelSequencesUpdated from '@salesforce/label/c.Message_SequencesUpdated';
import labelPricebookAssignment from '@salesforce/label/c.Label_Pricebook_Assignment';
import labelLoading from '@salesforce/label/c.AltText_Loading';

import {
    verifyApiResponse,
    PAGE_ACTION_TYPES,
    parseErrorMessage,
} from 'c/utils';

import { deleteRecentItemRecords } from 'c/recentItemService';
import getAllPricebookAssignmentRules
    from '@salesforce/apex/ADM_EntitlementLightningService.getAllPricebookAssignmentRules';
import deletePricebookAssignmentRule
    from '@salesforce/apex/ADM_EntitlementLightningService.deletePricebookAssignmentRule';
import updatePricebookAssignmentRulesSequence
    from '@salesforce/apex/ADM_EntitlementLightningService.updatePricebookAssignmentRulesSequence';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelPricebookAssignmentRulesHelp
    from '@salesforce/label/c.URL_PricebookAssignmentRulesHelp';

const i18n = {
    pageHeader: labelEntitlementTitle,
    labelPriceBookAssignmentRules: labelPriceBookAssignmentRules,
    labelEntitlement: labelEntitlementTitle,
    labelNewRule: labelNewRule,
    reOrderButton: labelReOrder,
    showInactive: labelShowInactive,
    deleteSuccess: labelDeletedSuccess,
    deleteModalTitle: labelDeleteModalTitle,
    deleteModalContent: labelDeleteModalContent,
    delete: labelDeleteMenuItem,
    cancel: labelCancel,
    confirm: labelConfirm,
    clone: labelCloneMenuItem,
    edit: labelEditMenuItem,
    searchPlaceholder: labelSearchPlaceholder,
    pricebookName: labelPricebookName,
    description: labelDescription,
    active: labelActive,
    noResults: labelNoResults,
    yes: labelYes,
    no: labelNo,
    order: labelOrder,
    reorderingTitle: labelRuleExecutionOrder,
    save: labelSave,
    updateSuccess: labelSequencesUpdated,
    pricebookAssignment: labelPricebookAssignment,
    loading: labelLoading,
    helpLink: labelPricebookAssignmentRulesHelp,
    help: labelHelp
}

const ROW_ACTIONS = [
    { label: i18n.edit, name: 'edit' },
    { label: i18n.clone, name: 'clone' },
    { label: i18n.delete, name: 'delete' },
];

const PRICEBOOK_ASSIGNMENT_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__pricebookAssignmentRuleDetail'
    }
}

const DASH = '-';

export default class PricebookAssignmentListView extends NavigationMixin(LightningElement) {

    ruleList = [];
    pricebookAssignmentDetailURL;
    deleteModalDialogOpen = false;
    pendingDeleteRecord;
    @track pricebookAssignmentRules = [];
    @track listViewData = [];
    @track pricebookAssignmentListViewData = [];
    @track apiInProgress = false;
    toggleChecked = false;
    options = [];
    reorderModalDialogOpen = false;
    error = '';

    connectedCallback () {
        this[NavigationMixin.GenerateUrl](PRICEBOOK_ASSIGNMENT_DETAIL_VIEW).then(url => {
            this.pricebookAssignmentDetailURL = url;
        });
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef) {
            if (pageRef.state && pageRef.state.c__currentItem) {
                this.currentNavItem = pageRef.state.c__currentItem;
            }

            this.getAllRules();
        }
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    getAllRules () {
        this.apiInProgress = true;
        getAllPricebookAssignmentRules()
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.pricebookAssignmentRules = result.data;
                this.populateListView();
            })
            .catch(error => {
                this.pricebookAssignmentRules = [];
                this.listViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    navigateToDetailComponent (rowData, actionName) {
        const navState = {
            c__actionName: actionName
        }

        if (rowData) {
            if (rowData.id) {
                navState.c__recordId = rowData.id;
            }

            if (rowData.objectAPIName) {
                navState.c__objectName = rowData.objectAPIName;
            }
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, PRICEBOOK_ASSIGNMENT_DETAIL_VIEW);

        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    handleRowAction (event) {
        const actionName = event.detail.action.name;
        const rowData = event.detail.row;

        switch (actionName) {
            case 'edit':
                this.navigateToDetailComponent(rowData, PAGE_ACTION_TYPES.EDIT);
                break;
            case 'clone':
                this.navigateToDetailComponent(rowData, PAGE_ACTION_TYPES.CLONE);
                break;
            case 'delete':
                this.deleteRow(rowData);
                break;
            default:
                break;
        }
    }

    deleteRow (row) {
        this.deleteModalDialogOpen = true;
        this.pendingDeleteRecord = row;
    }

    handleCancelModal () {
        this.deleteModalDialogOpen = false;
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) {
            return;
        }

        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deletePricebookAssignmentRule({ pricebookAssignmentRuleId: this.pendingDeleteRecord.id })
            .then(result => {

                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }

                this.showDeletionSuccessNotification(this.pendingDeleteRecord.ruleName);

                deleteRecentItemRecords(recentlyViewedRecord).then(recentItem => {
                    if (recentItem && !verifyApiResponse(recentItem)) {
                        this.error = recentItem.message;
                    }
                });

                this.getAllRules();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
                this.pendingDeleteRecord = undefined;
            });
    }

    handleToggleChange (event) {
        this.toggleChecked = event.target.checked;
        this.populateListView();
    }

    handleNewRule () {
        const navState = {
            c__actionName: PAGE_ACTION_TYPES.NEW
        }

        navState.c__recordId = '';

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, PRICEBOOK_ASSIGNMENT_DETAIL_VIEW);
        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;

        if (searchKey && (searchKey.length >= 1 && searchKey.length < 3)) { return; }

        try {
            this.filterListViewData(searchKey);
        } catch (e) {
            this.error = parseErrorMessage(e);
        }
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
        updatePricebookAssignmentRulesSequence({ requestJson: JSON.stringify(saveData) })
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
                this.getAllRules();
                this.handleReorderCancelModal();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.populateListView();
        } else {
            this.listViewData = this.pricebookAssignmentListViewData.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const nameMatch = (item.ruleName)
                    ? item.ruleName.toLowerCase().indexOf(loweredSearchValue)
                    : -1;
                return (nameMatch !== -1);
            });
        }
    }

    populateListView () {
        this.listViewData = [];
        if (this.pricebookAssignmentRules && this.pricebookAssignmentRules.length > 0) {
            let activeCount  = 0;
            this.pricebookAssignmentRules.forEach(row => {
                const urlParams = [
                    'c__actionName=view',
                    `c__objectName=${this.objectAPIName}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`
                ];

                row.recordUrl = `${this.pricebookAssignmentDetailURL}?${urlParams.join('&')}`;
                row.ruleName = row.name;
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
        this.pricebookAssignmentListViewData = this.listViewData;
    }

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.pricebookAssignment}
                    "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    get i18n () {
        return i18n;
    }

    get rowCount () {
        return (this.listViewData) ? this.listViewData.length : 0;
    }

    get columns () {
        return [
            {
                label: this.i18n.order,
                fieldName: 'order',
                hideDefaultActions: true,
                initialWidth: 100,
                wrapText: false
            },
            {
                label: this.i18n.pricebookName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                initialWidth: 350,
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'ruleName' },
                    tooltip: { fieldName: 'ruleName' },
                    target: '_self'
                }
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

    get listBoxOptions () {
        return this.options;
    }
}