/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *****************************************************************************/

/**
 * @brief This class prevents user to create duplicate CPLI (contract price line item) record. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *  A360CE-350 Karthick Saravanan      28 Jan 2021      Created.
 *****************************************************************************************************/
public with sharing class CPLI_TriggerHandler {
    
    public static void preventDuplicateCPLI(List<SVMXA360__ContractPriceLineItem__c> newList,map<Id, SVMXA360__ContractPriceLineItem__c> oldMap){
        
        System.debug( LoggingLevel.DEBUG, 'preventDuplicateCPLI() enter - newList: ' + newList);
        System.debug( LoggingLevel.DEBUG, 'preventDuplicateCPLI() enter - oldMap: ' + oldMap);
        
        Map<UniqueKey, List<ContractPriceLineItem__c>> cpliUniqueMap = new Map<UniqueKey, List<ContractPriceLineItem__c>>();
        Set<String> uniqueKeySet = new Set<String>();

        try {           
            for(SVMXA360__ContractPriceLineItem__c newCPLI : newList){  
            
                validatePircingFields(newCPLI);
                UniqueKey key = new UniqueKey(newCPLI);
                populateUniqueKey(newCPLI);            
                if (String.isNotBlank(newCPLI.SVMXA360__UniqueKey__c) && (oldMap==null || 
                   newCPLI.SVMXA360__UniqueKey__c != oldMap.get(newCPLI.Id).SVMXA360__UniqueKey__c || 
                   newCPLI.SVMXA360__EntitledPrice__c!= oldMap.get(newCPLI.Id).SVMXA360__EntitledPrice__c )) { 
                    
                    if (!uniqueKeySet.contains(newCPLI.SVMXA360__UniqueKey__c)) {
                        //Handle new list of cpli records are not duplicate
                        uniqueKeySet.add(newCPLI.SVMXA360__UniqueKey__c);
                        
                        if (cpliUniqueMap.containskey(key)) {                       
                            cpliUniqueMap.get(key).add(newCPLI);
                        }else {
                            List<SVMXA360__ContractPriceLineItem__c> cpliList = new List<SVMXA360__ContractPriceLineItem__c>();
                            cpliList.add(newCPLI);
                            cpliUniqueMap.put(key, cpliList);
                        }
                    }else {
                        newCPLI.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                    }
                    
                }
            }
            
            List<String> keyList = new List<String>();
            for(UniqueKey key:cpliUniqueMap.KeySet()) {
                keyList.add(key.tostring());
            }
            String recordQuery ='SELECT Id,Name,SVMXA360__ServiceContractId__c,SVMXA360__ContractLineId__c,SVMXA360__EntitledServiceId__c,SVMXA360__ProductId__c,SVMXA360__ProductFamily__c,SVMXA360__ExpenseItem__c,SVMXA360__LineType__c,SVMXA360__UniqueKey__c,SVMXA360__EntitledPrice__c,SVMXA360__EntitledDiscount__c,SVMXA360__Surcharge__c ';
            if(UserInfo.isMultiCurrencyOrganization()) {
                recordQuery +=',CurrencyIsoCode ';
            }
            recordQuery += 'FROM SVMXA360__ContractPriceLineItem__c';
            System.debug(LoggingLevel.DEBUG, 'preventDuplicateCPLI() : keyList.size: ' + keyList.size());
            
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
            System.debug(LoggingLevel.INFO, 'preventDuplicateCPLI() :query for RecordList is :'+recordQuery);        
            if(cpliUniqueMap == null || cpliUniqueMap.size() == 0){
                return;
            }
            
            List<SVMXA360__ContractPriceLineItem__c> existCpliList = (List<SVMXA360__ContractPriceLineItem__c>) SvmxDatabase.query(recordQuery);
            
            if (existCpliList == null || existCpliList.size() == 0) {
                return;
            }
            
            validateUniquenessCheck(cpliUniqueMap,existCpliList,oldMap);
        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'preventDuplicateCPLI() : Failed to validate uniqueness check on cpli records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'preventDuplicateCPLI() - exit');
        }    
    }
    
    private static void validateUniquenessCheck(Map<UniqueKey, List<ContractPriceLineItem__c>> cpliUniqueMap, List<SVMXA360__ContractPriceLineItem__c> existCpliList,Map<Id, SVMXA360__ContractPriceLineItem__c> oldMap) {
        
        for(SVMXA360__ContractPriceLineItem__c record: existCpliList) {
            if (oldMap== null || !oldMap.containskey(record.Id)){
                
                UniqueKey key = new UniqueKey(record);
                if(cpliUniqueMap.containskey(key)) {
                    List<SVMXA360__ContractPriceLineItem__c> newCPLIList = cpliUniqueMap.get(key);
                    for(SVMXA360__ContractPriceLineItem__c newCPLIRecord: newCPLIList) {
                        
                        if(UserInfo.isMultiCurrencyOrganization() &&  newCPLIRecord.SVMXA360__EntitledPrice__c!=null && record.SVMXA360__EntitledPrice__c!=null) {
                            //currency check
                            String existCPLICurrencyCode = String.valueOf(record.get('CurrencyIsoCode'));
                            String newCPLICurrencyCode = String.valueOf(newCPLIRecord.get('CurrencyIsoCode'));
                            if( newCPLICurrencyCode == existCPLICurrencyCode ){
                                newCPLIRecord.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                            }
                        } else {
                            //percentage check
                            newCPLIRecord.SVMXA360__UniqueKey__c.addError(Label.Label_DuplicateErrorMessage);
                        }
                    }
                } 
            }
        }
    }
    
    private static void validatePircingFields(SVMXA360__ContractPriceLineItem__c objCPLI) {
        
        if( ( objCPLI.SVMXA360__EntitledPrice__c != null && (objCPLI.SVMXA360__EntitledDiscount__c != null || objCPLI.SVMXA360__Surcharge__c != null)) ||
            ( objCPLI.SVMXA360__EntitledDiscount__c != null && (objCPLI.SVMXA360__EntitledPrice__c != null || objCPLI.SVMXA360__Surcharge__c != null)) || 
            ( objCPLI.SVMXA360__Surcharge__c != null && (objCPLI.SVMXA360__EntitledPrice__c != null || objCPLI.SVMXA360__EntitledDiscount__c != null)) || 
            ( objCPLI.SVMXA360__EntitledPrice__c == null && objCPLI.SVMXA360__EntitledDiscount__c == null && objCPLI.SVMXA360__Surcharge__c == null) ) {
            
            objCPLI.addError(Label.Label_CPLI_Pricing_Error);                
        }
        if ( objCPLI.SVMXA360__EntitledDiscount__c != null && (objCPLI.SVMXA360__EntitledDiscount__c < 0 || objCPLI.SVMXA360__EntitledDiscount__c > 100 )) {
            
            objCPLI.SVMXA360__EntitledDiscount__c.addError(Label.Label_CPLI_Discount_Error);
        }
        if ( objCPLI.SVMXA360__Surcharge__c != null && objCPLI.SVMXA360__Surcharge__c < 0 ) {
            
            objCPLI.SVMXA360__Surcharge__c.addError(Label.Label_CPLI_Surcharge_Error);  
        }
    }
    
    private static void populateUniqueKey(SVMXA360__ContractPriceLineItem__c cpliRecord) {
        
        String uniqueKeyValue='';
        if(String.isNotBlank(cpliRecord.SVMXA360__ServiceContractId__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__ServiceContractId__c;
        }
        if(String.isNotBlank(cpliRecord.SVMXA360__ContractLineId__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__ContractLineId__c;
        }
        if(String.isNotBlank(cpliRecord.SVMXA360__EntitledServiceId__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__EntitledServiceId__c;
        }            
        if(String.isNotBlank(cpliRecord.SVMXA360__ProductId__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__ProductId__c;
        }
        if(String.isNotBlank(cpliRecord.SVMXA360__ProductFamily__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__ProductFamily__c;
        }
        if(String.isNotBlank(cpliRecord.SVMXA360__ExpenseItem__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__ExpenseItem__c;
        }            
        if(String.isNotBlank(cpliRecord.SVMXA360__LineType__c)){
            uniqueKeyValue+=cpliRecord.SVMXA360__LineType__c;
        } 
        if(UserInfo.isMultiCurrencyOrganization() ) {
            String currencyCode = String.valueOf(cpliRecord.get('CurrencyIsoCode'));
            uniqueKeyValue+=String.isNotBlank(currencyCode) ? currencyCode :'';
        }
        
        cpliRecord.SVMXA360__UniqueKey__c = uniqueKeyValue;        
    }
    
    //Wrapper class to prepare the uniquekey for CPLI 
    class UniqueKey {
        
        SVMXA360__ContractPriceLineItem__c objCPLI = new SVMXA360__ContractPriceLineItem__c();
        
        UniqueKey(SVMXA360__ContractPriceLineItem__c cpliRecord) {
            this.objCPLI = cpliRecord;
        }
        
        integer hashCode() {
            return toString().hashCode();
        }

        boolean equals(Object o) {
            return toString() == ((UniqueKey)o).toString();
        }

        public override string toString() {
            
            String uniqueStr = String.format(
                'SVMXA360__ServiceContractId__c = \'\'{0}\'\' AND SVMXA360__ContractLineId__c = \'\'{1}\'\' AND SVMXA360__EntitledServiceId__c = \'\'{2}\'\' AND SVMXA360__ProductId__c = \'\'{3}\'\' AND SVMXA360__ProductFamily__c = \'\'{4}\'\' AND SVMXA360__ExpenseItem__c = \'\'{5}\'\' AND  SVMXA360__LineType__c = \'\'{6}\'\'',
                new String[] {
                    objCPLI.SVMXA360__ServiceContractId__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__ServiceContractId__c),
                    objCPLI.SVMXA360__ContractLineId__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__ContractLineId__c),
                    objCPLI.SVMXA360__EntitledServiceId__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__EntitledServiceId__c),
                    objCPLI.SVMXA360__ProductId__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__ProductId__c),
                    objCPLI.SVMXA360__ProductFamily__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__ProductFamily__c),
                    objCPLI.SVMXA360__ExpenseItem__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__ExpenseItem__c),
                    objCPLI.SVMXA360__LineType__c==null?'':String.escapeSingleQuotes(objCPLI.SVMXA360__LineType__c)
                }
            );            
            return uniqueStr ;
        }
    }
}