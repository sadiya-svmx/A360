global with sharing class DepotFinderRequest {
    
    @AuraEnabled
    @InvocableVariable global String recordId;

    @AuraEnabled
    @InvocableVariable global String productId;

    @AuraEnabled
    @InvocableVariable global String productFamily;

    @AuraEnabled
    @InvocableVariable global String keyField;

    @AuraEnabled
    global String sourceField;

    @AuraEnabled
    @InvocableVariable global String sourceFieldValue;

    global SObject sourceRecord;

    global List<SObject> lstSourceRecords;

    global DepotFinderRequest() {

    }
}