/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve Admin Pages.
 *
 * @author Daniel Peter (Robots & Pencils)
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Daniel Peter        29 June 2020        Created.
 *****************************************************************************************************/
public with sharing class ADM_AdminPageService {

    /**
     * This method retrieves active admin pages from the Salesforce Org.
     *
     * @return Returns instance of Common.ServiceResponse with list of active admin pages.
     *
     * @see ADM_AdminPageServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     */
    public Common.ServiceResponse getActiveAdminPages() {

        System.debug( LoggingLevel.DEBUG, 'getActiveAdminPages() - enter' );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            // Assign admin page info to response data.
            serviceResponse.data = new ADM_AdminPageServiceImpl().getActiveAdminPages();
            System.debug( LoggingLevel.INFO, 'getActiveAdminPages() : Retrieved admin pages list' );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getActiveAdminPages() : Failed to retrieve admin pages. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getActiveAdminPages() - exit; serviceResponse.success= ' + serviceResponse.success );
        }

        return serviceResponse;
    }

}