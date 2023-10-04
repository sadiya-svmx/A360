/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates services to retrieve/create/update and delete 
 * Object Mappings. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 May 2020     Created.
 *              Sandeep Dhariwal        18 Aug 2020     BLOS-509
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 * A360TOOL-819 Ramachandra Mohan       26 Nov 2021     Validation service for Object Mapping.
 *****************************************************************************************************/
public with sharing class ADM_ObjectMappingService extends ADM_AbstractMappingService {
    
    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by lightning services.
     */
    public ADM_ObjectMappingService(){}

    /**
     * Class constructor to create instance of this class. This constructor is 
     * invoked by rest interfaces.
     */
    public ADM_ObjectMappingService( RestRequest request, RestResponse response ){
        super(request, response);
    }

	/**
     * This method retrieves all available Object mappings from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all object mapping informations.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     */
    override public Common.ServiceResponse getAllObjectMappings() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getAllObjectMappings();
            System.debug( LoggingLevel.INFO, 'getAllObjectMappings() : Retrieved object mapping list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappings() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappings() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to retrieve object mapping detail for requested object mapping.
     * 
     * @param objectMapping Instance of Adm.ObjectMapping with object mapping id for which 
     * 						field mapping informations to be retrieved.
     * @return Returns 	instance of Common.ServiceResponse with list of object mapping details 
     * 					in the data field.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
	 * @example getObjectMappingDetails({id:'01I5w000000cUDJ'});
     */
    
    override public Common.ServiceResponse getObjectMappingDetails( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getObjectMappingDetails( objectMapping );
            System.debug( LoggingLevel.INFO, 'getObjectMappingDetails() : Retrieved object mapping details successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingDetails() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse getObjectMappingsByName( final String targetObjectAPIName, final String sourceObjectAPIName ) {
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getObjectMappingsByName( targetObjectAPIName, sourceObjectAPIName );
            System.debug( LoggingLevel.INFO, 'getObjectMappingsByName() : Retrieved object mapping details successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByName() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    override public Common.ServiceResponse getObjectMappingsByHeaderObject( final String targetObjectAPIName, final String sourceObjectAPIName, final String headerObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByHeaderObject() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getObjectMappingsByName( targetObjectAPIName, sourceObjectAPIName, headerObject );
            System.debug( LoggingLevel.INFO, 'getObjectMappingsByHeaderObject() : Retrieved object mapping details successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByHeaderObject() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectMappingsByHeaderObject() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectMappingsByHeaderObject() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    override public Common.ServiceResponse getObjectValueMappingsByName( final String targetObjectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getObjectValueMappingsByName( targetObjectAPIName );
            System.debug( LoggingLevel.INFO, 'getObjectValueMappingsByName() : Retrieved object mapping details successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByName() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByName() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    override public Common.ServiceResponse retreiveObjectMappingsWithDetailsByIds( List<String> mappingIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'retreiveObjectMappingsWithDetailsByIds() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getObjectMappingsWithDetailsByIds( mappingIds );
            System.debug( LoggingLevel.INFO, 'retreiveObjectMappingsWithDetailsByIds() : Retrieved object mapping details successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'retreiveObjectMappingsWithDetailsByIds() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retreiveObjectMappingsWithDetailsByIds() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retreiveObjectMappingsWithDetailsByIds() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    override public Common.ServiceResponse getObjectValueMappingsByHeaderObject( final String targetObjectAPIName, final String headerObject ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByHeaderObject() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getObjectValueMappingsByName( targetObjectAPIName, headerObject );
            System.debug( LoggingLevel.INFO, 'getObjectValueMappingsByHeaderObject() : Retrieved object mapping details successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByHeaderObject() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectValueMappingsByHeaderObject() : Failed to retrieve Object Mappings details. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectValueMappingsByHeaderObject() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }    
    
    /**
     * This method is used to validate object mapping information into Salesforce Org.
     * 
     * @param objectMapping Instance of Adm.ObjectMapping with object and field mapping informations to be validated.
     * @return Returns instance of Common.ServiceResponse with validation information in the data field.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
     * @example validateObjectMapping({id:'01I5w000000cUDJ',name: 'Create WorkORder From Case Map' ,developerName: 'Create_WorkORder_From_Case_Map',...});
     */
    override public Common.ServiceResponse validateObjectMapping( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateObjectMapping() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().validateObjectMapping( objectMapping );
            System.debug( LoggingLevel.INFO, 'validateObjectMapping() : Validated object mapping successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Failed to validate Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateObjectMapping() : Failed to validate Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateObjectMapping() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to save object mapping information into Salesforce Org.
     * 
     * @param objectMapping Instance of Adm.ObjectMapping with object and field mapping informations.
     * @return Returns instance of Common.ServiceResponse with saved object mapping information in the data field.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
     * @example saveObjectMapping({id:'01I5w000000cUDJ',name: 'Create WorkORder From Case Map' ,developerName: 'Create_WorkORder_From_Case_Map',...});
     */
    override public Common.ServiceResponse saveObjectMapping( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveObjectMapping() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().saveObjectMapping( objectMapping );
            System.debug( LoggingLevel.INFO, 'saveObjectMapping() : Saved object mapping successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMapping() : Failed to save Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveObjectMapping() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
    /**
     * This method is used to delete the object Mapping for given mapping id.
     * 
     * @return 	Returns instance of Common.ServiceResponse with success 'true' on 
     * 			successful delete of the object mapping, Otherwise, set it to 'false'.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
     * @example deleteObjectMapping({id:'01I5w000000cUDJ'});
     */
    override public Common.ServiceResponse deleteObjectMapping( final Adm.ObjectMapping objectMapping ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteObjectMapping() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            new ADM_ObjectMappingServiceImpl().deleteObjectMapping( objectMapping );
            System.debug( LoggingLevel.INFO, 'deleteObjectMapping() : Deleted object mapping successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to delete Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteObjectMapping() : Failed to delete Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteObjectMapping() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method retrieves all available Object mappings with details from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with list of all object mapping informations.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     */
    override public Common.ServiceResponse getAllObjectMappingsWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingsWithDetails() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            // Assign object mapping informations to response data.
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().getAllObjectMappingsWithDetails();
            System.debug( LoggingLevel.INFO, 'getAllObjectMappingsWithDetails() : Retrieved object mapping list' );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllObjectMappingsWithDetails() : Failed to retrieve Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllObjectMappingsWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to save List of object mapping information into Salesforce Org.
     * 
     * @param objectMappingList List of Adm.ObjectMapping with object and field mapping informations.
     * @return Returns instance of Common.ServiceResponse with saved object mapping information in the data field.
     * 
     * @see ADM_ObjectMappingServiceImpl
     * @exception SvmxSystem.SvmxNestedException, Exception
     * 
     */
    override public Common.ServiceResponse saveObjectMappings( final List<Adm.ObjectMapping> objectMappingList ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveObjectMappings() - enter' );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            serviceResponse.data = new ADM_ObjectMappingServiceImpl().saveObjectMappings( objectMappingList );
            System.debug( LoggingLevel.INFO, 'saveObjectMappings() : Saved object mapping successfully' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Failed to save Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveObjectMappings() : Failed to save Object Mappings. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage(); // TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveObjectMappings() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
}