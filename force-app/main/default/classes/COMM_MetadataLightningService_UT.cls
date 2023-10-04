@IsTest
public class COMM_MetadataLightningService_UT {
    
	static testmethod void testGetAllEntityDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getAllEntityDefinitions();
        List<Common.EntityDefinition> entityDefinitionList = (List<Common.EntityDefinition>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetAllEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
	static testmethod void testGetEntityDefinition() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinition( JSON.serialize(requestEntityDefinition) );
        Common.EntityDefinition entityDefinition = (Common.EntityDefinition) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinition() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinition != null );
        System.Assert( entityDefinition.apiName.equalsIgnoreCase('WorkOrder') );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_nullObjectNames() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinition( null );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_invalidObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinition( JSON.serialize(requestEntityDefinition) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_invalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinition( '{"}' );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
	static testmethod void testGetEntityDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinitions( JSON.serialize(new List<Common.EntityDefinition>{requestEntityDefinition} ) );
        System.Assert( serviceResponse.success );
        
        List<Common.EntityDefinition> entityDefinitionList = (List<Common.EntityDefinition>) serviceResponse.data;
            
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_invalidObjectNames() {
        
        Test.startTest();
       
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinitions(JSON.serialize( new List<Common.EntityDefinition>{requestEntityDefinition} ) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_emptyObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinitions( JSON.serialize( new List<Common.EntityDefinition>{requestEntityDefinition} ) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_nullRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinitions( null );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_invalidRequestJson() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getEntityDefinitions( '{"}' );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitions( JSON.serialize(requestEntityDefinition) );
      	System.Assert( serviceResponse.success );
        
        Common.EntityDefinition entityDefinition = (Common.EntityDefinition) serviceResponse.data;
        
        System.Assert( entityDefinition.fieldDefinitions != null );
        System.Assert( entityDefinition.fieldDefinitions.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_invalidObjectName() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitions( JSON.serialize(requestEntityDefinition) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectName() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitions( JSON.serialize(requestEntityDefinition) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_nullRequestJson() {
        
        Test.startTest();
     
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitions( null );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_invalidRequestJson() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitions( '{"}' );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsList() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsList( JSON.serialize( new List<Common.EntityDefinition>{requestEntityDefinition} ) );
        System.Assert( serviceResponse.success );
        
        List<Common.EntityDefinition> entityDefinitionList = (List<Common.EntityDefinition>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetFieldDefinitionsList() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Common.EntityDefinition entityDefinition = entityDefinitionList.get(0);
        
        System.Assert( entityDefinition.fieldDefinitions != null );
        System.Assert( entityDefinition.fieldDefinitions.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsList_invalidObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsList( JSON.serialize( new List<Common.EntityDefinition>{requestEntityDefinition} ) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsList_emptyObjectAPIName() {
        
        Test.startTest();
       
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsList( JSON.serialize( new List<Common.EntityDefinition>{requestEntityDefinition} ) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsList_emptyObjectNames() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsList( JSON.serialize( new List<Common.EntityDefinition>() ) );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsList_nullRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsList(null);
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsList_invalidRequestJson() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsList('{"}');
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitionsListByType() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFieldDefinitionsListByType( 'Expression' );
        
        System.Assert( serviceResponse.success );
        System.Assert( serviceResponse.data != null );
        
        List<Common.EntityDefinition> entityDefinitionList = (List<Common.EntityDefinition>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'getFieldDefinitionsListByType() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }

    static testmethod void testGetAllActiveFlows() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFlowDefinitionList();
        System.Assert( serviceResponse.success == true );
        
        Test.stopTest();
    }

    static testmethod void testGetFlowByApiName() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFlowByApiName('test');
        System.assert(serviceResponse.success == true);

        Test.stopTest();
    }
    
    static testmethod void testGetFlowByApiNameUsingNullParameter() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFlowByApiName(null);
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

    static testmethod void testGetFlowByApiNameUsingInvalidParameter() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getFlowByApiName('    ');
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

	static testmethod void testGetAllProfiles() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getAllProfiles();
        List<Common.Profile> profileList = (List<Common.Profile>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetAllProfiles() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( profileList != null, 'profileList should not be null.');
        System.Assert( profileList.size() != 0, 'profileList count should not be zero.');
        
        Test.stopTest();
    }

    static testmethod void testGetAllQuickActionsByObjectName() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getAllQuickActionsByObjectName('Asset');
        List<Common.QuickActionDefinition> actionDefinitionList = (List<Common.QuickActionDefinition>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetAllQuickActionsByObjectName() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( actionDefinitionList != null, 'actionDefinitionList should not be null.');
        System.Assert( actionDefinitionList.size() != 0, 'actionDefinitionList count should not be zero.');
        
        Test.stopTest();
    }

    static testmethod void testGetQuickActionsByApiName() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = COMM_MetadataLightningService.getQuickActionsByApiName('Asset', 'NewAccount');
        Common.QuickActionDefinition actionDefinition = (Common.QuickActionDefinition) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetQuickActionsByApiName() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( actionDefinition != null, 'actionDefinition should not be null.');
        
        Test.stopTest();
    } 
    
    static testmethod void testGetLWCComponentDetails(){
        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.ToolingMockEndpoint());
        Test.startTest();
    
        String objectAPIName = 'WorkOrder';
        Object responseObject = COMM_MetadataLightningService.getLWCComponentDetails(objectAPIName);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }
}