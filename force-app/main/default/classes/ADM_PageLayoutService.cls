/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has service implementation to retrieve/save/delete Pagelayouts.
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                8 Jun 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 *****************************************************************************************************/
public with sharing class ADM_PageLayoutService extends ADM_AbstractPageLayoutService {

    public ADM_PageLayoutService(){}
    
    public ADM_PageLayoutService(RestRequest req, RestResponse res){
    	super(req, res);
	}
    
    /**
     * This method fetches pagelayout details for the requested Id 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     */
    override public Common.ServiceResponse getPageLayoutDetails( String pageLayoutId, Boolean translationRequired ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().getPageLayoutDetails( pageLayoutId, translationRequired);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    
     /**
     * This method fetches record type for the requested object name
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with record type details for requested object name.
     */
    public Common.ServiceResponse getRecordTypeDetails( String objectAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        final COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();
        
        try {

            serviceResponse.data = metadataManager.getRecordTypeDetails( objectAPIName );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getRecordTypeDetails() : Failed to retrieve Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRecordTypeDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }


    /**
     * This method fetches record type for the requested object list name
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with record type details for requested object list name.
     */
    public Common.ServiceResponse getObjectRecordTypeDetails( List<String> objectAPINames ) {
        
        System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        final COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();
        
        try {

            serviceResponse.data = metadataManager.getObjectRecordTypeDetails( objectAPINames );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getObjectRecordTypeDetails() : Failed to retrieve Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getObjectRecordTypeDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method fetches pagelayout details for the requested Id 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with page layout details for requested id.
     */
    public Common.ServiceResponse getPageLayoutDetails( String pageLayoutId, Boolean translationRequired, Adm.SourceOrigin sourceOrigin ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().getPageLayoutDetails( pageLayoutId, translationRequired, sourceOrigin );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPageLayoutDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    } 

    /**
     * This method fetches pagelayout details for the requested Id 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with List of pagelayouts.
     */
    override public Common.ServiceResponse getAllPageLayouts( final String screenType, Boolean translationRequired) {
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().getAllPageLayouts( screenType, translationRequired );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayouts() : Failed to retrieve Page Layouts. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method validated pagelayout information
     * 
     * @return Returns instance of Common.ServiceResponse with validation page layout results.
     */
    override public Common.ServiceResponse validatePageLayout( final Adm.PageLayoutValidationRequest pageLayoutValidationRequest ) {
        
        System.debug( LoggingLevel.DEBUG, 'validatePageLayout() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().validatePageLayout(pageLayoutValidationRequest);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validatePageLayout() : Failed to validate page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validatePageLayout() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }
    
    /**
     * This method saves pagelayout info and maps back the
     * salesforce generated ids to the pagelayout info.
     * 
     * @return Returns instance of Common.ServiceResponse with save page layout info.
     */
    override public Common.ServiceResponse savePageLayout( final Adm.PageLayout pageLayoutInfo ) {
        System.debug( LoggingLevel.DEBUG, 'savePageLayout() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().savePageLayout(pageLayoutInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePageLayout() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

     /**
     * This method retrieve where used details of transaction.
     * 
     * @return Returns instance of Common.ServiceResponse with where used details.
     */
    override public Common.ServiceResponse getWhereUsedTransactionDetails( final Adm.WhereUsedInputRecord whereUsedInfo ) {
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedTransactionDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().getWhereUsedTransactionDetails(whereUsedInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedTransactionDetails() : Failed to save page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedTransactionDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method retrieve transactions for configuration filter.
     * 
     * @return Returns instance of Common.ServiceResponse with where used details.
     */
    override public Common.ServiceResponse getFilteredConfigurations( final Adm.ConfigFilterInputRecord configFilterInfo  ) {
        System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = ADM_ConfigurationFilterManager.getInstance().getFilteredConfigurations(configFilterInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getFilteredConfigurations() : Failed to save page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getFilteredConfigurations() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method retrieve configuration filters.
     * 
     * @return Returns instance of Common.ServiceResponse with where used details.
     */
    override public Common.ServiceResponse getAllConfigurationFilters(String entityType) {
        System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = ADM_ConfigurationFilterManager.getInstance().getAllConfigurationFilters(entityType);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllConfigurationFilters() : Failed to save page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllConfigurationFilters() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method saves pagelayout info and maps back the
     * salesforce generated ids to the pagelayout info.
     * 
     * @return Returns instance of Common.ServiceResponse with save page layout info.
     */
    public Common.ServiceResponse savePageLayout( final Adm.PageLayout pageLayoutInfo, Adm.SourceOrigin sourceOrigin ) {
        System.debug( LoggingLevel.DEBUG, 'savePageLayout() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().savePageLayout(pageLayoutInfo, sourceOrigin);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePageLayout() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method deletes pagelayout and related records
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with page layout deletion success status.
     */
    override public Common.ServiceResponse deletePageLayout( String pageLayoutId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deletePageLayout() - enter : pageLayoutId ' + pageLayoutId );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            new ADM_PageLayoutServiceImpl().deletePageLayout( pageLayoutId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to delete Page Layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePageLayout() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used for getting all the custom labels required
     * for Screen Designer.
     * 
     * @return Returns instance of Common.ServiceResponse with Custom labels.
     */
    override public Common.ServiceResponse getPageLayoutCustomLabels() {
        
        System.debug( LoggingLevel.DEBUG, 'getPageLayoutCustomLabels() - enter;');
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = ADM_CustomLabelService.getPageLayoutCustomLabels();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutCustomLabels() : Failed to fetch custom labels. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPageLayoutCustomLabels() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }
    /**
     * This method fetches pagelayout details for the requested Id 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with User info.
     */
    override public Common.ServiceResponse getUserInfo() {
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            Adm.UserInfo userRecord = new Adm.UserInfo();
            userRecord.id = UserInfo.getUserId();
            userRecord.firstName = UserInfo.getFirstName();
            userRecord.dateFormat = SvmxSystem.getUserDateFormat();
            userRecord.timeZoneOffSet = SvmxSystem.getUserTimezoneOffset();
            userRecord.timeFormat = 'h:mm A';
            userRecord.userType = UserInfo.getUserType();
            userRecord.userTimeZoneName = UserInfo.getTimeZone().getDisplayName();
            
            Map<String,String> numberFormatMap = SvmxSystem.getDecimalSeparator(); 
            userRecord.thousandSepartor = numberFormatMap.get('TS') ;
            userRecord.decimalSeparator = numberFormatMap.get('DS') ;
            userRecord.userCurrency = UserInfo.getDefaultCurrency();
            userRecord.svmxNameSpace = 'SVMXA360';
            userRecord.organizationId = UserInfo.getOrganizationId();
            userRecord.organizationName = UserInfo.getOrganizationName();
            userRecord.organizationType = [SELECT OrganizationType FROM Organization LIMIT 1].OrganizationType;
            userRecord.userLocale = UserInfo.getLocale();
            
            serviceResponse.data = userRecord;        
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayouts() : Failed to retrieve Page Layouts. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayouts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }
    
    /**
     * This method fetches all pagelayout with details 
     * from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with List of pagelayouts.
     */
    override public Common.ServiceResponse getAllPageLayoutsWithDetails() {
        System.debug( LoggingLevel.DEBUG, 'getAllPageLayoutsWithDetails() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().getAllPageLayoutsWithDetails();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayoutsWithDetails() : Failed to retrieve Page Layouts. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPageLayoutsWithDetails() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method fetches all tags from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with List of tags.
     */
    override public Common.ServiceResponse getAllTags() {
        System.debug( LoggingLevel.DEBUG, 'getAllTags() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().getAllTags();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTags() : Failed to retrieve Tags. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTags() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }

    /**
     * This method fetches where used status from the Salesforce Org.
     * 
     * @return Returns instance of Common.ServiceResponse with where used status.
     */
    override public Common.ServiceResponse getWhereUsedStatus() {
        System.debug( LoggingLevel.DEBUG, 'getWhereUsedStatus() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = ADM_ConfigurationUsageManager.getInstance().getWhereUsedStatus();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedStatus() : Failed to retrieve Tags. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getWhereUsedStatus() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }
    
    /**
     * This method fetches all configurable feature params values.
     * 
     * @return Returns instance of Common.ServiceResponse with map of feature params values.
     */
    override public Common.ServiceResponse getAllFeatureParameterValues() {
        System.debug( LoggingLevel.DEBUG, 'getAllFeatureParameterValues() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = COMM_FeatureAccessManager.getInstance().getAllFeatureParameterValues();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllFeatureParameterValues() : Failed to retrieve feature params. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllFeatureParameterValues() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }
    
    /**
     * This method saves list of pagelayouts and maps back the
     * salesforce generated ids to the pagelayout info.
     * 
     * @return Returns instance of Common.ServiceResponse with save page layout info.
     */
    override public Common.ServiceResponse savePageLayouts( final List<Adm.PageLayout> pageLayoutInfo ) {
        System.debug( LoggingLevel.DEBUG, 'savePageLayouts() - enter' );
        
        final Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {

            serviceResponse.data = new ADM_PageLayoutServiceImpl().savePageLayouts(pageLayoutInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayouts() : Failed to save page layout. Error' + e.getStackTraceString() );
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();// TODO Servicemax Internal Error Label.
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePageLayouts() - exit; serviceResponse.success= ' + serviceResponse.success );
        }
        
        return serviceResponse;    
    }
}