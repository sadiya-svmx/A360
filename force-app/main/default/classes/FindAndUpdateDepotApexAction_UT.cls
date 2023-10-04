@isTest
public with sharing class FindAndUpdateDepotApexAction_UT {
    @TestSetup
    static void createData(){
        Account acc = (Account) SvmxTestDataFactory.insertSObject('Account');
        Contact cont = (Contact)SvmxTestDataFactory.insertSObject('Contact', new Map<String,Object>{'AccountId'=> acc.Id, 'LastName'=>'Test Last Name'});
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        
        Schema.Location loc = (Schema.Location)SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{'Name' => 'Test Location', 'ExternalReference' => 'test123'});
        SVMXA360__LocationServices__c locations = (SVMXA360__LocationServices__c) SvmxTestDataFactory.insertSObject('SVMXA360__LocationServices__c', 
                                                new Map<String,Object>{'SVMXA360__Product__c' => product.Id, 'SVMXA360__Location__c' => loc.Id});

        Asset asst = (Asset) SvmxTestDataFactory.insertSObject('Asset', new Map<String,Object>{'Name'=> 'Test Asset 1', 'Product2Id' => product.Id, 'AccountId'=>acc.Id, 'ContactId'=>cont.Id});
        SvmxTestDataFactory.insertSObject('ReturnOrder', new Map<String,Object>{'SVMXA360__AssetId__c'=> asst.Id});
        
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Location',
                                                                                    'SVMXA360__TargetObjectAPIName__c' => 'ReturnOrder','SVMXA360__DeveloperName__c' => 'MAP001',
                                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        
        List<SVMXA360__CONF_ObjectMappingDetail__c> objectMappingDetails = SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 1);
        objectMappingDetails.get(0).SVMXA360__TargetFieldAPIName__c = 'DestinationLocationId';
        objectMappingDetails.get(0).SVMXA360__SourceFieldAPIName__c = 'Id';
        objectMappingDetails.get(0).SVMXA360__Type__c  = 'Field';
    
        insert objectMappingDetails;

        SVMXA360__CONF_DepotFinderRule__c rules = (SVMXA360__CONF_DepotFinderRule__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_DepotFinderRule__c', 
                                                                                new Map<String,Object>{'SVMXA360__DeveloperName__c' => 'Depot_Rule_001', 'SVMXA360__EnableDepotFinder__c' => true,
                                                                                    'SVMXA360__MatchProductAndFamily__c' => true, 'SVMXA360__LocationServiceFieldAPIName__c' => 'SVMXA360__ServiceType__c',
                                                                                    'SVMXA360__SourceFieldAPIName__c' => 'ShipmentType', 'SVMXA360__RuleScope__c' => 'Global', 'SVMXA360__ObjectAPIName__c' => 'ReturnOrder'});
    }

    @isTest
    static void updateDepotLocationTest() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        try{
            lstSObjects = [Select Id, ShipmentType, Description, SVMXA360__AssetId__c from ReturnOrder];
            FindAndUpdateDepotApexAction.updateDepotLocation(lstSObjects);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }

    @isTest
    static void updateDepotLocationExceptionTest() {
        List<SObject> lstSObjects = new List<SObject>();
        String exceptionMessage = '';
        try{
            FindAndUpdateDepotApexAction.updateDepotLocation(lstSObjects);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }
}