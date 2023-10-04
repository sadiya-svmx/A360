/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods with actual implementation which will be
 * comsumed by the class ADM_MaintenanceProcess_LS.
 * 
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                23 May 2023     Created.
 *****************************************************************************************************/
public with sharing class ADM_MaintenanceProcessManager {
    private static final ADM_MaintenanceProcessManager instance = new ADM_MaintenanceProcessManager ();
    
    /**
     * Public method to retrieve instance of this class.
     */
    public static ADM_MaintenanceProcessManager getInstance() {
        return instance;
    }

    public List<Adm.MaintenacePlanProcess> getProcessList () {
        System.debug( LoggingLevel.DEBUG, 'getProcessList() - enter');
        List<Adm.MaintenacePlanProcess> processList = new List<Adm.MaintenacePlanProcess>();

        try {
            for (SVMXA360__SM_MaintenancePlanProcess__c processRec : (List<SVMXA360__SM_MaintenancePlanProcess__c>)SvmxDatabase.query([SELECT Id, Name, SVMXA360__SM_Description__c, SVMXA360__SM_Standard__c, SVMXA360__SM_isActive__c, 
                                LastModifiedDate, SVMXA360__SM_LastRunDate__c, SVMXA360__SM_LastRunStatus__c FROM SVMXA360__SM_MaintenancePlanProcess__c])){
                Adm.MaintenacePlanProcess mplanProcessRecord = new Adm.MaintenacePlanProcess();
                mplanProcessRecord.id = processRec.Id;
                mplanProcessRecord.name = processRec.Name;
                mplanProcessRecord.description = processRec.SVMXA360__SM_Description__c;
                mplanProcessRecord.isActive = processRec.SVMXA360__SM_isActive__c;
                mplanProcessRecord.isDefault = processRec.SVMXA360__SM_Standard__c;
                mplanProcessRecord.lastModifiedDate = processRec.LastModifiedDate; 
                mplanProcessRecord.lastRan = processRec.SVMXA360__SM_LastRunDate__c;
                mplanProcessRecord.lastRunStatus =  processRec.SVMXA360__SM_LastRunStatus__c;
                processList.add(mplanProcessRecord);               
            }

        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'getProcessList() : Failed to retrieve maintenance plan process. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessList() - exit');
        }
        return processList;
    }

    /**
     * This method is used to delete maintenance plan process record 
     * for requested process id.
     */
    public void deleteProcess (final String processId) {
        System.debug( LoggingLevel.DEBUG, 'deleteProcess() - enter; processId = '+ processId );

        try {
            if (String.isBlank( processId ) ) {
                System.debug( LoggingLevel.ERROR, 'deleteProcess() : Invalid request parameters. processId= ' + processId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<SVMXA360__SM_MaintenancePlanProcess__c> processRecord = SvmxDatabase.query([SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE Id =: processId]);
            SvmxDatabase.deleteRecord(processRecord);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcess() : Failed to delete maintenance plan process. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteProcess() : Failed to delete maintenance plan process. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcess() - exit');
        }
    }

    public void runProcessEngine (final List<String> processIds) {
        System.debug( LoggingLevel.DEBUG, 'runProcessEngine() - enter; processIds = '+ processIds );
        Boolean isExceptionThrown = false;
        try {
            if ( processIds == null || processIds.isEmpty()) {
                System.debug( LoggingLevel.ERROR, 'runProcessEngine() : Invalid request parameters. processIds= ' + processIds );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            MPLN_ProcessBatch mplnProcessBatch = new MPLN_ProcessBatch(processIds); 
            Database.executeBatch(mplnProcessBatch);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            isExceptionThrown = true;
            System.debug( LoggingLevel.ERROR, 'runProcessEngine() : Failed to run engine. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            isExceptionThrown = true;
            System.debug( LoggingLevel.ERROR, 'runProcessEngine() : Failed to run engine. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            List<SVMXA360__SM_MaintenancePlanProcess__c> processList = new List<SVMXA360__SM_MaintenancePlanProcess__c>();

            for (String processId : processIds) {
                SVMXA360__SM_MaintenancePlanProcess__c processRec = new SVMXA360__SM_MaintenancePlanProcess__c(Id = processId);
                processRec.SVMXA360__SM_LastRunStatus__c = isExceptionThrown ? 'Failure' : 'Running';
                processList.add(processRec);
            }

            SvmxDatabase.updateRecord(processList);
            System.debug( LoggingLevel.DEBUG, 'runProcessEngine() - exit');
        }
    }

    /**
     * This method is used to fetch supported queues 
     * for given sobject.
     */
    public List<String> getSObjectSupportedQueues (final String objectAPIName) {
        System.debug( LoggingLevel.DEBUG, 'getSObjectSupportedQueues() - enter; objectAPIName = '+ objectAPIName );
        List<String> queueIds = new List<String>();

        try {
            if (String.isBlank( objectAPIName ) ) {
                System.debug( LoggingLevel.ERROR, 'getSObjectSupportedQueues() : Invalid request parameters. objectAPIName= ' + objectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            for(QueueSobject sobjectRec : (List<QueueSobject>)SvmxDatabase.query([SELECT Id, QueueId FROM QueueSobject WHERE SobjectType =: objectAPIName])){
                queueIds.add(sobjectRec.QueueId);
            }
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'getSObjectSupportedQueues() : Failed to retrieve queues. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSObjectSupportedQueues() - exit');
        }

        return queueIds;

    }

    /**
     * This method is used to retreieve maintenance plan process record 
     * for requested process id.
     */
    public Adm.MaintenancePlanProcessDetail getProcessDetails (final String processId) {
        System.debug( LoggingLevel.DEBUG, 'getProcessDetails - enter; processId = '+ processId );
        
        Adm.MaintenancePlanProcessDetail processDetail;
        try {
            if (String.isBlank( processId ) ) {
                System.debug( LoggingLevel.ERROR, 'getProcessDetails() : Invalid request parameters. processId= ' + processId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<SVMXA360__SM_MaintenancePlanProcess__c> processRecord = SvmxDatabase.query([SELECT Id, Name, SVMXA360__SM_isActive__c, SVMXA360__SM_AssignTo__c, SVMXA360__SM_AssignToObjectAPIName__c, SVMXA360__SM_AssignToValue__c, 
                                            SVMXA360__SM_DaysInAdvance__c, SVMXA360__SM_Description__c, SVMXA360__SM_DeveloperName__c, SVMXA360__SM_MappingAssettoWOId__c, SVMXA360__SM_MappingMPlantoWOId__c, SVMXA360__SM_SendFailureEmailTo__c, 
                                            SVMXA360__SM_SendSuccessEmailTo__c, SVMXA360__SM_Standard__c, LastModifiedDate, SVMXA360__RecurrencePattern__c, SVMXA360__SM_RunAt__c, SVMXA360__SM_TimeZone__c, SVMXA360__SM_LastRunDate__c, 
                                            SVMXA360__EnableDetailedLoggingNotifications__c, SVMXA360__SM_LastRunStatus__c FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE Id =: processId]);
                                        
            
            if (!processRecord.isEmpty()) {
                processDetail = mapProcessRecord(processRecord[0]);
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProcessDetails() : Failed to retreieve maintenance plan process. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'getProcessDetails() : Failed to retreieve maintenance plan process. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessDetails() - exit');
        }       
        
        return processDetail;

    }

    /**
     * This method is used to save maintenance plan process record 
     * from the request data.
    */
    public Adm.MaintenancePlanProcessDetail saveProcessDetails (final Adm.MaintenancePlanProcessDetail processDetail) {
        System.debug( LoggingLevel.DEBUG, 'saveProcessDetails - enter; processDetail = '+ processDetail );
        
        try {
            if (processDetail == null) {
                System.debug( LoggingLevel.ERROR, 'saveProcessDetails() : Invalid request parameters. processDetail= ' + processDetail );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }  

            if (processDetail.isDefault != null && processDetail.isDefault) {
                List<SVMXA360__SM_MaintenancePlanProcess__c> defaultProcessList = SvmxDatabase.query([SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c 
                                                                WHERE SVMXA360__SM_Standard__c = true AND Id !=: processDetail.id]);
                if (!defaultProcessList.isEmpty()) {
                    throw new SvmxSystem.SvmxNestedException( System.Label.Message_DefaultProcessValidation );
                }
            }
            
            SVMXA360__SM_MaintenancePlanProcess__c processRecord = mapProcessDetail (processDetail);
            processRecord = (SVMXA360__SM_MaintenancePlanProcess__c) SvmxDatabase.upsertRecord(processRecord);
            processDetail.id = processRecord.Id;
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            
            System.debug( LoggingLevel.ERROR, 'saveProcessDetails() : Failed to save maintenance plan process. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'saveProcessDetails() : Failed to save maintenance plan process. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessDetails() - exit; processDetail= ' + processDetail );
        }

        return processDetail;
    }
    
    public Adm.ValidationResult validateMaintenanceProcess( final Adm.MaintenancePlanProcessDetail maintenancePlanProcess, final List<Adm.ReferenceData> referenceDatas ) {
        return validateMaintenanceProcesses( new List<Adm.MaintenancePlanProcessDetail>{maintenancePlanProcess}, referenceDatas).get(0);
    }
    
    public List<Adm.ValidationResult> validateMaintenanceProcesses( final List<Adm.MaintenancePlanProcessDetail> maintenancePlanProcessList, final List<Adm.ReferenceData> referenceDatas ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateMaintenanceProcess() - enter; maintenancePlanProcessList= ' + maintenancePlanProcessList );
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        try {
            
            final Set<String> mappingSet = new Set<String>();
			List<SVMXA360__CONF_ObjectMapping__c> mappingList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ObjectMapping__c] );
            
            for( SVMXA360__CONF_ObjectMapping__c mappingRecord : mappingList ) {
                mappingSet.add(mappingRecord.SVMXA360__DeveloperName__c);
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                
                if( referenceData.configType != Adm.ConfigurationType.Mapping ) {
                    continue;
                }
                
                for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                    mappingSet.add(configurationData.developerName);
                }
            }
            
            for( Adm.MaintenancePlanProcessDetail maintenancePlanProcessDetail : maintenancePlanProcessList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.MaintenancePlanProcess );
                validationResults.add( validationResult );
                
                if( String.isNotBlank(maintenancePlanProcessDetail.mPlanToWOMappingId) && !mappingSet.contains(maintenancePlanProcessDetail.mPlanToWOMappingId) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.MaintenancePlanProcess, 'Object Mapping MPLN to Work Order does not exists : '+ maintenancePlanProcessDetail.mPlanToWOMappingId ) );
                }
                
                if( String.isNotBlank(maintenancePlanProcessDetail.assetToWOMappingId) && !mappingSet.contains(maintenancePlanProcessDetail.assetToWOMappingId) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.MaintenancePlanProcess, 'Object Mapping Asset to Work Order does not exists : '+ maintenancePlanProcessDetail.assetToWOMappingId ) );
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Save config Template . Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigTemplates() - exit; validationResults= ' + validationResults );
        }
        return validationResults;
    }

    Adm.MaintenancePlanProcessDetail mapProcessRecord (SVMXA360__SM_MaintenancePlanProcess__c processRecord) {
        Adm.MaintenancePlanProcessDetail processDetail = new Adm.MaintenancePlanProcessDetail();
        processDetail.id = processRecord.Id;
        processDetail.name = processRecord.Name;
        processDetail.description = processRecord.SVMXA360__SM_Description__c;
        processDetail.isActive = processRecord.SVMXA360__SM_isActive__c;
        processDetail.isDefault = processRecord.SVMXA360__SM_Standard__c;
        processDetail.lastModifiedDate = processRecord.LastModifiedDate;
        processDetail.assignTo = processRecord.SVMXA360__SM_AssignTo__c;
        processDetail.assignToObject = processRecord.SVMXA360__SM_AssignToObjectAPIName__c;
        processDetail.nDaysBefore = processRecord.SVMXA360__SM_DaysInAdvance__c;
        processDetail.assignToValue = processRecord.SVMXA360__SM_AssignToValue__c;
        processDetail.developerName = processRecord.SVMXA360__SM_DeveloperName__c;
        processDetail.assetToWOMappingId = processRecord.SVMXA360__SM_MappingAssettoWOId__c;
        processDetail.mPlanToWOMappingId = processRecord.SVMXA360__SM_MappingMPlantoWOId__c;
        processDetail.sendFailureEmail = processRecord.SVMXA360__SM_SendFailureEmailTo__c;
        processDetail.sendSuccessEmail = processRecord.SVMXA360__SM_SendSuccessEmailTo__c;
        processDetail.recurrencePattern = processRecord.SVMXA360__RecurrencePattern__c;
        processDetail.runAt = processRecord.SVMXA360__SM_RunAt__c;
        processDetail.timeZone = processRecord.SVMXA360__SM_TimeZone__c;
        processDetail.lastRunDate = processRecord.SVMXA360__SM_LastRunDate__c;
        processDetail.lastRunStatus = processRecord.SVMXA360__SM_LastRunStatus__c;
        processDetail.detailLogNotification = processRecord.SVMXA360__EnableDetailedLoggingNotifications__c;

        return processDetail;
    }

    SVMXA360__SM_MaintenancePlanProcess__c mapProcessDetail (Adm.MaintenancePlanProcessDetail processDetail) {
        SVMXA360__SM_MaintenancePlanProcess__c processRecord = new SVMXA360__SM_MaintenancePlanProcess__c();
        if (processDetail.id != null) {
            processRecord.Id = processDetail.id;
        }
        processRecord.Name = processDetail.name;
        processRecord.SVMXA360__SM_Description__c = processDetail.description;
        processRecord.SVMXA360__SM_isActive__c = processDetail.isActive;
        processRecord.SVMXA360__SM_Standard__c = processDetail.isDefault;
        processRecord.SVMXA360__SM_AssignTo__c = processDetail.assignTo;
        processRecord.SVMXA360__SM_DaysInAdvance__c = processDetail.nDaysBefore;
        processRecord.SVMXA360__SM_AssignToValue__c = processDetail.assignToValue;
        processRecord.SVMXA360__SM_AssignToObjectAPIName__c = processDetail.assignToObject;
        processRecord.SVMXA360__SM_DeveloperName__c = processDetail.developerName;
        processRecord.SVMXA360__SM_MappingAssettoWOId__c = processDetail.assetToWOMappingId;
        processRecord.SVMXA360__SM_MappingMPlantoWOId__c = processDetail.mPlanToWOMappingId;
        processRecord.SVMXA360__SM_SendFailureEmailTo__c = processDetail.sendFailureEmail;
        processRecord.SVMXA360__SM_SendSuccessEmailTo__c = processDetail.sendSuccessEmail;
        processRecord.SVMXA360__RecurrencePattern__c = processDetail.recurrencePattern;
        processRecord.SVMXA360__SM_RunAt__c = processDetail.runAt;
        processRecord.SVMXA360__SM_TimeZone__c = processDetail.timeZone;
        processRecord.SVMXA360__EnableDetailedLoggingNotifications__c = processDetail.detailLogNotification;

        return processRecord;

    }

}