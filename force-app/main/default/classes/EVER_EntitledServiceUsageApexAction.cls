/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief An invocable apex action to perform entitled service udage update.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       21 Dec 2020     Created.
 *****************************************************************************************************/
global class EVER_EntitledServiceUsageApexAction {

    global class ServiceUsageRequest {
        
        @InvocableVariable(label='Entitled Service Id' description='Entitlement service record ID.' required=true)
        global String entitledServiceId;
        
        @InvocableVariable(label='Entitled Service Value' description='Entitlement service count/amount to be increased/decreased.' required=true)
        global Double serviceValue;
        
        @InvocableVariable(label='Entitled Service Unit (Count/Amount)' description='Entitlement service type to be consumed.' required=true)
        global String serviceUnit;
        
        @InvocableVariable(label='Entitled Service Operation (Increment/Decrement)' description='Service usage operation, Increase or Decrease.' required=true)
        global String serviceOperation;

        @InvocableVariable(label='Source Record Id' description='Source Record ID (Case/Work Order/Return Order).' required=false)
        global String sourceRecordId;
    }
    
    /**
     * Apex action to updage entitled service usage.
     */
    @InvocableMethod(label='Update Entitled Service Usage' description='Apex action to update entitled service usage.' category='Asset 360 Actions')
    global static void updateEntitledServiceUsage( final List<ServiceUsageRequest> serviceUsageRequestList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateEntitledServiceUsage() - enter' );
        
        try {
            
            if( serviceUsageRequestList == null || serviceUsageRequestList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'updateEntitledServiceUsage() : Invalid request parameters. serviceUsageRequestList= ' + serviceUsageRequestList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            final List<Ever.ServiceUsageInfo> serviceUsageInfoList = new List<Ever.ServiceUsageInfo>();
            
            // Create service usage info list.
            for( ServiceUsageRequest serviceUsageRequest : serviceUsageRequestList ) {
                
                Ever.ServiceUsageInfo serviceUsageInfo = new Ever.ServiceUsageInfo();
                serviceUsageInfo.entitledServiceId = serviceUsageRequest.entitledServiceId;
                serviceUsageInfo.sourceRecordId = serviceUsageRequest.sourceRecordId;
                serviceUsageInfo.serviceValue = serviceUsageRequest.serviceValue;
                
                switch on serviceUsageRequest.serviceUnit {
                    
                    when 'Count' {
                        serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Count;
                    }
                    when 'Amount' {
                        serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Amount;
                    }
                    when else {
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED + ' ' + serviceUsageRequest.serviceUnit );
                    }
                }
                
                switch on serviceUsageRequest.serviceOperation {
                    
                    when 'Increment' {
                        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Increment;
                    }
                    when 'Decrement' {
                        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Decrement;
                    }
                    when else {
                        throw new SvmxSystem.SvmxNestedException( ErrorMessage.TYPE_UNSUPPORTED + ' ' + serviceUsageRequest.serviceOperation );
                    }
                }
                
                serviceUsageInfoList.add(serviceUsageInfo);
            }
            
            // Update service usage.
            new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfoList);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateEntitledServiceUsage() : Failed to perform service update. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateEntitledServiceUsage() : Failed to perform service update. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateEntitledServiceUsage() - exit' );
        }
    }
}