/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A global apex class to copy Product Required to Product Consumed for the Work Order.
 * Configured to work on click of a button in the SPM Transaction
 *
 * @author Alistair Mack
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *          Alistair Mack         7th September 2021    Created.
 *****************************************************************************************************/
global with sharing class CreateProductsConsumedFromRequired implements SVMXA360.ISPMAction {
    
    public SVMXA360.SvmxGlobal.SvmxResponse execute( final SVMXA360.SvmxGlobal.SvmxPageData pageData ) {

        SVMXA360.SvmxGlobal.SvmxPageData pageDataResponse = new SVMXA360.SvmxGlobal.SvmxPageData();
        SVMXA360.SvmxGlobal.SvmxResponse serviceResponse = new SVMXA360.SvmxGlobal.SvmxResponse();
        List<SVMXA360.SvmxGlobal.SvmxPageDetail> newPageDetails = new List<SVMXA360.SvmxGlobal.SvmxPageDetail>();
        
        try{
            WorkOrder headerRecord = (WorkOrder)pageData.headerRecord;
            Common.ServiceResponse mapProductRequiredResponse = new CreateProductsConsumedFromRequiredImpl().mapProductRequired(headerRecord);

            if(!mapProductRequiredResponse.success){
                serviceResponse.success = false;
                serviceResponse.message = mapProductRequiredResponse.message;
                return serviceResponse;
            }

            List<ProductConsumed> newProductConsumedList = (List<ProductConsumed>)mapProductRequiredResponse.data;

            for (SVMXA360.SvmxGlobal.SvmxPageDetail pageDetail : pageData.pageDetails) {
                String uniqueKey = pageDetail.uniqueKey;
                switch on uniqueKey {
                    when 'Product Consumed' {
                        if(!newProductConsumedList.isEmpty()){
                            pageDetail.detailRecords.addAll(newProductConsumedList);
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