global with sharing class CancelServiceContractApexAction {
    /**
     * This method is to Cancel Service Contract 
     * 
     * @param List<CancelServiceContractData> Request for which we need to Cancel Service Contract.
     * 
     * @return Returns the same CancelServiceContractData which holds the request data.
     */

    @InvocableMethod(label='Cancel Contract Line Items' description='Service Contract details for Cancelling' category='Asset 360 Actions')
    global static List<CancelServiceContractData> cancelServiceContract( final List<CancelServiceContractData> cancelServiceContractDataList) {
        System.debug(LoggingLevel.DEBUG, 'cancelServiceContract - enter.  cancelServiceContractData - '+ cancelServiceContractDataList);

        try {

            if( cancelServiceContractDataList == null || cancelServiceContractDataList.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Invalid request parameters. cancelServiceContractData= ' + cancelServiceContractDataList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            Common.ServiceResponse cancelServiceContractResponse = (new SCON_ServiceContractPlanHandler()).cancelServiceContract(cancelServiceContractDataList[0]);
            
            if(!cancelServiceContractResponse.success) {
                System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Cancelling failed. Message = ' + cancelServiceContractResponse.message );
                throw new SvmxSystem.SvmxNestedException( cancelServiceContractResponse.message );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Failed Cancelling Service Contract. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Failed Cancelling Service Contract. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'cancelServiceContract() - exit; cancelServiceContractDataList = ' + cancelServiceContractDataList );
        }

        return cancelServiceContractDataList;
    }
}