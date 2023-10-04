/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete process wizards.
 *
 * @author Ryan Follmer
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ryan Follmer            14 August 2020  Created.
 *****************************************************************************************************/
public with sharing class ADM_ProcessWizardLightningService {

    @AuraEnabled
    public static Common.ServiceResponse getProcessWizardDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetails() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Adm.ProcessWizard wizard = (Adm.ProcessWizard) JSON.deserializeStrict( requestJson, Adm.ProcessWizard.class );

            // Verify request parameters for required information.
            if( wizard == null || String.isBlank( wizard.id ) ) {
                System.debug( LoggingLevel.ERROR, 'getProcessWizardDetails() : Invalid arguments. wizard= ' + wizard);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }            

            serviceResponse.data = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizard.id);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetails() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetails() : Failed to retrieve Process Wizard details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetails() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getProcessWizardDetailsByObject( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetailsByObject() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Adm.ProcessWizard wizard = (Adm.ProcessWizard) JSON.deserializeStrict( requestJson, Adm.ProcessWizard.class );

            // Verify request parameters for required information.
            if( wizard == null || String.isBlank( wizard.objectAPIName ) ) {
                System.debug( LoggingLevel.ERROR, 'getProcessWizardDetailsByObject() : Invalid arguments. wizard= ' + wizard);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }            

            serviceResponse.data = ADM_ProcessWizardManager.getInstance().getProcessWizardDetailsByObject(wizard.objectAPIName);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetailsByObject() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardDetailsByObject() : Failed to retrieve Process Wizard details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardDetailsByObject() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled (cacheable=true)
    public static Common.ServiceResponse getActiveProcessWizardDetailsByObject( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getActiveProcessWizardDetailsByObject() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Adm.ProcessWizard wizard = (Adm.ProcessWizard) JSON.deserializeStrict( requestJson, Adm.ProcessWizard.class );

            // Verify request parameters for required information.
            if( wizard == null || String.isBlank( wizard.objectAPIName ) ) {
                System.debug( LoggingLevel.ERROR, 'getProcessWizardDetailsByObject() : Invalid arguments. wizard= ' + wizard);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }            

            serviceResponse.data = ADM_ProcessWizardManager.getInstance().getActiveProcessWizardDetailsByObject(wizard.objectAPIName);
        }
        catch( JSONException e ) {
            System.debug( LoggingLevel.ERROR, 'getActiveProcessWizardDetailsByObject() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getActiveProcessWizardDetailsByObject() : Failed to retrieve Process Wizard details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getActiveProcessWizardDetailsByObject() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getProcessWizardSummary() {
        
        System.debug( LoggingLevel.DEBUG, 'getProcessWizardSummary() - enter;' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = ADM_ProcessWizardManager.getInstance().getProcessWizardSummary();
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessWizardSummary() : Failed to retrieve Process Wizard Summary Info. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessWizardSummary() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }    

    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getProcessStepTargetsByType( final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByType() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            Adm.ProcessStepTargetRequest request = (Adm.ProcessStepTargetRequest) JSON.deserializeStrict( requestJson, Adm.ProcessStepTargetRequest.class );

            // Verify request parameters for required information.
            if( request == null || 
                String.isBlank( request.objectAPIName ) ||
                String.isBlank( request.stepTypeName ) ) {
                System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByType() : Invalid arguments. request= ' + request);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }   
            serviceResponse.data = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByType(request.stepTypeName, request.objectApiName);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByType() : Failed to retrieve ProcessStep Type Targets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByType() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getProcessStepTargetsByApiName( final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByApiName() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            Adm.ProcessStepTargetRequest request = (Adm.ProcessStepTargetRequest) JSON.deserializeStrict( requestJson, Adm.ProcessStepTargetRequest.class );

            // Verify request parameters for required information.
            if( request == null || 
                String.isBlank( request.targetAPIName ) ||
                String.isBlank( request.objectApiName ) ||
                String.isBlank( request.stepTypeName ) ) {
                System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByApiName() : Invalid arguments. request= ' + request);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }   
            serviceResponse.data = ADM_ProcessWizardManager.getInstance().getProcessStepTargetsByApiName(request.stepTypeName, request.targetApiName, request.objectApiName);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getProcessStepTargetsByApiName() : Failed to retrieve ProcessStep Type Targets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProcessStepTargetsByApiName() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse saveProcessWizards( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveProcessWizards() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.ProcessWizardSaveRequest request = (Adm.ProcessWizardSaveRequest) JSON.deserializeStrict( requestJson, Adm.ProcessWizardSaveRequest.class );
            
            if (request == null || request.objectAPINames == null || request.objectAPINames.size() == 0) {
                System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Invalid request parameters. requestJson= ' + requestJson );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            Adm.isRecentItemTransaction = true;
            List<Adm.ProcessWizard> wizards = request.wizards;
            List<String> objectAPINames = request.objectAPINames;

            serviceResponse.data = ADM_ProcessWizardManager.getInstance().saveProcessWizards(wizards, objectAPINames);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch(SvmxSystem.SvmxServiceException e) {
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Process Wizards. Error= ' + e.errors );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            serviceResponse.errors = e.errors;
        }        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveProcessWizards() : Failed to save Process Wizards. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveProcessWizards() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }    

    @AuraEnabled
    public static Common.ServiceResponse deleteProcessWizard( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteProcessWizard() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.ProcessWizard wizard = (Adm.ProcessWizard) JSON.deserializeStrict( requestJson, Adm.ProcessWizard.class );

            // Verify request parameters for required information.
            if( wizard == null || String.isBlank( wizard.id ) ) {
                System.debug( LoggingLevel.ERROR, 'deleteProcessWizard() : Invalid arguments. wizard= ' + wizard);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }          

            ADM_ProcessWizardManager.getInstance().deleteProcessWizard(wizard.id);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizard() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizard() : Failed to delete Process Wizard. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcessWizard() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteProcessWizardsByObjectNames( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardsByObjectNames() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            List<String> objectAPINames = (List<String>) JSON.deserializeStrict( requestJson, List<String>.class );

            // Verify request parameters for required information.
            if( objectAPINames == null || objectAPINames.size() == 0 ) {
                System.debug( LoggingLevel.ERROR, 'deleteProcessWizardsByObjectNames() : Invalid arguments. requestJson= ' + requestJson);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }          

            ADM_ProcessWizardManager.getInstance().deleteProcessWizardsByObjectNames(objectAPINames);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardsByObjectNames() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardsByObjectNames() : Failed to delete Process Wizard. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardsByObjectNames() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteProcessWizardStep( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardStep() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.ProcessStep wizardStep = (Adm.ProcessStep) JSON.deserializeStrict( requestJson, Adm.ProcessStep.class );

            // Verify request parameters for required information.
            if( wizardStep == null || String.isBlank( wizardStep.id ) ) {
                System.debug( LoggingLevel.ERROR, 'deleteProcessWizardStep() : Invalid arguments. wizardStep= ' + wizardStep);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }          

            ADM_ProcessWizardManager.getInstance().deleteProcessWizardStep(wizardStep.id);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardStep() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteProcessWizardStep() : Failed to delete Process Wizard Step. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteProcessWizardStep() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse invokeRecordAction( final String actionName, final String wizardStepId, final String recordId ) {
        System.debug( LoggingLevel.DEBUG, 'invokeRecordAction() - enter; recordAction='+ actionName+' wizardStepId= ' + wizardStepId +' recordId= '+recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            ADM_ProcessWizardManager.getInstance().invokeRecordAction(actionName, wizardStepId,recordId);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'invokeRecordAction() : Failed to invoke recordAction for Wizard Step. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeRecordAction() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

}