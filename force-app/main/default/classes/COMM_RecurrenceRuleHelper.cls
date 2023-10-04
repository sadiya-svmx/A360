/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief Recurrence Rule Parser.
 * 
 * @author Sachin S
 * @version 1.0
 * @since 2023
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                11 July 2023     Created.
 *****************************************************************************************************/
public class COMM_RecurrenceRuleHelper {

    private static Map<String, Integer> WeekdayMap = new Map<String, Integer>{
        'SU' => 1, 'MO' => 2, 'TU' => 3, 'WE' => 4, 'TH' => 5, 'FR' => 6, 'SA' => 7
    };
   
    public class RRuleComponent {
        
        public Datetime fromDate;
        public String frequency;
        public Integer interval;
        public String[] byDays;
        public Integer byMonth;
        public Integer bySetpos;
        public Integer byMonthDay;
    }
     
    public static Datetime getNextDateFromRRule( final String rruleString ) {
        return getNextDateFromRRule( rruleString, System.now() );
    }
    
    public static Datetime getNextDateFromRRule(String rruleString, Datetime fromDate) {
        
        final Map<String, String> rruleComponents = parseComponents( rruleString );
        
        final RRuleComponent rruleComponent = new RRuleComponent();
        rruleComponent.fromDate = fromDate;
        rruleComponent.frequency = rruleComponents.get('FREQ');
        rruleComponent.interval = rruleComponents.get('INTERVAL') != null ? Integer.valueOf( rruleComponents.get('INTERVAL')) : 1;
        rruleComponent.byDays = (rruleComponents.get('BYDAY') != null ) ? rruleComponents.get('BYDAY').split(',') : new String[]{};
        rruleComponent.byMonth = (rruleComponents.get('BYMONTH') != null ) ? Integer.valueOf( rruleComponents.get('BYMONTH') ) : 1;
        rruleComponent.bySetpos = (rruleComponents.get('BYSETPOS') != null) ? Integer.valueOf( rruleComponents.get('BYSETPOS') ) : 0;
        rruleComponent.byMonthDay = (rruleComponents.get('BYMONTHDAY') != null ) ? Integer.valueOf( rruleComponents.get('BYMONTHDAY') ) : 1;
        
        try {
            return getNextDate( rruleComponent );
        } catch (exception ex) {
            System.debug(LoggingLevel.info, 'Invalid Recurrence Pattern ' +  rruleString + ' ' + ex.getMessage());
            return null;
        }
    }
    
    private static Map<String, String> parseComponents( final String rruleString ) {
        
        final Map<String, String> rruleComponents = new Map<String, String>();
        
        for( String component : rruleString.split(';') ) {
            
            final List<String> keyValue = component.split('=');
            
            if (keyValue.size() == 2) {
                rruleComponents.put(keyValue[0], keyValue[1]);
            }
        }
        
        return rruleComponents;
    }
    
    private static Datetime getNextDailyDate( final Datetime fromDate, final Integer interval ) {
        Datetime dt = Datetime.now().dateGMT();
        if (fromDate != null) {
            dt = fromDate.addDays(interval);
        }
        return dt;
    }
    
    private static Datetime getNextWeeklyDate( final RRuleComponent rruleComponent ) {
        String[] byDays = rruleComponent.byDays;
        Datetime fromDate = rruleComponent.fromDate != null ? rruleComponent.fromDate : Datetime.now().dateGMT();     
        Integer targetDayOfWeek = 1;
        Integer daysToAdd = 0;
        Datetime nextDate;
        Integer daysDiff = 0;
        Integer firstDayOfWeek = Integer.valueOf(fromDate.formatGMT('u'));
        firstDayOfWeek = Math.mod(firstDayOfWeek + 1, 7);
        for (String day : byDays) {
            targetDayOfWeek = WeekdayMap.get(day);
            daysDiff = targetDayOfWeek - firstDayOfWeek;
            if (daysDiff >= 0){
                daysToAdd = Math.mod((targetDayOfWeek - firstDayOfWeek + 7), 7);
                nextDate = fromDate.addDays(daysToAdd);
                return nextDate;
            } 
        }
        targetDayOfWeek = WeekdayMap.get(byDays[0]);
        daysDiff = targetDayOfWeek - firstDayOfWeek;
        daysToAdd = Math.mod((daysDiff + 7), 7);
        daysToAdd = daysDiff < 0 ? (daysToAdd - 7) : daysToAdd;
        System.debug('daysToAdd ' + daysToAdd);
        nextDate = fromDate.addDays(daysToAdd + (rruleComponent.interval) * 7);
        return nextDate;
    }
    
    public static Datetime getNextMonthlyDate( final RRuleComponent rruleComponent ) {
        
        Integer bySetpos = rruleComponent.bySetpos;
        Integer byMonthDay = rruleComponent.byMonthDay;
        Datetime fromDate = rruleComponent.fromDate != null ? rruleComponent.fromDate : Datetime.now().dateGMT();     
        Integer interval = rruleComponent.interval;
        String[] byDays = rruleComponent.byDays;

        Datetime nextDate = Datetime.newInstance(fromDate.year(), fromDate.month(), byMonthDay, fromDate.hour(), fromDate.minute(), fromDate.second());
		DateTime tempDate = getDateBasedOnSetPosDay(byDays, bySetpos, nextDate);
        if (tempDate < fromDate) {
			nextDate = nextDate.addMonths(interval);
           	tempDate = getDateBasedOnSetPosDay(byDays, bySetpos, nextDate);
		}
        return tempDate;
    }
    
    public static Datetime getNextYearlyDate( final RRuleComponent rruleComponent ) {
        
        Integer bySetpos = rruleComponent.bySetpos;
        Datetime fromDate = rruleComponent.fromDate != null ? rruleComponent.fromDate : Datetime.now().dateGMT(); 
        Integer byMonth = rruleComponent.byMonth;
        Integer byMonthDay = rruleComponent.byMonthDay;
        Integer interval = rruleComponent.interval;
        String[] byDays = rruleComponent.byDays;

        Datetime nextDate = Datetime.newInstance(fromDate.year(), byMonth, byMonthDay, fromDate.hour(), fromDate.minute(), fromDate.second());
        DateTime tempDate = getDateBasedOnSetPosDay(byDays, bySetpos, nextDate);

        if (tempDate < fromDate) {
        	nextDate = nextDate.addYears(interval);
            tempDate = getDateBasedOnSetPosDay(byDays, bySetpos, nextDate);
		}
        return tempDate;

    }
    
    private static Integer getNextWeekday( final Integer currentWeekday, final String[] byDays) {
        
        Integer weekday = (byDays != null && byDays.size() > 0 ) ? WeekdayMap.get(byDays[0]) : 1;
        
        if( byDays != null && byDays.size() > 0 ) {
            
            for( String byDay : byDays ) {
                
                if( WeekdayMap.get(byDay) > currentWeekday ) {
                    weekday = WeekdayMap.get(byDay);
                }
            }
        }
        
        return weekday;
    }
    
    private static DateTime getDateBasedOnSetPosDay (String[] byDays, Integer bySetpos, dateTime givenDate) {
        if (!byDays.isEmpty()){
            Integer targetDayOfWeek = WeekdayMap.get(byDays[0]);
            if(bySetpos > 0) {
                Integer firstDayOfWeek = Integer.valueOf(givenDate.formatGMT('u'));
                firstDayOfWeek = Math.mod(firstDayOfWeek + 1, 7);
				Integer daysToAdd = Math.mod((targetDayOfWeek - firstDayOfWeek + 7), 7);
                System.debug('daysToAdd ' + daysToAdd);
                givenDate = givenDate.addDays(daysToAdd + (bySetpos - 1) * 7);
            } else {
                Integer year = givenDate.year();  // Replace with the desired year
                Integer month = givenDate.month();
                Datetime lastDayOfMonth = Datetime.newInstanceGmt(year, month, Date.daysInMonth(year, month));
                Integer lastDayOfWeek = Integer.valueOf(lastDayOfMonth.formatGMT('u'));
                lastDayOfWeek = Math.mod(lastDayOfWeek + 1, 7);
                Integer daysToSubtract = Math.mod((lastDayOfWeek - targetDayOfWeek + 7), 7);
                givenDate = lastDayOfMonth.addDays(-daysToSubtract);
            }
        }   
        
        return givenDate;
    }

    private static Datetime getNextDate( final RRuleComponent rruleComponent ) {
        
        Datetime nextDate;
        
        switch on rruleComponent.frequency {
            
            when 'DAILY' {
                nextDate = getNextDailyDate( rruleComponent.fromDate, rruleComponent.interval );
            }
            when 'WEEKLY' {
                nextDate = getNextWeeklyDate(rruleComponent);
            }
            when 'MONTHLY' {
                nextDate = getNextMonthlyDate(rruleComponent);
            }
            when 'YEARLY' {
                nextDate = getNextYearlyDate(rruleComponent);
            }
        }
        
        return nextDate;
    }
}