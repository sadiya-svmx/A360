public with sharing class DPOT_ManageDepotService extends DPOT_AbstractManageDepotService{
    
    public DPOT_ManageDepotService() {
    }

    public DPOT_ManageDepotService( RestRequest request, RestResponse response ) {
        super(request, response);    
    }

    /**
     * getDepotLocation method provides a single Locations for a specific input
     * @param methodName Method name from the request URL.
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Common.ServiceResponse getDepotLocation(List<DepotFinderRequest> lstReturnRequest) {
        System.debug( LoggingLevel.INFO, 'getDepotLocation() - enter ' + lstReturnRequest);
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = new DPOT_ManageDepotServiceImpl().getDepotLocation(lstReturnRequest);
        }
        catch( Exception e ) {   
            System.debug( LoggingLevel.ERROR, 'getDepotLocation() : Failed to retrieve location. Error ' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.INFO, 'getDepotLocation() - exit; serviceResponse.success ' + serviceResponse.success);
        }
        return serviceResponse;
    }

    /**
     * updateSourceWithDepotLocation method finds the matching locations and updates that into the Source records
     * @param lstSourceRecords List of source (records to be updated) records
     * @return Returns Common.ServiceResponse instance with response data.
     */
    public Common.ServiceResponse updateSourceWithDepotLocation(List<SObject> lstSourceRecords) {
        System.debug(LoggingLevel.INFO, 'updateSourceWithDepotLocation() - enter. Request = ' + lstSourceRecords);
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try {
            DPOT_ManageDepotServiceImpl manageDepotServiceImpl = new DPOT_ManageDepotServiceImpl();
            serviceResponse.data = manageDepotServiceImpl.updateSourceWithDepotLocation(lstSourceRecords);
        }
        catch(QueryException ex) {   
            System.debug( LoggingLevel.ERROR, 'updateSourceWithDepotLocation() : Failed to query Location Services object. Error ' + ex.getMessage());
            serviceResponse.success = false;
            serviceResponse.message = ex.getMessage();
        }
        catch(DMLException ex) {   
            System.debug( LoggingLevel.ERROR, 'updateSourceWithDepotLocation() : Failed to update Source record. Error ' + ex.getMessage());
            serviceResponse.success = false;
            serviceResponse.message = ex.getMessage();
        }
        catch(Exception ex) {   
            System.debug( LoggingLevel.ERROR, 'updateSourceWithDepotLocation() : Failed to get Depot location. Error ' + ex.getMessage());
            serviceResponse.success = false;
            serviceResponse.message = ex.getMessage();
        }
        finally {
            System.debug( LoggingLevel.INFO, 'updateSourceWithDepotLocation() - exit');
        }
        return serviceResponse;
    }
}