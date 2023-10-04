/******************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve where used details of Expression, Transaction, Mapping and Lookup. 
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna Nagapudi      	28 Mar 2022     Created.
 *****************************************************************************************************/
public with sharing class ADM_WhereUsedManager {
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_WhereUsedManager instance;

    // Static string variable to hold screen type transaction
    public static final String TRANSACTION_TYPE = 'Transaction';

    // Static string variable to hold screen type screen
    public static final String SCREEN = 'Screen';
    
    // Static string variable to hold screen type screen
    public static final String EXPRESSION = 'Expression';
    
    // Static string variable to hold screen type screen
    public static final String LOOKUP_FILTER = 'Lookup Filter';
    
    // Static string variable to hold screen type screen
    public static final String MAPPING = 'Mapping';

    // Static string variable to hold Service Process Manager
    public static final String SERVICE_PROCESS_MANAGER = 'Service Process Manager';

    // Static string variable to hold salesforce configuration
    public static final String SALESFORCE_CONFIGURATION = 'Salesforce Configuration';

    // Static string variable to hold Settings
    public static final String SETTINGS = 'Settings';
    
    // Static string variable to hold Depot
    public static final String DEPOT = 'Depot';
    
    // Static string variable to hold Warranty
    public static final String WARRANTY_MANAGEMENT = 'Warranty Management';
    
    // Static string variable to hold Product Service Campaigns
    public static final String PRODUCT_SERVICE_CAMPAIGNS = 'Product Service Campaigns';

    // Static string variable to hold Configuration Templates
    public static final String CONFIGURATION_TEMPLATES = 'Configuration Templates';

    // Static string variable to hold Wizard
    public static final String WIZARD = 'Wizard';

    // Static string variable to hold Flow
    public static final String FLOW = 'Flow';

    // Static string variable to hold RecordPage
    public static final String RECORDPAGE = 'RecordPage';

    // Static string variable to hold Asset
    public static final String ASSET = 'Asset';

    // Static string variable to hold Asset Hierarchy
    public static final String ASSET_HIERARCHY = 'Asset Hierarchy';

    // Static string variable to hold Asset Timeline
    public static final String ASSET_TIMELINE = 'Asset Timeline';

    public ADM_ConfigurationUsageManager configUsageInstance = ADM_ConfigurationUsageManager.getInstance();
    
    // List of fields to be queried from Layout Related Section Object.
    private final static List<String> relatedSectionQueryFields = new List<String>{
        'Id', 
        'Name', 
        'SVMXA360__FieldMapping__c',
        'SVMXA360__ValueMapping__c',
        'SVMXA360__Layout__r.Name', 
        'SVMXA360__Layout__r.SVMXA360__DeveloperName__c', 
        'SVMXA360__Layout__c',
        'SVMXA360__VisibilityCriteriaID__c',
        'SVMXA360__QualifyingCriteria__c',
        'SVMXA360__Layout__r.SVMXA360__ScreenType__c'
    };

    // List of fields to be queried from Layout Related Section Object.
    private final static List<String> sectionQueryFields = new List<String>{
        'Id', 
        'Name', 
        'SVMXA360__VisibilityCriteriaID__c',
        'SVMXA360__Layout__r.Name', 
        'SVMXA360__Layout__r.SVMXA360__DeveloperName__c', 
        'SVMXA360__Layout__c',
        'SVMXA360__Layout__r.SVMXA360__ScreenType__c'
    };
    
    // List of fields to be queried from Layout Object.
    private final static List<String> layoutQueryFields = new List<String>{
        'Id',
        'Name', 
        'SVMXA360__DeveloperName__c',
        'SVMXA360__FieldMapping__c',
        'SVMXA360__ValueMapping__c', 
        '(SELECT Id, Name FROM SVMXA360__LayoutSections__r)' 
    };
    
    // List of fields to be queried from Layout Element Object.
    private final static List<String> layoutElementQueryFields = new List<String>{
        'Id', 
        'Name', 
        'SVMXA360__LayoutSection__c', 
        'SVMXA360__LayoutSection__r.Name', 
        'SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c',
        'SVMXA360__LayoutSection__r.SVMXA360__Layout__r.Name',
        'SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c',
        'SVMXA360__LayoutSection__r.SVMXA360__Layout__c',
        'SVMXA360__LayoutRelatedSection__r.Name', 
        'SVMXA360__LayoutRelatedSection__c', 
        'SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c',
        'SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.Name',
        'SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c',
        'SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c',
        'SVMXA360__FormFillMappingId__c'                                                                                        
    };
    
    // List of fields to be queried from Wizard Step Object.
    private final static List<String> wizardStepQueryFields = new List<String>{
        'Id',
        'Name',
        'SVMXA360__ProcessWizard__c',
        'SVMXA360__ProcessWizard__r.Name',
        'SVMXA360__ProcessWizard__r.SVMXA360__ObjectAPIName__c',
        'SVMXA360__ProcessWizard__r.SVMXA360__DeveloperName__c',
        'SVMXA360__Target__c',
        'SVMXA360__Type__c',
        'SVMXA360__ProcessWizard__r.SVMXA360__Active__c'                                                                                        
    };

    // List of fields to be queried from Wizard Object.
    private final static List<String> wizardQueryFields = new List<String>{
        'Id',
        'Name',
        'SVMXA360__DeveloperName__c',
        'SVMXA360__ObjectAPIName__c',
        'SVMXA360__VisibilityCriteria__c'                                                                                        
    };

    // List of fields to be queried from Expression Based Mapping Row Object.
    private final static List<String> exprBasedMappingFields = new List<String>{
        'Id',
        'Name',
        'SVMXA360__ExpressionId__c',
        'SVMXA360__ExpressionBasedMapping__c',
        'SVMXA360__ObjectMappingId__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.Name',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.SVMXA360__DeveloperName__c',
        'SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.SVMXA360__ScreenType__c'
    };

    public class ExpressionBasedMappingForTransaction {
        public List<SVMXA360__CONF_ExpressionBasedMappingRow__c> transactionExprBasedMappingList {get;set;}
        public List<SVMXA360__CONF_ExpressionBasedMappingRow__c> screenExprBasedMappingList {get;set;}
    }
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private ADM_WhereUsedManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_WhereUsedManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'ADM_WhereUsedManager.getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new ADM_WhereUsedManager();
                System.debug( LoggingLevel.INFO, 'ADM_WhereUsedManager.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'ADM_WhereUsedManager.getInstance() - exit' );
        }
        
        return instance;
    }

     /**
     * This method is used to retrieve all where used details.
     */
    public List<Adm.WhereUsedInfo> getWhereUsedDetails(Adm.WhereUsedInputRecord inputRecord) {
        
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() - enter' );
        
        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();
        
        try {
            
            if( String.IsBlank(inputRecord.moduleType) || String.IsBlank(inputRecord.configurationId) || String.IsBlank(inputRecord.configDeveloperName)) {
                System.debug( LoggingLevel.ERROR, 'getWhereUsedDetails() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            inputRecord.moduleType = String.escapeSingleQuotes(inputRecord.moduleType);
            inputRecord.configurationId = String.escapeSingleQuotes(inputRecord.configurationId);
            inputRecord.configDeveloperName = String.escapeSingleQuotes(inputRecord.configDeveloperName);
            inputRecord.configType = String.isBlank(inputRecord.configType) ? inputRecord.configType : String.escapeSingleQuotes(inputRecord.configType);
    
            if(inputRecord.moduleType == EXPRESSION) {

                whereUsedInfoList.addAll(getWhereUsedExpressionDetails(inputRecord));
            }

            if(inputRecord.moduleType == LOOKUP_FILTER) {

                whereUsedInfoList.addAll(getWhereUsedLookUpDetails(inputRecord));
            }

            if(inputRecord.moduleType == TRANSACTION_TYPE) {

                whereUsedInfoList.addAll(getWhereUsedTransactionDetails(inputRecord));                                                                      
            }
            
            if(inputRecord.moduleType == SCREEN) {

                whereUsedInfoList.addAll(getWhereUsedScreenDetails(inputRecord));                                                                      
            }

            if(inputRecord.moduleType == MAPPING) {
                String mappingQuery = 'SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__Type__c FROM SVMXA360__CONF_ObjectMapping__c WHERE Id =\''+inputRecord.configurationId+'\'';
                List<SVMXA360__CONF_ObjectMapping__c> mappingRecord = SvmxDatabase.query( Database.query(mappingQuery) );
                if (mappingRecord.size() > 0) {
                    inputRecord.configType = mappingRecord.get(0).SVMXA360__Type__c;
                }
                whereUsedInfoList.addAll(getWhereUsedMappingDetails(inputRecord));
            }
            
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() : Retrieved all where used details' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getWhereUsedDetails() : Failed to retrieve where used details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() - exit; whereUsedInfo.size()= ' + whereUsedInfoList.size() );
        }
        
        return whereUsedInfoList;
    }

    /**
     * This method is used to retrieve all where used expression details.
     */
    public List<Adm.WhereUsedInfo> getWhereUsedExpressionDetails(Adm.WhereUsedInputRecord inputRecord) {

        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();

        String assetHierarchyQuery = 'SELECT Id, Name, SVMXA360__FilterCriteria__c, SVMXA360__HierarchyConfigId__c, SVMXA360__HierarchyConfigId__r.Name, SVMXA360__HierarchyConfigId__r.SVMXA360__DeveloperName__c FROM SVMXA360__CONF_HierarchyConfigDetail__c WHERE SVMXA360__FilterCriteria__c =\''+inputRecord.configurationId+'\' OR SVMXA360__NotificationFilterCriteria__c =\''+inputRecord.configurationId+'\'';

        List<SVMXA360__CONF_HierarchyConfigDetail__c> expressionUsedInHierarchy = SvmxDatabase.query( Database.query(assetHierarchyQuery) );
                
        if(expressionUsedInHierarchy.size() > 0) {
            whereUsedInfoList.add(getWhereUsedExpressionInHierarchy(expressionUsedInHierarchy));
        }

        String assetTimelineQuery = 'SELECT Id, SVMXA360__QualifyingCriteria__c, SVMXA360__TimelineConfigId__c, SVMXA360__TimelineConfigId__r.Name, SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c FROM SVMXA360__CONF_TimelineConfigDetail__c WHERE SVMXA360__QualifyingCriteria__c =\''+inputRecord.configurationId+'\'';

        List<SVMXA360__CONF_TimelineConfigDetail__c> expressionUsedInTimeline = SvmxDatabase.query( Database.query(assetTimelineQuery) );
                
        if(expressionUsedInTimeline.size() > 0) {
            whereUsedInfoList.add(getWhereUsedExpressionInTimeline(expressionUsedInTimeline));
        }

        String layoutQuery = 'SELECT '+String.join( layoutQueryFields, ',')+' FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__QualifyingCriteria__c =\''+inputRecord.configurationId+'\'';                                                                                     
        List<SVMXA360__CONF_Layout__c> exprUsedInTrasactionHeaderList = SvmxDatabase.query( Database.query( layoutQuery ) );

        String relatedSectionQuery = 'SELECT '+String.join( relatedSectionQueryFields, ',')+' FROM SVMXA360__CONF_LayoutRelatedSection__c WHERE SVMXA360__QualifyingCriteria__c =\''+inputRecord.configurationId+'\' OR SVMXA360__VisibilityCriteriaID__c =\''+inputRecord.configurationId+'\'';
        List<SVMXA360__CONF_LayoutRelatedSection__c> exprUsedInTrasactionChildsList = SvmxDatabase.query( Database.query( relatedSectionQuery ) );

        String sectionQuery = 'SELECT '+String.join( sectionQueryFields, ',')+' FROM SVMXA360__CONF_LayoutSection__c WHERE SVMXA360__VisibilityCriteriaID__c =\''+inputRecord.configurationId+'\''; 
        List<SVMXA360__CONF_LayoutSection__c> exprUsedInSectionList = SvmxDatabase.query( Database.query( sectionQuery ) );

        String exprBasedMappingQuery = 'SELECT '+String.join( exprBasedMappingFields, ',')+' FROM SVMXA360__CONF_ExpressionBasedMappingRow__c WHERE SVMXA360__ExpressionId__c =\''+inputRecord.configurationId+'\''; 
        List<SVMXA360__CONF_ExpressionBasedMappingRow__c> exprBasedMappingList = SvmxDatabase.query( Database.query( exprBasedMappingQuery ) );

        List<SVMXA360__CONF_LayoutRelatedSection__c> transactionChildDisplayRuleList = new List<SVMXA360__CONF_LayoutRelatedSection__c>();
        List<SVMXA360__CONF_LayoutRelatedSection__c> screenChildDisplayRuleList = new List<SVMXA360__CONF_LayoutRelatedSection__c>();

        List<SVMXA360__CONF_LayoutSection__c> transactionHeaderDisplayRuleList = new List<SVMXA360__CONF_LayoutSection__c>();
        List<SVMXA360__CONF_LayoutSection__c> screenHeaderDisplayRuleList = new List<SVMXA360__CONF_LayoutSection__c>();

        List<SVMXA360__CONF_ExpressionBasedMappingRow__c> transactionExprBasedMappingList = new List<SVMXA360__CONF_ExpressionBasedMappingRow__c>();
        List<SVMXA360__CONF_ExpressionBasedMappingRow__c> screenExprBasedMappingList = new List<SVMXA360__CONF_ExpressionBasedMappingRow__c>();

        for(SVMXA360__CONF_LayoutSection__c element : exprUsedInSectionList){
            if(element.SVMXA360__Layout__c != null && (element.SVMXA360__Layout__r.SVMXA360__ScreenType__c == '' || element.SVMXA360__Layout__r.SVMXA360__ScreenType__c == SCREEN)) {
                screenHeaderDisplayRuleList.add(element);
            } else if (element.SVMXA360__Layout__c != null &&  element.SVMXA360__Layout__r.SVMXA360__ScreenType__c == TRANSACTION_TYPE) {
                transactionHeaderDisplayRuleList.add(element);
            }
        }

        for(SVMXA360__CONF_LayoutRelatedSection__c element : exprUsedInTrasactionChildsList){
            if(element.SVMXA360__Layout__c != null && (element.SVMXA360__Layout__r.SVMXA360__ScreenType__c == '' || element.SVMXA360__Layout__r.SVMXA360__ScreenType__c == SCREEN)) {
                screenChildDisplayRuleList.add(element);
            } else if (element.SVMXA360__Layout__c != null &&  element.SVMXA360__Layout__r.SVMXA360__ScreenType__c == TRANSACTION_TYPE) {
                transactionChildDisplayRuleList.add(element);
            }
        }

        ExpressionBasedMappingForTransaction exprBasedMappingDetails = new ExpressionBasedMappingForTransaction();
        if (exprBasedMappingList.size() > 0) {
            exprBasedMappingDetails = populateExpressionBasedMappingForTransaction(exprBasedMappingList);
        } 
        
        String expressionQuery = 'SELECT Id, Name, SVMXA360__ExpressionType__c FROM SVMXA360__CONF_Expression__c WHERE Id =\''+inputRecord.configurationId+'\''; 
        List<SVMXA360__CONF_Expression__c> expressionRecordlist = SvmxDatabase.query( Database.query( expressionQuery ) );

        String expressionType = '';
        if(expressionRecordlist.size() > 0) {
            expressionType = expressionRecordlist.get(0).SVMXA360__ExpressionType__c == 'VISIBILITY-RULE-CRITERIA' ? 'VISIBILITY-RULE-CRITERIA' : '';
        }        
        Adm.WhereUsedTransaction  whereUsedTrans = new Adm.WhereUsedTransaction();
        whereUsedTrans.transactionList = exprUsedInTrasactionHeaderList;
        whereUsedTrans.relatedSectionList = transactionChildDisplayRuleList;
        whereUsedTrans.sectionList = transactionHeaderDisplayRuleList;
        if (exprBasedMappingDetails.transactionExprBasedMappingList != NULL) {
            whereUsedTrans.exprBasedMappingList = exprBasedMappingDetails.transactionExprBasedMappingList;
        }
        whereUsedTrans.screenType = TRANSACTION_TYPE;
        whereUsedTrans.moduleType = EXPRESSION;
        whereUsedTrans.configType = expressionType;

        if(whereUsedTrans.transactionList.size() > 0  || whereUsedTrans.relatedSectionList.size() > 0 || whereUsedTrans.sectionList.size() > 0 || 
            (whereUsedTrans.exprBasedMappingList != NULL && whereUsedTrans.exprBasedMappingList.size() > 0)) { 
            whereUsedInfoList.add(createWhereUserWrapperForTransactions(whereUsedTrans)); 
        } 
        
        Adm.WhereUsedTransaction  whereUsedScreen = new Adm.WhereUsedTransaction();
        whereUsedScreen.relatedSectionList = screenChildDisplayRuleList;
        whereUsedScreen.sectionList = screenHeaderDisplayRuleList;
        if (exprBasedMappingDetails.screenExprBasedMappingList != NULL) {
            whereUsedScreen.exprBasedMappingList = exprBasedMappingDetails.screenExprBasedMappingList;
        }
        whereUsedScreen.screenType = SCREEN;
        whereUsedScreen.moduleType = EXPRESSION;
        whereUsedScreen.configType = expressionType;

        if(whereUsedScreen.relatedSectionList.size() > 0  || whereUsedScreen.sectionList.size() > 0 || 
            (whereUsedScreen.exprBasedMappingList != NULL && whereUsedScreen.exprBasedMappingList.size() > 0)) { 
            whereUsedInfoList.add(createWhereUserWrapperForTransactions(whereUsedScreen)); 
        }

        String wizardStepQuery = 'SELECT '+String.join( wizardStepQueryFields, ',')+' FROM SVMXA360__CONF_ProcessWizardStep__c WHERE SVMXA360__VisibilityCriteria__c =\''+inputRecord.configurationId+'\'';                                                                               
        List<SVMXA360__CONF_ProcessWizardStep__c> transactionsUsedInWizardSteps = SvmxDatabase.query( Database.query( wizardStepQuery ) );

        String wizardQuery = 'SELECT '+String.join( wizardQueryFields, ',')+' FROM SVMXA360__CONF_ProcessWizard__c WHERE SVMXA360__VisibilityCriteria__c =\''+inputRecord.configurationId+'\'';                                                                               
        List<SVMXA360__CONF_ProcessWizard__c> transactionsUsedInWizards = SvmxDatabase.query( Database.query( wizardQuery ) );

        Map<String, Adm.ConfigurationTemplate> configurations = new Map<String, Adm.ConfigurationTemplate>();
        if(transactionsUsedInWizards.size() > 0 || transactionsUsedInWizardSteps.size() > 0) { 
            Adm.WhereUsedInfo whereUsedInfo = new  Adm.WhereUsedInfo();
            whereUsedInfo.moduleNameValue = SERVICE_PROCESS_MANAGER;
            whereUsedInfo.subModuleNameValue = WIZARD;
            whereUsedInfo.moduleName = System.Label.Label_Service_Process_Manager;
            whereUsedInfo.subModuleName = System.Label.Label_Wizard;

            for(SVMXA360__CONF_ProcessWizard__c wizard : transactionsUsedInWizards) {

                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = wizard.Name;
                config.configurationDeveloperName = wizard.SVMXA360__DeveloperName__c;
                config.configurationId = wizard.Id;
                config.configurationObject = wizard.SVMXA360__ObjectAPIName__c;

                configurations = createConfigurationTemplate(config, null, configurations);
            }

            for(SVMXA360__CONF_ProcessWizardStep__c step : transactionsUsedInWizardSteps) {

                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = step.SVMXA360__ProcessWizard__r.Name;
                config.configurationDeveloperName = step.SVMXA360__ProcessWizard__r.SVMXA360__DeveloperName__c;
                config.configurationId = step.SVMXA360__ProcessWizard__c;
                config.configurationObject = step.SVMXA360__ProcessWizard__r.SVMXA360__ObjectAPIName__c;

                Adm.SectionTemplate section = new Adm.SectionTemplate();
                section.sectionName = step.Name;
                section.sectionType = System.Label.Label_WizardStep;

                configurations = createConfigurationTemplate(config, section, configurations);
            }
            whereUsedInfo.configurationTemplates = new List<Adm.ConfigurationTemplate>();
            whereUsedInfo.configurationTemplates.addAll(configurations.values()); 
            whereUsedInfoList.add(whereUsedInfo); 
        }
        return whereUsedInfoList;
    }

    /**
     * This method is used to retrieve all where used lookUp details.
     */
    public List<Adm.WhereUsedInfo> getWhereUsedLookUpDetails(Adm.WhereUsedInputRecord inputRecord) {

        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();

        String layoutElementQuery = 'SELECT '+String.join( layoutElementQueryFields, ',')+' FROM SVMXA360__CONF_LayoutElement__c '; 
        String whereClause = 'WHERE SVMXA360__LookupConfiguration__c =\''+inputRecord.configurationId+'\' AND (SVMXA360__LayoutSection__c != NULL OR SVMXA360__LayoutRelatedSection__c != NULL)';  
        layoutElementQuery += whereClause;                                                                               
        List<SVMXA360__CONF_LayoutElement__c> lookUpUsedInTransactionList = SvmxDatabase.query( Database.query( layoutElementQuery ) );

        List<SVMXA360__CONF_LayoutElement__c> transactionElementsList = new List<SVMXA360__CONF_LayoutElement__c>();
        List<SVMXA360__CONF_LayoutElement__c> screenElementsList = new List<SVMXA360__CONF_LayoutElement__c>();
        for(SVMXA360__CONF_LayoutElement__c element : lookUpUsedInTransactionList){
            String configScreenType = '';
            if (element.SVMXA360__LayoutSection__r.SVMXA360__Layout__c != null) {
                configScreenType = element.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c;
            } else if (element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c != null) {
                configScreenType = element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c;
            }
            if(configScreenType == '' || configScreenType == SCREEN) {
                screenElementsList.add(element);
            } else if (configScreenType == TRANSACTION_TYPE) {
                transactionElementsList.add(element);
            }
        }

        if(screenElementsList.size() > 0) {
            Adm.WhereUsedTransaction  whereUsedScreen = new Adm.WhereUsedTransaction();
            whereUsedScreen.layoutElementList = screenElementsList;
            whereUsedScreen.screenType = SCREEN;
            whereUsedInfoList.add(createWhereUserWrapperForTransactions(whereUsedScreen)); 

        } 

        if(transactionElementsList.size() > 0) {
            Adm.WhereUsedTransaction  whereUsedTrans = new Adm.WhereUsedTransaction();
            whereUsedTrans.layoutElementList = transactionElementsList;
            whereUsedTrans.screenType = TRANSACTION_TYPE;
            whereUsedInfoList.add(createWhereUserWrapperForTransactions(whereUsedTrans));  
        }

        return whereUsedInfoList;
    }

    /**
     * This method is used to retrieve all where used screen details.
     */
    public List<Adm.WhereUsedInfo> getWhereUsedScreenDetails(Adm.WhereUsedInputRecord inputRecord) {
        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();

        List<SVMXA360__ConfigurationUsage__c> configUsageList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__TransactionId__c, SVMXA360__EntityType__c, SVMXA360__EntityId__c, SVMXA360__EntityName__c, SVMXA360__EntityLabel__c FROM SVMXA360__ConfigurationUsage__c WHERE SVMXA360__TransactionId__c = :inputRecord.configurationId AND SVMXA360__EntityType__c = 'Flow']);

        if (configUsageList.size() > 0) {
            whereUsedInfoList.add(getWhereUsedFlowDetails(configUsageList));
        }
        return whereUsedInfoList;
    }    

    /**
     * This method is used to retrieve all where used transaction details.
     */
    public List<Adm.WhereUsedInfo> getWhereUsedTransactionDetails(Adm.WhereUsedInputRecord inputRecord) {

        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();

        String wizardStepQuery = 'SELECT '+String.join( wizardStepQueryFields, ',')+' FROM SVMXA360__CONF_ProcessWizardStep__c WHERE SVMXA360__Type__c = \'SPM Transaction\' AND SVMXA360__Target__c =\''+inputRecord.configDeveloperName+'\' AND SVMXA360__ProcessWizard__r.SVMXA360__Active__c = true';                                                                               
        List<SVMXA360__CONF_ProcessWizardStep__c> transactionsUsedInWizards = SvmxDatabase.query( Database.query( wizardStepQuery ) );
                
        if(transactionsUsedInWizards.size() > 0) {
            Adm.WhereUsedInfo whereUsedInfo = new  Adm.WhereUsedInfo();
            whereUsedInfo.moduleNameValue = SERVICE_PROCESS_MANAGER;
            whereUsedInfo.subModuleNameValue = WIZARD;
            whereUsedInfo.moduleName = System.Label.Label_Service_Process_Manager;
            whereUsedInfo.subModuleName = System.Label.Label_Wizard;

            Map<String, Adm.ConfigurationTemplate> configurations = new Map<String, Adm.ConfigurationTemplate>();
            for(SVMXA360__CONF_ProcessWizardStep__c step : transactionsUsedInWizards) {

                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = step.SVMXA360__ProcessWizard__r.Name;
                config.configurationDeveloperName = step.SVMXA360__ProcessWizard__r.SVMXA360__DeveloperName__c;
                config.configurationId = step.SVMXA360__ProcessWizard__c;
                config.configurationObject = step.SVMXA360__ProcessWizard__r.SVMXA360__ObjectAPIName__c;

                Adm.SectionTemplate section = new Adm.SectionTemplate();
                section.sectionName = step.Name;
                section.sectionType = System.Label.Label_WizardStep;

                configurations = createConfigurationTemplate(config, section, configurations);
            }
            whereUsedInfo.configurationTemplates = new List<Adm.ConfigurationTemplate>();
            whereUsedInfo.configurationTemplates.addAll(configurations.values()); 
            whereUsedInfoList.add(whereUsedInfo);   
        }

        List<SVMXA360__ConfigurationUsage__c> configUsageList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__TransactionId__c, SVMXA360__EntityType__c, SVMXA360__EntityName__c, SVMXA360__EntityId__c, SVMXA360__EntityLabel__c FROM SVMXA360__ConfigurationUsage__c WHERE SVMXA360__TransactionId__c = :inputRecord.configurationId]);

        List<SVMXA360__ConfigurationUsage__c> configUsageFlowList = new List<SVMXA360__ConfigurationUsage__c>();
        List<SVMXA360__ConfigurationUsage__c> configUsageRecordPageList = new List<SVMXA360__ConfigurationUsage__c>();

        for (SVMXA360__ConfigurationUsage__c configUsage: configUsageList) {
            if (configUsage.SVMXA360__EntityType__c == 'Flow') {
                configUsageFlowList.add(configUsage);
            } else if (configUsage.SVMXA360__EntityType__c == 'RecordPage') {
                configUsageRecordPageList.add(configUsage);
            }
        }
        
        if (configUsageFlowList.size() > 0) {
            whereUsedInfoList.add(getWhereUsedFlowDetails(configUsageFlowList));
        }

        if (configUsageRecordPageList.size() > 0) {
            whereUsedInfoList.add(getWhereUsedRecordPageDetails(configUsageRecordPageList));
        }

        return whereUsedInfoList;

    }

    /**
     * This method is used to retrieve all where used transaction details in flow.
     */
    public Adm.WhereUsedInfo getWhereUsedFlowDetails(List<SVMXA360__ConfigurationUsage__c> configUsageList) {

        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();
        Adm.WhereUsedInfo whereUsedInfo = new  Adm.WhereUsedInfo();
        whereUsedInfo.moduleNameValue = SALESFORCE_CONFIGURATION;
        whereUsedInfo.subModuleNameValue = FLOW;
        whereUsedInfo.moduleName = SALESFORCE_CONFIGURATION;
        whereUsedInfo.subModuleName = System.Label.Label_StepTypeFlow;

        if (configUsageInstance.configUsageSuccessLastExecutedOn == null) {
            configUsageInstance.getConfigurationUsageSettings();
        }
        whereUsedInfo.lastExecutionDateTime = String.valueOfGmt(configUsageInstance.configUsageSuccessLastExecutedOn);
        whereUsedInfo.configurationTemplates = new List<Adm.ConfigurationTemplate>(); 
        Map<String, Adm.ConfigurationTemplate> configTemplateMap = new Map<String, Adm.ConfigurationTemplate>();
        for(SVMXA360__ConfigurationUsage__c configUsage : configUsageList) {
            if(!configTemplateMap.containsKey(configUsage.SVMXA360__EntityId__c)) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = configUsage.SVMXA360__EntityLabel__c;
                config.configurationDeveloperName = configUsage.SVMXA360__EntityName__c;
                config.configurationId = configUsage.SVMXA360__EntityId__c;
                configTemplateMap.put(configUsage.SVMXA360__EntityId__c, config);
            }
        }
        whereUsedInfo.configurationTemplates.addAll(configTemplateMap.values());    

        return whereUsedInfo;
        
    } 
    
    /**
    * This method is used to retrieve all where used transaction details in record pages.
    */
    public Adm.WhereUsedInfo getWhereUsedRecordPageDetails(List<SVMXA360__ConfigurationUsage__c> configUsageList) {

        Adm.WhereUsedInfo whereUsedInfo = new  Adm.WhereUsedInfo();
        whereUsedInfo.moduleNameValue = SALESFORCE_CONFIGURATION;
        whereUsedInfo.subModuleNameValue = RECORDPAGE;
        whereUsedInfo.moduleName = SALESFORCE_CONFIGURATION;
        whereUsedInfo.subModuleName = 'Lightning - ' + System.Label.Label_LightningRecordPage;

        if (configUsageInstance.configUsageSuccessLastExecutedOn == null) {
            configUsageInstance.getConfigurationUsageSettings();
        }
        whereUsedInfo.lastExecutionDateTime = String.valueOfGmt(configUsageInstance.configUsageSuccessLastExecutedOn);

        whereUsedInfo.configurationTemplates = new List<Adm.ConfigurationTemplate>(); 
        Map<String, Adm.ConfigurationTemplate> configTemplateMap = new Map<String, Adm.ConfigurationTemplate>();
        for(SVMXA360__ConfigurationUsage__c configUsage : configUsageList) {
            if(!configTemplateMap.containsKey(configUsage.SVMXA360__EntityId__c)) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = configUsage.SVMXA360__EntityLabel__c;
                config.configurationDeveloperName = configUsage.SVMXA360__EntityName__c;
                config.configurationId = configUsage.SVMXA360__EntityId__c;
                configTemplateMap.put(configUsage.SVMXA360__EntityId__c, config);
            }
        }
        whereUsedInfo.configurationTemplates.addAll(configTemplateMap.values());    

        return whereUsedInfo;
    }

    /**
     * This method is used to retrieve all where used mapping details.
     */
    public List<Adm.WhereUsedInfo> getWhereUsedMappingDetails(Adm.WhereUsedInputRecord inputRecord) {

        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();

        String warrantyQuery = 'SELECT Id,Name,SVMXA360__ObjectMapping__r.Name, SVMXA360__ObjectMapping__r.SVMXA360__DeveloperName__c, SVMXA360__ObjectMapping__c FROM SVMXA360__CONF_WarrantyConfig__c WHERE SVMXA360__ObjectMapping__c =\''+inputRecord.configurationId+'\'';

        List<SVMXA360__CONF_WarrantyConfig__c> mappingUsedInWarranty = SvmxDatabase.query( Database.query(warrantyQuery) );
                
        if(mappingUsedInWarranty.size() > 0) {
            whereUsedInfoList.add(getWhereUsedMappingInWarranty(mappingUsedInWarranty));
        }  

        String depotQuery = 'SELECT Id, Name, SVMXA360__ObjectMapping__c, SVMXA360__ObjectMapping__r.Name, SVMXA360__ObjectMapping__r.SVMXA360__DeveloperName__c FROM SVMXA360__CONF_DepotFinderRule__c WHERE SVMXA360__ObjectMapping__c =\''+inputRecord.configurationId+'\'';
        List<SVMXA360__CONF_DepotFinderRule__c> mappingUsedInDepot = SvmxDatabase.query( Database.query( depotQuery ) );

        if(mappingUsedInDepot.size() > 0) { 
            whereUsedInfoList.add(getWhereUsedMappingInDepot(mappingUsedInDepot));
        } 

        Set<SVMXA360__CONF_PSCConfiguration__c> pscTemplates = getMappingsOfPSC(inputRecord.configDeveloperName);

        if(PSCTemplates.size() > 0) { 
            whereUsedInfoList.add(getWhereUsedMappingInPSC(pscTemplates));
        }

        whereUsedInfoList.addAll(getWhereUsedMappingInTransaction(inputRecord));

        return whereUsedInfoList;
    }

    public Adm.WhereUsedInfo getWhereUsedMappingInWarranty(List<SVMXA360__CONF_WarrantyConfig__c> mappingUsedInWarranty) {
                
        Adm.WhereUsedInfo whereUsedInfoWarranty = new  Adm.WhereUsedInfo();
        
        whereUsedInfoWarranty.moduleNameValue = WARRANTY_MANAGEMENT;
        whereUsedInfoWarranty.subModuleNameValue = SETTINGS;
        whereUsedInfoWarranty.moduleName = System.Label.Label_Warranty_Management;
        whereUsedInfoWarranty.subModuleName = System.Label.Label_Settings;

        whereUsedInfoWarranty.configurationTemplates = new List<Adm.ConfigurationTemplate>();
        for(SVMXA360__CONF_WarrantyConfig__c warrantyTemplate : mappingUsedInWarranty) {

            Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
            config.configurationName = warrantyTemplate.SVMXA360__ObjectMapping__r.Name;
            config.configurationDeveloperName = warrantyTemplate.SVMXA360__ObjectMapping__r.SVMXA360__DeveloperName__c;
            config.configurationId = warrantyTemplate.SVMXA360__ObjectMapping__c;

            whereUsedInfoWarranty.configurationTemplates.add(config); 
        } 
        return whereUsedInfoWarranty;

    }

    public Adm.WhereUsedInfo getWhereUsedExpressionInHierarchy(List<SVMXA360__CONF_HierarchyConfigDetail__c> expressionUsedInHierarchy) {
                
        Adm.WhereUsedInfo whereUsedInfoHierarchy = new  Adm.WhereUsedInfo();
        
        whereUsedInfoHierarchy.moduleNameValue = ASSET;
        whereUsedInfoHierarchy.subModuleNameValue = ASSET_HIERARCHY;
        whereUsedInfoHierarchy.moduleName = System.Label.LabelAsset;
        whereUsedInfoHierarchy.subModuleName = System.Label.LabelAssetHierarchy;

        whereUsedInfoHierarchy.configurationTemplates = new List<Adm.ConfigurationTemplate>();
        Map<String, Adm.ConfigurationTemplate> configTemplateMap = new Map<String, Adm.ConfigurationTemplate>();
        for(SVMXA360__CONF_HierarchyConfigDetail__c hierarchyTemplate : expressionUsedInHierarchy) {
            if(!configTemplateMap.containsKey(hierarchyTemplate.SVMXA360__HierarchyConfigId__c)) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = hierarchyTemplate.SVMXA360__HierarchyConfigId__r.Name;
                config.configurationDeveloperName = hierarchyTemplate.SVMXA360__HierarchyConfigId__r.SVMXA360__DeveloperName__c;
                config.configurationId = hierarchyTemplate.SVMXA360__HierarchyConfigId__c;
                configTemplateMap.put(hierarchyTemplate.SVMXA360__HierarchyConfigId__c, config);
            }
        } 
        whereUsedInfoHierarchy.configurationTemplates.addAll(configTemplateMap.values()); 
        return whereUsedInfoHierarchy;

    }

    public Adm.WhereUsedInfo getWhereUsedExpressionInTimeline(List<SVMXA360__CONF_TimelineConfigDetail__c> expressionUsedInTimeline) {
                
        Adm.WhereUsedInfo whereUsedInfoTimeline = new  Adm.WhereUsedInfo();
        
        whereUsedInfoTimeline.moduleNameValue = ASSET;
        whereUsedInfoTimeline.subModuleNameValue = ASSET_TIMELINE;
        whereUsedInfoTimeline.moduleName = System.Label.LabelAsset;
        whereUsedInfoTimeline.subModuleName = System.Label.LabelAssetTimeline;

        whereUsedInfoTimeline.configurationTemplates = new List<Adm.ConfigurationTemplate>();
        Map<String, Adm.ConfigurationTemplate> configTemplateMap = new Map<String, Adm.ConfigurationTemplate>();
        for (SVMXA360__CONF_TimelineConfigDetail__c timelineTemplate : expressionUsedInTimeline) {
            if(!configTemplateMap.containsKey(timelineTemplate.SVMXA360__TimelineConfigId__c)) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = timelineTemplate.SVMXA360__TimelineConfigId__r.Name;
                config.configurationDeveloperName = timelineTemplate.SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c;
                config.configurationId = timelineTemplate.SVMXA360__TimelineConfigId__c;
                configTemplateMap.put(timelineTemplate.SVMXA360__TimelineConfigId__c, config);
            }    
        }
        whereUsedInfoTimeline.configurationTemplates.addAll(configTemplateMap.values()); 
        return whereUsedInfoTimeline;

    }

    public Adm.WhereUsedInfo getWhereUsedMappingInDepot(List<SVMXA360__CONF_DepotFinderRule__c> mappingUsedInDepot) {

        Adm.WhereUsedInfo whereUsedInfoDepot = new  Adm.WhereUsedInfo();
        
        whereUsedInfoDepot.moduleNameValue = DEPOT;
        whereUsedInfoDepot.subModuleNameValue = SETTINGS;
        whereUsedInfoDepot.moduleName = System.Label.Title_Depot;
        whereUsedInfoDepot.subModuleName = System.Label.Label_Settings;

        whereUsedInfoDepot.configurationTemplates = new List<Adm.ConfigurationTemplate>();
        for(SVMXA360__CONF_DepotFinderRule__c depotTemplate : mappingUsedInDepot) {

            Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
            config.configurationName = depotTemplate.SVMXA360__ObjectMapping__r.Name;
            config.configurationDeveloperName = depotTemplate.SVMXA360__ObjectMapping__r.SVMXA360__DeveloperName__c;
            config.configurationId = depotTemplate.SVMXA360__ObjectMapping__c;

            whereUsedInfoDepot.configurationTemplates.add(config); 
        }
        return whereUsedInfoDepot;
    }

    public Adm.WhereUsedInfo getWhereUsedMappingInPSC(Set<SVMXA360__CONF_PSCConfiguration__c> pscTemplates) {

        Adm.WhereUsedInfo whereUsedInfoPSC = new  Adm.WhereUsedInfo();

        whereUsedInfoPSC.moduleNameValue = PRODUCT_SERVICE_CAMPAIGNS;
        whereUsedInfoPSC.subModuleNameValue = CONFIGURATION_TEMPLATES;
        whereUsedInfoPSC.moduleName =  System.Label.Label_Product_Service_Campaigns;
        whereUsedInfoPSC.subModuleName = System.Label.Label_Configuration_Templates;

        whereUsedInfoPSC.configurationTemplates = new List<Adm.ConfigurationTemplate>();
        for(SVMXA360__CONF_PSCConfiguration__c pscTemplate : pscTemplates) {
        
            Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
            config.configurationName = pscTemplate.Name;
            config.configurationDeveloperName = pscTemplate.SVMXA360__DeveloperName__c;
            config.configurationId = pscTemplate.Id;

            whereUsedInfoPSC.configurationTemplates.add(config); 
        }
        return whereUsedInfoPSC;
    }

    public List<Adm.WhereUsedInfo> getWhereUsedMappingInTransaction(Adm.WhereUsedInputRecord inputRecord) {

        List<Adm.WhereUsedInfo> whereUsedInfoList = new List<Adm.WhereUsedInfo>();

        String layoutQuery = 'SELECT '+String.join( layoutQueryFields, ',')+' FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__FieldMapping__c =\''+inputRecord.configurationId+'\' OR SVMXA360__ValueMapping__c =\'' + +inputRecord.configurationId+'\'';                                                                                     
        List<SVMXA360__CONF_Layout__c> mapUsedInTrasactionHeaderList = SvmxDatabase.query( Database.query( layoutQuery ) );
                
        String relatedSectionQuery = 'SELECT '+String.join( relatedSectionQueryFields, ',')+' FROM SVMXA360__CONF_LayoutRelatedSection__c WHERE SVMXA360__FieldMapping__c =\''+inputRecord.configurationId+'\' OR SVMXA360__ValueMapping__c =\'' + +inputRecord.configurationId+'\'';                                                                                     
        List<SVMXA360__CONF_LayoutRelatedSection__c> mapUsedInTrasactionChildsList = SvmxDatabase.query( Database.query( relatedSectionQuery ) );

        String layoutElementQuery = 'SELECT '+String.join( layoutElementQueryFields, ',')+' FROM SVMXA360__CONF_LayoutElement__c '; 
        String whereClause = 'WHERE SVMXA360__FormFillMappingId__c =\''+inputRecord.configurationId+'\' AND (SVMXA360__LayoutSection__c != NULL OR SVMXA360__LayoutRelatedSection__c != NULL)';  
        layoutElementQuery += whereClause;
        
        String exprBasedMappingQuery = 'SELECT '+String.join( exprBasedMappingFields, ',')+' FROM SVMXA360__CONF_ExpressionBasedMappingRow__c WHERE SVMXA360__ObjectMappingId__c =\''+inputRecord.configurationId+'\''; 
        List<SVMXA360__CONF_ExpressionBasedMappingRow__c> exprBasedMappingList = SvmxDatabase.query( Database.query( exprBasedMappingQuery ) );

        List<SVMXA360__CONF_LayoutElement__c> mapUsedInFormfillList = SvmxDatabase.query( Database.query( layoutElementQuery ) );

        List<SVMXA360__CONF_LayoutElement__c> mapUsedInScreenFormfillList = new List<SVMXA360__CONF_LayoutElement__c>();
        List<SVMXA360__CONF_LayoutElement__c> mapUsedInTransactionFormfillList = new List<SVMXA360__CONF_LayoutElement__c>();

        List<SVMXA360__CONF_ExpressionBasedMappingRow__c> transactionExprBasedMappingList = new List<SVMXA360__CONF_ExpressionBasedMappingRow__c>();
        List<SVMXA360__CONF_ExpressionBasedMappingRow__c> screenExprBasedMappingList = new List<SVMXA360__CONF_ExpressionBasedMappingRow__c>();

        ExpressionBasedMappingForTransaction exprBasedMappingDetails = new ExpressionBasedMappingForTransaction();
        if (exprBasedMappingList.size() > 0) {
            exprBasedMappingDetails = populateExpressionBasedMappingForTransaction(exprBasedMappingList);
        }

        for(SVMXA360__CONF_LayoutElement__c element : mapUsedInFormfillList){
            String configScreenType = '';
            if (element.SVMXA360__LayoutSection__r.SVMXA360__Layout__c != null) {
                configScreenType = element.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c;
            } else if (element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c != null) {
                configScreenType = element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c;
            }
            if(configScreenType == '' || configScreenType == SCREEN) {
                mapUsedInScreenFormfillList.add(element);
            } else if (configScreenType == TRANSACTION_TYPE) {
                mapUsedInTransactionFormfillList.add(element);
            }
        }

        if(mapUsedInTrasactionHeaderList.size() > 0 || mapUsedInTrasactionChildsList.size() > 0 || mapUsedInTransactionFormfillList.size() > 0 || 
            (exprBasedMappingDetails.transactionExprBasedMappingList != NULL && exprBasedMappingDetails.transactionExprBasedMappingList.size() > 0)) { 
            Adm.WhereUsedTransaction  whereUsedTrans = new Adm.WhereUsedTransaction();
            whereUsedTrans.transactionList = mapUsedInTrasactionHeaderList;
            whereUsedTrans.relatedSectionList = mapUsedInTrasactionChildsList;
            whereUsedTrans.layoutElementList = mapUsedInTransactionFormfillList;
            whereUsedTrans.exprBasedMappingList = exprBasedMappingDetails.transactionExprBasedMappingList;
            whereUsedTrans.screenType = TRANSACTION_TYPE;
            whereUsedTrans.moduleType = MAPPING;
            whereUsedTrans.configType = inputRecord.configType;
            whereUsedInfoList.add(createWhereUserWrapperForTransactions(whereUsedTrans));
        }
        if(mapUsedInScreenFormfillList.size() > 0 || (exprBasedMappingDetails.screenExprBasedMappingList != NULL && exprBasedMappingDetails.screenExprBasedMappingList.size() > 0)) {
            Adm.WhereUsedTransaction  whereUsedTrans = new Adm.WhereUsedTransaction();
            whereUsedTrans.layoutElementList = mapUsedInScreenFormfillList;
            whereUsedTrans.screenType = SCREEN;
            whereUsedTrans.moduleType = MAPPING;
            whereUsedTrans.exprBasedMappingList = exprBasedMappingDetails.screenExprBasedMappingList;
            whereUsedInfoList.add(createWhereUserWrapperForTransactions(whereUsedTrans));
        }
        return whereUsedInfoList;
    }

    /**
     * This method is used to create where used wrapper for Transactions.
     */
    public Adm.WhereUsedInfo createWhereUserWrapperForTransactions(Adm.WhereUsedTransaction  whereUsedTrans) {
         
        Adm.WhereUsedInfo whereUsedInfo = new  Adm.WhereUsedInfo ();
        whereUsedInfo.moduleNameValue = SERVICE_PROCESS_MANAGER;
        whereUsedInfo.moduleName = System.Label.Label_Service_Process_Manager;
        if(whereUsedTrans.screenType == SCREEN) {
            whereUsedInfo.subModuleNameValue = SCREEN;
            whereUsedInfo.subModuleName = System.Label.Label_Screen;
        } else if (whereUsedTrans.screenType == TRANSACTION_TYPE) {
            whereUsedInfo.subModuleNameValue = TRANSACTION_TYPE;
            whereUsedInfo.subModuleName = System.Label.Label_StepTypeTransaction;
        }

        Map<String, Adm.ConfigurationTemplate> transactionConfigurations = new Map<String, Adm.ConfigurationTemplate>();
        if( (whereUsedTrans.transactionList != null && whereUsedTrans.transactionList.size() > 0) ||
            (whereUsedTrans.sectionList != null && whereUsedTrans.sectionList.size() > 0))  {
            transactionConfigurations = createWhereUserWrapperForHeader(whereUsedTrans,transactionConfigurations);
        }
        
        if( whereUsedTrans.relatedSectionList != null &&  whereUsedTrans.relatedSectionList.size() > 0)  {
            transactionConfigurations = createWhereUserWrapperForChild(whereUsedTrans,transactionConfigurations);
        }    

        if( whereUsedTrans.layoutElementList != null && whereUsedTrans.layoutElementList.size() > 0)  {
            transactionConfigurations = createWhereUserWrapperForElement(whereUsedTrans,transactionConfigurations);
        } 
        
        if( whereUsedTrans.exprBasedMappingList != null && whereUsedTrans.exprBasedMappingList.size() > 0)  {
            transactionConfigurations = createWhereUserWrapperForExprBasedMapping(whereUsedTrans,transactionConfigurations);
        }
        whereUsedInfo.configurationTemplates = new List<Adm.ConfigurationTemplate>();
        whereUsedInfo.configurationTemplates.addAll(transactionConfigurations.values());
        return whereUsedInfo;
    } 

    public Map<String, Adm.ConfigurationTemplate> createWhereUserWrapperForHeader(Adm.WhereUsedTransaction  whereUsedTrans, Map<String, Adm.ConfigurationTemplate> transactionConfigurations) {

        if(whereUsedTrans.transactionList != NULL && whereUsedTrans.transactionList.size() > 0) {
            for(SVMXA360__CONF_Layout__c layout : whereUsedTrans.transactionList) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                config.configurationName = layout.Name;
                config.configurationDeveloperName = layout.SVMXA360__DeveloperName__c;
                config.configurationId = layout.Id;

                if(layout.SVMXA360__LayoutSections__r != null && layout.SVMXA360__LayoutSections__r.size() > 0) {
                    SVMXA360__CONF_LayoutSection__c headerSection = layout.SVMXA360__LayoutSections__r.get(0);
                
                    Adm.SectionTemplate section = new Adm.SectionTemplate();
                    section.sectionName = headerSection.Name;
                    if (whereUsedTrans.moduleType == MAPPING) {
                        section.sectionType = System.Label.Label_WhereUsedHeaderMapping;
                    } else if (whereUsedTrans.moduleType == EXPRESSION) {
                        section.sectionType = System.Label.Label_WhereUsedHeaderSection + System.Label.Label_WhereUsedQualifyingCriteria;
                    } else {
                        section.sectionType = System.Label.Label_WhereUsedHeaderSection;
                    }
                    if (layout.SVMXA360__FieldMapping__c != NULL && whereUsedTrans.configType == 'Field Mapping') { 
                        section.fieldMapping = layout.SVMXA360__FieldMapping__c;
                    } else if (layout.SVMXA360__ValueMapping__c != NULL && whereUsedTrans.configType == 'Value Mapping') {
                        section.valueMapping = layout.SVMXA360__ValueMapping__c;
                    }
                    transactionConfigurations = createConfigurationTemplate(config, section, transactionConfigurations);

                }
            }
        }

        if(whereUsedTrans.sectionList != NULL && whereUsedTrans.sectionList.size() > 0) {
            for(SVMXA360__CONF_LayoutSection__c layoutSection : whereUsedTrans.sectionList) {
                if(layoutSection.SVMXA360__VisibilityCriteriaID__c != null) {

                    Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                    config.configurationName = layoutSection.SVMXA360__Layout__r.Name;
                    config.configurationDeveloperName = layoutSection.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
                    config.configurationId = layoutSection.SVMXA360__Layout__c;
                
                    Adm.SectionTemplate section = new Adm.SectionTemplate();
                    section.sectionName = layoutSection.Name;
                    section.sectionType = System.Label.Label_WhereUsedHeaderSection + System.Label.Label_WhereUsedDisplayRules;
                    transactionConfigurations = createConfigurationTemplate(config, section, transactionConfigurations);

                }
            }
        }
        return transactionConfigurations;
    }    
    
    public Map<String, Adm.ConfigurationTemplate> createWhereUserWrapperForChild(Adm.WhereUsedTransaction  whereUsedTrans, Map<String, Adm.ConfigurationTemplate> transactionConfigurations) {

        for(SVMXA360__CONF_LayoutRelatedSection__c relatedSection : whereUsedTrans.relatedSectionList) {

            Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
            config.configurationName = relatedSection.SVMXA360__Layout__r.Name;
            config.configurationDeveloperName = relatedSection.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
            config.configurationId = relatedSection.SVMXA360__Layout__c;

            Adm.SectionTemplate section = new Adm.SectionTemplate();
            section.sectionName = relatedSection.Name;
            section.sectionType = System.Label.Label_WhereUsedChildSection;
            if (whereUsedTrans.moduleType == EXPRESSION && relatedSection.SVMXA360__QualifyingCriteria__c != NULL && whereUsedTrans.configType == ''){
                section.sectionType += System.Label.Label_WhereUsedQualifyingCriteria;
            }else if (relatedSection.SVMXA360__FieldMapping__c != NULL && whereUsedTrans.moduleType == MAPPING && whereUsedTrans.configType == 'Field Mapping') { 
                section.fieldMapping = relatedSection.SVMXA360__FieldMapping__c;
                section.sectionType += System.Label.Label_WhereUsedFieldMapping;
            } else if (relatedSection.SVMXA360__ValueMapping__c != NULL && whereUsedTrans.moduleType == MAPPING && whereUsedTrans.configType == 'Value Mapping') {
                section.valueMapping = relatedSection.SVMXA360__ValueMapping__c;
                section.sectionType += System.Label.Label_WhereUsedValueMapping;
            } else if (relatedSection.SVMXA360__VisibilityCriteriaID__c != NULL && whereUsedTrans.moduleType == EXPRESSION && whereUsedTrans.configType == 'VISIBILITY-RULE-CRITERIA') {
                section.sectionType += System.Label.Label_WhereUsedDisplayRules;
            }
            transactionConfigurations = createConfigurationTemplate(config, section, transactionConfigurations);
        }

        return transactionConfigurations;
    } 

    public Map<String, Adm.ConfigurationTemplate> createWhereUserWrapperForElement(Adm.WhereUsedTransaction  whereUsedTrans, Map<String, Adm.ConfigurationTemplate> transactionConfigurations) {
        Set<String> sectionIds = new Set<String>();
            for(SVMXA360__CONF_LayoutElement__c element : whereUsedTrans.layoutElementList) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                if (element.SVMXA360__LayoutSection__r.SVMXA360__Layout__c != null) {
                    config.configurationId = element.SVMXA360__LayoutSection__r.SVMXA360__Layout__c;
                    config.configurationDeveloperName = element.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
                    config.configurationName = element.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.Name;
                } else if (element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c != null) {
                    config.configurationId = element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c;
                    config.configurationDeveloperName = element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
                    config.configurationName = element.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.Name;
                }

                Adm.SectionTemplate section = new Adm.SectionTemplate();
                String sectionId = '';
                if (element.SVMXA360__LayoutSection__c != null) {
                    section.sectionType = System.Label.Label_WhereUsedHeaderSection;
                    section.sectionName = element.SVMXA360__LayoutSection__r.Name;
                    sectionId = element.SVMXA360__LayoutSection__r.Id;
                } else if (element.SVMXA360__LayoutRelatedSection__c != null) {
                    section.sectionType = System.Label.Label_WhereUsedChildSection;
                    section.sectionName = element.SVMXA360__LayoutRelatedSection__r.Name;
                    sectionId = element.SVMXA360__LayoutRelatedSection__r.Id;
                }

                if(element.SVMXA360__FormFillMappingId__c != NULL && whereUsedTrans.moduleType == MAPPING) {
                    section.formFillMapping = element.SVMXA360__FormFillMappingId__c;
                    section.sectionType = section.sectionType + System.Label.Label_WhereUsedAutoFillUp;
                }
                if(String.isNotBlank(sectionId) && !sectionIds.contains(sectionId)) {
                    transactionConfigurations = createConfigurationTemplate(config,section,transactionConfigurations);
                    sectionIds.add(sectionId);
                }
            }
        return transactionConfigurations;
    } 

    public Map<String, Adm.ConfigurationTemplate> createWhereUserWrapperForExprBasedMapping(Adm.WhereUsedTransaction  whereUsedTrans, Map<String, Adm.ConfigurationTemplate> transactionConfigurations) {
        Set<String> sectionIds = new Set<String>();
            for(SVMXA360__CONF_ExpressionBasedMappingRow__c element : whereUsedTrans.exprBasedMappingList) {
                Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
                if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__c != NULL) {
                    config.configurationId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__c;
                    config.configurationDeveloperName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
                    config.configurationName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.Name;
                } else if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c != NULL) {
                        config.configurationId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c;
                        config.configurationDeveloperName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.SVMXA360__DeveloperName__c;
                        config.configurationName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.Name;
                } else if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__c != NULL &&
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__c != NULL) {
                        config.configurationId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__c;
                        config.configurationDeveloperName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
                        config.configurationName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.Name;
                } else if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__c != NULL &&
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c != NULL) {
                        config.configurationId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c;
                        config.configurationDeveloperName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__DeveloperName__c;
                        config.configurationName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.Name;
                }

                Adm.SectionTemplate section = new Adm.SectionTemplate();
                String sectionId = '';

                if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__c != NULL) {
                        section.sectionType = System.Label.Label_WhereUsedChildSection + System.Label.Label_WhereUsedConditionalValueMapping;
                        section.sectionName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.Name;
                        sectionId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__c;
                } else if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c != NULL) {
                        section.sectionType = System.Label.Label_WhereUsedConditionalDefaultMapping;
                        sectionId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c;
                } else if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__c != NULL) {
                        section.sectionType = System.Label.Label_WhereUsedHeaderSection + System.Label.Label_WhereUsedConditionalAutoFill;
                        section.sectionName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.Name;
                        sectionId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__c;
                } else if (element.SVMXA360__ExpressionBasedMapping__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__c != NULL) {
                        section.sectionType = System.Label.Label_WhereUsedChildSection + System.Label.Label_WhereUsedConditionalAutoFill;
                        section.sectionName = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.Name;
                        sectionId = element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__c;
                }
                if(String.isNotBlank(sectionId) && !sectionIds.contains(sectionId)) {
                    transactionConfigurations = createConfigurationTemplate(config,section,transactionConfigurations);
                    sectionIds.add(sectionId);
                }
            }
        return transactionConfigurations;
    } 

    public Map<String, Adm.ConfigurationTemplate>  createConfigurationTemplate(Adm.ConfigurationTemplate configTemplate, Adm.SectionTemplate sectionTemplate, Map<String, Adm.ConfigurationTemplate> configTemplateMap) {
        
        if(configTemplateMap.containsKey(configTemplate.configurationId)) {
            if (sectionTemplate != null) {
                Adm.SectionTemplate section = new Adm.SectionTemplate();
                section.sectionType = sectionTemplate.sectionType;
                section.sectionName = sectionTemplate.sectionName;
                section.fieldMapping = sectionTemplate.fieldMapping;
                section.valueMapping = sectionTemplate.valueMapping;
                section.formFillMapping = sectionTemplate.formFillMapping;
                configTemplateMap.get(configTemplate.configurationId).sectionTemplates.add(section);
            }
        } else {
            Adm.ConfigurationTemplate config = new Adm.ConfigurationTemplate();
            config.configurationName = configTemplate.configurationName;
            config.configurationDeveloperName = configTemplate.configurationDeveloperName;
            config.configurationId = configTemplate.configurationId;
            config.configurationObject = configTemplate.configurationObject;

            if (sectionTemplate != null) {
                Adm.SectionTemplate section = new Adm.SectionTemplate();
                section.sectionType = sectionTemplate.sectionType;
                section.sectionName = sectionTemplate.sectionName;
                section.fieldMapping = sectionTemplate.fieldMapping;
                section.valueMapping = sectionTemplate.valueMapping;
                section.formFillMapping = sectionTemplate.formFillMapping;

                config.sectionTemplates = new List<Adm.SectionTemplate>{section};
            } else {
                config.sectionTemplates = new List<Adm.SectionTemplate>();
            }
            configTemplateMap.put(configTemplate.configurationId, config);
        }

        return configTemplateMap;
    }

    public Set<SVMXA360__CONF_PSCConfiguration__c>  getMappingsOfPSC(String mappingDeveloperName) {
        
        Set<SVMXA360__CONF_PSCConfiguration__c>  pscConfigurations = new Set<SVMXA360__CONF_PSCConfiguration__c>();
        List<SVMXA360__CONF_PSCConfiguration__c> pscList = SvmxDatabase.query( Database.query('SELECT Id,Name,SVMXA360__DeveloperName__c,SVMXA360__PSCMappingJSON__c FROM SVMXA360__CONF_PSCConfiguration__c') );
        for(SVMXA360__CONF_PSCConfiguration__c psc : pscList) {
            if(psc.SVMXA360__PSCMappingJSON__c != NULL) {
                List<Adm.PscMappingConfiguration> mappingConfigurationList = (List<Adm.PscMappingConfiguration>) JSON.deserializeStrict(psc.SVMXA360__PSCMappingJSON__c, List<Adm.PscMappingConfiguration>.class);
                
                for(Adm.PscMappingConfiguration mapping: mappingConfigurationList) {
                   	if(mapping.targetMappingId == mappingDeveloperName) {
                        pscConfigurations.add(psc);
                        break;
                    }
                }   
            }
        }
        return pscConfigurations;
    }

    public ExpressionBasedMappingForTransaction populateExpressionBasedMappingForTransaction(List<SVMXA360__CONF_ExpressionBasedMappingRow__c> exprBasedMappingList) {
        
        ExpressionBasedMappingForTransaction exprBasedMapping = new ExpressionBasedMappingForTransaction();
        exprBasedMapping.transactionExprBasedMappingList =  new List<SVMXA360__CONF_ExpressionBasedMappingRow__c>();
        exprBasedMapping.screenExprBasedMappingList =  new List<SVMXA360__CONF_ExpressionBasedMappingRow__c>();
        for(SVMXA360__CONF_ExpressionBasedMappingRow__c element : exprBasedMappingList){
            if (element.SVMXA360__ExpressionBasedMapping__c != NULL) {
                if (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__c != NULL &&
                    (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == '' ||
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == SCREEN)) {
                    exprBasedMapping.screenExprBasedMappingList.add(element);
                } else if (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__c != NULL && 
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionChild__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == TRANSACTION_TYPE) {
                    exprBasedMapping.transactionExprBasedMappingList.add(element);
                }

                if (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c != NULL && 
                    (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.SVMXA360__ScreenType__c == '' ||
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.SVMXA360__ScreenType__c == SCREEN)) {
                    exprBasedMapping.screenExprBasedMappingList.add(element);
                } else if (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__r.SVMXA360__ScreenType__c == TRANSACTION_TYPE) {
                    exprBasedMapping.transactionExprBasedMappingList.add(element);
                }

                if (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__c != NULL &&
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__c != NULL &&
                    (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == '' ||
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == SCREEN)) {
                    exprBasedMapping.screenExprBasedMappingList.add(element);
                } else if(element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == TRANSACTION_TYPE) {
                    exprBasedMapping.transactionExprBasedMappingList.add(element);
                }

                if (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__c != NULL &&
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c != NULL &&
                    (element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == '' ||
                    element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == SCREEN)) {
                    exprBasedMapping.screenExprBasedMappingList.add(element);
                } else if(element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__c != NULL && 
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__c != NULL &&
                        element.SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionElement__r.SVMXA360__LayoutRelatedSection__r.SVMXA360__Layout__r.SVMXA360__ScreenType__c == TRANSACTION_TYPE) {
                    exprBasedMapping.transactionExprBasedMappingList.add(element);
                }
            }

        }
        return exprBasedMapping;
    }
}