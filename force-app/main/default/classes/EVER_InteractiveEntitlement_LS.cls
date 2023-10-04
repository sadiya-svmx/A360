/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve all qualified Service Contracts and
 * apply selected Service Contract.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       31 Jul 2020     Created.
 *****************************************************************************************************/
public with sharing class EVER_InteractiveEntitlement_LS {

    /**
     * This method is used to retrieve get service coverage for requested
     * source record and default entitlement setting.
     *
     * @returns Returns list of all qualified service coverages.
     */
    @AuraEnabled
    public static Common.ServiceResponse getServiceCoverages( final String sourceRecordId ) {

        System.debug( LoggingLevel.DEBUG, 'getServiceCoverages() - enter' );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            if( String.isBlank(sourceRecordId) ) {

                System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Invalid input parameter. sourceRecordId= ' + sourceRecordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            String sourceObjectName = ( (Id) sourceRecordId ).getSObjectType().getDescribe().getName();
            serviceResponse.data = new EVER_InteractiveEntitlementEngine(sourceObjectName).getServiceCoverageDetails(sourceRecordId);

            System.debug( LoggingLevel.INFO, 'getServiceCoverages() : Retrieved Service Coverages.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Failed to retrieve Service Coverages. Error' + e.getMessage() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Failed to retrieve Service Coverages. Error' + e.getMessage() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoverages() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method is used to retrieve get service coverage for requested
     * source record and entitlement settings.
     *
     * @returns Returns list of all qualified service coverages.
     */
    @AuraEnabled
    public static Common.ServiceResponse getServiceCoveragesForSettings( final String sourceRecordId, final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'getServiceCoveragesForSettings() - enter; sourceRecordId= ' + sourceRecordId + '; requestJson= ' + requestJson );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            if( String.isBlank(sourceRecordId) ) {

                System.debug( LoggingLevel.ERROR, 'getServiceCoveragesForSettings() : Invalid input parameter. sourceRecordId= ' + sourceRecordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            String sourceObjectName = ( (Id) sourceRecordId ).getSObjectType().getDescribe().getName();
            Adm.EntitlementSettings entitlementSettings = (Adm.EntitlementSettings) JSON.deserializeStrict( requestJson, Adm.EntitlementSettings.class );

            serviceResponse.data = new EVER_InteractiveEntitlementEngine(sourceObjectName).getServiceCoverageDetails(sourceRecordId, entitlementSettings);

            System.debug( LoggingLevel.INFO, 'getServiceCoveragesForSettings() : Retrieved Service Coverages.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoveragesForSettings() : Failed to retrieve Service Coverages. Error' + e.getMessage() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( JSONException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoveragesForSettings() : Failed to retrieve Service Coverages. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Failed to retrieve Service Coverages. Error' + e.getMessage() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoveragesForSettings() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method is used to save selected service coverage to source object.
     */
    @AuraEnabled
    public static Common.ServiceResponse saveServiceCoverage( final String sourceRecordId, final String requestJson ) {

        System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - enter; sourceRecordId= ' + sourceRecordId + '; requestJson= ' + requestJson );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {

            if( String.isBlank(sourceRecordId) ) {

                System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Invalid input parameter. sourceRecordId= ' + sourceRecordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            String sourceObjectName = ( (Id) sourceRecordId ).getSObjectType().getDescribe().getName();
            Ever.ServiceCoverage serviceCoverage = (Ever.ServiceCoverage) JSON.deserializeStrict( requestJson, Ever.ServiceCoverage.class );

            new EVER_InteractiveEntitlementEngine(sourceObjectName).saveServiceCoverage(sourceRecordId, serviceCoverage);

            System.debug( LoggingLevel.INFO, 'saveServiceCoverage() : Saved Service Coverages.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to save Service Coverages. Error' + e.getMessage() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( JSONException e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to dave Service Coverages. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverages() : Failed to retrieve Service Coverages. Error' + e.getMessage() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }
}