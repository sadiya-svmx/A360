@isTest
public class CONF_PageLayoutRunTime_LS_UT {

    @testSetup static void pageLayoutRunTimeTestData(){        
        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__ScreenType__c'=> 'Transaction','SVMXA360__TransactionType__c' =>'Standalone Edit', 
                                                   'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__DeveloperName__c' => 'standaloneedit123','SVMXA360__FieldSets__c' => null});
        SVMXA360__CONF_Layout__c pageLayoutRecord2 = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__ScreenType__c'=> 'Transaction','SVMXA360__TransactionType__c' =>'Source to Target', 
                                                   'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__SourceObjectAPIName__c' => 'Account','SVMXA360__FieldSets__c' => null,
                                                   'SVMXA360__DeveloperName__c' => 'sourcetotarget123'});      
        
        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutSection__c', 
                                               new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id}, 
                                               2);
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id, 'SVMXA360__ObjectAPIName__c' => 'Contact',
            'SVMXA360__ControllerReferenceField__c' => 'AccountId', 'SVMXA360__SourceControllerReferenceField__c' => 'AccountId',
            'SVMXA360__SectionSequence__c' => 1, 'SVMXA360__SortBy__c' => '[{"fieldAPIName":"Name","dataType":"NAME","sortingOrder":"desc"},' +
                '{"fieldAPIName":"Name","dataType":"REFERENCE","sortingOrder":"asc", "relationshipName":"Account", "referenceNameFields":["Name"]}]',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'}, 
        1));
        
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord2.Id, 'SVMXA360__ObjectAPIName__c' => 'Contact',
            'SVMXA360__ControllerReferenceField__c' => 'AccountId', 'SVMXA360__SourceControllerReferenceField__c' => 'AccountId',
            'SVMXA360__SectionSequence__c' => 1, 'SVMXA360__SourceObjectAPIName__c' => 'Contact', 'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
            'Name' => 'Contact (Account ID)', 'SVMXA360__SortBy__c' => null}, 
        1));

        for(sObject sobjectRecord : sobjectRecordList){
            if(sobjectRecord.getSObjectType() == SVMXA360__CONF_LayoutSection__c.getSObjectType()){
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'Name'}, 
                                               4);
            }else{
                SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                                               new Map<String,Object>{'SVMXA360__LayoutRelatedSection__c' => sobjectRecord.Id,
                                                   'SVMXA360__ElementAPIName__c' => 'Name'}, 
                                               4);                
            }
        }
        
        Account accRecord = (Account)SvmxTestDataFactory.insertSObject('Account');
        
        List<Contact> conRecordList = (List<Contact>)SvmxTestDataFactory.insertSObjectList('Contact', 
                                               new Map<String,Object>{'AccountId' => accRecord.Id}, 
                                               2);
        
    }
    
    public static testMethod void testGetPageData_InvalidRequest(){

        Test.startTest();
        String requestJson = '';
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.getPageData(requestJson);
        System.assertEquals(resp.success, false);
        Test.stopTest();
    }
    
    public static testMethod void testGetRecordTypeDetails(){

        Test.startTest();
        String requestJson = 'WorkOrder';
        Object responseObject = CONF_PageLayoutRunTime_LS.getRecordTypeDetails(requestJson);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }

    public static testMethod void testGetRecordTypeDetails_InvalidRequest(){

        Test.startTest();
        String requestJson = '';
        Object responseObject = CONF_PageLayoutRunTime_LS.getRecordTypeDetails(requestJson);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), false);
        Test.stopTest();
    }
    
    public static testMethod void testGetPageData_StandaloneEdit(){
        
        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__TransactionType__c = 'Standalone Edit' LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        System.assert(pageLayoutList.size() == 1, 'Pagelayout not found');
        System.assert(accList.size() == 1, 'Account not found');
        String requestJson = '{"pageLayoutId": "'+ pageLayoutList[0].Id + '" , "recordId":"' + accList[0].Id + '" }';
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.getPageData(requestJson);
        System.assertEquals(resp.success, true);
        Test.stopTest();
    }

    public static testMethod void testGetPageData_SourceToTarget(){
        
        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__TransactionType__c = 'Source to Target' LIMIT 1];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        System.assert(pageLayoutList.size() == 1, 'Pagelayout not found');
        System.assert(accList.size() == 1, 'Account not found');
        String requestJson = '{"pageLayoutId": "'+ pageLayoutList[0].Id + '" , "recordId":"' + accList[0].Id + '" }';
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.getPageData(requestJson);
        System.assertEquals(resp.success, true);
        Test.stopTest();
    }

    public static testmethod void testGetNewChildRecord(){
        Test.startTest();

        String screenType = 'Transaction';
        String objectName = 'Asset';

        //Creating transaction for Source to Target transaction type
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'Test Transaction a',
            'SVMXA360__DeveloperName__c' => 'Test_Transaction_a',
            'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__ScreenType__c' => screenType,
            'SVMXA360__TransactionType__c' => 'Standalone Edit',
            'SVMXA360__FieldSets__c' => null} ); 
        //Creating transaction for Standalone Edit transaction type    
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'Test Transaction b',
            'SVMXA360__DeveloperName__c' => 'Test_Transaction_b',
            'SVMXA360__SourceObjectAPIName__c' => 'Case',    
			'SVMXA360__ObjectAPIName__c' => objectName,
            'SVMXA360__ScreenType__c' => screenType,
            'SVMXA360__TransactionType__c' => 'Source to Target',
            'SVMXA360__FieldSets__c' => null} );     
        //Creating value Object Mapping     
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{
            'Name' => 'AWO Installation - A360',
            'SVMXA360__DeveloperName__c' => 'AWO_Installation_Mapping',
            'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__Type__c' => 'Value Mapping'} );   
        //Creating field Object Mapping       
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMapping__c', new Map<String,Object>{
            'Name' => 'Case to Remote Work Order - A360',
            'SVMXA360__DeveloperName__c' => 'CASE_WORD_Remote_Mapping',
            'SVMXA360__SourceObjectAPIName__c' => 'Case',
            'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__Type__c' => 'Field Mapping'} ); 

        List<SVMXA360__CONF_Layout__c> layoutRecordList = [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__DeveloperName__c = 'Test_Transaction_a' OR SVMXA360__DeveloperName__c = 'Test_Transaction_b' ORDER BY Name ASC]; 
        List<SVMXA360__CONF_ObjectMapping__c> listObjectMapping = [Select Id, SVMXA360__DeveloperName__c, SVMXA360__Type__c, SVMXA360__SourceObjectAPIName__c, SVMXA360__TargetObjectAPIName__c
                                                                    FROM SVMXA360__CONF_ObjectMapping__c WHERE
                                                                    SVMXA360__DeveloperName__c = 'AWO_Installation_Mapping' OR
                                                                    SVMXA360__DeveloperName__c = 'CASE_WORD_Remote_Mapping' ORDER BY SVMXA360__DeveloperName__c ASC];                                                               
        
        //Creating value Object Mapping details                                            
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ObjectMappingDetail__c', new Map<String,Object>{
            'SVMXA360__ObjectMappingID__c' => listObjectMapping.get(0).Id,
            'SVMXA360__TargetFieldAPIName__c' => 'Status',
            'SVMXA360__Type__c' => 'Value',
            'SVMXA360__Value__c' => 'Installed'} ); 
        //Creating field Object Mapping details 
        List<SVMXA360__CONF_ObjectMappingDetail__c> mappingDetailList = new List<SVMXA360__CONF_ObjectMappingDetail__c>();
        SVMXA360__CONF_ObjectMappingDetail__c configDetail1 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'Subject',
            SVMXA360__Value__c = 'test',
            SVMXA360__Type__c = 'Value'
        );
        mappingDetailList.add(configDetail1);
        SVMXA360__CONF_ObjectMappingDetail__c configDetail2 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'CaseId',
            SVMXA360__SourceFieldAPIName__c = 'Id',
            SVMXA360__Type__c = 'Field'
        );
        mappingDetailList.add(configDetail2);
		SVMXA360__CONF_ObjectMappingDetail__c configDetail3 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'Duration',
            SVMXA360__Value__c = '30.0',
            SVMXA360__Type__c = 'Value'
        );
        mappingDetailList.add(configDetail3);
		SVMXA360__CONF_ObjectMappingDetail__c configDetail4 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'SVMXA360__EntitlementDate__c',
            SVMXA360__Value__c = '2021-08-16',
            SVMXA360__Type__c = 'Value'
        );  
        mappingDetailList.add(configDetail4);
        SVMXA360__CONF_ObjectMappingDetail__c configDetail5 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'SVMXA360__ClosedDate__c',
            SVMXA360__Value__c = '2021-08-03T08:08:00.000Z',
            SVMXA360__Type__c = 'Value'
        ); 
        mappingDetailList.add(configDetail5);
        SVMXA360__CONF_ObjectMappingDetail__c configDetail6 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'MinimumCrewSize',
            SVMXA360__Value__c = '10',
            SVMXA360__Type__c = 'Value'
        );  
        mappingDetailList.add(configDetail6);
        SVMXA360__CONF_ObjectMappingDetail__c configDetail7 = new SVMXA360__CONF_ObjectMappingDetail__c(
        	SVMXA360__ObjectMappingID__c = listObjectMapping.get(1).Id,
            SVMXA360__TargetFieldAPIName__c = 'SVMXA360__PerformAutoEntitlement__c',
            SVMXA360__Value__c = 'false',
            SVMXA360__Type__c = 'Value'
        ); 
        mappingDetailList.add(configDetail7);
        insert mappingDetailList;
        //Creating transaction related section for source to target     
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_LayoutRelatedSection__c', new Map<String,Object>{
            'Name' => 'Work Order Details',
            'SVMXA360__Layout__c' => layoutRecordList.get(1).Id,
            'SVMXA360__FieldMapping__c' => listObjectMapping.get(1).Id,
            'SVMXA360__SourceControllerReferenceField__c' => 'ParentId',
            'SVMXA360__SortBy__c' => '[{"fieldAPIName":"Subject","dataType":"STRING","sortingOrder":"desc"},' +  
            						   '{"fieldAPIName":"CaseId","dataType":"REFERENCE","relationshipName":"Case","referenceNameFields":["CaseNumber"],"sortingOrder":"asc"},' +
                					   '{"fieldAPIName":"Duration","dataType":"DOUBLE","sortingOrder":"asc"},' + 
                					   '{"fieldAPIName":"SVMXA360__EntitlementDate__c","dataType":"DATE","sortingOrder":"asc"},' +
                                	   '{"fieldAPIName":"SVMXA360__ClosedDate__c","dataType":"DATETIME","sortingOrder":"asc"},' +
                                       '{"fieldAPIName":"MinimumCrewSize","dataType":"INTEGER","sortingOrder":"asc"},' +
									   '{"fieldAPIName":"SVMXA360__PerformAutoEntitlement__c","dataType":"BOOLEAN","sortingOrder":"asc"}]', 
            'SVMXA360__SourceObjectAPIName__c' => 'Case',
			'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} );  
        //Creating transaction related section for standalone edit     
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_LayoutRelatedSection__c', new Map<String,Object>{
            'Name' => 'Work Order Value Mapping',
            'SVMXA360__Layout__c' => layoutRecordList.get(0).Id,
            'SVMXA360__ControllerReferenceField__c' => 'ParentWorkOrderId',
            'SVMXA360__SortBy__c' => null,  
            'SVMXA360__ValueMapping__c' => listObjectMapping.get(0).Id,
            'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} );     
        //Creating source record for source to target transaction  
        Case sourceRecord = new Case(
            Priority = 'Medium',
            Subject = 'Test Subject',
            Status = 'New',
            SVMXA360__PerformAutoEntitlement__c = false);    
        insert sourceRecord;
        WorkOrder targetRecord = new WorkOrder(            
            Priority = 'Medium',
            Description = 'Test WO',
            Status = 'New',
            SVMXA360__PerformAutoEntitlement__c = false);
        insert targetRecord;
            
        SvmxTestDataFactory.insertSObjectList('Case', 
             new Map<String,Object>{ 
                'ParentId' => sourceRecord.Id,
                'SVMXA360__PerformAutoEntitlement__c' => false
             }, 2); 
        
        String srcRequestJson = '{"pageLayoutId": "'+ layoutRecordList.get(1).SVMXA360__DeveloperName__c + '" , "recordId":"' + sourceRecord.Id + '"}';
		Common.ServiceResponse pageDataResp = CONF_PageLayoutRunTime_LS.getPageData(srcRequestJson);
        System.assertEquals(pageDataResp.success, true);
        
    	String requestJson = '{"pageLayoutId": "'+ layoutRecordList.get(1).SVMXA360__DeveloperName__c + '" , "sourceRecordId":"' + sourceRecord.Id + '" , "detailLineId":"Work Order Details"}';
		Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.getNewChildRecord(requestJson);
        System.assertEquals(resp.success, true);

        String tarRequestJson1 = '{"pageLayoutId": "'+ layoutRecordList.get(0).SVMXA360__DeveloperName__c + '" , "recordId":"' + targetRecord.Id + '"}';
		Common.ServiceResponse pageDataResp1 = CONF_PageLayoutRunTime_LS.getPageData(tarRequestJson1);
        System.assertEquals(pageDataResp1.success, true);

        String requestJson1 = '{"pageLayoutId": "'+ layoutRecordList.get(0).SVMXA360__DeveloperName__c + '" , "detailLineId":"Work Order Value Mapping"}';
        Common.ServiceResponse resp1 = CONF_PageLayoutRunTime_LS.getNewChildRecord(requestJson1);
        System.assertEquals(resp1.success, true);

        Test.stopTest();
    } 
    public static testMethod void testGetNewChildRecord_InvalidRequest(){

        Test.startTest();

        String requestJson = '';
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.getPageData(requestJson);
        System.assertEquals(resp.success, false);

        String requestJson2 = '{"pageLayoutId": "" , "detailLineId":"Work Order Value Mapping"}';
        Common.ServiceResponse resp2 = CONF_PageLayoutRunTime_LS.getNewChildRecord(requestJson2);
        System.assertEquals(resp2.success, false);

        //Creating transaction for Source to Target transaction type
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'Test Transaction 1',
            'SVMXA360__DeveloperName__c' => 'Test_Transaction_1',
            'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
            'SVMXA360__ScreenType__c' => 'Transaction',
            'SVMXA360__TransactionType__c' => 'Source to Target',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} ); 

        List<SVMXA360__CONF_Layout__c> layoutRecordList = [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__DeveloperName__c = 'Test_Transaction_1']; 
        
        String requestJson3 = '{"pageLayoutId": "'+ layoutRecordList.get(0).SVMXA360__DeveloperName__c + '" , "sourceRecordId":"" , "detailLineId":"Work Order Details"}';
        Common.ServiceResponse resp3 = CONF_PageLayoutRunTime_LS.getNewChildRecord(requestJson3);
        // Success should be false when sourceRecordId is not provided
        System.assertEquals(resp3.success, true);
        Test.stopTest();
    }
    
    public static testMethod void testSavePageData(){
        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__TransactionType__c = 'Source to Target' LIMIT 1];
        System.assert(pageLayoutList.size() == 1, 'Pagelayout not found');
    
        List<Account> accList = [SELECT Id, IsDeleted, Name, Type, BillingAddress, ShippingAddress, Phone, Industry, Rating FROM Account LIMIT 1];
        System.assert(accList.size() == 1, 'Account not found');
    
        List<Contact> conList = [SELECT Id, isDeleted, AccountId, LastName, FirstName, Salutation, Name, OtherAddress, MailingAddress, Phone, HasOptedOutOfEmail, HasOptedOutOfFax,
                                DoNotCall, IsEmailBounced FROM Contact Limit 1];
        System.assert(conList.size() == 1, 'Contact not found');
    
        Config.PageDataRequest pdReq = new Config.PageDataRequest();
    
        pdReq.pageLayoutId = pageLayoutList[0].Id;
        pdReq.headerRecord = (sObject)accList[0];
        List<sObject> sobjConList = (List<sObject>)conList;

        Config.PageDetail pageDetail = new Config.PageDetail();
		pageDetail.uniqueKey = 'Contact (Account ID)';
        pageDetail.detailRecords = sobjConList;
		
        List<Config.PageDetail> pageDetails = new List<Config.PageDetail>();
        pageDetails.add(pageDetail);
        
        pdReq.pageDetails = pageDetails;
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.savePageData(JSON.serialize(pdReq));
        System.assertEquals(resp.success, true);
    
        Test.stopTest();
    }
    
    public static testMethod void testSavePageData_QuickSave(){
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__TransactionType__c = 'Source to Target' LIMIT 1];
        System.assert(pageLayoutList.size() == 1, 'Pagelayout not found');
    
        List<Account> accList = [SELECT Id, IsDeleted, Name, Type, BillingAddress, ShippingAddress, Phone, Industry, Rating FROM Account LIMIT 1];
        System.assert(accList.size() == 1, 'Account not found');
    
        List<Contact> conList = [SELECT Id, isDeleted, AccountId, LastName, FirstName, Salutation, Name, OtherAddress, MailingAddress, Phone, HasOptedOutOfEmail, HasOptedOutOfFax,
                                DoNotCall, IsEmailBounced FROM Contact Limit 1];
        System.assert(conList.size() == 1, 'Contact not found');
    
        Config.PageDataRequest pdReq = new Config.PageDataRequest();
    
        pdReq.pageLayoutId = pageLayoutList[0].Id;
        pdReq.headerRecord = (sObject)accList[0];
        pdReq.actionType = 'quicksave';
        List<sObject> sobjConList = (List<sObject>)conList;

        Config.PageDetail pageDetail = new Config.PageDetail();
		pageDetail.uniqueKey = 'Contact (Account ID)';
        pageDetail.detailRecords = sobjConList;
		
        List<Config.PageDetail> pageDetails = new List<Config.PageDetail>();
        pageDetails.add(pageDetail);
        
        pdReq.pageDetails = pageDetails;
        Test.startTest();

        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.savePageData(JSON.serialize(pdReq));
        System.assertEquals(resp.success, true);
    
        Test.stopTest();    
    }
    
    public static testMethod void testSavePageData_EmptyRequest(){
    	Test.startTest();
        Config.PageDataRequest pdReq = new Config.PageDataRequest();
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.savePageData(JSON.serialize(pdReq));
        System.assertEquals(resp.success, false);

        Test.stopTest();
	}
    
    public static testMethod void testSavePageData_EmptyHeader(){
    	Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__TransactionType__c = 'Source to Target' LIMIT 1];
        System.assert(pageLayoutList.size() == 1, 'Pagelayout not found');
        
        Config.PageDataRequest pdReq = new Config.PageDataRequest();
        pdReq.pageLayoutId = pageLayoutList[0].Id;

        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.savePageData(JSON.serialize(pdReq));
        System.assertEquals(resp.success, false);

        Test.stopTest();
	}
    
    public static testMethod void testSavePageData_DeleteLines(){
        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__TransactionType__c = 'Source to Target' LIMIT 1];
        System.assert(pageLayoutList.size() == 1, 'Pagelayout not found');
    
        List<Account> accList = [SELECT Id, IsDeleted, Name, Type, BillingAddress, ShippingAddress, Phone, Industry, Rating FROM Account LIMIT 1];
        System.assert(accList.size() == 1, 'Account not found');
    
        List<Contact> conList = [SELECT Id, isDeleted, AccountId, LastName, FirstName, Salutation, Name, OtherAddress, MailingAddress, Phone, HasOptedOutOfEmail, HasOptedOutOfFax,
                                DoNotCall, IsEmailBounced FROM Contact Limit 1];
        System.assert(conList.size() == 1, 'Contact not found');
    
        Config.PageDataRequest pdReq = new Config.PageDataRequest();
    
        pdReq.pageLayoutId = pageLayoutList[0].Id;
        pdReq.headerRecord = (sObject)accList[0];
        
        Config.PageDetail pageDetail = new Config.PageDetail();
		pageDetail.uniqueKey = 'Contact (Account ID)';
        pageDetail.deleteIds = new List<String>{conList[0].Id};
		
        List<Config.PageDetail> pageDetails = new List<Config.PageDetail>();
        pageDetails.add(pageDetail);

        pdReq.pageDetails = pageDetails;
        Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.savePageData(JSON.serialize(pdReq));
        System.assertEquals(resp.success, true);
    
        Test.stopTest();
	}
    
    public static testMethod void testGetPageLayoutDetails(){

        Test.startTest();
        List<SVMXA360__CONF_Layout__c> pageLayoutList = [SELECT Id FROM SVMXA360__CONF_Layout__c LIMIT 1];
        System.assert(pageLayoutList.size() == 1);
		Object responseObject = CONF_PageLayoutRunTime_LS.getPageLayoutDetails(pageLayoutList[0].Id);
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    public static testMethod void testGetAllPageLayouts(){

        Test.startTest();
		Object responseObject = CONF_PageLayoutRunTime_LS.getAllPageLayouts('Transaction');
        String responseString = responseObject.toString();
        Map<String, Object> deserializedResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString);
		System.assertEquals(deserializedResponse.get('success'), true);
        Test.stopTest();
    }
    
    public static testMethod void testSendToNewRelic(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SvmxTestDataFactory.NewRelicMockEndPoint());
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP605','SVMXA360__Key__c' => 'ENABLE_APP_USAGE_TRACKING', 'SVMXA360__Value__c' => 'f9c8bd26b72a74ebe814d644c139e3e8FFFFNRAL'}, 1);
		Common.ServiceResponse resp = CONF_PageLayoutRunTime_LS.sendToNewRelic('[{"eventType": "SPMRuntime", "Type": "Transaction", "DeveloperName": "Test123"}]');

        System.assertEquals(resp.success, true);
        Test.stopTest();
    }
}