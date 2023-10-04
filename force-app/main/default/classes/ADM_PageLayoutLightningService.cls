/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete Pagelayouts.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                8 Jun 2020     Created.
 *****************************************************************************************************/
global with sharing class ADM_PageLayoutLightningService {

    /**
     * This method fetches pagelayout details for the requested Id 
     * from the Salesforce Org.
     * @param String Id of the pagelayout to be fetched
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     * @example getPageLayoutDetails('<PageLayoutID>');
     */
    @RemoteAction @AuraEnabled
    global static Object getPageLayoutDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            if(String.isBlank(requestJson)){
                System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Invalid request' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );                
            }

            boolean translationRequired = false;
            serviceResponse = new ADM_PageLayoutService().getPageLayoutDetails(requestJson, translationRequired, Adm.SourceOrigin.Admin);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches all the page layouts available in the
     * Salesforce Org.
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     * @example getAllPageLayouts();
     */
    @RemoteAction @AuraEnabled
    global static Object getAllPageLayouts( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            boolean translationRequired = false;
            serviceResponse = new ADM_PageLayoutService().getAllPageLayouts(requestJson, translationRequired);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayouts() : Failed to retrieve List of Page Layouts. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches all the tags available in the
     * Salesforce Org.
     * @return Returns instance of Common.ServiceResponse with tags.
     * @example getAllTags();
     */
    @RemoteAction @AuraEnabled
    global static Object getAllTags( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllTags() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_PageLayoutService().getAllTags();
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTags() : Failed to retrieve List of tags. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTags() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches Where Used status
     * Salesforce Org.
     * @return Returns instance of Common.ServiceResponse with where used status.
     * @example getWhereUsedStatus();
     */
    @RemoteAction @AuraEnabled
    global static Object getWhereUsedStatus( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedStatus() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_PageLayoutService().getWhereUsedStatus();
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedStatus() : Failed to retrieve List of tags. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedStatus() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method fetches the transactions for specific object available in the
     * Salesforce Org. getLayoutsByObjectNameAndType() is not required for rest interface.
     * @return Returns instance of Common.ServiceResponse with transaction for requested object.
     * @example getLayoutsByObjectNameAndType();
     */
    @AuraEnabled
    global static Object getLayoutsByObjectNameAndType( final String screenType, final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getLayoutsByObjectNameAndType() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        ADM_PageLayoutManager pageLayoutManager = ADM_PageLayoutManager.getInstance();
        
        try {

            serviceResponse = pageLayoutManager.getLayoutsByObjectNameAndType( screenType, objectName );
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getLayoutsByObjectNameAndType() : Failed to retrieve List of transactions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getLayoutsByObjectNameAndType() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method performs page layout save and maps back the 
     * salesforce generated Ids
     * @return Returns instance of Common.ServiceResponse with save page layout info.
     */
    @RemoteAction @AuraEnabled
    global static Object savePageLayout(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'savePageLayout() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.PageLayout pageLayoutInfo = (Adm.PageLayout) JSON.deserializeStrict( requestJson, Adm.PageLayout.class );
            serviceResponse = new ADM_PageLayoutService().savePageLayout(pageLayoutInfo, Adm.SourceOrigin.Admin);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'savePageLayout() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method retrieves transaction where used details
     * @return Returns instance of Common.ServiceResponse with where used info.
     */
    @RemoteAction @AuraEnabled
    global static Object getWhereUsedTransactionDetails(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedTransactionDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.WhereUsedInputRecord whereUsedInputRecord = (Adm.WhereUsedInputRecord) JSON.deserializeStrict( requestJson, Adm.WhereUsedInputRecord.class );
            serviceResponse = new ADM_PageLayoutService().getWhereUsedTransactionDetails(whereUsedInputRecord);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedTransactionDetails() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedTransactionDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method retrieves transactions of configuration filter
     * @return Returns instance of Common.ServiceResponse with where used info.
     */
    @RemoteAction @AuraEnabled
    global static Object getFilteredConfigurations(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Adm.ConfigFilterInputRecord configFilterInputRecord = (Adm.ConfigFilterInputRecord) JSON.deserializeStrict( requestJson, Adm.ConfigFilterInputRecord.class );
            serviceResponse = new ADM_PageLayoutService().getFilteredConfigurations(configFilterInputRecord);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getFilteredConfigurations() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method retrieves configuration filters
     * @return Returns instance of Common.ServiceResponse with where used info.
     */
    @RemoteAction @AuraEnabled
    global static Object getAllConfigurationFilters(String entityType) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_PageLayoutService().getAllConfigurationFilters(entityType);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationFilters() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    /**
     * This method deletes pagelayout and related records 
     * from the Salesforce Org.
     * @param String Id of the pagelayout to be deleted
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     */
    @RemoteAction @AuraEnabled
    global static Object deletePageLayout( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePageLayout() - enter : requestJson ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            if(String.isBlank(requestJson)){
                System.debug( LoggingLevel.ERROR, 'deletePageLayout() : Invalid request' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );                
            }

            serviceResponse = new ADM_PageLayoutService().deletePageLayout(requestJson);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'deletePageLayout() : Failed to delete Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'deletePageLayout() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

    @RemoteAction @AuraEnabled
    global static Object getUserInfo ( final String requestJson ){

        System.debug( LoggingLevel.DEBUG, 'getUserInfo() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{

            serviceResponse = new ADM_PageLayoutService().getUserInfo();

        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getUserInfo() : Failed to fetch userinfo. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getUserInfo() - exit; UserInfo = ' + serviceResponse.data );
        }

        return JSON.serialize(serviceResponse);
    }

    @RemoteAction 
    global static Object getAllEntityDefinitions( final String requestJson ){
        return JSON.serialize(COMM_MetadataLightningService.getAllEntityDefinitions());
    }

    @RemoteAction 
    global static Object getEntityDefinition( final String requestJson ){
        return JSON.serialize(COMM_MetadataLightningService.getEntityDefinition(requestJson));
    }

    @RemoteAction 
    global static Object getEntityDefinitions( final String requestJson ){
        return JSON.serialize(COMM_MetadataLightningService.getEntityDefinitions(requestJson));
    }

    @RemoteAction 
    global static Object getFieldDefinitions( final String requestJson ){
        return JSON.serialize(COMM_MetadataLightningService.getFieldDefinitions(requestJson));
    }
    
    @RemoteAction 
    global static Object getFieldDefinitionsList( final String requestJson ){
        return JSON.serialize(COMM_MetadataLightningService.getFieldDefinitionsList(requestJson));
    }

    @RemoteAction
    global static Object getChildRelationships (final String requestJson){

        System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{
            List<Common.EntityDefinition> entityDefinitions = (List<Common.EntityDefinition>) JSON.deserializeStrict( requestJson, List<Common.EntityDefinition>.class );
            serviceResponse = new COMM_MetadataService().getChildRelationships(entityDefinitions);

        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to fetch getChildRelationships. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - exit; getChildRelationships = ' + serviceResponse.data );
        }

        return JSON.serialize(serviceResponse);
    }

    @RemoteAction
    global static Object getFieldSetDefinitions (final String requestJson){
        return JSON.serialize(COMM_MetadataLightningService.getFieldSetDefinitions(requestJson));
    }

    @RemoteAction
    global static Object getMappingsByTarget(final String requestJson){

        System.debug( LoggingLevel.DEBUG, 'getMappingsByTarget() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{

            Adm.ObjectMapping objectMappingInfo = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );
            serviceResponse.data = ADM_ObjectMappingManager.getInstance().getObjectValueMappingsByName(objectMappingInfo.targetObjectAPIName, objectMappingInfo.headerRecordObject);
        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getMappingsByTarget() : Failed to fetch getMappingsByTarget. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getMappingsByTarget() - exit; MappingList = ' + serviceResponse.data );
        }

        return JSON.serialize(serviceResponse);
    }

    /*
        This method is deprecated. Use getMappingsBySourceTarget(final String requestJson) instead.
    */
    @RemoteAction 
    global static Object getMappingsBySourceTarget(final String targetObjectAPIName, final String sourceObjectAPIName){
        return null;
    }
    
    @RemoteAction
    global static Object getMappingsBySourceTarget(final String requestJson){

        System.debug( LoggingLevel.DEBUG, 'getMappingsBySourceTarget() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{
            Adm.ObjectMapping objectMappingInfo = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );

            serviceResponse.data = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName(objectMappingInfo.targetObjectAPIName, objectMappingInfo.sourceObjectAPIName, objectMappingInfo.headerRecordObject);
        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getMappingsBySourceTarget() : Failed to fetch getMappingsBySourceTarget. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getMappingsBySourceTarget() - exit; MappingList = ' + serviceResponse.data );
        }

        return JSON.serialize(serviceResponse);
    }

    @RemoteAction
    global static Object getExpressionsByObject(final String objectAPIName ){

        System.debug( LoggingLevel.DEBUG, 'getExpressionsByObject() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{

            serviceResponse.data = ADM_ExpressionManager.getInstance().getExpressions(objectAPIName);
        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsByObject() : Failed to fetch getExpressionsByObject. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsByObject() - exit; ExpressionList = ' + serviceResponse.data );
        }

        return JSON.serialize(serviceResponse);
    }

    @RemoteAction
    global static Object getExpressionsByType( final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'getExpressionsByType() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{
            Adm.Expression expressionInfo = (Adm.Expression) JSON.deserializeStrict( requestJson, Adm.Expression.class );
            serviceResponse.data = ADM_ExpressionManager.getInstance().getExpressionsByType(expressionInfo.objectAPIName, expressionInfo.expressionType);
        
        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getExpressionsByType() : Failed to fetch getVisibilityCriteriaExpressions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getExpressionsByType() - exit; ExpressionList = ' + serviceResponse.data );
        }

        return JSON.serialize(serviceResponse);
    }

    /*
        This method is deprecated. Use getLookupConfigurations(final String objectName, final String headerObject) instead.
    */
    @RemoteAction 
    global static Object getLookupConfigurations(final String requestJson){
        System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.LookupConfig lookupConfigInfo = (Adm.LookupConfig) JSON.deserializeStrict( requestJson, Adm.LookupConfig.class );
            serviceResponse = new ADM_LookupConfigService().getLookupConfigurations( lookupConfigInfo.objectAPIName, lookupConfigInfo.headerRecordObject );
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLookupConfigurations() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return JSON.serialize(serviceResponse);
    }

    @RemoteAction
    global static Object getPageLayoutCustomLabels(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutCustomLabels() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_PageLayoutService().getPageLayoutCustomLabels();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPageLayoutCustomLabels() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return JSON.serialize(serviceResponse);
    }    
    
    @RemoteAction
    global static Object getAllFeatureParameterValues(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllFeatureParameterValues() - enter;');
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new ADM_PageLayoutService().getAllFeatureParameterValues();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllFeatureParameterValues() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return JSON.serialize(serviceResponse);
    }     
}