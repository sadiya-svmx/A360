public with sharing class ADM_AdminWelcomePage_LS {
    /**
     * This method is used to retrieve all the card data.
     * 
     * @return Returns list of card data
     */
    @AuraEnabled(cacheable=true)
    public static List<Adm.WelcomePageCard> getAllCardData() {
        System.debug( LoggingLevel.FINEST, 'getAdminWelcomePageCard() - enter');
        
        List<Adm.WelcomePageCard> cardList = new List<Adm.WelcomePageCard>();
        
        try {
            cardList = ADM_AdminWelcomePageHandler.getInstance().getAdminWelcomePageCard();
            System.debug( LoggingLevel.INFO, 'getAdminWelcomePageCard() : Retrieved admin welcome change custom metadata. cardList.size()= ' + cardList.size() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAdminWelcomePageCard() : Failed to retrieve custom metadata. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'getAdminWelcomePageCard() - exit; cardList.size()= ' + cardList.size() );
        }
        
        return cardList;
    }
}