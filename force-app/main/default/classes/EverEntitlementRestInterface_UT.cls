@IsTest
public class EverEntitlementRestInterface_UT {
    
    private static RestRequest req;
    private static RestResponse res;
    
    static void createRestContext( final String method, final String httpMethod, final String param, final String argument ) {
        
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/ever/entitlement/v1/' + method + '/';
        if((httpMethod == 'GET' ) && argument != ''){
            req.requestURI += argument+'/';
        }
        if(httpMethod == 'POST'){
            req.requestBody = Blob.valueOf(argument);
        }
        
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        if( param != null ) {
            req.addParameter('filter', param );
        }
        
        RestContext.request = req;
        RestContext.response = res;
    }
    
    @testSetup public static void setup() {
        EVER_InteractiveEntitlementEngine_UT.setup();
    }
    
    static testmethod void testGetServiceCoverages() {
        
        Test.startTest();
        
        Case caseRecord = [SELECT Id FROM Case Limit 1];
        createRestContext('getServiceCoverages', 'GET', '{"includeParentAsset":true}', caseRecord.id);
        EverEntitlementRestInterface.doGet();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testGetEntitlementVerificationHistory() {
        
        Test.startTest();
        
        Case caseRecord = [SELECT Id FROM Case Limit 1];
        createRestContext('getEntitlementVerficationHistory', 'GET', null, caseRecord.id);
        EverEntitlementRestInterface.doGet();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testmethod void testSaveServiceCoverage() {
        
        Test.startTest();
        
        Case caseRecord = [SELECT Id FROM Case Limit 1];
        
        Adm.EntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( 'Case' );
        
        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine( 'Case' ).getServiceCoverageDetails(caseRecord.id, entitlementSettings );
        
        serviceCoverage.selectedCoverage = serviceCoverage.contractList.get(0);
        serviceCoverage.selectedCoverage.coverageType = Ever.CoverageType.Contract.name();
        String jsonRequest = JSON.serialize(serviceCoverage);
        
        createRestContext('saveServiceCoverage/'+caseRecord.id, 'POST', null, jsonRequest);
        EverEntitlementRestInterface.doPost();
        
        String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
            
        Test.stopTest();
    }
    
    static testmethod void testGetServiceCoverages_Invalid() {
        
        Test.startTest();
        
        Case caseRecord = [SELECT Id FROM Case Limit 1];
        createRestContext('getServiceCoverages', 'GET', '{"includeParentAsset:true}', caseRecord.id);
        EverEntitlementRestInterface.doGet();
        
        System.assertEquals(res.statusCode, 422);
        
        Test.stopTest();
    }
}