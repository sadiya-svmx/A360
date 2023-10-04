@isTest
public class COMM_MetadataServiceImpl_UT {
    
    static testmethod void testGetAllEntityDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        List<Common.EntityDefinition> entityDefinitionList = new COMM_MetadataServiceImpl().getAllEntityDefinitions();
        
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
            
        Common.EntityDefinition entityDefinition = new COMM_MetadataServiceImpl().getEntityDefinition( requestEntityDefinition );
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinition() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinition != null );
        System.Assert( entityDefinition.apiName.equalsIgnoreCase('WorkOrder') );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_nullObjectNames() {
        
        Test.startTest();
        
        try {
            new COMM_MetadataServiceImpl().getEntityDefinition( null );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_invalidObjectNames() {
        
        Test.startTest();
        
        try {
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = 'Invalid';
            
            new COMM_MetadataServiceImpl().getEntityDefinition( requestEntityDefinition );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
	static testmethod void testGetEntityDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        List<Common.EntityDefinition> entityDefinitionList = new COMM_MetadataServiceImpl().getEntityDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition});
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_nullObjectNames() {
        
        Test.startTest();
        
        try {
            new COMM_MetadataServiceImpl().getEntityDefinitions( null );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_invalidObjectNames() {
        
        Test.startTest();
        
        try {
            
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = 'Invalid';
            
            new COMM_MetadataServiceImpl().getEntityDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinitions_emptyObjectNames() {
        
        Test.startTest();
        
        try {
            
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = '';
            
            new COMM_MetadataServiceImpl().getEntityDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        List<Common.EntityDefinition> entityDefinitionList = new COMM_MetadataServiceImpl().getChildRelationships( new List<Common.EntityDefinition>{requestEntityDefinition});
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships_nullObjectNames() {
        
        Test.startTest();
        
        try {
            new COMM_MetadataServiceImpl().getChildRelationships( null );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships_invalidObjectNames() {
        
        Test.startTest();
        
        try {
            
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = 'Invalid';
            
            new COMM_MetadataServiceImpl().getChildRelationships( new List<Common.EntityDefinition>{requestEntityDefinition} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships_emptyObjectNames() {
        
        Test.startTest();
        
        try {
            
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = '';
            
            new COMM_MetadataServiceImpl().getChildRelationships( new List<Common.EntityDefinition>{requestEntityDefinition} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_singleObject() {
        
        Test.startTest();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        Common.EntityDefinition entityDefinition = new COMM_MetadataServiceImpl().getFieldDefinitions( requestEntityDefinition );
      
        System.Assert( entityDefinition.fieldDefinitions != null );
        System.Assert( entityDefinition.fieldDefinitions.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_invalidObjectName() {
        
        Test.startTest();
        
        try {
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = 'Invalid';
            
            new COMM_MetadataServiceImpl().getFieldDefinitions( requestEntityDefinition );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectName() {
        
        Test.startTest();
        
        try {
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = '';
            
            new COMM_MetadataServiceImpl().getFieldDefinitions( requestEntityDefinition );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        requestEntityDefinition.apiName = 'WorkOrder';
        
        List<Common.EntityDefinition> entityDefinitionList = new COMM_MetadataServiceImpl().getFieldDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition});
        
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
        
        try {
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = 'Invalid';
            
            new COMM_MetadataServiceImpl().getFieldDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectAPIName() {
        
        Test.startTest();
        
        try {
            Common.EntityDefinition requestEntityDefinition = new Common.EntityDefinition();
        	requestEntityDefinition.apiName = '';
            
            new COMM_MetadataServiceImpl().getFieldDefinitions( new List<Common.EntityDefinition>{requestEntityDefinition} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_emptyObjectNames() {
        
        Test.startTest();
        
        try {
            new COMM_MetadataServiceImpl().getFieldDefinitions( new List<Common.EntityDefinition>() );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }

    static testmethod void testGetAllActiveFlows() {
        
        Test.startTest();
        
        List<Common.FlowDefinition> flowDefinitionList = new COMM_MetadataServiceImpl().getAllActiveFlows();
        System.Assert( flowDefinitionList != null );
        
        Test.stopTest();
    }


    static testmethod void testGetFlowByApiName() {
        Test.startTest();

        Common.FlowDefinition flowDefinition = new COMM_MetadataServiceImpl().getFlowByApiName('pagelayout');
        System.assert(flowDefinition == null);

        Test.stopTest();
    }
    
    static testmethod void testGetFlowByApiNameUsingNullParameter() {
        Test.startTest();

        try {
            new COMM_MetadataServiceImpl().getFlowByApiName(null);
            System.assert(false);
        }
        catch ( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    static testmethod void testGetFlowByApiNameUsingInvalidParameter() {
        Test.startTest();

        try {
            new COMM_MetadataServiceImpl().getFlowByApiName('    ');
            System.assert(false);
        }
        catch ( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }       
    
    static testmethod void testGetAllProfiles() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        List<Common.Profile> profileList = new COMM_MetadataServiceImpl().getAllProfiles();
        
        System.debug(LoggingLevel.INFO, 'testGetAllProfiles() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( profileList != null, 'profileList should not be null.');
        System.Assert( profileList.size() != 0, 'profileList count should not be zero.');
        
        Test.stopTest();
    } 
    
    static testmethod void testGetAllQuickActionsByObjectName() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        List<Common.QuickActionDefinition> actionDefinitionList = new COMM_MetadataServiceImpl().getAllQuickActionsByObjectName('Asset');
        
        System.debug(LoggingLevel.INFO, 'testGetAllQuickActionsByObjectName() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( actionDefinitionList != null, 'actionDefinitionList should not be null.');
        System.Assert( actionDefinitionList.size() != 0, 'actionDefinitionList count should not be zero.');
        
        Test.stopTest();
    }

    static testmethod void testGetQuickActionsByApiName() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.QuickActionDefinition actionDefinition = new COMM_MetadataServiceImpl().getQuickActionsByApiName('Asset', 'NewAccount');
        
        System.debug(LoggingLevel.INFO, 'testGetQuickActionsByApiName() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( actionDefinition != null, 'actionDefinitionList should not be null.');
        
        Test.stopTest();
    }
}