/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete object mappings.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 * A360TOOL-819 Ramachandra Mohan       26 Nov 2021     Validation service for Object Mapping.
 *****************************************************************************************************/
public with sharing class ADM_ObjectMappingServiceImpl {
    
    private final ADM_ObjectMappingManager objectMappingManager = ADM_ObjectMappingManager.getInstance();
    
    /**
     * This method retrieves all object mapping configured and populate 
     * informations it to the object mapping wrapper.
     */
    public List<Adm.ObjectMapping> getAllObjectMappings() {
        
        System.debug( LoggingLevel.FINEST, 'getAllObjectMappings() - enter');
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            // Retrieve object mapping information from object mapping manager.
            objectMappingList = objectMappingManager.getAllObjectMappings();
            System.debug( LoggingLevel.INFO, 'getAllObjectMappings() : Retrieved all Object Mapping informations. objectMappingList.size()= ' + objectMappingList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappings() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllObjectMappings() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }
    
    /**
     * This method retrieves object mapping for requested Ids and populate 
     * informations it to the object mapping wrapper.
     */
    public Map<String, Adm.ObjectMapping> getObjectMappingsWithDetailsByIds(List<String> mappingIds ) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectMappingsWithDetailsByIds() - enter');
        
        Map<String, Adm.ObjectMapping> objectMappingMap = new Map<String, Adm.ObjectMapping>();
        
        try {
            // Retrieve object mapping information from object mapping manager.
            objectMappingMap = objectMappingManager.getObjectMappingsWithDetailsByIds( mappingIds );
            System.debug( LoggingLevel.INFO, 'getObjectMappingsWithDetailsByIds() : Retrieved all Object Mapping informations. objectMappingMap.size()= ' + objectMappingMap.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsWithDetailsByIds() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectMappingsWithDetailsByIds() - exit; objectMappingMap.size()= ' + objectMappingMap.size() );
        }
        
        return objectMappingMap;
    }

    /**
     * This method is used to retrieve object mapping details for requested object mapping.  
     */
    public Adm.ObjectMapping getObjectMappingDetails( final Adm.ObjectMapping requestObjectMapping ) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectMappingDetails() - enter');
        
        Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
        try {
            // Verify request parameters for required informations.
            if( requestObjectMapping == null || String.isBlank( requestObjectMapping.id ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Invalid arguments. objectMapping= ' + requestObjectMapping);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve objet mapping with details for requested object mapping id.
            objectMapping = objectMappingManager.getObjectMappingDetails( requestObjectMapping.id );
            System.debug( LoggingLevel.INFO, 'getObjectMappingDetails() : Retrieved Object Mapping Details. objectMapping= ' + objectMapping );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve object mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectMappingDetails() - exit');
        }
        
        return objectMapping;
    }
    
    /**
     * This method is used to retrieve object mapping details for requested object name.  
     */
    public List<Adm.ObjectMapping> getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName ) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectMappingsByName() - enter');
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        try {
            // Verify request parameters for required informations.
            if( String.isBlank(targetObjectAPIName) && String.isBlank( sourceObjectAPIName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Invalid arguments. targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName= ' + sourceObjectAPIName);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve objet mapping with details for requested object name.
            if (targetObjectAPIName.indexOf(',') != -1 && sourceObjectAPIName.indexOf(',') != -1) {
                objectMappingList = objectMappingManager.getObjectMappingsByName( targetObjectAPIName.split(','), sourceObjectAPIName.split(',') );
            } else if (String.isNotBlank(targetObjectAPIName) && String.isNotBlank(sourceObjectAPIName)) {
                objectMappingList = objectMappingManager.getObjectMappingsByName( targetObjectAPIName, sourceObjectAPIName );
            } else {
                objectMappingList = objectMappingManager.getObjectMappingsByName( targetObjectAPIName );
            }
            
            System.debug( LoggingLevel.INFO, 'getObjectMappingsByName() : Retrieved Object Mapping Details. objectMappingList= ' + objectMappingList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve object mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectMappingsByName() - exit');
        }
        
        return objectMappingList;
    }

        /**
     * This method is used to retrieve object mapping details for requested object name.  
     */
    public List<Adm.ObjectMapping> getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName, final String headerObject ) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectMappingsByName() - enter');
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        try {
            // Verify request parameters for required informations.
            if( String.isBlank(targetObjectAPIName) && String.isBlank( sourceObjectAPIName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Invalid arguments. targetObjectAPIName= ' + targetObjectAPIName + '; sourceObjectAPIName= ' + sourceObjectAPIName);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
 
            objectMappingList = objectMappingManager.getObjectMappingsByName( targetObjectAPIName, sourceObjectAPIName, headerObject );

            System.debug( LoggingLevel.INFO, 'getObjectMappingsByName() : Retrieved Object Mapping Details. objectMappingList= ' + objectMappingList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve object mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectMappingsByName() - exit');
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to retrieve object mapping details for requested object name.  
     */
    public List<Adm.ObjectMapping> getObjectValueMappingsByName( final String targetObjectAPIName) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectValueMappingsByName() - enter');
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        try {
            // Verify request parameters for required informations.
            if( String.isBlank(targetObjectAPIName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Invalid arguments. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve objet mapping with details for requested object name.
            objectMappingList =  objectMappingManager.getObjectValueMappingsByName( targetObjectAPIName );

            System.debug( LoggingLevel.INFO, 'getObjectValueMappingsByName() : Retrieved Object Mapping Details. objectMappingList= ' + objectMappingList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve object mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectValueMappingsByName() - exit');
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to retrieve object mapping details for requested object name.  
     */
    public List<Adm.ObjectMapping> getObjectValueMappingsByName( final String targetObjectAPIName, final String headerObject ) {
        
        System.debug( LoggingLevel.FINEST, 'getObjectValueMappingsByName() - enter');
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        try {
            // Verify request parameters for required informations.
            if( String.isBlank(targetObjectAPIName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Invalid arguments. targetObjectAPIName= ' + targetObjectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Retrieve objet mapping with details for requested object name.

            objectMappingList =  objectMappingManager.getObjectValueMappingsByName( targetObjectAPIName, headerObject );
            
            System.debug( LoggingLevel.INFO, 'getObjectValueMappingsByName() : Retrieved Object Mapping Details. objectMappingList= ' + objectMappingList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve object mapping details. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getObjectValueMappingsByName() - exit');
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to validate requested objec mapping information.  
     */
    public Adm.ValidationResult validateObjectMapping( final Adm.ObjectMapping requestObjectMapping ) {
        
        System.debug( LoggingLevel.FINEST, 'validateObjectMapping() - enter; objectMapping= ' + requestObjectMapping );
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {
            
            // Verify request for required parameter. Throw SvmxSystem.SvmxNestedException in case of any missing parameters.
            if( requestObjectMapping == null || requestObjectMapping.name == null || String.isBlank(requestObjectMapping.targetObjectAPIName ) || requestObjectMapping.objectMappingDetails == null || requestObjectMapping.objectMappingDetails.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Invalid request parameters. objectMapping= ' + requestObjectMapping );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Perform object mapping validation for requested object mapping.
            validationResult = objectMappingManager.validateObjectMapping( requestObjectMapping );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Failed to save Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Failed to save Object Mapping. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validateObjectMapping() - exit; validationResult= ' + validationResult );
        }
        
        return validationResult;
    }
    
    /**
     * This method is used to save requested objec mapping information. If the id field is null then, 
     * a new object mapping record will be created, otherwise, existing object mapping record will be updated.  
     */
    public Adm.ObjectMapping saveObjectMapping( final Adm.ObjectMapping requestObjectMapping ) {
        
        System.debug( LoggingLevel.FINEST, 'saveObjectMapping() - enter; objectMapping= ' + requestObjectMapping );
        
        Adm.ObjectMapping objectMapping = requestObjectMapping;
        
        try {
            
            // Verify request for required parameter. Throw SvmxSystem.SvmxNestedException in case of any missing parameters.
            if( requestObjectMapping == null || requestObjectMapping.name == null || String.isBlank(requestObjectMapping.targetObjectAPIName ) || requestObjectMapping.objectMappingDetails == null || requestObjectMapping.objectMappingDetails.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Invalid request parameters. objectMapping= ' + requestObjectMapping );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Perform object mapping save for requested object mapping.
            objectMapping = objectMappingManager.saveObjectMapping( requestObjectMapping );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mapping. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveObjectMapping() - exit; objectMapping= ' + objectMapping );
        }
        
        return objectMapping;
    }
    
    /**
     * This method is used to delete requested object mapping information.
     */
    public void deleteObjectMapping( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.FINEST, 'deleteObjectMapping() - enter; objectMapping= ' + objectMapping );
        
        try {
            
            // Verify for valid object mapping id to perform delete operation.
            if( objectMapping == null || objectMapping.id == null ) {
                
                System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Invalid request parameters. objectMapping= ' + objectMapping );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            objectMappingManager.deleteObjectMapping( objectMapping.id );
            System.debug( LoggingLevel.INFO, 'deleteObjectMapping() : deleted Object Mapping; objectMapping= ' + objectMapping.id );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to save Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to save Object Mapping. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deleteObjectMapping() - exit; objectMapping= ' + objectMapping );
        }
    }

    /**
     * This method retrieves all object mapping with details configured and populate 
     * informations it to the object mapping wrapper.
     */
    public List<Adm.ObjectMapping> getAllObjectMappingsWithDetails() {
        
        System.debug( LoggingLevel.FINEST, 'getAllObjectMappingsWithDetails() - enter');
        
        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        
        try {
            // Retrieve object mapping information from object mapping manager.
            objectMappingList = objectMappingManager.getAllObjectMappingsWithDetails();
            System.debug( LoggingLevel.INFO, 'getAllObjectMappingsWithDetails() : Retrieved all Object Mapping informations. objectMappingList.size()= ' + objectMappingList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappingsWithDetails() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllObjectMappingsWithDetails() - exit; objectMappingList.size()= ' + objectMappingList.size() );
        }
        
        return objectMappingList;
    }

    /**
     * This method is used to save requested object mapping list. If the id field is null then, 
     * a new object mapping record will be created, otherwise, existing object mapping record will be updated.  
     */
    public List<Adm.ObjectMapping> saveObjectMappings( final List<Adm.ObjectMapping> objectMappingList ) {
        
        System.debug( LoggingLevel.FINEST, 'saveObjectMappings() - enter; objectMappingList= ' + objectMappingList );
        
        List<Adm.ObjectMapping> objectMapping = objectMappingList;
        
        try {
            
            // Verify request for required parameter. Throw SvmxSystem.SvmxNestedException in case of any missing parameters.
            if( objectMappingList == null || objectMappingList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Invalid request parameters. objectMappingList= ' + objectMappingList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // Perform object mapping save for requested object mapping.
            objectMapping = objectMappingManager.saveObjectMappings( objectMappingList );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Failed to save Object Mapping. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Failed to save Object Mapping. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveObjectMappings() - exit; objectMapping= ' + objectMapping );
        }
        
        return objectMapping;
    }
}