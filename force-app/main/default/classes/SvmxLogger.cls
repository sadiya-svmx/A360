/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief The namespace with methods create logger and log the messages to Application Log.
 * The methods internally publish events which invokes event flow trigger to insert log records.
 * 
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 Sep 2020     Created.
 *****************************************************************************************************/
public with sharing class SvmxLogger {

    public enum Level {
        Debug,
        Info,
        Error,
        Warning
    }
    
    public enum Application {
        Entitlement,
        PostInstallScript,
        Warranty,
        TechnicalAttribute,
        VendorWarranty
    }
    
    /**
     * Application name for which logger is created.
     */
    private Application application;
    
    /**
     * Public static method to create instance of Logger with application name.
     * @param application Name of the application for which logger to be created. 
     * Eg. Entitlement, Warranty, Post-Install Script.
     */
    public static SvmxLogger getLogger( final Application application ) {
        return new SvmxLogger( application );
    }
    
    /**
     * This method is used to log debug message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    /*public void debug( final String message) {
		debug( Level.Info, message);
	}*/
    
    /**
     * This method is used to log error message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void error( final String message) {
		debug( Level.Error, message);
	}
    
    /**
     * This method is used to log error message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void error( final String message, final String sourceRecordId) {
		debug( Level.Error, message, sourceRecordId);
	}
    
    /**
     * This method is used to log warning message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void warning( final String message) {
		debug( Level.Warning, message);
	}
    
    /**
     * This method is used to log warning message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void warning( final String message, final String sourceRecordId) {
		debug( Level.Warning, message, sourceRecordId);
	}
    
    /**
     * This method is used to log info message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void info( final String message) {
		debug( Level.Info, message);
	}
    
    /**
     * This method is used to log info message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void info( final String message, final String sourceRecordId) {
		debug( Level.Info, message, sourceRecordId );
	}
    
    /**
     * This method is used to log exception message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void error( final Exception e ) {
		debug( Level.Error, e.getMessage() );
	}
    
    /**
     * This method is used to log exception message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void error( final Exception e, final String sourceRecordId ) {
		debug( Level.Error, e.getMessage(), sourceRecordId );
	}
    
    /**
     * This method is used to log message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void debug( final Level logLevel, final String message ) {
         debug( logLevel, message, null );
    }
    
    /**
     * This method is used to log message to the servicemax application log.
     * @param message Message to be logged in the application log.
     */
    public void debug( final Level logLevel, final String message, final String sourceRecordId ) {
         publish( logLevel, message, sourceRecordId );
    }
    
    /**
     * This method is used to publish message to the event bus.
     * @param message Message to be logged in the application log.
     */
    private void publish( final Level logLevel, final String message ) {
        publish( logLevel, message, null);
    }
    
    /**
     * This method is used to publish message to the event bus.
     * @param message Message to be logged in the application log.
     */
    private void publish( final Level logLevel, final String message, final String sourceRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'publish() - enter; message= ' + message );
        
        try {
            
            SVMXA360__ApplicationEventLog__e applicationEventLog = new SVMXA360__ApplicationEventLog__e();
            applicationEventLog.SVMXA360__ApplicationName__c = this.application.name();
            applicationEventLog.SVMXA360__LogType__c = logLevel.name();
            applicationEventLog.SVMXA360__Message__c = message;
            applicationEventLog.SVMXA360__Timestamp__c = System.currentTimeMillis();
            applicationEventLog.SVMXA360__UserId__c = UserInfo.getUserId();
            applicationEventLog.SVMXA360__SourceRecordId__c = sourceRecordId;
            
            if( !Test.isRunningTest() ) {
                
                // Publish event to event bus.
                Database.SaveResult saveResult = EventBus.publish(applicationEventLog);
                
                if( saveResult.isSuccess() ) {
                    
                    System.debug( LoggingLevel.DEBUG, 'Successfully published event. message= ' + message );
                } else {
                    for( Database.Error error : saveResult.getErrors() ) {
                        System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + error.getStatusCode() + ' - ' + error.getMessage() );
                    }
                }
            }
            
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + e.getMessage() + '\n' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'publish() - exit' );
        }
    }
    /**
     * Private constructor to restrict creation of this class instance.
     */
    private SvmxLogger() {
    }
    
    /**
     * Private class to create instance of this class with application name.
     */
    private SvmxLogger( final Application application ) {
        this.application = application;
    }
    
    /**
     * Wrapper structure for Application Event
     */
    public class ApplicationEventLog {
        
        public String applicationName {get; set;}
        public String sourceRecordId {get; set;}
        public String userId {get; set;}
        public String message {get; set;}
        public String logLevel {get; set;}
        public Decimal timestamp {get; set;}
        public String operationType {get; set;}
    }
    
    /**
     * This method is used to publish multiple messages to the event bus.
     * @param applicationEventLog List of events with sourceId and message per event
     */
    public void publish( final List<ApplicationEventLog> eventLogList) {
        
        System.debug( LoggingLevel.DEBUG, 'publish() - enter; eventLogList= ' + eventLogList );
        
        try {
            
            List<SVMXA360__ApplicationEventLog__e> applicationEventLogList = new List<SVMXA360__ApplicationEventLog__e>();
            
            SVMXA360__ApplicationEventLog__e applicationEventLog; 
            
            for (ApplicationEventLog eachLog : eventLogList) {
                
                applicationEventLog = new SVMXA360__ApplicationEventLog__e();
                applicationEventLog.SVMXA360__ApplicationName__c = eachLog.applicationName;
                applicationEventLog.SVMXA360__LogType__c = eachLog.logLevel;
                applicationEventLog.SVMXA360__Message__c = eachLog.message;
                applicationEventLog.SVMXA360__UserId__c = eachLog.userId;
                applicationEventLog.SVMXA360__SourceRecordId__c = eachLog.sourceRecordId;
                applicationEventLog.SVMXA360__OperationType__c = eachLog.operationType;
                
                applicationEventLogList.add(applicationEventLog);
                
            }
            
            if( !Test.isRunningTest() ) {
                
                // Publish events to event bus.
                Database.SaveResult[] saveResultList = Eventbus.publish(applicationEventLogList);
                
                for (Database.SaveResult eachResult : saveResultList ) {
                    if( eachResult.isSuccess() ) {
                        System.debug( LoggingLevel.DEBUG, 'Successfully published event.' );
                    } else {
                        for( Database.Error error : eachResult.getErrors() ) {
                            System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + error.getStatusCode() + ' - ' + error.getMessage() );
                        }
                    }
                }
                
            }
            
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + e.getMessage() + '\n' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'publish() - exit' );
        }
    }
 
}