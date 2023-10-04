/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This abstract class facilitates methods to perform auto/interactive entitlement.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       09 Jul 2020     Created.
 * BLOS-313     Ramachandra Mohan		31 Jul 2020		Update retrieve source record method to only query required fields.
 * BLOS-564     Ramachandra Mohan       20 Aug 2020     Fixed issue on custom asset field in source object.
 * BLOS-613     Ramachandra Mohan       26 Aug 2020     Support warranty type filtering on Asset Warranty.
 * BLOS-664     Ramachandra Mohan       28 Aug 2020     Entitlement Notes issue fix.
 * BLOS-907     Ramachandra Mohan       30 Sep 2020     Additional validation to check remaining cases for Entitlement.
 * A360CE-329   Ramachandra Mohan       14 Dec 2020     Select header entitlement if not exists for contract line.
 * A360CE-412   Ramachandra Mohan       17 Dec 2020     Update Billing Type for valid service coverage.
 * A360CE-124   Ramachandra Mohan       21 Dec 2020     Invoke Autolaunch flow to trigger milestone.
 * A360CE-423   Ramachandra Mohan       28 Dec 2020     Update default billing type on no coverage.
 * A360CE-422   Ramachandra Mohan       07 Jan 2021     Update billing type only when service count is > 0.
 * A360CE-436   Ramachandra Mohan       07 Jan 2021     Duplicate entitlement record issue fix.
 * A360CE-447   Ramachandra Mohan       18 Jan 2021     Support Billing Type in Interactive entitlement save.
 * A360CE-714   Ramachandra Mohan       02 Mar 2021     Set Default Billing Type if not set in any other scenarios.
 * A360CE-746   Ramachandra Mohan       28 Mar 2021     Include Fully Consumed Services.
 * A360AM-1574  Ramachandra Mohan       02 Dec 2021     Respect Contract Availability Status for Auto-entitlement.
 * A360AM-1584  Sandeep Dhariwal        23 Dec 2021     Respect Contract Availability Status for Interactive-entitlement.
 * A360CE-936   Sandeep Dhariwal        23 Dec 2021     Changes to optimize. Only query entitlements related to CLIs when covered by asset.
 * A360CE-989   Sandeep Dhariwal        08 Apr 2022     Stack Ranking Changes.
 *****************************************************************************************************/
public with sharing abstract class EVER_AbstractEntitlementEngine {

    /**
     * Private static variable to hold logger instance for entitlement.
     */
    protected final SvmxLogger Logger = SvmxLogger.getLogger( SvmxLogger.Application.Entitlement );

    // Static string variable to hold newline char.
    public static final String NEW_LINE								= '\n';

    // Static string variable to hold incident not covered string.
    public static final String INCIDENT_NOT_COVERED 				= System.Label.Info_IncidentNotCovered;

    // Static string variable to hold missing field to perform auto entitlement error.
    public static final String ERROR_ENVT_MISSING_FIELD				= System.Label.Info_AutoEntitlementNotPerformed;

    // Static string variable to hold missing field to perform auto entitlement error.
    public static final String ERROR_NO_QUALIFIED_RULE				= System.Label.Info_NoQualifiedEntitlementRule;

    // Static string variable to hold missing field to perform auto entitlement error.
    public static final String ERROR_CANNOT_ALLOW_ADDITIONAL_CASE	= System.Label.Error_CannotAllowAdditionalCase;

    // Static string variable to hold record type common configuration
    public static final String RECORD_TYPE_ENTITLED_SERVICE = 'EntitledServices';

    // Static string variable to hold record type sla
    public static final String RECORD_TYPE_SLA = 'SLA';

    // List of fields to be queried from Contract Line object.
    private final static List<String> ContractQueryFields = new List<String>{
        'Id',
        'AssetId',
        'StartDate',
        'EndDate',
        'ServiceContractId',
        'ServiceContract.Name',
        'ServiceContract.ContactId',
        'ServiceContract.AccountId',
        'ServiceContract.StartDate',
        'ServiceContract.EndDate',
        'ServiceContract.Pricebook2Id'
    };

    // List of fields to be quired from Asset Warranty object.
    private final static List<String> AssetWarrantyQueryFields = new List<String>{
        'Id',
        'AssetWarrantyNumber',
        'AssetId',
        'StartDate',
        'EndDate',
        'toLabel(WarrantyType)',
        'WarrantyTermId',
        'WarrantyTerm.WarrantyTermName',
        'Pricebook2Id'
    };
    // List of fields to be queried from Contract Line object.
    private final static List<String> ServiceContractQueryFields = new List<String>{
        'Id',
        'Name',
        'ContactId',
        'AccountId',
        'StartDate',
        'EndDate',
        'Pricebook2Id'
    };

    private final static List<String> EntitlementQueryFields = new List<String>{
      'Id',
      'Name',
      'AccountId',
      'AssetId',
      'StartDate',
      'EndDate',
      'ServiceContractId',
      'ContractLineItemId',
      'ContractLineItem.ServiceContractId',
      'SVMXA360__EntitledServiceId__c',
      'SVMXA360__ServiceCountAlertThreshold__c',
      'SVMXA360__TotalServiceCount__c',
      'SVMXA360__ConsumedServiceCount__c',
      'SVMXA360__ServiceAmountAlertThreshold__c',
      'SVMXA360__TotalServiceAmount__c',
      'SVMXA360__ConsumedServiceAmount__c',
      'SVMXA360__EntitledServiceProductId__c',
      'SVMXA360__ServiceCountType__c',
      'SVMXA360__WorkOrderEntitlementProcessId__c',
      'SVMXA360__CaseEntitlementProcessId__c',
      'ServiceContract.Pricebook2Id'
    };

    private final static List<String> CPLIQueryFields = new List<String>{
        'Id',
        'Name',
        'SVMXA360__ContractLineId__c',
        'SVMXA360__EntitledDiscount__c',
        'SVMXA360__EntitledPrice__c',
        'SVMXA360__EntitledServiceId__c',
        'SVMXA360__ExpenseItem__c',
        'SVMXA360__LineType__c',
        'SVMXA360__ProductId__r.Name',
        'SVMXA360__ProductFamily__c',
        'SVMXA360__ServiceContractId__c',
        'SVMXA360__Surcharge__c'
      };

    final Set<String> QualifiedAuthoringStatus = new Set<String> {
        'AuthoringCompleted',
        'InProgress'
    };

    // Map to hold source field name vs label map.
    protected final Map<String,String> sourceFieldLabelMap;

    // Protected string const to hold Contract.
    protected final String StringContract					= 'Contract';

    // Protected string const to hold Warranty.
    protected final String StringWarranty 					= 'Warranty';

    // Protected string const to hold Covered By Asset.
    protected final String StringAsset					= 'Asset';

    // Protected string const to hold Covered By Account.
    protected final String StringAccount				= 'Account';

    // Protected string const to hold Parent Asset.
    protected final String StringParentAsset			= 'Parent Asset';

    // Protected string const to hold Root Asset.
    protected final String StringRootAsset				= 'Root Asset';

    // Protected string const to hold WorkOrder.
    protected final String StringWorkOrder				= 'WorkOrder';

    // String instance variable to hold source object name.
    protected final String sourceObjectName;

    // Boolean instance variable to indicate whether the engine instance is auto entitlement or manual entitlement.
    protected Boolean isAutoEntitlement;

    // Map instance variable to hold entitlement fields.
    protected Map<Ever.EntitlementField, String> entitlementFieldMap;

    // Map instance variable to hold asset records.
    protected Map<Id, Asset> assetRecordsMap;

    // Map instance variable to hold entitlement configuration for each source records.
    private Map<Id, Adm.EntitlementBase> sourceIdEntitlementBaseMap = new Map<Id,Adm.EntitlementBase>();

    // Entitled service source record map
    private Map<String, List<SObject>> entitledServiceSourceMap = new Map<String, List<SObject>>();

    // List of qualified entitlements
    private final List<Entitlement> entitlementList = new List<Entitlement>();

    // Entitled service map
    private Map<Id, Ever.CoverageInfo> entitledServiceMap = new Map<Id, Ever.CoverageInfo>();

    // Public nested class to hole entitlement params.
    public class EntitlementParams {

        // Set of all qualified asset ids.
        public Set<String> assetIds = new Set<String>();

        // Set of all qualified account ids.
        public Set<String> accountIds = new Set<String>();

        // Set of all qualified contact ids.
        public Set<String> contactIds = new Set<String>();

        // Set of all qualified service Contract ids.
        public Set<String> serviceContractIds = new Set<String>();

        // Set of all warrantyTypes.
        public Set<String> warrantyTypes = new Set<String>();

        // List of where clause using which service contract records are queried.
        public List<String> serviceContractWhereClauseList = new List<String>();

        // List of where clause using which contract records are queried.
        public List<String> contractWhereClauseList = new List<String>();

        // List of where clause using which contract records are queried.
        public List<String> entitlementWhereClauseList = new List<String>();

        // List of where clause using which warrenty records are queried.
        public List<String> warrantyWhereClauseList = new List<String>();

        // Contract id vs List of Entitlements records.
        public Map<id, List<Entitlement>> coverageEntitlementMap = new Map<id, List<Entitlement>>();

        // Asset id vs List of queried ContractlineItem records.
        public Map<id, List<ContractLineItem>> assetContractMap = new Map<id, List<ContractLineItem>>();

        // Account id vs List of queried ContractlineItem records.
        public Map<id, List<ContractLineItem>> accountContractMap = new Map<id, List<ContractLineItem>>();

        // Asset id vs List of queried Warranty records.
        public Map<id, List<AssetWarranty>> assetWarrantyMap = new Map<id, List<AssetWarranty>>();
        // Account id vs List of queried ServiceContract records.
        public Map<id, List<ServiceContract>> accountServiceContractMap = new Map<id, List<ServiceContract>>();

        // Entitlement id vs List of CPLI records.
        public Map<id, List<SVMXA360__ContractPriceLineItem__c>> entitlementCPLIMap = new Map<id, List<SVMXA360__ContractPriceLineItem__c>>();

    }

    public class StackRankingParameters {

        public Boolean applyStackRanking;

        public String cliStackRankingField;

        public String sconStackRankingField;

        public String warrantyStackRankingField;

        public String contractStackRankingOrder;

        public String warrantyStackRankingOrder;

        public String cliStackRankingClause;

        public String sconStackRankingClause;

        public String warrantyStackRankingClause;
    }

    /**
     * Class constructor to create instance of this class.
     *
     * @param sourceObjectName Source object name for which the engine to be execured.
     * @param isAutoEntitlement Boolean flag to indicate whether this engine is auto entitlement or not.
     */
    public EVER_AbstractEntitlementEngine( final String sourceObjectName, final Boolean isAutoEntitlement ) {

        if( String.isBlank( sourceObjectName ) ) {

            System.debug( LoggingLevel.ERROR, 'EVER_CheckEntitlementEngine() : Invalid request parameters. sourceObjectName= ' + sourceObjectName );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }

        this.sourceObjectName = sourceObjectName;
        this.isAutoEntitlement = isAutoEntitlement;
        this.sourceFieldLabelMap = new Map<String,String>();

        // Retrieve entitlement field map for source object & entitlement rule.
        entitlementFieldMap = Ever.getEntitlementFieldsMap( sourceObjectName );
    }

    /**
     * This method is used to retrieve qualified service coverage for given source
     * record id. This method will be invoked from interactive entitlement engine.
     *
     * @param sourceRecord Source record for which service coverage to be retrieved.
     *
     * @return Returns list of qualified contract and warranty list.
     */
    protected Ever.ServiceCoverage getServiceCoverage( final SObject sourceRecord ) {

        System.debug( LoggingLevel.DEBUG, 'getServiceCoverage() - enter; sourceRecord= ' + sourceRecord );

        Ever.ServiceCoverage serviceCoverage = new Ever.ServiceCoverage();

        try {

            final Adm.EntitlementBase entitlementBase = getEntitlementConfiguration(sourceRecord);
            //Retrieve on hold entitlements
            handleOnHoldEntitlements( entitlementBase );

            updateSourceFieldApiNames( entitlementBase );

            // Callback method to validate source record. Throws SvmxNestedException for invalid source record.
            validateSourceRecord( sourceRecord, entitlementBase );

            // Retrieve and populate asset records only if covered by Asset.
            if( entitlementBase.coveredBy.equalsIgnoreCase( StringAsset ) ) {

                // Retrieve asset records for requested source records.
                assetRecordsMap = retrieveAssetRecords( new List<SObject> {sourceRecord} );
            }

            final EntitlementParams entitlementParams = new EntitlementParams();

            // Callback method to build entitlement criteria and populate values in entitlement params.
            buildEntitlementCriteria( sourceRecord, entitlementBase, entitlementParams );

            System.debug( LoggingLevel.INFO, 'getServiceCoverage() : Created entitlement criterias. entitlementParams= ' + entitlementParams );

            queryWarrantyContractRecords(entitlementParams);

            // Query list of qualified coverages and warranties.
            serviceCoverage = getQualifiedServiceCoverage(sourceRecord, entitlementBase, entitlementParams );
        }

        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverage() : Failed to perform entitlement verification. Error= ' + e.getMessage() );
            throw e;
        }

        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverage() : Failed to perform entitlement verification. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoverage() - exit; serviceCoverage= ' + serviceCoverage );
        }

        return serviceCoverage;
    }

    /**
     * This method is used to perform auto entitlement for requested list of record ids.
     * This method retrieves qualified contracts/warranties and applys to source object
     * as configured in entitlement rule. This method also create entitlement history with
     * all qualified service coverage.
     *
     * @param sourceRecords Source record for which auto entitlement to be performed.
     */
    protected void performAutoEntitlement( final List<SObject> sourceRecords ) {

        System.debug( LoggingLevel.DEBUG, 'performAutoEntitlement() - enter; sourceRecords= ' + sourceRecords );

        try {

            final List<SObject> validSourceRecords = new List<SObject>();
            final List<SObject> invalidSourceRecords = new List<SObject>();
            final EntitlementParams entitlementParams = new EntitlementParams();

            // Retrieve asset records for requested source records.
            assetRecordsMap = retrieveAssetRecords( sourceRecords );

            for( SObject sourceRecord : sourceRecords ) {

                try {
                    // Callback to retrieve entitlement base.
                    final Adm.EntitlementBase entitlementBase = getEntitlementConfiguration(sourceRecord);

                    if( entitlementBase == null && !inheritService( sourceRecord ) ) {

                        System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : No qualified entitlement rule found. sourceRecords= ' + sourceRecords );
                        throw new SvmxSystem.SvmxNestedException( ERROR_NO_QUALIFIED_RULE );
                    }

                    if( !inheritService( sourceRecord ) ) {
                        // Update source field API names if configured in Entitlement rule/settings.
                        updateSourceFieldApiNames( entitlementBase );

                        // Populate source record to entitlement rule map.
                        sourceIdEntitlementBaseMap.put( sourceRecord.Id, entitlementBase );

                        // Validate each source record. Don't perform entitlement check if validation is failed.
                        validateSourceRecord( sourceRecord, entitlementBase );

                        // Update where clause for contract/warranty and asset/account/contact ids.
                        buildEntitlementCriteria( sourceRecord, entitlementBase, entitlementParams );
                    }

                    validSourceRecords.add(sourceRecord);
                }
                catch( Exception e ) {

                    System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Failed to perform auto entitlement. Error= ' + e.getMessage() );
                    System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : ' + e.getStackTraceString() );

                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.PerformAutoEntitlement), false );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.IsEntitlementPerformed), false );

                    Logger.error(e, sourceRecord.id);

                    invalidSourceRecords.add(sourceRecord);
                }
            }

            // Perform save service coverage
            saveServiceCoverage( validSourceRecords, entitlementParams );

            // Update invalid source record entitlement notes.
            SvmxDatabase.updateRecord(invalidSourceRecords);

            System.debug( LoggingLevel.INFO, 'performAutoEntitlement() : Performed Auto entitlement for valid source records. validSourceRecords.size()= ' + validSourceRecords.size() );
        }

        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Failed to perform entitlement verification. Error= ' + e.getMessage() );
            Logger.error(e);
        }

        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Failed to perform entitlement verification. Error= ' + e.getStackTraceString() );
            Logger.error(e);
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'performAutoEntitlement() - exit' );
        }
    }

    /**
     * This method is used to retrieve source records for requested record ids.
     *
     * @param recordIds record id for which source records to be retrieved.
     * @return Returns SObject records for requested record id.
     */
    @testVisible protected List<SObject> retrieveSourceRecords( final List<String> recordIds ) {

        System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecords() - enter; recordIds= ' + recordIds.size() );

        List<SObject> sourceRecords = new List<SObject>();

        try {

            // Verify records and source object name.
            if( recordIds == null || recordIds.size() == 0 ) {

                System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Invalid request parameters.' + '; recordIds= ' + recordIds );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            final Set<String> sourceFields = new Set<String>{'Id'};
            sourceFields.addAll( Ever.getEntitlementFieldsMap(sourceObjectName).values() );

            // Retrieve Asset and Account fields from the source object.
            Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions( sourceObjectName , true );

            for( Common.FieldDefinition fieldDefinition : entityDefinition.fieldDefinitions ) {

                if( fieldDefinition.referenceTo != null && fieldDefinition.referenceTo.size() > 0 && ( fieldDefinition.referenceTo.get(0).equalsIgnoreCase(StringAsset) || fieldDefinition.referenceTo.get(0).equalsIgnoreCase(StringAccount) ) ) {

                    sourceFields.add(fieldDefinition.apiName);
                    sourceFieldLabelMap.put( fieldDefinition.apiName, fieldDefinition.label );
                }
            }
            System.debug( LoggingLevel.INFO, 'retrieveSourceRecords() : sourceFields= ' + sourceFields );

            if( isAutoEntitlement ) {

                // Get all fields consumed in the Expression.
                final List<SVMXA360__CONF_Expression__c> expressionList = ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(sourceObjectName, ADM_ExpressionManager.EVER_RULE_CRITERIA);
                sourceFields.addAll( COMM_ExpressionUtils.getInstance().fetchSObjectFields(expressionList) );

                final String retrieveSourceQuery = 'SELECT ' + String.join(new List<String>(sourceFields), ',') + ' FROM ' + sourceObjectName + ' WHERE id IN :recordIds AND SVMXA360__PerformAutoEntitlement__c = true';
                System.debug( LoggingLevel.INFO, 'retrieveSourceRecords() : retrieveSourceQuery= ' + retrieveSourceQuery );

                // Query requested source records where auto entitlement is enabled.
                sourceRecords = SvmxDatabase.query( Database.query( String.escapeSingleQuotes(retrieveSourceQuery) ) );
            } else {

                if ( UserInfo.isMultiCurrencyOrganization() && !sourceFields.contains('CurrencyISOCode') ) {
                    sourceFields.add('CurrencyISOCode');
                }
                // Query requested source record.
                sourceRecords = SvmxDatabase.query( Database.query( 'SELECT ' + String.join(new List<String>(sourceFields), ',') + ' FROM ' + sourceObjectName + ' WHERE id IN :recordIds' ) );
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Failed to retrieve entitlement source records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'retrieveSourceRecords() : Failed to retrieve entitlement source records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveSourceRecords() - exit; sourceRecords= ' + sourceRecords.size() );
        }

        return sourceRecords;
    }

    /**
     * This method is used to retrieve entitlement date from source record. The entitlement
     * date set to today() when entitlement date is not configured in the source record.
     *
     * @param sourceRecord Source record from which entitlement date to be retrieved.
     * @return Returns entitlement date from source object.
     */
    @testVisible protected Date retrieveEntitlementDate( final SObject sourceRecord ) {

        System.debug( LoggingLevel.FINE, 'retrieveEntitlementDate() - enter; sourceRecord= ' + sourceRecord );

        Date entitlementDate = Date.today();

        // Retrieve entitlement date field.
        final String entitlementDateField = entitlementFieldMap.get( Ever.EntitlementField.EntitlementDate );

        try {

            // Retrieve entitlement date only when configured in source record.
            if( entitlementDateField != null && sourceRecord.get(entitlementDateField) != null ) {
                entitlementDate = Date.valueOf( sourceRecord.get(entitlementDateField) );
            }
        }

        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'retrieveEntitlementDate() : Failed to retrieve entitlement date. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.FINE, 'retrieveEntitlementDate() - exit; entitlementDate= ' + entitlementDate );
        }

        return entitlementDate;
    }

    /**
     * This method is used to retrieve asset records for asset ids configured in requested source records.
     *
     * @param sourceRecords Source records for which asset records to be retrieved.
     * @return Returns Map of Asset records.
     */
    protected Map<Id,Asset> retrieveAssetRecords( final List<SObject> sourceRecords ) {

        System.debug( LoggingLevel.DEBUG, 'retrieveAssetRecords() - enter; sourceRecords= ' + sourceRecords );

        final Map<Id,Asset> assetRecordsMap = new Map<Id,Asset>();

        try {

            Set<String> assetFields = new Set<String>();

            // Get all asset field id from the source object.
            Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions( sourceObjectName , true );

            for( Common.FieldDefinition fieldDefinition : entityDefinition.fieldDefinitions ) {

                if( ( fieldDefinition.referenceTo != null && fieldDefinition.referenceTo.size() > 0 && fieldDefinition.referenceTo.get(0).equalsIgnoreCase(StringAsset) )
                    || (sourceObjectName.equalsIgnoreCase(StringAsset) && fieldDefinition.dataType != null && fieldDefinition.dataType.equalsIgnoreCase('ID'))) {
                    assetFields.add( fieldDefinition.apiName );
                }
            }

            // Create set of unique asset ids.
            final Set<String> assetIdSet = new Set<String>();
            for( SObject sourceRecord : sourceRecords ) {
                for( String assetField : assetFields ) {
                    if( sourceRecord.get( assetField ) != null ) {
                        assetIdSet.add( (String) sourceRecord.get( assetField ) );
                    }
                }
            }

            // Query Asset records if atleast one record id exists in the set.
            if( assetIdSet.size() > 0 ) {
                assetRecordsMap.putAll( (List<Asset>) SvmxDatabase.query( [SELECT Id, AccountId, ParentId, RootAssetId, Product2Id FROM Asset WHERE id IN :assetIdSet] ) );
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'retrieveAssetRecords() : Failed to retrieve asset records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveAssetRecords() - exit; assetRecordsMap= ' + assetRecordsMap );
        }

        return assetRecordsMap;
    }

    /**
     * This method is used to get coverage status for requested service coverage.
     *
     * @param serviceCoverage Service Coverage for which coverage status to be retrieved.
     * @return Returns One of the Coverage status enum.
     */
    protected Ever.CoverageStatus getCoverageStatus( final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'getCoverageStatus() - enter; serviceCoverage= ' + serviceCoverage );

        // Defaulting it to no coverage found.
        Ever.CoverageStatus coverageStatus = Ever.CoverageStatus.NoCoverage;

        try {
            // Identify coverage status by qualified coverage for given service coverage.
            if( serviceCoverage.contractList != null && serviceCoverage.contractList.size() > 0 ) {

                // Check whether both contract and warranty found.
                if( serviceCoverage.warrantyList != null && serviceCoverage.warrantyList.size() > 0 ) {
                    coverageStatus = Ever.CoverageStatus.BothContractWarranty;
                } else if( serviceCoverage.contractList.size() == 1 ) {

                    // Identify number of entitlement for qualified contract.
                    coverageStatus = Ever.CoverageStatus.OneContract;
                    Ever.CoverageInfo contractInfo = serviceCoverage.contractList.get(0);

                    if( contractInfo.entitlements != null && contractInfo.entitlements.size() > 0 ) {

                        // Check whether contract has one entitlement or multiple entitlements.
                        coverageStatus = (contractInfo.entitlements.size() == 1 ) ? Ever.CoverageStatus.OneContractEntitlement : Ever.CoverageStatus.OneContractMultipleEntitlements;
                    }
                } else {
                    // When more than one contract found.
                    coverageStatus = Ever.CoverageStatus.MultipleContracts;
                }
            } else if( serviceCoverage.warrantyList != null && !serviceCoverage.warrantyList.isEmpty() ) {

                // Check one warranty or multiple warranties.
                coverageStatus = (serviceCoverage.warrantyList.size() == 1) ? Ever.CoverageStatus.OneWarranty : Ever.CoverageStatus.MultipleWarranties;
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getCoverageStatus() : Failed to retrieve coverage status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getCoverageStatus() - exit; coverageStatus= ' + coverageStatus );
        }

        return coverageStatus;
    }

    protected void saveServiceCoverage( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - enter; sourceRecord= ' + sourceRecord + '; serviceCoverage= ' + serviceCoverage );

        try {

            // Verify source record.
            if( sourceRecord == null || sourceRecord.id == null ) {

                System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Invalid request parameters.' + '; sourceRecord= ' + sourceRecord );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            resetSourceRecordFields(sourceRecord);

            // Validate number of remaining cases for Entitlement
            validateRemainingCases(serviceCoverage);

            // Callback method to perform source object update. Callback method must implement the logic to
            // identifing and updating different fields source object including entitlement notes.
            beforeSourceObjectUpdate( sourceRecord, serviceCoverage );

            // Update billing type for WorkOrder
            updateBillingType( sourceRecord, serviceCoverage, getEntitlementConfiguration(sourceRecord) );

            final Map<String, EntitlementVerificationHistory__c> entitlementHistoryMap = new Map<String, EntitlementVerificationHistory__c>();
            final EntitlementVerificationHistory__c entitlementVerificationHistory = createEntitlementHistory( sourceRecord, serviceCoverage );

            entitlementHistoryMap.put( sourceRecord.Id, entitlementVerificationHistory );

            populateEntitlement(new List<SObject>{sourceRecord}, entitlementHistoryMap );

            // Update source records with status and entitlement notes.
            SvmxDatabase.updateRecord(sourceRecord);

            final Map<String, EntitlementVerificationHistory__c> sourceRecordHistoryMap = getOldHistoryMap( new List<SObject>{sourceRecord} );

            // Create Entitlement verification history.
            SvmxDatabase.insertRecord( entitlementVerificationHistory );

            // Handle Entitlement settings
            handleEntitledServiceUsage( new List<SObject>{sourceRecord}, entitlementHistoryMap, sourceRecordHistoryMap);
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to sace service contract. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to save service contract. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - exit' );
        }
    }

    /**
     * This method is used to retrieve entitlement base for source record.
     */
    protected Adm.EntitlementBase getEntitlementBase( final SObject sourceRecord ) {

        System.debug( LoggingLevel.DEBUG, 'getEntitlementBase() - enter; sourceRecord= ' + sourceRecord );

        Adm.EntitlementBase entitlementBase;

        try {
            // Verify source record.
            if( sourceRecord == null || sourceRecord.id == null ) {

                System.debug( LoggingLevel.ERROR, 'getEntitlementBase() : Invalid request parameters.' + '; sourceRecord= ' + sourceRecord );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            entitlementBase = sourceIdEntitlementBaseMap.get( sourceRecord.id );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getEntitlementBase() : Failed to retrieve entitlement base. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitlementBase() : Failed to retrieve entitlement base. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementBase() - exit; entitlementBase= ' + entitlementBase );
        }

        return entitlementBase;
    }

    /**
     * This method is used to validate remaining cases for entitlement assignement.
     */
    private void validateRemainingCases( final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'validateRemainingCases() - enter; serviceCoverage= ' + serviceCoverage );

        try {

            if( serviceCoverage.selectedCoverage != null && serviceCoverage.selectedCoverage.coverageType.equalsIgnoreCase( Ever.CoverageType.Entitlement.name() ) ) {

                List<Entitlement> entitlementRecordList = SvmxDatabase.query( [SELECT RemainingCases FROM Entitlement WHERE Id =:serviceCoverage.selectedCoverage.Id ] );
                if( entitlementRecordList != null && entitlementRecordList.size() > 0 ) {

                    Entitlement entitlementRecord = entitlementRecordList.get(0);
                    if( entitlementRecord.RemainingCases != null && entitlementRecord.RemainingCases == 0 ) {
                        throw new SvmxSystem.SvmxNestedException( ERROR_CANNOT_ALLOW_ADDITIONAL_CASE );
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'validateRemainingCases() : No remaining entitlement. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'validateRemainingCases() : Failed to validate remaining cases. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateRemainingCases() - exit' );
        }
    }

    /**
     * This method is used to update overrite account/asset fields from entitlement configuration.
     */
    private void updateSourceFieldApiNames( final Adm.EntitlementBase entitlementBase ) {

        if( String.isNotBlank( entitlementBase.assetAPIName ) ) {
            entitlementFieldMap.put(Ever.EntitlementField.Asset, entitlementBase.assetAPIName);
        }

        if( String.isNotBlank( entitlementBase.accountAPIName ) ) {
            entitlementFieldMap.put(Ever.EntitlementField.Account, entitlementBase.accountAPIName);
        }
    }
    /**
     * This method is used to apply entitlement to requested source records.
     */
    private void saveServiceCoverage( final List<SObject> sourceRecords, final EntitlementParams entitlementParams ) {

        System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - enter; sourceRecords= ' + sourceRecords + '; entitlementParams= ' + entitlementParams );
        Map<Id, String> workOrderPricebookMap = new Map<Id, String>();
        boolean assignPricebook = false;
        final List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();
        if ( !commonEntitlementSettings.isEmpty() && commonEntitlementSettings.get(0).SVMXA360__AssignPricebook__c ) {
            assignPricebook = true;
        }

        try {

            if( sourceRecords.size() > 0 ) {

                if( inheritService() ) {
                    queryinheritCoverage(sourceRecords, entitlementParams);
                }

                // Query and populate warranty/contract records.
                queryWarrantyContractRecords( entitlementParams );

                final Map<String, EntitlementVerificationHistory__c> entitlementHistoryMap = new Map<String, EntitlementVerificationHistory__c>();

                // For each source records, perform source object update.
                for( SObject sourceRecord : sourceRecords ) {

                    // Retrieve entitlement configuration and qualified service coverage for each source record.
                    final Adm.EntitlementBase entitlementBase = getEntitlementBase(sourceRecord);
                    final Ever.ServiceCoverage serviceCoverage = getQualifiedServiceCoverage(sourceRecord, entitlementBase, entitlementParams );

                    resetSourceRecordFields( sourceRecord );

                    if( !inheritService( sourceRecord ) ) {

                        // Callback method to perform source object update. Callback method must implement the logic to
                        // identifing and updating different fields source object including entitlement notes.
                        beforeSourceObjectUpdate( sourceRecord, serviceCoverage );

                        // Update billing type for Work Order.
                        updateBillingType( sourceRecord, serviceCoverage, entitlementBase );
                    }

                    // WorkOrder Object Type Check
                    if( sourceObjectName.equalsIgnoreCase(StringWorkOrder)  && serviceCoverage.selectedCoverage != null &&
                       serviceCoverage.selectedCoverage.pricebookId != null && assignPricebook ) {
                           workOrderPricebookMap.put(sourceRecord.Id,serviceCoverage.selectedCoverage.pricebookId);
                    }

                    final EntitlementVerificationHistory__c entitlementVerificationHistory = createEntitlementHistory( sourceRecord, serviceCoverage );
                    entitlementHistoryMap.put( sourceRecord.Id, entitlementVerificationHistory );
                }

                if( sourceObjectName.equalsIgnoreCase(StringWorkOrder) && assignPricebook ) {
                    populateWorkOrderPricebook( sourceRecords, workOrderPricebookMap );
                }

                // populate entitlement
                populateEntitlement( sourceRecords, entitlementHistoryMap );

                // Update source records with status and entitlement notes.
                SvmxDatabase.updateRecord(sourceRecords);

                final Map<String, EntitlementVerificationHistory__c> sourceRecordHistoryMap = getOldHistoryMap( sourceRecords );

                // Create Entitlement verification history.
                SvmxDatabase.insertRecord(entitlementHistoryMap.values());

                // Handle Entitlement settings
                handleEntitledServiceUsage(sourceRecords, entitlementHistoryMap, sourceRecordHistoryMap);

                // Trigger autolaunch flow.
                updateSourceEntitlement( sourceRecords );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to perform check entitlements. Error= ' + e.getMessage() );
            Logger.error(e, sourceRecords.size() == 1 ? sourceRecords.get(0).id : null );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to perform check entitlements. Error= ' + e.getStackTraceString() );
            Logger.error(e, sourceRecords.size() == 1 ? sourceRecords.get(0).id : null);
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - exit' );
        }
    }

    private void queryinheritCoverage( final List<SObject> sourceRecords, final EntitlementParams entitlementParams ) {

        System.debug( LoggingLevel.DEBUG, 'queryinheritCoverage() - enter' );

        final Set<String> serviceContractIdSet = new Set<String>();
        final Set<String> contractLineItemIdSet = new Set<String>();
        for( SObject sourceRecord : sourceRecords ) {

            final String contractLineItemId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.ContractLineItem) );

            if( contractLineItemId != null ) {
                contractLineItemIdSet.add(contractLineItemId);
            } else {
                final String serviceContractId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract) );
                if( serviceContractId != null ) {
                    serviceContractIdSet.add(serviceContractId);
                }
            }
        }

        if( !contractLineItemIdSet.isEmpty() ) {

            final String contractQuery = 'SELECT '+String.join( ContractQueryFields, ',')+' FROM ContractLineItem WHERE Id IN :contractLineItemIdSet';
            System.debug( LoggingLevel.DEBUG, 'queryinheritCoverage() : contractQuery= ' + contractQuery );

            processContractRecords( entitlementParams, SvmxDatabase.query( Database.query( contractQuery ) ) );
        }

        if( !serviceContractIdSet.isEmpty() ) {

            final String serviceContractQuery = 'SELECT '+String.join(ServiceContractQueryFields, ',')+' FROM ServiceContract WHERE Id IN :serviceContractIdSet';
            System.debug( LoggingLevel.DEBUG, 'queryinheritCoverage() : serviceContractQuery= ' + serviceContractQuery );

            // Populate contract records and also entitlements if exists.
            processServiceContractRecords( entitlementParams, SvmxDatabase.query( Database.query( serviceContractQuery ) ) );
        }

         System.debug( LoggingLevel.DEBUG, 'queryinheritCoverage() - exit' );
    }

    /**
     * This method is used to retrieve entitlement SLA records for given entitled service records.
     */
    private void initEntitlements( final List<SObject> sourceRecords ) {

        System.debug( LoggingLevel.DEBUG, 'initEntitlements() - enter');

        try {

            System.debug( LoggingLevel.INFO, 'initEntitlements() : Initializing entitlement map.');

            // For each source records, perform source object update.
            for( SObject sourceRecord : sourceRecords ) {

                final String entitledServiceId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.EntitledService) );
                if( String.isNotBlank(entitledServiceId)  ) {

                    if( !entitledServiceSourceMap.containsKey(entitledServiceId) ) {
                        entitledServiceSourceMap.put(entitledServiceId, new List<SObject>() );
                    }
                    entitledServiceSourceMap.get( entitledServiceId ).add(sourceRecord);
                }
            }

            if( !entitledServiceSourceMap.isEmpty() ) {

                Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), RECORD_TYPE_SLA );
                entitlementList.addAll( (List<Entitlement>) SvmxDatabase.query([SELECT Id, SVMXA360__EntitledServiceId__c FROM Entitlement WHERE RecordTypeId = :recordTypeId AND SVMXA360__EntitledServiceId__c IN :entitledServiceSourceMap.keySet() AND SlaProcess.SObjectType = :sourceObjectName]));
            }

            System.debug( LoggingLevel.INFO, 'initEntitlements() : entitlementList= ' + entitlementList );
            System.debug( LoggingLevel.INFO, 'initEntitlements() : entitledServiceSourceMap= ' + entitledServiceSourceMap );

        }
        catch(Exception e ) {

            System.debug( LoggingLevel.ERROR, 'initEntitlements() : Error retrieving entitlements. Error: ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initEntitlements() - exit');
        }
    }

    /*
     * This method is used to populate entitlement to source records.
     */
    private void populateEntitlement( final List<SObject> sourceRecords, final Map<String, EntitlementVerificationHistory__c> entitlementHistoryMap ) {

        System.debug( LoggingLevel.DEBUG, 'populateEntitlement() - enter');

        if( !sourceObjectName.equalsIgnoreCase( String.valueOf( ReturnOrder.getSObjectType() ) ) ) {

            initEntitlements( sourceRecords );

            // populate SLA entitlement records if exists
            for( Entitlement entitlementRecord : entitlementList ) {

                if( !entitledServiceSourceMap.containsKey(entitlementRecord.SVMXA360__EntitledServiceId__c) ) {
                    continue;
                }

                for( SObject sourceRecord : entitledServiceSourceMap.get(entitlementRecord.SVMXA360__EntitledServiceId__c) ) {

                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.Entitlement), entitlementRecord.Id );
                    if( entitlementHistoryMap.containsKey(sourceRecord.id) ) {
                        entitlementHistoryMap.get(sourceRecord.id).SVMXA360__EntitlementId__c = entitlementRecord.Id;
                    }
                }
            }
        }

        System.debug( LoggingLevel.DEBUG, 'populateEntitlement() - exit');
    }

    /**
     * Private method to reset source record entitlement fields.
     */
    private void resetSourceRecordFields( final SObject sourceRecord ) {

        // Reset all entitlement related fields with default values in source record.
        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitlementDate), retrieveEntitlementDate( sourceRecord ) );
        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.IsEntitlementPerformed), true );
        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.PerformAutoEntitlement), false );

        if( !inheritService( sourceRecord ) ) {

            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), null );
            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty), null );
            if( !sourceObjectName.equalsIgnoreCase(String.valueOf(ReturnOrder.getSObjectType())) ) {
                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.Entitlement), null );
            }
            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), null );
        }
    }

    /**
     * This method is used to query all contracts and warranty records.
     */
    private void queryWarrantyContractRecords( final EntitlementParams entitlementParams ) {

        System.debug( LoggingLevel.DEBUG, 'queryWarrantyContractRecords() - enter; entitlementParams= ' + entitlementParams );

        try {

            final Set<String> assetIds = entitlementParams.assetIds;

            if ( !isAutoEntitlement && UserInfo.isMultiCurrencyOrganization() && !EntitlementQueryFields.contains('CurrencyIsoCode') ) {
                EntitlementQueryFields.add('CurrencyIsoCode');
            }

            StackRankingParameters stackRankingParams = retrieveStackRankingParams();

            // When both future and expired entitlement selected in interactive
            // entitlement, where clause list will be empty.
            if( entitlementParams.contractWhereClauseList.size() > 0 || ( !isAutoEntitlement && entitlementParams.assetIds.size() != 0 ) ) {

                final Set<String> contactIds = entitlementParams.contactIds;
                final Set<String> accountIds = entitlementParams.accountIds;

                // Add where clause for asset, account & contact sets.
                if( assetIds.size() != 0 ) { entitlementParams.contractWhereClauseList.add('AssetId IN :assetIds');}
                if( accountIds.size() != 0 ) { entitlementParams.contractWhereClauseList.add('ServiceContract.AccountId IN :accountIds'); }
                if( contactIds.size() != 0 ) { entitlementParams.contractWhereClauseList.add('ServiceContract.ContactId IN :contactIds'); }
                entitlementParams.contractWhereClauseList.add('ServiceContract.SVMXA360__ContractAuthoringStatus__c IN :QualifiedAuthoringStatus');

                // Create query with where clause to retrieve qualified contract line records.
                final String contractQuery = 'SELECT '+String.join(ContractQueryFields, ',')+' FROM ContractLineItem WHERE ' + 
                                             String.join( entitlementParams.contractWhereClauseList, ' AND ' ) + 
                                             stackRankingParams.cliStackRankingClause;
                System.debug( LoggingLevel.DEBUG, 'queryWarrantyContractRecords() : contractQuery= ' + contractQuery );

                // Populate contract records and also entitlements if exists.
                processContractRecords( entitlementParams, SvmxDatabase.query( Database.query( contractQuery ) ) );
            }

            else if( entitlementParams.serviceContractWhereClauseList.size() > 0 || ( !isAutoEntitlement && entitlementParams.accountIds.size() != 0 ) ) {

                final Set<String> contactIds = entitlementParams.contactIds;
                final Set<String> accountIds = entitlementParams.accountIds;
                Set<String> serviceContractIds = new Set<String>();

                // Add where clause for account & contact sets.
                if( entitlementParams.serviceContractIds.size() != 0 && !isAutoEntitlement) {
                    serviceContractIds = entitlementParams.serviceContractIds;
                    entitlementParams.serviceContractWhereClauseList.add('Id IN :serviceContractIds');
                }

                if( accountIds.size() != 0 ) { entitlementParams.serviceContractWhereClauseList.add('AccountId IN :accountIds'); }
                if( contactIds.size() != 0 ) { entitlementParams.serviceContractWhereClauseList.add('ContactId IN :contactIds'); }
				entitlementParams.serviceContractWhereClauseList.add('SVMXA360__ContractAuthoringStatus__c IN :QualifiedAuthoringStatus');

                // Create query with where clause to retrieve qualified contract line records.
                final String serviceContractQuery = 'SELECT '+String.join(ServiceContractQueryFields, ',')+
                                                    ' FROM ServiceContract WHERE ' + 
                                                    String.join( entitlementParams.serviceContractWhereClauseList, ' AND ' ) + 
                                                    stackRankingParams.sconStackRankingClause;
                System.debug( LoggingLevel.DEBUG, 'queryWarrantyContractRecords() : serviceContractQuery= ' + serviceContractQuery );

                // Populate contract records and also entitlements if exists.
                processServiceContractRecords( entitlementParams, SvmxDatabase.query( Database.query( serviceContractQuery ) ) );
            }

            // Query warranties using created where clause.
            if( entitlementParams.warrantyWhereClauseList.size() > 0 || ( !isAutoEntitlement && entitlementParams.assetIds.size() != 0 ) ) {

                final Set<String> warrantyTypes = entitlementParams.warrantyTypes;

                // Create query with where clause to retrieve qualified asset warranties.
                if( assetIds.size() != 0 ) { entitlementParams.warrantyWhereClauseList.add('AssetId IN :assetIds'); }
                if( warrantyTypes.size() != 0 ) { entitlementParams.warrantyWhereClauseList.add('WarrantyType NOT IN :warrantyTypes'); }

                final String warrantyQuery = 'SELECT '+String.join(AssetWarrantyQueryFields, ',')+' FROM AssetWarranty WHERE ' + 
                                             String.join( entitlementParams.warrantyWhereClauseList, ' AND ' ) + 
                                             stackRankingParams.warrantyStackRankingClause;

                System.debug( LoggingLevel.DEBUG, 'queryWarrantyContractRecords() : warrantyQuery= ' + warrantyQuery );
                final List<AssetWarranty> assetWarrantyRecords  = SvmxDatabase.query( Database.query( warrantyQuery ) );

                // Create asset vs warranty map.
                for( AssetWarranty assetWarranty : assetWarrantyRecords ) {

                    if( !entitlementParams.assetWarrantyMap.containsKey( assetWarranty.AssetId ) ) {
                        entitlementParams.assetWarrantyMap.put( assetWarranty.AssetId, new List<AssetWarranty>() );
                    }
                    entitlementParams.assetWarrantyMap.get(assetWarranty.AssetId).add(assetWarranty);
                }
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'queryWarrantyContractRecords() : Failed to retrieve Contract Lines or Asset Warranties. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'queryWarrantyContractRecords() - exit' );
        }
    }

    private StackRankingParameters retrieveStackRankingParams () {

        StackRankingParameters params = new StackRankingParameters();
    
        List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = 
                        ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();
        
        if ( !commonEntitlementSettings.isEmpty() && commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
             commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
             commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
             commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
             commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
             commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null ) {
    
            params.applyStackRanking = true;
            params.cliStackRankingField = 'ServiceContract.' + (String)commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c;
            params.sconStackRankingField = (String)commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c;
            params.warrantyStackRankingField = (String)commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c;
            params.contractStackRankingOrder = (String)commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c == 'Ascending' ? ' ASC' : ' DESC';
            params.warrantyStackRankingOrder = (String)commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c == 'Ascending' ? ' ASC' : ' DESC';
            params.cliStackRankingClause = ' ORDER BY ' + params.cliStackRankingField + ' ' + params.contractStackRankingOrder + ' NULLS LAST';
            params.sconStackRankingClause = ' ORDER BY ' + params.sconStackRankingField + ' ' + params.contractStackRankingOrder + ' NULLS LAST';
            params.warrantyStackRankingClause = ' ORDER BY ' + params.warrantyStackRankingField + ' ' + params.warrantyStackRankingOrder + ' NULLS LAST';
    
            if ( !ContractQueryFields.contains(params.cliStackRankingField) ) {
                ContractQueryFields.add(params.cliStackRankingField);
            }
    
            if ( !ServiceContractQueryFields.contains(params.sconStackRankingField) ) {
                ServiceContractQueryFields.add(params.sconStackRankingField);
            }
    
            if ( !AssetWarrantyQueryFields.contains(params.warrantyStackRankingField) ) {
                AssetWarrantyQueryFields.add(params.warrantyStackRankingField);
            }
    
        } else {
            params.applyStackRanking = false;
            params.cliStackRankingClause = '';
            params.sconStackRankingClause = '';
            params.warrantyStackRankingClause = '';
        }
        
        return params;
    }

    /**
     * This method is used to porcess contract records and preserve in different maps. This method also retrieves entitlement
     * for retrieved contractd and populates in contract vs entitlement map.
     */
    private void processContractRecords( final EntitlementParams entitlementParams, final List<ContractLineItem> contractLineItemRecords ) {

        System.debug( LoggingLevel.DEBUG, 'processContractRecords() - enter; contractLineItemRecords= ' + contractLineItemRecords );

        try {

            Set<String> serviceContractIdSet = new Set<String>();
            // Create both account/asset vs contract maps.
            for( ContractLineItem contractLine : contractLineItemRecords ) {

                // Create asset vs contract map. This will be that case when Covered By 'Asset' is
                // configured in Entitlement Rule/Settings.
                if( contractLine.AssetId != null && entitlementParams.assetIds != null && !entitlementParams.assetIds.isEmpty() ) {

                    if( !entitlementParams.assetContractMap.containsKey( contractLine.AssetId ) ) {
                        entitlementParams.assetContractMap.put( contractLine.AssetId, new List<ContractLineItem>() );
                    }
                    entitlementParams.assetContractMap.get(contractLine.AssetId).add(contractLine);
                }

                // Create account vs Contract map. This will be the case when Covered By 'Account' is
                // configured in Entitlement Rule/Settings.
                if( contractLine.ServiceContract.AccountId != null ) {

                    if( !entitlementParams.accountContractMap.containsKey( contractLine.ServiceContract.AccountId ) ) {
                        entitlementParams.accountContractMap.put( contractLine.ServiceContract.AccountId, new List<ContractLineItem>() );
                    }
                    entitlementParams.accountContractMap.get(contractLine.ServiceContract.AccountId).add(contractLine);
                }

                serviceContractIdSet.add( contractLine.ServiceContractId );
            }

            entitlementParams.serviceContractIds.addAll(serviceContractIdSet);

            System.debug( LoggingLevel.FINE, 'processContractRecords() : entitlementParams.assetContractMap= ' + entitlementParams.assetContractMap );
            System.debug( LoggingLevel.FINE, 'processContractRecords() : entitlementParams.accountContractMap= ' + entitlementParams.accountContractMap );

            // Retrieve entitlement records for retrieves contract line item records.
            if( contractLineItemRecords.size() > 0 || serviceContractIdSet.size() > 0 ) {

                Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), RECORD_TYPE_ENTITLED_SERVICE );
                String whereClause = 'RecordTypeId = :recordTypeId AND ( ( ContractLineItemId IN :contractLineItemRecords OR ServiceContractId IN :serviceContractIdSet ) )';

                if( entitlementParams.entitlementWhereClauseList.size() > 0 ) {
                    whereClause += ' AND ( ' + String.join( entitlementParams.entitlementWhereClauseList, ' OR ') + ')';
                }

                /*
                 * On Case/WorkOrder/ReturnOrder, Only show Entitlements that match the Entitlement process or blank.
                 */
                final String entitlementQuery = 'SELECT ' + String.join( EntitlementQueryFields, ',') + ' FROM Entitlement WHERE ' + whereClause;

                System.debug( LoggingLevel.INFO, 'processContractRecords() - entitlementQuery= ' + entitlementQuery );
                List<Entitlement> entitlementList = SvmxDatabase.query( Database.query( entitlementQuery ) );

                for( Entitlement entitlement : entitlementList ) {

                    updateEntitlementMap(entitlement, entitlementParams );
                }

                //Query related Contract Price Line items and store them in entitlementParams
                processCPLIRecords(entitlementParams, entitlementList);
            }

            System.debug( LoggingLevel.FINE, 'processContractRecords() : entitlementParams.coverageEntitlementMap= ' + entitlementParams.coverageEntitlementMap );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'processContractRecords() : Failed to process contract line records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'processContractRecords() - exit' );
        }
    }

    /**
     * Method to query CPLI and store them in entitlementParams
     */

    private void processCPLIRecords(final EntitlementParams entitlementParams, List<Entitlement> entitlementList) {

        System.debug( LoggingLevel.DEBUG, 'processCPLIRecords() - enter; entitlementList= ' + entitlementList );

        // Retrieve CPLI records for retrieved Entitlement records.
        String whereClause = ' ( SVMXA360__EntitledServiceId__c IN :entitlementList ) ';

        if (UserInfo.isMultiCurrencyOrganization()) {
            CPLIQueryFields.add('CurrencyIsoCode');
        }

        final String cpliQuery = 'SELECT '+ String.join( CPLIQueryFields, ',') + ' FROM SVMXA360__ContractPriceLineItem__c WHERE ( SVMXA360__EntitledServiceId__c IN :entitlementList ) ORDER BY SVMXA360__LineType__c';

        System.debug( LoggingLevel.INFO, 'processCPLIRecords() - cpliQuery= ' + cpliQuery );
        List<SVMXA360__ContractPriceLineItem__c> cpliList = SvmxDatabase.query( Database.query( cpliQuery ) );

        for (SVMXA360__ContractPriceLineItem__c cpli : cpliList) {

            if( !entitlementParams.entitlementCPLIMap.containsKey(cpli.SVMXA360__EntitledServiceId__c ) ) {
                entitlementParams.entitlementCPLIMap.put(cpli.SVMXA360__EntitledServiceId__c , new List<SVMXA360__ContractPriceLineItem__c>() );
            }
            entitlementParams.entitlementCPLIMap.get(cpli.SVMXA360__EntitledServiceId__c).add(cpli);
        }
    }

    /**
     * Method to update coverage vs entitlement map.
     */
    private void updateEntitlementMap( final Entitlement entitlement, final EntitlementParams entitlementParams ) {

        if( entitlement.ContractLineItemId != null ) {

            if( !entitlementParams.coverageEntitlementMap.containsKey( entitlement.ContractLineItemId ) ) {
                entitlementParams.coverageEntitlementMap.put( entitlement.ContractLineItemId, new List<Entitlement>() );
            }

            if( !entitlementParams.coverageEntitlementMap.get(entitlement.ContractLineItemId).contains(entitlement) ) {
                entitlementParams.coverageEntitlementMap.get(entitlement.ContractLineItemId).add(entitlement);
            }
        } else if( entitlement.ServiceContractId != null ) {

            if( !entitlementParams.coverageEntitlementMap.containsKey( entitlement.ServiceContractId ) ) {
                entitlementParams.coverageEntitlementMap.put( entitlement.ServiceContractId, new List<Entitlement>() );
            }

            if( !entitlementParams.coverageEntitlementMap.get(entitlement.ServiceContractId).contains(entitlement) ) {
                entitlementParams.coverageEntitlementMap.get(entitlement.ServiceContractId).add(entitlement);
            }
        }
    }

    /**
     * This method is used to porcess contract records and preserve in different maps. This method also retrieves entitlement
     * for retrieved contractd and populates in contract vs entitlement map.
     */
    private void processServiceContractRecords( final EntitlementParams entitlementParams, final List<ServiceContract> serviceContractRecords ) {

        System.debug( LoggingLevel.DEBUG, 'processServiceContractRecords() - enter; serviceContractRecords= ' + serviceContractRecords );

        try {
            // Create both account/asset vs contract maps.
            for( ServiceContract serviceContractRecord : serviceContractRecords ) {

                // Create account vs Contract map. This will be the case when Covered By 'Account' is
                // configured in Entitlement Rule/Settings.
                if( serviceContractRecord.AccountId != null ) {

                    if( !entitlementParams.accountServiceContractMap.containsKey( serviceContractRecord.AccountId ) ) {
                        entitlementParams.accountServiceContractMap.put( serviceContractRecord.AccountId, new List<ServiceContract>() );
                    }
                    entitlementParams.accountServiceContractMap.get(serviceContractRecord.AccountId).add(serviceContractRecord);
                }
            }

            System.debug( LoggingLevel.FINE, 'processServiceContractRecords() : entitlementParams.accountServiceContractMap= ' + entitlementParams.accountServiceContractMap );

            // Retrieve entitlement records for retrieves contract line item records.
            if( serviceContractRecords.size() > 0 ) {

                Id recordTypeId = COMM_RecordTypeManager.getInstance().getRecordTypeId( Entitlement.getSObjectType(), RECORD_TYPE_ENTITLED_SERVICE );
                String whereClause =  + 'RecordTypeId = : recordTypeId AND ( ServiceContractId IN :serviceContractRecords )';
                if( entitlementParams.entitlementWhereClauseList.size() > 0 ) {
                    whereClause += ' AND (' + String.join( entitlementParams.entitlementWhereClauseList, ' OR ') + ')';
                }

                /*
                 * On Case/WorkOrder/ReturnOrder, Only show Entitlements that match the Entitlement process or blank.
                 */
                final String entitlementQuery = 'SELECT ' + String.join( EntitlementQueryFields, ',') + ' FROM Entitlement WHERE ' + whereClause;
                System.debug( LoggingLevel.INFO, 'processContractRecords() - entitlementQuery= ' + entitlementQuery );
                List<Entitlement> entitlementList = SvmxDatabase.query( Database.query( entitlementQuery ) );

                for( Entitlement entitlement : entitlementList ) {

                    if( !entitlementParams.coverageEntitlementMap.containsKey( entitlement.ServiceContractId ) ) {
                        entitlementParams.coverageEntitlementMap.put( entitlement.ServiceContractId, new List<Entitlement>() );
                    }

                    if( !entitlementParams.coverageEntitlementMap.get(entitlement.ServiceContractId).contains(entitlement) ) {
                        entitlementParams.coverageEntitlementMap.get(entitlement.ServiceContractId).add(entitlement);
                    }
                }

                //Query related Contract Price Line items and store them in entitlementParams
                processCPLIRecords(entitlementParams, entitlementList);

            }

            System.debug( LoggingLevel.FINE, 'processServiceContractRecords() : entitlementParams.coverageEntitlementMap= ' + entitlementParams.coverageEntitlementMap );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'processServiceContractRecords() : Failed to process contract line records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'processServiceContractRecords() - exit' );
        }
    }

    private Ever.ServiceCoverage getServiceCoverageFromInheritService( final SObject sourceRecord, final EntitlementParams entitlementParams ) {

        System.debug( LoggingLevel.DEBUG, 'getServiceCoverageFromInheritService() - enter');

        Ever.ServiceCoverage serviceCoverage = new Ever.ServiceCoverage();

        final String contractLineItemId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.ContractLineItem ) );
        final String serviceContractId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.ServiceContract ) );
        final String entitledServiceId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.EntitledService ) );

        if( String.isNotBlank(entitledServiceId) && ( entitlementParams.coverageEntitlementMap.containsKey(contractLineItemId) || entitlementParams.coverageEntitlementMap.containsKey(serviceContractId) ) ) {

            List<Entitlement> entitlementList = entitlementParams.coverageEntitlementMap.containsKey(contractLineItemId) ? entitlementParams.coverageEntitlementMap.get(contractLineItemId):entitlementParams.coverageEntitlementMap.get(serviceContractId);
            for( Entitlement entitlement : entitlementList ) {
                if( entitlement.Id == entitledServiceId ) {
                    serviceCoverage.selectedCoverage = createEntitlementInfo( new List<Entitlement> {entitlement}, StringAsset, System.Label.Label_Asset, !entitlementParams.coverageEntitlementMap.containsKey(contractLineItemId),entitlementParams.entitlementCPLIMap, sourceRecord ).get(0);
                }
            }
        }

        System.debug( LoggingLevel.DEBUG, 'getServiceCoverageFromInheritService() - exit; serviceCoverage= ' + serviceCoverage);

        return serviceCoverage;
    }
    /**
     * This method is used to create Service Coverage for requested source record. This also invokes callback
     * to handle qualified service coverages in case we have any further filtering.
     */
    private Ever.ServiceCoverage getQualifiedServiceCoverage( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final EntitlementParams entitlementParams ) {

        System.debug( LoggingLevel.DEBUG, 'getQualifiedServiceCoverage() - enter; sourceRecord= ' + sourceRecord );

        Ever.ServiceCoverage serviceCoverage = new Ever.ServiceCoverage();

        try {

            if( inheritService( sourceRecord ) ) {
                serviceCoverage = getServiceCoverageFromInheritService( sourceRecord, entitlementParams );
            } else if( entitlementBase != null ) {
                final String assetId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) );

                // Retrieve contracts retrieved by asset ids.
                if( entitlementParams.assetContractMap.containsKey(assetId) ) {
                    serviceCoverage.contractList.addAll( createContractInfo( entitlementBase, entitlementParams.assetContractMap.get(assetId), entitlementParams.coverageEntitlementMap, StringAsset, System.Label.Label_Asset, entitlementParams.entitlementCPLIMap, sourceRecord ) );
                }

                // Retrieve warranties retrieved by asset ids.
                if( entitlementParams.assetWarrantyMap.containsKey(assetId) ) {
                    serviceCoverage.warrantyList.addAll( createWarrantyInfo( entitlementParams.assetWarrantyMap.get(assetId), StringAsset, System.Label.Label_Asset ) );
                }

                switch on entitlementBase.coveredBy.toLowerCase() {

                    when 'asset' {

                        final Asset assetRecord = assetRecordsMap.get(assetId);

                        // Include contract/warranty from parent asset map
                        if( entitlementBase.includeParentAsset ) {

                            if( entitlementParams.assetContractMap.containsKey(assetRecord.ParentId) ) {
                                serviceCoverage.contractList.addAll( createContractInfo( entitlementBase, entitlementParams.assetContractMap.get(assetRecord.ParentId), entitlementParams.coverageEntitlementMap, StringParentAsset, System.Label.Label_ParentAsset, entitlementParams.entitlementCPLIMap, sourceRecord ) );
                            }

                            if( entitlementParams.assetWarrantyMap.containsKey(assetRecord.ParentId) ) {
                                serviceCoverage.warrantyList.addAll( createWarrantyInfo( entitlementParams.assetWarrantyMap.get(assetRecord.ParentId), StringParentAsset, System.Label.Label_ParentAsset ) );
                            }
                        }

                        // Include contract/warranty from root asset map
                        if( entitlementBase.includeRootAsset && ( !entitlementBase.includeParentAsset || assetRecord.ParentId != assetRecord.RootAssetId ) ) {

                            if( assetRecord.RootAssetId != assetId && entitlementParams.assetContractMap.containsKey(assetRecord.RootAssetId) ) {
                                serviceCoverage.contractList.addAll( createContractInfo( entitlementBase, entitlementParams.assetContractMap.get(assetRecord.RootAssetId), entitlementParams.coverageEntitlementMap, StringRootAsset, System.Label.Label_RootAsset, entitlementParams.entitlementCPLIMap, sourceRecord ) );
                            }

                            if( assetRecord.RootAssetId != assetId && entitlementParams.assetWarrantyMap.containsKey(assetRecord.RootAssetId) ) {
                                serviceCoverage.warrantyList.addAll( createWarrantyInfo( entitlementParams.assetWarrantyMap.get(assetRecord.RootAssetId), StringRootAsset, System.Label.Label_RootAsset ) );
                            }
                        }
                    }
                    when 'account' {

                        // Contract lines are queried by account when entitlement is covered by Account.
                        final String accountId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) );

                        if( entitlementParams.accountServiceContractMap.containsKey(accountId) ) {
                            serviceCoverage.contractList.addAll( createServiceContractInfo( entitlementBase, entitlementParams.accountServiceContractMap.get(accountId), entitlementParams.coverageEntitlementMap, StringAccount, System.Label.Label_Account , entitlementParams.entitlementCPLIMap, sourceRecord ) );
                        }
                    }
                }

                serviceCoverage.coveredBy = entitlementBase.coveredBy;

                List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = 
                    ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();

                if( !commonEntitlementSettings.isEmpty() && !commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c ) {
                    sortServiceCoverage(serviceCoverage);
                }

                // Callback method to further filter contracts and warranties.
                handleQualifiedServiceCoverage( sourceRecord, entitlementBase, serviceCoverage );

                if ( UserInfo.isMultiCurrencyOrganization() && !isAutoEntitlement ) {
                    serviceCoverage.currencyISOCode = (String)sourceRecord.get('CurrencyISOCode');
                } else {
                    serviceCoverage.currencyISOCode = UserInfo.getDefaultCurrency();
                }
            }


        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getQualifiedServiceCoverage() : Failed to retrieve Contract Lines or Asset Warranties. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQualifiedServiceCoverage() - exit; serviceCoverage= ' + serviceCoverage );
        }

        return serviceCoverage;
    }

    /**
     * Private method to sort coverage info list
     */
    private void sortServiceCoverage( final Ever.ServiceCoverage serviceCoverage ) {

        // Set list to null if contract or warranty not exists.
        serviceCoverage.warrantyList = ( serviceCoverage.warrantyList.size() > 0 ) ? serviceCoverage.warrantyList : null;
        serviceCoverage.contractList = ( serviceCoverage.contractList.size() > 0 ) ? serviceCoverage.contractList : null;

        if( serviceCoverage.warrantyList != null ) {
            serviceCoverage.warrantyList.sort();
        }

        if( serviceCoverage.contractList != null ) {
            serviceCoverage.contractList.sort();
        }
    }
    /**
     * This method is used to create and populate warranty informations from asset warranty records.
     */
    private List<Ever.CoverageInfo> createWarrantyInfo( final List<AssetWarranty> assetWarrantyList, final String trackedBy, final String trackedByLabel ) {

        System.debug( LoggingLevel.FINE, 'createWarrantyInfo() - enter; assetWarrantyList= ' + assetWarrantyList );

        List<Ever.CoverageInfo> warrantyList = new List<Ever.CoverageInfo>();

        try {

            List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();
            Boolean stackRankingEnabled = false;

            if ( !commonEntitlementSettings.isEmpty() && 
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null) {
                stackRankingEnabled = true;
            }

            for( AssetWarranty assetWarranty : assetWarrantyList ) {

                Ever.CoverageInfo warranty = new Ever.CoverageInfo();

                warranty.Id = assetWarranty.id;
                warranty.coverageType = Ever.CoverageType.Warranty.name();
                warranty.assetId = assetWarranty.AssetId;
                warranty.name = assetWarranty.AssetWarrantyNumber;
                warranty.trackedBy = trackedBy;
                warranty.trackedByLabel = trackedByLabel;
                warranty.warrantyType = assetWarranty.WarrantyType;
                warranty.startDate = assetWarranty.StartDate;
                warranty.endDate = assetWarranty.EndDate;
                warranty.pricebookId = assetWarranty.Pricebook2Id;
                if( assetWarranty.EndDate != null ){
                    warranty.remainingDays = Date.today().daysBetween(assetWarranty.EndDate);
                }

                if( assetWarranty.WarrantyTerm != null ) {

                    final Ever.WarrantyTerm warrantyTerm = new Ever.WarrantyTerm();
                    warrantyTerm.Id = assetWarranty.WarrantyTermId;
                    warrantyTerm.name = assetWarranty.WarrantyTerm.WarrantyTermName;

                    warranty.warrantyTerm = warrantyTerm;
                }

                if ( stackRankingEnabled ) {
                    warranty.stackRankingFieldValue = 
                        assetWarranty.get((String)commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c);
                }

                warrantyList.add(warranty);
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createWarrantyInfo() : Failed to create Warranty Info wrapper. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createWarrantyInfo() - exit; warrantyList= ' + warrantyList );
        }

        return warrantyList;
    }

    /**
     * This method is used to create and populate contract line informations from ContractLineItem records.
     */
    private List<Ever.CoverageInfo> createContractInfo( final Adm.EntitlementBase entitlementBase, final List<ContractLineItem> contractLineList, Map<id, List<Entitlement>> coverageEntitlementMap, final String trackedBy, final String trackedByLabel, Map<id, List<SVMXA360__ContractPriceLineItem__c>> entitlementCPLIMap, SObject sourceRecord ) {

        System.debug( LoggingLevel.FINE, 'createContractInfo() - enter; contractLineList= ' + contractLineList );

        List<Ever.CoverageInfo> contractList = new List<Ever.CoverageInfo>();

        try {

            List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();
            Boolean stackRankingEnabled = false;

            if ( !commonEntitlementSettings.isEmpty() && 
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null ) {
                stackRankingEnabled = true;
            }

            // Create coverage info wrapper for each contract line item.
            for( ContractLineItem contractLine : contractLineList ) {

                Ever.CoverageInfo contractInfo = new Ever.CoverageInfo();
                contractInfo.id = contractLine.id;
                contractInfo.name = contractLine.ServiceContract.Name;
                contractInfo.coverageType = Ever.CoverageType.Contract.name();
                contractInfo.trackedBy = trackedBy;
                contractInfo.trackedByLabel = trackedByLabel;
                contractInfo.assetId = contractLine.AssetId;
                contractInfo.contactId = contractLine.ServiceContract.ContactId;
                contractInfo.accountId = contractLine.ServiceContract.AccountId;
                contractInfo.serviceContractId = contractLine.ServiceContractId;
                contractInfo.contractLineItemId = contractLine.id;
                contractInfo.startDate = (contractLine.StartDate != null && contractLine.EndDate != null && entitlementBase.coveredBy.equalsIgnoreCase(StringAsset)) ? contractLine.StartDate : contractLine.ServiceContract.StartDate;
                contractInfo.endDate = (contractLine.StartDate != null && contractLine.EndDate != null && entitlementBase.coveredBy.equalsIgnoreCase(StringAsset) ) ? contractLine.EndDate : contractLine.ServiceContract.EndDate;
                contractInfo.pricebookId = contractLine.ServiceContract.Pricebook2Id;
                if( contractInfo.endDate != null ) {
                    contractInfo.remainingDays = Date.today().daysBetween(contractInfo.endDate);
                }

                // Create entitlement info wrapper if exists.
                if( coverageEntitlementMap.containsKey(contractInfo.id) ) {
                    contractInfo.entitlements = createEntitlementInfo( coverageEntitlementMap.get(contractInfo.id), trackedBy, trackedByLabel, false, entitlementCPLIMap, sourceRecord );
                } else if( coverageEntitlementMap.containsKey(contractInfo.serviceContractId) ) {
                    contractInfo.entitlements = createEntitlementInfo( coverageEntitlementMap.get(contractInfo.serviceContractId), trackedBy, trackedByLabel, true , entitlementCPLIMap, sourceRecord);
                }

                if ( stackRankingEnabled ) {
                    contractInfo.stackRankingFieldValue = 
                        contractLine.getSobject('ServiceContract').get((String)commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c);
                }

                contractList.add(contractInfo);
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractInfo() : Failed to create Contract Info wrapper. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createContractInfo() - exit; contractList= ' + contractList );
        }

        return contractList;
    }

    /**
     * This method is used to create and populate contract line informations from ContractLineItem records.
     */
    private List<Ever.CoverageInfo> createServiceContractInfo( final Adm.EntitlementBase entitlementBase, final List<ServiceContract> serviceContractList, Map<id, List<Entitlement>> coverageEntitlementMap, final String trackedBy, final String trackedByLabel, Map<id, List<SVMXA360__ContractPriceLineItem__c>> entitlementCPLIMap, SObject sourceRecord ) {

        System.debug( LoggingLevel.FINE, 'createServiceContractInfo() - enter; serviceContractList= ' + serviceContractList );

        List<Ever.CoverageInfo> contractList = new List<Ever.CoverageInfo>();

        try {

            List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();
            Boolean stackRankingEnabled = false;

            if ( !commonEntitlementSettings.isEmpty() && 
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null ) {
                stackRankingEnabled = true;
            }

            // Create coverage info wrapper for each contract line item.
            for( ServiceContract serviceContractRecord : serviceContractList ) {

                Ever.CoverageInfo contractInfo = new Ever.CoverageInfo();
                contractInfo.id = serviceContractRecord.id;
                contractInfo.name = serviceContractRecord.Name;
                contractInfo.coverageType = Ever.CoverageType.Contract.name();
                contractInfo.trackedBy = trackedBy;
                contractInfo.trackedByLabel = trackedByLabel;
                contractInfo.contactId = serviceContractRecord.ContactId;
                contractInfo.accountId = serviceContractRecord.AccountId;
                contractInfo.serviceContractId = serviceContractRecord.Id;
                contractInfo.startDate = serviceContractRecord.StartDate;
                contractInfo.endDate = serviceContractRecord.EndDate;
                contractInfo.pricebookId = serviceContractRecord.Pricebook2Id;
                if( serviceContractRecord.EndDate != null ) {
                    contractInfo.remainingDays = Date.today().daysBetween(serviceContractRecord.EndDate);
                }
                // Create entitlement info wrapper if exists.
                if( coverageEntitlementMap.containsKey(contractInfo.serviceContractId) ) {
                    contractInfo.entitlements = createEntitlementInfo( coverageEntitlementMap.get(contractInfo.serviceContractId), trackedBy, trackedByLabel, true, entitlementCPLIMap, sourceRecord);
                }

                if ( stackRankingEnabled ) {
                    contractInfo.stackRankingFieldValue = 
                        serviceContractRecord.get((String)commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c);
                }

                contractList.add(contractInfo);
            }
            contractList.sort();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createServiceContractInfo() : Failed to create Contract Info wrapper. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createServiceContractInfo() - exit; contractList= ' + contractList );
        }

        return contractList;
    }

    /**
     * This method is used to create entitlement info wrapper.
     */
    private List<Ever.CoverageInfo> createEntitlementInfo( final List<Entitlement> entitlementRecords, final String trackedBy, final String trackedByLabel, final Boolean isServiceContract , Map<id, List<SVMXA360__ContractPriceLineItem__c>> entitlementCPLIMap, SObject sourceRecord) {

        System.debug( LoggingLevel.FINE, 'createEntitlementInfo() - enter; entitlementRecords= ' + entitlementRecords );

        List<Ever.CoverageInfo> entitlementInfoList = new List<Ever.CoverageInfo>();

        try {

            Map<String,Double> conversionRateMap = new Map<String,Double>();

            if ( UserInfo.isMultiCurrencyOrganization() && !isAutoEntitlement) {

                Set<String> isoCodes = new Set<String>();
                
                for( Entitlement entitlementRecord : entitlementRecords ) {
                    isoCodes.add( (String)entitlementRecord.get('CurrencyIsoCode') );
                    
                    if ( entitlementCPLIMap.get(entitlementRecord.Id) != NULL ){
                        for ( SVMXA360__ContractPriceLineItem__c cpliRecord: entitlementCPLIMap.get(entitlementRecord.Id)) {
                            isoCodes.add( (String)cpliRecord.get('CurrencyIsoCode') );
                        }
                    }
                }

                isoCodes.add( (String)sourceRecord.get('CurrencyIsoCode') );

                List<SObject> currencyTypeList = SvmxDatabase.query( Database.query('SELECT IsoCode,ConversionRate FROM'+
                                                                                    ' CurrencyType WHERE IsoCode IN : isoCodes') );

                for( SObject currencyTypeRecord : currencyTypeList){          
                    conversionRateMap.put((String)currencyTypeRecord.get('IsoCode'),(Double)currencyTypeRecord.get('ConversionRate'));        
                }
            }

            for( Entitlement entitlementRecord : entitlementRecords ) {

                Ever.CoverageInfo entitlementInfo = new Ever.CoverageInfo();
                entitlementInfo.id = entitlementRecord.Id;
                entitlementInfo.name = entitlementRecord.Name;
                entitlementInfo.coverageType = Ever.CoverageType.Entitlement.name();
                entitlementInfo.trackedBy = trackedBy;
                entitlementInfo.trackedByLabel = trackedByLabel;
                entitlementInfo.serviceContractId = isServiceContract ? entitlementRecord.ServiceContractId : entitlementRecord.ContractLineItem.ServiceContractId;
                entitlementInfo.contractLineItemId = entitlementRecord.ContractLineItemId;
                entitlementInfo.startDate = entitlementRecord.StartDate;
                entitlementInfo.endDate = entitlementRecord.EndDate;
                if( entitlementRecord.EndDate != null ) {
                    entitlementInfo.remainingDays = Date.today().daysBetween(entitlementRecord.EndDate);
                }

                entitlementInfo.serviceProductId = entitlementRecord.SVMXA360__EntitledServiceProductId__c;
                entitlementInfo.serviceType = entitlementRecord.SVMXA360__ServiceCountType__c;
                if( String.isNotBlank(entitlementInfo.serviceType) && entitlementInfo.serviceType.equalsIgnoreCase('Amount') ) {
                    entitlementInfo.serviceAlertThreshold = entitlementRecord.SVMXA360__ServiceAmountAlertThreshold__c;
                    entitlementInfo.totalService = entitlementRecord.SVMXA360__TotalServiceAmount__c ;
                    entitlementInfo.consumedService = entitlementRecord.SVMXA360__ConsumedServiceAmount__c != null ? entitlementRecord.SVMXA360__ConsumedServiceAmount__c : 0;
                    if ( !isAutoEntitlement ) {
                        populateServiceAmounts(entitlementInfo, sourceRecord, entitlementRecord, conversionRateMap);
                    }    
                } else {
                    entitlementInfo.serviceAlertThreshold = entitlementRecord.SVMXA360__ServiceCountAlertThreshold__c;
                    entitlementInfo.totalService = entitlementRecord.SVMXA360__TotalServiceCount__c ;
                    entitlementInfo.consumedService = entitlementRecord.SVMXA360__ConsumedServiceCount__c != null ? entitlementRecord.SVMXA360__ConsumedServiceCount__c : 0;
                }
                entitlementInfo.pricebookId = entitlementRecord.ServiceContract.Pricebook2Id;
                entitlementInfo.assetId = entitlementRecord.AssetId;
                entitlementInfo.accountId = entitlementRecord.AccountId;

                entitlementInfo.contractPriceLineItems = createCPLIInfo(entitlementCPLIMap.get(entitlementRecord.Id) , sourceRecord, conversionRateMap);

                entitlementInfoList.add( entitlementInfo );

                entitledServiceMap.put(entitlementInfo.id, entitlementInfo);
            }
            entitlementInfoList.sort();
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitlementInfo() : Failed to create Entitlement Info wrapper. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createEntitlementInfo() - enter; entitlementInfoList= ' + entitlementInfoList );
        }

        return entitlementInfoList;
    }

    /**
     * Private method to populate expression wrapper with amount fields.
     */
    private static void populateServiceAmounts (Ever.CoverageInfo entitlementInfo, SObject sourceRecord, Entitlement entitlementRecord, 
                                                Map<String,Double> conversionRateMap) {
        
        System.debug( LoggingLevel.DEBUG, 'populateServiceAmounts() - enter; entitlementRecord = '+entitlementRecord);

        try {

            if ( UserInfo.isMultiCurrencyOrganization() ) {

                String sourceRecordCurrencyCode = (String)sourceRecord.get('CurrencyIsoCode');
                String entitlementCurrencyCode = (String)entitlementRecord.get('CurrencyIsoCode');

                if ( entitlementInfo.serviceAlertThreshold != null && entitlementInfo.serviceAlertThreshold != 0 ) {
                    entitlementInfo.serviceAlertThreshold = (entitlementInfo.serviceAlertThreshold/conversionRateMap.get(entitlementCurrencyCode)) * 
                                                            conversionRateMap.get(sourceRecordCurrencyCode);
                }
                
                if ( entitlementInfo.totalService != 0 ) {
                    entitlementInfo.totalService = (entitlementInfo.totalService/conversionRateMap.get(entitlementCurrencyCode)) * 
                                                    conversionRateMap.get(sourceRecordCurrencyCode);
                }

                if ( entitlementInfo.consumedService != 0 ) {
                    entitlementInfo.consumedService = (entitlementInfo.consumedService/conversionRateMap.get(entitlementCurrencyCode)) * 
                            conversionRateMap.get(sourceRecordCurrencyCode);
                }
                
            }

        } catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'populateServiceAmounts() : Failed to populate Service Amounts. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }

    /**
     * This method is used to create CPLI info wrapper.
     */
    private List<Ever.CoverageInfo> createCPLIInfo( final List<SVMXA360__ContractPriceLineItem__c> cpliRecords, SObject sourceRecord, Map<String,Double> conversionRateMap) {

        System.debug( LoggingLevel.FINE, 'createCPLIInfo() - enter; cpliRecords= ' + cpliRecords );

        List<Ever.CoverageInfo> cpliInfoList = new List<Ever.CoverageInfo>();

        try {

            if( cpliRecords != NULL) {

                for( SVMXA360__ContractPriceLineItem__c cpliRecord : cpliRecords ) {

                    Ever.CoverageInfo cpliInfo = new Ever.CoverageInfo();
                    cpliInfo.Id = cpliRecord.Id;
                    cpliInfo.name = cpliRecord.Name;
                    cpliInfo.contractLineItemId = cpliRecord.SVMXA360__ContractLineId__c;
                    cpliInfo.entitledServiceId = cpliRecord.SVMXA360__EntitledServiceId__c;
                    cpliInfo.lineType = cpliRecord.SVMXA360__LineType__c;
                    cpliInfo.productName = cpliRecord.SVMXA360__ProductId__r.Name;
                    cpliInfo.productFamily = cpliRecord.SVMXA360__ProductFamily__c;
                    cpliInfo.entitledDiscount = cpliRecord.SVMXA360__EntitledDiscount__c;
                    cpliInfo.entitledPrice = cpliRecord.SVMXA360__EntitledPrice__c;
                    cpliInfo.surcharge = cpliRecord.SVMXA360__Surcharge__c;
                    cpliInfo.expenseItem = cpliRecord.SVMXA360__ExpenseItem__c;
                    
                    if(UserInfo.isMultiCurrencyOrganization() && cpliInfo.entitledPrice != NULL && !isAutoEntitlement) {
                        cpliInfo.currencyCode = (String)sourceRecord.get('CurrencyISOCode');
                        
                        String cpliCurrencyCode = (String)cpliRecord.get('CurrencyIsoCode');
                        cpliInfo.entitledPrice = (cpliInfo.entitledPrice/conversionRateMap.get(cpliCurrencyCode)) * 
                                                    conversionRateMap.get(cpliInfo.currencyCode);
                    }  else {
                        cpliInfo.currencyCode = UserInfo.getDefaultCurrency();
                    }
                        
                    cpliInfoList.add(cpliInfo);

                }
                cpliInfoList.sort();
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createCPLIInfo() : Failed to create CPLI Info wrapper. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createCPLIInfo() - enter; cpliInfoList= ' + cpliInfoList );
        }

        return cpliInfoList;

    }

    /**
     * This method is used to create entitlement history record from given source record and service coverage details.
     */
    private EntitlementVerificationHistory__c createEntitlementHistory( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.FINE, 'createEntitlementHistory() - enter; sourceRecord= ' + sourceRecord );

        final EntitlementVerificationHistory__c entitlementHistory = new EntitlementVerificationHistory__c();

        try {

            // Configure object reference by source object type.
            switch on sourceRecord {

                when Case caseRecord {
                    entitlementHistory.SVMXA360__CaseId__c = caseRecord.id;
                }

                when WorkOrder workOrderRecord {
                    entitlementHistory.SVMXA360__WorkOrderId__c = workOrderRecord.Id;
                }

                when ReturnOrder returnOrderRecord {
                    entitlementHistory.SVMXA360__ReturnOrderId__c = returnOrderRecord.Id;
                }
            }

            // Pupulate start date and end date if exists.
            if( serviceCoverage.selectedCoverage != null ) {

                entitlementHistory.SVMXA360__StartDate__c = serviceCoverage.selectedCoverage.startDate;
				entitlementHistory.SVMXA360__EndDate__c = serviceCoverage.selectedCoverage.endDate;
                entitlementHistory.SVMXA360__TrackedAt__c = serviceCoverage.selectedCoverage.trackedBy;
            }

            entitlementHistory.SVMXA360__EntitledBy__c = serviceCoverage.coveredBy;
            entitlementHistory.SVMXA360__AssetId__c = (Id) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) );
            entitlementHistory.SVMXA360__EntitlementDate__c = (Date) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.EntitlementDate ) );
            if( !sourceObjectName.equalsIgnoreCase(String.valueOf(ReturnOrder.getSObjectType())) ) {
                entitlementHistory.SVMXA360__EntitlementId__c = (Id) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Entitlement ) );
            }
            entitlementHistory.SVMXA360__EntitledServiceId__c = (Id) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.EntitledService ) );
            entitlementHistory.SVMXA360__AssetWarrantyId__c = (Id) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.AssetWarranty ) );
            entitlementHistory.SVMXA360__ServiceContractId__c = (Id) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.ServiceContract ) );
            entitlementHistory.SVMXA360__ContractLineItemId__c = (Id) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.ContractLineItem ) );

            if( isAutoEntitlement ) {

                entitlementHistory.SVMXA360__MultipleCoverages__c = serviceCoverage.multipleCoverages;
                entitlementHistory.SVMXA360__MultipleEntitlement__c = serviceCoverage.multipleEntitlements;
            }

            entitlementHistory.SVMXA360__VerificationMode__c = isAutoEntitlement ? Ever.VERIFICATION_MODE_AUTO : Ever.VERIFICATION_MODE_MANUAL;
            entitlementHistory.SVMXA360__EntitlementNotes__c = serviceCoverage.entitlementNotes;
            entitlementHistory.SVMXA360__BillingType__c = String.valueOf( sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.BillingType ) ) );

            if( isAutoEntitlement ) {
                entitlementHistory.SVMXA360__EntitlementEngineNotes__c = createEngineNote(sourceRecord, serviceCoverage );
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitlementHistory() : Failed to create Entitlement history record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'createEntitlementHistory() - exit; entitlementHistory= ' + entitlementHistory );
        }

        return entitlementHistory;
    }

    /**
     * This method is used to create engine notes with qualified auto entitlement rule and service assignment rule.
     */
    private String createEngineNote( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage ) {

        String engineNote = '';
        Adm.EntitlementBase entitlementBase = getEntitlementBase(sourceRecord);
        if( entitlementBase != null ) {
            engineNote = 'Auto Entitlement Rule: ' + entitlementBase.name;
        }

        if( serviceCoverage != null && serviceCoverage.serviceAssignmentRule != null  ) {
            if( !String.isEmpty(engineNote) ) {
                engineNote += ',\n';
            }
            engineNote += 'Service Assignment Rule: ' + serviceCoverage.serviceAssignmentRule.name;
        }

        return engineNote;
    }

    /**
     * This method is used to create formated entitlement note with date and coverage names.
     */
    protected String createEntitlementNote( final SObject sourceRecord, final Ever.CoverageInfo coverageInfo ) {

        String entitlementNotes = 'Covered By: '+ coverageInfo.name;
        entitlementNotes += ',\n Start Date: '+ coverageInfo.startDate;
        entitlementNotes += ',\n End Date: '+ coverageInfo.endDate;
        entitlementNotes += ',\n Entitlement Date: ' + String.valueOf( retrieveEntitlementDate( sourceRecord ) );

        return entitlementNotes;
    }

    /**
     * This method is used to populare billing type on Work Order.
     */
    private void updateBillingType( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage, final Adm.EntitlementBase entitlementBase ) {

        System.debug( LoggingLevel.FINEST, 'updateBillingType() - enter; BillingType= ' + sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.BillingType) ) );

        if( String.isNotBlank( serviceCoverage.billingType) ) {
            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.BillingType), serviceCoverage.billingType );
        } else {

            if( entitlementBase != null && String.isNotBlank( entitlementBase.defaultBillingType ) ) {
                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.BillingType), entitlementBase.defaultBillingType );
            }

            System.debug(LoggingLevel.INFO, 'updateBillingType() : selectedCoverage= ' + serviceCoverage.selectedCoverage );
            if( serviceCoverage.selectedCoverage != null ) {

                Boolean updateBillingType = true;

                // if the Threshold levels are reached, i.e., Remaining Service Count =< 0 (Example: 0 or negative value)
                // then have the user pick a value for Billing Type
                // If the Service Threshold has been reached, then have the user pick a value for Billing Type.
                if( ((Id)serviceCoverage.selectedCoverage.id).getSobjectType() == Entitlement.getSobjectType() && serviceCoverage.selectedCoverage.totalService != null && serviceCoverage.selectedCoverage.consumedService != null ) {
                    updateBillingType = ( (serviceCoverage.selectedCoverage.totalService - serviceCoverage.selectedCoverage.consumedService) > 0 ) &&
                        (serviceCoverage.selectedCoverage.consumedService < serviceCoverage.selectedCoverage.totalService);

                    System.debug(LoggingLevel.INFO, 'updateBillingType() : Verify by service count. updateBillingType= ' + updateBillingType );
                }

                if( updateBillingType ) {

                    final Date entitlementDate = (Date) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.EntitlementDate) );

                    if( serviceCoverage.selectedCoverage != null && serviceCoverage.selectedCoverage.startDate <= entitlementDate && serviceCoverage.selectedCoverage.endDate >= entitlementDate ) {

                        if( sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract) ) != null ) {
                            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.BillingType), StringContract );
                        } else if( sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty) ) != null ) {
                            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.BillingType), StringWarranty );
                        }
                    }
                }
            }
        }

        System.debug( LoggingLevel.FINEST, 'updateBillingType() - exit; BillingType= ' + sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.BillingType) ) );
    }

    private void updateSourceEntitlement( final List<SObject> sourceRecords ) {

        System.debug( LoggingLevel.FINE, 'updateSourceEntitlement() - enter; sourceRecord= ' + sourceRecords.size() );

        try {

            if( sourceRecords != null && !sourceRecords.isEmpty() ) {

                final String sObjectType = String.valueOf( sourceRecords.get(0).getSObjectType() );
                final List<SVMXA360__ApplicationEventBus__e> servicemaxEventList = new List<SVMXA360__ApplicationEventBus__e>();

                for( SObject sourceRecord : sourceRecords ) {

                    final SVMXA360__ApplicationEventBus__e servicemaxEvent = new SVMXA360__ApplicationEventBus__e ();
                    servicemaxEvent.Type__c = SvmxLogger.Application.Entitlement.name();
                    servicemaxEvent.SVMXA360__SourceRecordId__c = sourceRecord.Id;
                    servicemaxEvent.SVMXA360__SourceObjectAPIName__c = sObjectType;

                    servicemaxEventList.add(servicemaxEvent);
                }

                // Publish event to event bus.
                List<Database.SaveResult> saveResultList = EventBus.publish(servicemaxEventList);

                for( Database.SaveResult saveResult : saveResultList ) {

                    if( saveResult.isSuccess() ) {

                        System.debug( LoggingLevel.DEBUG, 'Successfully published event.' );
                    } else {
                        for( Database.Error error : saveResult.getErrors() ) {
                            System.debug( LoggingLevel.ERROR, 'Failed to publish event: ' + error.getStatusCode() + ' - ' + error.getMessage() );
                        }
                    }
                }
            }
        }
        catch(Exception e ) {
            System.debug( LoggingLevel.ERROR, 'updateSourceEntitlement() : Failed to invoke autolaunch flow. Error= ' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateSourceEntitlement() - exit' );
        }
    }

    /**
     * Public method to populate pricebooks on Work Order.
     */
    public void populateWorkOrderPricebook(final List<SObject> sourceRecords, Map<Id, String> workOrderPricebookMap) {

        System.debug( LoggingLevel.DEBUG, 'populateWorkOrderPricebook() - enter' );
        ADM_ExpressionHandler expressionHandler = new ADM_ExpressionHandler();
        List<SVMXA360__CONF_Expression__c> expressionRecordList = new List<SVMXA360__CONF_Expression__c>();
        Map<Id, Adm.PricebookAssignmentRule> pricebookAssignmentRuleMap = new Map<Id,Adm.PricebookAssignmentRule>();
        Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = new Map<String, Schema.DescribeFieldResult>();

        try {

            for( SObject sourceRecord : sourceRecords ) {

                if( !workOrderPricebookMap.isEmpty() && workOrderPricebookMap.containsKey(sourceRecord.Id) ) {

                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.Pricebook), workOrderPricebookMap.get(sourceRecord.Id) );

                } else {

                    if( pricebookAssignmentRuleMap.isEmpty() ) {

                        sObjectFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( sourceObjectName );
                        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList =
                            ADM_PricebookAssignmentRuleManager.getInstance().getPricebookAssignmentRules('WorkOrder');

                        for( Adm.PricebookAssignmentRule pricebookAssignmentRule : pricebookAssignmentRuleList ) {
                            if( pricebookAssignmentRule.active && pricebookAssignmentRule.qualifyingCriteria != null && String.isNotBlank( pricebookAssignmentRule.qualifyingCriteria.id ) ) {
                                pricebookAssignmentRuleMap.put(pricebookAssignmentRule.qualifyingCriteria.id, pricebookAssignmentRule );
                            }
                        }

                        Map<id,SVMXA360__CONF_Expression__c> expressionRecordMap =
                            new Map<id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(pricebookAssignmentRuleMap.keySet()));
                        for( Adm.PricebookAssignmentRule pricebookAssignmentRule : pricebookAssignmentRuleList ) {
                            if( pricebookAssignmentRule.active && pricebookAssignmentRule.qualifyingCriteria != null && String.isNotBlank( pricebookAssignmentRule.qualifyingCriteria.id ) ) {
                                expressionRecordList.add( expressionRecordMap.get(pricebookAssignmentRule.qualifyingCriteria.id) );
                            }
                        }

                    }

                    if( !expressionRecordList.isEmpty() && !pricebookAssignmentRuleMap.isEmpty() ) {
                        for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                            // Parse method is called for a record to evaluate the expression for list of related records
                            if( expressionHandler.parseExpression( sourceRecord, sObjectFieldResultMap, expressionRecord ).equals('T') ) {
                                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.Pricebook), pricebookAssignmentRuleMap.get(expressionRecord.Id).pricebook.id);
                                break;
                            }
                        }
                    }
                }
            }

        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'populateWorkOrderPricebook() : Failed to populate work order pricebook. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'populateWorkOrderPricebook() - exit' );
        }
    }

    /**
     * This method is used to check whether inherit Service setting is
     * enabled for source object.
     */
    private Boolean inheritService( final SObject sourceRecord ) {

        Boolean inheritService = inheritService();

        if( inheritService ) {

            final String entitledServiceId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.EntitledService) );
            final String assetWarrantyId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty) );
            inheritService = ( String.isNotBlank(entitledServiceId) || String.isNotBlank(assetWarrantyId) );
        }

        return inheritService;
    }

    /**
     * This method is used to check whether inherit Service setting is
     * enabled for source object.
     */
    private Boolean inheritService() {

        Boolean inheritService = false;

        if( !String.valueOf(Case.getSObjectType()).equalsIgnoreCase(sourceObjectName) && isAutoEntitlement ) {

            final List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettingsList = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();

            if( commonEntitlementSettingsList.isEmpty() ) {

                System.debug( LoggingLevel.ERROR, 'handleEntitlementSettings() : Failed to retrieve Common Entitlement Settings' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + 'Common Entitlement Settings' );
            }

            final SVMXA360__CONF_EntitlementSettings__c commonEntitlementSettings = commonEntitlementSettingsList.get(0);

            switch on sourceObjectName {

                when 'WorkOrder' {
                    inheritService = commonEntitlementSettings.SVMXA360__InheritServiceOnWorkOrder__c;
                }
                when 'ReturnOrder' {
                    inheritService = commonEntitlementSettings.SVMXA360__InheritServiceOnReturnOrder__c;
                }
            }
        }

        return inheritService;
    }

    /**
     * This method is used to handle service count logic
     */
    private void handleEntitledServiceUsage( final List<SObject> sourceRecords, final Map<String, EntitlementVerificationHistory__c> entitlementHistoryMap, final Map<String, EntitlementVerificationHistory__c> sourceRecordHistoryMap ) {

        System.debug( LoggingLevel.FINE, 'handleEntitledServiceUsage() - enter; sObjectType=' + sourceRecords );

        try {

            final List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettingsList = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();

            if( commonEntitlementSettingsList.isEmpty() ) {

                System.debug( LoggingLevel.ERROR, 'handleEntitledServiceUsage() : Failed to retrieve Common Entitlement Settings' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + 'Common Entitlement Settings' );
            }

            final SVMXA360__CONF_EntitlementSettings__c commonEntitlementSettings = commonEntitlementSettingsList.get(0);

            final Boolean adjustServiceThreshold = commonEntitlementSettings.SVMXA360__AdjustServiceThreshold__c;
            final String adjustVisitCountAssignedObject = commonEntitlementSettings.SVMXA360__AdjustVisitCountAssignedObject__c;

            System.debug( LoggingLevel.DEBUG, 'handleEntitledServiceUsage() : adjustServiceThreshold=' + adjustServiceThreshold );
            System.debug( LoggingLevel.DEBUG, 'handleEntitledServiceUsage() : adjustVisitCountAssignedObject=' + adjustVisitCountAssignedObject );

            final List<Ever.ServiceUsageInfo> serviceUsageInfoList = new List<Ever.ServiceUsageInfo>();
            if( adjustServiceThreshold ) {

                final String sObjectType = String.valueOf( sourceRecords.get(0).getSObjectType() );

                for( SObject sourceRecord : sourceRecords ) {

                    String entitledServiceId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.EntitledService) );

                    if( adjustServiceThreshold && sObjectType.equalsIgnoreCase( adjustVisitCountAssignedObject ) && String.isNotBlank(entitledServiceId) ) {

                        System.debug( LoggingLevel.DEBUG, 'handleEntitledServiceUsage() : sourceRecordHistoryMap=' + sourceRecordHistoryMap );

                        if( sourceRecordHistoryMap.containsKey(sourceRecord.Id) && sourceRecordHistoryMap.get(sourceRecord.Id).SVMXA360__EntitledServiceId__c == entitledServiceId ) {
                            continue;
                        }

                        Ever.ServiceUsageInfo serviceUsageInfo = new Ever.ServiceUsageInfo();

                        serviceUsageInfo.sourceRecordId = sourceRecord.Id;
                        serviceUsageInfo.entitlementHistoryId = entitlementHistoryMap != null && entitlementHistoryMap.containsKey( sourceRecord.Id ) ? entitlementHistoryMap.get( sourceRecord.Id ).Id : null;
                        serviceUsageInfo.entitledServiceId = entitledServiceId;
                        serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Count;
                        serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Decrement;
                        serviceUsageInfo.serviceValue = 1;

                        serviceUsageInfoList.add( serviceUsageInfo );

                        System.debug( LoggingLevel.DEBUG, 'handleEntitledServiceUsage() : serviceUsageInfo=' + serviceUsageInfo );
                    }
                }

                if( adjustServiceThreshold && sObjectType.equalsIgnoreCase( adjustVisitCountAssignedObject ) ) {
                  handleEntitledServiceCredit( serviceUsageInfoList, sourceRecords, entitlementHistoryMap, sourceRecordHistoryMap );
                }
            }

            if( !serviceUsageInfoList.isEmpty() ) {
                new EVER_EntitledServiceUsage().updateConsumedUsage(serviceUsageInfoList, isAutoEntitlement ? 'Auto Entitlement' : 'Interactive Entitlement' );
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'handleEntitledServiceUsage() : Common Entitlement Settings not exists. Error= ' + e.getStackTraceString() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'handleEntitledServiceUsage() : Failed to retrieve Common Entitlement Settings. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'handleEntitledServiceUsage() - exit' );
        }
    }

    /**
     * This method is to perform credit back logic on entitled service usage.
     */
    private void handleEntitledServiceCredit( final List<Ever.ServiceUsageInfo> serviceUsageInfoList, final List<SObject> sourceRecords, final Map<String, EntitlementVerificationHistory__c> entitlementHistoryMap, final Map<String, EntitlementVerificationHistory__c> sourceRecordHistoryMap ) {

        System.debug( LoggingLevel.FINE, 'handleEntitledServiceCredit() - enter' );

        try {

            for( SObject sourceRecord : sourceRecords ) {

                final String sourceRecordId = sourceRecord.Id;
                final String entitledServiceId = (String) sourceRecord.get( entitlementFieldMap.get(Ever.EntitlementField.EntitledService) );

                // Process only if the entitlement is performed atleast once.
                if( !sourceRecordHistoryMap.containsKey(sourceRecordId) ) {
                    continue;
                }

                // Process credit operation only if the entitled service got updated.
                EntitlementVerificationHistory__c history = sourceRecordHistoryMap.get(sourceRecordId);
                if( String.isNotBlank( history.SVMXA360__EntitledServiceId__c ) && history.SVMXA360__EntitledServiceId__c != entitledServiceId ) {

                    Ever.ServiceUsageInfo serviceUsageInfo = new Ever.ServiceUsageInfo();

                    serviceUsageInfo.sourceRecordId = sourceRecord.Id;
                    serviceUsageInfo.entitlementHistoryId = entitlementHistoryMap != null && entitlementHistoryMap.containsKey(sourceRecord.Id) ? entitlementHistoryMap.get( sourceRecord.Id ).Id : null;
                    serviceUsageInfo.entitledServiceId = history.SVMXA360__EntitledServiceId__c; // Credit back service for old entitled service.
                    serviceUsageInfo.serviceUnit = Ever.ServiceUnit.Count;
                    serviceUsageInfo.serviceOperation = Ever.ServiceOperation.Increment;
                    serviceUsageInfo.serviceValue = 1;

                    serviceUsageInfoList.add( serviceUsageInfo );

                    System.debug( LoggingLevel.DEBUG, 'handleEntitledServiceCredit() : Crediting Back Entitled Service. serviceUsageInfo= ' + serviceUsageInfo );
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'handleEntitledServiceCredit() : Failed to perform entitled service credit operation. Error= ' + e.getMessage() );
        }
        finally {
            System.debug( LoggingLevel.FINE, 'handleEntitledServiceCredit() - exit' );
        }
    }

    private Map<String, EntitlementVerificationHistory__c> getOldHistoryMap( final List<SObject> sourceRecords ) {

        // Retrieve old entitlement history.
        final List<EntitlementVerificationHistory__c> entitlementHistoryList = SvmxDatabase.query([SELECT Id, Name, SVMXA360__EntitledServiceId__c, SVMXA360__CaseId__c, SVMXA360__WorkOrderId__c, SVMXA360__ReturnOrderId__c FROM SVMXA360__EntitlementVerificationHistory__c WHERE (SVMXA360__CaseId__c IN :sourceRecords OR SVMXA360__WorkOrderId__c IN :sourceRecords OR SVMXA360__ReturnOrderId__c IN :sourceRecords) ORDER BY CreatedDate DESC ]);
        final Map<String, EntitlementVerificationHistory__c> sourceRecordHistoryMap = new Map<String, EntitlementVerificationHistory__c>();

        for( EntitlementVerificationHistory__c history : entitlementHistoryList ) {

            String sourceRecordId = history.SVMXA360__CaseId__c;

            switch on sourceObjectName {

                when 'WorkOrder' {
                    sourceRecordId = history.SVMXA360__WorkOrderId__c;
                }

                when 'ReturnOrder' {
                    sourceRecordId = history.SVMXA360__ReturnOrderId__c;
                }
            }

            if( !sourceRecordHistoryMap.containsKey(sourceRecordId) ) {
                sourceRecordHistoryMap.put( sourceRecordId, history );
            }
        }

        return sourceRecordHistoryMap;
    }

    /*
        This method adds onHold service contract status in the set when Include On Hold entitlements checkbox is checked on the engine.
    */
    private void handleOnHoldEntitlements ( final Adm.EntitlementBase entitlementBase ){
        Adm.EntitlementSettings entitlementSettings = (Adm.EntitlementSettings) entitlementBase;
        if( !isAutoEntitlement && entitlementSettings.onHoldEntitlements != null && entitlementSettings.onHoldEntitlements ){
            QualifiedAuthoringStatus.add('OnHold');
        }
    }
    /**
     * Callback method to be implemented in derived class to forther filter qualified service coverages.
     */
    protected abstract void handleQualifiedServiceCoverage( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final Ever.ServiceCoverage serviceCoverage );

    /**
     * Callback method to be implemented in derived class to retrieve entitlement rule/entitlement setting for requested source record.
     */
    protected abstract Adm.EntitlementBase getEntitlementConfiguration( final SObject sourceRecord );

    /**
     * Callback method to be implemented in derived class to validate source record for and missing required fields.
     */
    protected abstract void validateSourceRecord( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase );

    /**
     * Callback method to be implemented in derived class to build entitlement criterias using which contract/warrenties are queried.
     */
    protected abstract void buildEntitlementCriteria( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final EntitlementParams entitlementParams );

    /**
     * Callback method to be implemented in derived class to perform before source object update.
     */
    protected abstract void beforeSourceObjectUpdate( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage );

}