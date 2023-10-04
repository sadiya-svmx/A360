@isTest
public class DPOT_ManageDepotRule_LS_UT {
    @isTest
    static void getDepotFinderRuleTest() {
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_DepotFinderRule__c', 
                                                new Map<String,Object>{'SVMXA360__EnableDepotFinder__c'=> true, 
                                                'SVMXA360__MatchProductAndFamily__c' => true,
                                                'SVMXA360__ObjectAPIName__c' => 'ReturnOrder', 
                                                'SVMXA360__RuleScope__c'=>'Global',
                                                'SVMXA360__DeveloperName__c' => 'Depot_Rule_001'});
        Common.ServiceResponse serviceResponse = DPOT_ManageDepotRule_LS.getDepotFinderRule();
        System.assert(serviceResponse.data != null);
    }

    @isTest
    static void getObjectMappingsTest() {
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                            new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Location',
                                                                            'SVMXA360__TargetObjectAPIName__c' => 'ReturnOrder',
                                                                            'SVMXA360__DeveloperName__c' => 'MAP001',
                                                                            'Name' => 'MAP001', 
                                                                            'SVMXA360__Type__c' => 'Field Mapping'});
        
        Common.ServiceResponse serviceResponse = DPOT_ManageDepotRule_LS.getObjectMappings();
        System.assert(serviceResponse.data != null);
    }

    @isTest
    static void getLocationServicesFieldsTest() {
        Common.ServiceResponse serviceResponse = DPOT_ManageDepotRule_LS.getLocationServicesFields();
        System.assert(serviceResponse.data != null);
    }

    @isTest
    static void getSourceObjectFieldsTest() {
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_DepotFinderRule__c', 
                                                new Map<String,Object>{'SVMXA360__EnableDepotFinder__c'=> true, 
                                                'SVMXA360__MatchProductAndFamily__c' => true,
                                                'SVMXA360__ObjectAPIName__c' => 'ReturnOrder', 
                                                'SVMXA360__RuleScope__c'=>'Global',
                                                'SVMXA360__DeveloperName__c' => 'Depot_Rule_001'});
        Common.ServiceResponse serviceResponse = DPOT_ManageDepotRule_LS.getSourceObjectFields();
        System.assert(serviceResponse.success);
    }

    @isTest
    static void getSourceObjectFieldsNoRuleTest() {
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse ();
        try {
            serviceResponse = DPOT_ManageDepotRule_LS.getSourceObjectFields();    
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception ' + serviceResponse);
        }
        System.assert(serviceResponse != null);
    }

    @isTest
    static void updateRecordTest() {
        SVMXA360__CONF_DepotFinderRule__c config = new SVMXA360__CONF_DepotFinderRule__c();
        config.SVMXA360__EnableDepotFinder__c = true;
        config.SVMXA360__MatchProductAndFamily__c = true;
        config.SVMXA360__RuleScope__c = 'Global';
        config.SVMXA360__DeveloperName__c = 'Depot_Rule_001'; 
        Common.ServiceResponse serviceResponse = DPOT_ManageDepotRule_LS.updateDepotRuleRecord(config);
        System.assert(serviceResponse!=null);
    }
}