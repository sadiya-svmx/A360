import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEntitlementRules
    from '@salesforce/apex/ADM_EntitlementLightningService.getEntitlementRules';
import deleteEntitlement
    from '@salesforce/apex/ADM_EntitlementLightningService.deleteEntitlementRule';
import { deleteRecentItemRecords } from 'c/recentItemService';
import updateEntitlementSequence
    from '@salesforce/apex/ADM_EntitlementLightningService.updateRulesSequence';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelEntitlementRuleMessage from '@salesforce/label/c.Message_EntitlementRule';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelShowInactive from '@salesforce/label/c.Label_Show_Inactive';
import labelReOrder from '@salesforce/label/c.Label_ReOrder';
import labelLoading from '@salesforce/label/c.AltText_Loading';
import labelOrder from '@salesforce/label/c.Label_Order';
import labelRuleName from '@salesforce/label/c.Label_RuleName';
import labelDescription from '@salesforce/label/c.Label_Description';
import labelActive from '@salesforce/label/c.Label_Active';
import labelEntitlementRule from '@salesforce/label/c.Label_EntitlementRule';
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
    entitlementRuleMessage: labelEntitlementRuleMessage,
    searchPlaceholder: labelSearchPlaceholder,
    showInactive: labelShowInactive,
    reOrderButton: labelReOrder,
    loading: labelLoading,
    order: labelOrder,
    ruleName: labelRuleName,
    description: labelDescription,
    active: labelActive,
    entitlementRule: labelEntitlementRule,
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

const ENTITLEMENT_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__entitlementRuleDetail'
    }
}

export default class AutomaticRulesListView extends NavigationMixin(LightningElement) {

    toggleChecked = false;
    entitlementData;
    options = [];
    currentNavItem;

    @track listViewData;
    @track columns;
    @track apiInProgress = false;
    @track error;
    @track entitlementDetailUrl;
    @track deleteModalDialogOpen;
    @track reorderModalDialogOpen;
    @track entitlementListViewData;

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
        this[NavigationMixin.GenerateUrl](ENTITLEMENT_DETAIL_VIEW).then(url => {
            this.entitlementDetailUrl = url;
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
                label: this.i18n.ruleName,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                initialWidth: 350,
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'ruleName' },
                    tooltip: { fieldName: 'entitlementToolTip' },
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
        getEntitlementRules({ objectName: this.objectName })
            .then(result => {
                if (!verifyApiResponse(result)) {
                    this.error = result.message;
                    return;
                }
                this.entitlementData = this.getMappedData(result.data);
                this.populateListView();
            })
            .catch(error => {
                this.entitlementData = [];
                this.listViewData = [];
                this.error = parseErrorMessage(error);
            })
            .finally( () => {
                this.apiInProgress = false;
            });
    }

    getMappedData (data) {
        return data.map(row => {return {
            ruleName: row.name,
            id: row.id,
            description: row.description,
            isActive: row.isActive,
            activeVal: null,
            recordUrl: '',
            sequence: row.sequence,
            entitlementToolTip: row.name + '\n' + ((row.description) ? '\n' + row.description : '')
        }});
    }

    populateListView () {
        if (this.entitlementData) {
            let activeCount  = 0;
            this.listViewData = [];
            this.entitlementData.forEach(row => {
                const urlParams = [
                    'c__actionName=view',
                    `c__objectName=${this.objectName}`,
                    `c__recordId=${row.id}`,
                    `c__currentItem=${this.currentNavItem}`
                ];

                row.recordUrl = `${this.entitlementDetailUrl}?${urlParams.join('&')}`;
                if ( row.isActive ) {
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
        this.entitlementListViewData = this.listViewData;
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

    filterListViewData (searchValue) {
        if (searchValue.length === 0) {
            // Restore list when search filter is removed.
            this.populateListView();
        } else {
            this.listViewData = this.entitlementListViewData.filter(item => {
                const loweredSearchValue = searchValue.toLowerCase();
                const nameMatch = (item.ruleName)
                    ? item.ruleName.toLowerCase().indexOf(loweredSearchValue)
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

        const detailRef = Object.assign({}, ENTITLEMENT_DETAIL_VIEW);

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

    handleReorder () {
        this.options = [];
        if (this.listViewData) {
            this.listViewData.forEach(row => {
                if (row.isActive) {
                    this.options.push({ label: row.ruleName, value: row.id })
                }
            });
        }
        this.reorderModalDialogOpen = true;

    }

    handleReorderCancelModal () {
        this.reorderModalDialogOpen = false;
    }

    get listBoxOptions () {
        return this.options;
    }

    handleDeleteConfirmModal () {
        this.handleCancelModal();

        if (!this.pendingDeleteRecord) return;
        this.apiInProgress = true;

        const recentlyViewedRecord = [{
            configurationId: this.pendingDeleteRecord.id
        }];

        deleteEntitlement({ requestJson: JSON.stringify({ id: this.pendingDeleteRecord.id }) })
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

    getReorderedData (data) {
        return data.map(row => {return {
            name: row.ruleName,
            id: row.id,
            sequence: row.sequence,
            isActive: row.isActive
        }});
    }

    handleReorderSaveModal () {

        const cmp = this.template.querySelector('c-reorder-list-box');
        const newOrderedValues = cmp.value;
        let order = 1;
        const reorderedList = [];
        const listviewRecs = this.getReorderedData(this.listViewData);
        newOrderedValues.forEach(row => {
            this.listViewData.forEach(entitlementRow => {
                if (entitlementRow.order === order.toString()) {
                    if (entitlementRow.id  === row) {
                        reorderedList.push(entitlementRow);
                    } else {
                        listviewRecs.forEach(entRow => {
                            if (entRow.id  === row) {
                                entRow.sequence =  entitlementRow.sequence;
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
        updateEntitlementSequence({ requestJson: JSON.stringify(saveData) })
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

    showDeletionSuccessNotification (recordName) {
        const evt = new ShowToastEvent({
            title: `${this.i18n.entitlementRule} "${recordName}" ${this.i18n.deleteSuccess}`,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

}