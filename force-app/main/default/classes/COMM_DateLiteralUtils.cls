/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A class with utility methods to perform operations around salesforce 
 * date literals.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       24 May 2020     Created.
 *****************************************************************************************************/
public with sharing class COMM_DateLiteralUtils {
  
    /**
     * This method is used to retrieve date/datetime instance for requested literal.
     * 
     * @param displaytype The enum Schema.Displaytype.Date or Schema.Displaytype.Datetime 
     * 					instance to be retrieved from literal.
     * @param literal Salesforce date literals for with date/datetime instance to be retrieved.
     */
    public static Object getDateForLiteral( Schema.Displaytype displaytype, final String literal ) {
        
        System.debug( LoggingLevel.FINEST, 'getDateForLiteral() - enter; displaytype= ' + displaytype + '; literal= ' + literal );
        
        Object dateInstance;
        
        try {
            
            // Check for valid parameters.
            if( displaytype == null || String.isBlank( literal ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getDateForLiteral() : Invalid argument. displaytype= ' + displaytype + '; literal= ' + literal );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve date/datetime depending on requested Displaytype.
            switch on displaytype {
                
                when Date {
                    dateInstance = getDateTimeForLiteral(literal).date();
                }
                when Datetime {
                    dateInstance = getDateTimeForLiteral(literal);
                }
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'getDateForLiteral() : unsupported type. literal= ' + literal );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getDateForLiteral() : Failed to create datetime instance. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getDateForLiteral() - exit; dateInstance= ' + dateInstance );
        }
        
        return dateInstance;
    }
    
    /**
     * This method is used to retrieve date instance for requested literal.
     * 
     * @param literal Salesforce date literals for with date instance to be retrieved.
     */
    public static Date getDateForLiteral( final String literal ) {
        
        System.debug( LoggingLevel.FINEST, 'getDateForLiteral() - enter; literal= ' + literal );
        
        Date dateInstance;
        
        try {
            // Check for valid literal parameter
            if( String.isBlank( literal ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getDateTimeForLiteral() : Invalid argument. literal= ' + literal );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            dateInstance = getDateTimeForLiteral(literal).date();
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getDateForLiteral() : Failed to create datetime instance. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getDateForLiteral() - exit; dateInstance= ' + dateInstance );
        }
        
        return dateInstance;
    }
    
    /**
     * This method is used to retrieve datetime instance for requested literal.
     * 
     * @param literal Salesforce date literals for with datetime instance to be retrieved.
     */
    public static Datetime getDateTimeForLiteral( final String literal ) {
        
        System.debug( LoggingLevel.FINEST, 'getDateTimeForLiteral() - enter; literal= ' + literal );
        
        Datetime datetimeInstance;
        
        try {
            
            // Check valid literal string argument.
            if( String.isBlank( literal ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getDateTimeForLiteral() : Invalid argument. literal= ' + literal );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve date for requested literal.
            switch on literal.toUpperCase() {
                
                when 'FSVMXNOW' {
                    datetimeInstance = Datetime.now();
                }
                when 'FSVMXTODAY' {
                    datetimeInstance = Datetime.newInstance( System.today(), Time.newInstance(0, 0, 0, 0));
                }
                when 'FSVMXYESTERDAY' {
                    datetimeInstance = Datetime.newInstance( System.today() - 1, Time.newInstance(0, 0, 0, 0));
                }
                when 'FSVMXTOMORROW' {
                    datetimeInstance = Datetime.newInstance( System.today() + 1, Time.newInstance(0, 0, 0, 0));
                }
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'getDateTimeForLiteral() : unsupported type. literal= ' + literal );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getDateTimeForLiteral() : Failed to create datetime instance. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getDateTimeForLiteral() - exit; datetimeInstance= ' + datetimeInstance );
        }
        
        return datetimeInstance;
    }
    
    /**
     * This method is to verify requested datetime instance is with in the range of 
     * requested literal.
     * 
     * @param dateInstance Date instance for which range to be verified.
     * @param literal Salesforce literal on which the date instance range to be verified.
     */
    public static Boolean isDateInRange( final Datetime dateInstance, final String literal ) {
        
        System.debug( LoggingLevel.FINEST, 'isDateInRange() - enter; dateInstance= ' + dateInstance + '; literal= ' + literal );
        
        Boolean isDateInRange = false;
        
        try {
            
            // Check for valid datetime instance and literal parameters.
            if( dateInstance == null || String.isBlank( literal ) ) {
                
                System.debug( LoggingLevel.ERROR, 'isDateInRange() : Invalid argument. dateInstance= ' + dateInstance + '; literal= ' + literal );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Verify whether requested datetime instance in range with passed literal.
            isDateInRange = isDateInRange( dateInstance.date(), literal );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'isDateInRange() : Failed to perform range date check. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'isDateInRange() - exit; isDateInRange= ' + isDateInRange );
        }
        
        return isDateInRange;
    }
    
    /**
     * This method is to verify requested date instance is with in the range of 
     * requested literal.
     * 
     * @param dateInstance Date instance for which range to be verified.
     * @param literal Salesforce literal on which the date instance range to be verified.
     */
    public static Boolean isDateInRange( final Date dateInstance, final String literal ) {
        
        System.debug( LoggingLevel.FINEST, 'isDateInRange() - enter; dateInstance= ' + dateInstance + '; literal= ' + literal );
        
        Boolean isDateInRange = false;
        
        try {
            
            // Check for valid date instance and literal parameters.
            if( dateInstance == null || String.isBlank( literal ) ) {
                
                System.debug( LoggingLevel.ERROR, 'isDateInRange() : Invalid argument. dateInstance= ' + dateInstance + '; literal= ' + literal );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Verify whether requested date instance in range with passed literal.
            switch on literal.toUpperCase() {
           
                when 'FSVMXNOW','FSVMXTODAY' {
                    isDateInRange = ( dateInstance == Date.today() );
                }
                when 'FSVMXTOMORROW' {
                    isDateInRange = ( dateInstance == Date.today().addDays(1) );
                }
                when 'FSVMXYESTERDAY' {
                    isDateInRange = ( dateInstance == Date.today().addDays(-1) );
                }
                when 'FSVMXTHIS_WEEK' {
                    isDateInRange = ( dateInstance >= Date.today().toStartOfWeek() && dateInstance < Date.today().toStartOfWeek().addDays(7) );
                }
                when 'FSVMXLAST_WEEK' {
                    isDateInRange = ( dateInstance < Date.today().toStartOfWeek() && dateInstance >= Date.today().toStartOfWeek().addDays(-7) );
                }
                when 'FSVMXNEXT_WEEK' {
                    isDateInRange = ( dateInstance >= Date.today().toStartOfWeek().addDays(7) && dateInstance < Date.today().toStartOfWeek().addDays(14) );
                }
                when 'FSVMXTHIS_MONTH' {
                    isDateInRange = ( dateInstance >= Date.today().toStartOfMonth() && dateInstance < Date.today().toStartOfMonth().addMonths(1) );
                }
                when 'FSVMXLAST_MONTH' {
                    isDateInRange = ( dateInstance < Date.today().toStartOfMonth() && dateInstance >= Date.today().toStartOfMonth().addMonths(-1) );
                }
                when 'FSVMXNEXT_MONTH' {
                    isDateInRange = ( dateInstance >= Date.today().toStartOfMonth().addMonths(1) && dateInstance < Date.today().toStartOfMonth().addMonths(2) );
                }
                when 'FSVMXNEXT_90_DAYS' {
                    isDateInRange = ( dateInstance >= Date.today() && dateInstance < Date.today().addDays(90) );
                }
                when 'FSVMXLAST_90_DAYS' {
                    isDateInRange = ( dateInstance < Date.today() && dateInstance >= Date.today().addDays(-90) );
                }
                when else {
                    
                    // Handle parametered literals like NEXT_N_WEEKS:3
                    final List<String> literalSplit  = literal.split(':');
                    
                    if( literal.indexOf(':') == -1 || !literalSplit.get(1).isNumeric() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'isDateInRange() : unsupported type. literal= ' + literal );
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                    }
                    
                    isDateInRange = isDateInRange( dateInstance, literalSplit.get(0), Integer.valueOf( literalSplit.get(1) ) );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'isDateInRange() : Failed to perform range date check. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'isDateInRange() - exit; isDateInRange= ' + isDateInRange );
        }
        
        return isDateInRange;
    }
    
    /**
     * This method is to verify requested date instance is with in the range of 
     * requested literal format like NEXT_n_DAYS:2.
     * 
     * @param dateInstance Date instance for which range to be verified.
     * @param literal Salesforce literal on which the date instance range to be verified.
     * @param n Number of days/weeks/months for which date range to be compared.
     */
    private static Boolean isDateInRange( final Date dateInstance, final String literal, final Integer n ) {
        
        System.debug( LoggingLevel.FINEST, 'isDateInRange() - enter; dateInstance= ' + dateInstance + '; literal= ' + literal + '; n= ' + n );
        
        Boolean isDateInRange = false;
        
        try {
                        
            switch on literal.toUpperCase() {
           
                when 'FSVMXLAST_N_DAYS' {
                    isDateInRange = ( dateInstance < Date.today() && dateInstance >= Date.today().addDays( -1 * n ) );
                }
                when 'FSVMXNEXT_N_DAYS' {
                    isDateInRange = ( dateInstance >= Date.today() && dateInstance < Date.today().addDays( n ) );
                }
                when 'FSVMXNEXT_N_WEEKS' {
                    isDateInRange = ( dateInstance >= Date.today().toStartOfWeek().addDays(7) && dateInstance < Date.today().toStartOfWeek().addDays( n * 7 ) );
                }
                when 'FSVMXLAST_N_WEEKS' {
                    isDateInRange = ( dateInstance < Date.today().toStartOfWeek() && dateInstance >= Date.today().toStartOfWeek().addDays( -1 * n * 7 ) );
                }
                when 'FSVMXNEXT_N_MONTHS' {
                    isDateInRange = ( dateInstance >= Date.today().toStartOfMonth().addMonths(1) && dateInstance < Date.today().toStartOfMonth().addMonths(n) );
                }
                when 'FSVMXLAST_N_MONTHS' {
                    isDateInRange = ( dateInstance < Date.today().toStartOfMonth() && dateInstance >= Date.today().toStartOfMonth().addMonths( -1 * n ) );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'isDateInRange() : unsupported type. literal= ' + literal );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'isDateInRange() : Failed to perform range date check. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'isDateInRange() - exit; isDateInRange= ' + isDateInRange );
        }
        
        return isDateInRange;
    }
  
    /**
     * This method is to verify requested date instance is with in the range of 
     * requested literal.
     * 
     * @param dateInstance Date instance for which range to be verified.
     * @param literal Salesforce literal on which the date instance range to be verified.
     * @param operator The operator for which the date instance needs to be evaluated
     */
    public static Boolean isDateInRange( final Date dateInstance, final String literal, String operator ) {
        
        System.debug( LoggingLevel.FINEST, 'isDateInRange() - enter; dateInstance= ' + dateInstance + '; literal= ' + literal );
        
        Boolean isDateInRange = false;
        
        try {
            
            // Check for valid date instance and literal parameters.
            if( dateInstance == null || String.isBlank( literal ) ) {
                
                System.debug( LoggingLevel.ERROR, 'isDateInRange() : Invalid argument. dateInstance= ' + dateInstance + '; literal= ' + literal );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Verify whether requested date instance in range with passed literal.
            switch on literal.toUpperCase() {
           
                when 'FSVMXNOW','FSVMXTODAY' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today(),Date.today() );
                }
                when 'FSVMXTOMORROW' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().addDays(1),Date.today().addDays(1) );
                }
                when 'FSVMXYESTERDAY' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().addDays(-1),Date.today().addDays(-1) );
                }
                when 'FSVMXTHIS_WEEK' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfWeek(),Date.today().toStartOfWeek().addDays(7) );
                }
                when 'FSVMXLAST_WEEK' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfWeek().addDays(-7),Date.today().toStartOfWeek().addDays(-1) );
                }
                when 'FSVMXNEXT_WEEK' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfWeek().addDays(8),Date.today().toStartOfWeek().addDays(14) );
                }
                when 'FSVMXTHIS_MONTH' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfMonth(),Date.today().toStartOfMonth().addMonths(1) );
                }
                when 'FSVMXLAST_MONTH' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfMonth().addMonths(-1),Date.today().toStartOfMonth().addDays(-1) );
                }
                when 'FSVMXNEXT_MONTH' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfMonth().addMonths(1),Date.today().toStartOfMonth().addDays(2) );
                }
                when 'FSVMXNEXT_90_DAYS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().addDays(1),Date.today().addDays(90) );
                }
                when 'FSVMXLAST_90_DAYS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().addDays(-90),Date.today().addDays(-1) );
                }
                when else {
                    
                    // Handle parametered literals like NEXT_N_WEEKS:3
                    final List<String> literalSplit  = literal.split(':');
                    
                    if( literal.indexOf(':') == -1 || !literalSplit.get(1).isNumeric() ) {
                        
                        System.debug( LoggingLevel.ERROR, 'isDateInRange() : unsupported type. literal= ' + literal );
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                    }
                    
                    isDateInRange = isDateInRange( dateInstance, literalSplit.get(0), Integer.valueOf( literalSplit.get(1)), operator );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'isDateInRange() : Failed to perform range date check. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'isDateInRange() - exit; isDateInRange= ' + isDateInRange );
        }
        
        return isDateInRange;
    }
    
    /**
     * This method is to verify requested date instance is with in the range of 
     * requested literal format like NEXT_n_DAYS:2.
     * 
     * @param dateInstance Date instance for which range to be verified.
     * @param literal Salesforce literal on which the date instance range to be verified.
     * @param n Number of days/weeks/months for which date range to be compared.
     */
    private static Boolean isDateInRange( Date dateInstance, String literal, Integer n, String operator ) {
        
        System.debug( LoggingLevel.FINEST, 'isDateInRange() - enter; dateInstance= ' + dateInstance + '; literal= ' + literal + '; n= ' + n );
        
        Boolean isDateInRange = false;
        
        try {
                        
            switch on literal.toUpperCase() {
                
                when 'FSVMXLAST_N_DAYS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().addDays( -1 * n ),Date.today().addDays(-1) );
                }
                when 'FSVMXNEXT_N_DAYS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today(),Date.today().addDays( n ) );
                }
                when 'FSVMXNEXT_N_WEEKS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfWeek().addDays(8),Date.today().toStartOfWeek().addDays(n * 7) );
                }
                when 'FSVMXLAST_N_WEEKS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfWeek().addDays( -1 * n * 7 ),Date.today().toStartOfWeek() );
                }
                when 'FSVMXNEXT_N_MONTHS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfMonth().addMonths(1),Date.today().toStartOfMonth().addMonths(n) );
                }
                when 'FSVMXLAST_N_MONTHS' {
                    isDateInRange = processLiteral( dateInstance,operator,Date.today().toStartOfMonth().addMonths( -1 * n ),Date.today().toStartOfMonth() );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'isDateInRange() : unsupported type. literal= ' + literal );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'isDateInRange() : Failed to perform range date check. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'isDateInRange() - exit; isDateInRange= ' + isDateInRange );
        }
        
        return isDateInRange;
    }

    /**
    * This method is used to process Now and Today Literal.
    */ 
    private static Boolean processLiteral( Date dateInstance, String operator, Date literalStartDate, Date literalEndDate) {
        System.debug( LoggingLevel.FINEST, 'processWeekLiteral() - enter; dateInstance= ' + dateInstance  );
        
        Boolean isDateInRange = false;
        
        try {
            
            // Check for valid date instance and literal parameters.
            if( dateInstance == null) {
                
                System.debug( LoggingLevel.ERROR, 'processWeekLiteral() : Invalid argument. dateInstance= ' + dateInstance  );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Verify whether requested date instance in range with passed literal.
            switch on operator.toUpperCase() {
           
                when 'GT' {
                    isDateInRange = ( dateInstance > literalEndDate );
                }
                when 'LT' {
                    isDateInRange = ( dateInstance < literalStartDate );
                }
                when 'GE' {
                    isDateInRange = ( dateInstance >= literalStartDate );
                }
                when 'LE' {
                    isDateInRange = ( dateInstance <= literalEndDate );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'processWeekLiteral() : unsupported operator. operator= ' + operator );
                	throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED );
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'processWeekLiteral() : Failed to perform range date check. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'processWeekLiteral() - exit; isDateInRange= ' + isDateInRange );
        }
        
        return isDateInRange;
    }

    /**
    * This method is used to process end date based on duration and unit.
    */ 
    public static Date calculateEndDate( final Date startDate, final Integer duration, final String unitOfTime ) {
        
        System.debug( LoggingLevel.DEBUG, 'calculateEndDate() - enter; duration= ' + duration + '; unitOfTime= ' + unitOfTime );
        
        Date endDate = startDate;
        
        try {
            switch on unitOfTime {
                
                when 'Days' {
                    //endDate = Datetime.newInstance( System.currentTimeMillis() ).addDays(duration).date();
                    endDate = startDate.addDays(duration);
                }
                when 'Weeks' {
                    //endDate = Datetime.newInstance( System.currentTimeMillis() ).addDays( duration * 7 ).date();
                    endDate = startDate.addDays( duration * 7 );
                }
                when 'Months' {
                    //endDate = Datetime.newInstance( System.currentTimeMillis() ).addMonths(duration).date();
                    endDate = startDate.addMonths(duration);
                }
                when 'Years' {
                    //endDate = Datetime.newInstance( System.currentTimeMillis() ).addYears(duration).date();
                    endDate = startDate.addYears(duration);
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'calculateEndDate() - exit; endDate= ' + endDate );
        }
        
        return endDate;
    }

}