/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A Singleton class which provides utility methods to retrieve object 
 * and field describe informations.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       07 May 2020     Created.
 * A360ADM-453  Ramachandra Mohan       28 Oct 2020     Removed isUpdateable check for object & field describe.
 * A360ENG-886  Jason Bradley           25 Feb 2021     Added resolveToRelationshipName and resolveToFieldName.
 * A360AM-572   Manish Kushwah          21 May 2021     Added getObjectDescribeById method
 *****************************************************************************************************/
public with sharing class COMM_DescribeManager {

    /**
     * A private static variable to hole instance for this class.
     */
    private static COMM_DescribeManager instance;
    
    /**
     * Private instance variable to hold global describe results.
     */
    private Map<String, Schema.SObjectType> sObjectTypeMap;

    /**
     * Private instance variable to hold all global describe results.
     */
    private List<Common.EntityDetails> entityDetails;
    
    /**
     * Private instance variable to hold object describe results.
     */
    private Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap;
    
    /**
     * Private instance variable to hold field describe for each object.
     */
    private Map<String, Map<String, DescribeFieldResult>> describeFieldResultMap;
    
    /**
     * A static method to get instance of this class.
     */
    public static COMM_DescribeManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'COMM_DescribeManager.getInstance() - enter' );
        
        try {
            
            // Create instance of this class only if its not exists.
            if( instance == null ) {
                
           		instance = new COMM_DescribeManager();
                System.debug( LoggingLevel.DEBUG, 'COMM_DescribeManager.getInstance() : Instance created successfully');
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'COMM_DescribeManager.getInstance() - exit' );
        }
        
        return instance;
    }
    
    /**
     * This method is used to perform global describe and retrieve all 
     * sobject types in the Org.
     */
    public Map<String, Schema.SObjectType> getGlobalDescribe() {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalDescribe() - enter' );
        
        try {
            /*
             * Perform global describe once per transaction or if the caller is a batch class. 
             * The batch classes are long running process in the background. It would be good 
             * to perform global describe every time the method is called by any batch classes.
             */
            if( sObjectTypeMap.size() == 0 || System.isBatch() ) {
                
                Map<String, Schema.SObjectType> allSObjectTypeMap = Schema.getGlobalDescribe();
                for( String objectName : allSObjectTypeMap.keySet() ) {
                    
                    if( Common.WhitelistStandardObjects.contains(objectName.toLowerCase()) || ( objectName.endsWithIgnoreCase('__c') && !Common.BlacklistCustomObjects.contains( objectName.toLowerCase() ) ) ) {
                        sObjectTypeMap.put(objectName, allSObjectTypeMap.get(objectName) );
                    }
                }
                
                System.debug( LoggingLevel.INFO, 'getGlobalDescribe() : Performed global describe.' );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGlobalDescribe() : Failed to perform global describe. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGlobalDescribe() - exit' );
        }
                
        return sObjectTypeMap;
    }

    /**
     * This method is used to perform global describe and retrieve all 
     * sobject types in the Org except blacklist objects.
     */

    public List<Common.EntityDetails> getAllGlobalDescribe() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllGlobalDescribe() - enter' );
        
        try {
            /*
             * Perform global describe once per transaction or if the caller is a batch class. 
             * The batch classes are long running process in the background. It would be good 
             * to perform global describe every time the method is called by any batch classes.
             */
            if( entityDetails.size() == 0 || System.isBatch() ) {
                
                Map<String, Schema.SObjectType> allSObjectTypeMap = Schema.getGlobalDescribe();
                for( String objectName : allSObjectTypeMap.keySet() ) {
                    Schema.SObjectType objectNameAPINAme = allSObjectTypeMap.get(objectName);
                    Common.EntityDetails entityDetail = new Common.EntityDetails();
                    if( !Common.BlacklistCustomObjects.contains( objectName.toLowerCase() ) &&
                        !objectName.endsWithIgnoreCase('ChangeEvent') &&
                        !objectName.endsWithIgnoreCase('Share') &&
                        !objectName.endsWithIgnoreCase('History') ) {
                        Schema.DescribeSObjectResult objResult = objectNameAPINAme.getDescribe();
                        entityDetail.objectAPIName = objResult.getName();
                        entityDetail.objectLabel = objResult.getLabel();
                        entityDetails.add(entityDetail);
                    }
                }
                
                System.debug( LoggingLevel.INFO, 'getAllGlobalDescribe() : Performed global describe.' );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllGlobalDescribe() : Failed to perform global describe. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllGlobalDescribe() - exit' );
        }
                
        return entityDetails;
    }

    /**
     * This method is used to retrieve object describe result for given Salesforce record Id.
     */
    public Schema.DescribeSobjectResult getObjectDescribeById( final String recordId ) {

        System.debug( LoggingLevel.DEBUG, 'getObjectDescribeById() - enter; recordId= ' + recordId );
        
        Schema.DescribeSobjectResult describeSobjectResult;

        try {
            // Check for valid argument
            if( String.isBlank( recordId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectDescribeById() : Invalid argument; recordId= ' + recordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            final String objectName = String.valueOf( ( (Id) recordId ).getSobjectType() );
            describeSobjectResult = getObjectDescribe(objectName);
            
            System.debug( LoggingLevel.INFO, 'getObjectDescribeById() : Retrieved object describe for recordId= ' + recordId );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribeById() : Failed to perform object describe. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribeById() : Failed to perform object describe. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectDescribeById() - exit');
        }
        
        return describeSobjectResult;
    }
    
    /**
     * This method is used to retrieve object describe result for given object API name.
     */
    public Schema.DescribeSobjectResult getObjectDescribe( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectDescribe() - enter; objectName= ' + objectName );
        
        Schema.DescribeSobjectResult describeSobjectResult;
        
        try {
            // Check for valid argument
            if( String.isBlank( objectName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Invalid argument; objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Perform object describe if its not already performed.
            if( !describeSobjectResultMap.containsKey(objectName) ) {
                
                final SObjectType sObjectType = sObjectTypeMap.get(objectName);
                if( sObjectType == null ) {
                    
                    System.Type objectType = Type.forName( 'Schema.' + objectName );
                    if( objectType == null ) {
                        
                        System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Object not visible or not exists; objectName= ' + objectName );
                        throw new SvmxSystem.SvmxNestedException(String.format(
                            ErrorMessage.OBJECT_INACCESSIBLE_OR_NOT_EXISTS,
                            new List<String> { objectName }
                        ));
                    }
                    // get sObjectType for given object name.
                	sObjectType = ( (SObject) objectType.newInstance() ).getSObjectType();
                }
                
                describeSobjectResultMap.put( objectName, sObjectType.getDescribe() );
            }
            
            describeSobjectResult = describeSobjectResultMap.get(objectName);
            
            System.debug( LoggingLevel.INFO, 'getObjectDescribe() : Retrieved object describe for ' + objectName );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Failed to perform object describe. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Failed to perform object describe. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectDescribe() - exit');
        }
        
        return describeSobjectResult;
    }
    
    /**
     * This method is used to retrieve object describe for list of object names.
     */
    public Map<String, Schema.DescribeSobjectResult> getObjectDescribe( final List<String> objectNameList ) {
        
        System.debug(LoggingLevel.DEBUG, 'getObjectDescribe() - enter; objectNameList=' + objectNameList );
        
        final Map<String, Schema.DescribeSobjectResult> describeSobjectResultSubMap = new Map<String,Schema.DescribeSobjectResult>();
        
        try {
            
            if( objectNameList == null || objectNameList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Invalid argument; objectNameList= ' + objectNameList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
                
            final List<String> describeApiList = new List<String>();
            // Get all available describe results
            for( String objectName : objectNameList ) {
                
                if( !describeSobjectResultMap.containsKey(objectName) ) {
                    describeApiList.add(objectName);
                } else {
                    describeSobjectResultSubMap.put(objectName, describeSobjectResultMap.get(objectName) );
                }
            }
            // Perform object describe for those which are not exists in the instance map.
            if( !describeApiList.isEmpty() ) {
                
                // Populate the object describe result in both instance map variable and return value map.
                for( String objectName : describeApiList ) {
                    
                    Schema.DescribeSobjectResult result = getObjectDescribe( objectName );
                    
                    describeSobjectResultSubMap.put( result.getName(), result);
                    describeSobjectResultMap.put(result.getName(), result);
                }
            }
            
            System.debug( LoggingLevel.INFO, 'getObjectDescribe() : Retrieved object describes for requested objects.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Failed to perform object describe. Error= ' + e.getMessage() );
            throw e;
        }
        catch(Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'Failed to perform object describe. Error=' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug(LoggingLevel.DEBUG,'getObjectDescribe() - exit');
        }
        
        return describeSobjectResultSubMap;
    }
    
    /**
     * This method is used to retrieve list of fields for given object.
     */
    public Map<String, Schema.SObjectField> getObjectFieldMap( final String objectName ) {
        
        System.debug(LoggingLevel.DEBUG, 'getObjectFieldMap() - enter; objectName=' + objectName );
        
        Map<String, Schema.SObjectField> sObjectFieldMap;
        
        try {
            
            if( String.isBlank(objectName) ) {
           
                System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Invalid argument; objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve describe result and get the fields for requested object name
            Schema.DescribeSobjectResult describeSobjectResult = getObjectDescribe(objectName );
            sObjectFieldMap = describeSobjectResult.fields.getMap();
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug(LoggingLevel.ERROR, 'getObjectFieldMap() : Failed to describe object. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getObjectFieldMap() : Failed to describe object. Error=' + e.getStackTraceString() );
            throw  e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectFieldMap() - exit' );
        }
        
        return sObjectFieldMap;
    }
    
    public Map<String, Schema.DescribeFieldResult> getFieldDescribeResults( final String objectName ) {
        
        System.debug(LoggingLevel.DEBUG, 'getFieldDescribeResults() - enter; objectName=' + objectName );
        
        Map<String, Schema.DescribeFieldResult> newDescribeFieldResultMap;
        
        try {
            
            if( String.isBlank(objectName) ) {
           
                System.debug( LoggingLevel.ERROR, 'getFieldDescribeResults() : Invalid argument; objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            newDescribeFieldResultMap = getFieldDescribeResults( new List<String>{objectName}).get(objectName);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug(LoggingLevel.ERROR, 'getFieldDescribeResults() : Failed to retrieve field describe list. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getFieldDescribeResults() : Failed to retrieve field describe list. Error=' + e.getStackTraceString() );
            throw  e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDescribeResults() - exit' );
        }
        
        return newDescribeFieldResultMap;
    }
    
    public Map<String, Map<String,Schema.DescribeFieldResult>> getFieldDescribeResults( final List<String> objectAPINames ) {
        
        System.debug(LoggingLevel.DEBUG, 'getFieldDescribeResults() - enter; objectAPINames=' + objectAPINames );
        
        Map<String, Map<String,Schema.DescribeFieldResult>> describeFieldResultListMap = new Map<String, MAp<String,Schema.DescribeFieldResult>>();
        
        try {
            
            if( objectAPINames == null || objectAPINames.size() == 0 ) {
           
                System.debug( LoggingLevel.ERROR, 'getFieldDescribeResults() : Invalid argument; objectAPINames= ' + objectAPINames );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            Map<String, Schema.DescribeSobjectResult> describeSobjectResultMap = getObjectDescribe( objectAPINames );
            for( Schema.DescribeSobjectResult describeSobjectResult : describeSobjectResultMap.values() ) {
                
                if( describeSobjectResult.isAccessible() && describeSobjectResult.isQueryable() ) {
                    
                    if( !describeFieldResultMap.containsKey( describeSobjectResult.getName() ) ) {
                        
                        final Map<String, Schema.SObjectField> sObjectFieldMap = getObjectFieldMap( describeSobjectResult.getName() );
                    
                        for( Schema.SObjectField sObjectField : sObjectFieldMap.values() ) {
                            
                            // Field describe for each field available in the entity.
                            final Schema.DescribeFieldResult describeFieldResult = getFieldDescribe( sObjectField );
                            if( !describeFieldResultListMap.containsKey( describeSobjectResult.getName() ) ) {
                                describeFieldResultListMap.put( describeSobjectResult.getName(), new Map<String,Schema.DescribeFieldResult>() );
                            }
                            
                            describeFieldResultListMap.get(describeSobjectResult.getName()).put(describeFieldResult.getName(), describeFieldResult);
                        }
                        
                        describeFieldResultMap.put( describeSobjectResult.getName(), describeFieldResultListMap.get( describeSobjectResult.getName() ) );
                    } else {
                        describeFieldResultListMap.put(describeSobjectResult.getName(), describeFieldResultMap.get( describeSobjectResult.getName() ) );
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug(LoggingLevel.ERROR, 'getFieldDescribeResults() : Failed to retrieve field describe list. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getFieldDescribeResults() : Failed to retrieve field describe list. Error=' + e.getStackTraceString() );
            throw  e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFieldDescribeResults() - exit' );
        }
        
        return describeFieldResultListMap;
    }
    
    /**
     * This method is used to perform field describe for given sObjectField.
     */
    public Schema.DescribeFieldResult getFieldDescribe( final Schema.SObjectField sObjectField ) {
        
        System.debug(LoggingLevel.FINEST, 'getFieldDescribe() - enter; sObjectField= ' + sObjectField );
        
        Schema.DescribeFieldResult describeFieldResult = null;
        
        try {
            
            if( sObjectField == null ) {
                
                System.debug(LoggingLevel.ERROR, 'getFieldDescribe() : Invalid argument. sObjectField=' + sObjectField );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            describeFieldResult = sObjectField.getDescribe();
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug(LoggingLevel.ERROR, 'getFieldDescribe() : Failed to describe field. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug(LoggingLevel.ERROR, 'getFieldDescribe() : Failed to describe field. Error=' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug(LoggingLevel.FINEST, 'getFieldDescribe() - exit' );
        }
        
        return describeFieldResult;
    }

    /**
     * This method is used to retrieve all Quick Actions by Object Name
     * 
     * @returns Returns list of Quick Action definitions available for user context.
     */
    public List<Common.QuickActionDefinition> getAllQuickActionsByObjectName(final String objectName) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - enter' );
        
        List<Common.QuickActionDefinition> actionDefinitionList = new List<Common.QuickActionDefinition>();
        try {
            if( String.isBlank( objectName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<QuickAction.DescribeAvailableQuickActionResult> actions = QuickAction.DescribeAvailableQuickActions(objectName); 
            if( actions.size() > 0 ) {
                // Create QuickAction wrapper for each QuickAction retrieved.
                for( QuickAction.DescribeAvailableQuickActionResult action : actions ) {
                    if( action.getType().equals('Create') || action.getType().equals('Update') ) {
                        Common.QuickActionDefinition actionWrapper = createActionDefinition( action );
                        actionDefinitionList.add(actionWrapper);
                    }
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            
            System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() : Retrieved all QuickActions' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Failed to retrieve QuickAction definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllQuickActionsByObjectName() : Failed to retrieve QuickAction definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllQuickActionsByObjectName() - exit; actionDefinitionList.size()= ' + actionDefinitionList.size() );
        }
        
        return actionDefinitionList;
    }

    /**
     * This method is used to retrieve a Quick Action by a list of Api Names
     * 
     * @returns Returns a Quick Action definition available for user context.
     */
    public Common.QuickActionDefinition getQuickActionsByApiName(final String objectName, final string apiName) {
        
        System.debug( LoggingLevel.DEBUG, 'getQuickActionByApiName() - enter' );
        
        Common.QuickActionDefinition actionDefinition = new Common.QuickActionDefinition();
        try {
            if( String.isBlank(objectName) || String.isBlank(apiName) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<QuickAction.DescribeAvailableQuickActionResult> actions = QuickAction.DescribeAvailableQuickActions(objectName); 
            
            if( actions.size() > 0 ) {
                // Create QuickAction wrapper for each QuickAction retrieved.
                for( QuickAction.DescribeAvailableQuickActionResult action : actions ) {
                    if(action.name == apiName) {
                        actionDefinition = createActionDefinition( action );
                        break;
                    }
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'getQuickActionByApiName() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            if(actionDefinition.name == null) {
                System.debug( LoggingLevel.ERROR, 'getQuickActionByApiName() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            
            System.debug( LoggingLevel.DEBUG, 'getQuickActionByApiName() : Retrieved all QuickActions' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQuickActionByApiName() : Failed to retrieve QuickAction definitions. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getQuickActionByApiName() : Failed to retrieve QuickAction definitions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQuickActionByApiName() - exit; actionDefinition ' + actionDefinition);
        }
        
        return actionDefinition;
    }

    /**
     * This method is used to get the query field with relationship name for lookup name fields.
     * Ex. Service_Order__r.Name
     */
    public String getReferenceNameField( final Schema.DescribeFieldResult describeFieldResult ){
        
        System.debug(LoggingLevel.FINEST, 'getReferenceNameField() - enter; describeFieldResult= ' + describeFieldResult );
        
        String referenceTo = describeFieldResult.getName().equalsIgnoreCase('OWNERID')? 'User' : String.valueOf(describeFieldResult.getReferenceTo()[0]);
        String relationshipName = describeFieldResult.getRelationshipName();
        String referenceNameField = 'Name';
        Schema.DescribeSobjectResult describeSobjectResult = getObjectDescribe( referenceTo );
        Map<String, Schema.SObjectField> sObjectFieldMap = describeSobjectResult.fields.getMap();
        
        for( Schema.SObjectField sObjField : sObjectFieldMap.values() ){
            Schema.DescribeFieldResult fieldRes = sObjField.getDescribe();
            if(fieldRes.isNameField()){
                referenceNameField = fieldRes.getName();
                break;
            }            
        }
        
        return relationshipName + '.' + referenceNameField;
    }

    /**
     * Converts a field api name in its "relationship" form to it's raw field api.
     * 
     * @param relationshipName Api name of the target field, in the "relationship" form.
     * 
     * @return Raw field api name
     * 
     * @example resolveToFieldName('Lookup__r') == 'Lookup__c'
     * @example resolveToFieldName('Account') == 'AccountId'
     */
    public String resolveToFieldName (String relationshipName) {
        String fieldName = relationshipName != null ? relationshipName : '';

        // Resolve custom field relationship name to field name
        if (fieldName.endsWithIgnoreCase('__r')) {
            fieldName = fieldName.replaceAll('(?i)__r$', '__c');
        }

        // Resolve standard field relationship name to field name
        if (!fieldName.endsWithIgnoreCase('__c')) {
            fieldName += 'Id';
        }

        return fieldName;
    }

    /**
     * Converts a field api name in its raw form to its "relationship" form.
     * 
     * @param fieldName Api name of the target field, in the raw form.
     * 
     * @return Field api name in the "relationship" form
     * 
     * @example resolveToRelationshipName('Lookup__c') == 'Lookup__r'
     * @example resolveToRelationshipName('AccountId') == 'Account'
     */
    public String resolveToRelationshipName (String fieldName) {
        String relationshipName = fieldName != null ? fieldName : '';

        // Resolve custom field name to relationship name
        if (relationshipName.endsWithIgnoreCase('__c')) {
            relationshipName = relationshipName.replaceAll('(?i)__c$', '__r');
        }

        // Resolve standard field name to relationship name
        if (relationshipName.endsWithIgnoreCase('Id')) {
            relationshipName = relationshipName.replaceAll('(?i)Id$', '');
        }

        return relationshipName;
    }

    public List<String> getNameFields(final String objectName) {
        System.debug(LoggingLevel.FINEST, 'getNameField() - enter; objectName= ' + objectName);
            
        if (String.isBlank(objectName)) {
            System.debug(LoggingLevel.ERROR, 'getNameField() : Invalid argument; objectName= ' + objectName);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.INVALID_ARGUMENT);
        }

        System.Type objectType = Type.forName('Schema', objectName);
        Schema.SObjectType sObjectType = ((SObject)objectType.newInstance()).getSObjectType();
        if (sObjectType == null) {
            System.debug(LoggingLevel.ERROR, 'getNameField() : Object not visible or does not exist; objectName= ' + objectName);
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.OBJECT_NOT_EXISTS);
        }

        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = sObjectDescribe.fields.getMap();

        List<String> nameFields = new List<String>();
        for (Schema.SObjectField sObjectField : fields.values()) {
            Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
            if (fieldDescribe.isNameField()) {
                nameFields.add(fieldDescribe.getName());
            }
        }
        return nameFields;
    }

    /**
     * This method is used to get the sobject type for a given object API name.
     */
    public sObjectType getsObjectType( String objectName ){
        
        final SObjectType sObjectType;
        System.Type objectType = Type.forName( 'Schema.' + objectName );
        if( objectType == null ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Object not visible or not exists; objectName= ' + objectName );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.OBJECT_NOT_EXISTS );
        }
        Boolean objectAccessFlag = COMM_DescribeManager.getInstance().getObjectDescribe(objectName).isAccessible();
        if(!objectAccessFlag){
            System.debug( LoggingLevel.ERROR, 'getObjectDescribe() : Object is not accessible; objectName= ' + objectName  );
            throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + ' ' + objectName );
        }

        // get sObjectType for given object name.
        sObjectType = ( (SObject) objectType.newInstance() ).getSObjectType();

        return sObjectType;
    }

    /**
     * This method is used to get the target Recordtype for the given quickAction.
     * 
     */
    public String getTargetRecordTypeForQuickAction(String actionName){
        String targetsobjecttype = null;
        List<QuickAction.DescribeQuickActionResult> result = QuickAction.DescribeQuickActions(new List<String> { actionName});
        if(result != null && !result.isEmpty()){
            targetsobjecttype = result[0].targetsobjecttype;
        }
        System.debug('For ' + actionName + ' targetObj ' + targetsobjecttype);
        return targetsobjecttype;
    }

    public void invokeQuickAction(SObject sObj, String actionName, String contextId){
        List<Common.GlobalProperty> property = CONF_CustomSettingsManager.getInstance().
            getAllGlobalProperties().get('RECORDACTION_EXTENSION_CLASS');
        String className = null;
        if(property != null && !property.isEmpty()){
            className = property[0].value;
        }
         
        if (String.isEmpty(className)){
           invokeQuickActionAPI(sObj, actionName, contextId);
           return;
        }
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        req.setQuickActionName(actionName);
        req.setRecord(sObj);
        req.setContextId(contextId);
        System.debug('Performing Quick Action with '+actionName);
        Type t = Type.forName(className);
        if ( t == null) {
            throw new SvmxSystem.SvmxNestedException( 'Invalid RecordActionExtensionClass name in Application Configuration custom setting');
        }
        try{
            COMM_RecordActionService v = (COMM_RecordActionService)t.newInstance();
            QuickAction.QuickActionResult result = v.performQuickAction(req);
            
            if(!result.isSuccess()){
                System.debug('Error invoking action');
                System.debug(String.join(result.getErrors(),' ; '));
                throw new SvmxSystem.SvmxNestedException(String.join(result.getErrors(),' ; '));
            }
        }catch(System.TypeException ex){
            throw new SvmxSystem.SvmxNestedException( 'RecordActionExtensionClass name in Application Configuration custom setting should implement COMM_RecordActionService');
        }
    }
    
    public void invokeQuickActionAPI(SObject sObj, String actionName, String contextId){
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        req.setQuickActionName(actionName);
        req.setRecord(sObj);
        req.setContextId(contextId);
        System.debug('Performing Quick Action with '+actionName);
        QuickAction.QuickActionResult result = QuickAction.performQuickAction(req);
        if(!result.isSuccess()){
            System.debug('Error invoking action');
            System.debug(String.join(result.getErrors(),' ; '));
            throw new SvmxSystem.SvmxNestedException(String.join(result.getErrors(),' ; '));
        }
    }
    
    /**
     * Private constructor to avoid creating multiple instance of 
     * this class in single transaction.
     */
    private COMM_DescribeManager() {
        
        sObjectTypeMap = new Map<String, Schema.SObjectType>();
        describeSobjectResultMap = new Map<String, Schema.DescribeSobjectResult>();
        describeFieldResultMap = new Map<String, Map<String, DescribeFieldResult>>();
        entityDetails = new List<Common.EntityDetails>();
    }

    /**
     * Private method to create QuickActionDefinition wrapper from DescribeAvailableQuickActionResult record.
     */
    private Common.QuickActionDefinition createActionDefinition( QuickAction.DescribeAvailableQuickActionResult actionRec ) {
        
        Common.QuickActionDefinition actionWrapper = new Common.QuickActionDefinition();
        
        actionWrapper.id = actionRec.getActionEnumOrId();
        actionWrapper.label = actionRec.getLabel();
        actionWrapper.name = actionRec.getName();
        actionWrapper.type = actionRec.getType();
        return actionWrapper;
    }

    /**
     * Private method to create QuickActionDefinition wrapper from DescribeQuickActionResult record.
     */
    private Common.QuickActionDefinition createActionDefinition( QuickAction.DescribeQuickActionResult actionRec ) {
        
        Common.QuickActionDefinition actionWrapper = new Common.QuickActionDefinition();
        
        actionWrapper.id = actionRec.getActionEnumOrId();
        actionWrapper.label = actionRec.getLabel();
        actionWrapper.name = actionRec.getName();
        actionWrapper.type = actionRec.getType();
        return actionWrapper;
    }
}