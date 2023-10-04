/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a service class which provides methods for metadata services.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       18 May 2020     Created.
 *****************************************************************************************************/
public with sharing class COMM_MetadataService extends COMM_AbstractMetadataService {
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public COMM_MetadataService(){}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public COMM_MetadataService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    /**
     * This method is used to retrieve all object information exists in the Salesforce Org.
     * 
     * @returns Returns list of entity definition available for user context.
     */
    override public Common.ServiceResponse getAllEntityDefinitions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntityDefinitions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve entity definitions
            serviceResponse.data = new COMM_MetadataServiceImpl().getAllEntityDefinitions();
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
     * This method is used to retrieve entity definition for requested entitys.
     * 
     * @param entityDefinition entity definition with apiNames for which definitions to be retrieved.
     * @return Returns entity definitions for requested entity.
     * 
     * @example getEntityDefinitions([{apiName: 'SVMXA360__Object_Mapping__c'},{apiName: 'SVMXA360__Object_Mapping_Detail__c}])
     */
    public Common.ServiceResponse getEntityDefinition( final Common.EntityDefinition entityDefinition ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve list of entity definition for requested entity's.
            serviceResponse.data = new COMM_MetadataServiceImpl().getEntityDefinition( entityDefinition );
            System.debug( LoggingLevel.INFO, 'getEntityDefinition() : Retrieved object definition list' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve Object definition. Error' + e.getMessage() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve Object definition. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve entity definition for requested entitys.
     * 
     * @param entityDefinitions List of entity definition with apiNames for which definitions to be retrieved.
     * @return Returns list of entity definitions for requested entitys.
     * 
     * @example getEntityDefinitions([{apiName: 'SVMXA360__Object_Mapping__c'},{apiName: 'SVMXA360__Object_Mapping_Detail__c}])
     */
    override public Common.ServiceResponse getEntityDefinitions( final List<Common.EntityDefinition> entityDefinitions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinitions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve list of entity definition for requested entity's.
            serviceResponse.data = new COMM_MetadataServiceImpl().getEntityDefinitions( entityDefinitions );
            System.debug( LoggingLevel.INFO, 'getEntityDefinitions() : Retrieved object definition list' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve Object definition. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve Object definition. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinitions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve child relationship entity definition for requested entitys.
     * 
     * @param entityDefinitions List of entity definition with apiNames for which definitions to be retrieved.
     * @return Returns list of entity definitions for requested entitys.
     * 
     * @example getChildRelationships([{apiName: 'Case'},{apiName: 'WorkOrder}])
     */
    override public Common.ServiceResponse getChildRelationships( final List<Common.EntityDefinition> entityDefinitions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve list of entity definition for requested entity's.
            serviceResponse.data = new COMM_MetadataServiceImpl().getChildRelationships( entityDefinitions );
            System.debug( LoggingLevel.INFO, 'getChildRelationships() : Retrieved child relationship list' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to retrieve child relationship. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to retrieve child relationship. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions({apiName:'SVMXA360__Object_Mapping__c'})
     */
    public Common.ServiceResponse getFieldDefinitions( final Common.EntityDefinition entityDefinition ) {
        return getFieldDefinitions( entityDefinition, false );
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * 
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions({apiName:'SVMXA360__Object_Mapping__c'})
     */
    public Common.ServiceResponse getFieldDefinitions( final Common.EntityDefinition entityDefinition, final Boolean stripPicklistValues ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve field definitions for requested entity definition.
            serviceResponse.data = new COMM_MetadataServiceImpl().getFieldDefinitions( entityDefinition, stripPicklistValues );
            System.debug( LoggingLevel.INFO, 'getFieldDefinitions() : Retrieved field definition list' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definition. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definition. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retireve field definitions for all requested entity definitions
     * 
     * @param entityDefinitions List of EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @return Returns List of EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions([{apiName:'SVMXA360__Object_Mapping__c'},{apiName:'SVMXA360__Object_Mapping_Detail__c'}])
     */
    public Common.ServiceResponse getFieldDefinitions( final List<Common.EntityDefinition> entityDefinitions ) {
        return getFieldDefinitions( entityDefinitions, false );
    }
    
    /**
     * This method is used to retireve field definitions for all requested entity definitions
     * 
     * @param entityDefinitions List of EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * 
     * @return Returns List of EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions([{apiName:'SVMXA360__Object_Mapping__c'},{apiName:'SVMXA360__Object_Mapping_Detail__c'}])
     */
    override public Common.ServiceResponse getFieldDefinitions( final List<Common.EntityDefinition> entityDefinitions, final Boolean stripPicklistValues ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve field definitions for all requested entity definitions.
            serviceResponse.data = new COMM_MetadataServiceImpl().getFieldDefinitions( entityDefinitions, stripPicklistValues );
            System.debug( LoggingLevel.INFO, 'getFieldDefinitions() : Retrieved field definition list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retireve field definitions for all requested entity definitions
     * 
     * @param entityDefinitions List of EntityDefinition with apiName for which list of field definitions to be retrieved.
     * 
     * @return Returns List of EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldSetDefinitions([{apiName:'SVMXA360__Object_Mapping__c'},{apiName:'SVMXA360__Object_Mapping_Detail__c'}])
     */
    override public Common.ServiceResponse getFieldSetDefinitions( final List<Common.EntityDefinition> entityDefinitions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve field definitions for all requested entity definitions.
            serviceResponse.data = new COMM_MetadataServiceImpl().getFieldSetDefinitions( entityDefinitions);
            System.debug( LoggingLevel.INFO, 'getFieldSetDefinitions() : Retrieved field definition list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Failed to retrieve field definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve active flow definitions.
     * 
     * @return Returns List of FlowDefinition instances
     * 
     * @example getAllActiveFlows()
     */
    override public Common.ServiceResponse getAllActiveFlows() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Retrieve flow definitions
            serviceResponse.data = new COMM_MetadataServiceImpl().getAllActiveFlows();
            System.debug( LoggingLevel.INFO, 'getAllActiveFlows() : Retrieved flow definition list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllActiveFlows() : Failed to retrieve flow definitions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve a single active flow using the API Name parameter.
     * @param flowApiName The apiName of the Flow.
     * @returns Returns a single FlowDefinition
     */
    override public Common.ServiceResponse getFlowByApiName( final String flowApiName ) {

        System.debug( LoggingLevel.DEBUG, 'getFlowByApiName() - enter; flowApiName=' + flowApiName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            if( String.isBlank(flowApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            serviceResponse.data = new COMM_MetadataServiceImpl().getFlowByApiName( flowApiName );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getFlowByApiName() : Failed to retrieve a Flow Definition. SvmxNestedException Error= ' + e.getMessage() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();            
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
    

    /**
     * This method is used to retrieve all all profiles in the Salesforce Org.
     * 
     * @returns Returns list of profiles available for user context
     */
    public Common.ServiceResponse getAllProfiles() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllProfiles() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new COMM_MetadataServiceImpl().getAllProfiles();
            System.debug( LoggingLevel.INFO, 'getAllProfiles() : Retrieved profile list' );
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
    
    /**
     * This method is used to retrieve Quick Actions by Object Name
     * 
     * @returns Returns list of quick actions available for user context
     */
    public Common.ServiceResponse getAllQuickActionsByObjectName( final String objectApiName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new COMM_MetadataServiceImpl().getAllQuickActionsByObjectName( objectApiName );
            System.debug( LoggingLevel.INFO, 'getAllQuickActionsByObjectName() : Retrieved Quick Action list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Failed to retrieve Quick Actions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve Quick Actions by Api Name
     * 
     * @returns Returns list of quick actions available for user context
     */
    public Common.ServiceResponse getQuickActionsByApiName( final string objectName, final string apiName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new COMM_MetadataServiceImpl().getQuickActionsByApiName( objectName, apiName );
            System.debug( LoggingLevel.INFO, 'getQuickActionsByApiName() : Retrieved Quick Action list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQuickActionsByApiName() : Failed to retrieve Quick Actions. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }   
}