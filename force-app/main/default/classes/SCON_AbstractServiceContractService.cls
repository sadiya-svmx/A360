/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for Service Contract service implementation.
 * Also provides implementation for invokeMethod which maps to the requested scon service implementation. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *             Karthick Saravanan      10 Nov 2021      Created.
 *****************************************************************************************************/
public abstract class SCON_AbstractServiceContractService extends COMM_SvmxRestBase {
    
    /**
     * Class constructor to create instance of this class. This default constructor 
     * is required to invoke class instance from lightning services. 
     */
    public SCON_AbstractServiceContractService() {
    }

    /**
     * Class constructor to create instance of this class. This constructor is invoked 
     * by rest interface class.
     * 
     * @param request RestRequest class instance.
     * @param response RestResponse class instance.
     */
    protected SCON_AbstractServiceContractService(RestRequest req, RestResponse res) {
        super(req, res, 'scon');
    }

    /**
     * Override method invoked by base rest class with requested method.
     * 
     * @param methodName Method name from the request URL.
     * 
     * @return Returns Common.ServiceResponse instance with response data.
     */
    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'createServiceContract' {                
                    response = createServiceContract( (ServiceContractData) deserializeRequestTo( ServiceContractData.class ) );
                }
                when 'createContractLineItems' {                
                    response = createContractLineItems( (ContractLineItemData) deserializeRequestTo( ContractLineItemData.class ) );
                }
                when 'createEntitledService' {                
                    response = createEntitledServices( (EntitledServiceData) deserializeRequestTo( EntitledServiceData.class ) );
                }
                when 'cancelServiceContract' {                
                    response = cancelServiceContract( (CancelServiceContractData) deserializeRequestTo( CancelServiceContractData.class ) );
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
     *   This method creates Service Contract and its directly associated Entitled Services and 
     *   Contract Price Line Items for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/scon/v1/createServiceContract/
     */
    public abstract Common.ServiceResponse createServiceContract( final ServiceContractData serviceContractData );

    /**
     *   This method creates Contract Line Items for a given list of assets. This also creates the ES 
     *   and CPLIs associated to the Contract Line Items.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/scon/v1/createContractLineItems/
     */
    public abstract Common.ServiceResponse createContractLineItems( final ContractLineItemData contractLineItemData );

    /**
     *   This method creates creates Entitled Services for a given Service Contract or Contract Line. 
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/scon/v1/createEntitledService/
     */
    public abstract Common.ServiceResponse createEntitledServices( final EntitledServiceData entitledServiceData );

    /**
     *   This method cancels the Service Contract for the given contract id.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/scon/v1/cancelServiceContract/
     */
    public abstract Common.ServiceResponse cancelServiceContract( final CancelServiceContractData cancelServiceContract );
}