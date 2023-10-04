@isTest
public class PageLayoutRestInterface_UT {
    public Static RestRequest req;
    public Static RestResponse res;
    
    @testSetup static void pageLayoutTestData(){
        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                                                          new Map<String,Object>{'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
                                                                              'SVMXA360__ObjectAPIName__c' => 'Account'});
        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutSection__c', 
                                               new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id}, 
                                               2);
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id, 'SVMXA360__FieldSets__c' => '["fls1","fls2"]', 'SVMXA360__ObjectAPIName__c' => 'Contact'}, 
        2));

        for(sObject sobjectRecord : sobjectRecordList){
            if(sobjectRecord.getSObjectType() == SVMXA360__CONF_LayoutSection__c.getSObjectType()){
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutSection__c' => sobjectRecord.Id}, 
                                               4);
            }else{
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutRelatedSection__c' => sobjectRecord.Id}, 
                                               4);                
            }
        }
    }
    
    static testmethod void testGetPageLayoutDetails_Rest(){
        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        
        System.assert(pageLayoutList.size() == 1);
          
        restUtils('getPageLayoutDetails', 'GET', pageLayoutList[0].Id);
        PageLayoutRestInterface.doPost();
        
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    static testmethod void testGetListOfLayouts_Rest(){
        Test.startTest();
        restUtils('getAllPageLayouts', 'GET', '');
        PageLayoutRestInterface.doGet();
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }

    static testmethod void testGetCustomLabels_Rest(){
        Test.startTest();
        restUtils('getPageLayoutCustomLabels', 'GET', '');
        PageLayoutRestInterface.doGet();
		String responseStr = res.responseBody.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.stopTest();
    }
    
	static testMethod void testSavePageLayout_Rest(){
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        
        System.assert(pageLayoutList.size() == 1);
          
        restUtils('getPageLayoutDetails', 'GET', pageLayoutList[0].Id);
        PageLayoutRestInterface.doPost();
        String responseStr = res.responseBody.toString(); 
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);

        Test.startTest();
		object requestObject = (object)deserializedResponse.get('data');
        restUtils('savePageLayout', 'POST', JSON.serialize(requestObject));
		PageLayoutRestInterface.doPost();	
        responseStr = res.responseBody.toString(); 
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    static testMethod void testSaveAllPageLayouts_Rest_Invalid(){
        Test.startTest();
        List<Adm.PageLayout> pageLayout = new List<Adm.PageLayout>();
        restUtils('savePageLayouts', 'POST', JSON.serialize(pageLayout));
		PageLayoutRestInterface.doPost();	
        String responseStr = res.responseBody.toString(); 
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        Test.stopTest();        
    }
    
    static testMethod void testSaveAllPageLayouts_Rest(){
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        
        System.assert(pageLayoutList.size() == 1);
          
        restUtils('getAllPageLayoutsWithDetails', 'GET', null);
        PageLayoutRestInterface.doGet();
        String responseStr = res.responseBody.toString(); 
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);   
        
        Test.startTest();
		object requestObject = (object)deserializedResponse.get('data');
        restUtils('savePageLayouts', 'POST', JSON.serialize(requestObject));
		PageLayoutRestInterface.doPost();	
        responseStr = res.responseBody.toString(); 
        deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    static testMethod void testValidatePageLayout_Rest() {
        
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        
        System.assert(pageLayoutList.size() == 1);

        Test.startTest();
        List<Adm.PageLayout> pageLayouts = ADM_PageLayoutManager.getInstance().getAllPageLayoutsWithDetails();
        
        final Adm.PageLayoutValidationRequest request = new Adm.PageLayoutValidationRequest();
        request.pageLayout = pageLayouts.get(0);
        request.referenceDatas = new List<Adm.ReferenceData>();
        
        restUtils('validatePageLayout', 'POST', JSON.serialize(request));
		PageLayoutRestInterface.doPost();	
        final String responseStr = res.responseBody.toString(); 
        final Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        
        Test.stopTest();
    }
    
    static testMethod void testGetAllPageLayoutsDetails_Rest(){
        Test.startTest();
        restUtils('getAllPageLayoutsWithDetails', 'GET', null);
        PageLayoutRestInterface.doGet();
        String responseStr = res.responseBody.toString(); 
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    static testMethod void testDeletePageLayout_Rest(){
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        
        System.assert(pageLayoutList.size() == 1);

        Test.startTest();
        restUtils('deletePageLayout', 'DELETE', pageLayoutList[0].Id);
		PageLayoutRestInterface.doPost();	
        String responseStr = res.responseBody.toString(); 
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }   

    static testMethod void testDeletePageLayout_RestInvalid(){
        Test.startTest();
        restUtils('deletePageLayout', 'DELETE', '');
		PageLayoutRestInterface.doPost();	
        String responseStr = res.responseBody.toString(); 
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseStr);
        System.assertEquals(deserializedResponse.get('success'), false);
        
        Test.stopTest();
    }    
    
	static testmethod void testGetPageLayoutDetails_Rest_InvalidRequest(){
        Test.startTest();
        
        Adm.PageLayout request = new Adm.PageLayout();
        
        String serializedRequest = JSON.serialize(request);
        
        restUtils('xxxxxxxxxx', 'GET', serializedRequest);
        PageLayoutRestInterface.doPost();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.NOT_FOUND, res.statusCode);
        
        restUtils('', 'GET', '');
        PageLayoutRestInterface.doPost();
        
        System.assert( res.statusCode == COMM_SvmxRestBase.BAD_REQUEST, res.statusCode);
        
        Test.stopTest();    
    }
    
    Static void restUtils(String endPointUrl, String httpMethod, String serializedRequest){
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/svmx/rest/PageLayoutRestInterface/v1/' + endPointUrl + '/';
        if((httpMethod == 'GET' || httpMethod == 'DELETE') && serializedRequest != ''){
            req.requestURI += serializedRequest+'/';
        }
        if(httpMethod == 'POST'){
           req.requestBody = Blob.valueOf(serializedRequest);
        }
        System.debug(loggingLevel.Info , 'URL ' + req.requestURI);
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = httpMethod;
        
        RestContext.request = req;
        RestContext.response = res;
    }
}