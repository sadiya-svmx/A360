/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements service to retrieve/create/update 
 * Translations . 
 *
 * @author Sathya Pachaiappan
 * @version 1.0
 * @since 2021
 */

public with sharing class ADM_ApplicationConfigServiceImpl {
    
    /**
     * Instance variable to hold translation Manager.
     */
    private final ADM_TranslationManager translationManager = ADM_TranslationManager.getInstance();

    public List<Adm.SvmxTranslations> getAllConfigTranslations () {
        System.debug( LoggingLevel.DEBUG, 'getAllConfigTranslations() - enter' );
        
        List<Adm.SvmxTranslations> translationsList = new List<Adm.SvmxTranslations>();
        
        try {
            translationsList = translationManager.getAllConfigTranslations();
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigTranslations() : Failed to retrieve config translations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigTranslations() - exit; translationsList.size()= ' + translationsList.size() );
        }
        
        return translationsList;
    }

    /**
     * This method is used to save config translations.
     * 
     * @param confTranslations List of SVMX config translations to be saved.
     * 
     * 
     */
    public List<Adm.SvmxTranslations> saveConfigTranslations( final List<Adm.SvmxTranslations> confTranslations ) {
        System.debug( LoggingLevel.DEBUG, 'saveConfigTranslations() - enter' );
        
        List<Adm.SvmxTranslations> translationsList = new List<Adm.SvmxTranslations>();
        
        try {
            translationsList = translationManager.saveTranslationData(confTranslations);
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTranslations() : Failed to retrieve config translations. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigTranslations() - exit; translationsList.size()= ' + translationsList.size() );
        }
        return translationsList;
    }
    
    public List<Adm.ValidationResult> validateTranslations( final Adm.TranslationValidationRequest translationValidationRequest ) {
        
        System.debug( LoggingLevel.FINEST, 'validateTranslation() - enter; translationValidationRequest= ' + translationValidationRequest );
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {
            
            // Verify request for required parameter. Throw SvmxSystem.SvmxNestedException in case of any missing parameters.
            if( translationValidationRequest == null ||  translationValidationRequest.svmxTranslations == null ) {
             
                System.debug( LoggingLevel.ERROR, 'validateTranslation() : Invalid request parameters. translationValidationRequest= ' + translationValidationRequest );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Perform validate for requested Translations.
            validationResults = translationManager.validateTranslations( translationValidationRequest.svmxTranslations, translationValidationRequest.referenceDatas );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTranslation() : Failed to validate Translations. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTranslation() : Failed to validate Translations. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateTranslation() - exit; validationResult= ' + validationResults );
        }
        
        return validationResults;
    }
}