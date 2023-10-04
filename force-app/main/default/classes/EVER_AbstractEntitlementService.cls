/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for service contract implementation.
 * Also provides implementation for invokeMethod which maps to the requested service contract service implementation. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       06 Apr 2021     Created.
 *****************************************************************************************************/
public abstract class EVER_AbstractEntitlementService extends COMM_SvmxRestBase {
    
	/**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected EVER_AbstractEntitlementService( RestRequest request, RestResponse response ) {
        super( request, response, 'entitlement' );    
    }
    
    /**
     * Override method invoked by base rest class with requested method.
     * 
     * @param methodName Method name from the request URL.
     * 
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            // Invoke service for requested method name.
            switch on methodName {
                
                when 'getServiceCoverages' {
                    
                    if( recordId == null ) {
                        
                        this.response.statusCode = BAD_REQUEST;
                        return response;
                    }
                    
                    Adm.EntitlementSettings entitlementSettings = null;
                    
                    final String jsonString = request.params.get('filter');
                    if( jsonString != null ) {
                        
                        try {
                            entitlementSettings = (Adm.EntitlementSettings) JSON.deserialize( jsonString, Adm.EntitlementSettings.class );
                        }
                        catch( JSONException e ) {
                            
                            System.debug( LoggingLevel.ERROR, 'deserializeRequestTo() : Failed to deserialize Request. Error' + e.getStackTraceString() );
                            this.response.statusCode = UNPROCESSABLE_ENTITY;
                        }
                    }
                    serviceResponse = getServiceCoverages( recordId, entitlementSettings );
                }
                when 'getEntitlementVerficationHistory' {
                    serviceResponse = getEntitlementVerficationHistory( recordId );
                }
                when 'saveServiceCoverage' {
                    serviceResponse = saveServiceCoverage( recordId, (Ever.ServiceCoverage) deserializeRequestTo( Ever.ServiceCoverage.class ) );
                }
                when else {
                    
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve entity definition for requested api names.
     * 
     * @param objectName Object name for which entitlement rules to be retrieved.
     * @return Returns List of entitlement rules for requested apiNames.
     * 
     * @example GET /services/apexrest/SVMXA360/ever/entitlement/v1/getServiceCoverages/50021000006jA92AAE/?filter={"includeParentAsset":true}
     */
    public abstract Common.ServiceResponse getServiceCoverages( final Id sourceRecordId, final Adm.EntitlementSettings entitlementSettings );
    
    /**
     * This method is used to retrieve the entitlement verification history for given source recordId.
     * 
     * @param sourceRecordId source record id for which entitlement verification history to be retrieved.
     * @return Returns latest entitlement verification history.
     * 
     * @example GET /services/apexrest/SVMXA360/ever/entitlement/v1/getEntitlementVerficationHistory/50021000006jA92AAE/
     */
    public abstract Common.ServiceResponse getEntitlementVerficationHistory( final Id sourceRecordId );
    
    /**
     * This method is used to save service coverage for requested api names.
     * 
     * @param sourceRecordId record id for which service coverage to be saved.
     * 
     * @example POST /services/apexrest/SVMXA360/ever/entitlement/v1/saveServiceCoverage/50021000006jA92AAE/
     */
    public abstract Common.ServiceResponse saveServiceCoverage( final Id sourceRecordId, final Ever.ServiceCoverage serviceCoverage );
}