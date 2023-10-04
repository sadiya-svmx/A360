@isTest
public class EVER_InteractiveEntitlementEngine_UT {

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
        Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSettings = [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId];
        entitlementSettings.SVMXA360__FutureEntitlements__c  = false;
        entitlementSettings.SVMXA360__ExpiredEntitlements__c  = false;
        update entitlementSettings;

        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_CoveredByAccount() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSettings = [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId];
        entitlementSettings.SVMXA360__FutureEntitlements__c  = false;
        entitlementSettings.SVMXA360__ExpiredEntitlements__c  = false;
        entitlementSettings.SVMXA360__CoveredBy__c = 'Account';
        update entitlementSettings;

        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_FutureEntitlements() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSettings = [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId];
        entitlementSettings.SVMXA360__FutureEntitlements__c  = true;
        entitlementSettings.SVMXA360__ExpiredEntitlements__c  = false;
        update entitlementSettings;

        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_ExpiredEntitlements() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSettings = [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId];
        entitlementSettings.SVMXA360__FutureEntitlements__c  = false;
        entitlementSettings.SVMXA360__ExpiredEntitlements__c  = true;
        update entitlementSettings;

        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_FutureExpiredEntitlements() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSettings = [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId];
        entitlementSettings.SVMXA360__FutureEntitlements__c  = true;
        entitlementSettings.SVMXA360__ExpiredEntitlements__c  = true;
        update entitlementSettings;

        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_WithSettings() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Adm.EntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( 'Case' );
        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id, entitlementSettings );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_MissingAssetField() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        caseRecord.AssetId = null;
        update caseRecord;

        Adm.EntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( 'Case' );

        try {
            new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id, entitlementSettings );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_MissingAccountField() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        caseRecord.AccountId = null;
        update caseRecord;

        Id recordTypeId = SVMXA360__CONF_EntitlementSettings__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(ADM_EntitlementSettingsManager.RECORD_TYPE_OBJECT_CONFIGURATION).getRecordTypeId();
        SVMXA360__CONF_EntitlementSettings__c entitlementSettingsRecord = [SELECT Id FROM SVMXA360__CONF_EntitlementSettings__c WHERE RecordTypeId = :recordTypeId];
        entitlementSettingsRecord.SVMXA360__MatchAccount__c  = true;
        update entitlementSettingsRecord;

        Adm.EntitlementSettings entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( 'Case' );

        try {
            new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id, entitlementSettings );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }

        entitlementSettings.coveredBy = 'Account';

        try {
            new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id, entitlementSettings );
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }

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
        new EVER_InteractiveEntitlementEngine('Case').saveServiceCoverage( caseRecord.id, serviceCoverage );

        Test.stopTest();
    }

    testmethod static void testSaveServiceCoverage_IncidentNotCovered() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        caseRecord.SVMXA360__EntitlementNotes__c = null;
        update caseRecord;

        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        new EVER_InteractiveEntitlementEngine('Case').saveServiceCoverage( caseRecord.id, serviceCoverage );

        caseRecord = [SELECT Id, SVMXA360__EntitlementNotes__c FROM Case LIMIT 1];
        System.assert( caseRecord.SVMXA360__EntitlementNotes__c != null );

        Test.stopTest();
    }

    testmethod static void testSaveServiceCoverage_InvalidParam() {

        Test.startTest();

        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( caseRecord.id );

        System.assert( serviceCoverage != null );
        System.assert( serviceCoverage.contractList != null );
        System.assert( serviceCoverage.contractList.size() > 0 );

        try {
            String recordId = null;
            new EVER_InteractiveEntitlementEngine('Case').saveServiceCoverage( recordId, serviceCoverage );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }

        try {
            new EVER_InteractiveEntitlementEngine('Case').saveServiceCoverage( 'invalid', serviceCoverage );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }

    testmethod static void testGetServiceCoverage_InvalidParam() {

        Test.startTest();

        try {
            Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }

        try {
            Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( 'invalid' );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }

        try {
            Ever.ServiceCoverage serviceCoverage = new EVER_InteractiveEntitlementEngine('Case').getServiceCoverageDetails( null, null );
            System.assert(false);
        }
        catch(Exception e ) {
            System.assert(true);
        }

        Test.stopTest();
    }
}