/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a trigger handler class for the Service_Contract_Trigger. 
 *
 * @author Hemant Keni
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *  A360CE-337 Hemant Keni      	03 Feb 2021     Created.
 *****************************************************************************************************/
public with sharing class EVER_EntitledServiceTriggerHandler {


    /**
     * This method is used to retrieve validate the updated Service Contracts Start/End dates should cover the related Contract Line Items start and end date.
     *
     * @param newMap Trigger.newMap - Updated map of Service contracts.
     * @param oldMap Trigger.oldMap - Old map of Service contracts.
     * @return void.
     *
     */
    public static void validateStartAndEndDate( Map<Id, ServiceContract> newMap, Map<Id, ServiceContract> oldMap ){

        System.debug(LoggingLevel.DEBUG, 'EVER_EntitledServiceTriggerHandler.validateStartAndEndDate - Enter');

        List<ServiceContract> changedContractList = getStartEndDateChangedContracts(newMap.Values(), oldMap);

        if(!changedContractList.isEmpty()){
            List<Id> changedContractIdList = new List<Id>();

            for(ServiceContract changedContract : changedContractList){
                changedContractIdList.add(changedContract.Id);
            }

            List<AggregateResult> groupedCLIResultList;
            
            try {
                groupedCLIResultList = [Select ServiceContractId, Min(StartDate), Max(EndDate) FROM ContractLineItem WHERE ServiceContractId IN : changedContractIdList WITH SECURITY_ENFORCED GROUP BY ServiceContractId];
            } catch(QueryException ex){
                throw new SvmxSystem.SvmxNestedException(ErrorMessage.RESTRICTED_ACCESS + ContractLineItem.getSObjectType().getDescribe().getName());
            }
            
            System.debug(LoggingLevel.DEBUG, 'groupedCLIResultList : '+ groupedCLIResultList);

            if( groupedCLIResultList != null && !groupedCLIResultList.isEmpty() ){
                for( AggregateResult groupedCLIResult : groupedCLIResultList ){

                    Id serviceContractId = (Id) groupedCLIResult.get('ServiceContractId');
                    ServiceContract updatedServiceContract = newMap.get(serviceContractId);
                    Date minStartDate = (Date) groupedCLIResult.get('expr0');
                    Date maxEndDate = (Date) groupedCLIResult.get('expr1');

                    if( updatedServiceContract != null && ((updatedServiceContract.startDate == null || (minStartDate != null && updatedServiceContract.startDate != null && updatedServiceContract.startDate > minStartDate)) 
                        || (updatedServiceContract.EndDate == null || (maxEndDate != null && updatedServiceContract.EndDate != null && updatedServiceContract.EndDate < maxEndDate))) ){
                            updatedServiceContract.addError(Label.Error_CLI_Outside_Specified_Dates);
                    }
                }
            }
        }

        System.debug(LoggingLevel.DEBUG, 'EVER_EntitledServiceTriggerHandler.validateStartAndEndDate - Exit');
    }

    /**
     * This method is used to retrieve validate the updated Service Contracts Start/End dates should cover the related Contract Line Items start and end date.
     * 
     * @param newList Trigger.new - Updated list of Service contracts.
     * @param oldMap Trigger.oldMap - Old map of Service contracts.
     * 
     * @return List<ServiceContract> - List of ServiceContract whose start or end date is changed.
     *
     */
    private static List<ServiceContract> getStartEndDateChangedContracts( List<ServiceContract> newList, Map<Id, ServiceContract> oldMap ){

        System.debug(LoggingLevel.DEBUG, 'EVER_EntitledServiceTriggerHandler.getStartEndDateChangedContracts - Enter');

        List<ServiceContract> changedContractList = new List<ServiceContract>();

        if(oldMap != null && !oldMap.isEmpty() && newList != null && !newList.isEmpty()){
            for(ServiceContract newContract : newList){
                ServiceContract oldContract = oldMap.get(newContract.Id);
                if(oldContract != null &&
                    ( oldContract.StartDate != newContract.StartDate || oldContract.EndDate != newContract.EndDate)){
                    changedContractList.add(newContract);
                }
            }
        }

        System.debug(LoggingLevel.DEBUG, 'changedContractList : '+ changedContractList);
        System.debug(LoggingLevel.DEBUG, 'EVER_EntitledServiceTriggerHandler.getStartEndDateChangedContracts - Enter');

        return changedContractList;
    }
}