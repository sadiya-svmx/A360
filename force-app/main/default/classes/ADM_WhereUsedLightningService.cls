/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve where used details of mapping, expression, lookup and transaction
 *
 * @author Jyothsna Nagapudi
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna Nagapudi       April 2022     Created.
 *****************************************************************************************************/
public class ADM_WhereUsedLightningService {
    
    /**
     * This method retrieves all where used details
     * 
     * @return Returns instance of Common.ServiceResponse with list of all where used details.
     */
	@AuraEnabled
    public static Common.ServiceResponse getWhereUsedDetails( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.WhereUsedInputRecord inputRecord = (Adm.WhereUsedInputRecord) JSON.deserializeStrict( requestJson, Adm.WhereUsedInputRecord.class );
            serviceResponse.data = ADM_WhereUsedManager.getInstance().getWhereUsedDetails(inputRecord);
            System.debug( LoggingLevel.INFO, 'getWhereUsedDetails() : Retrieved where used list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedDetails() : Failed to retrieve where used. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}