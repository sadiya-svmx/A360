/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides services to create Service Contract and its related records.
 * 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Karthick Saravanan     10 Nov 2021      Created.
 *****************************************************************************************************/
public with sharing class SCON_ServiceContractService extends SCON_AbstractServiceContractService {

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public SCON_ServiceContractService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public SCON_ServiceContractService( RestRequest request, RestResponse response ){
        super(request, response);
    }

    /**
     * This method creates Service Contract and its directly associated Entitled Services and 
     * Contract Price Line Items
     * 
     * @param ServiceContractData Service Contract wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful of create service contract, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse createServiceContract(ServiceContractData serviceContractData){  
        
        System.debug( LoggingLevel.DEBUG, 'createServiceContract() - enter' );
        
        return new SCON_ServiceContractPlanHandler().createServiceContract(serviceContractData);
    }

    /**
     * This method creates Contract Line Items for a given list of assets. This also creates the ES 
     * and CPLIs associated to the Contract Line Items
     * 
     * @param ContractLineItemData Contract line item wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful of create CLI, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse createContractLineItems(ContractLineItemData contractLineItemData){  
        
        System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - enter' );
        
        return new SCON_ServiceContractPlanHandler().createContractLineItems(contractLineItemData);
    }

    /**
     * This method is used to create/update Entitled Service for a given Service Contract or Contract Line. 
     * 
     * @param EntitledServiceData Entitled Service wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of entitled service, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse createEntitledServices(EntitledServiceData entitledServiceData){  
        
        System.debug( LoggingLevel.DEBUG, 'createEntitledServices() - enter' );
        
        return new SCON_ServiceContractPlanHandler().createEntitledServices(entitledServiceData);
    }

    /**
     * This method is to Cancel Service Contract 
     * 
     * @param CancelServiceContractData Cancel Service Contract wrapper instance to be created/updated.
     * 
     * @return Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful save of service contract, Otherwise, set it to 'false'.
     */
    override public Common.ServiceResponse cancelServiceContract(CancelServiceContractData cancelServiceContract){  
        
        System.debug( LoggingLevel.DEBUG, 'cancelServiceContract() - enter' );
        
        return new SCON_ServiceContractPlanHandler().cancelServiceContract(cancelServiceContract);
    }

}