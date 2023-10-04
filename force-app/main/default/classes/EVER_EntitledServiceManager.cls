/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/save/delete entitled service informations from Salesforce Org. 
 *
 * @author Karthick Saravanan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID         Name                    Date            Comment
 *****************************************************************************************************
 * A360CE-364   Karthick Saravanan      04 Jan 2021     Created.
 *****************************************************************************************************/
public with sharing class EVER_EntitledServiceManager {
    
    // List of fields to be search from Entitled Service object.
    private final static List<String> searchConditions = new List<String>{
        'Name',
        'ContractLineItem.LineItemNumber',
        'Asset.Name'
    };

    // Static string variable to hold record type name - EntitledServices
    private static final String RECORD_TYPE_ENTITLED_SERVICE = 'EntitledServices';
    
    // Static string variable to hold Amount Service Unit
    private static final String SERVICE_UNIT_AMOUNT = 'Amount';

    // List of fields to be queried from Entitled Service object.
    private final static List<String> EntitlementQueryFields = new List<String>{
        'Id', 
        'Name',
        'AccountId',
        'Account.Name',
        'AssetId',
        'Asset.Name',
        'StartDate',
        'EndDate',        
        'Status',
        'ServiceContractId',
        'ServiceContract.Name',
        'ContractLineItemId',
        'ContractLineItem.LineItemNumber',
        'SVMXA360__EntitledServiceProductId__c',
        'SVMXA360__EntitledServiceProductId__r.Name',
        'SVMXA360__CaseEntitlementProcessId__c',
        'SVMXA360__WorkOrderEntitlementProcessId__c',
        'SVMXA360__TotalServiceCount__c',
        'SVMXA360__AvailableServiceCount__c',
        'SVMXA360__ServiceCountAlertThreshold__c',
        'SVMXA360__TotalServiceAmount__c',
        'SVMXA360__ServiceAmountAlertThreshold__c',
        'SVMXA360__AvailableServiceAmount__c',
        'SVMXA360__ServiceCountType__c',
        'SvcApptBookingWindowsId',
        'SvcApptBookingWindows.Name'
    };

    // List of fields to be queried from Contract Line object.
    private final static List<String> ServiceContractQueryFields = new List<String>{
        'Id',
        'Name',
        'AccountId', 
        'Account.Name',
        'StartDate', 
        'EndDate'
    };

    // List of fields to be queried from Contract Line object.
    private final static List<String> ContractQueryFields = new List<String>{
        'Id',
        'LineItemNumber',
        'StartDate', 
        'EndDate', 
        'AssetId',
        'Asset.Name',
        'ServiceContractId',
        'ServiceContract.Name',
        'ServiceContract.AccountId', 
        'ServiceContract.Account.Name'
    };

    /**
     * Private static variable to hold instance of this class.
     */
    private static EVER_EntitledServiceManager instance;
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private EVER_EntitledServiceManager(){}

    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static EVER_EntitledServiceManager getInstance() {
        
        System.debug( LoggingLevel.INFO, 'EVER_EntitledServiceManager .getInstance() - enter' );
        
        try {
            
            if( instance == null ) {
                
                instance = new EVER_EntitledServiceManager ();
                System.debug( LoggingLevel.INFO, 'EVER_EntitledServiceManager.getInstance() : Instance created successfully' );
            }
        }
        finally {
            System.debug( LoggingLevel.INFO, 'EVER_EntitledServiceManager.getInstance() - exit' );
        }
        
        return instance;
    }


    /**
    * This method is used to retrieve all the entitled services configured for the service contract or contract line item.
    */
    public Ever.EntitledService getEntitledServices(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledServiceManager-getEntitledServices() - enter' );
        
        Ever.EntitledService objEntitledService = new Ever.EntitledService ();
        
        try {
            

            if( inputData == null || string.isBlank(inputData.parentId)) {
                
                System.debug( LoggingLevel.ERROR, 'getEntitledServices() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            String recQueryStr;
            String countQueryStr;
            
            Id parentRecordId = (Id) String.escapeSingleQuotes(inputData.parentId);
            System.debug(LoggingLevel.INFO, 'getEntitledServices() :parentRecordId Id= :'+parentRecordId);
            
            Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();            
            recQueryStr = 'SELECT ' + String.join( EntitlementQueryFields, ',') + ' FROM Entitlement';
            countQueryStr ='SELECT count() FROM Entitlement';
            
            //where clause for parent objects- ServiceContract and Contract Line
            String whereClause =' WHERE RecordTypeId =\''+recordTypeId+'\'';
            if(parentRecordId.getSobjectType() == ServiceContract.getSobjectType()){
                whereClause+= ' AND ServiceContractId =\''+parentRecordId+'\'';
            }else{
                whereClause+= ' AND ContractLineItemId =\''+parentRecordId+'\'';
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

            System.debug(LoggingLevel.INFO, 'getEntitledServices() :query for Total Count is :'+countQueryStr);
            System.debug(LoggingLevel.INFO, 'getEntitledServices() :query for RecordList is :'+recQueryStr);

            //Get the total count of entitled service for the service contract using lazy loading.
            Integer recordCount = database.countQuery(countQueryStr);
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<Entitlement> entitlementList = SvmxDatabase.query(recQueryStr);

            objEntitledService.totalRecordCount = recordCount;            
            objEntitledService.entitledServiceDetailList = getEntitledServiceDetailList(entitlementList);  

            System.debug( LoggingLevel.DEBUG, 'getEntitledServices() : Retrieved all EntitledServices for service contract=' +objEntitledService );
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitledServices() : Failed to retrieve EntitledServices. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServices() - exit; objEntitledService.size()= ' + objEntitledService.totalRecordCount );
        }
        
        return objEntitledService;
    }


    /**
    * This method is used to retrieve parent record informations for Entitled Service.
    */
    public Ever.EntitledServiceDetail getParentRecordValues(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledServiceManager-getParentRecordValues() - enter' );

        Ever.EntitledServiceDetail objEntitledServiceDetail = new Ever.EntitledServiceDetail ();
        
        try {

            if( inputData == null || string.isBlank(inputData.parentId)) {                
                System.debug( LoggingLevel.ERROR, 'getEntitledServices() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
                        
            Id parentRecordId = (Id) inputData.parentId;
            System.debug(LoggingLevel.INFO, 'getParentRecordValues() :parentRecordId Id= :'+parentRecordId);

            string fieldsToQuery = parentRecordId.getSobjectType() == ServiceContract.getSobjectType() ? String.join( ServiceContractQueryFields, ',') : String.join( ContractQueryFields, ',');
            String recordQuery = 'SELECT ' + fieldsToQuery + ' FROM '+parentRecordId.getSobjectType()+' WHERE Id =\''+parentRecordId+'\'';            
            System.debug(LoggingLevel.INFO, 'getParentRecordValues() :recordQuery= :'+recordQuery);
            
            if(parentRecordId.getSobjectType() == ServiceContract.getSobjectType()){
                //retrieve service contract record info
                /* sfge-disable-next-line ApexFlsViolationRule */
                ServiceContract serviceContractRecord = (ServiceContract) SvmxDatabase.query( recordQuery ).get(0);
                objEntitledServiceDetail.serviceContractId = serviceContractRecord.Id;
                objEntitledServiceDetail.serviceContractName = serviceContractRecord.Name;
                objEntitledServiceDetail.accountId = serviceContractRecord.AccountId;
                objEntitledServiceDetail.accountName = serviceContractRecord.Account.Name;
                objEntitledServiceDetail.startDate = serviceContractRecord.StartDate;
                objEntitledServiceDetail.endDate = serviceContractRecord.EndDate; 

            }else{
                //retrieve contract line item record info
                /* sfge-disable-next-line ApexFlsViolationRule */
                ContractLineItem contractLineItemRec = (ContractLineItem) SvmxDatabase.query( recordQuery ).get(0);
                objEntitledServiceDetail.serviceContractId = contractLineItemRec.ServiceContractId;
                objEntitledServiceDetail.serviceContractName = contractLineItemRec.ServiceContract.Name;
                objEntitledServiceDetail.contractLineId = contractLineItemRec.Id;
                objEntitledServiceDetail.contractLineName = contractLineItemRec.LineItemNumber;                
                objEntitledServiceDetail.accountId = contractLineItemRec.ServiceContract.AccountId;
                objEntitledServiceDetail.accountName = contractLineItemRec.ServiceContract.Account.Name;
                objEntitledServiceDetail.assetId = contractLineItemRec.AssetId;
                objEntitledServiceDetail.assetName = contractLineItemRec.Asset.Name;
                objEntitledServiceDetail.startDate = contractLineItemRec.StartDate; 
                objEntitledServiceDetail.endDate = contractLineItemRec.EndDate; 
            }
            System.debug( LoggingLevel.DEBUG, 'getParentRecordValues() : objEntitledServiceDetail=' +objEntitledServiceDetail ); 
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Failed to retrieve Parent Record Info for entitled service. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getParentRecordValues() : Failed to retrieve Parent Record Info. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getParentRecordValues() - exit; objEntitledServiceDetail= ' + objEntitledServiceDetail );
        }
        
        return objEntitledServiceDetail;
    }


    /**
    * This method is used to retrieve details of Entitled Service for given entitlement id.
    */
    public Ever.EntitledServiceDetail getEntitledServiceDetails(Config.FilterCriteria inputData) {
        
        System.debug( LoggingLevel.DEBUG, 'EVER_EntitledServiceManager-getEntitledServiceDetails() - enter inputData ='+inputData );

        Ever.EntitledServiceDetail objEntitledServiceDetail = new Ever.EntitledServiceDetail ();
        
        try {            

            if( inputData == null || string.isBlank(inputData.id)) {                
                System.debug( LoggingLevel.ERROR, 'getEntitledServiceDetails() : Invalid arguments. inputData = ' + inputData);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetails() : inputData.id=' +inputData.id );        

            // Retrieve Entitled Service details
            Set<Id> entilementProcessIdSet = new Set<Id>();
            String recordQuery = 'SELECT ' + String.join( EntitlementQueryFields, ',') + ' FROM Entitlement WHERE Id =\''+ String.escapeSingleQuotes(inputData.id) +'\'';            
            System.debug(LoggingLevel.INFO, 'getEntitledServiceDetails() :recordQuery= :'+recordQuery);
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<Entitlement> entitlementList = SvmxDatabase.query(recordQuery);
            List<Ever.EntitledServiceDetail> entitledServiceDetailList = getEntitledServiceDetailList(entitlementList);    
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetails() : entitledServiceDetailList' +entitledServiceDetailList );

            if(entitledServiceDetailList.size() > 0) {
                objEntitledServiceDetail = entitledServiceDetailList[0];
            } else {
                System.debug( LoggingLevel.ERROR, 'getEntitledServiceDetails() : Record not exists.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }  
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetails() : Retrieved Entitled Service for service contract' +objEntitledServiceDetail );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceDetails() : Failed to retrieve entitled service. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceDetails() : Failed to retrieve Entitled Service. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetails() - exit; objEntitledServiceDetail= ' + objEntitledServiceDetail );
        }
        
        return objEntitledServiceDetail;
    }

    /**
     * This method is used to save/update Entitled Service.
     * 
     * @param Ever.EntitledServiceDetail Entitled Service details to be saved.
     */
    public Ever.EntitledServiceDetail saveEntitledService( Ever.EntitledServiceDetail entitledServiceDetail ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitledService() - enter; entitledServiceDetail= ' + entitledServiceDetail );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Entitled Service informations.
            if( entitledServiceDetail == null || String.isBlank(entitledServiceDetail.accountId) || String.isBlank(entitledServiceDetail.name) ||
                (String.isBlank(entitledServiceDetail.serviceContractId) && String.isBlank(entitledServiceDetail.contractLineId) ) ) {             
                System.debug( LoggingLevel.ERROR, 'saveEntitledService() : Invalid request parameters. entitledServiceDetail= ' + entitledServiceDetail );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            // Upsert Entitled Service record.
            Entitlement entitlementRecord = (Entitlement) SvmxDatabase.upsertRecord(createEntitledServiceRecord(entitledServiceDetail));            
            System.debug( LoggingLevel.INFO, 'saveEntitledService() : Saved entitlementRecord = ' + entitlementRecord );            
            // Update Id to entitledServiceDetail in response
            entitledServiceDetail.id = entitlementRecord.id;
            System.debug( LoggingLevel.DEBUG, 'saveEntitledService() : Saved entitledServiceDetail ' +entitledServiceDetail );
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );            
            System.debug( LoggingLevel.ERROR, 'saveEntitledService() : Failed to save entitledServiceDetail. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback( sPoint );            
            System.debug( LoggingLevel.ERROR, 'saveEntitledService() : Failed to save entitledServiceDetail. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitledService() - exit; entitledServiceDetail= ' + entitledServiceDetail );
        }
        
        return entitledServiceDetail;
    }

    /**
     * This method is used to delete entitled service for the requested entitled service id.
     */
    public void deleteEntitledService( String entitledServiceId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitledService() - enter; entitledServiceId= ' + entitledServiceId );
        
        try {
            // Verify for valid entitledServiceId.
            if( String.isBlank( entitledServiceId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteEntitledService() : Invalid request parameters. entitledServiceId= ' + entitledServiceId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            List<Entitlement> entitlements = deleteCheckOnES(new Set<Id>{entitledServiceId});

            SvmxDatabase.deleteRecord( entitlements );

            System.debug( LoggingLevel.INFO, 'deleteEntitledService() : entitled service removed successfully. entitledServiceId= ' + entitledServiceId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledService() : Failed to delete entitled service. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledService() : Failed to delete entitled service. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitledService() - exit');
        }
    }

    /**
     * This method is used to retrieve list of EntitledServiceDetail records.
     */
    private List<Ever.EntitledServiceDetail> getEntitledServiceDetailList(List<Entitlement> entitlementList) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetailList() - enter:' ); 
        List<Ever.EntitledServiceDetail> lstEntitledServiceDetail = new List<Ever.EntitledServiceDetail>();
        Set<Id> entilementProcessIdSet = new Set<Id>();
        Map<Id,SlaProcess> entitlementProcessMap = new Map<Id,SlaProcess>();

        if(!entitlementList.isEmpty() ) {

            for( Entitlement entitlementRecord : entitlementList ) {

                if(String.isNotBlank(entitlementRecord.SVMXA360__CaseEntitlementProcessId__c)){
                    entilementProcessIdSet.add(entitlementRecord.SVMXA360__CaseEntitlementProcessId__c);
                }
                if(String.isNotBlank(entitlementRecord.SVMXA360__WorkOrderEntitlementProcessId__c)){
                    entilementProcessIdSet.add(entitlementRecord.SVMXA360__WorkOrderEntitlementProcessId__c);
                }
            }

            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetailList() - entilementProcessIdSet :' +entilementProcessIdSet); 
            entitlementProcessMap = getEntitlementProcess( entilementProcessIdSet );
            // Create EntitledService wrapper for each EntitledService retrieved.
            for( Entitlement entitlementRecord : entitlementList ) {
                lstEntitledServiceDetail.add( createEntitledService( entitlementRecord, entitlementProcessMap ) );
            }
        }

        System.debug( LoggingLevel.DEBUG, 'getEntitledServiceDetailList() - exit; lstEntitledServiceDetail = ' + lstEntitledServiceDetail );

        return lstEntitledServiceDetail;
    }

    /**
     * This method is used to retrieve all Entitlement Process(SLA) records configured.
     */
    public static Map<Id,SlaProcess> getEntitlementProcess(Set<Id> entitlementProcessIdSet) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementProcess() - enter:' +entitlementProcessIdSet );        
        Map<Id,SlaProcess> entitlementProcessMap = new Map<Id,SlaProcess>();

        if(! entitlementProcessIdSet.isEmpty() ) {
            /* sfge-disable-next-line ApexFlsViolationRule */
            entitlementProcessMap = new Map<Id,SlaProcess>((List<SlaProcess>)SvmxDatabase.query([Select Id,Name from SlaProcess where Id IN :entitlementProcessIdSet]));
        }
        System.debug( LoggingLevel.DEBUG, 'getEntitlementProcess() - exit; entitlementProcessMap = ' + entitlementProcessMap );

        return entitlementProcessMap;
    }
    
    /**
     * Private method to Construct Entitled Service record.
     */
    private Entitlement createEntitledServiceRecord( Ever.EntitledServiceDetail entitledServiceDetail ) {
        
        System.debug( LoggingLevel.INFO, 'createEntitledServiceRecord() - enter; entitledServiceDetail= ' + entitledServiceDetail );
        
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();

        //Date range validation for Entitled Service
        performDateIntegrityCheck(entitledServiceDetail);

        Entitlement entitlementRecord = new Entitlement();
        // Assign id field if Entitled Service already exists. 
        entitlementRecord.Id = (String.isNotBlank(entitledServiceDetail.id))? entitledServiceDetail.id :null;
        entitlementRecord.RecordTypeId = recordTypeId;
        //Status is read only field
        //entitlementRecord.Status = entitledServiceDetail.status;
        entitlementRecord.AccountId = entitledServiceDetail.accountId;
        entitlementRecord.Name = (String.isNotBlank(entitledServiceDetail.name))? entitledServiceDetail.name :null;
        entitlementRecord.ServiceContractId = (String.isNotBlank(entitledServiceDetail.serviceContractId))? entitledServiceDetail.serviceContractId :null;
        entitlementRecord.ContractLineItemId = (String.isNotBlank(entitledServiceDetail.contractLineId))? entitledServiceDetail.contractLineId :null;
        entitlementRecord.AssetId = (String.isNotBlank(entitledServiceDetail.assetId))? entitledServiceDetail.assetId :null;
        entitlementRecord.SVMXA360__EntitledServiceProductId__c = (String.isNotBlank(entitledServiceDetail.serviceProductId))? entitledServiceDetail.serviceProductId :null;
        entitlementRecord.StartDate = entitledServiceDetail.startDate; 
        entitlementRecord.EndDate = entitledServiceDetail.endDate;
        entitlementRecord.SVMXA360__ServiceCountType__c = entitledServiceDetail.serviceType;
        if( entitlementRecord.SVMXA360__ServiceCountType__c == SERVICE_UNIT_AMOUNT) {        
            entitlementRecord.SVMXA360__TotalServiceAmount__c = entitledServiceDetail.totalService; 
            entitlementRecord.SVMXA360__ServiceAmountAlertThreshold__c = entitledServiceDetail.serviceAlertThreshold;
            entitlementRecord.SVMXA360__TotalServiceCount__c = null;
            entitlementRecord.SVMXA360__ServiceCountAlertThreshold__c = null; 
        }else {
            entitlementRecord.SVMXA360__TotalServiceCount__c = entitledServiceDetail.totalService; 
            entitlementRecord.SVMXA360__ServiceCountAlertThreshold__c = entitledServiceDetail.serviceAlertThreshold;
            entitlementRecord.SVMXA360__TotalServiceAmount__c = null;
            entitlementRecord.SVMXA360__ServiceAmountAlertThreshold__c = null;
        }
        //OperationHoursId
        entitlementRecord.SvcApptBookingWindowsId = entitledServiceDetail?.operatingHoursId;
        entitlementRecord.SVMXA360__CaseEntitlementProcessId__c = (String.isNotBlank(entitledServiceDetail.caseEntitlementProcessId))? entitledServiceDetail.caseEntitlementProcessId :null;
        entitlementRecord.SVMXA360__WorkOrderEntitlementProcessId__c = (String.isNotBlank(entitledServiceDetail.workOrderEntitlementProcessId))? entitledServiceDetail.workOrderEntitlementProcessId :null;
        
        System.debug( LoggingLevel.INFO, 'createEntitledServiceRecord() - exit; entitlementRecord= ' + entitlementRecord );
        return entitlementRecord;
    }

    private void performDateIntegrityCheck( Ever.EntitledServiceDetail entitledServiceDetail ){ 

        System.debug( LoggingLevel.DEBUG, 'performDateIntegrityCheck() enter - entitledServiceDetail: ' + entitledServiceDetail);

        if (String.isNotBlank(entitledServiceDetail.contractLineId)) {
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<ContractLineItem> cliRecords = SvmxDatabase.query([Select Id,StartDate,EndDate from ContractLineItem where Id = :entitledServiceDetail.contractLineId]);
            if (cliRecords == null || cliRecords.isEmpty()) {
                return;
            }
            ContractLineItem cliRecord = cliRecords.get(0);
            if ((entitledServiceDetail.startDate!=null && cliRecord.StartDate!=null && entitledServiceDetail.startDate < cliRecord.StartDate)
                || (entitledServiceDetail.endDate!=null && cliRecord.EndDate!=null && entitledServiceDetail.endDate > cliRecord.EndDate) ){
                String formattedStartDate = cliRecord.StartDate !=null ? cliRecord.StartDate.format() : null;
                String formattedEndDate = cliRecord.EndDate !=null ? cliRecord.EndDate.format() : null;
                String errorMessage = String.format(System.Label.Label_ESDateRangeErrMsgForCLI, new List<String>{formattedStartDate, formattedEndDate});
                
                throw new SvmxSystem.SvmxNestedException(errorMessage);
            }
        } else {
            /* sfge-disable-next-line ApexFlsViolationRule */
            List<ServiceContract> contractRecords = SvmxDatabase.query([Select Id,StartDate,EndDate from ServiceContract where Id = :entitledServiceDetail.serviceContractId]);
            if (contractRecords == null || contractRecords.isEmpty()) {
                return;
            }
            ServiceContract contractRecord = contractRecords.get(0);
            if ((entitledServiceDetail.startDate!=null && contractRecord.StartDate!=null && entitledServiceDetail.startDate < contractRecord.StartDate)
                || (entitledServiceDetail.endDate!=null && contractRecord.EndDate!=null && entitledServiceDetail.endDate > contractRecord.EndDate) ){
                String formattedStartDate = contractRecord.StartDate !=null ? contractRecord.StartDate.format() : null;
                String formattedEndDate = contractRecord.EndDate !=null ? contractRecord.EndDate.format() : null;
                String errorMessage = String.format(System.Label.Label_ESDateRangeErrMsgForServiceContract, new List<String>{formattedStartDate, formattedEndDate});
                
                throw new SvmxSystem.SvmxNestedException(errorMessage);
            }
        }
    }

    /**
     * Private method to create EntitledServiceDetail wrapper from EntitledService record.
     */
    private Ever.EntitledServiceDetail createEntitledService( Entitlement entitlementRec, Map<Id,SlaProcess> entitlementProcessMap ) {
        
        Ever.EntitledServiceDetail objEntitledServiceDetail = new Ever.EntitledServiceDetail();
        
        objEntitledServiceDetail.id = entitlementRec.Id;
        objEntitledServiceDetail.name = entitlementRec.Name;
        //Service Contract Info
        objEntitledServiceDetail.serviceContractId = entitlementRec.ServiceContractId;
        objEntitledServiceDetail.serviceContractName = entitlementRec.ServiceContract.Name;
        //Contract Line Item Info
        objEntitledServiceDetail.contractLineId = entitlementRec.ContractLineItemId;
        objEntitledServiceDetail.contractLineName = entitlementRec.ContractLineItem.LineItemNumber;
        //Account Info
        objEntitledServiceDetail.accountId = entitlementRec.AccountId;
        objEntitledServiceDetail.accountName = entitlementRec.Account.Name;
        //Asset Info
        objEntitledServiceDetail.assetId = entitlementRec.AssetId;
        objEntitledServiceDetail.assetName = entitlementRec.Asset.Name;
        //Operating Hours Info
        objEntitledServiceDetail.operatingHoursId = entitlementRec.SvcApptBookingWindowsId;
        objEntitledServiceDetail.operatingHoursName = entitlementRec.SvcApptBookingWindows.Name;
        //Product Info
        objEntitledServiceDetail.serviceProductId = entitlementRec.SVMXA360__EntitledServiceProductId__c;
        objEntitledServiceDetail.serviceProductName = entitlementRec.SVMXA360__EntitledServiceProductId__r.Name;
        objEntitledServiceDetail.status = entitlementRec.Status;
        //Service Unit Type
        objEntitledServiceDetail.serviceType = entitlementRec.SVMXA360__ServiceCountType__c;
        
        if( objEntitledServiceDetail.serviceType == SERVICE_UNIT_AMOUNT ) {
            //Amount Info
            objEntitledServiceDetail.remainingService = entitlementRec.SVMXA360__AvailableServiceAmount__c;
            objEntitledServiceDetail.serviceAlertThreshold = entitlementRec.SVMXA360__ServiceAmountAlertThreshold__c;
            objEntitledServiceDetail.totalService = entitlementRec.SVMXA360__TotalServiceAmount__c;
            
        } else {
            //Count Info
            objEntitledServiceDetail.remainingService = entitlementRec.SVMXA360__AvailableServiceCount__c;
            objEntitledServiceDetail.serviceAlertThreshold = entitlementRec.SVMXA360__ServiceCountAlertThreshold__c;
            objEntitledServiceDetail.totalService = entitlementRec.SVMXA360__TotalServiceCount__c;
        }
        objEntitledServiceDetail.startDate = entitlementRec.StartDate;
        objEntitledServiceDetail.endDate = entitlementRec.EndDate;
        
        objEntitledServiceDetail.caseEntitlementProcessId = entitlementRec.SVMXA360__CaseEntitlementProcessId__c;
        objEntitledServiceDetail.caseEntitlementProcessName = entitlementProcessMap.containsKey( entitlementRec.SVMXA360__CaseEntitlementProcessId__c ) ? entitlementProcessMap.get( entitlementRec.SVMXA360__CaseEntitlementProcessId__c ).Name : null;
        objEntitledServiceDetail.workOrderEntitlementProcessId = entitlementRec.SVMXA360__WorkOrderEntitlementProcessId__c;
        objEntitledServiceDetail.workOrderEntitlementProcessName = entitlementProcessMap.containsKey( entitlementRec.SVMXA360__WorkOrderEntitlementProcessId__c ) ? entitlementProcessMap.get( entitlementRec.SVMXA360__WorkOrderEntitlementProcessId__c ).Name : null;
        return objEntitledServiceDetail;
    }

    private Entitlement relatedRecordsCheckOnES (Entitlement entitlement) {
        if(entitlement == null ) {
            return entitlement;
        }
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/';
        String errorMessage = '';

        //In case ContractPriceLineItems are presnet
        if (entitlement.SVMXA360__Contract_Price_Line_Items__r.size() > 0) {
            errorMessage = Label.Message_CLIDeleteErrorForCPLI + ' ';
            for (SVMXA360__ContractPriceLineItem__c cPLI : entitlement.SVMXA360__Contract_Price_Line_Items__r) {
                errorMessage += '<a target="_blank" href="' + baseUrl + cPLI.Id + '">'+ cPLI.Name +'</a>, ';
            }
        }

        errorMessage = errorMessage.removeEnd(', ');

        if ( String.isBlank(errorMessage) ) {
            return entitlement;
        } else if ( Trigger.isExecuting ) {
            entitlement = (Entitlement)Trigger.oldMap.get(entitlement.Id);
            entitlement.addError(errorMessage);
        } else {
            throw new SvmxSystem.SvmxNestedException(errorMessage);
        }

        return entitlement;
    }

    public List<Entitlement> deleteCheckOnES (Set<Id> entitledServiceIdSet) {
        System.debug( LoggingLevel.DEBUG, 'deleteCheckOnES() - enter; entitledServiceIdSet= ' + entitledServiceIdSet );
        Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();

        List<Entitlement> entitlements = new List<Entitlement>();
        try {
            if( entitledServiceIdSet == null || entitledServiceIdSet.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' entitledServiceIdSet= ' + entitledServiceIdSet );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            for (Entitlement entitlement : (List<Entitlement>)SvmxDatabase.query([ 
                SELECT ID, Name,
                    (SELECT ID, Name FROM SVMXA360__Contract_Price_Line_Items__r)
                FROM Entitlement
                WHERE ID IN : entitledServiceIdSet AND RecordTypeId = :recordTypeId
            ]) ) {
                entitlements.add(relatedRecordsCheckOnES(entitlement));
            }
            return entitlements;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnES() : Failed to delete Entitled Service. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'deleteCheckOnES() : Failed to delete Entitled Service. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteCheckOnES() - exit; entitlements= ' + entitlements );
        }
    }
}