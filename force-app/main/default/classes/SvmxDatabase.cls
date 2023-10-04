/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief The namespace which has methods to perform SOQL & DML operations which 
 * internally performe FLS check on each field.
 * 
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        	Name                    Date            Comment
 *****************************************************************************************************
 *              	Ramachandra Mohan       14 May 2020     Created.
 * BLOS-166     	Ramachandra Mohan       11 Jun 2020     Updated upsert methods to process with CRETEABLE.
 * BLOS-314     	Ramachandra Mohan       16 Jul 2020     Updated performOperation to check record size before performing DML operations.
 * A360AM-173   	Manish Kushwah          22 Jan 2021     Added new method getFieldValue for getting field value from the record.
 * A360ENG-539  	Jason Bradley           29 Jan 2021     Added new method search for executing SOSL queries.
 * A360TOOL-918 	Ramachandra Mohan       05 Jan 2022     New methods to support externalIDField in upsert.
 * A360TOOL-1208	Ramachandra Mohan       12 Jul 2022     Additional checks to verify object access.
 *****************************************************************************************************/
public with sharing class SvmxDatabase {
    
    /**
     * Private string const to hold duplicate value error.
     */
    private final static String ERROR_DUPLICATE_VALUE_FOUND = 'duplicate value found:';
    
    /**
     * Private string const to hold field validation error.
     */
    private final static String ERROR_FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,';
    
    /**
     * Private enum represents the type of operations.
     */
    private enum Operation { QueryRecords, InsertRecords, UpdateRecords, UpsertRecords, DeleteRecords }

    /**
     * List of blacklisted objects whose RecordTypes should not be returned in queries.
     */
    private static final Set<String> RECORD_TYPE_SOBJECT_TYPE_BLACKLIST = new Set<String> { 'Metric' };
    
    /**
     * Creates a dynamic SOQL query at runtime. This method can be used wherever a static SOQL query can be used, 
     * such as in regular assignment statements and for loops. Unlike inline SOQL, fields in bind variables are 
     * not supported.
     * 
     * @param queryString Dynamic query string to be executed.
     * 
     * @return Returns query result as list of SObject.
     */
    public static List<SObject> query( final String queryString ) {
        
        System.debug( LoggingLevel.DEBUG, 'query() - enter; queryString= ' + queryString );
        
        List<SObject> newSourceRecords = new List<SObject>();
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            newSourceRecords = Database.query( queryString );
            
            // Perform field level security on retrieved list.
            if( newSourceRecords.size() > 0 ) {
                newSourceRecords = query( newSourceRecords );
            }
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'query() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'query() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'query() - exit' );
        }
        
        return newSourceRecords;
    }
    
    /* TODO: Look at building an alternative version of this for use with Search.SearchResults.
        SOSL results contain some very useful information that can be used to improve the user
        experience (WITH SNIPPET + Search.SearchResults Title and snippet properties).
    */
    /**
     * Executes a dynamic SOSL query. This method can be used wherever a static SOSL query can be used, 
     * such as in regular assignment statements and for loops. Unlike inline SOSL, fields in bind variables are 
     * not supported.
     * 
     * @param queryString Dynamic query string to be executed.
     * 
     * @return Returns query result as a list of lists of SObjects (multiple subsets, each by SObjectType).
     */
    public static List<List<SObject>> search(final String queryString) {

        System.debug( LoggingLevel.DEBUG, 'search() - enter; queryString= ' + queryString );

        List<List<SObject>> matchingRecordsBySObjectType = new List<List<SObject>>();

        try {
            matchingRecordsBySObjectType = Search.query(queryString);
            
            // Perform field level security validations
            for (Integer i = 0; i < matchingRecordsBySObjectType.size(); i++) {
                SObject[] records = matchingRecordsBySObjectType[i];
                if (records.size() > 0) {
                    matchingRecordsBySObjectType[i] = query(records);
                }
            }
        } catch(SvmxSystem.FLSException e) {
            System.debug(LoggingLevel.ERROR, 'search() : One or more field have restricted access to the user. Error= ' + e.getMessage());
            throw e;
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, 'search() : Internal server error. Error= ' + e.getStackTraceString());
            throw e;
        } finally {
            System.debug(LoggingLevel.DEBUG, 'search() - exit');
        }

        return matchingRecordsBySObjectType;
    }
    
    /**
     * Static method which performs field level permission check for queried record. In case of any 
     * permission issues, the method will thorw FLS exception.
     * 
     * @param sourceRecord Queried record on which FLS checks are performed.
     * 
     * @example SvmxDatabase.query(new WorkOrder());
     */
    public static SObject query( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'query() - enter; sourceRecord= ' + sourceRecord );
        
        SObject newSourceRecord = sourceRecord;
            
        try {
            // Perform field level security
            newSourceRecord = performOperation( sourceRecord, Operation.QueryRecords, AccessType.READABLE, true );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'query() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'query() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'query() - exit' );
        }
        
        return newSourceRecord;
    }
    
    /**
     * Static method which performs field level permission check for queried list of records. In case of any 
     * permission issues, the method will thorw FLS exception.
     * 
     * @param sourceRecords Queried list of records on which FLS checks to be performed.
     * 
     * @example SvmxDatabase.query([SELECT Id, Name FROM WorkOrder]);
     */
    public static List<SObject> query( final List<SObject> sourceRecords ) {
        
        System.debug( LoggingLevel.DEBUG, 'query() - enter; sourceRecords= ' + sourceRecords );
        
        List<SObject> newSourceRecords = sourceRecords;
        
        try {
            newSourceRecords = performOperation( sourceRecords, Operation.QueryRecords, AccessType.READABLE, true );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'query() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'query() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'query() - exit' );
        }
        
        return newSourceRecords;
    }
    
    /**
     * This method is used to adds a record to the organization’s data.
     * 
     * @param sourceRecord SObject record to insert.
     */
    public static SObject insertRecord( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'insertRecord() - enter; sourceRecord= ' + sourceRecord );
        
        SObject newSourceRecord = sourceRecord;
        
        try {
            newSourceRecord = performOperation( sourceRecord, Operation.InsertRecords, AccessType.CREATABLE, true );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'insertRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'insertRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'insertRecord() - exit' );
        }
        
        return newSourceRecord;
    }
    
    /**
     * Adds one or more sObjects, such as individual accounts or contacts, to the organization’s 
     * data. an exception is thrown if the method is not successful.
     * 
     * @param sourceRecord SObject record to insert.
     */
    public static List<SObject> insertRecord( final List<SObject> sourceRecords ) {
        return insertRecord( sourceRecords, true) ;
    }
    
    /**
     * Adds one or more records, such as individual accounts or contacts, to the organization’s 
     * data.
     * 
     * @param sourceRecord SObject record to insert.
     * @param allOrNothing The optional allOrNothing parameter specifies whether the operation allows 
     * 					   partial success. If you specify false for this parameter and a record fails, 
     * 					   the remainder of the DML operation can still succeed. If the parameter is not 
     * 					   set or is set true, an exception is thrown if the method is not successful.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static List<SObject> insertRecord( final List<SObject> sourceRecords, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'insertRecord() - enter; sourceRecords= ' + sourceRecords );
        
        List<SObject> newSourceRecords = sourceRecords;
            
        try {
            newSourceRecords = performOperation( sourceRecords, Operation.InsertRecords, AccessType.CREATABLE, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'insertRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'insertRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'insertRecord() - exit' );
        }
        
        return newSourceRecords;
    }
    
    /**
     * This method is used to modify an existing record in the organization’s.
     * 
     * @param sourceRecord SObject record to update.
     */
    public static SObject updateRecord( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateRecord() - enter; sourceRecord= ' + sourceRecord );
        
        SObject newSourceRecord = sourceRecord;
            
        try {
            newSourceRecord = performOperation( sourceRecord, Operation.UpdateRecords, AccessType.UPDATABLE, true );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateRecord() - exit' );
        }
        
        return newSourceRecord;
    }
    
    /**
     * Modifies one or more existing sObject records, such as individual accounts or contactsinvoice 
     * statements, in your organization’s data. An exception is thrown if the method is not successful
     * 
     * @param sourceRecord List of SObject records to update.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static List<SObject> updateRecord( final List<SObject> sourceRecords ) {
        return updateRecord( sourceRecords, true );
    }
    
    /**
     * Modifies one or more existing sObject records, such as individual accounts or contactsinvoice 
     * statements, in the organization’s data.
     * 
     * @param sourceRecord List of SObject records to update.
     * @param allOrNothing The optional allOrNothing parameter specifies whether the operation allows 
     * 					   partial success. If you specify false for this parameter and a record fails, 
     * 					   the remainder of the DML operation can still succeed. If the parameter is not 
     * 					   set or is set true, an exception is thrown if the method is not successful.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static List<SObject> updateRecord( final List<SObject> sourceRecords, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateRecord() - enter; sourceRecords= ' + sourceRecords );
        
        List<SObject> newSourceRecords = sourceRecords;
        try {
            newSourceRecords = performOperation( sourceRecords, Operation.UpdateRecords, AccessType.UPDATABLE, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateRecord() - exit' );
        }
        
        return newSourceRecords;
    }
    
    /**
     * This method is used to insert record if not exists or update an existing record in the organization’s.
     * 
     * @param sourceRecord SObject record to update.
     */
    public static SObject upsertRecord( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'upsertRecord() - enter; sourceRecord= ' + sourceRecord );
        
        SObject newSourceRecord = sourceRecord;
        try {
            newSourceRecord = performOperation( sourceRecord, Operation.UpsertRecords, AccessType.UPSERTABLE, true );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'upsertRecord() - exit' );
        }
        
        return newSourceRecord;
    }
    
    /**
     * This method is used to insert record if not exists or update an existing record in the organization’s.
     * 
     * @param sourceRecord SObject record to update.
     */
    public static SObject upsertRecord( final SObject sourceRecord, final Schema.SObjectField externalIDField, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'upsertRecord() - enter; sourceRecord= ' + sourceRecord );
        
        SObject newSourceRecord = sourceRecord;
        try {
            newSourceRecord = performOperation( sourceRecord, Operation.UpsertRecords, AccessType.UPSERTABLE, externalIDField, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'upsertRecord() - exit' );
        }
        
        return newSourceRecord;
    }
    
    /**
     * Add/Modifies one or more existing sObject records, such as individual accounts or contactsinvoice 
     * statements, in your organization’s data. An exception is thrown if the method is not successful
     * 
     * @param sourceRecord List of SObject records to upsert.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static List<SObject> upsertRecord( List<SObject> sourceRecords ) {
        return upsertRecord( sourceRecords, true );
    }
    
    /**
     * Modifies one or more existing sObject records, such as individual accounts or contactsinvoice 
     * statements, in the organization’s data.
     * 
     * @param sourceRecord List of SObject records to upsert.
     * @param allOrNothing The optional allOrNothing parameter specifies whether the operation allows 
     * 					   partial success. If you specify false for this parameter and a record fails, 
     * 					   the remainder of the DML operation can still succeed. If the parameter is not 
     * 					   set or is set true, an exception is thrown if the method is not successful.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static List<SObject> upsertRecord( List<SObject> sourceRecords, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'upsertRecord() - enter; sourceRecords= ' + sourceRecords );
        
        List<SObject> newSourceRecords = new List<SObject>();
            
        try {
            newSourceRecords = performOperation( sourceRecords, Operation.UpsertRecords, AccessType.UPSERTABLE, null, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'upsertRecord() - exit' );
        }
        
        return newSourceRecords;
    }
    
    /**
     * Modifies one or more existing sObject records, such as individual accounts or contactsinvoice 
     * statements, in the organization’s data.
     * 
     * @param sourceRecord List of SObject records to upsert.
     * @param allOrNothing The optional allOrNothing parameter specifies whether the operation allows 
     * 					   partial success. If you specify false for this parameter and a record fails, 
     * 					   the remainder of the DML operation can still succeed. If the parameter is not 
     * 					   set or is set true, an exception is thrown if the method is not successful.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static List<SObject> upsertRecord( List<SObject> sourceRecords, final Schema.SObjectField externalIDField, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'upsertRecord() - enter; sourceRecords= ' + sourceRecords );
        
        List<SObject> newSourceRecords = new List<SObject>();
            
        try {
            newSourceRecords = performOperation( sourceRecords, Operation.UpsertRecords, AccessType.UPSERTABLE, externalIDField, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'upsertRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'upsertRecord() - exit' );
        }
        
        return newSourceRecords;
    }
    
    /**
     * Deletes an existing sObject record from the organization's data.
     * 
     * @param sourceRecord SObject record to be deleted.
     */
    public static void deleteRecord( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteRecord() - enter; sourceRecord= ' + sourceRecord );
        
        try {
            performOperation( sourceRecord, Operation.DeleteRecords, AccessType.UPSERTABLE, true );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteRecord() - exit' );
        }
    }
    
    /**
     * Deletes a list of existing sObject records, such as individual accounts or contacts, 
     * from the organization’s data. An exception is thrown if the method is not successful.
     * 
     * @param sourceRecord List of SObject records to delete.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static void deleteRecord( final List<SObject> sourceRecords ) {
        deleteRecord( sourceRecords, true);
    }
    
    /**
     * Deletes a list of existing sObject records, such as individual accounts or contacts, 
     * from the organization’s data.
     * 
     * @param sourceRecord List of SObject records to delete.
     * @param allOrNothing The optional allOrNothing parameter specifies whether the operation allows 
     * 					   partial success. If you specify false for this parameter and a record fails, 
     * 					   the remainder of the DML operation can still succeed. If the parameter is not 
     * 					   set or is set true, an exception is thrown if the method is not successful.
     * 
     * @exception SvmxSystem.FLSException, Exception
     */
    public static void deleteRecord( final List<SObject> sourceRecords, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteRecord() - enter; sourceRecords= ' + sourceRecords );
        
        try {
            performOperation( sourceRecords, Operation.DeleteRecords, AccessType.UPSERTABLE, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteRecord() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteRecord() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteRecord() - exit' );
        }
    }
    
    /**
     * This method is used to verify FLS access for requested sObject record.
     * 
     * @param sourceRecord SObject record for which FLS check to be performed.
     * @param accessType Access type applied for FLS check.
     * 
     * @return Returns true if all the fields consumed in SObject are accessable 
     * 		   to logged in User, Otherwise, returns false.
     * 
     * @see AccessType
     * @exception SvmxSystem.FLSException, Exception
     */
    public static Boolean verifyFLSAccess(final SObject sourceRecord, final AccessType accessType ) {
        return verifyFLSAccess( new List<SObject>{sourceRecord}, accessType );
    } 
    
    /**
     * This method is used to verify FLS access for requested sObject record.
     * 
     * @param sourceRecords List of SObject records for which FLS check to be performed.
     * @param accessType Access type applied for FLS check.
     * 
     * @return Returns true if all the fields consumed in SObject are accessable 
     * 		   to logged in User, Otherwise, returns false.
     * 
     * @see AccessType
     * @exception SvmxSystem.FLSException, Exception
     */
    public static Boolean verifyFLSAccess(final List<SObject> sourceRecords, final AccessType accessType ) {

		System.debug( LoggingLevel.DEBUG, 'verifyFLSAccess() - enter' );
        
        Boolean isAccessable = true;
        
        try {
            
            SObjectAccessDecision decision = Security.stripInaccessible( accessType, sourceRecords );
            
            Map<String,Set<String>> removedFieldSet = decision.getRemovedFields();
            if( !removedFieldSet.isEmpty() ) {
                isAccessable = false;
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'verifyFLSAccess() : Failed to verify FLS access. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'verifyFLSAccess() - exit' );
        }
        
        return isAccessable;
    } 
    
    /**
     * Private method to perform DML operation with FLS check
     */
    private static SObject performOperation( final SObject sourceRecord, final Operation dmlOperation, final AccessType accessType, final Boolean allOrNothing ) {
        
        SObject newSourceRecord = sourceRecord;
        
        try {
            if( sourceRecord == null ) {
            
                System.debug( LoggingLevel.ERROR, 'performOperation() : Invalid argument. sourceRecord= ' + sourceRecord );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            newSourceRecord = performOperation( sourceRecord, dmlOperation, accessType, null, allOrNothing );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Failed to perform SOQL/DML operation. Error= ' + e.getMessage() );
            throw e;
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'performOperation() - exit' );
        }
        
        return newSourceRecord;
    }
    
    /**
     * Private method to perform DML operation with FLS check
     */
    private static SObject performOperation( final SObject sourceRecord, final Operation dmlOperation, final AccessType accessType, final Schema.SObjectField externalIDField, final Boolean allOrNothing ) {
        
        SObject newSourceRecord = sourceRecord;
        
        try {
            if( sourceRecord == null ) {
            
                System.debug( LoggingLevel.ERROR, 'performOperation() : Invalid argument. sourceRecord= ' + sourceRecord );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            newSourceRecord = performOperation( new List<SObject>{sourceRecord}, dmlOperation, accessType, externalIDField, allOrNothing )[0];
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Failed to perform SOQL/DML operation. Error= ' + e.getMessage() );
            throw e;
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'performOperation() - exit' );
        }
        
        return newSourceRecord;
    }
    
    private static List<SObject> performOperation( List<SObject> sourceRecords, Operation dmlOperation, AccessType aType, final Boolean allOrNothing ) {
        
        List<SObject> newRecords = sourceRecords;
        
        try {
            newRecords = performOperation( sourceRecords, dmlOperation, aType, null, allOrNothing );
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : One or more field have restricted access to the user. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Internal server error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'performOperation() - exit' );
        }
        
        return newRecords;
    }
        
    /**
     * Private method to perform DML operation with FLS check
     */
    private static List<SObject> performOperation( List<SObject> sourceRecords, Operation dmlOperation, AccessType aType, final Schema.SObjectField externalIDField, final Boolean allOrNothing ) {
        
        System.debug( LoggingLevel.FINE, 'performOperation() - enter; sourceRecords= ' + sourceRecords );
        
        List<SObject> newRecords = sourceRecords;
        
        try {
            
            if( sourceRecords == null ) {
            
                System.debug( LoggingLevel.ERROR, 'performOperation() : Invalid argument. sourceRecords= ' + sourceRecords );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            if (sourceRecords.size() > 0) {
                
                final Schema.SObjectType sObjectType = sourceRecords.get(0).getSObjectType();
                
                checkObjectAccess( sObjectType, dmlOperation, aType );
                
                // The RecordType object requires an additional access check for its referenced SObjectType field
                if (aType == AccessType.READABLE && String.valueOf(sObjectType).equals('RecordType')) {
                    newRecords = sourceRecords = filterInaccessibleRecordTypes(sourceRecords);
                }
            }

            if (sourceRecords.size() > 0) {
                
                SObjectAccessDecision decision = Security.stripInaccessible( aType, sourceRecords );
            
                Map<String,Set<String>> removedFieldSet = decision.getRemovedFields();
                if( !removedFieldSet.isEmpty() && !Test.isRunningTest() && !SvmxSystem.isRunningPostInstall ) {
                    
                    // Throw error in case the field is restricted for read or create.
                    if( aType == AccessType.CREATABLE || aType == AccessType.READABLE ) {
                        
                        System.debug( LoggingLevel.ERROR, 'performOperation() : One or more field have restricted access to the user. User= ' + System.UserInfo.getUserId() );
                        throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + removedFieldSet );
                    }
                    
                    // Manually validate field level permission for Master-Child relationship field, as stripInaccessible 
                    // method will not internally validate the FLS.
                    String objectApiName = String.valueOf( sourceRecords.get(0).getSObjectType() );
                    Map<String, Schema.SObjectField> sObjectFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap(objectApiName);
                    
                    // Loop through each striped fields and check whether the field is master-child or not. 
                    for( String fieldAPIName : removedFieldSet.values().get(0) ) {
                        
                        if( String.isBlank( fieldAPIName ) || sObjectFieldMap.get(fieldAPIName) == null ) {
                            continue;
                        }
                            
                        Schema.DescribeFieldResult describeFieldResult = COMM_DescribeManager.getInstance().getFieldDescribe( sObjectFieldMap.get(fieldAPIName) );
                        if( describeFieldResult.isCreateable() && describeFieldResult.isCustom() ) {
                            
                            // Throw FLS error only if fields is not a master-detail field.
                            if( describeFieldResult.getRelationshipOrder() == null || describeFieldResult.getType() != DisplayType.REFERENCE ) {
                                
                                System.debug( LoggingLevel.ERROR, 'performOperation() : One or more field have restricted access to the user. User= ' + System.UserInfo.getUserId() );
                                throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + fieldAPIName );
                            }
                        }
                    }
                }
                
                System.debug( LoggingLevel.FINE, 'performOperation() : Field Level Security verification completed.' );
                
                // Perform DML operation.
                switch on dmlOperation {
                    
                    when InsertRecords { 
                        List<Database.saveResult> saveResultList = Database.insert( newRecords, allOrNothing ); 
                        if ( !allOrNothing ) {
                            parseDatabaseResult(dmlOperation, saveResultList, sourceRecords);
                        }
                    }
                    when UpdateRecords { 
                        List<Database.saveResult> saveResultList = Database.update( newRecords, allOrNothing ); 
                        if ( !allOrNothing ) {
                            parseDatabaseResult(dmlOperation, saveResultList, sourceRecords);
                        }
                    }
                    when UpsertRecords {
                        newRecords = castToSourceSObjectType(sourceRecords, sourceRecords.get(0).getSObjectType() );
                        List<Database.UpsertResult> upsertResultList = (externalIDField == null) ? Database.upsert( newRecords, allOrNothing ) : Database.upsert( newRecords, externalIDField, allOrNothing );
                        if ( !allOrNothing ) {
                            parseDatabaseResult(dmlOperation, upsertResultList, sourceRecords);
                        }
                    }
                    when DeleteRecords { 
                        if( Test.isRunningTest() || sourceRecords.get(0).getSObjectType().getDescribe().isDeletable() ) {
                            Database.delete( newRecords, allOrNothing );
                        } else {
                            System.debug( LoggingLevel.ERROR, 'performOperation() : Restricted access to delete records. User= ' + System.UserInfo.getUserId() );
                            throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + sourceRecords.get(0).getSObjectType().getDescribe().getName() );
                        }
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Restricted field access. Error= ' + e.getMessage() );
            throw e;
        }
        catch( SvmxSystem.FLSException e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Restricted field access. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'performOperation() : Internal server error. Error= ' + e.getStackTraceString() );
            throw new SvmxSystem.SvmxNestedException( processException(e) );
        }
        finally {
            System.debug( LoggingLevel.FINE, 'performOperation() - exit' );
        }
        
        return newRecords;
    }
    
    private static void checkObjectAccess( final Schema.SObjectType sObjectType, final Operation dmlOperation, final AccessType aType ) {
        
        System.debug( LoggingLevel.FINE, 'checkObjectAccess() - enter' );
        
        try {
            switch on dmlOperation {
                
                when QueryRecords { 
                    if( !sObjectType.getDescribe().isAccessible() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'checkObjectAccess() : Object have restricted access to the user. User= ' + System.UserInfo.getUserId() + '; Object: ' + String.valueOf(sObjectType) );
                        throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + String.valueOf(sObjectType) );
                    }
                }
                when InsertRecords { 
                    if( !sObjectType.getDescribe().isCreateable() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'checkObjectAccess() : Object have restricted access to the user. User= ' + System.UserInfo.getUserId() + '; Object: ' + String.valueOf(sObjectType) );
                        throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + String.valueOf(sObjectType) );
                    }
                }
                when UpdateRecords  {
                    if( !sObjectType.getDescribe().isUpdateable() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'checkObjectAccess() : Object have restricted access to the user. User= ' + System.UserInfo.getUserId() + '; Object: ' + String.valueOf(sObjectType) );
                        throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + String.valueOf(sObjectType) );
                    }
                }
                when UpsertRecords {
                    if( !sObjectType.getDescribe().isCreateable() || !sObjectType.getDescribe().isUpdateable() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'checkObjectAccess() : Object have restricted access to the user. User= ' + System.UserInfo.getUserId() + '; Object: ' + String.valueOf(sObjectType) );
                        throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + String.valueOf(sObjectType) );
                    }
                }
                when DeleteRecords {
                    if( !Test.isRunningTest() && !sObjectType.getDescribe().isDeletable() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'checkObjectAccess() : Object have restricted access to the user. User= ' + System.UserInfo.getUserId() + '; Object: ' + String.valueOf(sObjectType) );
                        throw new SvmxSystem.FLSException( ErrorMessage.RESTRICTED_ACCESS + String.valueOf(sObjectType) );
                    }
                }
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'checkObjectAccess() - exit' );
        }
    }

    private static List<SObject> filterInaccessibleRecordTypes(final List<SObject> recordTypes) {
        List<SObject> accessibleRecordTypes = new List<SObject>();

        Set<Id> recordTypeIds = new Set<Id>();
        for (SObject sourceRecord : recordTypes) {
            recordTypeIds.add(sourceRecord.Id);
        }
        Map<Id, RecordType> recordTypesById = new Map<Id, RecordType>([SELECT SObjectType FROM RecordType WHERE Id IN: recordTypeIds]);

        Set<String> sObjectNamesForRecordTypes = new Set<String>();
        for (Id recordTypeId : recordTypesById.keySet()) {
            RecordType recordType = recordTypesById.get(recordTypeId);
            sObjectNamesForRecordTypes.add(recordType.SObjectType);
        }

        Map<String, Schema.DescribeSObjectResult> objectDescribesByName = new Map<String, Schema.DescribeSObjectResult>();
        for (String sObjectName : sObjectNamesForRecordTypes) {
            System.Type objectType = Type.forName('Schema', sObjectName);
            if (objectType != null) {
                Schema.SObjectType sObjectType = ((SObject)objectType.newInstance()).getSObjectType();
                if (sObjectType != null) {
                    Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
                    objectDescribesByName.put(sObjectDescribe.getName(), sObjectDescribe);
                }
            }
        }

        for (SObject sourceRecord : recordTypes) {
            RecordType asRecordType = recordTypesById.get(sourceRecord.Id);
            Schema.DescribeSObjectResult referencedSObjectDescribe = objectDescribesByName.get(asRecordType.SObjectType);
            if (
                referencedSObjectDescribe != null &&
                referencedSObjectDescribe.isAccessible() &&
                !RECORD_TYPE_SOBJECT_TYPE_BLACKLIST.contains(asRecordType.SObjectType)
            ) {
                accessibleRecordTypes.add(sourceRecord);
            }
        }

        return accessibleRecordTypes;
    }
    
    /**
     * Private method to handle known exceptions.
     */
    private static String processException( final Exception ex ) {
        
        String message='';
        if (ex!=null) {
            for (Integer index = 0; index < ex.getNumDml(); index++) {
                System.debug(ex.getDmlMessage(index)); 
                message = ex.getDmlMessage(index);
                return message;
            }
        }
        return message;
    }
    
    /**
     * This method is used to create source object instance records which will be invoked only for upsert.
     */
    private static List<SObject> castToSourceSObjectType( final List<SObject> sourceRecords, Schema.SObjectType sObjectType) {
        
        System.debug( LoggingLevel.FINEST, 'castToSourceSObjectType() - enter' );
        
        List<SObject> resultCasttList;
            
        try {
            
            resultCasttList = (List<SObject>) System.Type.forName('List<' + sObjectType + '>').newInstance();
        	resultCasttList.addAll(sourceRecords); 
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'castToSourceSObjectType() : Failed to cast source object type. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'castToSourceSObjectType() - exit' );
        }
        
        return resultCasttList;
    }

    /**
     * This method is used to get the field value from the record. It is recursive method to traverse over multiple lookup fields.
     */
    public static Object getFieldValue(SObject record, String field) {
        System.debug(LoggingLevel.DEBUG, 'getFieldValue() - enter; record= ' + record + ' field= ' + field);

        Object fieldValue = null;
        if (field.contains('.')) {
            String refObjectName = field.substringBefore('.');
            String remainingFieldName = field.substringAfter('.');
            //Sobject tempSobject = record?.getSObject(refObjectName);
            Sobject tempSobject = record == null ? null : record.getSObject(refObjectName);
            fieldValue = SvmxDatabase.getFieldValue(tempSobject, remainingFieldName);
        } else {
            //fieldValue = record?.get(field);
            fieldValue = record == null ? null : record.get(field);
        }

        System.debug(LoggingLevel.DEBUG, 'getFieldValue() - exit; fieldValue= ' + fieldValue);

        return fieldValue;
    }

    private static void parseDatabaseResult (Operation dmlOperation, List<Object> resultList, List<SObject> sObjectList) {
        List<Common.ServiceError> errorList = new List<Common.ServiceError>();
        Common.DatabaseResult databaseResult = new Common.DatabaseResult();

        Integer index = 0;
        // Iterate through each returned result
        System.debug( LoggingLevel.DEBUG, 'sObjectList Save Result; srList= ' + resultList);
        for (Object result : resultList) {

            List<Database.Error> errors = new List<Database.Error>();
            switch on dmlOperation {

                when InsertRecords, UpdateRecords { 

                    Database.saveResult saveResult = (Database.saveResult) result; 
                    if( !saveResult.isSuccess() ) {
                        errors = saveResult.getErrors();
                    }
                }
                when UpsertRecords {
                    Database.UpsertResult saveResult = (Database.UpsertResult) result;
                    if( !saveResult.isSuccess() ) {
                        errors = saveResult.getErrors();
                    }
                }
            }
            for(Database.Error error : errors) {
                Id referenceId =  getReferenceId(sObjectList[index]);
                errorList.add( addError( (String)referenceId ,error)) ;
            }

            index++;
        }
        if (errorList != null && !errorList.isEmpty()) {
            databaseResult.errors = errorList;
            throw new SvmxSystem.SvmxNestedException( databaseResult );
        }
    }

    private static Id getReferenceId (SObject sourceRecord) {

        System.debug( LoggingLevel.DEBUG, 'getReferenceId() - enter; sourceRecord= ' + sourceRecord);
        Id referenceId;
        try {

            if (sourceRecord.get('Id') != null ) {
                return (Id)sourceRecord.get('Id') ;
            }

            switch on String.valueOf( sourceRecord.getSObjectType() ) {

                when 'ContractLineItem' {
                    referenceId = (Id)sourceRecord.get('AssetId');
                }
                when 'Entitlement' {
                    if ((Id)sourceRecord.get('ContractLineItemId') != null) {
                        referenceId = (Id)sourceRecord.get('ContractLineItemId');
                    } else {
                        referenceId = (Id)sourceRecord.get('ServiceContractId');
                    }
                }
                when 'SVMXA360__ContractPriceLineItem__c' {
    
                    if ( (Id)sourceRecord.get('SVMXA360__EntitledServiceId__c') != null ) {
                        referenceId = (Id)sourceRecord.get('SVMXA360__EntitledServiceId__c');
                    } else if ( (Id)sourceRecord.get('SVMXA360__ContractLineId__c') != null ) {
                        referenceId = (Id)sourceRecord.get('SVMXA360__ContractLineId__c');
                    } else {
                        referenceId = (Id)sourceRecord.get('SVMXA360__ServiceContractId__c');
                    }
                }
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getReferenceId() : Failed to get parent id. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getReferenceId() - exit; referenceId= ' + referenceId);
        }
        
        return referenceId;
    }

    private static Common.ServiceError addError( String referenceId, Database.Error error ) {

        Common.ServiceError svmxErr = new Common.ServiceError();
        svmxErr.referenceId = referenceId;
        svmxErr.message = error != null ? error.getStatusCode() + ' - ' + error.getMessage() : '';

        return svmxErr;
    }

}