/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A Singleton class which provides utility methods to retrieve object 
 * and field describe informations.
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Soumyaranjan Pati        1st Feb 2021     Created.
 *              Ramachandra Mohan       09 Mar 2023     Created methods to check whether name, 
 *                                                      developerName exists or not.
 *****************************************************************************************************/
public with sharing class COMM_RecordTypeManager {

    private final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
    /**
     * A private static variable to hole instance for this class.
     */
    private static COMM_RecordTypeManager instance;
    
    /**
     * A static method to get instance of this class.
     */
    public static COMM_RecordTypeManager getInstance() {
        
        System.debug( LoggingLevel.FINE, 'COMM_RecordTypeManager.getInstance() - enter' );
        
        try {
            
            // Create instance of this class only if its not exists.
            if( instance == null ) {
                
           		instance = new COMM_RecordTypeManager();
                System.debug( LoggingLevel.DEBUG, 'COMM_RecordTypeManager.getInstance() : Instance created successfully');
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'COMM_RecordTypeManager.getInstance() - exit' );
        }
        
        return instance;
    }
    
    public Boolean hasRecordType( final String objectAPIName, final String recordTypeName ) {
        
        System.debug( LoggingLevel.DEBUG, 'hasRecordType() - enter; objectAPIName=' + objectAPIName + '; recordTypeName=' + recordTypeName );
        
        Boolean hasRecordType = false;
        
        try {
            
            // Check for valid argument
            if( objectAPIName == null || String.isBlank(recordTypeName) ) {
                
                System.debug( LoggingLevel.ERROR, 'hasRecordType() : Invalid argument; objectAPIName= ' + objectAPIName + '; recordTypeName=' + recordTypeName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            System.debug( LoggingLevel.INFO, 'hasRecordType() : Retrieving recordTypeId for recordTypeName=' + recordTypeName );
            
            // get describe result for requested sobject type.
            final Schema.DescribeSobjectResult describeSobjectResult = describeManager.getObjectDescribe( objectAPIName );
            
            if( describeSobjectResult != null ) {
                hasRecordType = describeSobjectResult.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName) 
                    || describeSobjectResult.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName.toLowerCase())
                    || describeSobjectResult.getRecordTypeInfosByName().containsKey(recordTypeName)
                    || describeSobjectResult.getRecordTypeInfosByName().containsKey(recordTypeName.toLowerCase())
                    || describeSobjectResult.getRecordTypeInfosById().containsKey(recordTypeName);
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'hasRecordType() : Failed to retrieve record type id. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'hasRecordType() : Failed to retrieve record type id. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'hasRecordType() - exit; hasRecordType=' + hasRecordType );
        }
        
        return hasRecordType;
    }
    
    public Boolean hasRecordTypeName( final String objectAPIName, final String recordTypeName ) {
        
        System.debug( LoggingLevel.DEBUG, 'hasRecordTypeName() - enter; objectAPIName=' + objectAPIName + '; recordTypeName=' + recordTypeName );
        
        Boolean hasRecordType = false;
        
        try {
            
            // Check for valid argument
            if( objectAPIName == null || String.isBlank(recordTypeName) ) {
                
                System.debug( LoggingLevel.ERROR, 'hasRecordTypeName() : Invalid argument; objectAPIName= ' + objectAPIName + '; recordTypeName=' + recordTypeName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            System.debug( LoggingLevel.INFO, 'hasRecordTypeName() : Retrieving recordTypeId for recordTypeName=' + recordTypeName );
            
            // get describe result for requested sobject type.
            final Schema.DescribeSobjectResult describeSobjectResult = describeManager.getObjectDescribe( objectAPIName );
            
            if( describeSobjectResult != null ) {
                hasRecordType = describeSobjectResult.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName) 
                    || describeSobjectResult.getRecordTypeInfosByName().containsKey(recordTypeName)
                    || describeSobjectResult.getRecordTypeInfosByName().containsKey(recordTypeName.toLowerCase());
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'hasRecordTypeName() : Failed to retrieve record type id. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'hasRecordTypeName() : Failed to retrieve record type id. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'hasRecordType() - exit; hasRecordType=' + hasRecordType );
        }
        
        return hasRecordType;
    }
    
    public Boolean hasRecordTypeDeveloperName( final String objectAPIName, final String recordTypeName ) {
        
        System.debug( LoggingLevel.DEBUG, 'hasRecordTypeDeveloperName() - enter; objectAPIName=' + objectAPIName + '; recordTypeName=' + recordTypeName );
        
        Boolean hasRecordType = false;
        
        try {
            
            // Check for valid argument
            if( objectAPIName == null || String.isBlank(recordTypeName) ) {
                
                System.debug( LoggingLevel.ERROR, 'hasRecordTypeDeveloperName() : Invalid argument; objectAPIName= ' + objectAPIName + '; recordTypeName=' + recordTypeName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            System.debug( LoggingLevel.INFO, 'hasRecordTypeDeveloperName() : Retrieving recordTypeId for recordTypeName=' + recordTypeName );
            
            // get describe result for requested sobject type.
            final Schema.DescribeSobjectResult describeSobjectResult = describeManager.getObjectDescribe( objectAPIName );
            
            if( describeSobjectResult != null ) {
                hasRecordType = describeSobjectResult.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName) 
                    || describeSobjectResult.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName.toLowerCase());
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'hasRecordTypeDeveloperName() : Failed to retrieve record type id. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'hasRecordTypeDeveloperName() : Failed to retrieve record type id. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'hasRecordTypeDeveloperName() - exit; hasRecordType=' + hasRecordType );
        }
        
        return hasRecordType;
    }
    
    /**
     * This method is used to retrieve record type Id for requested record type name in sobject type.
     * 
     * @param sObjectType SObjectType instance from which record type info will be retrieved.
     * @param recordTypeName Record type name for which id to be retrieved.
     */
    public Id getRecordTypeId( final SObjectType sObjectType, final String recordTypeName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getRecordTypeId() - enter; sObjectType=' + sObjectType + '; recordTypeName=' + recordTypeName );
        
        Id recordTypeId = null;
        
        try {
            
            // Check for valid argument
            if( sObjectType == null || String.isBlank(recordTypeName) ) {
                
                System.debug( LoggingLevel.ERROR, 'getRecordTypeId() : Invalid argument; sObjectType= ' + sObjectType + '; recordTypeName=' + recordTypeName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            System.debug( LoggingLevel.INFO, 'getRecordTypeId() : Retrieving recordTypeId for recordTypeName=' + recordTypeName );
            
            // get describe result for requested sobject type.
            final Schema.DescribeSobjectResult describeSobjectResult = describeManager.getObjectDescribe( String.valueOf(sObjectType) );
            
            if( describeSobjectResult != null ) {
                recordTypeId = describeSobjectResult.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getRecordTypeId() : Failed to retrieve record type id. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getRecordTypeId() : Failed to retrieve record type id. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecordTypeId() - exit; recordTypeId=' + recordTypeId );
        }
        
        return recordTypeId;
    }
    
    private COMM_RecordTypeManager() {
        System.debug( LoggingLevel.FINE, 'COMM_RecordTypeManager() - enter' );
    }
}