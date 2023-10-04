/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for quering the data.
 *
 * @author Hemant Keni
 * @version 1.0 - Sum'22
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Hemant Keni             24 Jan 2022     Created.
 *****************************************************************************************************/
public abstract class COMM_AbstractSvmxQueryService extends COMM_SvmxRestBase {
    
    public COMM_AbstractSvmxQueryService(){ }
    
    protected COMM_AbstractSvmxQueryService(RestRequest req, RestResponse res) {
        super(req, res, 'data');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();

        try {

            switch on methodName {

                when 'queryRecords' {
                    response = queryRecords((Config.FilterCriteria) deserializeRequestTo( Config.FilterCriteria.class ));
                }
                when 'getPackageVersion' {
                    response = getPackageVersion();
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   

        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }

    /**
     * This method is used to query records from the Org.
     * 
     * @return Returns list of records specified in the request.
     * 
     * @example GET /services/apexrest/SVMXA360/common/data/v1/queryRecords/
     */
    public abstract Common.ServiceResponse queryRecords( final Config.FilterCriteria request );
     /**
     * This method is used to query A360 package version details.
     * 
     * @return Returns A360 package version details.
     * 
     * @example GET /services/apexrest/SVMXA360/common/data/v1/getPackageVersion/
     */
    public abstract Common.ServiceResponse getPackageVersion();

}