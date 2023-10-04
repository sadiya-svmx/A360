/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements logic to perform interactive entitlement.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       09 Jul 2020     Created.
 * A360CE-746   Ramachandra Mohan       28 Mar 2021     Include Fully Consumed Services.
 *****************************************************************************************************/
public with sharing class EVER_InteractiveEntitlementEngine extends EVER_AbstractEntitlementEngine {

    // Private instance variable to hold entitlement settings
    private Adm.EntitlementSettings entitlementSettings;

    /**
     * Class constructor to create instance of this class with source object name.
     */
    public EVER_InteractiveEntitlementEngine( final String sourceObjectName ) {
        super( sourceObjectName, false );
    }

    /**
     * This method is used to retrieve qualified service coverage for given source
     * record id. This method will be invoked from interactive entitlement engine.
     *
     * @param recordId Source record id for which service coverage to be retrieved.
     *
     * @return Returns list of qualified contract and warranty list.
     */
    public Ever.ServiceCoverage getServiceCoverageDetails( final String recordId ) {

        System.debug( LoggingLevel.DEBUG, 'getServiceCoverageDetails() - enter; recordId= ' + recordId );

        Ever.ServiceCoverage serviceCoverage = new Ever.ServiceCoverage();

        try {

            /*if( !USER_FeatureAccessManager.getInstance().isFeatureAccesible( SvmxLicense.Application.Entitlement ) ) {

                System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Entitlement feature not enabled for the user.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.FEATURE_NOT_LICENSED + SvmxLicense.Application.Entitlement.name() );
            }*/

            // Check for valid record id parameter.
            if( String.isBlank(recordId) ) {

                System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Invalid request parameters. recordId= ' + recordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            // Retrieve source record for requested source record Id.
            final List<SObject> sourceRecords = retrieveSourceRecords( new List<String>{recordId} );

            if( sourceRecords.isEmpty() ) {

                System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Record not exists. recordId= ' + recordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            final SObject sourceRecord = sourceRecords.get(0);

            System.debug(LoggingLevel.INFO, 'getServiceCoverageDetails() : Retrieving Service Coverage for record= ' + sourceRecord );
            serviceCoverage = getServiceCoverage( sourceRecord );
        }

        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Failed to perform entitlement verification. Error= ' + e.getMessage() );
            throw e;
        }

        catch(Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Failed to perform entitlement verification. Error= ' + e.getStackTraceString() );
            throw e;
        }

        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoverageDetails() - exit; serviceCoverage= ' + serviceCoverage );
        }

        return serviceCoverage;
    }

    /**
     * This method is used to retrieve qualified service coverage for given source
     * record id. This method will be invoked from interactive entitlement engine.
     *
     * @param recordId Source record id for which service coverage to be retrieved.
     *
     * @return Returns list of qualified contract and warranty list.
     */
    public Ever.ServiceCoverage getServiceCoverageDetails( final String recordId, final Adm.EntitlementBase entitlementBase ) {

        System.debug( LoggingLevel.DEBUG, 'getServiceCoverageDetails() - enter; recordId= ' + recordId );

        Ever.ServiceCoverage serviceCoverage = new Ever.ServiceCoverage();

        try {

            /*if( !USER_FeatureAccessManager.getInstance().isFeatureAccesible( SvmxLicense.Application.Entitlement ) ) {

                System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Entitlement feature not enabled for the user.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.FEATURE_NOT_LICENSED + SvmxLicense.Application.Entitlement.name() );
            }*/

            this.entitlementSettings = (Adm.EntitlementSettings) entitlementBase;

            // Invoke base class method to retrieve service contract for requested source record.
            serviceCoverage = getServiceCoverageDetails( recordId );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Failed to perform entitlement verification. Error= ' + e.getMessage() );
            throw e;
        }
        catch(Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceCoverageDetails() : Failed to perform entitlement verification. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceCoverageDetails() - exit; serviceCoverage= ' + serviceCoverage );
        }

        return serviceCoverage;
    }

    /**
     * This method is used to save service contract for requested source record id.
     * This method also create entitlement history with updated service coverage.
     *
     * @param sourceRecordId Source record ids for which service contract to be saved.
     * @param serviceCoverage Service Coverage to be applied to source record.
     */
    public void saveServiceCoverage( final String sourceRecordId, final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - enter; sourceRecordId= ' + sourceRecordId );

        try {

			/*if( !USER_FeatureAccessManager.getInstance().isFeatureAccesible( SvmxLicense.Application.Entitlement ) ) {

                System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Entitlement feature not enabled for the user.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.FEATURE_NOT_LICENSED + SvmxLicense.Application.Entitlement.name() );
            }*/

            //Validate requested record id list.
            if( String.isBlank(sourceRecordId) ) {

                System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Invalid request parameters. sourceRecordId= ' + sourceRecordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            // retrieve all source records for requested record ids.
            final List<SObject> sourceRecords = retrieveSourceRecords( new List<String> {sourceRecordId} );

            if( sourceRecords.isEmpty() ) {

                System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Record not exists. sourceRecordId= ' + sourceRecordId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            // Invoke engine method to perform interactive save for requested service coverage.
            saveServiceCoverage( sourceRecords.get(0), serviceCoverage );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to perform entitlement verification. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'saveServiceCoverage() : Failed to perform entitlement verification. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceCoverage() - exit' );
        }
    }

    /**
     * Override method to retrieve entitlement settings.
     */
    override protected Adm.EntitlementBase getEntitlementConfiguration( final SObject sourceRecord ) {

        System.debug( LoggingLevel.DEBUG, 'getEntitlementConfiguration() - enter; sourceRecord= ' + sourceRecord );

        try {
            if( this.entitlementSettings == null ) {
                this.entitlementSettings = ADM_EntitlementSettingsManager.getInstance().getEntitlementSettings( sourceObjectName );
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getEntitlementConfiguration() : Failed to retrieve entitlement settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementConfiguration() - exit; entitlementSettings= ' + entitlementSettings );
        }

        return this.entitlementSettings;
    }

    /**
     * Override method to validate source record before retrieving service contracts.
     *
     * @param sourceRecord Source record on which validation to be performed.
     * @param entitlementBase Interactive entitlement configuration.
     */
    override protected void validateSourceRecord( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase ) {

        System.debug( LoggingLevel.DEBUG, 'validateSourceRecord() - enter; sourceRecord= ' + sourceRecord );

        try {
            final Adm.EntitlementSettings entitlementSettings = (Adm.EntitlementSettings) entitlementBase;

            switch on entitlementSettings.coveredBy.toLowerCase() {

                // Check for valid asset or account field in the source object.
                when 'asset' {

                    if( sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) ) == null ) {
                        handleSourceRecordError( sourceRecord, entitlementFieldMap.get( Ever.EntitlementField.Asset ) );
                    }

                    if( entitlementSettings.matchAccount && sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) == null ) {
                        handleSourceRecordError( sourceRecord, entitlementFieldMap.get( Ever.EntitlementField.Account ) );
                    }
                }

                // Check for valid account field in the source object
                when 'account' {

                    if( sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) == null ) {
                        handleSourceRecordError( sourceRecord, entitlementFieldMap.get( Ever.EntitlementField.Account ) );
                    }
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'validateSourceRecord() : Failed to perform source object validation. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'validateSourceRecord() : Failed to perform source object validation. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateSourceRecord() - enter; sourceRecord= ' + sourceRecord );
        }
    }

    /**
     * Override method to build entitlement criteral to retrieve contract and/or warranty.
     */
    override protected void buildEntitlementCriteria( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final EntitlementParams entitlementParams ) {

        System.debug( LoggingLevel.DEBUG, 'buildEntitlementCriteria() - enter; sourceRecord= ' + sourceRecord );

        try {

            final Adm.EntitlementSettings entitlementSettings = (Adm.EntitlementSettings) entitlementBase;
            final Date entitlementDateVal = retrieveEntitlementDate( sourceRecord );
            final String entitlementDate = String.valueOf(entitlementDateVal);

            Integer monthForFuture = entitlementSettings.futureEntitlementDuration != null ?
                Integer.valueOf(entitlementSettings.futureEntitlementDuration) : 36;
            Integer monthForExpired = entitlementSettings.expiredEntitlementDuration != null ?
                Integer.valueOf(entitlementSettings.expiredEntitlementDuration) : 36;
            monthForExpired = monthForExpired * -1;

            String futureStartDateBuffer = String.valueOf(entitlementDateVal.addMonths(monthForFuture));
            String expiryEndDateBuffer = String.valueOf(entitlementDateVal.addMonths(monthForExpired));

            switch on entitlementSettings.coveredBy.toLowerCase() {

                when 'asset' {

                    // Create where clause for configured entitlement settings.
                    if( !entitlementSettings.futureEntitlements && !entitlementSettings.expiredEntitlements ) {

                        final String lineDataClause = '( StartDate != null AND EndDate != null AND StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')';
                        final String  headerDateClause = '( ServiceContract.StartDate <= ' + entitlementDate + ' AND ServiceContract.EndDate >= ' + entitlementDate + ')';

                        entitlementParams.contractWhereClauseList.add( '(' + lineDataClause + ' AND ' + headerDateClause + ')' );
                        entitlementParams.warrantyWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                    } else if( entitlementSettings.futureEntitlements && !entitlementSettings.expiredEntitlements ) {

                        final String lineDataClause = '( StartDate != null AND EndDate != null AND EndDate >= ' + entitlementDate + ' AND StartDate <= ' + futureStartDateBuffer +')';
                        final String headerDateClause = '( ServiceContract.EndDate >= ' + entitlementDate + ' AND ServiceContract.StartDate <= ' + futureStartDateBuffer + ')';

                        entitlementParams.contractWhereClauseList.add( '(' + lineDataClause + ' AND ' + headerDateClause + ')' );
                        entitlementParams.warrantyWhereClauseList.add( '( EndDate >= ' + entitlementDate + ' AND StartDate <= ' + futureStartDateBuffer +')' );
                        entitlementParams.entitlementWhereClauseList.add( '( EndDate >= ' + entitlementDate + ' AND StartDate <= ' + futureStartDateBuffer +')' );
                    } else if( !entitlementSettings.futureEntitlements && entitlementSettings.expiredEntitlements ) {

                        final String lineDataClause = '( StartDate != null AND EndDate != null AND StartDate <= ' + entitlementDate + ' AND EndDate >= ' + expiryEndDateBuffer + ')';
                        final String headerDateClause = '( ServiceContract.StartDate <= ' + entitlementDate + ' AND ServiceContract.EndDate >= ' + expiryEndDateBuffer + ')';

                        entitlementParams.contractWhereClauseList.add( '(' + lineDataClause + ' AND ' + headerDateClause + ')' );
                        entitlementParams.warrantyWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + expiryEndDateBuffer +  ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + expiryEndDateBuffer +  ')' );
                    } else {

                        final String lineDataClause = '( StartDate != null AND EndDate != null AND StartDate <= ' + futureStartDateBuffer + ' AND EndDate >= ' + expiryEndDateBuffer + ')';
                        final String headerDateClause = '( ServiceContract.StartDate <= ' + futureStartDateBuffer + ' AND ServiceContract.EndDate >= ' + expiryEndDateBuffer + ')';

                        entitlementParams.contractWhereClauseList.add( '(' + lineDataClause + ' AND ' + headerDateClause + ')' );
                        entitlementParams.warrantyWhereClauseList.add( '( StartDate <= ' + futureStartDateBuffer + ' AND EndDate >= ' + expiryEndDateBuffer +  ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( StartDate <= ' + futureStartDateBuffer + ' AND EndDate >= ' + expiryEndDateBuffer +  ')' );
                    }

                    // Populate asset and account ids to be included in the where clause.
                    final String assetId = (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Asset ) );
                    entitlementParams.assetIds.add( assetId );

                    if( entitlementSettings.matchAccount ) {
                        entitlementParams.accountIds.add( (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) );
                    }

                    if( entitlementSettings.includeParentAsset && assetRecordsMap.get(assetId).ParentId != null ) {
                        entitlementParams.assetIds.add( assetRecordsMap.get(assetId).ParentId );
                    }

                    if( entitlementSettings.includeRootAsset && assetRecordsMap.get(assetId).RootAssetId != null ) {
                        entitlementParams.assetIds.add( assetRecordsMap.get(assetId).RootAssetId );
                    }
                }
                when 'account' {

                    if( !entitlementSettings.futureEntitlements && !entitlementSettings.expiredEntitlements ) {

                        entitlementParams.serviceContractWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( StartDate <= ' + entitlementDate + ' AND EndDate >= ' + entitlementDate + ')' );
                    } else if( entitlementSettings.futureEntitlements && !entitlementSettings.expiredEntitlements ) {

                        entitlementParams.serviceContractWhereClauseList.add( '( EndDate >= ' + entitlementDate + ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( EndDate >= ' + entitlementDate + ')' );
                    } else if( !entitlementSettings.futureEntitlements && entitlementSettings.expiredEntitlements ) {

                        entitlementParams.serviceContractWhereClauseList.add( '( EndDate >= ' + entitlementDate + ')' );
                        entitlementParams.entitlementWhereClauseList.add( '( StartDate <= ' + entitlementDate + ')' );
                    }

                    entitlementParams.accountIds.add( (String) sourceRecord.get( entitlementFieldMap.get( Ever.EntitlementField.Account ) ) );
                }
            }
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'buildEntitlementCriteria() : Failed to build entitlement criteria. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildEntitlementCriteria() - exit' );
        }
    }

    /**
     * Override method which will be invoked before consuming service coverageds.
     */
    override protected void handleQualifiedServiceCoverage( final SObject sourceRecord, final Adm.EntitlementBase entitlementBase, final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'handleQualifiedServiceCoverage() - enter; entitlementBase= ' + entitlementBase );

        try {

            final Adm.EntitlementSettings entitlementSettings = (Adm.EntitlementSettings) entitlementBase;

            if( entitlementSettings.fullyConsumedServices != null && !entitlementSettings.fullyConsumedServices && serviceCoverage.contractList != null ) {

                for( Ever.CoverageInfo contractInfo : serviceCoverage.contractList ) {

                    if( contractInfo.entitlements != null && !contractInfo.entitlements.isEmpty() ) {

                        List<Ever.CoverageInfo> entitlementList = new List<Ever.CoverageInfo>();
                        for( Ever.CoverageInfo entitlementInfo : contractInfo.entitlements ) {
                            if( entitlementInfo.totalService != null && entitlementInfo.consumedService != null && ( entitlementInfo.totalService - entitlementInfo.consumedService ) > 0 ) {
                                entitlementList.add(entitlementInfo);
                            }
                        }

                        contractInfo.entitlements = entitlementList;
                    }
                }
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleQualifiedServiceCoverage() - exit' );
        }
    }

    /**
     * Override method which will be invoked before performing source object update.
     */
    override protected void beforeSourceObjectUpdate( final SObject sourceRecord, final Ever.ServiceCoverage serviceCoverage ) {

        System.debug( LoggingLevel.DEBUG, 'beforeSourceObjectUpdate() - enter; sourceRecord= ' + sourceRecord );

        try {

            if( serviceCoverage.selectedCoverage != null ) {

                switch on serviceCoverage.selectedCoverage.coverageType.toLowerCase() {

                    when 'contract' {
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.selectedCoverage.serviceContractId );
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );
                    }

                    when 'warranty' {
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.AssetWarranty), serviceCoverage.selectedCoverage.Id );
                    }

                    when 'entitlement' {

                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.ServiceContract), serviceCoverage.selectedCoverage.serviceContractId );
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitledService), serviceCoverage.selectedCoverage.Id );
                        sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.contractLineItem), serviceCoverage.selectedCoverage.contractLineItemId );
                    }
                }
            }

            if( String.isBlank( serviceCoverage.entitlementNotes ) ) {

                if( serviceCoverage.selectedCoverage == null ) {
                    serviceCoverage.entitlementNotes = INCIDENT_NOT_COVERED;
                }
            }

            sourceRecord.put( entitlementFieldMap.get(Ever.EntitlementField.EntitlementNotes), serviceCoverage.entitlementNotes );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'beforeSourceObjectUpdate() : Failed to update source object. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'beforeSourceObjectUpdate() - exit' );
        }
    }

    /**
     * Method to handle the required field missing error on the source object.
     */
    @testVisible
    private void handleSourceRecordError( final SObject sourceRecord, final String fieldAPIName ) {

        System.debug( LoggingLevel.DEBUG, 'handleSourceRecordError() - enter; sourceRecord= ' + sourceRecord );

        try {
            if( sourceRecord == null || String.isEmpty( fieldAPIName ) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            Schema.DescribeSObjectResult sourceObjectResult = sourceRecord.id.getSobjectType().getDescribe();
            Map<String, Schema.DescribeFieldResult> describeFieldResultMap = COMM_DescribeManager.getInstance().getFieldDescribeResults( sourceObjectResult.getName() );

            if( !describeFieldResultMap.containsKey( fieldAPIName ) ){
                System.debug( LoggingLevel.ERROR, 'handleSourceRecordError() : field not found on the source object.' );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            String fieldLabel = describeFieldResultMap.get( fieldAPIName ).getLabel();

            String errorMessageString = String.format( ErrorMessage.FIELD_SHOULD_CONTAIN_VALUE, new List<String>{sourceObjectResult.getLabel(), fieldLabel} );

            throw new SvmxSystem.SvmxNestedException(errorMessageString);
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'handleSourceRecordError() : Failed to get the error messag. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleSourceRecordError() - exit' );
        }
    }
}