@istest
public class ADM_AdminWelcomePage_LS_UT {
    @isTest
    static void testGetCards() {
        try{
            Test.startTest();
            
            List<Adm.WelcomePageCard> cardList = ADM_AdminWelcomePage_LS.getAllCardData();

            Test.stopTest();
            system.assertEquals(cardList.size(), 3);
        } catch(Exception e){
           System.assert(false, 'should not trough error');
        }
     }
}