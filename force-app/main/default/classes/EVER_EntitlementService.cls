/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a service class which provides methods for service contract.
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
public with sharing class EVER_EntitlementService extends EVER_AbstractEntitlementService {
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public EVER_EntitlementService( RestRequest request, RestResponse response ) {
        super(request, response);
    }
    
    override public Common.ServiceResponse getServiceCoverages( final Id sourceRecordId, final Adm.EntitlementSettings entitlementSettings ) {
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new EVER_EntitlementServiceImpl().getServiceCoverages( sourceRecordId, entitlementSettings );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Failed to retrieve Service Coverages. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoverages() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to fetch entitlement verification history for requested record id.
     * 
     * @param sourceRecordId sourceRecordId of either Case, Work Order or return order
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful fetch of entitlement verification history, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse getEntitlementVerficationHistory( final Id sourceRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - enter; sourceRecordId: ' + sourceRecordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new EVER_EntitlementServiceImpl().getEntitlementVerficationHistory( sourceRecordId );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Failed to retrieve Entitlement Verification History. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse saveServiceCoverage( final Id sourceRecordId, final Ever.ServiceCoverage serviceCoverage ) {
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse = new EVER_EntitlementServiceImpl().saveServiceCoverage( sourceRecordId, serviceCoverage );
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to save Service Coverages. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}