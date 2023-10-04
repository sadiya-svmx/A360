/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve Admin Pages (LWC / Aura accessible).
 *
 * @author Daniel Peter (Robots & Pencils)
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Daniel Peter        29 June 2020        Created.
 *              Soumyaranjan Pati      29 Dec 2020      Updated for A360AM-86.
 * A360AM-770   Ramachandra Mohan   05 June 2021        Updates developer name from 'Timeline' to 'timeline'.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_AdminPageManager {

    /**
     * Static variable to hold instance of this class.
     */
    private static ADM_AdminPageManager instance = null;


    /**
     * Static method to return instnace of this class.
     */
    public static ADM_AdminPageManager getInstance() {

        if( instance == null ) {
            instance = new ADM_AdminPageManager();
        }

        return instance;
    }

    /**
     * This method is used to retrieve all active admin pages.
     */
    public List<Adm.AdminPage> getActiveAdminPages() {

        System.debug( LoggingLevel.DEBUG, 'getActiveAdminPages() - enter' );

        List<Adm.AdminPage> activeAdminPageList = new List<Adm.AdminPage>();

        try {

            // Retrieve active admin pages
            final List<SVMXA360__CONF_AdminPage__c> adminPageRecordList = getActiveAdminPageRecords();

            if( adminPageRecordList.size() > 0 ) {

                // Create admin page wrapper for each admin page
                for( SVMXA360__CONF_AdminPage__c adminPageRecord : adminPageRecordList ) {
                    activeAdminPageList.add(createAdminPage( adminPageRecord ) );
                }
            } else {
                activeAdminPageList = getDefaultAdminPages();
            }

            System.debug( LoggingLevel.DEBUG, 'getActiveAdminPages() : Retrieved active admin pages' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getActiveAdminPages() : Failed to retrieve admin pages. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getActiveAdminPages() - exit; activeAdminPageList.size()= ' + activeAdminPageList.size() );
        }

        return activeAdminPageList;
    }


    /**
     * This method is used to retrieve all active admin page records.
     */
    public List<SVMXA360__CONF_AdminPage__c> getActiveAdminPageRecords() {

        final List<SVMXA360__CONF_AdminPage__c> adminPageRecordList;

        try {
            adminPageRecordList = SvmxDatabase.query([
                SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c, SVMXA360__TargetType__c,
                SVMXA360__TargetDeveloperName__c, SVMXA360__Parameters__c, SVMXA360__Sequence__c, SVMXA360__IsActive__c,
                    (SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c, SVMXA360__TargetType__c,
                     SVMXA360__TargetDeveloperName__c, SVMXA360__Parameters__c, SVMXA360__Parent__c, SVMXA360__Sequence__c, SVMXA360__IsActive__c
                     FROM SVMXA360__AdminPages__r
                     WHERE SVMXA360__IsActive__c = true
                     ORDER BY SVMXA360__Sequence__c ASC NULLS LAST)
                FROM SVMXA360__CONF_AdminPage__c
                WHERE SVMXA360__IsActive__c = true
                AND SVMXA360__Parent__c = null
                ORDER BY SVMXA360__Sequence__c ASC NULLS LAST
            ]);
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getActiveAdminPageRecords() : Failed to retrieve Admin Pages. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getActiveAdminPageRecords() - exit; adminPageRecordList.size()= ' + adminPageRecordList.size() );
        }

        return adminPageRecordList;
    }

    /**
     * Private method to create admin page wrapper from admin page record.
     */
    @testVisible
    private Adm.AdminPage createAdminPage( final SVMXA360__CONF_AdminPage__c adminPageRecord ) {
        
        List<Adm.AdminPage> children = new List<Adm.AdminPage>();
        Map<Id, List<Adm.AdminPage>> secondNodeChildrenMap = new Map<Id, List<Adm.AdminPage>>();

        Set<Id> secondNodes = new Set<Id>();

        for (SVMXA360__CONF_AdminPage__c childRecord: adminPageRecord.SVMXA360__AdminPages__r) {
            secondNodes.add(childRecord.id);
        }
        
        for (SVMXA360__CONF_AdminPage__c childRecord : (List<SVMXA360__CONF_AdminPage__c>) SvmxDatabase.query([SELECT Id, Name, SVMXA360__Type__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c, 
                    SVMXA360__TargetType__c, SVMXA360__TargetDeveloperName__c, SVMXA360__Parameters__c, SVMXA360__Sequence__c, SVMXA360__IsActive__c, SVMXA360__Parent__c
                    FROM SVMXA360__CONF_AdminPage__c
                    WHERE SVMXA360__Parent__c IN: secondNodes AND SVMXA360__IsActive__c = true
                    ORDER BY SVMXA360__Sequence__c ASC NULLS LAST])) {
            Adm.AdminPage childPage = new Adm.AdminPage();
            childPage.id = childRecord.Id;
            childPage.pageType = childRecord.SVMXA360__Type__c;
            childPage.name = childRecord.Name;
            childPage.developerName = childRecord.SVMXA360__DeveloperName__c;
            childPage.description = childRecord.SVMXA360__Description__c;
            childPage.targetType = childRecord.SVMXA360__TargetType__c;
            childPage.targetDeveloperName = childRecord.SVMXA360__TargetDeveloperName__c;
            childPage.parameters = childRecord.SVMXA360__Parameters__c;
            childPage.sequence = (childRecord.SVMXA360__Sequence__c != null ? childRecord.SVMXA360__Sequence__c.intValue() : null);
            childPage.isActive = childRecord.SVMXA360__IsActive__c;
            List<Adm.AdminPage> tempChildrenList = new List<Adm.AdminPage>();

            if (secondNodeChildrenMap.containsKey(childRecord.SVMXA360__Parent__c)) {
                tempChildrenList = secondNodeChildrenMap.get(childRecord.SVMXA360__Parent__c);
            }
            tempChildrenList.add(childPage);
            secondNodeChildrenMap.put(childRecord.SVMXA360__Parent__c, tempChildrenList);
        }

        for (SVMXA360__CONF_AdminPage__c childRecord: adminPageRecord.SVMXA360__AdminPages__r) {
            Adm.AdminPage childPage = new Adm.AdminPage();
            childPage.id = childRecord.Id;
            childPage.pageType = childRecord.SVMXA360__Type__c;
            childPage.name = childRecord.Name;
            childPage.developerName = childRecord.SVMXA360__DeveloperName__c;
            childPage.description = childRecord.SVMXA360__Description__c;
            childPage.targetType = childRecord.SVMXA360__TargetType__c;
            childPage.targetDeveloperName = childRecord.SVMXA360__TargetDeveloperName__c;
            childPage.parameters = childRecord.SVMXA360__Parameters__c;
            childPage.sequence = (childRecord.SVMXA360__Sequence__c != null ? childRecord.SVMXA360__Sequence__c.intValue() : null);
            childPage.isActive = childRecord.SVMXA360__IsActive__c;
            if(secondNodeChildrenMap.containsKey(childPage.id)){
                childPage.children = secondNodeChildrenMap.get(childPage.id);
            }
            children.add(childPage);
        }
        
        Adm.AdminPage adminPage = new Adm.AdminPage();
        adminPage.id = adminPageRecord.Id;
        adminPage.pageType = adminPageRecord.SVMXA360__Type__c;
        adminPage.name = adminPageRecord.Name;
        adminPage.developerName = adminPageRecord.SVMXA360__DeveloperName__c;
        adminPage.description = adminPageRecord.SVMXA360__Description__c;
        adminPage.targetType = adminPageRecord.SVMXA360__TargetType__c;
        adminPage.targetDeveloperName = adminPageRecord.SVMXA360__TargetDeveloperName__c;
        adminPage.parameters = adminPageRecord.SVMXA360__Parameters__c;
        adminPage.sequence = (adminPageRecord.SVMXA360__Sequence__c != null ? adminPageRecord.SVMXA360__Sequence__c.intValue() : null);
        adminPage.isActive = adminPageRecord.SVMXA360__IsActive__c;
        adminPage.children = children;

        return adminPage;
    }

    /**
     * Private method to create default admin pages if none exist. Fires a queueable to create the pages (since the method is cacheable and cannot have DML, and immediately returns a set of the legitmate items)
     */
    @testVisible
    private List<Adm.AdminPage> getDefaultAdminPages() {

        //Asset Management  A360AM-347
        Adm.AdminPage hierarchy = new Adm.AdminPage();
        hierarchy.name = 'Hierarchy';
        hierarchy.pageType = 'PAGE';
        hierarchy.developerName = 'hierarchy';
        hierarchy.description = 'Asset Hierarchy';
        hierarchy.targetType = 'LWC';
        hierarchy.targetDeveloperName = 'c-hierarchy-config-list-view';
        hierarchy.sequence = 1;
        hierarchy.isActive = true;

        Adm.AdminPage timeline = new Adm.AdminPage();
        timeline.name = 'Timeline';
        timeline.pageType = 'PAGE';
        timeline.developerName = 'timeline';
        timeline.description = 'Asset Timeline';
        timeline.targetType = 'LWC';
        timeline.targetDeveloperName = 'c-asset-timeline-admin-list';
        timeline.sequence = 2;
        timeline.isActive = true;

        Adm.AdminPage warrantyRules = new Adm.AdminPage();
        warrantyRules.name = 'Rules';
        warrantyRules.pageType = 'PAGE';
        warrantyRules.developerName = 'warranty_management_rules';
        warrantyRules.description = 'Warranty Mangement Rules';
        warrantyRules.targetType = 'LWC';
        warrantyRules.targetDeveloperName = 'c-warranty-rules';
        warrantyRules.sequence = 3;
        warrantyRules.isActive = true;

        Adm.AdminPage setupHome = new Adm.AdminPage();
        setupHome.name = 'Setup Home';
        setupHome.pageType = 'PAGE';
        setupHome.developerName = 'setup_home';
        setupHome.description = 'Setup Home';
        setupHome.targetType = 'LWC';
        setupHome.targetDeveloperName = 'c-admin-welcome';
        setupHome.sequence = 0;
        setupHome.isActive = true;

        Adm.AdminPage assetManagement = new Adm.AdminPage();
        assetManagement.name = 'Asset Management';
        assetManagement.pageType = 'GROUP';
        assetManagement.developerName = 'asset_management';
        assetManagement.description = 'Asset Management';
        assetManagement.targetType = null;
        assetManagement.targetDeveloperName = null;
        assetManagement.sequence = 1;
        assetManagement.isActive = true;
        assetManagement.children = new List<Adm.AdminPage>{hierarchy,timeline,warrantyRules};

        //Technical Attributes  A360AM-1953
        Adm.AdminPage templateRules = new Adm.AdminPage();
        templateRules.name = 'Template Rules';
        templateRules.pageType = 'PAGE';
        templateRules.developerName = 'template_rules';
        templateRules.description = 'Template Rules';
        templateRules.targetType = 'LWC';
        templateRules.targetDeveloperName = 'c-template-match-rule-list-view';
        templateRules.sequence = 1;
        templateRules.isActive = true;

        Adm.AdminPage technicalAttributeSettings = new Adm.AdminPage();
        technicalAttributeSettings.name = 'Settings';
        technicalAttributeSettings.pageType = 'PAGE';
        technicalAttributeSettings.developerName = 'technical_attribute_settings';
        technicalAttributeSettings.description = 'Technical Attribute Settings.';
        technicalAttributeSettings.targetType = 'LWC';
        technicalAttributeSettings.targetDeveloperName = 'c-technical-attribute-settings';
        technicalAttributeSettings.sequence = 2;
        technicalAttributeSettings.isActive = true;

        Adm.AdminPage technicalAttributeGroup = new Adm.AdminPage();
        technicalAttributeGroup.name = 'Technical Attributes';
        technicalAttributeGroup.pageType = 'GROUP';
        technicalAttributeGroup.developerName = 'technical_attributes';
        technicalAttributeGroup.description = 'Technical Attributes';
        technicalAttributeGroup.targetType = null;
        technicalAttributeGroup.targetDeveloperName = null;
        technicalAttributeGroup.sequence = 2;
        technicalAttributeGroup.isActive = true;
        technicalAttributeGroup.children = new List<Adm.AdminPage>{templateRules,technicalAttributeSettings};

        Adm.AdminPage automaticRules = new Adm.AdminPage();
        automaticRules.name = 'Automatic Rules';
        automaticRules.pageType = 'PAGE';
        automaticRules.developerName = 'automatic_rules';
        automaticRules.description = 'Automatic Rules';
        automaticRules.targetType = 'LWC';
        automaticRules.targetDeveloperName = 'c-automatic-rules';
        automaticRules.sequence = 1;
        automaticRules.isActive = true;

        Adm.AdminPage interactiveEntitlement = new Adm.AdminPage();
        interactiveEntitlement.name = 'Interactive Entitlement';
        interactiveEntitlement.pageType = 'PAGE';
        interactiveEntitlement.developerName = 'interactive_entitlement';
        interactiveEntitlement.description = 'Interactive Entitlement';
        interactiveEntitlement.targetType = 'LWC';
        interactiveEntitlement.targetDeveloperName = 'c-entitlement-settings';
        interactiveEntitlement.sequence = 2;
        interactiveEntitlement.isActive = true;

        Adm.AdminPage serviceAssignmentRules = new Adm.AdminPage();
        serviceAssignmentRules.name = 'Service Assignment Rules';
        serviceAssignmentRules.pageType = 'PAGE';
        serviceAssignmentRules.developerName = 'service_assignment_rules';
        serviceAssignmentRules.description = 'Service Assignment Rules';
        serviceAssignmentRules.targetType = 'LWC';
        serviceAssignmentRules.targetDeveloperName = 'c-service-assignment-rules';
        serviceAssignmentRules.sequence = 3;
        serviceAssignmentRules.isActive = true;

        Adm.AdminPage pricebookAssignmentRules = new Adm.AdminPage();
        pricebookAssignmentRules.name = 'Pricebook Assignment Rules';
        pricebookAssignmentRules.pageType = 'PAGE';
        pricebookAssignmentRules.developerName = 'pricebook_assignment_rules';
        pricebookAssignmentRules.description = 'Pricebook Assignment Rules';
        pricebookAssignmentRules.targetType = 'LWC';
        pricebookAssignmentRules.targetDeveloperName = 'c-entitlement-settings';
        pricebookAssignmentRules.sequence = 4;
        pricebookAssignmentRules.isActive = true;

        Adm.AdminPage settings = new Adm.AdminPage();
        settings.name = 'Settings';
        settings.pageType = 'PAGE';
        settings.developerName = 'entitlement_common_settings';
        settings.description = 'Entitlement Common Settings';
        settings.targetType = 'LWC';
        settings.targetDeveloperName = 'c-entitlement-common-settings';
        settings.sequence = 5;
        settings.isActive = true;

        Adm.AdminPage entitlementGroup = new Adm.AdminPage();
        entitlementGroup.name = 'Entitlement';
        entitlementGroup.pageType = 'GROUP';
        entitlementGroup.developerName = 'entitlement';
        entitlementGroup.description = 'Entitlement Grouping';
        entitlementGroup.targetType = null;
        entitlementGroup.targetDeveloperName = null;
        entitlementGroup.sequence = 3;
        entitlementGroup.isActive = true;
        entitlementGroup.children = new List<Adm.AdminPage>{automaticRules, interactiveEntitlement, ServiceAssignmentRules, PricebookAssignmentRules, Settings};

        Adm.AdminPage expressionBuilder = new Adm.AdminPage();
        expressionBuilder.name = 'Expression Builder';
        expressionBuilder.pageType = 'PAGE';
        expressionBuilder.developerName = 'expression_builder';
        expressionBuilder.description = 'Expression Builder';
        expressionBuilder.targetType = 'LWC';
        expressionBuilder.targetDeveloperName = 'c-expression-admin-list-view';
        expressionBuilder.sequence = 4;
        expressionBuilder.isActive = true;

        Adm.AdminPage lwcDesigner = new Adm.AdminPage();
        lwcDesigner.name = 'LWC Designer';
        lwcDesigner.pageType = 'PAGE';
        lwcDesigner.developerName = 'lwc_designer';
        lwcDesigner.description = 'LWC Designer';
        lwcDesigner.targetType = 'URL';
        lwcDesigner.targetDeveloperName = '/lightning/cmp/SVMXA360__LayoutEditor';
        lwcDesigner.sequence = 5;
        lwcDesigner.isActive = true;

        Adm.AdminPage transactionDesigner = new Adm.AdminPage();
        transactionDesigner.name = 'Transaction Designer';
        transactionDesigner.pageType = 'PAGE';
        transactionDesigner.developerName = 'transaction_designer';
        transactionDesigner.description = 'Transaction Designer';
        transactionDesigner.targetType = 'URL';
        transactionDesigner.targetDeveloperName = '/lightning/cmp/SVMXA360__transactionEditor';
        transactionDesigner.sequence = 2;
        transactionDesigner.isActive = true;

        Adm.AdminPage mappingRules = new Adm.AdminPage();
        mappingRules.name = 'Mapping Rules';
        mappingRules.pageType = 'PAGE';
        mappingRules.developerName = 'mapping_rules';
        mappingRules.description = 'Mapping Rules';
        mappingRules.targetType = 'LWC';
        mappingRules.targetDeveloperName = 'c-mapping-admin-list-view';
        mappingRules.sequence = 3;
        mappingRules.isActive = true;

        Adm.AdminPage wizard = new Adm.AdminPage();
        wizard.name = 'Wizards';
        wizard.pageType = 'PAGE';
        wizard.developerName = 'service_wizards';
        wizard.description = 'Service Wizards';
        wizard.targetType = 'LWC';
        wizard.targetDeveloperName = 'c-wizard-admin-list-view';
        wizard.sequence = 1;
        wizard.isActive = true;

        Adm.AdminPage translationWorkbench = new Adm.AdminPage();
        translationWorkbench.name = 'Translation Workbench';
        translationWorkbench.pageType = 'PAGE';
        translationWorkbench.developerName = 'translation_workbench';
        translationWorkbench.description = 'Translation Workbench';
        translationWorkbench.targetType = 'LWC';
        translationWorkbench.targetDeveloperName = 'c-translation-workbench';
        translationWorkbench.sequence = 1;
        translationWorkbench.isActive = true;

        Adm.AdminPage applicationConfiguration = new Adm.AdminPage();
        applicationConfiguration.name = 'Settings';
        applicationConfiguration.pageType = 'GROUP';
        applicationConfiguration.developerName = 'spm_settings';
        applicationConfiguration.description = 'Settings';
        applicationConfiguration.targetType = null;
        applicationConfiguration.targetDeveloperName = null;
        applicationConfiguration.sequence = 7;
        applicationConfiguration.isActive = true;
        applicationConfiguration.children = new List<Adm.AdminPage>{translationWorkbench};

        Adm.AdminPage serviceProcessManager = new Adm.AdminPage();
        serviceProcessManager.name = 'Service Process Manager';
        serviceProcessManager.pageType = 'GROUP';
        serviceProcessManager.developerName = 'service_process_manager';
        serviceProcessManager.description = 'Service Process Manager Grouping';
        serviceProcessManager.targetType = null;
        serviceProcessManager.targetDeveloperName = null;
        serviceProcessManager.sequence = 6;
        serviceProcessManager.isActive = true;
        serviceProcessManager.children = new List<Adm.AdminPage>{wizard, transactionDesigner, mappingRules, expressionBuilder, lwcDesigner, applicationConfiguration};

        //depot
        Adm.AdminPage depotFinderRule = new Adm.AdminPage();
        depotFinderRule.name = 'Rules';
        depotFinderRule.pageType = 'PAGE';
        depotFinderRule.developerName = 'depot_finder_rule';
        depotFinderRule.description = 'Depot Management Rules';
        depotFinderRule.targetType = 'LWC';
        depotFinderRule.targetDeveloperName = 'c-depot-finder-rule';
        depotFinderRule.sequence = 1;
        depotFinderRule.isActive = true;

        Adm.AdminPage depotManagement = new Adm.AdminPage();
        depotManagement.name = 'Depot Management';
        depotManagement.pageType = 'GROUP';
        depotManagement.developerName = 'depot_management';
        depotManagement.description = 'Depot Management Grouping';
        depotManagement.targetType = null;
        depotManagement.targetDeveloperName = null;
        depotManagement.sequence = 5;
        depotManagement.isActive = true;
        depotManagement.children = new List<Adm.AdminPage>{depotFinderRule};

        //Product Service Campaigns A360AM-86
        Adm.AdminPage pscConfigurationRule = new Adm.AdminPage();
        pscConfigurationRule.name = 'Configuration Templates';
        pscConfigurationRule.pageType = 'PAGE';
        pscConfigurationRule.developerName = 'psc_configuration_templates';
        pscConfigurationRule.description = 'Configuration Templates';
        pscConfigurationRule.targetType = 'LWC';
        pscConfigurationRule.targetDeveloperName = 'c-psc-config-admin-list-view';
        pscConfigurationRule.sequence = 1;
        pscConfigurationRule.isActive = true;

        Adm.AdminPage pscSettingsRule = new Adm.AdminPage();
        pscSettingsRule.name = 'Settings';
        pscSettingsRule.pageType = 'PAGE';
        pscSettingsRule.developerName = 'psc_settings';
        pscSettingsRule.description = 'Settings';
        pscSettingsRule.targetType = 'LWC';
        pscSettingsRule.targetDeveloperName = 'c-psc-setting-admin-detail';
        pscSettingsRule.sequence = 2;
        pscSettingsRule.isActive = true;

        Adm.AdminPage pscManagement = new Adm.AdminPage();
        pscManagement.name = 'Product Service Campaign';
        pscManagement.pageType = 'GROUP';
        pscManagement.developerName = 'product_service_campaign';
        pscManagement.description = 'Product Service Campaign';
        pscManagement.targetType = null;
        pscManagement.targetDeveloperName = null;
        pscManagement.sequence = 4;
        pscManagement.isActive = true;
        pscManagement.children = new List<Adm.AdminPage>{pscConfigurationRule, pscSettingsRule};


        Adm.AdminPage mplanProcesses = new Adm.AdminPage();
        mplanProcesses.name = 'Maintenance Plan Processes';
        mplanProcesses.pageType = 'PAGE';
        mplanProcesses.developerName = 'mplan_processes';
        mplanProcesses.description = 'Maintenance Plan Processes';
        mplanProcesses.targetType = 'LWC';
        mplanProcesses.targetDeveloperName = 'c-mpln-admin-process-list-view';
        mplanProcesses.sequence = 1;
        mplanProcesses.isActive = true;

        Adm.AdminPage mplanProcessing = new Adm.AdminPage();
        mplanProcessing.name = 'Maintenance Plan Processing';
        mplanProcessing.pageType = 'GROUP';
        mplanProcessing.developerName = 'maintenance_plan_processing';
        mplanProcessing.description = 'Maintenance Plan Processing Grouping';
        mplanProcessing.targetType = null;
        mplanProcessing.targetDeveloperName = null;
        mplanProcessing.sequence = 7;
        mplanProcessing.isActive = true;
        mplanProcessing.children = new List<Adm.AdminPage>{mplanProcesses};
        //End Product Service Campaigns A360AM-86

        List<Adm.AdminPage> defaultAdminPages = new List<Adm.AdminPage>{setupHome, assetManagement, entitlementGroup, 
            pscManagement, depotManagement, serviceProcessManager, mplanProcessing};

        system.enqueueJob(new AsyncCreateDefaultAdminPages());

        return defaultAdminPages;
    }

    public void createDefaultAdminPages() {
        List<SVMXA360__CONF_AdminPage__c> defaultAdminPages = new List<SVMXA360__CONF_AdminPage__c>();

        // References for Foregin Key Lookup DML
        SVMXA360__CONF_AdminPage__c setupHome = new SVMXA360__CONF_AdminPage__c(
            Name = 'Setup Home',
            SVMXA360__Type__c = 'Page',
            SVMXA360__DeveloperName__c = 'setup_home',
            SVMXA360__Description__c = 'Setup Home',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-admin-welcome',
            SVMXA360__Sequence__c = 0,
            SVMXA360__IsActive__c = true
        );

        // References for Foregin Key Lookup DML
        SVMXA360__CONF_AdminPage__c entitlementGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Entitlement',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'entitlement',
            SVMXA360__Description__c = 'Entitlement Grouping',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 3,
            SVMXA360__IsActive__c = true
        );

        SVMXA360__CONF_AdminPage__c serviceProcessManagerGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Service Process Manager',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'service_process_manager',
            SVMXA360__Description__c = 'Service Process Manager Grouping',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 6,
            SVMXA360__IsActive__c = true
        );


        SVMXA360__CONF_AdminPage__c mplanProcessGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Maintenance Plan Processing',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'maintenance_plan_processing',
            SVMXA360__Description__c = 'Maintenanace Plan Processing Grouping',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 7,
            SVMXA360__IsActive__c = true
        );

        SVMXA360__CONF_AdminPage__c depotManagementGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Depot Management',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'depot_management',
            SVMXA360__Description__c = 'Depot Management Grouping',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 5,
            SVMXA360__IsActive__c = true
        );

        //Product Service Campaigns A360AM-86

        SVMXA360__CONF_AdminPage__c pscManagementGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Product Service Campaign',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'product_service_campaign',
            SVMXA360__Description__c = 'Product Service Campaign Grouping',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 4,
            SVMXA360__IsActive__c = true
        );
        //End Product Service Campaigns A360AM-86

        //Asset Management  A360AM-347
        
        SVMXA360__CONF_AdminPage__c assetManagementGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Asset Management',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'asset_management',
            SVMXA360__Description__c = 'Asset Management',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        );

        //Technical Attributes  A360AM-1953
        SVMXA360__CONF_AdminPage__c technicalAttributeGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Technical Attributes',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__DeveloperName__c = 'technical_attributes',
            SVMXA360__Description__c = 'Technical Attributes',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        );

        SvmxDatabase.upsertRecord(new List<SVMXA360__CONF_AdminPage__c>{setupHome, entitlementGrouping, serviceProcessManagerGrouping, depotManagementGrouping, pscManagementGrouping,assetManagementGrouping, technicalAttributeGrouping, mplanProcessGrouping});

        //Entitlement Menu
        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Automatic Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = entitlementGrouping.Id,
            SVMXA360__DeveloperName__c = 'automatic_rules',
            SVMXA360__Description__c = 'Automatic Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-automatic-rules',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Interactive Entitlement',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = entitlementGrouping.Id,
            SVMXA360__DeveloperName__c = 'interactive_entitlement',
            SVMXA360__Description__c = 'Interactive Entitlement',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-entitlement-settings',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Service Assignment Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = entitlementGrouping.Id,
            SVMXA360__DeveloperName__c = 'service_assignment_rules',
            SVMXA360__Description__c = 'Service Assignment Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-service-assignment-rules',
            SVMXA360__Sequence__c = 3,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Pricebook Assignment Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = entitlementGrouping.Id,
            SVMXA360__DeveloperName__c = 'pricebook_assignment_rules',
            SVMXA360__Description__c = 'Pricebook Assignment Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-pricebook-assignment-list-view',
            SVMXA360__Sequence__c = 4,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Settings',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = entitlementGrouping.Id,
            SVMXA360__DeveloperName__c = 'entitlement_common_settings',
            SVMXA360__Description__c = 'Entitlement Common Settings',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-entitlement-common-settings',
            SVMXA360__Sequence__c = 5,
            SVMXA360__IsActive__c = true
        ));

        // Service Process Manager Menu

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Expression Builder',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = serviceProcessManagerGrouping.Id,
            SVMXA360__DeveloperName__c = 'expression_builder',
            SVMXA360__Description__c = 'Expression Builder',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-expression-admin-list-view',
            SVMXA360__Sequence__c = 4,
            SVMXA360__IsActive__c = true
        ));

        SVMXA360__CONF_AdminPage__c applicationConfigurationGrouping = new SVMXA360__CONF_AdminPage__c(
            Name = 'Settings',
            SVMXA360__Type__c = 'GROUP',
            SVMXA360__Parent__c = serviceProcessManagerGrouping.Id,
            SVMXA360__DeveloperName__c = 'spm_settings',
            SVMXA360__Description__c = 'Settings',
            SVMXA360__TargetType__c = '',
            SVMXA360__TargetDeveloperName__c = '',
            SVMXA360__Sequence__c = 7,
            SVMXA360__IsActive__c = true
        );

        defaultAdminPages.add(applicationConfigurationGrouping);

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'LWC Designer',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = serviceProcessManagerGrouping.Id,
            SVMXA360__DeveloperName__c = 'lwc_designer',
            SVMXA360__Description__c = 'LWC Designer',
            SVMXA360__TargetType__c = 'URL',
            SVMXA360__TargetDeveloperName__c = '/lightning/cmp/SVMXA360__LayoutEditor',
            SVMXA360__Sequence__c = 5,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Transaction Designer',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = serviceProcessManagerGrouping.Id,
            SVMXA360__DeveloperName__c = 'transaction_designer',
            SVMXA360__Description__c = 'Transaction Designer',
            SVMXA360__TargetType__c = 'URL',
            SVMXA360__TargetDeveloperName__c = '/lightning/cmp/SVMXA360__transactionEditor',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Mapping Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = serviceProcessManagerGrouping.Id,
            SVMXA360__DeveloperName__c = 'mapping_rules',
            SVMXA360__Description__c = 'Mapping Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-mapping-admin-list-view',
            SVMXA360__Sequence__c = 3,
            SVMXA360__IsActive__c = true
        ));


        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Wizards',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = serviceProcessManagerGrouping.Id,
            SVMXA360__DeveloperName__c = 'service_wizards',
            SVMXA360__Description__c = 'Service Wizards',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-wizard-admin-list-view',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        //depot finder
        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = depotManagementGrouping.Id,
            SVMXA360__DeveloperName__c = 'depot_management_rules',
            SVMXA360__Description__c = 'Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-depot-finder-rule',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        //Product Service Campaigns A360AM-86
        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Configuration Templates',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = pscManagementGrouping.Id,
            SVMXA360__DeveloperName__c = 'psc_configuration_templates',
            SVMXA360__Description__c = 'Configuration Templates',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-psc-config-admin-list-view',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Settings',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = pscManagementGrouping.Id,
            SVMXA360__DeveloperName__c = 'psc_settings',
            SVMXA360__Description__c = 'Settings',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-psc-setting-admin-detail',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        ));

        //End Product Service Campaigns A360AM-86 

        //Asset Management A360AM-347

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Hierarchy',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = assetManagementGrouping.Id,
            SVMXA360__DeveloperName__c = 'hierarchy',
            SVMXA360__Description__c = 'Asset Hierarchy',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-hierarchy-config-list-view',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));
        
        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Timeline',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = assetManagementGrouping.Id,
            SVMXA360__DeveloperName__c = 'timeline',
            SVMXA360__Description__c = 'Asset Timeline',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-asset-timeline-admin-list',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = assetManagementGrouping.Id,
            SVMXA360__DeveloperName__c = 'warranty_management_rules',
            SVMXA360__Description__c = 'Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-warranty-rules',
            SVMXA360__Sequence__c = 3,
            SVMXA360__IsActive__c = true
        ));

        //Technical Attributes  A360AM-1953
        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Template Rules',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = technicalAttributeGrouping.Id,
            SVMXA360__DeveloperName__c = 'template_rules',
            SVMXA360__Description__c = 'Template Rules',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-template-match-rule-list-view',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Settings',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = technicalAttributeGrouping.Id,
            SVMXA360__DeveloperName__c = 'technical_attribute_settings',
            SVMXA360__Description__c = 'Technical Attribute Settings',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-technical-attribute-settings',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        ));

        defaultAdminPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Maintenance Plan Processes',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = mplanProcessGrouping.Id,
            SVMXA360__DeveloperName__c = 'mplan_processes',
            SVMXA360__Description__c = 'Maintenance Plan Processes',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-mpln-admin-process-list-view',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        SvmxDatabase.upsertRecord(defaultAdminPages);

        List<SVMXA360__CONF_AdminPage__c> configurationSettingPages = new List<SVMXA360__CONF_AdminPage__c>();
        
        configurationSettingPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Translations',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = applicationConfigurationGrouping.Id,
            SVMXA360__DeveloperName__c = 'translation_workbench',
            SVMXA360__Description__c = 'Settings',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-translation-workbench',
            SVMXA360__Sequence__c = 1,
            SVMXA360__IsActive__c = true
        ));

        configurationSettingPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Usage Statistics',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = applicationConfigurationGrouping.Id,
            SVMXA360__DeveloperName__c = 'feature_settings',
            SVMXA360__Description__c = 'Usage Statistics',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-feature-setting-admin',
            SVMXA360__Sequence__c = 2,
            SVMXA360__IsActive__c = true
        ));

        configurationSettingPages.add(new SVMXA360__CONF_AdminPage__c(
            Name = 'Debug Transactions',
            SVMXA360__Type__c = 'PAGE',
            SVMXA360__Parent__c = applicationConfigurationGrouping.Id,
            SVMXA360__DeveloperName__c = 'debug_transactions',
            SVMXA360__Description__c = 'Debug Transactions',
            SVMXA360__TargetType__c = 'LWC',
            SVMXA360__TargetDeveloperName__c = 'c-spm-common-settings',
            SVMXA360__Sequence__c = 3,
            SVMXA360__IsActive__c = true
        ));

        SvmxDatabase.upsertRecord(configurationSettingPages);
    }

    private class AsyncCreateDefaultAdminPages implements Queueable {
        public void execute(QueueableContext context) {
            ADM_AdminPageManager.getInstance().createDefaultAdminPages();  
        }
    }

    /**
     * Private consructor to restrict multiple instance creation of this class.
     */
    private ADM_AdminPageManager() {
    }
}