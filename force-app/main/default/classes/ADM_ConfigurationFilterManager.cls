/******************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve expression informations from Salesforce Org. 
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna Nagapudi      	02 Aug 2020     Created.
 *****************************************************************************************************/
public with sharing class ADM_ConfigurationFilterManager{

    ADM_ExpressionHandler expressionHandler = new ADM_ExpressionHandler();
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_ConfigurationFilterManager instance;
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private ADM_ConfigurationFilterManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_ConfigurationFilterManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'ADM_ConfigurationFilterManager.getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new ADM_ConfigurationFilterManager();
                System.debug( LoggingLevel.INFO, 'ADM_ConfigurationFilterManager.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'ADM_ConfigurationFilterManager.getInstance() - exit' );
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all configuration filters.
     */
    public List<Adm.ConfigurationFilter> getAllConfigurationFilters(String objectAPIName) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - enter' );
        
        List<Adm.ConfigurationFilter> configurationFilters = new List<Adm.ConfigurationFilter>();
        
        try {

            // Retrieve configuration filters
            List<SVMXA360__CONF_ConfigurationFilter__c> configurationFilterList = new List<SVMXA360__CONF_ConfigurationFilter__c>();

            if( String.IsBlank(objectAPIName) ) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                configurationFilterList =  SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__FilterCriteriaId__c FROM SVMXA360__CONF_ConfigurationFilter__c]);
            } else {
                /* sfge-disable-next-line ApexFlsViolationRule */
                configurationFilterList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__FilterCriteriaId__c FROM SVMXA360__CONF_ConfigurationFilter__c WHERE SVMXA360__ObjectAPIName__c =: objectAPIName]);
            }
            
            if( configurationFilterList.size() > 0 ) {
                
                // Create configuration filter wrapper for each configuration filter retrieved.
                for( SVMXA360__CONF_ConfigurationFilter__c configurationFilterRecord : configurationFilterList ) {
                    configurationFilters.add( createConfigurationFilterWrapper( configurationFilterRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() : Retrieved all configuration filters');
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationFilters() : Failed to retrieve configuration filters. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - exit; configurationFilterDetails.size()= ' + configurationFilters.size() );
        }
        
        return configurationFilters;
    } 

    /**
     * Private method to create configuration filter wrapper from configuration filter record.
     */
    private Adm.ConfigurationFilter createConfigurationFilterWrapper( SVMXA360__CONF_ConfigurationFilter__c configurationFilterRec ) {
        
        Adm.ConfigurationFilter configurationFilterWrapper = new Adm.ConfigurationFilter();
        
        configurationFilterWrapper.id = configurationFilterRec.Id;
        configurationFilterWrapper.name = configurationFilterRec.Name;
        configurationFilterWrapper.objectAPIName = configurationFilterRec.SVMXA360__ObjectAPIName__c;
        configurationFilterWrapper.developerName = configurationFilterRec.SVMXA360__DeveloperName__c;
        configurationFilterWrapper.filterCriteriaId = configurationFilterRec.SVMXA360__FilterCriteriaId__c;

        return configurationFilterWrapper;
    }

     /**
     * This method is used to retrieve all records belong to configuration filter.
     */
    public List<Adm.PageLayout> getFilteredConfigurations(Adm.ConfigFilterInputRecord configFilterInfo ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() - enter' );
        
        List<Adm.PageLayout> configurationFilterDetails = new List<Adm.PageLayout>();
        
        try {

            if( String.IsBlank(configFilterInfo.id)) {
                System.debug( LoggingLevel.ERROR, 'getFilteredConfigurations() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve configuration filter
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_ConfigurationFilter__c> configurationFilterList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__FilterCriteriaId__c, SVMXA360__FilterTags__c, SVMXA360__Columns__c FROM SVMXA360__CONF_ConfigurationFilter__c WHERE Id =: configFilterInfo.id] );
            

            if(configurationFilterList.size() > 0 && configurationFilterList[0].SVMXA360__ObjectAPIName__c != null) {
                List<SObject> records = new List<SObject>();
                if(configurationFilterList[0].SVMXA360__ObjectAPIName__c == 'SVMXA360__CONF_Layout__c') {
                    if(String.isBlank(configFilterInfo.screenType) || configFilterInfo.screenType.equalsIgnoreCase('Screen')){
                        List<String> screenTypeValues = new List<String> {'', 'Screen'};
                        /* sfge-disable-next-line ApexFlsViolationRule */
                        records = SvmxDatabase.query( [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__ScreenType__c IN : screenTypeValues ORDER BY Name]);
                    } else {
                        /* sfge-disable-next-line ApexFlsViolationRule */
                        records = SvmxDatabase.query( [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__ScreenType__c =: configFilterInfo.screenType ORDER BY Name]);
                    }
                }
                else {
                    /* sfge-disable-next-line ApexFlsViolationRule */
                    records = SvmxDatabase.query( 'SELECT Id FROM ' + configurationFilterList[0].SVMXA360__ObjectAPIName__c );
                }

                List<SObject> filteredRecords = new List<SObject>();
                Set<Id> recordIdSet = new Set<Id>();
                for (SObject record : records) {
                    recordIdSet.add(record.id);
                }
                if(configurationFilterList[0].SVMXA360__FilterCriteriaId__c != null && recordIdSet.size() > 0) {
                    filteredRecords = expressionHandler.matchRecordsForExpression(recordIdSet, configurationFilterList[0].SVMXA360__FilterCriteriaId__c);
                }
                List<String> entityIds = new List<String>();

                for(SObject record : filteredRecords) {
                    entityIds.add(record.id);
                }
                List<String> layoutIds = new List<String>();
                if(entityIds.size() > 0 && String.isNotBlank(configurationFilterList[0].SVMXA360__FilterTags__c)) {
                    List<String> filteredEntityIds = applyTagsFilter(entityIds, configurationFilterList[0].SVMXA360__FilterTags__c);  
                    configurationFilterDetails = ADM_PageLayoutManager.getInstance().getPageLayoutsWithDetails(filteredEntityIds);
                    layoutIds.addAll(filteredEntityIds); 
                } else {
                    configurationFilterDetails = ADM_PageLayoutManager.getInstance().getPageLayoutsWithDetails(entityIds);
                    layoutIds.addAll(entityIds); 
                }

                Map<String, List<String>> layoutTagsMap = new Map<String, List<String>>();
                layoutTagsMap = ADM_PageLayoutManager.getInstance().getSVMXTags (layoutIds) ;

                for(Adm.PageLayout layoutRecord  : configurationFilterDetails){
                    if (layoutTagsMap.containsKey(layoutRecord.Id)) {
                        layoutRecord.pageHeader.tags = layoutTagsMap.get(layoutRecord.Id);
                    }                            
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() : Retrieved all configuration filter details');
        }
       catch (SvmxSystem.SvmxNestedException e) {
            if(e.getMessage().equalsIgnoreCase(ErrorMessage.RECORD_NOT_EXISTS)) {
                return configurationFilterDetails;
            } else {
                throw e; 
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getFilteredConfigurations() : Failed to retrieve configuration filter details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() - exit; configurationFilterDetails.size()= ' + configurationFilterDetails.size() );
        }
        
        return configurationFilterDetails;
    } 

    /**
     * This method is used to retrieve all transaction filtered by tags .
     */
    private List<String> applyTagsFilter(List<Id> entityIdList, String configurationFilterTags) {
        
        System.debug( LoggingLevel.DEBUG, 'applyTagsFilter() - enter' );
        
        List<String> configurationIdsAfterTagsFilter = new List<String>();
        
        try {

            String objectName = entityIdList.get(0).getSObjectType().getDescribe().getName();
            List<String> tagNameList = configurationFilterTags.split('\\;');
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<SVMXA360__CONF_TagElement__c> tagElementList = SvmxDatabase.query([SELECT Id, name, SVMXA360__EntityId__c, SVMXA360__TagDefinition__r.name FROM SVMXA360__CONF_TagElement__c WHERE SVMXA360__EntityId__c IN: entityIdList AND SVMXA360__TagDefinition__r.name IN: tagNameList]);
            
            Set<String> entityIds = new Set<String>();
            for (SVMXA360__CONF_TagElement__c tagElement : tagElementList) {
                entityIds.add(tagElement.SVMXA360__EntityId__c);
            }
			configurationIdsAfterTagsFilter.addAll(entityIds);
            
            System.debug( LoggingLevel.DEBUG, 'applyTagsFilter() : Retrieved all configuration after tag filters' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'applyTagsFilter() : Failed to retrieve configuration filter details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'applyTagsFilter() - exit; configurationIdsAfterTagsFilter.size()= ' + configurationIdsAfterTagsFilter.size() );
        }
        
        return configurationIdsAfterTagsFilter;
    }
}