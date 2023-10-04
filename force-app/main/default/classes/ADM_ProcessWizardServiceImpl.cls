/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete wizards.
 *
 * @author Sathish Kumar DB
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sathish Kumar DB       01 Feb 2021     Created.
 *****************************************************************************************************/
public with sharing class ADM_ProcessWizardServiceImpl {
    
    private final ADM_ProcessWizardManager wizardManager = ADM_ProcessWizardManager.getInstance();

    /**
     * This method retrieves all wizard with details configured and populate 
     * informations it to the wizard wrapper.
     */
    public List<Adm.ProcessWizard> getAllActiveProcessWizardDetails() {
        
        System.debug( LoggingLevel.FINEST, 'getAllActiveProcessWizardDetails() - enter');
        
        List<Adm.ProcessWizard> wizardList = new List<Adm.ProcessWizard>();
        
        try {
            // Retrieve wizard information from object mapping manager.
            wizardList = wizardManager.getAllActiveProcessWizardDetails();
            System.debug( LoggingLevel.INFO, 'getAllActiveProcessWizardDetails() : Retrieved all Object Mapping informations. wizardList.size()= ' + wizardList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllActiveProcessWizardDetails() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllActiveProcessWizardDetails() - exit; wizardList.size()= ' + wizardList.size() );
        }
        
        return wizardList;
    }

    /**
     * This method is used to validate requested wizard list.  
     */
    public Adm.ValidationResult validateProcessWizard( final Adm.WizardValidationRequest wizardValidationRequest ) {
        
        System.debug( LoggingLevel.FINEST, 'validateProcessWizard() - enter; wizardValidationRequest= ' + wizardValidationRequest );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            
            // Verify request for required parameter. Throw SvmxSystem.SvmxNestedException in case of any missing parameters.
            if( wizardValidationRequest == null ||  wizardValidationRequest.processWizard == null ) {
             
                System.debug( LoggingLevel.ERROR, 'validateProcessWizard() : Invalid request parameters. processWizard= ' + wizardValidationRequest );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Perform save for requested Wizards.
            validationResult = wizardManager.validateProcessWizard( wizardValidationRequest.processWizard, wizardValidationRequest.referenceDatas );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateProcessWizard() : Failed to validate Wizard. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateProcessWizard() : Failed to validate Wizard. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateProcessWizard() - exit; validationResult= ' + validationResult );
        }
        
        return validationResult;
    }
    
    /**
     * This method is used to save requested wizard list. If the id field is null then, 
     * a new wizard record will be created, otherwise, existing wizard record will be updated.  
     */
    public List<Adm.ProcessWizard> saveProcessWizards( final List<Adm.ProcessWizard> wizardList, final List<String> objectAPINames ) {
        
        System.debug( LoggingLevel.FINEST, 'saveProcessWizards() - enter; wizardList= ' + wizardList );
        
        List<Adm.ProcessWizard> wizardLists = wizardList;
        
        try {
            
            // Verify request for required parameter. Throw SvmxSystem.SvmxNestedException in case of any missing parameters.
            if( wizardList == null || wizardList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Invalid request parameters. wizardList= ' + wizardList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            if( objectAPINames == null || objectAPINames.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Invalid request parameters. objectAPINames= ' + objectAPINames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Perform save for requested Wizards.
            wizardLists = wizardManager.saveProcessWizards( wizardList, objectAPINames );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Wizard. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Wizard. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveProcessWizards() - exit; wizardLists= ' + wizardLists );
        }
        
        return wizardLists;
    }
}