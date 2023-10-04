/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/save/delete CLI informations from Salesforce Org. 
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID         Name                    Date            Comment
 *****************************************************************************************************
 * A360AM-1499   Mahima Tarika      27 Oct 2021     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class CLI_ContractLinesHandler {
    // List of fields to be search from CLI object.
    private final static List<String> searchConditions = new List<String>{
        'LineItemNumber',
        'Asset.Name',
        'Product2.Name',
        'Status'
    };
    /**
    * This method is used to retrieve all the CLIs configured for the service contract or contract line item.
    */
    // List of fields to be queried from CLI object.
    private final static List<String> ContractLinesQueryFields = new List<String>{
        'Id', 
        'LineItemNumber',
        'AssetId',
        'Asset.Name',
        'StartDate',
        'EndDate',
        'Status',
        'Product2Id',
        'Product2.Name',
        'PriceBookEntryId',
        'ServiceContractId',
        'Discount',
        'ListPrice',
        'UnitPrice',
        'Quantity'
    };
    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final CLI_ContractLinesHandler instance = new CLI_ContractLinesHandler();
    
    /**
     * Public method to retrieve instance of this class.
     */
    public static CLI_ContractLinesHandler getInstance() {
        return instance;
    }
    
    public Scon.ContractLineItems getContractLines (Config.FilterCriteria inputData) {

        System.debug( LoggingLevel.DEBUG, 'contractLines_Manager-getContractLines() - enter' );
        Scon.ContractLineItems contractLineItems = new Scon.ContractLineItems();

        try {

            if( inputData == null || string.isBlank(inputData.parentId)) {
                
                System.debug( LoggingLevel.ERROR, 'getContractLines() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            String recQueryStr;
            String countQueryStr;

            Id parentRecordId = (Id) String.escapeSingleQuotes(inputData.parentId);
            System.debug(LoggingLevel.INFO, 'getContractLines() :parentRecordId Id= :'+parentRecordId);

            recQueryStr = 'SELECT ' + String.join( ContractLinesQueryFields, ',') + ' FROM ContractLineItem';
            countQueryStr ='SELECT count() FROM ContractLineItem';
            
            //where clause for parent objects- ServiceContract and Contract Line
            String whereClause =' WHERE ServiceContractId =\''+parentRecordId+'\'';
            
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

            System.debug(LoggingLevel.INFO, 'getContractLines() :query for Total Count is :'+countQueryStr);
            System.debug(LoggingLevel.INFO, 'getContractLines() :query for RecordList is :'+recQueryStr);

            //Get the total count of CLI for the service contract using lazy loading.
            Integer recordCount = database.countQuery(countQueryStr);
            system.debug('Query=='+recQueryStr);

            List<ContractLineItem> contractLineItemsList = SvmxDatabase.query(recQueryStr);
            List<Scon.ContractLineItemRecord> cliWrapperList = new list<Scon.ContractLineItemRecord>();

            for(ContractLineItem cli : contractLineItemsList) {
                cliWrapperList.add(buildContractLineItem(cli));
            }

            contractLineItems.totalRecordCount = recordCount;
            contractLineItems.cliRecords = cliWrapperList;

            System.debug( LoggingLevel.DEBUG, 'getContractLines() : Retrieved all clis for service contract=' + contractLineItems );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getContractLines() : Failed to retrieve clis. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractLines() - exit; Total Retrieved clis= ' + contractLineItems.totalRecordCount );
        }

        return contractLineItems;
    }

    private Scon.ContractLineItemRecord buildContractLineItem( final ContractLineItem contractLineItem ) {
        Scon.ContractLineItemRecord contractLineItemWrapper = new Scon.ContractLineItemRecord();
        contractLineItemWrapper.Id = contractLineItem.Id;
        contractLineItemWrapper.lineItemNumber = contractLineItem.LineItemNumber;
        contractLineItemWrapper.serviceContractId = contractLineItem.ServiceContractId;
        contractLineItemWrapper.assetId = contractLineItem.AssetId;
        contractLineItemWrapper.assetName = contractLineItem.asset.Name;
        contractLineItemWrapper.startDate = contractLineItem.StartDate;
        contractLineItemWrapper.endDate = contractLineItem.EndDate;
        contractLineItemWrapper.status = contractLineItem.status;
        contractLineItemWrapper.productId = contractLineItem.Product2Id;
        contractLineItemWrapper.productName = contractLineItem.Product2.Name;
        contractLineItemWrapper.priceBookEntryId = contractLineItem.PricebookEntryId;
        contractLineItemWrapper.discount = contractLineItem.Discount;
        contractLineItemWrapper.listPrice = contractLineItem.ListPrice;
        contractLineItemWrapper.unitPrice = contractLineItem.UnitPrice;
        contractLineItemWrapper.quantity = contractLineItem.Quantity;
        return contractLineItemWrapper;
    }

    /**
     * This method is used to save list of Contract Line Item.
     */
    public List<Scon.ContractLineItemRecord> saveContractLineItems( final List<Scon.ContractLineItemRecord> contractLineItems ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractLineItems() - enter; contractLineItems= ' + contractLineItems );
        
        try {
            if( contractLineItems == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractLineItems= ' + contractLineItems );
            }
            System.debug('...contractLineItems: ' + contractLineItems);
            List<ContractLineItem> contractLineItemRecords = buildContractLineItemRecords(contractLineItems);
            System.debug('...contractLineItemRecords: ' + contractLineItemRecords);

            contractLineItemRecords = SvmxDatabase.upsertRecord(contractLineItemRecords);

            for( Integer index = 0; index < contractLineItemRecords.size(); index++ ) {
                contractLineItems.get(index).id = contractLineItemRecords.get(index).id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'saveContractLineItems() : Failed to save Contract Line Items. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItems() : Failed to save Contract Line Items. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractLineItems() - exit; contractLineItems= ' + contractLineItems );
        }

        return contractLineItems;
    }

    private List<ContractLineItem> buildContractLineItemRecords( final List<Scon.ContractLineItemRecord> contractLineItems ) {
        
        final List<ContractLineItem> contractLineItemRecords = new List<ContractLineItem>();
        for( Scon.ContractLineItemRecord contractLineItem : contractLineItems ) {
            contractLineItemRecords.add( buildContractLineItemRecord(contractLineItem) );
        }

        return contractLineItemRecords;
    }

    private ContractLineItem buildContractLineItemRecord( final Scon.ContractLineItemRecord contractLineItem ) {

        if( contractLineItem.serviceContractId == null ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }

        final ContractLineItem contractLineItemRecord = new ContractLineItem();

        if( contractLineItem.id != null ) {
            contractLineItemRecord.id = contractLineItem.id;
        } else {
            contractLineItemRecord.ServiceContractId = contractLineItem.serviceContractId;
        }
        contractLineItemRecord.PriceBookEntryId = contractLineItem.priceBookEntryId;
        contractLineItemRecord.Quantity = contractLineItem.quantity;
        contractLineItemRecord.UnitPrice = contractLineItem.unitPrice;
        contractLineItemRecord.Discount = contractLineItem.discount;
        contractLineItemRecord.StartDate = contractLineItem.startDate;
        contractLineItemRecord.EndDate = contractLineItem.endDate;
        contractLineItemRecord.AssetId = contractLineItem.assetId;

        return contractLineItemRecord;
    }

    private ContractLineItem relatedRecordsCheckOnCLI (ContractLineItem contractLineItem) {
        if(contractLineItem == null ) {
            return contractLineItem;
        }
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/';
        String errorMessage = '';

        //In case both child records are present
        if (contractLineItem.Entitlements.size() > 0 
            && contractLineItem.SVMXA360__Contract_Price_Line_Items__r.size() > 0) {

            errorMessage = Label.Message_CLIDeleteError;

        } else if (contractLineItem.Entitlements.size() > 0) {
            //In case only Entitlments are presnet

            errorMessage = Label.Message_CLIDeleteErrorForEs + ' ';
            for (Entitlement entitlement : contractLineItem.Entitlements) {
                errorMessage += '<a target="_blank" href="' + baseUrl + entitlement.Id + '">'+ entitlement.Name +'</a>, ';
            }

        } else if (contractLineItem.SVMXA360__Contract_Price_Line_Items__r.size() > 0) {
            //In case only ContractPriceLineItems are presnet

            errorMessage = Label.Message_CLIDeleteErrorForCPLI + ' ';
            for (SVMXA360__ContractPriceLineItem__c cPLI : contractLineItem.SVMXA360__Contract_Price_Line_Items__r) {
                errorMessage += '<a target="_blank" href="' + baseUrl + cPLI.Id + '">'+ cPLI.Name +'</a>, ';
            }
        }

        errorMessage = errorMessage.removeEnd(', ');

        if ( String.isBlank(errorMessage) ) {
            return contractLineItem;
        } else if ( Trigger.isExecuting ) {
            contractLineItem = (ContractLineItem)Trigger.oldMap.get(contractLineItem.Id);
            contractLineItem.addError(errorMessage);
        } else {
            throw new SvmxSystem.SvmxNestedException(errorMessage);
        }

        return contractLineItem;
    }

    public List<ContractLineItem> deleteCheckOnCLI (Set<Id> contractLinesIdSet) {
        System.debug( LoggingLevel.DEBUG, 'deleteCheckOnCLI() - enter; contractLinesIdSet= ' + contractLinesIdSet );

        List<ContractLineItem> contractLineItems = new List<ContractLineItem>();
        try {
            if( contractLinesIdSet == null || contractLinesIdSet.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractLinesIdSet= ' + contractLinesIdSet );
            }

            for (ContractLineItem contractLineItem : (List<ContractLineItem>)SvmxDatabase.query([ 
                SELECT ID, LineItemNumber,
                    (SELECT ID, Name FROM Entitlements),
                    (SELECT ID, Name FROM SVMXA360__Contract_Price_Line_Items__r)
                FROM ContractLineItem
                WHERE ID IN : contractLinesIdSet
            ]) ) {
                contractLineItems.add(relatedRecordsCheckOnCLI(contractLineItem));
            }
            return contractLineItems;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnCLI() : Failed to delete Contract Line Items. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnCLI() : Failed to delete Contract Line Items. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCheckOnCLI() - exit; contractLineItems= ' + contractLineItems );
        }
    }
}