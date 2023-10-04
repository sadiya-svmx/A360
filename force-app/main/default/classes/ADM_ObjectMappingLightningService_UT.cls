@IsTest
public class ADM_ObjectMappingLightningService_UT {
	static testmethod void testGetAllObjectMappings() {
        
        Test.startTest();
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMapping__c',5);
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getAllObjectMappings();
        System.assert(serviceResponse.success);
        
        List<Adm.ObjectMapping> objectMappingList = (List<Adm.ObjectMapping>) serviceResponse.data;
            
        System.assert( objectMappingList != null );
        System.assert( objectMappingList.size() == 5 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetAllObjectMappings_empty() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getAllObjectMappings();
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        System.assert( objectMapping != null );
        System.assert( objectMapping.id != null );
        System.assert( objectMapping.objectMappingDetails != null );
        System.assert( objectMapping.objectMappingDetails.size() == 5 );
        
        Test.stopTest();
    }

    static testmethod void testgetObjectMappingsByName() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingsByName('Asset', 'Case');
        System.assert(serviceResponse.success);
    
        System.assert( serviceResponse.data != null );
        
        Test.stopTest();
    }
    
    static testmethod void testgetObjectMappingsWithDetailsByIds() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingsWithDetailsByIds(new List<String>{objectMappingRecord.Id});
        System.assert(serviceResponse.success);
    
        System.assert( serviceResponse.data != null );
        
        Test.stopTest();
    }
   
    static testmethod void testgetObjectMappingsWithDetailsByIds_Invalid() { 
        
        Test.startTest();
                
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingsWithDetailsByIds(new List<String>());
    
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testgetObjectMappingsByNameException() { 
        
        Test.startTest();
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c');
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingsByName('', '');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_InvalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_nullRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(null);
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testGetObjectMappingDetails_invalidObjectMappingId() { 
        
        Test.startTest();
        
        Adm.ObjectMapping requestObjectMapping = new Adm.ObjectMapping();
        requestObjectMapping.id = 'Invalid';
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Common.ServiceResponse newServiceResponse = ADM_ObjectMappingLightningService.saveObjectMapping(JSON.serialize(objectMapping));
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
        System.assert(serviceResponse.success);
        
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.objectMappingDetails.get(0).id = null;
        
        Common.ServiceResponse newServiceResponse = ADM_ObjectMappingLightningService.saveObjectMapping(JSON.serialize(objectMapping));
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        Common.ServiceResponse newServiceResponse = ADM_ObjectMappingLightningService.saveObjectMapping(JSON.serialize(objectMapping));
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
        Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.objectMappingDetails.get(0).mappingType = null;
        
        Common.ServiceResponse newServiceResponse = ADM_ObjectMappingLightningService.saveObjectMapping(JSON.serialize(objectMapping));
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
		Adm.ObjectMapping objectMapping = (Adm.ObjectMapping) serviceResponse.data;
        
        objectMapping.id = null;
        objectMapping.developerName = 'newMappingId';
        for(  Adm.ObjectMappingDetail detail : objectMapping.objectMappingDetails ) {
            detail.id = null;
        }
        
        Test.setReadOnlyApplicationMode(true);
        
        Common.ServiceResponse newServiceResponse = ADM_ObjectMappingLightningService.saveObjectMapping(JSON.serialize(objectMapping));
        System.assert(newServiceResponse.success == false);
       
        Test.setReadOnlyApplicationMode(false);
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_invalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.saveObjectMapping('{"}');
        System.assert(serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testSaveObjectMapping_nullRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.saveObjectMapping(null);
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.deleteObjectMapping(JSON.serialize(requestObjectMapping));
        System.assert(serviceResponse.success);
        
        Common.ServiceResponse newServiceResponse = ADM_ObjectMappingLightningService.getObjectMappingDetails(JSON.serialize(requestObjectMapping));
        System.assert(newServiceResponse.success == false);
       
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping_invalidRequestJson() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.deleteObjectMapping('{"}');
        System.assert(serviceResponse.success == false);
        
        Test.stopTest();
    }
    
    static testmethod void testDeleteObjectMapping_nullObjectMappingId() { 
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.deleteObjectMapping(null);
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
        
        Common.ServiceResponse serviceResponse = ADM_ObjectMappingLightningService.deleteObjectMapping(JSON.serialize(requestObjectMapping));
        System.assert(serviceResponse.success == false);
        
		Test.setReadOnlyApplicationMode(false);        
        Test.stopTest();
    }
}