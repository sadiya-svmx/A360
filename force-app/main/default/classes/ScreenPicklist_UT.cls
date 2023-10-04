@isTest
public class ScreenPicklist_UT {

    @testSetup static void pageLayoutRunTimeTestData(){        
        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__ScreenType__c'=> 'Transaction','SVMXA360__TransactionType__c' =>'Standalone Edit', 
                                                   'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__DeveloperName__c' => 'standaloneedit1','SVMXA360__FieldSets__c' => null});
        SVMXA360__CONF_Layout__c pageLayoutRecord2 = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__ScreenType__c'=> 'Transaction','SVMXA360__TransactionType__c' =>'Standalone Edit', 
                                                   'SVMXA360__ObjectAPIName__c' => 'Account','SVMXA360__FieldSets__c' => null,
                                                   'SVMXA360__DeveloperName__c' => 'standaloneedit2'}); 
    }
    
    @isTest static void testGetDefaultValue() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();

        ScreenPicklist screenPickistInstance = new ScreenPicklist(context);

        Test.startTest();

        VisualEditor.DataRow defaultValue = screenPickistInstance.getDefaultValue();
        
        Test.stopTest();

        System.assertEquals( defaultValue.getValue(), '', 'Default Value None');
    }
    
    @isTest static void testGetScreenValuesEntityNull() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();

        ScreenPicklist screenPickistInstance = new ScreenPicklist(context);

        Test.startTest();

        VisualEditor.DynamicPickListRows picklistValues = screenPickistInstance.getValues();
        
        Test.stopTest();

        System.assert(picklistValues.size() > 0, 'The number of picklist items should be greater than zero.');
    }
    
    @isTest static void testGetScreenValuesEntityNotNull() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Account';

        ScreenPicklist screenPickistInstance = new ScreenPicklist(context);

        Test.startTest();

        VisualEditor.DynamicPickListRows picklistValues = screenPickistInstance.getValues();
        
        Test.stopTest();

        System.assert(picklistValues.size() > 0, 'The number of picklist items should be greater than zero.');
    }
}