@isTest
public class ADM_RecentItemsLightningService_UT {

    @testSetup static void recentItemTestData(){
        
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
        new Map<String,Object>{
                 'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression ),
                 'SVMXA360__ObjectAPIName__c' => 'Account',
                 'Name' => 'Test Expression',
                 'SVMXA360__HeaderRecordObject__c' => '',
                 'SVMXA360__ExpressionType__c' => 'VISIBILITY-RULE-CRITERIA'
        });

        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = 
            (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                                    'Name' => 'Test Mapping',
                                                                                    'SVMXA360__DeveloperName__c' => 'MAP001',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});

        SVMXA360__COMM_Recentitem__c expressionRecentItemRecord = (SVMXA360__COMM_Recentitem__c) SvmxTestDataFactory.insertSObject('SVMXA360__COMM_Recentitem__c',
                                                                                    new Map<String,Object>{'SVMXA360__AdminConfigurationName__c' => expressionRec.Name,
                                                                                        'SVMXA360__ConfigurationDeveloperName__c' => expressionRec.SVMXA360__DeveloperName__c,
                                                                                        'SVMXA360__ConfigurationId__c' => expressionRec.Id,
                                                                                        'SVMXA360__ConfigurationType__c' => 'Expression'});
        SVMXA360__COMM_Recentitem__c mappingRecentItemRecord = (SVMXA360__COMM_Recentitem__c) SvmxTestDataFactory.insertSObject('SVMXA360__COMM_Recentitem__c',
                                                                                    new Map<String,Object>{'SVMXA360__AdminConfigurationName__c' => objectMappingRecord.Name,
                                                                                        'SVMXA360__ConfigurationDeveloperName__c' => objectMappingRecord.SVMXA360__DeveloperName__c,
                                                                                        'SVMXA360__ConfigurationId__c' => objectMappingRecord.Id,
                                                                                        'SVMXA360__ConfigurationType__c' => 'Mapping'});
    }
    
    public static testMethod void testGetRecentItemsDetails(){

        Test.startTest();
		Object responseObject = ADM_RecentItemsLightningService.getRecentItemsDetails();
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }

    public static testMethod void testSaveRecentItem(){

        List<SVMXA360__COMM_Recentitem__c> recentItemList = [SELECT Id, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationType__c FROM SVMXA360__COMM_Recentitem__c LIMIT 1];
        System.assert(recentItemList.size() == 1);
        Adm.RecentItemInfo recentItem = new Adm.RecentItemInfo ();
        recentItem.configurationName = recentItemList[0].SVMXA360__AdminConfigurationName__c;
        recentItem.configurationDeveloperName = recentItemList[0].SVMXA360__ConfigurationDeveloperName__c;
        recentItem.configurationId = recentItemList[0].SVMXA360__ConfigurationId__c;
        recentItem.configurationType = recentItemList[0].SVMXA360__ConfigurationType__c;
        
        Test.startTest();
		Object responseObject = ADM_RecentItemsLightningService.saveRecentItem(JSON.serialize(recentItem));
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
	
        Test.stopTest();
    }

    public static testMethod void testSaveRecentItems(){

        Adm.RecentItemInfo recentItem = new Adm.RecentItemInfo ();
        List<Adm.RecentItemInfo> recentItemList = new List<Adm.RecentItemInfo>();

        for( Integer i = 0; i < 10 ; i++ ) {
            recentItem.configurationName = 'Test Wizard ' + i;
            recentItem.configurationDeveloperName = 'Test_Wizard_' + i;
            recentItem.configurationType = 'Wizard';
            recentItemList.add(recentItem);
        }
        Test.startTest();
        ADM_RecentItemsManager.getInstance().saveRecentItems(recentItemList);
        List<SVMXA360__COMM_Recentitem__c> recentItems = [SELECT Id, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationType__c FROM SVMXA360__COMM_Recentitem__c];
        System.debug('recentItems:' + recentItems);
        System.debug('recentItems size:' + recentItems.size());
        System.assert(recentItems.size() == 10);
	
        Test.stopTest();
    }

    public static testMethod void testSaveNewRecentItem(){

        Adm.RecentItemInfo recentItem = new Adm.RecentItemInfo ();
        recentItem.configurationName = 'Depot Settings';
        recentItem.configurationDeveloperName = 'Depot Settings';
        recentItem.configurationType = 'Depot Settings';
        
        Test.startTest();
		Object responseObject = ADM_RecentItemsLightningService.saveRecentItem(JSON.serialize(recentItem));
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
	
        Test.stopTest();
    }

    public static testMethod void testSaveRecentItem_Invalid(){
		Test.startTest();
		Object responseObject = ADM_RecentItemsLightningService.saveRecentItem(JSON.serialize(''));
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
	
        Test.stopTest();
    }

    public static testMethod void testDeleteRecentItemsDetails(){

        List<SVMXA360__COMM_Recentitem__c> recentItemList = [SELECT Id, SVMXA360__AdminConfigurationName__c, SVMXA360__ConfigurationDeveloperName__c, SVMXA360__ConfigurationId__c, SVMXA360__ConfigurationType__c FROM SVMXA360__COMM_Recentitem__c LIMIT 1];
        System.assert(recentItemList.size() == 1);
        Adm.RecentItemInfo recentItem = new Adm.RecentItemInfo ();
        recentItem.configurationId = recentItemList[0].SVMXA360__ConfigurationId__c;

        Test.startTest();
        Common.ServiceResponse response = ADM_RecentItemsLightningService.deleteRecentItemsDetails(JSON.serialize(new List<Adm.RecentItemInfo>{recentItem}));
		System.assertEquals(response.success, true);
	
        Test.stopTest();
    }

    public static testMethod void testDeleteRecentItemsDetails_Invalid(){
		Test.startTest();
		Common.ServiceResponse response = ADM_RecentItemsLightningService.deleteRecentItemsDetails(JSON.serialize(''));
		System.assertEquals(response.success, false);
	
        Test.stopTest();
    }
}