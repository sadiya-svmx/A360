/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides various service methods for Warranty Management accessed from LWC.
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       29 June 2020     Created.
 *****************************************************************************************************/

public with sharing class WARR_ManageWarranty_LS {

    @AuraEnabled
    public static SVMXA360__CONF_WarrantyConfig__c getWarrantyConfigurationRecord(){
        SVMXA360__CONF_WarrantyConfig__c warrantyConfigRecord;
        try {
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            warrantyConfigRecord = manageWarrantyService.getWarrantyConfigRules(warrantyConfigRecord);
            System.debug(LoggingLevel.INFO, 'warrantyConfigRecord = ' + warrantyConfigRecord);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in querying config record ' + ex.getMessage());
            throw ex;
        }
        return warrantyConfigRecord;
    }

    @AuraEnabled
    public static Map<String,String> getObjectMappings(){
        Map<String,String> mappingIdToName = new Map<String,String>();
        try {
            List<Adm.ObjectMapping> lstObjectMappings = ADM_ObjectMappingManager.getInstance().getObjectMappingsByName('AssetWarranty', 'WarrantyTerm');
            for(Adm.ObjectMapping objectMapping : lstObjectMappings){
                mappingIdToName.put(objectMapping.id, objectMapping.name);
            }
            System.debug(LoggingLevel.INFO, 'Total Mappings are ' + mappingIdToName.size() + '; and are ' + mappingIdToName);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in querying config record ' + ex.getMessage());
            throw ex;
        }
        return mappingIdToName;
    }
    
    @AuraEnabled
    public static Map<String,String> getCoverageValuesOfWarrantyTerm(){
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>();
        try {
            mapFieldAPIToLabel = (new WARR_ManageWarrantyUtils()).getCoverageFieldPicklistValues();
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in describing WarrantyTerm object ' + ex.getMessage());
            throw ex;
        }
        return mapFieldAPIToLabel;
    }

    @AuraEnabled
    public static Map<String,String> getDateFieldsOfAsset(){
        Map<String,String> mapFieldAPIToLabel = new Map<String,String>();
        try {
            mapFieldAPIToLabel = (new WARR_ManageWarrantyUtils()).getDateFieldsFromAssetObject();
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in describing Asset object ' + ex.getMessage());
            throw ex;
        }
        return mapFieldAPIToLabel;
    }

    @AuraEnabled
    public static SObject updateRecord(SVMXA360__CONF_WarrantyConfig__c recordToUpdate) {
        SVMXA360__CONF_WarrantyConfig__c savedRecord;
        try {
            System.debug(LoggingLevel.INFO, 'recordToUpdate = ' + recordToUpdate);
            savedRecord = (SVMXA360__CONF_WarrantyConfig__c)SvmxDatabase.upsertRecord(recordToUpdate);
            System.debug(LoggingLevel.INFO, ' Saved record = ' + savedRecord);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception in upserting ' + ex.getMessage());
            throw ex;
        }
        return savedRecord;
    }

    @AuraEnabled
    public static List<WarrantyTerm> getMatchingWarrantyTermRecords(String assetId){
        List<WarrantyTerm> lstMatchingWarrantyTerms;
        try {
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            List<Asset> lstAssetRecords = new List<Asset>();
            Asset assetRecord = manageWarrantyService.getAssetRecord(assetId);
            lstAssetRecords.add(assetRecord);
            lstMatchingWarrantyTerms = manageWarrantyService.getMatchingWarrantyTermRecords(lstAssetRecords);    
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception ' + ex.getMessage());
            throw ex;
        }
        return lstMatchingWarrantyTerms;
    }

    @AuraEnabled
    public static List<WarrantyTerm> getUnmatchedWarrantyTermRecords(List<String> lstWarrantyTermIds){
        List<WarrantyTerm> lstNotMatchingWarrantyTerms = new List<WarrantyTerm>();
        try {
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            lstNotMatchingWarrantyTerms = manageWarrantyService.getUnmatchedWarrantyTermRecords(lstWarrantyTermIds);    
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception ' + ex.getMessage());
            throw ex;
        }        
        return lstNotMatchingWarrantyTerms;
    }

    @AuraEnabled
    public static List<WarrantyTerm> searchWarrantyTermRecords(List<WarrantyTerm> lstWarrantyTermRecords, String searchKeyword){
        List<WarrantyTerm> lstWarrantyTerms;
        try {
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            lstWarrantyTerms = manageWarrantyService.searchWarrantyTermRecords(lstWarrantyTermRecords, searchKeyword);
        } catch (Exception ex) {
            System.debug(LoggingLevel.INFO, 'Exception ' + ex.getMessage());
            throw ex;
        }
        return lstWarrantyTerms;
    }

    @AuraEnabled
    public static Asset getAssetRecord(String assetId){
        Asset assetRecord;
        try {
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            assetRecord = manageWarrantyService.getAssetRecord(assetId);
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception in fetching Asset record = ' + ex.getMessage());
            throw ex;
        }
        return assetRecord;
    }

    @AuraEnabled
    public static AssetWarranty createManualWarranty(String warrantyTermRecord, Asset assetRecord){
        AssetWarranty assetWarranty;
        try {
            WarrantyTerm warrantyTerm = (WarrantyTerm)JSON.deserialize(warrantyTermRecord, WarrantyTerm.class);
            system.debug(LoggingLevel.INFO, 'Warranty Term record = ' + warrantyTerm);
            WARR_ManageWarrantyService manageWarrantyService = new WARR_ManageWarrantyService();
            assetWarranty = manageWarrantyService.createManualWarranty(warrantyTerm, assetRecord);    
        } catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'Exception = ' + ex.getMessage());    
            throw new AuraHandledException(ex.getMessage());
        }
        return assetWarranty;
    }

    /**
     * This method retrieves all available supplier warranties
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all supplier warranties.
     */
    @AuraEnabled
    public static Common.ServiceResponse getSupplierWarranties(final String recordId) {
        
        System.debug( LoggingLevel.DEBUG, 'WARR_ManageWarranty_LS -getSupplierWarranties() - enter--'+recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            serviceResponse.data = WARR_SupplierWarrantyManager.getInstance().getSupplierWarranties(recordId);
            System.debug( LoggingLevel.INFO, 'getSupplierWarranties() : Retrieved supplier warranties successfully' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSupplierWarranties() : Failed to get supplier warranties. Error=' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSupplierWarranties() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}