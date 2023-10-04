@isTest
public class CONF_SvmxDataValidator_UT {

    @testSetup public static void setup() {
        
        new CONF_PostInstallHandler().manualInstall(null);
    }
    
    static testMethod void testValidateMapping() {
        
        Test.startTest();
        
        Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
        objectMapping.sourceObjectAPIName = 'Case';
        objectMapping.targetObjectAPIName = 'Asset';
        
        Adm.ObjectMappingDetail objectMappingDetail = new Adm.ObjectMappingDetail();
        objectMappingDetail.sourceFieldAPIName = 'AssetId';
        objectMappingDetail.targetFieldAPIName = 'AccountId';
        
        objectMapping.objectMappingDetails = new List<Adm.ObjectMappingDetail>();
        objectMapping.objectMappingDetails.add(objectMappingDetail);
        
        Config.DataValidationResult dataValidationResult = new CONF_SvmxDataValidator().validateMapping(objectMapping);
        System.assert( dataValidationResult.success, dataValidationResult.errors );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateMappings() {
        
        Test.startTest();
        
        Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
        objectMapping.sourceObjectAPIName = 'Case';
        objectMapping.targetObjectAPIName = 'Asset';
        
        Adm.ObjectMappingDetail objectMappingDetail = new Adm.ObjectMappingDetail();
        objectMappingDetail.sourceFieldAPIName = 'AssetId';
        objectMappingDetail.targetFieldAPIName = 'AccountId';
        
        objectMapping.objectMappingDetails = new List<Adm.ObjectMappingDetail>();
        objectMapping.objectMappingDetails.add(objectMappingDetail);
        
        final List<Config.DataValidationResult> dataValidationResultList = new CONF_SvmxDataValidator().validateMappings( new List<Adm.ObjectMapping>{objectMapping} );
        
        System.assert( dataValidationResultList != null );
        System.assert( dataValidationResultList.size() == 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateMapping_ObjectNotExists() {
        
        Test.startTest();
        
        Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
        objectMapping.sourceObjectAPIName = 'Unknown';
        objectMapping.targetObjectAPIName = 'Unknown';
        
        Config.DataValidationResult dataValidationResult = new CONF_SvmxDataValidator().validateMapping(objectMapping);
        System.assert( dataValidationResult.success == false );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateMapping_FieldNotExists() {
        
        Test.startTest();
        
        Adm.ObjectMapping objectMapping = new Adm.ObjectMapping();
        objectMapping.sourceObjectAPIName = 'Case';
        objectMapping.targetObjectAPIName = 'Asset';
        
        Adm.ObjectMappingDetail objectMappingDetail = new Adm.ObjectMappingDetail();
        objectMappingDetail.sourceFieldAPIName = 'Unknown';
        objectMappingDetail.targetFieldAPIName = 'Unknown';
        
        objectMapping.objectMappingDetails = new List<Adm.ObjectMappingDetail>();
        objectMapping.objectMappingDetails.add(objectMappingDetail);
        
        Config.DataValidationResult dataValidationResult = new CONF_SvmxDataValidator().validateMapping(objectMapping);
        System.assert( dataValidationResult.success == false );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateExpression() {
        
        Test.startTest();
        
        Adm.Expression expression = new Adm.Expression();
        expression.objectAPIName = 'Case';
        
        Adm.ExpressionDetail expressionDetail = new Adm.ExpressionDetail();
        expressionDetail.fieldAPIName = 'AssetId';
        
        expression.expressionDetailList = new List<Adm.ExpressionDetail>();
        expression.expressionDetailList.add(expressionDetail);
        
        Config.DataValidationResult dataValidationResult = new CONF_SvmxDataValidator().validateExpression(expression);
        System.assert( dataValidationResult.success, dataValidationResult.errors );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateExpressions() {
        
        Test.startTest();
        
        Adm.Expression expression = new Adm.Expression();
        expression.objectAPIName = 'Case';
        
        Adm.ExpressionDetail expressionDetail = new Adm.ExpressionDetail();
        expressionDetail.fieldAPIName = 'AssetId';
        
        expression.expressionDetailList = new List<Adm.ExpressionDetail>();
        expression.expressionDetailList.add(expressionDetail);
        
        final List<Config.DataValidationResult> dataValidationResultList = new CONF_SvmxDataValidator().validateExpressions( new List<Adm.Expression>{expression} );
        
        System.assert( dataValidationResultList != null );
        System.assert( dataValidationResultList.size() == 0 );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateExpression_ObjectNotExists() {
        
        Test.startTest();
        
        Adm.Expression expression = new Adm.Expression();
        expression.objectAPIName = 'Unknown';
        
        Config.DataValidationResult dataValidationResult = new CONF_SvmxDataValidator().validateExpression(expression);
        System.assert( dataValidationResult.success == false );
        
        Test.stopTest();
    }
    
    static testMethod void testValidateExpression_FieldNotExists() {
        
        Test.startTest();
        
        Adm.Expression expression = new Adm.Expression();
        expression.objectAPIName = 'Case';
        
        Adm.ExpressionDetail expressionDetail = new Adm.ExpressionDetail();
        expressionDetail.fieldAPIName = 'Unknown';
        
        expression.expressionDetailList = new List<Adm.ExpressionDetail>();
        expression.expressionDetailList.add(expressionDetail);
        
        Config.DataValidationResult dataValidationResult = new CONF_SvmxDataValidator().validateExpression(expression);
        System.assert( dataValidationResult.success == false );
        
        Test.stopTest();
    }
}