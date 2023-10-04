/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for PSC Config service implementation.
 * Also provides implementation for invokeMethod which maps to the requested PSC implementation. 
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *             Soumyaranjan Pati       11 Jan 2021     Created.
 *****************************************************************************************************/
public abstract class ADM_AbstractPSCConfigurationService extends COMM_SvmxRestBase {
    
    public ADM_AbstractPSCConfigurationService(){
    }
    
    protected ADM_AbstractPSCConfigurationService(RestRequest req, RestResponse res) {
        super(req, res, 'psc');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getConfigTemplates' {
                    response = getConfigTemplates();
                }
                when 'getSettingConfigTemplates' {
                    response = getSettingConfigTemplates();
                }
                when 'getObjectMappingDetails' {
                    response = getObjectMappingDetails( serviceName, methodName);
                }
                when 'validateConfigTemplate' {                
                    response = validateConfigTemplate( (Adm.PscValidationRequest) deserializeRequestTo( Adm.PscValidationRequest.class ) );
                }
                when 'saveConfigTemplates' {                
                    response = saveConfigTemplates( (Adm.PSCConfigurations) deserializeRequestTo( Adm.PSCConfigurations.class ) );
                }
                when 'updateConfigSetting' {                
                    response = updateConfigSetting( (Adm.PSCConfigurations) deserializeRequestTo( Adm.PSCConfigurations.class ) );
                }
                when 'getConfigTemplateInfo' {                
                    response = getConfigTemplateInfo( (Adm.PSCConfigurations) deserializeRequestTo( Adm.PSCConfigurations.class ) );
                }
                when 'deleteConfigTemplate' {  
                    Adm.PSCConfigurations objectMapping = new Adm.PSCConfigurations();
                    objectMapping.id = recordId;              
                    response = deleteConfigTemplate( objectMapping );
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
     * This method is used to retrieve all PSC Configurations from the Org.
     * 
     * @return Returns list of all PSC configurations.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/psc/v1/getConfigTemplates/
     */
    public abstract Common.ServiceResponse getConfigTemplates();

    /**
     * This method is used to retrieve PSC Configurations Setting from the Org.
     * 
     * @return Returns list of PSC Setting.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/psc/v1/getSettingConfigTemplates/
     */
    public abstract Common.ServiceResponse getSettingConfigTemplates();

    /**
     * This method is used to validate the PSC Configurations in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/psc/v1/validateConfigTemplate/
     */
    public abstract Common.ServiceResponse validateConfigTemplate( final Adm.PscValidationRequest pscValidationRequest );
    
    /**
     * This method is used to save the PSC Configurations in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/psc/v1/saveConfigTemplates/
     */
    public abstract Common.ServiceResponse saveConfigTemplates( final Adm.PSCConfigurations objectRecord );
   
    /**
     * This method is used to fetch the Object mapping in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/psc/v1/getObjectMappingDetails/
     */
    public abstract Common.ServiceResponse getObjectMappingDetails( final String sourceObject, final String targetObject );

    /**
     * This method is used to Update the PSC Configurations Setting in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/psc/v1/updateConfigSetting/
     */
    public abstract Common.ServiceResponse updateConfigSetting( final Adm.PSCConfigurations objectRecord );

    /**
     * This method is used to Update the PSC Configurations Setting in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/psc/v1/getConfigTemplateInfo/
     */
    public abstract Common.ServiceResponse getConfigTemplateInfo( final Adm.PSCConfigurations objectRecord );

    /**
     * This method is used to deletes the PSC Configurations in the Org for the given request.
     * 
     * 
     * @example DELETE /services/apexrest/SVMXA360/admin/psc/v1/deleteConfigTemplate/
     */
    public abstract Common.ServiceResponse deleteConfigTemplate( final Adm.PSCConfigurations objectRecord );
}