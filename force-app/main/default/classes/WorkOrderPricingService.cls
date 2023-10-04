/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A global apex class to get the pricing for the Work Order.
 * Configured to work on click of a button in the SPM Transaction
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *            Shashank Panchal       2nd June 2021       Created.
 *****************************************************************************************************/
global class WorkOrderPricingService implements SVMXA360.ISPMAction {
    public SVMXA360.SvmxGlobal.SvmxResponse execute( final SVMXA360.SvmxGlobal.SvmxPageData pageData ) {
        
        SVMXA360.SvmxGlobal.SvmxPageData pageDataResponse = new SVMXA360.SvmxGlobal.SvmxPageData();
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = new SVMXA360.SvmxGlobal.SvmxResponse();
        try{
            WorkOrder headerRecord = (WorkOrder)pageData.headerRecord;
            SVMXA360.CalculatePriceApexAction.PriceCalRequest pCalReq = new SVMXA360.CalculatePriceApexAction.PriceCalRequest();
            pCalReq.workOrderRecordId = headerRecord.Id;  
            pCalReq.isUpdateRecords = false;
            
            for (SVMXA360.SvmxGlobal.SvmxPageDetail pageDetail : pageData.pageDetails) {
                String uniqueKey = pageDetail.uniqueKey;
                if(SvmxDatabase.verifyFLSAccess(pageDetail.detailRecords, AccessType.READABLE)){
                    switch on uniqueKey {
                        when 'Labor/Travel' {
                            pCalReq.lstWOLIRecords = pageDetail.detailRecords;
                        }
                        when 'Product Consumed' {
                            pCalReq.lstProductConsumedRecords = pageDetail.detailRecords;
                        }
                        when 'Expense' {
                            pCalReq.lstExpenseRecords = pageDetail.detailRecords;
                        }
                        when else {
                        }
                    }
                } else {
                    serviceResponse.success = false;
                    serviceResponse.message = System.label.Error_PricingFieldInaccessible;
                    return serviceResponse;
                } 
    
            }
    
            List<SVMXA360.CalculatePriceApexAction.PriceCalRequest> pcalResponseList = SVMXA360.CalculatePriceApexAction.calculatePrice(new List<SVMXA360.CalculatePriceApexAction.PriceCalRequest>{pCalReq});
            for (SVMXA360.SvmxGlobal.SvmxPageDetail pageDetail : pageData.pageDetails) {
                String uniqueKey = pageDetail.uniqueKey;
                List<sObject> sObjectRecords;
    
                switch on uniqueKey {
                    when 'Labor/Travel' {
                        pageDetail.detailRecords = pcalResponseList[0].lstWOLIRecords;
                    }
                    when 'Product Consumed' {
                        pageDetail.detailRecords = pcalResponseList[0].lstProductConsumedRecords; 
                    }
                    when 'Expense' {
                        pageDetail.detailRecords = pcalResponseList[0].lstExpenseRecords;
                    }
                    when else {
                    }
                }
            }
    
            System.debug(LoggingLevel.INFO, 'headerRecord ' + headerRecord.getSObjectType());
            pageDataResponse.headerRecord = headerRecord;
            pageDataResponse.pageDetails = pageData.pageDetails;
            serviceResponse.success = true;
            serviceResponse.data = JSON.serialize(pageDataResponse);
                
            return serviceResponse;
        }catch(exception ex){
            throw ex;
        }
    }
}