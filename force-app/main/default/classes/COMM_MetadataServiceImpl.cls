/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is the implementation class for services to retrieve metadata 
 * informations like Objects, Fields etc.
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
public class COMM_MetadataServiceImpl {
    
    /**
     * Static variable to hold metadata manager class instance.
     */
    private static final COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();

    /**
     * Static variable to hold describe manager class instance.
     */
    private static final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
    
    /**
     * This method is used to retrieve all object information exists in the Salesforce Org.
     * 
     * @returns Returns list of entity definition available for user context.
     */
    public List<Common.EntityDefinition> getAllEntityDefinitions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntityDefinitions() - enter' );
        
        List<Common.EntityDefinition> entityDefinitionList;
        try {
        	entityDefinitionList = metadataManager.getAllEntityDefinitions();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntityDefinitions() : Failed to retrieve object definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntityDefinitions() - exit; entityDefinitionList.size()= ' + entityDefinitionList.size() );
        }
        
        return entityDefinitionList;
    }
    
    /**
     * This method is used to retrieve entity definition for requested entitys.
     * 
     * @param entityDefinition entity definition with apiNames for which definitions to be retrieved.
     * @return Returns entity definitions for requested entity.
     * 
     * @example new COMM_MetadataServiceImpl().getEntityDefinitions({apiName: 'SVMXA360__Object_Mapping__c'})
     */
    public Common.EntityDefinition getEntityDefinition( final Common.EntityDefinition entityDefinition ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - enter; entityDefinition= ' + entityDefinition );
        
        Common.EntityDefinition newEntityDefinition;
        
        try {
            
            if( entityDefinition == null || String.isBlank( entityDefinition.apiName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Invalid argument; entityDefinition= ' + entityDefinition );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            newEntityDefinition = getEntityDefinitions( new List<Common.EntityDefinition>{entityDefinition} ).get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve object definition. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve object definition. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - exit' );
        }
        
        return newEntityDefinition;
    }
    
    /**
     * This method is used to retrieve entity definition for requested entitys.
     * 
     * @param entityDefinitions List of entity definition with apiNames for which definitions to be retrieved.
     * @return Returns list of entity definitions for requested entitys.
     * 
     * @example getEntityDefinitions([{apiName: 'SVMXA360__Object_Mapping__c'},{apiName: 'SVMXA360__Object_Mapping_Detail__c}])
     */
    public List<Common.EntityDefinition> getEntityDefinitions( final List<Common.EntityDefinition> entityDefinitions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - enter; entityDefinitions= ' + entityDefinitions );
        
        List<Common.EntityDefinition> entityDefinitionList;
        
        try {
            
            if( entityDefinitions == null || entityDefinitions.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Invalid argument; entityDefinitions= ' + entityDefinitions );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            final Set<String> objectNames = new Set<String>();
            for( Common.EntityDefinition entityDefinition : entityDefinitions ) {
                
                if( String.isBlank( entityDefinition.apiName ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Invalid argument; entityDefinition.apiName= ' + entityDefinition.apiName );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                }
                
                objectNames.add( entityDefinition.apiName );
            }
            
            entityDefinitionList = metadataManager.getEntityDefinitions( new List<String>(objectNames) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve object definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Failed to retrieve object definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - exit' );
        }
        
        return entityDefinitionList;
    }
    
    /**
     * This method is used to retrieve child entity definition for requested entitys.
     * 
     * @param entityDefinitions List of entity definition with apiNames for which definitions to be retrieved.
     * @return Returns list of entity definitions for requested entitys.
     * 
     * @example getChildRelationships([{apiName: 'Case'},{apiName: 'WorkOrder}])
     */
    public List<Common.EntityDefinition> getChildRelationships( final List<Common.EntityDefinition> entityDefinitions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - enter; entityDefinitions= ' + entityDefinitions );
        
        List<Common.EntityDefinition> entityDefinitionList;
        
        try {
            
            if( entityDefinitions == null || entityDefinitions.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Invalid argument; entityDefinitions= ' + entityDefinitions );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            final Set<String> objectNames = new Set<String>();
            for( Common.EntityDefinition entityDefinition : entityDefinitions ) {
                
                if( String.isBlank( entityDefinition.apiName ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Invalid argument; entityDefinition.apiName= ' + entityDefinition.apiName );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                }
                
                objectNames.add( entityDefinition.apiName );
            }
            
            entityDefinitionList = metadataManager.getChildRelationships( new List<String>(objectNames) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to retrieve child relationship. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to retrieve child relationship. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - exit' );
        }
        
        return entityDefinitionList;
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions({apiName:'SVMXA360__Object_Mapping__c'})
     */
    public Common.EntityDefinition getFieldDefinitions( final Common.EntityDefinition entityDefinition ) {
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
    public Common.EntityDefinition getFieldDefinitions( final Common.EntityDefinition entityDefinition, final Boolean stripPicklistValues ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter; entityDefinition= ' + entityDefinition );
        
        Common.EntityDefinition newEntityDefinition;
        
        try {
            
            if( entityDefinition == null || String.isBlank(entityDefinition.apiName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Invalid argument; entityDefinition= ' + entityDefinition );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            newEntityDefinition = getFieldDefinitions( new List<Common.EntityDefinition> {entityDefinition}, stripPicklistValues )[0];
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definition. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit' );
        }
        
        return newEntityDefinition;
    }

	/**
     * This method is used to retireve field definitions for all requested entity definitions
     * 
     * @param entityDefinitions List of EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @return Returns List of EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions([{apiName:'SVMXA360__Object_Mapping__c'},{apiName:'SVMXA360__Object_Mapping_Detail__c'}])
     */
    public List<Common.EntityDefinition> getFieldDefinitions( final List<Common.EntityDefinition> entityDefinitions ) {
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
    public List<Common.EntityDefinition> getFieldDefinitions( final List<Common.EntityDefinition> entityDefinitions, final Boolean stripPicklistValues ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter' );
        
        List<Common.EntityDefinition> entityDefinitionList = new List<Common.EntityDefinition>();
        
        try {
            
            if( entityDefinitions == null || entityDefinitions.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Invalid argument; entityDefinitions= ' + entityDefinitions );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            final Set<String> objectNames = new Set<String>();
            for( Common.EntityDefinition entityDefinition : entityDefinitions ) {
                
                if( String.isBlank( entityDefinition.apiName ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Invalid argument; entityDefinition.apiName= ' + entityDefinition.apiName );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                }
                
                objectNames.add( entityDefinition.apiName );
            }
            
            entityDefinitionList = metadataManager.getFieldDefinitions( new List<String>(objectNames), stripPicklistValues );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve field definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit; entityDefinitionList.size()= ' + entityDefinitionList.size() );
        }
        
        return entityDefinitionList;
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
    public List<Common.EntityDefinition> getFieldSetDefinitions( final List<Common.EntityDefinition> entityDefinitions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - enter' );
        
        List<Common.EntityDefinition> entityDefinitionList = new List<Common.EntityDefinition>();
        
        try {
            
            if( entityDefinitions == null || entityDefinitions.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Invalid argument; entityDefinitions= ' + entityDefinitions );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            final Set<String> objectNames = new Set<String>();
            for( Common.EntityDefinition entityDefinition : entityDefinitions ) {
                
                if( String.isBlank( entityDefinition.apiName ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Invalid argument; entityDefinition.apiName= ' + entityDefinition.apiName );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
                }
                
                objectNames.add( entityDefinition.apiName );
            }
            
            entityDefinitionList = metadataManager.getFieldSetDefinitions( new List<String>(objectNames));
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Failed to retrieve field definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Failed to retrieve field definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - exit; entityDefinitionList.size()= ' + entityDefinitionList.size() );
        }
        
        return entityDefinitionList;
    }

     /**
     * This method is used to retrieve active flow definitions.
     * 
     * @return Returns List of FlowDefinition instances
     * 
     * @example getAllActiveFlows()
     */
    public List<Common.FlowDefinition> getAllActiveFlows() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() - enter' );
        
        List<Common.FlowDefinition> flowDefinitionList = new List<Common.FlowDefinition>();
        
        try {
            flowDefinitionList = metadataManager.getAllActiveFlows();

            System.debug(  LoggingLevel.DEBUG, 'getAllActiveFlows() : Retrieved all flow information. flowDefinitionList.size()= ' + flowDefinitionList.size()  );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllActiveFlows() : Failed to retrieve flow definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() - exit; flowDefinitionList.size()= ' + flowDefinitionList.size() );
        }
        
        return flowDefinitionList;
    }

    /**
     * This method is used to retrieve a single active flow using the API Name parameter.
     * @param flowApiName The apiName of the Flow.
     * @returns Returns a single FlowDefinition
     */
    public Common.FlowDefinition getFlowByApiName(final String flowApiName) {
        
        System.debug( LoggingLevel.DEBUG, 'getFlowByApiName() - enter; flowApiName=' + flowApiName );
        
        Common.FlowDefinition flowDefinition;

        try {

            if( String.isBlank(flowApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            flowDefinition = metadataManager.getFlowByApiName( flowApiName );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getFlowByApiName() : Failed to retrieve a Flow Definition. SvmxNestedException Error= ' + e.getMessage() );
            throw e;
        }        
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getFlowByApiName() : Failed to retrieve a Flow Definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFlowByApiName() - exit; flowDefinition= ' + flowDefinition );
        }
        
        return flowDefinition;
    }    
    
    /**
     * This method is used to retrieve all all profiles in the Salesforce Org.
     * 
     * @returns Returns list of all profiles available
     */
    public List<Common.Profile> getAllProfiles() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllProfiles() - enter' );
        
        List<Common.Profile> profilesList;
        try {
        	profilesList = metadataManager.getAllProfiles();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllProfiles() : Failed to retrieve Profiles. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllProfiles() - exit; profilesList.size()= ' + profilesList.size() );
        }
        
        return profilesList;
    }

    /**
     * This method is used to retrieve Quick Actions by Object Name
     * 
     * @returns Returns list of all available Quick Actions
     */
    public List<Common.QuickActionDefinition> getAllQuickActionsByObjectName( final String objectApiName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - enter' );
        
        List<Common.QuickActionDefinition> actionDefinitionList;
        try {
        	actionDefinitionList = describeManager.getAllQuickActionsByObjectName( objectApiName );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Failed to retrieve Quick Actions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - exit; actionDefinitionList.size()= ' + actionDefinitionList.size() );
        }
        
        return actionDefinitionList;
    }
    
    /**
     * This method is used to retrieve Quick Action by Api Name
     * 
     * @returns Returns the Quick Action Definition
     */
    public Common.QuickActionDefinition getQuickActionsByApiName( final string objectName,  final string apiName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() - enter' );
        
        Common.QuickActionDefinition actionDefinition;
        try {
        	actionDefinition = describeManager.getQuickActionsByApiName( objectName, apiName );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQuickActionsByApiName() : Failed to retrieve Quick Actions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQuickActionsByApiName() - exit; actionDefinition= ' + actionDefinition );
        }
        
        return actionDefinition;
    }   
}