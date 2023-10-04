@IsTest
public class ADM_ObjectMappingManager_UT {

    @testSetup public static void setup() {
        
		SVMXA360__CONF_ObjectMapping__c objectMappingRecord = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP001',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetails = SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 7);
        objectMappingDetails.get(0).SVMXA360__TargetFieldAPIName__c = 'AccountId';
        objectMappingDetails.get(0).SVMXA360__SourceFieldAPIName__c = 'AccountId';
        objectMappingDetails.get(0).SVMXA360__Type__c  = 'Field';
        
        objectMappingDetails.get(1).SVMXA360__TargetFieldAPIName__c = 'StartDate';
        objectMappingDetails.get(1).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(1).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(1).SVMXA360__Value__c   = 'FsvmxToday';
        
        objectMappingDetails.get(2).SVMXA360__TargetFieldAPIName__c = 'Subject';
        objectMappingDetails.get(2).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(2).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(2).SVMXA360__Value__c   = 'Sample Subject';
        
        objectMappingDetails.get(3).SVMXA360__TargetFieldAPIName__c = 'OwnerId';
        objectMappingDetails.get(3).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(3).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(3).SVMXA360__Value__c   = 'FSVMXCURRENTUSERID';
        
        objectMappingDetails.get(4).SVMXA360__TargetFieldAPIName__c = 'LocationId';
        objectMappingDetails.get(4).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(4).SVMXA360__Type__c  = 'Function';
        objectMappingDetails.get(4).SVMXA360__Value__c   = 'FSVMXNULL';
        
        objectMappingDetails.get(5).SVMXA360__TargetFieldAPIName__c = 'MinimumCrewSize';
        objectMappingDetails.get(5).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(5).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(5).SVMXA360__Value__c   = '5';
        
        objectMappingDetails.get(6).SVMXA360__TargetFieldAPIName__c = 'Tax';
        objectMappingDetails.get(6).SVMXA360__SourceFieldAPIName__c = null;
        objectMappingDetails.get(6).SVMXA360__Type__c  = 'Value';
        objectMappingDetails.get(6).SVMXA360__Value__c   = '10';
         
                
        insert objectMappingDetails;
        
        SVMXA360__CONF_ObjectMapping__c objectValueMappingRecord = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP002',
                                                                                    'SVMXA360__Type__c' => 'Value Mapping'
                                                                                        });
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectValueMappingDetails = SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectValueMappingRecord.Id}, 2);
        
        objectValueMappingDetails.get(1).SVMXA360__TargetFieldAPIName__c = 'StartDate';
        objectValueMappingDetails.get(1).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(1).SVMXA360__Type__c  = 'Function';
        objectValueMappingDetails.get(1).SVMXA360__Value__c   = 'FsvmxToday';
        
        objectValueMappingDetails.get(0).SVMXA360__TargetFieldAPIName__c = 'Subject';
        objectValueMappingDetails.get(0).SVMXA360__SourceFieldAPIName__c = null;
        objectValueMappingDetails.get(0).SVMXA360__Type__c  = 'Value';
        objectValueMappingDetails.get(0).SVMXA360__Value__c   = 'Sample Subject';
        
        insert objectValueMappingDetails;
                
        Account accountRecord = (Account) SvmxTestDataFactory.insertSObject('Account');
        SvmxTestDataFactory.insertSObject('Case', new Map<String,Object>{'AccountId' => accountRecord.Id} );
    }
    
    static testmethod void testGetAllObjectMappings() {
        
        Test.startTest();
        
        List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappings();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 2, objectMappingList.size() );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllObjectMappingWithDetails() {
        
        Test.startTest();
        
        List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappingsWithDetails();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 2, objectMappingList.size() );
        System.assert( objectMappingList.get(0).objectMappingDetails != null );
        System.assert( objectMappingList.get(0).objectMappingDetails.size() != 0 );
        
        Test.stopTest();
    }
	
	static testmethod void testGetObjectMappingDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        System.assert( objectMapping != null );
        System.assert( objectMapping.id != null );
        System.assert( objectMapping.objectMappingDetails != null );
        System.assert( objectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_nullObjectMappingId() { 
        
        Test.startTest();
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_invalidObjectMappingId() { 
        
        Test.startTest();
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingDetails('invalid');
            System.assert(false);
        }
        catch(Exception e ){
            System.assert(true);
        }
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingWithDetailRecords('');
            System.assert(false);
        }
        catch(Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingsByName() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                                                                  new Map<String,Object>{
                                                                                                                                      'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                                                                      'SVMXA360__SourceObjectAPIName__c' => 'Case'
                                                                                                                                  });
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        {
            Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('WorkOrder').get(0);
        
            System.assert( objectMapping != null );
            System.assert( objectMapping.id != null );
            System.assert( objectMapping.targetObjectAPIName != null );
            System.assert( objectMapping.targetObjectAPIName.equalsIgnoreCase('WorkOrder') );
        }
        
        {
            Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('WorkOrder', 'Case').get(0);
        
            System.assert( objectMapping != null );
            System.assert( objectMapping.id != null );
            System.assert( objectMapping.targetObjectAPIName != null );
            System.assert( objectMapping.targetObjectAPIName.equalsIgnoreCase('WorkOrder') );
            System.assert( objectMapping.sourceObjectAPIName.equalsIgnoreCase('Case') );
        }
        
 
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByName() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                                                                  new Map<String,Object>{
                                                                                                                                      'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                                                                      'SVMXA360__Type__c' => 'Value Mapping'
                                                                                                                                  });
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);

        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectValueMappingsByName('WorkOrder').get(0);
    
        System.assert( objectMapping != null );
        System.assert( objectMapping.id != null );
        System.assert( objectMapping.targetObjectAPIName != null );
        System.assert( objectMapping.targetObjectAPIName.equalsIgnoreCase('WorkOrder') );

        Test.stopTest();
    }

    static testmethod void testGetObjectMappingsByName_emptyList() { 
        
        Test.startTest();
       
        {
            List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('ReturnOrder');
        
            System.assert(objectMappingList != null );
            System.assert(objectMappingList.isEmpty());
        }
        
        {
            List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('ReturnOrder', 'Case');
        
            System.assert(objectMappingList != null );
            System.assert(objectMappingList.isEmpty());
        }
        
 
        Test.stopTest();
    }
 
    static testmethod void testGetObjectValueMappingsByName_emptyList() { 
        
        Test.startTest();

        List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getObjectValueMappingsByName('ReturnOrder');
    
        System.assert(objectMappingList != null );
        System.assert(objectMappingList.isEmpty());
 
        Test.stopTest();
    }

    static testmethod void testGetObjectMappingsByName_invalidParameters() { 
        
        Test.startTest();
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingsByName(null);
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingRecordsByName(null);
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        List<String> listStringVar = new List<String>();
         try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingsByName(listStringVar,listStringVar);
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingRecordsByName(listStringVar, listStringVar);
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
         try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('');
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
         try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('','');
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
 
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByName_invalidParameters() { 
        
        Test.startTest();
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectValueMappingsByName(null);
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectValueMappingRecordsByName(null);
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }

        try {
            ADM_ObjectMappingManager.getInstance().getObjectValueMappingsByName('');
            System.assert( false );
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testValidateObjectMapping() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP111',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping',
                                                                                    'SVMXA360__HeaderRecordObject__c' => ''});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET001',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => 'Account.textName',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'Type',
                                                   'SVMXA360__Type__c' => 'Field',
                                                   'SVMXA360__Value__c' => '',
                                                   'SVMXA360__LiteralParameter__c'=> ''
                                                   }, 
                                               1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET002',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => '',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'Description',
                                                   'SVMXA360__Type__c' => 'Function',
                                                   'SVMXA360__Value__c' => 'Current Record',
                                                   'SVMXA360__LiteralParameter__c'=> 'Account.textName'
                                                   }, 
                                               1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET003',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => '',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'EndDate',
                                                   'SVMXA360__Type__c' => 'Function',
                                                   'SVMXA360__Value__c' => 'User',
                                                   'SVMXA360__LiteralParameter__c'=> 'Account.textName'
                                                   }, 
                                               1);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        Adm.ValidationResult validationResult = ADM_ObjectMappingManager.getInstance().validateObjectMapping(objectMapping);
        
        System.assert( validationResult != null );
        System.assert( !validationResult.isValid );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                                                                  new Map<String,Object>{'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.ObjectMapping )});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        objectMapping.id = null;
        objectMapping.developerName = 'New';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Adm.ObjectMapping newObjectMapping = ADM_ObjectMappingManager.getInstance().saveObjectMapping(objectMapping);
        
        System.assert( newObjectMapping != null );
        System.assert( newObjectMapping.id != null );
        System.assert( newObjectMapping.objectMappingDetails != null );
        System.assert( newObjectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_update() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        objectMapping.objectMappingDetails.get(0).id = null;
        
        Adm.ObjectMapping newObjectMapping = ADM_ObjectMappingManager.getInstance().saveObjectMapping(objectMapping);
        
        System.assert( newObjectMapping != null );
        System.assert( newObjectMapping.id != null );
        System.assert( newObjectMapping.objectMappingDetails != null );
        System.assert( newObjectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_emptyObjectMappingDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        try {
            ADM_ObjectMappingManager.getInstance().saveObjectMapping(objectMapping);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_nullMappingType() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        objectMapping.objectMappingDetails.get(0).mappingType = null;
        
        try {
            
            ADM_ObjectMappingManager.getInstance().saveObjectMapping(objectMapping);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }

    static testmethod void testValidateOnMappingRetrieve() {
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP111',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping',
                                                                                    'SVMXA360__HeaderRecordObject__c' => ''});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET001',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => 'Account.textName',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'Type',
                                                   'SVMXA360__Type__c' => 'Field',
                                                   'SVMXA360__Value__c' => '',
                                                   'SVMXA360__LiteralParameter__c'=> ''
                                                   }, 
                                               1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET002',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => '',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'Description',
                                                   'SVMXA360__Type__c' => 'Function',
                                                   'SVMXA360__Value__c' => 'Current Record',
                                                   'SVMXA360__LiteralParameter__c'=> 'Account.textName'
                                                   }, 
                                               1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET003',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => '',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'EndDate',
                                                   'SVMXA360__Type__c' => 'Function',
                                                   'SVMXA360__Value__c' => 'User',
                                                   'SVMXA360__LiteralParameter__c'=> 'Account.textName'
                                                   }, 
                                               1);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        try {
            
            ADM_ObjectMappingManager.getInstance().validateMapping(objectMapping);
            System.assert(true);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(false);
        }
        
        Test.stopTest();
    }

    static testmethod void testValidateBeforeSaveMapping() {
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP222',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET001',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => 'Account.CreatedDate',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'Type',
                                                   'SVMXA360__Type__c' => 'Field',
                                                   'SVMXA360__Value__c' => '',
                                                   'SVMXA360__LiteralParameter__c'=> ''
                                                   }, 
                                               1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET002',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => '',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'Description',
                                                   'SVMXA360__Type__c' => 'Function',
                                                   'SVMXA360__Value__c' => 'Current Record',
                                                   'SVMXA360__LiteralParameter__c'=> 'Account.CreatedDate'
                                                   }, 
                                               1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id,
                                                   'Name' => 'MAPDET003',
                                                   'SVMXA360__RelatedObjectDetails__c' => 'Account',
                                                   'SVMXA360__SourceFieldAPIName__c' => '',
                                                   'SVMXA360__TargetFieldAPIName__c' => 'EndDate',
                                                   'SVMXA360__Type__c' => 'Function',
                                                   'SVMXA360__Value__c' => 'User',
                                                   'SVMXA360__LiteralParameter__c'=> 'Account.Decription'
                                                   }, 
                                               1);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        ADM_ObjectMappingManager.getInstance().populateCompatibilityMatrix();
        
        try {
            
            ADM_ObjectMappingManager.getInstance().validateBeforeSaveMappingDetails(objectMapping);
            System.assert(true);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(false);
        }
        
        Test.stopTest();
    }

    static testmethod void testSaveObjectMapping_RestrictedAccess() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping objectMapping = ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            
            detail.id = null;
        }
        
        Test.setReadOnlyApplicationMode(true);
        try {
            ADM_ObjectMappingManager.getInstance().saveObjectMapping(objectMapping);
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }
        
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_nullObjectMapping() { 
        
        Test.startTest();
        
        try {
            ADM_ObjectMappingManager.getInstance().saveObjectMapping(null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }

    static testmethod void testSaveObjectMappings() { 
        
        Test.startTest();
        
        final List<Adm.ObjectMapping> objectMappingList = ADM_ObjectMappingManager.getInstance().getAllObjectMappingsWithDetails();
        
        for( Adm.ObjectMapping objectMapping : objectMappingList ) {
            
            objectMapping.id = null;
            objectMapping.developerName = objectMapping.developerName + 'New';
            for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
                detail.id = null;
            }
        }
        
        List<Adm.ObjectMapping> newObjectMappingList = ADM_ObjectMappingManager.getInstance().saveObjectMappings(objectMappingList, true);
        
        System.assert( newObjectMappingList != null );
        System.assert( newObjectMappingList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        ADM_ObjectMappingManager.getInstance().deleteObjectMapping(objectMappingRecord.Id);
        
        try {
            ADM_ObjectMappingManager.getInstance().getObjectMappingDetails(objectMappingRecord.Id);
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }
        
        
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping_nullObjectMappingId() { 
        
        Test.startTest();
        
        try {
            ADM_ObjectMappingManager.getInstance().deleteObjectMapping(null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping_readOnlyMode() { 
        
        Test.startTest();
        
        try {
            
            SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
            SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                                   new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                                   5);
            
            Test.setReadOnlyApplicationMode(true);
            ADM_ObjectMappingManager.getInstance().deleteObjectMapping(objectMappingRecord.Id);
            
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
		Test.setReadOnlyApplicationMode(false);        
        Test.stopTest();
    }
}