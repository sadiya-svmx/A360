/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve asset timeline data.
 *
 * @author Ryan Follmer
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ryan Follmer            10 December 2020  Created.
 * A360AM-107   Ryan Follmer            27 May 2021       Added support for SVMXA360__IsDefault__c
 * A360AM-592   Ryan Follmer            28 May 2021       Added support for SVMXA360__ShowMatchingOnLoad__c
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class AMGT_TimeLineManager {

    /**
     * Static variable to hold instance of this class.
     */
    private static AMGT_TimeLineManager instance = null;
    private static final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
    private static final COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();

    private static final List<String> eventFields = new List<String> {
        'Location', 'StartDateTime', 'EndDateTime', 'WhatId', 'What.Name', 'OwnerId', 'Owner.Name'
    };

    private static final List<String> taskFields = new List<String> {
        'ActivityDate', 'WhatId', 'What.Name', 'WhoId', 'Who.Name', 'TaskSubtype', 'Priority'
    };

    private static final String QUERYABLE_BY_BATCH = 'BATCHABLE';
    private static final String REQUIRES_SEPARATE_QUERIES = 'SEPARATE';
    private static final String typeSeperator = '^#SEP#^';

    /**
     * Private constructor to restrict multiple instance creation of this class.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private AMGT_TimeLineManager() {
    }

    /**
     * Static method to return instance of this class.
     */
    public static AMGT_TimeLineManager getInstance() {
        if( instance == null ) {
            instance = new AMGT_TimeLineManager();
        }
        
        return instance;
    }

    /**
     * This method is used to retrieve timeline data for the requested parent record and field. 
     */
    public Amgt.TimelineResponse getTimelineData( final Amgt.TimelineRequest request ) {
        
        System.debug( LoggingLevel.DEBUG, 'getTimelineData() - enter; request= ' + request );
        
        Amgt.TimelineResponse response = new Amgt.TimelineResponse();
        
        try {

            if( request == null 
                || String.isBlank( request.parentRecordId ) 
                || String.isBlank( request.fieldApiName ) 
                || request.startDate == null
                || request.endDate == null
            ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            // Retrieve field value and object API Name from sObject for the field defined in the request (TimelineRequest.fieldApiName)
            SourceRecordInfo sourceRecordInfo = getSourceRecordIdWithObjectName( String.escapeSingleQuotes(request.parentRecordId), String.escapeSingleQuotes(request.fieldApiName) );

            if ( sourceRecordInfo == null ) {
                System.debug( LoggingLevel.DEBUG, 'getTimelineData() - sourceRecordInfo is null; request= ' + request );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            // Retrieve CONF_TimelineConfig__c records that apply to the user's profile
            Map<String, SVMXA360__CONF_TimelineConfigDetail__c> configurations = request.isMobileRequest == true
                                                                                ? getTimelineConfigurationsForUser(request.objectApiNameList)
                                                                                : getTimelineConfigurationsForUser();

            // A360AM-112: if configurations are null or empty, use a default implementation
            if (configurations.isEmpty()) {

                // Retrieve CONF_TimelineConfig__c records that marked as the default configuration
                configurations = request.isMobileRequest == true
                                ? getDefaultTimelineConfigurationsForOrg(request.objectApiNameList)
                                : getDefaultTimelineConfigurationsForOrg();

                // When there are no configurations for the user AND there are no configurations defined as the "default", then use the fallback configuration.
                if (configurations.isEmpty()) {
                    configurations = request.isMobileRequest == true
                                    ? getFallbackAssetTimelineConfigurations(request.objectApiNameList)
                                    : getFallbackAssetTimelineConfigurations();
                }
            }

            // For each configuration object, get the metadata
            //  Map: String = configuration detail record id
            //  Map: ConfigurationWithObjectMetadata = class containing the Configuration Detail Record & Object Metadata
            Map<String, ConfigurationWithObjectMetadata> configurationsWithMetadata = getConfigurationsWithMetadata( configurations);

            List<ConfigurationWithObjectMetadata> assetMilestones = getAssetMilestones (configurations);

            // For configurations that have qualifying criteria, set the qualify criteria expression as a soql string if set on the configuration record.
            buildQualifyingCriteria( configurationsWithMetadata );
            buildQualifyingCriteria( assetMilestones );

            // For a configuration, determine the object relationship name based on the Object and Source Field Api Names
            setChildRelationshipNames(sourceRecordInfo, configurationsWithMetadata);

            /*
                Split out Configurations where the Object API Name is the same among configurations
                - Why?
                    When parsing the SOQL results, we have to correctly retrieve the Display Field, Start Ends, End Dates, etc based on the configuration record.
                    If we issue a single query for multiple configurations for the same object, there is no reasonable way to differentiate 1 object record from another.
                    In other words, once we invoke the SOQL query, we lose the ability to determine which configuration record matches an SObject record.
                - Outcome
                    We need to issue additional queries for those extra configurations and then merge the results.
            */ 
            Map<String, List<ConfigurationWithObjectMetadata>> splitConfigurations = splitOutObjectDuplicates(configurationsWithMetadata);

            List<ConfigurationMetadataWithQuery> queries = buildQueries(request, sourceRecordInfo, splitConfigurations);
            List<ConfigurationMetadataWithQuery> asseMilestoneQueries = buildAssetMilestoneQueries(request, sourceRecordInfo, assetMilestones);

            response = processQueries(sourceRecordInfo, queries, asseMilestoneQueries,assetMilestones, splitConfigurations);
            response.configDevloperName = configurations.values()[0].SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c; 
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getTimelineData() : Failed to retrieve Timeline Data. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTimelineData() - exit; result size = ' + response.timelineResults.size() );
        }
        
        return response;
    }

    private Amgt.TimelineResponse processQueries( 
        SourceRecordInfo sourceRecordInfo, 
        List<ConfigurationMetadataWithQuery> queries,
        List<ConfigurationMetadataWithQuery> assetMilestoneQueries,
        List<ConfigurationWithObjectMetadata> assetMilestoneMetadata,
        Map<String, List<ConfigurationWithObjectMetadata>> configurations) {
        Amgt.TimelineResponse response = new Amgt.TimelineResponse();
        Map<String, Amgt.TimelineTypeToShow> typesToShow = new Map<String, Amgt.TimelineTypeToShow>();
        if (queries != null && !queries.isEmpty()) {
            Integer queryCount = queries.size();
            List<ConfigurationWithObjectMetadata> canBeQueriedTogether = configurations.get(QUERYABLE_BY_BATCH);
            for (Integer queryIndex = 0; queryIndex < queryCount; queryIndex++) {
                ConfigurationMetadataWithQuery queryConfig = queries[queryIndex];
                List<SObject> sObjectList = SvmxDatabase.query( queryConfig.query );

                if (queryConfig.configuration == null) { // configuration is null for queries that can be batched together.
                   if (response.timelineResults == null) {
                        response.timelineResults = new List<Amgt.Timeline>();
                    }
                    Amgt.TimelineResponse resp = createTimelineDataResults(sourceRecordInfo, sObjectList, canBeQueriedTogether);
                    response.timelineResults.addAll( resp.timelineResults);
                    response.id = sourceRecordInfo.recordId;
                    response.displayName = resp.displayName;
                   
                } else {

                    Amgt.TimelineResponse additionalResp = createTimelineDataResults(sourceRecordInfo, sObjectList, new List<ConfigurationWithObjectMetadata> {queryConfig.configuration});
					boolean tobeAdded = false;
                    if (response.timelineResults == null) {
                        response.timelineResults = new List<Amgt.Timeline>();
                        tobeAdded = true;
                    }

                    // Perform Duplicate Check and Additional Records
                    if (additionalResp.timelineResults != null && !additionalResp.timelineResults.isEmpty()) {
                        Map<Id, Amgt.Timeline> timelineResultMap = getMapForTimelineResults(response.timelineResults);
                        for ( Amgt.Timeline additionalTimelineRecord : additionalResp.timelineResults ) {
                            response.timelineResults.add(additionalTimelineRecord);
                        }
                    }
                    response.id = sourceRecordInfo.recordId;
                    if (String.isNotBlank(additionalResp.displayName)) {
                        response.displayName = additionalResp.displayName;
                    }
                   
                }
            }
            Map<String, Amgt.TimelineTypeToShow> typesToShow1 = getTypesToShow(canBeQueriedTogether);
            for(String key: typesToShow1.keyset()){
                typesToShow.put(key,typesToShow1.get(key));
            }
            Map<String, Amgt.TimelineTypeToShow> typesToShow2 = getTypesToShow(configurations.get(REQUIRES_SEPARATE_QUERIES));
            for(String key: typesToShow2.keyset()){
                typesToShow.put(key,typesToShow2.get(key));
            }
        }
        if(assetMilestoneQueries != null && assetMilestoneQueries.size() >0) {
            
            for (ConfigurationMetadataWithQuery queryConfig : assetMilestoneQueries) {
                List<SObject> sObjectList = SvmxDatabase.query( queryConfig.query );
                Amgt.TimelineResponse milesStoneResponse = createAssetMilestoneTimelineResults(sourceRecordInfo, sObjectList, new List<ConfigurationWithObjectMetadata> {queryConfig.configuration});
                boolean tobeAdded = false;
                if (response.timelineResults == null) {
                    response.timelineResults = new List<Amgt.Timeline>();
                    tobeAdded = true;
                }

                // Perform Duplicate Check and Additional Records
                if (milesStoneResponse.timelineResults != null && !milesStoneResponse.timelineResults.isEmpty()) {
                    Map<Id, Amgt.Timeline> timelineResultMap = getMapForTimelineResults(response.timelineResults);
                    for ( Amgt.Timeline additionalTimelineRecord : milesStoneResponse.timelineResults ) {
                        response.timelineResults.add(additionalTimelineRecord);
                    }
                }
                response.id = sourceRecordInfo.recordId;
                if (String.isNotBlank(milesStoneResponse.displayName)) {
                    response.displayName = milesStoneResponse.displayName;
                }
            }
            Map<String, Amgt.TimelineTypeToShow> typesToShow1 = getTypesToShow(assetMilestoneMetadata);
            for(String key: typesToShow1.keyset()){
                typesToShow.put(key,typesToShow1.get(key));
            }
        }
        response.typesToShow = typesToShow;
        return response;
    }

	private Map<Id, Amgt.Timeline> getMapForTimelineResults(List<Amgt.Timeline> timelineResults){
        Map<Id, Amgt.Timeline> timelineMap = new Map<Id, Amgt.Timeline>();

        for ( Amgt.Timeline result : timelineResults ) {
            timelineMap.put(result.id, result);
        }

		return timelineMap;
	} 

    private Map<String, List<ConfigurationWithObjectMetadata>> splitOutObjectDuplicates( Map<String, ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        Set<String> objectApiNames = new Set<String>();

        List<ConfigurationWithObjectMetadata> canBeQueriedTogether = new List<ConfigurationWithObjectMetadata>();
        List<ConfigurationWithObjectMetadata> requiresAdditionalQueries = new List<ConfigurationWithObjectMetadata>();

        for ( ConfigurationWithObjectMetadata config : configurationsWithMetadata.values() ) {
            String objectName = config.metadata.apiName;

            if (objectApiNames.contains(objectName)) {
                requiresAdditionalQueries.add(config);
            } else {
                canBeQueriedTogether.add(config);
                objectApiNames.add(objectName);
            }
        }

        Map<String, List<ConfigurationWithObjectMetadata>> result = new Map<String, List<ConfigurationWithObjectMetadata>>();
        result.put(QUERYABLE_BY_BATCH, canBeQueriedTogether);
        result.put(REQUIRES_SEPARATE_QUERIES, requiresAdditionalQueries);

        return result;
    }


    private SourceRecordInfo getSourceRecordIdWithObjectName( String parentRecordId, String fieldApiName ) {
        SourceRecordInfo info;
        String recordId;

        Schema.DescribeSobjectResult parentObject = describeManager.getObjectDescribe(String.valueOf(Id.valueOf(parentRecordId).getSobjectType()));
        String parentObjectName = parentObject.getName();

        String parentRecordSoql = 'SELECT Id ';

        if (!fieldApiName.equalsIgnoreCase('Id')) {
            parentRecordSoql += ', ' + String.escapeSingleQuotes(fieldApiName);
        }
        parentRecordSoql += ' FROM ' + parentObjectName;
        parentRecordSoql += ' Where Id = \'' + parentRecordId + '\'';

        List<SObject> sObjectList = SvmxDatabase.query(parentRecordSoql);

        if( sObjectList != null && sObjectList.size() > 0 ) {
            recordId = (String) sObjectList[0].get(fieldApiName);

            if ( String.isBlank(recordId) ) {
                System.debug( LoggingLevel.DEBUG, 'getSourceRecordIdWithObjectName() - recordId is null; parentRecordId = ' + parentRecordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            info = new SourceRecordInfo();

            info.recordId = recordId;

            Common.EntityDefinition sourceObject = metadataManager.getFieldDefinitions( String.valueOf(Id.valueOf(recordId).getSobjectType()), true );

            info.objectApiName = sourceObject.apiName;

            Common.FieldDefinition nameField = getNameFieldDefinition(sourceObject);
            info.nameFieldApiName = nameField.apiName;
        }

        System.debug(LoggingLevel.DEBUG, 'getSourceRecordIdWithObjectName() - exit; info = ' + info);

        return info;
    }

    private Map<String, SVMXA360__CONF_TimelineConfigDetail__c> getTimelineConfigurationsForUser() {
        final String profile18 = UserInfo.getProfileId();
        final String profile15 = ((Id)profile18).to15();

        List<SVMXA360__CONF_TimelineConfigDetail__c> configurationList = SvmxDatabase.query(
            [
                SELECT Id, 
                    Name, 
                    SVMXA360__TimelineConfigId__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__DisplayFieldAPIName__c,
                    SVMXA360__StartDateFieldAPIName__c,
                    SVMXA360__EndDateFieldAPIName__c,
                    SVMXA360__BackgroundColor__c,
                    SVMXA360__IconName__c,
                    SVMXA360__QualifyingCriteria__c,
                    SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c,
                    SVMXA360__QualifyingCriteria__r.Name,
                    SVMXA360__Sequence__c, 
                    SVMXA360__SourceFieldAPIName__c,
                    SVMXA360__ShowMatchingOnLoad__c,
                    LastModifiedDate,
                    LastModifiedBy.Name,
                    SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c
                FROM SVMXA360__CONF_TimelineConfigDetail__c 
                WHERE SVMXA360__TimelineConfigId__c IN (
                    SELECT SVMXA360__TimelineConfigId__c 
                        FROM SVMXA360__CONF_TimelineConfigAccess__c
                        WHERE SVMXA360__ProfileId__c = :profile18
                        OR SVMXA360__ProfileId__c = :profile15
                )
                ORDER BY SVMXA360__Sequence__c
            ]);

        return new Map<String, SVMXA360__CONF_TimelineConfigDetail__c>(configurationList);
    }
    
    private Map<String, SVMXA360__CONF_TimelineConfigDetail__c> getTimelineConfigurationsForUser(List<String> objectApiNameList) {
        final String profile18 = UserInfo.getProfileId();
        final String profile15 = ((Id)profile18).to15();

        String objectApiNameClause = getObjectApiNameClause(objectApiNameList);
        
        if(!String.isEmpty(objectApiNameClause)){
            objectApiNameClause = ' AND ' + objectApiNameClause;
        }

        List<SVMXA360__CONF_TimelineConfigDetail__c> configurationList = (List<SVMXA360__CONF_TimelineConfigDetail__c>) SvmxDatabase.query(
            'SELECT Id,'+ 
                'Name, '+
                'SVMXA360__TimelineConfigId__c,'+
                'SVMXA360__ObjectAPIName__c,'+
                'SVMXA360__DisplayFieldAPIName__c,'+
                'SVMXA360__StartDateFieldAPIName__c,'+
                'SVMXA360__EndDateFieldAPIName__c,'+
                'SVMXA360__BackgroundColor__c,'+
                'SVMXA360__IconName__c,'+
                'SVMXA360__QualifyingCriteria__c,'+
                'SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c,'+
                'SVMXA360__QualifyingCriteria__r.Name,'+
                'SVMXA360__Sequence__c,'+
                'SVMXA360__SourceFieldAPIName__c,'+
                'SVMXA360__ShowMatchingOnLoad__c,'+
                'LastModifiedDate,'+
                'LastModifiedBy.Name,'+
                'SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c'+
            ' FROM SVMXA360__CONF_TimelineConfigDetail__c'+
            ' WHERE SVMXA360__TimelineConfigId__c IN ('+
                'SELECT SVMXA360__TimelineConfigId__c '+
                    ' FROM SVMXA360__CONF_TimelineConfigAccess__c'+
                    ' WHERE SVMXA360__ProfileId__c = \''+ profile18 +'\''+
                    ' OR SVMXA360__ProfileId__c = \''+ profile15 +'\''+
            ')'+
            objectApiNameClause +
            ' ORDER BY SVMXA360__Sequence__c'
        );

        return new Map<String, SVMXA360__CONF_TimelineConfigDetail__c>(configurationList);
    }

    private Map<String, SVMXA360__CONF_TimelineConfigDetail__c> getDefaultTimelineConfigurationsForOrg() {
        List<SVMXA360__CONF_TimelineConfigDetail__c> configurationList = SvmxDatabase.query(
            [
                SELECT Id, 
                    Name, 
                    SVMXA360__TimelineConfigId__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__DisplayFieldAPIName__c,
                    SVMXA360__StartDateFieldAPIName__c,
                    SVMXA360__EndDateFieldAPIName__c,
                    SVMXA360__BackgroundColor__c,
                    SVMXA360__IconName__c,
                    SVMXA360__QualifyingCriteria__c,
                    SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c,
                    SVMXA360__QualifyingCriteria__r.Name,
                    SVMXA360__Sequence__c, 
                    SVMXA360__SourceFieldAPIName__c,
                    SVMXA360__ShowMatchingOnLoad__c,
                    LastModifiedDate,
                    LastModifiedBy.Name,
                    SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c
                FROM SVMXA360__CONF_TimelineConfigDetail__c 
                WHERE SVMXA360__TimelineConfigId__r.SVMXA360__IsDefault__c = true
                ORDER BY SVMXA360__Sequence__c
            ]);

        return new Map<String, SVMXA360__CONF_TimelineConfigDetail__c>(configurationList);
    }

    private Map<String, SVMXA360__CONF_TimelineConfigDetail__c> getDefaultTimelineConfigurationsForOrg(List<String> objectApiNameList) {
        String objectApiNameClause = getObjectApiNameClause(objectApiNameList);
        
        if(!String.isEmpty(objectApiNameClause)){
            objectApiNameClause = ' AND ' + objectApiNameClause;
        }

        List<SVMXA360__CONF_TimelineConfigDetail__c> configurationList = SvmxDatabase.query(
            
            'SELECT Id,'+
                'Name,'+
                'SVMXA360__TimelineConfigId__c,'+
                'SVMXA360__ObjectAPIName__c,'+
                'SVMXA360__DisplayFieldAPIName__c,'+
                'SVMXA360__StartDateFieldAPIName__c,'+
                'SVMXA360__EndDateFieldAPIName__c,'+
                'SVMXA360__BackgroundColor__c,'+
                'SVMXA360__IconName__c,'+
                'SVMXA360__QualifyingCriteria__c,'+
                'SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c,'+
                'SVMXA360__QualifyingCriteria__r.Name,'+
                'SVMXA360__Sequence__c, '+
                'SVMXA360__SourceFieldAPIName__c,'+
                'SVMXA360__ShowMatchingOnLoad__c,'+
                'LastModifiedDate,'+
                'LastModifiedBy.Name,'+
                'SVMXA360__TimelineConfigId__r.SVMXA360__DeveloperName__c'+
            ' FROM SVMXA360__CONF_TimelineConfigDetail__c'+ 
            ' WHERE SVMXA360__TimelineConfigId__r.SVMXA360__IsDefault__c = true'+
            objectApiNameClause +
            ' ORDER BY SVMXA360__Sequence__c'
        );

        return new Map<String, SVMXA360__CONF_TimelineConfigDetail__c>(configurationList);
    }

    /**
    *  When a user retrieving timeline data does not have access to timeline configuration records,
    *   this method provides a default implementation.
    */
    private Map<String, SVMXA360__CONF_TimelineConfigDetail__c> getFallbackAssetTimelineConfigurations() {
        Map<String, SVMXA360__CONF_TimelineConfigDetail__c> configurations = new Map<String, SVMXA360__CONF_TimelineConfigDetail__c>();

        configurations.put('1', createConfigurationDetail('Case', 'AssetId', 'Subject', 'CreatedDate', null, 1, null, 'standard:case'));
        configurations.put('2', createConfigurationDetail('WorkOrder', 'AssetId', 'Subject', 'CreatedDate', null, 2, null, 'standard:work_order'));
        configurations.put('3', createConfigurationDetail('Task', 'WhatId', 'Subject', 'CreatedDate', null, 3, null, 'standard:task'));
        configurations.put('4', createConfigurationDetail('Event', 'WhatId', 'Subject', 'StartDateTime', null, 4, null, 'standard:event'));
        configurations.put('5', createConfigurationDetail('AssetWarranty', 'AssetId', 'WarrantyTerm.WarrantyTermName', 'StartDate', 'EndDate', 5, '#F8C471', 'standard:asset_warranty'));
        configurations.put('6', createConfigurationDetail('ContractLineItem', 'AssetId', 'ServiceContract.Name', 'StartDate', 'EndDate', 6, '#82E0AA', 'standard:contract_line_item'));
        configurations.put('7', createConfigurationDetail('Entitlement', 'AssetId', 'Name', 'StartDate', null, 7, '#85C1E9', 'standard:entitlement'));
        configurations.put('8', createConfigurationDetail('AssetDowntimePeriod', 'AssetId', 'DowntimeType', 'StartTime', 'EndTime', 8, '#A57EFF', 'standard:asset_downtime_period'));

        return configurations;
    }

    /**
    *  When a user retrieving timeline data does not have access to timeline configuration records,
    *   this method provides a default implementation.
    */
    private Map<String, SVMXA360__CONF_TimelineConfigDetail__c> getFallbackAssetTimelineConfigurations(List<String> objectApiNameList) {
        Map<String, SVMXA360__CONF_TimelineConfigDetail__c> configurations = new Map<String, SVMXA360__CONF_TimelineConfigDetail__c>();
        Integer configId = 1;
        Boolean allObjectsRequired = objectApiNameList == null || objectApiNameList.isEmpty();
        if(allObjectsRequired || objectApiNameList.contains('Case')){
            configurations.put(''+configId++, createConfigurationDetail('Case', 'AssetId', 'Subject', 'CreatedDate', null, 1, null, 'standard:case'));
        }
        if(allObjectsRequired || objectApiNameList.contains('WorkOrder')){
            configurations.put(''+configId++, createConfigurationDetail('WorkOrder', 'AssetId', 'Subject', 'CreatedDate', null, 2, null, 'standard:work_order'));
        }
        if(allObjectsRequired || objectApiNameList.contains('Task')){
            configurations.put(''+configId++, createConfigurationDetail('Task', 'WhatId', 'Subject', 'CreatedDate', null, 3, null, 'standard:task'));
        }
        if(allObjectsRequired || objectApiNameList.contains('Event')){
            configurations.put(''+configId++, createConfigurationDetail('Event', 'WhatId', 'Subject', 'StartDateTime', null, 4, null, 'standard:event'));
        }
        if(allObjectsRequired || objectApiNameList.contains('AssetWarranty')){
            configurations.put(''+configId++, createConfigurationDetail('AssetWarranty', 'AssetId', 'WarrantyTerm.WarrantyTermName', 'StartDate', 'EndDate', 5, '#F8C471', 'standard:asset_warranty'));
        }
        if(allObjectsRequired || objectApiNameList.contains('ContractLineItem')){  
            configurations.put(''+configId++, createConfigurationDetail('ContractLineItem', 'AssetId', 'ServiceContract.Name', 'StartDate', 'EndDate', 6, '#82E0AA', 'standard:contract_line_item'));
        }
        if(allObjectsRequired || objectApiNameList.contains('Entitlement')){
            configurations.put(''+configId++, createConfigurationDetail('Entitlement', 'AssetId', 'Name', 'StartDate', null, 7, '#85C1E9', 'standard:entitlement'));
        }
        if(allObjectsRequired || objectApiNameList.contains('AssetDowntimePeriod')){
            configurations.put(''+configId++, createConfigurationDetail('AssetDowntimePeriod', 'AssetId', 'DowntimeType', 'StartTime', 'EndTime', 8, '#A57EFF', 'standard:asset_downtime_period'));
        }

        return configurations;
    }

    private String getObjectApiNameClause(List<String> objectApiNameList){
        String objectApiNameClause = '';

        if(objectApiNameList != null && !objectApiNameList.isEmpty()){
            objectApiNameClause = 'SVMXA360__ObjectAPIName__c IN (';
            for(String objectApiName : objectApiNameList){
                objectApiNameClause += '\'' + String.escapeSingleQuotes(objectApiName) + '\',';
            }
            // remove last comma
            objectApiNameClause = objectApiNameClause.subString(0, objectApiNameClause.length() - 1);
            objectApiNameClause += ') ';
        }

        return objectApiNameClause;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private SVMXA360__CONF_TimelineConfigDetail__c createConfigurationDetail( String objectName, String sourceField, String displayField, String startDateField, String endDateField, Integer sequence, String backgroundColor, String iconName ) {
        SVMXA360__CONF_TimelineConfigDetail__c config = new SVMXA360__CONF_TimelineConfigDetail__c();

        config.SVMXA360__ObjectAPIName__c = objectName;
        config.SVMXA360__SourceFieldAPIName__c = sourceField;
        config.SVMXA360__DisplayFieldAPIName__c = displayField;
        config.SVMXA360__StartDateFieldAPIName__c = startDateField;
        config.SVMXA360__EndDateFieldAPIName__c = endDateField;
        config.SVMXA360__Sequence__c = sequence;
        config.SVMXA360__BackgroundColor__c = backgroundColor;
        config.SVMXA360__IconName__c = iconName;
        config.SVMXA360__ShowMatchingOnLoad__c = true;

        return config;
    }

    private Map<Id,List<String>> getExpressionIdsNeedingCriteriaFromConfigurations( Map<String, ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        Map<Id, List<String>> expressionIds = new Map<Id, List<String>>();

        for ( ConfigurationWithObjectMetadata config : configurationsWithMetadata.values() ) {
            // Check if the configuration has an expression configuration
            //  AND check if the expression's criteria has not been populated:
            //      - When the exression's criteria has not been populated, we need to retreive the expression data
            if (config.timelineConfiguration.SVMXA360__QualifyingCriteria__c != null && config.timelineConfiguration.SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c == null) {
                List<string> expressionList = expressionIds.get(config.timelineConfiguration.SVMXA360__TimelineConfigId__c);
                if(expressionList == null){
                    expressionList = new List<string>();
                }
                expressionList.add( (String)config.timelineConfiguration.SVMXA360__QualifyingCriteria__c);
                expressionIds.put(config.timelineConfiguration.SVMXA360__TimelineConfigId__c, expressionList);
            }
        }

        return expressionIds;
    }

    private void buildQualifyingCriteria ( List< ConfigurationWithObjectMetadata> configurationsWithMetadataList ) {
        // Get expression IDs from the configuration records that need criteria to be retrieved
        //   Map: Id = configuration detail record id
        //   Map: String = expression record id
        Map<Id, List<String>> configurationExpressions = new Map<Id, List<String>>();
        for(ConfigurationWithObjectMetadata configurationsWithMetadata: configurationsWithMetadataList ){
            if (configurationsWithMetadata.timelineConfiguration.SVMXA360__QualifyingCriteria__c != null
                && configurationsWithMetadata.timelineConfiguration.SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c == null) {
                List<string> expressionList = configurationExpressions.get(configurationsWithMetadata.timelineConfiguration.SVMXA360__TimelineConfigId__c);
                if(expressionList == null){
                    expressionList = new List<string>();
                }
                expressionList.add( (String)configurationsWithMetadata.timelineConfiguration.SVMXA360__QualifyingCriteria__c);
                configurationExpressions.put(configurationsWithMetadata.timelineConfiguration.SVMXA360__TimelineConfigId__c, expressionList);
            }
        }
        
        // Retrieve expressions for the configuration records
        Map<Id,Adm.Expression> expressions;
        if (configurationExpressions.size() > 0) {
            List<String> expressionList = new List<String>();
            for (List<String> exps: configurationExpressions.values()) {
                expressionList.addAll(exps);
            }
            expressions = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( expressionList, null );
        }

        for ( ConfigurationWithObjectMetadata configWithMeta : configurationsWithMetadataList ) {

            SVMXA360__CONF_TimelineConfigDetail__c timelineConfig = configWithMeta.timelineConfiguration;

            if (timelineConfig.SVMXA360__QualifyingCriteria__c != null) {
                String criteria = timelineConfig.SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c;
                String criteriaName =  timelineConfig.SVMXA360__QualifyingCriteria__r.Name;
                String iconName =  timelineConfig.SVMXA360__IconName__c;
                if( criteria == null && !expressions.isEmpty() ) {
                    if ( expressions.containsKey(timelineConfig.SVMXA360__QualifyingCriteria__c) ) {
                        Adm.Expression expression = expressions.get(timelineConfig.SVMXA360__QualifyingCriteria__c);
                        criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
                    }
                }

                configWithMeta.qualifyingExpression = criteria;
                configWithMeta.qualifyingExpressionName = criteriaName;
                configWithMeta.iconName = iconName;
            }
        }
    }


    private void buildQualifyingCriteria ( Map<String, ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        // Get expression IDs from the configuration records that need criteria to be retrieved
        //   Map: Id = configuration detail record id
        //   Map: String = expression record id
        Map<Id, List<String>> configurationExpressions = getExpressionIdsNeedingCriteriaFromConfigurations(configurationsWithMetadata);

        // Retrieve expressions for the configuration records
        Map<Id,Adm.Expression> expressions;
        if (configurationExpressions.size() > 0) {
            List<String> expressionList = new List<String>();
            for (List<String> exps: configurationExpressions.values()) {
                expressionList.addAll(exps);
            }
            expressions = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( expressionList, null );
        }

        for ( String configurationId : configurationsWithMetadata.keySet() ) {
            ConfigurationWithObjectMetadata configWithMeta = configurationsWithMetadata.get(configurationId);

            SVMXA360__CONF_TimelineConfigDetail__c timelineConfig = configWithMeta.timelineConfiguration;

            if (timelineConfig.SVMXA360__QualifyingCriteria__c != null) {
                String criteria = timelineConfig.SVMXA360__QualifyingCriteria__r.SVMXA360__Criteria__c;
                String criteriaName =  timelineConfig.SVMXA360__QualifyingCriteria__r.Name;
                String iconName =  timelineConfig.SVMXA360__IconName__c;
                if( criteria == null && !expressions.isEmpty() ) {
                    if ( expressions.containsKey(timelineConfig.SVMXA360__QualifyingCriteria__c) ) {
                        Adm.Expression expression = expressions.get(timelineConfig.SVMXA360__QualifyingCriteria__c);
                        criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expression);
                    }
                }

                configWithMeta.qualifyingExpression = criteria;
                configWithMeta.qualifyingExpressionName = criteriaName;
                configWithMeta.iconName = iconName;
            }
        }
    }

    private String buildAssetMilestonesQuery( Amgt.TimelineRequest request, SourceRecordInfo sourceRecordInfo, List<ConfigurationWithObjectMetadata> configurationsWithMetadata ){
        SVMXA360__CONF_TimelineConfigDetail__c configuration = configurationsWithMetadata[0].timelineConfiguration;
        Common.EntityDefinition objectMeta = configurationsWithMetadata[0].metadata;
        List<String> fieldList = new List<String>();
        String queryCriteria = '';
        Common.FieldDefinition fallbackDisplayField = configurationsWithMetadata[0].nameField;
        if(configuration.SVMXA360__EndDateFieldAPIName__c != null) {
            fieldList.add(configuration.SVMXA360__EndDateFieldAPIName__c);
        }
        if(!configuration.SVMXA360__DisplayFieldAPIName__c.equalsIgnoreCase('none')){
            fieldList.add(configuration.SVMXA360__DisplayFieldAPIName__c);
        }
        fieldList.add(configuration.SVMXA360__StartDateFieldAPIName__c);
        if (!configuration.SVMXA360__DisplayFieldAPIName__c.equalsIgnoreCase(fallbackDisplayField.apiName)) {
            fieldList.add(fallbackDisplayField.apiName);
        }
        Common.FieldDefinition startDateFieldDef = getFieldDefinition(objectMeta, configuration.SVMXA360__StartDateFieldAPIName__c);

        if ( String.isNotBlank(configuration.SVMXA360__EndDateFieldAPIName__c) ) {
            // If the configuration has a start AND end date field defined, we compare the intersection of date ranges.
            Common.FieldDefinition endDateFieldDef = getFieldDefinition(objectMeta, configuration.SVMXA360__EndDateFieldAPIName__c);

            queryCriteria += 'AND  (' + configuration.SVMXA360__EndDateFieldAPIName__c + ' = null';
            queryCriteria += ' OR ' + configuration.SVMXA360__EndDateFieldAPIName__c + ' >= ' + getDateValue(endDateFieldDef, request.startDate,false) + ')';
            queryCriteria += ' AND ' + configuration.SVMXA360__StartDateFieldAPIName__c + ' <= ' + getDateValue(startDateFieldDef, request.endDate,true);
        }
        else {
            queryCriteria +=  'AND '+configuration.SVMXA360__StartDateFieldAPIName__c + ' >= ' + getDateValue(startDateFieldDef, request.startDate,false);
            queryCriteria += ' AND ' + configuration.SVMXA360__StartDateFieldAPIName__c + ' <= ' + getDateValue(startDateFieldDef, request.endDate,true);
        }
        String query = 'select Id,{0} from Asset where Id = {1} {2} {3}';
        return String.format(
            query, 
            new List<String>{
                String.join(fieldList,','),
                '\''+sourceRecordInfo.recordId+'\'',
                queryCriteria,
                configurationsWithMetadata[0].qualifyingExpression == null? '':' AND '+configurationsWithMetadata[0].qualifyingExpression
            }
        );        
    }

    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity, PMD.NcssMethodCount')
    private String buildQuery( Amgt.TimelineRequest request, SourceRecordInfo sourceRecordInfo, List<ConfigurationWithObjectMetadata> configurationsWithMetadata ){
        String mainQuery;
        String subQuery = '';

        String taskObjectName = String.valueOf(Task.sObjectType);
        String eventObjectName = String.valueOf(Event.sObjectType);
        String workOrderObjectName = String.valueOf(WorkOrder.sObjectType);

        for (ConfigurationWithObjectMetadata configWithMetadata : configurationsWithMetadata) {
            SVMXA360__CONF_TimelineConfigDetail__c configuration = configWithMetadata.timelineConfiguration;
            Common.EntityDefinition objectMeta = configWithMetadata.metadata;
            Common.FieldDefinition fallbackDisplayField = configWithMetadata.nameField;

            String qualifyingCriteria = configWithMetadata.qualifyingExpression;
            String relationshipName = configWithMetadata.relationshipName;
            Boolean endDateFieldExists = String.isNotBlank(configuration.SVMXA360__EndDateFieldAPIName__c);

            if ( String.isNotBlank(subQuery) ) {
                subQuery += ', ';
            }

            subQuery += ' (SELECT Id ';
            subQuery += ', ' + configuration.SVMXA360__SourceFieldAPIName__c;
            subQuery += ', ' + configuration.SVMXA360__DisplayFieldAPIName__c;

            if (!configuration.SVMXA360__DisplayFieldAPIName__c.equalsIgnoreCase(fallbackDisplayField.apiName)) {
                subQuery += ', ' + fallbackDisplayField.apiName;
            }

            subQuery += ', ' + configuration.SVMXA360__StartDateFieldAPIName__c;

            if ( endDateFieldExists ) {
                subQuery += ', ' + configuration.SVMXA360__EndDateFieldAPIName__c;
            }

            if (configuration.SVMXA360__ObjectAPIName__c.equalsIgnoreCase(taskObjectName)) {
                for( String taskField : taskFields ) {

                    if (!taskField.equalsIgnoreCase(configuration.SVMXA360__DisplayFieldAPIName__c)
                        && !taskField.equalsIgnoreCase(configuration.SVMXA360__EndDateFieldAPIName__c)
                        && !taskField.equalsIgnoreCase(configuration.SVMXA360__SourceFieldAPIName__c)
                        && !taskField.equalsIgnoreCase(configuration.SVMXA360__StartDateFieldAPIName__c)
                    ) {
                        subQuery += ', ' + taskField;
                    }
                }
            }

            if (configuration.SVMXA360__ObjectAPIName__c.equalsIgnoreCase(eventObjectName)) {
                for( String eventField : eventFields ) {

                    if (!eventField.equalsIgnoreCase(configuration.SVMXA360__DisplayFieldAPIName__c)
                        && !eventField.equalsIgnoreCase(configuration.SVMXA360__EndDateFieldAPIName__c)
                        && !eventField.equalsIgnoreCase(configuration.SVMXA360__SourceFieldAPIName__c)
                        && !eventField.equalsIgnoreCase(configuration.SVMXA360__StartDateFieldAPIName__c)
                    ) {
                        subQuery += ', ' + eventField;
                    }
                }
            }

            if (request.isMobileRequest == true
                && configuration.ObjectAPIName__c.equalsIgnoreCase(workOrderObjectName)
                && !subQuery.containsIgnoreCase('worktype.name')
            ) {
                subQuery += ', worktype.name';
            }

            subQuery += ' FROM ' + relationshipName;

            Common.FieldDefinition startDateFieldDef = getFieldDefinition(objectMeta, configuration.SVMXA360__StartDateFieldAPIName__c);

            if ( endDateFieldExists ) {
                // If the configuration has a start AND end date field defined, we compare the intersection of date ranges.
                Common.FieldDefinition endDateFieldDef = getFieldDefinition(objectMeta, configuration.SVMXA360__EndDateFieldAPIName__c);

                subQuery += ' WHERE (' + configuration.SVMXA360__EndDateFieldAPIName__c + ' = null';
                subQuery += ' OR ' + configuration.SVMXA360__EndDateFieldAPIName__c + ' >= ' + getDateValue(endDateFieldDef, request.startDate,false) + ')';
                subQuery += ' AND ' + configuration.SVMXA360__StartDateFieldAPIName__c + ' <= ' + getDateValue(startDateFieldDef, request.endDate,true);
            }
            else {
                subQuery += ' WHERE ' + configuration.SVMXA360__StartDateFieldAPIName__c + ' >= ' + getDateValue(startDateFieldDef, request.startDate,false);
                subQuery += ' AND ' + configuration.SVMXA360__StartDateFieldAPIName__c + ' <= ' + getDateValue(startDateFieldDef, request.endDate,true);
            }

            if (String.isNotBlank(qualifyingCriteria)) {
                subQuery += ' AND (' + qualifyingCriteria+' )';
            }

            subQuery += ')';
        }

        if (String.isNotBlank(subQuery)) {
            mainQuery = 'SELECT Id, ' + sourceRecordInfo.nameFieldApiName + ', ';
            mainQuery += subQuery;
            mainQuery += ' FROM ';
            mainQuery += sourceRecordInfo.objectApiName;
            mainQuery += ' WHERE Id = \'' + sourceRecordInfo.recordId + '\'';
        }

        return mainQuery;
    }

    private List<ConfigurationMetadataWithQuery> buildAssetMilestoneQueries(
        Amgt.TimelineRequest request, 
        SourceRecordInfo sourceRecordInfo,
        List<ConfigurationWithObjectMetadata> assetQueriesMetadata){
        List<ConfigurationMetadataWithQuery> queries = new List<ConfigurationMetadataWithQuery>();
        for ( ConfigurationWithObjectMetadata config : assetQueriesMetadata ) {
            queries.add(new ConfigurationMetadataWithQuery(
                config, 
                buildAssetMilestonesQuery(request, sourceRecordInfo, new List<ConfigurationWithObjectMetadata> {config})
            ));
        }
        return queries;
    }

	private List<ConfigurationMetadataWithQuery> buildQueries(Amgt.TimelineRequest request, SourceRecordInfo sourceRecordInfo, Map<String,List<ConfigurationWithObjectMetadata>> splitConfigurations){
        
        List<ConfigurationMetadataWithQuery> queries = new List<ConfigurationMetadataWithQuery>();

        List<ConfigurationWithObjectMetadata> canBeQueriedTogether = splitConfigurations.get(QUERYABLE_BY_BATCH);
        List<ConfigurationWithObjectMetadata> requiresAdditionalQueries = splitConfigurations.get(REQUIRES_SEPARATE_QUERIES);
        String query = buildQuery(request, sourceRecordInfo, canBeQueriedTogether);
        if (String.isNotBlank(query)) {
            queries.add(new ConfigurationMetadataWithQuery(null, query ));
        }
        

        for ( ConfigurationWithObjectMetadata config : requiresAdditionalQueries ) {
            String addlQuery = buildQuery(request, sourceRecordInfo, new List<ConfigurationWithObjectMetadata> {config});
            if (String.isNotBlank(addlQuery)) {
                queries.add(new ConfigurationMetadataWithQuery(config, addlQuery));
            }
        }

        return queries;
	} 

    private String getDateValue(Common.FieldDefinition fieldDef, Date dateValue, Boolean isDateEnd){
        String newDateValue;

        Time timeinstance;

        if(isDateEnd) {
            timeinstance = Time.newInstance(23, 59, 59, 0);
        } else {
            timeinstance = Time.newInstance(0, 0, 1, 0);
        }
        DateTime dt = Datetime.newInstance(dateValue, timeinstance);

        switch on fieldDef.dataType.toUpperCase() {
            when 'DATE' {
                newDateValue = dt.format('yyyy-MM-dd');
            }
            when 'DATETIME' {
                newDateValue = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            }
        }

        return newDateValue;
    } 

	private void setChildRelationshipNames(SourceRecordInfo sourceRecordInfo, Map<String, ConfigurationWithObjectMetadata> configurationsWithMetadata){
        Schema.DescribeSobjectResult sourceObject = describeManager.getObjectDescribe(sourceRecordInfo.objectApiName);
        List<Schema.ChildRelationship> childRelationships = sourceObject.getChildRelationships();

        for ( Schema.ChildRelationship rel : childRelationships ) {
            Schema.DescribeSObjectResult childRelObject = rel.getChildSObject().getDescribe();

            if (childRelObject.isAccessible() && childRelObject.isQueryable()) {
                String childRelationshipName = rel.getRelationshipName();
                String fieldName = String.valueOf(rel.getField());
                String childObjectName = childRelObject.getName();

                for ( ConfigurationWithObjectMetadata config : configurationsWithMetadata.values() ) {
                    SVMXA360__CONF_TimelineConfigDetail__c timelineConfig = config.timelineConfiguration;
                    if (timelineConfig.SVMXA360__ObjectAPIName__c.equalsIgnoreCase(childObjectName)
                        && timelineConfig.SVMXA360__SourceFieldAPIName__c.equalsIgnoreCase(fieldName)) {

                        config.relationshipName = childRelationshipName;
                    }
                }
            }
        }

        // Verify all relationship names are set.
        for ( ConfigurationWithObjectMetadata config : configurationsWithMetadata.values() ) {
            if (String.isBlank(config.relationshipName)) {
                System.debug( LoggingLevel.DEBUG, 'setChildRelationshipNames() - relationshipName is not set; config= ' + config );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.OBJECT_NOT_EXISTS );
            }
        }
    }

    private Amgt.TimelineResponse createAssetMilestoneTimelineResults( SourceRecordInfo sourceRecordInfo, List<SObject> sObjectList, List<ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        Amgt.TimelineResponse response = new Amgt.TimelineResponse();

        List<Amgt.Timeline> timelineData = new List<Amgt.Timeline>();
        Map<String, String> dupeDataMap = new Map<String, String>();

        ConfigurationWithObjectMetadata config = configurationsWithMetadata[0];
        SVMXA360__CONF_TimelineConfigDetail__c timelineConfiguration = config.timelineConfiguration;
        Common.EntityDefinition objectMeta = config.metadata;
        Common.FieldDefinition fallbackDisplayField = config.nameField;

        for (Sobject rec : sObjectList) {

            String recordId = rec.Id;

            if (!dupeDataMap.containsKey(recordId)) {
                dupeDataMap.put(recordId, recordId);

                Amgt.Timeline timelineResult = new Amgt.Timeline();

                timelineResult.id = recordId;

                String displayValue = '';
                if (timelineConfiguration.SVMXA360__DisplayFieldAPIName__c.equalsIgnoreCase('none')) {
                    displayValue = getFieldDefinition(objectMeta, timelineConfiguration.SVMXA360__StartDateFieldAPIName__c).label;
                } else {
                    displayValue = (String)getSObjectValue(rec, timelineConfiguration.SVMXA360__DisplayFieldAPIName__c, objectMeta);
                }

                // Use Fallback display field (name field for the object)
                if ( String.isBlank(displayValue) && fallbackDisplayField != null ) {
                    displayValue = (String)getSObjectValue(rec, fallbackDisplayField.apiName, objectMeta);
                }

                timelineResult.startDate = getSObjectValue(rec, timelineConfiguration.SVMXA360__StartDateFieldAPIName__c, objectMeta);

                if (timelineConfiguration.SVMXA360__DisplayFieldAPIName__c.equalsIgnoreCase('none') 
                    && !String.isBlank(timelineConfiguration.SVMXA360__EndDateFieldAPIName__c)) {
                    timelineResult.endDate = getSObjectValue(rec, timelineConfiguration.SVMXA360__EndDateFieldAPIName__c, objectMeta);
                    displayValue += ' - '+ getFieldDefinition(objectMeta, timelineConfiguration.SVMXA360__EndDateFieldAPIName__c).label;
                }
                timelineResult.displayName = displayValue;

                timelineResult.objectAPIName = objectMeta.apiName;
                timelineResult.objectLabel = objectMeta.label;
                timelineResult.expressionName = config.qualifyingExpressionName !=null
                    ? config.metadata.apiName+'_'+config.qualifyingExpressionName
                    : 'All Records';
                String expName = config.qualifyingExpressionName !=null
                    ? config.qualifyingExpressionName
                    : 'All Records';
                String type = String.isBlank(timelineConfiguration.SVMXA360__EndDateFieldAPIName__c)?'Event':'Bands';
                timelineResult.uniqueName = objectMeta.apiName+typeSeperator+expName+typeSeperator+timelineResult.displayName+typeSeperator+type;
                timelineResult.backgroundColor = timelineConfiguration.SVMXA360__BackgroundColor__c;
                timelineResult.iconName = timelineConfiguration.SVMXA360__IconName__c;

                if (timelineConfiguration.SVMXA360__Sequence__c != null) {
                    timelineResult.sequence = Integer.Valueof(timelineConfiguration.SVMXA360__Sequence__c);
                }

                timelineResult.record = rec;

                timelineData.add(timelineResult);
            }
        }
        response.timelineResults = timelineData;

        return response;
    }

    
    private Amgt.TimelineResponse createTimelineDataResults( SourceRecordInfo sourceRecordInfo, List<SObject> sObjectList, List<ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        Amgt.TimelineResponse response = new Amgt.TimelineResponse();

        List<Amgt.Timeline> timelineData = new List<Amgt.Timeline>();
        Map<String, String> dupeDataMap = new Map<String, String>();

        for ( SObject result : sObjectList ) {
            Map<String,Object> populatedFields = result.getPopulatedFieldsAsMap();

            for ( String fieldName : populatedFields.keySet() ) {
                if (populatedFields.get(fieldName) instanceof List<sObject>) {
                    List<SObject> childRecords = (List<SObject>) populatedFields.get(fieldName);

                    ConfigurationWithObjectMetadata config = getConfigurationByRelationshipName(fieldName, configurationsWithMetadata);
                    SVMXA360__CONF_TimelineConfigDetail__c timelineConfiguration = config.timelineConfiguration;
                    Common.EntityDefinition objectMeta = config.metadata;
                    Common.FieldDefinition fallbackDisplayField = config.nameField;

                    for (Sobject rec : childRecords) {

                        String recordId = rec.Id;

                        if (!dupeDataMap.containsKey(recordId)) {
                            dupeDataMap.put(recordId, recordId);

                            Amgt.Timeline timelineResult = new Amgt.Timeline();

                            timelineResult.id = recordId;

                            String displayValue = (String)getSObjectValue(rec, timelineConfiguration.SVMXA360__DisplayFieldAPIName__c, objectMeta);

                            // Use Fallback display field (name field for the object)
                            if ( String.isBlank(displayValue) && fallbackDisplayField != null ) {
                                displayValue = (String)getSObjectValue(rec, fallbackDisplayField.apiName, objectMeta);
                            }

                            timelineResult.displayName = displayValue;
                            timelineResult.startDate = getSObjectValue(rec, timelineConfiguration.SVMXA360__StartDateFieldAPIName__c, objectMeta);

                            if (!String.isBlank(timelineConfiguration.SVMXA360__EndDateFieldAPIName__c)) {
                                timelineResult.endDate = getSObjectValue(rec, timelineConfiguration.SVMXA360__EndDateFieldAPIName__c, objectMeta);
                            }

                            timelineResult.objectAPIName = objectMeta.apiName;
                            timelineResult.objectLabel = objectMeta.label;
                            timelineResult.expressionName = config.qualifyingExpressionName !=null
                                ? config.metadata.apiName+'_'+config.qualifyingExpressionName
                                : 'All Records';
                            String expName = config.qualifyingExpressionName !=null
                                ? config.qualifyingExpressionName
                                : 'All Records';
                            String type = String.isBlank(timelineConfiguration.SVMXA360__EndDateFieldAPIName__c)?'Event':'Bands';
                            timelineResult.uniqueName = objectMeta.apiName+typeSeperator+expName+typeSeperator+type;
                            timelineResult.backgroundColor = timelineConfiguration.SVMXA360__BackgroundColor__c;
                            timelineResult.iconName = timelineConfiguration.SVMXA360__IconName__c;

                            if (timelineConfiguration.SVMXA360__Sequence__c != null) {
                                timelineResult.sequence = Integer.Valueof(timelineConfiguration.SVMXA360__Sequence__c);
                            }

                            timelineResult.record = rec;

                            timelineData.add(timelineResult);
                        }
                    }
                } else {
                    response.displayName = String.valueOf(populatedFields.get(sourceRecordInfo.nameFieldApiName));
                }
            }
        }
        response.timelineResults = timelineData;

        return response;
    }

    private Map<String, Amgt.TimelineTypeToShow> getTypesToShow( List<ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        Map<String, Amgt.TimelineTypeToShow> typesToShow = new Map<String, Amgt.TimelineTypeToShow>();

        for ( ConfigurationWithObjectMetadata config : configurationsWithMetadata ) {
            Amgt.TimelineTypeToShow typeToShow = new Amgt.TimelineTypeToShow();
            String startDateLabel =  getFieldDefinition(config.metadata, config.timelineConfiguration.SVMXA360__StartDateFieldAPIName__c).label;
            String labelonly = '';
            if (config.metadata.apiName.equalsIgnoreCase('asset')) {
                typeToShow.label = startDateLabel;
                if (config.timelineConfiguration.SVMXA360__EndDateFieldAPIName__c != null) {
                    typeToShow.label +=' - '+ getFieldDefinition(config.metadata, config.timelineConfiguration.SVMXA360__EndDateFieldAPIName__c).label;
                }
                labelonly = typeToShow.label ;
                if (String.isNotEmpty(config.qualifyingExpressionName)) {
                    typeToShow.label += ' - '+config.qualifyingExpressionName;
                }
            } else {
                typeToShow.label = config.metadata.label;
                labelonly = typeToShow.label ;
                if (String.isNotEmpty(config.qualifyingExpressionName)) {
                    typeToShow.label += ' - '+config.qualifyingExpressionName;
                }
            }
            typeToShow.objectApiName = config.metadata.apiName;
            typeToShow.expressionName = config.qualifyingExpressionName;
            typeToShow.iconName = config.timelineConfiguration.SVMXA360__IconName__c;
            typeToShow.sequence = config.timelineConfiguration.SVMXA360__Sequence__c;
            typeToShow.isTimespanEvent = config.timelineConfiguration.SVMXA360__EndDateFieldAPIName__c != null;
            typeToShow.showMatchingRecordsOnLoad = config.timelineConfiguration.SVMXA360__ShowMatchingOnLoad__c;
            String updatedKeyString = config.metadata.apiName
                +typeSeperator
                +(config.qualifyingExpressionName != null?config.qualifyingExpressionName:'All Records');
            if (config.metadata.apiName.equalsIgnoreCase('asset')) {
                updatedKeyString += typeSeperator+ labelonly;
            }
            updatedKeyString += typeSeperator+ (config.timelineConfiguration.SVMXA360__EndDateFieldAPIName__c != null?'Bands':'Event');
            typesToShow.put(updatedKeyString, typeToShow);
            
        }

        return typesToShow;
    }

    private ConfigurationWithObjectMetadata getConfigurationByRelationshipName ( String relationshipName, List<ConfigurationWithObjectMetadata> configurationsWithMetadata ) {
        for ( ConfigurationWithObjectMetadata config : configurationsWithMetadata ) {
            if (config.relationshipName.equalsIgnoreCase(relationshipName)) {
                return config;
            }
        }

        return null;
    }
    /**
     * Wrapper class to hold information about the source record
     */
    private class SourceRecordInfo {
        public Id recordId { get; set; }
        
        public String objectApiName { get; set; }

        public String nameFieldApiName { get; set; }
    }

    private class ConfigurationWithObjectMetadata {
        public SVMXA360__CONF_TimelineConfigDetail__c timelineConfiguration { get; set; }

        public Common.EntityDefinition metadata { get; set; }

        public Common.FieldDefinition nameField { get; set; }

        public String qualifyingExpression { get; set; }

        public String qualifyingExpressionName { get; set; }

        public String iconName { get; set; }

        public String relationshipName { get; set; }
    }

    private class ConfigurationMetadataWithQuery {

        public ConfigurationWithObjectMetadata configuration { get; set; }

        public String query { get; set; }

        public ConfigurationMetadataWithQuery(ConfigurationWithObjectMetadata config, String dynamicQuery){
            configuration = config;
            query = dynamicQuery;
        }
    }

    private List<ConfigurationWithObjectMetadata> getAssetMilestones ( Map<String,SVMXA360__CONF_TimelineConfigDetail__c> configurations ) {
        List<ConfigurationWithObjectMetadata> assetMileStonesMetadata =  new  List<ConfigurationWithObjectMetadata>();
        Common.EntityDefinition entityDefinition = metadataManager.getFieldDefinitions('Asset');
        for ( String configId : configurations.keySet() ) { 
            SVMXA360__CONF_TimelineConfigDetail__c config = configurations.get(configId);

            if ( config.SVMXA360__ObjectAPIName__c.toUpperCase() == entityDefinition.apiName.toUpperCase() ) {
                ConfigurationWithObjectMetadata configWithMeta = new ConfigurationWithObjectMetadata();
        
                configWithMeta.timelineConfiguration = config;
                configWithMeta.metadata = entityDefinition;
                configWithMeta.nameField = getNameFieldDefinition(entityDefinition);
                assetMileStonesMetadata.add(configWithMeta);
            }
        }
        return assetMileStonesMetadata;
    }

    private Map<String, ConfigurationWithObjectMetadata> getConfigurationsWithMetadata( Map<String,SVMXA360__CONF_TimelineConfigDetail__c> configurations ) {
        Map<String, ConfigurationWithObjectMetadata> configurationsWithMetadata = new Map<String, ConfigurationWithObjectMetadata>();

        Set<String> objectNames = new Set<String>();

        for ( SVMXA360__CONF_TimelineConfigDetail__c config : configurations.values() ) {
            String objectName = config.SVMXA360__ObjectAPIName__c.toUpperCase();

            if ( !objectNames.contains(objectName)  && !objectName.toLowerCase().equals('asset')) {
                objectNames.add(objectName);
            }
        }

        if (objectNames.isEmpty()) {
            //as no objects configured returning empty metadata config 
            return configurationsWithMetadata;
        }

        List<Common.EntityDefinition> entityDefinitionList = metadataManager.getFieldDefinitions( new List<String>(objectNames) );

        for ( Common.EntityDefinition entity : entityDefinitionList ) {

            for ( String configId : configurations.keySet() ) { 
                SVMXA360__CONF_TimelineConfigDetail__c config = configurations.get(configId);

                if ( config.SVMXA360__ObjectAPIName__c.toUpperCase() == entity.apiName.toUpperCase() ) {
                    ConfigurationWithObjectMetadata configWithMeta = new ConfigurationWithObjectMetadata();
            
                    configWithMeta.timelineConfiguration = config;
                    configWithMeta.metadata = entity;
                    configWithMeta.nameField = getNameFieldDefinition(entity);

                    configurationsWithMetadata.put( configId, configWithMeta );
                }
            }
        }

        return configurationsWithMetadata;
    }

    private Object getSObjectValue( SObject record, String fieldName, Common.EntityDefinition objectMetadata ) {
        if (fieldName.contains('.')) {
            return SvmxDatabase.getFieldValue(record, fieldName);
        }

        Common.FieldDefinition fieldDef = getFieldDefinition(objectMetadata, fieldName);

        if (fieldDef == null) { return null; }

        Object fieldValue = record.get( fieldDef.apiName );

        if (fieldValue == null) { return null; }

        switch on fieldDef.dataType.toUpperCase() {
            when 'DATE' {
                return (Date)fieldValue;
            }
            when 'DATETIME' {
                return (DateTime)fieldValue;                
            }
            when else {
                return fieldValue;
            }
        }
    }

    private Common.FieldDefinition getFieldDefinition( Common.EntityDefinition objectMetadata, String fieldName ) {
        Common.FieldDefinition fieldDef;

        if (objectMetadata != null 
            && objectMetadata.fieldDefinitions != null 
            && !objectMetadata.fieldDefinitions.isEmpty()) {
            
            for ( Common.FieldDefinition def : objectMetadata.fieldDefinitions ) {
                if (def.apiName == fieldName) {
                    fieldDef = def;
                    break;
                }
            }
        }

        return fieldDef;
    }

    private Common.FieldDefinition getNameFieldDefinition( Common.EntityDefinition objectMetadata ) {
        Common.FieldDefinition fieldDef;

        if (objectMetadata != null 
            && objectMetadata.fieldDefinitions != null 
            && !objectMetadata.fieldDefinitions.isEmpty()) {
            
            for ( Common.FieldDefinition def : objectMetadata.fieldDefinitions ) {
                if (def.nameField) {
                    fieldDef = def;
                    break;
                }
            }
        }

        return fieldDef;
    }
}