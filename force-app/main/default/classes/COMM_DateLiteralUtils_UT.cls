@isTest
public class COMM_DateLiteralUtils_UT {
    static testmethod void testGetDateForLiteral_Date() {
        
        Test.startTest();
        
        Object dateInstance = COMM_DateLiteralUtils.getDateForLiteral( Schema.Displaytype.Date, 'FSVMXTODAY');
        
        System.assert( dateInstance != null );
        System.assert( dateInstance instanceof Date );
        System.assert( dateInstance == Date.today() );
        
        Test.stopTest();
    }
    
    static testmethod void testGetDateForLiteral_Datetime() {
        
        Test.startTest();
        
        Object dateInstance = COMM_DateLiteralUtils.getDateForLiteral( Schema.Displaytype.Datetime, 'FSVMXTODAY');
        
        System.assert( dateInstance != null );
        System.assert( dateInstance instanceof Datetime );
        
        Test.stopTest();
    }
    
    static testmethod void testGetDateForLiteral_invalidDisplayType() {
        
        Test.startTest();
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral( null, 'FSVMXTODAY');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral( Schema.Displaytype.Integer, 'FSVMXTODAY');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetDateForLiteral_invalidLiteral() {
        
        Test.startTest();
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral( Schema.Displaytype.Date, null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral( Schema.Displaytype.Date, '');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral( Schema.Displaytype.Date, 'invalid');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetDateForLiteral() {
        
        Test.startTest();
        
        Date dateInstance = COMM_DateLiteralUtils.getDateForLiteral('FSVMXTODAY');
        
        System.assert( dateInstance != null );
        System.assert( dateInstance == Date.today() );
        
        Test.stopTest();
    }
    
    static testmethod void testGetDateForLiteral_invalidLiterals() {
        
        Test.startTest();
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateForLiteral('invalid');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetDateTimeForLiteral() {
        
        Test.startTest();
        {
            Datetime dateInstance = COMM_DateLiteralUtils.getDateTimeForLiteral('FSVMXNOW');
            System.assert( dateInstance != null );
            System.assert( dateInstance.date() == Date.today() );
        }
        {
            Datetime dateInstance = COMM_DateLiteralUtils.getDateTimeForLiteral('FSVMXTODAY');
            System.assert( dateInstance != null );
            System.assert( dateInstance.date() == Date.today() );
        }
        {
            Datetime dateInstance = COMM_DateLiteralUtils.getDateTimeForLiteral('FSVMXYESTERDAY');
            System.assert( dateInstance != null );
            System.assert( dateInstance.date() == Date.today().addDays(-1) );
        }
        {
            Datetime dateInstance = COMM_DateLiteralUtils.getDateTimeForLiteral('FSVMXTOMORROW');
            
            System.assert( dateInstance != null );
            System.assert( dateInstance.date() == Date.today().addDays(1) );
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetDatetimeForLiteral_invalidLiterals() {
        
        Test.startTest();
        
        try {
            COMM_DateLiteralUtils.getDateTimeForLiteral(null);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateTimeForLiteral('');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.getDateTimeForLiteral('invalid');
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testIsDateInRange() {
        
        Test.startTest();
        
        System.assert( COMM_DateLiteralUtils.isDateInRange( System.now(), 'FsvmxNow') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today(), 'FsvmxNow') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today(), 'FsvmxToday') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addDays(-1), 'FsvmxYesterday') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addDays(1), 'FsvmxTomorrow') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today(), 'FsvmxTHIS_WEEK') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addDays(-7), 'FsvmxLAST_WEEK') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addDays(7), 'FsvmxNEXT_WEEK') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today(), 'FsvmxTHIS_MONTH') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(-1), 'FsvmxLAST_MONTH') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(1), 'FsvmxNEXT_MONTH') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(-1), 'FsvmxLAST_90_DAYS') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(1), 'FsvmxNEXT_90_DAYS') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(-1), 'FsvmxLAST_N_DAYS:40') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(1), 'FsvmxNEXT_N_DAYS:40') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(-1), 'FsvmxLAST_N_WEEKS:6') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(1), 'FsvmxNEXT_N_WEEKS:6') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(-1), 'FsvmxLAST_N_MONTHS:2') );
        System.assert( COMM_DateLiteralUtils.isDateInRange( Date.today().addMonths(1), 'FsvmxNEXT_N_MONTHS:2') );
        
        Test.stopTest();
    }
    
    static testmethod void testIsDateInRange_InvalidParam() {
        
        Test.startTest();
        
        try {
            COMM_DateLiteralUtils.isDateInRange( System.now(), null);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        try {
            COMM_DateLiteralUtils.isDateInRange( Date.today(), null);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        try {
            COMM_DateLiteralUtils.isDateInRange( System.now(), 'FsvmxLAST_N_DAYS:i');
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        try {
            COMM_DateLiteralUtils.isDateInRange( System.now(), 'Invalid:2');
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
}