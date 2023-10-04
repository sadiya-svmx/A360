@IsTest
public class ADM_ObjectMappingServiceImpl_UT {
    
	static testmethod void testGetAllObjectMappings() {
        
        Test.startTest();
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMapping__c',5);
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getAllObjectMappings();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllObjectMappings_empty() {
        
        Test.startTest();
        
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getAllObjectMappings();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 0 );
        
        Test.stopTest();
    }
	
	static testmethod void testGetObjectMappingDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
            
        Adm.ObjectMapping objectMapping = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
        
        System.assert( objectMapping != null );
        System.assert( objectMapping.id != null );
        System.assert( objectMapping.objectMappingDetails != null );
        System.assert( objectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_nullObjectMappingId() { 
        
        Test.startTest();
        
        try {
            new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(null);
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
            Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        	requestObjectMapping.id = 'Invalid';
            
            new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
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
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                      'SVMXA360__SourceObjectAPIName__c' => 'Asset'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getObjectMappingsByName('Case', 'Asset');
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() != 0 );
        
        objectMappingList = new ADM_ObjectMappingServiceImpl().getObjectMappingsByName('Case', null);
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingsByHeaderObject() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                      'SVMXA360__SourceObjectAPIName__c' => 'Asset',
                                                                                                                                      'SVMXA360__HeaderRecordObject__c' => null});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getObjectMappingsByName('Case', 'Asset', null);
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByName() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                    'SVMXA360__Type__c' => 'Value Mapping'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getObjectValueMappingsByName('Case');
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByHeaderObject() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                    'SVMXA360__Type__c' => 'Value Mapping', 
                                                                                                                                    'SVMXA360__HeaderRecordObject__c' => null});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getObjectValueMappingsByName('Case', null);
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingsByName_InvalidParameter() { 
        
        Test.startTest();
        
        try {
            new ADM_ObjectMappingServiceImpl().getObjectMappingsByName(null,null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingsByHeaderObject_InvalidParameter() { 
        
        Test.startTest();
        
        try {
            new ADM_ObjectMappingServiceImpl().getObjectMappingsByName(null,null,null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByName_InvalidParameter() { 
        
        Test.startTest();
        
        try {
            new ADM_ObjectMappingServiceImpl().getObjectValueMappingsByName(null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByHeaderObject_InvalidParameter() { 
        
        Test.startTest();
        
        try {
            new ADM_ObjectMappingServiceImpl().getObjectValueMappingsByName(null, null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Adm.ObjectMapping objectMapping = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Adm.ObjectMapping newObjectMapping = new ADM_ObjectMappingServiceImpl().saveObjectMapping(objectMapping);
        
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
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Adm.ObjectMapping objectMapping = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
        
        objectMapping.objectMappingDetails.get(0).id = null;
        
        Adm.ObjectMapping newObjectMapping = new ADM_ObjectMappingServiceImpl().saveObjectMapping(objectMapping);
        
        System.assert( newObjectMapping != null );
        System.assert( newObjectMapping.id != null );
        System.assert( newObjectMapping.objectMappingDetails != null );
        System.assert( newObjectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_emptyObjectMappingDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Adm.ObjectMapping objectMapping = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
        
        try {
            new ADM_ObjectMappingServiceImpl().saveObjectMapping(objectMapping);
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
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Adm.ObjectMapping objectMapping = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
        
        objectMapping.objectMappingDetails.get(0).mappingType = null;
        
        try {
            
            new ADM_ObjectMappingServiceImpl().saveObjectMapping(objectMapping);
            System.assert(false);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_RestrictedAccess() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Adm.ObjectMapping objectMapping = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Test.setReadOnlyApplicationMode(true);
        try {
            new ADM_ObjectMappingServiceImpl().saveObjectMapping(objectMapping);
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
            new ADM_ObjectMappingServiceImpl().saveObjectMapping(null);
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        new ADM_ObjectMappingServiceImpl().deleteObjectMapping(requestObjectMapping);
        
        try {
            new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
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
            new ADM_ObjectMappingServiceImpl().deleteObjectMapping(null);
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
            
            Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        	requestObjectMapping.id = objectMappingRecord.Id;
            
            new ADM_ObjectMappingServiceImpl().getObjectMappingDetails(requestObjectMapping);
            Test.setReadOnlyApplicationMode(true);
            new ADM_ObjectMappingServiceImpl().deleteObjectMapping(requestObjectMapping);
            
            System.assert(false);
        }
        catch( Exception e ){
            System.assert(true);
        }
		Test.setReadOnlyApplicationMode(false);        
        Test.stopTest();
    }

    static testmethod void testGetAllObjectMappingsWithDetails() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
            
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getAllObjectMappingsWithDetails();
        
        System.assert( objectMappingList != null );
        System.assert( objectMappingList[0].id != null );
        System.assert( objectMappingList[0].objectMappingDetails != null );
        System.assert( objectMappingList[0].objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }

    static testmethod void testSaveObjectMappings() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        List<Adm.ObjectMapping> objectMappingList = new ADM_ObjectMappingServiceImpl().getAllObjectMappingsWithDetails();
        
        objectMappingList[0].id = null;
        objectMappingList[0].developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMappingList[0].objectMappingDetails ) {
            detail.id = null;
        }
        
        List<Adm.ObjectMapping> newObjectMapping = new ADM_ObjectMappingServiceImpl().saveObjectMappings(objectMappingList);
        
        System.assert( newObjectMapping != null );
        System.assert( newObjectMapping[0].id != null );
        System.assert( newObjectMapping[0].objectMappingDetails != null );
        System.assert( newObjectMapping[0].objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
}