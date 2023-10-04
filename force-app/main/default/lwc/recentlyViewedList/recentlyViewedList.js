import { LightningElement, track, api } from 'lwc';
import TIMEZONE from '@salesforce/i18n/timeZone';
import {
    PAGE_ACTION_TYPES,
    sortObjectArray,
    verifyApiResponse,
    ROUTES,
    NAVIGATION_ITEMS,
    parseErrorMessage,
    ADMIN_MODULES
} from 'c/utils';

import getRecentItemsDetails
    from '@salesforce/apex/ADM_RecentItemsLightningService.getRecentItemsDetails';
import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';

import labelRecentlyViewedList from '@salesforce/label/c.Label_RecentlyViewedList';
import labelRecentItem from '@salesforce/label/c.Label_RecentItem';
import labelRecentType from '@salesforce/label/c.Label_RecentType';
import labelRecentDate from '@salesforce/label/c.Label_RecentDate';

const i18n = {
    recentlyViewedList: labelRecentlyViewedList,
    recentItem: labelRecentItem,
    recentType: labelRecentType,
    recentDate: labelRecentDate,

};

export default class RecentlyViewedList extends LightningElement {
    @track detailUrl;
    @track apiInProgress;
    @track error;
    @track sortBy = 'configurationDate';
    @track sortDirection = 'desc';

    currentNavItem;
    _listViewHeaderHeight = 100;
    @track objectDetails = new Map();

    constructor () {
        super();
        this.columns = this.getColumns();
    }

    connectedCallback () {
        this.apiInProgress = true;
        Promise.all([this.getRecentItems(), this.getEntityDefinitions()])
            .then(() => {
                this.getColumnsData();
            })
            .catch(error => {
                this.error = parseErrorMessage(error);
            })
            .finally(() => {
                this.apiInProgress = false;
            });
    }

    renderedCallback () {
        const listViewHeader = this.template.querySelector('.list-view-header');

        if (listViewHeader) {
            this._listViewHeaderHeight = listViewHeader.offsetHeight;
        }
    }

    get i18n () {
        return i18n;
    }

    get computedDataTableHeight () {
        return `height: calc(100% - ${this._listViewHeaderHeight}px)`;
    }

    @api
    get srcIconName () {
        return 'standard:recent';
    }
    @api iconSize = 'medium';

    getColumns () {
        return [
            {
                label: this.i18n.recentItem,
                fieldName: 'recordUrl',
                hideDefaultActions: true,
                sortable: true,
                type: 'xUrl',
                typeAttributes: {
                    disabled: { fieldName: 'navigationDisabled' },
                    fieldType: { fieldName: 'configurationType' },
                    label: { fieldName: 'configurationName' },
                    tooltip: { fieldName: 'nameToolTip' },
                    target: '_self'
                }
            },
            {
                label: this.i18n.recentType,
                fieldName: 'configurationType',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true
            },
            {
                label: this.i18n.recentDate,
                fieldName: 'configurationDate',
                hideDefaultActions: true,
                wrapText: false,
                sortable: true,
                type: 'date',
                typeAttributes: {
                    timeZone: TIMEZONE,
                    month: '2-digit',
                    day: '2-digit',
                    year: 'numeric'
                }
            },
        ];
    }

    getEntityDefinitions () {
        return getAllEntityDefinitions()
            .then (result => {
                if (!verifyApiResponse(result)) {
                    throw new Error(result.message);
                }
                this.error = null;
                result.data.forEach(entity => {
                    this.objectDetails[entity.apiName] = entity.label;
                });
            });

    }


    getRecentItems () {
        return getRecentItemsDetails()
            .then(result => {
                const deSerializedResult = JSON.parse(result);
                if (!verifyApiResponse(deSerializedResult)) {
                    throw new Error(deSerializedResult.message);
                }
                this.error = null;
                this.filteredListViewData = deSerializedResult.data;
            });
    }

    handleColumnSort (event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.filteredListViewData);
    }

    sortData (incomingData) {
        const sortByOverride = (this.sortBy === "recordUrl") ? "configurationName" : this.sortBy;

        this.filteredListViewData = sortObjectArray(
            incomingData,
            sortByOverride,
            this.sortDirection
        );
    }

    getColumnsData () {
        if (this.filteredListViewData) {
            this.filteredListViewData.forEach( row => {
                let currentNavItem = '';
                let urlParams = [];
                let detailUrl = '';

                if (row.configurationType === ADMIN_MODULES.EXPRESSION) {
                    currentNavItem = NAVIGATION_ITEMS.EXPRESSION_EDITOR;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.EXPRESSION_EDITOR;
                } else if (row.configurationType === ADMIN_MODULES.MAPPING) {
                    currentNavItem = NAVIGATION_ITEMS.MAPPING_EDITOR;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.MAPPING_EDITOR;
                } else if (row.configurationType === ADMIN_MODULES.TEMPLATE_RULES) {
                    currentNavItem = NAVIGATION_ITEMS.TEMPLATE_RULES;
                    const actionName = 'Edit';
                    urlParams = [
                        `c__actionName=${actionName}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.TEMPLATE_RULES;
                } else if (row.configurationType === ADMIN_MODULES.TECHNICAL_ATTRIBUTE_SETTINGS) {
                    currentNavItem = NAVIGATION_ITEMS.TECHNICAL_ATTRIBUTE_SETTINGS;
                    const target = 'c-technical-attribute-settings';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.ASSET_HIERARCHY) {
                    currentNavItem = NAVIGATION_ITEMS.ASSET_HIERARCHY_DETAIL_VIEW;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.ASSET_HIERARCHY_DETAIL_VIEW;
                } else if (row.configurationType === ADMIN_MODULES.ASSET_TIMELINE) {
                    currentNavItem = NAVIGATION_ITEMS.ASSET_TIMELINE_DETAIL_VIEW;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.ASSET_TIMELINE_DETAIL_VIEW;
                } else if (row.configurationType === ADMIN_MODULES.WARRANTY_MANAGEMENT_SETTINGS) {
                    currentNavItem = NAVIGATION_ITEMS.WARRANTY_RULE_VIEW;
                    const target = 'c-warranty-rules';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.ENTITLEMENT_SETTINGS) {
                    currentNavItem = NAVIGATION_ITEMS.ENTITLEMENT_SETTINGS;
                    const target = 'c-entitlement-common-settings';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.PSC_CONFIGURATION_TEMPLATES) {
                    currentNavItem = NAVIGATION_ITEMS.PSC_CONFIGURATION_TEMPLATES;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.PSC_CONFIGURATION_TEMPLATES;
                } else if (row.configurationType ===
                    ADMIN_MODULES.PRODUCT_SERVICE_CAMPAIGNS_SETTINGS) {
                    currentNavItem = NAVIGATION_ITEMS.PSC_CONFIGURATION_SETTINGS;
                    const target = 'c-psc-setting-admin-detail';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.DEPOT_SETTINGS) {
                    currentNavItem = NAVIGATION_ITEMS.DEPOT_SETTINGS;
                    const target = 'c-depot-finder-rule';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.TRANSLATIONS) {
                    currentNavItem = NAVIGATION_ITEMS.TRANSLATIONS;
                    const target = 'c-translation-workbench';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.USAGE_STATISTICS) {
                    currentNavItem = NAVIGATION_ITEMS.USAGE_STATISTICS;
                    const target = 'c-feature-setting-admin';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.DEBUG_TRANSACTIONS) {
                    currentNavItem = NAVIGATION_ITEMS.DEBUG_TRANSACTIONS;
                    const target = 'c-spm-common-settings';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType === ADMIN_MODULES.WIZARD) {
                    currentNavItem = NAVIGATION_ITEMS.WIZARD_DETAIL_VIEW;
                    const objectLabel = this.objectDetails[row.objectApiName];
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__objectLabel=${objectLabel}`,
                        `c__objectName=${row.objectApiName}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.WIZARD_DETAIL_VIEW;
                } else if (row.configurationType === ADMIN_MODULES.AUTOMATIC_RULES) {
                    currentNavItem = NAVIGATION_ITEMS.AUTOMATIC_RULE_VIEW;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__objectName=${row.objectApiName}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.AUTOMATIC_RULE_VIEW;
                }  else if (row.configurationType === ADMIN_MODULES.MAINTENANCE_PLAN_PROCESS) {
                    currentNavItem = NAVIGATION_ITEMS.MAINTENANCE_PLAN_PROCESS;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.EDIT}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.MAINTENANCE_PLAN_PROCESS;
                } else if (row.configurationType === ADMIN_MODULES.INTERACTIVE_ENTITLEMENT) {
                    currentNavItem = NAVIGATION_ITEMS.INTERACTIVE_ENTITLEMENT;
                    const target = 'c-entitlement-settings';
                    urlParams = [
                        `c__target=${target}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SETUP_HOME;
                } else if (row.configurationType ===
                    ADMIN_MODULES.ENTITLEMENT_SERVICE_ASSIGNMENT_RULES) {
                    currentNavItem = NAVIGATION_ITEMS.SERVICE_ASSIGNMENT_RULES;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__objectName=${row.objectApiName}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.SERVICE_ASSIGNMENT_RULES;
                } else if (row.configurationType === ADMIN_MODULES.PRICEBOOK_ASSIGNMENT_RULES) {
                    currentNavItem = NAVIGATION_ITEMS.PRICEBOOK_ASSIGNMENT_RULES;
                    urlParams = [
                        `c__actionName=${PAGE_ACTION_TYPES.VIEW}`,
                        `c__objectName=${row.objectApiName}`,
                        `c__recordId=${row.configurationId}`,
                        `c__currentItem=${currentNavItem}`].join('&');
                    detailUrl = ROUTES.PRICEBOOK_ASSIGNMENT_RULES;
                } else if (row.configurationType === ADMIN_MODULES.TRANSACTION) {
                    detailUrl = `${ROUTES.TRANSACTION_EDITOR}#/editor/${row.configurationId}`;
                } else if (row.configurationType === ADMIN_MODULES.SCREEN) {
                    detailUrl = `${ROUTES.LAYOUT_EDITOR}#/editor/${row.configurationId}`;
                }
                if (row.configurationType !== ADMIN_MODULES.TRANSACTION ||
                    row.configurationType !== ADMIN_MODULES.SCREEN) {
                    row.recordUrl = `${detailUrl}?${urlParams}`;
                } else {
                    row.recordUrl = detailUrl;
                }
                this.sortData(this.filteredListViewData);
            });
        }
    }
}