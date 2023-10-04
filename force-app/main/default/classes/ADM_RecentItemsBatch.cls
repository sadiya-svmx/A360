/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/
/**
 * @brief The batch to clean up recent items if records more than 10 per user.
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
public without sharing class ADM_RecentItemsBatch implements Database.Batchable<sObject> {
    
    public List<SVMXA360__COMM_Recentitem__c> start(Database.BatchableContext bc) {
        List<SVMXA360__COMM_Recentitem__c> recentItemsList = new List<SVMXA360__COMM_Recentitem__c>();
        List<SVMXA360__COMM_Recentitem__c> recentItemsToDeleted = new List<SVMXA360__COMM_Recentitem__c>();
        List<AggregateResult> groupedResults = [SELECT lastModifiedById,Id FROM SVMXA360__COMM_Recentitem__c Group by lastModifiedById,Id order by MAX(lastModifiedDate) DESC];
        
        Map<String, List<SVMXA360__COMM_Recentitem__c>> recentItemsByUser = new Map<String, List<SVMXA360__COMM_Recentitem__c>>();
      
        for(AggregateResult result : groupedResults) {
            SVMXA360__COMM_Recentitem__c recentItem = new SVMXA360__COMM_Recentitem__c();
            String idString = (Id) result.get('Id');
            String modifyId = (Id) result.get('lastModifiedById'); 
            
            recentItem.Id = idString;
            
            if(recentItemsByUser.containsKey(modifyId)) {
               recentItemsByUser.get(modifyId).add(recentItem); 
            } else {
               recentItemsByUser.put(modifyId, new List<SVMXA360__COMM_Recentitem__c>{recentItem});
            }
		}
        
        for(String userId: recentItemsByUser.keySet()) {
            Integer i = 0;
            while(i < 10 && !(recentItemsByUser.get(userId)).isEmpty()) {
            	recentItemsByUser.get(userId).remove(0); 
                i++;
            }
            recentItemsToDeleted.addAll(recentItemsByUser.get(userId));
		}
        return recentItemsToDeleted;
    }

    public void execute(Database.BatchableContext bc, List<SVMXA360__COMM_Recentitem__c> recentItemList) {
        Savepoint sp = Database.setSavePoint();
        try{
            if(recentItemList.size() > 0) {
            	SvmxDatabase.deleteRecord(recentItemList);   
            }
        }catch(DMLException e) {   
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'delete RecentItem : Failed to delete recentItemInfo. Error= ' + e.getMessage());
            throw e;
        }catch( Exception e ) {
            Database.rollback( sp );
            System.debug( LoggingLevel.ERROR, 'delete RecentItem  : Failed to delete recentItemInfo. Error= ' + e.getStackTraceString() );
            throw e;
        } 
    }

    public void finish( Database.BatchableContext bc ) {

    }

}