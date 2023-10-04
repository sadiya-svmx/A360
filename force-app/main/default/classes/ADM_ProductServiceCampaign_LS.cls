/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete expressions.
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *           Soumyaranjan Pati       11 Jan 2021       Created.
 *****************************************************************************************************/
public class ADM_ProductServiceCampaign_LS {
    /**
     * This method retrieves all available PSC Configuration Templates 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all PSC Configuration Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse getAllConfigTemplates() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllConfigTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ProductServiceCampaignService().getConfigTemplates();
            System.debug( LoggingLevel.INFO, 'getAllConfigTemplates() : PSC Configuration Templates list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigTemplates() : Failed to retrieve PSC Configuration Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all available Object mapping details
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all object mapping details.
     */
	@AuraEnabled
    public static Common.ServiceResponse getObjectMappingDetails(final String sourceObject, final String targetObject) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - enter sourceObject '+sourceObject +' targetObject '+targetObject );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ProductServiceCampaignService().getObjectMappingDetails(sourceObject, targetObject);
            System.debug( LoggingLevel.INFO, 'getObjectMappingDetails() : PSC Configuration Templates list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve PSC Configuration Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This used to get the Config Template Information 
     * 
     * @return Returns instance of Common.ServiceResponse with response of the Config Template.
     */
	@AuraEnabled
    public static Common.ServiceResponse getConfigTemplateInfo( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.PSCConfigurations wrapperVar = (Adm.PSCConfigurations) JSON.deserializeStrict( requestJson, Adm.PSCConfigurations.class );
            serviceResponse = new ADM_ProductServiceCampaignService().getConfigTemplateInfo(wrapperVar);
            System.debug( LoggingLevel.INFO, 'getConfigTemplateInfo() : Get Template details' );
        }
        catch(System.JSONException e) {
            System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Failed to get the Template. JSONException' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Failed to get the Template. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method retrieves PSC Configuration Settings 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of Setting PSC Configuration Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse getSettingConfigTemplates() {
        
        System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_ProductServiceCampaignService().getSettingConfigTemplates();
            System.debug( LoggingLevel.INFO, 'getSettingConfigTemplates() : Retrieved PSC Settings list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSettingConfigTemplates() : Failed to retrieve PSC Settings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method deletes the Templates 
     * 
     * @return Returns instance of Common.ServiceResponse with response of delete Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse deleteConfigTemplate( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteConfigTemplate() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.PSCConfigurations expression = (Adm.PSCConfigurations) JSON.deserializeStrict( requestJson, Adm.PSCConfigurations.class );
            serviceResponse = new ADM_ProductServiceCampaignService().deleteConfigTemplate(expression);
            System.debug( LoggingLevel.INFO, 'deleteConfigTemplate() : deleted Templates details' );
        }
        catch(System.JSONException e) {
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete Templates. JSONException' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteConfigTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method for Update the Config Setting record
     * 
     * @return Returns instance of Common.ServiceResponse with response of Config Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse updateConfigTemplateSetting( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'updateConfigTemplateSetting() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.PSCConfigurations configVar = (Adm.PSCConfigurations) JSON.deserializeStrict( requestJson, Adm.PSCConfigurations.class );
            serviceResponse = new ADM_ProductServiceCampaignService().updateConfigSetting(configVar);
            System.debug( LoggingLevel.INFO, 'updateConfigTemplateSetting() : Updated details' );
        }
        catch(System.JSONException e) {
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update Templates Setting. JSONException' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update Templates Setting. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateConfigTemplateSetting() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    /**
     * This method for Save the Config Setting record
     * 
     * @return Returns instance of Common.ServiceResponse with response of  Templates.
     */
	@AuraEnabled
    public static Common.ServiceResponse saveConfigTemplates( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'saveConfigTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.PSCConfigurations configVar = (Adm.PSCConfigurations) JSON.deserializeStrict( requestJson, Adm.PSCConfigurations.class );
            serviceResponse = new ADM_ProductServiceCampaignService().saveConfigTemplates(configVar);
            System.debug( LoggingLevel.INFO, 'saveConfigTemplates() : Upsert details' );
        }
        catch(System.JSONException e) {
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Upsert Config Templates. JSONException' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Upser Config Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}