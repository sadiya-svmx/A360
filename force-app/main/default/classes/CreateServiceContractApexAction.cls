global with sharing class CreateServiceContractApexAction {
    
    global class CreateServiceContractRequest {
        @InvocableVariable(label='Source Record Id' description='The record Id of the Source Record' required=true)
        global String sourceRecordId;

        @InvocableVariable(label='Source Contract Plan Id' description='The record Id of the Service Contract Plan' required=false)
        global String serviceContractPlanId;

        @InvocableVariable(label='Location Id' description='The record Id of the location' required=false)
        global String locationId;

        @InvocableVariable(label='Service Contract Name' description='The name of the Service Contract to be created' required=true)
        global String serviceContractName;

        @InvocableVariable(label='Service Contract Description' description='The description of the Service Contract to be created' required=false)
        global String serviceContractDescription;

        @InvocableVariable(label='Start Date' description='The Start Date of the Service Contract and related records' required=true)
        global Date serviceContractStartDate;

        @InvocableVariable(label='Evaluate For Child Assets' description='The Boolean variable to hold create contract for parent and child assets' required=false)
        global Boolean evaluateForChildAssets;

        @InvocableVariable(label='Bulk Contract Lines' description='The Boolean variable to hold create contract for bulk contract lines' required=false)
        global Boolean createBulkContractLines;

        @InvocableVariable(label='List of Assets and to be associated Service Contract Plan' description='The list which holds asset and to be associated service contract plan Id' required=false)
        global List<AssetServiceContractPlanData> assetServiceContractPlanList;
        
        @InvocableVariable(label='Operation Type' description='Operation Type - one of FOR-SERVICE-CONTRACT-PLAN/FOR-PRODUCT. Default value is FOR-SERVICE-CONTRACT-PLAN')
        global String operationType;
        
        @InvocableVariable(label='Service Contract End Date' description='End Date of the Service Contract' required=false)
        global Date serviceContractEndDate;
        
        @InvocableVariable(label='Pricebook Record Id' description='Pricebook to be used for Service Contract' required=false)
        global String pricebookId;

        @InvocableVariable(label='Service Plan Product Record Id' description='Record Id of the Service Product Plan in Service Contract Plan' required=false)
        global String servicePlanProductId;

        @InvocableVariable(label='Look on Applicable Contract Line Product Id' description='The Boolean variable to look on Applicable Contract Line Product Id' required=false)
        global Boolean isCLIPlanProductId;

        @InvocableVariable(label='Sales Contract Record Id' description='Sales Contract Id to be populated in Service Contract' required=false)
        global String salesContractId;

        @InvocableVariable(label='Sales Contract Field Name' description='Field name of the Sales Contract on Service Contract' required=false)
        global String salesContractIdFieldName;
    
    }
    
    global class CreateServiceContractResponse {
        
        @InvocableVariable(label='Created Service Contract Record' description='Service Contract record which got created' required=true)
        global ServiceContract serviceContractRecord;
    }
    
    /**
     * This method is to create Service Contract for a given Source and Service Contract Plan OR a give Service Plan product
     * 
     * @param CreateServiceContractRequest Request for which we need to create Service Contract.
     * 
     * @return Returns CreateServiceContractResponse which holds the created Service Contract.
     */
    @InvocableMethod(label='Create Service Contract' description='Apex action to create Service Contract for a Plan' category='Asset 360 Actions' configurationEditor='svmxa360-service-contract-action-flow-editor')
    global static List<CreateServiceContractResponse> createServiceContract( final List<CreateServiceContractRequest> serviceContractDataList) {
        
        System.debug(LoggingLevel.DEBUG, 'createServiceContract - enter.  serviceContractDataList - '+ serviceContractDataList);

        List<CreateServiceContractApexAction.CreateServiceContractResponse> serviceContractResponseList;
        
        try{
            
            if( serviceContractDataList == null || serviceContractDataList.isEmpty() ) {

                System.debug( LoggingLevel.ERROR, 'createServiceContract() : Invalid request parameters. serviceContractDataList= ' + serviceContractDataList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            CreateServiceContractApexAction.CreateServiceContractResponse serviceContractResponse = new CreateServiceContractApexAction.CreateServiceContractResponse();
            serviceContractResponseList = new List<CreateServiceContractApexAction.CreateServiceContractResponse>();
            
            if (String.isBlank(serviceContractDataList[0].operationType) || serviceContractDataList[0].operationType.toUpperCase() == 'FOR-SERVICE-CONTRACT-PLAN') {
                
                Scon.ServiceContractPlanRequest sconRequest = new Scon.ServiceContractPlanRequest();
                sconRequest.sourceRecordId = serviceContractDataList[0].sourceRecordId;
                sconRequest.serviceContractPlanId = serviceContractDataList[0].serviceContractPlanId;
                sconRequest.locationId = serviceContractDataList[0].locationId;
                sconRequest.serviceContractName = serviceContractDataList[0].serviceContractName;
                sconRequest.serviceContractDescription = serviceContractDataList[0].serviceContractDescription;
                sconRequest.serviceContractStartDate = serviceContractDataList[0].serviceContractStartDate;
                if ( serviceContractDataList[0].evaluateForChildAssets != null) {
                    sconRequest.evaluateForChildAssets = serviceContractDataList[0].evaluateForChildAssets;
                } else {
                    sconRequest.evaluateForChildAssets = false;
                }
                if(serviceContractDataList[0].createBulkContractLines != null) {
                    sconRequest.createBulkContractLines = serviceContractDataList[0].createBulkContractLines;
                } else {
                    sconRequest.createBulkContractLines = false;
                }
                
                if (serviceContractDataList[0].assetServiceContractPlanList != NULL && !serviceContractDataList[0].assetServiceContractPlanList.isEmpty()) {
                    Map <Id,Id> assetSCONPlanIdMap = new Map <Id,Id>();
                    for ( AssetServiceContractPlanData assetServiceContractPlanReq : serviceContractDataList[0].assetServiceContractPlanList) {
                        assetSCONPlanIdMap.put(assetServiceContractPlanReq.assetId, assetServiceContractPlanReq.serviceContractPlanId);
                    }
                    sconRequest.assetServiceContractPlanIdMap = assetSCONPlanIdMap;
                }
                
                Scon.ServiceContractResponse handlerServiceContractResponse = new SCON_ServiceContractPlanHandler().executeServiceContractPlan( sconRequest);
                serviceContractResponse.serviceContractRecord = handlerServiceContractResponse.serviceContractRecord;
                serviceContractResponseList.add(serviceContractResponse);
                
            } else if (serviceContractDataList[0].operationType.toUpperCase() == 'FOR-PRODUCT') {
                
                ServiceContractData contractDataReq = new ServiceContractData();
                contractDataReq.accountId = serviceContractDataList[0].sourceRecordId;
                contractDataReq.startDate = serviceContractDataList[0].serviceContractStartDate;
                contractDataReq.endDate = serviceContractDataList[0].serviceContractEndDate;
                contractDataReq.pricebookId = serviceContractDataList[0].pricebookId;
                contractDataReq.servicePlanProductId = serviceContractDataList[0].servicePlanProductId;
                contractDataReq.isCLIPlanProductId = serviceContractDataList[0].isCLIPlanProductId!=null ? serviceContractDataList[0].isCLIPlanProductId : false;
                contractDataReq.serviceContractName = serviceContractDataList[0].serviceContractName;
                contractDataReq.description = serviceContractDataList[0].serviceContractDescription;
                contractDataReq.salesContractId = serviceContractDataList[0].salesContractId;
                contractDataReq.salesContractIdFieldName = serviceContractDataList[0].salesContractIdFieldName;

                Common.ServiceResponse serviceResponse = (new SCON_ServiceContractPlanHandler()).createServiceContract(contractDataReq);
                
                if(!serviceResponse.success) {
                    System.debug( LoggingLevel.ERROR, 'createEntitledService() : Cration of Entitled Service failed. Message = ' + serviceResponse.message );
                    throw new SvmxSystem.SvmxNestedException( serviceResponse.message );
                }
                
                serviceContractResponse.serviceContractRecord = new ServiceContract(Id=contractDataReq.serviceContractId); 
                serviceContractResponseList.add(serviceContractResponse);
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Service Contract for the plan/product. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to Create Service Contract for the plan/product. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createServiceContract() - exit; serviceContractResponseList = ' + serviceContractResponseList );
        }

        return serviceContractResponseList;
        
    }
}