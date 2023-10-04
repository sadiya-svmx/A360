/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/create/update and delete 
 * Wizards. 
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
public with sharing class ADM_ProcessWizardService extends ADM_AbstractWizardService {

    public ADM_ProcessWizardService() {

    }

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_ProcessWizardService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method retrieves all active wizards with details from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all active wizard informations.
     * 
     * @see ADM_ProcessWizardServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     */
    override public Common.ServiceResponse getAllActiveProcessWizardDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllActiveProcessWizardDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign wizard informations to response data.
            serviceResponse.data = new ADM_ProcessWizardServiceImpl().getAllActiveProcessWizardDetails();
            System.debug( LoggingLevel.INFO, 'getAllActiveProcessWizardDetails() : Retrieved active wizards list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllActiveProcessWizardDetails() : Failed to retrieve Wizards. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllActiveProcessWizardDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to validate List of wizard informations into Salesforce Org.
     * 
     * @param wizardList List of Adm.ProcessWizard with wizard informations.
     * @return Returns instance of Common.ServiceResponse with validate wizard information in the data field.
     * 
     * @see ADM_ProcessWizardServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
     */
    override public Common.ServiceResponse validateProcessWizard( final Adm.WizardValidationRequest wizardValidationRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateProcessWizard() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ProcessWizardServiceImpl().validateProcessWizard( wizardValidationRequest );
            System.debug( LoggingLevel.INFO, 'validateProcessWizard() : Validated wizard successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateProcessWizard() : Failed to validate Wizards. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateProcessWizards() : Failed to validate Wizards. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateProcessWizards() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save List of wizard informations into Salesforce Org.
     * 
     * @param wizardList List of Adm.ProcessWizard with wizard informations.
     * @return Returns instance of Common.ServiceResponse with saved wizard information in the data field.
     * 
     * @see ADM_ProcessWizardServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
     */
    override public Common.ServiceResponse saveProcessWizards( final List<Adm.ProcessWizard> wizardList, final List<String> objectAPINames ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveProcessWizards() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ProcessWizardServiceImpl().saveProcessWizards( wizardList, objectAPINames );
            System.debug( LoggingLevel.INFO, 'saveProcessWizards() : Saved wizard successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Wizards. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Wizards. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessWizards() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}