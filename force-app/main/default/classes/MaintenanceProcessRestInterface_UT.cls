@IsTest
public class MaintenanceProcessRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    @testSetup public static void setup() {
        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__SM_MaintenancePlanProcess__c', 
                                                                                new Map<String,Object>{'Name' => 'Test Process 1232', 'SVMXA360__SM_Description__c' =>
                                                                                    'Process for unit tests', 'SVMXA360__SM_isActive__c' => true, 'SVMXA360__SM_Standard__c' => false},
                                                                                2);
        
        Group userGroup = new Group(Name='Group 000001', Type='Queue');
        insert userGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject sampleQueue = new QueueSObject(QueueID = userGroup.id, SObjectType = 'WorkOrder');
            insert sampleQueue;
        }
    }
    
    static testmethod void testGetAllMaintenanceProcesses() {
        
        Test.startTest();
        
        createRestContext('getAllMaintenancePlanProcesses', 'GET', '', '');
        MaintenanceProcessRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetMaintenanceProcessDetail() {
        
        SVMXA360__SM_MaintenancePlanProcess__c mplnRecord = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c LIMIT 1];
        
        Test.startTest();
        
        createRestContext('getMaintenancePlanProcessDetail', 'GET', '', mplnRecord.id );
        MaintenanceProcessRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testSaveMaintenanceProcess() {
        
        SVMXA360__SM_MaintenancePlanProcess__c mplnRecord = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c LIMIT 1];
        Adm.MaintenancePlanProcessDetail maintenancePlanProcessDetail = ADM_MaintenanceProcessManager.getInstance().getProcessDetails( mplnRecord.id );
        
        Test.startTest();
        
        createRestContext('saveMaintenancePlanProcess', 'POST', '', JSON.serialize(maintenancePlanProcessDetail) );
        MaintenanceProcessRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testValidateMaintenancePlanProcess() {
        
        SVMXA360__SM_MaintenancePlanProcess__c mplnRecord = [SELECT Id FROM SVMXA360__SM_MaintenancePlanProcess__c LIMIT 1];
        Adm.MaintenancePlanProcessDetail maintenancePlanProcessDetail = ADM_MaintenanceProcessManager.getInstance().getProcessDetails( mplnRecord.id );
        Adm.MaintenaceProcessValidationRequest validationRequest = new Adm.MaintenaceProcessValidationRequest();
        validationRequest.maintenacePlanProcess = maintenancePlanProcessDetail;
        
        Adm.ReferenceData referenceData = new Adm.ReferenceData();
        referenceData.configType = Adm.ConfigurationType.Mapping;
        
        validationRequest.referenceDatas = new List<Adm.ReferenceData>();
        validationRequest.referenceDatas.add(referenceData);
        
        Adm.ConfigurationData configurationData = new Adm.ConfigurationData();
        configurationData.name = 'Default Map';
        configurationData.developerName = 'Default_Map';
        
        referenceData.configDataList = new List<Adm.ConfigurationData>();
        referenceData.configDataList.add(configurationData);
        
        Test.startTest();
        
        createRestContext('validateMaintenancePlanProcess', 'POST', '', JSON.serialize(validationRequest) );
        MaintenanceProcessRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/mpln/v1/' + method + '/';
        if( httpMethod == 'GET' && argument != ''){
            req.requestURI += argument+'/';
        }
        if(httpMethod == 'POST'){
            req.requestBody = Blob.valueOf(argument);
        }
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        req.addParameter('objectName', param );
        
        RestContext.request = req;
        RestContext.response = res;
    }
}