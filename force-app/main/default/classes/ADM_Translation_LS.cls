public class ADM_Translation_LS {

    @AuraEnabled(cacheable=true)
    public static List<Adm.TranslationTag> getTranslations(String language) {
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        if(String.isEmpty(language)) {
            System.debug( LoggingLevel.ERROR, 'getTranslations() : Invalid request parameters. language= ' + language );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }
        return ADM_TranslationManager.getInstance().getTranslations(language, 'all');
    }

    @AuraEnabled
    public static List<Adm.TranslationTag> getTagDetails(String translationTagId ){
        if(String.isEmpty(translationTagId)) {
            System.debug( LoggingLevel.ERROR, 'getTagDetails() : Invalid request parameters. language= ' + translationTagId );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }
       
        return ADM_TranslationManager.getInstance().getTagDetails(translationTagId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Adm.option> getTranslationContexts () {
        return ADM_TranslationManager.getInstance().getTranslationContexts();
    }

    @AuraEnabled (cacheable=true)
    public static List<Adm.option> getSupportedLanguages () {
        return ADM_TranslationManager.getInstance().getSupportedLanguages();
    }

    @AuraEnabled
    public static Common.ServiceResponse upsertTranslatedTags( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'upsertTranslatedTags() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final List<Adm.TranslationTag> translations = (List<Adm.TranslationTag>) JSON.deserializeStrict( requestJson, List<Adm.TranslationTag>.class );
            serviceResponse.success = ADM_TranslationManager.getInstance().upsertTranslatedTags(translations);            
            System.debug( LoggingLevel.INFO, 'upsertTranslatedTags() : Saved Translations' );
           
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertTranslatedTags() : Failed to save Translations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertTranslatedTags() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'upsertTranslatedTags() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse upsertTranslatedTagsByContextAndMasterText( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'upsertTranslatedTagsByContextAndMasterText() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            final List<Adm.TranslationTag> translations = (List<Adm.TranslationTag>) JSON.deserializeStrict( requestJson, List<Adm.TranslationTag>.class );
            serviceResponse.success = ADM_TranslationManager.getInstance().upsertTranslatedTagsByContextAndMasterText(translations);            
            System.debug( LoggingLevel.INFO, 'upsertTranslatedTagsByContextAndMasterText() : Saved Translations' );
           
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertTranslatedTagsByContextAndMasterText() : Failed to save Translations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertTranslatedTagsByContextAndMasterText() : Failed to retrieve records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'upsertTranslatedTagsByContextAndMasterText() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}