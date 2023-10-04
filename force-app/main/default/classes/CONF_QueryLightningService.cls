/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve records with filter.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 *****************************************************************************************************/
public with sharing class CONF_QueryLightningService {

    /**
     * This method is used to retrieve records for configured filter criteria.
     * 
     * @param requestJson Config.FilterCriteria wrapper with filter information.
     */
    @AuraEnabled(cacheable=true)
    public static Common.ServiceResponse queryRecords( final String requestJson ) {
        
        System.debug( LoggingLevel.DEBUG, 'queryRecords() - enter; requestJson= ' + requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Config.FilterCriteria filterCriteria = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );
            serviceResponse.data = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria);
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'queryRecords() : Failed to retrieve lookup records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'queryRecords() : Failed to retrieve lookup records. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'queryRecords() - exit; success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}