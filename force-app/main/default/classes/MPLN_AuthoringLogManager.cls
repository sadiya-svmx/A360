/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This class facilitates methods to create/save MPLN Authoring object informations. 
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *  ID              Name                Date            Comment
 *****************************************************************************************************
 * A360AM-1036      Manish Kushwah      08 Sep 2021     Created.
 *****************************************************************************************************/
public with sharing class MPLN_AuthoringLogManager {

    /**
     * Private static variable to hold instance of this class.
     */
    private static MPLN_AuthoringLogManager instance;

    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private MPLN_AuthoringLogManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static MPLN_AuthoringLogManager getInstance() {
        
        System.debug(LoggingLevel.INFO, 'MPLN_AuthoringLogManager.getInstance() - enter');
        
        try {
            if(instance == null) {
                
                instance = new MPLN_AuthoringLogManager();
                System.debug(LoggingLevel.INFO, 'MPLN_AuthoringLogManager.getInstance() : Instance created successfully');
            }
        }
        finally {
            System.debug(LoggingLevel.INFO, 'MPLN_AuthoringLogManager.getInstance() - exit');
        }
        
        return instance;
    }

    public void createSuccessLog(SVMXA360__ApplicationEventBus__e event, MaintenancePlan maintenancePlan) {

        if (String.isNotBlank(event.SVMXA360__Payload__c)) {

            List<String> payLoadItems = event.SVMXA360__Payload__c.split(';');

            if (payLoadItems.size() == 2) {

                String templateId = payLoadItems[0];
                String parentLogRecordId = payLoadItems[1];

                /* sfge-disable-next-line ApexFlsViolationRule */
                List<SVMXA360__MPLNAuthoringLog__c> parentAuthoringLogList = SvmxDatabase.query([SELECT Id, SVMXA360__TotalBatchesCompleted__c, SVMXA360__Status__c FROM SVMXA360__MPLNAuthoringLog__c WHERE Id =: parentLogRecordId for update]);

                if ( !parentAuthoringLogList.isEmpty() ) {
                    parentAuthoringLogList[0].SVMXA360__TotalBatchesCompleted__c += 1;
        
                    // Create detail record
                    SVMXA360__MPLNAuthoringLog__c childAuthoringLogRecord = new SVMXA360__MPLNAuthoringLog__c();
                    childAuthoringLogRecord.SVMXA360__ParentMPLNAuthoringLogId__c = parentLogRecordId;
                    childAuthoringLogRecord.SVMXA360__ServiceContractId__c = event.SVMXA360__SourceRecordId__c;
                    childAuthoringLogRecord.SVMXA360__MaintenancePlanTemplateId__c = templateId;
                    childAuthoringLogRecord.SVMXA360__MaintenancePlanId__c = maintenancePlan.Id;
                    childAuthoringLogRecord.SVMXA360__UserId__c = event.SVMXA360__UserId__c;
                    childAuthoringLogRecord.SVMXA360__LogType__c = 'Detail';
                    childAuthoringLogRecord.SVMXA360__OperationType__c = 'Create';
                    childAuthoringLogRecord.SVMXA360__Status__c = 'Success';
                    childAuthoringLogRecord.SVMXA360__Message__c = 'Success';
                    parentAuthoringLogList.add(childAuthoringLogRecord);
                    SvmxDatabase.upsertRecord(parentAuthoringLogList);
                }
            }
        }
    }

    public void createFailureLog(SVMXA360__ApplicationEventBus__e event, String errorMessage) {

        if (String.isNotBlank(event.SVMXA360__Payload__c)) {

            List<String> payLoadItems = event.SVMXA360__Payload__c.split(';');

            if (payLoadItems.size() == 2) {

                String templateId = payLoadItems[0];
                String parentLogRecordId = payLoadItems[1];

                /* sfge-disable-next-line ApexFlsViolationRule */
                List<SVMXA360__MPLNAuthoringLog__c> parentAuthoringLogList = SvmxDatabase.query([SELECT Id, SVMXA360__TotalBatchesCompleted__c, SVMXA360__Status__c FROM SVMXA360__MPLNAuthoringLog__c WHERE Id =: parentLogRecordId for update]);

                if ( !parentAuthoringLogList.isEmpty() ) {
                    parentAuthoringLogList[0].SVMXA360__TotalBatchesCompleted__c += 1;
                    parentAuthoringLogList[0].SVMXA360__Status__c = 'Failed';

                    // Create detail record
                    SVMXA360__MPLNAuthoringLog__c childAuthoringLogRecord = new SVMXA360__MPLNAuthoringLog__c();
                    childAuthoringLogRecord.SVMXA360__ParentMPLNAuthoringLogId__c = parentLogRecordId;
                    childAuthoringLogRecord.SVMXA360__ServiceContractId__c = event.SVMXA360__SourceRecordId__c;
                    childAuthoringLogRecord.SVMXA360__MaintenancePlanTemplateId__c = templateId;
                    childAuthoringLogRecord.SVMXA360__UserId__c = event.SVMXA360__UserId__c;
                    childAuthoringLogRecord.SVMXA360__LogType__c = 'Detail';
                    childAuthoringLogRecord.SVMXA360__OperationType__c = 'Create';
                    childAuthoringLogRecord.SVMXA360__Status__c = 'Failed';
                    childAuthoringLogRecord.SVMXA360__Message__c = errorMessage;
                    parentAuthoringLogList.add(childAuthoringLogRecord);
                    SvmxDatabase.upsertRecord(parentAuthoringLogList);
                }
            }
        }
    }
}