/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This provides a invocable method which can be used in Flows as Apex Action 
 * to calculate price for records of WOLI, PC and Expense based on the pricing/discounts available 
 * in Contract Price Line Item CPLI object.
 * 
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       16 Dec 2020     Created.
 *****************************************************************************************************/
global with sharing class CalculatePriceApexAction {
    
    global class PriceCalRequest {
        
        @InvocableVariable(label='Work Order Record Id' description='Work Order record Id.')
        global String workOrderRecordId;

        @InvocableVariable(label='List of Work Order Line Item Records' description='List of Work Order Line Items related to the Work Order.')
        global List<SObject> lstWOLIRecords;

        @InvocableVariable(label='List of Expense Records' description='List of Expense records related to the Work Order.')
        global List<SObject> lstExpenseRecords;

        @InvocableVariable(label='List of Product Consumed Records' description='List of Product Consumed records related to the Work Order.')
        global List<SObject> lstProductConsumedRecords;

        @InvocableVariable(label='Should the pricing engine update records?' description='If true, then the pricing engine will update all the source records after price calculation')
        global Boolean isUpdateRecords;

        @InvocableVariable(label='Should the Service Contract takes precedence over Asset Warranty?' description='Default value is false. If true, Service Contract pricing will be applied.')
        global Boolean isServiceContractPriority;
    }

    @invocableMethod(label='Work Order pricing' description='Calculates prices for a Work Order based on its entitlement to Service Contract or Warranty.' category='Asset 360 Actions')
    global static List<CalculatePriceApexAction.PriceCalRequest> calculatePrice(List<CalculatePriceApexAction.PriceCalRequest> lstInputParams) {
        system.debug(LoggingLevel.INFO, 'calculatePrice() - enter.');
        List<CalculatePriceApexAction.PriceCalRequest> lstResponse = new List<CalculatePriceApexAction.PriceCalRequest>();
        try {
            PCAL_ManagePricingService pricingService = new PCAL_ManagePricingService();
            if (lstInputParams == null || lstInputParams.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.MISSING_REQUIRED_PARAMETER);
            }
            
            List<SObject> lstRecords = pricingService.getPricesForRecords(lstInputParams);

            if (lstInputParams[0].isUpdateRecords == null || lstInputParams[0].isUpdateRecords) {
                SvmxDatabase.updateRecord(lstRecords);
            }

            Map<String,List<SObject>> mapObjectNameToRecords = pricingService.prepareResponse(lstRecords);
            CalculatePriceApexAction.PriceCalRequest response = new CalculatePriceApexAction.PriceCalRequest();
            response.lstProductConsumedRecords = mapObjectNameToRecords.get(String.valueOf(ProductConsumed.getSObjectType()));
            response.lstWOLIRecords = mapObjectNameToRecords.get(String.valueOf(WorkOrderLineItem.getSObjectType()));
            response.lstExpenseRecords = mapObjectNameToRecords.get(String.valueOf(Expense.getSObjectType()));
            lstResponse.add(response);
            
        } catch (DmlException ex) {
            system.debug(LoggingLevel.INFO, 'calculatePrice(). Exception in updating source records: ' + ex);
            throw ex;
        } 
        catch (Exception ex) {
            system.debug(LoggingLevel.INFO, 'calculatePrice(). Exception in price calculation: ' + ex);
            throw ex;
        }
        system.debug(LoggingLevel.INFO, 'calculatePrice() - exit. lstResponse = ' + lstResponse);
        return lstResponse;
    }
}