@IsTest
public class COMM_MetadataManager_UT {
    @testSetup public static void setup() {
        SvmxTestDataFactory.insertDefaultAllowedCoreObjects();
    }

    static testmethod void testGetEntityDefinition() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getEntityDefinition( 'WorkOrder' );
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinition() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinition != null );
        System.Assert( entityDefinition.apiName.equalsIgnoreCase('WorkOrder') );
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntityDefinition_nullObjectNames() {
        
        Test.startTest();
        
        try {
            COMM_MetadataManager.getInstance().getEntityDefinition( null );
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
            COMM_MetadataManager.getInstance().getEntityDefinition( 'Invalid' );
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
        
        List<Common.EntityDefinition> entityDefinitionList = COMM_MetadataManager.getInstance().getEntityDefinitions( new List<String>{'WorkOrder'});
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
	static testmethod void testGetAllProfiles() {
        
        Test.startTest();
        
        Long startTime = System.currentTimeMillis();
        
        List<Common.Profile> profileList = COMM_MetadataManager.getInstance().getAllProfiles();
        
        System.debug(LoggingLevel.INFO, 'testGetAllProfiles() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( profileList != null, 'profileList should not be null.');
        System.Assert( profileList.size() != 0, 'profileList count should not be zero.');
        
        Test.stopTest();
    }

    static testmethod void testGetEntityDefinitions_nullObjectNames() {
        
        Test.startTest();
        
        try {
            COMM_MetadataManager.getInstance().getEntityDefinitions( null );
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
            COMM_MetadataManager.getInstance().getEntityDefinitions( new List<String>{'Invalid'} );
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
        
        List<Common.EntityDefinition> entityDefinitionList = COMM_MetadataManager.getInstance().getChildRelationships( new List<String>{'WorkOrder'});
        
        System.debug(LoggingLevel.INFO, 'testGetEntityDefinitions() - Execution Time: ' + ( System.currentTimeMillis() - startTime ) );
        
        System.Assert( entityDefinitionList != null );
        System.Assert( entityDefinitionList.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetChildRelationships_nullObjectNames() {
        
        Test.startTest();
        
        try {
            COMM_MetadataManager.getInstance().getChildRelationships( null );
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
            COMM_MetadataManager.getInstance().getChildRelationships( new List<String>{'Invalid'} );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_singleObject() {
        
        Test.startTest();
        
        Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions( 'WorkOrder' );
      
        System.Assert( entityDefinition.fieldDefinitions != null );
        System.Assert( entityDefinition.fieldDefinitions.size() != 0 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetFieldDefinitions_invalidObjectName() {
        
        Test.startTest();
        
        try {
            COMM_MetadataManager.getInstance().getFieldDefinitions( 'Invalid' );
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
            COMM_MetadataManager.getInstance().getFieldDefinitions( '' );
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
        
        List<Common.EntityDefinition> entityDefinitionList = COMM_MetadataManager.getInstance().getFieldDefinitions( new List<String>{'WorkOrder'});
        
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
            COMM_MetadataManager.getInstance().getFieldDefinitions( new List<String>{'Invalid'} );
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
            COMM_MetadataManager.getInstance().getFieldDefinitions( new List<String>() );
            System.Assert(false);
        }
        catch( Exception e ) {
            System.Assert(true);
        }
        
        Test.stopTest();
    }

    static testmethod void testGetAllActiveFlows() {
        
        Test.startTest();

        List<Common.FlowDefinition> flowDefinitionList = COMM_MetadataManager.getInstance().getAllActiveFlows();
        System.Assert( flowDefinitionList != null );
        
        Test.stopTest();
    }

    /*static testmethod void testGetFlowByApiName() {
        Test.startTest();
        Common.FlowDefinition flowDefinition;
        System.debug('starting testGetFlowByApiName');

        flowDefinition = COMM_MetadataManager.getInstance().getFlowByApiName('pagelayout');
        System.assertNotEquals(null, flowDefinition);

        Test.stopTest();
    }*/
    
    static testmethod void testGetFlowByApiNameUsingNullParameter() {
        Test.startTest();

        try {
            COMM_MetadataManager.getInstance().getFlowByApiName(null);
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
            COMM_MetadataManager.getInstance().getFlowByApiName('    ');
            System.assert(false);
        }
        catch ( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    static testmethod void testgetEntityDefinitionIdWithInvalidObjectType() {
        Test.startTest();

        try {
            String entityID = COMM_MetadataManager.getEntityDefinitionId('asfasf');
            System.assertEquals(null,entityID,'Entity id should return null');
        }
        catch ( Exception e ) {
            System.assert(false,'got exception'+e.getMessage());
        }

        Test.stopTest();
    }


    static testmethod void testgetEntityDefinitionIdWithInvalidParam() {
        Test.startTest();

        try {
            String entityID = COMM_MetadataManager.getEntityDefinitionId(null);
        }
        catch ( Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    static testmethod void testgetEntityDefinitionId() {
        Test.startTest();

        try {
            String entityID = COMM_MetadataManager.getEntityDefinitionId('case');
            System.assertEquals('Case',entityID,'Entity id mismatching');
        }
        catch ( Exception e ) {
            System.assert(false);
        }

        Test.stopTest();
    }
}