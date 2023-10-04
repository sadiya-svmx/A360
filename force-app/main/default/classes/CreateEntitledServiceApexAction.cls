global with sharing class CreateEntitledServiceApexAction {

    /**
     * This method is to create Entitled Service for given Service Contract or Contract Line Item
     *
     * @param List<EntitledServiceData> Request for which we need to create Entitled Service.
     *
     * @return Returns List<EntitledServiceData> which holds the created Entitled Service Id.
     */

     @InvocableMethod(label='Create Entitled Service' description='Apex Action to create Entitled Service for given Service Contract or Contract Line Item' category='Asset 360 Actions')
     global static List<EntitledServiceData> createEntitledService ( final List<EntitledServiceData> entitledServiceRequestList) {

        System.debug(LoggingLevel.DEBUG, 'createEntitledService - enter.  entitledServiceRequestList = '+ entitledServiceRequestList);

        try {

            if( entitledServiceRequestList == null || entitledServiceRequestList.isEmpty()) {

                System.debug( LoggingLevel.ERROR, 'createEntitledService() : Invalid request parameters. entitledServiceRequestList= ' + entitledServiceRequestList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            Common.ServiceResponse serviceResponse = new SCON_ServiceContractPlanHandler().createEntitledServices(entitledServiceRequestList[0]);

            if(!serviceResponse.success) {
                System.debug( LoggingLevel.ERROR, 'createEntitledService() : Cration of Entitled Service failed. Message = ' + serviceResponse.message );
                throw new SvmxSystem.SvmxNestedException( serviceResponse.message );
            }

        }
        catch(SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledService() : Failed to create Entiled Service. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledService() : Failed to Create Entiled Service. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createEntitledService() - exit; entitledServiceRequestList = ' + entitledServiceRequestList );
        }

        return entitledServiceRequestList;
    }
}