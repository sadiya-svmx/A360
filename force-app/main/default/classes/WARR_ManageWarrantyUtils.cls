/* sfge-disable ApexFlsViolationRule */
public with sharing class WARR_ManageWarrantyUtils {

    public List<SObject> extractAssetRecords(List<CreateWarrantyApexAction.WARR_WarrantyRequest> lstInputParams){
        List<SObject> lstAssetRecords = new List<SObject>();
        if(lstInputParams == null || lstInputParams.isEmpty()){
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.REQUEST_IS_BLANK);
        } else {
            for(CreateWarrantyApexAction.WARR_WarrantyRequest eachInput : lstInputParams){
                if(eachInput.assetRecord != null){
                    lstAssetRecords.add(eachInput.assetRecord);
                }
            }
        }
        if(lstAssetRecords.isEmpty() && !lstInputParams[0].lstAssetRecords.isEmpty()){
            lstAssetRecords.addAll(lstInputParams[0].lstAssetRecords);
        }
        return lstAssetRecords;
    }

    public Map<String,String> getCoverageFieldPicklistValues(){
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>();
        try {
            Map<String, Schema.DescribeFieldResult> fieldDescribe = COMM_DescribeManager.getInstance().getFieldDescribeResults('WarrantyTerm');
            if(!fieldDescribe.isEmpty()){
                Schema.DescribeFieldResult describeResult = fieldDescribe.get('EffectiveStartDate');
                for(Schema.PicklistEntry eachValue : describeResult.getPicklistValues()){
                    mapFieldAPIToLabel.put(eachValue.getValue(), eachValue.getLabel());
                }
            }
            System.debug(LoggingLevel.INFO, 'Picklist values map of Coverage Effective field = ' + mapFieldAPIToLabel);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in describing WarrantyTerm = ' + ex.getMessage());
            throw ex;
        }
        return mapFieldAPIToLabel;
    }


    public Map<String,String> getDateFieldsFromAssetObject(){
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>();
        try {
            Map<String, Schema.DescribeFieldResult> mapFieldDescribe = COMM_DescribeManager.getInstance().getFieldDescribeResults('Asset');
            for(String eachField : mapFieldDescribe.keySet()){
                Schema.DescribeFieldResult describeResult = mapFieldDescribe.get(eachField);
                if(Schema.DisplayType.DATE == describeResult.getType()){
                    mapFieldAPIToLabel.put(describeResult.getName(), describeResult.getLabel());
                }
            }
            System.debug(LoggingLevel.INFO, 'Date fields in Asset object = ' + mapFieldAPIToLabel);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in describing Asset object ' + ex.getMessage());
            throw ex;
        }
        return mapFieldAPIToLabel;
    }

    public Map<Id,Asset> getAssetMap(List<SObject> lstAssetRecords){
        Map<Id,Asset> mapIdToAsset = new Map<Id,Asset>();
        for(SObject eachAsset : lstAssetRecords){
            system.debug(LoggingLevel.INFO,'eachAsset = ' + eachAsset);
            if(eachAsset.get('Product2Id') != null){
                mapIdToAsset.put((Id)eachAsset.get('Id'), (Asset)eachAsset);
            }
        }
        system.debug(LoggingLevel.INFO,'mapIdToAsset size = ' + mapIdToAsset.size());
        return mapIdToAsset;
    }

    public Set<Id> getProductIdsFromAsset(List<Asset> lstAssetRecords){
        Set<Id> setProductIds = new Set<Id>();
        for(Asset eachAsset : lstAssetRecords){
            setProductIds.add(eachAsset.Product2Id);
        }
        system.debug(LoggingLevel.INFO,'setProductIds = ' + setProductIds);
        return setProductIds;
    }

    public Map<String, String> getProductIdFamilyMap(Set<Id> setProductIds){
        Map<String, String> mapProductIdToFamily = new Map<String, String>();
        /* sfge-disable-next-line ApexFlsViolationRule */
        for(Product2 eachProduct: [Select Id, Family from Product2 where Family != null and ID IN :setProductIds]){
            mapProductIdToFamily.put(eachProduct.Id, eachProduct.Family);
        }
        return mapProductIdToFamily;
    }

    public Asset getAssetRecord(String assetId){
        Asset assetRecord;
        try {
            Set<String> setFieldsToQuery = new Set<String>{'Id','Name', 'Product2Id', 'InstallDate', 'PurchaseDate', 'UsageEndDate', 'ManufactureDate'};
            Map<String,String> mapFieldAPIToLabel = getDateFieldsFromAssetObject();
            if (!mapFieldAPIToLabel.isEmpty()) {
                setFieldsToQuery.addAll(mapFieldAPIToLabel.keySet());
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<Asset> lstAssetRecords = SvmxDatabase.query(Database.Query('Select ' + String.join(new List<String>(setFieldsToQuery), ',') + ' from Asset where Id =:assetId'));
            if(!lstAssetRecords.isEmpty()){
                assetRecord = lstAssetRecords[0];
            }
            system.debug(LoggingLevel.INFO, 'Asset record = ' + lstAssetRecords);
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception in querying Asset record = ' + ex.getMessage());
            throw ex;
        }
        return assetRecord;
    }
}