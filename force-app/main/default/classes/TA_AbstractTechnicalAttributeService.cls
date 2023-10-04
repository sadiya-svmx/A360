/*****************************************************************************
 *                       Copyright (C) 2022 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for Technical Attribute service implementation.
 *
 * @author Jeevika Rao
 * @version Win 23
 * @since 2022
 */
/*****************************************************************************************************
 *    ID          Name                Date            Comment
 *****************************************************************************************************
 A360AM-1859    Jeevika Rao          05 July 2022        Created.
 *****************************************************************************************************/
public abstract class TA_AbstractTechnicalAttributeService extends COMM_SvmxRestBase {
    
    public TA_AbstractTechnicalAttributeService(){
    }
    
    protected TA_AbstractTechnicalAttributeService(RestRequest req, RestResponse res) {
        super(req, res, 'technicalAttribute');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'saveTechnicalAttributes' {
                    response = saveTechnicalAttributes( getTechnicalAttributeRequest() );
                }
                when else {
                    System.debug( LoggingLevel.ERROR, 'invokeMethod() : Method not Found: methodName= ' + methodName );
                    this.response.statusCode = NOT_FOUND;
                }
            }
        }   
        catch( Exception e ) {
            
            response.success = false;
            response.message = e.getMessage();
            
            System.debug(LoggingLevel.ERROR, 'invokeMethod(): Failed to complete the service. Error=' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'invokeMethod(): Failed to complete the service. Error=' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit; success= ' + response.success );
        }

        return response;
    }
    
    private TechAttr.TechnicalAttributeRequest getTechnicalAttributeRequest() {
        
        final TechAttr.TechnicalAttributeRequest technicalAttributeRequest = (TechAttr.TechnicalAttributeRequest) deserializeRequestTo( TechAttr.TechnicalAttributeRequest.class );
        final List<TechAttr.TechnicalAttributeData> technicalAttributeDataList = new List<TechAttr.TechnicalAttributeData>();
        
        try {
            final JSONParser parser = createJSONParser();
            
            while( parser.nextToken() != null ) {
                if( parser.getCurrentToken() == JSONToken.START_ARRAY ) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            technicalAttributeDataList.add((TechAttr.TechnicalAttributeData)parser.readValueAs(TechAttr.TechnicalAttributeData.class));
                            parser.skipChildren();
                        }
                    }
                }
            }
            
            if( !technicalAttributeDataList.isEmpty() ) {
                technicalAttributeRequest.attributeList = technicalAttributeDataList;
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeRequest() - exit; technicalAttributeRequest= ' + technicalAttributeRequest );
        }
        
        return technicalAttributeRequest;
    }
    /**
     * This method is used to save the Technical Attributes in the Org for the given request.
     * 
     * 
     * @example POST /services/apexrest/SVMXA360/technicalAttribute/v1/saveTechnicalAttributes/
     */
    public abstract Common.ServiceResponse saveTechnicalAttributes( final TechnicalAttributeRequest technicalAttributeRequest );
     
}