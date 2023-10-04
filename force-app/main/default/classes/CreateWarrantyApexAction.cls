global with sharing class CreateWarrantyApexAction {
    global class WARR_WarrantyRequest{
        @InvocableVariable(label='Asset is created or updated or both' description='Provide the event type as create or update o')
        global String eventType;

        @InvocableVariable(label='Warranty Configuration Rule record' description='Warranty Configuration Rule record.')
        global SVMXA360__CONF_WarrantyConfig__c warrantyConfigRule;

        @InvocableVariable(label='List of Asset Records' description='List of Asset records to consider for warranty generation.')
        global List<SObject> lstAssetRecords;

        @InvocableVariable(label='Asset Record' description='Asset record to consider for warranty generation.')
        global SObject assetRecord;
    }

    @invocableMethod(label='Create Warranty' description='creates Asset Warranties in the background based on the Warranty rules.' category='Asset 360 Actions')
    global static void createWarranty(List<CreateWarrantyApexAction.WARR_WarrantyRequest> lstInputParams){
        try {
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            manageWarrantyService.validateRequest(lstInputParams);
            List<SObject> lstAssets = (new WARR_ManageWarrantyUtils()).extractAssetRecords(lstInputParams);
            manageWarrantyService.createAutoWarranty(lstAssets, lstInputParams[0].warrantyConfigRule, lstInputParams[0].eventType);
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception' + ex);
            throw ex;
        }
    }
}