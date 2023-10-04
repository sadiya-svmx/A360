@isTest
public class AMGT_TimeLineAssetFieldPicklist_UT {
    
    @isTest static void getDefaultValue_ObjectContainsAssetField() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Case';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();

        VisualEditor.DataRow defaultValue = timeline.getDefaultValue();
        
        Test.stopTest();

        System.assertEquals( defaultValue.getValue(), String.valueOf(Schema.Case.AssetId), 'Default field for work order should be AssetId');
    }

    @isTest static void getDefaultValue_EmptyEntityName() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = '';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();

        VisualEditor.DataRow defaultValue = timeline.getDefaultValue();
        
        Test.stopTest();

        System.assertEquals( null, defaultValue, 'Default value should be null.');
    }

    @isTest static void getDefaultValue_ObjectDoesNotContainAssetField() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'User';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();

        VisualEditor.DataRow defaultValue = timeline.getDefaultValue();
        
        Test.stopTest();

        System.assertEquals( null, defaultValue, 'Default value should be null when an object does not contain an asset field.');
    }

    @isTest static void getDefaultValue_ObjectIsAsset() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Asset';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();

        VisualEditor.DataRow defaultValue = timeline.getDefaultValue();
        
        Test.stopTest();

        System.assertEquals( defaultValue.getValue(), String.valueOf(Schema.Asset.Id), 'Default field for Asset should be the ID Field.');
    }

    @isTest static void getValues_ObjectContainsAssetField() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'WorkOrder';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();
        VisualEditor.DynamicPickListRows picklistValues = timeline.getValues();
        Test.stopTest();

        System.assert(picklistValues.size() > 0, 'The number of picklist items should be greater than zero.');
    }

    @isTest static void getValues_ObjectDoesNotContainAssetField() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'User';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();
        VisualEditor.DynamicPickListRows picklistValues = timeline.getValues();
        Test.stopTest();

        System.assertEquals(0, picklistValues.size(), 'The number of picklist items should be zero.');
    }

    @isTest static void getValues_EmptyEntityName() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = '';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();
        VisualEditor.DynamicPickListRows picklistValues = timeline.getValues();
        Test.stopTest();

        System.assertEquals(2, picklistValues.size(), 'The number of picklist items should be one.');
    }

    @isTest static void getValues_ObjectIsAsset() {
        VisualEditor.DesignTimePageContext context = new VisualEditor.DesignTimePageContext();
        context.entityName = 'Asset';

        AMGT_TimeLineAssetFieldPicklist timeline = new AMGT_TimeLineAssetFieldPicklist(context);

        Test.startTest();
        VisualEditor.DynamicPickListRows picklistValues = timeline.getValues();
        Test.stopTest();

        Boolean containsAssetIdField = false;

        for (VisualEditor.DataRow row : picklistValues.getDataRows()) {
            if (row.getValue() == String.valueOf(Schema.Asset.Id)) {
                containsAssetIdField = true;
                break;
            }
        }

        System.assertEquals(true, containsAssetIdField, 'Picklist values for the Asset object should contain the ID field.');
    }

}