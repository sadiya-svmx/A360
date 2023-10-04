global with sharing class CreateContractLineItemApexAction {
    
    
    /**
     * This method is to create Contract Line Items for the Assets provided in the request
     * 
     * @param List<ContractLineItemData> Request for which we need to Contract Line Items.
     * 
     * @return Returns the same List<ContractLineItemData> which holds the created Contract Line Item IDs after creation.
     */
    @InvocableMethod(label='Create Contract Line Items' description='reate Contract Line Items for the Assets provided' category='Asset 360 Actions')
    global static List<ContractLineItemData> createContractLineItems( final List<ContractLineItemData> contractLineItemDataList) {
        
        System.debug(LoggingLevel.DEBUG, 'createContractLineItems - enter.  ContractLineItemData - '+ contractLineItemDataList);

        try {

            if( contractLineItemDataList == null ||  contractLineItemDataList.isEmpty()) {

                System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Invalid request parameters. ContractLineItemData= ' + contractLineItemDataList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            Common.ServiceResponse createCLIResponse = (new SCON_ServiceContractPlanHandler()).createContractLineItems(contractLineItemDataList[0]);
            
            if(!createCLIResponse.success) {
                System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Cration of Contract Line Item failed. Message = ' + createCLIResponse.message );
                throw new SvmxSystem.SvmxNestedException( createCLIResponse.message );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to Contract Line Item. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - exit; contractLineItemList = ' + contractLineItemDataList );
        }

        return contractLineItemDataList;
    }
}