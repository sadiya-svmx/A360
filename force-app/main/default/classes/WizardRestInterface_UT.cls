@IsTest
public class WizardRestInterface_UT {

    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/admin/wizard/v1/' + method + '/';
        if((httpMethod == 'GET' || httpMethod == 'DELETE') && argument != ''){
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
    
    @testSetup public static void setup() {
        List<SVMXA360__CONF_ProcessWizard__c> wizardRecordList = (List<SVMXA360__CONF_ProcessWizard__c>)SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_ProcessWizard__c', 1 );

        wizardRecordList[0].SVMXA360__ObjectAPIName__c = 'Account';
        wizardRecordList[0].SVMXA360__Active__c = true;

        insert wizardRecordList;
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                                               new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id}, 
                                               5 );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                                               new Map<String,Object>{
                                                   'SVMXA360__ProcessWizard__c' => wizardRecordList[0].Id,
                                                   'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                               2 );
    }
    
    static testmethod void testGetAllActiveProcessWizardDetails() {
        
        Test.startTest();
        
        createRestContext('getAllActiveProcessWizardDetails', 'GET', '', '');
        WizardRestInterface.doGet();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }

    static testmethod void testSaveProcessWizards() {
        List<SVMXA360__CONF_ProcessWizard__c> wizards = [SELECT Id FROM SVMXA360__CONF_ProcessWizard__c LIMIT 1];
        System.assert(wizards.size() ==  1);

        Adm.ProcessWizard processWizard = ADM_ProcessWizardManager.getInstance().getProcessWizardDetails(wizards[0].id);
        processWizard.isModified = true;
        List<Adm.ProcessWizard> processWizards = new List<Adm.ProcessWizard>{processWizard};
        Adm.WizardRequest wizardRequest = new Adm.WizardRequest();
        wizardRequest.wizardList = processWizards;
        wizardRequest.objectApiNameList = new List<String>{'Account'};
        Test.startTest();
        
        createRestContext('saveProcessWizards', 'POST', '', JSON.serialize(wizardRequest));
        WizardRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testDoGet_WizardinvalidMethod() {
        
        Test.startTest();
        
        createRestContext('', 'GET', '', '');
        WizardRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.BAD_REQUEST, res.statusCode);
        
        Test.stopTest();
    }

    static testmethod void testDoGet_Unsupported() {
        
        Test.startTest();
        
        createRestContext('Unsupported', 'GET', '', '');
        WizardRestInterface.doGet();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.NOT_FOUND, res.statusCode);
        
        Test.stopTest();
    }
}