/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abtract class which provides methods for page layout service implementation.
 * Also provides implementation for invokeMethod which maps to the requested page layout service implementation. 
 *
 * @author Sachin S
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sachin S                19 Jun 2020     Created.
 *              Sathish Kumar DB        02 Feb 2021     A360TOOL-327
 *****************************************************************************************************/
public abstract class ADM_AbstractPageLayoutService extends COMM_SvmxRestBase {
    
    public ADM_AbstractPageLayoutService(){
    }
    
    protected ADM_AbstractPageLayoutService(RestRequest req, RestResponse res) {
        super(req, res, 'PageLayoutRestInterface');
    }

    override public Object invokeMethod() {

        System.debug( LoggingLevel.DEBUG, 'invokeMethod() - enter; methodName= ' + methodName );

        Common.ServiceResponse response = new Common.ServiceResponse();
        
        try {
            
            switch on methodName {
                
                when 'getPageLayoutDetails' {
                    String translation = request.params.get('translation');
                    Boolean translationRequired = translation != null ? boolean.valueOf(translation) : false;
                    response = getPageLayoutDetails( recordId, translationRequired );
                }            
                when 'getAllPageLayouts' {
                    String translation = request.params.get('translation');
                    Boolean translationRequired = translation != null ? boolean.valueOf(translation) : false;
                   	response = getAllPageLayouts( recordId, false );
                }
                when 'getAllPageLayoutsWithDetails' {
                    response = getAllPageLayoutsWithDetails();
                }
                when 'getAllTags' {
                    response = getAllTags();
                }
                when 'getWhereUsedStatus' {
                    response = getWhereUsedStatus();
                }
                when 'getWhereUsedTransactionDetails' {
                    final Adm.WhereUsedInputRecord whereUsedRequest = (Adm.WhereUsedInputRecord)deserializeRequestTo(Adm.WhereUsedInputRecord.class); 
                    response = getWhereUsedTransactionDetails(whereUsedRequest);
                }
                when 'getFilteredConfigurations' {
                    final Adm.ConfigFilterInputRecord configFilterRequest = (Adm.ConfigFilterInputRecord)deserializeRequestTo(Adm.ConfigFilterInputRecord.class); 
                    response = getFilteredConfigurations( configFilterRequest );
                }
                when 'getAllConfigurationFilters' {
                    response = getAllConfigurationFilters(recordId);
                }
                when 'getUserInfo' {                
                    response = getUserInfo();
                }
                when 'validatePageLayout' {                
                    final Adm.PageLayoutValidationRequest pageLayoutValidationRequest = (Adm.PageLayoutValidationRequest)deserializeRequestTo(Adm.PageLayoutValidationRequest.class);     
                    response = validatePageLayout( pageLayoutValidationRequest );
                }
                when 'savePageLayout' {                
                    final Adm.PageLayout pageLayout = (Adm.PageLayout)deserializeRequestTo(Adm.PageLayout.class);     
                    response = savePageLayout( pageLayout );
                }
                when 'savePageLayouts' {                
                    final List<Adm.PageLayout> pageLayoutList = (List<Adm.PageLayout>)deserializeRequestTo(List<Adm.PageLayout>.class);     
                    response = savePageLayouts( pageLayoutList );
                }
                when 'deletePageLayout' {                
                    response = deletePageLayout( recordId );
                }
                when 'getPageLayoutCustomLabels' {                
                    response = getPageLayoutCustomLabels();
                }
                when 'getAllFeatureParameterValues' {                
                    response = getAllFeatureParameterValues();
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
    
    public abstract Common.ServiceResponse getPageLayoutDetails(String pageLayoutId, Boolean translationRequired);
    public abstract Common.ServiceResponse getAllPageLayouts(String screenType, Boolean translationRequired);
    public abstract Common.ServiceResponse getUserInfo();
    public abstract Common.ServiceResponse validatePageLayout(Adm.PageLayoutValidationRequest request);
    public abstract Common.ServiceResponse savePageLayout(Adm.PageLayout request);
    public abstract Common.ServiceResponse deletePageLayout(String pageLayoutId);
    public abstract Common.ServiceResponse getPageLayoutCustomLabels();
    public abstract Common.ServiceResponse getAllPageLayoutsWithDetails();
    public abstract Common.ServiceResponse getAllTags();
    public abstract Common.ServiceResponse getWhereUsedStatus();
    public abstract Common.ServiceResponse getWhereUsedTransactionDetails(Adm.WhereUsedInputRecord request);
    public abstract Common.ServiceResponse getFilteredConfigurations(Adm.ConfigFilterInputRecord request);
    public abstract Common.ServiceResponse getAllConfigurationFilters(String entityType);
    public abstract Common.ServiceResponse savePageLayouts(List<Adm.PageLayout> pageLayoutList);
    public abstract Common.ServiceResponse getAllFeatureParameterValues();

}