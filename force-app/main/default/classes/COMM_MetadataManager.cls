/******************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines methodds to retrieve metadata informations like Objects, Fields etc.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       18 May 2020     Created.
 * BLOS-862     Ramachandra Mohan       17 Sep 2020     Support controller name and dependent picklist flag.
 * BLOS-721     Ramachandra Mohan       22 Sep 2020     Updated relatedTo object labels with parent field label.
 * A360ADM-141  Ramachandra Mohan       13 Oct 2020     Updated getChildRelationships to filter only whitelist objects.
 * A360ADM-443  Ramachandra Mohan       23 Oct 2020     Removed whitelist filtering for referenceTo.
 * A360ADM-453  Ramachandra Mohan       28 Oct 2020     Removed isUpdateable check for object & field describe
 * A360ENG-886  Jason Bradley           25 Feb 2021     Added getFieldDefinition with support for compound field paths.
 * A360ENG-1000 Sachin S                27 Apr 2021     Added new attribute compountFieldName to identify compound sub fields.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class COMM_MetadataManager {
    
    /**
     * Private static variable to hold instance of describe manager which will be consumed to 
     * retrieve entity and field definitions.
     */
    private static final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
    private static final Set<String> allowedFlowProcessTypes = new Set<String>{'AutoLaunchedFlow', 'Flow'};
    /**
     * Private static variable to hold instance of this class.
     */
    private static COMM_MetadataManager instance;
    /**
     * Private static variable to hold LWC details.
     */
    private static List<Common.LWCRecord> lwcRecordList;
    
    /**
     * Static method to retrieve instance of this class. 
     */
    public static COMM_MetadataManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'getInstance() - enter');
        
        try {
            // Create instance of this class if not exists.
            if( instance == null ) {
                instance = new COMM_MetadataManager();
                lwcRecordList = new List<Common.LWCRecord>();
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'getInstance() - exit');
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all object information exists in the Salesforce Org.
     * 
     * @returns Returns list of entity definition available for user context.
     */
    public List<Common.EntityDefinition> getAllEntityDefinitions() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntityDefinitions() - enter' );
        
        List<Common.EntityDefinition> entityDefinitionList;
        try {
            
            final Map<String, Schema.SObjectType> sObjectTypeMap = COMM_DescribeManager.getInstance().getGlobalDescribe();
        	entityDefinitionList = getEntityDefinitions( new List<String>(sObjectTypeMap.keySet()) );
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
    * This method retrieves record type details for requested object name.
    */
    public List<Common.RecordType> getRecordTypeDetails( final String objectAPIName ) {

        System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - enter :  objectAPIName ' +  objectAPIName );
        
        List<Common.RecordType> recordTypeList = new List<Common.RecordType>();  
        
        try {
            // Verify for valid parameters.
            if( String.isBlank(objectAPIName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getRecordTypeDetails() : Invalid request parameters. objectAPIName = ' + objectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<RecordType> recordTypeRecords = SvmxDatabase.query([SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = :objectAPIName]);

            for(RecordType recordType : recordTypeRecords) {
                Common.RecordType recordTypeWrapper = new Common.RecordType();
                recordTypeWrapper.id = recordType.Id;
                recordTypeWrapper.name = recordType.Name;
                recordTypeWrapper.developerName = recordType.DeveloperName;
                recordTypeList.add(recordTypeWrapper);
            }
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getRecordTypeDetails() : Failed to retrieve record type details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - exit; recordTypeList.size()= ' + recordTypeList.size() );
        } 
        
        return recordTypeList;
        
    }

    /**
    * This method retrieves record type details for requested list of object name.
    */
    public Map<String, List<Common.RecordType>> getObjectRecordTypeDetails( final List<String> objectAPINames ) {

        System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeDetails() - enter :  objectAPINames ' +  objectAPINames );
        
        Map<String, List<Common.RecordType>> recordTypeMap = new Map<String, List<Common.RecordType>>();  
        
        try {
            // Verify for valid parameters.
            if( objectAPINames == null || objectAPINames.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeDetails() : Invalid request parameters. objectAPINames = ' + objectAPINames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            List<RecordType> recordTypeRecords = SvmxDatabase.query([SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType IN :objectAPINames]);

            for(RecordType recordType : recordTypeRecords) {
                Common.RecordType recordTypeWrapper = new Common.RecordType();
                recordTypeWrapper.id = recordType.Id;
                recordTypeWrapper.name = recordType.Name;
                recordTypeWrapper.developerName = recordType.DeveloperName;

                if (recordTypeMap.containsKey(recordType.SobjectType)) {
                    recordTypeMap.get(recordType.SobjectType).add(recordTypeWrapper);
                } else {
                    List<Common.RecordType> recordTypeList = new List<Common.RecordType>();
                    recordTypeList.add(recordTypeWrapper);
                    recordTypeMap.put(recordType.SobjectType, recordTypeList);
                }
            }
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeDetails() : Failed to retrieve record type details. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeDetails() - exit; recordTypeMap.size()= ' + recordTypeMap.size() );
        } 
        
        return recordTypeMap;
        
    }

    /**
     * This method is used to retrieve all object information exists in the Salesforce Org except blacklist objects.
     * 
     * @returns Returns list of entity definition available for user context.
     */
    public List<Common.EntityDetails> getAllEntityDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntityDetails() - enter' );
        
        List<Common.EntityDetails> sObjectTypeAllDetails = new List<Common.EntityDetails>();
        try {
            
            sObjectTypeAllDetails = COMM_DescribeManager.getInstance().getAllGlobalDescribe();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntityDetails() : Failed to retrieve object definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntityDetails() - exit; entityDefinitionList.size()= ' + sObjectTypeAllDetails.size() );
        }
        
        return sObjectTypeAllDetails;
    }
    
    /**
     * This method is used to retrieve entity definition for requested object name.
     * 
     * @param objectNames List of entity definition with apiNames for which definitions to be retrieved.
     * @return Returns entity definitions for requested object name.
     * 
     * @example getEntityDefinition('SVMXA360__Object_Mapping__c')
     */
	public Common.EntityDefinition getEntityDefinition( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinition() - enter; objectName= ' + objectName );
        
        Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
        
        try {
            
            // Verify for valid list of object API names
            if( String.isBlank(objectName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntityDefinition() : Invalid argument; objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            entityDefinition = getEntityDefinitions( new List<String>{objectName} ).get(0);
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
        
        return entityDefinition;
    }
    
    /**
     * This method is used to retrieve entity definition for requested entitys.
     * 
     * @param objectNames List of entity definition with apiNames for which definitions to be retrieved.
     * @return Returns list of entity definitions for requested entitys.
     * 
     * @example getEntityDefinitions(['SVMXA360__Object_Mapping__c','SVMXA360__Object_Mapping_Detail__c'])
     */
	public List<Common.EntityDefinition> getEntityDefinitions( final List<String> objectNames ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntityDefinitions() - enter; objectNames= ' + objectNames );
        
        List<Common.EntityDefinition> entityDefinitionList = new List<Common.EntityDefinition>();
        
        try {
            
            // Verify for valid list of object API names
            if( objectNames == null || objectNames.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Invalid argument; objectNames= ' + objectNames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Perform object describe for requested objects.
            Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = describeManager.getObjectDescribe( objectNames );
            
            for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultMap.values() ) {
                
                // Create entity definition only if user has access. 
                if( describeSobjectResult.isAccessible() && describeSobjectResult.isQueryable() ) {
                    entityDefinitionList.add( createEntityDefinition(describeSobjectResult) );
                }
            }
            // Sort list by label
            entityDefinitionList.sort();
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve object definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve object definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntityDefinitions() - exit');
        }
        
        return entityDefinitionList;
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions('SVMXA360__Object_Mapping__c')
     */
    public Common.EntityDefinition getFieldDefinitions( final String objectName ) {
        return getFieldDefinitions( objectName, false );
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * 
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions('SVMXA360__Object_Mapping__c')
     */
    public Common.EntityDefinition getFieldDefinitions( final String objectName, final Boolean stripPicklistValues ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter; objectName= ' + objectName );
        
        Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
        
        try {
            
            // Verify for valid list of object API names
            if( String.isBlank(objectName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Invalid argument; objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            entityDefinition = getFieldDefinitions( new List<String> {objectName}, stripPicklistValues, false ).get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve object definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Failed to retrieve object definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit' );
        }
        
        return entityDefinition;
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions(['SVMXA360__Object_Mapping__c','SVMXA360__Object_Mapping_Detail__c'])
     */
    public List<Common.EntityDefinition> getFieldDefinitions( final List<String> objectNames ) {
        return getFieldDefinitions( objectNames, false, false );
    }

     /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * 
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions(['SVMXA360__Object_Mapping__c','SVMXA360__Object_Mapping_Detail__c'])
     */
    public List<Common.EntityDefinition> getFieldDefinitions( final List<String> objectNames, final Boolean stripPicklistValues ) {
        return getFieldDefinitions( objectNames, stripPicklistValues, false );
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * @param ignorePermissions Boolean value to indicate whether to ignore object and field level permissions in the response or not.
     * 
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getFieldDefinitions(['SVMXA360__Object_Mapping__c','SVMXA360__Object_Mapping_Detail__c'])
     */
    public List<Common.EntityDefinition> getFieldDefinitions( final List<String> objectNames, final Boolean stripPicklistValues, final Boolean ignorePermissions ) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - enter; objectNames= ' + objectNames );
        
        List<Common.EntityDefinition> entityDefinitionList = new List<Common.EntityDefinition>();
        
        try {
            
            // Verify for valid list of object API names
            if( objectNames == null || objectNames.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldDefinitions() : Invalid argument; objectNames= ' + objectNames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // For each object API name, retrieve entity and field definitions.
            Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = describeManager.getObjectDescribe( objectNames );
            for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultMap.values() ) {
                
                if( (describeSobjectResult.isAccessible() || ignorePermissions) && describeSobjectResult.isQueryable() ) {
                    
                    final Common.EntityDefinition entityDefinition = createEntityDefinition( describeSobjectResult );
                    final Map<String, Schema.SObjectField> sObjectFieldMap = describeManager.getObjectFieldMap( entityDefinition.apiName );
                    
                    for( Schema.SObjectField sObjectField : sObjectFieldMap.values() ) {
                        
                        // Field describe for each field available in the entity.
                        final Schema.DescribeFieldResult describeFieldResult = describeManager.getFieldDescribe( sObjectField );
                        final Schema.DescribeFieldResult accessibleDescribeFieldResult;
                        if( describeFieldResult.isAccessible() || ignorePermissions ) {
                            if( entityDefinition.apiName == 'Event' ) {
                                if ( Common.WhitelistEventFields.contains(describeFieldResult.getName().toLowerCase() ) || describeFieldResult.isCustom() ) {
                                    accessibleDescribeFieldResult = describeFieldResult;
                                }

                            } else if ( entityDefinition.apiName == 'Task' ) {
                                if ( Common.WhitelistTaskFields.contains(describeFieldResult.getName().toLowerCase() ) || describeFieldResult.isCustom() ) {
                                    accessibleDescribeFieldResult = describeFieldResult;
                                }
                            } else {
                                accessibleDescribeFieldResult = describeFieldResult;
                            }
                            if( accessibleDescribeFieldResult != null ) {
                                Common.FieldDefinition fieldDefinition = createFieldDefinition(accessibleDescribeFieldResult, stripPicklistValues);
                                entityDefinition.fieldDefinitions.add(fieldDefinition);
                                entityDefinition.fieldDefinitionsByApiName.put(fieldDefinition.apiName.toLowerCase(), fieldDefinition);
                            }
                        }
                    }
                    
                    // Sort field definition by field label and save it to list.
                    entityDefinition.fieldDefinitions.sort();
                    entityDefinitionList.add(entityDefinition);
                    
                    System.debug(LoggingLevel.INFO, 'getFieldDefinitions() - Field definitions retrieved successfully. ObjectName= ' + entityDefinition.label );
                }
            }
            
            // Sort entity definition list by label
            entityDefinitionList.sort();
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve object definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntityDefinitions() : Failed to retrieve object definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDefinitions() - exit' );
        }
        
        return entityDefinitionList;
    }

    /**
     * Retrieves the target field definition, given an object name and a field name (supports compound paths)
     * 
     * @param objectName apiName of the entity that the target field resides on
     * @param fieldName apiName of the target field
     * 
     * @return Returns a FieldDefinition instance for the target field
     * 
     * @example getFieldDefinition('SVMXA360__Object_Mapping__c', 'SVMXA360__Object_Mapping_Detail__r.Name')
     */
    public Common.FieldDefinition getFieldDefinition(final String objectName, final String fieldName, final Boolean stripPicklistValues) {
        
        System.debug( LoggingLevel.DEBUG, 'getFieldDefinition() - enter; objectName= ' + objectName );
        
        Common.FieldDefinition fieldDefinition;
        
        try {
            // Verify object API name
            if (String.isBlank(objectName)) {
                System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : Invalid argument; objectName= ' + objectName);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            // Verify field API name
            if (String.isBlank(fieldName)) {
                System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : Invalid argument; fieldName= ' + fieldName);
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
            }

            List<String> compoundPathParts = fieldName.split('\\.');
            Common.EntityDefinition objectDefinition = getFieldDefinitions(objectName, stripPicklistValues);

            Integer numberOfPathParts = compoundPathParts.size();
            for (Integer i = 0; i < numberOfPathParts; i++) {
                String compoundPathPart = compoundPathParts[i];

                fieldDefinition = findField(objectDefinition, compoundPathPart);
                if (fieldDefinition == null) {
                    System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : Invalid field name "' + objectDefinition.apiName + '.' + compoundPathPart + '".');
                    throw new SvmxSystem.SvmxNestedException(String.format(
                        ErrorMessage.FIELD_INACCESSIBLE_OR_NOT_EXISTS,
                        new List<String> {
                            objectDefinition.apiName,
                            compoundPathPart
                        }
                    ));
                }

                if (i < numberOfPathParts - 1) {
                    if (fieldDefinition.dataType != Schema.DisplayType.REFERENCE.name()) {
                        System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : Field name "' + fieldDefinition.apiName + '" in compound path "' + fieldName + '" is not a reference field.');
                        throw new SvmxSystem.SvmxNestedException(String.format(
                            ErrorMessage.FIELD_NOT_A_REFERENCE,
                            new List<String> { fieldDefinition.apiName }
                        ));
                    }

                    // TODO: Polymorphic lookup support?
                    objectDefinition = getFieldDefinitions(fieldDefinition.referenceTo[0], stripPicklistValues);
                    if (objectDefinition == null) {
                        System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : No access to object referenced by lookup field or object does not exist. object=' + fieldDefinition.referenceTo[0]);
                        throw new SvmxSystem.SvmxNestedException(String.format(
                            ErrorMessage.OBJECT_INACCESSIBLE_OR_NOT_EXISTS,
                            new List<String> { fieldDefinition.referenceTo[0] }
                        ));
                    }
                }
            }

            System.debug(LoggingLevel.INFO, 'getFieldDefinition() - Field definition retrieved successfully. objectName= ' + objectName + ' fieldName= ' + fieldName);
        } catch (SvmxSystem.SvmxNestedException e) {
            System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : Failed to retrieve field definition. Error= ' + e.getMessage());
            throw e;
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'getFieldDefinition() : Failed to retrieve field definition. Error= ' + e.getStackTraceString());
            throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'getFieldDefinitions() - exit');
        }
        
        return fieldDefinition;
    }
    
    /**
     * This method is used to retireve field definitions for requested entity definition
     * 
     * @param entityDefinition EntityDefinition with apiName for which list of field definitions to be retrieved.
     * @param stripPicklistValues Boolean value to indicate whether to include picklist values in the response or not.
     * 
     * @return Returns EntityDefinition instance with list of field definitions.
     * 
     * @example getChildRelationships(['WorkOrder','Case'])
     */
    public List<Common.EntityDefinition> getChildRelationships( final List<String> objectNames ) {
        
        System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - enter; objectNames= ' + objectNames );
        
        List<Common.EntityDefinition> entityDefinitionList = new List<Common.EntityDefinition>();
        
        try {
            
            // Verify for valid list of object API names
            if( objectNames == null || objectNames.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Invalid argument; objectNames= ' + objectNames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // For each object API name, retrieve entity and field definitions.
            Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = describeManager.getObjectDescribe( objectNames );
            for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultMap.values() ) {
                
                if( !describeSobjectResult.isAccessible() || !describeSobjectResult.isQueryable() ) {
                    continue;
                }
                
                Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
                entityDefinition.apiName = describeSobjectResult.getName();
                entityDefinition.label = describeSobjectResult.getLabel();
                    
                for( Schema.ChildRelationship childRelationship : describeSobjectResult.getChildRelationships() ) {
                    
                    final String objectName = String.valueOf(childRelationship.getChildSObject() ).toLowerCase();
                    if(  !Common.WhitelistStandardObjects.contains(objectName) && objectName.indexOf('__c') == -1 ) {
                        continue;
                    }

                    final Schema.DescribeSObjectResult childDescribeSObjectResult = describeManager.getObjectDescribe( objectName );
                    final String childObjectName = childDescribeSObjectResult.getName();
                        
                    if( !childDescribeSObjectResult.isAccessible() || !childDescribeSObjectResult.isQueryable() ) {
                        continue;
                    }
                    
                    if(  Common.WhitelistStandardObjects.contains(childObjectName.toLowerCase() ) || ( childDescribeSObjectResult.isCustom() && !Common.BlacklistCustomObjects.contains( childObjectName.toLowerCase() ) ) ) {
                        
                        final Schema.DescribeFieldResult lookupFieldDescribe = describeManager.getFieldDescribe( childRelationship.getField() );
                        Common.ChildDefinition childDefinition = new Common.ChildDefinition();
                        
                        childDefinition.apiName = childObjectName;
                        childDefinition.label = childDescribeSObjectResult.getLabel();
                        childDefinition.customLookupField = lookupFieldDescribe.isCustom();
                        childDefinition.lookupFieldLabel = lookupFieldDescribe.getLabel();
                        childDefinition.lookupFieldName = String.valueOf( childRelationship.getField() );
                        childDefinition.relationshipName = childRelationship.getRelationshipName();
                        
                        entityDefinition.childDefinitions.add( childDefinition );
                    }
                    
                }
                entityDefinitionList.add(entityDefinition);
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to retrieve child relationships. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getChildRelationships() : Failed to retrieve child relationships. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getChildRelationships() - exit' );
        }
        
        return entityDefinitionList;
    }

    public List<Common.EntityDefinition> getFieldSetDefinitions( final List<String> objectNames ) {
                
        System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - enter; objectNames= ' + objectNames );
        
        List<Common.EntityDefinition> entityDefinitionList = new List<Common.EntityDefinition>();
        
        try {
            
            // Verify for valid list of object API names
            if( objectNames == null || objectNames.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Invalid argument; objectNames= ' + objectNames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // For each object API name, retrieve entity and field definitions.
            Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = describeManager.getObjectDescribe( objectNames );
            for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultMap.values() ) {
                
                if( !describeSobjectResult.isAccessible() || !describeSobjectResult.isQueryable() ) {
                    continue;
                }        
                
                Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
                entityDefinition.apiName = describeSobjectResult.getName();
                entityDefinition.label = describeSobjectResult.getLabel();
                List<Common.FieldSetDefinition> fieldSetDefinitions = new List<Common.FieldSetDefinition>();

                for( Schema.FieldSet fldSet : describeSobjectResult.fieldSets.getMap().values()) {
                    Common.FieldSetDefinition fldSetDefn = new Common.FieldSetDefinition(fldSet.getName(), fldSet.getLabel(), fldSet.getDescription());
                    entityDefinition.fieldSetDefinitions.add(fldSetDefn);                
                }
                
                entityDefinitionList.add(entityDefinition);
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Failed to retrieve child relationships. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFieldSetDefinitions() : Failed to retrieve child relationships. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldSetDefinitions() - exit' );
        }

        return entityDefinitionList;
    }


    /**
     * This method is used to retrieve all active flows that exist in the Salesforce Org.
     * 
     * @returns Returns list of flow definitions available for user context.
     */
    public List<Common.FlowDefinition> getAllActiveFlows() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() - enter' );
        
        List<Common.FlowDefinition> flowDefinitionList = new List<Common.FlowDefinition>();
        try {
            List<FlowDefinitionView> flowDefinitionsViews = getActiveFlowDefinitions();

            if( flowDefinitionsViews.size() > 0 ) {
                
                // Create Flow wrapper for each Flow retrieved.
                for( FlowDefinitionView flowRecord : flowDefinitionsViews ) {
                    Common.FlowDefinition flowWrapper = createFlowDefinition( flowRecord );
                    flowDefinitionList.add(flowWrapper);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getAllActiveFlows() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllActiveFlows() : Retrieved all Flows' );
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
     * @returns Returns a FlowDefinition available for the user context.
     */
    public Common.FlowDefinition getFlowByApiName(final String flowApiName) {
        
        System.debug( LoggingLevel.DEBUG, 'getFlowByApiName() - enter; flowApiName=' + flowApiName );
        
        Common.FlowDefinition flowDefinition;

        try {

            if( String.isBlank(flowApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<FlowDefinitionView> flowDefinitionsViews = getFlowDefinitionByApiName( flowApiName );

            if ( flowDefinitionsViews.size() > 0 ) {
                flowDefinition = createFlowDefinition( flowDefinitionsViews.get(0) );
            }

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
     * This method is used to retrieve all profiles.
     */
    public List<Common.Profile> getAllProfiles() {
        
        List<Common.Profile> allProfiles = new List<Common.Profile>();
        
        try {
            List<Profile> profileList = SvmxDatabase.query( [SELECT Id, Name, Description, LastReferencedDate, LastViewedDate, UserLicenseId, UserType FROM Profile ORDER BY Name] );

            if( profileList.size() > 0 ) {
                
                // Create profile wrapper for each profile
                for( Profile profileRecord : profileList ) {
                    allProfiles.add( createProfile( profileRecord ) );
                }
            }            

        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllProfiles() : Failed to retrieve Profiles. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllProfiles() - exit; allProfiles.size()= ' + allProfiles.size() );
        }
        
        return allProfiles;
    }
    
    /**
     * This method is to create entity definition wrapper class for given describe object result.
     */
    @testVisible
    private Common.EntityDefinition createEntityDefinition( Schema.DescribeSobjectResult describeSobjectResult ) {
        
        Common.EntityDefinition entityDefinition = new Common.EntityDefinition();
        entityDefinition.label = describeSobjectResult.getLabel();
        entityDefinition.apiName = describeSobjectResult.getName();
        entityDefinition.custom = describeSobjectResult.isCustom();
        entityDefinition.recordTypeInfos = createRecordTypeDefinitions(describeSobjectResult.getRecordTypeInfos());
       
        return entityDefinition;
    }
    
    /**
     * This method is used to create field definition wrapper for given describe field result.
     */
     @testVisible
    private Common.FieldDefinition createFieldDefinition( final Schema.DescribeFieldResult describeFieldResult, final Boolean stripPicklistValues ) {
        
        Common.FieldDefinition fieldDefinition = new Common.FieldDefinition();
        
        fieldDefinition.label = describeFieldResult.getLabel();
        fieldDefinition.apiName =  describeFieldResult.getName();
        fieldDefinition.dataType = describeFieldResult.getType().name();
        fieldDefinition.custom = describeFieldResult.isCustom();
        fieldDefinition.localName = describeFieldResult.getLocalName();
        fieldDefinition.updateable = describeFieldResult.isUpdateable();
        fieldDefinition.createable = describeFieldResult.isCreateable();
        fieldDefinition.calculated = describeFieldResult.isCalculated();
        fieldDefinition.length = describeFieldResult.getLength();
        fieldDefinition.scale = describeFieldResult.getScale();
        fieldDefinition.digits = describeFieldResult.getDigits();
        fieldDefinition.filterable = describeFieldResult.isFilterable();
        fieldDefinition.idLookup = describeFieldResult.isIdLookup();
        fieldDefinition.unique = describeFieldResult.isUnique();
        fieldDefinition.nillable = describeFieldResult.isNillable();
        fieldDefinition.nameField = describeFieldResult.isNameField();
        fieldDefinition.autoNumber = describeFieldResult.isAutoNumber();
        fieldDefinition.precision = describeFieldResult.getPrecision();
        fieldDefinition.htmlFormatted = describeFieldResult.isHtmlFormatted();
        fieldDefinition.dependentPicklist = describeFieldResult.isDependentPicklist();
        fieldDefinition.compoundFieldName = describeFieldResult.getCompoundFieldName();
        if( describeFieldResult.getController() != null ) {
            
            final Schema.DescribeFieldResult controllerDescribeFieldResult = describeManager.getFieldDescribe(describeFieldResult.getController() );
            fieldDefinition.controllerFieldName =  controllerDescribeFieldResult.getName();
        }
        
        // Retrieve reference object for lookup fields.
        if( describeFieldResult.getType() == Schema.Displaytype.REFERENCE ) {
            
            fieldDefinition.relationshipName = describeFieldResult.getRelationshipName();
            if( describeFieldResult.getName().equalsIgnoreCase('OWNERID') ) {
                
                fieldDefinition.referenceTo = new List<String>{'User'};
            } else {
                fieldDefinition.referenceTo = createReferenceToList( describeFieldResult );
            }
            
            if( fieldDefinition.referenceTo != null && fieldDefinition.referenceTo.size() > 0 ) {
                fieldDefinition.referenceNameFields = getReferenceNameField( fieldDefinition.referenceTo );
            }
        // For picklist and multipicklist, retrieve picklist values
        } else if( describeFieldResult.getType() == Schema.Displaytype.PICKLIST || describeFieldResult.getType() == Schema.Displaytype.MULTIPICKLIST ) {
            if( !stripPicklistValues ) {
                fieldDefinition.picklistValues = createPicklistValues( describeFieldResult.getPicklistValues() );
            }
        }
        
        return fieldDefinition;
    }

    /**
     * Private method to create flow wrapper from FlowDefinitionView record.
     */
    private Common.FlowDefinition createFlowDefinition( FlowDefinitionView flowRec ) {
        
        Common.FlowDefinition flowWrapper = new Common.FlowDefinition();
        
        flowWrapper.activeVersionId = flowRec.ActiveVersionId;
        flowWrapper.apiName = flowRec.ApiName;
        flowWrapper.builder = flowRec.Builder;
        flowWrapper.description = flowRec.Description;
        flowWrapper.durableId = flowRec.DurableId;
        flowWrapper.installedPackageName = flowRec.InstalledPackageName;
        flowWrapper.isActive = flowRec.IsActive;
        flowWrapper.isOutOfDate = flowRec.IsOutOfDate;
        flowWrapper.isTemplate = flowRec.IsTemplate;
        flowWrapper.label = flowRec.Label;
        flowWrapper.latestVersionId = flowRec.LatestVersionId;
        flowWrapper.manageableState = flowRec.ManageableState;
        flowWrapper.namespacePrefix = flowRec.NamespacePrefix;
        flowWrapper.processType = flowRec.ProcessType;
        flowWrapper.triggerType = flowRec.TriggerType;
        return flowWrapper;
    }

    /**
     * Private method to create profile wrapper from profile record.
     */
    private Common.Profile createProfile( final Profile profileRecord ) {
        
        Common.Profile profileWrapper = new Common.Profile();
        
        profileWrapper.id = profileRecord.Id;
        profileWrapper.name = profileRecord.Name;
        profileWrapper.description = profileRecord.Description;
        profileWrapper.userType = profileRecord.UserType;
        profileWrapper.userLicenseId = profileRecord.UserLicenseId;
        profileWrapper.lastReferencedDate = profileRecord.LastReferencedDate;
        profileWrapper.lastViewedDate = profileRecord.LastViewedDate;
        
        return profileWrapper;
    }

     /**
     * Private method to create profile wrapper from profile record.
     */
    private List<Common.RecordTypeDefinition> createRecordTypeDefinitions(List<Schema.RecordTypeInfo> recordTypeInfos) {
        List<Common.RecordTypeDefinition> recordTypeWrappers = new List<Common.RecordTypeDefinition>();

        for(Schema.RecordTypeInfo recordTypeInfo : recordTypeInfos) {
            Common.RecordTypeDefinition recordTypeWrapper = new Common.RecordTypeDefinition();
            recordTypeWrapper.developerName = recordTypeInfo.getDeveloperName();
            recordTypeWrapper.name = recordTypeInfo.getName();
            recordTypeWrapper.recordTypeId = recordTypeInfo.getRecordTypeId();
            recordTypeWrapper.isActive = recordTypeInfo.isActive();
            recordTypeWrapper.isAvailable = recordTypeInfo.isAvailable();
            recordTypeWrapper.isDefaultRecordTypeMapping = recordTypeInfo.isDefaultRecordTypeMapping();
            recordTypeWrapper.isMaster = recordTypeInfo.isMaster();
            recordTypeWrappers.add(recordTypeWrapper);
        }
        return recordTypeWrappers;
    } 

    /**
     * This private method executes the query to return all the active flows 
     */
    private List<FlowDefinitionView> getActiveFlowDefinitions() {
        return SvmxDatabase.query([SELECT ActiveVersionId, ApiName, Builder, Description, DurableId,
                                    InstalledPackageName, IsActive, IsOutOfDate, IsTemplate,
                                    Label, LatestVersionId, ManageableState,
                                    NamespacePrefix, ProcessType, TriggerType
                                   FROM FlowDefinitionView WHERE isActive = TRUE AND ProcessType IN :allowedFlowProcessTypes AND TriggerType = null ORDER BY Label]);
    }

        /**
     * This private method executes the query to return all the active flows 
     */
    private List<FlowDefinitionView> getFlowDefinitionByApiName( final String apiName ) {
        return SvmxDatabase.query([SELECT ActiveVersionId, ApiName, Builder, Description, DurableId,
                                    InstalledPackageName, IsActive, IsOutOfDate, IsTemplate,
                                    Label, LatestVersionId, ManageableState,
                                    NamespacePrefix, ProcessType, TriggerType
                                   FROM FlowDefinitionView WHERE ApiName = :apiName AND isActive = TRUE AND ProcessType IN :allowedFlowProcessTypes AND TriggerType = null]);
    }

    /**
     * Attempts to find a FieldDefinition given an EntityDefinition, with support for alternative representations of field apis.
     * 
     * @param entityDefinition Entity definition on which to search for the target field
     * @param fieldApiName Field api name to search for. Can also be in the "relationship name" form
     * 
     * @return {Common.FieldDefinition} Returns a field definition instance that matches the given field api
     * 
     * @example findField(entityDef, 'Lookup__r') -> Common.FieldDefinition{apiName='Lookup__c'}
     * @example findField(entityDef, 'Lookup__c') -> Common.FieldDefinition{apiName='Lookup__c'}
     * @example findField(entityDef, 'Account') -> Common.FieldDefinition{apiName='AccountId'}
     * @example findField(entityDef, 'AccountId') -> Common.FieldDefinition{apiName='AccountId'}
     */
    private Common.FieldDefinition findField(final Common.EntityDefinition entityDefinition, final String fieldApiName) {
        Common.FieldDefinition fieldDefinition = null;

        if (entityDefinition != null && entityDefinition.fieldDefinitionsByApiName != null || String.isBlank(fieldApiName)) {

            // First, attempt a direct name match
            fieldDefinition = entityDefinition.fieldDefinitionsByApiName.get(fieldApiName.toLowerCase());

            // Second, assume the api name is in the "relationsihp name" form, resolve it to its field Api name, and try again
            if (fieldDefinition == null) {
                fieldDefinition = entityDefinition.fieldDefinitionsByApiName.get(
                    describeManager.resolveToFieldName(fieldApiName).toLowerCase()
                );
            }
        }

        return fieldDefinition;
    }
    
    /**
     * This method retrieves LWC details exposed in org 
     * * @return Returns LWCRecord instance with list of LWC Details.
     */
    public List<String> getAllReferencedEntities(String referenceEntityName){
        List<String> entities = new List<String>();
        try{
            String queryString = 'select id, ChildSobject.DeveloperName, durableid from relationshipdomain where ParentSobject.DeveloperName = \''+String.escapeSingleQuotes(referenceEntityName)+'\'';

            String response = callToolingAPIWithQuery(queryString);
            if( response != null ) {
                for(SvmxReferencedEntity data: ((SvmxReferencedEntityResponse) JSON.deserialize(response, SvmxReferencedEntityResponse.class))?.records) {
                    String entityName = data?.childSobject?.developerName;
                    if(String.isNotBlank(entityName) 
                        && !Common.BlacklistCustomObjects.contains( entityName.toLowerCase() ) 
                        && !entityName.endsWithIgnoreCase('ChangeEvent') 
                        && !entityName.endsWithIgnoreCase('Share') 
                        && !entityName.endsWithIgnoreCase('History')
                        ) {
                        entities.add(entityName);
                    }
                }
                System.debug(entities);
            }
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getAllEntitiesWithReference() : Failed to retrieve getAllEntitiesWithReference. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitiesWithReference() - exit;' );
        }
        return entities;
    }
    /**
     * Private method to retrieve name fields for referenceTo objects.
     * 
     * @param referenceTo List of reference object name for which field name to be retrieved.
     * 
     * @return Returns list of name field names for requested objects.
     */
    private List<String> getReferenceNameField( final List<String> referenceTo ) {
        
        System.debug( LoggingLevel.DEBUG, 'getReferenceNameField() - enter; referenceTo= ' + referenceTo );
        
        List<String> referenceNameFields = new List<String>();
        
        try {
            
            Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = describeManager.getObjectDescribe( referenceTo );
            for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultMap.values() ) {
                
                Map<String, Schema.SObjectField> sObjectFieldMap = describeSobjectResult.fields.getMap();
                for( Schema.SObjectField sObjectField : sObjectFieldMap.values() ) {
                    
                    // Field describe for each field available in the entity.
                    final Schema.DescribeFieldResult describeFieldResult = describeManager.getFieldDescribe( sObjectField );
                    if( describeFieldResult.isNameField() ) {
                        
                        referenceNameFields.add( describeFieldResult.getName() );
                        break;
                    }                 
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getReferenceNameField() : Failed to retrieve reference name field. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getReferenceNameField() - exit' );
        }
        
        return referenceNameFields;
    }

     /**
     * This method retrieves LWC details exposed in org 
     * * @return Returns LWCRecord instance with list of LWC Details.
     */
    public List<Common.QuickActionDefinition> getQuickActionDefinition(String actionName){
        
        System.debug( LoggingLevel.DEBUG, 'getQuickActionDefinition() - enter'); 
        Common.QuickActionDefinitionDetails quickActionResponse = null;
        List<Common.QuickActionDefinition> quickActionList = null;
        try{
            List<String> actionNames = actionName.split('\\.');

            String queryString = 'SELECT Id, Label, DeveloperName, Type, TargetSobjectType FROM QuickActionDefinition WHERE DeveloperName = \''+String.escapeSingleQuotes(actionNames[actionNames.size()-1])+'\'';

            String response = callToolingAPIWithQuery(queryString);
            if( response != null ) {
                 quickActionResponse = (Common.QuickActionDefinitionDetails) System.JSON.deserialize(response, Common.QuickActionDefinitionDetails.class);
            }
            if(quickActionResponse != null && quickActionResponse.records != null && !quickActionResponse.records.isEmpty()) {    
                quickActionList = quickActionResponse.records;
            }
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getQuickActionDefinition() : Failed to retrieve QuickActionDefinition. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQuickActionDefinition() - exit;' );
        }

        return quickActionList;
    }

    /**
     * This method retrieves LWC details exposed in org
     * * @return Returns LWCRecord instance with list of LWC Details.
     */
    public List<Common.LWCRecord> getLWCComponentDetails( final String objectAPIName ){
        
        System.debug( LoggingLevel.DEBUG, 'getLWCComponentDetails() - enter');
        
        try{
    
            if (lwcRecordList.isEmpty()) {
    
                String lwcBundlequeryString = 'SELECT Id, DeveloperName, IsExposed, MasterLabel, NamespacePrefix, TargetConfigs FROM LightningComponentBundle WHERE IsExposed = true';
                
                lwcRecordList = getLWCDefinitionByQuery( lwcBundlequeryString );
                
            }
    
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getLWCComponentDetails() : Failed to retrieve LWC components. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLWCComponentDetails() - exit; lwcRecordList size = ' + lwcRecordList.size() );
        }
    
        return lwcRecordList;
    }

    /**
     * This method is used to retrieve a single LWC detail using the API Name parameter.
     * @param lwcApiName The apiName of the LWC.
     * @returns Returns a FlowDefinition available for the user context.
     */
    public Common.LWCRecord getLWCDetailsByApiName(final String lwcApiName) { 
        
        System.debug( LoggingLevel.DEBUG, 'getLWCDetailsByApiName() - enter; lwcApiName=' + lwcApiName );
        
        Common.LWCRecord lwcRecord;

        try {

            if( String.isBlank(lwcApiName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            String queryString = 'SELECT Id, DeveloperName, FullName, IsExposed, MasterLabel, NamespacePrefix FROM LightningComponentBundle WHERE DeveloperName = \'' + lwcApiName + '\'';
            lwcRecord = getLWCDefinitionByQuery( queryString )[0];

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getLWCDetailsByApiName() : Failed to retrieve a LWC Definition. SvmxNestedException Error= ' + e.getMessage() );
            throw e;
        }        
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getLWCDetailsByApiName() : Failed to retrieve a LWC Definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLWCDetailsByApiName() - exit; lwcRecord= ' + lwcRecord );
        }
        
        return lwcRecord;
    }

    /**
     * This private method executes the query to return LWC record Definition
     */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    private List<Common.LWCRecord> getLWCDefinitionByQuery( final String query ) { 
        System.debug( LoggingLevel.DEBUG, 'getLWCDefinitionByQuery() - enter'); 

        List<Common.LWCRecord> lwcRecordList = new List<Common.LWCRecord>();
        
        try{
            String response = callToolingAPIWithQuery(query);
            System.debug( LoggingLevel.DEBUG, 'response :' + response);
            Common.LWCRecordDetails lwcResponse = new Common.LWCRecordDetails();
            if( response != null ) {
                lwcResponse = (Common.LWCRecordDetails) System.JSON.deserialize(response, Common.LWCRecordDetails.class);
            }
            if(lwcResponse != null && lwcResponse.records != null && !lwcResponse.records.isEmpty()) {    
                lwcRecordList = lwcResponse.records;
            }
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getLWCDefinitionByQuery() : Failed to retrieve LWC components. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLWCDefinitionByQuery() - exit; lwcRecordList size = ' + lwcRecordList.size());
        }

        return lwcRecordList;
    }

    private List<Common.LWCResource> getLWCResourceByQuery( final String query ) { 
        System.debug( LoggingLevel.DEBUG, 'getLWCResourceByQuery() - enter'); 

        List<Common.LWCResource> lwcRecordList = new List<Common.LWCResource>();
        
        try{
            String response = callToolingAPIWithQuery(query);
            System.debug( LoggingLevel.DEBUG, 'response :' + response);
            Common.LWCResourceDetails lwcResponse = new Common.LWCResourceDetails();
            if( response != null ) {
                lwcResponse = (Common.LWCResourceDetails) System.JSON.deserialize(response, Common.LWCResourceDetails.class);
            }
            if(lwcResponse != null && lwcResponse.records != null && !lwcResponse.records.isEmpty()) {    
                lwcRecordList = lwcResponse.records;
            }
            
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getLWCResourceByQuery() : Failed to retrieve LWC components. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getLWCResourceByQuery() - exit; lwcRecordList size = ' + lwcRecordList.size());
        }

        return lwcRecordList;
    }

    /**
     * This method executes the query to return component dependency details
     */

    public List<Common.ComponentDependency> getComponentDependencyDetails( final String query ) { 
        System.debug( LoggingLevel.DEBUG, 'getComponentDependencyDetails() - enter'); 

        List<Common.ComponentDependency> componentDependencyList = new List<Common.ComponentDependency>();
        
        try{
            String response = callToolingAPIWithQuery(query);
            System.debug( LoggingLevel.DEBUG, 'response :' + response);
            Common.ComponentDependencyDetails componentDependencyResponse = new Common.ComponentDependencyDetails();
            if( response != null ) {
                componentDependencyResponse = (Common.ComponentDependencyDetails) System.JSON.deserialize(response, Common.ComponentDependencyDetails.class);
            }
            if(componentDependencyResponse != null && componentDependencyResponse.records != null && !componentDependencyResponse.records.isEmpty()) {    
                componentDependencyList = componentDependencyResponse.records;
            }
            
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getComponentDependencyDetails() : Failed to retrieve component dependencies. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getComponentDependencyDetails() - exit; componentDependencyList size = ' + componentDependencyList.size());
        }

        return componentDependencyList;
    }

    /**
     * This method executes the query to return component dependency details
     */

    public List<Common.RemoteSiteSettings> getRemoteSiteSettingsDetails( final String query ) { 
        System.debug( LoggingLevel.DEBUG, 'getRemoteSiteSettingsDetails() - enter'); 

        List<Common.RemoteSiteSettings> remoteSiteSettingsList = new List<Common.RemoteSiteSettings>();
        
        try{
            String response = callToolingAPIWithQuery(query);
            System.debug( LoggingLevel.DEBUG, 'response :' + response);
            Common.RemoteSiteSettingsDetails remoteSiteSettingsResponse = new Common.RemoteSiteSettingsDetails();
            if( response != null ) {
                remoteSiteSettingsResponse = (Common.RemoteSiteSettingsDetails) System.JSON.deserialize(response, Common.RemoteSiteSettingsDetails.class);
            }
            if(remoteSiteSettingsResponse != null && remoteSiteSettingsResponse.records != null && !remoteSiteSettingsResponse.records.isEmpty()) {    
                remoteSiteSettingsList = remoteSiteSettingsResponse.records;
            }
            
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getRemoteSiteSettingsDetails() : Failed to retrieve component dependencies. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRemoteSiteSettingsDetails() - exit; remoteSiteSettingsList size = ' + remoteSiteSettingsList.size());
        }

        return remoteSiteSettingsList;
    }

    /**
     * This method executes the query to return flexi page details
     */

    public List<Common.FlexiPageRecord> getFlexiPageDetails( final String query ) { 
        System.debug( LoggingLevel.DEBUG, 'getFlexiPageDetails() - enter'); 

        List<Common.FlexiPageRecord> flexiPageList = new List<Common.FlexiPageRecord>();
        
        try{
            String response = callToolingAPIWithQuery(query);
            System.debug( LoggingLevel.DEBUG, 'response :' + response);
            Common.FlexiPageRecords flexiPageRecords = new Common.FlexiPageRecords();
            if( response != null ) {
                flexiPageRecords = (Common.FlexiPageRecords) System.JSON.deserialize(response, Common.FlexiPageRecords.class);
            }
            if(flexiPageRecords != null && flexiPageRecords.records != null && !flexiPageRecords.records.isEmpty()) {    
                flexiPageList = flexiPageRecords.records;
            }
            
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getFlexiPageDetails() : Failed to retrieve flexi page list. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFlexiPageDetails() - exit; flexiPageList size = ' + flexiPageList.size());
        }

        return flexiPageList;
    }

        /**
     * This method executes the query to return flow details
     */

    public List<Common.FlowRecord> getFlowDetails( final String query ) { 
        System.debug( LoggingLevel.DEBUG, 'getFlowDetails() - enter'); 

        List<Common.FlowRecord> flowList = new List<Common.FlowRecord>();
        
        try{
            String response = callToolingAPIWithQuery(query);
            System.debug( LoggingLevel.DEBUG, 'response :' + response);
            Common.FlowRecords flowRecords = new Common.FlowRecords();
            if( response != null ) {
                flowRecords = (Common.FlowRecords) System.JSON.deserialize(response, Common.FlowRecords.class);
            }
            if(flowRecords != null && flowRecords.records != null && !flowRecords.records.isEmpty()) {    
                flowList = flowRecords.records;
            }
            
        }catch( Exception e ){
            System.debug( LoggingLevel.ERROR, 'getFlowDetails() : Failed to retrieve flexi page list. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFlowDetails() - exit; flowList size = ' + flowList.size());
        }

        return flowList;
    }
    
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred') 
    private String callToolingAPIWithQuery(String query) {
        
        System.debug( LoggingLevel.DEBUG, 'callToolingAPIWithQuery() - enter' );
        
        String response  ='{}';
        try {
            String sessionId = !Test.isRunningTest()
                ? Page.COMM_AccessProvider.getContent().toString()
                : '';
            Http httpConnect = new Http();
            HttpRequest queryReq = new HttpRequest();
            
            queryReq.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v57.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
            queryReq.setHeader('Authorization', 'OAuth ' + sessionId.trim() );
            queryReq.setHeader('Content-Type', 'application/json');
            queryReq.setTimeout(110000);
            queryReq.setMethod('GET');
            
            HttpResponse queryRes = httpConnect.send(queryReq);
            response = queryRes.getBody();
        }
        catch(System.CalloutException ex) {
            System.debug( LoggingLevel.ERROR, 'callToolingAPIWithQuery() : Failed to invoke tooling query. Error: ' + ex.getMessage() );
        }
        catch(Exception ex) {
            System.debug( LoggingLevel.ERROR, 'callToolingAPIWithQuery() : Failed to invoke tooling query. Error: ' + ex.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'callToolingAPIWithQuery() - exit; response : ' + response );
        }
        
        return response;
    }
    
    /**
     * Private method to retrieve and create picklist value wrapper.
     */
    @testVisible
    private List<Common.PicklistValue> createPicklistValues( List<Schema.PickListEntry> picklistEntries ) {
        
        List<Common.PicklistValue> picklistValues = new List<Common.PicklistValue>();
        
        for( Schema.PickListEntry pickListEntry : picklistEntries ) {
            
            if( pickListEntry.isActive() ){
                
                Common.PicklistValue picklistValue = new Common.PicklistValue();
                picklistValue.label = pickListEntry.getLabel();
                picklistValue.value = pickListEntry.getValue();
                
                picklistValues.add( picklistValue );
            }
        }

        return picklistValues;
    }
    
    /**
     * This method is used to create reference list for lookup fiels.
     */
    @testVisible
    private List<String> createReferenceToList( final Schema.DescribeFieldResult describeFieldResult ) {
        
        List<String> referenceToList = new List<String>();
        
        final List<Schema.SObjectType> sObjectTypeList = describeFieldResult.getReferenceTo();
        
        for( Schema.SObjectType sObjectType : sObjectTypeList ) {
            referenceToList.add( String.valueOf(sObjectType) );
        }
        
        return referenceToList;
    }
    
    /**
     * Private constructor to restrict multiple instance of this class per transaction.
     */
    private COMM_MetadataManager() {
    }

    @AuraEnabled (cacheable=true)
    public static string getEntityDefinitionId (String objectApiName){
        try {
            if(String.isEmpty(objectApiName)){
                System.debug( LoggingLevel.ERROR, 'getEntityDefinitionId() : Invalid request parameters. objectAPIName= ' + objectAPIName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            List <SObject> entityDefinitions =  svmxDatabase.query([SELECT DurableId FROM EntityDefinition WHERE QualifiedApiName =:objectAPIName]);
            if(entityDefinitions != null && ! entityDefinitions.isEmpty()){
                return (String)entityDefinitions[0].get('DurableId');
            }        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    class SvmxReferencedEntity {
        public SvmxReferencedEntityAttributes attributes{get;set;} 
        public String id{get;set;} 
        public SvmxReferencedSobjectEntity childSobject{get;set;} 
        public String durableId{get;set;} 
    }

    class SvmxReferencedEntityAttributes {
        public String type{get;set;} 
        public String url{get;set;} 
    }

    class SvmxReferencedSobjectEntity {
        public SvmxReferencedEntityAttributes attributes{get;set;} 
        public String developerName{get;set;} 
        public String label{get;set;}
    }
    class SvmxReferencedEntityResponse {       
        public List<SvmxReferencedEntity> records{get;set;}
    }
}