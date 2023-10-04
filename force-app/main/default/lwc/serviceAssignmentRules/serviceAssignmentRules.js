import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import labelEntitlementTitle from '@salesforce/label/c.Label_Entitlement';
import labelServiceAssignmentRulesTitle from '@salesforce/label/c.Label_Service_Assignment_Rules';
import labelCase from '@salesforce/label/c.Label_Case';
import labelCases from '@salesforce/label/c.Label_Cases';
import labelWorkOrder from '@salesforce/label/c.Label_WorkOrder';
import labelWorkOrders from '@salesforce/label/c.Label_WorkOrders';
import labelReturnOrders from '@salesforce/label/c.Label_ReturnOrders';
import labelReturnOrder from '@salesforce/label/c.Label_ReturnOrder';
import labelNewRule from '@salesforce/label/c.Button_NewRule';
import labelShowMenu from '@salesforce/label/c.AltText_ShowMenu';
import CASE_OBJECT from '@salesforce/schema/Case';
import WORK_ORDER_OBJECT from '@salesforce/schema/WorkOrder';
import RETURN_ORDER_OBJECT from '@salesforce/schema/ReturnOrder';
import { PAGE_ACTION_TYPES } from 'c/utils';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelEntitlementServiceRulesHelp
    from '@salesforce/label/c.URL_EntitlementServiceRulesHelp';


const i18n = {
    pageHeader: labelEntitlementTitle,
    serviceAssignRulesHeader: labelServiceAssignmentRulesTitle,
    casesSectionHeader: labelCases,
    workOrdersSectionHeader: labelWorkOrders,
    returnOrdersSectionHeader: labelReturnOrders,
    caseButton: labelCase,
    workOrderButton: labelWorkOrder,
    returnOrderButton: labelReturnOrder,
    newRule: labelNewRule,
    showMenuAltText: labelShowMenu,
    helpLink: labelEntitlementServiceRulesHelp,
    help: labelHelp
}

const SERVICE_ASSIGNMENT_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__serviceAssignmentRuleDetail'
    }
}

const NEW_MENU_ITEMS = [
    { id: '1', label: i18n.caseButton, value: CASE_OBJECT.objectApiName },
    { id: '2', label: i18n.workOrderButton, value: WORK_ORDER_OBJECT.objectApiName },
    { id: '3', label: i18n.returnOrderButton, value: RETURN_ORDER_OBJECT.objectApiName }
];

export default class ServiceAssignmentRules extends NavigationMixin(LightningElement) {
    @track newButtonItems = NEW_MENU_ITEMS;

    caseObject = CASE_OBJECT.objectApiName;
    workOrderObject = WORK_ORDER_OBJECT.objectApiName;
    returnOrderObject = RETURN_ORDER_OBJECT.objectApiName;

    currentPageReference;
    currentNavItem;

    get i18n () {
        return i18n;
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef && pageRef.state && pageRef.state.c__currentItem) {
            this.currentNavItem = pageRef.state.c__currentItem;
        }
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    handleNewRule (event) {
        const selectedMenuItemValue = event.detail.value;

        const navState = {
            c__actionName: PAGE_ACTION_TYPES.NEW
        }

        navState.c__recordId = '';

        if (selectedMenuItemValue) {
            navState.c__objectName = selectedMenuItemValue;
        }

        if (this.currentNavItem) {
            navState.c__currentItem = this.currentNavItem;
        }

        const detailRef = Object.assign({}, SERVICE_ASSIGNMENT_DETAIL_VIEW);
        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

}