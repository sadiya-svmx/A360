/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 * @brief Test batch class to clean up recent items if records more than 10 per user.
 *
 * @author Jyothsna Nagapudi
 * @version Sum 22
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jyothsna Nagapudi      14 Mar 2022     Created.
 *****************************************************************************************************/
@isTest
public class ADM_RecentItemsBatch_UT {
    static testmethod void recentItemsCleanUpTest() {
        List<SVMXA360__CONF_ObjectMapping__c> objectMappingList = new List<SVMXA360__CONF_ObjectMapping__c>();
        List<SVMXA360__COMM_Recentitem__c> recentItemList = new List<SVMXA360__COMM_Recentitem__c>();
        // Create test recent items
       for (Integer i=0; i<200; i++) {
            SVMXA360__CONF_ObjectMapping__c objectMappingRecord = new SVMXA360__CONF_ObjectMapping__c(SVMXA360__SourceObjectAPIName__c = 'Case',
                                                                                    SVMXA360__TargetObjectAPIName__c = 'WorkOrder',
                                                                                    Name = 'Test Mapping' + i,
                                                                                    SVMXA360__DeveloperName__c = 'MAP00' + i,
                                                                                    SVMXA360__Type__c = 'Field Mapping');
            objectMappingList.add(objectMappingRecord);
            
        }
        insert objectMappingList;
        
        for (Integer i=0; i<200; i++) {
            SVMXA360__COMM_Recentitem__c mappingRecentItemRecord = new SVMXA360__COMM_Recentitem__c(SVMXA360__AdminConfigurationName__c = objectMappingList.get(i).Name,
                                                                                        SVMXA360__ConfigurationDeveloperName__c = objectMappingList.get(i).SVMXA360__DeveloperName__c,
                                                                                        SVMXA360__ConfigurationId__c = objectMappingList.get(i).Id,
                                                                                        SVMXA360__ConfigurationType__c = 'Mapping');
            recentItemList.add(mappingRecentItemRecord);
            
        }
        insert recentItemList;
     
        Test.startTest();
        ADM_RecentItemsBatch cleanUpBatch = new ADM_RecentItemsBatch();
        Database.executeBatch(cleanUpBatch);
        Test.stopTest();
        // Verify recent items clean up
        SVMXA360__COMM_Recentitem__c[] itemsList = [SELECT Id, SVMXA360__ConfigurationDeveloperName__c, Name FROM SVMXA360__COMM_Recentitem__c WHERE lastModifiedById = :UserInfo.getUserId()];
        System.debug('Size:' + itemsList.size());
        System.assert(itemsList != null);
        System.assert(itemsList.get(0).SVMXA360__ConfigurationDeveloperName__c.contains('MAP'));
    }
}