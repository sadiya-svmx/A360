/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implementes utility methods to create developer names for 
 * requested developer name type. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       29 May 2020     Created.
 *****************************************************************************************************/
public class COMM_DeveloperName {
    
    /**
     * Private instance variable to hold name type vs object API name map.
     */
    private static final Map<Common.Application, String> ApplicationAPINameMap = new Map<Common.Application, String>{
        Common.Application.Expression => 'SVMXA360__CONF_Expression__c',
        Common.Application.ObjectMapping => 'SVMXA360__CONF_ObjectMapping__c',
        Common.Application.ProcessWizard => 'SVMXA360__CONF_ProcessWizard__c',
        Common.Application.ProcessWizardStep => 'SVMXA360__CONF_ProcessWizardStep__c'
    };
        
    /**
     * Private instance variable to hold 3 char prefix for eaxh application.
     */
    private static final Map<Common.Application, String> PrefixMap = new Map<Common.Application, String>{
        Common.Application.Expression => 'EXP',
        Common.Application.ObjectMapping => 'MAP'  
    };
    
    /**
     * Private static string variable to hold string zero.
     */
    private static String Zero					= '0';
    
    /**
     * Private static string variable to hold field API name for developer name.
     */
    private static String DeveloperNameField	= 'SVMXA360__DeveloperName__c';
    
    /**
     * Private static integer variable to hold sequence number length. E.g {000001}
     */
    private static Integer SequenceLength		= 6;
    
    /**
     * Private static integer variable to hold prefix length. E.g MAP, EXP.
     */
    private static Integer PrefixLength			= 3;
    
    /**
     * Private static integer variable to hold sequence index.
     */
    private static Integer SequenceIndex 		= ( UserInfo.getOrganizationId().length() + PrefixLength );
    
    /**
     * This method is used to create developer name for given developer name type and Process name.
     */
    public static String createDeveloperName( final Common.Application application, final String processName ) {
        
        System.debug( LoggingLevel.FINE, 'createDeveloperName() - enter; application= ' + application + '; processName= ' + processName);
        
        String developerName = processName.normalizeSpace().replaceAll('\\s+', '_');
		
        try {
            
            final String objectAPIName = ApplicationAPINameMap.get(application);
            final String queryString = 'SELECT SVMXA360__DeveloperName__c FROM '+ objectAPIName +' WHERE SVMXA360__DeveloperName__c LIKE \''+developerName+'%\' ORDER BY CreatedDate DESC NULLS LAST LIMIT 1';
            
            List<SObject> sObjectList = SvmxDatabase.query(queryString);
            
            if( sObjectList != null && sObjectList.size() > 0 ) {
                
                String oldDeveloperName = (String) sObjectList[0].get(DeveloperNameField);
                
                if( oldDeveloperName.length() >= developerName.length() ) {
                    
                    Integer sequence = 1;
                    if( oldDeveloperName.length() > developerName.length() ) {
                        
                        String sequenceString = oldDeveloperName.substring( developerName.length() + 1 );
                        if( sequenceString.isNumeric() ) {
                            
                            sequence = Integer.valueOf(sequenceString) + 1;
                        }
                    } 
                    
                    developerName = developerName + '_' + sequence;
                }
            }
        }
        catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'createDeveloperName() : Failed to create developer name. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createDeveloperName() - exit; developerName= ' + developerName );
        }
        
        return developerName;
    }
    
    /**
     * This method is used to create developer name for given developer name type.
     */
    public static String createDeveloperName( final Common.Application application ) {
        
        System.debug( LoggingLevel.FINE, 'createDeveloperName() - enter; application= ' + application );
        
        String developerName;
        
        try {
            // Retrieve single developer name for requested name type.
            final List<String> developerNames = createDeveloperNames( application, 1 );
            
            if( !developerNames.isEmpty() ) {
                developerName = developerNames.get(0);
            }
        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'createDeveloperName() : Failed to create developer name. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createDeveloperName() - exit; developerName= ' + developerName );
        }
        
        return developerName;
    }
    
    /**
     * This method is used to create multiple developer names in sequence for given name type and count.
     */
    public static List<String> createDeveloperNames( final Common.Application application, final Integer count ) {
        
        System.debug( LoggingLevel.FINE, 'createDeveloperName() - enter; application= ' + application + '; count= ' + count );
        
        final List<String> developerNames = new List<String>();
        
        try {
            // Prefix developer name with current Org Id.
            String lastDeveloperName = UserInfo.getOrganizationId() + PrefixMap.get(application);
            
            // Retrieve next available sequence number for given application type.
            Integer newSequence = getSequenceNumber(application);
            for( Integer i = 0; i < count; i++ ) {
                developerNames.add( lastDeveloperName + Zero.repeat(SequenceLength - String.valueOf(newSequence).length()) + newSequence++ );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createDeveloperName() : Failed to create developer name. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createDeveloperName() - exit; developerNames= ' + developerNames );
        }
        
        return developerNames;
    }

    /**
     * This method returns true if the given developer name is not being used for the given Application type.
     */
    public static Boolean isDeveloperNameAvailable( final Common.Application application, final String developerName ) {
        System.debug( LoggingLevel.FINE, 'isDeveloperNameAvailable() - enter; application= ' + application + '; developerName= ' + developerName);
        
        Boolean isAvailable = false;

        try {
            
            final String objectAPIName = ApplicationAPINameMap.get(application);
            final String queryString = 'SELECT Id FROM '+ objectAPIName +' WHERE SVMXA360__DeveloperName__c = \''+developerName+ '\' LIMIT 1';
            
            List<SObject> sObjectList = SvmxDatabase.query(queryString);
            
            isAvailable = sObjectList.size() == 0;
        }
        catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'isDeveloperNameAvailable() : Failed to check developer name. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'isDeveloperNameAvailable() - exit; developerName= ' + developerName );
        }
        
        return isAvailable;
    }

    /**
     * Private method to retrieve last available sequence number.
     */
    private static Integer getSequenceNumber( final Common.Application application ) {
        
        System.debug( LoggingLevel.FINE, 'getSequenceNumber() - enter; application= ' + application );
        
        Integer sequenceNumber = 1;
        
        try {
            
            final String objectAPIName = ApplicationAPINameMap.get(application);
            final String queryString = 'SELECT SVMXA360__DeveloperName__c FROM '+ objectAPIName +' WHERE SVMXA360__DeveloperName__c LIKE \''+UserInfo.getOrganizationId()+'%\' ORDER BY CreatedDate DESC NULLS LAST LIMIT 1';
        	
            System.debug( LoggingLevel.FINE, 'getSequenceNumber() : queryString= ' + queryString );
            
            List<SObject> sObjectList = SvmxDatabase.query(queryString);
            
            if( sObjectList != null && sObjectList.size() > 0 ) {
                
                String oldDeveloperName = (String) sObjectList[0].get(DeveloperNameField);
                sequenceNumber = Integer.valueOf( oldDeveloperName.substring(SequenceIndex) ) + 1;
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSequenceNumber() : Failed to retrieve last developer name. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'getSequenceNumber() - exit; sequenceNumber= ' + sequenceNumber );
        }
        
        
        return sequenceNumber;
    }
}