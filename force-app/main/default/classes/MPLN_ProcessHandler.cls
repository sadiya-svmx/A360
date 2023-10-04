/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This apex class serves as engine for processing Maintenance Plan to generate work order. 
 *
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                07 Jan 2023     Created.
 *****************************************************************************************************/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class MPLN_ProcessHandler {
    Map<Id, Id> workRuleWorkTypeMap = new Map<Id, Id>();
    Map<Id, SVMXA360__SM_MaintenancePlan__c> maintenancePlanMap = new Map<Id, SVMXA360__SM_MaintenancePlan__c>();
    Map<Id, Asset> assetRecordMap = new Map<Id, Asset>();
    Map<String, String> assetWorkRuleExpressionMap = new Map<String, String>();
    Set<Id> technicalAttributes = new Set<Id>();
    Map<String, String> currentAttributeReadings = new Map<String, String>();
    Map<Id, WorkOrder> woRuleMap = new Map<Id, WorkOrder>();
    Map<String, ProcessLogger> processLoggerMap = new Map<String, ProcessLogger>();
    Set<String> mappingIds = new Set<String>();
    String techAttributeObject = 'Asset';
    ProcessLogger logObj;


    public List<ProcessLogger> processMaintenancePlans (List<SVMXA360__SM_MaintenancePlan__c> mplansList) {
        Set<Id> mplanAssetIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> workRuleIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<String, Set<String>> ownerObjectFieldMap = new  Map<String, Set<String>>();
        System.debug(LoggingLevel.Info,  ' Processing Batch with ' + mplansList.size() + ' Maintenance Plans ');
        Savepoint sp = Database.setSavepoint(); //Defining Save point before executing any DMLs in the engine execute

        try {

            for (SVMXA360__SM_MaintenancePlan__c mplanRec : mplansList) {
                maintenancePlanMap.put(mplanRec.Id, mplanRec);

                if (mplanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__c != null){
                    mappingIds.add(mplanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__c);
                }

                if (mplanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__c != null) {
                    mappingIds.add(mplanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__c);
                }

                String ownerObjectName = mplanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToObjectAPIName__c;
                if (ownerObjectName != null) {
                    Set<String> tempFields = new Set<String>();
                    if (ownerObjectFieldMap.containsKey(ownerObjectName)){
                        tempFields = ownerObjectFieldMap.get(ownerObjectName);
                    } 
                    tempFields.add(mplanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToValue__c);
                    ownerObjectFieldMap.put(ownerObjectName, tempFields);
                }

                if (mplanRec.SVMXA360__Account__c != null) {
                    accountIds.add(mplanRec.SVMXA360__Account__c);
                }

                logObj = new ProcessLogger();
                logObj.processId = mplanRec.SVMXA360__MaintenancePlanProcessId__c;
                logObj.processName = mplanRec.SVMXA360__MaintenancePlanProcessId__r.Name;
                logObj.planId = mplanRec.Id;
                logObj.planName = mplanRec.Name;
                logObj.strLogger = '';
                processLoggerMap.put(mplanRec.Id, logObj);

                currentAttributeReadings.put(mplanRec.Id + '' + 'ownerId', mplanRec.ownerId);
            } 
            
            if (!maintenancePlanMap.isEmpty()) {

                for (SVMXA360__SM_MaintenancePlanAsset__c mPlanAsset : (List<SVMXA360__SM_MaintenancePlanAsset__c>) SvmxDatabase.query([SELECT Id, SVMXA360__Asset__c, SVMXA360__WorkType__c, SVMXA360__MaintenancePlan__r.SVMXA360__WorkType__c  
                                                                        FROM SVMXA360__SM_MaintenancePlanAsset__c 
                                                                        WHERE SVMXA360__MaintenancePlan__c IN: maintenancePlanMap.keySet()])) 
                {
                    mplanAssetIds.add(mPlanAsset.Id);

                    if (mPlanAsset.SVMXA360__Asset__c != null) {
                        assetIds.add(mPlanAsset.SVMXA360__Asset__c);
                    }
                }					           	 
            }
            
            List<SVMXA360__SM_MaintenanceWorkRule__c> workRuleList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__WorkType__c, SVMXA360__MaintenancePlanAsset__c,  SVMXA360__AdvancedExpression__c, SVMXA360__SortOrder__c,
                                                                    SVMXA360__MaintenancePlan__c, SVMXA360__MaintenancePlan__r.Name, SVMXA360__MaintenancePlan__r.SVMXA360__WorkType__c, SVMXA360__MaintenancePlanAsset__r.SVMXA360__WorkType__c, SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c, 
                                                                    SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Name, SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c FROM SVMXA360__SM_MaintenanceWorkRule__c WHERE SVMXA360__MaintenancePlanAsset__c IN: mplanAssetIds 
                                                                     ORDER BY SVMXA360__SortOrder__c]);   //OR SVMXA360__MaintenancePlan__c IN: maintenancePlanMap.keySet()
                                                                    
            for (SVMXA360__SM_MaintenanceWorkRule__c workRuleRec: workRuleList){
                if (workRuleRec.SVMXA360__WorkType__c != null) {
                    workRuleWorkTypeMap.put(workRuleRec.Id, workRuleRec.SVMXA360__WorkType__c);
                } else if (workRuleRec.SVMXA360__MaintenancePlanAsset__c != null && workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__WorkType__c != null) {
                    workRuleWorkTypeMap.put(workRuleRec.Id, workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__WorkType__c);
                } else if (workRuleRec.SVMXA360__MaintenancePlan__c != null && workRuleRec.SVMXA360__MaintenancePlan__r.SVMXA360__WorkType__c != null) {
                    workRuleWorkTypeMap.put(workRuleRec.Id, workRuleRec.SVMXA360__MaintenancePlan__r.SVMXA360__WorkType__c);
                }   

                workRuleIds.add(workRuleRec.Id);
                String mapKey = workRuleRec.SVMXA360__MaintenancePlanAsset__c + '' + workRuleRec.SVMXA360__SortOrder__c;
                if (workRuleRec.SVMXA360__AdvancedExpression__c != null) {
                    String advancedExpression = workRuleRec.SVMXA360__AdvancedExpression__c.ToUpperCase();
                    advancedExpression = advancedExpression.replaceAll('AND', ' && ');
                    advancedExpression = advancedExpression.replaceAll('OR', ' || ');
                    advancedExpression = advancedExpression.replaceAll('NOT', ' ! ');
                    assetWorkRuleExpressionMap.put(mapKey, advancedExpression);
                }
            }

            List<SVMXA360__SM_Condition__c> conditions = new List<SVMXA360__SM_Condition__c>();
            Set<Id> conditionIds = new Set<Id>();
            Set<String> assetFields = new Set<String>{'Id'};

            if (!workRuleIds.isEmpty()) {
                conditions = SvmxDatabase.query([SELECT Id, Name, SVMXA360__ConditionType__c, SVMXA360__FieldAPIName__c, SVMXA360__Operand__c, SVMXA360__Operator__c,
                    SVMXA360__RecurrencePattern__c, SVMXA360__Sequence__c, SVMXA360__StartAt__c, SVMXA360__StopAt__c, SVMXA360__MaintenanceWorkRule__c, SVMXA360__MaintenanceWorkRule__r.Name,
                    SVMXA360__TechnicalAttribute__c, SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c, SVMXA360__Threshold__c, SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__c,
                    SVMXA360__MaintenanceWorkRule__r.SVMXA360__SortOrder__c, SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c,  SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c 
                    FROM SVMXA360__SM_Condition__c WHERE SVMXA360__MaintenanceWorkRule__c IN: workRuleIds]);
                
                for (SVMXA360__SM_Condition__c condition : conditions) {
                    conditionIds.add(condition.Id);
                    if (condition.SVMXA360__ConditionType__c == 'Frequency' || condition.SVMXA360__ConditionType__c == 'Criteria') {
                        if (condition.SVMXA360__TechnicalAttribute__c != null) {
                            technicalAttributes.add(condition.SVMXA360__TechnicalAttribute__c);
                        } 
                        if (condition.SVMXA360__FieldAPIName__c != null) {
                            assetFields.add(condition.SVMXA360__FieldAPIName__c);
                        }  
                    } 
                }
            }

            if (!mappingIds.isEmpty()) {
                for(SVMXA360__CONF_ObjectMappingDetail__c mappingDetailRec : (List<SVMXA360__CONF_ObjectMappingDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__SourceFieldAPIName__c, SVMXA360__TargetFieldAPIName__c, SVMXA360__Type__c,
                                                                                SVMXA360__ObjectMappingID__r.SVMXA360__SourceObjectAPIName__c, SVMXA360__ObjectMappingID__r.SVMXA360__TargetObjectAPIName__c FROM SVMXA360__CONF_ObjectMappingDetail__c WHERE 
                                                                                SVMXA360__ObjectMappingID__c IN: mappingIds])){
                    if(mappingDetailRec.SVMXA360__ObjectMappingID__r.SVMXA360__SourceObjectAPIName__c != null){
                        if (mappingDetailRec.SVMXA360__ObjectMappingID__r.SVMXA360__SourceObjectAPIName__c.equalsIgnoreCase('Asset') && mappingDetailRec.SVMXA360__Type__c == 'Field'){
                            assetFields.add(mappingDetailRec.SVMXA360__SourceFieldAPIName__c);
                        }   
                    }                                                                              
                }
            }

            if (ownerObjectFieldMap.containsKey('Asset')) {
                assetFields.addAll(ownerObjectFieldMap.get('Asset'));
            }

            if (!technicalAttributes.isEmpty()){
                for(SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTAReading : (List<SVMXA360__SM_TA_AssetTechnicalAttribute__c>)SvmxDatabase.query([SELECT Id, SVMXA360__Value__c, SVMXA360__BooleanValue__c, SVMXA360__NumberValue__c, SVMXA360__DateValue__c, SVMXA360__AttributeId__r.SVMXA360__DataType__c, 
                                                                                SVMXA360__DatetimeValue__c, SVMXA360__AttributeId__c, SVMXA360__AssetId__c FROM SVMXA360__SM_TA_AssetTechnicalAttribute__c 
                                                                                WHERE SVMXA360__AttributeId__c IN: technicalAttributes AND SVMXA360__AssetId__c IN: assetIds]))
                {
                    mapCurrentAttributeReadings(assetTAReading);
                }

            }

            if (!assetFields.isEmpty()) {
                String queryFields= getQueryFieldString(assetFields);
                System.debug(LoggingLevel.Info, 'Asset Ids ' + assetIds);
                String queryString = 'SELECT ' + queryFields + ' FROM Asset WHERE Id IN: assetIds';
                Object fieldValue;
                List<Asset> assetList = SvmxDatabase.query(Database.query(queryString));
                for (Asset assetRec : assetList) {
                    assetRecordMap.put(assetRec.Id, assetRec);
                    for (String assetFld : assetFields) {
                        if (assetRec.get(assetFld) != null) {
                            fieldValue = assetRec.get(assetFld);
                            String attributeKey = assetRec.Id + '' + '' + assetFld;
                            System.debug(LoggingLevel.INFO, 'Criteria attributeKey before evaluate ' + attributeKey);

                            currentAttributeReadings.put(attributeKey, String.valueOf(fieldValue));
                        }
                    }
                }

            }

            if (ownerObjectFieldMap.containsKey('Account') && !accountIds.isEmpty()) {
                String queryFields = getQueryFieldString(ownerObjectFieldMap.get('Account'));
                String queryString = 'SELECT ' + queryFields + ' FROM Account WHERE Id IN: accountIds';
                Object fieldValue;
                List<Account> accountList = SvmxDatabase.query(Database.query(queryString));
                for (Account accRec : accountList) {
                    for (String accFld : ownerObjectFieldMap.get('Account')) {
                        if (accRec.get(accFld) != null) {
                            fieldValue = accRec.get(accFld);
                            String attributeKey = accRec.Id + '' + '' + accFld;
                            System.debug(LoggingLevel.INFO, 'Criteria attributeKey before evaluate ' + attributeKey);

                            currentAttributeReadings.put(attributeKey, String.valueOf(fieldValue));
                        }                                                   
                    }
                }

            }

            Map<Id, String> previousOutputMap = new Map<Id, String>();
            for(SVMXA360__ConditionalOutputDetail__c outputDetail : (List<SVMXA360__ConditionalOutputDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__AssetConditionId__c, SVMXA360__ExpectedReading__c FROM SVMXA360__ConditionalOutputDetail__c WHERE SVMXA360__AssetConditionId__c IN: conditionIds
                                                                    AND SVMXA360__isLatest__c = true])){
                previousOutputMap.put(outputDetail.SVMXA360__AssetConditionId__c, outputDetail.SVMXA360__ExpectedReading__c);
            }

            Map<Id, List<ConditionWrapper>> workRuleAttributeReadingMap = new Map<Id, List<ConditionWrapper>>();

            for (SVMXA360__SM_Condition__c conditionRec : conditions) {
                String attributeDataType;
                String attributeKey;
                String currentReading;
                ConditionWrapper conditionWrapperRecord;
                String previousTargetReading;
                String strLogger = '';
                Boolean conditionOutput = false;
                String booleanStr = 'F';

                if (processLoggerMap.containsKey(conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c)) {
                    logObj = processLoggerMap.get(conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c);
                }
                if (previousOutputMap.containsKey(conditionRec.Id)) {
                    previousTargetReading = previousOutputMap.get(conditionRec.Id);
                }

                if (conditionRec.SVMXA360__ConditionType__c == 'Frequency' || conditionRec.SVMXA360__ConditionType__c == 'Criteria') {
                    if (conditionRec.SVMXA360__FieldAPIName__c != null) {
                        attributeKey = conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c + '' + conditionRec.SVMXA360__FieldAPIName__c;
                        attributeDataType = getFieldDataType(conditionRec.SVMXA360__FieldAPIName__c);
                    } else if (conditionRec.SVMXA360__TechnicalAttribute__c != null && conditionRec.SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c != null) {
                        attributeKey = conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c + '' + conditionRec.SVMXA360__TechnicalAttribute__c;
                        attributeDataType = conditionRec.SVMXA360__TechnicalAttribute__r.SVMXA360__DataType__c;
                    }

                    System.debug(LoggingLevel.INFO, 'Attribute Date Type ' + attributeDataType);
                    System.debug(LoggingLevel.INFO, 'Frequency attributeKey during evaluate ' + attributeKey);

                    strLogger += '\n' + String.valueOfGmt(system.now()) + ' Evaluating the condition ' + '\'' + conditionRec.Name + '\'' + ' of type \'' + conditionRec.SVMXA360__ConditionType__c + '\' for Work Rule ' + '\'' + conditionRec.SVMXA360__MaintenanceWorkRule__r.Name + '\'';
                    System.debug(LoggingLevel.INFO, 'Criteria attributeKey during evaluate ' + attributeKey);
                    String expressionKey = conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__c + '' + conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__SortOrder__c;
                    if (currentAttributeReadings.containsKey(attributeKey)) {
                        currentReading = currentAttributeReadings.get(attributeKey);
                        conditionWrapperRecord = new ConditionWrapper(currentReading, previousTargetReading, conditionRec.SVMXA360__TechnicalAttribute__c, conditionRec.SVMXA360__Operator__c, conditionRec.SVMXA360__Operand__c, attributeDataType,
                                                                        conditionRec.SVMXA360__StartAt__c, conditionRec.SVMXA360__StopAt__c, conditionRec.SVMXA360__Threshold__c);
                        conditionOutput = parseRule(conditionWrapperRecord);
                        booleanStr = (conditionOutput) ? 'T':'F';                                     
                    } 
                    
                    strLogger += '\n' + String.valueOfGmt(system.now()) + ' Output of the condition ' + '\'' + conditionRec.Name + '\'' + ' : ' + conditionOutput;
                    buildExpression(expressionKey, conditionRec.SVMXA360__Sequence__c, booleanStr);
                } else if (conditionRec.SVMXA360__ConditionType__c == 'Time') {
                    DateTime currentReadingGMT = Datetime.now().dateGMT();
                    DateTime nextScheduleDateTime;
                    Integer nDaysBefore = 0;

                    strLogger += '\n' + String.valueOfGmt(system.now()) + ' Evaluating the condition ' + '\'' + conditionRec.Name + '\'' + ' of type \'Time\' for Work Rule ' + '\'' + conditionRec.SVMXA360__MaintenanceWorkRule__r.Name + '\'';
                    conditionWrapperRecord = new ConditionWrapper(String.valueOf(currentReadingGMT), previousTargetReading, conditionRec.SVMXA360__FieldAPIName__c, conditionRec.SVMXA360__Operator__c, conditionRec.SVMXA360__Operand__c, 'Date',
                    conditionRec.SVMXA360__StartAt__c, conditionRec.SVMXA360__StopAt__c, conditionRec.SVMXA360__Threshold__c);
                    
                    if (conditionRec.SVMXA360__RecurrencePattern__c != null) {
                        DateTime lastRunDateTimeGMT = previousTargetReading != null ? DateTime.valueOfGMT(previousTargetReading) : null;
                        nextScheduleDateTime = COMM_RecurrenceRuleHelper.getNextDateFromRRule(conditionRec.SVMXA360__RecurrencePattern__c, lastRunDateTimeGMT);
                    }
                    if (maintenancePlanMap.containsKey(conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c)) {
                        SVMXA360__SM_MaintenancePlan__c mPlanRec = maintenancePlanMap.get(conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c); 
                        nDaysBefore = mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_DaysInAdvance__c != null ? integer.valueOf(mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_DaysInAdvance__c): 0;
                    }

                    if (nextScheduleDateTime != null) {
                        conditionWrapperRecord.nextTargetReading = String.valueOf(nextScheduleDateTime);
                        if (maintenancePlanMap.containsKey(conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c)) {
                            nextScheduleDateTime = nextScheduleDateTime.addDays(-nDaysBefore);
                        }
                        
                        if (currentReadingGMT >= nextScheduleDateTime) {
                            booleanStr = 'T';
                            conditionOutput = true;
                        }
                    }

                    strLogger += '\n' + String.valueOfGmt(system.now()) + ' Output of the condition ' + '\'' + conditionRec.Name + '\'' + ' : ' + conditionOutput;
                    String expressionKey = conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__MaintenancePlanAsset__c + '' + conditionRec.SVMXA360__MaintenanceWorkRule__r.SVMXA360__SortOrder__c;
                    buildExpression(expressionKey, conditionRec.SVMXA360__Sequence__c, booleanStr);  
                }

                if(conditionWrapperRecord != null){
                    conditionWrapperRecord.conditionId = conditionRec.Id;
                    conditionWrapperRecord.conditionName = conditionRec.Name;
                    List<ConditionWrapper> conditionWrapperList = new List<ConditionWrapper>();
                    if(workRuleAttributeReadingMap.containsKey(conditionRec.SVMXA360__MaintenanceWorkRule__c)){
                        conditionWrapperList = workRuleAttributeReadingMap.get(conditionRec.SVMXA360__MaintenanceWorkRule__c);
                    }
                    conditionWrapperList.add(conditionWrapperRecord);
                    workRuleAttributeReadingMap.put(conditionRec.SVMXA360__MaintenanceWorkRule__c, conditionWrapperList);
                }   
                logObj.strLogger += strLogger;
            }

            Set<String> qualifiedWorkRule = new Set<String>();
            for (SVMXA360__SM_MaintenanceWorkRule__c workRuleRec : workRuleList) {
                SVMXA360__SM_MaintenancePlan__c mPlanRec;
                String expressionKey = workRuleRec.SVMXA360__MaintenancePlanAsset__c + '' + workRuleRec.SVMXA360__SortOrder__c;
                if (processLoggerMap.containsKey(workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c)) {
                    logObj = processLoggerMap.get(workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c);
                }
                if (maintenancePlanMap.containsKey(workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c)) {
                    mPlanRec = maintenancePlanMap.get(workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c);
                }
                if (assetWorkRuleExpressionMap.containsKey(expressionKey)) {
                    String advancedExpression = assetWorkRuleExpressionMap.get(expressionKey);
                    if(!qualifiedWorkRule.contains(workRuleRec.Id)) {
                        if (evaluateExpression(advancedExpression)){
                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ' Qualified Work Rule ' + '\'' + workRuleRec.Name + '\'' + ' to generate Work Order for Maintenance Plan ' + '\'' + mPlanRec.Name + ' for Asset ' + '\'' + workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Name + '\'';
                            qualifiedWorkRule.add(workRuleRec.Id);
                            logObj.strLogger = generateWorkOrder(workRuleRec, logObj.strLogger);
                        } else {
                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ' Not Qualified Work Rule ' + '\'' + workRuleRec.Name + '\'' + ' to generate Work Order for Maintenance Plan ' + '\'' + mPlanRec.Name + '\'' + ' for Asset ' + '\'' + workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__r.Name + '\'';
                        }
                    } 
                }
            }


            if (!woRuleMap.isEmpty()){
                SvmxDatabase.insertRecord(woRuleMap.values());                         
            }

            List<SVMXA360__ConditionalOutput__c> conditionalOutputList = new List<SVMXA360__ConditionalOutput__c>();
            Set<Id> woIds = new Set<Id>();
            for (SVMXA360__SM_MaintenanceWorkRule__c workRuleRec : workRuleList) {
                if (processLoggerMap.containsKey(workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c)) {
                    logObj = processLoggerMap.get(workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c);
                }
                if (woRuleMap.containsKey(workRuleRec.Id) && workRuleAttributeReadingMap.containsKey(workRuleRec.Id)) {      
                    SVMXA360__ConditionalOutput__c conditionOutputRec = new SVMXA360__ConditionalOutput__c();    
                    conditionOutputRec.SVMXA360__MaintenancePlanId__c = workRuleRec.SVMXA360__MaintenancePlanAsset__r.SVMXA360__MaintenancePlan__c;
                    conditionOutputRec.SVMXA360__MaintenanceWorkRuleId__c = workRuleRec.Id;
                    WorkOrder woRec = woRuleMap.get(workRuleRec.Id);
                    conditionOutputRec.SVMXA360__WorkOrderId__c = woRec.Id;  
                    woIds.add(conditionOutputRec.SVMXA360__WorkOrderId__c);
                    conditionalOutputList.add(conditionOutputRec);
                }
            }

            if (!conditionalOutputList.isEmpty()){
                List<WorkOrder> workOrderList = SvmxDatabase.query([SELECT Id, WorkOrderNumber FROM WorkOrder WHERE Id IN: woIds]);
                Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder> (workOrderList);
                SvmxDatabase.insertRecord(conditionalOutputList);   
                List<Id> conditionOutputIds = new List<Id>();  
                List<SVMXA360__ConditionalOutputDetail__c> outputDetailList = new List<SVMXA360__ConditionalOutputDetail__c>();   
                for (SVMXA360__ConditionalOutput__c conditionalOutputRec : conditionalOutputList) {
                    String workOrderNumber = '';
                    if (woMap.containsKey(conditionalOutputRec.SVMXA360__WorkOrderId__c)) {
                        workOrderNumber = woMap.get(conditionalOutputRec.SVMXA360__WorkOrderId__c).WorkOrderNumber;
                    }
                    if (processLoggerMap.containsKey(conditionalOutputRec.SVMXA360__MaintenancePlanId__c)) {
                        logObj = processLoggerMap.get(conditionalOutputRec.SVMXA360__MaintenancePlanId__c);
                        logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ' Creating Output Entry for the Work Order ' + '\'' + workOrderNumber + '\''  + ' Generated';
                    }
                    if (workRuleAttributeReadingMap.containsKey(conditionalOutputRec.SVMXA360__MaintenanceWorkRuleId__c)) {
                        conditionOutputIds.add(conditionalOutputRec.Id);
                        for (ConditionWrapper conditionWrapRec : workRuleAttributeReadingMap.get(conditionalOutputRec.SVMXA360__MaintenanceWorkRuleId__c)) {
                            SVMXA360__ConditionalOutputDetail__c outputDetail = new SVMXA360__ConditionalOutputDetail__c ();
                            outputDetail.SVMXA360__AssetConditionId__c = conditionWrapRec.conditionId;
                            outputDetail.SVMXA360__ConditionalOutputId__c = conditionalOutputRec.Id;
                            outputDetail.SVMXA360__AttributeValue__c = conditionWrapRec.currentReading;
                            outputDetail.SVMXA360__ExpectedReading__c = conditionWrapRec.nextTargetReading;
                            outputDetail.SVMXA360__isLatest__c = true;
                            outputDetailList.add(outputDetail);
                            logObj.strLogger += '\n' + String.valueOfGmt(system.now()) + ' Creating Output Entry detail for the Condition ' + '\'' + conditionWrapRec.conditionName + '\'' + ' capturing the current readings';

                        }
                    }
                }    

                for(SVMXA360__ConditionalOutputDetail__c conditionalOutputRec : (List<SVMXA360__ConditionalOutputDetail__c>)SvmxDatabase.query([SELECT Id, SVMXA360__isLatest__c FROM SVMXA360__ConditionalOutputDetail__c WHERE 
                                                        SVMXA360__ConditionalOutputId__c IN: conditionOutputIds AND SVMXA360__isLatest__c = true])){
                    conditionalOutputRec.SVMXA360__isLatest__c = false;      
                    outputDetailList.add(conditionalOutputRec);                                        
                }

                if(!outputDetailList.isEmpty()){
                    SvmxDatabase.upsertRecord(outputDetailList); 
                }
            }   
        }
        catch(Exception ex){
            Database.rollback(sp);
            throw ex;
        }

        return processLoggerMap.values();
    }

    String generateWorkOrder (SVMXA360__SM_MaintenanceWorkRule__c workRule, String strLogger) {
        WorkOrder woRecord = new WorkOrder();

        if (workRuleWorkTypeMap.containsKey(workRule.Id)) {
            woRecord.WorkTypeId = workRuleWorkTypeMap.get(workRule.Id);
        }
        //woRecord.MaintenancePlanId = workRule.SVMXA360__MaintenancePlan__c;
        if (maintenancePlanMap.containsKey(workRule.SVMXA360__MaintenancePlan__c)) {
            SVMXA360__SM_MaintenancePlan__c mPlanRec = maintenancePlanMap.get(workRule.SVMXA360__MaintenancePlan__c);

            if (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__c != null) {
                strLogger += '\n' + String.valueOfGmt(system.now()) + ' Applying Mapping from Maintenance Plan to Work Order ' +  '\'' + mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__r.Name + '\'';
                System.debug(LoggingLevel.info, ' Applying Mapping from Maintenance Plan to Work Order ' +  mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__c);
                woRecord = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping(mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingMPlantoWOId__c, woRecord, mPlanRec);
                strLogger += '\n' + String.valueOfGmt(system.now()) + ' Mapping Applied Successfully ';

            }

            if (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__c != null && workRule.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c != null && assetRecordMap.containsKey(workRule.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c)){
                strLogger += '\n' + String.valueOfGmt(system.now()) + ' Applying Mapping from Asset to Work Order ' + '\'' + mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__r.Name + '\'';
                System.debug(LoggingLevel.info, ' Applying Mapping from Asset to Work Order ' +  mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__c);

                woRecord = (WorkOrder) new CONF_ObjectMappingHandler().applyObjectMapping(mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_MappingAssettoWOId__c, woRecord, assetRecordMap.get(workRule.SVMXA360__MaintenancePlanAsset__r.SVMXA360__Asset__c));
                strLogger += '\n' + String.valueOfGmt(system.now()) + ' Mapping Applied Successfully ';
            }

            if (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignTo__c != null && (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignTo__c.equalsIgnoreCase('User') || 
                                                                                                    mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignTo__c.equalsIgnoreCase('Queue'))) {
                woRecord.OwnerId = mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToValue__c;
            } else if(mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToObjectAPIName__c != null){
                String tempKey;
                if (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToObjectAPIName__c.equalsIgnoreCase('Account')) {
                    tempKey = mPlanRec.SVMXA360__Account__c + '' + '' +  mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToValue__c;
                    if(currentAttributeReadings.containsKey(tempKey)){
                        woRecord.OwnerId = currentAttributeReadings.get(tempKey);
                    }
                } else if (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToObjectAPIName__c.equalsIgnoreCase('SVMXA360__SM_MaintenancePlan__c')) {
                    tempKey = mPlanRec.Id + '' + '' + mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToValue__c;
                    if(currentAttributeReadings.containsKey(tempKey)){
                        woRecord.OwnerId = currentAttributeReadings.get(tempKey);
                    }
                } else if (mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToObjectAPIName__c.equalsIgnoreCase('Asset')){
                    tempKey = workRule.SVMXA360__MaintenancePlanAsset__c + '' + '' + mPlanRec.SVMXA360__MaintenancePlanProcessId__r.SVMXA360__SM_AssignToValue__c;
                    if(currentAttributeReadings.containsKey(tempKey)){
                        woRecord.OwnerId = currentAttributeReadings.get(tempKey);
                    }
                }
            }
        }
        System.debug('Work Order Record ' + woRecord);
        woRuleMap.put(workRule.Id, woRecord);
        return strLogger;
    }

    boolean evaluateExpression(String advancedExpression){
        advancedExpression = advancedExpression.ToUpperCase();
        advancedExpression = advancedExpression.replaceAll('AND', ' && ');
        advancedExpression = advancedExpression.replaceAll('OR', ' || ');
        advancedExpression = advancedExpression.replaceAll('NOT', ' ! ');
        advancedExpression = advancedExpression.trim();
        advancedExpression = advancedExpression.replaceAll(' ','');
        String tempAdvancedExp = '';
        
        System.debug(LoggingLevel.INFO,'advancedExpression Entry : ' + advancedExpression);

        do
        {
            tempAdvancedExp = advancedExpression;
            advancedExpression  = advancedExpression.replace('(F)','F').replace('!T','F').replace('!F','T').replace('(T)','T').replace('F&&F','F').replace('F&&T','F').replace('T&&F','F').replace('T&&T','T').replace('F||F','F').replace('F||T','T').replace('T||F','T').replace('T||T','T');
        }
        while(tempAdvancedExp != advancedExpression);

        System.debug(LoggingLevel.INFO,'advancedExpression output : ' + advancedExpression);

        if(advancedExpression.equals('T')){
            return True;
        }

        return False;
    }

    void mapCurrentAttributeReadings (SVMXA360__SM_TA_AssetTechnicalAttribute__c assetTAReading) {
        String attributeKey = assetTAReading.SVMXA360__AssetId__c + '' + '' + assetTAReading.SVMXA360__AttributeId__c;
        System.debug(LoggingLevel.INFO, 'Criteria attributeKey before evaluate ' + attributeKey);

        switch on assetTAReading.SVMXA360__AttributeId__r.SVMXA360__DataType__c {
            when 'Text' {		
                if (assetTAReading.SVMXA360__Value__c != null) {
                    currentAttributeReadings.put(attributeKey, assetTAReading.SVMXA360__Value__c);
                }
            }	
            when 'Number' {		
                if (assetTAReading.SVMXA360__NumberValue__c != null) {
                    currentAttributeReadings.put(attributeKey, String.valueOf(assetTAReading.SVMXA360__NumberValue__c));
                }                    
            }
            when 'Picklist' {		
                if (assetTAReading.SVMXA360__Value__c != null) {
                    currentAttributeReadings.put(attributeKey, assetTAReading.SVMXA360__Value__c);
                }                     
            }
            when 'Boolean' {
                if (assetTAReading.SVMXA360__BooleanValue__c != null) {
                    currentAttributeReadings.put(attributeKey, String.valueOf(assetTAReading.SVMXA360__BooleanValue__c));
                }                      
            }
            when 'Date' {
                if (assetTAReading.SVMXA360__DateValue__c != null) {
                    currentAttributeReadings.put(attributeKey, String.valueOf(assetTAReading.SVMXA360__DateValue__c));
                }   
            }
            when 'Datetime' {
                if (assetTAReading.SVMXA360__DatetimeValue__c != null) {
                    currentAttributeReadings.put(attributeKey, String.valueOf(assetTAReading.SVMXA360__DatetimeValue__c));
                } 
            }
        }
    }

    boolean parseRule (ConditionWrapper conditionWrapperRecord) {
        //operand is frequency in case of frequency based conditions
        System.debug(LoggingLevel.INFO, 'Parse Rule Enter - Input Param : ' + conditionWrapperRecord);
        if(conditionWrapperRecord.currentReading == null || conditionWrapperRecord.operand == null){
            return false;
        }

        boolean ruleOutput = false;
        if(conditionWrapperRecord.dataType.equalsIgnoreCase('Number') || conditionWrapperRecord.dataType.equalsIgnoreCase('Double') || conditionWrapperRecord.dataType.equalsIgnoreCase('Integer')
             || conditionWrapperRecord.dataType.equalsIgnoreCase('Currency') || conditionWrapperRecord.dataType.equalsIgnoreCase('Percent')) {
            
            Double nextTargetReading = 0;
            Double targetReadingWithThreshold = nextTargetReading;
            Double operandNumeric = Double.valueOf(conditionWrapperRecord.operand);

            if(conditionWrapperRecord.operator.equalsIgnoreCase('Every')){
                nextTargetReading = Double.valueOf(conditionWrapperRecord.startAt);
                targetReadingWithThreshold = nextTargetReading;
                if (conditionWrapperRecord.previousTargetReading != null) {
                    nextTargetReading = Double.valueOf(conditionWrapperRecord.previousTargetReading) + operandNumeric;
                }
                targetReadingWithThreshold = (conditionWrapperRecord.threshold != null && conditionWrapperRecord.threshold != 0) ? nextTargetReading - ((100 - conditionWrapperRecord.threshold/100) * operandNumeric): nextTargetReading;
                if(Double.valueOf(targetReadingWithThreshold) <= Double.valueOf(conditionWrapperRecord.stopAt) && Double.valueOf(conditionWrapperRecord.currentReading) >= Double.valueOf(targetReadingWithThreshold)){
                    ruleOutput = true;
                }
                
            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('Every Decrement')){
                nextTargetReading = Double.valueOf(conditionWrapperRecord.startAt);
                targetReadingWithThreshold = nextTargetReading;
                if (conditionWrapperRecord.previousTargetReading != null) {
                    nextTargetReading = Double.valueOf(conditionWrapperRecord.previousTargetReading) - operandNumeric;
                } 
                targetReadingWithThreshold = (conditionWrapperRecord.threshold != null && conditionWrapperRecord.threshold != 0) ? nextTargetReading - (conditionWrapperRecord.threshold/100 * operandNumeric): nextTargetReading;

                if(Double.valueOf(targetReadingWithThreshold) >= Double.valueOf(conditionWrapperRecord.stopAt) && Double.valueOf(targetReadingWithThreshold) <= Double.valueOf(conditionWrapperRecord.currentReading)){
                    ruleOutput = true;
                }
            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('eq')){
                nextTargetReading = operandNumeric;
                if(Double.valueOf(nextTargetReading) == Double.valueOf(conditionWrapperRecord.currentReading)){
                    ruleOutput = true;
                }
            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('gt')){
                nextTargetReading = operandNumeric;
                if(Double.valueOf(nextTargetReading) > Double.valueOf(conditionWrapperRecord.currentReading)){
                    ruleOutput = true;
                }
            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('lt')){
                nextTargetReading = operandNumeric;
                if(Double.valueOf(nextTargetReading) < Double.valueOf(conditionWrapperRecord.currentReading)){
                    ruleOutput = true;
                }
            }
            conditionWrapperRecord.nextTargetReading = nextTargetReading != null ? String.valueOf(nextTargetReading) : null ;

		}else if(conditionWrapperRecord.dataType.equalsIgnoreCase('Date')) {
            Date nextTargetReading;   
            Date currentReading = Date.valueOf(conditionWrapperRecord.currentReading);  
            if (conditionWrapperRecord.nDaysBefore != null ) {
                currentReading = currentReading.addDays(conditionWrapperRecord.nDaysBefore);       
            }
            if(conditionWrapperRecord.operator.equalsIgnoreCase('Every')){
                if (conditionWrapperRecord.previousTargetReading == null) {
                    conditionWrapperRecord.previousTargetReading = conditionWrapperRecord.startAt;
                } 
                //For time frequency we are using recurrence pattern, below code is not required and commented for time being.
                /*if (conditionWrapperRecord.attribute.equalsIgnoreCase('Weeks')) {
                    nextTargetReading = Date.valueOf(conditionWrapperRecord.previousTargetReading).addDays(integer.valueOf(conditionWrapperRecord.operand) * 7);
                } else if (conditionWrapperRecord.attribute.equalsIgnoreCase('Months')) {
                    nextTargetReading = Date.valueOf(conditionWrapperRecord.previousTargetReading).addMonths(integer.valueOf(conditionWrapperRecord.operand));
                } else if (conditionWrapperRecord.attribute.equalsIgnoreCase('Years')) {
                    nextTargetReading = Date.valueOf(conditionWrapperRecord.previousTargetReading).addYears(integer.valueOf(conditionWrapperRecord.operand));
                }*/

                if(Date.valueOf(nextTargetReading) <= Date.valueOf(conditionWrapperRecord.stopAt) && currentReading >= Date.valueOf(nextTargetReading)){
                    ruleOutput = true;
                }

            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('eq')){
                if(Date.valueOf(conditionWrapperRecord.operand) == currentReading){
                    ruleOutput = true;
                }
            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('gt')){
                if(currentReading > Date.valueOf(conditionWrapperRecord.operand)){
                    ruleOutput = true;
                }
            }else if(conditionWrapperRecord.operator.equalsIgnoreCase('lt')){
                if(currentReading < Date.valueOf(conditionWrapperRecord.operand)){
                    ruleOutput = true;
                }
            }
            conditionWrapperRecord.nextTargetReading = nextTargetReading != null ? String.valueOf(nextTargetReading) : null ;
        }else if(conditionWrapperRecord.dataType.equalsIgnoreCase('Picklist') || conditionWrapperRecord.dataType.equalsIgnoreCase('Text') || conditionWrapperRecord.dataType.equalsIgnoreCase('String')
                || conditionWrapperRecord.dataType.equalsIgnoreCase('TextArea')) {
            if(conditionWrapperRecord.currentReading.equalsIgnoreCase(conditionWrapperRecord.operand)){
                ruleOutput = true;
            }            
        }
        
        System.debug(LoggingLevel.INFO, 'Parse Rule Exit - Output : ' + ruleOutput);
		return ruleOutput;
   	}

    String getQueryFieldString(Set<String> assetFields){
        String queryFields='';
        for (String field : assetFields) {
            if (queryFields.length()>0) {
                queryFields += ',';
            }
            queryFields += field;
        } 
        return queryFields;  
    }

    void buildExpression(String expressionKey, Decimal conditionSequence, String booleanStr){
        if ((expressionKey != null || expressionKey != '') && assetWorkRuleExpressionMap.containsKey(expressionKey)) {
            String advancedExpression = assetWorkRuleExpressionMap.get(expressionKey);

            if (conditionSequence != null){
                String sequenceStr = String.valueOf(Integer.valueOf(conditionSequence));
                advancedExpression = advancedExpression.replaceAll(sequenceStr, booleanStr);
                assetWorkRuleExpressionMap.put(expressionKey, advancedExpression);
            } 

        }
    }

    String getFieldDataType(String fieldAPIName){
        Map<String, Schema.DescribeFieldResult> fieldDescribeResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults(techAttributeObject);
        String dataTyeString;
        if (fieldDescribeResultMap.containsKey(fieldAPIName)) {
            Schema.DescribeFieldResult describeFldResult = fieldDescribeResultMap.get(fieldAPIName);
            Schema.DisplayType fieldDataType = describeFldResult.getType();
            dataTyeString = String.valueOf(fieldDataType);
        }
        return dataTyeString;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public class ConditionWrapper {
        public String conditionId;
        public String conditionName;
        public String startAt;
        public String stopAt;
        public String currentReading;
        public String previousTargetReading;
        public String nextTargetReading;
        public String attribute;
        public String operator;
        public String operand;
        public String dataType;
        public Decimal threshold;
        public integer nDaysBefore;
        public ConditionWrapper (String currentReading, String previousTargetReading, String attribute, String operator, String operand, String dataType,
                                String startAt, String stopAt, Decimal threshold){
            this.conditionId = conditionId;
            this.currentReading = currentReading;
            this.previousTargetReading = previousTargetReading;
            this.attribute = attribute;
            this.operator = operator;
            this.operand = operand;
            this.dataType = dataType;
            this.startAt = startAt;
            this.stopAt = stopAt;
            this.threshold = threshold;
        }
    }

    public class ProcessLogger{
        public String planId;
        public String planName;
        public String strLogger;
        public String processId;
        public String processName;
        public String status;
    }
}