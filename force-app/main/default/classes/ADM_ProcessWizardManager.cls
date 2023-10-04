/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/save/delete process wizards.
 *
 * @author Ryan Follmer
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ryan Follmer            14 August 2020  Created.
 *****************************************************************************************************/
public with sharing class ADM_ProcessWizardManager {
    
    private static final String ERROR_REQUIRED_FIELD        =   '{0} is required.';
    
    /**
     * Static variable to hold instance of this class.
     */
    private static ADM_ProcessWizardManager instance = null;
    
    /**
     * Static variable to hold process wizard wrapper details for each processWizardId queried.
     */
    private static Map<String, Adm.ProcessWizard> wizardWrapperMap = new Map<String, Adm.ProcessWizard>();
    
    /**
     * Static variable to hold Process Wizard records.
     */
    private static Map<String, SVMXA360__CONF_ProcessWizard__c> wizardRecordMap = new Map<String, SVMXA360__CONF_ProcessWizard__c>();

    /**
     * Static variable to hold Process Wizard step parameters records.
     */
    private static Map<String, List<Adm.ProcessStepParameter>> stepParametersMap = new Map<String, List<Adm.ProcessStepParameter>>();
 
    /**
     * Static variable to hold Process Wizard step dependency records.
     */
    private static Map<String, List<Adm.DependentStep>> stepDependencyMap = new Map<String, List<Adm.DependentStep>>();

    private static Map<Id,String> profileNameMap = new Map<Id,String>();
    /**
     * Private constructor to restrict multiple instance creation of this class.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private ADM_ProcessWizardManager() {
    }

    /**
     * Static method to return instance of this class.
     */
    public static ADM_ProcessWizardManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_ProcessWizardManager();
        }
        
        return instance;
    }

    /**
     * This method is used to retrieve a collection of all active process wizard records, and related child step and access records. 
     */
    public List<SVMXA360__CONF_ProcessWizard__c> getAllActiveProcessWizardsRecordsWithDetail() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList;
        
        try {
            wizardRecordList = SvmxDatabase.query(
                    [ 
                    SELECT 
                    SVMXA360__Active__c, 
                    SVMXA360__Description__c, 
                    SVMXA360__DeveloperName__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__Scope__c,
                    SVMXA360__Sequence__c,
                    SVMXA360__VisibilityCriteria__c,
                    SVMXA360__VisibilityCriteria__r.Name,
                    SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                    Id,
                    LastModifiedDate,
                    LastModifiedBy.Name, 
                    Name,
                    SVMXA360__StepCompletionType__c,
                    (SELECT Id, 
                        Name, 
                        SVMXA360__Namespace__c, 
                        SVMXA360__ProcessWizard__c, 
                        SVMXA360__Target__c, 
                        SVMXA360__Type__c, 
                        SVMXA360__VisibilityCriteria__c, 
                        SVMXA360__VisibilityCriteria__r.Name,
                        SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                        SVMXA360__CriteriaAction__c,
                        SVMXA360__CriteriaActionHelpText__c,
                        SVMXA360__HelpText__c,
                        SVMXA360__Sequence__c,
                        SVMXA360__OpenAsModal__c,
                        SVMXA360__iconName__c,
                        LastModifiedDate,
                        LastModifiedBy.Name,
                        SVMXA360__StepDependencyFlag__c,
                        SVMXA360__DeveloperName__c                            
                    FROM SVMXA360__Process_Wizard_Steps__r
                    ORDER BY SVMXA360__Sequence__c),
                    (SELECT Id, 
                        SVMXA360__ProcessWizard__c, 
                        SVMXA360__ProfileId__c,
                        Name,
                        LastModifiedDate,
                        LastModifiedBy.Name                             
                    FROM SVMXA360__Process_Wizard_Access__r)
                FROM SVMXA360__CONF_ProcessWizard__c
                WHERE SVMXA360__Active__c = true 
                ORDER BY SVMXA360__Sequence__c]);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllActiveProcessWizardsRecordsWithDetail() : Failed to retrieve All Active Process Wizards Records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllActiveProcessWizardsRecordsWithDetail() - exit;');
        }
        
        return wizardRecordList;
    }
    
    /**
     * This method is used to retrieve a collection of all active process wizard records, and related child step and access records. 
     */
    public List<SVMXA360__CONF_ProcessWizard__c> getAllProcessWizardsRecordsWithDetail() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList;
        
        try {
            wizardRecordList = SvmxDatabase.query(
                    [ 
                    SELECT 
                    SVMXA360__Active__c, 
                    SVMXA360__Description__c, 
                    SVMXA360__DeveloperName__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__Scope__c,
                    SVMXA360__Sequence__c,
                    SVMXA360__VisibilityCriteria__c,
                    SVMXA360__VisibilityCriteria__r.Name,
                    SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                    Id,
                    LastModifiedDate,
                    LastModifiedBy.Name, 
                    Name,
                    SVMXA360__StepCompletionType__c,
                    (SELECT Id, 
                        Name, 
                        SVMXA360__Namespace__c, 
                        SVMXA360__ProcessWizard__c, 
                        SVMXA360__Target__c, 
                        SVMXA360__Type__c, 
                        SVMXA360__VisibilityCriteria__c, 
                        SVMXA360__VisibilityCriteria__r.Name,
                        SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                        SVMXA360__CriteriaAction__c,
                        SVMXA360__CriteriaActionHelpText__c,
                        SVMXA360__HelpText__c,
                        SVMXA360__Sequence__c,
                        SVMXA360__OpenAsModal__c,
                        SVMXA360__iconName__c,
                        LastModifiedDate,
                        LastModifiedBy.Name,
                        SVMXA360__StepDependencyFlag__c,
                        SVMXA360__DeveloperName__c
                    FROM SVMXA360__Process_Wizard_Steps__r
                    ORDER BY SVMXA360__Sequence__c),
                    (SELECT Id, 
                        SVMXA360__ProcessWizard__c, 
                        SVMXA360__ProfileId__c,
                        Name,
                        LastModifiedDate,
                        LastModifiedBy.Name                             
                    FROM SVMXA360__Process_Wizard_Access__r)
                FROM SVMXA360__CONF_ProcessWizard__c
                ORDER BY SVMXA360__Sequence__c]);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllProcessWizardsRecordsWithDetail() : Failed to retrieve All Active Process Wizards Records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllProcessWizardsRecordsWithDetail() - exit;');
        }
        
        return wizardRecordList;
    }

    /**
     * This method is used to retrieve a collection of process wizard records, and related child step and access records for the requested object API Name. 
     */
    public List<SVMXA360__CONF_ProcessWizard__c> getProcessWizardsByRecordsObjectWithDetail( final String objectApiName ) {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList;
        
        try {
            
            if( String.isBlank(objectApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            wizardRecordList = SvmxDatabase.query(
                    [ 
                    SELECT 
                    SVMXA360__Active__c, 
                    SVMXA360__Description__c, 
                    SVMXA360__DeveloperName__c,
                    SVMXA360__ObjectAPIName__c,
                    SVMXA360__Scope__c,
                    SVMXA360__Sequence__c,
                    SVMXA360__VisibilityCriteria__c,
                    SVMXA360__VisibilityCriteria__r.Name,
                    SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                    Id,
                    LastModifiedDate,
                    LastModifiedBy.Name, 
                    Name,
                    SVMXA360__StepCompletionType__c,
                    (SELECT Id, 
                        Name, 
                        SVMXA360__Namespace__c, 
                        SVMXA360__ProcessWizard__c, 
                        SVMXA360__Target__c, 
                        SVMXA360__Type__c, 
                        SVMXA360__VisibilityCriteria__c, 
                        SVMXA360__VisibilityCriteria__r.Name,
                        SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                        SVMXA360__CriteriaAction__c,
                        SVMXA360__CriteriaActionHelpText__c,
                        SVMXA360__HelpText__c,
                        SVMXA360__Sequence__c,
                        SVMXA360__OpenAsModal__c,
                        SVMXA360__iconName__c,
                        LastModifiedDate,
                        LastModifiedBy.Name,
                        SVMXA360__StepDependencyFlag__c,
                        SVMXA360__DeveloperName__c
                    FROM SVMXA360__Process_Wizard_Steps__r
                    ORDER BY SVMXA360__Sequence__c),
                    (SELECT Id, 
                        SVMXA360__ProcessWizard__c, 
                        SVMXA360__ProfileId__c,
                        Name,
                        LastModifiedDate,
                        LastModifiedBy.Name                             
                    FROM SVMXA360__Process_Wizard_Access__r)
                FROM SVMXA360__CONF_ProcessWizard__c
                WHERE SVMXA360__ObjectAPIName__c = :objectApiName 
                ORDER BY SVMXA360__Sequence__c]);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardsByRecordsObjectWithDetail() : Failed to retrieve Process Wizards By Object. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardsByRecordsObjectWithDetail() - exit; objectApiName=' + objectApiName );
        }
        
        return wizardRecordList;
    }

    /**
     * This method is used to retrieve a collection of active process wizard records, and related child step and access records for the requested object API Name. 
     */
    public List<SVMXA360__CONF_ProcessWizard__c> getActiveProcessWizardsByRecordsObjectWithDetail( final String objectApiName ) {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = new List<SVMXA360__CONF_ProcessWizard__c>();
        
        try {
            
            if( String.isBlank(objectApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
	    System.debug('Profile Id: '+UserInfo.getProfileId());
            System.debug('Object API name: '+objectApiName);
            List<SVMXA360__CONF_ProcessWizardAccess__c> accessRecords = SvmxDatabase.query([ 
                SELECT SVMXA360__ProcessWizard__c from
                                                                                             
                SVMXA360__CONF_ProcessWizardAccess__c WHERE
                                                                                             SVMXA360__ProcessWizard__r.SVMXA360__ObjectAPIName__c = :objectApiName and
                                                                                             SVMXA360__ProcessWizard__r.SVMXA360__Active__c = true and
                                                                                             SVMXA360__ProfileId__c = :UserInfo.getProfileId()
                                                                                           ]);
            if(!accessRecords.isEmpty()){
                Set<Id> wizardIds = new Set<Id>();
                for (SVMXA360__CONF_ProcessWizardAccess__c accessRec : accessRecords){
                    wizardIds.add(accessRec.SVMXA360__ProcessWizard__c);
                }
                wizardRecordList = SvmxDatabase.query(
                    [ 
                        SELECT 
                        SVMXA360__Active__c, 
                        SVMXA360__Description__c, 
                        SVMXA360__DeveloperName__c,
                        SVMXA360__ObjectAPIName__c,
                        SVMXA360__Scope__c,
                        SVMXA360__Sequence__c,
                        SVMXA360__VisibilityCriteria__c,
                        SVMXA360__VisibilityCriteria__r.Name,
                        SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                        Id,
                        LastModifiedDate,
                        LastModifiedBy.Name, 
                        Name,
                        SVMXA360__StepCompletionType__c,
                        (SELECT Id, 
                            Name, 
                            SVMXA360__Namespace__c, 
                            SVMXA360__ProcessWizard__c, 
                            SVMXA360__Target__c, 
                            SVMXA360__Type__c, 
                            SVMXA360__VisibilityCriteria__c, 
                            SVMXA360__VisibilityCriteria__r.Name,
                         	SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                            SVMXA360__CriteriaAction__c,
                            SVMXA360__CriteriaActionHelpText__c,
                            SVMXA360__HelpText__c,
                            SVMXA360__Sequence__c,
                            SVMXA360__OpenAsModal__c,
                            SVMXA360__iconName__c,
                            LastModifiedDate,
                            LastModifiedBy.Name,
                            SVMXA360__StepDependencyFlag__c,
                            SVMXA360__DeveloperName__c
                        FROM SVMXA360__Process_Wizard_Steps__r order by SVMXA360__Sequence__c )
                    FROM SVMXA360__CONF_ProcessWizard__c
                    WHERE Id in :wizardIds order by SVMXA360__Sequence__c]);
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getActiveProcessWizardsByRecordsObjectWithDetail() : Failed to retrieve Process Wizards By Object. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getActiveProcessWizardsByRecordsObjectWithDetail() - exit; objectApiName=' + objectApiName );
        }
        
        return wizardRecordList;
    }

    /**
     * This method is used to retrieve a single process wizard record, and related child step and access records for the requested process wizard record ID. 
     */
    public SVMXA360__CONF_ProcessWizard__c getProcessWizardRecordsWithDetail( final String processWizardId ) {
        SVMXA360__CONF_ProcessWizard__c wizardRecord;
        
        try {
            
            if( String.isBlank(processWizardId ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            if( !wizardRecordMap.containsKey( processWizardId ) ) {
                List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = SvmxDatabase.query(
                        [ 
                        SELECT 
                        SVMXA360__Active__c, 
                        SVMXA360__Description__c, 
                        SVMXA360__DeveloperName__c,
                        SVMXA360__ObjectAPIName__c,
                        SVMXA360__Scope__c,
                        SVMXA360__Sequence__c,
                        SVMXA360__VisibilityCriteria__c,
                        SVMXA360__VisibilityCriteria__r.Name,
                        SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                        Id,
                        LastModifiedDate,
                        LastModifiedBy.Name, 
                        Name,
                        SVMXA360__StepCompletionType__c,
                        (SELECT Id, 
                            Name, 
                            SVMXA360__Namespace__c, 
                            SVMXA360__ProcessWizard__c, 
                            SVMXA360__Target__c, 
                            SVMXA360__Type__c, 
                            SVMXA360__VisibilityCriteria__c, 
                            SVMXA360__VisibilityCriteria__r.Name,
                            SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c,
                            SVMXA360__CriteriaAction__c,
                            SVMXA360__CriteriaActionHelpText__c,
                            SVMXA360__HelpText__c,
                            SVMXA360__Sequence__c,
                            SVMXA360__OpenAsModal__c,
                            SVMXA360__iconName__c,
                            LastModifiedDate,
                            LastModifiedBy.Name,
                            SVMXA360__StepDependencyFlag__c,
                            SVMXA360__DeveloperName__c
                        FROM SVMXA360__Process_Wizard_Steps__r 
                        ORDER BY SVMXA360__Sequence__c),
                        (SELECT Id, 
                            SVMXA360__ProcessWizard__c, 
                            SVMXA360__ProfileId__c,
                            Name,
                            LastModifiedDate,
                            LastModifiedBy.Name                             
                        FROM SVMXA360__Process_Wizard_Access__r)
                    FROM SVMXA360__CONF_ProcessWizard__c
                    WHERE Id = :processWizardId ]);

                if( wizardRecordList.size() > 0 ) {
                    wizardRecordMap.put(processWizardId, wizardRecordList.get(0) );
                }
            }
            
            wizardRecord = wizardRecordMap.get(processWizardId);
            
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardRecordsWithDetail() : Failed to retrieve Process Wizard. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardRecordsWithDetail() - exit; processWizardId=' + processWizardId );
        }
        
        return wizardRecord;
    }
    /**
     * This method is used to retrieve a collection of process wizard summary information.
     */
    public List<Adm.ProcessWizardSummary> getProcessWizardSummary() {

        System.debug( LoggingLevel.DEBUG, 'getProcessWizardSummary() - enter;' );
        
        List<Adm.ProcessWizardSummary> summaries = new List<Adm.ProcessWizardSummary>();
            
        try {
            List<AggregateResult> groupedResults = [SELECT SVMXA360__ObjectAPIName__c, SVMXA360__Active__c, LastModifiedBy.Name LastModifiedByUser, 
                                                    Count(Id) WizardCount, Max(LastModifiedDate) LastModified
                                                    FROM SVMXA360__CONF_ProcessWizard__c WITH SECURITY_ENFORCED
                                                    GROUP BY SVMXA360__ObjectAPIName__c, SVMXA360__Active__c, LastModifiedBy.Name
                                                    ORDER BY SVMXA360__ObjectAPIName__c, SVMXA360__Active__c, LastModifiedBy.Name];
            
            if (groupedResults != null && groupedResults.size() > 0) {
                Map<String, Adm.ProcessWizardSummary> data = new Map<String, Adm.ProcessWizardSummary>();

                for (AggregateResult result : groupedResults) {
                    String objectName = (String)result.get('SVMXA360__ObjectAPIName__c');
                    Boolean isActive = (result.get('SVMXA360__Active__c') == null) ? false : (Boolean)result.get('SVMXA360__Active__c');
                    String lastModifiedBy = (String)result.get('LastModifiedByUser');
                    Integer wizardCount = (Integer)result.get('WizardCount');
                    DateTime lastModifiedDate = (DateTime)result.get('LastModified');
                    
                    Adm.ProcessWizardSummary summary = data.get(objectName);
                
                    if (summary == null) {
                        summary = new Adm.ProcessWizardSummary();
                        summary.objectAPIName = objectName;
                        summary.lastModifiedDate = lastModifiedDate;
                        summary.lastModifiedBy = LastModifiedBy;
                        summary.activeWizards = (isActive) ? wizardCount : 0;
                        summary.inactiveWizards = (isActive) ? 0 : wizardCount;
                
                    } else {
                        summary.activeWizards += (isActive) ? wizardCount : 0;
                        summary.inactiveWizards += (isActive) ? 0 : wizardCount;
                
                        if (lastModifiedDate > summary.lastModifiedDate) {
                            summary.lastModifiedDate = lastModifiedDate;
                            summary.LastModifiedBy = LastModifiedBy;
                        }
                    }
                
                    data.put(objectName, summary);
                }
                
                if (!data.isEmpty()) {
                    summaries = data.values();
                    summaries.sort();
                }
            }
            
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardSummary() : Failed to retrieve Process Wizard Summary Info. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardSummary() - exit; summaries.size()= ' + summaries.size() );
        }
        
        return summaries;    
    }

    /**
     * This method is used to retrieve a collection of all active process wizards, and related child step and access records for the requested object API name. 
     */
    public List<Adm.ProcessWizard> getAllActiveProcessWizardDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllProcessWizardDetails() - enter;' );
        
        List<Adm.ProcessWizard> processWizardList = new List<Adm.ProcessWizard>();
        
        try {

            List<SVMXA360__CONF_ProcessWizard__c> processWizardRecordList = getAllActiveProcessWizardsRecordsWithDetail();

            List<String> stepIdList = getProcessStepIds( processWizardRecordList );  
            createProcessStepParameterWrapper(stepIdList);
            createProcessStepDependencyWrapper(stepIdList);
            
            if( processWizardRecordList.size() > 0 ) {
                for( SVMXA360__CONF_ProcessWizard__c wizardRecord : processWizardRecordList ) {
                    processWizardList.add( createProcessWizardWrapperWithDetails( wizardRecord ) );
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllProcessWizardDetails() : Failed to retrieve Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllProcessWizardDetails() - exit; processWizardList.size()= ' + processWizardList.size() );
        }
        
        return processWizardList;
    }
    
    /**
     * This method is used to retrieve a collection of all active process wizards, and related child step and access records for the requested object API name. 
     */
    public List<Adm.ProcessWizard> getAllProcessWizardDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllProcessWizardDetails() - enter;' );
        
        List<Adm.ProcessWizard> processWizardList = new List<Adm.ProcessWizard>();
        
        try {

            List<SVMXA360__CONF_ProcessWizard__c> processWizardRecordList = getAllProcessWizardsRecordsWithDetail();

            List<String> stepIdList = getProcessStepIds( processWizardRecordList );  
            createProcessStepParameterWrapper(stepIdList);
            createProcessStepDependencyWrapper(stepIdList);
            
            if( processWizardRecordList.size() > 0 ) {
                for( SVMXA360__CONF_ProcessWizard__c wizardRecord : processWizardRecordList ) {
                    processWizardList.add( createProcessWizardWrapperWithDetails( wizardRecord ) );
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllProcessWizardDetails() : Failed to retrieve Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllProcessWizardDetails() - exit; processWizardList.size()= ' + processWizardList.size() );
        }
        
        return processWizardList;
    }

    /**
     * This method is used to retrieve a collection of process wizards, and related child step and access records for the requested object API name. 
     */
    public List<Adm.ProcessWizard> getProcessWizardDetailsByObject( final String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetailsByObject() - enter; objectAPIName= ' + objectAPIName );
        
        List<Adm.ProcessWizard> processWizardList = new List<Adm.ProcessWizard>();
        
        try {

            if( String.isBlank(objectAPIName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<SVMXA360__CONF_ProcessWizard__c> processWizardRecordList = getProcessWizardsByRecordsObjectWithDetail( objectAPIName );

            List<String> stepIdList = getProcessStepIds( processWizardRecordList );  
            createProcessStepParameterWrapper(stepIdList);
            createProcessStepDependencyWrapper(stepIdList);
            
            if( processWizardRecordList.size() > 0 ) {
                for( SVMXA360__CONF_ProcessWizard__c wizardRecord : processWizardRecordList ) {
                    processWizardList.add( createProcessWizardWrapperWithDetails( wizardRecord ) );
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetailsByObject() : Failed to retrieve Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetailsByObject() - exit; processWizardList.size()= ' + processWizardList.size() );
        }
        
        return processWizardList;
    }

    /**
     * This method is used to retrieve a collection of process wizards, and related child step and access records for the requested object API name. 
     */
    public List<Adm.ProcessWizard> getActiveProcessWizardDetailsByObject( final String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetailsByObject() - enter; objectAPIName= ' + objectAPIName );
        
        List<Adm.ProcessWizard> processWizardList = new List<Adm.ProcessWizard>();
        
        try {

            if( String.isBlank(objectAPIName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<SVMXA360__CONF_ProcessWizard__c> processWizardRecordList = getActiveProcessWizardsByRecordsObjectWithDetail( objectAPIName );
            List<String> stepIdList = getProcessStepIds( processWizardRecordList );  
            createProcessStepParameterWrapper(stepIdList);
            createProcessStepDependencyWrapper(stepIdList);
            
            if( !processWizardRecordList.isEmpty() ) {
                for( SVMXA360__CONF_ProcessWizard__c wizardRecord : processWizardRecordList ) {
                    processWizardList.add( createProcessWizardWrapperWithSteps( wizardRecord ) );
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetailsByObject() : Failed to retrieve Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetailsByObject() - exit; processWizardList.size()= ' + processWizardList.size() );
        }
        
        return processWizardList;
    }

    /**
     * This method is used to retrieve a collection of ProcessStepTargets
     */
    public List<Adm.ProcessStepTarget> getProcessStepTargetsByType( final String stepTypeName, final String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByType() - enter; stepTypeName= ' + stepTypeName );
        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByType() - enter; objectAPIName= ' + objectAPIName );
        
        List<Adm.ProcessStepTarget> processStepTargetList = new List<Adm.ProcessStepTarget>();
        
        try {

            List<Object> processStepTargetRecords = new List<Object>();

            if( String.isBlank(stepTypeName ) ||
                String.isBlank(objectAPIName )) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.FLOW) {
                processStepTargetRecords = COMM_MetadataManager.getInstance().getAllActiveFlows();
            } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.SPM_TRANSACTION) {
                Common.ServiceResponse response = ADM_PageLayoutManager.getInstance().getLayoutsByObjectNameAndType(
                        'Transaction',
                        objectAPIName
                    );
                processStepTargetRecords = (List<Object>) response.data;
            } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.RECORD_ACTION) {
                processStepTargetRecords = COMM_DescribeManager.getInstance().getAllQuickActionsByObjectName(objectAPIName);
            } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.LWC) {  
                processStepTargetRecords = COMM_MetadataManager.getInstance().getLWCComponentDetails(objectAPIName);

            }
            
            if( !processStepTargetRecords.isEmpty() ) {
                for( Object processStepTargetRecord : processStepTargetRecords ) {
                    processStepTargetList.add( createProcessStepTargetWrapper( processStepTargetRecord, stepTypeName ) );
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByType() : Failed to retrieve Process Step Targets. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByType() : Failed to retrieve Process Step Targets. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByType() - exit; processStepTargetList.size()= ' + processStepTargetList.size() );
        }
        
        return processStepTargetList;
    }

    /**
     * This method is used to retrieve a ProcessStepTarget by Unique Identifier
     */
    public Adm.ProcessStepTarget getProcessStepTargetsByApiName( final String stepTypeName, final String targetApiName, final String objectApiName ) {

        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByApiName() - enter; stepTypeName= ' + stepTypeName );
        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetByApiName() - enter; targetApiName= ' + targetApiName );
        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetByApiName() - enter; targetApiName= ' + objectApiName );

         Adm.ProcessStepTarget processStepTarget = new Adm.ProcessStepTarget();
        
        try {

            Object processStepTargetRecord;
            
            if( String.isBlank(stepTypeName) ||
                String.isBlank(targetApiName ) || 
                String.isBlank(objectApiName)) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.FLOW) {
                processStepTargetRecord = COMM_MetadataManager.getInstance().getFlowByApiName( targetApiName );
            } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.SPM_TRANSACTION) {
                processStepTargetRecord = ADM_PageLayoutManager.getInstance().getPageLayoutDetails(
                        targetApiName, 
                        false,
                        null
                    );
            } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.RECORD_ACTION) {
                processStepTargetRecord = COMM_DescribeManager.getInstance().getQuickActionsByApiName( objectApiName, targetApiName );
            } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.LWC) { 
                processStepTargetRecord = COMM_MetadataManager.getInstance().getLWCDetailsByApiName( targetApiName );
            } 
            
            if( processStepTargetRecord != null ) {
                processStepTarget = createProcessStepTargetWrapper( processStepTargetRecord, stepTypeName );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByApiName() : Failed to retrieve Process Step Targets. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByApiName() : Failed to retrieve Process Step Targets. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByApiName() - exit; processStepTarget ' + processStepTarget);
        }
        
        return processStepTarget;
    }

    /**
     * This method is used to retrieve a single process wizard, and related child step and access records. 
     */
    public Adm.ProcessWizard getProcessWizardDetails( final String processWizardId ) {
        Adm.ProcessWizard wizard;
        
        try {
            
            if( String.isBlank(processWizardId ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            if( !wizardWrapperMap.containsKey(processWizardId) ) {
                final SVMXA360__CONF_ProcessWizard__c processWizardRecord = getProcessWizardRecordsWithDetail( processWizardId );

                List<SVMXA360__CONF_ProcessWizard__c> processWizardRecordList = new List<SVMXA360__CONF_ProcessWizard__c>(); 
                processWizardRecordList.add(processWizardRecord);
                List<String> stepIdList = getProcessStepIds( processWizardRecordList );  
                createProcessStepParameterWrapper(stepIdList);
                createProcessStepDependencyWrapper(stepIdList);
                
                // Throw record not exists exception if no record found for requested id
                if( processWizardRecord != null ) {
                    wizardWrapperMap.put(processWizardId, createProcessWizardWrapperWithDetails( processWizardRecord ));
                } else {
                    System.debug( LoggingLevel.ERROR, 'getProcessWizardDetails() : Record not exists. processWizardId= ' + processWizardId );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
                }
            }
            
            wizard = wizardWrapperMap.get(processWizardId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetails() : Failed to retrieve a Process Wizard. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetails() : Failed to retrieve a Process Wizard. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetails() - exit; processWizard= ' + wizard );
        }
        
        return wizard;
    }

    /**
     * This method is used to save a collection of process wizards, and related child step and access records. 
     */
    public List<Adm.ProcessWizard> saveProcessWizards( final List<Adm.ProcessWizard> processWizards, final List<String> objectAPINames ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveProcessWizards() - enter; processWizards= ' + processWizards );
        
        Savepoint sPoint = Database.setSavepoint();
        Map<String, Adm.ProcessWizard> processWizardsMap = new Map<String, Adm.ProcessWizard>();

        try {
            
            if( objectAPINames == null || objectAPINames.size() == 0 ) {
                System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Invalid request parameters. processWizards= ' + processWizards + '; objectAPINames=' + objectAPINames);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.REQUEST_IS_BLANK );
            }

            if (processWizards == null) {
                processWizards = new List<Adm.ProcessWizard>();
            }
            
            List<Common.ServiceError> validationErrors = validateProcessWizardRequestDetails(processWizards);

            if (validationErrors.size() > 0) { 
                SvmxSystem.SvmxServiceException serviceEx = new SvmxSystem.SvmxServiceException( ErrorMessage.INVALID_ARGUMENT );
                serviceEx.errors = validationErrors;
    
                throw serviceEx;
            }

            Map<String, SVMXA360__CONF_ProcessWizard__c> oldProcessWizardMap = new Map<String, SVMXA360__CONF_ProcessWizard__c>();            
    
            // Retrieve all existing process wizards 
            oldProcessWizardMap.putAll( [ SELECT Id, (select Id,Name from SVMXA360__Process_Wizard_Steps__r) FROM SVMXA360__CONF_ProcessWizard__c WHERE SVMXA360__ObjectAPIName__c IN :objectAPINames ]);

            List<SVMXA360__CONF_ProcessWizard__c> processWizardRecords = new List<SVMXA360__CONF_ProcessWizard__c>();

            for (Adm.ProcessWizard processWizard : processWizards) {
                
                processWizardsMap.put(processWizard.developerName, processWizard);
                if (processWizard.isModified) { 
                    final SVMXA360__CONF_ProcessWizard__c processWizardRecord = createProcessWizardRecord(processWizard);
                    processWizardRecords.add(processWizardRecord);
                }

                // remove wizard record from old record list if found in request.
                if( oldProcessWizardMap.containsKey( processWizard.Id ) ) {
                    oldProcessWizardMap.remove( processWizard.Id );
                }
            }

            // Upsert process wizard record.
            if (processWizardRecords.size() > 0) {
                processWizardRecords = (List<SVMXA360__CONF_ProcessWizard__c>) SvmxDatabase.upsertRecord( processWizardRecords );
                ADM_TranslationUtils.getInstance().createTranslatedRecord((List<SObject>)processWizardRecords);
            
                // Update Process Wizard IDs in the collection passed in. The ID value is used in the process to save steps and access records.
                
                for (SVMXA360__CONF_ProcessWizard__c processWizardRecord : processWizardRecords) {
                    if (processWizardsMap.containsKey(processWizardRecord.SVMXA360__DeveloperName__c)) {
                        processWizardsMap.get(processWizardRecord.SVMXA360__DeveloperName__c).id = processWizardRecord.id;
                    }
                }
                
            }

            // Delete process wizards which may have been removed in the request.
            if( oldProcessWizardMap.size() > 0 ) {
                SvmxDatabase.deleteRecord(oldProcessWizardMap.values());
            }

            List<Adm.RecentItemInfo> deletedrecentItemInfoList = new List<Adm.RecentItemInfo>();
            for (SVMXA360__CONF_ProcessWizard__c deletedWizard : oldProcessWizardMap.values()) {
                    for (SVMXA360__CONF_ProcessWizardStep__c deletedStep : deletedWizard.SVMXA360__Process_Wizard_Steps__r) {
                    Adm.RecentItemInfo recentItem = new Adm.RecentItemInfo();
                    recentItem.configurationId = deletedStep.id;
                    deletedrecentItemInfoList.add(recentItem);
                }
            }

            if (Adm.isRecentItemTransaction) {
                ADM_RecentItemsManager recentItemManager = ADM_RecentItemsManager.getInstance();
                if (deletedrecentItemInfoList.size() > 0) {
                    recentItemManager.deleteRecentItemsDetails(deletedrecentItemInfoList);
                }
            }

            System.debug( LoggingLevel.INFO, 'saveProcessWizards() : Saved Process Wizards.' );
            
            if (!processWizardsMap.values().isEmpty()) {
                // Save Process Step Records.
                saveProcessWizardStepRecords(processWizardsMap.values());

                // Save Process Access Records.
                saveProcessWizardAccessRecords(processWizardsMap.values());
            }
        }
        catch( SvmxSystem.SvmxServiceException e ) {
            Database.rollback( sPoint );

            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Validation Failed during Save Process Wizards. Error= ' + e.errors );
            throw e;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Process Wizards. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessWizards() - exit; processWizardsMap.values()= ' + processWizardsMap.values() );
        }
        
        return processWizardsMap.values();
    }

    /**
     * This method is used to validates given of process wizards, and related child step and access records. 
     */
    public Adm.ValidationResult validateProcessWizard( final Adm.ProcessWizard processWizard, final List<Adm.ReferenceData> referenceDatas ) {
        return validateProcessWizards( new List<Adm.ProcessWizard>{ processWizard }, referenceDatas ).get(0);
    }
    
    /**
     * This method is used to validates a collection of process wizards, and related child step and access records. 
     */
    public List<Adm.ValidationResult> validateProcessWizards( final List<Adm.ProcessWizard> processWizards, final List<Adm.ReferenceData> referenceDatas ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateProcessWizards() - enter; processWizards= ' + processWizards );
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();

        try {
           
            final Set<String> expressionSet = new Set<String>();
			List<SVMXA360__CONF_Expression__c> expressionList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Expression__c] );
            
            for( SVMXA360__CONF_Expression__c expressionRecord : expressionList ) {
                expressionSet.add(expressionRecord.SVMXA360__DeveloperName__c);
            }
            
            final Set<String> transactionSet = new Set<String>();
			List<SVMXA360__CONF_Layout__c > transactionList = SvmxDatabase.query( [SELECT SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c ] );
            
            for( SVMXA360__CONF_Layout__c  transactionRecord : transactionList ) {
                transactionSet.add(transactionRecord.SVMXA360__DeveloperName__c);
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                
                for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                    
                    if( referenceData.configType == Adm.ConfigurationType.Transactions ) {
                        transactionSet.add(configurationData.developerName);
                    }
                    if( referenceData.configType == Adm.ConfigurationType.Expression ) {
                        expressionSet.add(configurationData.developerName);
                    }
                }
            }
            
            final Set<String> profileNameSet = new Set<String>();
            for( Profile profileRecord : (List<Profile>) SvmxDatabase.query([SELECT Name FROM Profile]) ) {
                profileNameSet.add(profileRecord.Name);
            }
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            
            for( Integer index = 0; index < processWizards.size(); index++ ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.Wizard );
                validationResults.add( validationResult );
                
                final Adm.ProcessWizard processWizard = processWizards.get(index);
                
                if( !entityDefinitionMap.containsKey(processWizard.objectApiName) ) {
                    
                    try {
                        final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(processWizard.objectApiName);
                        entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                    }
                    catch( SvmxSystem.SvmxNestedException e ) {
                        
                        validationResult.setError('Object does not exists: ' + processWizard.objectApiName);
                        continue;
                    }
                }
                
                if ( String.isNotBlank(processWizard.expressionDeveloperName) && !expressionSet.contains(processWizard.expressionDeveloperName) ) {
                    validationResult.setError( 'Qualification Criteria does not exists : '+ processWizard.expressionDeveloperName );
                }
                
                validateWizardStep(processWizard, validationResult, expressionSet, transactionSet );
                
                if( processWizard.access != null ) {
                    
                    for( Adm.ProcessAccess processAccess : processWizard.access ) {
                        
                        if( !profileNameSet.contains(processAccess.profileId) ) {
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Wizard, 'Wizard Name: ' + processWizard.name + ', Profile does not exists: ' + processAccess.profileId ) );
                        }
                    }
                }
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateProcessWizards() : Failed to validate Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateProcessWizards() - exit; validationResults= ' + validationResults );
        }
        
        return validationResults;
    }

    private void validateWizardStep( final Adm.ProcessWizard processWizard, final Adm.ValidationResult validationResult, final Set<String> expressionSet, final Set<String> transactionSet ) {
        
        if( processWizard.steps != null ) {
            
            for( Adm.ProcessStep step : processWizard.steps ) {
                
                if ( String.isNotBlank(step.expressionDeveloperName) && !expressionSet.contains(step.expressionDeveloperName) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Wizard, 'Step Name: ' + step.name +', Step Qualification Criteria does not exists : '+ step.expressionDeveloperName ) );
                }
                
                if( step.type.equalsIgnoreCase( 'SPM Transaction') && String.isBlank(step.target) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Wizard, 'One or more mandatory fields are missing. Step name: ' + step.name ) );
                }
                
                if( step.type.equalsIgnoreCase( 'SPM Transaction') && String.isNotBlank(step.target) && !transactionSet.contains(step.target) ) {
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Wizard, 'Step Name: ' + step.name + ', Target transaction does not exists: ' + step.target ) );
                }
            }
        }
    }
    
    /**
     * This method is used to delete a process wizards, and related child step and access records 
     * for the requested list of object API names.
     */
    public void deleteProcessWizardsByObjectNames( final List<String> objectAPINames ) {
        System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardsByObject() - enter; objectAPIName= ' + objectAPINames );
        
        try {
            if( objectAPINames == null || objectAPINames.size() == 0 ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_ProcessWizard__c WHERE SVMXA360__ObjectAPIName__c IN :objectAPINames ] );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardsByObject() : Failed to delete Process Wizards. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardsByObject() : Failed to delete Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardsByObject() - exit');
        }
    }

    /**
     * This method is used to delete a process wizard, and related child step and access records 
     * for requested process wizard id.
     */
    public void deleteProcessWizard( final String processWizardId ) {
        System.debug( LoggingLevel.DEBUG, 'deleteProcessWizard() - enter; processWizardId= ' + processWizardId );
        
        try {
            if( String.isBlank( processWizardId ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_ProcessWizard__c WHERE Id = :processWizardId ] );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizard() : Failed to delete Process Wizard. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizard() : Failed to delete Process Wizard. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcessWizard() - exit');
        }
    }

    /**
     * This method is used to delete a process wizard step 
     * for requested process wizard step id.
     */
    public void deleteProcessWizardStep( final String processWizardStepId ) {
        System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardStep() - enter; processWizardStepId= ' + processWizardStepId );
        
        try {
            if( String.isBlank( processWizardStepId ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c WHERE Id = :processWizardStepId ] );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardStep() : Failed to delete Process Wizard Step. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardStep() : Failed to delete Process Wizard Step. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardStep() - exit');
        }
    }

    /**
     * This method is used to invoke a record action 
     * for requested process wizard step id.
     */
    public void invokeRecordAction( final String actionName, 
                                    final String processWizardStepId, 
                                    final String recordId ) {
        System.debug( LoggingLevel.DEBUG, 'invokeRecordAction() - enter; processWizardStepId= ' + processWizardStepId );
        
        try {
            if( String.isBlank( actionName )  
                || String.isBlank( processWizardStepId )
                || String.isBlank( recordId ) ) {
                System.debug( LoggingLevel.ERROR, 'invokeRecordAction() : Invalid arguments. RecordId= ' + recordId + ' and wizard stepId= '+processWizardStepId);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            String recordType = String.valueOf(((ID)recordId).getSObjectType());
            List<Common.QuickActionDefinition> deflist = COMM_MetadataManager.getInstance().getQuickActionDefinition(actionName);
            String targetRecordType = null;
            String actionType = null;
            if(deflist!=null && !deflist.isEmpty()){
                    targetRecordType =deflist[0].TargetSobjectType;
                    actionType = deflist[0].type;
            }
            if(targetRecordType == null || actionType == null){
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + actionName );
            }
            List<SVMXA360__CONF_ProcessStepParameter__c> paramsList = SvmxDatabase.query(
                    [ 
                        SELECT 
                        Id, 
                        SVMXA360__ParameterKey__c, 
                        SVMXA360__ParameterValue__c,
                        SVMXA360__ValueType__c,
                        SVMXA360__ProcessWizardStepId__c
                        FROM SVMXA360__CONF_ProcessStepParameter__c                             
                        WHERE SVMXA360__ProcessWizardStepId__c = :processWizardStepId
                    ]);

            Map<String,Object> targetList = new Map<String,Object>();
            Map<String,String> recordMap = new Map<String,String>();
            SObject sObj = (SObject) Type.forName('Schema.' + targetRecordType ).newInstance();
            Map<String, Schema.SObjectField> fieldMap = sObj.getSObjectType().getDescribe().fields.getMap();            
            for(SVMXA360__CONF_ProcessStepParameter__c param: paramsList){
                if(param.SVMXA360__ValueType__c == 'Field'){
                    recordMap.put(param.SVMXA360__ParameterKey__c, param.SVMXA360__ParameterValue__c);
                    targetList.put(param.SVMXA360__ParameterKey__c, null);
                }else{
                    if(fieldMap.containsKey(param.SVMXA360__ParameterKey__c)){
                        Schema.DisplayType fieldType = fieldMap.get(param.SVMXA360__ParameterKey__c).getDescribe().getType();
                        Object fieldValue = param.SVMXA360__ParameterValue__c;
                        switch on fieldType {
                            when BOOLEAN {
                                fieldValue = Boolean.valueOf(param.SVMXA360__ParameterValue__c);
                            }
                            when INTEGER {
                                fieldValue = Integer.valueOf(param.SVMXA360__ParameterValue__c);
                            }
                            when DOUBLE,
                                CURRENCY,
                                PERCENT {
                                fieldValue = Decimal.valueOf(param.SVMXA360__ParameterValue__c);
                            }
                            when LONG {
                                fieldValue = Long.valueOf(param.SVMXA360__ParameterValue__c);
                            }
                        }
                        targetList.put(param.SVMXA360__ParameterKey__c, fieldValue);
                    }
                }
            }
            if(!recordMap.values().isEmpty()){
                Set<String> uniqueFieldNames = new Set<string>();
                uniqueFieldNames.addAll(recordMap.values());
                String query ='select ID,'+ String.join(new List<String>(uniqueFieldNames),',') + ' from '+String.escapeSingleQuotes(recordType)+' where id = \''+String.escapeSingleQuotes(recordId)+'\'';
                List<SObject> objList = SvmxDatabase.query(query);
                if(!objList.isEmpty()){
                    sobject obj = objList.get(0);
                    for(String cols: recordMap.keySet()){
                        targetList.put(cols,obj.get(recordMap.get(cols)));
                    }
                }
            }
            for(String key: targetList.keySet()){
                sobj.put(key, targetList.get(key));
            }
            if(recordType == targetRecordType && actionType == 'Update'){
                sobj.put('ID', recordId);
            }
            COMM_DescribeManager.getInstance().invokeQuickAction(sobj,actionName,recordId);
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'invokeRecordAction() : Failed to invoke Process Wizard Step. Error= ' + e.getStackTraceString() );
            system.debug( LoggingLevel.ERROR,e);
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeRecordAction() - exit');
        }
    }

    private List<SVMXA360__CONF_ProcessWizardStep__c> saveProcessWizardStepRecords( final List<Adm.ProcessWizard> processWizards ) {
        System.debug( LoggingLevel.DEBUG, 'saveProcessWizardStepRecords() - enter; processWizards= ' + processWizards );
        List<SVMXA360__CONF_ProcessWizardStep__c> processStepRecordList = new List<SVMXA360__CONF_ProcessWizardStep__c>();
        Savepoint sPoint = Database.setSavepoint();

        try {
            Set<String> processWizardIDs = new Set<String>();
            Map<String, String> wizardObjectNameMap = new Map<String, String>();
            for ( Adm.ProcessWizard processWizard: processWizards ) {
                processWizardIDs.add(processWizard.id);
                wizardObjectNameMap.put(processWizard.id, processWizard.objectAPIName);
            }

            Map<String, SVMXA360__CONF_ProcessWizardStep__c> oldProcessStepMap = new Map<String, SVMXA360__CONF_ProcessWizardStep__c>();
            // Retrieve all existing process step records 
            if( !processWizardIDs.isEmpty() ) {
                oldProcessStepMap.putAll( [ SELECT Id FROM SVMXA360__CONF_ProcessWizardStep__c WHERE SVMXA360__ProcessWizard__c IN :processWizardIDs ]);
            }
            
            List<Adm.ProcessStep> modifiedStepList = new List<Adm.ProcessStep>();
            List<Adm.ProcessStep> unModifiedStepList = new List<Adm.ProcessStep>();
            Set<String> wizardStepName = new Set<String>();
            for (Adm.ProcessWizard processWizard: processWizards) {
                wizardStepName = new Set<String>();
                if (processWizard.steps != null && processWizard.steps.size() > 0) {
                    for( Adm.ProcessStep processStep : processWizard.steps ) {
                        if(String.isNotBlank(processStep.developerName)) {
                            wizardStepName.add(processStep.developerName);
                        }
                    }
                    for( Adm.ProcessStep processStep : processWizard.steps ) {

                        if (processStep.isModified) {
                            final SVMXA360__CONF_ProcessWizardStep__c processStepRecord = createProcessStepRecord( wizardStepName, processWizard.developerName,processWizard.id, processStep );
                            
                            processStepRecordList.add(processStepRecord);
                            modifiedStepList.add(processStep);
                        } else {
                            unModifiedStepList.add(processStep);    
                        }
                        
                        // remove step record from existing record list if found in request.
                        if( oldProcessStepMap.containsKey( processStep.Id ) ) { 
                            oldProcessStepMap.remove( processStep.Id );
                        }
                    }
                }
            }
            
            // Upsert all process step records
            processStepRecordList = SvmxDatabase.upsertRecord(processStepRecordList);
            ADM_TranslationUtils.getInstance().createTranslatedRecord((List<SObject>)processStepRecordList);
            System.debug( LoggingLevel.INFO, 'saveProcessWizardStepRecords() : Saved Process Wizard Step records.' );
            
            // Delete process wizard step which is removed in request.
            if( oldProcessStepMap.size() > 0 ) {
                SvmxDatabase.deleteRecord(oldProcessStepMap.values());
            }

            List<Adm.RecentItemInfo> deletedrecentItemInfoList = new List<Adm.RecentItemInfo>();
            for (SVMXA360__CONF_ProcessWizardStep__c deletedStep : oldProcessStepMap.values()) {
                Adm.RecentItemInfo recentItem = new Adm.RecentItemInfo();
                recentItem.configurationId = deletedStep.id;
                deletedrecentItemInfoList.add(recentItem);
            }

            List<Adm.RecentItemInfo> recentItemInfoList = new List<Adm.RecentItemInfo>();
            // Update Id's for process wizard step records.
            for( Integer index = 0; index < processStepRecordList.size(); index++ ) {
                modifiedStepList.get(index).id = processStepRecordList.get(index).id;
                Adm.RecentItemInfo recentItemInfo = new Adm.RecentItemInfo();
                recentItemInfo.configurationName = processStepRecordList.get(index).Name;
                recentItemInfo.configurationId = processStepRecordList.get(index).Id;
                recentItemInfo.configurationType = 'Wizard';
                recentItemInfo.objectApiName = wizardObjectNameMap.get(processStepRecordList.get(index).SVMXA360__ProcessWizard__c);
                recentItemInfoList.add(recentItemInfo);
            }

            if (Adm.isRecentItemTransaction) {
                ADM_RecentItemsManager recentItemManager = ADM_RecentItemsManager.getInstance();
                if( recentItemInfoList.size() > 0 ) {
                    recentItemManager.saveRecentItems(recentItemInfoList);
                }
                if (deletedrecentItemInfoList.size() > 0) {
                    recentItemManager.deleteRecentItemsDetails(deletedrecentItemInfoList);
                }
            }

            List<Adm.ProcessStep> processStepList = new List<Adm.ProcessStep>();
            processStepList.addAll(modifiedStepList);
            processStepList.addAll(unModifiedStepList);
            
            if (processStepList.size() > 0) {
                // Save Process Step Parameter Records.
                saveProcessStepParameterRecords(processStepList);
                // Save Process Step Dependency Records
                saveProcessStepDependencyRecords(processStepList);
            }
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizardStepRecords() : Failed to save Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessWizardStepRecords() - exit; processStepRecordList= ' + processStepRecordList );
        }    

        return processStepRecordList;
    }
    
    private List<SVMXA360__CONF_ProcessStepParameter__c> saveProcessStepParameterRecords( final List<Adm.ProcessStep> processSteps ) {
        System.debug( LoggingLevel.DEBUG, 'saveProcessStepParameterRecords() - enter; processSteps= ' + processSteps );
        
        List<SVMXA360__CONF_ProcessStepParameter__c> stepParameterRecordList = new List<SVMXA360__CONF_ProcessStepParameter__c>();
        Savepoint sPoint = Database.setSavepoint();

        try {
            Set<String> wizardStepIDs = new Set<String>();
            
            for (Adm.ProcessStep wizardStep : processSteps) {
                    wizardStepIDs.add(wizardStep.id);
            }    
            
            Map<String, SVMXA360__CONF_ProcessStepParameter__c> oldProcessStepParameterMap = new Map<String, SVMXA360__CONF_ProcessStepParameter__c>();
            // Retrieve all existing process step parameter records 
            if( !wizardStepIDs.isEmpty() ) {
                oldProcessStepParameterMap.putAll( (List<SVMXA360__CONF_ProcessStepParameter__c>)SvmxDatabase.query( [ SELECT Id FROM SVMXA360__CONF_ProcessStepParameter__c WHERE SVMXA360__ProcessWizardStepId__c IN :wizardStepIDs ] ));
            }
            
            List<Adm.ProcessStepParameter> modifiedStepParameterList = new List<Adm.ProcessStepParameter>();
            List<Adm.ProcessStepParameter> unModifiedStepParameterList = new List<Adm.ProcessStepParameter>();

            for( Adm.ProcessStep processStep : processSteps ) {
                if(processStep.stepParameters != null && processStep.stepParameters.size() > 0) {
                    for (Adm.ProcessStepParameter stepParameter : processStep.stepParameters) {
                        if(stepParameter.isModified) {     
                            final SVMXA360__CONF_ProcessStepParameter__c stepParameterRecord = createStepParameterRecord( processStep.id, stepParameter );              
                            stepParameterRecordList.add(stepParameterRecord);
                            modifiedStepParameterList.add(stepParameter);
                        } else {
                            unModifiedStepParameterList.add(stepParameter);    
                        }  
                        
                        // remove step parameter record from existing record list if found in request.
                        if( oldProcessStepParameterMap.containsKey( stepParameter.Id ) ) { 
                            oldProcessStepParameterMap.remove( stepParameter.Id );
                        }
                    }  
                }          
            }

            // Upsert all process step parameters records
            stepParameterRecordList = SvmxDatabase.upsertRecord(stepParameterRecordList);
            
            System.debug( LoggingLevel.INFO, 'saveProcessStepParameterRecords() : Saved Process Wizard Step Parameter records.' );
            
            // Delete process wizard step parameter which is removed in request.
            if( oldProcessStepParameterMap.size() > 0 ) {
                SvmxDatabase.deleteRecord(oldProcessStepParameterMap.values());
            }

            // Update Id's for process wizard step records.
            for( Integer index = 0; index < stepParameterRecordList.size(); index++ ) {
                modifiedStepParameterList.get(index).id = stepParameterRecordList.get(index).id;
            }
            List<Adm.ProcessStepParameter> stepParameterList = new List<Adm.ProcessStepParameter>();
            stepParameterList.addAll(modifiedStepParameterList);
            stepParameterList.addAll(unModifiedStepParameterList);
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveProcessStepParameterRecords() : Failed to save Process Wizards. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessStepParameterRecords() - exit; stepParameterRecordList= ' + stepParameterRecordList );
        }
        
        return stepParameterRecordList;
    } 
    private List<SVMXA360__CONF_ProcessWizardStepDependency__c> saveProcessStepDependencyRecords( final List<Adm.ProcessStep> processSteps ) {
        System.debug( LoggingLevel.DEBUG, 'saveProcessStepDependencyRecords() - enter; processSteps= ' + processSteps );
        
        List<SVMXA360__CONF_ProcessWizardStepDependency__c> stepDependencyRecordList = new List<SVMXA360__CONF_ProcessWizardStepDependency__c>();
        Map<String, String> stepReferenceIdMap = new Map<String, String>();
        Savepoint sPoint = Database.setSavepoint();

        try {
            Set<String> wizardStepIDs = new Set<String>();
            
            for (Adm.ProcessStep wizardStep : processSteps) {
                wizardStepIDs.add(wizardStep.id);
                stepReferenceIdMap.put(wizardStep.referenceId, wizardStep.id);
            }    

            Map<String, SVMXA360__CONF_ProcessWizardStepDependency__c> oldProcessStepDependencyMap = new Map<String, SVMXA360__CONF_ProcessWizardStepDependency__c>();
            
            if( !wizardStepIDs.isEmpty() ) {
                oldProcessStepDependencyMap.putAll( (List<SVMXA360__CONF_ProcessWizardStepDependency__c>)SvmxDatabase.query( [ SELECT Id FROM SVMXA360__CONF_ProcessWizardStepDependency__c WHERE SVMXA360__ProcessWizardStep__c IN :wizardStepIDs ] ));
            }
           
            for( Adm.ProcessStep processStep : processSteps ) {
                if(processStep.dependentSteps != null && processStep.dependentSteps.size() > 0) {
                    for (Adm.DependentStep dependentStep : processStep.dependentSteps) {
                        if(dependentStep.isModified) {
                            dependentStep.dependentStepId = stepReferenceIdMap.get(dependentStep.referenceId);
                            final SVMXA360__CONF_ProcessWizardStepDependency__c stepDependencyRecord = createStepDependencyRecord( dependentStep, processStep.Id); 
                            stepDependencyRecordList.add(stepDependencyRecord);
                        }

                        if( oldProcessStepDependencyMap.containsKey(dependentStep.id) ) { 
                            oldProcessStepDependencyMap.remove( dependentStep.id );
                        }
                    }  
                }    
            }

            stepDependencyRecordList = SvmxDatabase.upsertRecord(stepDependencyRecordList);
            
            if( oldProcessStepDependencyMap.size() > 0 ) {
                SvmxDatabase.deleteRecord(oldProcessStepDependencyMap.values());
            }
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveProcessStepDependencyRecords() : Failed to save Process Dependency Step Records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessStepDependencyRecords() - exit; stepDependency= ' + stepDependencyRecordList );
        }
        return stepDependencyRecordList;
    } 

    private List<SVMXA360__CONF_ProcessWizardAccess__c> saveProcessWizardAccessRecords( final List<Adm.ProcessWizard> processWizards ) {
        Map<String, SVMXA360__CONF_ProcessWizardAccess__c> oldProcessAccessMap = new Map<String, SVMXA360__CONF_ProcessWizardAccess__c>();

        Set<String> processWizardIDs = new Set<String>();
        for ( Adm.ProcessWizard processWizard: processWizards ) {
            processWizardIDs.add(processWizard.id);
        }

        // Retrieve all existing process access records. 
        if( !processWizardIDs.isEmpty() ) {
            oldProcessAccessMap.putAll( [ SELECT Id FROM SVMXA360__CONF_ProcessWizardAccess__c WHERE SVMXA360__ProcessWizard__c IN :processWizardIDs ]);
        }
        
        List<SVMXA360__CONF_ProcessWizardAccess__c> processAccessRecordList = new List<SVMXA360__CONF_ProcessWizardAccess__c>();
        List<Adm.ProcessAccess> modifiedAccessList = new List<Adm.ProcessAccess>();
        List<Adm.ProcessAccess> unModifiedAccessList = new List<Adm.ProcessAccess>();

        for (Adm.ProcessWizard processWizard: processWizards) {
            if (processWizard.access != null && processWizard.access.size() > 0) {
                for( Adm.ProcessAccess processAccess : processWizard.access ) {

                    if (processAccess.isModified) { 
                        final SVMXA360__CONF_ProcessWizardAccess__c processAccessRecord = createProcessAccessRecord( processWizard.id, processAccess );
                        processAccessRecordList.add(processAccessRecord);
                        modifiedAccessList.add(processAccess);
                    } else {
                        unModifiedAccessList.add(processAccess);    
                    }

                    // remove acccess record from existing record list if found in request.
                    if( oldProcessAccessMap.containsKey( processAccess.Id ) ) { 
                        oldProcessAccessMap.remove( processAccess.Id );
                    }
                }
            }
        }
        
        // Upsert all process wizard access records
        processAccessRecordList = SvmxDatabase.upsertRecord(processAccessRecordList);
        
        System.debug( LoggingLevel.INFO, 'saveProcessWizardAccessRecords() : Saved Process Wizard Access records. ' );
        
        // Delete process wizard access which is removed in request.
        if( oldProcessAccessMap.size() > 0 ) {
            SvmxDatabase.deleteRecord(oldProcessAccessMap.values());
        }

        // Update Id's for process wizard access records.
        for( Integer index = 0; index < processAccessRecordList.size(); index++ ) {
            modifiedAccessList.get(index).id = processAccessRecordList.get(index).id;
        }
        List<Adm.ProcessAccess> processAccessList = new List<Adm.ProcessAccess>();
        processAccessList.addAll(modifiedAccessList);
        processAccessList.addAll(unModifiedAccessList);

        return processAccessRecordList;
    }    

    private SVMXA360__CONF_ProcessWizard__c createProcessWizardRecord( final Adm.ProcessWizard processWizard ) {
        
        System.debug( LoggingLevel.FINE, 'createProcessWizardRecord() - enter; processWizard= ' + processWizard );
        
        SVMXA360__CONF_ProcessWizard__c processWizardRecord = new SVMXA360__CONF_ProcessWizard__c();
        
        if( processWizard.id != null ) {
            processWizardRecord.Id = processWizard.id;
        } else {
            processWizardRecord.SVMXA360__DeveloperName__c = processWizard.developerName;
        }
        
        processWizardRecord.SVMXA360__Description__c = processWizard.description;
        processWizardRecord.SVMXA360__ObjectAPIName__c = processWizard.objectAPIName;
        processWizardRecord.Name = processWizard.name;
        processWizardRecord.SVMXA360__Active__c = processWizard.active;
        processWizardRecord.SVMXA360__Scope__c = processWizard.scope;
        processWizardRecord.SVMXA360__Sequence__c = processWizard.sequence;
        processWizardRecord.SVMXA360__VisibilityCriteria__c = processWizard.expressionId;
        processWizardRecord.SVMXA360__StepCompletionType__c = (processWizard.stepDependencyType == 'Checklist') ? processWizard.stepDependencyType : 'Standard';
        
        return processWizardRecord;
    }
    @TestVisible
    private SVMXA360__CONF_ProcessWizardStep__c createProcessStepRecord( Set<String> wizardStepName, String processWizardName, String processWizardId, Adm.ProcessStep processStep ) {
        
        System.debug( LoggingLevel.FINE, 'createProcessStepRecord() - enter; processStep= ' + processStep );
        
        final SVMXA360__CONF_ProcessWizardStep__c processStepRecord = new SVMXA360__CONF_ProcessWizardStep__c();
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( processStep.name ) || String.isBlank( processStep.type ) ) {
                System.debug( LoggingLevel.ERROR, 'createProcessStepRecord() : Invalid request parameters. processStep= ' + processStep );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            if( String.isBlank(processStep.developerName)) {
                processStep.developerName = processWizardName + '_' + processStep.Name?.replace(' ', '_');

                if(wizardStepName.contains(processStep.developerName)) {
                    processStep.developerName = processStep.developerName + wizardStepName.size();
                }
                processStep.developerName = normalizeDeveloperName(processStep.developerName);
                wizardStepName.add(processStep.developerName);
            }
            // Assign id field if step already exists. 
            // Assign Master Object id only for new records.
            if( String.isNotBlank( processStep.id ) ) {
                processStepRecord.id = processStep.id;
            } else {
                processStepRecord.SVMXA360__ProcessWizard__c = processWizardId;
            }
            
            processStepRecord.Name = processStep.name;
            processStepRecord.SVMXA360__Type__c = processStep.type;
            processStepRecord.SVMXA360__Namespace__c = processStep.namespace;
            processStepRecord.SVMXA360__Target__c = processStep.target;
            processStepRecord.SVMXA360__VisibilityCriteria__c = processStep.expressionId;
            processStepRecord.SVMXA360__HelpText__c = processStep.helpText;
            processStepRecord.SVMXA360__Sequence__c = processStep.sequence;
            processStepRecord.SVMXA360__CriteriaAction__c = processStep.criteriaAction;
            processStepRecord.SVMXA360__CriteriaActionHelpText__c = processStep.criteriaActionHelpText;
            processStepRecord.SVMXA360__OpenAsModal__c = processStep.openAsModal;
            processStepRecord.SVMXA360__IconName__c = processStep.iconName;
            processStepRecord.SVMXA360__StepDependencyFlag__c = (processStep?.dependentSteps?.size() > 0) ? true : false;
            processStepRecord.SVMXA360__DeveloperName__c = processStep?.developerName;

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'createProcessStepRecord() : Failed to create Process Wizard Step sobject. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createProcessStepRecord() - exit; record= ' + processStepRecord );
        }
        
        return processStepRecord;
    }

    @TestVisible
    private SVMXA360__CONF_ProcessStepParameter__c createStepParameterRecord( String processStepId, Adm.ProcessStepParameter processStepParameter ) {
        
        System.debug( LoggingLevel.INFO, 'createStepParameterRecord() - enter; processStepParameter= ' + processStepParameter );
        
        final SVMXA360__CONF_ProcessStepParameter__c stepParameterRecord = new SVMXA360__CONF_ProcessStepParameter__c();
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( processStepParameter.valueType ) || String.isBlank( processStepParameter.parameterKey ) || String.isBlank( processStepParameter.parameterValue ) ) {
                System.debug( LoggingLevel.ERROR, 'createStepParameterRecord() : Invalid request parameters. processStepParameter = ' + processStepParameter );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Assign id field if step already exists. 
            // Assign Master Object id only for new records.
            if( String.isNotBlank( processStepParameter.id ) ) {
                stepParameterRecord.id = processStepParameter.id;
            } else {
                stepParameterRecord.SVMXA360__ProcessWizardStepId__c = processStepId;
            }
            
            stepParameterRecord.SVMXA360__ParameterKey__c = processStepParameter.parameterKey;
            stepParameterRecord.SVMXA360__ParameterValue__c = processStepParameter.parameterValue;
            stepParameterRecord.SVMXA360__ValueType__c = processStepParameter.valueType;

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'createStepParameterRecord() : Failed to create Process Wizard Step Parameter sobject. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createStepParameterRecord() - exit; record= ' + stepParameterRecord );
        }
        
        return stepParameterRecord;
    }  

    @TestVisible
    private SVMXA360__CONF_ProcessWizardAccess__c createProcessAccessRecord( String processWizardId, Adm.ProcessAccess processAccess ) {
        
        System.debug( LoggingLevel.INFO, 'createProcessAccessRecord() - enter; processAccess= ' + processAccess );
        
        final SVMXA360__CONF_ProcessWizardAccess__c processAccessRecord = new SVMXA360__CONF_ProcessWizardAccess__c();
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( processAccess.profileId ) ) {
                System.debug( LoggingLevel.ERROR, 'createProcessAccessRecord() : Invalid request parameters. processAccess= ' + processAccess );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Assign id field if step already exists. 
            // Assign Master Object id only for new records.
            if( String.isNotBlank( processAccess.id ) ) {
                processAccessRecord.id = processAccess.id;
            } else {
                processAccessRecord.SVMXA360__ProcessWizard__c = processWizardId;
            }
            
            processAccessRecord.SVMXA360__ProfileId__c = processAccess.profileId;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'createProcessAccessRecord() : Failed to create Process Wizard Access sobject. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createProcessAccessRecord() - exit; record= ' + processAccessRecord );
        }
        
        return processAccessRecord;
    }        

    private Adm.ProcessWizard createProcessWizardWrapperWithDetails( final SVMXA360__CONF_ProcessWizard__c processWizardRecord ) {
        
        Adm.ProcessWizard wizard = createProcessWizardWrapper( processWizardRecord);

        // Check for Step Records
        if( processWizardRecord.SVMXA360__Process_Wizard_Steps__r.size() > 0 ) {
            wizard.steps = new List<Adm.ProcessStep>();
            
            for( SVMXA360__CONF_ProcessWizardStep__c stepRecord : processWizardRecord.SVMXA360__Process_Wizard_Steps__r ) {
                wizard.steps.add( createProcessWizardStepWrapper( stepRecord) );
            }
        }

        // Check for Access Records
        if( processWizardRecord.SVMXA360__Process_Wizard_Access__r.size() > 0 ) {
            wizard.access = new List<Adm.ProcessAccess>();

            for( SVMXA360__CONF_ProcessWizardAccess__c accessRecord : processWizardRecord.SVMXA360__Process_Wizard_Access__r ) {
                wizard.access.add( createProcessWizardAccessWrapper( accessRecord ) );
            }
        }

        return wizard;
    }

    /**
    * This method is used to construct Process Wizard wrapper with process wizard and step information.
    */ 
    private Adm.ProcessWizard createProcessWizardWrapperWithSteps( final SVMXA360__CONF_ProcessWizard__c processWizardRecord ) {
        SVMXA360__CONF_ProcessWizard__c processWizardRecordUpdated = (SVMXA360__CONF_ProcessWizard__c)ADM_TranslationUtils.getInstance().getTranslatedRecord(processWizardRecord);
        
        Adm.ProcessWizard wizard = createProcessWizardWrapper( processWizardRecordUpdated );

        // Check for Step Records
        if( processWizardRecordUpdated.SVMXA360__Process_Wizard_Steps__r.size() > 0 ) {

            wizard.steps = new List<Adm.ProcessStep>();
            
            for( SVMXA360__CONF_ProcessWizardStep__c stepRecord : (List<SVMXA360__CONF_ProcessWizardStep__c>)ADM_TranslationUtils.getInstance().getTranslatedRecord(processWizardRecordUpdated.SVMXA360__Process_Wizard_Steps__r) ) {
                wizard.steps.add( createProcessWizardStepWrapper( stepRecord  ));
            }
        }

        return wizard;
    }

    private Adm.ProcessWizard createProcessWizardWrapper( final SVMXA360__CONF_ProcessWizard__c processWizardRecord ) {
        
        Adm.ProcessWizard wizard = new Adm.ProcessWizard();
        
        wizard.active = processWizardRecord.SVMXA360__Active__c;
        wizard.description = processWizardRecord.SVMXA360__Description__c;
        wizard.developerName = processWizardRecord.SVMXA360__DeveloperName__c;
        wizard.id = processWizardRecord.Id;
        wizard.lastModifiedBy = processWizardRecord.LastModifiedBy.Name;
        wizard.lastModifiedDate = processWizardRecord.LastModifiedDate;
        wizard.name = processWizardRecord.Name;
        wizard.objectAPIName = processWizardRecord.SVMXA360__ObjectAPIName__c;
        wizard.scope = processWizardRecord.SVMXA360__Scope__c;
        wizard.sequence = Integer.valueOf(processWizardRecord.SVMXA360__Sequence__c);
        wizard.expressionId = processWizardRecord.SVMXA360__VisibilityCriteria__c;
        wizard.expressionName = processWizardRecord.SVMXA360__VisibilityCriteria__r.Name;
        wizard.expressionDeveloperName = processWizardRecord.SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c;
        wizard.stepDependencyType = processWizardRecord.SVMXA360__StepCompletionType__c;
        wizard.isVisible = true;
        wizard.isModified = false;
        
        return wizard;
    }

    private Adm.ProcessStep createProcessWizardStepWrapper( final SVMXA360__CONF_ProcessWizardStep__c processStepRecord) {
        
        Adm.ProcessStep step = new Adm.ProcessStep();
        
        step.id = processStepRecord.Id;
        step.lastModifiedDate = processStepRecord.LastModifiedDate;
        step.lastModifiedBy = processStepRecord.LastModifiedBy.Name; 
        step.name = processStepRecord.Name;
        step.namespace = processStepRecord.SVMXA360__Namespace__c;
        step.target = processStepRecord.SVMXA360__Target__c;
        step.type = processStepRecord.SVMXA360__Type__c;
        step.expressionId = processStepRecord.SVMXA360__VisibilityCriteria__c;
        step.expressionName = processStepRecord.SVMXA360__VisibilityCriteria__r.Name;
        step.expressionDeveloperName = processStepRecord.SVMXA360__VisibilityCriteria__r.SVMXA360__DeveloperName__c;
        step.processWizardId = processStepRecord.SVMXA360__ProcessWizard__c;
        step.helpText = processStepRecord.SVMXA360__HelpText__c;
        step.sequence = Integer.valueOf(processStepRecord.SVMXA360__Sequence__c);
        step.criteriaAction = processStepRecord.SVMXA360__CriteriaAction__c;
        step.criteriaActionHelpText = processStepRecord.SVMXA360__CriteriaActionHelpText__c;
        step.isVisible = true;
        step.openAsModal = processStepRecord.SVMXA360__OpenAsModal__c;
        step.stepParameters = stepParametersMap.get(processStepRecord.Id);
        step.dependentSteps = stepDependencyMap.get(processStepRecord.Id);
        step.iconName = processStepRecord.SVMXA360__iconName__c;
        step.stepDependencyFlag = ( processStepRecord.SVMXA360__StepDependencyFlag__c == null ) ? false : processStepRecord.SVMXA360__StepDependencyFlag__c;
        step.developerName = processStepRecord.SVMXA360__DeveloperName__c;
        step.isModified = false;
        
        return step;
    } 

    private Map<String, List<Adm.ProcessStepParameter>> createProcessStepParameterWrapper( List<String> processStepIds ) {
        
        List<SVMXA360__CONF_ProcessStepParameter__c> processStepParameterList = new List<SVMXA360__CONF_ProcessStepParameter__c>();

        try {
            processStepParameterList = SvmxDatabase.query(
                    [ 
                        SELECT 
                        Id, 
                        SVMXA360__ParameterKey__c, 
                        SVMXA360__ParameterValue__c,
                        SVMXA360__ValueType__c,
                        SVMXA360__ProcessWizardStepId__c
                        FROM SVMXA360__CONF_ProcessStepParameter__c                             
                        WHERE SVMXA360__ProcessWizardStepId__c IN :processStepIds
                    ]);

            for (SVMXA360__CONF_ProcessStepParameter__c processStepParameter : processStepParameterList) { 
                if( !stepParametersMap.containsKey( processStepParameter.SVMXA360__ProcessWizardStepId__c ) ) { 
                    Adm.ProcessStepParameter stepParameter = new Adm.ProcessStepParameter();
                    List<Adm.ProcessStepParameter> stepParameterList = new List<Adm.ProcessStepParameter>(); 
                    stepParameter = createStepParameterWrapper(processStepParameter);        
                    stepParameterList.add(stepParameter);  
                    stepParametersMap.put(processStepParameter.SVMXA360__ProcessWizardStepId__c , stepParameterList);
                } else {
                    Adm.ProcessStepParameter stepParameter = new Adm.ProcessStepParameter();        
                    stepParameter = createStepParameterWrapper(processStepParameter); 
                    stepParametersMap.get(processStepParameter.SVMXA360__ProcessWizardStepId__c).add(stepParameter);
                }      
            }    
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'createProcessStepParameterWrapper() : Failed to retrieve process step parameters. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createProcessStepParameterWrapper() - exit;');
        }
        
        return stepParametersMap;
    } 

    public Map<String, List<Adm.DependentStep>> createProcessStepDependencyWrapper( List<String> processStepIds ) {
        
        List<SVMXA360__CONF_ProcessWizardStepDependency__c> processStepDependencyList = new List<SVMXA360__CONF_ProcessWizardStepDependency__c>();

        try {
            processStepDependencyList = SvmxDatabase.query([SELECT Id, 
                                                                SVMXA360__ProcessWizardStep__c, 
                                                                SVMXA360__DependentStep__c, 
                                                                SVMXA360__DependentStep__r.Name
                                                            FROM SVMXA360__CONF_ProcessWizardStepDependency__c                             
                                                            WHERE SVMXA360__ProcessWizardStep__c IN :processStepIds
                                                        ]);

            for (SVMXA360__CONF_ProcessWizardStepDependency__c processStepDependency : processStepDependencyList) {
                String currentStepId = processStepDependency.SVMXA360__ProcessWizardStep__c;
                String dependentStepId = processStepDependency.SVMXA360__DependentStep__c;
                if(!String.isBlank(currentStepId) && !String.isBlank(dependentStepId)){
                    Adm.DependentStep dependentStep = createStepDependencyWrapper( processStepDependency ); 
                    if( !stepDependencyMap.containsKey( currentStepId ) ) {        
                        List<Adm.DependentStep> dependentStepList = new List<Adm.DependentStep>{dependentStep};  
                        stepDependencyMap.put(currentStepId, dependentStepList);
                    } else {
                        stepDependencyMap.get(currentStepId).add(dependentStep);
                    } 
                }     
            }    
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'createProcessStepDependencyWrapper() : Failed to retrieve process step dependency. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createProcessStepDependencyWrapper() - exit;');
        }
        return stepDependencyMap;
    } 

    private List<String> getProcessStepIds( List<SVMXA360__CONF_ProcessWizard__c> processWizardRecordList ) {  
        List<String> stepIdList = new List<String>();
        for ( SVMXA360__CONF_ProcessWizard__c wizardRecord : processWizardRecordList ) { 
            for ( SVMXA360__CONF_ProcessWizardStep__c stepRecord : wizardRecord.SVMXA360__Process_Wizard_Steps__r ) {
                stepIdList.add(stepRecord.Id);
            }
        }
        return stepIdList;
    } 
    
    private Adm.ProcessStepParameter createStepParameterWrapper( final SVMXA360__CONF_ProcessStepParameter__c processStepParameter ) {
        
        Adm.ProcessStepParameter stepParameter = new Adm.ProcessStepParameter(); 

        stepParameter.id = processStepParameter.Id;
        stepParameter.valueType = processStepParameter.SVMXA360__ValueType__c;
        stepParameter.parameterKey = processStepParameter.SVMXA360__ParameterKey__c;        
        stepParameter.parameterValue = processStepParameter.SVMXA360__ParameterValue__c;
        stepParameter.processWizardStepId = processStepParameter.SVMXA360__ProcessWizardStepId__c;
        stepParameter.isModified = false;

        return stepParameter;
    }

    private Adm.DependentStep createStepDependencyWrapper( final SVMXA360__CONF_ProcessWizardStepDependency__c processDependency ) {
        
        Adm.DependentStep dependentStep = new Adm.DependentStep();

        dependentStep.id = processDependency.Id;
        dependentStep.dependentStepId = processDependency.SVMXA360__DependentStep__c;
        dependentStep.dependentStepName = processDependency.SVMXA360__DependentStep__r.Name;
        dependentStep.isModified = false;

        return dependentStep;
    }

    private Adm.ProcessAccess createProcessWizardAccessWrapper( final SVMXA360__CONF_ProcessWizardAccess__c processAccessRecord ) {
        
        Adm.ProcessAccess access = new Adm.ProcessAccess();
        
        access.id = processAccessRecord.Id;
        access.name = getProfileName(processAccessRecord.SVMXA360__ProfileId__c);
        access.processWizardId = processAccessRecord.SVMXA360__ProcessWizard__c;
        access.profileId = processAccessRecord.SVMXA360__ProfileId__c;
        access.lastModifiedDate = processAccessRecord.LastModifiedDate;
        access.lastModifiedBy = processAccessRecord.LastModifiedBy.Name;
        access.isModified = false;

        return access;
    }

    private String getProfileName( final Id profileId ) {
        
        if( profileNameMap.isEmpty() ) {
            
            for( Profile profileRecord : (List<Profile>) SvmxDatabase.query([SELECT Id, Name FROM Profile]) ) {
                profileNameMap.put(profileRecord.Id, profileRecord.Name);
            }
        }
        return profileNameMap.get(profileId);
    }
    
    private Adm.ProcessStepTarget createProcessStepTargetWrapper(Object record, String stepTypeName) {
        
        Adm.ProcessStepTarget target = new Adm.ProcessStepTarget();

        if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.FLOW) {
            Common.FlowDefinition flowDefinition = (Common.FlowDefinition) record;
            target.id = flowDefinition.activeVersionId;
            target.label = flowDefinition.label;
            target.apiName = flowDefinition.apiName;
            target.namespacePrefix = flowDefinition.namespacePrefix;
        } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.SPM_TRANSACTION) {
            Adm.PageLayout pageLayout = (Adm.PageLayout) record;
            target.id = pageLayout.id;
            target.label = pageLayout.name;
            target.apiName = pageLayout.developerName;
        } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.RECORD_ACTION) {
            Common.QuickActionDefinition quickAction = (Common.QuickActionDefinition) record;
            target.id = quickAction.id;
            target.label = quickAction.label;
            target.apiName = quickAction.name;
        } else if(ADM_ProcessWizardStepType.valueOf(stepTypeName) == ADM_ProcessWizardStepType.LWC) { 
            Common.LWCRecord lwcRecord = (Common.LWCRecord) record;
            target.id = lwcRecord.id;
            target.label = lwcRecord.masterLabel;
            target.apiName = lwcRecord.developerName;
            target.namespacePrefix = lwcRecord.namespacePrefix;
        }

        return target;
	} 

    private List<Common.ServiceError> validateProcessWizardRequestDetails( final List<Adm.ProcessWizard> processWizards ) {
        List<Common.ServiceError> errors = new List<Common.ServiceError>();

        for (Adm.ProcessWizard processWizard: processWizards) {
            List<Common.ServiceError> processWizardErrors = validateProcessWizardRequest(processWizard);

            if (processWizardErrors.size() > 0) { 
                errors.addAll(processWizardErrors);
            }
        }

        return errors;
    }

    @TestVisible
    private List<Common.ServiceError> validateProcessWizardRequest( final Adm.ProcessWizard processWizard ) {

        List<Common.ServiceError> errors = new List<Common.ServiceError>();
        Boolean processWizardHasError = false;
        String processWizardReferenceId = (processWizard == null || String.isBlank(processWizard.referenceId)) ? '' : processWizard.referenceId;

        if (processWizard == null) {
            addErrorDetail(errors, processWizardReferenceId, ErrorMessage.INVALID_ARGUMENT);
            return errors; // Return early because we can't perform additional checks on a null processWizard object.
        }
        
        if (String.isBlank(processWizard.name) && processWizard.isModified) {
            processWizardHasError = true;
            addErrorDetail(errors, processWizardReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizard__c.Name.getDescribe()));
        }

        if (String.isBlank(processWizard.objectAPIName) && processWizard.isModified) {
            processWizardHasError = true;
            addErrorDetail(errors, processWizardReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizard__c.SVMXA360__ObjectAPIName__c.getDescribe()));
        }

        if (String.isBlank(processWizard.developerName) && processWizard.isModified) {
            processWizardHasError = true;
            addErrorDetail(errors, processWizardReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizard__c.SVMXA360__DeveloperName__c.getDescribe()));
        }

        if (String.isBlank(processWizard.scope) && processWizard.isModified) {
            processWizardHasError = true;
            addErrorDetail(errors, processWizardReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizard__c.SVMXA360__Scope__c.getDescribe()));
        }
           

        if (processWizard.access != null && processWizard.access.size() > 0) {
            for (Adm.ProcessAccess processAccess : processWizard.access) {
                if (String.isBlank(processAccess.profileId)) {

                    // Tracking the processWizardHasError because while ProcessAccess records are stored in a separate collection,
                    //    we want to report the error up to reference from the Process Wizard itself (as opposed to the process wizard access data).
                    if (!processWizardHasError) {
                        processWizardHasError = true;
                        addErrorDetail(errors, processWizardReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizardAccess__c.SVMXA360__ProfileId__c.getDescribe()));
                    }
                }
            }
        } 

        if (processWizard.steps != null && processWizard.steps.size() > 0) {
            for (Adm.ProcessStep processStep : processWizard.steps) {
                List<Common.ServiceError> stepErrors = verifyProcessStep(processStep);

                if( stepErrors != null && stepErrors.size() > 0) {
                    errors.addAll(stepErrors);
                }                        
            }
        }         

        return errors;
    }

    private List<Common.ServiceError> verifyProcessStep( final Adm.ProcessStep processStep ) {
        List<Common.ServiceError> errors = new List<Common.ServiceError>();
        String stepReferenceId = (String.isBlank(processStep.referenceId)) ? '' : processStep.referenceId;

        if( String.isBlank( processStep.name ) && processStep.isModified) {
            addErrorDetail(errors, stepReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizardStep__c.Name.getDescribe()));
        } 
            
        if( String.isBlank( processStep.type) && processStep.isModified) {
            addErrorDetail(errors, stepReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizardStep__c.SVMXA360__Type__c.getDescribe()));
        } 

        if (String.isBlank( processStep.type ) == false && String.isBlank( processStep.target ) && processStep.isModified) {
            addErrorDetail(errors, stepReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessWizardStep__c.SVMXA360__Target__c.getDescribe()));
        }

        if (processStep.stepParameters != null && processStep.stepParameters.size() > 0) {
            for (Adm.ProcessStepParameter stepParameter : processStep.stepParameters) {
                List<Common.ServiceError> parameterErrors = verifyStepParameter(stepParameter);

                if( parameterErrors != null && parameterErrors.size() > 0) {
                    errors.addAll(parameterErrors);
                }                        
            }
        }

        return errors;
    }

    private List<Common.ServiceError> verifyStepParameter( final Adm.ProcessStepParameter stepParameter) {
        List<Common.ServiceError> errors = new List<Common.ServiceError>();
        String parameterReferenceId = (String.isBlank(stepParameter.referenceId)) ? '' : stepParameter.referenceId;
        
        if( String.isBlank( stepParameter.valueType ) && stepParameter.isModified ) {
            addErrorDetail(errors, parameterReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessStepParameter__c.SVMXA360__ValueType__c.getDescribe()));
        } 
            
        if( String.isBlank( stepParameter.parameterKey ) && stepParameter.isModified ) {
            addErrorDetail(errors, parameterReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessStepParameter__c.SVMXA360__ParameterKey__c.getDescribe()));
        } 

        if ( String.isBlank( stepParameter.parameterValue )  && stepParameter.isModified ) {
            addErrorDetail(errors, parameterReferenceId, createRequiredFieldErrorMessage(Schema.SVMXA360__CONF_ProcessStepParameter__c.SVMXA360__ParameterValue__c.getDescribe()));
        }   
        
        return errors;
    } 

    private void addErrorDetail( List<Common.ServiceError> errors, String referenceId, String message ) {
        if (errors == null) {
            errors = new List<Common.ServiceError>();
        }

        Common.ServiceError serviceError;

        // Locate existing reference if it exists
        for (Common.ServiceError existingError : errors) {
            if (existingError.referenceId == referenceId) {
                serviceError = existingError;
                break;
            }
        }

        if (serviceError == null) {
            serviceError = new Common.ServiceError();

            serviceError.referenceId = referenceId;
            errors.add(serviceError);
        } 

        if (serviceError.errors == null) {
            serviceError.errors = new List<Common.ServiceError>();
        }

        Common.ServiceError errorDetail = new Common.ServiceError();
        errorDetail.message = message;

        serviceError.errors.add(errorDetail);
    }

    private String createRequiredFieldErrorMessage(Schema.DescribeFieldResult dfr) {
        return String.format(ERROR_REQUIRED_FIELD, new List<Object> {dfr.getLabel()});
    }

    private SVMXA360__CONF_ProcessWizardStepDependency__c createStepDependencyRecord(Adm.DependentStep dependentStep, String stepId){
        System.debug( LoggingLevel.INFO, 'createStepDependencyRecord() - enter; processStepParameter= ' + dependentStep );
        
        final SVMXA360__CONF_ProcessWizardStepDependency__c stepDependencyRecord = new SVMXA360__CONF_ProcessWizardStepDependency__c();
        
        try {
            
            // Validate for required fields.
            if(String.isBlank( dependentStep.dependentStepId) || String.isBlank(stepId)) {
                System.debug( LoggingLevel.ERROR, 'createStepDependencyRecord() : Invalid request parameters. processStepDependency = ' + dependentStep );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            stepDependencyRecord.Id = dependentStep.id;
            stepDependencyRecord.SVMXA360__ProcessWizardStep__c = stepId;
            stepDependencyRecord.SVMXA360__DependentStep__c = dependentStep.dependentStepId;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'createStepDependencyRecord() : Failed to create Process Wizard Step Parameter sobject. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createStepDependencyRecord() - exit; record= ' + stepDependencyRecord );
        }
        
        return stepDependencyRecord;
    }

    private static String normalizeDeveloperName(String inputValue) {
        if (inputValue != null && inputValue.length() > 140) {
            inputValue = inputValue.substring(0, 140);
        }
    
        return inputValue;
    }
}