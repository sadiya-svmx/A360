/****************************************************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 ***************************************************************************************************************/

/**
 * @brief This class facilitates methods to retrieve configuration used in flow and recordpages of Salesforce Org. 
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
/****************************************************************************************************************
 *    ID        Name                    Date            Comment
 ****************************************************************************************************************
 *              Jyothsna Nagapudi      	12 Aug 2020     Created.
 ****************************************************************************************************************/
public with sharing class ADM_ConfigurationUsageManager{   
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_ConfigurationUsageManager instance;

    /**
     * Public static variable to hold last execution of configuration usage.
     */
    private static datetime configUsageLastExecutedOn;

    /**
     * Public static variable to hold last successful execution of configuration usage.
     */
    public datetime configUsageSuccessLastExecutedOn;

    /**
     * Public static variable to hold status of configuration usage.
     */
    private static String configUsageStatus;

    /**
      * Public static variable to hold message of configuration usage.
     */
    private static String configUsageMessage;

    /**
      * Public variable to hold status of remote site settings.
     */
    public Boolean isRemoteSiteSettingActive = false;
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private ADM_ConfigurationUsageManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_ConfigurationUsageManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'ADM_ConfigurationUsageManager.getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new ADM_ConfigurationUsageManager();
                System.debug( LoggingLevel.INFO, 'ADM_ConfigurationUsageManager.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'ADM_ConfigurationUsageManager.getInstance() - exit' );
        }
        
        return instance;
    }

    /**
    * This method is used to get where used status
    */
    public String getWhereUsedStatus() {

        System.debug(LoggingLevel.DEBUG, 'getWhereUsedStatus() - enter');

		try {

            String remoteSiteSettingsQueryString = 'SELECT Id, SiteName, EndpointUrl,IsActive from RemoteProxy where SiteName = \'Asset360Configurator\'';
            List<Common.RemoteSiteSettings> remoteSiteSettingsList = new List<Common.RemoteSiteSettings>();
            if(!Test.isRunningTest()) {
            	remoteSiteSettingsList = COMM_MetadataManager.getInstance().getRemoteSiteSettingsDetails(remoteSiteSettingsQueryString);
            }

            if (remoteSiteSettingsList.size() > 0 && remoteSiteSettingsList.get(0).isActive) {
                isRemoteSiteSettingActive = true;
            }

            if (isRemoteSiteSettingActive) {
                if (configUsageLastExecutedOn == null || configUsageStatus == null || configUsageMessage == null || configUsageSuccessLastExecutedOn == null) {
                    getConfigurationUsageSettings();
                }

                Long timeFromLastExecution;

                if (configUsageLastExecutedOn != null) {
                    timeFromLastExecution = (System.now().getTime() - configUsageLastExecutedOn.getTime())/1000;
                }
                
                List<String> modifiedRecordPages = getModifiedRecordPages();
                List<String> modifiedFlows = getModifiedFlows();

                if ( String.isBlank(configUsageStatus) || configUsageLastExecutedOn == null ) {
                    refreshConfigurationUsage();
                    return 'NOT COMPLETED';
                } else if ( configUsageStatus.equalsIgnoreCase('TODO') ) {
                    refreshConfigurationUsage();
                    return 'NOT COMPLETED';
                }  else if ( configUsageStatus.equalsIgnoreCase('CANCELLED') ) {
                    refreshConfigurationUsage();
                    return 'NOT COMPLETED';
                } else if ( configUsageStatus.equalsIgnoreCase('INPROGRESS') && timeFromLastExecution < 120) {
                    return 'NOT COMPLETED';
                } else if ( configUsageStatus.equalsIgnoreCase('INPROGRESS') && timeFromLastExecution > 120 ) {
                    CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP601', String.valueOf( 'CANCELLED' ) );
                    CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP603', String.valueOf( System.currentTimeMillis() ) );
                    return 'CANCELLED';
                } else if ( configUsageStatus.equalsIgnoreCase('COMPLETED') && timeFromLastExecution > 120 && (modifiedRecordPages.size() > 0 || modifiedFlows.size() > 0)) {
                    refreshConfigurationUsage();
                    return 'NOT COMPLETED';
                } else if ( configUsageStatus.equalsIgnoreCase('COMPLETED') && timeFromLastExecution > 120 && modifiedRecordPages.size() == 0 && modifiedFlows.size() == 0) {
                    return 'COMPLETED';
                } else if ( configUsageStatus.equalsIgnoreCase('COMPLETED') && timeFromLastExecution <= 120 ) {
                    return 'COMPLETED';
                } else if (configUsageStatus.equalsIgnoreCase('FAILED') && timeFromLastExecution < 120) {
                    return 'NOT COMPLETED';
                } else if (configUsageStatus.equalsIgnoreCase('FAILED') && timeFromLastExecution >= 120) {
                    refreshConfigurationUsage();
                    return 'NOT COMPLETED';
                }
            } else {
                return 'NOT COMPLETED - Remote Site Setting AutoConfigurator is not active';
            }    

            return null;

        }  
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'getWhereUsedStatus() : Failed to invoke configurator. Error' + e.getMessage());
			throw e;
		}
        finally {
			System.debug(LoggingLevel.DEBUG, 'getWhereUsedStatus() - exit' );
		}  
    }    

    /**
    * This method is used to refresh configuration usage
    */
    public void refreshConfigurationUsage() {
              
        System.debug(LoggingLevel.DEBUG, 'refreshConfigurationUsage() - enter');

		try {

            CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP601', String.valueOf( 'INPROGRESS' ) );
            CONF_CustomSettingsManager.getInstance().setGlobalPropertyByName( 'GP603', String.valueOf( System.currentTimeMillis() ) );

            if(!Test.isRunningTest()) {
                configUsageCallout();  
            }
		} 
        catch (Exception e) {
            
            System.debug(LoggingLevel.ERROR, 'refreshConfigurationUsage() : Failed to invoke configurator. Error' + e.getMessage());
			throw e;
		}
        finally {
			System.debug(LoggingLevel.DEBUG, 'refreshConfigurationUsage() - exit' );
		}
    } 
    
    
    @future(callout=true)
    public static void configUsageCallout() {

        System.debug( LoggingLevel.INFO, 'configUsageCallout() - entry' );

        try {
            final Common.SforceSessionInfo authInfo = new Common.SforceSessionInfo();
            
            authInfo.acessToken = !Test.isRunningTest()
                ? Page.COMM_AccessProvider.getContent().toString().trim()
                : '';
            authInfo.serviceEndpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/57.0/';
            
            Http httpConnect = new Http();
            HttpRequest request = new HttpRequest();
            final Common.GlobalProperty globalProperty = CONF_CustomSettingsManager.getInstance().getGlobalPropertyByName( 'GP803' );
            request.setEndpoint( ( globalProperty.value == null ? 'https://asset360tooling.servicemax.com' : globalProperty.value ) + '/svmx/a360/configurator/updateConfigurationUsage/' );
            
            request.setHeader('sforceSessionInfo', JSON.serialize(authInfo) );
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('statusMailId', UserInfo.getUserEmail());
            request.setMethod('GET');
            
            httpConnect.send(request);
        }
        catch(System.CalloutException ex) {
            System.debug( LoggingLevel.ERROR, 'configUsageCallout() : Failed to invoke configuration usage. Error: ' + ex.getMessage() );
        }
        catch(Exception ex) {
            System.debug( LoggingLevel.ERROR, 'configUsageCallout() : Failed to invoke configuration usage. Error: ' + ex.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'configUsageCallout() - exit' );
        }
    }

    /**
     * This method is used to retrieve modified record pages after last execution
     */
    public List<String> getModifiedRecordPages() {
        
        System.debug( LoggingLevel.DEBUG, 'getModifiedRecordPages() - enter' );
        List<String> recordPagesList = new List<String>();
        
        try {
             
            if (configUsageLastExecutedOn == null || configUsageStatus == null || configUsageMessage == null || configUsageSuccessLastExecutedOn == null) {
                getConfigurationUsageSettings();
            }

            // Retrieve configuration Usage

             List<SVMXA360__ConfigurationUsage__c> oldConfigurationUsageList = new List<SVMXA360__ConfigurationUsage__c>();

             List<SVMXA360__ConfigurationUsage__c> unModifiedConfigUsageList = new List<SVMXA360__ConfigurationUsage__c>();

             String entityType = 'RecordPage';


            //Retrieving flexipages related transaction that are already stored in configuration usage.
                
            oldConfigurationUsageList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__TransactionId__c, SVMXA360__EntityType__c, SVMXA360__EntityName__c, SVMXA360__EntityLabel__c FROM SVMXA360__ConfigurationUsage__c WHERE SVMXA360__EntityType__c =: entityType]);


            List<String> oldRecordPagesInConfigUsage = new List<String>();
                
            for(SVMXA360__ConfigurationUsage__c configUsage: oldConfigurationUsageList) {
                oldRecordPagesInConfigUsage.add(configUsage.SVMXA360__EntityName__c);
            }

            //Retrieving all flexipages where 'SPM transaction' is used since we cannot filter by object in MetadataComponentDependency.

            String dependencyQueryString = 'SELECT MetadataComponentName, MetadataComponentType, RefMetadataComponentName, RefMetadataComponentType FROM MetadataComponentDependency where RefMetadataComponentType = \'LightningComponentBundle\' AND MetadataComponentType = \'FlexiPage\'';
            List<Common.ComponentDependency> componentDependencyList = new List<Common.ComponentDependency>();
            if(!Test.isRunningTest()) {
            	componentDependencyList = COMM_MetadataManager.getInstance().getComponentDependencyDetails(dependencyQueryString);
            }
            List<String> newRecordPagesUsedInTransaction = new List<String>();

            for(Common.ComponentDependency dependency : componentDependencyList) {
                if(dependency.refMetadataComponentName == 'runtimeTransaction') {
                    newRecordPagesUsedInTransaction.add(dependency.metadataComponentName);
                }
            }

            //Retrieving all flexipages related to the given object.

            String recordPagequery = 'Select Id,type,DeveloperName,EntityDefinitionId,LastModifiedDate,MasterLabel,NamespacePrefix From FlexiPage';
            List<Common.FlexiPageRecord> flexiPageList = new List<Common.FlexiPageRecord>();
			if(!Test.isRunningTest()) {
            	flexiPageList = COMM_MetadataManager.getInstance().getFlexiPageDetails(recordPagequery);
            }
            List<Common.FlexiPageRecord> filteredFlexiPageList = new List<Common.FlexiPageRecord>();

            for (Common.FlexiPageRecord flexiPage : flexiPageList) {
                if ( newRecordPagesUsedInTransaction.size() > 0 && newRecordPagesUsedInTransaction.contains(flexiPage.DeveloperName)) {
                    filteredFlexiPageList.add(flexiPage);
                }
            }

            List<String> unModifiedrecordPagesList = new List<String>();

            //seggregating modified flexipage after last execution

            for (Common.FlexiPageRecord flexiPage : filteredFlexiPageList) {
                String flexiPageName = '';
                if ( flexiPage.namespacePrefix != NULL ) {
                    flexiPageName = flexiPage.namespacePrefix + '__' + flexiPage.DeveloperName;   
                } else {
                    flexiPageName = flexiPage.DeveloperName;
                }
                if ( oldRecordPagesInConfigUsage.size() > 0 && oldRecordPagesInConfigUsage.contains(flexiPageName) && configUsageLastExecutedOn != null && flexiPage.lastModifiedDate < configUsageLastExecutedOn) {
                    unModifiedrecordPagesList.add(flexiPageName);
                } else {
                    recordPagesList.add(flexiPageName);
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getModifiedRecordPages() : Retrieved all configuration filters');
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getModifiedRecordPages() : Failed to retrieve configuration filters. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getModifiedRecordPages() - exit; recordPagesList.size()= ' + recordPagesList.size() );
        }
        
        return recordPagesList;
    }

    /**
    * This method is used to retrieve modified flows after last execution
    */
    public List<String> getModifiedFlows() {
        
        System.debug( LoggingLevel.DEBUG, 'getModifiedFlows() - enter' );
        List<String> filteredFlowList = new List<String>();
        
        try {
             
            if (configUsageLastExecutedOn == null || configUsageStatus == null || configUsageMessage == null || configUsageSuccessLastExecutedOn == null) {
                getConfigurationUsageSettings();
            }

            // Retrieve configuration Usage

             List<SVMXA360__ConfigurationUsage__c> oldConfigurationUsageList = new List<SVMXA360__ConfigurationUsage__c>();

             List<SVMXA360__ConfigurationUsage__c> unModifiedConfigUsageList = new List<SVMXA360__ConfigurationUsage__c>();

             String entityType = 'Flow';


            //Retrieving flexipages related transaction that are already stored in configuration usage.
                
            oldConfigurationUsageList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__TransactionId__c, SVMXA360__EntityType__c, SVMXA360__EntityName__c, SVMXA360__EntityId__c, SVMXA360__EntityLabel__c FROM SVMXA360__ConfigurationUsage__c WHERE SVMXA360__EntityType__c =: entityType]);


            List<String> oldFlowsUsedInTransaction = new List<String>();
                
            for(SVMXA360__ConfigurationUsage__c configUsage: oldConfigurationUsageList) {
                oldFlowsUsedInTransaction.add(configUsage.SVMXA360__EntityId__c);
            }

            List<String> newFlowsUsedInTransaction = new List<String>();

            //Retrieving all screen flows.

            String flowQuery = 'Select Id,MasterLabel,ProcessType,Status,LastModifiedDate From Flow where processType = \'Flow\'';
            
            List<Common.FlowRecord> flowList = new List<Common.FlowRecord>();
			if(!Test.isRunningTest()) {
            	flowList = COMM_MetadataManager.getInstance().getFlowDetails(flowQuery);
            }    

            //seggregating modified flexipage after last execution

            List<String> unModifiedFlowList = new List<String>();
            Set<String> flowIdsInOrg = new Set<String>();

            for (Common.FlowRecord flow : flowList) {
                flowIdsInOrg.add(flow.id);
                if ( (oldFlowsUsedInTransaction.size() > 0 && oldFlowsUsedInTransaction.contains(flow.id) && configUsageLastExecutedOn != null && flow.lastModifiedDate < configUsageLastExecutedOn) ||
                     (configUsageLastExecutedOn != null && flow.lastModifiedDate < configUsageLastExecutedOn) ) {
                    unModifiedFlowList.add(flow.id);
                } else {
                    filteredFlowList.add(flow.id);
                }
            }

            for (String flowid : oldFlowsUsedInTransaction) {
                if(!flowIdsInOrg.contains(flowid)) {
                    filteredFlowList.add(flowid);
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getModifiedFlows() : Retrieved all configuration filters');
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getModifiedFlows() : Failed to retrieve configuration filters. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getModifiedFlows() - exit; filteredFlowList.size()= ' + filteredFlowList.size() );
        }
        
        return filteredFlowList;
    }

    /**
    * This method is used to retrieve configuration usage settings
    */
    public void getConfigurationUsageSettings() {

        //Retrieving configuration usage settings to find the last execution time, status, message.

        List<SVMXA360__CONF_CSET_GlobalProperties__c> configurationUsageSettings = CONF_CustomSettingsManager.getInstance().getGlobalPropertyValues('CONFIGURATION_USAGE_SETTING');

        for (SVMXA360__CONF_CSET_GlobalProperties__c setting : configurationUsageSettings) {
            if (setting.Name == 'GP601' && setting.SVMXA360__Value__c != null) {
                configUsageStatus = setting.SVMXA360__Value__c;
            } else if (setting.Name == 'GP602' && setting.SVMXA360__Value__c != null) {
                configUsageMessage = setting.SVMXA360__Value__c;
            } else if (setting.Name == 'GP603' && setting.SVMXA360__Value__c != null) {
                configUsageLastExecutedOn = Datetime.newInstance(Long.valueOf(setting.SVMXA360__Value__c));
            } else if (setting.Name == 'GP604' && setting.SVMXA360__Value__c != null) {
                configUsageSuccessLastExecutedOn = Datetime.newInstance(Long.valueOf(setting.SVMXA360__Value__c));
            }
        }
        System.debug('configUsageLastExecutedOn:'+ configUsageLastExecutedOn);

    } 
    /**
     * This method is used to save/update configuration usage.
     * 
     * @param configurationUsages - list of configuration usage to save.
     */
    public List<Adm.ConfigurationUsage> saveConfigurationUsages( final List<Adm.ConfigurationUsage> configurationUsages ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveConfigurationUsages() - enter');
        
        Savepoint sPoint = Database.setSavepoint();

        List<Adm.ConfigurationUsage> savedConfigurationUsages = new List<Adm.ConfigurationUsage>();
        
        try {
            
            // Verify request informations.
            if( configurationUsages == null || configurationUsages.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveConfigurationUsages() : Invalid request parameters. configurationUsages= ' + configurationUsages );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<SVMXA360__ConfigurationUsage__c> configUsageList = new List<SVMXA360__ConfigurationUsage__c>();
            
            // Upsert configuration usage record.
            for(Adm.ConfigurationUsage configUsage : configurationUsages) {
                configUsageList.add(createConfigUsageRecord(configUsage));
            }

            // Upsert confifuration usage records
            configUsageList = SvmxDatabase.upsertRecord(configUsageList);

            for(SVMXA360__ConfigurationUsage__c configUsage : configUsageList) {
                savedConfigurationUsages.add(createConfigUsageWrapper(configUsage));
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveConfigurationUsages() : Failed to save configuration usage. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveConfigurationUsages() : Failed to save configuration usage. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigurationUsages() - exit; savedConfigurationUsages size= ' + savedConfigurationUsages.size() );
        }
        
        return savedConfigurationUsages;
    } 

    /**
    * This method is used to retrieve all the configuration usage.
    */
    public List<Adm.ConfigurationUsage> getAllConfigurationUsages() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllConfigurationUsages() - enter' );
        
        List<Adm.ConfigurationUsage> configurationUsages = new List<Adm.ConfigurationUsage>();
        
        try {
            
            // Retrieve all configuration usage
            final List<SVMXA360__ConfigurationUsage__c> configurationUsageList = getAllConfigurationUsageRecords();
            
            if( configurationUsageList.size() > 0 ) {
                
                // Create configuration usage wrapper for each configuration usage retrieved.
                for( SVMXA360__ConfigurationUsage__c configurationUsageRecord : configurationUsageList ) {
                    configurationUsages.add( createConfigUsageWrapper( configurationUsageRecord ) );
                }
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationUsages() : Retrieved all configuration usage' );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationUsages() : Failed to retrieve configuration usage. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationUsages() - exit; configurationUsages.size()= ' + configurationUsages.size() );
        }
        
        return configurationUsages;
    }

    /**
    * This public method executes the query to return all configuration usages 
    */
    public List<SVMXA360__ConfigurationUsage__c> getAllConfigurationUsageRecords() {
        return SvmxDatabase.query([SELECT Id, Name, SVMXA360__EntityId__c, SVMXA360__EntityLabel__c, SVMXA360__EntityName__c, SVMXA360__EntityType__c,
                                SVMXA360__TransactionId__c FROM SVMXA360__ConfigurationUsage__c]);
    }

    /**
    * Private method to create configuration usage record.
    */
    private SVMXA360__ConfigurationUsage__c createConfigUsageRecord( final Adm.ConfigurationUsage configUsage ) {
        
        System.debug( LoggingLevel.FINE, 'createConfigUsageRecord() - enter; configUsage= ' + configUsage );
        
        SVMXA360__ConfigurationUsage__c configUsageRecord = new SVMXA360__ConfigurationUsage__c();
        
        if( configUsage.id != null ) {
            configUsageRecord.Id = configUsage.id;
        }

        configUsageRecord.SVMXA360__EntityId__c = configUsage.entityId;
        configUsageRecord.SVMXA360__EntityLabel__c = configUsage.entityLabel;
        configUsageRecord.SVMXA360__EntityName__c = configUsage.entityName;
        configUsageRecord.SVMXA360__EntityType__c = configUsage.entityType;
        configUsageRecord.SVMXA360__TransactionId__c = configUsage.configurationId;
        
        return configUsageRecord;
    } 
    
        /**
    * Private method to create configuration usage record.
    */
    private Adm.ConfigurationUsage createConfigUsageWrapper( final SVMXA360__ConfigurationUsage__c configUsageRecord ) {
        
        System.debug( LoggingLevel.FINE, 'createConfigUsageWrapper() - enter; configUsageRecord= ' + configUsageRecord );
        
        Adm.ConfigurationUsage configUsage = new Adm.ConfigurationUsage();
       
        configUsage.Id = configUsageRecord.id;
        configUsage.entityId = configUsageRecord.SVMXA360__EntityId__c;
        configUsage.entityLabel = configUsageRecord.SVMXA360__EntityLabel__c;
        configUsage.entityName = configUsageRecord.SVMXA360__EntityName__c;
        configUsage.entityType = configUsageRecord.SVMXA360__EntityType__c;
        configUsage.configurationId = configUsageRecord.SVMXA360__TransactionId__c;
        
        return configUsage;
    } 
}