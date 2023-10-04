@IsTest
public class EVER_InteractiveEntitlement_LS_UT {

    @testSetup public static void setup() {

        EVER_AbstractEntitlementEngine_UT.setup();

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
                                              'SVMXA360__OnHoldEntitlements__c' => true,
                                              'SVMXA360__AssignPricebook__c' => false,
                                              'SVMXA360__ApplyStackRanking__c' => false
                                              }, 2
                                         );
        entitlementSettings.get(0).RecordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        entitlementSettings.get(1).RecordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_COMMON_CONFIGURATION).getRecordTypeId();
        SvmxDatabase.insertRecord(entitlementSettings);
    }

    testmethod static void testGetServiceCoverage() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Common.ServiceResponse serviceResponse = EVER_InteractiveEntitlement_LS.getServiceCoverages( caseRecord.id );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_WithSettings() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Adm.EntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( 'Case' );

		Common.ServiceResponse serviceResponse = EVER_InteractiveEntitlement_LS.getServiceCoveragesForSettings( caseRecord.id, JSON.serialize(entitlementSettings) );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );

        Test.stopTest();
    }

    testmethod static void testSaveServiceCoverage() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

		serviceCoverage.selectedCoverage = serviceCoverage.contractList.get(0);

        Common.ServiceResponse serviceResponse = EVER_InteractiveEntitlement_LS.saveServiceCoverage( caseRecord.id, JSON.serialize(serviceCoverage) );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_InvalidParam() {

        Test.startTest();

        Common.ServiceResponse serviceResponse = EVER_InteractiveEntitlement_LS.getServiceCoverages( null );
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        serviceResponse = EVER_InteractiveEntitlement_LS.getServiceCoverages( 'invalid' );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        serviceResponse = EVER_InteractiveEntitlement_LS.getServiceCoveragesForSettings( caseRecord.Id, null );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        serviceResponse = EVER_InteractiveEntitlement_LS.getServiceCoveragesForSettings( caseRecord.Id, '{' );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        Test.stopTest();
    }

    testmethod static void testSaveServiceCoverage_InvalidParam() {

        Test.startTest();

        Common.ServiceResponse serviceResponse = EVER_InteractiveEntitlement_LS.saveServiceCoverage( null, null );
        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        serviceResponse = EVER_InteractiveEntitlement_LS.saveServiceCoverage( 'invalid', null );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        serviceResponse = EVER_InteractiveEntitlement_LS.saveServiceCoverage( caseRecord.Id, null );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        serviceResponse = EVER_InteractiveEntitlement_LS.saveServiceCoverage( caseRecord.Id, '{' );

        System.assert( serviceResponse != null );
        System.assert( serviceResponse.success == false );

        Test.stopTest();
    }
}