@IsTest
public class COMM_DatabaseUtils_UT {
    
    @testSetup public static void setup() {
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMapping__c', 5);
    }
    
    testmethod static void testQueryRecords_id() {
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMapping = [SELECT Id FROM SVMXA360__CONF_ObjectMapping__c LIMIT 1];
        
        Config.FilterCriteria filterCriteria = new Config.FilterCriteria();
        filterCriteria.id = objectMapping.id;
        filterCriteria.objectName = 'SVMXA360__CONF_ObjectMapping__c';
        filterCriteria.fields = new List<String>{'id'};
        
        List<SObject> recordList = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria);
        
        System.assert( recordList != null );
        System.assert( recordList.size() > 0 );
        
        Test.stopTest();
    }

    testmethod static void testGetPackageVersion() {
    
        Test.startTest();
        
        String versionNumber = COMM_DatabaseUtils.getInstance().getPackageVersion();
        
        System.assert( versionNumber != null );
        
        Test.stopTest();
    }
    
    testmethod static void testQueryRecords_like() {
        
        Test.startTest();
        
        Config.FilterCriteria filterCriteria = new Config.FilterCriteria();
        filterCriteria.searchTerm = 'ObjectMapping';
        filterCriteria.objectName = 'SVMXA360__CONF_ObjectMapping__c';
        filterCriteria.fields = new List<String>{'id'};
        filterCriteria.whereClause = 'Name != null';
        
        List<SObject> recordList = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria);
        
        System.assert( recordList != null );
        System.assert( recordList.size() > 0 );
        
        Test.stopTest();
    }

    testmethod static void testFetchApplicationNavigationType() {
        
        Test.startTest();
        try {
            Common.ServiceResponse serviceResponse = COMM_DatabaseUtils.fetchApplicationNavigationType();
        }
        catch( Exception e ){
            System.assert( true );
        }
        
        Test.stopTest();
    }
    
    testmethod static void testQueryRecords_missingParameter() {
        
        Test.startTest();
        
        try {
            COMM_DatabaseUtils.getInstance().queryRecords(null);
            System.assert( false );
        }
        catch( Exception e ){
            System.assert( true );
        }
        
        try {
            COMM_DatabaseUtils.getInstance().queryRecords( new Config.FilterCriteria() );
            System.assert( false );
        }
        catch( Exception e ){
            System.assert( true );
        }
        
        Test.stopTest();
    }

    testmethod static void testGetObjectAPIFromRecordId_success() {
        
        Test.startTest();
        try {
            Account acc = new Account();
            acc.Name='Test Account';
            insert acc;
            Common.ServiceResponse serviceResponse = COMM_DatabaseUtils.getObjectAPIFromRecordId(acc.Id);
            System.assertEquals(serviceResponse.data.toString(),'Account','Incorrect Object API returned');
        }
        catch( Exception e ){
            System.assert( false );
        }
        
        Test.stopTest();
    }

    testmethod static void testGetObjectAPIFromRecordId_missingParam() {
        
        Test.startTest();
        try {
            Common.ServiceResponse serviceResponseErr = COMM_DatabaseUtils.getObjectAPIFromRecordId(null);
        }
        catch( Exception e ){
            System.assert( true );
        }
        
        Test.stopTest();
    }

    testmethod static void testGetObjectAPIFromRecordIdOnInvalidParam() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponseErr = COMM_DatabaseUtils.getObjectAPIFromRecordId('safadwf');
        System.assertEquals(serviceResponseErr.message,ErrorMessage.INVALID_ARGUMENT,'Incorrect error message returned');
        System.assertEquals(serviceResponseErr.success,false,'Incorrect status returned');
        
        Test.stopTest();
    }
}