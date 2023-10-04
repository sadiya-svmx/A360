public with sharing class DPOT_ManageDepotRule_LS {
    
    @AuraEnabled
    public static Common.ServiceResponse getDepotFinderRule(){
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {
            DPOT_ManageDepotUtils utils = new DPOT_ManageDepotUtils();
            serviceResponse.data = utils.getDepotSettings();
            System.debug(LoggingLevel.INFO, 'depotFinderRule = ' + serviceResponse.data);
        } catch (Exception ex) {
            serviceResponse.success = false;
            System.debug(LoggingLevel.INFO, 'Exception in querying config record ' + ex.getMessage());
            throw ex;
        }
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getLocationServicesFields(){
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {
            DPOT_ManageDepotUtils utils = new DPOT_ManageDepotUtils();
            serviceResponse.data = utils.getLocationServicesFields();
            System.debug(LoggingLevel.INFO, 'serviceResponse = ' + serviceResponse);
        } catch (Exception ex) {
            serviceResponse.success = false;
            System.debug(LoggingLevel.INFO, 'Exception in getting Fields from Location Services record ' + ex.getMessage());
            throw ex;
        }
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getSourceObjectFields(){
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {
            DPOT_ManageDepotUtils utils = new DPOT_ManageDepotUtils();
            serviceResponse.data = utils.getSourceObjectFields();
            System.debug(LoggingLevel.INFO, 'serviceResponse = ' + serviceResponse);
        } catch (Exception ex) {
            serviceResponse.success = false;
            System.debug(LoggingLevel.INFO, 'Exception in getting Fields from Location Services record ' + ex.getMessage());
            throw ex;
        }
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse getObjectMappings(){
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {
            List<Adm.ObjectMapping> lstObjectMappings = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('ReturnOrder', 'Location');
            Map<String,String> mappingIdToName = new Map<String,String>();
            for(Adm.ObjectMapping objectMapping : lstObjectMappings){
                mappingIdToName.put(objectMapping.id, objectMapping.name);
            }
            serviceResponse.data = mappingIdToName;
            System.debug(LoggingLevel.INFO, 'Mappings are ' + serviceResponse.data);
        } catch (Exception ex) {
            serviceResponse.success = false;
            System.debug(LoggingLevel.INFO, 'Exception in getting Fields from Location Services record ' + ex.getMessage());
            throw ex;
        }
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse updateDepotRuleRecord(SVMXA360__CONF_DepotFinderRule__c recordToUpdate){
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {
            System.debug(LoggingLevel.INFO, 'recordToUpdate = ' + recordToUpdate);
            serviceResponse.data = (SVMXA360__CONF_DepotFinderRule__c)SvmxDatabase.upsertRecord(recordToUpdate);
            System.debug(LoggingLevel.INFO, ' Saved record = ' + serviceResponse);
        } catch (Exception ex) {
            serviceResponse.success = false;
            System.debug(LoggingLevel.INFO, 'Exception in upserting ' + ex.getMessage());
            throw ex;
        }
        return serviceResponse;
    }
}