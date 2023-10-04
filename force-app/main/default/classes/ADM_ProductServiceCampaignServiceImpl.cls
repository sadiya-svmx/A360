/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete PSC Configuration Templates.
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Soumyaranjan Pati      11th Jan 2021     Created.
 *****************************************************************************************************/
public with sharing class ADM_ProductServiceCampaignServiceImpl {
    
    private final ADM_PSCConfigurationManager objectVar = ADM_PSCConfigurationManager.getInstance();

    private final COMM_RecordTypeManager recordTypeClassVar = COMM_RecordTypeManager.getInstance();
    
    /**
     * This method retrieves all PSC Configuration Templates and populate 
     * informations it to the PSC Configuration wrapper.
     */
    public List<Adm.PSCConfigurations> getConfigTemplates() {
        
        System.debug( LoggingLevel.FINEST, 'getConfigTemplates() - enter');
        
        List<Adm.PSCConfigurations> configTemplateList = new List<Adm.PSCConfigurations>();
        
        try {
            // Config Template informations from PSC Configuration manager.
            configTemplateList = objectVar.getConfigTemplates();
            System.debug( LoggingLevel.INFO, 'getConfigTemplates() : Retrieved all PSC Configurations. configTemplateList.size()= ' + configTemplateList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getConfigTemplates() : Failed to PSC Config Templates. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getConfigTemplates() - exit; configTemplateList.size()= ' + configTemplateList.size() );
        }
        
        return configTemplateList;
    }

    /**
     * This method is used to retrieve requested PSC Templates information.
     */
    public List<Adm.PSCConfigurations> getConfigTemplateInfo( final Adm.PSCConfigurations configTemplate ) {
        
        System.debug( LoggingLevel.FINEST, 'getConfigTemplateInfo() - enter; configTemplate= ' + configTemplate );
        List<Adm.PSCConfigurations> configTemplateList = new List<Adm.PSCConfigurations>();
        
        try {
            
            // Verify for valid PSC Config Template id to perform retrieve operation.
            if( configTemplate == null || configTemplate.id == null ) {
                
                System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Invalid request parameters. configTemplate= ' + configTemplate );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            configTemplateList = objectVar.getConfigTemplateInfo( configTemplate.id );
            System.debug( LoggingLevel.INFO, 'getConfigTemplateInfo() : retrieved configTemplate= ' + configTemplate.id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Failed to retrieve Config Template. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getConfigTemplateInfo() : Failed to retrieve config Template. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getConfigTemplateInfo() - exit; configTemplate= ' + configTemplate );
        }
        return configTemplateList;
    }

     /**
     * This method is used to retrieve requested object mapping.
     */
    public List<Adm.KeyValueInfo> getObjectMappingDetails( final String sourceObject, final String targetObject ) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectMappingDetails() - enter; sourceObject= ' + sourceObject +' targetObject '+targetObject);
        List<Adm.KeyValueInfo> returnVal = new List<Adm.KeyValueInfo>();
        
        try {
            
            // Verify for valid PSC Config Template id to perform retrieve operation.
            if( String.isBlank(sourceObject) || String.isBlank(targetObject) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Invalid request parameters. sourceObject= ' + sourceObject +' targetObject '+targetObject);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            returnVal = objectVar.getObjectMappingDetails( sourceObject, targetObject );
            System.debug( LoggingLevel.INFO, 'getObjectMappingDetails() : retrieved object mapping sourceObject= ' + sourceObject +' targetObject '+targetObject );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve object mapping. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectMappingDetails() - exit; sourceObject= ' + sourceObject +' targetObject '+targetObject );
        }
        return returnVal;
    }

    /**
     * This method retrieves PSC Configuration Setting and populate 
     * informations it to the PSC Configuration wrapper.
     */
    public List<Adm.PSCConfigurations> getSettingConfigTemplates() {
        
        System.debug( LoggingLevel.FINEST, 'getSettingConfigTemplates() - enter');
        
        List<Adm.PSCConfigurations> configTemplateList = new List<Adm.PSCConfigurations>();
        
        try {
            // Config Template informations from PSC Configuration manager.
            configTemplateList = objectVar.getSettingConfigTemplates();
            System.debug( LoggingLevel.INFO, 'getSettingConfigTemplates() : Retrieved PSC Configurations Setting. configTemplateList.size()= ' + configTemplateList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSettingConfigTemplates() : Failed to PSC Config Setting. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getSettingConfigTemplates() - exit; configTemplateList.size()= ' + configTemplateList.size() );
        }
        
        return configTemplateList;
    }
    
    
    /**
     * This method is used to delete requested PSC Templates information.
     */
    public void deleteConfigTemplate( final Adm.PSCConfigurations configTemplate ) {
        
        System.debug( LoggingLevel.FINEST, 'deleteConfigTemplate() - enter; configTemplate= ' + configTemplate );
        
        try {
            
            // Verify for valid PSC Config Template id to perform delete operation.
            if( configTemplate == null || configTemplate.id == null ) {
                
                System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Invalid request parameters. configTemplate= ' + configTemplate );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            objectVar.deleteConfigTemplate( configTemplate.id );
            System.debug( LoggingLevel.INFO, 'deleteConfigTemplate() : deleted configTemplate= ' + configTemplate.id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete Config Template. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteConfigTemplate() : Failed to delete config Template. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deleteConfigTemplate() - exit; configTemplate= ' + configTemplate );
        }
    }
    /**
     * This method is used to Update requested PSC Templates Setting.
     */
    public void updateConfigTemplateSetting( final Adm.PSCConfigurations configTemplate ) {
        
        System.debug( LoggingLevel.FINEST, 'updateConfigTemplateSetting() - enter; configTemplate= ' + configTemplate );
        
        try {
            objectVar.updateConfigTemplateSetting(configTemplate);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update Config Template Setting. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateConfigTemplateSetting() : Failed to Update config Template Setting. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'updateConfigTemplateSetting() - exit; configTemplate= ' + configTemplate );
        }
    }
    /**
     * This method is used to Update requested PSC Templates Setting.
     */
    public String saveConfigTemplates( final Adm.PSCConfigurations configTemplate ) {
        
        System.debug( LoggingLevel.FINEST, 'saveConfigTemplates() - enter; configTemplate= ' + configTemplate );
        try {
           return objectVar.saveConfigTemplates(configTemplate); 
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Save Config Template . Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveConfigTemplates() : Failed to Save config Template . Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveConfigTemplates() - exit; configTemplate= ' + configTemplate );
        }
    }
    
    /**
     * This method is used to Update requested PSC Templates Setting.
     */
    public Adm.ValidationResult validateConfigTemplate( final Adm.PscValidationRequest pscValidationRequest ) {
        
        System.debug( LoggingLevel.FINEST, 'validateConfigTemplate() - enter; PscValidationRequest= ' + pscValidationRequest );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
           validationResult = objectVar.validateConfigTemplate(pscValidationRequest.pscConfiguration, pscValidationRequest.referenceDatas); 
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateConfigTemplate() : Failed to Validate Config Template . Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateConfigTemplate() : Failed to Validate config Template . Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateConfigTemplate() - exit; validationResult= ' + validationResult );
        }
        return validationResult;
    }
}