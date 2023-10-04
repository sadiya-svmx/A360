public with sharing class DPOT_ManageDepotUtils {
    public DPOT_ManageDepotUtils() {

    }
    
    public SVMXA360__CONF_DepotFinderRule__c getDepotSettings(){
        SVMXA360__CONF_DepotFinderRule__c rule;
        List<SVMXA360__CONF_DepotFinderRule__c> lstFinderRules = SvmxDatabase.query([Select Id, SVMXA360__EnableDepotFinder__c, SVMXA360__MatchProductAndFamily__c, SVMXA360__LocationServiceFieldAPIName__c, SVMXA360__SourceFieldAPIName__c, SVMXA360__ObjectMapping__c, SVMXA360__ObjectAPIName__c, SVMXA360__RuleScope__c from SVMXA360__CONF_DepotFinderRule__c where SVMXA360__RuleScope__c = 'Global' and SVMXA360__ObjectAPIName__c = 'ReturnOrder' Order By LastModifiedDate DESC limit 1]);
        if (!lstFinderRules.isEmpty()) {
            rule = lstFinderRules[0];
        } else {
            throw new SvmxSystem.SvmxNestedException('No Settings found');
        }
        System.debug(LoggingLevel.INFO, 'getDepotSettings() - Exit. Rule = ' + rule);
        return rule;
    }

    public Map<String,String> getAssetIdProductIdMap(List<SObject> lstSourceRecords){
        System.debug(LoggingLevel.INFO, 'getAssetIdProductIdMap() - Enter');
        Map<String,String> mapAssetIdToProductId = new Map<String,String>();
        Set<String> setAssetIds = getAssetIds(lstSourceRecords);
        if (!setAssetIds.isEmpty()) {
            for (Asset eachAssetRecord : (List<Asset>)SvmxDatabase.query([Select Id, Product2Id from Asset where Product2Id != null AND Id IN :setAssetIds])) {
                mapAssetIdToProductId.put(eachAssetRecord.Id, eachAssetRecord.Product2Id);
            }
        }
        System.debug(LoggingLevel.INFO, 'getAssetIdProductIdMap() - Exit.');
        return mapAssetIdToProductId;
    }

    private Set<String> getAssetIds(List<SObject> lstSourceRecords){
        System.debug(LoggingLevel.INFO, 'getAssetIds() - Enter');
        Set<String> setAssetIds = new Set<String>();
        for (SObject eachSourceRecord : lstSourceRecords) {
            if (eachSourceRecord.get('SVMXA360__AssetId__c') != null) {
                setAssetIds.add((String)eachSourceRecord.get('SVMXA360__AssetId__c'));
            }
        }
        System.debug(LoggingLevel.INFO, 'getAssetIds() - Exit. setAssetIds = ' + setAssetIds);
        return setAssetIds;
    }

    public Map<String,String> getProductFamily(List<String> lstProductIds){
        Map<String,String> mapProductIdToFamily = new Map<String,String>();
        if (!lstProductIds.isEmpty()) {
            List<Product2> lstRecords = SvmxDatabase.query([Select Family from Product2 where Id IN :lstProductIds]);
            for(Product2 eachProduct : lstRecords){
                mapProductIdToFamily.put(eachProduct.Id, eachProduct.Family);
            }
        }
        System.debug(LoggingLevel.INFO, 'mapProductIdToFamily = ' + mapProductIdToFamily);
        return mapProductIdToFamily;
    }

    public List<String> getSourceFieldValues(List<SObject> lstSourceRecords, String sourceField){
        System.debug(LoggingLevel.INFO, 'getSourceFieldValues() - Enter. Source field = ' + sourceField);
        List<String> lstSourceFieldValues = new List<String>();
        for(SObject eachSourceRecord : lstSourceRecords){
            if(eachSourceRecord.get(sourceField) != null){
                lstSourceFieldValues.add(String.valueOf(eachSourceRecord.get(sourceField)));
            }
        }
        System.debug(LoggingLevel.INFO, 'getSourceFieldValues() - Exit. Values = ' + lstSourceFieldValues);
        return lstSourceFieldValues;
    }

    public Map<String,String> getLocationServicesFields(){
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>();
        try {
            List<Schema.DisplayType> fieldDisplayTypes = new List<Schema.DisplayType>{Schema.DisplayType.BOOLEAN, Schema.DisplayType.DATE, Schema.DisplayType.TIME, 
                                                                    Schema.DisplayType.DOUBLE, Schema.DisplayType.INTEGER, Schema.DisplayType.PERCENT, 
                                                                    Schema.DisplayType.LONG, Schema.DisplayType.TEXTAREA, Schema.DisplayType.DATETIME, 
                                                                    Schema.DisplayType.CURRENCY, Schema.DisplayType.MULTIPICKLIST};
            Map<String, Schema.DescribeFieldResult> mapFieldDescribe = COMM_DescribeManager.getInstance().getFieldDescribeResults('SVMXA360__LocationServices__c');
            for (String eachField : mapFieldDescribe.keySet()) {
                Schema.DescribeFieldResult describeResult = mapFieldDescribe.get(eachField);
                System.debug(LoggingLevel.INFO, 'FieldName = ' + eachField + '; Type = '  + describeResult.getType());
                if(describeResult.isCustom() && describeResult.getName() != 'SVMXA360__Location__c' 
                && describeResult.getName() != 'SVMXA360__Product__c' && describeResult.getName() != 'SVMXA360__ProductFamily__c'
                && !fieldDisplayTypes.contains(describeResult.getType())) {
                    mapFieldAPIToLabel.put(describeResult.getName(), describeResult.getLabel());
                }
            }
            System.debug(LoggingLevel.INFO, 'Fields in Location Services object = ' + mapFieldAPIToLabel);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in describing LocationServices object ' + ex.getMessage());
            throw ex;
        }
        return mapFieldAPIToLabel;
    }

    public Map<String,String> getSourceObjectFields(){
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>();
        try {
            SVMXA360__CONF_DepotFinderRule__c rule = getDepotSettings();
            Map<String, Schema.DescribeFieldResult> mapFieldDescribe = COMM_DescribeManager.getInstance().getFieldDescribeResults(rule.SVMXA360__ObjectAPIName__c);
            List<String> lstFieldTypes = new List<String>{Schema.DisplayType.BOOLEAN.name(), Schema.DisplayType.DATE.name(), 
                Schema.DisplayType.DATETIME.name(), Schema.DisplayType.DOUBLE.name(), Schema.DisplayType.INTEGER.name(), 
                Schema.DisplayType.PERCENT.name(), Schema.DisplayType.LONG.name(), Schema.DisplayType.TEXTAREA.name(), 
                Schema.DisplayType.TIME.name(), Schema.DisplayType.CURRENCY.name()};
            for (String eachField : mapFieldDescribe.keySet()) {
                Schema.DescribeFieldResult describeResult = mapFieldDescribe.get(eachField);
                if (!lstFieldTypes.contains(describeResult.getType().name())) {
                    mapFieldAPIToLabel.put(describeResult.getName(), describeResult.getLabel());    
                }
            }
            System.debug(LoggingLevel.INFO, 'Fields in Source object:' + rule.SVMXA360__ObjectAPIName__c + '= ' + mapFieldAPIToLabel);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in describing Source object defined in Depot Rule ' + ex.getMessage());
            throw ex;
        }
        return mapFieldAPIToLabel;
    }
}