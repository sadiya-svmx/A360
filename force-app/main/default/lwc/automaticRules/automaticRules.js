import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import labelEntitlementTitle from '@salesforce/label/c.Label_Entitlement';
import labelAutomaticRulesTitle from '@salesforce/label/c.Label_Automatic_Rules';
import labelCase from '@salesforce/label/c.Label_Case';
import labelCases from '@salesforce/label/c.Label_Cases';
import labelWorkOrder from '@salesforce/label/c.Label_WorkOrder';
import labelWorkOrders from '@salesforce/label/c.Label_WorkOrders';
import labelReturnOrders from '@salesforce/label/c.Label_ReturnOrders';
import labelReturnOrder from '@salesforce/label/c.Label_ReturnOrder';
import labelNewRule from '@salesforce/label/c.Button_NewRule';
import labelShowMenu from '@salesforce/label/c.AltText_ShowMenu';
import labelHelp from '@salesforce/label/c.Label_Help';
import labelAutoEntitlementRuleHelp from '@salesforce/label/c.URL_AutoEntitlementRulesHelp';

import { PAGE_ACTION_TYPES } from 'c/utils';

const i18n = {
    pageHeader: labelEntitlementTitle,
    automaticRulesHeader: labelAutomaticRulesTitle,
    casesSectionHeader: labelCases,
    workOrdersSectionHeader: labelWorkOrders,
    returnOrdersSectionHeader: labelReturnOrders,
    caseButton: labelCase,
    workOrderButton: labelWorkOrder,
    returnOrderButton: labelReturnOrder,
    newRule: labelNewRule,
    showMenuAltText: labelShowMenu,
    helpLink: labelAutoEntitlementRuleHelp,
    help: labelHelp
}

const ENTITLEMENT_DETAIL_VIEW = {
    type: 'standard__component',
    attributes: {
        componentName: 'SVMXA360__entitlementRuleDetail'
    }
}

const NEW_MENU_ITEMS = [
    { id: '1', label: i18n.caseButton, value: 'Case' },
    { id: '2', label: i18n.workOrderButton, value: 'WorkOrder' },
    { id: '3', label: i18n.returnOrderButton, value: 'ReturnOrder' }
];

export default class AutomaticRules extends NavigationMixin(LightningElement) {
    @track newButtonItems = NEW_MENU_ITEMS;

    caseObject = 'Case';
    workOrderObject = 'WorkOrder';
    returnOrderObject = 'ReturnOrder';

    currentPageReference;
    currentNavItem;

    get i18n () {
        return i18n;
    }

    handleHelpClick () {
        window.open(i18n.helpLink, '_blank');
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;

        if (pageRef && pageRef.state && pageRef.state.c__currentItem) {
            this.currentNavItem = pageRef.state.c__currentItem;
        }
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

        const detailRef = Object.assign({}, ENTITLEMENT_DETAIL_VIEW);
        detailRef.state = navState;

        this[NavigationMixin.Navigate](detailRef);
    }

}