/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides services to create Service Contract and its related records.
 * This would be used by CPQ.
 *
 * @author Shashank Panchal
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Shashank Panchal       17 Aug 2021     Created.
 *****************************************************************************************************/
global with sharing class ServiceContractService {

    /**
     * This method creates Service Contract and its directly associated Entitled Services and 
     * Contract Price Line Items
     */
    global static SVMXA360.SvmxGlobal.SvmxResponse createServiceContract(ServiceContractData serviceContractData){        
        return new SCON_ServiceContractService().createServiceContract(serviceContractData);
    }

    /**
     * This method creates Contract Line Items for a given list of assets. This also creates the ES 
     * and CPLIs associated to the Contract Line Items
     */
    global static SVMXA360.SvmxGlobal.SvmxResponse createContractLineItems(ContractLineItemData contractLineItemData){        
        return new SCON_ServiceContractService().createContractLineItems(contractLineItemData);
    }

    /**
     * This method creates Entitled Services for a given Service Contract or Contract Line. 
     */
    global static SVMXA360.SvmxGlobal.SvmxResponse createEntitledServices(EntitledServiceData entitledServiceData){
        return new SCON_ServiceContractService().createEntitledServices(entitledServiceData);
    }

    /**
     * This method cancels the Service Contract.
     */
    global static SVMXA360.SvmxGlobal.SvmxResponse cancelServiceContract(CancelServiceContractData cancelServiceContract){
        return new SCON_ServiceContractService().cancelServiceContract(cancelServiceContract);
    }
}