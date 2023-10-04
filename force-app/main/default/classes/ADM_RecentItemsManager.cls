/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save recent items.
 *
 * @author Jyothsna S
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna N              15 Nov 2021      Created.     
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_RecentItemsManager {

    private static ADM_RecentItemsManager instance;

    public static ADM_RecentItemsManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_RecentItemsManager();
        }
        
        return instance;
    }

    public List<Adm.RecentItemInfo> getRecentItemsDetails(){
        
        System.debug( LoggingLevel.DEBUG, 'getRecentItemsDetails() - enter');
        
        List<Adm.RecentItemInfo> recentItemInfos = new List<Adm.RecentItemInfo>();  
        
        try{

            List<SVMXA360__COMM_Recentitem__c> recentItemsList = new List<SVMXA360__COMM_Recentitem__c>();

           
            recentItemsList = getRecentItemsRecords();

            //recentItemsList will have only 10 records at a time

            for (SVMXA360__COMM_Recentitem__c recentItem : recentItemsList) {

                if ( recentItem.SVMXA360__ConfigurationType__c == 'Entitlement Service Assignment Rules' ) {

                    SVMXA360__CONF_EntitledServiceAssignmentRule__c config = [SELECT Id, Name FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Expression' ) {

                    SVMXA360__CONF_Expression__c config = [SELECT Id, Name FROM SVMXA360__CONF_Expression__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Mapping' ) {

                    SVMXA360__CONF_ObjectMapping__c config = [SELECT Id, Name FROM SVMXA360__CONF_ObjectMapping__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Asset Hierarchy' ) {

                    SVMXA360__CONF_HierarchyConfig__c config = [SELECT Id, Name FROM SVMXA360__CONF_HierarchyConfig__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Asset Timeline' ) {

                    SVMXA360__CONF_TimelineConfig__c config = [SELECT Id, Name FROM SVMXA360__CONF_TimelineConfig__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'PSC Congfiguration Templates' ) {

                    SVMXA360__CONF_PSCConfiguration__c config = [SELECT Id, Name FROM SVMXA360__CONF_PSCConfiguration__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Wizard' ) {

                    SVMXA360__CONF_ProcessWizardStep__c config = [SELECT Id, Name FROM SVMXA360__CONF_ProcessWizardStep__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Automatic Rules' ) {

                    SVMXA360__CONF_EntitlementRule__c config = [SELECT Id, Name FROM SVMXA360__CONF_EntitlementRule__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Priceboook Assignment Rules' ) {

                    SVMXA360__CONF_PricebookAssignmentRule__c config = [SELECT Id, Name FROM SVMXA360__CONF_PricebookAssignmentRule__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Transaction' ) {

                    SVMXA360__CONF_Layout__c config = [SELECT Id, Name FROM SVMXA360__CONF_Layout__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Screen' ) {

                    SVMXA360__CONF_Layout__c config = [SELECT Id, Name FROM SVMXA360__CONF_Layout__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Template Rules' ) {

                    SVMXA360__CONF_TA_TemplateMatchRule__c config = [SELECT Id, SVMXA360__RuleName__c FROM SVMXA360__CONF_TA_TemplateMatchRule__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.SVMXA360__RuleName__c;

                } else if ( recentItem.SVMXA360__ConfigurationType__c == 'Maintenance Plan' ) {

                    SVMXA360__SM_MaintenancePlanProcess__c config = [SELECT Id, Name FROM SVMXA360__SM_MaintenancePlanProcess__c WHERE Id =: recentItem.SVMXA360__ConfigurationId__c];
                    recentItem.SVMXA360__AdminConfigurationName__c = config.Name;

                }
                recentItemInfos.add( createRecentItemWrapper( recentItem ) );
            }

        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getRecentItemsDetails() : Failed to retrieve recent items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecentItemsDetails() - exit; recentItemInfos.size()= ' + recentItemInfos.size() );
        }

        return recentItemInfos;
    }

    /**
     * This method is used to retrieve all recent item records.
     */
    public List<SVMXA360__COMM_Recentitem__c> getRecentItemsRecords() {

        final List<SVMXA360__COMM_Recentitem__c> recentItemList;
        Map<String, SVMXA360__COMM_Recentitem__c> recentItemMap = new Map<String, SVMXA360__COMM_Recentitem__c>();

        try {
            //filtering unique records. If duplicate records are created when configutaion items open in mulitple tabs and browsers at same time
            recentItemList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationType__c, LastModifiedDate, SVMXA360__ObjectAPIName__c FROM SVMXA360__COMM_Recentitem__c 
            WHERE CreatedById = :UserInfo.getUserId() ORDER BY LastModifiedDate DESC LIMIT 100]);
            for (SVMXA360__COMM_Recentitem__c recentItem : recentItemList) {
                if (recentItemMap.size() < 10) {
                    if (!recentItemMap.containsKey(recentItem.SVMXA360__ConfigurationId__c)) {
                        recentItemMap.put(recentItem.SVMXA360__ConfigurationId__c, recentItem);
                    }
                } else {
                    break;
                }

            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getRecentItemsRecords() : Failed to retrieve Admin Pages. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecentItemsRecords() - exit; recentItemList.size()= ' + recentItemList.size() );
        }

        return recentItemMap.values();
    }

    /**
     * This method is used to delete recent item records.
     */
    public void deleteRecentItemsDetails( List<Adm.RecentItemInfo> recentItemInfo ){
        
        System.debug( LoggingLevel.DEBUG, 'deleteRecentItemsDetails() - enter' + recentItemInfo);  
        
        try{

            if( recentItemInfo == null || recentItemInfo.size() == 0 ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<SVMXA360__COMM_Recentitem__c> recentItemsList = new List<SVMXA360__COMM_Recentitem__c>();

            recentItemsList = fetchRecentItemsRecords(recentItemInfo);

            SvmxDatabase.deleteRecord(recentItemsList);

        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'deleteRecentItemsDetails() : Failed to delete recent items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteRecentItemsDetails() - exit;' );
        }
    }

    /**
     * This method is used to fetch recent item records.
     */
    public List<SVMXA360__COMM_Recentitem__c> fetchRecentItemsRecords( List<Adm.RecentItemInfo> recentItemInfo ) {

        final List<SVMXA360__COMM_Recentitem__c> recentItemList;
        Set<String> recentItemIds = new Set<String>();

        try {

            for ( Adm.RecentItemInfo recentItem : recentItemInfo) {
                recentItemIds.add(recentItem.configurationId);   
            }

            recentItemList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationType__c, LastModifiedDate, SVMXA360__ObjectAPIName__c FROM SVMXA360__COMM_Recentitem__c 
            WHERE SVMXA360__ConfigurationId__c IN :recentItemIds]);
        }
        catch( Exception e ) {

            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchRecentItemsRecords() - exit; recentItemList.size()= ' + recentItemList.size() );
        }

        return recentItemList;
    }
    public Adm.RecentItemInfo saveRecentItem( Adm.RecentItemInfo recentItemInfo ){
        
        System.debug( LoggingLevel.DEBUG, 'saveRecentItem() - enter' + recentItemInfo);

        Savepoint sp = Database.setSavePoint();

        try{

            if(recentItemInfo == null){
                System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Invalid request parameters. recentItemInfo= ' + recentItemInfo );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );            
            }
            
            SVMXA360__COMM_Recentitem__c recentItemRecord = new SVMXA360__COMM_Recentitem__c();


            List<SVMXA360__COMM_Recentitem__c> recentItemList = SvmxDatabase.query( [SELECT Id, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationType__c, CreatedById, LastModifiedDate, SVMXA360__ObjectAPIName__c FROM SVMXA360__COMM_Recentitem__c 
            WHERE SVMXA360__ConfigurationId__c = :recentItemInfo.configurationId AND SVMXA360__ConfigurationType__c = :recentItemInfo.configurationType AND CreatedById = :UserInfo.getUserId()]);
			
            if (recentItemList.size() > 0) {
                recentItemRecord = recentItemList.get(0);
            } else {
                SVMXA360__COMM_Recentitem__c recentItemPrev = new SVMXA360__COMM_Recentitem__c();
                List<SVMXA360__COMM_Recentitem__c> recentItemsList = getRecentItemsRecords();
                Integer recentItemSize = recentItemsList.size();
                if ( recentItemSize >= 10 ) {
                    recentItemPrev = recentItemsList.get(recentItemSize - 1 );
                    recentItemRecord = mapRecentItemFields(recentItemPrev, recentItemInfo);
                } else {
                    recentItemRecord = mapRecentItemFields(recentItemInfo);
                }
            }
           	recentItemRecord = (SVMXA360__COMM_Recentitem__c)SvmxDatabase.upsertRecord(recentItemRecord);
            recentItemInfo = createRecentItemWrapper(recentItemRecord);
            
        }catch(SvmxSystem.SvmxNestedException e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Failed to save page layout. Error= ' + e.getMessage() );
            throw e;
        }catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Failed to save page layout. Error= ' + e.getMessage());
            throw e;
        }catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Failed to save page layout. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'saveRecentItem() - exit; pageLayoutInfo ' + recentItemInfo );
        }

        return recentItemInfo;
    }

    public void saveRecentItems( List<Adm.RecentItemInfo> recentItemInfoList ){
        
        System.debug( LoggingLevel.DEBUG, 'saveRecentItems() - enter' );

        Savepoint sp = Database.setSavePoint();

        try{

            if(recentItemInfoList.size() < 0){
                System.debug( LoggingLevel.ERROR, 'saveRecentItems() : Invalid request parameters. recentItemInfoList= ' + recentItemInfoList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );            
            }
            
            Map<String, SVMXA360__COMM_Recentitem__c> recentItemRecordMap = new Map<String, SVMXA360__COMM_Recentitem__c>();
            List<SVMXA360__COMM_Recentitem__c> recentItemRecordList = new List<SVMXA360__COMM_Recentitem__c>();
            List<String> configurationIds = new List<String>();
            String configurationType = recentItemInfoList.get(0).configurationType;

            for(Adm.RecentItemInfo recentItemInfo : recentItemInfoList) {
                configurationIds.add(recentItemInfo.configurationId);
            }


            List<SVMXA360__COMM_Recentitem__c> recentItemList = SvmxDatabase.query( [SELECT Id, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationType__c, CreatedById, LastModifiedDate, SVMXA360__ObjectAPIName__c FROM SVMXA360__COMM_Recentitem__c 
            WHERE SVMXA360__ConfigurationId__c = :configurationIds AND SVMXA360__ConfigurationType__c = :configurationType AND CreatedById = :UserInfo.getUserId()]);
			
            for(SVMXA360__COMM_Recentitem__c recentItem : recentItemList) {
                recentItemRecordMap.put(recentItem.SVMXA360__ConfigurationId__c, recentItem);
            }

            SVMXA360__COMM_Recentitem__c recentItemPrev = new SVMXA360__COMM_Recentitem__c();
            List<SVMXA360__COMM_Recentitem__c> recentItemsList = getRecentItemsRecords();
            Integer currentRecentItemSize = recentItemsList.size();

            for(Adm.RecentItemInfo recentItemInfo : recentItemInfoList) {
                if(recentItemRecordMap.containsKey(recentItemInfo.configurationId)) {
                    SVMXA360__COMM_Recentitem__c existingRecord = new SVMXA360__COMM_Recentitem__c();
                    existingRecord = recentItemRecordMap.get(recentItemInfo.configurationId);
                    recentItemRecordList.add(existingRecord);
                    recentItemList.remove(recentItemList.indexOf(existingRecord));
                } else {
                    Integer count = recentItemsList.size();
                    if ( count == 0 ) {
                        break;
                    }
                    if ( currentRecentItemSize >= 10) {
                        recentItemPrev = recentItemsList.get( count - 1 );
                        recentItemsList.remove(count - 1);
                        recentItemRecordList.add(mapRecentItemFields(recentItemPrev, recentItemInfo));
                    } else {
                        recentItemRecordList.add(mapRecentItemFields(recentItemInfo));
                        currentRecentItemSize = currentRecentItemSize + 1;
                    }
                }
                
            }
            recentItemRecordList = SvmxDatabase.upsertRecord(recentItemRecordList);
            
        }catch(SvmxSystem.SvmxNestedException e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveRecentItems() : Failed to save recentItemInfo. Error= ' + e.getMessage() );
            throw e;
        }catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveRecentItems() : Failed to save recentItemInfo. Error= ' + e.getMessage());
            throw e;
        }catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'saveRecentItems() : Failed to save recentItemInfo. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'saveRecentItems() - exit; recentItemInfo ' );
        }
    }

    SVMXA360__COMM_Recentitem__c mapRecentItemFields(final Adm.RecentItemInfo recentItemInfo){
        SVMXA360__COMM_Recentitem__c recentItemRecord = new SVMXA360__COMM_Recentitem__c();
        if(recentItemInfo.id != null){
            recentItemRecord.Id = recentItemInfo.id;
        }
        recentItemRecord.SVMXA360__AdminConfigurationName__c = recentItemInfo.configurationName;         
        recentItemRecord.SVMXA360__ConfigurationDeveloperName__c = recentItemInfo.configurationDeveloperName;
        recentItemRecord.SVMXA360__ConfigurationId__c = recentItemInfo.configurationId;
        recentItemRecord.SVMXA360__ConfigurationType__c = recentItemInfo.configurationType;
        recentItemRecord.SVMXA360__ObjectAPIName__c = recentItemInfo.objectApiName;
    
        return recentItemRecord;
    }

    SVMXA360__COMM_Recentitem__c mapRecentItemFields(SVMXA360__COMM_Recentitem__c recentItemInfoPrev, Adm.RecentItemInfo recentItemInfo){
        
        recentItemInfoPrev.SVMXA360__AdminConfigurationName__c = recentItemInfo.configurationName;         
        recentItemInfoPrev.SVMXA360__ConfigurationDeveloperName__c = recentItemInfo.configurationDeveloperName;
        recentItemInfoPrev.SVMXA360__ConfigurationId__c = recentItemInfo.configurationId;
        recentItemInfoPrev.SVMXA360__ConfigurationType__c = recentItemInfo.configurationType;
        recentItemInfoPrev.SVMXA360__ObjectAPIName__c = recentItemInfo.objectApiName;
    
        return recentItemInfoPrev;
    }

    Adm.RecentItemInfo createRecentItemWrapper( final SVMXA360__COMM_Recentitem__c recentItemRecord ){
        final Adm.RecentItemInfo recentItemInfo = new Adm.RecentItemInfo();
        recentItemInfo.id = recentItemRecord.Id;
        recentItemInfo.configurationName = recentItemRecord.SVMXA360__AdminConfigurationName__c;
        recentItemInfo.configurationDeveloperName = recentItemRecord.SVMXA360__ConfigurationDeveloperName__c;
        recentItemInfo.configurationId = recentItemRecord.SVMXA360__ConfigurationId__c;
        recentItemInfo.configurationType = recentItemRecord.SVMXA360__ConfigurationType__c;
        recentItemInfo.configurationDate = recentItemRecord.LastModifiedDate;
        recentItemInfo.objectApiName = recentItemRecord.SVMXA360__ObjectAPIName__c;

        return recentItemInfo;
    }

    ADM_RecentItemsManager(){}
}