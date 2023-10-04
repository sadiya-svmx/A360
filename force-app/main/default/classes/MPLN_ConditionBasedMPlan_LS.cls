/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates aura enabled methods for creation and managing Maintenance plan using 
 * custom LWC pages.
 * 
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                23 May 2023     Created.
 *****************************************************************************************************/

 public with sharing class MPLN_ConditionBasedMPlan_LS {
    
    @AuraEnabled
    public static Common.ServiceResponse getMatchingAssetsFromTemplate ( final String requestJson ) {        
                                                                            
       	System.debug( LoggingLevel.DEBUG, 'getMatchingAssetsFromTemplate() - enter; requestJson= ' + requestJson );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            final Mpln.MaintenanceAssetRequest maintenanceAssetRequest = (Mpln.MaintenanceAssetRequest) JSON.deserializeStrict( requestJson, Mpln.MaintenanceAssetRequest.class );

        	serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getMatchingAssetsFromTemplate(maintenanceAssetRequest);
		}
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getMatchingAssetsFromTemplate() : Failed to retrieve Mplan Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getMatchingAssetsFromTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    	
    }
        
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getRecordTypeDetails(final String objectAPIName){
        System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - enter; requestJson= ' + objectAPIName );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {

            COMM_MetadataManager commMetadataManager = COMM_MetadataManager.getInstance();
            serviceResponse.data = commMetadataManager.getRecordTypeDetails(objectAPIName);    
        } catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getRecordTypeDetails() : Failed to recordtype details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;
    }
 
    @AuraEnabled
    public static Common.ServiceResponse getWorkRulesFromMaintenanceTemplate( final String requestJson ) {
        System.debug( LoggingLevel.DEBUG, 'getWorkRulesFromMaintenanceTemplate() - enter; requestJson= ' + requestJson );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            final Mpln.MaintenanceWorkRuleRequest maintenanceWorkRuleRequest = (Mpln.MaintenanceWorkRuleRequest) JSON.deserialize( requestJson, Mpln.MaintenanceWorkRuleRequest.class );

        	serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getWorkRulesFromMaintenanceTemplate(maintenanceWorkRuleRequest);
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getWorkRulesFromMaintenanceTemplate() : Failed to retrieve Mplan Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWorkRulesFromMaintenanceTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getWorkRulesFromTemplate( final String requestJson ) {
    
        System.debug( LoggingLevel.DEBUG, 'getWorkRulesFromTemplate() - enter; requestJson= ' + requestJson );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            final Mpln.MaintenanceWorkRuleRequest maintenanceWorkRuleRequest = (Mpln.MaintenanceWorkRuleRequest) JSON.deserializeStrict( requestJson, Mpln.MaintenanceWorkRuleRequest.class );

        	serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getWorkRulesFromTemplate(maintenanceWorkRuleRequest);
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getWorkRulesFromTemplate() : Failed to retrieve Mplan Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWorkRulesFromTemplate() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getWorkRulesFromPlan( final List<String> maintenanceAssetIds ) {
    
        System.debug( LoggingLevel.DEBUG, 'getWorkRulesFromPlan() - enter; maintenanceAssetIds= ' + maintenanceAssetIds );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();   
        
        
        try {
            serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getWorkRulesFromPlan(maintenanceAssetIds);
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getWorkRulesFromPlan() : Failed to retrieve Mplan Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWorkRulesFromPlan() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getAttributeTemplates() {
       
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {

        	serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getAttributeTemplates();
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAttributeTemplates() : Failed to retrieve Attribute Templates. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAttributeTemplates() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getAttributeCategories(String requestJson) {
        System.debug( LoggingLevel.DEBUG, 'getAttributeCategories() - enter; requestJson= ' + requestJson );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            final Mpln.MplnTemplateRecord maintenanceAttributeTemplateRequest = (Mpln.MplnTemplateRecord) JSON.deserializeStrict( requestJson, Mpln.MplnTemplateRecord.class );

        	serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getAttributeCategories(maintenanceAttributeTemplateRequest);
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAttributeCategories() : Failed to retrieve AttributeCategories. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAttributeCategories() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;    
    }

    @AuraEnabled
    public static Common.ServiceResponse getAttributes(String requestJson) {
        System.debug( LoggingLevel.DEBUG, 'getAttributes() - enter; requestJson= ' + requestJson );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            final Mpln.MplnTemplateRecord maintenanceAttributeTemplateRequest = (Mpln.MplnTemplateRecord) JSON.deserializeStrict( requestJson, Mpln.MplnTemplateRecord.class );

        	serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getAttributes(maintenanceAttributeTemplateRequest);
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAttributes() : Failed to retrieve Attributes. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAttributes() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;    
    }

    @AuraEnabled
    public static Common.ServiceResponse getMaintenanceAssets(String recordId) {
        System.debug( LoggingLevel.DEBUG, 'getMaintenanceAssets() - enter; recordId= ' + recordId );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();    
        
        try {
            serviceResponse.data = MPLN_ConditionBasedMPlanManager.getInstance().getMaintenanceAssets(recordId);
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getMaintenanceAssets() : Failed to retrieve Maintenance Assets. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getMaintenanceAssets() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getAssetFields(final string objectAPIName) {
        System.debug( LoggingLevel.DEBUG, 'getAssetFields() - enter; requestJson= ' + objectAPIName );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            COMM_MetadataManager commMetadataManager = COMM_MetadataManager.getInstance();
            serviceResponse.data = commMetadataManager.getFieldDefinitions(objectAPIName);       
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getAssetFields() : Failed to retrieve AsssetFields. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetFields() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse; 
    }
    
    @AuraEnabled
    public static Common.ServiceResponse saveWorkRuleTemplate (String maintenanceAssetsJSON) {
        System.debug( LoggingLevel.DEBUG, 'saveWorkRule() - enter; requestJson= ' + maintenanceAssetsJSON );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            MPLN_ConditionBasedMPlanManager mplnManager = new MPLN_ConditionBasedMPlanManager();
            Mpln.MaintenanceAssetInformation maintenanceAssetInfoList = ((Mpln.MaintenanceAssetInformation)JSON.deserialize(maintenanceAssetsJSON, Mpln.MaintenanceAssetInformation.class)); 
            
            mplnManager.saveWorkRuleTemplate(maintenanceAssetInfoList);
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'saveWorkRule() : Failed to save WorkRule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveWorkRule() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;     
    }

    @AuraEnabled
    public static Common.ServiceResponse deleteWorkRules(List<String> workRuleIdList) {
        System.debug( LoggingLevel.DEBUG, 'deleteWorkRules() - enter; workRuleIdList= ' + workRuleIdList );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            MPLN_ConditionBasedMPlanManager mplnManager = new MPLN_ConditionBasedMPlanManager();
            mplnManager.deleteWorkRules(workRuleIdList);

        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'deleteWorkRules() : Failed to Delete WorkRule. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteWorkRules() - exit; serviceResponse.success= ' + serviceResponse.success );    
        }
        
        return serviceResponse;
    }
    
}