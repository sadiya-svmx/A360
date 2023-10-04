@IsTest
public class UserGroupMemberTriggerHandler_UT {
    
    static testmethod void testUserGroupCreation() {

        Test.startTest();

        //User Group Record
        SVMXA360__CONF_UserGroup__c userGroupRecord = 
        (SVMXA360__CONF_UserGroup__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_UserGroup__c', new Map<String,Object>{'Name' => 'Test Class Users',
                                                                                                                               'SVMXA360__DeveloperName__c' => 'Test_Class_Users',
                                                                                                                               'SVMXA360__Description__c' => 'Test Purpose'});
        SVMXA360__CONF_UserGroupMember__c userGroupMemberRecord = 
        (SVMXA360__CONF_UserGroupMember__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_UserGroupMember__c', new Map<String,Object>{'SVMXA360__UserId__c' => UserInfo.getUserId(),
                                                                                                                               'SVMXA360__UserGroupId__c' => userGroupRecord.Id});
        System.assert(userGroupMemberRecord.SVMXA360__UserGroupId__c == userGroupRecord.Id);
        
        Test.stopTest();
    }

    static testmethod void testNullUser_Insert() {
        
        Test.startTest();
        
        //User Group Record
        SVMXA360__CONF_UserGroup__c userGroupRecord = 
        (SVMXA360__CONF_UserGroup__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_UserGroup__c', new Map<String,Object>{'Name' => 'Test Internal Class Users',
                                                                                                                               'SVMXA360__DeveloperName__c' => 'Test_Class_Internal_Users',
                                                                                                                               'SVMXA360__Description__c' => 'Test Purpose'});
        
        
        try{
            //Create User Group Member record without User 
            SVMXA360__CONF_UserGroupMember__c userGroupMemberRecord = 
        (SVMXA360__CONF_UserGroupMember__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_UserGroupMember__c', new Map<String,Object>{'SVMXA360__UserId__c' => null,
                                                                                                                               'SVMXA360__UserGroupId__c' => userGroupRecord.Id});
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
        }
        Test.stopTest();
    }
}