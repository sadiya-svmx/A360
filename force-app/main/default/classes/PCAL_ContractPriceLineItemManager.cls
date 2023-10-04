/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve contract price line item informations from Salesforce Org. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 * A360CE-395   Karthick Saravanan      07 Dec 2020     Created.
 *******************************************************s**********************************************/
public with sharing class PCAL_ContractPriceLineItemManager {

    
    // List of fields to be search from Contract Price Line Item object.
    private final static List<String> searchConditions = new List<String>{
        'SVMXA360__LineType__c',
        'SVMXA360__ProductId__r.Name',
        'SVMXA360__ProductFamily__c',
        'SVMXA360__ContractLineId__r.LineItemNumber',
        'SVMXA360__EntitledServiceId__r.Name'
    };
    
    // List of fields to be queried from Service Contract object.
    private final static List<String> ServiceContractQueryFields = new List<String>{
        'Id',
        'Name'
    };

    // List of fields to be queried from Contract Line object.
    private final static List<String> ContractLineItemQueryFields = new List<String>{
        'Id',
        'LineItemNumber',
        'ServiceContractId',
        'ServiceContract.Name'
    };
    
    // List of fields to be queried from Entitlement object.
    private final static List<String> EntitlementQueryFields = new List<String>{
        'Id',
        'Name',
        'ServiceContractId',
        'ServiceContract.Name',
        'ContractLineItem.Id',
        'ContractLineItem.LineItemNumber'    
    };
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static PCAL_ContractPriceLineItemManager instance;
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private PCAL_ContractPriceLineItemManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static PCAL_ContractPriceLineItemManager getInstance() {
        
        System.debug( LoggingLevel.INFO, 'PCAL_ContractPriceLineItemManager .getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new PCAL_ContractPriceLineItemManager ();
                System.debug( LoggingLevel.INFO, 'PCAL_ContractPriceLineItemManager.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.INFO, 'PCAL_ContractPriceLineItemManager.getInstance() - exit' );
        }
        
        return instance;
    }

    /**
    * This method is used to retrieve all the contract price line item configured for the service contract.
    */
    public Config.ContractPriceLineItems getContractPriceLineItems(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'PCAL_ContractPriceLineItemManager-getContractPriceLineItems() - enter' );

        Config.ContractPriceLineItems objContractPriceLineItems;
        
        try {
            

            if( inputData == null || string.isBlank(inputData.parentId)) {
                
                System.debug( LoggingLevel.ERROR, 'getContractPriceLineItems() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            String recQueryStr;
            String countQueryStr;

            Id parentRecordId = (Id) String.escapeSingleQuotes(inputData.parentId);
            System.debug(LoggingLevel.INFO, 'getContractPriceLineItems() :parentRecordId Id= :'+parentRecordId);
            
            
            recQueryStr = 'SELECT Id,Name,SVMXA360__ContractLineId__c,SVMXA360__ContractLineId__r.LineItemNumber,SVMXA360__EntitledDiscount__c,SVMXA360__EntitledServiceId__c,SVMXA360__EntitledServiceId__r.Name,SVMXA360__ExpenseItem__c,SVMXA360__LineType__c,SVMXA360__EntitledPrice__c,SVMXA360__ProductId__c,SVMXA360__ProductId__r.Name,SVMXA360__ProductFamily__c,SVMXA360__Surcharge__c,SVMXA360__ServiceContractId__c';
            if (UserInfo.isMultiCurrencyOrganization()) {
                recQueryStr += ', CurrencyIsoCode';
            }
            recQueryStr += ' FROM SVMXA360__ContractPriceLineItem__c';
            
            countQueryStr ='SELECT count() FROM SVMXA360__ContractPriceLineItem__c';
            
            //where clause for parent objects- ServiceContract,ContractLineItem and Entitlement
            String whereClause =' WHERE';
            if(parentRecordId.getSobjectType() == ServiceContract.getSobjectType()){
                whereClause+= ' SVMXA360__ServiceContractId__c =\''+parentRecordId+'\'';
            }else if(parentRecordId.getSobjectType() == ContractLineItem.getSobjectType()){
                whereClause+= ' SVMXA360__ContractLineId__c =\''+parentRecordId+'\'';
            }else{
                whereClause+= ' SVMXA360__EntitledServiceId__c =\''+parentRecordId+'\'';
            }
            
            if(String.isNotBlank(inputData.searchTerm) ){
                String searchKey =  '%'+String.escapeSingleQuotes(inputData.searchTerm)+'%';
                whereClause+= ' AND ( ';                
                for (Integer index=0;index< searchConditions.size();index++){                        
                    whereClause+= searchConditions[index]+' Like \''+searchKey+'\'';                   
                    if(index != searchConditions.size()-1){
                        whereClause+=' OR ';
                    }
                }
                whereClause+= ' )';         
            }
            recQueryStr +=whereClause;
            countQueryStr +=whereClause;

            //Added with security enforced to perform FLS check for count query
            if(!Test.isRunningTest()){
                countQueryStr+=' WITH SECURITY_ENFORCED';
            }
            
            recQueryStr += COMM_DatabaseUtils.getInstance().getOrderByLimitClause(inputData);
            
            System.debug(LoggingLevel.INFO, 'getContractPriceLineItems() :query for Total Count is :'+countQueryStr);
            System.debug(LoggingLevel.INFO, 'getContractPriceLineItems() :query for RecordList is :'+recQueryStr);

            //Get the total count of contract price line items for the service contract using lazy loading.
            Integer recordCount = database.countQuery(countQueryStr);
            List<SVMXA360__ContractPriceLineItem__c> contractPriceList = SvmxDatabase.query(recQueryStr);
            
            objContractPriceLineItems = new Config.ContractPriceLineItems(recordCount,contractPriceList);
            
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItems() : Retrieved all contract price items for service contract' +objContractPriceLineItems );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItems() : Failed to retrieve contract price items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItems() - exit; objContractPriceLineItems.size()= ' + objContractPriceLineItems.totalRecordCount );
        }
        
        return objContractPriceLineItems;
    }
    
     /**
    * This method is used to retrieve parent record informations for Contract Price Line Item.
    */
    public Config.ContractPriceLineItemDetail getParentRecordValues(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'PCAL_ContractPriceLineItemManager-getParentRecordValues() - enter' );

        Config.ContractPriceLineItemDetail objContractPriceLineItem = new Config.ContractPriceLineItemDetail();
        
        try {

            if( inputData == null || string.isBlank(inputData.parentId)) {                
                System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
                        
            Id parentRecordId = (Id) inputData.parentId;
            System.debug(LoggingLevel.INFO, 'getParentRecordValues() :parentRecordId Id= :'+parentRecordId);            
            String recordQuery;
            if(parentRecordId.getSobjectType() == ServiceContract.getSobjectType()){
                
                if (UserInfo.isMultiCurrencyOrganization()) {
                    ServiceContractQueryFields.add('CurrencyIsoCode');
                }
                
                recordQuery = 'SELECT ' + String.join( ServiceContractQueryFields, ',') + ' FROM '+parentRecordId.getSobjectType()+' WHERE Id =\''+parentRecordId+'\'';            
                System.debug(LoggingLevel.INFO, 'getParentRecordValues() :recordQuery= :'+recordQuery);
                
                //retrieve service contract record info
                ServiceContract serviceContractRecord = (ServiceContract) SvmxDatabase.query( recordQuery ).get(0);
                System.debug(LoggingLevel.INFO, 'getParentRecordValues() :serviceContractRecord = :'+serviceContractRecord  );
                objContractPriceLineItem.serviceContractId = serviceContractRecord.Id;
                objContractPriceLineItem.serviceContractName = serviceContractRecord.Name;
                
                objContractPriceLineItem.currencyIsoCode = UserInfo.isMultiCurrencyOrganization()? (String)serviceContractRecord.get('CurrencyIsoCode'):null;

            }else if (parentRecordId.getSobjectType() == ContractLineItem.getSobjectType()){
            
                 if (UserInfo.isMultiCurrencyOrganization()) {
                    ContractLineItemQueryFields.add('ServiceContract.CurrencyIsoCode');
                }
                
                recordQuery = 'SELECT ' + String.join( ContractLineItemQueryFields, ',') + ' FROM '+parentRecordId.getSobjectType()+' WHERE Id =\''+parentRecordId+'\'';            
                System.debug(LoggingLevel.INFO, 'getParentRecordValues() :recordQuery= :'+recordQuery);
                //retrieve contract line item record info
                ContractLineItem contractLineItemRec = (ContractLineItem) SvmxDatabase.query( recordQuery ).get(0);
                System.debug(LoggingLevel.INFO, 'getParentRecordValues() :contractLineItemRec = :'+contractLineItemRec );
                objContractPriceLineItem.serviceContractId = contractLineItemRec.ServiceContractId;
                objContractPriceLineItem.serviceContractName = (String.isNotBlank(contractLineItemRec.ServiceContractId))?contractLineItemRec.ServiceContract.Name :null;
                
                objContractPriceLineItem.contractLineId = contractLineItemRec.Id;
                objContractPriceLineItem.contractLineName = contractLineItemRec.LineItemNumber;                
                objContractPriceLineItem.currencyIsoCode = ( UserInfo.isMultiCurrencyOrganization() && String.isNotBlank(contractLineItemRec.ServiceContractId) ) ? (String)contractLineItemRec.ServiceContract.get('CurrencyIsoCode'):null;
                
            } else {
                
                if (UserInfo.isMultiCurrencyOrganization()) {
                    EntitlementQueryFields.add('ServiceContract.CurrencyIsoCode');
                }
                
                recordQuery = 'SELECT ' + String.join( EntitlementQueryFields, ',') + ' FROM '+parentRecordId.getSobjectType()+' WHERE Id =\''+parentRecordId+'\'';            
                System.debug(LoggingLevel.INFO, 'getParentRecordValues() :recordQuery= :'+recordQuery);
                
                //retrieve entitled service record info
                Entitlement entitledServiceRecord = (Entitlement) SvmxDatabase.query( recordQuery ).get(0);
                System.debug(LoggingLevel.INFO, 'getParentRecordValues() :entitledServiceRecord = :'+entitledServiceRecord );
                objContractPriceLineItem.serviceContractId = entitledServiceRecord.ServiceContractId;
                objContractPriceLineItem.serviceContractName = String.isNotBlank(entitledServiceRecord.ServiceContractId) ? entitledServiceRecord.ServiceContract.Name :null;
                
                objContractPriceLineItem.contractLineId = entitledServiceRecord.ContractLineItemId;
                objContractPriceLineItem.contractLineName = String.isNotBlank(entitledServiceRecord.ContractLineItemId)? entitledServiceRecord.ContractLineItem.LineItemNumber :null;
                
                objContractPriceLineItem.entitledServiceId = entitledServiceRecord.Id;
                objContractPriceLineItem.entitledServiceName = entitledServiceRecord.Name;
                
                objContractPriceLineItem.currencyIsoCode = ( UserInfo.isMultiCurrencyOrganization() && String.isNotBlank(entitledServiceRecord.ServiceContractId) )? (String)entitledServiceRecord.ServiceContract.get('CurrencyIsoCode'):null;
            }
            System.debug( LoggingLevel.DEBUG, 'getParentRecordValues() : objContractPriceLineItem=' +objContractPriceLineItem ); 
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Failed to retrieve Parent Record Info for Contract Price Line Item. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Failed to retrieve Parent Record Info. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getParentRecordValues() - exit; objContractPriceLineItem= ' + objContractPriceLineItem );
        }
        
        return objContractPriceLineItem;
    }

    /**
    * This method is used to retrieve details of contract price line item for given contract price id.
    */
    public Config.ContractPriceLineItemDetail getContractPriceLineItemDetails(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'PCAL_ContractPriceLineItemManager-getContractPriceLineItemDetails() - enter' );

        Config.ContractPriceLineItemDetail objContractPriceLineItem;
        
        try {
            

            if( inputData == null || string.isBlank(inputData.id)) {
                
                System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemDetails() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemDetails() : inputData.id' +inputData.id );
           
            // Retrieve contract price line item details
            List<SVMXA360__ContractPriceLineItem__c> contractPriceDetailList = getContractPriceWithDetails( inputData.id );
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemDetails() : contractPriceDetailList' +contractPriceDetailList );
            
            if( contractPriceDetailList.size() > 0 ) {
                // Create contract price line item detail wrapper for retrieved contract price record.
                objContractPriceLineItem = createContractPriceLineItem( contractPriceDetailList[0] );
            } else {
                System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemDetails() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }
            
            
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemDetails() : Retrieved contract price items for service contract' +objContractPriceLineItem );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemDetails() : Failed to retrieve contract price items. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemDetails() - exit; objContractPriceLineItem= ' + objContractPriceLineItem );
        }
        
        return objContractPriceLineItem;
    }


    /**
     * This method is used to save/update contract price line item.
     * 
     * @param Config.ContractPriceLineItemDetail contract price line item details to be saved.
     */
    public Config.ContractPriceLineItemDetail saveContractPriceLineItem( Config.ContractPriceLineItemDetail contractPriceLineItem ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItem() - enter; contractPriceLineItem= ' + contractPriceLineItem );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid contract price informations.
            if( contractPriceLineItem == null || contractPriceLineItem.serviceContractId == null || String.isBlank(contractPriceLineItem.lineType)) {
             
                System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItem() : Invalid request parameters. contractPriceLineItem= ' + contractPriceLineItem );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }


            // Upsert contractPriceLineItem record.
            SVMXA360__ContractPriceLineItem__c contractPriceLineItemRecord = (SVMXA360__ContractPriceLineItem__c) SvmxDatabase.upsertRecord(createContractPriceRecord(contractPriceLineItem));
            
            System.debug( LoggingLevel.INFO, 'saveContractPriceLineItem() : Saved contractPriceLineItemRecord record = ' + contractPriceLineItemRecord );
            
            // Update Id and name to contract price line item details in response
            List<SVMXA360__ContractPriceLineItem__c> contractPriceDetailList = SvmxDatabase.query([SELECT Id, Name FROM SVMXA360__ContractPriceLineItem__c where Id = :contractPriceLineItemRecord.id]);
            contractPriceLineItem.id = contractPriceDetailList!=null ? contractPriceDetailList[0].id :null;
            contractPriceLineItem.name = contractPriceDetailList!=null ? contractPriceDetailList[0].Name :null;
            System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItem() : Saved contractPriceLineItem ' +contractPriceLineItem );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItem() : Failed to save contractPriceLineItem. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItem() : Failed to save contractPriceLineItem. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItem() - exit; contractPriceLineItem= ' + contractPriceLineItem );
        }
        
        return contractPriceLineItem;
    }

     /**
     * This method is used to delete contract price line item for the requested contract price id.
     */
    public void deleteContractPriceLineItem( String contractPriceId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLineItem() - enter; contractPriceId= ' + contractPriceId );
        
        try {
            // Verify for valid contractPriceId.
            if( String.isBlank( contractPriceId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteContractPriceLineItem() : Invalid request parameters. contractPriceId= ' + contractPriceId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__ContractPriceLineItem__c WHERE Id = :contractPriceId ] );
            
            System.debug( LoggingLevel.INFO, 'deleteContractPriceLineItem() : contract price line item removed successfully. contractPriceId= ' + contractPriceId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLineItem() : Failed to delete contract price line item. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLineItem() : Failed to delete contract price line item. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLineItem() - exit');
        }
    }

     /**
     * Private method to contractPriceLineItem record.
     */
    private SVMXA360__ContractPriceLineItem__c createContractPriceRecord( Config.ContractPriceLineItemDetail contractPriceLineItem ) {
        
        System.debug( LoggingLevel.INFO, 'createContractPriceRecord() - enter; contractPriceLineItem= ' + contractPriceLineItem );
        
        SVMXA360__ContractPriceLineItem__c contractPriceRecord = new SVMXA360__ContractPriceLineItem__c();
        // Assign id field if contract price line item already exists. 
        contractPriceRecord.Id = (String.isNotBlank(contractPriceLineItem.id))?contractPriceLineItem.id :null;
        
        if (UserInfo.isMultiCurrencyOrganization()) {
            String currencyCode = String.isNotBlank(contractPriceLineItem.currencyIsoCode) ? contractPriceLineItem.currencyIsoCode :null;
            contractPriceRecord.put('CurrencyIsoCode', currencyCode );
        }
        contractPriceRecord.SVMXA360__ServiceContractId__c = (String.isNotBlank(contractPriceLineItem.serviceContractId))?contractPriceLineItem.serviceContractId :null;
        contractPriceRecord.SVMXA360__ContractLineId__c = (String.isNotBlank(contractPriceLineItem.contractLineId))?contractPriceLineItem.contractLineId :null;
        contractPriceRecord.SVMXA360__EntitledServiceId__c = (String.isNotBlank(contractPriceLineItem.entitledServiceId))?contractPriceLineItem.entitledServiceId :null;
        contractPriceRecord.SVMXA360__LineType__c = contractPriceLineItem.lineType;
        contractPriceRecord.SVMXA360__ExpenseItem__c = contractPriceLineItem.expenseItem;
        contractPriceRecord.SVMXA360__ProductId__c = (String.isNotBlank(contractPriceLineItem.productId))?contractPriceLineItem.productId :null; 
        contractPriceRecord.SVMXA360__ProductFamily__c = contractPriceLineItem.productFamily;
        contractPriceRecord.SVMXA360__EntitledPrice__c = (String.isNotBlank(contractPriceLineItem.price))? double.valueOf(contractPriceLineItem.price) :null; 
        contractPriceRecord.SVMXA360__Surcharge__c = (String.isNotBlank(contractPriceLineItem.surcharge))? double.valueOf(contractPriceLineItem.surcharge) :null;
        contractPriceRecord.SVMXA360__EntitledDiscount__c = (String.isNotBlank(contractPriceLineItem.discount))? double.valueOf(contractPriceLineItem.discount) :null;
        System.debug( LoggingLevel.INFO, 'createContractPriceRecord() - enter; contractPriceRecord= ' + contractPriceRecord );
        return contractPriceRecord;
    }


    /**
     * Private method to create contract price line item detail wrapper from contract price line item record.
     */
    private Config.ContractPriceLineItemDetail createContractPriceLineItem( SVMXA360__ContractPriceLineItem__c contractPriceRec ) {
        
        Config.ContractPriceLineItemDetail objContractPriceDetail = new Config.ContractPriceLineItemDetail();
        
        objContractPriceDetail.id = contractPriceRec.Id;
        objContractPriceDetail.name = contractPriceRec.Name;
        objContractPriceDetail.serviceContractId = contractPriceRec.SVMXA360__ServiceContractId__c;
        objContractPriceDetail.serviceContractName = contractPriceRec.SVMXA360__ServiceContractId__r.Name;
        objContractPriceDetail.contractLineId = contractPriceRec.SVMXA360__ContractLineId__c;
        objContractPriceDetail.contractLineName = contractPriceRec.SVMXA360__ContractLineId__r.LineItemNumber;
        objContractPriceDetail.entitledServiceId = contractPriceRec.SVMXA360__EntitledServiceId__c;
        objContractPriceDetail.entitledServiceName = contractPriceRec.SVMXA360__EntitledServiceId__r.Name;
        objContractPriceDetail.lineType = contractPriceRec.SVMXA360__LineType__c;
        objContractPriceDetail.expenseItem = contractPriceRec.SVMXA360__ExpenseItem__c;
        objContractPriceDetail.productId = contractPriceRec.SVMXA360__ProductId__c;
        objContractPriceDetail.productName = contractPriceRec.SVMXA360__ProductId__r.Name;
        objContractPriceDetail.productFamily = contractPriceRec.SVMXA360__ProductFamily__c;
        objContractPriceDetail.price = String.valueOf(contractPriceRec.SVMXA360__EntitledPrice__c);
        objContractPriceDetail.surcharge = String.valueOf(contractPriceRec.SVMXA360__Surcharge__c);
        objContractPriceDetail.discount = String.valueOf(contractPriceRec.SVMXA360__EntitledDiscount__c);       
        if (UserInfo.isMultiCurrencyOrganization()) {
            objContractPriceDetail.currencyIsoCode = (String)contractPriceRec.get('CurrencyIsoCode');
        }
        
        return objContractPriceDetail;
    }

    /**
     * This public method executes the query to return details of Contract price line item for the given contract price Ids 
     */
    public List<SVMXA360__ContractPriceLineItem__c> getContractPriceWithDetails(Id contractPriceId) {
        
        String recordQuery = 'SELECT Id,Name,SVMXA360__ContractLineId__c,SVMXA360__ContractLineId__r.LineItemNumber,SVMXA360__EntitledDiscount__c,SVMXA360__EntitledServiceId__c,SVMXA360__EntitledServiceId__r.Name,SVMXA360__ExpenseItem__c,SVMXA360__LineType__c,SVMXA360__EntitledPrice__c,SVMXA360__ProductId__c,SVMXA360__ProductId__r.Name,SVMXA360__ProductFamily__c,SVMXA360__Surcharge__c,SVMXA360__ServiceContractId__c,SVMXA360__ServiceContractId__r.Name';
        if (UserInfo.isMultiCurrencyOrganization()) {
            recordQuery += ', CurrencyIsoCode';
        }
        recordQuery += ' FROM SVMXA360__ContractPriceLineItem__c WHERE Id =:contractPriceId';
        
        return SvmxDatabase.query(Database.query(recordQuery));
    }

}