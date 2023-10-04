/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve metadata informations like Objects, Fields etc.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 *****************************************************************************************************/
public with sharing class COMM_MetadataLightningService {

    /**
     * This method is used to retrieve all object information exists in the Salesforce Org.
     * 
     * @returns Returns list of entity definition available for user context.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getAllEntityDefinitions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntityDefinitions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve entity definitions
            serviceResponse = new COMM_MetadataService().getAllEntityDefinitions();
            System.debug( LoggingLevel.INFO, 'getAllEntityDefinitions() : Retrieved object definition list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntityDefinitions() : Failed to retrieve Object definition. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntityDefinitions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve all object information exists in the Salesforce Org except blaclist.
     * 
     * @returns Returns list of entity definition available for user context.
     */
    @AuraEnabled(cacheable=true)
    public static Object getAllEntityDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntityDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();
        
        try {
            // Retrieve entity details
            serviceResponse.data = metadataManager.getAllEntityDetails();
            System.debug( LoggingLevel.INFO, 'getAllEntityDetails() : Retrieved object  list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntityDetails() : Failed to retrieve Object details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntityDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve entity definition for requested object name.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getEntityDefinition( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Common.EntityDefinition entityDefinition = (Common.EntityDefinition) JSON.deserializeStrict( requestJson, Common.EntityDefinition.class );
            serviceResponse = new COMM_MetadataService().getEntityDefinition(entityDefinition);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve Object definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve Object definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getEntityDefinitions( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinitions() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            List<Common.EntityDefinition> entityDefinitions = (List<Common.EntityDefinition>) JSON.deserializeStrict( requestJson, List<Common.EntityDefinition>.class );
        	serviceResponse = new COMM_MetadataService().getEntityDefinitions(entityDefinitions);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve Object definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve Object definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinitions() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getFieldDefinitions( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Common.EntityDefinition entityDefinition = (Common.EntityDefinition) JSON.deserializeStrict( requestJson, Common.EntityDefinition.class );
        	serviceResponse = new COMM_MetadataService().getFieldDefinitions(entityDefinition);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getFieldDefinitionsList( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitionsList() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            List<Common.EntityDefinition> entityDefinitions = (List<Common.EntityDefinition>) JSON.deserializeStrict( requestJson, List<Common.EntityDefinition>.class );
            serviceResponse = new COMM_MetadataService().getFieldDefinitions(entityDefinitions);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitionsList() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitionsList() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitionsList() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getFieldDefinitionsListByType( final String configurationType ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitionsListByType() - enter; configurationType= ' + configurationType );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            if( Common.AllowedConfigCoreObjects.containsKey(configurationType) ) {
                
                final List<Common.EntityDefinition> entityDefinitions = new List<Common.EntityDefinition>();
                for( String allowedObject : Common.AllowedConfigCoreObjects.get(configurationType) ) {
                    
                    final Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
                    entityDefinition.apiName = allowedObject;
                    entityDefinitions.add(entityDefinition);
                }
                serviceResponse = new COMM_MetadataService().getFieldDefinitions(entityDefinitions);
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitionsListByType() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitionsListByType() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled(cacheable=true)
    public static Object getFieldSetDefinitions (final String requestJson){

        System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - enter' );
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try{
            List<Common.EntityDefinition> entityDefinitions = (List<Common.EntityDefinition>) JSON.deserializeStrict( requestJson, List<Common.EntityDefinition>.class );
            serviceResponse = new COMM_MetadataService().getFieldSetDefinitions(entityDefinitions);

        }catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Failed to fetch getFieldSetDefinitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - exit; getFieldSetDefinitions = ' + serviceResponse.data );
        }

        return serviceResponse;
    }

    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getFlowDefinitionList() {
        
        System.debug( LoggingLevel.DEBUG, 'getFlowDefinitionList() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new COMM_MetadataService().getAllActiveFlows();
            System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() : Retrieved flow list' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllActiveFlows() : Failed to retrieve flow definitions. Error ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllActiveFlows() : Failed to retrieve flow definitions. Error ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getFlowByApiName( final String flowApiName ) {

        System.debug( LoggingLevel.DEBUG, 'getFlowByApiName() - enter; flowApiName=' + flowApiName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            if( String.isBlank(flowApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            serviceResponse.data = new COMM_MetadataServiceImpl().getFlowByApiName( flowApiName );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getFlowByApiName() : Failed to retrieve a Flow Definitions. Error= ' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFlowByApiName() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupList(String searchTerm, String objectName, String filters, String recordId, String fields) {

        System.debug( LoggingLevel.DEBUG, 'getLookupList() - enter; = ' + searchTerm + '=' + objectName +  '=' + recordId + '=' +fields);

        List<sObject> lookupList = new List<sObject>();

        try {

            final Config.FilterCriteria filterCriteria = new Config.FilterCriteria();
            filterCriteria.searchTerm = (searchTerm != null ) ? String.escapeSingleQuotes(searchTerm) : null;
            filterCriteria.objectName = (objectName != null ) ? String.escapeSingleQuotes(objectName) : null;
            filterCriteria.whereClause = (filters != null ) ? String.escapeSingleQuotes(filters) : null;
            filterCriteria.id = (recordId != null ) ? String.escapeSingleQuotes(recordId) : null;
            filterCriteria.fields = fields.split(',');
            
            lookupList = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria);

        } catch (Exception e) {

            System.debug( LoggingLevel.ERROR, 'getFieldDefinitionsList() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getLookupList() : lookupList.size()= ' + lookupList.size() );
        }

        return lookupList;  
    }

    /**
     * This method is used to retrieve all profiles in the Salesforce Org.
     * 
     * @returns Returns list of profiles available for user context.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse getAllProfiles() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllProfiles() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new COMM_MetadataService().getAllProfiles();
            System.debug( LoggingLevel.INFO, 'getAllProfiles() : Retrieved object definition list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllProfiles() : Failed to retrieve Profiles. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllProfiles() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getAllQuickActionsByObjectName( final String objectApiName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObject() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new COMM_MetadataService().getAllQuickActionsByObjectName( objectApiName );
            System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() : Retrieved quick action list' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Failed to retrieve quick action definitions. Error ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Failed to retrieve quick action definitions. Error ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getQuickActionsByApiName( final string objectName, final string apiName) {
        
        System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new COMM_MetadataService().getQuickActionsByApiName( objectName, apiName );
            System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() : Retrieved quick action list' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQuickActionsByApiName() : Failed to retrieve quick action definitions. Error ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQuickActionsByApiName() : Failed to retrieve quick action definitions. Error ' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method fetches the LWC details which are exposed in 
     * Salesforce Org. getLWCComponentDetails() is not required for rest interface.
     * @return Returns instance of Common.ServiceResponse with LWC details.
     * @example getLWCComponentDetails();
     */
    @AuraEnabled
    public static Object getLWCComponentDetails( final String objectAPIName) {
        
        System.debug( LoggingLevel.DEBUG, 'getLWCComponentDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();
        
        try {

            serviceResponse.data = metadataManager.getLWCComponentDetails(objectAPIName);
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getLWCComponentDetails() : Failed to retrieve List of LWC details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getLWCComponentDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return JSON.serialize(serviceResponse);
    }

     @AuraEnabled(cacheable=true)
    public static List<String> getAllReferencedEntities(String referenceEntityName){
        System.debug( LoggingLevel.DEBUG, 'getAllReferencedEntities() - enter' );

        List<String> serviceResponse = new List<String>();
        COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();

        try {

            serviceResponse = metadataManager.getAllReferencedEntities(referenceEntityName);

        } catch(Exception e) {
            System.debug( LoggingLevel.ERROR, 'getAllReferencedEntities() : Failed to retrieve List of LWC details. Error' + e.getStackTraceString() );
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAllReferencedEntities() - exit; serviceResponse.success= ' + serviceResponse != null );
        }

        return serviceResponse;
    }
}