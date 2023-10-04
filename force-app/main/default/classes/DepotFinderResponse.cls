global with sharing class DepotFinderResponse {
    
    @AuraEnabled
    @InvocableVariable global String recordId;
    
    @AuraEnabled
    @InvocableVariable global List<String> locationIds;

    public DepotFinderResponse() {
        locationIds = new List<String>();
    }
}