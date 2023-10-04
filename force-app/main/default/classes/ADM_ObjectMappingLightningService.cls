/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete object mappings.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 * A360TOOL-819 Ramachandra Mohan       26 Nov 2021     Validation service for Object Mapping.
 *****************************************************************************************************/
public with sharing class ADM_ObjectMappingLightningService {

    /**
     * This method retrieves all available Object mappings 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all object mapping informations.
     */
    @AuraEnabled
    public static Common.ServiceResponse getAllObjectMappings() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse = new ADM_ObjectMappingService().getAllObjectMappings();
            System.debug( LoggingLevel.INFO, 'getAllObjectMappings() : Retrieved object mapping list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappings() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve object mapping details for requested 
     * object mapping in the json.
     */
    @AuraEnabled
    public static Common.ServiceResponse getObjectMappingDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );
            serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(objectMapping);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mapping details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mapping details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method validates object mapping details have valid field api names
     * Salesforce Org. validateObjectMappingDetails() is not required for rest interface.
     * @return Returns instance of Adm.ObjectMapping.
     * @example validateObjectMappingDetails();
     */
    @AuraEnabled
    public static Common.ServiceResponse validateObjectMappingDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateObjectMappingDetails() - enter; requestJson= ' + requestJson  );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        ADM_ObjectMappingManager objectManager = ADM_ObjectMappingManager.getInstance();
        
        try {
            Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );
            serviceResponse.data = objectManager.validateMapping( objectMapping );
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMappingDetails() : Failed to retrieve List of transactions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'validateObjectMappingDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     *This method validates object mapping details have valid field api names before save
     * Salesforce Org. validateBeforeSaveMappingDetails() is not required for rest interface.
     * @return Returns instance of Adm.ObjectMapping.
     * @example validateBeforeSaveMappingDetails(); 
     */
    @AuraEnabled
    public static Common.ServiceResponse validateBeforeSaveMappingDetails( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateBeforeSaveMappingDetails() - enter; requestJson= ' + requestJson  );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        ADM_ObjectMappingManager objectManager = ADM_ObjectMappingManager.getInstance();
        
        try {
            Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );
            serviceResponse.data = objectManager.validateBeforeSaveMappingDetails( objectMapping );
        
        } catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'validateBeforeSaveMappingDetails() : Failed to retrieve List of transactions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        } finally {
            System.debug( LoggingLevel.DEBUG, 'validateBeforeSaveMappingDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method is used to retrieve object mapping details for requested 
     * object mapping in the json.
     */
    @AuraEnabled
    public static Common.ServiceResponse getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter; targetObjectAPIName= ' + targetObjectAPIName + ' sourceObjectAPIName= '+sourceObjectAPIName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse = new ADM_ObjectMappingService().getObjectMappingsByName(targetObjectAPIName, sourceObjectAPIName);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mapping details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve object mapping details for requested 
     * object mapping in the json.
     */
    @AuraEnabled
    public static Common.ServiceResponse getMappingsForObjectList( final List<String> targetObjects, final List<String> sourceObjects ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter; targetObjects= ' + targetObjects + ' sourceObjects= '+sourceObjects );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName(targetObjects, sourceObjects);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mapping details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save object mapping for requested object mapping in json.
     * 
     * @return Returns object mapping details once saved successfully.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveObjectMapping( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveObjectMapping() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );
            serviceResponse = new ADM_ObjectMappingService().saveObjectMapping(objectMapping);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mapping. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mapping. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveObjectMapping() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    @AuraEnabled
    public static Common.ServiceResponse deleteObjectMapping( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteObjectMapping() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) JSON.deserializeStrict( requestJson, Adm.ObjectMapping.class );
            serviceResponse = new ADM_ObjectMappingService().deleteObjectMapping(objectMapping);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to delete Object Mapping. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to delete Object Mapping. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteObjectMapping() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve object mapping details for requested 
     * object mapping ids in the json.
     */
    @AuraEnabled
    public static Common.ServiceResponse getObjectMappingsWithDetailsByIds( final List<String> mappingIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsWithDetailsByIds() - enter; mappingIds= ' + mappingIds );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse = new ADM_ObjectMappingService().retreiveObjectMappingsWithDetailsByIds(mappingIds);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsWithDetailsByIds() : Failed to retrieve Object Mapping details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsWithDetailsByIds() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}