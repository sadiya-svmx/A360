/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to have code classes and enums which are used across all 
 * apex classes.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       07 May 2020     Created.
 *****************************************************************************************************/
public class SvmxSystem {
    
    public static Boolean isRunningPostInstall = false;
    
    /**
     * Enum to categorize FLS access type 
     */
    public enum FLSAccessType { Accessible, Createable, Updateable, Upserteable }
    
    /**
     * Custom exception used for generic errors.
     */
    public virtual class SvmxBaseException extends Exception {
    }
    
    /**
     * Custom exception used for generic errors.
     */
    public class SvmxNestedException extends SvmxBaseException {
        Common.DatabaseResult databaseResult = new Common.DatabaseResult();
        public SvmxNestedException (Common.DatabaseResult databaseResult) {
            super();
            this.databaseResult = databaseResult;
        }

        public Common.DatabaseResult getDatabaseResult () {
            return this.databaseResult;
        }
    }

    /**
     * Custom exception used when exceptions require a collection of errors.
     */
    public class SvmxServiceException extends SvmxBaseException {
        public List<Common.ServiceError> errors {get;set;}
    }
    
    /**
     * Custom exception which is used in FLS check.
     */
    public class FLSException extends SvmxBaseException {
    }

    /**
     *  Static method to get date format in user locale
     */
    public static String getUserDateFormat (){
        date localDate = date.newinstance(2020, 10, 30);
        String dateFormat = string.valueof(localDate.format());
        dateFormat = dateFormat.replace('10','MM').replace('30','DD').replace('2020','YYYY');      
        return dateFormat; 
    }

    /**
     *  Static method to get user time zone offset value
     */
    public static String getUserTimezoneOffset (){
        String offsetSign = '+';
        String hours = '00';
        String minutes = '00';
		Integer timeZoneOffsetMiliSec = UserInfo.getTimeZone().getOffset(DateTime.now());
        if(timeZoneOffsetMiliSec < 0) {
            offsetSign = '-';
        }

        Integer timeZoneOffsetMinutes = Integer.valueOf((math.abs(timeZoneOffsetMiliSec))/60000);
        if(timeZoneOffsetMinutes >= 60){
            hours = String.valueOf(timeZoneOffsetMinutes/60);
            minutes = String.valueOf(math.mod(timeZoneOffsetMinutes, 60));
        }else{
            minutes = String.valueOf(timeZoneOffsetMinutes);
        }
        
        if(hours != null && hours.length() < 2){
            hours = '0' + hours;
        }
            
        if(minutes != null && minutes.length() < 2){
            minutes = '0' + minutes;
        }
		
        return offsetSign + hours + ':' + minutes;
    }

    /** 
    *  Static method to get decimal separator for login user
    */
    public Static Map<String,String> getDecimalSeparator(){
		Decimal decValue = 1000.11;
		String userLocaleFormat = decValue.format();
		String thousandSeparator = userLocaleFormat.substring(1,2);
		String decimalSeparator = userLocaleFormat.substring(5,6);
		return new Map<String,String>{'TS' => thousandSeparator, 'DS' => decimalSeparator};
	}
}