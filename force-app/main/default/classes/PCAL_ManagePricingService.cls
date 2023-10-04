public with sharing class PCAL_ManagePricingService extends PCAL_AbstractManagePricingService {
    public PCAL_ManagePricingService() {

    }

    public PCAL_ManagePricingService( RestRequest request, RestResponse response ) {
        super(request, response);
    }

    /**
     * calculateLinePrice method provides prices for PC/WOLI/Expense records
     * @param methodName Method name from the request URL.
     * @return Returns Common.ServiceResponse instance with response data.
     */
    /*override public Common.ServiceResponse calculateLinePrice(CalculatePriceApexAction.PriceCalRequest inputRequest) {
        System.debug( LoggingLevel.INFO, 'calculateLinePrice() - enter; inputRequest =  ' + inputRequest);
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new PCAL_ManagePricingServiceImpl().getPricesForRecords(lstRecords);
        }
        catch( Exception e ) {   
            System.debug( LoggingLevel.ERROR, 'calculateLinePrice() : Failed to retrieve location. Error ' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.INFO, 'calculateLinePrice() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        return serviceResponse;
    }*/

    public List<SObject> getPricesForRecords(List<CalculatePriceApexAction.PriceCalRequest> lstInputParams) {
        System.debug( LoggingLevel.INFO, 'getPricesForRecords() - enter.');
        List<SObject> lstRecords = new List<SObject>();
        try {
            String workOrderId;
            Boolean isServiceContractPriority = false;
            for (CalculatePriceApexAction.PriceCalRequest eachParam : lstInputParams) {
                if (eachParam.workOrderRecordId != null) {
                    workOrderId = eachParam.workOrderRecordId;
                }
                if (eachParam.isServiceContractPriority != null) {
                    isServiceContractPriority = Boolean.valueOf(eachParam.isServiceContractPriority);
                }
                if (eachParam.lstWOLIRecords != null && !eachParam.lstWOLIRecords.isEmpty()) {
                    lstRecords.addAll(eachParam.lstWOLIRecords);
                }
                if (eachParam.lstExpenseRecords != null && !eachParam.lstExpenseRecords.isEmpty()) {
                    lstRecords.addAll(eachParam.lstExpenseRecords);
                }
                if (eachParam.lstProductConsumedRecords != null && !eachParam.lstProductConsumedRecords.isEmpty()) {
                    lstRecords.addAll(eachParam.lstProductConsumedRecords);
                }
            }
            if(lstRecords != null && lstRecords.contains(null)) {
                Integer i = 0;
                while (i < lstRecords.size()) {
                    if (lstRecords[i] == null) {
                        lstRecords.remove(i);        
                    } else {
                        i++;
                    }
                }
            }
            if (lstRecords.isEmpty()) {
                System.debug( LoggingLevel.INFO, 'No records in input, lstRecords is ' + lstRecords);
                return lstRecords;
            }
            lstRecords = new PCAL_ManagePricingServiceImpl().getPricesForRecords(lstRecords, workOrderId, isServiceContractPriority);
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'getPricesForRecords() : Error in pricing engine; ' + ex.getStackTraceString() );
            throw ex;
        }
        System.debug( LoggingLevel.INFO, 'getPricesForRecords() - exit.');
        return lstRecords;
    }

    public Map<String,List<SObject>> prepareResponse(List<SObject> lstRecords) {
        System.debug( LoggingLevel.INFO, 'prepareResponse() - enter.');
        Map<String,List<SObject>> mapObjectNameToRecords = new Map<String,List<SObject>>();
        try {
            mapObjectNameToRecords = new PCAL_ManagePricingServiceImpl().prepareResponse(lstRecords);
        } catch (Exception ex) {
            System.debug( LoggingLevel.ERROR, 'prepareResponse() : Error in pricing engine; ' + ex.getStackTraceString() );
            throw ex;
        }
        System.debug( LoggingLevel.INFO, 'prepareResponse() - exit.');
        return mapObjectNameToRecords;
    }
}