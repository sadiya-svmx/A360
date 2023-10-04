@isTest
private class ADM_TagHandler_UT {
    @isTest 
    static void testManageSVMXTags() {
        Account account = new Account(Name = 'Test_Account123');
        insert account;

        SVMXA360__CONF_TagDefinition__c tagDefn1 = new SVMXA360__CONF_TagDefinition__c(name='testTag1');
        SVMXA360__CONF_TagDefinition__c tagDefn2 = new SVMXA360__CONF_TagDefinition__c(name='testTag2');
        SVMXA360__CONF_TagDefinition__c tagDefn3 = new SVMXA360__CONF_TagDefinition__c(name='testTag3');
        SVMXA360__CONF_TagDefinition__c tagDefn4 = new SVMXA360__CONF_TagDefinition__c(name='testTag4');

        insert (new List<SVMXA360__CONF_TagDefinition__c>{tagDefn1, tagDefn2, tagDefn3, tagDefn4});
        
        SVMXA360__CONF_TagElement__c tagElement1 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn1.Id, 
                                                        SVMXA360__EntityId__c	 = account.Id);

        SVMXA360__CONF_TagElement__c tagElement2 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn2.Id,
                                                        SVMXA360__EntityId__c	 = account.Id);
        SVMXA360__CONF_TagElement__c tagElement3 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn3.Id,
                                                        SVMXA360__EntityId__c	 = account.Id);
                                                                                
        insert (new List<SVMXA360__CONF_TagElement__c>{tagElement1, tagElement2, tagElement3});

        List<String> tagsName = new List<String> {'testTag1', 'testTag2', 'testTag4', 'testTag5'};

        // tagDefn3 should be deleted

        ADM_TagHandler.getInstance().manageSVMXTags(account.Id, tagsName);

        List<SVMXA360__CONF_TagElement__c> tagEle3 = [SELECT ID FROM SVMXA360__CONF_TagElement__c WHERE SVMXA360__TagDefinition__r.Name = :'testTag3'];
        List<SVMXA360__CONF_TagElement__c> tagEle4 = [SELECT ID FROM SVMXA360__CONF_TagElement__c WHERE SVMXA360__TagDefinition__r.Name = :'testTag4'];
        List<SVMXA360__CONF_TagElement__c> tagEle5 = [SELECT ID FROM SVMXA360__CONF_TagElement__c WHERE SVMXA360__TagDefinition__r.Name = :'testTag5'];
        
        System.assertEquals(0, tagEle3.size(), 'tagEle3 should be deleted');
        System.assertEquals(1, tagEle4.size(), 'Tag Element for Tag Definition 3 should be created');
        System.assertEquals(1, tagEle5.size(), 'Tag Element and Tag Definition for teatTag5 should be created');
        
    }

    @isTest 
    static void testGetSVMXTags() {
        Account account1 = new Account(Name = 'Test_Account1');
        insert account1;

        Account account2 = new Account(Name = 'Test_Account2');
        insert account2;

        List<String> entityIdList = new List<String> { account1.Id, account2.Id };

        SVMXA360__CONF_TagDefinition__c tagDefn1 = new SVMXA360__CONF_TagDefinition__c(name='testTag1');
        SVMXA360__CONF_TagDefinition__c tagDefn2 = new SVMXA360__CONF_TagDefinition__c(name='testTag2');
        SVMXA360__CONF_TagDefinition__c tagDefn3 = new SVMXA360__CONF_TagDefinition__c(name='testTag3');
        SVMXA360__CONF_TagDefinition__c tagDefn4 = new SVMXA360__CONF_TagDefinition__c(name='testTag4');

        insert (new List<SVMXA360__CONF_TagDefinition__c>{tagDefn1, tagDefn2, tagDefn3, tagDefn4});
        
        SVMXA360__CONF_TagElement__c tagElement1 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn1.Id, 
                                                        SVMXA360__EntityId__c	 = entityIdList[0]);

        SVMXA360__CONF_TagElement__c tagElement2 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn2.Id,
                                                        SVMXA360__EntityId__c	 = entityIdList[0]);
        SVMXA360__CONF_TagElement__c tagElement3 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn3.Id,
                                                        SVMXA360__EntityId__c	 = entityIdList[1]);
        SVMXA360__CONF_TagElement__c tagElement4 = new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDefn4.Id,
                                                        SVMXA360__EntityId__c	 = entityIdList[1]);                                                                        
        insert (new List<SVMXA360__CONF_TagElement__c>{tagElement1, tagElement2, tagElement3, tagElement4});

        Map<String, List<String>> tagMap = ADM_TagHandler.getInstance().getSVMXTags(entityIdList);

        System.assertEquals(2, tagMap.get(entityIdList[0]).size());
        System.assertEquals(2, tagMap.get(entityIdList[1]).size());
        
    }

    @isTest 
    static void testGetAllTags() {

        SVMXA360__CONF_TagDefinition__c tagDefn1 = new SVMXA360__CONF_TagDefinition__c(name='testTag1');
        SVMXA360__CONF_TagDefinition__c tagDefn2 = new SVMXA360__CONF_TagDefinition__c(name='testTag2');
        SVMXA360__CONF_TagDefinition__c tagDefn3 = new SVMXA360__CONF_TagDefinition__c(name='testTag3');
        SVMXA360__CONF_TagDefinition__c tagDefn4 = new SVMXA360__CONF_TagDefinition__c(name='testTag4');

        insert (new List<SVMXA360__CONF_TagDefinition__c>{tagDefn1, tagDefn2, tagDefn3, tagDefn4});

        List<String> tagsName = ADM_TagHandler.getInstance().getAllTags();

        System.assertEquals(4, tagsName.size());
    }
}