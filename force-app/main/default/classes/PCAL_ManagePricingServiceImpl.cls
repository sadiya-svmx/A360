public with sharing class PCAL_ManagePricingServiceImpl {

    public PCAL_ManagePricingServiceImpl() {
    }

    public List<SObject> getPricesForRecords(List<SObject> lstSObjectRecords, String workOrderId, Boolean isServiceContractPriority) {
        System.debug( LoggingLevel.INFO, 'PCAL_ManagePricingServiceImpl getPricesForRecords() - enter; lstSObjectRecords = ' + lstSObjectRecords);
        List<SObject> lstRecords;
        try {
            PCAL_ManagePricingUtils utils = PCAL_ManagePricingUtils.getInstance();
            Set<String> setPricebookEntryIds = new Set<String>();
            setPricebookEntryIds.addAll(utils.getPricebookEntryIds(lstSObjectRecords));
            Set<String> setProductIds = utils.getProductIds(setPricebookEntryIds);
            WorkOrder workOrderRecord = utils.getWorkOrderRecord(lstSObjectRecords, workOrderId);
            List<PricebookEntry> lstPricebookEntryRecords = getListPrice(setProductIds, workOrderRecord);
            Map<Id,PricebookEntry> mapIdToPricebookEntry = new Map<Id,PricebookEntry>(lstPricebookEntryRecords);
            if (utils.getWOContract(workOrderRecord) == null && utils.getWOWarranty(workOrderRecord) == null) {
                System.debug( LoggingLevel.ERROR, 'No Warranty or Service Contract associated with Work Order.');
                List<SObject> lstProcessedRecords = new List<SObject>();
                prepareFinalSObjectList(lstProcessedRecords, lstSObjectRecords, mapIdToPricebookEntry);
                return lstSObjectRecords;
            }
            if (!isServiceContractPriority && String.isNotBlank(utils.getWOWarranty(workOrderRecord))) {
                AssetWarranty assetWarranty = utils.getAssetWarrantyRecord(utils.getWOWarranty(workOrderRecord));
                lstRecords = calculatePriceWithWarranty(lstSObjectRecords, lstPricebookEntryRecords, assetWarranty);
            } else {
                Map<Id,String> mapProductIdToFamily = utils.getProductFamily(setProductIds);
                lstRecords = findMatchingPrice(lstSObjectRecords, mapProductIdToFamily, workOrderRecord, mapIdToPricebookEntry);
            }
        } catch (Exception ex) {
            System.debug( LoggingLevel.INFO, 'PCAL_ManagePricingServiceImpl getPricesForRecords(). Error in pricing engine. ' + ex.getStackTraceString());
            throw ex;
        }
        System.debug( LoggingLevel.INFO, 'PCAL_ManagePricingServiceImpl getPricesForRecords() - exit; lstRecords = ' + lstRecords);
        return lstRecords;
    }

    private List<PricebookEntry> getListPrice(Set<String> setProductIds, WorkOrder workOrderRecord) {
        System.debug( LoggingLevel.INFO, 'getListPrice() - enter; setProductIds = ' + setProductIds);
        PCAL_ManagePricingUtils utils = PCAL_ManagePricingUtils.getInstance();
        String priceBookId = utils.getPriceBook(workOrderRecord);
        List<PricebookEntry> lstPricebookEntryRecords = new List<PricebookEntry>();
        if (String.isNotBlank(priceBookId) && setProductIds != null && !setProductIds.isEmpty()) {
            String soqlPricebookEntry = 'Select Id, Product2Id, UnitPrice from PricebookEntry where Pricebook2Id = :priceBookId and Product2Id IN :setProductIds and IsActive = true';
            if (UserInfo.isMultiCurrencyOrganization()) {
                String workOrderCurrency = utils.getWOCurrency(workOrderRecord);
                soqlPricebookEntry += ' and CurrencyIsoCode = :workOrderCurrency ';                
            }
            System.debug( LoggingLevel.INFO, 'soqlPricebookEntry = ' + soqlPricebookEntry);
            lstPricebookEntryRecords = (List<PricebookEntry>)SvmxDatabase.query(Database.query(soqlPricebookEntry));            
        }
        System.debug( LoggingLevel.INFO, 'getListPrice() - exit.');
        return lstPricebookEntryRecords;
    }
    
    private List<SObject> findMatchingPrice(List<SObject> lstSObjectRecords, Map<Id,String> mapProductIdToFamily, WorkOrder workOrderRecord, 
                                            Map<Id,PricebookEntry> mapIdToPricebookEntry) {
        System.debug( LoggingLevel.INFO, 'findMatchingPrice() - enter.');
        List<SObject> lstProcessedRecords = new List<SObject>();
        try {
            PCAL_ManagePricingUtils utils = PCAL_ManagePricingUtils.getInstance();
            String sconId = utils.getWOContract(workOrderRecord);
            if (String.isBlank(sconId)) {
                System.debug( LoggingLevel.INFO, 'No Service Contract associated with Work Order.');
                return lstProcessedRecords;
            }

            List<SVMXA360__ContractPriceLineItem__c> lstCPLIRecords = new List<SVMXA360__ContractPriceLineItem__c>();
            Set<String> setLineTypes = new Set<String>{'Parts', 'Labor', 'Travel'};
            lstCPLIRecords = getPricingDataFromCPLI(sconId, mapProductIdToFamily.keySet(), null, setLineTypes, null);
            calculatePrice(lstProcessedRecords, lstSObjectRecords, lstCPLIRecords, mapProductIdToFamily, mapIdToPricebookEntry, workOrderRecord);
            if (lstSObjectRecords.size() != lstProcessedRecords.size()) {
                lstCPLIRecords = getPricingDataFromCPLI(sconId, null, mapProductIdToFamily.values(), setLineTypes, null);
                calculatePrice(lstProcessedRecords, lstSObjectRecords, lstCPLIRecords, mapProductIdToFamily, mapIdToPricebookEntry, workOrderRecord);
                if (lstSObjectRecords.size() != lstProcessedRecords.size()) {
                    lstCPLIRecords = getPricingDataFromCPLI(sconId, null, null, setLineTypes, null);
                    calculatePrice(lstProcessedRecords, lstSObjectRecords, lstCPLIRecords, mapProductIdToFamily, mapIdToPricebookEntry, workOrderRecord);    
                }
            }
            setLineTypes = new Set<String>{'Expense'};
            if (lstSObjectRecords.size() != lstProcessedRecords.size()) {
                Set<String> setExpenseItems = utils.getExpenseItems(lstSObjectRecords);
                if (!setExpenseItems.isEmpty()) {
                    lstCPLIRecords = getPricingDataFromCPLI(sconId, null, null, setLineTypes, setExpenseItems);
                    calculatePrice(lstProcessedRecords, lstSObjectRecords, lstCPLIRecords, mapProductIdToFamily, mapIdToPricebookEntry, workOrderRecord);
                }
                if (lstSObjectRecords.size() != lstProcessedRecords.size()) {
                    lstCPLIRecords = getPricingDataFromCPLI(sconId, null, null, setLineTypes, null);
                    calculatePrice(lstProcessedRecords, lstSObjectRecords, lstCPLIRecords, mapProductIdToFamily, mapIdToPricebookEntry, workOrderRecord);
                }
            }
            prepareFinalSObjectList(lstProcessedRecords, lstSObjectRecords, mapIdToPricebookEntry);
        } catch (Exception ex) {
            System.debug( LoggingLevel.INFO, 'findMatchingPrice() - Exception in findMatchingPrice method.' + ex);
            throw ex;
        }
        System.debug( LoggingLevel.INFO, 'findMatchingPrice() - exit.');
        return lstProcessedRecords;
    }

    private void prepareFinalSObjectList(List<SObject> lstProcessedRecords, List<SObject> lstSObjectRecords, Map<Id,PricebookEntry> mapIdToPricebookEntry) {
        System.debug( LoggingLevel.INFO, 'prepareFinalSObjectList() - enter.');
        
        for (SObject eachRecord : lstSObjectRecords) {
            if (!lstProcessedRecords.contains(eachRecord)) {
                Decimal unitPrice;
                if (eachRecord.getSObjectType() == ProductConsumed.getSObjectType() || eachRecord.getSObjectType() == WorkOrderLineItem.getSObjectType()) {
                    unitPrice = mapIdToPricebookEntry.get((String)eachRecord.get('PricebookEntryId')).UnitPrice;
                } else {
                    unitPrice = (Decimal)eachRecord.get('Amount');
                }
                populateFields(eachRecord, unitPrice, null, null);
                lstProcessedRecords.add(eachrecord);
            }
        }
        System.debug( LoggingLevel.INFO, 'prepareFinalSObjectList() - exit.');
    }

    private List<SVMXA360__ContractPriceLineItem__c> getPricingDataFromCPLI(String sconId, Set<Id> setProductIds, List<String> lstProductFamily, 
                                                                            Set<String> setLineTypes, Set<String> setExpenseItems) {
        
        System.debug( LoggingLevel.INFO, 'getPricingDataFromCPLI() - enter; ' + ' sconId = ' + sconId);
        
        List<SVMXA360__ContractPriceLineItem__c> lstCPLIRecords;
        try {
            String soqlCPLI = 'Select Id, SVMXA360__ServiceContractId__c, SVMXA360__ContractLineId__c, SVMXA360__EntitledServiceId__c, SVMXA360__LineType__c, '
                            + 'SVMXA360__ProductId__c, SVMXA360__ProductFamily__c, SVMXA360__ExpenseItem__c, SVMXA360__EntitledPrice__c, SVMXA360__Surcharge__c, ' 
                            + 'SVMXA360__EntitledDiscount__c';
    
            if (UserInfo.isMultiCurrencyOrganization()) {
                soqlCPLI += ', CurrencyIsoCode';
            }
            soqlCPLI += ' from SVMXA360__ContractPriceLineItem__c WHERE SVMXA360__ServiceContractId__c = :sconId ';
            
            if (setProductIds != null && !setProductIds.isEmpty()) {
                soqlCPLI += ' AND SVMXA360__ProductId__c IN :setProductIds ';
            }
            if (lstProductFamily != null && !lstProductFamily.isEmpty()) {
                soqlCPLI += ' AND SVMXA360__ProductFamily__c IN :lstProductFamily';
            }
            if (!setLineTypes.isEmpty()) {
                soqlCPLI += ' AND SVMXA360__LineType__c IN :setLineTypes';
                if (setLineTypes.contains('Expense')) {
                    if (setExpenseItems != null && !setExpenseItems.isEmpty()) {
                        soqlCPLI += ' AND SVMXA360__ExpenseItem__c IN :setExpenseItems';
                    } else {
                        soqlCPLI += ' AND SVMXA360__ExpenseItem__c = null';
                    }
                }
            }
            if (setProductIds == null && lstProductFamily == null) {
                soqlCPLI += ' AND SVMXA360__ProductId__c = null AND SVMXA360__ProductFamily__c = null';
            }
            soqlCPLI += ' ORDER BY SVMXA360__ContractLineId__c NULLS LAST, SVMXA360__EntitledServiceId__c NULLS LAST';

            System.debug( LoggingLevel.INFO, ' soqlCPLI = ' + soqlCPLI);
            lstCPLIRecords = (List<SVMXA360__ContractPriceLineItem__c>)SvmxDatabase.query(Database.query(soqlCPLI));
        } catch (Exception ex) {
            System.debug( LoggingLevel.INFO, 'getPricingDataFromCPLI() - Exception in querying CPLI object .' + ex);
            throw ex;
        }
        
        System.debug( LoggingLevel.INFO, 'getPricingDataFromCPLI() - exit; lstCPLIRecords = ' + lstCPLIRecords);

        return lstCPLIRecords;

    }

    private SVMXA360__ContractPriceLineItem__c getMatchingCPLIRecordForPCWOLI(List<SVMXA360__ContractPriceLineItem__c> lstCPLIRecords, String productFamily, 
                                                                                String productId, String lineType, WorkOrder workOrderRecord) {
        System.debug( LoggingLevel.INFO, ' getMatchingCPLIRecordForPCWOLI() - enter.');
        SVMXA360__ContractPriceLineItem__c matchedCPLI;
        PCAL_ManagePricingUtils utils = PCAL_ManagePricingUtils.getInstance();
        String contractLineId = utils.getContractLine(workOrderRecord);
        String entitledServiceId = utils.getEntitledService(workOrderRecord);
        String woCurrency = utils.getWOCurrency(workOrderRecord);
        for (SVMXA360__ContractPriceLineItem__c eachCPLIRecord : lstCPLIRecords) {
            if (eachCPLIRecord.SVMXA360__LineType__c == lineType && isCPLIMatchingRecordFound(eachCPLIRecord, productFamily, productId, contractLineId, entitledServiceId, woCurrency)) {
                matchedCPLI = eachCPLIRecord;
                break;
            }
        }
        System.debug( LoggingLevel.INFO, ' getMatchingCPLIRecordForPCWOLI() - exit; matchedCPLI for PC WOLI :' + matchedCPLI);
        return matchedCPLI;
    }

    private Boolean isCPLIMatchingRecordFound(SVMXA360__ContractPriceLineItem__c eachCPLIRecord, String productFamily, String productId, 
                                                String contractLineId, String entitledServiceId, String woCurrency) {
        Boolean isMatchingCPLIRecord = false; 
        if (String.isNotBlank(productId) && productId == eachCPLIRecord.SVMXA360__ProductId__c 
            && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, ' match with product with CL and ES ');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productId) && productId == eachCPLIRecord.SVMXA360__ProductId__c 
            && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, ' match with product with CL and ES=null ');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productId) && productId == eachCPLIRecord.SVMXA360__ProductId__c 
            && eachCPLIRecord.SVMXA360__ContractLineId__c == null && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, ' match with product with CL=null and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productId) && productId == eachCPLIRecord.SVMXA360__ProductId__c 
            && eachCPLIRecord.SVMXA360__ContractLineId__c == null && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, ' match with product with ES and CL both null');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productFamily) && productFamily == eachCPLIRecord.SVMXA360__ProductFamily__c
            && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, ' match with family with CL and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productFamily) && productFamily == eachCPLIRecord.SVMXA360__ProductFamily__c
            && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, ' match with family with CL and ES=null');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productFamily) && productFamily == eachCPLIRecord.SVMXA360__ProductFamily__c
            && eachCPLIRecord.SVMXA360__ContractLineId__c == null && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, ' match with family with CL=null and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(productFamily) && productFamily == eachCPLIRecord.SVMXA360__ProductFamily__c
            && eachCPLIRecord.SVMXA360__ContractLineId__c == null && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, ' match with family with CL and ES both null');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ProductFamily__c) && String.isBlank(eachCPLIRecord.SVMXA360__ProductId__c)
            && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, ' match with any part with CL and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ProductFamily__c) && String.isBlank(eachCPLIRecord.SVMXA360__ProductId__c)
            && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, ' match with any part with CL and ES=null');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ProductFamily__c) && String.isBlank(eachCPLIRecord.SVMXA360__ProductId__c)
            && eachCPLIRecord.SVMXA360__ContractLineId__c == null && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, ' match with any part with CL=null and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ProductFamily__c) && String.isBlank(eachCPLIRecord.SVMXA360__ProductId__c)
            && eachCPLIRecord.SVMXA360__ContractLineId__c == null && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, ' match with any part with both CL and ES=null');
            isMatchingCPLIRecord = true;
        }
        if (UserInfo.isMultiCurrencyOrganization() && isMatchingCPLIRecord && eachCPLIRecord.SVMXA360__EntitledPrice__c != null 
            && eachCPLIRecord.get('CurrencyIsoCode') != woCurrency) {
            isMatchingCPLIRecord = false;
        }
        return isMatchingCPLIRecord;
    }

    private SVMXA360__ContractPriceLineItem__c getMatchingCPLIRecordForExpense(String expenseItem, List<SVMXA360__ContractPriceLineItem__c> lstCPLIRecords, 
                                                                                WorkOrder workOrderRecord) {
        System.debug( LoggingLevel.INFO, 'getMatchingCPLIRecordForExpense() - enter. expenseItem = ' + expenseItem);
        SVMXA360__ContractPriceLineItem__c matchedCPLI;
        PCAL_ManagePricingUtils utils = PCAL_ManagePricingUtils.getInstance();
        String contractLineId = utils.getContractLine(workOrderRecord);
        String entitledServiceId = utils.getEntitledService(workOrderRecord);
        String woCurrency = utils.getWOCurrency(workOrderRecord);
        for (SVMXA360__ContractPriceLineItem__c eachCPLIRecord : lstCPLIRecords) {
            if (eachCPLIRecord.SVMXA360__LineType__c == 'Expense' && isCPLIMatchingRecordFound(expenseItem, eachCPLIRecord, contractLineId, entitledServiceId, woCurrency)) {
                matchedCPLI = eachCPLIRecord;
                break;
            }
        }
        System.debug( LoggingLevel.INFO, 'getMatchingCPLIRecordForExpense() - exit. Matching CPLI record for Expense = ' + matchedCPLI);
        return matchedCPLI;
    }

    private Boolean isCPLIMatchingRecordFound(String expenseItem, SVMXA360__ContractPriceLineItem__c eachCPLIRecord, String contractLineId, 
                                                String entitledServiceId, String woCurrency) {
        Boolean isMatchingCPLIRecord = false;
        if (String.isNotBlank(expenseItem) && expenseItem == eachCPLIRecord.SVMXA360__ExpenseItem__c && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, 'match with expense item with CL and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(expenseItem) && expenseItem == eachCPLIRecord.SVMXA360__ExpenseItem__c && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, 'match with expense item with CL and ES=null');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(expenseItem) && expenseItem == eachCPLIRecord.SVMXA360__ExpenseItem__c && eachCPLIRecord.SVMXA360__ContractLineId__c == null && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, 'match with expense item CL=null and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isNotBlank(expenseItem) && expenseItem == eachCPLIRecord.SVMXA360__ExpenseItem__c && eachCPLIRecord.SVMXA360__ContractLineId__c == null && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, 'match with expense item CL and ES both null');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ExpenseItem__c) && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, 'match with ANY expense item with CL and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ExpenseItem__c) && contractLineId == eachCPLIRecord.SVMXA360__ContractLineId__c && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, 'match with ANY expense item with CL and ES=null');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ExpenseItem__c) && eachCPLIRecord.SVMXA360__ContractLineId__c == null && entitledServiceId == eachCPLIRecord.SVMXA360__EntitledServiceId__c) {
            System.debug( LoggingLevel.INFO, 'match with ANY expense item CL=null and ES');
            isMatchingCPLIRecord = true;
        } else if (String.isBlank(eachCPLIRecord.SVMXA360__ExpenseItem__c) && eachCPLIRecord.SVMXA360__ContractLineId__c == null && eachCPLIRecord.SVMXA360__EntitledServiceId__c == null) {
            System.debug( LoggingLevel.INFO, 'match with ANY expense item CL and ES both null');
            isMatchingCPLIRecord = true;
        }
        if (UserInfo.isMultiCurrencyOrganization() && isMatchingCPLIRecord && eachCPLIRecord.SVMXA360__EntitledPrice__c != null 
            && eachCPLIRecord.get('CurrencyIsoCode') != woCurrency) {
            isMatchingCPLIRecord = false;
        }
        return isMatchingCPLIRecord;
    }

    private void calculatePrice(List<SObject> lstProcessedRecords, List<SObject> lstSObjectRecords, List<SVMXA360__ContractPriceLineItem__c> lstCPLIRecords, 
                            Map<Id,String> mapProductIdToFamily, Map<Id,PricebookEntry> mapIdToPricebookEntry, WorkOrder workOrderRecord) {
        System.debug( LoggingLevel.INFO, 'calculatePrice() - enter.');
        try {
            if (!lstCPLIRecords.isEmpty()) {
                for (SObject eachRecord : lstSObjectRecords) {
                    System.debug( LoggingLevel.INFO, ' eachRecord = ' + eachRecord);
                    if (!lstProcessedRecords.contains(eachRecord)) {
                        switch on String.valueOf(eachRecord.getSObjectType()) {
                            when 'ProductConsumed' {
                                String pricebookEntryId = (String)eachRecord.get('PricebookEntryId');
                                SVMXA360__ContractPriceLineItem__c matchedCPLI = getMatchingCPLIRecordForPCWOLI(lstCPLIRecords, mapProductIdToFamily.get(mapIdToPricebookEntry.get(pricebookEntryId).Product2Id), mapIdToPricebookEntry.get(pricebookEntryId).Product2Id, 'Parts', workOrderRecord);
                                if (matchedCPLI != null) {
                                    Decimal entitledPrice = calculateEntitledPrice(matchedCPLI.SVMXA360__EntitledPrice__c, matchedCPLI.SVMXA360__EntitledDiscount__c, matchedCPLI.SVMXA360__Surcharge__c, mapIdToPricebookEntry.get(pricebookEntryId).UnitPrice);
                                    populateFields(eachRecord, entitledPrice, matchedCPLI.SVMXA360__EntitledDiscount__c, matchedCPLI.SVMXA360__Surcharge__c);
                                    lstProcessedRecords.add(eachRecord);
                                }
                            }
                            when 'WorkOrderLineItem' {
                                String pricebookEntryId = (String)eachRecord.get('PricebookEntryId');
                                String lineType = (String)eachRecord.get('SVMXA360__LineType__c');
                                SVMXA360__ContractPriceLineItem__c matchedCPLI = getMatchingCPLIRecordForPCWOLI(lstCPLIRecords, mapProductIdToFamily.get(mapIdToPricebookEntry.get(pricebookEntryId).Product2Id), mapIdToPricebookEntry.get(pricebookEntryId).Product2Id, lineType, workOrderRecord);
                                if (matchedCPLI != null) {
                                    Decimal entitledPrice = calculateEntitledPrice(matchedCPLI.SVMXA360__EntitledPrice__c, matchedCPLI.SVMXA360__EntitledDiscount__c, matchedCPLI.SVMXA360__Surcharge__c, mapIdToPricebookEntry.get(pricebookEntryId).UnitPrice);
                                    populateFields(eachRecord, entitledPrice, matchedCPLI.SVMXA360__EntitledDiscount__c, matchedCPLI.SVMXA360__Surcharge__c);
                                    lstProcessedRecords.add(eachRecord);
                                }
                            }
                            when 'Expense' {
                                String expenseItem = (String)eachRecord.get('SVMXA360__ExpenseItem__c');
                                Decimal expenseAmount = (Decimal)eachRecord.get('Amount');
                                SVMXA360__ContractPriceLineItem__c matchedCPLI = getMatchingCPLIRecordForExpense(expenseItem, lstCPLIRecords, workOrderRecord);
                                if (matchedCPLI != null) {
                                    Decimal entitledPrice = calculateEntitledPrice(matchedCPLI.SVMXA360__EntitledPrice__c, matchedCPLI.SVMXA360__EntitledDiscount__c, matchedCPLI.SVMXA360__Surcharge__c, expenseAmount);
                                    populateFields(eachRecord, entitledPrice, matchedCPLI.SVMXA360__EntitledDiscount__c, matchedCPLI.SVMXA360__Surcharge__c);
                                    lstProcessedRecords.add(eachRecord);
                                }
                            }
                            when else {
                                System.debug( LoggingLevel.INFO, ' No match ');
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'calculatePrice() - Exception in finding a matching CPLI for a given PC, WOLI or Expense record. ' + ex);
            throw ex;
        }
        System.debug( LoggingLevel.INFO, 'calculatePrice() - exit.');
    }

    private List<SObject> calculatePriceWithWarranty(List<SObject> lstSObjectRecords, List<PricebookEntry> lstPricebookEntryRecords, AssetWarranty assetWarranty) {
        System.debug( LoggingLevel.INFO, 'calculatePriceWithWarranty() - enter.');
        try {
            Map<String,String> mapPBEntryIdToProductId = new Map<String,String>();
            Map<String,Decimal> mapProductIdToUnitPrice = new Map<String,Decimal>();
            for(PricebookEntry eachEntry : lstPricebookEntryRecords) {
                mapPBEntryIdToProductId.put(eachEntry.Id, eachEntry.Product2Id);
                mapProductIdToUnitPrice.put(eachEntry.Product2Id, eachEntry.UnitPrice);
            }
            for (SObject eachRecord : lstSObjectRecords) {
                System.debug( LoggingLevel.INFO, ' eachRecord = ' + eachRecord);
                switch on String.valueOf(eachRecord.getSObjectType()) {
                    when 'ProductConsumed' {
                        String pricebookEntryId = (String)eachRecord.get('PricebookEntryId');
                        Decimal entitledPrice = calculateEntitledPrice(null, assetWarranty.PartsCovered, null, mapProductIdToUnitPrice.get(mapPBEntryIdToProductId.get(pricebookEntryId)));
                        populateFields(eachRecord, entitledPrice, assetWarranty.PartsCovered, null);
                    }
                    when 'WorkOrderLineItem' {
                        String pricebookEntryId = (String)eachRecord.get('PricebookEntryId');
                        String lineType = (String)eachRecord.get('SVMXA360__LineType__c');
                        Decimal laborOrTravelCovered;
                        if (lineType == 'Travel') {
                            laborOrTravelCovered = assetWarranty.SVMXA360__TravelCovered__c;
                        } else {
                            laborOrTravelCovered = assetWarranty.LaborCovered;
                        }
                        Decimal entitledPrice = calculateEntitledPrice(null, laborOrTravelCovered, null, mapProductIdToUnitPrice.get(mapPBEntryIdToProductId.get(pricebookEntryId)));                            
                        populateFields(eachRecord, entitledPrice, laborOrTravelCovered, null);
                    }
                    when 'Expense' {
                        String expenseItem = (String)eachRecord.get('SVMXA360__ExpenseItem__c');
                        Decimal expenseAmount = (Decimal)eachRecord.get('Amount');
                        Decimal entitledPrice = calculateEntitledPrice(null, assetWarranty.ExpensesCovered, null, expenseAmount);
                        populateFields(eachRecord, entitledPrice, assetWarranty.ExpensesCovered, null);
                    }
                    when else {
                        System.debug( LoggingLevel.INFO, ' No match ');
                    }
                }
            }
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'calculatePriceWithWarranty() - Exception in calculating price for a given PC, WOLI or Expense record with Warranty. ' + ex);
            throw ex;
        }
        System.debug( LoggingLevel.INFO, 'calculatePriceWithWarranty() - exit.');
        return lstSObjectRecords;
    }
    
    private Decimal calculateEntitledPrice(Decimal entitledPrice, Decimal discount, Decimal surcharge, Decimal listPrice) {
        System.debug( LoggingLevel.ERROR, 'calculateEntitledPrice() - enter; entitledPrice = ' + entitledPrice + ' discount = ' + discount + '; surcharge =  ' + surcharge + '; listPrice = ' + listPrice);
        try {
            if (discount != null && listPrice != null) {
                entitledPrice = listPrice - ((discount/100) * listPrice);
            } else if (surcharge != null && listPrice != null) {
                entitledPrice = listPrice + ((surcharge/100) * listPrice);
            }
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'calculateEntitledPrice() - Exception in calculation of Price: ' + ex);
            throw new SvmxSystem.SvmxNestedException(System.Label.Message_PricingEngine_CalculationError);
        }
        System.debug( LoggingLevel.INFO, 'calculateEntitledPrice() - exit; entitledPrice = ' + entitledPrice);
        return entitledPrice;
    }

    private void populateFields(SObject eachRecord, Decimal entitledPrice, Decimal discount, Decimal surcharge) {
        eachRecord.put('SVMXA360__EntitledPrice__c', entitledPrice);
        eachRecord.put('SVMXA360__EntitledDiscount__c', discount);
        eachRecord.put('SVMXA360__Surcharge__c', surcharge);
        eachRecord.put('UnitPrice', entitledPrice);
    }

    public Map<String,List<SObject>> prepareResponse(List<SObject> lstRecords) {
        System.debug( LoggingLevel.INFO, 'prepareResponse() - enter; lstRecords = ' + lstRecords);
        Map<String,List<SObject>> mapObjectNameToRecords = new Map<String,List<SObject>>();
        for (SObject eachRecord : lstRecords) {
            String objectName = String.valueOf(eachRecord.getSObjectType());
            if (!mapObjectNameToRecords.containsKey(objectName)) {
                mapObjectNameToRecords.put(objectName, new List<SObject>());
            }
            mapObjectNameToRecords.get(objectName).add(eachRecord);
        }
        System.debug( LoggingLevel.INFO, 'prepareResponse() - mapObjectNameToRecords;  = ' + mapObjectNameToRecords);
        return mapObjectNameToRecords;
    }
}