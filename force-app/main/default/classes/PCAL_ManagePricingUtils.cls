/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A Singleton class which provides utility methods for Price calculation engine 
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       6 Jan 2021     Created.
 *****************************************************************************************************/

public with sharing class PCAL_ManagePricingUtils {

    private static PCAL_ManagePricingUtils instance = null;

    private PCAL_ManagePricingUtils() {
    }

    public static PCAL_ManagePricingUtils getInstance() {
        System.debug( LoggingLevel.FINE, 'PCAL_ManagePricingUtils.getInstance() - enter' );
        
        if (instance == null) {
            instance = new PCAL_ManagePricingUtils();
        }

        System.debug( LoggingLevel.FINE, 'PCAL_ManagePricingUtils.getInstance() - exit' );
        return instance;
    }

    public WorkOrder getWorkOrderRecord(List<SObject> lstSObjects, String workOrderId) {
        System.debug(LoggingLevel.INFO, 'getWorkOrderRecord() - enter.');
        if (String.isBlank(workOrderId)) {
            if (lstSObjects != null) {
                for(SObject eachSObject : lstSObjects) {
                    if(eachSObject.get('WorkOrderId') != null) {
                        workOrderId = (String)eachSObject.get('WorkOrderId');
                        break;
                    }
                }
            }
        }

        WorkOrder workOrderRecord;
        if (String.isBlank(workOrderId)) {
            System.debug( LoggingLevel.ERROR, 'No Work Order record Id provided in input and neither input records are associated to Work Order.');
            throw new SvmxSystem.SvmxNestedException(System.Label.Message_PricingEngine_WorkOrderNotAssociated);
        } else {
            String soqlWO = 'Select Id, ServiceContractId, Pricebook2Id, SVMXA360__ContractLineItemId__c, SVMXA360__EntitledServiceId__c, AssetWarrantyId';
            if (UserInfo.isMultiCurrencyOrganization()) {
                soqlWO += ', CurrencyIsoCode';
            }
            soqlWO += ' from WorkOrder where Id = :workOrderId';
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<WorkOrder> lstWorkOrder = (List<WorkOrder>)SvmxDatabase.query(Database.query(soqlWO));
            if (lstWorkOrder.isEmpty()) {
                System.debug( LoggingLevel.ERROR, 'Work Order record with Id ' + workOrderId + ' not found.');
                throw new SvmxSystem.SvmxNestedException(System.Label.Message_PricingEngine_RecordNotFound + workOrderId);
            } else {
                workOrderRecord = lstWorkOrder[0];
            }
        }
        System.debug(LoggingLevel.INFO, 'getWorkOrderRecord() - exit; Work Order record is : ' + workOrderRecord);
        return workOrderRecord;
    }

    public Set<String> getPricebookEntryIds(List<SObject> lstRecords) {
        System.debug(LoggingLevel.INFO, 'getPricebookEntryIds() - enter.');
        Set<String> setPricebookEntryIds = new Set<String>();
        try {
            if (lstRecords != null) {
                for(SObject eachRecord : lstRecords) {
                    if((eachRecord.getSObjectType() == ProductConsumed.getSObjectType() || eachRecord.getSObjectType() == WorkOrderLineItem.getSObjectType()) 
                        && eachRecord.get('PricebookEntryId') != null) {
                        setPricebookEntryIds.add((String)eachRecord.get('PricebookEntryId'));
                    }
                }
            }    
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'getPricebookEntryIds() - Exception in fetching PricebookEntryId field from source (PC and WOLI) records.' + ex);
            throw ex;
        }
        System.debug(LoggingLevel.INFO, 'getPricebookEntryIds() - exit.');
        return setPricebookEntryIds;
    }

    public Set<String> getProductIds(Set<String> setPricebookEntryIds) {
        System.debug(LoggingLevel.INFO, 'getProductIds() - enter.');
        Set<String> setProductIds = new Set<String>();
        try {
            if (!setPricebookEntryIds.isEmpty()) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                List<PricebookEntry> lstPricebookEntryRecords = (List<PricebookEntry>)SvmxDatabase.query([Select Id, Product2Id from PricebookEntry where Id IN :setPricebookEntryIds and Product2Id != null]);
                for(PricebookEntry eachEntry : lstPricebookEntryRecords) {
                    setProductIds.add((String)eachEntry.get('Product2Id'));
                }
            }
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'getProductIds() - Exception in fetching PricebookEntryId field from source (PC and WOLI) records.' + ex);
            throw ex;
        }
        System.debug(LoggingLevel.INFO, 'getProductIds() - exit.');

        return setProductIds;
    }

    public Set<String> getExpenseItems(List<SObject> lstRecords) {
        System.debug(LoggingLevel.INFO, 'getExpenseItems() - enter.');
        Set<String> setExpenseItems = new Set<String>();
        try {
            if (lstRecords != null) {
                for(SObject eachRecord : lstRecords) {
                    if (eachRecord.getSObjectType() == Expense.getSObjectType() && eachRecord.get('SVMXA360__ExpenseItem__c') != null) {
                        setExpenseItems.add((String)eachRecord.get('SVMXA360__ExpenseItem__c'));
                    }
                }
            }    
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'getExpenseItems() - Exception in fetching Expense Item field from Expense records.' + ex);
            throw ex;
        }
        System.debug(LoggingLevel.INFO, 'getExpenseItems() - exit.');

        return setExpenseItems;
    }

    public Map<Id,String> getProductFamily(Set<String> setProductIds) {
        System.debug(LoggingLevel.INFO, 'getProductFamily() - enter.');
        Map<Id,String> mapProductIdToFamily = new Map<Id,String>();
        try {
            if (!setProductIds.isEmpty()) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                List<Product2> lstProductRecords = SvmxDatabase.query([Select Id, Family from Product2 where Id IN: setProductIds]);
                for(Product2 eachProduct : lstProductRecords) {
                    mapProductIdToFamily.put(eachProduct.Id, eachProduct.Family);
                }    
            }    
        } catch (Exception ex) {
            System.debug( LoggingLevel.INFO, 'getProductFamily() - Exception in fetching Family field from Product object.' + ex);
            throw ex;
        }
        System.debug(LoggingLevel.INFO, 'getProductFamily() - exit.');
        
        return mapProductIdToFamily;
    }

    public String getWOContract(WorkOrder workOrderRecord) {
        return workOrderRecord.ServiceContractId;
    }

    public String getWOWarranty(WorkOrder workOrderRecord) {
        return workOrderRecord.AssetWarrantyId;
    }

    public String getPriceBook(WorkOrder workOrderRecord) {
        return workOrderRecord.Pricebook2Id;
    }

    public String getContractLine(WorkOrder workOrderRecord) {
        return workOrderRecord.SVMXA360__ContractLineItemId__c;
    }

    public String getEntitledService(WorkOrder workOrderRecord) {
        return workOrderRecord.SVMXA360__EntitledServiceId__c;
    }

    public String getWOCurrency(WorkOrder workOrderRecord) {
        String workOrderCurrency;
        if (UserInfo.isMultiCurrencyOrganization()) {
            workOrderCurrency = (String)workOrderRecord.get('CurrencyIsoCode');
        }
        return workOrderCurrency;
    }

    public AssetWarranty getAssetWarrantyRecord(String assetWarrantyId) {
        System.debug(LoggingLevel.INFO, 'getAssetWarrantyRecord() - enter. assetWarrantyId = ' + assetWarrantyId);
        AssetWarranty assetWarranty;
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<AssetWarranty> lstAssetWarranty = SvmxDatabase.query([Select Id, LaborCovered, PartsCovered, ExpensesCovered, SVMXA360__TravelCovered__c from AssetWarranty where Id = :assetWarrantyId]);
            if (lstAssetWarranty == null || lstAssetWarranty.isEmpty()) {
                System.debug( LoggingLevel.ERROR, 'Asset Warranty record with Id ' + assetWarrantyId + ' not found.');
                throw new SvmxSystem.SvmxNestedException(System.Label.Message_PricingEngine_NoAssetWarrantyRecordFound);
            } else {
                assetWarranty = lstAssetWarranty[0];
            }
        } catch (Exception ex) {
            System.debug( LoggingLevel.INFO, 'getAssetWarrantyRecord() - Exception in fetching Asset Warranty record. ' + ex);
            throw ex;
        }
        return assetWarranty;
    }
}