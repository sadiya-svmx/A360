public with sharing class ADM_AdminWelcomePageHandler {
    /**
     * Static variable to hold instance of this class.
     */
    private static ADM_AdminWelcomePageHandler instance = null;
    private final static Integer NUMBER_OF_CARDS = 3;
    /**
     * Private constructor to restrict multiple instance creation of this class.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private ADM_AdminWelcomePageHandler() {
    }

    /**
     * Static method to return instance of this class.
     */
    public static ADM_AdminWelcomePageHandler getInstance() {
        
        if( instance == null ) {
            instance = new ADM_AdminWelcomePageHandler();
        }

        return instance;
    }

    public List<Adm.WelcomePageCard> getAdminWelcomePageCard () {
        List<Adm.WelcomePageCard> cardList = new List<ADM.WelcomePageCard>();

        for(Integer cardNumber = 0; cardNumber < NUMBER_OF_CARDS; cardNumber++) {
            ADM.WelcomePageCard mdata = new ADM.WelcomePageCard();
            mdata.cardOrderNumber =  cardNumber;
            getCardLabelByOrderNumber(mdata, cardNumber);
            cardList.add(mdata);
        }
        return cardList;
    }

    public void getCardLabelByOrderNumber (ADM.WelcomePageCard card, Integer cardNumber) {
        switch on cardNumber {
            when 0 {
                card.cardCaption = System.Label.Label_WelcomePageCard1Caption;
                card.cardDescription = System.Label.Label_WelcomePageCard1Description;
                card.cardButtonLabel = System.Label.Label_WelcomePageCard1ButtonLabel;
                card.cardURL = System.Label.URL_ReleaseNotesLink;
                card.cardIcon =  'utility:announcement';
            }	
            when 1 {
                card.cardCaption = System.Label.Label_WelcomePageCard2Caption;
                card.cardDescription = System.Label.Label_WelcomePageCard2Description;
                card.cardButtonLabel = System.Label.Label_WelcomePageCard2ButtonLabel;
                card.cardURL = System.Label.URL_ProductTrainingLink;
                card.cardIcon =  'utility:trail';
            }
            when 2 {
                card.cardCaption = System.Label.Label_WelcomePageCard3Caption;
                card.cardDescription = System.Label.Label_WelcomePageCard3Description;
                card.cardButtonLabel = System.Label.Label_WelcomePageCard3ButtonLabel;
                card.cardURL = System.Label.URL_CommunityPageLink;
                card.cardIcon =  'utility:comments';
            }
        }
    }
}