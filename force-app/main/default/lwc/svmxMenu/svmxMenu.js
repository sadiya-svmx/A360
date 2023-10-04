import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getActiveAdminPages
    from "@salesforce/apex/ADM_AdminPageLightningService.getActiveAdminPages";
import { deepCopy, parseErrorMessage } from 'c/utils';

import labelEntitlement from "@salesforce/label/c.Label_Entitlement";
import labelAutomaticRules from "@salesforce/label/c.Label_Automatic_Rules";
import labelInteractiveEntitlement from "@salesforce/label/c.Label_Interactive_Entitlement";
import labelServiceProcessManager from "@salesforce/label/c.Label_Service_Process_Manager";
import labelExpressionBuilder from "@salesforce/label/c.Label_Expression_Builder";
import labelLWCDesigner from "@salesforce/label/c.Label_LWC_Designer";
import labelTransactionDesigner from "@salesforce/label/c.Label_Transaction_Designer";
import labelObjectMappings from "@salesforce/label/c.Title_Mappings";
import labelWarrantyManagement from "@salesforce/label/c.Label_Warranty_Management";
import labelWarranty from "@salesforce/label/c.Label_Warranty"
import labelSettings from "@salesforce/label/c.Label_Settings";
import labelWizards from "@salesforce/label/c.Label_Wizards";
import titleDepotManagement from '@salesforce/label/c.Title_Depot';
import labelPriceBookAssignmentRules from '@salesforce/label/c.Label_Pricebook_Assignment_Rules';
import labelServiceAssignmentRules from
    '@salesforce/label/c.Label_Entitlement_Service_Assignment_Rules';
import labelPSC from '@salesforce/label/c.Label_Product_Service_Campaigns';
import labelPSCConfigTemplates from '@salesforce/label/c.Label_Configuration_Templates';
import labelTranslationWorkbench from '@salesforce/label/c.Title_TranslationWorkbench';
import labelFeatureSettingAdmin from '@salesforce/label/c.Title_FeatureSettingAdmin';
import labelAssetManagement from '@salesforce/label/c.LabelAsset';
import labelTimeline from '@salesforce/label/c.LabelAssetTimeline';
import labelHierarchy from '@salesforce/label/c.LabelAssetHierarchy';
import labelSearchPlaceholder from '@salesforce/label/c.Placeholder_Search';
import labelNoResults from '@salesforce/label/c.Message_NoResults';
import labelSetupHome from '@salesforce/label/c.Label_Setup_Home';
import labelDebugTransactions from '@salesforce/label/c.Label_DebugTransactions';
import labelTechnicalAttributes from '@salesforce/label/c.Label_TechnicalAttributes';
import labelTemplateRules from '@salesforce/label/c.Label_TemplateRules';
import title_MaintenancePlanProcesses from '@salesforce/label/c.Title_MaintenancePlanProcesses';
import title_MaintenancePlanProcessing from '@salesforce/label/c.Title_MaintenancePlanProcessing';

const i18n = {
    setup_home: labelSetupHome,
    entitlement: labelEntitlement,
    automatic_rules: labelAutomaticRules,
    interactive_entitlement: labelInteractiveEntitlement,
    service_process_manager: labelServiceProcessManager,
    expression_builder: labelExpressionBuilder,
    lwc_designer: labelLWCDesigner,
    transaction_designer: labelTransactionDesigner,
    mapping_rules: labelObjectMappings,
    warranty_management: labelWarrantyManagement,
    warranty_management_rules: labelWarranty,
    service_wizards: labelWizards,
    depot_management: titleDepotManagement,
    depot_management_rules: labelSettings,
    pricebook_assignment_rules: labelPriceBookAssignmentRules,
    product_service_campaign: labelPSC,
    psc_configuration_templates: labelPSCConfigTemplates,
    psc_settings: labelSettings,
    service_assignment_rules: labelServiceAssignmentRules,
    searchPlaceholder: labelSearchPlaceholder,
    entitlement_common_settings: labelSettings,
    translation_workbench: labelTranslationWorkbench,
    feature_settings: labelFeatureSettingAdmin,
    spm_settings: labelSettings,
    debug_transactions: labelDebugTransactions,
    asset_management: labelAssetManagement,
    hierarchy: labelHierarchy,
    timeline: labelTimeline,
    technical_attributes: labelTechnicalAttributes,
    template_rules: labelTemplateRules,
    noresults: labelNoResults,
    technical_attribute_settings: labelSettings,
    mplan_processes: title_MaintenancePlanProcesses,
    maintenance_plan_processing: title_MaintenancePlanProcessing
};


export default class SvmxMenu extends NavigationMixin(LightningElement) {
    @track selectedMenuItem;
    @track menuItems = [];
    @track filteredMenuItems = [];
    accountHomePageRef;
    @track pageRefURL;
    @track isLoaded ;
    @track searchKey;
    @track noItems = false;

    constructor () {
        super();
        this.template.addEventListener ('click', function (event) {
            event.preventDefault();
        })
    }

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        this.currentPageReference = pageRef;
        if (this.currentPageReference.state.c__currentItem) {
            this.selectedMenuItem = this.currentPageReference.state.c__currentItem;
        } else if (this.currentPageReference.attributes.componentName) {
            const auraAppName = this.currentPageReference.attributes.componentName;
            if (auraAppName === 'SVMXA360__mappingDetail') {
                this.selectedMenuItem = 'mapping_rules';
            } else if (auraAppName === 'SVMXA360__expressionDetail') {
                this.selectedMenuItem = 'expression_builder';
            } else if (auraAppName === 'SVMXA360__entitlementRuleDetail') {
                this.selectedMenuItem = 'automatic_rules';
            } else if (auraAppName === 'SVMXA360__LayoutEditor') {
                this.selectedMenuItem = 'lwc_designer';
            } else if (auraAppName === 'SVMXA360__transactionEditor') {
                this.selectedMenuItem = 'transaction_designer';
            } else if (auraAppName === 'SVMXA360__timelineConfigDetail') {
                this.selectedMenuItem = 'timeline'
            }
        }
    }

    @wire(getActiveAdminPages)
    transformMenuItems (value) {
        let itemsSize = 0;
        const { data, error } = value;
        if (data) {
            this.dispatchEvent(new CustomEvent('loadcomplete', { bubbles: true, composed: true }));
            const menuItems = this.mapMenuItems (data.data);
            itemsSize = this.getItemsSize(menuItems);
            this.filteredMenuItems = this.mapChildHref (menuItems, itemsSize);
            this.noItems = this.filteredMenuItems.length === 0;
        } else if (error) {
            console.error(error);
        }
    }

    getItemsSize (menuItems) {
        let itemsSize = 0;
        if (menuItems) {
            menuItems.forEach(menuItem => {
                if ( menuItem.items && menuItem.items.length > 0 ) {
                    // eslint-disable-next-line no-param-reassign
                    itemsSize = itemsSize + menuItem.items.length;
                    this.getItemsSize (menuItem.items, itemsSize);
                }
                else if (menuItem.isPage) {
                    // eslint-disable-next-line no-param-reassign
                    itemsSize = itemsSize + 1;
                }
            });
        }
        return itemsSize;
    }

    mapChildHref (menuItems, itemsSize) {
        if (menuItems) {
            let index = 0;
            menuItems.forEach(menuItem => {
                if ( menuItem.items && menuItem.items.length > 0 ) {
                    menuItem.items.forEach(childMenuItem => {
                        index = index + 1;
                        this.populateChildHref(childMenuItem, itemsSize, index, () => {
                            this.menuItems = menuItems;
                        });
                        this.mapChildHref(childMenuItem.items, itemsSize);
                    });
                }
                else if ( menuItem.isPage) {
                    index = index + 1;
                    this.populateChildHref(menuItem, itemsSize, index, () => {
                        this.menuItems = menuItems;
                    });
                }
            });
        }
        return menuItems;
    }

    mapMenuItems (items) {
        return items?.map(menuItem => ({
            label: i18n[menuItem.developerName],
            name: menuItem.developerName,
            disable: false,
            expanded: false,
            isGroup: menuItem.pageType === "GROUP",
            isPage: menuItem.pageType === "PAGE",
            // eslint-disable-next-line max-len
            targetDeveloperName: menuItem.pageType === "PAGE" ? menuItem.targetDeveloperName : null,
            targetType: menuItem.pageType === "PAGE" ? menuItem.targetType : null,
            href: this.currentPageReference,
            items: this.mapMenuItems (menuItem.children)
        })
        );
    }

    get i18n () {
        return i18n;
    }

    get groups () {
        return this.filterGroups(this.menuItems);
    }

    filterGroups (menuItems) {
        const groupItems = [];
        if ( menuItems ) {
            menuItems.filter( menuItem => menuItem.isGroup === true)
                .forEach(menuItem => {
                    groupItems.push(menuItem.name);
                    if (menuItem.items) {
                        const childGroup = this.filterGroups (menuItem.items);
                        groupItems.push(...childGroup);
                    }
                })
        }
        return groupItems;
    }

    handleSelect (event) {
        if (!this.groups.includes(event.detail.name)) {
            this.selectedMenuItem = event.detail.name;
            // Find the childMenuItem for the selected Item and redirect accordingly
            this.handleNavigation( this.menuItems, this.selectedMenuItem );
        }
    }

    handleNavigation ( menuItems, selectedMenuItem ) {
        (menuItems || []).forEach(menuItem => {
            if (menuItem.items && menuItem.items.length > 0) {
                this.handleNavigation ( menuItem.items, selectedMenuItem );
            } else {
                if (menuItem.name === selectedMenuItem) {
                    this.navigateToPage(menuItem);
                }
            }
        });
    }

    navigateToPage (node) {
        if (node.targetType === 'URL') {
            window.location.replace(node.href)
        } else {
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": node.href
                }
            });
        }
    }
    populateChildHref (childMenuItem,childMenuItemSize,currentIndex,setMenuItemsCallBack) {
        let pageRefObj;

        if (childMenuItem.targetType === 'URL') {
            if (childMenuItem.name === 'lwc_designer') {
                pageRefObj = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'SVMXA360__LayoutEditor'
                    }
                };
            } else if (childMenuItem.name === 'transaction_designer') {
                pageRefObj = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'SVMXA360__transactionEditor'
                    }
                };
            }


        }
        else {
            pageRefObj = {
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'SVMXA360__setupHome'
                },
                state: {
                    c__currentItem: childMenuItem.name,
                    c__target: childMenuItem.targetDeveloperName
                }
            };
        }
        this[NavigationMixin.GenerateUrl](pageRefObj).then(url => {
            childMenuItem.href = url;
            if (currentIndex ===  childMenuItemSize) {
                this.isLoaded = true;
                setMenuItemsCallBack();
            }
        });
    }

    handleSearchKeyChange (event) {
        const searchKey = event.target.value;
        try {
            this.filterMenuData(searchKey);
        } catch (e) {
            this.error = parseErrorMessage(e);
        }
    }

    filterMenuData (searchValue) {
        this.filteredMenuItems = this.menuItems;
        const loweredSearchValue = searchValue.toLowerCase();
        if (loweredSearchValue.length !== 0) {
            const clonedMenuItems = deepCopy(this.menuItems);
            this.filteredMenuItems = this.applySearch (loweredSearchValue, clonedMenuItems );
        }

        this.noItems = this.filteredMenuItems.length === 0;
    }

    applySearch ( searchValue, menuItems ) {
        return menuItems.filter(menuItem => {
            const itemLabel = menuItem.label ? menuItem.label.toLowerCase() : '';
            menuItem.expanded = true;
            if ( itemLabel.indexOf(searchValue) !== -1 ) {
                return true;
            } else if (menuItem.items) {
                menuItem.items = this.applySearch (searchValue, menuItem.items);
                if ( menuItem.items.length > 0 ) {
                    return true;
                }
            }
            return false;
        });
    }
}