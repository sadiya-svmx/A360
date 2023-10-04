/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides service to get the page data on runtime.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                08 Dec 2020     Created.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public with sharing class CONF_PageLayoutHandler {
    
    private static final String TRANSACTION_STANDALONEEDIT = 'Standalone Edit';
    private static final String TRANSACTION_SOURCETOTARGET = 'Source To Target';
    private static final String TYPE_HEADER = 'Header';
    private static final String TYPE_TARGETCHILD = 'TargetChild';
    private static final String SCREENTYPE_TRANSACTION = 'TRANSACTION'; 

    private static String transactionType;
    private static String sourceRecordId;
    private static String targetRecordId;
    private static sObject currentRecordHeader;
    private static Map<String, String> qualificationCriteriaMap = new Map<String, String>();

    public Config.PageDataResponse getPageData( Config.PageDataRequest pageDataRequest ) {

        System.debug(LoggingLevel.FINEST, 'getPageData() - enter; pageDataRequest= ' + pageDataRequest );

        Config.PageDataResponse pageDataResponse = new Config.PageDataResponse();

        try{

            if( String.isBlank(pageDataRequest.pageLayoutId) ){
                
                System.debug( LoggingLevel.ERROR, 'getPageData() : Invalid pagelayout id. pageLayoutId= ' + pageDataRequest.pageLayoutId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            SVMXA360__CONF_Layout__c pageLayoutConfig = getPageLayoutDetails(pageDataRequest.pageLayoutId);

            if( !pageLayoutConfig.SVMXA360__ScreenType__c.equalsIgnoreCase(SCREENTYPE_TRANSACTION) ){
                System.debug( LoggingLevel.ERROR, 'getPageData() : Invalid Screen Type for getPageData. Screen Type= ' + pageLayoutConfig.SVMXA360__ScreenType__c );
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_InvalidScreenType );                
            }

            transactionType = pageLayoutConfig.SVMXA360__TransactionType__c;

            if(transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT)){
                pageDataRequest.targetRecordId = pageDataRequest.recordId;
            } else {
                pageDataRequest.sourceRecordId = pageDataRequest.recordId;
            }

            SourceTargetConfig headerObjectConfig = mapHeaderConfig(pageLayoutConfig, pageDataRequest.sourceRecordId, pageDataRequest.targetRecordId);

            List<sObject> headerRecord = queryAndApplyMapping(headerObjectConfig);

            if(headerRecord == null || headerRecord.isEmpty()){
                System.debug( LoggingLevel.ERROR, 'getPageData() : Header Record does not Exist. ');
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_HeaderRecordNotExists );
            }

            pageDataResponse.headerRecord = currentRecordHeader = headerRecord[0];
            pageDataResponse.pageDetails = getChildRecords(pageLayoutConfig.SVMXA360__RelatedSections__r);
            if (headerObjectConfig.matchedExpressionId != null) {
                Config.PageConfig pageConfig = new Config.PageConfig ();
                String mappingId = transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT) ? headerObjectConfig.valueMappingId : headerObjectConfig.fieldMappingId;
                pageConfig.headerMappingInfo = new Config.ExpressionMapping(headerObjectConfig.matchedExpressionId, mappingId);
                pageDataResponse.config = pageConfig;
            }

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug(LoggingLevel.ERROR, 'getPageData() : Failed to fetch requested page data. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getPageData() : Failed to fetch requested page data. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.FINEST, 'getPageData() - exit' );
        }

        return pageDataResponse;

    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Config.PageDataResponse savePageData( Config.PageDataRequest pageDataRequest ) {
        
        System.debug(LoggingLevel.FINEST, 'savePageData() - enter; pageDataRequest= ' + pageDataRequest );

        Config.PageDataResponse pageDataResponse = new Config.PageDataResponse();    

        Savepoint sp = Database.setSavePoint();

        try{

            if( String.isBlank(pageDataRequest.pageLayoutId) || pageDataRequest.headerRecord == null){
                
                System.debug( LoggingLevel.ERROR, 'getPageData() : Invalid pagelayout id. pageLayoutId= ' + pageDataRequest.pageLayoutId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            final List<SVMXA360__CONF_Layout__c> layoutList = SvmxDatabase.query( [SELECT Id, SVMXA360__TransactionType__c, SVMXA360__FieldSets__c, SVMXA360__ObjectAPIName__c FROM SVMXA360__CONF_Layout__c 
                                                                WHERE Id =: pageDataRequest.pageLayoutId OR SVMXA360__DeveloperName__c =: pageDataRequest.pageLayoutId] );

            if(layoutList.isEmpty()){
                
                System.debug( LoggingLevel.ERROR, 'savePageData() : Page Layout not found');
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.SCREEN_NOT_FOUND );
            }
               
            transactionType = layoutList[0].SVMXA360__TransactionType__c;

            sObject headerRecord = pageDataRequest.headerRecord;
            boolean isQuickSave = (pageDataRequest.actionType != null && pageDataRequest.actionType.equalsIgnoreCase('quicksave')) ? true: false;
            System.AccessType accessType = System.AccessType.CREATABLE; 

            if( transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT)){
                accessType = System.AccessType.UPDATABLE; 
            } 

            SObjectAccessDecision decision = Security.stripInaccessible( accessType, new List<sObject> { headerRecord } );

            headerRecord = decision.getRecords()[0];

            Map<String, SVMXA360__CONF_LayoutRelatedSection__c> detailLayoutMap = getPageLayoutLineDetails(pageDataRequest.pageLayoutId);
            List<sObject> deleteObjectList = getsObjectDeleteList(pageDataRequest.pageDetails, detailLayoutMap); 

            if(!deleteObjectList.isEmpty()){
                /*
                    CRUD permission check is handled in method getsObjectDeleteList
                */
                delete deleteObjectList;
            }

            upsert headerRecord;
            pageDataResponse.headerRecord = headerRecord;
            
            if(isQuickSave){
                List<sObject> sObjectList = queryUpdatedRecords(new List<String>{headerRecord.Id}, layoutList[0].SVMXA360__ObjectAPIName__c, layoutList[0].SVMXA360__FieldSets__c); 
                pageDataResponse.headerRecord = sObjectList[0];
            }

            constructChildSobject(pageDataRequest.pageDetails, detailLayoutMap, headerRecord.Id);
            List<sObject> sObjectToUpsert = new List<sObject>();
            
            for(Config.PageDetail pageDetail : pageDataRequest.pageDetails){
                if(pageDetail.detailRecords != null){
                    sObjectToUpsert.addAll(pageDetail.detailRecords); 
                }
            }

            if(!sObjectToUpsert.isEmpty()){
                Boolean isSuccess = true;
                String errorMsg = '';
                Map<String, List<String>> objectRecordIdsMap = new Map<String, List<String>>();
                /*
                    CRUD permission check is handled in method constructChildSobject
                */

                Database.UpsertResult[] srList = Database.upsert(sObjectToUpsert, false);
                Integer errCounter = 1; // Track error counter for display
                for (Database.UpsertResult sr : srList) {
                    if (!sr.isSuccess()) {
                        isSuccess = false;
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(LoggingLevel.info, 'The following error has occurred.');                    
                            System.debug(LoggingLevel.error, err.getStatusCode() + ': ' + err.getMessage());
                            System.debug(LoggingLevel.error, 'sObject fields that affected this error: ' + err.getFields());
                            errorMsg += '('+ errCounter +') '+err.getStatusCode() +' : '+ err.getMessage() + ' : ' + err.getFields() +'. ';
                            errCounter++;
                        }
                    } else {
                        String objectAPIName = sr.getId().getSObjectType().getDescribe().getName();
                        List<String> recordIds = new List<String>();
                        if(objectRecordIdsMap.containsKey(objectAPIName)){
                            recordIds = objectRecordIdsMap.get(objectAPIName);
                        }
                        recordIds.add(sr.getId());
                        objectRecordIdsMap.put(objectAPIName, recordIds);
                    }
                }
                if(!isSuccess){
                    throw new SvmxSystem.SvmxNestedException(errorMsg);
                }
                
                if(isQuickSave){
                    for(Config.PageDetail pageDetail : pageDataRequest.pageDetails){

                        if(detailLayoutMap.containsKey(pageDetail.uniqueKey)){
                            SVMXA360__CONF_LayoutRelatedSection__c layoutRelatedSectionRec = detailLayoutMap.get(pageDetail.uniqueKey);
                            List<sObject> childSObjectList = new List<sObject>();
                            if(objectRecordIdsMap.containsKey(layoutRelatedSectionRec.SVMXA360__ObjectAPIName__c)){
                                childSObjectList = queryUpdatedRecords(objectRecordIdsMap.get(layoutRelatedSectionRec.SVMXA360__ObjectAPIName__c), layoutRelatedSectionRec.SVMXA360__ObjectAPIName__c, layoutRelatedSectionRec.SVMXA360__FieldSets__c);
                                Map<Id, sObject> childRecordsMap = new Map<Id, sObject>(childSObjectList);
                            }
                            
                            Map<Id, sObject> childRecordsMap = new Map<Id, sObject>(childSObjectList);
                            for(integer i = 0; i < pageDetail.detailRecords.size(); i++){
                                String detailId = pageDetail.detailRecords[i].Id;
                                if(childRecordsMap.containsKey(detailId)){
                                    pageDetail.detailRecords[i] = childRecordsMap.get(detailId);
                                }                            
                            }
                        } 

                    }
                }

                pageDataResponse.pageDetails = pageDataRequest.pageDetails;
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sp );
            
            System.debug( LoggingLevel.ERROR, 'savePageData() : Failed to save transaction records. Error= ' + e.getMessage() );
            throw e;
        }
        catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'savePageData() : Failed to save transaction records. Error= ' + e.getMessage());
            throw e;
        }
        catch( Exception e ) {
            Database.rollback( sp );
            System.debug(LoggingLevel.ERROR, 'savePageData() : Failed to save transaction records. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.FINEST, 'savePageData() - exit' );
        }

        return pageDataResponse;
    }

    /**
     * This method retrieves child object record after applying mapping 
     * Input parameters are transaction id, child title, source record
     */
    public Config.PageDataResponse getNewChildRecord( Config.PageDataRequest pageDataRequest ) {

        System.debug(LoggingLevel.FINEST, 'getNewChildRecord() - enter; pageDataRequest= ' + pageDataRequest );

        Config.PageDataResponse pageDataResponse = new Config.PageDataResponse();

        try {

            if( String.isBlank(pageDataRequest.pageLayoutId) || String.isBlank(pageDataRequest.detailLineId)){
                
                System.debug( LoggingLevel.ERROR, 'getNewChildRecord() : Invalid parameters. pageLayoutId= ' + pageDataRequest.pageLayoutId + 'detailLineId=' + pageDataRequest.detailLineId);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<SVMXA360__CONF_LayoutRelatedSection__c> layoutRelatedList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__ObjectAPIName__c, SVMXA360__ValueMapping__c FROM SVMXA360__CONF_LayoutRelatedSection__c 
                                                                                                    WHERE Name = :pageDataRequest.detailLineId AND (SVMXA360__Layout__c = :pageDataRequest.pageLayoutId OR 
                                                                                                    SVMXA360__Layout__r.SVMXA360__DeveloperName__c = :pageDataRequest.pageLayoutId)] );
            

            if(!layoutRelatedList.isEmpty()){
                SVMXA360__CONF_LayoutRelatedSection__c layoutRelatedSection = layoutRelatedList[0];
            
                if(layoutRelatedSection.SVMXA360__ValueMapping__c != null) {
                    SObjectType objectType = COMM_DescribeManager.getInstance().getsObjectType( layoutRelatedSection.SVMXA360__ObjectAPIName__c );
                    List<sObject> sObjectRecords = new List<sObject>{ objectType.newSObject() };
                    List<Config.PageDetail> newChildRecords = new List<Config.PageDetail>();
                    Config.PageDetail newChildRecord = new Config.PageDetail();
                    newChildRecord.uniqueKey = layoutRelatedSection.Name;
                    newChildRecord.detailRecords = new CONF_ObjectMappingHandler().applyObjectMapping(layoutRelatedSection.SVMXA360__ValueMapping__c, sObjectRecords, null);
                    newChildRecords.add(newChildRecord); 
                    pageDataResponse.pageDetails = newChildRecords;
                }
            }                                                                                        
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug(LoggingLevel.ERROR, 'getNewChildRecord() : Failed to fetch requested page data. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getNewChildRecord() : Failed to fetch requested page data. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.FINEST, 'getNewChildRecord() - exit' );
        }
        
        return pageDataResponse;

    }

    List<Schema.DescribeFieldResult> getFieldDescribeResults( String objectAPIName ){
        Map<String, Schema.DescribeFieldResult> fieldDescribeResult = COMM_DescribeManager.getInstance().getFieldDescribeResults(objectAPIName);
        if( fieldDescribeResult == null || fieldDescribeResult.isEmpty()){
                
            System.debug( LoggingLevel.ERROR, 'getFieldDescribeResults() : User does not have access to : ' + objectAPIName );
            throw new SvmxSystem.SvmxNestedException( System.Label.Message_UserDoesnotHaveAccess + objectAPIName);
        }
        return fieldDescribeResult.values();
    }

    List<sObject> queryAndApplyMapping( SourceTargetConfig configDetail ){

        if( transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT)){
        
            return typeStandaloneEditor( configDetail );
        } else if ( transactionType.equalsIgnoreCase(TRANSACTION_SOURCETOTARGET) ){

            return typeSourceToTarget( configDetail );
        }

        return null; 
    }

    List<sObject> typeStandaloneEditor( SourceTargetConfig configDetail ){
        Set<String> targetFieldSet = getQueryFields(configDetail);
        List<sObject> mappedSobjectList = new List<sObject>();
        
        if(configDetail.fieldSets == null){
            for(Schema.DescribeFieldResult fieldDesc : getFieldDescribeResults(configDetail.targetObjectAPIName)){
                if(fieldDesc.getType() == Schema.Displaytype.LOCATION || fieldDesc.getType() == Schema.Displaytype.ADDRESS){
                    continue;
                }
                targetFieldSet.add(fieldDesc.getName());
            }   
        }
        
        String queryString = 'SELECT ' + String.join(new List<String>(targetFieldSet), ',') + ' FROM ' + configDetail.targetObjectAPIName;

        if(configDetail.type.equalsIgnoreCase(TYPE_HEADER)){
            targetRecordId = String.escapeSingleQuotes(configDetail.targetRecordId);
            queryString += ' WHERE Id =: targetRecordId';
        }else {
            queryString += ' WHERE ' + configDetail.controllerReferenceField +'=: targetRecordId ';
            if(configDetail.qualifyingCriteria != null && qualificationCriteriaMap.containsKey(configDetail.qualifyingCriteria)){
                queryString += ' AND (' + qualificationCriteriaMap.get(configDetail.qualifyingCriteria) + ')';
            }
        } 

        if(configDetail.type.equalsIgnoreCase(TYPE_TARGETCHILD) && configDetail.sortBy != null){
           String querySortString = getQuerySortString(configDetail.sortBy);
           queryString += ' ORDER BY ' + querySortString;
        }

        System.debug(LoggingLevel.Info, 'Dynamic SOQL : '+ queryString);
        List<sObject> targetObjRecords = Database.query(queryString);
        SObjectAccessDecision decision = Security.stripInaccessible( AccessType.READABLE, targetObjRecords );
        targetObjRecords = decision.getRecords();

        if(configDetail.type.equalsIgnoreCase(TYPE_HEADER) && targetObjRecords.isEmpty()){
            System.debug( LoggingLevel.ERROR, 'getPageDataRunTime() : Header Record does not Exist. targetRecordId= ' + configDetail.targetRecordId );
            throw new SvmxSystem.SvmxNestedException( System.Label.Error_HeaderRecordNotExists + ' : ' +  configDetail.targetRecordId);
        }

        if( configDetail.type.equalsIgnoreCase(TYPE_HEADER) && configDetail.valueMappingId != null){
            mappedSobjectList = new CONF_ObjectMappingHandler().applyObjectMapping( configDetail.valueMappingId, targetObjRecords, null ); 
        } else {
            mappedSobjectList.addAll( targetObjRecords );
        }
        
        return mappedSobjectList;
    }

    List<sObject> typeSourceToTarget( SourceTargetConfig configDetail ){
        Set<String> sourceFieldSet = getQueryFields(configDetail);
        Map<String, COMM_SObjectSorter.SortByInfo> sortingConfigMap = new Map<String, COMM_SObjectSorter.SortByInfo>();
        Map<String, Schema.DescribeFieldResult> targetSourceFieldMap = new Map<String, Schema.DescribeFieldResult>();
        String srcNameField;

        if(configDetail.fieldSets == null){
            for(Schema.DescribeFieldResult fieldDesc : getFieldDescribeResults(configDetail.sourceObjectAPIName)){
                if(fieldDesc.getType() == Schema.Displaytype.LOCATION || fieldDesc.getType() == Schema.Displaytype.ADDRESS){
                    continue;
                }
                sourceFieldSet.add(fieldDesc.getName());
            } 
        }

        if(configDetail.type.equalsIgnoreCase(TYPE_TARGETCHILD) && configDetail.sortBy != null){
            List<COMM_SObjectSorter.SortByInfo> deserializeSortingInfo = (List<COMM_SObjectSorter.SortByInfo>) JSON.deserialize(configDetail.sortBy, List<COMM_SObjectSorter.SortByInfo>.class);
            for(COMM_SObjectSorter.SortByInfo sortingDetail : deserializeSortingInfo){
                sortingConfigMap.put(sortingDetail.fieldAPIName, sortingDetail);
            }
            
            System.debug('configDetail.fieldMappingId ' + configDetail.fieldMappingId);
            for(SVMXA360__CONF_ObjectMappingDetail__c mappingDetail : (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__SourceFieldAPIName__c, SVMXA360__TargetFieldAPIName__c 
                                                                        FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE SVMXA360__ObjectMappingID__c =: configDetail.fieldMappingId AND 
                                                                        SVMXA360__TargetFieldAPIName__c IN: sortingConfigMap.keySet()])){
                if(mappingDetail.SVMXA360__SourceFieldAPIName__c != null){
                    sourceFieldSet.add(mappingDetail.SVMXA360__SourceFieldAPIName__c);
                    Map<String, Schema.DescribeFieldResult> fieldDescribeResult = COMM_DescribeManager.getInstance().getFieldDescribeResults(configDetail.sourceObjectAPIName);
                    for(Schema.DescribeFieldResult fieldDesc : fieldDescribeResult.values()){
                        if(fieldDesc.isNameField()){
                            srcNameField = fieldDesc.getName();
                            sourceFieldSet.add(srcNameField);
                            break;
                        }
                    }   

                    if(fieldDescribeResult.containsKey(mappingDetail.SVMXA360__SourceFieldAPIName__c)){
                        Schema.DescribeFieldResult fieldDesc = fieldDescribeResult.get(mappingDetail.SVMXA360__SourceFieldAPIName__c);
                        if(fieldDesc.getType() == Schema.Displaytype.REFERENCE ){
                            targetSourceFieldMap.put(mappingDetail.SVMXA360__TargetFieldAPIName__c, fieldDesc);
                            String lookupReferenceQueryField = COMM_DescribeManager.getInstance().getReferenceNameField(fieldDesc);
                            sourceFieldSet.add(lookupReferenceQueryField);
                        } else if(fieldDesc.getType() == Schema.Displaytype.ID){
                            targetSourceFieldMap.put(mappingDetail.SVMXA360__TargetFieldAPIName__c, fieldDesc);
                        }
                    }
                }                                                            
            }
        }

        String queryString = 'SELECT ' + String.join(new List<String>(sourceFieldSet), ',') + ' FROM ' + configDetail.sourceObjectAPIName;

        if(configDetail.type.equalsIgnoreCase(TYPE_HEADER)){
            sourceRecordId = String.escapeSingleQuotes(configDetail.sourceRecordId);
            queryString += ' WHERE Id =: sourceRecordId';
        } else {
            queryString += configDetail.sourcecontrollerReferenceField != null ? ' WHERE ' + configDetail.sourcecontrollerReferenceField +'=: sourceRecordId ' :
                             ' WHERE Id =: sourceRecordId';
            
            System.debug(LoggingLevel.Info, 'queryString : ' +  queryString );
            
            if(configDetail.qualifyingCriteria != null && qualificationCriteriaMap.containsKey(configDetail.qualifyingCriteria)){
                queryString += ' AND (' + qualificationCriteriaMap.get(configDetail.qualifyingCriteria) + ')';
            }
        } 

        System.debug(LoggingLevel.Info, 'Dynamic SOQL : '+ queryString);
        List<sObject> sourceObjRecords = Database.query(queryString);
        SObjectAccessDecision decision = Security.stripInaccessible( AccessType.READABLE, sourceObjRecords );
        sourceObjRecords = decision.getRecords();

        SObjectType targetsObjectType = COMM_DescribeManager.getInstance().getsObjectType( configDetail.targetObjectAPIName );

        List<sObject> mappedSobjectList = new List<sObject>();
        List<COMM_SObjectSorter.SObjectWrapper> mappedSobjectWrapperList = new List<COMM_SObjectSorter.SObjectWrapper>();
        for(sObject sourceRec : sourceObjRecords){
            List<sObject> targetObjRecords = new List<sObject>{ targetsObjectType.newSObject() };            
            if(configDetail.fieldMappingId != null){
                CONF_ObjectMappingHandler mappingHandlerInstance = new CONF_ObjectMappingHandler();
                System.debug(LoggingLevel.info, 'Source Record for Mapping: ' + sourceRec);
                List<sObject> mappedSObject = configDetail.type.equalsIgnoreCase(TYPE_HEADER) ? 
                                            mappingHandlerInstance.applyObjectMapping(configDetail.fieldMappingId, targetObjRecords, sourceRec) :
                                            mappingHandlerInstance.applyObjectMapping(configDetail.fieldMappingId, targetObjRecords, sourceRec, currentRecordHeader) ;
                if(!sortingConfigMap.isEmpty()){
                    COMM_SObjectSorter.sortingDetailList = sortingConfigMap.values();
                    for(String sortingField : sortingConfigMap.keySet()){
                        if(targetSourceFieldMap.containsKey(sortingField)){
                            COMM_SObjectSorter.SortByInfo sortingDetail = sortingConfigMap.get(sortingField);
                            Schema.DescribeFieldResult srcFieldDesc = targetSourceFieldMap.get(sortingField);
                            sObject lkpObj;
                            if(srcFieldDesc.getName().equalsIgnoreCase('Id')){
                                String sobjStr = '{ "attributes" : {"type":"' + configDetail.sourceObjectAPIName +'"}, "Id" :"' + sourceRec.get('Id') + '", "' + srcNameField + '":"' + sourceRec.get(srcNameField) + '"}';
                                lkpObj = (sObject)JSON.deserialize(sobjStr, sObject.class);
                            } else {
                                lkpObj = sourceRec.getSObject(srcFieldDesc.getRelationshipName());
                            }
                            mappedSObject[0].putSObject(sortingDetail.relationshipName, lkpObj);
                        } 
                        mappedSobjectWrapperList.add( new COMM_SObjectSorter.SObjectWrapper(mappedSObject[0]) );
                    }
                } else {
                    mappedSobjectList.addAll(mappedSObject);
                }
            } else {
                mappedSobjectList.addAll( targetObjRecords );
            } 
        }
        if(!mappedSobjectWrapperList.isEmpty()){
            mappedSobjectWrapperList.sort();
            for(COMM_SObjectSorter.SObjectWrapper sObjWrapperRec : mappedSobjectWrapperList){
                mappedSobjectList.add(sObjWrapperRec.sObjectRecord);
            }
        }
        
        
        return mappedSobjectList;
    }

    List<Config.PageDetail> getChildRecords(List<SVMXA360__CONF_LayoutRelatedSection__c> childDetails){
        List<Config.PageDetail> pageDetails = new List<Config.PageDetail>();

        if(childDetails != null){
            List<Id> qualificationCriteriaIds = new List<Id>();
            for(SVMXA360__CONF_LayoutRelatedSection__c childDetail : childDetails){
                if(childDetail.SVMXA360__QualifyingCriteria__c != null){
                    qualificationCriteriaIds.add(childDetail.SVMXA360__QualifyingCriteria__c);
                }
            }

            if(!qualificationCriteriaIds.isEmpty()){
                for (Adm.Expression expressionRec : ADM_ExpressionManager.getInstance().getExpressionsWithDetails(qualificationCriteriaIds, null).values()){
                    expressionRec.criteria = COMM_ExpressionUtils.getInstance().buildCriteria(expressionRec);
                    System.debug(LoggingLevel.info, 'Expression Criteria : ' + expressionRec.criteria);
                    qualificationCriteriaMap.put(expressionRec.Id, expressionRec.criteria);
                }   
            }   

            for(SVMXA360__CONF_LayoutRelatedSection__c childDetail : childDetails){
                SourceTargetConfig childConfig = mapChildConfig(childDetail);
                List<sObject> sObjectList = new List<sObject>();
                if(!transactionType.equalsIgnoreCase(TRANSACTION_SOURCETOTARGET) || childConfig.fieldMappingId != null){
                    sObjectList = queryAndApplyMapping(childConfig);
                }
                Config.PageDetail pageDetail = new Config.PageDetail();
                pageDetail.uniqueKey = childDetail.Name;
                pageDetail.detailRecords = sObjectList;
                pageDetails.add(PageDetail);
            } 
        }

        return pageDetails;
    }

    String getQuerySortString (String sortingInfo){
        List<COMM_SObjectSorter.SortByInfo> deserializeSortingInfo = (List<COMM_SObjectSorter.SortByInfo>) JSON.deserialize(sortingInfo, List<COMM_SObjectSorter.SortByInfo>.class);
        String querySortString;
        if(!deserializeSortingInfo.isEmpty()){
            
            for(COMM_SObjectSorter.SortByInfo soryByRec : deserializeSortingInfo){
                String queryField = soryByRec.fieldAPIName;
                if(soryByRec.dataType != null && soryByRec.dataType.equalsIgnoreCase('REFERENCE') && 
                    soryByRec.referenceNameFields != null && !soryByRec.referenceNameFields.isEmpty()){
                    
                    queryField = soryByRec.relationshipName +  '.' +  soryByRec.referenceNameFields[0];
                }
                if(querySortString == null){
                    querySortString = queryField + ' ' + soryByRec.sortingOrder;
                } else {
                    querySortString += ', ' + queryField + ' ' + soryByRec.sortingOrder;
                }
            }
        }

        return querySortString;
    }

    Set<String> getQueryFields(SourceTargetConfig configDetail){
        Set<String> queryFields = new Set<String>{'Id'};
        String objectAPIName;

        if( transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT)){
            objectAPIName = configDetail.targetObjectAPIName;
            /*List<SVMXA360__CONF_LayoutElement__c> layoutElementList = new List<SVMXA360__CONF_LayoutElement__c>();
            
            if(configDetail.type == TYPE_HEADER){
                layoutElementList = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.query( [SELECT Id, SVMXA360__ElementAPIName__c FROM SVMXA360__CONF_LayoutElement__c WHERE 
                                        SVMXA360__LayoutSection__r.SVMXA360__Layout__c =: configDetail.id AND SVMXA360__Type__c = 'Field']);
            } else {
                layoutElementList = (List<SVMXA360__CONF_LayoutElement__c>)SvmxDatabase.query( [SELECT Id, SVMXA360__ElementAPIName__c FROM SVMXA360__CONF_LayoutElement__c WHERE 
                                        SVMXA360__LayoutRelatedSection__c =: configDetail.id AND SVMXA360__Type__c = 'Field']);
            }

            for(SVMXA360__CONF_LayoutElement__c layoutElement : layoutElementList){
                if(layoutElement.SVMXA360__ElementAPIName__c != null){
                    queryFields.add(layoutElement.SVMXA360__ElementAPIName__c);
                }
            }*/

            if(configDetail.valueMappingId != null){
                for(SVMXA360__CONF_ObjectMappingDetail__c mappingElement : (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__TargetFieldAPIName__c, SVMXA360__LiteralParameter__c, 
                                                                        SVMXA360__Type__c, SVMXA360__Value__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE 
                                                                        SVMXA360__ObjectMappingID__c =: configDetail.valueMappingId])){
                    if(mappingElement.SVMXA360__Type__c.equalsIgnoreCase('Value') && mappingElement.SVMXA360__TargetFieldAPIName__c != null){
                        queryFields.add(mappingElement.SVMXA360__TargetFieldAPIName__c);
                    } else if (mappingElement.SVMXA360__Type__c.equalsIgnoreCase('Function') && mappingElement.SVMXA360__Value__c == 'Current Record'
                        && mappingElement.SVMXA360__LiteralParameter__c != null){
                        queryFields.add(mappingElement.SVMXA360__LiteralParameter__c);
                    }
                }
            }
        } else if ( transactionType.equalsIgnoreCase(TRANSACTION_SOURCETOTARGET) ){
            objectAPIName = configDetail.sourceObjectAPIName;
            if(configDetail.fieldMappingId != null){
                for(SVMXA360__CONF_ObjectMappingDetail__c mappingElement : (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__Type__c, SVMXA360__SourceFieldAPIName__c,
                                                                        SVMXA360__Value__c, SVMXA360__LiteralParameter__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE 
                                                                        SVMXA360__ObjectMappingID__c =: configDetail.fieldMappingId])){
                    if(mappingElement.SVMXA360__Type__c.equalsIgnoreCase('Field') && mappingElement.SVMXA360__SourceFieldAPIName__c != null){
                        queryFields.add(mappingElement.SVMXA360__SourceFieldAPIName__c);
                    }
                }
            }
        }

        queryFields.addAll(getFieldSetFields(configDetail.fieldSets, objectAPIName));
        return queryFields;
    }

    Set<String> getFieldSetFields(List<String> fieldSets, String objectAPIName){
        Set<String> fieldSetFields = new Set<String>();
        if(fieldSets != null){
            SObjectType sObjType = COMM_DescribeManager.getInstance().getsObjectType( objectAPIName );
            List<Schema.FieldSet> fieldsetList = sObjType.getDescribe().FieldSets.getMap().values();

            for(Schema.FieldSet fieldSet : fieldsetList){
                if(fieldSets.contains(fieldSet.getName())){
                    for(Schema.FieldSetMember f : fieldSet.getFields()){
                        fieldSetFields.add(f.getFieldPath());
                    }                    
                }
            }
        } 

        return fieldSetFields;         
    }

    SVMXA360__CONF_Layout__c getPageLayoutDetails( final String pageLayoutId ){
        
        final List<SVMXA360__CONF_Layout__c> layoutList = SvmxDatabase.query( [SELECT Id, SVMXA360__TransactionType__c, SVMXA360__FieldMapping__c, SVMXA360__QualifyingCriteria__c, SVMXA360__ObjectAPIName__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__ValueMapping__c, SVMXA360__FieldSets__c,
                                                    SVMXA360__ScreenType__c, SVMXA360__ApplyMapping__c, (SELECT Id, Name, SVMXA360__ObjectAPIName__c, SVMXA360__ControllerReferenceField__c, SVMXA360__SourceControllerReferenceField__c, SVMXA360__FieldMapping__c, SVMXA360__QualifyingCriteria__c, SVMXA360__SourceObjectAPIName__c, 
                                                    SVMXA360__ValueMapping__c, SVMXA360__SortBy__c, SVMXA360__FieldSets__c FROM SVMXA360__RelatedSections__r ORDER BY SVMXA360__SectionSequence__c ASC) FROM SVMXA360__CONF_Layout__c WHERE Id =: pageLayoutId OR SVMXA360__DeveloperName__c =: pageLayoutId] );
        
        if(layoutList.isEmpty()){
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Page layout does not exist. pageLayoutId= ' + pageLayoutId );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.SCREEN_NOT_FOUND );            
        }

        return layoutList[0];    
    }

    void constructChildSobject(List<Config.PageDetail> pageDetails, Map<String, SVMXA360__CONF_LayoutRelatedSection__c> detailLayoutMap, String headerRecordId){
        
        if( pageDetails != null && !pageDetails.isEmpty()){
            List<sObject> tempsObjectList;
        
            for(Config.PageDetail pageDetail : pageDetails){
                String uniqueKey = pageDetail.uniqueKey;
                if(detailLayoutMap.containsKey(uniqueKey)){
                    
                    if(pageDetail.detailRecords != null && !pageDetail.detailRecords.isEmpty()){
                        SVMXA360__CONF_LayoutRelatedSection__c detailLayoutRecord = detailLayoutMap.get(uniqueKey);
                        String objectAPIName = detailLayoutRecord.SVMXA360__ObjectAPIName__c;
                        SObjectType sObjectType = COMM_DescribeManager.getInstance().getsObjectType( objectAPIName );
                        tempsObjectList = (List<SObject>) System.Type.forName('List<' + sObjectType + '>').newInstance();
                        Boolean isCreate = false;
                        for(sObject sObjectRecord : pageDetail.detailRecords){

                            String idValue = sObjectRecord.get('Id') != null ? String.valueOf(sObjectRecord.get('Id')): '';
                            if(Pattern.matches('^[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?$', idValue)){
                                sObjectRecord.put('Id', null);
                                isCreate = true;
                            }
                            
                            if(isCreate){
                                sObjectRecord.put(detailLayoutRecord.SVMXA360__ControllerReferenceField__c, headerRecordId); 
                            }

                            tempsObjectList.add(sObjectRecord);
                        }

                        if(tempsObjectList != null && !tempsObjectList.isEmpty()){

                            SObjectAccessDecision decision = Security.stripInaccessible( AccessType.CREATABLE, tempsObjectList );
                            tempsObjectList = decision.getRecords();
                            pageDetail.detailRecords = tempsObjectList;
                        }
                    }
                }
            }

        }
    }

    List<sObject> getsObjectDeleteList(List<Config.PageDetail> pageDetails, Map<String, SVMXA360__CONF_LayoutRelatedSection__c> detailLayoutMap){

        List<sObject> deleteObjectList = new List<sObject>();

        if( pageDetails != null && !pageDetails.isEmpty()){
            List<sObject> tempsObjectList;
            String objectAPIName;
            for(Config.PageDetail pageDetail : pageDetails){
                    
                if(pageDetail.deleteIds != null && !pageDetail.deleteIds.isEmpty()){
                    SVMXA360__CONF_LayoutRelatedSection__c detailLayoutRecord = detailLayoutMap.get(pageDetail.uniqueKey);
                    objectAPIName = detailLayoutRecord.SVMXA360__ObjectAPIName__c;
                    SObjectType sObjectType = COMM_DescribeManager.getInstance().getsObjectType( objectAPIName );
                    tempsObjectList = (List<SObject>) System.Type.forName('List<' + sObjectType + '>').newInstance();

                    for(String lineId : pageDetail.deleteIds){
                        tempsObjectList.add(sObjectType.newSObject(lineId));
                    }    
                    
                    if(tempsObjectList != null && !tempsObjectList.isEmpty()){
                        if(!sObjectType.getDescribe().isDeletable()){
                            System.debug( LoggingLevel.ERROR, 'saveOperation() : Restricted access to delete records. User= ' + System.UserInfo.getUserId() );
                            throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + sObjectType.getDescribe().getName() );
                        }
                        deleteObjectList.addAll(tempsObjectList);
                    }    
                }    
            }    
        }

        return deleteObjectList;
    }

    Map<String, SVMXA360__CONF_LayoutRelatedSection__c> getPageLayoutLineDetails( final String pageLayoutId ){
        final List<SVMXA360__CONF_LayoutRelatedSection__c> lineItems = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__ObjectAPIName__c, SVMXA360__ControllerReferenceField__c, SVMXA360__SourceControllerReferenceField__c, SVMXA360__FieldMapping__c,  
                                                                        SVMXA360__QualifyingCriteria__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__Layout__c, SVMXA360__ValueMapping__c, SVMXA360__FieldSets__c FROM SVMXA360__CONF_LayoutRelatedSection__c 
                                                                        WHERE SVMXA360__Layout__c =: pageLayoutId OR SVMXA360__Layout__r.SVMXA360__DeveloperName__c =: pageLayoutId] );
        Map<String, SVMXA360__CONF_LayoutRelatedSection__c> detailLayoutMap = new Map<String, SVMXA360__CONF_LayoutRelatedSection__c>();
        for(SVMXA360__CONF_LayoutRelatedSection__c lineItemRec : lineItems){
            detailLayoutMap.put( lineItemRec.Name, lineItemRec );
        }           
        return detailLayoutMap;
    }

    List<sObject> queryUpdatedRecords(List<String> recordIds, String objectAPIName, String fieldSetConfig){
        List<sObject> sObjectList = new List<sObject>();
        
        if(!recordIds.isEmpty() && objectAPIName != null){
            Set<String> objFields = new Set<String>{'Id'};            
            if(!transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT) || fieldSetConfig == null){
                for(Schema.DescribeFieldResult fieldDesc : getFieldDescribeResults(objectAPIName)){
                    if(fieldDesc.getType() == Schema.Displaytype.LOCATION || fieldDesc.getType() == Schema.Displaytype.ADDRESS){
                        continue;
                    }
                    objFields.add(fieldDesc.getName());
                } 
            } else {
                List<String> fieldSets = (List<String>)JSON.deserialize(fieldSetConfig, List<String>.class);
                objFields.addAll(getFieldSetFields(fieldSets, objectAPIName));
            }

            String queryString = 'SELECT ' + String.join(new List<String>(objFields), ',') + ' FROM ' + objectAPIName + ' WHERE Id IN: recordIds';
            System.debug(LoggingLevel.Info, 'Dynamic SOQL : '+ queryString);
            sObjectList = Database.query(queryString);
            SObjectAccessDecision decision = Security.stripInaccessible( AccessType.READABLE, sObjectList );
            sObjectList = decision.getRecords();
        }

        return sObjectList;
    }

    SourceTargetConfig mapHeaderConfig(SVMXA360__CONF_Layout__c pageLayoutConfig, String sourceRecordId, String targetRecordId){
        SourceTargetConfig headerConfig = new SourceTargetConfig();
        headerConfig.id = pageLayoutConfig.Id;
        headerConfig.sourceRecordId = sourceRecordId;
        headerConfig.targetRecordId = targetRecordId;
        headerConfig.sourceObjectAPIName = pageLayoutConfig.SVMXA360__SourceObjectAPIName__c;
        headerConfig.targetObjectAPIName = pageLayoutConfig.SVMXA360__ObjectAPIName__c;
        headerConfig.qualifyingCriteria = pageLayoutConfig.SVMXA360__QualifyingCriteria__c;
        headerConfig.valueMappingId = pageLayoutConfig.SVMXA360__ValueMapping__c;
        headerConfig.fieldMappingId = pageLayoutConfig.SVMXA360__FieldMapping__c;
        if ((targetRecordId != null || sourceRecordId != null) && pageLayoutConfig.SVMXA360__ApplyMapping__c != null && pageLayoutConfig.SVMXA360__ApplyMapping__c.equalsIgnoreCase('Conditional')) {
            List<String> expressionIds = new List<String> ();
            List<SVMXA360__CONF_ExpressionBasedMappingRow__c> expressionMappingRows = (List<SVMXA360__CONF_ExpressionBasedMappingRow__c>)SvmxDatabase.query([SELECT Id, SVMXA360__Sequence__c, SVMXA360__ExpressionId__c, SVMXA360__ObjectMappingId__c FROM 
            SVMXA360__CONF_ExpressionBasedMappingRow__c WHERE SVMXA360__ExpressionBasedMapping__r.SVMXA360__TransactionHeader__c =: pageLayoutConfig.Id ORDER BY SVMXA360__Sequence__c ASC]);
            for(SVMXA360__CONF_ExpressionBasedMappingRow__c expressionMappingRow : expressionMappingRows){
                if (expressionMappingRow.SVMXA360__ExpressionId__c != null) {
                    expressionIds.add(expressionMappingRow.SVMXA360__ExpressionId__c);
                }    
            }
            
            Id dataSourceId = transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT) ? targetRecordId: sourceRecordId;

            sObject sObjectRecord = dataSourceId.getSObjectType().newSObject(dataSourceId);
            headerConfig.matchedExpressionId = new ADM_ExpressionHandler().getFirstQualifiedExpression(sObjectRecord, new List<String>(expressionIds));
            if (headerConfig.matchedExpressionId != null) {
                for (SVMXA360__CONF_ExpressionBasedMappingRow__c expressionMappingRow : expressionMappingRows) {
                    if (headerConfig.matchedExpressionId == expressionMappingRow.SVMXA360__ExpressionId__c) {
                        if (transactionType.equalsIgnoreCase(TRANSACTION_STANDALONEEDIT)) {
                            headerConfig.valueMappingId = expressionMappingRow.SVMXA360__ObjectMappingId__c;
                        } else {
                            headerConfig.fieldMappingId = expressionMappingRow.SVMXA360__ObjectMappingId__c;
                        }
                        break;
                    }
                }
            }
        }
        headerConfig.fieldSets = pageLayoutConfig.SVMXA360__FieldSets__c != null ? 
                                (List<String>)JSON.deserialize(pageLayoutConfig.SVMXA360__FieldSets__c, List<String>.class): null;
        headerConfig.type = TYPE_HEADER;
        return headerConfig;
    }

    SourceTargetConfig mapChildConfig(SVMXA360__CONF_LayoutRelatedSection__c relatedLayoutConfig){
        SourceTargetConfig childConfig = new SourceTargetConfig();
        childConfig.id = relatedLayoutConfig.Id;
        childConfig.sourceObjectAPIName = relatedLayoutConfig.SVMXA360__SourceObjectAPIName__c;
        childConfig.targetObjectAPIName = relatedLayoutConfig.SVMXA360__ObjectAPIName__c;
        childConfig.qualifyingCriteria = relatedLayoutConfig.SVMXA360__QualifyingCriteria__c;
        childConfig.valueMappingId = relatedLayoutConfig.SVMXA360__ValueMapping__c;
        childConfig.fieldMappingId = relatedLayoutConfig.SVMXA360__FieldMapping__c;
        childConfig.controllerReferenceField = relatedLayoutConfig.SVMXA360__ControllerReferenceField__c;
        childConfig.sourceControllerReferenceField = relatedLayoutConfig.SVMXA360__SourceControllerReferenceField__c;
        childConfig.type = TYPE_TARGETCHILD;
        childConfig.sortBy = relatedLayoutConfig.SVMXA360__SortBy__c;
        childConfig.fieldSets = relatedLayoutConfig.SVMXA360__FieldSets__c != null ? 
                                (List<String>)JSON.deserialize(relatedLayoutConfig.SVMXA360__FieldSets__c, List<String>.class): null;
        return childConfig;
    }

    public class SourceTargetConfig {
        public String id;
        public String type;
        public String sourceRecordId;
        public String targetRecordId;        
        public String sourceObjectAPIName;
        public String targetObjectAPIName;
        public String qualifyingCriteria;
        public String valueMappingId;
        public String fieldMappingId;
        public String controllerReferenceField;
        public String sourceControllerReferenceField;
        public String matchedExpressionId;
        public String sortBy;
        public List<String> fieldSets;
    }    
}