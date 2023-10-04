/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service calls to insert or update technical attribute values
 * 
 *
 * @author Jeevika Rao
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        	Name                    Date            Comment
 *****************************************************************************************************
 *              	Jeevika Rao            11 July 2022    	Created.
 *****************************************************************************************************/


public with sharing class TA_TechnicalAttributeService extends TA_AbstractTechnicalAttributeService{
    /**
    * Class constructor to create instance of this class.
    */
    public TA_TechnicalAttributeService() {}
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public TA_TechnicalAttributeService( RestRequest request, RestResponse response ){
        super(request, response);
    }
    
    /**
     * This method is used to save the Technical Attribute values.
     * 
     * @param TechnicalAttributeRequest Information of Technical Attribute values that need to be updated
     * @return Returns instance of Common.ServiceResponse with success as true and failure as false
     * @see TA_TechnicalAttributeHandler
     * 
     * @example saveTechnicalAttributes(TechnicalAttributeRequest);
     */
    
    override public Common.ServiceResponse saveTechnicalAttributes( final TechnicalAttributeRequest technicalAttributeRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributes() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{
            Common.RequestOption requestOption = new Common.RequestOption();
            requestOption.operationType = 'API';
            requestOption.isCreateActivityLogs = true;
            serviceResponse.data = new TA_TechnicalAttributeHandler().saveTechnicalAttributes(technicalAttributeRequest, requestOption);
            
            serviceResponse.success = true;
            serviceResponse.message =  System.Label.Message_AttributeValueSaved;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributes() : Failed to save attributes. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributes() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
        
    }
}