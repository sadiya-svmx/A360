/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for object mapping service implementation.
 * Also provides implementation for invokeMethod which maps to the requested object mapping service implementation. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal        18 Aug 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 * A360TOOL-819 Ramachandra Mohan       26 Nov 2021     Validation service for Object Mapping.
 *****************************************************************************************************/
public abstract class ADM_AbstractMappingService extends COMM_SvmxRestBase {
    
    public ADM_AbstractMappingService(){
    }
    
    protected ADM_AbstractMappingService(RestRequest req, RestResponse res) {
        super(req, res, 'mapping');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getAllObjectMappings' {
                    response = getAllObjectMappings();
                }            
                when 'getObjectMappingDetails' {
                    Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
                    objectMapping.id = recordId;              
                    response = getObjectMappingDetails( objectMapping );
                }
                when 'getObjectMappingsByName' {
                    response = getObjectMappingsByName( request.params.get('targetObject'), request.params.get('sourceObject') );
                }
                when 'getObjectMappingsByHeaderObject' {
                    response = getObjectMappingsByHeaderObject( request.params.get('targetObject'), request.params.get('sourceObject'), request.params.get('headerObject') );
                }
                when 'getObjectValueMappingsByName' {
                    response = getObjectValueMappingsByName( request.params.get('targetObject') );
                }
                when 'getObjectValueMappingsByHeaderObject' {
                    response = getObjectValueMappingsByHeaderObject( request.params.get('targetObject'), request.params.get('headerObject') );
                }
                when 'validateObjectMapping' {                
                    response = validateObjectMapping( (Adm.ObjectMapping) deserializeRequestTo( Adm.ObjectMapping.class ) );
                }
                when 'saveObjectMapping' {                
                    response = saveObjectMapping( (Adm.ObjectMapping) deserializeRequestTo( Adm.ObjectMapping.class ) );
                }
                when 'deleteObjectMapping' {  
                    Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
                    objectMapping.id = recordId;              
                    response = deleteObjectMapping( objectMapping );
                }
                when 'getAllObjectMappingsWithDetails' {
                    response = getAllObjectMappingsWithDetails();
                }
                when 'saveObjectMappings' {                
                    response = saveObjectMappings( (List<Adm.ObjectMapping>) deserializeRequestTo( List<Adm.ObjectMapping>.class ) );
                }
                when 'retreiveObjectMappingsWithDetailsByIds' {
                    response = retreiveObjectMappingsWithDetailsByIds( (List<String>) deserializeRequestTo( List<String>.class ) );
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
     * This method is used to retrieve all object mappings from the Org.
     * 
     * @return Returns list of all object mappings.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/mapping/getAllObjectMappings/
     */
    public abstract Common.ServiceResponse getAllObjectMappings();

    /**
     * This method is used to retrieve all object mappings from the Org for the given request.
     * 
     * @return Returns list of object mappings for the provided request.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectMappingDetails/
     */
    public abstract Common.ServiceResponse getObjectMappingDetails( final Adm.ObjectMapping objectMapping );

    /**
     * This method is used to retrieve all object mappings from the Org for the given request.
     * 
     * @return Returns list of object mappings for the provided request.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectMappingsByName/?targetObject=Case&sourceObject=Asset
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectMappingsByName/?targetObject=Case
     */
    public abstract Common.ServiceResponse getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName );

    /**
     * This method is used to retrieve all object mappings from the Org for the given request.
     * 
     * @return Returns list of object mappings for the provided request.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectMappingsByHeaderObject/?targetObject=Case&sourceObject=Asset&headerObject=WorkOrder
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectMappingsByHeaderObject/?targetObject=Case
     */
    public abstract Common.ServiceResponse getObjectMappingsByHeaderObject( final String targetObjectAPIName, final String sourceObjectAPIName, final string headerObject );

        /**
     * This method is used to retrieve all object mappings from the Org for the given request.
     * 
     * @return Returns list of object mappings for the provided request.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectValueMappingsByName/?targetObject=Case
     */
    public abstract Common.ServiceResponse getObjectValueMappingsByName( final String targetObjectAPIName );

    /**
     * This method is used to retrieve all object mappings from the Org for the given request.
     * 
     * @return Returns list of object mappings for the provided request.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectValueMappingsByHeaderObject/?targetObject=Case&headerObject=Asset
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getObjectValueMappingsByHeaderObject/?targetObject=Case
     */
    public abstract Common.ServiceResponse getObjectValueMappingsByHeaderObject( final String targetObjectAPIName, final String headerObject );

    /**
     * This method is used to validate the object mapping in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/mapping/v1/validateObjectMapping/
     */
    public abstract Common.ServiceResponse validateObjectMapping( final Adm.ObjectMapping objectMapping );

    /**
     * This method is used to save the object mapping in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/mapping/v1/saveObjectMapping/
     */
    public abstract Common.ServiceResponse saveObjectMapping( final Adm.ObjectMapping objectMapping );

    /**
     * This method is used to deletes the object mapping in the Org for the given request.
     * 
     * 
     * @example DELETE /services/apexrest/SVMXA360/admin/mapping/v1/deleteObjectMapping/
     */
    public abstract Common.ServiceResponse deleteObjectMapping( final Adm.ObjectMapping objectMapping );

    /**
     * This method is used to retrieve all object mappings with details from the Org.
     * 
     * @return Returns list of all object mappings.
     * 
     * @example GET /services/apexrest/SVMXA360/admin/mapping/v1/getAllObjectMappingsWithDetails/
     */
    public abstract Common.ServiceResponse getAllObjectMappingsWithDetails();

    /**
     * This method is used to save the object mappings in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/mapping/v1/saveObjectMappings/
     */
    public abstract Common.ServiceResponse saveObjectMappings( final List<Adm.ObjectMapping> objectMappingList );

    /**
     * This method is used to get the object mapping details in the Org for the given list of ids.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/admin/mapping/v1/retreiveObjectMappingsWithDetailsByIds/
     */
    public abstract Common.ServiceResponse retreiveObjectMappingsWithDetailsByIds( final List<String> mappingIds );
}