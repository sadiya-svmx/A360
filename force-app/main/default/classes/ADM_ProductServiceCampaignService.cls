/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to retrieve/save/delete operations 
 * on expressions.
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Soumyaranjan Pati      11th Jan 2021     Created.
 *****************************************************************************************************/
public class ADM_ProductServiceCampaignService extends ADM_AbstractPSCConfigurationService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_ProductServiceCampaignService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_ProductServiceCampaignService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method retrieves all available Configuration Templates 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all Configuration Templates  information.
     * @see ADM_ProductServiceCampaignServiceImpl
     */
    override public Common.ServiceResponse getConfigTemplates() {
        
        System.debug( LoggingLevel.DEBUG, 'getConfigTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign Configuration Templates  informations to response data.
            serviceResponse.data = new ADM_ProductServiceCampaignServiceImpl().getConfigTemplates();
            System.debug( LoggingLevel.INFO, 'getConfigTemplates() : Retrieved Config Templates list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getConfigTemplates() : Failed to Config Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to Get Configuration Template  detail for given Configuration Templates .
     * 
     * @param Configuration Templates  Instance of Adm.PSCConfigurations for which 
     *             Configuration Templates  will be retrieve.
     * @return Returns instance of Common.ServiceResponse with of Setting Configuration information.
     * @see ADM_ProductServiceCampaignServiceImpl
     * 
   * @example getConfigTemplateInfo(PSCConfigurations Information);
     */
    
    override public Common.ServiceResponse getConfigTemplateInfo( final Adm.PSCConfigurations templateRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ProductServiceCampaignServiceImpl().getConfigTemplateInfo( templateRecord );
            System.debug( LoggingLevel.INFO, 'getConfigTemplateInfo() : Fetched PSC Configuration Template successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Failed to retrieve PSC Configuration Template. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getConfigTemplateInfo() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to Get object mapping  detail for given source and target object .
     * 
     * @param source object name and target object name.
     * @return Returns instance of Common.ServiceResponse with of Object mapping informations.
     * @see ADM_ProductServiceCampaignServiceImpl
     * 
   * @example getObjectMappingDetails(final String sourceObject, final String targetObject);
     */
    
    override public Common.ServiceResponse getObjectMappingDetails( final String sourceObject, final String targetObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ProductServiceCampaignServiceImpl().getObjectMappingDetails( sourceObject, targetObject );
            System.debug( LoggingLevel.INFO, 'getObjectMappingDetails() : Fetched Object mapping successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve object mapping. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves available Setting Configuration Templates 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with of Setting Configuration information.
     * @see ADM_ProductServiceCampaignServiceImpl
     */
    override public Common.ServiceResponse getSettingConfigTemplates() {
        
        System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign Configuration Setting informations to response data.
            serviceResponse.data = new ADM_ProductServiceCampaignServiceImpl().getSettingConfigTemplates();
            System.debug( LoggingLevel.INFO, 'getSettingConfigTemplates() : Retrieved Config Setting' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSettingConfigTemplates() : Failed to retrive PSC Config Setting. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSettingConfigTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to validate Configuration Templates detail for given Configuration Templates.
     */
    override public Common.ServiceResponse validateConfigTemplate( final Adm.PscValidationRequest pscValidationRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateConfigTemplate() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ProductServiceCampaignServiceImpl().validateConfigTemplate( pscValidationRequest );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateConfigTemplate() : Failed to validate PSC Configurations Setting. Error' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateConfigTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to Upsert Configuration Templates detail for given Configuration Templates .
     * 
     * @param Configuration Templates  Instance of Adm.PSCConfigurations for which 
     *             Configuration Templates  will be Saved.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_ProductServiceCampaignServiceImpl
     * 
   * @example saveConfigTemplates(PSCConfigurations Information);
     */
    override public Common.ServiceResponse saveConfigTemplates( final Adm.PSCConfigurations objectMapping ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveConfigTemplates() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ProductServiceCampaignServiceImpl().saveConfigTemplates( objectMapping );
            System.debug( LoggingLevel.INFO, 'saveConfigTemplates() : Saved PSC Configuration Template successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Upsert PSC Configurations Setting. Error' + e.getStackTraceString() );
            serviceResponse.success = false;
            if ( e.getMessage().containsIgnoreCase('duplicate value found: SVMXA360__DeveloperName__c')) {
                String errorRecordId = e.getMessage().substringAfter('record with id: ');
                serviceResponse.message = System.Label.Error_Duplicate_Developer_Name +' '+ errorRecordId;
            } else {
                serviceResponse.message = e.getMessage();
            }
            
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveConfigTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to delete Configuration Templates  detail for given Configuration Templates .
     * 
     * @param Configuration Templates  Instance of Adm.PSCConfigurations for which 
     *             Configuration Templates  will be deleted.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_ProductServiceCampaignServiceImpl
     * 
   * @example deleteConfigTemplate(PSCConfigurations Information);
     */
    
    override public Common.ServiceResponse deleteConfigTemplate( final Adm.PSCConfigurations templates ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteConfigTemplate() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_ProductServiceCampaignServiceImpl().deleteConfigTemplate( templates );
            System.debug( LoggingLevel.INFO, 'deleteConfigTemplate() : Deleted PSCConfigurations successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete PSCConfigurations. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteConfigTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to Update Configuration Templates Setting detail for given Configuration Templates .
     * 
     * @param Configuration Templates  Instance of Adm.PSCConfigurations for which 
     *             Configuration Templates  will be deleted.
     * @return Returns   instance of Common.ServiceResponse with success as true and failure as false
     * @see ADM_ProductServiceCampaignServiceImpl
     * 
   * @example updateConfigSetting(PSCConfigurations Information);
     */
    
    override public Common.ServiceResponse updateConfigSetting( final Adm.PSCConfigurations templates ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateConfigTemplateSetting() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_ProductServiceCampaignServiceImpl().updateConfigTemplateSetting( templates );
            System.debug( LoggingLevel.INFO, 'updateConfigTemplateSetting() : Updated PSC Configuration Setting successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update PSC Configurations Setting. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateConfigTemplateSetting() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}