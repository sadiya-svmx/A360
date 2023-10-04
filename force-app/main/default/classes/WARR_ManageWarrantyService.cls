/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides various service methods which are used in Warranty Management. 
 * Below are the few areas of Warranty Management
 * Interative Warranty creation.
 * Automatic Warranty creation.
 * Warranty Configuration record
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       03 June 2020     Created.
 *****************************************************************************************************/

public with sharing class WARR_ManageWarrantyService {

    public void validateRequest(List<CreateWarrantyApexAction.WARR_WarrantyRequest> lstInputParams){
        if(lstInputParams == null || lstInputParams.isEmpty()){
            throw new SvmxSystem.SvmxNestedException(ErrorMessage.REQUEST_IS_BLANK);
        }
    }

    public SVMXA360__CONF_WarrantyConfig__c getWarrantyConfigRules(SVMXA360__CONF_WarrantyConfig__c warrantyConfig){
        SVMXA360__CONF_WarrantyConfig__c config;
        if(warrantyConfig != null){
            config = warrantyConfig;
        } else {
            List<SVMXA360__CONF_WarrantyConfig__c> lstWarrantyConfigs = SvmxDatabase.query('Select ' + COMM_Constants.WARRANTY_CONFIG_FIELDS + ' from SVMXA360__CONF_WarrantyConfig__c where SVMXA360__RuleScope__c = \'Global\' limit 1');
            if(!lstWarrantyConfigs.isEmpty()){
                config = lstWarrantyConfigs[0];
            }
        }
        return config;
    }

    public List<SObject> createAutoWarranty(List<SObject> lstAssetRecords, SVMXA360__CONF_WarrantyConfig__c warrantyConfigRule, String eventType){
        system.debug(LoggingLevel.INFO,'createAutoWarranty - enter. CPU time = ' + Limits.getCpuTime() + '; SOQLs = ' + Limits.getQueries());
        String termToWarrantyMappingId;
        Boolean isAutoOnCreate = false;
        Boolean isAutoOnUpdate = false;
        Map<String,String> mapFieldMapping = new Map<String,String>{'Install Date'=>'InstallDate','Purchase Date'=>'PurchaseDate', 'Manufacture Date'=>'ManufactureDate'};
        warrantyConfigRule = getWarrantyConfigRules(warrantyConfigRule);
        if (warrantyConfigRule != null) {
            isAutoOnCreate = Boolean.valueOf(warrantyConfigRule.SVMXA360__AutoWarrOnCreateAsset__c);
            isAutoOnUpdate = Boolean.valueOf(warrantyConfigRule.SVMXA360__AutoWarrOnUpdateAsset__c);
            if(warrantyConfigRule.SVMXA360__EffectiveFromConfig__c != null){
                mapFieldMapping = (Map<String, String>)JSON.deserialize(warrantyConfigRule.SVMXA360__EffectiveFromConfig__c, Map<String,String>.class);
            }
            termToWarrantyMappingId = warrantyConfigRule.SVMXA360__ObjectMapping__c;
            system.debug(LoggingLevel.INFO, 'isAutoOnCreate = ' + isAutoOnCreate + '; isAutoOnUpdate = ' + isAutoOnUpdate);
            system.debug(LoggingLevel.INFO, 'termToWarrantyMappingId = ' + termToWarrantyMappingId + '; mapFieldMapping = ' + mapFieldMapping);
        } else {
            system.debug(LoggingLevel.INFO, 'No Config rule defined');
        }
        
        List<AssetWarranty> lstAssetWarrantyRecords = new List<AssetWarranty>();
        try {
            WARR_ManageWarrantyServiceImpl warrantyServiceImpl = new WARR_ManageWarrantyServiceImpl();
            if((COMM_Constants.CREATE_EVENT.equals(eventType) && isAutoOnCreate) || (COMM_Constants.UPDATE_EVENT.equals(eventType) && isAutoOnUpdate)) {
                lstAssetWarrantyRecords = warrantyServiceImpl.createWarranty(lstAssetRecords, mapFieldMapping, termToWarrantyMappingId);
            }    
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO,'Exception during createAutoWarranty ' + ex.getMessage());
        }
        
        system.debug(LoggingLevel.INFO,'createAutoWarranty - exit. CPU time = ' + Limits.getCpuTime() + '; SOQLs = ' + Limits.getQueries());
        return lstAssetWarrantyRecords;
    }

    public Asset getAssetRecord(String assetId){
        Asset assetRecord;
        try {
            WARR_ManageWarrantyUtils warrantyUtils = new WARR_ManageWarrantyUtils();
            assetRecord = warrantyUtils.getAssetRecord(assetId);
            system.debug(LoggingLevel.INFO, 'Asset record = ' + assetRecord);    
        } catch (Exception ex) {
            throw ex;
        }
        return assetRecord;
    }

    public List<WarrantyTerm> getMatchingWarrantyTermRecords(List<Asset> lstAssetRecords){
        List<WarrantyTerm> lstMatchingWarrantyTerms = new List<WarrantyTerm>();
        try {
            WARR_ManageWarrantyUtils warrantyUtils = new WARR_ManageWarrantyUtils();
            Map<Id,Asset> mapIdToAsset = warrantyUtils.getAssetMap(lstAssetRecords);
            Set<Id> setProductIds = warrantyUtils.getProductIdsFromAsset(mapIdToAsset.values());
            Map<String,String> mapProductIdToFamily = warrantyUtils.getProductIdFamilyMap(setProductIds);
            WARR_ManageWarrantyServiceImpl warrantyServiceImpl = new WARR_ManageWarrantyServiceImpl();
            List<ProductWarrantyTerm> lstWarrantyTermProduct = warrantyServiceImpl.getProductWarrantyTermRecords(setProductIds, mapProductIdToFamily.values());
            
            if(!lstWarrantyTermProduct.isEmpty()) {
                Map<Id,Id> mapWarrTermIdToExprId = warrantyServiceImpl.getTermIdToExpression(lstWarrantyTermProduct);
                Map<Id,Set<Id>> mapQualifiedTermToAsset = warrantyServiceImpl.getQualifiedTerms(mapIdToAsset.keySet(), mapWarrTermIdToExprId);
                Map<Id,WarrantyTerm> mapIdToWarrantyTerm = warrantyServiceImpl.getWarrantyTermRecords(mapQualifiedTermToAsset.keySet(), '');
                lstMatchingWarrantyTerms = mapIdToWarrantyTerm.values();
            } else{
                system.debug(LoggingLevel.INFO,'No matching Warranty Term Products');
            }    
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO,'Exception in fetching matching Warranty Terms' + ex.getMessage());
        }
        return lstMatchingWarrantyTerms;
    }

    public List<WarrantyTerm> getUnmatchedWarrantyTermRecords(List<String> lstWarrantyTermIds){
        List<WarrantyTerm> lstNotMatchingWarrantyTerms;
        try {
            system.debug(LoggingLevel.INFO, 'lstWarrantyTermIds = ' + lstWarrantyTermIds);
            String whereClause = ' AND (EffectiveStartDate != null and IsActive = true) Order by WarrantyTermName';
            /* sfge-disable-next-line ApexFlsViolationRule */
            lstNotMatchingWarrantyTerms = SvmxDatabase.query(Database.query('Select ' + COMM_Constants.WARRANTY_TERM_FIELDS + ' from WarrantyTerm where ID NOT IN :lstWarrantyTermIds ' + whereClause));
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO,'Exception in fetching Warranty Terms which don\'t match' + ex.getMessage());
            throw ex;
        }
        return lstNotMatchingWarrantyTerms;
    }

    public List<WarrantyTerm> searchWarrantyTermRecords(List<WarrantyTerm> lstWarrantyTermRecords, String searchKeyword){
        system.debug(LoggingLevel.INFO, 'searchKeyword = ' + searchKeyword + '; lstWarrantyTermRecords size = ' + lstWarrantyTermRecords);
        String whereClause = '';
        if(!String.isBlank(searchKeyword)) {
            searchKeyword = String.escapeSingleQuotes(searchKeyword);
            whereClause = ' and (WarrantyTermName like \'%' + searchKeyword + '%\')';
        }
        /* sfge-disable-next-line ApexFlsViolationRule */
        List<WarrantyTerm> lstWarrantyTerms = SvmxDatabase.query(Database.query('Select ' + COMM_Constants.WARRANTY_TERM_FIELDS + ' from WarrantyTerm where ID IN :lstWarrantyTermRecords ' + whereClause)); 
        return lstWarrantyTerms;
    }

    public AssetWarranty createManualWarranty(WarrantyTerm warrantyTerm, Asset assetRecord){
        AssetWarranty assetWarranty;
        try {
            system.debug(LoggingLevel.INFO, 'Warranty Term record = ' + warrantyTerm + 'assetRecord = ' + assetRecord);
            SVMXA360__CONF_WarrantyConfig__c warrantyConfigRule;
            warrantyConfigRule = getWarrantyConfigRules(warrantyConfigRule);
            WARR_ManageWarrantyServiceImpl warrantyServiceImpl = new WARR_ManageWarrantyServiceImpl();
            assetWarranty = warrantyServiceImpl.createManualWarranty(warrantyTerm, assetRecord, warrantyConfigRule);
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception during warranty creation ' + ex.getMessage());
            throw ex;
        }
        return assetWarranty;
    }
}