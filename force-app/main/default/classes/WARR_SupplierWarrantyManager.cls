/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class provides various service methods for Supplier Warranty Management.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       23 Jan 2023     Created.
 *****************************************************************************************************/
public with sharing class WARR_SupplierWarrantyManager {

    /**
     * Private static variable to hold logger instance for entitlement.
     */
    protected final SvmxLogger Logger = SvmxLogger.getLogger( SvmxLogger.Application.VendorWarranty );
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static WARR_SupplierWarrantyManager instance;
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static WARR_SupplierWarrantyManager getInstance() {
        
        if( instance == null ) {
            instance = new WARR_SupplierWarrantyManager();
        }
        
        return instance;
    }

    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private WARR_SupplierWarrantyManager() {
    }

    /**
     * Method to fetch supplier warranties for the source record. 
     */
    public List<Warr.SupplierWarranty> getSupplierWarranties ( String recordId ) {

        System.debug( LoggingLevel.DEBUG, 'getSupplierWarranties() - enter - recordId = '+recordId );

        List<Warr.SupplierWarranty> supplierWarranties = new List<Warr.SupplierWarranty>();

        try {

            if( recordId == null || String.isBlank(recordId) ) {                
                System.debug( LoggingLevel.ERROR, 'getSupplierWarranties() : Invalid arguments. recordId = ' + recordId);
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            Id sObjRecordId = recordId;
            String sObjName = sObjRecordId.getSObjectType().getDescribe().getName();
            Config.FilterCriteria filterCriteria = createFilterCriteria( sObjRecordId,sObjName );
            sObject sourceRecord = COMM_DatabaseUtils.getInstance().queryRecords(filterCriteria)[0];

            Set<String> assetIds = new Set<String>();
            
            if ( sObjName == 'ReturnOrder' && sourceRecord.get('SVMXA360__AssetId__c') != null ) {
                assetIds.add((String)sourceRecord.get('SVMXA360__AssetId__c'));
            } else if ( sourceRecord.get('AssetId') != null ) {
                assetIds.add((String)sourceRecord.get('AssetId'));
            }

            if( assetIds == null || assetIds.isEmpty() ) {                
                System.debug( LoggingLevel.ERROR, 'getSupplierWarranties() : Invalid arguments. assetIds = ' + assetIds);
                throw new SvmxSystem.SvmxNestedException( System.label.Label_NoAssetFound );
            }

            supplierWarranties = fetchSupplierWarranties( assetIds );

            updateSourceRecord (sourceRecord, supplierWarranties);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSupplierWarranties() : Failed to get supplier Warranties. Error= ' + e.getMessage() );
            Logger.error(e, recordId);
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getSupplierWarranties() : Failed to get supplier Warranties. Error= ' + e.getStackTraceString() );
            Logger.error(e, recordId);
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSupplierWarranties() - exit; supplierWarranties = ' + supplierWarranties );
        }

        return supplierWarranties;
    }

    private List<Warr.SupplierWarranty> fetchSupplierWarranties( Set<String> assetIds ) {

        System.debug( LoggingLevel.DEBUG, 'getSupplierWarranties() - enter - assetIds = '+assetIds );

        List<Warr.SupplierWarranty> supplierWarranties = new List<Warr.SupplierWarranty>();

        try {

            List<AssetWarranty> assetWarranties = fetchSupplierWarrantyRecords( assetIds );

            if ( assetWarranties !=null && !assetWarranties.isEmpty() ) {

                for ( AssetWarranty assetWarrantyRecord : assetWarranties ) {

                    Warr.SupplierWarranty supplierWarranty = new Warr.SupplierWarranty();
                    supplierWarranty = buildSupplierWarranty(assetWarrantyRecord);
                    supplierWarranties.add(supplierWarranty);
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'fetchSupplierWarranties() : Failed to fetch supplier Warranties. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'fetchSupplierWarranties() - exit; supplierWarranties = ' + supplierWarranties );
        }

        return supplierWarranties;
    }

    private List<AssetWarranty> fetchSupplierWarrantyRecords( Set<String> assetIds ) {

        List<AssetWarranty> assetWarranties = new List<AssetWarranty>();

        assetWarranties = SvmxDatabase.query( [Select Id, AssetWarrantyNumber, SVMXA360__SupplierAccountId__c, SVMXA360__SupplierAccountId__r.Name, SVMXA360__SupplierContactId__c, AssetId, Asset.Name, EndDate, WarrantyTermId, WarrantyTerm.WarrantyTermName from AssetWarranty where WarrantyType = 'Supplier' AND AssetId IN :assetIds AND EndDate >= TODAY] );

        if ( assetWarranties != null && !assetWarranties.isEmpty() ) {
            return assetWarranties;
        } 
        
        List<Asset> assetRecords = SvmxDatabase.query( [Select Id from Asset where parentId IN :assetIds ] );
        Map<String,Asset> assetRecordMap = new Map<String,Asset>();

        if ( assetRecords != null && !assetRecords.isEmpty() ) {

            assetRecordMap = new Map<String,Asset>(assetRecords);
            fetchSupplierWarrantyRecords(assetRecordMap.keySet());
        } 
        else {
            return assetWarranties;
        }
        
        return fetchSupplierWarrantyRecords(assetRecordMap.keySet());
    }

    /**
     * Private method to create filter query criteria for the sObject record.
     */
    private static Config.FilterCriteria createFilterCriteria( String recordId, String sObjectName ) {
        
        Config.FilterCriteria filterWrapperData = new Config.FilterCriteria();
        filterWrapperData.id = recordId;
        filterWrapperData.objectName = sObjectName;
        filterWrapperData.fields = new List<String>{'AssetId','SVMXA360__SupplierWarranty__c'};
        if( sObjectName.equalsIgnoreCase('ReturnOrder') ) {
            filterWrapperData.fields = new List<String>{'SVMXA360__AssetId__c','SVMXA360__SupplierWarranty__c'};
        } 
         
        return filterWrapperData;
    }

    /**
     * Private method to update suplier warranty field indicator on source record.
     */
    private void updateSourceRecord( SObject sourceRecord, List<Warr.SupplierWarranty> supplierWarranties ) {
        
        
        Boolean existingSupplierWarranty;
        
        if (sourceRecord.get('SVMXA360__SupplierWarranty__c') != null) {
            existingSupplierWarranty = (Boolean)sourceRecord.get('SVMXA360__SupplierWarranty__c');
        }
        

        if ( supplierWarranties.size() > 0) {
            sourceRecord.put('SVMXA360__SupplierWarranty__c',true);
        } else {
            sourceRecord.put('SVMXA360__SupplierWarranty__c',false);
        }
        
        if (existingSupplierWarranty != (Boolean)sourceRecord.get('SVMXA360__SupplierWarranty__c')) {
            SvmxDatabase.upsertRecord(sourceRecord);
        }
        
    }

    private Warr.SupplierWarranty buildSupplierWarranty ( AssetWarranty assetWarrantyRecord ) {

        Warr.SupplierWarranty supplierWarranty = new Warr.SupplierWarranty();
        supplierWarranty.id = assetWarrantyRecord.Id;
        supplierWarranty.name = assetWarrantyRecord.AssetWarrantyNumber;
        supplierWarranty.componentId = assetWarrantyRecord.AssetId;
        supplierWarranty.componentName = assetWarrantyRecord.Asset.Name;
        supplierWarranty.supplierName = assetWarrantyRecord.SVMXA360__SupplierAccountId__r.Name;
        supplierWarranty.expireDate = assetWarrantyRecord.EndDate;
        supplierWarranty.warrantyTermId = assetWarrantyRecord.WarrantyTermId;
        supplierWarranty.warrantyTermName = assetWarrantyRecord.WarrantyTerm.WarrantyTermName ;

        return supplierWarranty;
    }
}