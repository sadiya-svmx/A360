/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a Base class for all the rest services which parses REST requests and 
 * calculates the method name to be invoked.   
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Jun 2020     Created.
 * BLOS-348     Ramachandra Mohan       06 Aug 2020     Updated URL parsing logic to support service type, version & recordId.
 *****************************************************************************************************/
public abstract class COMM_SvmxRestBase {

    public static final String HTTP_METHOD_GET		= 'GET';
    public static final String HTTP_METHOD_POST		= 'POST';
    public static final String HTTP_METHOD_DELETE	= 'DELETE';
    
    protected RestRequest request;
    protected RestResponse response;
    
    protected String serviceType;
    protected String serviceName;
    protected String version;
    protected String methodName;
    protected String recordId;
    protected String httpMethod;

    public static final Integer OK						= 200;
    public static final Integer BAD_REQUEST				= 400;
    public static final Integer NOT_FOUND				= 404;
    public static final Integer UNPROCESSABLE_ENTITY  	= 422;
    public static final Integer INTERNAL_SERVER_ERROR  	= 500;
    
    /**
     * !!! The empty constructor is available so that the rest implementations can be instantiated and used by-passing the
     * !!! the SFDC REST layer.
     */
    protected COMM_SvmxRestBase() {
    }

    /**
     * @description This class's constructor
     * @param req The request object got during the initial service call
     * @param res The response object got during the initial service call
     * @param serviceName The name of the REST service. Usually this will be class name of the service class. 
     */
    protected COMM_SvmxRestBase( RestRequest req, RestResponse res, String serviceName ) {
        
        this.request = req;
        this.response = res;
        this.serviceName = serviceName;
        
        initService();
    }

    /**
     * Initialize service type, version, method names from request URL.
     */
    private void initService() {
        
        System.debug( LoggingLevel.DEBUG, 'initService() - enter' );
        
        try {
            
            if( String.isBlank( request.requestURI) ) {
                
                System.debug( LoggingLevel.ERROR, 'initService() : Invalid URI. request.requestURI=' + request.requestURI );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_REQUEST_URL );  
            }
            
            final List<String> urlElements = request.requestURI.split('/');
            Integer index = urlElements.indexOf(this.serviceName);
            
            if( index == -1 || urlElements.size() < (index + 3) ) {
                
                System.debug( LoggingLevel.ERROR, 'initService() : Invalid URI. request.requestURI=' + request.requestURI );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_REQUEST_URL ); 
            }
            
            this.serviceType = urlElements.get( index - 1 );
            this.version = urlElements.get( ++index );
            this.methodName = urlElements.get( ++index );
            
            if( urlElements.size() > ++index ) {
                this.recordId = urlElements.get( index );
            }
            
            this.response.statusCode = OK;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'initService() : Failed to initialize REST service. Error' + e.getMessage() );
            this.response.statusCode = BAD_REQUEST;
            
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'initService() : Failed to initialize REST service. Error' + e.getMessage() );
            this.response.statusCode = INTERNAL_SERVER_ERROR;
            
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initService() - exit' );
        }
    }
    
    public void invokeMethod( final String httpMethod ) {
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; httpMethod= ' + httpMethod);
        
        this.httpMethod = httpMethod;
      
        final Object restResponseData = invokeMethod();
        
        if( restResponseData != null && this.response.statusCode == OK ) {
            
            String serializedData = JSON.serialize(restResponseData , true);
            this.response.responseBody = Blob.valueOf(serializedData);
        }
        
        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - exit');
    }
    
    protected Object deserializeRequestTo( final System.Type apexType ) {
        
        System.debug( LoggingLevel.FINEST, 'deserializeRequestTo() - enter');
        Object returnValue;
        
        try {        
            
            if( this.httpMethod.equalsIgnoreCase(HTTP_METHOD_POST) && request.requestBody != null ) {
                returnValue = JSON.deserialize( request.requestBody.toString(), apexType );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deserializeRequestTo() : Failed to deserialize Request. Error' + e.getStackTraceString() );
            this.response.statusCode = UNPROCESSABLE_ENTITY;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deserializeRequestTo() - exit; returnValue= ' + returnValue );
        }

        return returnValue;
    }
    
    protected JSONParser createJSONParser() {
        
        System.debug( LoggingLevel.FINEST, 'createJSONParser() - enter');
        
        JSONParser parser;
        try {
            if( this.httpMethod.equalsIgnoreCase(HTTP_METHOD_POST) && request.requestBody != null ) {
                parser = JSON.createParser(request.requestBody.toString());
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'createJSONParser() : Failed to deserialize Request. Error' + e.getStackTraceString() );
            this.response.statusCode = UNPROCESSABLE_ENTITY;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'createJSONParser() - exit; parser= ' + parser );
        }
        
        return parser;
    }
    
    /**
     * @description This method is called by this class itself to initiate a call to the
                    actual method implementation. Sub-classes must override this method.
     * @param mi The object containing all the information about the method that needs to be executed.
     * @return Object The result of the method execution. This object is converted to a JSON string and returned to the calling consumer. 
     */
    abstract protected Object invokeMethod();
}