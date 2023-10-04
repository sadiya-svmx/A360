/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/save/delete on CLIs.
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
  *A360AM-1499   Mahima Tarika     27 October 2021     Created.
 *****************************************************************************************************/
public with sharing class CLI_ContractLines_LS {

    @AuraEnabled  
    public static Common.ServiceResponse getContractLines(final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'contractLines_LS -getContractLines() - enter--'+requestJson );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            
            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );            
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );            
            // Retrieve CLIs from manager 
            serviceResponse.data = CLI_ContractLinesHandler.getInstance().getContractLines(inputData);
            System.debug( LoggingLevel.INFO, 'getContractLines() : Retrieved CLIs successfully' );
        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLines() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLines() : Failed to retrieve CLIs. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractLines() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method deletes the CLI
     * 
     * @return Returns instance of Common.ServiceResponse with response of CLI.
     */
	@AuraEnabled
    public static Common.ServiceResponse deleteCLIRecord( final String requestJson) {
        
        System.debug( LoggingLevel.DEBUG, 'contractLines_LS - deleteCLIRecord() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            Config.FilterCriteria  inputData = (Config.FilterCriteria) JSON.deserializeStrict( requestJson, Config.FilterCriteria.class );
            System.debug( LoggingLevel.INFO, 'inputData : '+inputData  );

            List<ContractLineItem> contractLineItems = CLI_ContractLinesHandler.getInstance().deleteCheckOnCLI(new Set<Id>{inputData.id});

            // Remove CLI Item from manager 
            SvmxDatabase.deleteRecord( contractLineItems );
            System.debug( LoggingLevel.INFO, 'deleteCLIRecord() : deleted CLI' );

        }
        catch( JSONException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteCLIRecord() : Failed to deserialize the requestJson parameter. Error' + e.getStackTraceString() );  
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteCLIRecord() : Failed to delete CLI. Error' + e.getStackTraceString() );            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); 
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCLIRecord() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    @AuraEnabled
    public static Common.ServiceResponse saveContractLineItem( final String requestJson ) {
        System.debug( LoggingLevel.DEBUG, 'saveContractLineItem() - enter; requestJson= ' + requestJson );

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            final List<Scon.ContractLineItemRecord> contractLineItems = (List<Scon.ContractLineItemRecord>) JSON.deserialize( requestJson, List<Scon.ContractLineItemRecord>.class );

            serviceResponse.data = CLI_ContractLinesHandler.getInstance().saveContractLineItems(contractLineItems);
            System.debug( LoggingLevel.INFO, 'saveContractLineItem() : Saved Contract Line Item' );
        }
        catch( JSONException e ) {

            System.debug( LoggingLevel.ERROR, 'saveContractLineItem() : Failed to save Contract Line Item. Error' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = ErrorMessage.INVALID_ARGUMENT;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'saveContractLineItem() : Failed to retrieve records. Error' + e.getStackTraceString() );

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractLineItem() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        return serviceResponse;
    }
}