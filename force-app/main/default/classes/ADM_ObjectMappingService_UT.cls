@isTest
public class ADM_ObjectMappingService_UT {
    
	static testmethod void testGetAllObjectMappings() {
        
        Test.startTest();
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMapping__c',5);
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getAllObjectMappings();
        System.assert(serviceResponse.success);
        
        List<Adm.ObjectMapping> objectMappingList = (List<Adm.ObjectMapping>) serviceResponse.data;
            
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllObjectMappings_empty() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getAllObjectMappings();
        System.assert(serviceResponse.success);
        
        List<Adm.ObjectMapping> objectMappingList = (List<Adm.ObjectMapping>) serviceResponse.data;
        
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
            
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        System.assert( objectMapping != null );
        System.assert( objectMapping.id != null );
        System.assert( objectMapping.objectMappingDetails != null );
        System.assert( objectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }

    static testmethod void testgetObjectMappingsWithDetailsByIds() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
            
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().retreiveObjectMappingsWithDetailsByIds(new List<String>{objectMappingRecord.Id});
        System.assert(serviceResponse.success);
        
        Map<String, Adm.ObjectMapping> objectMappingDetails = (Map<String, Adm.ObjectMapping>) serviceResponse.data;
        
        System.assert( objectMappingDetails.size() == 1 );
        Test.stopTest();
    }
    
    static testmethod void testgetObjectMappingsWithDetailsByIds_Invalid() { 
        
        Test.startTest();
                
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingsWithDetailsByIds(new List<String>());
    
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_nullObjectMappingId() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(null);
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_invalidObjectMappingId() { 
        
        Test.startTest();
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = 'Invalid';
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        System.assert(serviceResponse.success == false);
       
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
            
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingsByName('Case', 'Asset');
        System.assert(serviceResponse.success == true);
        
        serviceResponse = new ADM_ObjectMappingService().getObjectMappingsByName('Case', null);
        System.assert(serviceResponse.success == true);
        
        Test.stopTest();
    }

    
    static testmethod void testGetObjectMappingsByHeaderObject() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                      'SVMXA360__SourceObjectAPIName__c' => 'Asset'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
            
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingsByHeaderObject('Case', 'Asset', null);
        System.assert(serviceResponse.success == true);
                
        Test.stopTest();
    }
    
    static testmethod void testGetValueObjectMappingsByName() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                            'SVMXA360__Type__c' => 'Value Mapping'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
            
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectValueMappingsByName('Case');
        System.assert(serviceResponse.success == true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByHeaderObject() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c',
                                                                                                                                  new Map<String,Object>{'SVMXA360__TargetObjectAPIName__c'=> 'Case',
                                                                                                                                            'SVMXA360__Type__c' => 'Value Mapping'});
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
            
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectValueMappingsByHeaderObject('Case', null);
        System.assert(serviceResponse.success == true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetValueObjectMappingsByName_InvalidParameter() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectValueMappingsByName(null);
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectValueMappingsByHeaderObject_InvalidParameter() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectValueMappingsByHeaderObject(null, null);
        System.assert(serviceResponse.success == false);
        
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
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().saveObjectMapping(objectMapping);
        System.assert(newServiceResponse.success);
        
        Adm.ObjectMapping newObjectMapping = (Adm.ObjectMapping) newServiceResponse.data;
        
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
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.objectMappingDetails.get(0).id = null;
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().saveObjectMapping(objectMapping);
        System.assert(newServiceResponse.success);
        
        Adm.ObjectMapping newObjectMapping = (Adm.ObjectMapping) newServiceResponse.data;
        
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
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().saveObjectMapping(objectMapping);
        System.assert(newServiceResponse.success == false);
        
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
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.objectMappingDetails.get(0).mappingType = null;
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().saveObjectMapping(objectMapping);
        System.assert(newServiceResponse.success == false);
        
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
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
		Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Test.setReadOnlyApplicationMode(true);
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().saveObjectMapping(objectMapping);
        System.assert(newServiceResponse.success == false);
       
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_nullObjectMapping() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().saveObjectMapping(null);
        System.assert(serviceResponse.success == false );
        
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
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().deleteObjectMapping(requestObjectMapping);
        System.assert(serviceResponse.success);
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        System.assert(newServiceResponse.success == false);
       
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping_nullObjectMappingId() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().deleteObjectMapping(null);
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping_readOnlyMode() { 
        
        Test.startTest();
              
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Test.setReadOnlyApplicationMode(true);
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().deleteObjectMapping(requestObjectMapping);
        System.assert(serviceResponse.success == false);
        
		Test.setReadOnlyApplicationMode(false);        
        Test.stopTest();
    }

    static testmethod void testGetAllObjectMappingsWithDetails() {
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getAllObjectMappingsWithDetails();
        System.assert(serviceResponse.success);
        
        List<Adm.ObjectMapping> objectMappingList = (List<Adm.ObjectMapping>) serviceResponse.data;
            
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 1 );
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
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = objectMappingRecord.Id;
        
        Common.ServiceResponse serviceResponse = new ADM_ObjectMappingService().getObjectMappingDetails(requestObjectMapping);
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }

        List<Adm.ObjectMapping> objectMappingList = new List<Adm.ObjectMapping>();
        objectMappingList.add(objectMapping);
        
        Common.ServiceResponse newServiceResponse = new ADM_ObjectMappingService().saveObjectMappings(objectMappingList);
        System.assert(newServiceResponse.success);
        
        List<Adm.ObjectMapping> newObjectMapping = (List<Adm.ObjectMapping>) newServiceResponse.data;
        
        System.assert( newObjectMapping != null );
        System.assert( newObjectMapping[0].id != null );
        System.assert( newObjectMapping[0].objectMappingDetails != null );
        System.assert( newObjectMapping[0].objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }
}