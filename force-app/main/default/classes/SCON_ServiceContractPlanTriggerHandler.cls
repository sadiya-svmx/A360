/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class prevents user to create duplicate plans. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *             Karthick Saravanan       01 Apr 2021     Created.
 *****************************************************************************************************/
public with sharing class SCON_ServiceContractPlanTriggerHandler {
    
    public static void preventDuplicateCPLIPlan(List<SVMXA360__ContractPriceLineItemPlan__c> newList,map<Id, SVMXA360__ContractPriceLineItemPlan__c> oldMap){
        
        System.debug( LoggingLevel.INFO, 'preventDuplicateCPLIPlan() enter - newList: ' + newList);
        System.debug( LoggingLevel.INFO, 'preventDuplicateCPLIPlan() enter - oldMap: ' + oldMap);
        
        Map<CPLIPlanUniqueKey, List<SVMXA360__ContractPriceLineItemPlan__c>> cpliPlanUniqueMap = new Map<CPLIPlanUniqueKey, List<SVMXA360__ContractPriceLineItemPlan__c>>();
        Set<String> uniqueKeySet = new Set<String>();

        try {           
            for(SVMXA360__ContractPriceLineItemPlan__c newCPLIPlan : newList){
                validatePricingFields(newCPLIPlan);
                CPLIPlanUniqueKey key = new CPLIPlanUniqueKey(newCPLIPlan);
                populateCPLIPlanUniqueKey(newCPLIPlan);            
                if (String.isNotBlank(newCPLIPlan.SVMXA360__UniqueKey__c) && (oldMap==null || 
                    newCPLIPlan.SVMXA360__UniqueKey__c != oldMap.get(newCPLIPlan.Id).SVMXA360__UniqueKey__c || 
                    newCPLIPlan.SVMXA360__EntitledPrice__c != oldMap.get(newCPLIPlan.Id).SVMXA360__EntitledPrice__c )) { 
                    
                    if (!uniqueKeySet.contains(newCPLIPlan.SVMXA360__UniqueKey__c)) {
                        //Handle new list of cpli plans are not duplicate
                        uniqueKeySet.add(newCPLIPlan.SVMXA360__UniqueKey__c);                        
                        if (cpliPlanUniqueMap.containskey(key)) {                       
                            cpliPlanUniqueMap.get(key).add(newCPLIPlan);
                        }else {
                            List<SVMXA360__ContractPriceLineItemPlan__c> cpliPlanList = new List<SVMXA360__ContractPriceLineItemPlan__c>();
                            cpliPlanList.add(newCPLIPlan);
                            cpliPlanUniqueMap.put(key, cpliPlanList);
                        }
                    }else {
                        newCPLIPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                    }                    
                }
            }

            if(cpliPlanUniqueMap == null || cpliPlanUniqueMap.size() == 0){
                return;
            }
            List<String> keyList = new List<String>();
            for(CPLIPlanUniqueKey key:cpliPlanUniqueMap.KeySet()) {
                keyList.add(key.tostring());
            }

            String recordQuery ='SELECT Id,Name,SVMXA360__ServiceContractPlanId__c,SVMXA360__ContractLineItemPlanId__c,SVMXA360__EntitledServicePlanId__c,SVMXA360__ProductId__c,SVMXA360__ProductFamily__c,SVMXA360__ExpenseItem__c,SVMXA360__LineType__c,SVMXA360__UniqueKey__c,SVMXA360__EntitledPrice__c,SVMXA360__EntitledDiscount__c,SVMXA360__Surcharge__c ';
            if(UserInfo.isMultiCurrencyOrganization()) {
                recordQuery +=',CurrencyIsoCode ';
            }
            recordQuery += 'FROM SVMXA360__ContractPriceLineItemPlan__c';
            System.debug(LoggingLevel.DEBUG, 'preventDuplicateCPLIPlan() : keyList.size: ' + keyList.size());
            
            String whereClause = '';
            if (keyList.size() > 0) {
                whereClause+=' WHERE';
                for (Integer index=0;index< keyList.size();index++){ 
                    whereClause+= ' ( '+keyList[index]+' )';                   
                    if(index != keyList.size()-1){
                        whereClause+=' OR ';
                    }
                }
            }        
            recordQuery+=whereClause;
            System.debug(LoggingLevel.INFO, 'preventDuplicateCPLIPlan() :query for RecordList is :'+recordQuery);        
            
            List<SVMXA360__ContractPriceLineItemPlan__c> existCpliPlanList = (List<SVMXA360__ContractPriceLineItemPlan__c>) SvmxDatabase.query(recordQuery);
            
            if (existCpliPlanList == null || existCpliPlanList.size() == 0) {
                return;
            }
            
            validateUniquenessCheck(cpliPlanUniqueMap,existCpliPlanList,oldMap);
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDuplicateCPLIPlan() : Failed to validate uniqueness check on cpli records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'preventDuplicateCPLIPlan() - exit');
        }    
    }

    public void preventDuplicateESPlan(List<SVMXA360__EntitledServicePlan__c> newList, Map<Id, SVMXA360__EntitledServicePlan__c> oldMap){
        
        System.debug( LoggingLevel.INFO, 'preventDuplicateESPlan() enter - newList: ' + newList);

        try {
            Set<String> setUniqueKey = new Set<String>();
            Set<String> lstContractIds = new Set<String>();
            Set<String> lstContractLineItemIds = new Set<String>();
            Set<String> lstEntitledProductIds = new Set<String>();

            for (SVMXA360__EntitledServicePlan__c eachESPlan : newList) {
                populateESPlanUniqueKey(eachESPlan);
                if (oldMap == null || (oldMap != null && eachESPlan.SVMXA360__UniqueKey__c != oldMap.get(eachESPlan.Id).SVMXA360__UniqueKey__c)) {
                    if (!setUniqueKey.contains(eachESPlan.SVMXA360__UniqueKey__c)) {
                        setUniqueKey.add(eachESPlan.SVMXA360__UniqueKey__c);
                        lstContractIds.add(eachESPlan.SVMXA360__ServiceContractPlanId__c);
                        lstContractLineItemIds.add(eachESPlan.SVMXA360__ContractLineItemPlanId__c);
                        lstEntitledProductIds.add(eachESPlan.SVMXA360__EntitledServiceProductId__c);
                    } else {
                        eachESPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                    }
                }
            }
            String soqlESPlan = 'SELECT Id,SVMXA360__ServiceContractPlanId__c,SVMXA360__ContractLineItemPlanId__c,SVMXA360__EntitledServiceProductId__c,SVMXA360__UniqueKey__c ';
            soqlESPlan += ' FROM SVMXA360__EntitledServicePlan__c';
            soqlESPlan += ' WHERE SVMXA360__ServiceContractPlanId__c IN :lstContractIds AND SVMXA360__ContractLineItemPlanId__c IN: lstContractLineItemIds AND SVMXA360__EntitledServiceProductId__c IN: lstEntitledProductIds';
            System.debug(LoggingLevel.INFO, 'preventDuplicateESPlan() :query for ES Plan records is : ' + soqlESPlan);
            
            List<SVMXA360__EntitledServicePlan__c> existingESPlans = (List<SVMXA360__EntitledServicePlan__c>) SvmxDatabase.query(Database.query(soqlESPlan));
            
            System.debug( LoggingLevel.INFO, 'preventDuplicateESPlan() - existingESPlans queried are : ' + existingESPlans.size());
            
            if (existingESPlans == null || existingESPlans.isEmpty()) {
                return;
            }
            
            validateESUniqueness(newList, existingESPlans, oldMap);
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDuplicateESPlan() : Failed to validate uniqueness check on ES records. Error = ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.INFO, 'preventDuplicateESPlan() - exit');
        }
    }

    public void preventDuplicateCLIPlan(List<SVMXA360__ContractLineItemPlan__c> newList, Map<Id, SVMXA360__ContractLineItemPlan__c> oldMap){
        
        System.debug( LoggingLevel.INFO, 'preventDuplicateCLIPlan() enter - newList: ' + newList);

        try {
            Set<String> setUniqueKey = new Set<String>();
            Set<String> lstContractIds = new Set<String>();
            Set<String> lstProductIds = new Set<String>();
            Set<String> lstProductFamily = new Set<String>();

            for (SVMXA360__ContractLineItemPlan__c eachCLIPlan : newList) {
                validateCLIPlanFields(eachCLIPlan);
                populateCLIPlanUniqueKey(eachCLIPlan);
                if (oldMap == null || (oldMap != null && eachCLIPlan.SVMXA360__UniqueKey__c != oldMap.get(eachCLIPlan.Id).SVMXA360__UniqueKey__c)) {
                    if (!setUniqueKey.contains(eachCLIPlan.SVMXA360__UniqueKey__c)) {
                        setUniqueKey.add(eachCLIPlan.SVMXA360__UniqueKey__c);
                        lstContractIds.add(eachCLIPlan.SVMXA360__ServiceContractPlanId__c);
                        lstProductIds.add(eachCLIPlan.SVMXA360__ProductId__c);
                        lstProductFamily.add(eachCLIPlan.SVMXA360__ProductFamily__c);
                    } else {
                        eachCLIPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                    }
                }
            }
            String soqlCLIPlan = 'SELECT Id,SVMXA360__ServiceContractPlanId__c,SVMXA360__ProductId__c,SVMXA360__ProductFamily__c ';
            soqlCLIPlan += ' FROM SVMXA360__ContractLineItemPlan__c';
            soqlCLIPlan += ' WHERE SVMXA360__ServiceContractPlanId__c IN :lstContractIds AND SVMXA360__ProductId__c IN: lstProductIds AND SVMXA360__ProductFamily__c IN: lstProductFamily';
            System.debug(LoggingLevel.INFO, 'preventDuplicateCLIPlan() :query for CLI Plan records is : ' + soqlCLIPlan);
            
            List<SVMXA360__ContractLineItemPlan__c> existingCLIPlans = (List<SVMXA360__ContractLineItemPlan__c>) SvmxDatabase.query(Database.query(soqlCLIPlan));
            
            System.debug( LoggingLevel.INFO, 'preventDuplicateCLIPlan() - existingCLIPlans queried are : ' + existingCLIPlans.size());
            
            if (existingCLIPlans == null || existingCLIPlans.isEmpty()) {
                return;
            }
            
            validateCLIUniqueness(newList, existingCLIPlans);
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDuplicateCLIPlan() : Failed to validate uniqueness check on ES records. Error = ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.INFO, 'preventDuplicateCLIPlan() - exit');
        }
    }

    public void validateCLIUniqueness(List<SVMXA360__ContractLineItemPlan__c> newList, List<SVMXA360__ContractLineItemPlan__c> existingCLIPlans) {
        System.debug( LoggingLevel.INFO, 'validateCLIUniqueness() enter');
        for (SVMXA360__ContractLineItemPlan__c eachNewCLIPlan : newList) {
            for (SVMXA360__ContractLineItemPlan__c eachExistingCLIPlan : existingCLIPlans) {
                if (eachNewCLIPlan.SVMXA360__ServiceContractPlanId__c == eachExistingCLIPlan.SVMXA360__ServiceContractPlanId__c
                && eachNewCLIPlan.SVMXA360__ProductId__c == eachExistingCLIPlan.SVMXA360__ProductId__c
                && eachNewCLIPlan.SVMXA360__ProductFamily__c == eachExistingCLIPlan.SVMXA360__ProductFamily__c
                ) {
                    eachNewCLIPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                }
            }
        }
        System.debug( LoggingLevel.INFO, 'validateCLIUniqueness() - exit');
    }

    public void validateESUniqueness(List<SVMXA360__EntitledServicePlan__c> newList, List<SVMXA360__EntitledServicePlan__c> existingESPlans, Map<Id, SVMXA360__EntitledServicePlan__c> oldMap) {
        System.debug( LoggingLevel.INFO, 'validateESUniqueness() enter');
        for (SVMXA360__EntitledServicePlan__c eachNewESPlan : newList) {
            for (SVMXA360__EntitledServicePlan__c eachExistingESPlan : existingESPlans) {
                if (eachNewESPlan.SVMXA360__ServiceContractPlanId__c == eachExistingESPlan.SVMXA360__ServiceContractPlanId__c
                && eachNewESPlan.SVMXA360__ContractLineItemPlanId__c == eachExistingESPlan.SVMXA360__ContractLineItemPlanId__c
                && eachNewESPlan.SVMXA360__EntitledServiceProductId__c == eachExistingESPlan.SVMXA360__EntitledServiceProductId__c) {
                    eachNewESPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                }
            }
        }
        System.debug( LoggingLevel.INFO, 'validateESUniqueness() - exit');
    }

    
    private static void validateUniquenessCheck(Map<CPLIPlanUniqueKey, List<SVMXA360__ContractPriceLineItemPlan__c>> cpliPlanUniqueMap, List<SVMXA360__ContractPriceLineItemPlan__c> existCpliPlanList, Map<Id, SVMXA360__ContractPriceLineItemPlan__c> oldMap) {
        
        System.debug( LoggingLevel.DEBUG, 'validateUniquenessCheck() enter - cpliPlanUniqueMap: ' + cpliPlanUniqueMap);
        for(SVMXA360__ContractPriceLineItemPlan__c record: existCpliPlanList) {
            if (oldMap== null || !oldMap.containskey(record.Id)){
                
                CPLIPlanUniqueKey key = new CPLIPlanUniqueKey(record);
                if(cpliPlanUniqueMap.containskey(key)) {
                    List<SVMXA360__ContractPriceLineItemPlan__c> newCPLIPlanList = cpliPlanUniqueMap.get(key);

                    for(SVMXA360__ContractPriceLineItemPlan__c newCPLIPlan: newCPLIPlanList) {
                        
                        if(UserInfo.isMultiCurrencyOrganization() &&  newCPLIPlan.SVMXA360__EntitledPrice__c!=null && record.SVMXA360__EntitledPrice__c!=null) {
                            //Price field check
                            String existCPLIPlanCurrencyCode = String.valueOf(record.get('CurrencyIsoCode'));
                            String newCPLIPlanCurrencyCode = String.valueOf(newCPLIPlan.get('CurrencyIsoCode'));
                            if( newCPLIPlanCurrencyCode == existCPLIPlanCurrencyCode ){
                                newCPLIPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                            }
                        } else {
                            //For discount and currency fields.
                            newCPLIPlan.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                        }
                    }
                } 
            }
        }
        System.debug( LoggingLevel.DEBUG, 'validateUniquenessCheck() - exit');
    }
    
    private static void validatePricingFields(SVMXA360__ContractPriceLineItemPlan__c objCPLIPlan) {
        
        if( ( objCPLIPlan.SVMXA360__EntitledPrice__c != null && (objCPLIPlan.SVMXA360__EntitledDiscount__c != null || objCPLIPlan.SVMXA360__Surcharge__c != null)) ||
            ( objCPLIPlan.SVMXA360__EntitledDiscount__c != null && (objCPLIPlan.SVMXA360__EntitledPrice__c != null || objCPLIPlan.SVMXA360__Surcharge__c != null)) || 
            ( objCPLIPlan.SVMXA360__Surcharge__c != null && (objCPLIPlan.SVMXA360__EntitledPrice__c != null || objCPLIPlan.SVMXA360__EntitledDiscount__c != null)) || 
            ( objCPLIPlan.SVMXA360__EntitledPrice__c == null && objCPLIPlan.SVMXA360__EntitledDiscount__c == null && objCPLIPlan.SVMXA360__Surcharge__c == null) ) {
            
            objCPLIPlan.addError(Label.Label_CPLI_Pricing_Error);                
        }
    }
    
    private static void populateCPLIPlanUniqueKey(SVMXA360__ContractPriceLineItemPlan__c contractPriceLineItemPlan) {

        String uniqueKeyString = contractPriceLineItemPlan.SVMXA360__ServiceContractPlanId__c;
        
        if( String.isNotBlank( contractPriceLineItemPlan.SVMXA360__ContractLineItemPlanId__c ) ) {
            uniqueKeyString += contractPriceLineItemPlan.SVMXA360__ContractLineItemPlanId__c;
        }        
        if( String.isNotBlank( contractPriceLineItemPlan.SVMXA360__EntitledServicePlanId__c ) ) {
            uniqueKeyString += contractPriceLineItemPlan.SVMXA360__EntitledServicePlanId__c;
        }

        if( String.isNotBlank( contractPriceLineItemPlan.SVMXA360__ProductId__c ) ) {
            uniqueKeyString += contractPriceLineItemPlan.SVMXA360__ProductId__c;
        } else if( String.isNotBlank( contractPriceLineItemPlan.SVMXA360__ProductFamily__c ) ) {
            uniqueKeyString += contractPriceLineItemPlan.SVMXA360__ProductFamily__c;
        }
        
        if( String.isNotBlank( contractPriceLineItemPlan.SVMXA360__ExpenseItem__c ) ) {
            uniqueKeyString += contractPriceLineItemPlan.SVMXA360__ExpenseItem__c;
        }
        if(String.isNotBlank(contractPriceLineItemPlan.SVMXA360__LineType__c)){
            uniqueKeyString += contractPriceLineItemPlan.SVMXA360__LineType__c;
        }

        if(UserInfo.isMultiCurrencyOrganization() ) {
            String currencyCode = String.valueOf(contractPriceLineItemPlan.get('CurrencyIsoCode'));
            uniqueKeyString += String.isNotBlank(currencyCode) ? currencyCode :'';
        }
        
        contractPriceLineItemPlan.SVMXA360__UniqueKey__c = uniqueKeyString;        
    }

    private static void populateESPlanUniqueKey(SVMXA360__EntitledServicePlan__c entitledServicePlan) {

        String uniqueKeyString = entitledServicePlan.SVMXA360__ServiceContractPlanId__c;
        
        if( String.isNotBlank( entitledServicePlan.SVMXA360__ContractLineItemPlanId__c ) ) {
            uniqueKeyString += entitledServicePlan.SVMXA360__ContractLineItemPlanId__c;
        }        
        if( String.isNotBlank( entitledServicePlan.SVMXA360__EntitledServiceProductId__c ) ) {
            uniqueKeyString += entitledServicePlan.SVMXA360__EntitledServiceProductId__c;
        }

        entitledServicePlan.SVMXA360__UniqueKey__c = uniqueKeyString;        
    }

    private static void populateCLIPlanUniqueKey(SVMXA360__ContractLineItemPlan__c contractLineItemPlan) {

        String uniqueKeyString = contractLineItemPlan.SVMXA360__ServiceContractPlanId__c;
        
        if( String.isNotBlank( contractLineItemPlan.SVMXA360__ProductId__c ) ) {
            uniqueKeyString += contractLineItemPlan.SVMXA360__ProductId__c;
        }        
        if( String.isNotBlank( contractLineItemPlan.SVMXA360__ProductFamily__c ) ) {
            uniqueKeyString += contractLineItemPlan.SVMXA360__ProductFamily__c;
        }

        contractLineItemPlan.SVMXA360__UniqueKey__c = uniqueKeyString;        
    }

    private void validateCLIPlanFields(SVMXA360__ContractLineItemPlan__c cliPlan) {

        if ( (cliPlan.SVMXA360__ProductId__c != null && cliPlan.SVMXA360__ProductFamily__c != null) || 
             (cliPlan.SVMXA360__ProductId__c == null && cliPlan.SVMXA360__ProductFamily__c == null) ) {
                cliPlan.addError(Label.Error_CLIPlan_Validation_For_Fields);  
        }
    }

    //Wrapper class to prepare the uniquekey for CPLI Plan record
    class CPLIPlanUniqueKey {
        
        SVMXA360__ContractPriceLineItemPlan__c objCPLIPlan = new SVMXA360__ContractPriceLineItemPlan__c();
        
        CPLIPlanUniqueKey(SVMXA360__ContractPriceLineItemPlan__c cpliPlanRecord) {
            this.objCPLIPlan = cpliPlanRecord;
        }
        
        integer hashCode() {
            return toString().hashCode();
        }

        boolean equals(Object o) {
            return toString() == ((CPLIPlanUniqueKey)o).toString();
        }

        public override string toString() {
            
            String uniqueStr = String.format(
                'SVMXA360__ServiceContractPlanId__c = \'\'{0}\'\' AND SVMXA360__ContractLineItemPlanId__c = \'\'{1}\'\' AND SVMXA360__EntitledServicePlanId__c = \'\'{2}\'\' AND SVMXA360__ProductId__c = \'\'{3}\'\' AND SVMXA360__ProductFamily__c = \'\'{4}\'\' AND SVMXA360__ExpenseItem__c = \'\'{5}\'\' AND  SVMXA360__LineType__c = \'\'{6}\'\'',
                new String[] {
                    objCPLIPlan.SVMXA360__ServiceContractPlanId__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__ServiceContractPlanId__c),
                    objCPLIPlan.SVMXA360__ContractLineItemPlanId__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__ContractLineItemPlanId__c),
                    objCPLIPlan.SVMXA360__EntitledServicePlanId__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__EntitledServicePlanId__c),
                    objCPLIPlan.SVMXA360__ProductId__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__ProductId__c),
                    objCPLIPlan.SVMXA360__ProductFamily__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__ProductFamily__c),
                    objCPLIPlan.SVMXA360__ExpenseItem__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__ExpenseItem__c),
                    objCPLIPlan.SVMXA360__LineType__c==null?'':String.escapeSingleQuotes(objCPLIPlan.SVMXA360__LineType__c)
                }
            );            
            return uniqueStr ;
        }
    }

    public void validateDurationOfContractPlan(List<SVMXA360__ServiceContractPlan__c> newList, Map<Id, SVMXA360__ServiceContractPlan__c> oldMap){
        System.debug( LoggingLevel.INFO, 'validateDurationOfContractPlan() enter - newList: ' + newList);
        System.debug( LoggingLevel.INFO, 'validateDurationOfContractPlan() enter - oldMap: ' + oldMap);
        
        try {

            Map<Id, SVMXA360__ServiceContractPlan__c> changedSCPlanMap = getDurationChangedContractPlans(newList,oldMap);
            
            if(changedSCPlanMap == null || changedSCPlanMap.isEmpty()) {
                return;
            }
            
            Map<Id, List<SVMXA360__ContractLineItemPlan__c>> relatedCliPlansMap = new Map<Id, List<SVMXA360__ContractLineItemPlan__c>>();            
            for(SVMXA360__ContractLineItemPlan__c eachCliPlan : (List<SVMXA360__ContractLineItemPlan__c>) SvmxDatabase.query([Select Id, SVMXA360__ServiceContractPlanId__c, SVMXA360__ContractLineUnitOfTime__c, SVMXA360__ContractLineDuration__c FROM SVMXA360__ContractLineItemPlan__c Where  SVMXA360__ServiceContractPlanId__c IN:changedSCPlanMap.keySet()])) {
                if( !relatedCliPlansMap.containsKey(eachCliPlan.SVMXA360__ServiceContractPlanId__c) ) {
                    relatedCliPlansMap.put( eachCliPlan.SVMXA360__ServiceContractPlanId__c, new List<SVMXA360__ContractLineItemPlan__c>() );
                }
                relatedCliPlansMap.get(eachCliPlan.SVMXA360__ServiceContractPlanId__c).add(eachCliPlan);
            }
            
            Map<Id, List<SVMXA360__EntitledServicePlan__c>> relatedESPlansMap = new Map<Id, List<SVMXA360__EntitledServicePlan__c>>();
            for(SVMXA360__EntitledServicePlan__c eachESPlan : (List<SVMXA360__EntitledServicePlan__c>) SvmxDatabase.query([Select Id, SVMXA360__ServiceContractPlanId__c, SVMXA360__EntitledServiceUnitOfTime__c, SVMXA360__EntitledServiceDuration__c FROM SVMXA360__EntitledServicePlan__c Where  SVMXA360__ServiceContractPlanId__c IN:changedSCPlanMap.keySet()])) {
                
                if( !relatedESPlansMap.containsKey(eachESPlan.SVMXA360__ServiceContractPlanId__c) ) {
                    relatedESPlansMap.put( eachESPlan.SVMXA360__ServiceContractPlanId__c, new List<SVMXA360__EntitledServicePlan__c>() );
                }
                relatedESPlansMap.get(eachESPlan.SVMXA360__ServiceContractPlanId__c).add(eachESPlan);
            }
            
            if ( relatedCliPlansMap.isEmpty() && relatedESPlansMap.isEmpty()) {
                return;
            }

            checkContractPlanDuration(changedSCPlanMap.values(),relatedCliPlansMap,relatedESPlansMap);

        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'validateDurationOfContractPlan() : Failed to validate duration check on cli plan records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateDurationOfContractPlan() - exit');
        }
    }

    private static Map<Id,SVMXA360__ServiceContractPlan__c> getDurationChangedContractPlans( List<SVMXA360__ServiceContractPlan__c> newList, Map<Id, SVMXA360__ServiceContractPlan__c> oldMap ){

        System.debug(LoggingLevel.DEBUG, 'getDurationChangedContractPlans - Enter');

        Map<Id, SVMXA360__ServiceContractPlan__c> changedSCPlanMap = new Map<Id, SVMXA360__ServiceContractPlan__c>();
        for (SVMXA360__ServiceContractPlan__c eachSCPlan : newList) {

            SVMXA360__ServiceContractPlan__c oldSCPlan = oldMap.get(eachSCPlan.Id);
            if(oldSCPlan != null && 
                (oldSCPlan.SVMXA360__ContractTermDuration__c!= eachSCPlan.SVMXA360__ContractTermDuration__c) ||
                (oldSCPlan.SVMXA360__ContractTermUnitOfTime__c!= eachSCPlan.SVMXA360__ContractTermUnitOfTime__c) ){
                changedSCPlanMap.put(eachSCPlan.Id,eachSCPlan);
            }
        }
        System.debug(LoggingLevel.DEBUG, 'getDurationChangedContractPlans - Exit');

        return changedSCPlanMap;
    }

    private void checkContractPlanDuration(List<SVMXA360__ServiceContractPlan__c> newList, Map<Id, List<SVMXA360__ContractLineItemPlan__c>> relatedCliPlansMap, Map<Id, List<SVMXA360__EntitledServicePlan__c>> relatedESPlansMap) {
        
        for (SVMXA360__ServiceContractPlan__c eachSCPlan : newList) {
            eachSCPlan.SVMXA360__ContractTermDuration__c = eachSCPlan.SVMXA360__ContractTermDuration__c != null ? eachSCPlan.SVMXA360__ContractTermDuration__c : 0;
            if( relatedCliPlansMap.containsKey(eachSCPlan.Id)) {
                for (SVMXA360__ContractLineItemPlan__c eachCLIPlan : relatedCliPlansMap.get(eachSCPlan.Id)) {
                    if ( eachCLIPlan.SVMXA360__ContractLineUnitOfTime__c == null || eachCLIPlan.SVMXA360__ContractLineDuration__c == null) {
                        continue;
                    }
                    Date cliPlanEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(),
                    Integer.valueOf(eachCLIPlan.SVMXA360__ContractLineDuration__c),
                    eachCLIPlan.SVMXA360__ContractLineUnitOfTime__c );

                    Date scEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(),
                        Integer.valueOf(eachSCPlan.SVMXA360__ContractTermDuration__c),
                        eachSCPlan.SVMXA360__ContractTermUnitOfTime__c );
                    
                    if (cliPlanEndDate > scEndDate) {
                        eachSCPlan.addError(Label.Label_SCPlanDurationValidationErrorMessage);
                    }
                }
            }

            if( relatedESPlansMap.containsKey(eachSCPlan.Id)) {
                for (SVMXA360__EntitledServicePlan__c eachESPlan : relatedESPlansMap.get(eachSCPlan.Id)) {

                    if ( eachESPlan.SVMXA360__EntitledServiceUnitOfTime__c == null || eachESPlan.SVMXA360__EntitledServiceDuration__c == null) {
                        continue;
                    }

                    Date esPlanEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(),
                    Integer.valueOf(eachESPlan.SVMXA360__EntitledServiceDuration__c),
                    eachESPlan.SVMXA360__EntitledServiceUnitOfTime__c );

                    Date scEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(),
                        Integer.valueOf(eachSCPlan.SVMXA360__ContractTermDuration__c),
                        eachSCPlan.SVMXA360__ContractTermUnitOfTime__c );
                    
                    if (esPlanEndDate > scEndDate) {
                        eachSCPlan.addError(Label.Label_SCPlanDurationValidationErrorMessage);
                    }
                }
            }
        }
    }

    public void validateDurationCLIPlan(List<SVMXA360__ContractLineItemPlan__c> newList, Map<Id, SVMXA360__ContractLineItemPlan__c> oldMap){
        System.debug( LoggingLevel.INFO, 'validateDurationCLIPlan() enter - newList: ' + newList);
        System.debug( LoggingLevel.INFO, 'validateDurationCLIPlan() enter - oldMap: ' + oldMap);

        try {
            Set<Id> setContractIds = new Set<Id>();
            List<SVMXA360__ContractLineItemPlan__c> filterCLIPlanList = new List<SVMXA360__ContractLineItemPlan__c>();
            for (SVMXA360__ContractLineItemPlan__c eachCLIPlan : newList) {
                if( eachCLIPlan.SVMXA360__ContractLineUnitOfTime__c != null 
                && eachCLIPlan.SVMXA360__ContractLineDuration__c != null ) {
                    setContractIds.add( eachCLIPlan.SVMXA360__ServiceContractPlanId__c );
                    filterCLIPlanList.add(eachCLIPlan);
                }
            }

            if (setContractIds.isEmpty() ) { return; }

            String soqlsc = 'SELECT Id , SVMXA360__ContractTermUnitOfTime__c, SVMXA360__ContractTermDuration__c '
                + 'FROM SVMXA360__ServiceContractPlan__c '
                + 'WHERE ID IN :setContractIds';
            System.debug(LoggingLevel.INFO, 'validateDurationCLIPlan() :query for ServiceContractPlan records is : ' + soqlsc);

            Map<Id, SVMXA360__ServiceContractPlan__c> serviceContractMap = new Map<Id, SVMXA360__ServiceContractPlan__c>( (List<SVMXA360__ServiceContractPlan__c>) SvmxDatabase.query(Database.query(soqlsc)));

            for(SVMXA360__ContractLineItemPlan__c eachCLIPlan : filterCLIPlanList) {
                if ( serviceContractMap.get(eachCLIPlan.SVMXA360__ServiceContractPlanId__c) != null ) {
                    SVMXA360__ServiceContractPlan__c sCPlan = serviceContractMap.get(eachCLIPlan.SVMXA360__ServiceContractPlanId__c);
                    if ( sCPlan.SVMXA360__ContractTermUnitOfTime__c == null
                      || sCPlan.SVMXA360__ContractTermDuration__c == null) {
                        eachCLIPlan.addError(Label.Label_ContractPlanDurationMissingErrorMessage);
                        continue;
                    }

                    Date cliPlanEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(),
                        Integer.valueOf(eachCLIPlan.SVMXA360__ContractLineDuration__c),
                        eachCLIPlan.SVMXA360__ContractLineUnitOfTime__c );

                    Date scEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(),
                        Integer.valueOf(sCPlan.SVMXA360__ContractTermDuration__c),
                        sCPlan.SVMXA360__ContractTermUnitOfTime__c );

                    if (cliPlanEndDate > scEndDate) {
                        eachCLIPlan.addError(Label.Label_CLIPlanDurationValidationErrorMessage);
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'validateDurationCLIPlan() : Failed to validate duration check on cli plan records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateDurationCLIPlan() - exit');
        }  
    }

    public void validateDurationESPlan(List<SVMXA360__EntitledServicePlan__c> newList, Map<Id, SVMXA360__EntitledServicePlan__c> oldMap){
        System.debug( LoggingLevel.INFO, 'validateDurationESPlan() enter - newList: ' + newList);
        System.debug( LoggingLevel.INFO, 'validateDurationESPlan() enter - oldMap: ' + oldMap);

        try {
            Set<Id> setContractIds = new Set<Id>();
            Set<Id> setCLIPlan = new Set<Id>();

            List<SVMXA360__EntitledServicePlan__c> filterESPlanList = new List<SVMXA360__EntitledServicePlan__c>();
            for (SVMXA360__EntitledServicePlan__c eachESPlan : newList) {

                if( eachESPlan.SVMXA360__EntitledServiceUnitOfTime__c != null
                 && eachESPlan.SVMXA360__EntitledServiceDuration__c != null ) {
                    setContractIds.add( eachESPlan.SVMXA360__ServiceContractPlanId__c );

                    if (eachESPlan.SVMXA360__ContractLineItemPlanId__c != null ) {
                        setCLIPlan.add( eachESPlan.SVMXA360__ContractLineItemPlanId__c );
                    }

                    filterESPlanList.add(eachESPlan);
                }
            }

            if (setContractIds.isEmpty() ) { return; }

            String soqlsc = 'SELECT Id , SVMXA360__ContractTermUnitOfTime__c, SVMXA360__ContractTermDuration__c '
                + 'FROM SVMXA360__ServiceContractPlan__c '
                + 'WHERE ID IN :setContractIds';
            System.debug(LoggingLevel.INFO, 'validateDurationESPlan() :query for ServiceContractPlan records is : ' + soqlsc);
            Map<Id, SVMXA360__ServiceContractPlan__c> serviceContractMap = new Map<Id, SVMXA360__ServiceContractPlan__c>( (List<SVMXA360__ServiceContractPlan__c>) SvmxDatabase.query(Database.query(soqlsc)));

            String soqlCliPlan = 'SELECT Id , SVMXA360__ContractLineUnitOfTime__c, SVMXA360__ContractLineDuration__c '
            + 'FROM SVMXA360__ContractLineItemPlan__c '
            + 'WHERE ID IN :setCLIPlan';
            System.debug(LoggingLevel.INFO, 'validateDurationESPlan() :query for Applicable Contract Line Product records is : ' + soqlCliPlan);
            Map<Id, SVMXA360__ContractLineItemPlan__c> contractLineItemPlanMap = new Map<Id, SVMXA360__ContractLineItemPlan__c>( (List<SVMXA360__ContractLineItemPlan__c>) SvmxDatabase.query(Database.query(soqlCliPlan)));

            for(SVMXA360__EntitledServicePlan__c eachESPlan : filterESPlanList) {

                if ( serviceContractMap.containsKey(eachESPlan.SVMXA360__ServiceContractPlanId__c) ) {
                    SVMXA360__ServiceContractPlan__c sCPlan = serviceContractMap.get(eachESPlan.SVMXA360__ServiceContractPlanId__c);

                    if ( sCPlan.SVMXA360__ContractTermUnitOfTime__c == null
                      || sCPlan.SVMXA360__ContractTermDuration__c == null) {
                        eachESPlan.addError(Label.Label_ContractPlanDurationMissingErrorMessage);
                        continue;
                    }

                    Date esPlanEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(), 
                        Integer.valueOf(eachESPlan.SVMXA360__EntitledServiceDuration__c), 
                        eachESPlan.SVMXA360__EntitledServiceUnitOfTime__c );

                    Date scEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(), 
                        Integer.valueOf(sCPlan.SVMXA360__ContractTermDuration__c), 
                        sCPlan.SVMXA360__ContractTermUnitOfTime__c );

                    if (esPlanEndDate > scEndDate) {
                        eachESPlan.addError(Label.Label_ESPlanDurationValidationErrorMessage);
                        continue;
                    }
                }

                if ( contractLineItemPlanMap.containsKey(eachESPlan.SVMXA360__ContractLineItemPlanId__c ) ) {
                    SVMXA360__ContractLineItemPlan__c cliPlan = contractLineItemPlanMap.get(eachESPlan.SVMXA360__ContractLineItemPlanId__c);

                    if ( cliPlan.SVMXA360__ContractLineUnitOfTime__c == null
                      || cliPlan.SVMXA360__ContractLineDuration__c == null) {
                        continue;
                    }

                    Date esPlanEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(), 
                        Integer.valueOf(eachESPlan.SVMXA360__EntitledServiceDuration__c), 
                        eachESPlan.SVMXA360__EntitledServiceUnitOfTime__c );

                    Date cliPlanEndDate = COMM_DateLiteralUtils.calculateEndDate( Date.today(), 
                        Integer.valueOf(cliPlan.SVMXA360__ContractLineDuration__c), 
                        cliPlan.SVMXA360__ContractLineUnitOfTime__c );

                    if (esPlanEndDate > cliPlanEndDate) {
                        eachESPlan.addError(Label.Label_ESPlanDurationValidationWithCLIPlanErrorMessage);
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'validateDurationESPlan() : Failed to validate duration check on es plan records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateDurationESPlan() - exit');
        }  
    }

    public void preventDuplicateOfferedMPT (List<SVMXA360__OfferedMaintenancePlanTemplate__c> newList, Map<Id, SVMXA360__OfferedMaintenancePlanTemplate__c> oldMap){
        System.debug( LoggingLevel.INFO, 'preventDuplicateOfferedMPT() enter - newList: ' + newList);
        System.debug( LoggingLevel.INFO, 'preventDuplicateOfferedMPT() enter - oldMap: ' + oldMap);
        //mpt - Maintenance Plan Template
        try {
            Set<Id> mptIdSet = new Set<Id>();
            Set<Id> sconPlanIdSet = new Set<Id>();
            
            List<SVMXA360__OfferedMaintenancePlanTemplate__c> existingOfferedMPTList = new List<SVMXA360__OfferedMaintenancePlanTemplate__c>();
            for (SVMXA360__OfferedMaintenancePlanTemplate__c eachOfferedMPT : newList) {

                if( eachOfferedMPT.SVMXA360__MaintenancePlanTemplateId__c != null ) {
                    mptIdSet.add( eachOfferedMPT.SVMXA360__MaintenancePlanTemplateId__c );
                }
                if( eachOfferedMPT.SVMXA360__ServiceContractPlanId__c != null ) {
                    sconPlanIdSet.add( eachOfferedMPT.SVMXA360__ServiceContractPlanId__c );
                }                
            }
            existingOfferedMPTList = SvmxDatabase.query([Select Id, Name,SVMXA360__ServiceContractPlanId__c, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name FROM SVMXA360__OfferedMaintenancePlanTemplate__c Where SVMXA360__MaintenancePlanTemplateId__c IN:mptIdSet AND SVMXA360__ServiceContractPlanId__c IN:sconPlanIdSet]);
            
            if (existingOfferedMPTList == null || existingOfferedMPTList.isEmpty()) {
                return;
            }

            for (SVMXA360__OfferedMaintenancePlanTemplate__c eachOfferedMPT : newList) {
                for (SVMXA360__OfferedMaintenancePlanTemplate__c existingOfferedMPT : existingOfferedMPTList) {
                    if (eachOfferedMPT.SVMXA360__ServiceContractPlanId__c == existingOfferedMPT.SVMXA360__ServiceContractPlanId__c
                    && eachOfferedMPT.SVMXA360__MaintenancePlanTemplateId__c == existingOfferedMPT.SVMXA360__MaintenancePlanTemplateId__c
                    ) {
                        String errorMessage = String.format(System.Label.Label_OfferedMPTErrorMessage, new List<String>{existingOfferedMPT.SVMXA360__MaintenancePlanTemplateId__r.Name});
                        eachOfferedMPT.addError(errorMessage);
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDuplicateOfferedMPT() : Failed to validate duplciate check on offered mpt records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'preventDuplicateOfferedMPT() - exit');
        }  
    }

    public void preventDuplicateProductPlan (List<SVMXA360__ServiceContractPlan__c> newList, Map<Id, SVMXA360__ServiceContractPlan__c> oldMap) {
        System.debug( LoggingLevel.INFO, 'preventDuplicateProductPlan() enter - newList: ' + newList);
        System.debug( LoggingLevel.INFO, 'preventDuplicateProductPlan() enter - oldMap: ' + oldMap);

        //scp - Service Contract Plan
        try {
            Map<Id, List<SVMXA360__ServiceContractPlan__c>> productIdVsSCPMap = new Map<Id, List<SVMXA360__ServiceContractPlan__c>>();

            for (SVMXA360__ServiceContractPlan__c eachSCP : newList) {
                if ( eachSCP.SVMXA360__ServicePlanProductId__c == null ) {
                    continue;
                }

                if (  oldMap != null 
                && ( eachSCP.SVMXA360__ServicePlanProductId__c
                == oldMap.get(eachSCP.Id).SVMXA360__ServicePlanProductId__c)) {
                    continue;
                }

                if (productIdVsSCPMap.containsKey(eachSCP.SVMXA360__ServicePlanProductId__c)) {
                    productIdVsSCPMap.get( eachSCP.SVMXA360__ServicePlanProductId__c ).add(eachSCP);
                } else {
                    productIdVsSCPMap.put(eachSCP.SVMXA360__ServicePlanProductId__c,
                    new List<SVMXA360__ServiceContractPlan__c>{eachSCP} );
                }
            }

            List<SVMXA360__ServiceContractPlan__c> existingSCPList = 
                SvmxDatabase.query([SELECT Id, Name, SVMXA360__ServicePlanProductId__c FROM SVMXA360__ServiceContractPlan__c
                    WHERE SVMXA360__ServicePlanProductId__c IN :productIdVsSCPMap.keySet()]);

            if (existingSCPList == null || existingSCPList.isEmpty()) {
                return;
            }

            for (SVMXA360__ServiceContractPlan__c existingSCP : existingSCPList) {

                for(SVMXA360__ServiceContractPlan__c scp : productIdVsSCPMap.get(existingSCP.SVMXA360__ServicePlanProductId__c)) {
                    scp.addError(System.Label.Label_DuplicateErrorMessageScpProduct);
                }
            }
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDuplicateProductPlan() : Failed to validate duplciate check on Contract Plan records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'preventDuplicateProductPlan() - exit');
        }
    }
}