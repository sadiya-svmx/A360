/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 * @brief The batch to create service max tag records for all available configurations.
 *
 * @author Sathya Sundaram
 * @version Sum 21
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sathya Sundaram         07 Jun 2021     Created.
 *****************************************************************************************************/
public without sharing class COMM_TranslationDataLoaderBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts {

    private Integer index = -1;
    private ADM_TranslationManager.TranslationContext currentRecord  = null;
    private List<ADM_TranslationManager.TranslationContext> contexts = null;
    private Map<string,SVMXA360__CONF_ServicemaxTags__c> tagMap = new Map<string,SVMXA360__CONF_ServicemaxTags__c> ();
    private CONF_PostInstallLogger logger = CONF_PostInstallLogger.getInstance();
    private List<String> errors = new List<String>();
    private String filename = null;
    private Boolean doReconcile = false;

    public COMM_TranslationDataLoaderBatch ( Boolean reconcile) {
        this(null, reconcile);
    }

    public COMM_TranslationDataLoaderBatch ( String filename) {
        this(filename, false);
    }

    public COMM_TranslationDataLoaderBatch (String filename, Boolean reconcile) {
        
        this.doReconcile = reconcile;
        this.filename = filename;
    }
    
    public List<Object> start(Database.BatchableContext bc) {
        List<Object> objectList = new List<Object>();
        if (this.filename != null) {
            objectList =  ADM_TranslationManager.getInstance().getProcessedContentFromFile(getJsonData(getStaticResourcePath(fileName)));
        } 
        try{
            this.contexts = ADM_TranslationManager.getInstance().getAllTranslationContext();
        } catch (Exception e) {
            errors.add('Config Metadata is inaccessible '+e.getMessage());
        }
        if(this.doReconcile && this.filename == null) {
            if (contexts.isEmpty()){
                errors.add('Empty metadata context');
                return new List<SObject>();
            }
            if(currentRecord == null){
                currentRecord = contexts[0];
            }
            objectList =  ADM_TranslationManager.getInstance().getDataToBeTranslated(currentRecord);
        }
        return objectList;
    }

    public void execute(Database.BatchableContext bc, List<Object> scope) {
        try{
            if(this.filename == null) {
                ADM_TranslationManager.getInstance().reconcileTranslationData((List<SObject>)scope,currentRecord,tagMap);
            } else {
                ADM_TranslationManager.getInstance().saveTranslationData((List<Adm.SvmxTranslations>)scope);
            }
        } catch(DmlException e){
            if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION 
                && e.getMessage().contains('Duplicate')){
                    System.debug('Duplicate');
            } else {
                errors.add(e.getMessage());
            }
        } 
    }

    public void finish( Database.BatchableContext bc ) {

        if (filename !=null) {
            logger.logDetail ('Translations for packaged Data: '+(errors.isEmpty()?'Success':'Failure'));
            if (!doReconcile){
                for (String error: errors) {
                    logger.logDetail (error);
                }
                logger.logSummary('Translations for packaged Data: '+(errors.isEmpty()?'Success':'Failure'));
                try{
                    for(String error: errors) {
                        logger.applicationLog(error);
                    }
                    logger.createApplicationLogs(UserInfo.getUserId());
                } catch(Exception e){
                     logger.logDetail (e.getMessage());
                } finally {
                    logger.sendEmail (UserInfo.getUserId(), doReconcile, null); 
                }
            }
        }

        if( this.doReconcile && !this.contexts.isEmpty() ) {            
            if(filename !=null ){
                this.filename = null;
            }
            if( ++index < contexts.size() ) {
                currentRecord = contexts[index];
                Database.executeBatch(this);
            } else {
                logger.logDetail ('Translations for existing Data: '+(errors.isEmpty()?'Success':'Failure'));
                logger.logSummary('Translations for existing Data: '+(errors.isEmpty()?'Success':'Failure'));
                for (String error: errors) {
                    logger.logDetail (error);
                }
                try{
                    for(String error: errors) {
                        logger.applicationLog(error);
                    }
                    logger.createApplicationLogs(UserInfo.getUserId());
                } catch(Exception e){
                     logger.logDetail (e.getMessage());
                } finally {
                    logger.sendEmail (UserInfo.getUserId(), doReconcile, null); 
                }
            }
        }
    }

    /**
     * This method will get the static resource path for a mentioned file name
     * 
     * @param File name for which the static resource path to be retrieved and
     *        boolean value to check whether its import request
     * 
     * @return Returns static resource file path.
     */
    private String getStaticResourcePath( final String fileName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getStaticResourcePath() - enter; fileName=' + fileName );
        
        String staticResourcePath;
        try {
            
            if( String.isNotBlank(fileName) ) {
                
                final List<StaticResource> staticResourceList = (List<StaticResource>) SvmxDatabase.query( [SELECT Id,Name,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name =: fileName] );
                
                if(staticResourceList != null && staticResourceList.size() > 0) {
                    final String nameSpacePrefix = String.isBlank( staticResourceList.get(0).NamespacePrefix ) ? '' : staticResourceList.get(0).NamespacePrefix+'__';
                    staticResourcePath = '/resource/' + staticResourceList.get(0).SystemModstamp.getTime() + '/' + nameSpacePrefix + fileName;
                }
            }
        }
        catch (Exception e) {
           throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getStaticResourcePath() - exit; staticResourcePath=' + staticResourcePath );
        }
        
        return staticResourcePath;
    }
    
    /**
     * This method reads the json content for the mentioned file.
     * 
     * @param File name for which the json needs to be read.
     * @return This method returns the file content json as a string.
     */
    @SuppressWarnings('PMD.ApexOpenRedirect')
    private String getJsonData(String filePath) {
        
        System.debug( LoggingLevel.DEBUG, 'getJsonData() - enter; filePath= ' + filePath );
        
        String jsonData;
        try {
            
            if( Test.isRunningTest() ) {
                jsonData = '{"translations":[]}';
            } else {
                if(String.isNotBlank(filePath)){
                    PageReference pageReference = new PageReference(filePath);
                    jsonData = pageReference.getContent().toString();
                }
            }
            
        }
        catch(Exception e) {
            
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getJsonData() - exit' );
        }
        return jsonData;
    }
}