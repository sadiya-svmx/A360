@IsTest
public class ADM_AdminPageManager_UT {

    static testMethod void testAdminPagesHappyPath() {
        Test.startTest();


        ADM_AdminPageManager adminPageManager = ADM_AdminPageManager.getInstance();
        List<Adm.AdminPage> activeAdminPageList = adminPageManager.getActiveAdminPages();

        Test.stopTest();

        List<Adm.AdminPage> requery = adminPageManager.getActiveAdminPages();

        system.assertEquals(7, activeAdminPageList.size(), 'expected 7 active Admin Pages (group) at root level');
        system.assertEquals(3, activeAdminPageList[1].children.size(), 'expected 3 active Admin Page under the group');

        system.assertEquals(8, requery.size(), 'expected 8 active Admin Pages (group) at root level');
        system.assertEquals(3, requery[1].children.size(), 'expected 3 active Admin Page under the group');
    }
}