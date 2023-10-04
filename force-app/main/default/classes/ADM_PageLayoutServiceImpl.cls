public class ADM_PageLayoutServiceImpl {
    
    private final ADM_PageLayoutManager pageLayoutManager = ADM_PageLayoutManager.getInstance();

    /**
     * This method retrieves pagelayout details for requested id and populates the
     * information to the page layout wrapper.
     */
    public Adm.PageLayout getPageLayoutDetails( String pageLayoutId, Boolean translationRequired ) {
        
        System.debug( LoggingLevel.FINEST, 'getPageLayoutDetails() - enter');
        
        Adm.PageLayout pageLayout = new Adm.PageLayout();
        
        try {

            pageLayout = pageLayoutManager.getPageLayoutDetails( pageLayoutId, translationRequired, null );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve page layout details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getPageLayoutDetails() - exit; pageLayout= ' + pageLayout );
        }
        
        return pageLayout;
    }

    /**
     * This method retrieves pagelayout details for requested id and populates the
     * information to the page layout wrapper.
     */
    public Adm.PageLayout getPageLayoutDetails( String pageLayoutId, Boolean translationRequired, Adm.SourceOrigin sourceOrigin ) {
        
        System.debug( LoggingLevel.FINEST, 'getPageLayoutDetails() - enter');
        
        Adm.PageLayout pageLayout = new Adm.PageLayout();
        
        try {

            pageLayout = pageLayoutManager.getPageLayoutDetails( pageLayoutId, translationRequired, sourceOrigin );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPageLayoutDetails() : Failed to retrieve page layout details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getPageLayoutDetails() - exit; pageLayout= ' + pageLayout );
        }
        
        return pageLayout;
    }

    /**
     * This method retrieves pagelayout details for requested id and populates the 
     * information to the page layout wrapper.
     */
    public List<Adm.PageLayout> getAllPageLayouts( final String screenType, Boolean translationRequired ) {
        
        System.debug( LoggingLevel.FINEST, 'getAllPageLayouts() - enter');
        
        List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();
        
        try {

            pageLayoutList = pageLayoutManager.getAllPageLayouts( screenType, translationRequired );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayouts() : Failed to retrieve page layouts. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllPageLayouts() - exit; pageLayoutList.size = ' + pageLayoutList.size() );
        }
        
        return pageLayoutList;
    }

    /**
     * This method retrieves tags.
     */
    public List<String> getAllTags() {
        
        System.debug( LoggingLevel.FINEST, 'getAllTags() - enter');
        
        List<String> tags = new List<String>();
        
        try {

            tags = pageLayoutManager.getAllTags();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTags() : Failed to retrieve tags. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllTags() - exit; tags.size = ' + tags.size() );
        }
        
        return tags;
    }

    /**
     * This method performs the save of the page layout and maps back the
     * Salesforce generated Ids to the page layout wrapper
     */
    public Adm.ValidationResult validatePageLayout( final Adm.PageLayoutValidationRequest pageLayoutValidationRequest ) {
        
        System.debug( LoggingLevel.FINEST, 'validatePageLayout() - enter');
        
        Adm.ValidationResult validationResult = new Adm.ValidationResult();
        
        try {

            validationResult = pageLayoutManager.validatePageLayout(pageLayoutValidationRequest.pageLayout, pageLayoutValidationRequest.referenceDatas);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validatePageLayout() : Failed to validate Page Layout. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'validatePageLayout() - exit; validationResult = ' + validationResult);
        }
        
        return validationResult;
    }
    
    /**
     * This method performs the save of the page layout and maps back the
     * Salesforce generated Ids to the page layout wrapper
     */
    public Adm.PageLayout savePageLayout( final Adm.PageLayout pageLayoutInfo ) {
        
        System.debug( LoggingLevel.FINEST, 'savePageLayout() - enter');
        
        Adm.PageLayout pageLayout = new Adm.PageLayout();
        
        try {

            pageLayout = pageLayoutManager.savePageLayout(pageLayoutInfo, null);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'savePageLayout() - exit; pageLayout = ' + pageLayout);
        }
        
        return pageLayout;
    }

    /**
     * This method used to retrieve where used transaction details
     */
    public List<Adm.WhereUsedInfo> getWhereUsedTransactionDetails( final Adm.WhereUsedInputRecord whereUsedInfo ) {
        
        System.debug( LoggingLevel.FINEST, 'getWhereUsedTransactionDetails() - enter');
        
        List<Adm.WhereUsedInfo> whereUsedTransactionList = new List<Adm.WhereUsedInfo>();
        ADM_WhereUsedManager whereUsedManager = ADM_WhereUsedManager.getInstance();
        
        try {

            whereUsedTransactionList = whereUsedManager.getWhereUsedDetails(whereUsedInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getWhereUsedTransactionDetails() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getWhereUsedTransactionDetails() - exit; whereUsedTransactionList size = ' + whereUsedTransactionList.size());
        }
        
        return whereUsedTransactionList;
    }

    /**
     * This method performs the save of the page layout and maps back the
     * Salesforce generated Ids to the page layout wrapper
     */
    public Adm.PageLayout savePageLayout( final Adm.PageLayout pageLayoutInfo, Adm.SourceOrigin sourceOrigin ) {
        
        System.debug( LoggingLevel.FINEST, 'savePageLayout() - enter');
        
        Adm.PageLayout pageLayout = new Adm.PageLayout();
        
        try {

            pageLayout = pageLayoutManager.savePageLayout(pageLayoutInfo, sourceOrigin);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayout() : Failed to save Page Layout. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'savePageLayout() - exit; pageLayout = ' + pageLayout);
        }
        
        return pageLayout;
    }

    /**
     * This method deletes page layout and related records for the requested
     * pagelayout id from Salesforce org.
     */
    public void deletePageLayout( String pageLayoutId ) {
        
        System.debug( LoggingLevel.FINEST, 'deletePageLayout() - enter; pageLayoutId = '+ pageLayoutId );
        
        try {

            pageLayoutManager.deletePageLayout( pageLayoutId );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deletePageLayout() : Failed to delete page layout . Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deletePageLayout() - exit; pageLayoutId= ' + pageLayoutId );
        }
        
    }

    /**
     * This method retrieves all pagelayout with details
     * information to the page layout wrapper.
     */
    public List<Adm.PageLayout> getAllPageLayoutsWithDetails() {
        
        System.debug( LoggingLevel.FINEST, 'getAllPageLayoutsWithDetails() - enter');
        
        List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();
        
        try {

            pageLayoutList = pageLayoutManager.getAllPageLayoutsWithDetails();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPageLayoutsWithDetails() : Failed to retrieve page layouts. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAllPageLayoutsWithDetails() - exit; pageLayoutList.size = ' + pageLayoutList.size() );
        }
        
        return pageLayoutList;
    }

    /**
     * This method performs the save of the page layout and maps back the
     * Salesforce generated Ids to the page layout wrapper
     */
    public List<Adm.PageLayout> savePageLayouts( final List<Adm.PageLayout> pageLayoutInfo ) {
        
        System.debug( LoggingLevel.FINEST, 'savePageLayouts() - enter');
        
        List<Adm.PageLayout> pageLayout = new List<Adm.PageLayout>();
        
        try {
            // Verify request for valid page layout informations.
            if( pageLayoutInfo == null || pageLayoutInfo.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'savePageLayouts() : Invalid request parameters. pageLayoutInfo= ' + pageLayoutInfo );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            pageLayout = pageLayoutManager.savePageLayouts(pageLayoutInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'savePageLayouts() : Failed to save Page Layouts. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'savePageLayouts() - exit; pageLayout = ' + pageLayout);
        }
        
        return pageLayout;
    }
}