@isTest
public with sharing class GetDepotApexAction_UT {
    @TestSetup
    static void createData(){
        Product2 product = (Product2)SvmxTestDataFactory.insertSObject('Product2');
        Schema.Location loc = (Schema.Location)SvmxTestDataFactory.insertSObject('Location', new Map<String,Object>{'Name' => 'Test Location', 'ExternalReference' => 'test123'});
        SVMXA360__LocationServices__c locations = (SVMXA360__LocationServices__c) SvmxTestDataFactory.insertSObject('SVMXA360__LocationServices__c', 
                                                new Map<String,Object>{'SVMXA360__Product__c' => product.Id, 'SVMXA360__Location__c' => loc.Id, 'SVMXA360__ProductFamily__c' => 'Laptops'});
    }

    @isTest
    static void getDepotLocationsWithMatchingProductTest() {
        List<DepotFinderRequest> lstRequest = new List<DepotFinderRequest>();
        DepotFinderRequest request = new DepotFinderRequest();
        request.recordId = '1';
        request.productId = [Select Id from Product2 limit 1][0].Id;
        lstRequest.add(request);
        String exceptionMessage = '';
        List<DepotFinderResponse> lstResponse = new List<DepotFinderResponse>();
        try{
            lstResponse = GetDepotApexAction.getDepotLocations(lstRequest);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
        System.assert(lstResponse.size() == 1);
    }

    @isTest
    static void getDepotLocationsWithMatchingFamilyTest() {
        List<DepotFinderRequest> lstRequest = new List<DepotFinderRequest>();
        DepotFinderRequest request = new DepotFinderRequest();
        request.recordId = '1';
        request.productFamily = 'Laptops';
        lstRequest.add(request);
        String exceptionMessage = '';
        List<DepotFinderResponse> lstResponse = new List<DepotFinderResponse>();
        try{
            lstResponse = GetDepotApexAction.getDepotLocations(lstRequest);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
        System.assert(lstResponse.size() == 1);
    }

    @isTest
    static void getDepotLocationsInvalidTest() {
        List<DepotFinderRequest> lstRequest = new List<DepotFinderRequest>();
        String exceptionMessage = '';
        try{
            GetDepotApexAction.getDepotLocations(lstRequest);
        } catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(exceptionMessage != null);
    }
}