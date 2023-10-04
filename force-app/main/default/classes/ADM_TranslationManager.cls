/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_TranslationManager {
   
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_TranslationManager instance;
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_TranslationManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_TranslationManager();
        }
        return instance;
    }

    public List<Adm.SvmxTranslations> getAllConfigTranslations () {
        List<Adm.SvmxTranslations> translationsList  =  new List<Adm.SvmxTranslations>();
       
        for (SVMXA360__CONF_ServicemaxTags__c tag: 
                (List<SVMXA360__CONF_ServicemaxTags__c>)SvmxDatabase.query( [select Id,SVMXA360__MasterText__c,SVMXA360__Context__c, LastModifiedDate, LastModifiedBy.Name,(select Name, SVMXA360__Value__c, LastModifiedDate, LastModifiedBy.Name from SVMXA360__CONF_TagTranslations__r order by LastModifiedDate desc)  from SVMXA360__CONF_ServicemaxTags__c] )){
            translationsList.add(populateSvmxTranslationRecord(tag));
        }
        return translationsList;
    }

    public  List<Adm.TranslationTag> getTranslations(String language, String contextName ) {

        String query = 'select Id,SVMXA360__MasterText__c,SVMXA360__Context__c,(select Name, SVMXA360__Value__c from SVMXA360__CONF_TagTranslations__r where name=';
        query += '\''+String.escapeSingleQuotes(language)+'\' ) from SVMXA360__CONF_ServicemaxTags__c ';
        if (contextName != null && !contextName.equalsIgnoreCase('all')){
            query += ' where SVMXA360__Context__c = \''+contextName+'\'';
        }
        List<Adm.TranslationTag> tagList = new List<Adm.TranslationTag>();
        Map<String,String> contextMap = getTranslationContextMap();
        for (SVMXA360__CONF_ServicemaxTags__c tag: 
                (List<SVMXA360__CONF_ServicemaxTags__c>)SvmxDatabase.query( query )){
            tagList.add(createTranslationTagRecord(tag,language,contextMap));
        }
        return tagList;

    }


    public  List<Adm.TranslationTag> getTagDetails(String translationTagId ){
        List<Adm.TranslationTag> tagList = new List<Adm.TranslationTag>();
        for (SVMXA360__CONF_ServicemaxTags__c tag: 
                (List<SVMXA360__CONF_ServicemaxTags__c>)SvmxDatabase.query( [select Id,SVMXA360__MasterText__c,SVMXA360__Context__c,(select Name, SVMXA360__Value__c from SVMXA360__CONF_TagTranslations__r order by LastModifiedDate desc) from SVMXA360__CONF_ServicemaxTags__c  where Id=:translationTagId] )){
            tagList.addAll(createTranslationTagRecord(tag));
        }
        return tagList;

    }


    public  List<Adm.option> getTranslationContexts () {
        List<TranslationContextMetadata> contextMetadatas = getContextMetadatas();
        Map<String,Adm.option> options = new Map<String,Adm.option> ();
        Adm.option option = new Adm.option();
        option.label = 'All';
        option.value = 'all'; 
        options.put('all',option);
        for (TranslationContextMetadata context: contextMetadatas){
            if(!options.containsKey(context.context)){
                Adm.option contextOption = new Adm.option();
                contextOption.label = context.label;
                contextOption.value = context.context; 
                options.put(context.context,contextOption);
            }
        }
        return options.values();
    }

    public  List<Adm.option> getSupportedLanguages () {
        List<Adm.option> optionsList = new List<Adm.option>();
        Schema.DescribeFieldResult fieldResult = User.LanguageLocaleKey.getDescribe();
        List<String> svmxSupportedLanguage =  CONF_CustomSettingsManager.getInstance().getSupportedLanguages();
        boolean isDefaultupdated = false;
        String langCode  = [SELECT LanguageLocaleKey FROM Organization LIMIT 1].LanguageLocaleKey;
        for(Schema.PicklistEntry languageEntry: fieldResult.getPicklistValues()){
            if(languageEntry.isActive() 
                && svmxSupportedLanguage.contains (languageEntry.getValue())){
                Adm.option lang = new Adm.option();
                lang.label = languageEntry.getLabel();
                lang.value = languageEntry.getValue();
                lang.isDefault = UserInfo.getLanguage() == languageEntry.getValue();
                if (lang.isDefault) {
                  isDefaultupdated = lang.isDefault;
                }
                lang.selected = true;
                optionsList.add(lang);
            }
        }
        if (!isDefaultupdated && optionsList.size()>0) {
            for (Adm.option lang: optionsList) {
                if(lang.value == langCode){
                    isDefaultupdated =true;
                    lang.isDefault = true;
                }
            }
            if (!isDefaultupdated) {
                for (Adm.option lang: optionsList) {
                    if(lang.value == 'en_US'){
                        isDefaultupdated =true;
                        lang.isDefault = true;
                    }
                }
            }
        }

        
        if(optionsList.isEmpty()){
            Adm.option lang = new Adm.option();
            lang.label = 'English';
            lang.value = 'en_US';
            lang.isDefault = true;
            lang.selected = true;
            optionsList.add(lang);
        }
        return optionsList;
    }

    public boolean upsertTranslatedTagsByContextAndMasterText( final List<Adm.TranslationTag> translations ) {
        Boolean isSuccess = true;
        List<SVMXA360__CONF_TagTranslation__c> upsertTranslations = new List<SVMXA360__CONF_TagTranslation__c>();
        List<Adm.TranslationTag> updatedTranslations = new List<Adm.TranslationTag>();
        Map<String,List<String>> contextMap = new Map<String,List<string>>();
        for(Adm.TranslationTag tag: translations){
            List<String> masterTextList;
            if( contextMap.containsKey(tag.context)){
                masterTextList = contextMap.get(tag.context);
            } else {
                masterTextList = new List<String>();
            }
            masterTextList.add(tag.masterText);
            contextMap.put(tag.context,masterTextList);
        }
        if (!contextMap.isEmpty()) {
            String context = new List<String>(contextMap.keySet()).get(0);
            List<SVMXA360__CONF_ServicemaxTags__c> tagList = svmxDatabase.query([select id,SVMXA360__MasterText__c from SVMXA360__CONF_ServicemaxTags__c where SVMXA360__Context__c =: context and SVMXA360__MasterText__c in: contextMap.get(context)]);
            if (tagList.isEmpty()) {
                List<Adm.SvmxTranslations> scope = new List<Adm.SvmxTranslations>();
                for(Adm.TranslationTag tag: translations){
                    Adm.SvmxTranslations translation = new Adm.SvmxTranslations();
                    translation.context = context;
                    translation.masterText = tag.masterText;
                    Adm.SvmxLanguageValues langVal = new Adm.SvmxLanguageValues();
                    langVal.name = tag.language;
                    langVal.value = tag.translatedValue;
                    translation.languageValues = new List<Adm.SvmxLanguageValues>{langVal};
                    scope.add(translation);
                }
                this.saveTranslationData (scope);
            } else {
                for(SVMXA360__CONF_ServicemaxTags__c tag: tagList) {
                    Adm.TranslationTag newTag = new Adm.TranslationTag();
                    newTag.masterText = tag.SVMXA360__MasterText__c;
                    newTag.tagId = tag.id;
                    newTag.context = context;
                    for(Adm.TranslationTag translation: translations){ 
                        if(translation.masterText.equalsIgnoreCase(newTag.masterText) 
                            && translation.context.equalsIgnoreCase(context)){
                            newTag.language = translation.language;
                            newTag.translatedValue = translation.translatedValue;
                        } 
                    }
                    updatedTranslations.add(newTag);               
                }
            }
        }
        System.debug( LoggingLevel.INFO, 'upsertTranslatedTagsByContextAndMasterText() : Saving Translations' );
        return updatedTranslations.isEmpty()?true:this.upsertTranslatedTags(updatedTranslations);
    }

    public  boolean upsertTranslatedTags( final List<Adm.TranslationTag> translations ) {
        
        Boolean isSuccess = true;
        List<SVMXA360__CONF_TagTranslation__c> upsertTranslations = new List<SVMXA360__CONF_TagTranslation__c>();
        for(Adm.TranslationTag tag: translations){
            SVMXA360__CONF_TagTranslation__c translationTag = new SVMXA360__CONF_TagTranslation__c ();
            translationTag.name = String.escapeSingleQuotes(tag.language);
            translationTag.SVMXA360__Value__c = tag.translatedValue;
            translationTag.SVMXA360__CONF_ServicemaxTag__c = tag.tagId;
            translationTag.SVMXA360__LanguageUniqueId__c = tag.language+tag.tagId;
            upsertTranslations.add(translationTag);
        }
        svmxDatabase.upsertRecord(upsertTranslations,SVMXA360__CONF_TagTranslation__c.Fields.SVMXA360__LanguageUniqueId__c,true);
        System.debug( LoggingLevel.INFO, 'upsertTranslatedTags() : Saved Translations' );
        
        return isSuccess;
    }

    public List<TranslationContext> getAllTranslationContext() {
        List<TranslationContextMetadata> contextMetadatas = getContextMetadatas();
        Map<String,TranslationContext> contextMap = new Map<String,TranslationContext>();
        for (TranslationContextMetadata translationContext: contextMetadatas) { 
            TranslationContext context = null;
            if (contextMap.containsKey(translationContext.context)) {
                context = contextMap.get(translationContext.context);
            } else {
                context = new TranslationContext();
                context.fieldNames  = new List<string>();
            }
            context.context = translationContext.context;
            context.objectName = translationContext.objectName;
            context.fieldNames.add(translationContext.fieldName);
            contextMap.put(translationContext.context,context);
        }
        return contextMap.values();
    }

    public List<Adm.SvmxTranslations> getProcessedContentFromFile(String dataWrapperJson) {
        List<Adm.SvmxTranslations> seedWrapper = null;
        if(String.isNotBlank(dataWrapperJson)){
            seedWrapper = ((Adm.ServicemaxTag) JSON.deserialize(dataWrapperJson, Adm.ServicemaxTag.class)).translations;
        }
        return seedWrapper;
    }

    public List<SObject> getDataToBeTranslated(TranslationContext currentRecord) {
        if(currentRecord.objectName == null){
            return new List<SObject>();
        }
        String query = 'select Id';
        for (String fieldName: currentRecord.fieldNames) {
            query += ','+fieldName;
        }
        query += ' from '+ currentRecord.objectName;
        return SvmxDatabase.query(query);

    }


     private Adm.TranslationTag createTranslationTagRecord( 
        SVMXA360__CONF_ServicemaxTags__c tagRecord, String language, Map<String,String> translationMap ) {  
        Adm.TranslationTag tag = new Adm.TranslationTag();
        tag.tagId = tagRecord.Id ;
        tag.context = tagRecord.SVMXA360__Context__c ;
        tag.contextLabel = translationMap.get(tagRecord.SVMXA360__Context__c);
        tag.masterText = tagRecord.SVMXA360__MasterText__c ;
        tag.language = language ;
        if(tagRecord.SVMXA360__CONF_TagTranslations__r.size() > 0){
            tag.translatedValue = tagRecord.SVMXA360__CONF_TagTranslations__r[0].SVMXA360__Value__c;
        }else{
            tag.translatedValue = '';
        }
        return tag;
    }

    private Adm.SvmxTranslations populateSvmxTranslationRecord(SVMXA360__CONF_ServicemaxTags__c tagRecord) {
        
        Adm.SvmxTranslations tag = new Adm.SvmxTranslations ();
        tag.masterText = tagRecord.SVMXA360__MasterText__c;
        tag.context  = tagRecord.SVMXA360__context__c;
        tag.lastModifiedDate = tagRecord.LastModifiedDate;
        tag.lastModifiedBy = tagRecord.LastModifiedBy.Name;
        
        tag.languageValues = new List<Adm.SvmxLanguageValues> ();
        if(tagRecord.SVMXA360__CONF_TagTranslations__r.size() > 0){
            for(SObject taglang: tagRecord.SVMXA360__CONF_TagTranslations__r){
                Adm.SvmxLanguageValues lang = new Adm.SvmxLanguageValues();
                lang.name = (String)taglang.get('name');
                lang.value = (String)taglang.get('SVMXA360__Value__c');
                lang.lastModifiedDate = String.valueOf((Datetime)taglang.get('LastModifiedDate'));
		if (taglang.getSObject('LastModifiedBy') != null) {
                   lang.lastModifiedBy = (String) taglang.getSObject('LastModifiedBy').get('Name');
		}
                tag.languageValues.add(lang);
            }
        }
        return tag;
    }

    private List<Adm.TranslationTag> createTranslationTagRecord(
        SVMXA360__CONF_ServicemaxTags__c tagRecord){
            List<Adm.TranslationTag> tags = new List<Adm.TranslationTag> ();
        if(tagRecord.SVMXA360__CONF_TagTranslations__r.size() > 0){
            for(SObject taglang: tagRecord.SVMXA360__CONF_TagTranslations__r){
                Adm.TranslationTag tag = new Adm.TranslationTag();
                tag.language = (String)taglang.get('name');
                tag.translatedValue = (String)taglang.get('SVMXA360__Value__c');
                tags.add(tag);
            }
        }
        return tags;
    }

    private Map<String,String> getTranslationContextMap ( ){

        Map<String,String>  contextMap = new Map<String,String> ();
        List<TranslationContextMetadata> contextMetadatas = getContextMetadatas();
        for(TranslationContextMetadata context: contextMetadatas){
            contextMap.put(context.context,context.label);
        }
        return contextMap;
    }

    public Adm.ValidationResult validateTranslation( Adm.SvmxTranslations svmxTranslation, final List<Adm.ReferenceData> referenceDatas ) {
        return validateTranslations( new List<Adm.SvmxTranslations>{svmxTranslation}, referenceDatas).get(0);
    }
    
	public List<Adm.ValidationResult> validateTranslations( final List<Adm.SvmxTranslations> svmxTranslations, final List<Adm.ReferenceData> referenceDatas ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateTranslations() - enter; svmxTranslations= ' + svmxTranslations );
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        try {

            if( svmxTranslations == null || svmxTranslations.isEmpty() ) {
             
                System.debug( LoggingLevel.ERROR, 'validateTranslations() : Invalid request parameters. svmxTranslations= ' + svmxTranslations );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final Set<String> existingContextSet = new Set<String>();
            for (SVMXA360__CONF_ServicemaxTags__c servicemaxTags : (List<SVMXA360__CONF_ServicemaxTags__c>) SvmxDatabase.query( [SELECT Id,SVMXA360__MasterText__c,SVMXA360__Context__c FROM SVMXA360__CONF_ServicemaxTags__c] ) ) {
                existingContextSet.add( servicemaxTags.SVMXA360__Context__c + servicemaxTags.SVMXA360__MasterText__c );
            }
            
            for( Adm.ReferenceData referenceData : referenceDatas ) {
                if( referenceData.configDataList != null && !referenceData.configDataList.isEmpty() ) {
                    for( Adm.ConfigurationData configurationData : referenceData.configDataList ) {
                        existingContextSet.add(configurationData.tag);
                    }
                }
            }
            
            for( Adm.SvmxTranslations svmxTranslation : svmxTranslations ) {
                
                if( !existingContextSet.contains( svmxTranslation.context + svmxTranslation.masterText ) ) {
                    
                    final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.Translation );
                    validationResult.setError('Translation Tag does not exists : Context= ' + svmxTranslation.context + '; Master Text= ' + svmxTranslation.masterText );
                    validationResults.add(validationResult);
                }
            }
        }
        
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTranslations() : Failed to validate translation. Error= ' + e.getMessage() );
            throw e;
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTranslations() : Failed to validate translation. Error= ' + e.getMessage() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateTranslations() - exit' );
        }
        
        return validationResults;
    }
    
     public List<Adm.SvmxTranslations> saveTranslationData (List<Adm.SvmxTranslations> scope) {
        List<SVMXA360__CONF_ServicemaxTags__c> tagList = new List<SVMXA360__CONF_ServicemaxTags__c>();
        List<SVMXA360__CONF_TagTranslation__c> langList = new List<SVMXA360__CONF_TagTranslation__c>();
        for(Adm.SvmxTranslations tag: scope){
            SVMXA360__CONF_ServicemaxTags__c stag = new SVMXA360__CONF_ServicemaxTags__c();
            stag.SVMXA360__Context__c = String.escapeSingleQuotes(tag.context);
            //TODO : Revisit below wrt checkmarx scan 
            stag.SVMXA360__MasterText__c = tag.masterText;
            tagList.add(stag);
        }
        List<Database.SaveResult> result = null;
        result = Database.insert(tagList,false);
        Map<String,List<SVMXA360__CONF_TagTranslation__c>> tagMap = new Map<String,List<SVMXA360__CONF_TagTranslation__c>>();
        for (integer index= 0; index< result.size(); index++){
            
            List<Adm.SvmxLanguageValues> tagTranslationList = scope[index].languageValues;
            if (result[index].isSuccess()) {
                scope[index].translationId = result[index].getId();
                for (integer langIndex =0; langIndex < tagTranslationList.size(); langIndex++){
                    SVMXA360__CONF_TagTranslation__c tag = new SVMXA360__CONF_TagTranslation__c();
                    tag.SVMXA360__CONF_ServicemaxTag__c = String.escapeSingleQuotes(result[index].getId());
                    tag.Name = String.escapeSingleQuotes(tagTranslationList[langIndex].Name);
                    //TODO : Revisit below wrt checkmarx scan 
                    tag.SVMXA360__Value__c = tagTranslationList[langIndex].value;
                    tag.SVMXA360__LanguageUniqueId__c = String.escapeSingleQuotes(tag.Name+result[index].getId());
                    List<SVMXA360__CONF_TagTranslation__c> maplist = null;
                    if(tagMap.containsKey(result[index].getId())){
                        maplist=tagMap.get(result[index].getId());
                    }else{
                        maplist=new List<SVMXA360__CONF_TagTranslation__c>();
                    }
                    langList.add(tag);
                    maplist.add(tag);
                    tagMap.put(result[index].getId(),maplist);
                }
            } else{
                for(Database.Error err : result[index].getErrors()) {
                    if(err.getMessage().contains('Duplicate')){
                        String tagid = err.getMessage().substringAfter('Duplicate detected ');
                        if(String.isNotBlank(tagid)){
                            for (integer langIndex =0; langIndex < tagTranslationList.size(); langIndex++){
                                SVMXA360__CONF_TagTranslation__c tag = new SVMXA360__CONF_TagTranslation__c();
                                tag.SVMXA360__CONF_ServicemaxTag__c = String.escapeSingleQuotes(tagid);
                                tag.Name = String.escapeSingleQuotes(tagTranslationList[langIndex].Name);
                                //TODO : Revisit below wrt checkmarx scan 
                                tag.SVMXA360__Value__c = tagTranslationList[langIndex].value;
                                tag.SVMXA360__LanguageUniqueId__c = String.escapeSingleQuotes(tag.Name+tagid);
                                List<SVMXA360__CONF_TagTranslation__c> maplist = null;
                                if(tagMap.containsKey(tagid)){
                                    maplist=tagMap.get(tagid);
                                }else{
                                    maplist=new List<SVMXA360__CONF_TagTranslation__c>();
                                }
                                langList.add(tag);
                                maplist.add(tag);
                                tagMap.put(tagid,maplist);
                            }
                        } else{
                            scope[index].translationId = err.getMessage();
                        }
                    }else{
                        throw new DmlException(err.getMessage());
                    }
                }
            }
        }
            List<Database.UpsertResult> saveResult = Database.upsert(langList,SVMXA360__CONF_TagTranslation__c.Fields.SVMXA360__LanguageUniqueId__c);
            for(Adm.SvmxTranslations tag: scope){
                if(tag.translationId != null){
                    List<SVMXA360__CONF_TagTranslation__c> mapList = tagMap.get(tag.translationId);
                    if(mapList != null && !mapList.isEmpty()){
                        tag.languageValues = new List<Adm.SvmxLanguageValues>();
                        for(SVMXA360__CONF_TagTranslation__c lang: mapList) {
                            Adm.SvmxLanguageValues langVal = new Adm.SvmxLanguageValues();
                            langVal.translatedValueId = lang.id;
                            langVal.name = lang.Name;
                            langVal.value = lang.SVMXA360__Value__c;
                            tag.languageValues.add(langVal);
                        }
                    }
                }
            }
        return scope;
    }

    public void reconcileTranslationData (List<SObject> scope, TranslationContext currentRecord, Map<string,SVMXA360__CONF_ServicemaxTags__c> tagMap) {
        List<String> svmxTags = new List<String>();
        List<SVMXA360__CONF_ServicemaxTags__c> tagList = new List<SVMXA360__CONF_ServicemaxTags__c>();
        for(SObject tag: SvmxDatabase.query(
            [select SVMXA360__MasterText__c from SVMXA360__CONF_ServicemaxTags__c 
            where SVMXA360__Context__c =: currentRecord.context])){
            svmxTags.add((String)tag.get('SVMXA360__MasterText__c'));
        }
        for (SObject obj : scope){
            for(String fieldName : currentRecord.fieldNames){
                String currentTag = (String)obj.get(fieldName);
                if(!svmxTags.contains(currentTag) && String.isNotBlank((String)obj.get(fieldName))){
                    SVMXA360__CONF_ServicemaxTags__c tag = new SVMXA360__CONF_ServicemaxTags__c();
                    //TODO : Revisit below wrt checkmarx scan
                    tag.SVMXA360__MasterText__c = (String)obj.get(fieldName);
                    tag.SVMXA360__Context__c = String.escapeSingleQuotes(currentRecord.context);
                    String keyName = tag.SVMXA360__MasterText__c+tag.SVMXA360__Context__c;
                    if(!tagMap.containsKey(keyName)){
                        tagMap.put(keyName, tag);  
                        tagList.add(tag);
                    }
                }
            }
        }
        Database.insert(tagList,false);
    }
    
    public  void convertCSVToJSON (String content) {
        String[] contentList = content.split('\n');
        String[] header = contentList[0].split(',');
        Map<String,Adm.SvmxTranslations> tagMap = new  Map<String,Adm.SvmxTranslations> (); 
        for(integer index = 1; index< contentList.size(); index ++) {
            String[] fieldList = contentList[index].split(',');
            Adm.SvmxTranslations stag = null;
            if(tagMap.containsKey(fieldList[1]+fieldList[2])){
                stag = tagMap.get(fieldList[1]+fieldList[2]);
            } else{
                stag = new Adm.SvmxTranslations();
                stag.masterText = fieldList[1];
                stag.context = fieldList[2];
                stag.languageValues = new List<Adm.SvmxLanguageValues>();
            }
            for(integer colIndex = 3; colIndex < fieldList.size(); colIndex++){
                if(String.isNotBlank( header[colIndex])){
                    Adm.SvmxLanguageValues lang =  new Adm.SvmxLanguageValues();
                    lang.name = header[colIndex];
                    lang.value = fieldList[colIndex];
                    stag.languageValues.add(lang);
                    tagMap.put(fieldList[0]+fieldList[1],stag); 
                }else{
                    break;
                }
            }
        }
        Document d = new Document(); 
        d.Name = 'Asset360Translations.json'; 
        d.FolderId  =UserInfo.getUserId();
        d.Body = Blob.valueOf(JSON.serialize(tagMap.values())); 
        d.ContentType = 'text/json';
        d.Type = 'json';
        svmxDatabase.insertRecord( d);
    }

    public List<TranslationContextMetadata> getContextMetadatas () {
        List<TranslationContextMetadata> contexts = null;
        TranslationContext__mdt[] metadataList = TranslationContext__mdt.getAll().values();
        if(metadataList.isEmpty()){
           contexts = getDefaultContexts();
        } else {
            contexts = new List<TranslationContextMetadata>();
            for(TranslationContext__mdt metadata : metadataList){
                TranslationContextMetadata mdata = new TranslationContextMetadata();
                mdata.label =  metadata.Label;
                mdata.objectName =  metadata.SvmxA360__ObjectName__c;
                mdata.context =  metadata.SvmxA360__contextName__c;
                mdata.fieldName =  metadata.svmxA360__fieldName__c;
                contexts.add(mdata);
            }
        }
        return contexts;
    }

    public List<TranslationContextMetadata> getContextMetadataForObjectName (String objectName) {
        List<TranslationContextMetadata> translationContexts = getContextMetadatas();
        List<TranslationContextMetadata> translationContextsForObject = new List<TranslationContextMetadata>();
        for (TranslationContextMetadata context: translationContexts){
            if(context.objectName == objectName){
                translationContextsForObject.add(context);
            }
        }
        return translationContextsForObject;
    }

    public class TranslationContext {
        public List<String> fieldNames{get;set;}
        public String objectName{get;set;}
        public String context{get;set;}
    }

    public class TranslationContextMetadata {
        public String label{get;set;}
        public String objectName{get;set;}
        public String context{get;set;}
        public String fieldName{get;set;}
        private TranslationContextMetadata(){

        }
        public TranslationContextMetadata(
            String label,
            String objectName,
            String context,
            String fieldName){
                this.label = label;
                this.objectName = objectName;
                this.context = context;
                this.fieldName = fieldName;
            }
        
    }

    private  List<ADM_TranslationManager.TranslationContextMetadata> getDefaultContexts() {
        List<ADM_TranslationManager.TranslationContextMetadata>  metadata = new List<ADM_TranslationManager.TranslationContextMetadata> ();
        metadata.add(new TranslationContextMetadata('Transaction Related Section Title','SVMXA360__CONF_LayoutRelatedSection__c','transactionRelatedSectionTitle','Name'));
        metadata.add(new TranslationContextMetadata('Wizard Title','SVMXA360__CONF_ProcessWizard__c','wizardTitle','Name'));
        metadata.add(new TranslationContextMetadata('Transaction Custom Button Name','SVMXA360__CONF_LayoutElement__c','transactionButtonTitle','SVMXA360__Title__c'));
        metadata.add(new TranslationContextMetadata('Transaction Title','SVMXA360__CONF_Layout__c','transactionTitle','Name'));
        metadata.add(new TranslationContextMetadata('Transaction Section Title','SVMXA360__CONF_LayoutSection__c','transactionSectionTitle','Name'));
        metadata.add(new TranslationContextMetadata('Wizard Step Title','SVMXA360__CONF_ProcessWizardStep__c','wizardStepTitle','Name'));
        return metadata;
    }

    private ADM_TranslationManager(){

    }
}