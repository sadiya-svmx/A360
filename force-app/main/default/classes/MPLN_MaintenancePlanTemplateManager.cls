/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods with actual implementation which will be
 * comsumed by the class MPLN_MaintenancePlanTemplate_LS.
 *
 * @author Manish Kushwah
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Manish Kushwah          08 Apr 2021     Created.
 *              Soumyaranjan Pati       14 Apr 2021     Updated code for Work rule service
 *              Manish Kushwah          16 Apr 2021     Updated Applicable Product delete service and added getProductList service
 *              Soumyaranjan Pati       24 May 2021     Updated code for Recurrence Pattern validation
 * A360AM-1513  Manish Kushwah          29 Oct 2021     Updated to support Criteria-based Maintenance Work Rule
 *****************************************************************************************************/
public with sharing class MPLN_MaintenancePlanTemplateManager {

    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final MPLN_MaintenancePlanTemplateManager instance = new MPLN_MaintenancePlanTemplateManager();
    private Map<String, Schema.SObjectField> mPlanFieldMap = COMM_DescribeManager.getInstance().getObjectFieldMap('MaintenancePlan');
    private final String FREQUENCY_FIELD = 'Frequency';

    /**
     * Public method to retrieve instance of this class.
     */
    public static MPLN_MaintenancePlanTemplateManager getInstance() {
        return instance;
    }

    /**
     * This method is used to retrieve all Applicable Products records associated with 
     * the particular Maintenance Plan Template.
     */
    public List<Mpln.ApplicableProduct> getAllApplicableProducts( final String maintenancePlanTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllApplicableProducts() - enter: maintenancePlanTemplateId= ' + maintenancePlanTemplateId );
        
        List<Mpln.ApplicableProduct> applicableProductList = new List<Mpln.ApplicableProduct>();
        
        try {

            if( String.isBlank(maintenancePlanTemplateId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' maintenancePlanTemplateId= ' + maintenancePlanTemplateId );
            }

            applicableProductList = buildApplicableProducts( getAllApplicableProductRecords( maintenancePlanTemplateId ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllApplicableProducts() : Failed to retrieve Applicable Products. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllApplicableProducts() : Failed to retrieve Applicable Products. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllApplicableProducts() - exit; applicableProductList= ' + applicableProductList );
        }
        
        return applicableProductList;
    }

    /**
     * This method is used to retrieve Applicable Product record for 
     * the requested Applicable Product Id.
     */
    public Mpln.ApplicableProduct getApplicableProduct( final String applicableProductId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getApplicableProduct() - enter: applicableProductId= ' + applicableProductId );
        
        Mpln.ApplicableProduct applicableProduct = new Mpln.ApplicableProduct();
        
        try {

            if( String.isBlank(applicableProductId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' applicableProductId= ' + applicableProductId );
            }

            applicableProduct = buildApplicableProduct( getApplicableProductRecord( applicableProductId ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getApplicableProduct() : Failed to retrieve Applicable Product. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getApplicableProduct() : Failed to retrieve Applicable Product. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getApplicableProduct() - exit; applicableProduct= ' + applicableProduct );
        }
        
        return applicableProduct;
    }

    /**
     * This method is used to save list of Applicable Product.
     */
    public List<Mpln.ApplicableProduct> saveApplicableProducts( final List<Mpln.ApplicableProduct> applicableProducts ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveApplicableProducts() - enter; applicableProducts= ' + applicableProducts );
        
        try {
            if( applicableProducts == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' applicableProducts= ' + applicableProducts );
            }
            
            List<SVMXA360__ApplicableProduct__c> applicableProductRecords = buildApplicableProducts(applicableProducts);
            
            applicableProductRecords = SvmxDatabase.upsertRecord(applicableProductRecords);
            
            for( Integer index = 0; index < applicableProductRecords.size(); index++ ) {
                applicableProducts.get(index).id = applicableProductRecords.get(index).id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveApplicableProducts() : Failed to save Applicable Products. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveApplicableProducts() : Failed to save Applicable Products. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveApplicableProducts() - exit; applicableProducts= ' + applicableProducts );
        }
        
        return applicableProducts;
    }

    /**
     * This method is used to delete Applicable Product record
     */
    public void deleteApplicableProduct( final String applicableProductId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteApplicableProduct() - enter; applicableProductId= ' + applicableProductId );
        Savepoint savepoint;
        
        try {
            savepoint = Database.setSavepoint();
            
            if( String.isBlank(applicableProductId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' applicableProductId= ' + applicableProductId );
            }
            
            SVMXA360__ApplicableProduct__c applicableProductRecord = getApplicableProductRecord( applicableProductId );

            List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateRecords =  getWorkRuleTemplateRelatedToAP( applicableProductRecord.id );

            if ( !workRuleTemplateRecords.isEmpty() ) {
                SvmxDatabase.deleteRecord(workRuleTemplateRecords);
            }
            
            SvmxDatabase.deleteRecord(applicableProductRecord);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            Database.rollback(savepoint);
            System.debug( LoggingLevel.ERROR, 'deleteApplicableProduct() : Failed to delete Applicable Product. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            Database.rollback(savepoint);
            System.debug( LoggingLevel.ERROR, 'deleteApplicableProduct() : Failed to delete Applicable Product. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteApplicableProduct() - exit' );
        }
    }

    /**
     * This method is used to retrieve Product record list for 
     * the requested search keyword.
     */
    public List<Mpln.ProductInformation> getProductList( final String searchKeyword ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProductList() - enter: searchKeyword= ' + searchKeyword );
        
        List<Mpln.ProductInformation> products = new List<Mpln.ProductInformation>();
        
        try {

            if( String.isBlank(searchKeyword) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' searchKeyword= ' + searchKeyword );
            }

            products = buildProductInformations( getProductRecords( searchKeyword ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProductList() : Failed to retrieve Product records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getProductList() : Failed to retrieve Product records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getProductList() - exit; products= ' + products );
        }
        
        return products;
    }

    

    /**
     * This method is used to retrieve all Maintenance WorkRule Templates records associated with 
     * the particular Maintenance Plan Template.
     */
    public List<Mpln.WorkRuleTemplate> getAllMaintenanceWorkRuleTemplates( final String maintenancePlanTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceWorkRuleTemplates() - enter' );
        
        List<Mpln.WorkRuleTemplate> maintenanceWRTemplatesList = new List<Mpln.WorkRuleTemplate>();
        Map<String, String> rfcIdAndNameMap = new Map<String, String>();
        
        try {

            if( String.isBlank(maintenancePlanTemplateId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' maintenancePlanTemplateId= ' + maintenancePlanTemplateId );
            }

            List<SVMXA360__MaintenanceWorkRuleTemplate__c> maintenanceWorkRuleTemplateList = getAllMaintenanceWorkRuleTemplatesRecords( maintenancePlanTemplateId );

            Set<String> recordsetFilterCriteriaIds = new Set<String>();
            for ( SVMXA360__MaintenanceWorkRuleTemplate__c wrtRecord : maintenanceWorkRuleTemplateList ) {
                
                if ( String.isNotBlank(wrtRecord.SVMXA360__RecordsetFilterCriteriaId__c) ) {
                    recordsetFilterCriteriaIds.add(wrtRecord.SVMXA360__RecordsetFilterCriteriaId__c);
                }
            }

            if ( !recordsetFilterCriteriaIds.isEmpty() ) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                List<RecordsetFilterCriteria> recordsetFilterCriteriaList = SvmxDatabase.query([SELECT Id, Name FROM RecordsetFilterCriteria WHERE Id IN: recordsetFilterCriteriaIds]);

                for (RecordsetFilterCriteria recordsetFilterCriteriaRecord : recordsetFilterCriteriaList) {
                    rfcIdAndNameMap.put( recordsetFilterCriteriaRecord.Id, recordsetFilterCriteriaRecord.Name );
                }
            }

            maintenanceWRTemplatesList = buildMaintenanceWorkRuleTemplates( maintenanceWorkRuleTemplateList, rfcIdAndNameMap );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllMaintenanceWorkRuleTemplates() : Failed to retrieve Maintenance WorkRule Templates. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllMaintenanceWorkRuleTemplates() : Failed to retrieve Maintenance WorkRule Templates. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceWorkRuleTemplates() - exit; maintenanceWRTemplatesList= ' + maintenanceWRTemplatesList );
        }
        
        return maintenanceWRTemplatesList;
    }

    /**
     * This method is used to delete requested Maintenance WorkRule Template information.
     */
    public void deleteMaintenanceWorkRuleTemplate( final String workRuleTemplateId ) {
        
        System.debug( LoggingLevel.FINEST, 'deleteMaintenanceWorkRuleTemplate() - enter; workRuleTemplateId= ' + workRuleTemplateId );
        
        try {
            
            // Verify for valid Maintenance WorkRule Template id to perform delete operation.
            if( String.isBlank(workRuleTemplateId) ) {
                
                System.debug( LoggingLevel.ERROR, 'deleteMaintenanceWorkRuleTemplate() : Invalid request parameters. workRuleTemplateId= ' + workRuleTemplateId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE Id = :workRuleTemplateId] );
            System.debug( LoggingLevel.INFO, 'deleteMaintenanceWorkRuleTemplate() : deleted workRuleTemplateId= ' + workRuleTemplateId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteMaintenanceWorkRuleTemplate() : Failed to delete Maintenance WorkRule Template. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteMaintenanceWorkRuleTemplate() : Failed to delete Maintenance WorkRule Template. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'deleteMaintenanceWorkRuleTemplate() - exit; ' );
        }
    }

    /**
     * This method is used to retrieve Applicable Product records for requested Maintenance Plan Template Id.
     */
    private List<SVMXA360__ApplicableProduct__c> getAllApplicableProductRecords( final String maintenancePlanTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllApplicableProductRecords() - enter: maintenancePlanTemplateId= ' + maintenancePlanTemplateId );
        /* sfge-disable-next-line ApexFlsViolationRule */
        List<SVMXA360__ApplicableProduct__c> applicableProductRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name, SVMXA360__WorkTypeId__c, SVMXA360__WorkTypeId__r.Name, toLabel(SVMXA360__ProductFamily__c), SVMXA360__ProductId__c, SVMXA360__ProductId__r.Name FROM SVMXA360__ApplicableProduct__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: maintenancePlanTemplateId ORDER BY Name]);

        System.debug( LoggingLevel.DEBUG, 'getAllApplicableProductRecords() - exit' );
        
        return applicableProductRecords;
    }

    /**
     * This method is used to retrieve Product records for requested search keyword.
     */
    private List<Product2> getProductRecords( final String searchKeyword ) {
        
        System.debug( LoggingLevel.DEBUG, 'getProductRecords() - enter: searchKeyword= ' + searchKeyword );
        
        List<Product2> productRecords = new List<Product2>();
        
        String query = 'SELECT Id, Name, IsActive, toLabel(Family), Description FROM Product2 WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\' OR Family LIKE \'%' + String.escapeSingleQuotes(searchKeyword) + '%\' ORDER BY Name LIMIT 50';
        productRecords = SvmxDatabase.query(query);

        System.debug( LoggingLevel.DEBUG, 'getProductRecords() - exit' );
        
        return productRecords;
    }

    /**
     * This method is used to retrieve Maintenance Work Rule Template records related to Applicable Product.
     */
    private List<SVMXA360__MaintenanceWorkRuleTemplate__c> getWorkRuleTemplateRelatedToAP( final String applicableProductId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getWorkRuleTemplateRelatedToAP() - enter: applicableProductId= ' + applicableProductId );
        
        List<SVMXA360__MaintenanceWorkRuleTemplate__c> workRuleTemplateRecords = SvmxDatabase.query([SELECT Id FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__ApplicableProductId__c =: applicableProductId]);

        System.debug( LoggingLevel.DEBUG, 'getWorkRuleTemplateRelatedToAP() - exit' );
        
        return workRuleTemplateRecords;
    }

    /**
     * Retrieve Applicable Product record.
     */
    private SVMXA360__ApplicableProduct__c getApplicableProductRecord( final String applicableProductId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getApplicableProductRecord() - enter: applicableProductId= ' + applicableProductId );
        
        SVMXA360__ApplicableProduct__c applicableProductRecord;
        
        try {
            /* sfge-disable-next-line ApexFlsViolationRule */
            final List<SVMXA360__ApplicableProduct__c> applicableProductRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name, SVMXA360__WorkTypeId__c, SVMXA360__WorkTypeId__r.Name, SVMXA360__ProductFamily__c, SVMXA360__ProductId__c, SVMXA360__ProductId__r.Name FROM SVMXA360__ApplicableProduct__c WHERE Id = :applicableProductId]);
                
            if( applicableProductRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' applicableProductId= ' + applicableProductId );
            }
            
            applicableProductRecord = applicableProductRecords.get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getApplicableProductRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getApplicableProductRecord() - exit' );
        }
        
        return applicableProductRecord;
    }

    /**
     * This method is used to Upsert the requested Maintenance WorkRule Template information.
     */
    public void saveMaintenanceWorkRuleTemplate( final List<Mpln.WorkRuleTemplate> workRuleTemplates ) {
        
        System.debug( LoggingLevel.FINEST, 'saveMaintenanceWorkRuleTemplate() - enter; workRuleTemplates= ' + workRuleTemplates );
        
        try {
            
            // Verify for valid data to perform upsert operation.
            if( workRuleTemplates == null || workRuleTemplates.isEmpty()) {

                System.debug( LoggingLevel.ERROR, 'saveMaintenanceWorkRuleTemplate() : Invalid request parameters. workRuleTemplates= ' + workRuleTemplates );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            

            List<SVMXA360__MaintenanceWorkRuleTemplate__c> listMaintenceWorkRuleTemplate = buildMaintenanceWorkRuleTemplates( workRuleTemplates );

            if ( String.isBlank(listMaintenceWorkRuleTemplate[0].SVMXA360__Type__c) || listMaintenceWorkRuleTemplate[0].SVMXA360__Type__c == 'Calendar' ) {
                // Verify the Recurrence Pattern.
                Map<String,String> mapRecPatterns =  checkRecurrencePattern( listMaintenceWorkRuleTemplate );
                for (SVMXA360__MaintenanceWorkRuleTemplate__c mplanWRule : listMaintenceWorkRuleTemplate) {
                    if( mapRecPatterns.containsKey(mplanWRule.SVMXA360__RecurrencePattern__c) && mapRecPatterns.get(mplanWRule.SVMXA360__RecurrencePattern__c).equalsIgnoreCase(System.Label.Error_Invalid_Recurrence_Pattern) ) {
                        System.debug( LoggingLevel.ERROR, 'saveMaintenanceWorkRuleTemplate() : Invalid Recurrence Pattern. ' );
                        throw new SvmxSystem.SvmxNestedException( System.Label.Error_Invalid_Recurrence_Pattern );
                    }
                }
            }

            if ( !listMaintenceWorkRuleTemplate.isEmpty() ) {
                SvmxDatabase.upsertRecord(listMaintenceWorkRuleTemplate);
            }

            System.debug( LoggingLevel.INFO, 'saveMaintenanceWorkRuleTemplate() : Upserted workRuleTemplates= ' + workRuleTemplates );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveMaintenanceWorkRuleTemplate() : Failed to Upsert Maintenance WorkRule Template. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveMaintenanceWorkRuleTemplate() : Failed to Upsert Maintenance WorkRule Template. Error' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINEST, 'saveMaintenanceWorkRuleTemplate() - exit; workRuleTemplates= ' + workRuleTemplates );
        }
    }


    /**
     * This method is used to validate the RecurrencePattern on MaintenanceWorkRule object.
     */
    public Map<String,String> checkRecurrencePattern( final List<SVMXA360__MaintenanceWorkRuleTemplate__c> listMaintenceWorkRuleTemplate ) {
        
        System.debug( LoggingLevel.DEBUG, 'checkRecurrencePattern() - enter, listMaintenceWorkRuleTemplate '+listMaintenceWorkRuleTemplate );
        
        String returnMessage;
        Map<String,String> mapOfRecPatterns = new Map<String,String>();
        

        Savepoint sp = Database.setSavepoint();
        
        try {
            
            List<MaintenanceWorkRule> listMWorkRule = new List<MaintenanceWorkRule>();
            MaintenancePlan mplan = new MaintenancePlan();
            mplan.StartDate = System.today();
            mplan.NextSuggestedMaintenanceDate = System.today();
            if (!mPlanFieldMap.isEmpty() && mPlanFieldMap.containsKey(FREQUENCY_FIELD)) {
                mplan.put(FREQUENCY_FIELD, 1);
            }
            mplan.GenerationTimeframe = 1;
            mplan = (MaintenancePlan) SvmxDatabase.insertRecord(mplan);

            for ( SVMXA360__MaintenanceWorkRuleTemplate__c mplanWorkRule : listMaintenceWorkRuleTemplate) {
                mapOfRecPatterns.put(mplanWorkRule.SVMXA360__RecurrencePattern__c,'');
                MaintenanceWorkRule maintenanceWRule =  new MaintenanceWorkRule();
                maintenanceWRule.Title	= 'Check MaintenanceWorkRule';
                maintenanceWRule.SortOrder = 1;
                maintenanceWRule.RecurrencePattern = mplanWorkRule.SVMXA360__RecurrencePattern__c;
                maintenanceWRule.ParentMaintenancePlanId = mplan.id;
                listMWorkRule.add(maintenanceWRule);
            }
            if(SvmxDatabase.verifyFLSAccess(listMWorkRule,AccessType.CREATABLE)){
                Database.SaveResult[] srList = Database.insert(listMWorkRule, false);
    
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            for (String recName : mapOfRecPatterns.keySet()) {
                                if (err.getMessage().containsIgnoreCase(recName) && err.getMessage().containsIgnoreCase('Check the RRULE format.')) {
                                    mapOfRecPatterns.put(recName, System.Label.Error_Invalid_Recurrence_Pattern);
                                }
                            }
                        }
                    }
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'checkRecurrencePattern() : Error=' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'checkRecurrencePattern() - exit' );
            Database.RollBack(sp);
        }
        
        return mapOfRecPatterns;
    }

    /**
     * This method is used to retrieve Maintenance WorkRule Templates records for requested Maintenance Plan Template Id.
     */
    private List<SVMXA360__MaintenanceWorkRuleTemplate__c> getAllMaintenanceWorkRuleTemplatesRecords( final String maintenancePlanTemplateId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceWorkRuleTemplatesRecords() - enter' );
        
        List<SVMXA360__MaintenanceWorkRuleTemplate__c> maintenanceWorkRuleTemplatesRecords = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();
        /* sfge-disable-next-line ApexFlsViolationRule */
        maintenanceWorkRuleTemplatesRecords = SvmxDatabase.query([SELECT Id, Name, SVMXA360__ApplicableProductId__c, SVMXA360__ApplicableProductId__r.Name, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name, SVMXA360__SortOrder__c, SVMXA360__WorkTypeId__c, SVMXA360__WorkTypeId__r.Name, SVMXA360__RecurrencePattern__c, SVMXA360__TemplateType__c, SVMXA360__Type__c, SVMXA360__RecordsetFilterCriteriaId__c FROM SVMXA360__MaintenanceWorkRuleTemplate__c WHERE SVMXA360__MaintenancePlanTemplateId__c =: maintenancePlanTemplateId]);

        System.debug( LoggingLevel.DEBUG, 'getAllMaintenanceWorkRuleTemplatesRecords() - exit' );
        
        return maintenanceWorkRuleTemplatesRecords;
    }

    private List<Mpln.ApplicableProduct> buildApplicableProducts( final List<SVMXA360__ApplicableProduct__c> applicableProductRecords ) {
        
        final List<Mpln.ApplicableProduct> applicableProductList = new List<Mpln.ApplicableProduct>();
        if( applicableProductRecords != null && !applicableProductRecords.isEmpty() ) {
            
            for( SVMXA360__ApplicableProduct__c applicableProductRecord : applicableProductRecords ) {
                applicableProductList.add( buildApplicableProduct(applicableProductRecord) );
            }
        }
        
        return applicableProductList;
    }

    private List<SVMXA360__ApplicableProduct__c> buildApplicableProducts( final List<Mpln.ApplicableProduct> applicableProducts ) {
        
        final List<SVMXA360__ApplicableProduct__c> applicableProductRecords = new List<SVMXA360__ApplicableProduct__c>();
        for( Mpln.ApplicableProduct applicableProduct : applicableProducts ) {
            applicableProductRecords.add( buildApplicableProductRecord(applicableProduct) );
        }
        
        return applicableProductRecords;
    }

    private SVMXA360__ApplicableProduct__c buildApplicableProductRecord( final Mpln.ApplicableProduct applicableProduct ) {
        
        final SVMXA360__ApplicableProduct__c applicableProductRecord = new SVMXA360__ApplicableProduct__c();
        
        if( applicableProduct.id != null ) {
            applicableProductRecord.id = applicableProduct.id;
        } else {
            applicableProductRecord.SVMXA360__MaintenancePlanTemplateId__c = applicableProduct.maintenancePlanTemplateId;
        }
        
        applicableProductRecord.SVMXA360__WorkTypeId__c = applicableProduct.workTypeId;
        applicableProductRecord.SVMXA360__ProductId__c = applicableProduct.productId;
        applicableProductRecord.SVMXA360__ProductFamily__c = applicableProduct.productFamily;
        
        return applicableProductRecord;
    }

    private Mpln.ApplicableProduct buildApplicableProduct( final SVMXA360__ApplicableProduct__c applicableProductRecord ) {
        
        final Mpln.ApplicableProduct applicableProduct = new Mpln.ApplicableProduct();
        applicableProduct.id = applicableProductRecord.id;
        applicableProduct.name = applicableProductRecord.name;
        applicableProduct.lastModifiedDate = applicableProductRecord.LastModifiedDate;
        applicableProduct.lastModifiedBy = applicableProductRecord.LastModifiedBy.Name;
        applicableProduct.maintenancePlanTemplateId = applicableProductRecord.SVMXA360__MaintenancePlanTemplateId__c;
        applicableProduct.maintenancePlanTemplateName = applicableProductRecord.SVMXA360__MaintenancePlanTemplateId__r.Name;
        applicableProduct.workTypeId = applicableProductRecord.SVMXA360__WorkTypeId__c;
        applicableProduct.workTypeName = applicableProductRecord.SVMXA360__WorkTypeId__r.Name;
        applicableProduct.productFamily = applicableProductRecord.SVMXA360__ProductFamily__c;
        applicableProduct.productId = applicableProductRecord.SVMXA360__ProductId__c;
        applicableProduct.productName = applicableProductRecord.SVMXA360__ProductId__r.Name;

        return applicableProduct;
    }

    private List<Mpln.WorkRuleTemplate> buildMaintenanceWorkRuleTemplates( final List<SVMXA360__MaintenanceWorkRuleTemplate__c> maintenanceWorkRuleTemplatesRecords, final Map<String, String> rfcIdAndNameMap ) {
        
        final List<Mpln.WorkRuleTemplate> workRuleTemplateList = new List<Mpln.WorkRuleTemplate>();
        if( maintenanceWorkRuleTemplatesRecords != null && !maintenanceWorkRuleTemplatesRecords.isEmpty() ) {
            
            for( SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRecord : maintenanceWorkRuleTemplatesRecords ) {
                workRuleTemplateList.add( buildMaintenanceWorkRuleTemplate( workRuleTemplateRecord, rfcIdAndNameMap ) );
            }
        }
        
        return workRuleTemplateList;
    }

    private List<SVMXA360__MaintenanceWorkRuleTemplate__c> buildMaintenanceWorkRuleTemplates( final List<Mpln.WorkRuleTemplate> maintenanceWorkRuleTemplatesRecords ) {
        
        final List<SVMXA360__MaintenanceWorkRuleTemplate__c> maintenanceWorkRuleTemplatesSobjectRecords = new List<SVMXA360__MaintenanceWorkRuleTemplate__c>();
        for( Mpln.WorkRuleTemplate maintenanceWorkRuleTemplatesRecord : maintenanceWorkRuleTemplatesRecords ) {
            maintenanceWorkRuleTemplatesSobjectRecords.add( buildMaintenanceWorkRuleTemplate(maintenanceWorkRuleTemplatesRecord) );
        }
        
        return maintenanceWorkRuleTemplatesSobjectRecords;
    }

    private List<Mpln.ProductInformation> buildProductInformations( final List<Product2> productInformationRecords ) {
        
        final List<Mpln.ProductInformation> productInformationList = new List<Mpln.ProductInformation>();
        if( productInformationRecords != null && !productInformationRecords.isEmpty() ) {
            
            for( Product2 productInformationRecord : productInformationRecords ) {
                productInformationList.add( buildProductInformation(productInformationRecord) );
            }
        }
        
        return productInformationList;
    }

    private SVMXA360__MaintenanceWorkRuleTemplate__c buildMaintenanceWorkRuleTemplate( final Mpln.WorkRuleTemplate workRuleTemplateRecordWrapper ) {
        
        SVMXA360__MaintenanceWorkRuleTemplate__c maintenceWorkRuleTemplate = new SVMXA360__MaintenanceWorkRuleTemplate__c();
        if ( workRuleTemplateRecordWrapper.id != null ) {
            maintenceWorkRuleTemplate.id = workRuleTemplateRecordWrapper.id;
        }
        maintenceWorkRuleTemplate.name = workRuleTemplateRecordWrapper.name;
        maintenceWorkRuleTemplate.SVMXA360__MaintenancePlanTemplateId__c = workRuleTemplateRecordWrapper.maintenancePlanTemplateId;
        maintenceWorkRuleTemplate.SVMXA360__ApplicableProductId__c = workRuleTemplateRecordWrapper.applicableProductId;
        maintenceWorkRuleTemplate.SVMXA360__WorkTypeId__c = workRuleTemplateRecordWrapper.workTypeId;
        maintenceWorkRuleTemplate.SVMXA360__RecurrencePattern__c = workRuleTemplateRecordWrapper.recurrencePattern;
        maintenceWorkRuleTemplate.SVMXA360__SortOrder__c = workRuleTemplateRecordWrapper.sortOrder;
        maintenceWorkRuleTemplate.SVMXA360__Type__c = workRuleTemplateRecordWrapper.type;
        maintenceWorkRuleTemplate.SVMXA360__RecordsetFilterCriteriaId__c = workRuleTemplateRecordWrapper.recordsetFilterCriteriaId;

        return maintenceWorkRuleTemplate;
    }

    private Mpln.WorkRuleTemplate buildMaintenanceWorkRuleTemplate( final SVMXA360__MaintenanceWorkRuleTemplate__c workRuleTemplateRecord, final Map<String, String> rfcIdAndNameMap ) {
        
        final Mpln.WorkRuleTemplate workRuleTemplate = new Mpln.WorkRuleTemplate();
        workRuleTemplate.id = workRuleTemplateRecord.id;
        workRuleTemplate.name = workRuleTemplateRecord.name;
        workRuleTemplate.maintenancePlanTemplateId = workRuleTemplateRecord.SVMXA360__MaintenancePlanTemplateId__c;
        workRuleTemplate.maintenancePlanTemplateName = workRuleTemplateRecord.SVMXA360__MaintenancePlanTemplateId__r.Name;
        workRuleTemplate.applicableProductId = workRuleTemplateRecord.SVMXA360__ApplicableProductId__c;
        workRuleTemplate.applicableProductName = workRuleTemplateRecord.SVMXA360__ApplicableProductId__r.Name;
        workRuleTemplate.workTypeId = workRuleTemplateRecord.SVMXA360__WorkTypeId__c;
        workRuleTemplate.workTypeName = workRuleTemplateRecord.SVMXA360__WorkTypeId__r.Name;
        workRuleTemplate.templateType = workRuleTemplateRecord.SVMXA360__TemplateType__c;
        workRuleTemplate.recurrencePattern = workRuleTemplateRecord.SVMXA360__RecurrencePattern__c;
        workRuleTemplate.sortOrder = Integer.valueOf(workRuleTemplateRecord.SVMXA360__SortOrder__c);
        workRuleTemplate.type = String.isNotBlank(workRuleTemplateRecord.SVMXA360__Type__c) ? workRuleTemplateRecord.SVMXA360__Type__c : 'Calendar' ;
        workRuleTemplate.recordsetFilterCriteriaId = workRuleTemplateRecord.SVMXA360__RecordsetFilterCriteriaId__c;
        workRuleTemplate.recordsetFilterCriteriaName = rfcIdAndNameMap.get(workRuleTemplateRecord.SVMXA360__RecordsetFilterCriteriaId__c);

        return workRuleTemplate;
    }

    private Mpln.ProductInformation buildProductInformation( final Product2 productInformationRecord ) {
        
        final Mpln.ProductInformation productInformation = new Mpln.ProductInformation();
        productInformation.id = productInformationRecord.id;
        productInformation.name = productInformationRecord.Name;
        productInformation.productFamily = productInformationRecord.Family;
        productInformation.isActive = productInformationRecord.IsActive;
        productInformation.description = productInformationRecord.Description;

        return productInformation;
    }
}