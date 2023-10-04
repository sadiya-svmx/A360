/* sfge-disable ApexFlsViolationRule */
public with sharing class DPOT_ManageDepotServiceImpl {

    public DPOT_ManageDepotServiceImpl() {
    }

    public List<DepotFinderResponse> getDepotLocation(List<DepotFinderRequest> lstReturnRequest){
        System.debug(LoggingLevel.INFO, 'getDepotLocation() - enter');
        List<DepotFinderResponse> lstResponse = new List<DepotFinderResponse>();
        try {
            List<String> lstSourceFieldValues = new List<String>();
            Set<String> setProductIds = new Set<String>();
            List<String> lstProductFamily = new List<String>();
            String targetKeyField = '';
            for (DepotFinderRequest returnRequest : lstReturnRequest) {
                if (!String.isBlank(returnRequest.sourceFieldValue) && !String.isBlank(returnRequest.keyField)) {
                    lstSourceFieldValues.add(returnRequest.sourceFieldValue);
                    targetKeyField = returnRequest.keyField;
                } 
                if (!String.isBlank(returnRequest.productId)) {
                    setProductIds.add(returnRequest.productId);
                } 
                if (!String.isBlank(returnRequest.productFamily)) {
                    lstProductFamily.add(returnRequest.productFamily);
                }
            }
            
            List<SVMXA360__LocationServices__c> lstLocations = queryLocationService(setProductIds, lstProductFamily, targetKeyField, lstSourceFieldValues);
            DepotFinderResponse response;
            for (DepotFinderRequest returnRequest : lstReturnRequest) {
                response = new DepotFinderResponse();
                response.recordId = returnRequest.recordId;
                for (SVMXA360__LocationServices__c eachLocationServ : lstLocations) {
                    String matchingLocation;
                    if (!String.isBlank(returnRequest.keyField)) {
                        if(!String.isBlank(returnRequest.sourceFieldValue)) {
                            if(returnRequest.sourceFieldValue == eachLocationServ.get(returnRequest.keyField)) {
                                matchingLocation = eachLocationServ.SVMXA360__Location__c;
                            }
                        } else {
                            matchingLocation = 'No value in parameter sourceFieldValue';
                        }
                    } else if (!String.isBlank(returnRequest.productId) && returnRequest.productId == String.valueOf(eachLocationServ.SVMXA360__Product__c)) {
                        matchingLocation = eachLocationServ.SVMXA360__Location__c;
                    } else if (!String.isBlank(returnRequest.productFamily) && returnRequest.productFamily == eachLocationServ.SVMXA360__ProductFamily__c) {
                        matchingLocation = eachLocationServ.SVMXA360__Location__c;
                    }
                    if (!String.isBlank(matchingLocation) && !response.locationIds.contains(matchingLocation)) {
                        response.locationIds.add(matchingLocation);
                    }
                }
                lstResponse.add(response);
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in finding location. ' + ex.getStackTraceString());
            throw ex;
        }
        
        System.debug(LoggingLevel.INFO, 'getDepotLocation() - exit. Response = ' + lstResponse);
        return lstResponse;
    }

    public List<SObject> updateSourceWithDepotLocation(List<SObject> lstSourceRecords) {
        try {
            SVMXA360__CONF_DepotFinderRule__c depotRule = (new DPOT_ManageDepotUtils()).getDepotSettings();
            if (depotRule.SVMXA360__EnableDepotFinder__c) {
                Map<String,String> mapProductIdToFamily = new Map<String,String>();
                Map<String,String> mapAssetIdToProductId = new Map<String,String>();
                List<SVMXA360__LocationServices__c> lstLocations = getDepotLocations(depotRule, lstSourceRecords, mapProductIdToFamily, mapAssetIdToProductId);
                if (!lstLocations.isEmpty()) {
                    Map<String, List<SObject>> mapDepotToSource = getDepotToSourceMap(lstSourceRecords, lstLocations, depotRule, mapProductIdToFamily, mapAssetIdToProductId);
                    lstSourceRecords = applyMapping(mapDepotToSource, depotRule.SVMXA360__ObjectMapping__c);
                    lstSourceRecords = updateSourceRecords(lstSourceRecords);
                }
            } else {
                System.debug( LoggingLevel.ERROR, 'updateSourceWithDepotLocation() : Depot finder is disabled in settings.');
                throw new SvmxSystem.SvmxNestedException('Depot finder is disabled in settings');
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'updateSourceWithDepotLocation() : . ' + ex.getMessage());
            throw ex;
        }
        return lstSourceRecords;
    }

    public List<SVMXA360__LocationServices__c> getDepotLocations(SVMXA360__CONF_DepotFinderRule__c depotRule, List<SObject> lstSourceRecords, Map<String,String> mapProductIdToFamily, Map<String,String> mapAssetIdToProductId){
        System.debug(LoggingLevel.INFO, 'getDepotLocations() - enter');
        List<SVMXA360__LocationServices__c> lstLocations;
        try {
            DPOT_ManageDepotUtils utils = new DPOT_ManageDepotUtils();
            if(depotRule.SVMXA360__MatchProductAndFamily__c){
                mapAssetIdToProductId.putAll(utils.getAssetIdProductIdMap(lstSourceRecords));
                mapProductIdToFamily.putAll(utils.getProductFamily(mapAssetIdToProductId.values()));
            }
            List<String> lstSourceFieldValues;
            if(depotRule.SVMXA360__SourceFieldAPIName__c != null){
                lstSourceFieldValues = utils.getSourceFieldValues(lstSourceRecords, depotRule.SVMXA360__SourceFieldAPIName__c);
            }
            String locationServiceField;
            if(depotRule.SVMXA360__LocationServiceFieldAPIName__c != null){
                locationServiceField = depotRule.LocationServiceFieldAPIName__c;
            }
            lstLocations = queryLocationService(mapProductIdToFamily.keySet(), mapProductIdToFamily.values(), locationServiceField, lstSourceFieldValues);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in finding location. ' + ex.getMessage());
            throw ex;
        }
        System.debug(LoggingLevel.INFO, 'getDepotLocations() - exit. Locations returned = ' + lstLocations);
        return lstLocations;
    }

    public Map<String,List<SObject>> getDepotToSourceMap(List<SObject> lstSourceRecords, List<SVMXA360__LocationServices__c> lstLocations, SVMXA360__CONF_DepotFinderRule__c depotRule, Map<String,String> mapProductIdToFamily, Map<String,String> mapAssetIdToProductId){
        Map<String,List<SObject>> mapDepotToSource = new Map<String,List<SObject>>();
        try {
            for (SObject eachSourceRecord : lstSourceRecords) {
                String assetId = (String)eachSourceRecord.get('SVMXA360__AssetId__c');
                for (SVMXA360__LocationServices__c eachLocationService : lstLocations) {
                    String matchingLocation;
                    if (!String.isBlank(depotRule.SVMXA360__SourceFieldAPIName__c) && !String.isBlank(depotRule.SVMXA360__LocationServiceFieldAPIName__c)
                        && eachSourceRecord.get(depotRule.SVMXA360__SourceFieldAPIName__c) != null && eachLocationService.get(depotRule.SVMXA360__LocationServiceFieldAPIName__c) != null
                        && eachSourceRecord.get(depotRule.SVMXA360__SourceFieldAPIName__c) == eachLocationService.get(depotRule.SVMXA360__LocationServiceFieldAPIName__c)) {
                            System.debug(LoggingLevel.INFO, 'Enter in key match');
                            matchingLocation = eachLocationService.SVMXA360__Location__c;
                    } else if (mapAssetIdToProductId.get(assetId) != null && eachLocationService.SVMXA360__Product__c != null && mapAssetIdToProductId.get(assetId) ==  eachLocationService.SVMXA360__Product__c) {
                        System.debug(LoggingLevel.INFO, 'Enter in Product match');
                        matchingLocation = eachLocationService.SVMXA360__Location__c;
                    } else if (mapProductIdToFamily.get(mapAssetIdToProductId.get(assetId)) != null && eachLocationService.SVMXA360__ProductFamily__c!= null 
                        && mapProductIdToFamily.get(mapAssetIdToProductId.get(assetId)) == eachLocationService.SVMXA360__ProductFamily__c) {
                            System.debug(LoggingLevel.INFO, 'Enter in Product Family match');
                            matchingLocation = eachLocationService.SVMXA360__Location__c;
                    }
                    System.debug(LoggingLevel.INFO, 'matchingLocation = ' + matchingLocation);
                    if (!String.isBlank(matchingLocation)) {
                        if (!mapDepotToSource.containsKey(matchingLocation)) {
                            mapDepotToSource.put(matchingLocation, new List<SObject>());
                        }
                        mapDepotToSource.get(matchingLocation).add(eachSourceRecord);
                        break;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in preparing collection of Source to Location. ' + ex.getMessage());
            throw ex;
        }
        System.debug(LoggingLevel.INFO, 'mapDepotToSource = ' + mapDepotToSource);
        return mapDepotToSource;
    }

    public List<SObject> applyMapping(Map<String, List<SObject>> mapDepotToSource, String objectMappingId){
        System.debug(LoggingLevel.INFO, 'applyMapping() - enter. objectMappingId = ' + objectMappingId);
        List<SObject> lstSourceRecords = new List<SObject>();
        try {
            if(!String.isBlank(objectMappingId) && !mapDepotToSource.isEmpty()){
                mapDepotToSource = (new CONF_ObjectMappingHandler()).applyObjectMapping(objectMappingId, mapDepotToSource);
                lstSourceRecords = mapDepotToSource.values()[0];
            } else {
                System.debug(LoggingLevel.INFO, 'No mapping available to apply');
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in applyMapping ' + ex.getMessage());
            throw ex;    
        }
        finally{
            System.debug(LoggingLevel.INFO, 'applyMapping() - exit ' + lstSourceRecords);
        }
        return lstSourceRecords;
    }

    private List<SVMXA360__LocationServices__c> queryLocationService(Set<String> setProductIds, List<String> lstFamily, String keyField, List<String> lstSourceFieldValues){
        List<SVMXA360__LocationServices__c> lstLocations;
        try {
            System.debug(LoggingLevel.INFO, 'setProductIds = ' + setProductIds + '; lstFamily = ' + lstFamily + '; keyField = ' + keyField + '; lstSourceFieldValues = ' + lstSourceFieldValues);
            String whereClause = '';
            String orderByClause = '';
            if (!String.isBlank(keyField) && !lstSourceFieldValues.isEmpty()) {
                whereClause += keyField + ' IN: lstSourceFieldValues';
                orderByClause += ' Order By ' + keyField + ' DESC NULLS LAST ';
            } 
            if (!setProductIds.isEmpty()) {
                if (!String.isBlank(whereClause)) {
                    whereClause += ' OR ';
                }
                whereClause += 'SVMXA360__Product__c IN: setProductIds';
                if (!String.isBlank(orderByClause)) {
                    orderByClause += ' , SVMXA360__Product__c NULLS LAST ';
                } else {
                    orderByClause += ' Order By SVMXA360__Product__c NULLS LAST ';
                }
            } 
            if (!lstFamily.isEmpty()) {
                if (!String.isBlank(whereClause)) {
                    whereClause += ' OR ';
                }
                whereClause += 'SVMXA360__ProductFamily__c IN: lstFamily';
            }
            Set<String> setFieldsToQuery = new Set<String>{'Id', 'SVMXA360__Location__c', 'SVMXA360__Product__c', 'SVMXA360__ProductFamily__c', 'SVMXA360__ServiceType__c'};
            if (!String.isBlank(keyField)) {
                setFieldsToQuery.add(keyField);
            }
            String strSOQL = 'Select ' + String.join(new List<String>(setFieldsToQuery), ',') + ' from SVMXA360__LocationServices__c WHERE SVMXA360__Location__c != null ';
            System.debug(LoggingLevel.INFO, 'whereClause = ' + whereClause);
            if (String.isBlank(whereClause)) {
                System.debug(LoggingLevel.INFO, 'No condition matching so cannot proceed further');
                throw new SvmxSystem.SvmxNestedException('No condition matching so cannot proceed further');
            } else {
                strSOQL += ' AND (' + whereClause + ')';
            }
            strSOQL += orderByClause;
            System.debug(LoggingLevel.INFO, 'strSOQL = ' + strSOQL);
            lstLocations = SvmxDatabase.query(Database.query(strSOQL));
            if (lstLocations.isEmpty()) {
                System.debug(LoggingLevel.INFO, 'No matching results found');
                throw new SvmxSystem.SvmxNestedException('No matching results found');
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in finding location. ' + ex.getMessage());
            throw ex;
        }
        return lstLocations;
    }

    public void validateRequest(DepotFinderRequest returnRequest){
        if(returnRequest != null){
            System.debug(LoggingLevel.INFO, 'validateRequest() - enter');
            if (returnRequest.sourceRecord == null) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
        }
    }

    public void updateSourceRecord(SObject sObjectToUpdate, String locationId){
        System.debug(LoggingLevel.INFO, 'updateSourceRecordLocation() - enter');
        try {
            sObjectToUpdate.put('SourceLocationId', locationId);
            sObjectToUpdate = SvmxDatabase.updateRecord(sObjectToUpdate);    
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in updating source record ' + ex.getMessage());
            throw ex;    
        }
        finally{
            System.debug(LoggingLevel.INFO, 'updateSourceRecordLocation() - exit');
        }
    }

    public List<SObject> updateSourceRecords(List<SObject> lstSourceRecords){
        System.debug(LoggingLevel.INFO, 'updateSourceRecords() - enter');
        if (!lstSourceRecords.isEmpty()) {
            try {
                lstSourceRecords = SvmxDatabase.updateRecord(lstSourceRecords);    
            } catch (Exception ex) {
                System.debug(LoggingLevel.INFO, 'Exception in updating source record ' + ex.getMessage());
                throw ex;    
            }
            finally{
                System.debug(LoggingLevel.INFO, 'updateSourceRecords() - exit');
            }
        } else{
            System.debug(LoggingLevel.INFO, 'updateSourceRecords() - No records to update');
        }
        return lstSourceRecords;
    }
}