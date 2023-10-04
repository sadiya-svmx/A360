/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for metadata service implementation.
 * Also provides implementation for invokeMethod which maps to the requested metadata service implementation. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       23 Jun 2020     Created.
 *****************************************************************************************************/
public abstract class COMM_AbstractMetadataService extends COMM_SvmxRestBase {

    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public COMM_AbstractMetadataService(){
    }
    
    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected COMM_AbstractMetadataService( RestRequest request, RestResponse response ) {
        super( request, response, 'metadata' );    
    }
    
    /**
     * Override method invoked by base rest class with requested method.
     * 
     * @param methodName Method name from the request URL.
     * 
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Invoke service for requested method name.
            switch on methodName {
                
                when 'getAllEntityDefinitions' {
                    serviceResponse = getAllEntityDefinitions();
                }
                
                when 'getEntityDefinitions' {
                    serviceResponse = getEntityDefinitions( createEntityDefinitions() );
                }
                
                when 'getChildRelationships' {
                    serviceResponse = getChildRelationships( createEntityDefinitions() );
                }
                
                when 'getFieldDefinitions' {
                    
                    final String stripPicklistValuesString = request.params.get('stripPicklistValues');
                    final Boolean stripPicklistValues = String.isNotBlank( stripPicklistValuesString ) ? Boolean.valueOf(stripPicklistValuesString) : false;
                    
                    serviceResponse = getFieldDefinitions( createEntityDefinitions(), stripPicklistValues );
                }

                when 'getFieldSetDefinitions' {
                    serviceResponse = getFieldSetDefinitions( createEntityDefinitions() );
                }

                when 'getAllActiveFlows' {
                    serviceResponse = getAllActiveFlows();
                }

                when 'getFlowByApiName' {
                    final String flowApiName = request.params.get('flowApiName');
                    
                    serviceResponse = getFlowByApiName(flowApiName);
                }
                
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * Private method to construct request entity definition list from the rest request parameter.
     */
    private List<Common.EntityDefinition> createEntityDefinitions() {
        
        System.debug( LoggingLevel.DEBUG, 'createEntityDefinitions() - enter' );
        
        final List<Common.EntityDefinition> entityDefinitions = new List<Common.EntityDefinition>();
        
        try {
            
            final String apiNameString = request.params.get('apiNames');
            final List<String> apiNames = (List<String>) JSON.deserialize(apiNameString, List<String>.class);
            
            for( String apiName : apiNames ) {
                
                final Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
                entityDefinition.apiName = apiName;
                
                entityDefinitions.add( entityDefinition );
            }
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createEntityDefinitions() : Failed to create entity definitions. Error' + e.getStackTraceString() );
            this.response.statusCode = UNPROCESSABLE_ENTITY;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createEntityDefinitions() - exit' );
        }
        
        return entityDefinitions;
    }
        
    /**
     * This method is used to retrieve all allowed entity definitions from the Org.
     * 
     * @return Returns list of entity definition object instance.
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getAllEntityDefinitions/
     */
    public abstract Common.ServiceResponse getAllEntityDefinitions();
    
    /**
     * This method is used to retrieve entity definition for requested api names.
     * 
     * @param entityDefinitions Entity definition instances with api names for which definition to be retrieved.
     * @return Returns entity definition for requested apiNames.
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getEntityDefinitions/?apiNames=["Account","Case"]
     * response:
     * {"success":true,"message":null,"data":[{"label":"Account","fieldDefinitions":[],"custom":false,"apiName":"Account"},{"label":"Case","fieldDefinitions":[],"custom":false,"apiName":"Case"}]}
     */
    public abstract Common.ServiceResponse getEntityDefinitions( final List<Common.EntityDefinition> entityDefinitions );
    
    /**
     * This method is used to retrieve child entity definition for requested api names.
     * 
     * @param entityDefinitions Entity definition instances with api names for which definition to be retrieved.
     * @return Returns entity definition for requested apiNames.
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getChildRelationships/?apiNames=["Account","Case"]
     * response:
     * {"success":true,"message":null,"data":[{"label":"Account","fieldDefinitions":[],"custom":false,"apiName":"Account"},{"label":"Case","fieldDefinitions":[],"custom":false,"apiName":"Case"}]}
     */
    public abstract Common.ServiceResponse getChildRelationships( final List<Common.EntityDefinition> entityDefinitions );
    
    /**
     * This method is used to retrieve field definitions for requested entity api names.
     * 
     * @param entityDefinitions Entity definitions with apiName for which Field definition list to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * 
     * @return Returns list of field definition for requested apinames.
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getFieldDefinitions/?apiNames=["Account","Case"]&stripPicklistValues=true
     */
    public abstract Common.ServiceResponse getFieldDefinitions( final List<Common.EntityDefinition> entityDefinitions, final Boolean stripPicklistValues );
   
    /**
     * This method is used to retrieve field definitions for requested entity api names.
     * 
     * @param entityDefinitions Entity definitions with apiName for which Field definition list to be retrieved.
     * 
     * @return Returns list of field definition for requested apinames.
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getFieldDefinitions/?apiNames=["Account","Case"]&stripPicklistValues=true
     */
    public abstract Common.ServiceResponse getFieldSetDefinitions( final List<Common.EntityDefinition> entityDefinitions );

    /**
     * This method is used to retrieve active flow definitions.
     * 
     * @return Returns list of active flow definitions
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getAllActiveFlows/?
     */
    public abstract Common.ServiceResponse getAllActiveFlows();

    /**
     * This method is used to retrieve a single flow definitions using the Flow's apiName.
     * 
     * @return Returns a single flow definitions
     * 
     * @example /services/apexrest/SVMXA360/svmx/rest/metadata/getFlowByApiName/?flowApiName=Test_Flow
     */
    public abstract Common.ServiceResponse getFlowByApiName( final String flowApiName );

}