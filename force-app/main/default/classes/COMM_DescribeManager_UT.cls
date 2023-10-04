@isTest
public class COMM_DescribeManager_UT {

    static testMethod void testGetGlobalDescribe() {

        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Map<String, Schema.SObjectType> sObjectTypeMap = COMM_DescribeManager.getInstance().getGlobalDescribe();
        
        System.debug(LoggingLevel.INFO, 'testGetGlobalDescribe() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( sObjectTypeMap != null );
        System.Assert( sObjectTypeMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe() {

        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Schema.DescribeSobjectResult  describeSobjectResult = COMM_DescribeManager.getInstance().getObjectDescribe('WorkOrder');
        
        System.debug(LoggingLevel.INFO, 'testGetObjectDescribe() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( describeSobjectResult != null );
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe_emptyObjectName() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getObjectDescribe('');
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe_invalidObjectName() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getObjectDescribe('invalud');
        }
        catch( Exception e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe_listOfObjectName() {

        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        List<String> objectNames = new List<String>{'WorkOrder', 'WorkOrderLineItem'};
        Map<String, Schema.DescribeSobjectResult>  describeSobjectResultMap = COMM_DescribeManager.getInstance().getObjectDescribe(objectNames);
        
        System.debug(LoggingLevel.INFO, 'testGetObjectDescribe_listOfObjectName() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( describeSobjectResultMap != null );
        System.Assert( describeSobjectResultMap.size() == 2 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe_multipleIteration() {

        Test.startTest();
        
        List<String> objectNames = new List<String>{'WorkOrder', 'WorkOrderLineItem'};
        Map<String, Schema.DescribeSobjectResult>  describeSobjectResultMap = COMM_DescribeManager.getInstance().getObjectDescribe(objectNames);
        
        Long startTime = System.currentTimeMillis();
        
        describeSobjectResultMap = COMM_DescribeManager.getInstance().getObjectDescribe(objectNames);
        System.debug(LoggingLevel.INFO, 'testGetObjectDescribe_multipleIteration() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( describeSobjectResultMap != null );
        System.Assert( describeSobjectResultMap.size() == 2 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe_emptyListOfObjectName() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getObjectDescribe(new List<String>() );
            System.Assert( false );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectDescribe_invalidListOfObjectName() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getObjectDescribe(new List<String>{'invalid'} );
            System.Assert( false );
        }
        catch( Exception e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectFieldMap() {

        Test.startTest();
        
        Long startTime = System.currentTimeMillis();

        Map<String, Schema.sObjectField> sObjectFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('WorkOrder');
        
        System.debug(LoggingLevel.INFO, 'testGetObjectFieldMap() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( sObjectFieldMap != null );
        System.Assert( sObjectFieldMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectFieldMap_nullObjectName() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getObjectFieldMap(null);
            System.Assert( false );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetObjectFieldMap_invalidObjectName() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getObjectFieldMap('invalid');
            System.Assert( false );
        }
        catch( Exception e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldDescribeResults() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();

        Map<String, Schema.DescribeFieldResult> newDescribeFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults('WorkOrder');
        
        System.debug(LoggingLevel.INFO, 'testGetFieldDescribeResults() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( newDescribeFieldResultMap != null );
        System.Assert( newDescribeFieldResultMap.size() != 0 );
        
        COMM_DescribeManager.getInstance().getFieldDescribeResults('WorkOrder');
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldDescribeResults_emptyObjectName() {
        
        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getFieldDescribeResults('');
            System.Assert( false );
        }
        catch( Exception e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldDescribeResults_emptyObjectNames() {
        
        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getFieldDescribeResults( new List<String>() );
            System.Assert( false );
        }
        catch( Exception e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldDescribeResults_invalidObjectName() {
        
        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getFieldDescribeResults('invalid');
            System.Assert( false );
        }
        catch( Exception e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldDescribe() {

        Test.startTest();
        
        Long startTime = System.currentTimeMillis();

        Map<String, Schema.SObjectField> sObjectFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('WorkOrder');
        
        for( Schema.SObjectField sObjectField : sObjectFieldMap.values() ) {
            
            Schema.DescribeFieldResult describeFieldResult = COMM_DescribeManager.getInstance().getFieldDescribe(sObjectField);
            System.Assert( describeFieldResult != null );
        }
        
        System.debug(LoggingLevel.INFO, 'testGetFieldDescribe() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( sObjectFieldMap != null );
        System.Assert( sObjectFieldMap.size() != 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testGetFieldDescribe_nullCheck() {

        Test.startTest();
        
        try {
            COMM_DescribeManager.getInstance().getFieldDescribe(null);
            System.Assert( false );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.Assert( true );
        }
        
        Test.stopTest();
    }

    static testmethod void testGetAllQuickActionsByObjectName() {
        
        Test.startTest();

        List<Common.QuickActionDefinition> actionDefinitionList = COMM_DescribeManager.getInstance().getAllQuickActionsByObjectName('Asset');
        System.Assert( actionDefinitionList != null );
        
        Test.stopTest();
    }

    static testmethod void testGetQuickActionsByApiName() {
        
        Test.startTest();

        Common.QuickActionDefinition actionDefinition = COMM_DescribeManager.getInstance().getQuickActionsByApiName('Asset', 'NewAccount');
        System.Assert( actionDefinition != null );
        
        Test.stopTest();
    }

    static testmethod void testGetNameFields_Account() {
        Test.startTest();

        String[] nameFields = COMM_DescribeManager.getInstance().getNameFields('Account');
        System.assertEquals(1, nameFields.size());
        System.assertEquals(nameFields[0], 'Name');

        Test.stopTest();
    }

    static testmethod void testGetNameFields_ContractLineItem() {
        Test.startTest();

        String[] nameFields = COMM_DescribeManager.getInstance().getNameFields('ContractLineItem');
        System.assertEquals(1, nameFields.size());
        System.assertEquals(nameFields[0], 'LineItemNumber');

        Test.stopTest();
    }
}