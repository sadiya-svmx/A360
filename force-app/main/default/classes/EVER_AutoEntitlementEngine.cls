/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements logic to perform auto entitlement.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       09 Jul 2020     Created.
 * BLOS-613     Ramachandra Mohan       26 Aug 2020     Support warranty type filtering on Asset Warranty.
 * BLOS-691     Ramachandra Mohan       08 Sep 2020     Entitlement note update on multiple entitlement found.
 * A360CE-251   Ramachandra Mohan       15 Oct 2020     Include only Active entitlement rules to perform entitlement check.
 * A360CE-299   Ramachandra Mohan       30 Oct 2020     Additional condition to validate Account field.
 * A360CE-413   Ramachandra Mohan       12 Jan 2021     Additional condition apply entitled service assignement.
 * A360CE-945   Ramachandra Mohan       18 Nov 2021     Multiple Coverage issue for active Warranties.
 * A360CE-949   Ramachandra Mohan       02 Dec 2021     Change in Multiple Coverages scenarios.
 * A360CE-989   Sandeep Dhariwal        08 Apr 2022     Stack Ranking Changes.
 * A360CE-1014  Sandeep Dhariwal        07 Jun 2022     Handling Stack Ranking for the Contracts with same rank.
 * 
 *****************************************************************************************************/
public with sharing class EVER_AutoEntitlementEngine extends EVER_AbstractEntitlementEngine {
    
    /**
     * Private static variable to hold semicolon string.
     */
    private static final String SEMICOLON = ';';
    
	// Static string variable to hold no coverage found entitlement notes.
    private static final String NOTES_NO_COVERAGE_FOUND				= System.Label.Info_NoCoverageFound;
    
    // Static string variable to hold multiple coverage found entitlement notes.
    private static final String NOTES_MULTIPLE_COVERAGE_FOUND		= System.Label.Info_MultipleCoverageFound;
    
    // Static string variable to hold multiple entitlement found entitlement notes.
    private static final String NOTES_MULTIPLE_ENTITLEMENT_FOUND	= System.Label.Info_MultipleEntitlementFound;
    
    // Private map to hold expression vs entitlement rule information.
    private Map<Id, Adm.EntitlementRule> entitlementRuleMap;
    
    // Private map to hold expression vs entitled service rule information.
    private Map<Id, Adm.ServiceAssignmentRule> entitledServiceRuleMap;
    
    // Private map to hold expression id vs SVMXA360__CONF_Expression__c information.
    private List<SVMXA360__CONF_Expression__c> expressionRecordList;
    
    // Private map to hold expression id vs SVMXA360__CONF_Expression__c information.
    private List<SVMXA360__CONF_Expression__c> entitledServiceExpressionRecordList;
    
    /**
     * Class constructor to create instance of this class with source object name.
     */
    public EVER_AutoEntitlementEngine( final String sourceObjectName ) {
        super( sourceObjectName, true );
    }
    
    /**
     * This method is used to perform auto entitlement for requested list of record ids. 
     * This method retrieves qualified contracts/warranties and applys to source object 
     * as configured in entitlement rule. This method also create entitlement history with 
     * all qualified service coverage.
     * 
     * @param recordIds Source record ids for which auto entitlement to be performed.
     */
    public void performAutoEntitlement( final List<String> recordIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'performAutoEntitlement() - enter; recordIds= ' + recordIds );
        
        try {
            
            /*if( !USER_FeatureAccessManager.getInstance().isFeatureAccesible( SvmxLicense.Application.Entitlement ) ) {
                
                System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Entitlement feature not enabled for the user.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.FEATURE_NOT_LICENSED + SvmxLicense.Application.Entitlement.name() );
            }*/
            
            //Validate requested record id list.
            if( recordIds == null || recordIds.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Invalid request parameters. recordIds= ' + recordIds );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            // retrieve all source records for requested record ids.
            final List<SObject> sourceRecords = retrieveSourceRecords( recordIds );
            
            if( sourceRecords.isEmpty() ) {
                System.debug( LoggingLevel.ERROR, 'performAutoEntitlement() : Record not exists. recordIds= ' + recordIds );
            } else {
                performAutoEntitlement( sourceRecords );
            }
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
     * Override method to retrieve entitlement configuration for requested source record.
     * 
     * @param sourceRecord Source record for which expression rule to be qualified and retrieved.
     */
    override protected Adm.EntitlementBase getEntitlementConfiguration( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementConfiguration() - enter; sourceRecord= ' + sourceRecord );
        
        Adm.EntitlementRule qualifiedEntitlementRule;
        
        try {
   			// Retrieve entitlement rules and expressions for source object name once per instance.
            if( entitlementRuleMap == null ) {
                initRuleExpressions();
            }
            
            if( entitlementRuleMap.size() > 0 && expressionRecordList.size() > 0 ) {
                
                final Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( sourceObjectName );
                final ADM_ExpressionHandler expressionHandler = new ADM_ExpressionHandler();
                
                for( SVMXA360__CONF_Expression__c expressionRecord : expressionRecordList ) {
                    
                    // Parse method is called for a record to evaluate the expression for list of related records
                    if( expressionHandler.parseExpression( sourceRecord, sObjectFieldResultMap, expressionRecord ).equals('T') ) {
                        qualifiedEntitlementRule = entitlementRuleMap.get( expressionRecord.id );
                        break;
                    }
                }
            }
        }
        
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitlementConfiguration() : Failed to retrieve entitlement rule. Error= ' + e.getStackTraceString() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementConfiguration() : Failed to retrieve entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementConfiguration() - exit; qualifiedEntitlementRule= ' + qualifiedEntitlementRule );
        }
        
        return qualifiedEntitlementRule;
    }
    
    /**
     * Method to retrieve entitled service assignment rule for requested source record.
     * 
     * @param sourceRecord Source record for which expression rule to be qualified and retrieved.
     */
    private Adm.ServiceAssignmentRule getEntitledServiceRule( final SObject sourceRecord ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServiceRule() - enter; sourceRecord= ' + sourceRecord );
        
        Adm.ServiceAssignmentRule serviceAssignmentRule;
        
        try {
   			// Retrieve entitlement rules and expressions for source object name once per instance.
            if( entitledServiceRuleMap == null ) {
                initEntitledServiceRuleExpressions();
            }
            
            if( entitledServiceRuleMap.size() > 0 && entitledServiceExpressionRecordList.size() > 0 ) {
                
                final Map<String, Schema.DescribeFieldResult> sObjectFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( sourceObjectName );
                final ADM_ExpressionHandler expressionHandler = new ADM_ExpressionHandler();
                
                for( SVMXA360__CONF_Expression__c expressionRecord : entitledServiceExpressionRecordList ) {
                    
                    // Parse method is called for a record to evaluate the expression for list of related records
                    if( expressionHandler.parseExpression( sourceRecord, sObjectFieldResultMap, expressionRecord ).equals('T') ) {
                        serviceAssignmentRule = entitledServiceRuleMap.get( expressionRecord.id );
                        break;
                    }
                }
            }
        }
        
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceRule() : Failed to retrieve entitlement rule. Error= ' + e.getStackTraceString() );
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServiceRule() : Failed to retrieve entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServiceRule() - exit; serviceAssignmentRule= ' + serviceAssignmentRule );
        }
        
        return serviceAssignmentRule;
    }
    
    /**
     * Override method to validate source record for all required fields. This method will be invoked 
     * by the abstract entitlement engine.
     * 
     * @param sourceRecord Source record against which validations to be performed.
     * @param entitlementBase Entitlement configuration which is used to validate source record.
     */
    override protected void validateSourceRecord( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateSourceRecord() - enter; sourceRecord= ' + sourceRecord );
        
        try {
            final Adm.EntitlementRule entitlementRule = (Adm.EntitlementRule) entitlementBase;
            
            switch on entitlementRule.coveredBy.toLowerCase() {
                
                when 'asset' {
                    
                    if( sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) ) == null ) {
                        throw new SvmxSystem.SvmxNestedException( ERROR_ENVT_MISSING_FIELD + sourceFieldLabelMap.get(entitlementFieldMap.get( Ever.EntitlementField.Asset )) );
                    }
                    
                    if( entitlementRule.checkContracts && entitlementRule.matchAccount && sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) == null ) {
                        throw new SvmxSystem.SvmxNestedException( ERROR_ENVT_MISSING_FIELD + sourceFieldLabelMap.get(entitlementFieldMap.get( Ever.EntitlementField.Account )) );
                    }
                    
                    if( entitlementRule.matchContact && sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Contact ) ) == null ) {
                        throw new SvmxSystem.SvmxNestedException( ERROR_ENVT_MISSING_FIELD + sourceFieldLabelMap.get(entitlementFieldMap.get( Ever.EntitlementField.Contact )) );
                    }
                }
                when 'account' {
                    
                    if( sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) == null ) {
                        throw new SvmxSystem.SvmxNestedException( ERROR_ENVT_MISSING_FIELD + entitlementFieldMap.get( Ever.EntitlementField.Account ) );
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateSourceRecord() : Source record validation failed. Error= ' + e.getMessage() );
            throw e;
        }        
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'validateSourceRecord() : Failed to validate source record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateSourceRecord() - exit');
        }
    }
    
    /**
     * Override method to build entitlement criteria using entitlement rule configuration. This method also 
     * populates set of asset and account Ids which will be used while querying records.
     */
    override protected void buildEntitlementCriteria( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final EntitlementParams entitlementParams ) {
        
        System.debug( LoggingLevel.DEBUG, 'buildEntitlementCriteria() - enter; sourceRecord= ' + sourceRecord );
        
        try {
            
            final Adm.EntitlementRule entitlementRule = (Adm.EntitlementRule) entitlementBase;
            final String entitlementDate = String.valueOf( retrieveEntitlementDate( sourceRecord ) );
            
            switch on entitlementRule.coveredBy.toLowerCase() {
                
                when 'asset' {
                    // Create where clause for contract
                    if( entitlementRule.checkContracts ) {
                        
                        final String lineDataClause = '( StartDate != null AND EndDate != null AND StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')';
                        final String headerDateClause = '( ServiceContract.StartDate <= ' + entitlementDate + ' AND ServiceContract.EndDate >= ' + entitlementDate + ')';
                        
                        entitlementParams.contractWhereClauseList.add( '(' + lineDataClause + ' AND ' + headerDateClause + ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                    }
                    
                    // Create where clause for warranties
                    if( entitlementRule.checkWarranties ) {
                        entitlementParams.warrantyWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                    }
                    
                    // Populate asset ids from the source record
                    final String assetId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) );
                    entitlementParams.assetIds.add( assetId );
                    
                    // Populate account ids if match account options is enabled in the Entitlement Rule.
                    if( entitlementRule.matchAccount ) {
                        entitlementParams.accountIds.add( (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) );
                    } 
                    
                    // Populate parent assed ids if the options are enabled in the entitlement rule.
                    if( entitlementRule.includeParentAsset && assetRecordsMap.get(assetId).ParentId != null ) {
                        entitlementParams.assetIds.add( assetRecordsMap.get(assetId).ParentId );
                    }
                    
                    // Populate root assed ids if the options are enabled in the entitlement rule.
                    if( entitlementRule.includeRootAsset && assetRecordsMap.get(assetId).RootAssetId != assetId ) {
                        entitlementParams.assetIds.add( assetRecordsMap.get(assetId).RootAssetId );
                    }
                    
                    // Populate contact ids if match contact options is enabled in the Entitlement Rule.
                    if( entitlementRule.matchContact ) {
                        entitlementParams.contactIds.add( (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Contact ) ) );
                    }
                    
                    // Populate filter Warranty Types
                    if( String.isNotBlank( entitlementRule.warrantyTypes ) ) {
                        entitlementParams.warrantyTypes.addAll( entitlementRule.warrantyTypes.split(SEMICOLON) );
                    }
                }
                when 'account' {
                    
                    // For Covered By Account, only contract lines to be retrieved.
                    entitlementParams.serviceContractWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                    entitlementParams.accountIds.add( (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) );
                }
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateSourceRecord() : Failed to validate source record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildEntitlementCriteria() - exit' );
        }
    }
    
    /**
     * Overreide method to handle qualified service contract records. One can perform additional 
     * filtering in this callback method.
     */
    override protected void handleQualifiedServiceCoverage( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final Ever.ServiceCoverage serviceCoverage ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleQualifiedServiceCoverage() - enter; sourceRecord= ' + sourceRecord );
        
        try {
            
            final Date entitlementDate = retrieveEntitlementDate( sourceRecord );
            
            final String assetId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) );
            final String accountId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) );
            
            final Adm.EntitlementRule entitlementRule = (Adm.EntitlementRule) entitlementBase;
            
            // When multiple contract found, filter qualified contract by comparing date range and account.
            if( entitlementRule.checkContracts && serviceCoverage.contractList != null ) {
                
                // List only qualified contracts for requested source record.
                List<Ever.CoverageInfo> contractList = new List<Ever.CoverageInfo>();
                for( Ever.CoverageInfo contractInfo : serviceCoverage.contractList ) {
                    
                    if( contractInfo.startDate > entitlementDate || contractInfo.endDate < entitlementDate ) {
                        continue;
                    }
                    
                    if( ( entitlementRule.matchAccount || entitlementRule.coveredBy.equalsIgnoreCase(StringAccount) )  && contractInfo.accountId != accountId ) {
                        continue;
                    }
                    
                    // List only qualified entitlements from the list of all entitlement.
                    if( contractInfo.entitlements != null && contractInfo.entitlements.size() > 0 ) {
                        
                        List<Ever.CoverageInfo> entitlementList = new List<Ever.CoverageInfo>();
                        for( Ever.CoverageInfo entitlementInfo : contractInfo.entitlements ) {
                            
                            if( entitlementInfo.startDate > entitlementDate || entitlementInfo.endDate < entitlementDate ) {
                                continue;
                            }
                            if( entitlementInfo.totalService != null && entitlementInfo.consumedService != null && ( entitlementInfo.totalService - entitlementInfo.consumedService ) <= 0 ) {
                                continue;
                            }
                            entitlementList.add(entitlementInfo);
                        }
                        
                        contractInfo.entitlements = entitlementList;
                    }
                    
                    contractList.add(contractInfo);
                }
                
                serviceCoverage.contractList = contractList;
            }
            
            // Filter warranty by verifind entitlement date range.
            if( entitlementRule.checkWarranties && serviceCoverage.warrantyList != null ) {
                
                List<Ever.CoverageInfo> warrantyList = new List<Ever.CoverageInfo>();
                for( Ever.CoverageInfo warrantyInfo : serviceCoverage.warrantyList ) {
                    
                    if( warrantyInfo.startDate > entitlementDate || warrantyInfo.endDate < entitlementDate ) {
                        continue;
                    }
                    
                    warrantyList.add(warrantyInfo);
                }
                serviceCoverage.warrantyList = warrantyList;
            }  
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'handleQualifiedServiceCoverage() : Failed to perform Service Coverage filter. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleQualifiedServiceCoverage() - exit' );
        }
    }
    
    /**
     * Override method to perform source object update depending on the coverage status.
     */
    override protected void beforeSourceObjectUpdate( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage ) {
        
        System.debug( LoggingLevel.DEBUG, 'beforeSourceObjectUpdate() - enter; sourceRecord= ' + sourceRecord + '; serviceCoverage= ' + serviceCoverage );
        
        try {
            
            Ever.CoverageStatus coverageStatus = getCoverageStatus(serviceCoverage);
            final Adm.EntitlementRule entitlementRule = (Adm.EntitlementRule) getEntitlementBase(sourceRecord);
            
            System.debug( LoggingLevel.INFO, 'beforeSourceObjectUpdate() : coverageStatus= ' + coverageStatus );
            
            // Update source record as per coverage status.
            switch on coverageStatus {
                
                // No coverage found for requested source record.
                when NoCoverage {
                    serviceCoverage.entitlementNotes = NOTES_NO_COVERAGE_FOUND;
                }
                
                // One contract found for source record.
                when OneContract {
                    
                    serviceCoverage.selectedCoverage = serviceCoverage.contractList.get(0);
                    serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.selectedCoverage.serviceContractId );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );
                }
                
                // One Warranty found for source record.
                when OneWarranty {
                    
                    serviceCoverage.selectedCoverage = serviceCoverage.warrantyList.get(0);
                    serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty), serviceCoverage.selectedCoverage.Id );
                }
                
                // One contract and one entitlement found. Populate both service contract and entitlement 
                // reference in the source record.
                when OneContractEntitlement {
                    
                    serviceCoverage.selectedCoverage = serviceCoverage.contractList.get(0).entitlements.get(0);
                    serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.contractList.get(0).serviceContractId );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.Id );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );
                }
                
                // One contract for which multiple entitlements found.
                when OneContractMultipleEntitlements {
                    
                    final String contractId = serviceCoverage.contractList.get(0).Id;
                    serviceCoverage.selectedCoverage = getQualifiedCoverage( sourceRecord, serviceCoverage );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.contractList.get(0).serviceContractId );
                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );
                    
                    if( contractId.equalsIgnoreCase(serviceCoverage.selectedCoverage.Id) ) {
                        
                        serviceCoverage.multipleEntitlements = true;
                        serviceCoverage.entitlementNotes = NOTES_MULTIPLE_ENTITLEMENT_FOUND;
                    } else {
                        serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.Id );
                    }
                }
                
                when MultipleContracts {
                    
                    Ever.CoverageInfo qualifiedCoverageInfo = getQualifiedCoverage( sourceRecord, serviceCoverage );
                    
                    if( qualifiedCoverageInfo == null ) {
                        
                        serviceCoverage.multipleCoverages = true;
                    	serviceCoverage.entitlementNotes = NOTES_MULTIPLE_COVERAGE_FOUND;
                    } else {
                        
                        serviceCoverage.selectedCoverage = qualifiedCoverageInfo;
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.selectedCoverage.serviceContractId );
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );

                        if ( !serviceCoverage.multipleEntitlements ) {
                            serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.Id );
                        }
                    }
                }
                
                when MultipleWarranties {
                    
                    evaluateStackRankingForWarranties( serviceCoverage, sourceRecord );
                }
                // Multiple contracts or multiple warranties.
                when BothContractWarranty {
                    
                    switch on entitlementRule.resolutionMethod {
                        
                        when 'USE-CONTRACT' {
                            
                            if( serviceCoverage.contractList.size() == 1 ) {
                                
                                final String contractId = serviceCoverage.contractList.get(0).Id;
                                
                                serviceCoverage.selectedCoverage = getQualifiedCoverage( sourceRecord, serviceCoverage );
                                
                                serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.contractList.get(0).serviceContractId );
                                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );
                                
                                if( !contractId.equalsIgnoreCase(serviceCoverage.selectedCoverage.Id) ) {
                                    
                                    serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.Id );
                                } else if( serviceCoverage.selectedCoverage.entitlements != null && serviceCoverage.selectedCoverage.entitlements.size() > 0 ) {
                                    
                                    if( serviceCoverage.selectedCoverage.entitlements.size() == 1 ) {
                                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.entitlements.get(0).Id );
                                    } else {
                                        serviceCoverage.multipleEntitlements = true;
                                        serviceCoverage.entitlementNotes = NOTES_MULTIPLE_ENTITLEMENT_FOUND;
                                    }                                    
                                }
                            } else {
                                
                                Ever.CoverageInfo qualifiedCoverageInfo = getQualifiedCoverage( sourceRecord, serviceCoverage );
                                
                                if( qualifiedCoverageInfo == null ) {
                                    
                                    serviceCoverage.multipleCoverages = true;
                                    serviceCoverage.entitlementNotes = NOTES_MULTIPLE_COVERAGE_FOUND;
                                } else {
                                    
                                    serviceCoverage.selectedCoverage = qualifiedCoverageInfo;
                                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.selectedCoverage.serviceContractId );
                                    sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );

                                    if ( !serviceCoverage.multipleEntitlements ) {
                                        serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.Id );
                                    }
                                }
                            }
                        }
                        when 'USE-WARRANTY' {
                            
                            if( serviceCoverage.warrantyList.size() == 1 ) {
                                
                                serviceCoverage.selectedCoverage = serviceCoverage.warrantyList.get(0);
                                serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty), serviceCoverage.selectedCoverage.Id );
                            } else {
                                evaluateStackRankingForWarranties( serviceCoverage, sourceRecord );
                            }
                        }
                        
                        // Set default entitlement note when multiple coverage found and resolution method 
                        // is set to multiple found.
                        when 'MULTIPLE-FOUND' {
                            
                            serviceCoverage.multipleCoverages = true;
                            serviceCoverage.entitlementNotes = NOTES_MULTIPLE_COVERAGE_FOUND;
                        }
                    }
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'beforeSourceObjectUpdate() : Failed to update source record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
			System.debug( LoggingLevel.DEBUG, 'beforeSourceObjectUpdate() - exit' );            
        }
    }

    /**
     * Private method to evaluate stack ranking for warranties.
     */
    private void evaluateStackRankingForWarranties ( Ever.ServiceCoverage serviceCoverage, SObject sourceRecord ) {

        System.debug( LoggingLevel.DEBUG, 'evaluateStackRankingForWarranties() - enter');

        try {

            List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();

            if ( !commonEntitlementSettings.isEmpty() && commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null &&
                 serviceCoverage.warrantyList.get(0).stackRankingFieldValue != null && 
                 (serviceCoverage.warrantyList.get(0).stackRankingFieldValue != serviceCoverage.warrantyList.get(1).stackRankingFieldValue) ) {

                serviceCoverage.selectedCoverage = serviceCoverage.warrantyList.get(0);
                serviceCoverage.entitlementNotes = createEntitlementNote(sourceRecord, serviceCoverage.selectedCoverage );
                sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty), serviceCoverage.selectedCoverage.Id );
            } 
            else {

                serviceCoverage.multipleCoverages = true;
                serviceCoverage.entitlementNotes = NOTES_MULTIPLE_COVERAGE_FOUND;
            }

        }
        catch (Exception e) {
            System.debug( LoggingLevel.ERROR, 'evaluateStackRankingForWarranties() : Failed to evaluate stack ranking for warranties. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally{
            System.debug( LoggingLevel.DEBUG, 'evaluateStackRankingForWarranties() - exit' );            
        }
    }
    
    private Ever.CoverageInfo getQualifiedCoverage( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage ) {
        
        System.debug( LoggingLevel.DEBUG, 'getQualifiedCoverage() - enter; serviceCoverage= ' + serviceCoverage );
        
        final Set<Id> entitlementServiceId = new Set<Id>();
        final List<Ever.CoverageInfo> qualifiedCoverageInfoList = new List<Ever.CoverageInfo>();
        Ever.CoverageInfo qualifiedCoverageInfo = serviceCoverage.contractList.size() == 1 ? serviceCoverage.contractList.get(0) : null;
        
        final List<SVMXA360__CONF_EntitlementSettings__c> commonEntitlementSettings = ADM_EntitlementSettingsManager.getInstance().getCommonEntitlementSettingsRecord();

        if( !commonEntitlementSettings.isEmpty() && commonEntitlementSettings.get(0).SVMXA360__AssignEntitledService__c ) {

            Boolean applyStackRanking = false;
            Boolean breakLoopForStackRanking = false;
            Ever.CoverageInfo firstMatchingCoverageInfo = null;

            if ( commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
                 commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null &&
                 serviceCoverage.contractList.get(0).stackRankingFieldValue != null ) {
                applyStackRanking = true;
            }

            final Adm.ServiceAssignmentRule serviceAssignmentRule = getEntitledServiceRule( sourceRecord );
            System.debug( LoggingLevel.INFO, 'getQualifiedCoverage() : serviceAssignmentRule= ' + serviceAssignmentRule );
            
            for( Ever.CoverageInfo coverageInfo : serviceCoverage.contractList ) {
                
                Ever.CoverageInfo everCoverageInfo = coverageInfo;

                if ( firstMatchingCoverageInfo != null && applyStackRanking && 
                    ( coverageInfo.stackRankingFieldValue == null || ( coverageInfo.stackRankingFieldValue != null && 
                      coverageInfo.stackRankingFieldValue != firstMatchingCoverageInfo.stackRankingFieldValue ) ) ) {
                    break;
                }
                
                if( coverageInfo.entitlements == null || coverageInfo.entitlements.isEmpty() ) {
                    continue;
                }
                
                for( Ever.CoverageInfo entitlement : coverageInfo.entitlements ) {
                    
                    if( serviceAssignmentRule != null && String.isNotBlank( entitlement.serviceProductId ) ) {
                        
                        System.debug( LoggingLevel.INFO, 'getQualifiedCoverage() : entitlement= ' + entitlement );
                        
                        if( serviceAssignmentRule.product.id == entitlement.serviceProductId ) {

                            if ( firstMatchingCoverageInfo != null && applyStackRanking && 
                                coverageInfo.stackRankingFieldValue == firstMatchingCoverageInfo.stackRankingFieldValue ) {
                                qualifiedCoverageInfo = null;
                                breakLoopForStackRanking = true;
                                break;
                            }

                            serviceCoverage.serviceAssignmentRule = serviceAssignmentRule;
                            qualifiedCoverageInfo = entitlement;
                            everCoverageInfo = entitlement;

                            if ( applyStackRanking ) {
                                firstMatchingCoverageInfo = coverageInfo;
                            }
                            
                            break;
                        }
                    }
                }

                if ( breakLoopForStackRanking ) {
                    break;
                }
                
                if( coverageInfo.id != everCoverageInfo.id ) {
                    
                    qualifiedCoverageInfoList.add(qualifiedCoverageInfo);
                    if( qualifiedCoverageInfoList.size() > 1 ) {
                        
                        qualifiedCoverageInfo = null;
                        break;
                    }
                }
            }
        } 
        else if ( !commonEntitlementSettings.isEmpty() && commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c != null &&
                  commonEntitlementSettings.get(0).SVMXA360__ApplyStackRanking__c && 
                  commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingFieldAPIName__c != null &&
                  commonEntitlementSettings.get(0).SVMXA360__ContractStackRankingOrder__c != null &&
                  commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingOrder__c != null &&
                  commonEntitlementSettings.get(0).SVMXA360__WarrantyStackRankingFieldAPIName__c != null &&
                  serviceCoverage.contractList.get(0).stackRankingFieldValue != null && 
                  serviceCoverage.contractList.size() > 1 ) {

            qualifiedCoverageInfo = evaluateStackRankingForContracts( qualifiedCoverageInfo, serviceCoverage );
        }
        
        System.debug( LoggingLevel.DEBUG, 'getQualifiedCoverage() - exit; qualifiedCoverageInfo= ' + qualifiedCoverageInfo );
        
        return qualifiedCoverageInfo;
    }

    /**
     * Private method to evaluate stack ranking for Contracts.
     */
    private Ever.CoverageInfo evaluateStackRankingForContracts ( Ever.CoverageInfo qualifiedCoverageInfo, Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'evaluateStackRankingForContracts() - enter' );

        Boolean coverageFound = false;

        for ( Ever.CoverageInfo coverageInfo : serviceCoverage.contractList ) {

            if ( coverageInfo.stackRankingFieldValue != null && !coverageFound &&
                (coverageInfo.entitlements != null && !coverageInfo.entitlements.isEmpty()) ) {

                qualifiedCoverageInfo = coverageInfo;
                coverageFound = true;
            }

            if ( coverageFound && (coverageInfo.id != qualifiedCoverageInfo.id) && ( coverageInfo.entitlements.size() > 0 ) &&
                ( qualifiedCoverageInfo.serviceContractId == coverageInfo.serviceContractId ) ) {

                qualifiedCoverageInfo = null;
                break;
            }
        }
            
        if ( qualifiedCoverageInfo != null ) {
                
            if ( qualifiedCoverageInfo.entitlements.size() == 1 ) {
                qualifiedCoverageInfo = qualifiedCoverageInfo.entitlements.get(0);
            } else {
                serviceCoverage.multipleEntitlements = true;
                serviceCoverage.entitlementNotes = NOTES_MULTIPLE_ENTITLEMENT_FOUND;
            }
        }

        return qualifiedCoverageInfo;
    }

    /**
     * Private method to retrieve entitlement rules and qualification criteria records.
     */
    private void initRuleExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'initRuleExpressions() - enter' );
        
        try {
            
            entitlementRuleMap = new Map<Id,Adm.EntitlementRule>();
            expressionRecordList = new List<SVMXA360__CONF_Expression__c>();
            
            // Retrieve entitlement rules
            final List<Adm.EntitlementRule> entitlementRuleList = ADM_EntitlementRuleManager.getInstance().getEntitlementRules( sourceObjectName );
            
            for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
                
                if( entitlementRule.isActive && entitlementRule.expression != null && String.isNotBlank( entitlementRule.expression.id ) ) {
                    entitlementRuleMap.put(entitlementRule.expression.id, entitlementRule );
                }
            }
            
            Map<id,SVMXA360__CONF_Expression__c> expressionRecordMap = 
                new Map<id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(entitlementRuleMap.keySet()));
            
            for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
                if( entitlementRule.isActive && entitlementRule.expression != null && String.isNotBlank( entitlementRule.expression.id ) ) {
                    expressionRecordList.add( expressionRecordMap.get(entitlementRule.expression.id) );
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'initRuleExpressions() : Failed to initialize rule expressions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initRuleExpressions() - exit' );
        }
    }
    
    /**
     * Private method to retrieve entitled service assignment rule and qualification criteria records.
     */
    private void initEntitledServiceRuleExpressions() {
        
        System.debug( LoggingLevel.DEBUG, 'initEntitledServiceRuleExpressions() - enter' );
        
        try {
            
            entitledServiceRuleMap = new Map<Id,Adm.ServiceAssignmentRule>();
            entitledServiceExpressionRecordList = new List<SVMXA360__CONF_Expression__c>();
            
            // Retrieve entitlement rules
            final List<Adm.ServiceAssignmentRule> entitledRuleList = ADM_ServiceAssignmentRuleManager.getInstance().getServiceAssignmentRules( sourceObjectName );
            
            for( Adm.ServiceAssignmentRule serviceAssignmentRule : entitledRuleList ) {
                
                if( serviceAssignmentRule.active && serviceAssignmentRule.qualifyingCriteria != null && String.isNotBlank( serviceAssignmentRule.qualifyingCriteria.id ) ) {
                    entitledServiceRuleMap.put(serviceAssignmentRule.qualifyingCriteria.id, serviceAssignmentRule );
                }
            }
            
            Map<id,SVMXA360__CONF_Expression__c> expressionRecordMap = 
                new Map<id,SVMXA360__CONF_Expression__c>(ADM_ExpressionManager.getInstance().getExpressionRecordsWithDetails(entitledServiceRuleMap.keySet()));
            
            for( Adm.ServiceAssignmentRule serviceAssignmentRule : entitledRuleList ) {
                if( serviceAssignmentRule.active && serviceAssignmentRule.qualifyingCriteria != null && String.isNotBlank( serviceAssignmentRule.qualifyingCriteria.id ) ) {
                    entitledServiceExpressionRecordList.add( expressionRecordMap.get(serviceAssignmentRule.qualifyingCriteria.id) );
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'initEntitledServiceRuleExpressions() : Failed to initialize rule expressions. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'initEntitledServiceRuleExpressions() - exit' );
        }
    }
}