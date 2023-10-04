@IsTest
public class ADM_AdminPageLightningService_UT {

    static testMethod void testAdminPagesHappyPath() {
        Test.startTest();

        Common.ServiceResponse serviceResponse = ADM_AdminPageLightningService.getActiveAdminPages();

        Test.stopTest();

        Common.ServiceResponse requeryResponse = ADM_AdminPageLightningService.getActiveAdminPages();

        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(7 , ((List<Object>)serviceResponse.data).size(), 'expected 7 groups --');

        system.assertEquals(true, requeryResponse.success, 'expected successful serviceResponse');
        system.assertEquals(8 , ((List<Object>)requeryResponse.data).size(), 'expected 8 groups ---');
    }
}