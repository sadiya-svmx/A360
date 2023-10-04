/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for wizard service implementation.
 * Also provides implementation for invokeMethod which maps to the requested wizard service implementation. 
 *
 * @author Sathish Kumar DB
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sathish Kumar DB        01 Feb 2021     Created.
 *****************************************************************************************************/
public abstract class ADM_AbstractWizardService extends COMM_SvmxRestBase {

    public ADM_AbstractWizardService() {

    }

    protected ADM_AbstractWizardService(RestRequest req, RestResponse res) {
        super(req, res, 'wizard');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getAllActiveProcessWizardDetails' {
                    response = getAllActiveProcessWizardDetails();
                } 
                when 'validateProcessWizard' {  
                    final Adm.WizardValidationRequest wizardValidationRequest = (Adm.WizardValidationRequest) deserializeRequestTo( Adm.WizardValidationRequest.class);                
                    response = validateProcessWizard( wizardValidationRequest );
                }
                when 'saveProcessWizards' {  
                    Adm.WizardRequest wizardRequest = (Adm.WizardRequest) deserializeRequestTo( Adm.WizardRequest.class);                
                    response = saveProcessWizards( wizardRequest.wizardList, wizardRequest.objectApiNameList );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }

    /**
     * This method is used to retrieve all active wizards with details from the Org.
     * 
     * @return Returns list of all active wizards.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/wizard/v1/getAllActiveProcessWizardDetails/
     */
    public abstract Common.ServiceResponse getAllActiveProcessWizardDetails();

    /**
     * This method is used to save the list of wizards in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/wizard/v1/saveProcessWizards/
     */
    public abstract Common.ServiceResponse saveProcessWizards( final List<Adm.ProcessWizard> wizardList, final List<String> objectAPINames );
    
    /**
     * This method is used to validate the list of wizards in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/wizard/v1/validateProcessWizard/
     */
    public abstract Common.ServiceResponse validateProcessWizard( final Adm.WizardValidationRequest wizardValidationRequest );
}