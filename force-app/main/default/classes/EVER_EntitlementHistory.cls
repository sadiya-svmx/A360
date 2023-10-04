/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * entitlement history information which will be invoked by lwc components. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       27 July 2020     Created.
 *              Sandeep Dhariwal       30 Dec 2020      A360CE-398.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class EVER_EntitlementHistory {

    private static final Set<String> EntitlementVerficationFields = new Set<String>{
        'Id', 
        'SVMXA360__MultipleCoverages__c',
        'SVMXA360__MultipleEntitlement__c',
        'SVMXA360__EntitlementId__c', 
        'SVMXA360__EndDate__c',
        'SVMXA360__AssetWarrantyId__c',
        'SVMXA360__ServiceContractId__c', 
        'SVMXA360__EntitlementNotes__c',
        'SVMXA360__AssetWarrantyId__r.AssetWarrantyNumber',
        'SVMXA360__ServiceContractId__r.Name',
        'SVMXA360__EntitlementId__r.Name',
        'SVMXA360__AssetWarrantyId__r.WarrantyTermId',
        'SVMXA360__AssetWarrantyId__r.WarrantyTerm.WarrantyTermName',
        'SVMXA360__EntitledServiceId__c',
        'SVMXA360__EntitledServiceId__r.Name',
        'SVMXA360__EntitledServiceId__r.SVMXA360__TotalServiceCount__c',  
        'SVMXA360__EntitledServiceId__r.SVMXA360__ConsumedServiceCount__c',
        'SVMXA360__EntitledServiceId__r.SVMXA360__ServiceCountType__c',
        'SVMXA360__BillingType__c',
        'SVMXA360__EntitledServiceId__r.SVMXA360__TotalServiceAmount__c', 
        'SVMXA360__EntitledServiceId__r.SVMXA360__ConsumedServiceAmount__c'
    };

    /**
     * This method is used to retrieve sObject Entitlement performed for given recordId.
     * 
     * @param recordId for which esObject Entitlement performed information will be retrieved.
     * @return Returns   instance of Common.ServiceResponse with sObject Entitlement performed information 
     * 
   * @example getEntitlementPerformed(recordId);
     */
    public Common.ServiceResponse getEntitlementPerformed( final String recordId ) {
        System.debug( LoggingLevel.DEBUG, 'getEntitlementPerformed() - enter; recordId= ' + recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try {
            if( String.IsBlank(recordId) ) {
                System.debug( LoggingLevel.ERROR, 'getEntitlementPerformed() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            Id sObjRecordId = recordId;
            String sObjName = sObjRecordId.getSObjectType().getDescribe().getName();
            Config.FilterCriteria filterCriteria = createFilterCriteria( sObjRecordId,sObjName );
            serviceResponse.data = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria)[0];
        }
        catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitlementPerformed() : Failed to retrieve entitlement performed information. Error' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementPerformed() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * This method is used to retrieve expression detail for given recordId.
     * 
     * @param recordId for which entitlement history information will be retrieved.
     * @return Returns   instance of Common.ServiceResponse with entitlement history information 
     * 
   * @example getEntitlementVerficationHistory(recordId);
     */
    public Common.ServiceResponse getEntitlementVerficationHistory( final String recordId ) {
        System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - enter; recordId= ' + recordId );
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        try {
            if( String.IsBlank(recordId) ) {
                System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Missing required parameters.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            List<SVMXA360__EntitlementVerificationHistory__c> entitlementHistoryList = getEntitlementVerificationHistory( recordId );
            if( entitlementHistoryList.size() > 0 ) {
                serviceResponse.data = createEntitlementHistory(entitlementHistoryList[0]);
            }
        }
        catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitlementVerficationHistory() : Failed to retrieve entitlement history. Error' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementVerficationHistory() - exit; serviceResponse.success ' + serviceResponse.success );
        }
        
        return serviceResponse;
    }

    /**
     * Private method to create expression wrapper from expression record.
     */
    private static Ever.EntitlementHistory createEntitlementHistory( SVMXA360__EntitlementVerificationHistory__c entitlementHistoryRec ) {
        
        System.debug( LoggingLevel.DEBUG, 'createEntitlementHistory() - enter; entitlementHistoryRec = '+entitlementHistoryRec);

        Ever.EntitlementHistory entitlementHistoryWrapper = new Ever.EntitlementHistory();
        Ever.WarrantyTerm warrantyTerm = new Ever.WarrantyTerm();
        entitlementHistoryWrapper.id = entitlementHistoryRec.Id;
        entitlementHistoryWrapper.multipleCoverages = entitlementHistoryRec.SVMXA360__MultipleCoverages__c;
        entitlementHistoryWrapper.multipleEntitlement = entitlementHistoryRec.SVMXA360__MultipleEntitlement__c;
        entitlementHistoryWrapper.entitlementId = entitlementHistoryRec.SVMXA360__EntitlementId__c;
        entitlementHistoryWrapper.endDate = entitlementHistoryRec.SVMXA360__EndDate__c;
        entitlementHistoryWrapper.assetWarrantyId = entitlementHistoryRec.SVMXA360__AssetWarrantyId__c;
        entitlementHistoryWrapper.serviceContractId = entitlementHistoryRec.SVMXA360__ServiceContractId__c;
        entitlementHistoryWrapper.entitlementNotes = entitlementHistoryRec.SVMXA360__EntitlementNotes__c;
        entitlementHistoryWrapper.assetWarrantyName = entitlementHistoryRec.SVMXA360__AssetWarrantyId__r.AssetWarrantyNumber ;
        entitlementHistoryWrapper.serviceContractName = entitlementHistoryRec.SVMXA360__ServiceContractId__r.Name;
        entitlementHistoryWrapper.entitlementtName = entitlementHistoryRec.SVMXA360__EntitlementId__r.Name;
        entitlementHistoryWrapper.warrantyTerm = populateWarrantyTerm(entitlementHistoryRec);
        if( entitlementHistoryRec.SVMXA360__EndDate__c != null ) {
            entitlementHistoryWrapper.remainingHours = Date.today().daysBetween(entitlementHistoryRec.SVMXA360__EndDate__c);
        }
        entitlementHistoryWrapper.billingType = entitlementHistoryRec.SVMXA360__BillingType__c;
        entitlementHistoryWrapper.serviceCountType = entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__ServiceCountType__c;

        if( String.isNotBlank(entitlementHistoryWrapper.serviceCountType) ) {
            if ( entitlementHistoryWrapper.serviceCountType.equalsIgnoreCase('Amount') ) {
                populateServiceAmounts(entitlementHistoryWrapper, entitlementHistoryRec);
            } else {
                entitlementHistoryWrapper.totalService = entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__TotalServiceCount__c;
                entitlementHistoryWrapper.consumedService = entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__ConsumedServiceCount__c != null ? entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__ConsumedServiceCount__c : 0;
            }
        }

        entitlementHistoryWrapper.entitledServiceId = entitlementHistoryRec.SVMXA360__EntitledServiceId__c;
        entitlementHistoryWrapper.entitledServiceName = entitlementHistoryRec.SVMXA360__EntitledServiceId__r.Name;

        return entitlementHistoryWrapper;
    }

    /**
     * Private method to populate expression wrapper with amount fields.
     */
    private static void populateServiceAmounts (Ever.EntitlementHistory entitlementHistoryWrapper, 
                                                SVMXA360__EntitlementVerificationHistory__c entitlementHistoryRec) {
        
        System.debug( LoggingLevel.DEBUG, 'populateServiceAmounts() - enter; entitlementHistoryWrapper = '+entitlementHistoryWrapper);

        try {

            entitlementHistoryWrapper.totalService = entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__TotalServiceAmount__c;
            entitlementHistoryWrapper.consumedService = entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__ConsumedServiceAmount__c != null ? entitlementHistoryRec.SVMXA360__EntitledServiceId__r.SVMXA360__ConsumedServiceAmount__c : 0;

            if ( UserInfo.isMultiCurrencyOrganization() ) {
            
                if ( (String)entitlementHistoryRec.get('SVMXA360__CaseId__c') != null ) {
                    entitlementHistoryWrapper.currencyISOCode = (String)entitlementHistoryRec.getSobject('SVMXA360__CaseId__r').get('CurrencyIsoCode');
                } 
                
                else if ( (String)entitlementHistoryRec.get('SVMXA360__WorkOrderId__c') != null ) {
                    entitlementHistoryWrapper.currencyISOCode = (String)entitlementHistoryRec.getSobject('SVMXA360__WorkOrderId__r').get('CurrencyIsoCode');
                } 
                
                else {
                    entitlementHistoryWrapper.currencyISOCode = (String)entitlementHistoryRec.getSobject('SVMXA360__ReturnOrderId__r').get('CurrencyIsoCode');
                }

                if ( entitlementHistoryWrapper.currencyISOCode != (String)entitlementHistoryRec.get('CurrencyIsoCode') ) {

                    List<String> isoCodes = new List<String>();
                    Map<String,Double> conversionRateMap = new Map<String,Double>();
                    String entitlementCurrencyCode = (String)entitlementHistoryRec.get('CurrencyIsoCode');
                    isoCodes.add(entitlementHistoryWrapper.currencyISOCode);
                    isoCodes.add(entitlementCurrencyCode);

                    /* sfge-disable-next-line ApexFlsViolationRule */
                    List<SObject> currencyTypeList = SvmxDatabase.query( Database.query('SELECT IsoCode,ConversionRate FROM'+
                                                                                        ' CurrencyType WHERE IsoCode IN : isoCodes') );

                    for( SObject currencyTypeRecord : currencyTypeList){          
                        conversionRateMap.put((String)currencyTypeRecord.get('IsoCode'),(Double)currencyTypeRecord.get('ConversionRate'));        
                    }

                    entitlementHistoryWrapper.totalService = (entitlementHistoryWrapper.totalService/conversionRateMap.get(entitlementCurrencyCode)) * 
                            conversionRateMap.get(entitlementHistoryWrapper.currencyISOCode);

                    if ( entitlementHistoryWrapper.consumedService != 0 ) {
                        entitlementHistoryWrapper.consumedService = (entitlementHistoryWrapper.consumedService/conversionRateMap.get(entitlementCurrencyCode)) * 
                            conversionRateMap.get(entitlementHistoryWrapper.currencyISOCode);
                    }
                
                }
            }        

        } catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'populateServiceAmounts() : Failed to populate Service Amounts. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }

    /**
     * Private method to create expression wrapper from expression record.
     */
    private static Ever.WarrantyTerm populateWarrantyTerm( SVMXA360__EntitlementVerificationHistory__c entitlementHistoryRec ) {
        Ever.WarrantyTerm warrantyTerm = new Ever.WarrantyTerm();
        warrantyTerm.id = entitlementHistoryRec.SVMXA360__AssetWarrantyId__r.WarrantyTermId;
        warrantyTerm.name = entitlementHistoryRec.SVMXA360__AssetWarrantyId__r.WarrantyTerm.WarrantyTermName;
        return warrantyTerm;
    }

    /**
     * Private method to create filter query criteria for the sObject record.
     */
    private static Config.FilterCriteria createFilterCriteria( String recordId, String sObjectName ) {
        
        Config.FilterCriteria filterWrapperData = new Config.FilterCriteria();
        filterWrapperData.id = recordId;
        filterWrapperData.objectName = sObjectName;
        filterWrapperData.fields = new List<String>{'SVMXA360__IsEntitlementPerformed__c','SVMXA360__EntitlementNotes__c','Asset.Name','Account.Name'};
        if( sObjectName.equalsIgnoreCase('ReturnOrder') ) {
            filterWrapperData.fields = new List<String>{'SVMXA360__IsEntitlementPerformed__c','SVMXA360__EntitlementNotes__c','SVMXA360__AssetId__r.Name','Account.Name'};
        } 
         
        return filterWrapperData;
    }

    /**
     * This public method executes the query to return all the expressions for a given object
     */
    public static List<SVMXA360__EntitlementVerificationHistory__c> getEntitlementVerificationHistory(String recordId) {
        try {

            if( UserInfo.isMultiCurrencyOrganization() ) {
                EntitlementVerficationFields.add('SVMXA360__CaseId__r.CurrencyIsoCode');
                EntitlementVerficationFields.add('CurrencyIsoCode');
                EntitlementVerficationFields.add('SVMXA360__WorkOrderId__r.CurrencyIsoCode');
                EntitlementVerficationFields.add('SVMXA360__ReturnOrderId__r.CurrencyIsoCode');
                EntitlementVerficationFields.add('SVMXA360__CaseId__c');
                EntitlementVerficationFields.add('SVMXA360__WorkOrderId__c');
                EntitlementVerficationFields.add('SVMXA360__ReturnOrderId__c');
            }
            /* sfge-disable-next-line ApexFlsViolationRule */
            return SvmxDatabase.query(Database.query( 'SELECT ' + String.join(new List<String>(EntitlementVerficationFields), ',') +
                                                      ' FROM SVMXA360__EntitlementVerificationHistory__c where SVMXA360__CaseId__c = :recordId' +
                                                      ' OR SVMXA360__WorkOrderId__c = :recordId OR ' +
                                                      ' SVMXA360__ReturnOrderId__c = :recordId order by LastModifiedDate DESC'));
        }  catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitlementVerificationHistory() : Failed to retrieve entitlement history. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }
}