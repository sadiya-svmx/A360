/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve records with filter.
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni            31 March 2022     Created.
 *****************************************************************************************************/
public with sharing class COMM_SvmxQueryService extends COMM_AbstractSvmxQueryService {

    /**
     * Class constructor to create instance of this class.
     */
    public COMM_SvmxQueryService(){}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public COMM_SvmxQueryService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method is used to retrieve records for configured filter criteria.
     * 
     * @param filterCriteria Config.FilterCriteria wrapper with filter information.
     */
    override public Common.ServiceResponse queryRecords( final Config.FilterCriteria filterCriteria) {

        System.debug( LoggingLevel.DEBUG, 'queryRecords() - enter; filterCriteria= ' + filterCriteria );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria);
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'queryRecords() : Failed to query records. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'queryRecords() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

    /**
     * This method is used to retrieve A360 package version.
     * 
     */
    override public Common.ServiceResponse getPackageVersion() {


        System.debug( LoggingLevel.DEBUG, 'getPackageVersion() - enter');

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            serviceResponse.data = COMM_DatabaseUtils.getInstance().getPackageVersion();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getPackageVersion() : Failed to get package version. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPackageVersion() - exit; success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }
}