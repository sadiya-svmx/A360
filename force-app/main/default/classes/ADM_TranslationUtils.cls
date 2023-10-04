/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve Admin Pages.
 *
 * @author Sathya Pachaiappan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                        Date            Comment
 *****************************************************************************************************
 *              Sathya Pachaiappan        2 May 2021        Created.
 *****************************************************************************************************/
public with sharing class ADM_TranslationUtils {

    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_TranslationUtils instance;
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_TranslationUtils getInstance() {
        
        if( instance == null ) {
            instance = new ADM_TranslationUtils();
        }
        
        return instance;
    }

    public List<SObject> getTranslatedRecord(List<SObject> objRecords){
        if(objRecords == null || objRecords.isEmpty()){
            return new List<Sobject>();
        }
        List<ADM_TranslationManager.TranslationContextMetadata> translationContexts = ADM_TranslationManager.getInstance().getContextMetadataForObjectName(objRecords[0].id.getSObjectType().getDescribe().getName());
        Map<String,String> fieldNameValueMap = new Map<String,String>();
        List<String> masterTextList = new List<String>();
        List<String> contexts = new List<String>();
        for(SObject objRecord: objRecords){
            for(ADM_TranslationManager.TranslationContextMetadata translationContext: translationContexts){
                String masterText = (String)objRecord
                    .get(translationContext.fieldName);
                if(String.isNotBlank(masterText)){
                    masterTextList.add(masterText);
                    contexts.add(translationContext.context);
                }
            }
        }
        Map<String,String> tagMap = getTranslationMapForTags(contexts, masterTextList);
        for(SObject objectRecord: objRecords){
            for(ADM_TranslationManager.TranslationContextMetadata translationContext: translationContexts){
                String masterText = (String)objectRecord.get(translationContext.fieldName);
                String context = translationContext.context;
                String tagMapKey = context+masterText;
                if(tagMap.containsKey(tagMapKey)){
                    objectRecord.put(translationContext.fieldName,tagMap.get(tagMapKey));
                }
            }
        }
        return objRecords;
    }

    public SObject getTranslatedRecord(SObject objectRecord) {
        List<ADM_TranslationManager.TranslationContextMetadata> translationContexts = ADM_TranslationManager.getInstance().getContextMetadataForObjectName(objectRecord.id.getSObjectType().getDescribe().getName());
        List<String> masterTextList = new List<String>();
        List<String> contexts = new List<String>();
        for(ADM_TranslationManager.TranslationContextMetadata translationContext: translationContexts){
            String masterText = (String)objectRecord.get(translationContext.fieldName);
            if(String.isNotBlank(masterText)){
                masterTextList.add(masterText);
                contexts.add(translationContext.context);
            }
        }
        Map<String,String> tagMap = getTranslationMapForTags(contexts, masterTextList);
        for(ADM_TranslationManager.TranslationContextMetadata translationContext: translationContexts){
            String masterText = (String)objectRecord.get(translationContext.fieldName);
            String context = translationContext.context;
            String tagMapKey = context+masterText;
            if(tagMap.containsKey(tagMapKey)){
                objectRecord.put(translationContext.fieldName,tagMap.get(tagMapKey));
            }
        }
        return objectRecord;
    }

    public Map<String,String> getTranslationMapForTags(List<String> contexts,List<String> masterTextList){
        Map<String,String> tagMap = new Map<String,String>();
        String userLanguage = UserInfo.getLanguage();
        List<SVMXA360__CONF_ServicemaxTags__c> tagList = 
                     SvmxDatabase.query([select ID, 
                            SVMXA360__MasterText__c,
                            SVMXA360__Context__c,
                            (SELECT Id, 
                            Name, 
                            SVMXA360__Value__c
                            FROM SVMXA360__CONF_TagTranslations__r where Name=: userLanguage ) 
                    from SVMXA360__CONF_ServicemaxTags__c 
                    where SVMXA360__Context__c in: contexts 
                    and SVMXA360__MasterText__c in: masterTextList]);
        for(SVMXA360__CONF_ServicemaxTags__c tag: tagList){
            String masterText = tag.SVMXA360__MasterText__c;
            String context = tag.SVMXA360__Context__c;
            if(tag.SVMXA360__CONF_TagTranslations__r != null  
                && tag.SVMXA360__CONF_TagTranslations__r.size() >0){
                String translatedValue = tag.SVMXA360__CONF_TagTranslations__r[0].SVMXA360__Value__c;
                if(String.isNotBlank(translatedValue)){
                    tagMap.put(context+masterText, translatedValue);
                }
            }
        }
        return tagMap;
    }

    public void createTranslatedRecord(List<SObject> objRecords){
        if(objRecords == null || objRecords.isEmpty()){
             return;
        }
        List<ADM_TranslationManager.TranslationContextMetadata> translationContexts = ADM_TranslationManager.getInstance().getContextMetadataForObjectName(objRecords[0].id.getSObjectType().getDescribe().getName());
        Map<string,SVMXA360__CONF_ServicemaxTags__c> tagMap = new Map<string,SVMXA360__CONF_ServicemaxTags__c> ();
        for(SObject objRecord: objRecords){
            for(ADM_TranslationManager.TranslationContextMetadata translationContext: translationContexts){
                String masterText = (String)objRecord
                    .get(translationContext.fieldName);
                if(String.isNotBlank(masterText)){
                    SVMXA360__CONF_ServicemaxTags__c tag = new SVMXA360__CONF_ServicemaxTags__c();
                    tag.SVMXA360__MasterText__c = masterText;
                    tag.SVMXA360__Context__c = translationContext.context;
                    tagMap.put(tag.SVMXA360__MasterText__c+tag.SVMXA360__Context__c, tag);
                }
            }
        }
        try{
            Database.insert(tagMap.values(),false);
        }catch(Exception e){
            System.debug('Duplicates');
        }
     }

     private ADM_TranslationUtils() {
         
     }
}