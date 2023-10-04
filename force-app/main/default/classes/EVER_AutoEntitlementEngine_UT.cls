@isTest
public class EVER_AutoEntitlementEngine_UT {

    @testSetup public static void setup() {

        EVER_AbstractEntitlementEngine_UT.setup();

        SVMXA360__CONF_Expression__c expressionRecord1 = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c',
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => 'Expression_New_Case',
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Case',
                                                                                                                        'SVMXA360__ExpressionType__c' => 'EVER-RULE-CRITERIA',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '1'
                                                                                                                        });

        SVMXA360__CONF_Expression__c expressionRecord2 = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c',
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => 'Expression_Working_Case',
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'Case',
                                                                                                                        'SVMXA360__ExpressionType__c' => 'EVER-RULE-CRITERIA',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '1'
                                                                                                                        });

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c',
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRecord1.id,
                                                  'SVMXA360__FieldAPIName__c' => 'Status',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'New',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                  'SVMXA360__RelationshipName__c' => null,
                                                  'SVMXA360__RelatedObjectDetails__c' => null,
                                                  'SVMXA360__SourceObjectName__c' => null,
												  'SVMXA360__OperandType__c' => 'Value'}, 1);

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c',
                                                  new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRecord2.id,
                                                      'SVMXA360__FieldAPIName__c' => 'Status',
                                                      'SVMXA360__Operator__c' => 'eq',
                                                      'SVMXA360__Operand__c' => 'Working',
                                                      'SVMXA360__Sequence__c' => 1,
                                                      'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                      'SVMXA360__RelationshipName__c' => null,
                                                      'SVMXA360__RelatedObjectDetails__c' => null,
                                                      'SVMXA360__SourceObjectName__c' => null,
													  'SVMXA360__OperandType__c' => 'Value'}, 1);

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_EntitlementRule__c',
                                          new Map<String,Object>{
                                              'SVMXA360__ObjectAPIName__c' => 'Case',
                                              'SVMXA360__Sequence__c' => 1,
                                              'SVMXA360__DeveloperName__c' => 'Entitlement_Rule_Multiple_Found',
                                              'SVMXA360__Expression__c' => expressionRecord1.id,
                                              'SVMXA360__MatchContact__c' => false,
                                              'SVMXA360__MatchAccount__c' => true,
                                              'SVMXA360__ResolutionMethod__c' => 'MULTIPLE-FOUND',
                                              'SVMXA360__WarrantyTypes__c' => 'Standard',
                                              'SVMXA360__AssetAPIName__c' => 'AssetId',
                                              'SVMXA360__AccountAPIName__c' => 'AccountId'}
                                         );
        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_EntitlementRule__c',
                                          new Map<String,Object>{
                                              'SVMXA360__ObjectAPIName__c' => 'Case',
                                              'SVMXA360__Sequence__c' => 2,
                                              'SVMXA360__DeveloperName__c' => 'Entitlement_Rule_Use_Contract',
                                              'SVMXA360__Expression__c' => expressionRecord2.id,
                                              'SVMXA360__MatchContact__c' => false,
                                              'SVMXA360__MatchAccount__c' => true,
                                              'SVMXA360__ResolutionMethod__c' => 'USE-CONTRACT',
                                              'SVMXA360__WarrantyTypes__c' => 'Standard',
                                              'SVMXA360__AssetAPIName__c' => 'AssetId',
                                              'SVMXA360__AccountAPIName__c' => 'AccountId'}
                                         );

        List<SVMXA360__CONF_EntitlementSettings__c> entitlementSettings = (List<SVMXA360__CONF_EntitlementSettings__c>) SvmxTestDataFactory.createSObjectList( 'SVMXA360__CONF_EntitlementSettings__c',
                                                  new Map<String,Object>{
                                                      'SVMXA360__ObjectAPIName__c' => 'Case',
                                                      'SVMXA360__MatchAccount__c' => false,
                                                      'SVMXA360__CoveredBy__c ' => 'Asset',
                                                      'SVMXA360__AssetAPIName__c' => 'AssetId',
                                                      'SVMXA360__AccountAPIName__c' => 'AccountId',
                                                      'SVMXA360__InheritServiceOnWorkOrder__c' => false,
                                                      'SVMXA360__InheritServiceOnReturnOrder__c' => false,
                                                      'SVMXA360__AssignEntitledService__c' => false,
                                                      'SVMXA360__AssignPricebook__c' => false,
                                                      'SVMXA360__ApplyStackRanking__c' => true,
                                                      'SVMXA360__ContractStackRankingFieldAPIName__c' => 'LastModifiedDate',
                                                      'SVMXA360__WarrantyStackRankingFieldAPIName__c' => 'LastModifiedDate',
                                                      'SVMXA360__ContractStackRankingOrder__c' => 'Ascending',
                                                      'SVMXA360__WarrantyStackRankingOrder__c' => 'Ascending'
                                                      }, 1
                                                 );
        entitlementSettings.get(0).RecordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
        SvmxDatabase.insertRecord(entitlementSettings);
    }
    
    testmethod static void testPerformAutoEntitlement() {

        Test.startTest();

        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id FROM Case] ) {

            caseRecord.Status = 'Working';
            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final List<Entitlement> entitlementList = new List<Entitlement>();
        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id, LineItemNumber, ServiceContract.AccountId FROM ContractLineItem] ) {

            contractLineRecord.StartDate = Date.today().addYears(-1);
            contractLineRecord.EndDate = Date.today().addYears(1);

            contractLineItemList.add(contractLineRecord);
            entitlementList.add( new Entitlement(Name = String.valueOf(contractLineRecord.LineItemNumber), ContractLineItemId = contractLineRecord.id, AccountId = contractLineRecord.ServiceContract.AccountId, StartDate = contractLineRecord.StartDate, EndDate = contractLineRecord.EndDate) );
        }

        insert entitlementList;
        update contractLineItemList;
        
        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = Date.today().addYears(-2);
            assetWarranty.EndDate = Date.today().addYears(-1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, EntitlementId, SVMXA360__BillingType__c, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId == null, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.AssetWarrantyId == null, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.SVMXA360__BillingType__c != null, caseRecord.SVMXA360__BillingType__c);
            System.assert(caseRecord.SVMXA360__BillingType__c.equalsIgnoreCase('Contract'), caseRecord.SVMXA360__BillingType__c);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c, SVMXA360__BillingType__c, SVMXA360__EntitlementId__c, SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == true);
            System.assert(history.SVMXA360__ServiceContractId__c == null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__BillingType__c != null, history.SVMXA360__BillingType__c);
            System.assert(history.SVMXA360__BillingType__c.equalsIgnoreCase('Contract'), history.SVMXA360__BillingType__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_CoveredByAccount() {

        Test.startTest();

        SVMXA360__CONF_EntitlementRule__c entitlementRule = [SELECT Id FROM SVMXA360__CONF_EntitlementRule__c WHERE SVMXA360__DeveloperName__c = 'Entitlement_Rule_Use_Contract'];
        entitlementRule.SVMXA360__CoveredBy__c = 'Account';

        update entitlementRule;

        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id FROM Case LIMIT 1] ) {

            caseRecord.Status = 'Working';
            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id FROM ContractLineItem LIMIT 1] ) {

            contractLineRecord.StartDate = Date.today().addYears(-1);
            contractLineRecord.EndDate = Date.today().addYears(1);

            contractLineItemList.add(contractLineRecord);
        }

        update contractLineItemList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case LIMIT 1] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            //System.assert(caseRecord.ServiceContractId != null, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.AssetWarrantyId == null, caseRecord.SVMXA360__EntitlementNotes__c);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == false);
            System.assert(history.SVMXA360__ServiceContractId__c != null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_MultipleFound() {

        Test.startTest();

        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id FROM Case] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }
        update caseRecordList;

        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id FROM ContractLineItem] ) {

            contractLineRecord.StartDate = Date.today().addYears(-1);
            contractLineRecord.EndDate = Date.today().addYears(1);

            contractLineItemList.add(contractLineRecord);
        }
        update contractLineItemList;
        
        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = Date.today().addYears(-1);
            assetWarranty.EndDate = Date.today().addYears(1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId == null);
            System.assert(caseRecord.AssetWarrantyId == null);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c, SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__ServiceContractId__c == null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }
    
    testmethod static void testPerformAutoEntitlement_NoCoverageFound() {

        Test.startTest();

        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id FROM Case] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }
        update caseRecordList;

        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id FROM ContractLineItem] ) {

            contractLineRecord.StartDate = Date.today().addYears(-2);
            contractLineRecord.EndDate = Date.today().addYears(-1);

            contractLineItemList.add(contractLineRecord);
        }
        update contractLineItemList;

        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = Date.today().addYears(-2);
            assetWarranty.EndDate = Date.today().addYears(-1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId == null);
            System.assert(caseRecord.AssetWarrantyId == null, caseRecord.SVMXA360__EntitlementNotes__c);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == false );
            System.assert(history.SVMXA360__ServiceContractId__c == null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }
    
    testmethod static void testPerformAutoEntitlement_OneCoverageFound() {

        Test.startTest();

        final Set<String> assetIds = new Set<String>();
        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id, AssetId FROM Case LIMIT 5] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            assetIds.add(caseRecord.AssetId);
            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final Set<String> updatedAssetIds = new Set<String>();
        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id, AssetId FROM ContractLineItem] ) {

            contractLineRecord.StartDate = updatedAssetIds.contains(contractLineRecord.AssetId) ? Date.today().addYears(-2) : Date.today().addYears(-1);
            contractLineRecord.EndDate = updatedAssetIds.contains(contractLineRecord.AssetId) ? Date.today().addYears(-1) : Date.today().addYears(1);

            updatedAssetIds.add(contractLineRecord.AssetId);
            contractLineItemList.add(contractLineRecord);
        }

        update ContractLineItemList;

        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = Date.today().addYears(-2);
            assetWarranty.EndDate = Date.today().addYears(-1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId != null, caseRecord.SVMXA360__EntitlementNotes__c );
            System.assert(caseRecord.AssetWarrantyId == null);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == false );
            System.assert(history.SVMXA360__ServiceContractId__c != null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_OneCoverageEntitlementFound() {

        Test.startTest();

        final Set<String> assetIds = new Set<String>();
        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id, AssetId FROM Case LIMIT 5] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            assetIds.add(caseRecord.AssetId);
            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final Set<String> updatedAssetIds = new Set<String>();
        final List<Entitlement> entitlementList = new List<Entitlement>();
        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id, LineItemNumber, AssetId, ServiceContract.AccountId FROM ContractLineItem] ) {

            contractLineRecord.StartDate = updatedAssetIds.contains(contractLineRecord.AssetId) ? Date.today().addYears(-2) : Date.today().addYears(-1);
            contractLineRecord.EndDate = updatedAssetIds.contains(contractLineRecord.AssetId) ? Date.today().addYears(-1) : Date.today().addYears(1);

            updatedAssetIds.add(contractLineRecord.AssetId);
            contractLineItemList.add(contractLineRecord);
            entitlementList.add( new Entitlement(Name = String.valueOf(contractLineRecord.LineItemNumber), ContractLineItemId = contractLineRecord.id, AccountId = contractLineRecord.ServiceContract.AccountId, StartDate = contractLineRecord.StartDate, EndDate = contractLineRecord.EndDate) );
        }

        insert entitlementList;
        update ContractLineItemList;

        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = Date.today().addYears(-2);
            assetWarranty.EndDate = Date.today().addYears(-1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, EntitlementId, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId != null, caseRecord.SVMXA360__EntitlementNotes__c );
            //System.assert(caseRecord.EntitlementId != null, caseRecord.SVMXA360__EntitlementNotes__c );
            System.assert(caseRecord.AssetWarrantyId == null);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__EntitlementId__c, SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == false );
            System.assert(history.SVMXA360__ServiceContractId__c != null, history.SVMXA360__EntitlementNotes__c);
            //System.assert(history.SVMXA360__EntitlementId__c != null, history.SVMXA360__EntitlementNotes__c );
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_OneCoverageMultipleEntitlementFound() {

        Test.startTest();

        final Set<String> assetIds = new Set<String>();
        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id, AssetId FROM Case LIMIT 5] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            assetIds.add(caseRecord.AssetId);
            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final Set<String> updatedAssetIds = new Set<String>();
        final List<Entitlement> entitlementList = new List<Entitlement>();
        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id, LineItemNumber, AssetId, ServiceContract.AccountId FROM ContractLineItem] ) {

            contractLineRecord.StartDate = updatedAssetIds.contains(contractLineRecord.AssetId) ? Date.today().addYears(-2) : Date.today().addYears(-1);
            contractLineRecord.EndDate = updatedAssetIds.contains(contractLineRecord.AssetId) ? Date.today().addYears(-1) : Date.today().addYears(1);

            updatedAssetIds.add(contractLineRecord.AssetId);
            contractLineItemList.add(contractLineRecord);
            entitlementList.add( new Entitlement(Name = String.valueOf(contractLineRecord.LineItemNumber) + '1', ContractLineItemId = contractLineRecord.id, AccountId = contractLineRecord.ServiceContract.AccountId, StartDate = contractLineRecord.StartDate, EndDate = contractLineRecord.EndDate) );
            entitlementList.add( new Entitlement(Name = String.valueOf(contractLineRecord.LineItemNumber) + '2', ContractLineItemId = contractLineRecord.id, AccountId = contractLineRecord.ServiceContract.AccountId, StartDate = contractLineRecord.StartDate, EndDate = contractLineRecord.EndDate) );
            entitlementList.add( new Entitlement(Name = String.valueOf(contractLineRecord.LineItemNumber) + '3', ContractLineItemId = contractLineRecord.id, AccountId = contractLineRecord.ServiceContract.AccountId, StartDate = Date.today().addYears(-2), EndDate = Date.today().addYears(-1) ) );
        }

        insert entitlementList;
        update ContractLineItemList;

        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = Date.today().addYears(-2);
            assetWarranty.EndDate = Date.today().addYears(-1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, EntitlementId, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId != null, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.AssetWarrantyId == null, caseRecord.SVMXA360__EntitlementNotes__c);
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleEntitlement__c, SVMXA360__EntitlementId__c, SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            //System.assert(history.SVMXA360__MultipleEntitlement__c );
            System.assert(history.SVMXA360__ServiceContractId__c != null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_OneWarrantyFound() {

        Test.startTest();

        final Set<String> assetIds = new Set<String>();
        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id, AssetId FROM Case LIMIT 5] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            assetIds.add(caseRecord.AssetId);
            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id, AssetId FROM ContractLineItem] ) {

            contractLineRecord.StartDate = Date.today().addYears(-2);
            contractLineRecord.EndDate = Date.today().addYears(-1);

            contractLineItemList.add(contractLineRecord);
        }

        update ContractLineItemList;

        final Set<String> updatedAssetIds = new Set<String>();
        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty] ) {

            assetWarranty.StartDate = updatedAssetIds.contains(assetWarranty.AssetId) ? Date.today().addYears(-2) : Date.today().addYears(-1);
            assetWarranty.EndDate = updatedAssetIds.contains(assetWarranty.AssetId) ? Date.today().addYears(-1) : Date.today().addYears(1);

            updatedAssetIds.add(assetWarranty.AssetId);
            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId == null, caseRecord.SVMXA360__EntitlementNotes__c );
            System.assert(caseRecord.AssetWarrantyId != null, caseRecord.SVMXA360__EntitlementNotes__c );
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c,SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == false );
            System.assert(history.SVMXA360__ServiceContractId__c == null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c != null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_MultipleWarrantyFound() {

        Test.startTest();

        SVMXA360__CONF_EntitlementRule__c entitlementRule = [SELECT Id FROM SVMXA360__CONF_EntitlementRule__c WHERE SVMXA360__DeveloperName__c = 'Entitlement_Rule_Multiple_Found'];
        entitlementRule.SVMXA360__ResolutionMethod__c = 'USE-WARRANTY';

        update entitlementRule;

        final Set<String> assetIds = new Set<String>();
        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id, AssetId FROM Case LIMIT 5] ) {

            caseRecord.SVMXA360__EntitlementDate__c = Date.today();

            assetIds.add(caseRecord.AssetId);
            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        final List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        for( ContractLineItem contractLineRecord : [SELECT Id, AssetId FROM ContractLineItem] ) {

            contractLineRecord.StartDate = Date.today().addYears(-2);
            contractLineRecord.EndDate = Date.today().addYears(-1);

            contractLineItemList.add(contractLineRecord);
        }

        update ContractLineItemList;

        final List<AssetWarranty> assetWarrantyList = new List<AssetWarranty>();
        for( AssetWarranty assetWarranty : [SELECT Id, AssetId FROM AssetWarranty WHERE AssetId IN :assetIds] ) {

            assetWarranty.StartDate = Date.today().addYears(-1);
            assetWarranty.EndDate = Date.today().addYears(1);

            assetWarrantyList.add(assetWarranty);
        }

        update assetWarrantyList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, ServiceContractId, AssetWarrantyId, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert(caseRecord.ServiceContractId == null, caseRecord.SVMXA360__EntitlementNotes__c );
            System.assert(caseRecord.AssetWarrantyId == null, caseRecord.SVMXA360__EntitlementNotes__c );
        }

        for( EntitlementVerificationHistory__c history : [SELECT SVMXA360__CaseId__c , SVMXA360__MultipleCoverages__c, SVMXA360__ServiceContractId__c, SVMXA360__AssetWarrantyId__c, SVMXA360__EntitlementNotes__c FROM EntitlementVerificationHistory__c]) {

            System.assert(history.SVMXA360__CaseId__c != null);
            System.assert( String.isNotBlank(history.SVMXA360__EntitlementNotes__c) );
            System.assert(history.SVMXA360__MultipleCoverages__c == true );
            System.assert(history.SVMXA360__ServiceContractId__c == null, history.SVMXA360__EntitlementNotes__c);
            System.assert(history.SVMXA360__AssetWarrantyId__c == null, history.SVMXA360__EntitlementNotes__c);
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_InvalidSourceObject() {

        Test.startTest();

        final List<String> caseIds = new List<String>();
        final List<Case> caseRecordList = new List<Case>();

        for( Case caseRecord : [SELECT Id FROM Case LIMIT 5] ) {

            caseRecord.AccountId = null;

            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert( caseRecord.SVMXA360__IsEntitlementPerformed__c == false, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert( String.isNotBlank( caseRecord.SVMXA360__EntitlementNotes__c ), caseRecord.SVMXA360__EntitlementNotes__c );
        }

        caseIds.clear();
        caseRecordList.clear();
        for( Case caseRecord : [SELECT Id FROM Case LIMIT 5] ) {

            caseRecord.AssetId = null;

            caseIds.add(caseRecord.Id);
            caseRecordList.add(caseRecord);
        }

        update caseRecordList;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c == false, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert( String.isNotBlank( caseRecord.SVMXA360__EntitlementNotes__c ), caseRecord.SVMXA360__EntitlementNotes__c );
        }

        SVMXA360__CONF_EntitlementRule__c entitlementRule = [SELECT Id FROM SVMXA360__CONF_EntitlementRule__c WHERE SVMXA360__DeveloperName__c = 'Entitlement_Rule_Multiple_Found'];
        entitlementRule.SVMXA360__CoveredBy__c = 'Account';

        update entitlementRule;

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( caseIds );

        for( Case caseRecord : [SELECT Id, SVMXA360__IsEntitlementPerformed__c, SVMXA360__EntitlementNotes__c FROM Case WHERE id = :caseIds ] ) {

            System.assert(caseRecord.SVMXA360__IsEntitlementPerformed__c == false, caseRecord.SVMXA360__EntitlementNotes__c);
            System.assert( String.isNotBlank( caseRecord.SVMXA360__EntitlementNotes__c ), caseRecord.SVMXA360__EntitlementNotes__c );
        }

        Test.stopTest();
    }

    testmethod static void testPerformAutoEntitlement_InvalidParam() {

        Test.startTest();

        new EVER_AutoEntitlementEngine('Case').performAutoEntitlement( new List<String>() );

        List<String> inputParamList = new List<String> { null, '' };

        for( String inputParam : inputParamList ) {

            try {
                new EVER_AutoEntitlementEngine(inputParam);
                System.assert(false);
            }
            catch( Exception e ) {
                System.assert(true);
            }
        }

        Test.stopTest();
    }

    testmethod static void testPopulateWorkOrderPricebook() {

        Test.startTest();

        final List<SObject> workOrderList = new List<SObject>();
        Map<Id, String> workOrderPricebookMap = new Map<Id, String> ();

        Pricebook2 pricebook =
        (Pricebook2)SvmxTestDataFactory.insertSObject('Pricebook2', new Map<String,Object>{'IsActive'=> true, 'Description'=>'Auto Entitlement Test Pricebook', 'Name'=> 'Auto Entitlement Test Pricebook'});


        SVMXA360__CONF_Expression__c qualifyingRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c',
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => 'Expression_Working_WorkOrder',
                                                                                                                        'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
                                                                                                                        'SVMXA360__ExpressionType__c' => 'EVER-RULE-CRITERIA',
                                                                                                                        'SVMXA360__AdvancedExpression__c' => '1'
                                                                                                                        });

        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ExpressionDetail__c',
                                              new Map<String,Object>{'SVMXA360__ExpressionId__c' => qualifyingRec.id,
                                                  'SVMXA360__FieldAPIName__c' => 'Status',
                                                  'SVMXA360__Operator__c' => 'eq',
                                                  'SVMXA360__Operand__c' => 'New',
                                                  'SVMXA360__Sequence__c' => 1,
                                                  'SVMXA360__RelationshipFieldAPIName__c' => null,
                                                  'SVMXA360__RelationshipName__c' => null,
                                                  'SVMXA360__RelatedObjectDetails__c' => null,
                                                      'SVMXA360__SourceObjectName__c' => null,
                                                  'SVMXA360__OperandType__c' => 'Value'}, 1);

        SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_PricebookAssignmentRule__c',
                                                  new Map<String,Object>{
                                                      'SVMXA360__ObjectAPIName__c' => 'WorkOrder',
                                                      'SVMXA360__Sequence__c' => 1,
                                                      'SVMXA360__DeveloperName__c' => 'PriceAssignment_Rule_Multiple_Found',
                                                      'SVMXA360__Active__c' => true,
                                                      'SVMXA360__ExpressionId__c' => qualifyingRec.Id,
                                                      'SVMXA360__Pricebook__c' => pricebook.Id}
                                                 );

        WorkOrder workOrderRecord = new WorkOrder(Status = 'New');

        workOrderList.add(workOrderRecord);

        workOrderPricebookMap.put(workOrderRecord.Id, pricebook.Id);

        new EVER_AutoEntitlementEngine('WorkOrder').populateWorkOrderPricebook( workOrderList, workOrderPricebookMap );

        System.assert(workOrderRecord.Pricebook2Id != null);

        workOrderPricebookMap.clear();

        workOrderRecord.Pricebook2Id = null;

        new EVER_AutoEntitlementEngine('WorkOrder').populateWorkOrderPricebook( workOrderList, workOrderPricebookMap );

        System.assert(workOrderRecord.Pricebook2Id != null);

        Test.stopTest();
    }

    testmethod static void testPopulateWorkOrderPricebook_InvalidParam() {

        Test.startTest();

        try {
            new EVER_AutoEntitlementEngine('WorkOrder').populateWorkOrderPricebook( null, null );
            System.assert(false);
        }
        catch( Exception e ) {
            System.assert(true);
        }


        Test.stopTest();
    }
    
}