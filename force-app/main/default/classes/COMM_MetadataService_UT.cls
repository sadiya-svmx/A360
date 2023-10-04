@IsTest
public class COMM_MetadataService_UT {
    
	static testmethod void testGetAllEntityDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getAllEntityDefinitions();
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
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getEntityDefinition( requestEntityDefinition );
        Common.EntityDefinition entityDefinition = (Common.EntityDefinition) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinition() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinition != null );
        System.Assert( entityDefinition.apiName.equalsIgnoreCase('WorkOrder') );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_nullObjectNames() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getEntityDefinition( null );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_invalidObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getEntityDefinition( requestEntityDefinition );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
	static testmethod void testGetEntityDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getEntityDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition});
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
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getEntityDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_emptyObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getEntityDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getChildRelationships( new List<Common.EntityDefinition>{requestEntityDefinition});
        System.Assert( serviceResponse.success );
        
        List<Common.EntityDefinition> entityDefinitionList = (List<Common.EntityDefinition>) serviceResponse.data;
            
        System.debug(LoggingLevel.INFO, 'testGetChildRelationships() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships_invalidObjectNames() {
        
        Test.startTest();
       
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getChildRelationships( new List<Common.EntityDefinition>{requestEntityDefinition} );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships_emptyObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getChildRelationships( new List<Common.EntityDefinition>{requestEntityDefinition} );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_singleObject() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( requestEntityDefinition );
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
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( requestEntityDefinition );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectName() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( requestEntityDefinition );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition});
        System.Assert( serviceResponse.success );
        
        List<Common.EntityDefinition> entityDefinitionList = (List<Common.EntityDefinition>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Common.EntityDefinition entityDefinition = entityDefinitionList.get(0);
        
        System.Assert( entityDefinition.fieldDefinitions != null );
        System.Assert( entityDefinition.fieldDefinitions.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_invalidObjectNames() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'Invalid';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectAPIName() {
        
        Test.startTest();
       
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = '';
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectNames() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFieldDefinitions( new List<Common.EntityDefinition>() );
        System.Assert( serviceResponse.success == false );
        
        Test.stopTest();
    }

    static testmethod void testGetAllActiveFlows() {
        
        Test.startTest();
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getAllActiveFlows();
        System.Assert( serviceResponse.success == true );

        Test.stopTest();
    }
    
    static testmethod void testGetFlowByApiName() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFlowByApiName('test');
        System.assert(serviceResponse.success == true);

        Test.stopTest();
    }
    
    static testmethod void testGetFlowByApiNameUsingNullParameter() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFlowByApiName(null);
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

    static testmethod void testGetFlowByApiNameUsingInvalidParameter() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getFlowByApiName('    ');
        System.assert(serviceResponse.success == false);

        Test.stopTest();
    }

	static testmethod void testGetAllProfiles() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.ServiceResponse serviceResponse = new COMM_MetadataService().getAllProfiles();
        List<Common.Profile> profileList = (List<Common.Profile>) serviceResponse.data;
        
        System.debug(LoggingLevel.INFO, 'testGetAllProfiles() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( profileList != null, 'profileList should not be null.');
        System.Assert( profileList.size() != 0, 'profileList count should not be zero.');
        
        Test.stopTest();
    }
}