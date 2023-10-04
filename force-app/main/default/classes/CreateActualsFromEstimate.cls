/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A global apex class to copy estimate lines to the current Work Order from the estimate Work Order. 
 * Configured to work on click of a button in the SPM Transaction
 *
 * @author Alistair Mack
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *          Alistair Mack         2nd September 2021    Created.
 *****************************************************************************************************/
global with sharing class CreateActualsFromEstimate implements SVMXA360.ISPMAction {
    
    public static final String STATUS_CANCELED = 'Canceled';
    
    public SVMXA360.SvmxGlobal.SvmxResponse execute( final SVMXA360.SvmxGlobal.SvmxPageData pageData ) {

        SVMXA360.SvmxGlobal.SvmxPageData pageDataResponse = new SVMXA360.SvmxGlobal.SvmxPageData();
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = new SVMXA360.SvmxGlobal.SvmxResponse();
        List<SVMXA360.SvmxGlobal.SvmxPageDetail> newPageDetails = new List<SVMXA360.SvmxGlobal.SvmxPageDetail>();
        
        try{
            WorkOrder headerRecord = (WorkOrder)pageData.headerRecord;
            Common.ServiceResponse cloneEstimateLinesResponse = new CreateActualsFromEstimateImpl().cloneEstimateLines(headerRecord);

            if(!cloneEstimateLinesResponse.success){
                serviceResponse.success = false;
                serviceResponse.message = cloneEstimateLinesResponse.message;
                return serviceResponse;
            }

            List<SObject> sObjectList = (List<SObject>)cloneEstimateLinesResponse.data;
            List<ProductConsumed> newProdConsumedList = new List<ProductConsumed>();
            List<WorkOrderLineItem> newWoliList = new List<WorkOrderLineItem>();
            List<Expense> newExpenseList = new List<Expense>();

            for(SObject sObj : sObjectList){
                if(sObj instanceof ProductConsumed){
                    newProdConsumedList.add((ProductConsumed)sObj);
                } else if(sObj instanceof WorkOrderLineItem){
                    newWoliList.add((WorkOrderLineItem)sObj);
                } else if(sObj instanceof Expense){
                    newExpenseList.add((Expense)sObj);
                }
            }

            for (SVMXA360.SvmxGlobal.SvmxPageDetail pageDetail : pageData.pageDetails) {
                String uniqueKey = pageDetail.uniqueKey;
                switch on uniqueKey {
                    when 'Labor/Travel' {
                        //Cancel any existing labor lines from debrief
                        for(SObject sobj : pageDetail.detailRecords){
                            WorkOrderLineItem laborWoli = (WorkOrderLineItem)sobj;
                            if(laborWoli.CreatedDate != null){
                                laborWoli.Status = STATUS_CANCELED;
                            }
                        }
                        if(!newWoliList.isEmpty()){
                            pageDetail.detailRecords.addAll(newWoliList);
                        }
                    }
                    when 'Product Consumed' {
                        if(!newProdConsumedList.isEmpty()){
                            pageDetail.detailRecords.addAll(newProdConsumedList);
                        }
                    }
                    when 'Expense' {
                        if(!newExpenseList.isEmpty()){
                            pageDetail.detailRecords.addAll(newExpenseList);
                        }
                    }
                    when else {
                    }
                }
                newPageDetails.add(pageDetail);
            }

            pageDataResponse.headerRecord = headerRecord;
            pageDataResponse.pageDetails = newPageDetails;
            serviceResponse.success = true;
            serviceResponse.data = JSON.serialize(pageDataResponse);
            return serviceResponse;
        }catch(exception ex){
            throw ex;
        }
    }
}