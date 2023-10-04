public class ADM_RecentItemsServiceImpl {
    
    private final ADM_RecentItemsManager recentItemsManager = ADM_RecentItemsManager.getInstance();

    /**
     * This method retrieves recent items details.
     */
    public List<Adm.RecentItemInfo> getRecentItemsDetails() {
        
        System.debug( LoggingLevel.FINEST, 'getRecentItemsDetails() - enter');
        
        List<Adm.RecentItemInfo> recentItemInfo = new List<Adm.RecentItemInfo>();
        
        try {

            recentItemInfo = recentItemsManager.getRecentItemsDetails();
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getRecentItemsDetails() : Failed to retrieve recent items details. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getRecentItemsDetails() - exit; recent items= ' + recentItemInfo );
        }
        
        return recentItemInfo;
    }

    /**
     * This method performs the save of the recent items and maps back the
     * Salesforce generated Ids to the recent items wrapper
     */
    public Adm.RecentItemInfo saveRecentItem( Adm.RecentItemInfo recentItemInfo ) {
        
        System.debug( LoggingLevel.FINEST, 'saveRecentItem() - enter:' + recentItemInfo);
        
        try {

            recentItemInfo = recentItemsManager.saveRecentItem(recentItemInfo);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveRecentItem() : Failed to save recent Item. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveRecentItem() - exit; recent items = ' + recentItemInfo);
        }
        
        return recentItemInfo;
    }
}