@isTest
public class COMM_RecurrenceRuleHelper_UT {
    public static testMethod void recurrenceParser_DailyTest(){
    	Test.startTest();
        datetime fromDate = datetime.newInstanceGmt(2023, 7, 12);
        String rruleString = 'FREQ=DAILY;INTERVAL=2;';
        System.debug('fromDate Daily ' + fromDate);
		DateTime nextOccurence = COMM_RecurrenceRuleHelper.getNextDateFromRRule(rruleString, fromDate);
		System.assertEquals(datetime.newInstanceGmt(2023, 7, 14), nextOccurence.dateGMT());       
    }
    
    public static testMethod void recurrenceParser_WeeklyTest(){
    	Test.startTest();
        datetime fromDate = datetime.newInstanceGmt(2023, 7, 12);
        System.debug('fromDate Weekly ' + fromDate);
		String rruleString = 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TU,TH;';
		DateTime nextOccurence = COMM_RecurrenceRuleHelper.getNextDateFromRRule(rruleString, fromDate);
		System.assertEquals(datetime.newInstanceGmt(2023, 7, 13), nextOccurence.dateGMT()); 
        Test.stopTest();
    }
    
    public static testMethod void recurrenceParser_MonthlyTest(){
    	Test.startTest();
        datetime fromDate = datetime.newInstanceGmt(2023, 7, 16);
        System.debug('fromDate Monthly ' + fromDate);
        String rruleString = 'FREQ=MONTHLY;INTERVAL=2;BYDAY=SU;BYSETPOS=-1;';
		DateTime nextOccurence = COMM_RecurrenceRuleHelper.getNextDateFromRRule(rruleString, fromDate);
		System.assertEquals(datetime.newInstanceGmt(2023, 7, 30), nextOccurence.dateGMT()); 
        Test.stopTest();
    }
    
    public static testMethod void recurrenceParser_YearlyTest(){
    	Test.startTest();
        datetime fromDate = datetime.newInstanceGmt(2023, 7, 16);
        System.debug('fromDate Yearly ' + fromDate);
        String rruleString = 'FREQ=YEARLY;BYSETPOS=2;BYDAY=TU;BYMONTH=2;';
		DateTime nextOccurence = COMM_RecurrenceRuleHelper.getNextDateFromRRule(rruleString, fromDate);
		System.assertEquals(datetime.newInstanceGmt(2024, 2, 13), nextOccurence.dateGMT()); 
        Test.stopTest();
    }
}