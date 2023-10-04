/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is the handler class to automate service contract creation using template.
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan      06 Apr 2021     Created.
 *              Sandeep Dhariwal       10 Apr 2021
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class SCON_ServiceContractPlanHandler {

    private List<Entitlement> entitledServiceList = new List<Entitlement>();

    private Map<String, List<Entitlement>> entitledServiceMap = new Map<String, List<Entitlement>>();

    private Map<String, List<ContractLineItem>> contractLineItemMap = new Map<String, List<ContractLineItem>>();

    private List<SVMXA360__ContractPriceLineItem__c> contractPriceLineItemList = new List<SVMXA360__ContractPriceLineItem__c>();

    private List<Scon.EntitledServicePlan> entitledServicePlans = new List<Scon.EntitledServicePlan>();

    private Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap = new Map<Id, Scon.ServiceContractPlan>();

    // Get instance of COMM_DescribeManager
    private final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();

    public Scon.ServiceContractResponse executeServiceContractPlan( Scon.ServiceContractPlanRequest sconRequest ) {

        System.debug( LoggingLevel.DEBUG, 'executeServiceContrctPlan() - enter; sourceRecordId= ' + sconRequest.sourceRecordId + '; serviceContractPlanId= ' + sconRequest.serviceContractPlanId + ' ; createBulkContractLines = '+sconRequest.createBulkContractLines);

        Scon.ServiceContractResponse serviceContractResponse = new Scon.ServiceContractResponse();

        final System.Savepoint sPoint = Database.setSavepoint();

        try {

            if( sconRequest.serviceContractPlanId == null || sconRequest.serviceContractName == null 
             || sconRequest.serviceContractStartDate == null || sconRequest.sourceRecordId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            Scon.ServiceContractPlan serviceContractPlan = new Scon.ServiceContractPlan();            
            Set<Id> serviceContractPlanIdSet = new Set<Id>();
            serviceContractPlanIdSet.add(sconRequest.serviceContractPlanId);

            if ( sconRequest.assetServiceContractPlanIdMap != null && !sconRequest.assetServiceContractPlanIdMap.isEmpty() ){
                serviceContractPlanMap = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails( sconRequest.assetServiceContractPlanIdMap.values(), sconRequest.serviceContractPlanId );
                serviceContractPlanIdSet.addAll( sconRequest.assetServiceContractPlanIdMap.values() );
            } else {
                serviceContractPlanMap = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails( new List<String>{sconRequest.serviceContractPlanId},sconRequest.serviceContractPlanId );
            }

            if( serviceContractPlanMap.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS );
            }

            serviceContractPlan = serviceContractPlanMap.get( sconRequest.serviceContractPlanId );

            ServiceContract serviceContractRecord = new ServiceContract();

            serviceContractRecord = createServiceContract( sconRequest, serviceContractPlan);

            System.debug( LoggingLevel.INFO, 'executeServiceContrctPlan() : Created Service Contract. serviceContract= ' + serviceContractRecord + ' ; sconRequest = '+sconRequest);

            if ( !sconRequest.createBulkContractLines && sconRequest.assetServiceContractPlanIdMap != null && 
                 !sconRequest.assetServiceContractPlanIdMap.isEmpty() && serviceContractPlan.pricebookId != null) {
                createContractLineItems( sconRequest.assetServiceContractPlanIdMap, sconRequest.createBulkContractLines, 
                                         sconRequest.serviceContractPlanId, serviceContractRecord, null, null);
            }

            // Creating entitled service records
            if( serviceContractPlan.entitledServicePlans != null && !serviceContractPlan.entitledServicePlans.isEmpty() ) {
                createEntitledServices( serviceContractPlan, serviceContractRecord );
            }

            if( !entitledServiceMap.isEmpty() ) {
            
                for ( String entitledServicePlanId : entitledServiceMap.keySet() ) {
                    entitledServiceList.addAll(entitledServiceMap.get(entitledServicePlanId));
                }
                SvmxDatabase.insertRecord( entitledServiceList );
            }

            // Creating contract price line item records.
            if( serviceContractPlan.contractPriceLineItemPlans != null && !serviceContractPlan.contractPriceLineItemPlans.isEmpty() ) {

                final List<SVMXA360__ContractPriceLineItem__c> contractPriceLineList = new List<SVMXA360__ContractPriceLineItem__c>();
                for( Scon.ContractPriceLineItemPlan contractPriceLineTerm : serviceContractPlan.contractPriceLineItemPlans ) {
                    contractPriceLineItemList.addAll( buildContractPriceLines( contractPriceLineTerm, new List<ServiceContract> {serviceContractRecord} ) );
                }
            }

            if( !entitledServicePlans.isEmpty() ) {
                createContractPriceLines( entitledServicePlans );
            }

            if( !contractPriceLineItemList.isEmpty() ) {
                SvmxDatabase.insertRecord(contractPriceLineItemList);
            }

            // Creating Maintenance Plan Offering records.
            List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = SCON_ServiceContractPlanHelper.getOfferedMaintenancePlanTemplates(serviceContractPlanIdSet,serviceContractPlanMap);
            if( offeredMPTList != null && !offeredMPTList.isEmpty() ) {
                //create mPToffered
                List<SVMXA360__MaintenancePlanOffering__c> maintenancePlanOfferingList = new List<SVMXA360__MaintenancePlanOffering__c>();
                maintenancePlanOfferingList.addAll( buildMaintenancePlanOfferings( offeredMPTList, serviceContractRecord.Id ));
                SvmxDatabase.insertRecord(maintenancePlanOfferingList);
            }

            if ( sconRequest.createBulkContractLines && sconRequest.assetServiceContractPlanIdMap != null && 
                 !sconRequest.assetServiceContractPlanIdMap.isEmpty() && serviceContractPlan.pricebookId != null) {

                serviceContractResponse.parentAuthoringLog = SCON_ServiceContractPlanHelper.publishContractLinePlatformEvents( sconRequest, serviceContractRecord );
            } else {

                serviceContractRecord.SVMXA360__ContractAuthoringStatus__c = 'AuthoringCompleted'; 
                serviceContractRecord = (ServiceContract) SvmxDatabase.updateRecord( serviceContractRecord );
            }

            serviceContractResponse.serviceContractRecord = serviceContractRecord;        
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            Database.rollback(sPoint);
            System.debug( LoggingLevel.ERROR, 'executeServiceContrctPlan() : Failed to process Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            Database.rollback(sPoint);
            System.debug( LoggingLevel.ERROR, 'executeServiceContrctPlan() : Failed to process Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'executeServiceContrctPlan() - exit; serviceContractResponse= ' + serviceContractResponse);
        }

        return serviceContractResponse;
    }

    private ServiceContract createServiceContract( Scon.ServiceContractPlanRequest sconRequest,
                                                   final Scon.ServiceContractPlan serviceContractPlan ) {

        System.debug( LoggingLevel.DEBUG, 'createServiceContract() - enter; sourceRecordId= ' + sconRequest.sourceRecordId + '; serviceContractPlan= ' + serviceContractPlan);

        ServiceContract serviceContractRecord = new ServiceContract();

        Map<String, Schema.SObjectField> sObjectFieldResultMap;

        try {
            serviceContractRecord = populateAccountInfo( (Id)sconRequest.sourceRecordId, serviceContractRecord );
            serviceContractRecord.SVMXA360__ServiceContractPlanId__c = serviceContractPlan.id;
            serviceContractRecord.Name = sconRequest.serviceContractName;
            serviceContractRecord.StartDate = sconRequest.serviceContractStartDate;
            if( sconRequest.serviceContractEndDate == null && serviceContractPlan.duration != null && serviceContractPlan.unitOfTime != null ) {
                serviceContractRecord.EndDate = COMM_DateLiteralUtils.calculateEndDate( sconRequest.serviceContractStartDate, serviceContractPlan.duration, serviceContractPlan.unitOfTime );
            } else {
                serviceContractRecord.EndDate = sconRequest.serviceContractEndDate;
            }
            serviceContractRecord.Description = sconRequest.serviceContractDescription;
            serviceContractRecord.Pricebook2Id = sconRequest.pricebookId != null ? sconRequest.pricebookId : serviceContractPlan.pricebookId;
            serviceContractRecord.SpecialTerms = serviceContractPlan.specialTerms;
            serviceContractRecord.SVMXA360__ContractAuthoringStatus__c = 'Draft';

            if( UserInfo.isMultiCurrencyOrganization() ) {
                serviceContractRecord.put('CurrencyIsoCode', serviceContractPlan.currencyIsoCode );
            }

            if (String.isNotBlank(sconRequest.salesContractIdFieldName)) {
                //Get the map of fields for Service Contract Object
                sObjectFieldResultMap = describeManager.getObjectFieldMap( 'ServiceContract' );

                // Check if the field is valid
                if(!sObjectFieldResultMap.ContainsKey(sconRequest.salesContractIdFieldName)){
                    System.debug( LoggingLevel.ERROR, 'createServiceContract() : Invalid field on Service Contract' );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.FIELD_NOT_EXISTS );
                }

                serviceContractRecord.put(sconRequest.salesContractIdFieldName, sconRequest.salesContractId );
            }

            serviceContractRecord = (ServiceContract) SvmxDatabase.insertRecord( serviceContractRecord );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Service Contract. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Service Contract. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createServiceContract() - exit; serviceContractRecord= ' + serviceContractRecord);
        }

        return serviceContractRecord;
    }

    public List<ContractLineItem> createContractLineItems( Map <Id,Id> assetServiceContractPlanIdMap, Boolean createLogRecords, 
                                                           String  primaryServiceContractPlanId, ServiceContract serviceContractRecord,
                                                           String userId, String parentSCONLogRecordId ) {

        System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - enter; assetServiceContractPlanIdMap= ' + assetServiceContractPlanIdMap + ' ; createLogRecords = '+createLogRecords);

        final System.Savepoint sPoint = Database.setSavepoint();

        List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();

        Scon.LogMessage logMessage = new Scon.LogMessage();

        try {

            if ( assetServiceContractPlanIdMap == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            if ( serviceContractPlanMap.isEmpty() ) {
                serviceContractPlanMap = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails( assetServiceContractPlanIdMap.values(), primaryServiceContractPlanId );
            }

            List<Asset> assetRecordList = SCON_ServiceContractPlanHelper.getAssetRecords( assetServiceContractPlanIdMap.keyset() );

            logMessage.assetsProcessed = assetRecordList.size();

            Common.DatabaseResult dbResult = new Common.DatabaseResult();

            contractLineItemList = createContractLineItems( serviceContractPlanMap, assetServiceContractPlanIdMap, assetRecordList, serviceContractRecord );

            logMessage.contractLineItemsCreated = contractLineItemList.size();

            if ( createLogRecords ) {

                if( !entitledServiceMap.isEmpty() ) {
            
                    for ( String entitledServicePlanId : entitledServiceMap.keySet() ) {
                        entitledServiceList.addAll(entitledServiceMap.get(entitledServicePlanId));
                    }

                    try {
                        entitledServiceList = (List<Entitlement>) SvmxDatabase.insertRecord ( entitledServiceList, false );
                    } catch (SvmxSystem.SvmxNestedException ex) {
                        throw new SvmxSystem.SvmxNestedException(JSON.serialize(ex.getDatabaseResult().errors));
                    }

                    logMessage.entitledServicesCreated = entitledServiceList.size();
                }

                if( !entitledServicePlans.isEmpty() ) {
                    createContractPriceLines( entitledServicePlans );
                }
    
                if( !contractPriceLineItemList.isEmpty() ) {

                    try {
                        contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>) SvmxDatabase.insertRecord ( contractPriceLineItemList, false );
                    } catch (SvmxSystem.SvmxNestedException ex) {
                        throw new SvmxSystem.SvmxNestedException(JSON.serialize(ex.getDatabaseResult().errors));
                    }

                    logMessage.contractPriceLineItemsCreated = contractPriceLineItemList.size();
                }

                SCON_ServiceContractPlanHelper.createSCONLogRecord( serviceContractRecord.Id, parentSCONLogRecordId, userId, logMessage, 'Create');
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            Database.rollback(sPoint);
            logMessage.errors = e.getMessage();
            SCON_ServiceContractPlanHelper.createSCONLogRecord( serviceContractRecord.Id, parentSCONLogRecordId, userId, logMessage, 'Create');
            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            Database.rollback(sPoint);
            logMessage.errors = e.getMessage();
            SCON_ServiceContractPlanHelper.createSCONLogRecord( serviceContractRecord.Id, parentSCONLogRecordId, userId, logMessage, 'Create');
            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - exit; contractLineItemList= ' + contractLineItemList);
        }

        return contractLineItemList;

    }

    public List<ContractLineItem> createContractLineItems( final Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap, 
                                                           final Map <Id,Id> assetServiceContractPlanIdMap, List<Asset> assetRecordList,
                                                           ServiceContract serviceContractRecord ) {

        System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - enter; assetRecordList= ' + assetRecordList);

        List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
        
        try {
            
            Map<Id, Map<String, Scon.ContractLineItemPlan>> serviceContractPlanProductCLIPlanMap = 
                new  Map<Id, Map<String, Scon.ContractLineItemPlan>>();
            Map<String, Scon.ContractLineItemPlan> contractLineItemPlanIdMap = new Map<String, Scon.ContractLineItemPlan>();
            String filterValue;
            Set<String> qualifyingDefinitionIds = new Set<String>();
            Map<String, Scon.ContractLineItemPlan> productContractLineItemPlanMap;
            ContractLineItem contractLineItemRecord;

            if( !assetRecordList.isEmpty() ) {

                for ( Scon.ServiceContractPlan serviceContractPlan : serviceContractPlanMap.values() ) {

                    productContractLineItemPlanMap = new Map<String, Scon.ContractLineItemPlan>();

                    for( Scon.ContractLineItemPlan contractLineDefinition : serviceContractPlan.contractLineItemPlans ) {

                        filterValue = contractLineDefinition.productId != null ? contractLineDefinition.productId : contractLineDefinition.productFamily;
                        productContractLineItemPlanMap.put( filterValue, contractLineDefinition );
                        contractLineItemPlanIdMap.put( contractLineDefinition.Id, contractLineDefinition );
                    }

                    serviceContractPlanProductCLIPlanMap.put(serviceContractPlan.Id, productContractLineItemPlanMap);
                }

                final Set<String> uniqueProductSet = new Set<String>();
                final Map<String, List<Asset>> contractLineDefinitionAssetMap = new Map<String, List<Asset>>();
                for( Asset assetRecord : assetRecordList ) {

                    productContractLineItemPlanMap = serviceContractPlanProductCLIPlanMap.get( assetServiceContractPlanIdMap.get(assetRecord.Id) );
                    final Scon.ContractLineItemPlan contractLineDefinition = productContractLineItemPlanMap.containsKey( assetRecord.Product2Id ) ? productContractLineItemPlanMap.get(assetRecord.Product2Id) : productContractLineItemPlanMap.get(assetRecord.ProductFamily);
                    if  (contractLineDefinition == null) {
                        continue;
                    }

                    if( !contractLineDefinitionAssetMap.containsKey(contractLineDefinition.id) ) {
                        contractLineDefinitionAssetMap.put(contractLineDefinition.id, new List<Asset>() );
                    }

                    contractLineDefinitionAssetMap.get(contractLineDefinition.id).add(assetRecord);
                    uniqueProductSet.add(assetRecord.Product2Id);
                }

                Map<String, PricebookEntry> pricebookEntryMap = SCON_ServiceContractPlanHelper.getPricebookEntryMap( serviceContractPlanMap.values(), uniqueProductSet, serviceContractRecord );

                for( String definitionId : contractLineDefinitionAssetMap.keySet() ) {

                    final Scon.ContractLineItemPlan contractLineDefinition = contractLineItemPlanIdMap.get(definitionId);
                    for( Asset assetRecord : contractLineDefinitionAssetMap.get(definitionId) ) {

                        if( !pricebookEntryMap.containsKey(assetRecord.Product2Id) ) {

                            System.debug( LoggingLevel.WARN, 'No pricebookEntry exists for Product= ' + assetRecord.Product2Id );
                            continue;
                        }

                        qualifyingDefinitionIds.add(definitionId);
                        contractLineItemRecord = SCON_ServiceContractPlanHelper.buildContractLineItem( assetRecord, contractLineDefinition, serviceContractRecord, null, null);
                        contractLineItemRecord.PricebookEntryId = pricebookEntryMap.get(assetRecord.Product2Id).Id;
                        contractLineItemRecord.UnitPrice = pricebookEntryMap.get(assetRecord.Product2Id).UnitPrice;
                        contractLineItemList.add(contractLineItemRecord);

                        if( !contractLineItemMap.containsKey(definitionId) ) {
                            contractLineItemMap.put( definitionId, new List<ContractLineItem>() );
                        }

                        contractLineItemMap.get(definitionId).add(contractLineItemRecord);
                    }
                }

                if( !contractLineItemList.isEmpty() ) {

                    List<Scon.ContractLineItemPlan> qualifyingContractLineDefinitions = new List<Scon.ContractLineItemPlan>();

                    try {
                        contractLineItemList = (List<ContractLineItem>) SvmxDatabase.insertRecord ( contractLineItemList, false );
                    } catch (SvmxSystem.SvmxNestedException ex) {
                        throw new SvmxSystem.SvmxNestedException(JSON.serialize(ex.getDatabaseResult().errors));
                    }

                    System.debug( LoggingLevel.INFO, 'createContractLineItems() : Created Contract Line Item records.' );

                    for (String planId : qualifyingDefinitionIds) {
                        qualifyingContractLineDefinitions.add(contractLineItemPlanIdMap.get(planId));
                    }

                    createEntitledServices( qualifyingContractLineDefinitions, serviceContractRecord );
                    createContractPriceLines( qualifyingContractLineDefinitions );
                }

            } else {
                System.debug( LoggingLevel.WARN, 'createContractLineItems() : No Contract Line Items records created.');
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - exit; contractLineItemList= ' + contractLineItemList);
        }

        return contractLineItemList;
    }

    public List<ContractLineItem> createContractLineItems( final Id sourceRecordId, final Id locationId,
                                                           final Scon.ServiceContractPlan serviceContractPlan,
                                                           final Boolean evaluateForChildAssets,
                                                           final ServiceContract serviceContractRecord ) {

        System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - enter; serviceContractPlan= ' + serviceContractPlan + ' locationId = '+locationId);

        Scon.ContractLineItemResponse contractLineItemResponse = new Scon.ContractLineItemResponse();
        List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();

        try {

            List<Asset> assetRecordList = SCON_ServiceContractPlanHelper.getAssetRecords( sourceRecordId, locationId, serviceContractPlan, evaluateForChildAssets);

            contractLineItemResponse = createContractLineItems( serviceContractPlan, assetRecordList, serviceContractRecord, null );
            contractLineItemList = contractLineItemResponse.contractLineItemList;
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - exit; contractLineItemList= ' + contractLineItemList);
        }

        return contractLineItemList;
    }

    public Scon.QualifiedAssets getQualifiedAssets (final Id sourceRecordId, final Id locationId, final String serviceContractPlanId,
                                           final Boolean evaluateForChildAssets) {
        
        System.debug( LoggingLevel.DEBUG, 'getQualifiedAssets() - enter; sourceRecordId= ' + sourceRecordId + ' ; serviceContractPlanId = '+serviceContractPlanId);
        Scon.QualifiedAssets qualifiedAssets = new Scon.QualifiedAssets();
        
        try {

            if( sourceRecordId == null || serviceContractPlanId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            Integer recordsTobeCreated = 1;

            Scon.ServiceContractPlan serviceContractPlan = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails(serviceContractPlanId);

            if( serviceContractPlan.entitledServicePlans != null && !serviceContractPlan.entitledServicePlans.isEmpty() ) {

                recordsTobeCreated = recordsTobeCreated + serviceContractPlan.entitledServicePlans.size();

                for ( Scon.EntitledServicePlan entitledServicePlan : serviceContractPlan.entitledServicePlans ) {

                    if ( entitledServicePlan.contractPriceLineItemPlans != null && 
                         !entitledServicePlan.contractPriceLineItemPlans.isEmpty() ) {
                            recordsTobeCreated = recordsTobeCreated + entitledServicePlan.contractPriceLineItemPlans.size();
                    }
                }
            }

            if( serviceContractPlan.contractPriceLineItemPlans != null && !serviceContractPlan.contractPriceLineItemPlans.isEmpty() ) {
                recordsTobeCreated = recordsTobeCreated + serviceContractPlan.contractPriceLineItemPlans.size();
            }

            List<Asset> assetRecordList = SCON_ServiceContractPlanHelper.getAssetRecords (sourceRecordId, locationId, serviceContractPlan, evaluateForChildAssets);
            
            String filterValue;
            
            if ( !assetRecordList.isEmpty() ) {

                final Map<String, Scon.ContractLineItemPlan> productContractLineItemPlanMap = new Map<String, Scon.ContractLineItemPlan>();
                final Map<String, Scon.ContractLineItemPlan> contractLineItemPlanMap = new Map<String, Scon.ContractLineItemPlan>();

                for( Scon.ContractLineItemPlan contractLineDefinition : serviceContractPlan.contractLineItemPlans ) {

                    filterValue = contractLineDefinition.productId != null ? contractLineDefinition.productId : contractLineDefinition.productFamily;
                    productContractLineItemPlanMap.put( filterValue, contractLineDefinition );
                    contractLineItemPlanMap.put(contractLineDefinition.Id, contractLineDefinition);
                }

                final Set<String> uniqueProductSet = new Set<String>();
                final Map<String, List<Asset>> contractLineDefinitionAssetMap = new Map<String, List<Asset>>();

                for( Asset assetRecord : assetRecordList ) {

                    final Scon.ContractLineItemPlan contractLineDefinition = productContractLineItemPlanMap.containsKey( assetRecord.Product2Id ) ? productContractLineItemPlanMap.get(assetRecord.Product2Id) : productContractLineItemPlanMap.get(assetRecord.ProductFamily);

                    if( !contractLineDefinitionAssetMap.containsKey(contractLineDefinition.id) ) {
                        contractLineDefinitionAssetMap.put(contractLineDefinition.id, new List<Asset>() );
                    }

                    contractLineDefinitionAssetMap.get(contractLineDefinition.id).add(assetRecord);
                    uniqueProductSet.add(assetRecord.Product2Id);
                }

                Map<String, PricebookEntry> pricebookEntryMap = SCON_ServiceContractPlanHelper.getPricebookEntryMap( new List<Scon.ServiceContractPlan>{serviceContractPlan}, uniqueProductSet, new ServiceContract() );
                
                List<Asset> qualifiedAssetRecordList = new List<Asset>();

                for( String definitionId : contractLineDefinitionAssetMap.keySet() ) {

                    for( Asset assetRecord : contractLineDefinitionAssetMap.get(definitionId) ) {

                        if( !pricebookEntryMap.containsKey(assetRecord.Product2Id) ) {

                            System.debug( LoggingLevel.WARN, 'No pricebookEntry exists for Product= ' + assetRecord.Product2Id );
                            continue;
                        }

                        Scon.ContractLineItemPlan contractLineItemPlan = contractLineItemPlanMap.get(definitionId);
                        recordsTobeCreated += 1;

                        if( contractLineItemPlan.entitledServicePlans != null && !contractLineItemPlan.entitledServicePlans.isEmpty() ) {

                            recordsTobeCreated = recordsTobeCreated + contractLineItemPlan.entitledServicePlans.size();

                            for ( Scon.EntitledServicePlan entitledServicePlan : contractLineItemPlan.entitledServicePlans ) {

                                if ( entitledServicePlan.contractPriceLineItemPlans != null && 
                                     !entitledServicePlan.contractPriceLineItemPlans.isEmpty() ) {
                                        recordsTobeCreated = recordsTobeCreated + entitledServicePlan.contractPriceLineItemPlans.size();
                                }
                            }

                        }
            
                        if( contractLineItemPlan.contractPriceLineItemPlans != null && !contractLineItemPlan.contractPriceLineItemPlans.isEmpty() ) {
                            recordsTobeCreated = recordsTobeCreated + contractLineItemPlan.contractPriceLineItemPlans.size();
                        }

                        qualifiedAssetRecordList.add(assetRecord);
                    }
                }

                qualifiedAssets.qualifiedAssetList = qualifiedAssetRecordList;
            }

            qualifiedAssets.recordCount = recordsTobeCreated;
        }
        catch( SvmxSystem.SvmxNestedException e ){

            System.debug( LoggingLevel.ERROR, 'getQualifiedAssets() : Failed to get qualified records. Error= ' + e.getMessage() );
            throw e;
        } 
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getQualifiedAssets() : Failed to qualified Asset records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getQualifiedAssets() - exit; qualifiedAssets= ' + qualifiedAssets);
        }

        return qualifiedAssets;
    }

    public Scon.ContractLineItemResponse createContractLineItems( final Scon.ServiceContractPlan serviceContractPlan, 
                                                                  final List<Asset> assetRecordList, ServiceContract serviceContractRecord, 
                                                                  Map<Id,ContractLineAssetData> contractLineAssetDataMap) {

        System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - enter; assetRecordList= ' + assetRecordList);

        Scon.ContractLineItemResponse contractLineItemResponse = new Scon.ContractLineItemResponse();

        try {

            final Map<String, Scon.ContractLineItemPlan> productContractLineItemPlanMap = new Map<String, Scon.ContractLineItemPlan>();
            final Map<String, Scon.ContractLineItemPlan> contractLineItemPlanIdMap = new Map<String, Scon.ContractLineItemPlan>();
            String filterValue;
            Set<String> qualifyingDefinitionIds = new Set<String>();

            if( !assetRecordList.isEmpty() ) {

                final List<Scon.ContractLineItemPlan> qualifyingContractLineDefinitions = new List<Scon.ContractLineItemPlan>();
                for( Scon.ContractLineItemPlan contractLineDefinition : serviceContractPlan.contractLineItemPlans ) {

                    filterValue = contractLineDefinition.productId != null ? contractLineDefinition.productId : contractLineDefinition.productFamily;
                    productContractLineItemPlanMap.put( filterValue, contractLineDefinition );
                    contractLineItemPlanIdMap.put( contractLineDefinition.Id, contractLineDefinition );
                }

                final Set<String> uniqueProductSet = new Set<String>();
                final Map<String, List<Asset>> contractLineDefinitionAssetMap = new Map<String, List<Asset>>();
                for( Asset assetRecord : assetRecordList ) {

                    final Scon.ContractLineItemPlan contractLineDefinition = productContractLineItemPlanMap.containsKey( assetRecord.Product2Id ) ? productContractLineItemPlanMap.get(assetRecord.Product2Id) : productContractLineItemPlanMap.get(assetRecord.ProductFamily);

                    if( !contractLineDefinitionAssetMap.containsKey(contractLineDefinition.id) ) {
                        contractLineDefinitionAssetMap.put(contractLineDefinition.id, new List<Asset>() );
                    }

                    contractLineDefinitionAssetMap.get(contractLineDefinition.id).add(assetRecord);
                    uniqueProductSet.add(assetRecord.Product2Id);
                }

                Map<String, PricebookEntry> pricebookEntryMap = SCON_ServiceContractPlanHelper.getPricebookEntryMap( new List<Scon.ServiceContractPlan>{serviceContractPlan} , uniqueProductSet, serviceContractRecord );
                List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();

                Map<String, Schema.SObjectField> contractLineFieldResultMap = new Map<String, Schema.SObjectField>();
                
                if ( contractLineAssetDataMap != null && !contractLineAssetDataMap.isEmpty() ) {
                    contractLineFieldResultMap = describeManager.getObjectFieldMap( 'ContractLineItem' );
                }

                for( String definitionId : contractLineDefinitionAssetMap.keySet() ) {

                    final Scon.ContractLineItemPlan contractLineDefinition = contractLineItemPlanIdMap.get(definitionId);
                    for( Asset assetRecord : contractLineDefinitionAssetMap.get(definitionId) ) {

                        if( !pricebookEntryMap.containsKey(assetRecord.Product2Id) ) {

                            System.debug( LoggingLevel.WARN, 'No pricebookEntry exists for Product= ' + assetRecord.Product2Id );
                            continue;
                        }

                        qualifyingDefinitionIds.add(definitionId);

                        ContractLineAssetData contractLineAssetRequest;
                        if ( contractLineAssetDataMap != null && !contractLineAssetDataMap.isEmpty() && contractLineAssetDataMap.containsKey(assetRecord.Id) ) {
                            contractLineAssetRequest = contractLineAssetDataMap.get(assetRecord.Id);
                        }

                        final ContractLineItem contractLineItemRecord = SCON_ServiceContractPlanHelper.buildContractLineItem( assetRecord, contractLineDefinition, serviceContractRecord, contractLineAssetRequest, contractLineFieldResultMap );

                        if ( contractLineAssetRequest != null && contractLineAssetRequest.pricebookEntryId != null ) {
                            contractLineItemRecord.PricebookEntryId = contractLineAssetRequest.pricebookEntryId;
                        } else {
                            contractLineItemRecord.PricebookEntryId = pricebookEntryMap.get(assetRecord.Product2Id).Id;
                        }

                        contractLineItemRecord.UnitPrice = pricebookEntryMap.get(assetRecord.Product2Id).UnitPrice;
                        contractLineItemList.add(contractLineItemRecord);

                        if( !contractLineItemMap.containsKey(definitionId) ) {
                            contractLineItemMap.put( definitionId, new List<ContractLineItem>() );
                        }

                        contractLineItemMap.get(definitionId).add(contractLineItemRecord);
                    }
                }

                if( !contractLineItemList.isEmpty() ) {

                    contractLineItemResponse.contractLineItemList = contractLineItemList;
                    contractLineItemResponse.qualifyingDefinitionIds = qualifyingDefinitionIds;
                    contractLineItemResponse.contractLineItemPlanIdMap = contractLineItemPlanIdMap;
                }

            } else {
                System.debug( LoggingLevel.WARN, 'createContractLineItems() : No Contract Line Items records created.');
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - exit; contractLineItemResponse= ' + contractLineItemResponse);
        }

        return contractLineItemResponse;
    }

    private List<Entitlement> createEntitledServices( final Scon.ServiceContractPlan serviceContractPlan, ServiceContract serviceContractRecord ) {
        System.debug( LoggingLevel.DEBUG, 'createEntitledServices() - enter; serviceContractPlan= ' + serviceContractPlan);
        
        try {
            
            if( serviceContractPlan.entitledServicePlans != null && !serviceContractPlan.entitledServicePlans.isEmpty() ) {

                for( Scon.EntitledServicePlan entitledServicePlan : serviceContractPlan.entitledServicePlans ) {

                    final Entitlement entitlementRecord = buildEntitledService( entitledServicePlan, serviceContractRecord.id, null, serviceContractRecord );

                    entitledServiceMap.put(entitledServicePlan.id, new List<Entitlement>{entitlementRecord});

                    entitledServicePlans.add(entitledServicePlan);
                }
            }

            System.debug( LoggingLevel.INFO, 'createEntitledServices() : Created Entitled Service records.' );

        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Failed to create Entitled Service records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Failed to create Entitled Service records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createEntitledServices() - exit; entitledServiceList= ' + entitledServiceList);
        }

        return entitledServiceList;
    }

    private Map<String,List<Entitlement>> createEntitledServices( final List<Scon.ContractLineItemPlan> contractLineDefinitionList,  ServiceContract serviceContractRecord) {
        System.debug( LoggingLevel.DEBUG, 'createEntitledServices() - enter; contractLineDefinitionList= ' + contractLineDefinitionList);

        try {

            for( Scon.ContractLineItemPlan contractLineDefinition : contractLineDefinitionList ) {

                if( contractLineDefinition.entitledServicePlans != null && !contractLineDefinition.entitledServicePlans.isEmpty() ) {

                    final List<ContractLineItem> contractLineItems = contractLineItemMap.get(contractLineDefinition.id);
                    for( Scon.EntitledServicePlan entitledServicePlan : contractLineDefinition.entitledServicePlans ) {

                        final List<Entitlement> cliEntitledServiceList = buildEntitledServices( entitledServicePlan, contractLineItems, serviceContractRecord );
                        entitledServiceMap.put(entitledServicePlan.id, cliEntitledServiceList);
                        entitledServicePlans.add(entitledServicePlan);
                    }
                }
            }

            System.debug( LoggingLevel.INFO, 'createEntitledServices() : Created Entitled Service records.' );

        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Failed to create Entitled Service records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Failed to create Entitled Service records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createEntitledServices() - exit; entitledServiceMap= ' + entitledServiceMap);
        }

        return entitledServiceMap;
    }

    private List<Entitlement> buildEntitledServices( final Scon.EntitledServicePlan entitledServicePlan, final List<ContractLineItem> contractLineItemRecords, 
                                                     final ServiceContract serviceContractRecord ) {

        System.debug( LoggingLevel.FINE, 'buildEntitledServices() - enter; entitledServicePlan= ' + entitledServicePlan);

        List<Entitlement> entitledServiceRecords = new List<Entitlement>();

        try {
            for( ContractLineItem contractLineItemRecord :  contractLineItemRecords ) {
                entitledServiceRecords.add( buildEntitledService(entitledServicePlan, contractLineItemRecord.ServiceContractId, contractLineItemRecord, serviceContractRecord) );
            }
        }
        finally {
            System.debug( LoggingLevel.FINE, 'buildEntitledServices() - exit; entitledServiceRecords= ' + entitledServiceRecords);
        }

        return entitledServiceRecords;
    }

    private Entitlement buildEntitledService( final Scon.EntitledServicePlan entitledServicePlan, final Id serviceContractId, 
                                              final ContractLineItem contractLineItemRecord, final ServiceContract serviceContractRecord ) {

        System.debug( LoggingLevel.Info, 'buildEntitledService() - enter; entitledServicePlan= ' + entitledServicePlan);

        final Entitlement entitledServiceRecord = new Entitlement();

        try {

            entitledServiceRecord.ServiceContractId = serviceContractId;
            if ( contractLineItemRecord != null ) {
                entitledServiceRecord.ContractLineItemId = contractLineItemRecord.Id;
                entitledServiceRecord.AssetId = contractLineItemRecord.AssetId;
            }

            entitledServiceRecord.RecordTypeId =
                Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get(COMM_Constants.RECORD_TYPE_ENTITLED_SERVICE).getRecordTypeId();
            entitledServiceRecord.Name = entitledServicePlan.name;
            entitledServiceRecord.AccountId = serviceContractRecord.AccountId;
            entitledServiceRecord.SVMXA360__EntitledServiceProductId__c = entitledServicePlan.serviceProductId;

            Date startDate = serviceContractRecord.StartDate;
            Date endDate = serviceContractRecord.EndDate;


            if( contractLineItemRecord != null) {

                if ( contractLineItemRecord.StartDate != null ) {
                    startDate = contractLineItemRecord.StartDate;
                } 

                if ( contractLineItemRecord.EndDate != null ) {
                    endDate = contractLineItemRecord.EndDate;
                } 
            }

            entitledServiceRecord.StartDate = startDate;

            if( entitledServicePlan.duration != null && entitledServicePlan.unitOfTime != null ) {
                entitledServiceRecord.EndDate = COMM_DateLiteralUtils.calculateEndDate( startDate, entitledServicePlan.duration, entitledServicePlan.unitOfTime );
            } else {
                entitledServiceRecord.EndDate = endDate;
            }

            entitledServiceRecord.SVMXA360__ServiceCountType__c = entitledServicePlan.serviceUnit;
            if( entitledServicePlan.serviceUnit != null ) {
                if( entitledServicePlan.serviceUnit.equalsIgnoreCase(SCON_ServiceContractPlanManager.StringAmount) ) {
                    entitledServiceRecord.SVMXA360__TotalServiceAmount__c = entitledServicePlan.totalService;
                    entitledServiceRecord.SVMXA360__ServiceAmountAlertThreshold__c = entitledServicePlan.serviceAlertThreshold;
                } else {
                    entitledServiceRecord.SVMXA360__TotalServiceCount__c = entitledServicePlan.totalService;
                    entitledServiceRecord.SVMXA360__ServiceCountAlertThreshold__c = entitledServicePlan.serviceAlertThreshold;
                }
            }
            entitledServiceRecord.SvcApptBookingWindowsId = entitledServicePlan.operatingHoursId;
            entitledServiceRecord.SVMXA360__CaseEntitlementProcessId__c  = entitledServicePlan.caseEntitlementProcessId;
            entitledServiceRecord.SVMXA360__WorkOrderEntitlementProcessId__c  = entitledServicePlan.workOrderEntitlementProcessId;
        }
        finally {
            System.debug( LoggingLevel.FINE, 'buildEntitledService() - exit; entitledServiceRecord= ' + entitledServiceRecord);
        }

        return entitledServiceRecord;
    }

    private List<SVMXA360__ContractPriceLineItem__c> createContractPriceLines( final List<Scon.ContractLineItemPlan> contractLineItemPlans ) {

        System.debug( LoggingLevel.DEBUG, 'createContractPriceLines() - enter; contractLineItemPlans= ' + contractLineItemPlans);

        try {

            for( Scon.ContractLineItemPlan contractLineDefinition : contractLineItemPlans ) {

                if( contractLineDefinition.contractPriceLineItemPlans != null && !contractLineDefinition.contractPriceLineItemPlans.isEmpty() ) {

                    final List<ContractLineItem> contractLineItemList = contractLineItemMap.get(contractLineDefinition.id);
                    for( Scon.ContractPriceLineItemPlan contractPriceLineTerm : contractLineDefinition.contractPriceLineItemPlans ) {
                        contractPriceLineItemList.addAll( buildContractPriceLines( contractPriceLineTerm, contractLineItemList ) );
                    }
                }
            }

            System.debug( LoggingLevel.INFO, 'createContractPriceLines() : Created Contract Price Line Item records.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractPriceLines() : Failed to create Contract Price Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractPriceLines() : Failed to create Contract Price Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractPriceLines() - exit; contractPriceLineList= ' + contractPriceLineItemList);
        }

        return contractPriceLineItemList;
    }

    private List<SVMXA360__ContractPriceLineItem__c> createContractPriceLines( final List<Scon.EntitledServicePlan> entitledServicePlans ) {

        System.debug( LoggingLevel.DEBUG, 'createContractPriceLines() - enter; entitledServicePlans= ' + entitledServicePlans);

        try {
            for( Scon.EntitledServicePlan entitledServicePlan : entitledServicePlans ) {

                if( entitledServicePlan.contractPriceLineItemPlans != null && !entitledServicePlan.contractPriceLineItemPlans.isEmpty() ) {

                    final List<Entitlement> entitledServiceRecords = entitledServiceMap.get(entitledServicePlan.id);
                    for( Scon.ContractPriceLineItemPlan contractPriceLineTerm : entitledServicePlan.contractPriceLineItemPlans ) {
                        contractPriceLineItemList.addAll( buildContractPriceLines( contractPriceLineTerm, entitledServiceRecords ) );
                    }
                }
            }

            System.debug( LoggingLevel.INFO, 'createContractPriceLines() : Created Contract Price Line Item records.' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createContractPriceLines() : Failed to create Contract Price Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractPriceLines() : Failed to create Contract Price Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractPriceLines() - exit; contractPriceLineItemList= ' + contractPriceLineItemList);
        }

        return contractPriceLineItemList;
    }

    public List<SVMXA360__ContractPriceLineItem__c> buildContractPriceLines( final Scon.ContractPriceLineItemPlan contractPriceLineItemPlan, List<SObject> sObjectList ) {

        System.debug( LoggingLevel.DEBUG, 'buildContractPriceLines() - enter; contractPriceLineItemPlan= ' + contractPriceLineItemPlan);

        final List<SVMXA360__ContractPriceLineItem__c> contractPriceLineList = new List<SVMXA360__ContractPriceLineItem__c>();

        try {
            for( SObject sourceRecord : sObjectList ) {

                final SVMXA360__ContractPriceLineItem__c contractPriceLineItem = new SVMXA360__ContractPriceLineItem__c();

                switch on String.valueOf( sourceRecord.Id.getSObjectType() ) {

                    when 'ServiceContract' {
                        contractPriceLineItem.SVMXA360__ServiceContractId__c = sourceRecord.Id;
                    }
                    when 'ContractLineItem' {
                        contractPriceLineItem.SVMXA360__ServiceContractId__c = (Id)sourceRecord.get('ServiceContractId');
                        contractPriceLineItem.SVMXA360__ContractLineId__c = sourceRecord.Id;
                    }
                    when 'Entitlement' {
                        contractPriceLineItem.SVMXA360__ServiceContractId__c = (Id)sourceRecord.get('ServiceContractId');
                        if (contractPriceLineItemPlan.planType != 'Entitled Service Plan') {
                            contractPriceLineItem.SVMXA360__ContractLineId__c = (Id)sourceRecord.get('ContractLineItemId');
                        }
                        contractPriceLineItem.SVMXA360__EntitledServiceId__c = sourceRecord.Id;
                    }
                }

                contractPriceLineItem.SVMXA360__EntitledDiscount__c = contractPriceLineItemPlan.entitledDiscount;
                contractPriceLineItem.SVMXA360__EntitledPrice__c = contractPriceLineItemPlan.entitledPrice;
                contractPriceLineItem.SVMXA360__ExpenseItem__c = contractPriceLineItemPlan.expenseItem;
                contractPriceLineItem.SVMXA360__LineType__c = contractPriceLineItemPlan.lineType;
                contractPriceLineItem.SVMXA360__ProductId__c = contractPriceLineItemPlan.productId;
                contractPriceLineItem.SVMXA360__ProductFamily__c = contractPriceLineItemPlan.productFamily;
                contractPriceLineItem.SVMXA360__Surcharge__c = contractPriceLineItemPlan.surcharge;

                if( UserInfo.isMultiCurrencyOrganization() ) {
                    contractPriceLineItem.put('CurrencyIsoCode', contractPriceLineItemPlan.currencyIsoCode );
                }
                 
                contractPriceLineList.add( contractPriceLineItem );
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildContractPriceLines() - exit; contractPriceLineList= ' + contractPriceLineList);
        }

        return contractPriceLineList;
    }

    public List<SVMXA360__MaintenancePlanOffering__c> buildMaintenancePlanOfferings( List<Scon.OfferedMaintenancePlanTemplate> offeredMaintenancePlanTemplates, Id serviceContractPlanId ) {
        System.debug( LoggingLevel.DEBUG, 'buildMaintenancePlanOfferings() - enter; offeredMaintenancePlanTemplates= ' + offeredMaintenancePlanTemplates);

        final List<SVMXA360__MaintenancePlanOffering__c> maintenancePlanOfferingList = new List<SVMXA360__MaintenancePlanOffering__c>();
    
        try {
            for( Scon.OfferedMaintenancePlanTemplate offeredMaintenancePlanTemplate : offeredMaintenancePlanTemplates ) {
    
                final SVMXA360__MaintenancePlanOffering__c maintenancePlanOffering = new SVMXA360__MaintenancePlanOffering__c();
                maintenancePlanOffering.SVMXA360__MaintenancePlanTemplateId__c = offeredMaintenancePlanTemplate.maintenancePlanTemplateId;
                maintenancePlanOffering.SVMXA360__ServiceContractId__c = serviceContractPlanId;
                maintenancePlanOfferingList.add( maintenancePlanOffering );
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'buildMaintenancePlanOfferings() - exit; maintenancePlanOfferingList= ' + maintenancePlanOfferingList);
        }
    
        return maintenancePlanOfferingList;
    }

    private ServiceContract populateAccountInfo( final Id sourceRecordId, ServiceContract serviceContractRecord) {

        System.debug( LoggingLevel.DEBUG, 'populateAccountInfo() - enter; sourceRecordId= ' + sourceRecordId + '; serviceContractRecord= ' + serviceContractRecord);

        try {

            switch on String.valueOf( sourceRecordId.getSobjectType() ) {
                when 'Account' {
                    serviceContractRecord.AccountId = sourceRecordId;
                    List<Account> accountRecords = SvmxDatabase.query([SELECT Id, BillingStreet, BillingCity, BillingState,
                                                                BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity,
                                                                ShippingState, ShippingPostalCode, ShippingCountry FROM Account
                                                                where Id = :sourceRecordId]);
                    serviceContractRecord.BillingStreet = accountRecords[0].BillingStreet;
                    serviceContractRecord.BillingCity = accountRecords[0].BillingCity;
                    serviceContractRecord.BillingState = accountRecords[0].BillingState;
                    serviceContractRecord.BillingPostalCode = accountRecords[0].BillingPostalCode;
                    serviceContractRecord.BillingCountry = accountRecords[0].BillingCountry;
                    serviceContractRecord.ShippingStreet = accountRecords[0].ShippingStreet;
                    serviceContractRecord.ShippingCity = accountRecords[0].ShippingCity;
                    serviceContractRecord.ShippingState = accountRecords[0].ShippingState;
                    serviceContractRecord.ShippingPostalCode = accountRecords[0].ShippingPostalCode;
                    serviceContractRecord.ShippingCountry = accountRecords[0].ShippingCountry;
                    serviceContractRecord.AccountId = sourceRecordId;
                }
                when 'Asset' {
                    List<Asset> assetRecords = SvmxDatabase.query([SELECT AccountId, Account.BillingStreet, Account.BillingCity,
                                                            Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                                                            Account.ShippingStreet, Account.ShippingCity,
                                                            Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry
                                                            FROM Asset where Id = :sourceRecordId]);
                    serviceContractRecord.BillingStreet = assetRecords[0].Account.BillingStreet;
                    serviceContractRecord.BillingCity = assetRecords[0].Account.BillingCity;
                    serviceContractRecord.BillingState = assetRecords[0].Account.BillingState;
                    serviceContractRecord.BillingPostalCode = assetRecords[0].Account.BillingPostalCode;
                    serviceContractRecord.BillingCountry = assetRecords[0].Account.BillingCountry;
                    serviceContractRecord.ShippingStreet = assetRecords[0].Account.ShippingStreet;
                    serviceContractRecord.ShippingCity = assetRecords[0].Account.ShippingCity;
                    serviceContractRecord.ShippingState = assetRecords[0].Account.ShippingState;
                    serviceContractRecord.ShippingPostalCode = assetRecords[0].Account.ShippingPostalCode;
                    serviceContractRecord.ShippingCountry = assetRecords[0].Account.ShippingCountry;
                    serviceContractRecord.AccountId = assetRecords[0].AccountId;
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'populateBillingAndShippingAddress() : Failed to populate Account Info. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'populateBillingAndShippingAddress() : Failed to populate Account Info. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'populateBillingAndShippingAddress() - exit; serviceContractRecord= ' + serviceContractRecord);
        }

        return serviceContractRecord;
    }

    public Scon.ServiceContractDeleteResponse deleteServiceContract( Id serviceContractId ) {

        System.debug( LoggingLevel.DEBUG, 'deleteServiceContract() - enter; serviceContractId = ' + serviceContractId );

        Scon.ServiceContractDeleteResponse serviceContractDeleteResponse = new Scon.ServiceContractDeleteResponse();

        final System.Savepoint sPoint = Database.setSavepoint();

        try {

            if( serviceContractId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            Id recordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByDeveloperName().get('EntitledServices').getRecordTypeId();

            List<ServiceContract> serviceContractRecords = SvmxDatabase.query([SELECT Id, (Select Id from ContractLineItems),
                                                            (Select Id from Entitlements Where RecordTypeId = :recordTypeId), 
                                                            (Select Id from SVMXA360__Contract_Price_Line_Items__r)
                                                            FROM ServiceContract where Id =:serviceContractId]);   
                                                            
            ServiceContract serviceContractRecord = serviceContractRecords[0];
            Integer totalRecordCount = 1;

            if ( serviceContractRecord.ContractLineItems != null && !serviceContractRecord.ContractLineItems.isEmpty() ) {
                totalRecordCount = totalRecordCount + serviceContractRecord.ContractLineItems.size();
            }

            if ( serviceContractRecord.Entitlements != null && !serviceContractRecord.Entitlements.isEmpty() ) {
                totalRecordCount = totalRecordCount + serviceContractRecord.Entitlements.size();
            }

            if ( serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r != null && 
                 !serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r.isEmpty() ) {
                totalRecordCount = totalRecordCount + serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r.size();
            }

            if ( totalRecordCount < 5000 ) {

                if ( !serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r.isEmpty() ) {
                    List<SVMXA360__ContractPriceLineItem__c> contractPriceLineItemList = 
                        serviceContractRecord.SVMXA360__Contract_Price_Line_Items__r;
                    SvmxDatabase.deleteRecord( contractPriceLineItemList );
                }

                if ( !serviceContractRecord.Entitlements.isEmpty() ) {
                    List<Entitlement> entitlementList = serviceContractRecord.Entitlements;
                    SvmxDatabase.deleteRecord( entitlementList );
                }

                List<SVMXA360__SCONAuthoringLog__c> sconLogRecords = SvmxDatabase.query([SELECT Id from SVMXA360__SCONAuthoringLog__c where SVMXA360__ServiceContractId__c = :serviceContractRecord.Id]);
                
                if ( !sconLogRecords.isEmpty() ) {
                    SvmxDatabase.deleteRecord( sconLogRecords );
                }

                SvmxDatabase.deleteRecord(serviceContractRecord);
                serviceContractDeleteResponse.deletionStatus = 'Completed';

            } else {
                SVMXA360__SCONAuthoringLog__c parentLogRecord = SCON_ServiceContractPlanHelper.publishDeletePlatformEvents(serviceContractRecord);
                serviceContractDeleteResponse.serviceContractRecord = serviceContractRecord;
                serviceContractDeleteResponse.parentAuthoringLog = parentLogRecord;
                serviceContractDeleteResponse.deletionStatus = 'In Progress';

            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            Database.rollback(sPoint);
            System.debug( LoggingLevel.ERROR, 'deleteServiceContract() : Failed to delete Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            Database.rollback(sPoint);
            System.debug( LoggingLevel.ERROR, 'deleteServiceContract() : Failed to delete Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceContract() - exit; serviceContractDeleteResponse deletionStatus = ' + serviceContractDeleteResponse.deletionStatus);
        }

        return serviceContractDeleteResponse;
    }

    public void deleteServiceContractCoverages ( List<Id> recordIds, String userId, String parentSCONLogRecordId, String serviceContractId ) {
      
        System.debug( LoggingLevel.DEBUG, 'deleteServiceContractCoverages() - enter; recordIds= ' + recordIds );

        Scon.LogMessage logMessage = new Scon.LogMessage();

        try {

            String sObjectName = recordIds[0].getSObjectType().getDescribe().getName();

            if ( sObjectName == 'SVMXA360__ContractPriceLineItem__c' ) {

                List<SVMXA360__ContractPriceLineItem__c> cpliRecords = SvmxDatabase.query([SELECT Id FROM SVMXA360__ContractPriceLineItem__c where Id IN :recordIds]); 

                if ( !cpliRecords.isEmpty() ) {

                    logMessage.contractPriceLineItemsDeleted = cpliRecords.size();
                    SvmxDatabase.deleteRecord( cpliRecords );
                }
            }

            else if ( sObjectName == 'Entitlement' ) {

                List<Entitlement> entitlementRecords = SvmxDatabase.query([SELECT Id FROM Entitlement where Id IN :recordIds]); 

                if ( !entitlementRecords.isEmpty() ) {

                    logMessage.entitledServicesDeleted = entitlementRecords.size();
                    SvmxDatabase.deleteRecord( entitlementRecords );
                }
            }

            else if ( sObjectName == 'ContractLineItem' ) {

                List<ContractLineItem> cliRecords = SvmxDatabase.query([SELECT Id FROM ContractLineItem where Id IN :recordIds]); 

                if ( !cliRecords.isEmpty() ) {

                    logMessage.contractLineItemsDeleted = cliRecords.size();
                    SvmxDatabase.deleteRecord( cliRecords );
                }
            }

            SCON_ServiceContractPlanHelper.createSCONLogRecord( serviceContractId, parentSCONLogRecordId, userId, logMessage, 'Delete');

        }
        catch( SvmxSystem.SvmxNestedException e ) {

            logMessage.errors = e.getMessage();
            SCON_ServiceContractPlanHelper.createSCONLogRecord( serviceContractId, parentSCONLogRecordId, userId, logMessage, 'Delete');
            System.debug( LoggingLevel.ERROR, 'deleteServiceContractCoverages() : Failed to publish delete records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            logMessage.errors = e.getMessage();
            SCON_ServiceContractPlanHelper.createSCONLogRecord( serviceContractId, parentSCONLogRecordId, userId, logMessage, 'Delete');
            System.debug( LoggingLevel.ERROR, 'deleteServiceContractCoverages() : Failed to publish delete records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceContractCoverages() - exit; recordIds= ' + recordIds);
        }

    }

    public Scon.AuthoringSummaryDetails getAuthoringSummary ( final Id serviceContractId ) {
        System.debug( LoggingLevel.DEBUG, 'getAuthoringSummary() - enter; serviceContractId= ' + serviceContractId);

        final Scon.AuthoringSummaryDetails authoringSummaryDetails = new Scon.AuthoringSummaryDetails();

        try {

            if( serviceContractId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            List<SVMXA360__SCONAuthoringLog__c> masterLog = SvmxDatabase.query([SELECT SVMXA360__TotalBatchesCompleted__c, SVMXA360__TotalNumberOfBatches__c  FROM SVMXA360__SCONAuthoringLog__c
                WHERE SVMXA360__ServiceContractId__c = :serviceContractId AND SVMXA360__LogType__c = 'Master' AND SVMXA360__OperationType__c = 'Create']);

            authoringSummaryDetails.totalNumberOfBatchesExecuted = masterLog.isEmpty() ? 0 : (Integer) masterLog[0].SVMXA360__TotalBatchesCompleted__c;
            authoringSummaryDetails.totalNumberOfBatches = masterLog.isEmpty() ? 0 : (Integer) masterLog[0].SVMXA360__TotalNumberOfBatches__c;
            authoringSummaryDetails.authoringLogOfFailedBatches =  masterLog.isEmpty()
                ? new List<SVMXA360__SCONAuthoringLog__c>()
                : SvmxDatabase.query([SELECT Id, Name, SVMXA360__LogType__c FROM SVMXA360__SCONAuthoringLog__c
                WHERE SVMXA360__ParentSCONAuthoringLogId__c = :masterLog[0].Id AND SVMXA360__Status__c = 'Failed' AND SVMXA360__LogType__c = 'Detail']);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getAuthoringSummary() : Failed to fetch AuthoringSummary. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAuthoringSummary() : Failed to fetch AuthoringSummary. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAuthoringSummary() - exit;');
        }
        return authoringSummaryDetails;
    }

    public Common.ServiceResponse createServiceContract(ServiceContractData serviceContractData) {

        System.debug( LoggingLevel.DEBUG, 'createServiceContract() - enter; serviceContractData= ' + serviceContractData);

        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();

        serviceResponse.errors = new List<Common.ServiceError>();

        ServiceContract serviceContractRecord = new ServiceContract();

        try{
            if (serviceContractData == null) {
                System.debug(LoggingLevel.ERROR, 'createServiceContract Invalid request, serviceContractData: '+ serviceContractData );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
            if( String.isBlank(serviceContractData.accountId) || serviceContractData.startDate == null
             || String.isBlank(serviceContractData.servicePlanProductId) || String.isBlank(serviceContractData.serviceContractName) ) {
                System.debug( LoggingLevel.ERROR, 'createServiceContract() : Invalid request parameters. serviceContractData= ' + serviceContractData );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            SVMXA360__ServiceContractPlan__c serviceContractPlanRecord;
            if (serviceContractData.isCLIPlanProductId !=null && serviceContractData.isCLIPlanProductId ) {
                serviceContractPlanRecord = SCON_ServiceContractPlanHelper.getSCONfromCLIPlanProductId(serviceContractData.servicePlanProductId);
            } else {
                serviceContractPlanRecord = SCON_ServiceContractPlanHelper.getServiceContractPlanRecord(serviceContractData.servicePlanProductId);
            }
            
            if( serviceContractPlanRecord == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' serviceContractData.servicePlanProductId= ' + serviceContractData.servicePlanProductId );
            }

            Scon.ServiceContractPlan serviceContractPlan = new Scon.ServiceContractPlan();
            Scon.ServiceContractPlanRequest sconRequest = SCON_ServiceContractPlanHelper.buildSconRequest(serviceContractData,serviceContractPlanRecord);

            serviceContractPlan = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails( sconRequest.serviceContractPlanId );

            serviceContractRecord = createServiceContract( sconRequest, serviceContractPlan);

            System.debug( LoggingLevel.INFO, 'createServiceContract() : Created Service Contract. serviceContract= ' + serviceContractRecord + ' ; sconRequest = '+sconRequest);

            createChildRecords (serviceContractPlan,serviceContractRecord,serviceResponse);

            serviceContractData.serviceContractId = serviceContractRecord.Id;
            serviceResponse.data = serviceContractData;
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to create Service Contract for the request. Error= ' + e.getMessage() );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createServiceContract() : Failed to Create Service Contract for the request. Error= ' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createServiceContract() - exit; serviceResponse = ' + serviceResponse );
        }

        return serviceResponse;
    }

    public Common.ServiceResponse createContractLineItems(ContractLineItemData contractLineItemData) {

        System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - enter; contractLineItemData= ' + contractLineItemData);
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        
        try{

            if ( contractLineItemData == null || contractLineItemData.serviceContractId == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.ENTER_REQUIRED_FIELDS );
            }

            ServiceContract serviceContractRecord = SCON_ServiceContractPlanHelper.getServiceContractRecord( contractLineItemData.serviceContractId );
            
            List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
            Map<Id,ContractLineAssetData> contractLineAssetDataMap = new Map<Id,ContractLineAssetData>();
            String sourceError = 'Contract Line Items created with errors.';

            if ( contractLineItemData.servicePlanProductId == null ) {

                Scon.ContractLineItemResponse contractLineItemsWOPlan = SCON_ServiceContractPlanHelper.createContractLinesWithoutPlan( contractLineItemData, serviceContractRecord );
                contractLineAssetDataMap = contractLineItemsWOPlan.contractLineAssetDataMap;
                contractLineItemList = contractLineItemsWOPlan.contractLineItemList;
                
                try {
                    contractLineItemList = (List<ContractLineItem>)SvmxDatabase.insertRecord ( contractLineItemList, false );
                } catch (SvmxSystem.SvmxNestedException ex) {
                    SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                }

            } 
            else {

                Scon.ServiceContractPlan serviceContractPlan;
                SVMXA360__ServiceContractPlan__c serviceContractPlanRecord;

                if (contractLineItemData.isCLIPlanProductId !=null && contractLineItemData.isCLIPlanProductId ) {
                    serviceContractPlanRecord = SCON_ServiceContractPlanHelper.getSCONfromCLIPlanProductId(contractLineItemData.servicePlanProductId);
                } else {
                    serviceContractPlanRecord = SCON_ServiceContractPlanHelper.getServiceContractPlanRecord(contractLineItemData.servicePlanProductId);
                }
                serviceContractPlan = SCON_ServiceContractPlanManager.getInstance().getServiceContractPlanWithDetails( serviceContractPlanRecord.Id );

                Set<Id> contractLineItemIds = new Set<Id>();

                for ( ContractLineAssetData assetRequest : contractLineItemData.assetDataList ) {
                    if ( assetRequest.contractLineItemId != null ) {
                        contractLineItemIds.add(assetRequest.contractLineItemId); 
                    } else {
                        contractLineAssetDataMap.put(assetRequest.assetId, assetRequest);
                    }
                }

                Scon.ContractLineItemResponse contractLineItemResponse;

                if ( !contractLineAssetDataMap.isEmpty() ) {

                    List<Asset> assetRecordList = SCON_ServiceContractPlanHelper.getAssetRecords( contractLineAssetDataMap.keyset() );
                    
                    if ( assetRecordList.isEmpty() ) {
                        throw new SvmxSystem.SvmxNestedException( System.Label.Error_NoMatchingAssetsFound );
                    }
                    
                    contractLineItemResponse = createCLIsForAllAsset( serviceContractPlan, assetRecordList, serviceContractRecord, contractLineAssetDataMap, contractLineItemData );
                    contractLineItemList = contractLineItemResponse.contractLineItemList;
                }

                List<Scon.ContractLineItemPlan> qualifyingContractLineDefinitions = new List<Scon.ContractLineItemPlan>();
                
                if( contractLineItemList != null && !contractLineItemList.isEmpty() ) {
                
                    try {
                        contractLineItemList = (List<ContractLineItem>)SvmxDatabase.insertRecord ( contractLineItemList, false );
                    } catch (SvmxSystem.SvmxNestedException ex) {
                        SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                    }

                    System.debug( LoggingLevel.INFO, 'createContractLineItems() : Created Contract Line Item records.' );
                    
                    for (String planId : contractLineItemResponse.qualifyingDefinitionIds) {
                        qualifyingContractLineDefinitions.add(contractLineItemResponse.contractLineItemPlanIdMap.get(planId));
                    }

                }

                if ( qualifyingContractLineDefinitions.isEmpty() ) {

                    qualifyingContractLineDefinitions.add(SCON_ServiceContractPlanHelper.evaluateQualifyingPlan(serviceContractPlan,contractLineItemData.servicePlanProductId));
                    
                }

                populateCLIMap( contractLineItemIds, qualifyingContractLineDefinitions );

                createEntitledServicesAndCPLIs(qualifyingContractLineDefinitions,serviceContractRecord);

                if( !entitledServiceMap.isEmpty() ) {

                    for ( String entitledServicePlanId : entitledServiceMap.keySet() ) {
                        entitledServiceList.addAll(entitledServiceMap.get(entitledServicePlanId));
                    }

                    try {
                        entitledServiceList = (List<Entitlement>)SvmxDatabase.insertRecord ( entitledServiceList, false );
                    } catch (SvmxSystem.SvmxNestedException ex) {
                        SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                    }
                }

                if( !entitledServicePlans.isEmpty() ) {
                    createContractPriceLines( entitledServicePlans );
                }
        
                if( !contractPriceLineItemList.isEmpty() ) {

                    try {
                        contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>)SvmxDatabase.insertRecord ( contractPriceLineItemList, false );
                    } catch (SvmxSystem.SvmxNestedException ex) {
                        SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                    }
                }
            }

            contractLineItemData.assetDataList = SCON_ServiceContractPlanHelper.updateAssetDataRequest(contractLineItemList, contractLineAssetDataMap);
            serviceResponse.data = contractLineItemData;
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to create Contract Line Items for the request. Error= ' + e.getMessage() );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createContractLineItems() : Failed to Create Contract Line Items for the request. Error= ' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createContractLineItems() - exit; serviceResponse = ' + serviceResponse );
        }

        return serviceResponse;
    }

    private void populateCLIMap (Set<Id> contractLineItemIds, List<Scon.ContractLineItemPlan> qualifyingContractLineDefinitions) {
        
        if ( !contractLineItemIds.isEmpty() ) {

            if( !contractLineItemMap.containsKey(qualifyingContractLineDefinitions[0].Id) ) {
                contractLineItemMap.put( qualifyingContractLineDefinitions[0].Id, new List<ContractLineItem>() );
            }

            List<ContractLineItem> cliRecords = SvmxDatabase.query([SELECT Id, ServiceContractId, AssetId, StartDate, EndDate FROM ContractLineItem WHERE Id IN :contractLineItemIds]);

            for ( ContractLineItem cliRecord : cliRecords ) {
                contractLineItemMap.get(qualifyingContractLineDefinitions[0].Id).add(cliRecord);
            }
        }
    }

    private void createEntitledServicesAndCPLIs( List<Scon.ContractLineItemPlan> qualifyingContractLineDefinitions, ServiceContract serviceContractRecord) {
        
        if ( !qualifyingContractLineDefinitions.isEmpty() ) {
            createEntitledServices( qualifyingContractLineDefinitions, serviceContractRecord );
            createContractPriceLines( qualifyingContractLineDefinitions );
        }
    }

    public Common.ServiceResponse createEntitledServices(EntitledServiceData entitledServiceData) {
        
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        serviceResponse.errors = new List<Common.ServiceError>();
        ContractLineItem contractLineItemRecord;
        Entitlement entitledServiceRecord;
        Map<String, Schema.SObjectField> sObjectFieldResultMap;

        try{

            SCON_ServiceContractPlanHelper.validateEntitledServiceData (entitledServiceData);
            
            ServiceContract serviceContractRecord = SCON_ServiceContractPlanHelper.getServiceContractRecord( entitledServiceData.serviceContractId );
            if( serviceContractRecord == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' entitledServiceData.serviceContractId= ' + entitledServiceData.serviceContractId );
            }
            System.debug( LoggingLevel.INFO, 'createEntitledServices() : Existing Service Contract. serviceContract= ' + serviceContractRecord );

            final List<ContractLineItem> contractLineItemRecords = SvmxDatabase.query( [Select Id,AssetId,ServiceContractId,StartDate,EndDate from ContractLineItem Where Id=:entitledServiceData.contractLineItemId] );

            if (contractLineItemRecords!=null && !contractLineItemRecords.isEmpty()) {
                contractLineItemRecord = contractLineItemRecords.get(0);
                System.debug( LoggingLevel.INFO, 'createEntitledServices() : Existing contractLineItemRecord= ' + contractLineItemRecord );
            }

            List<Entitlement> existingEntitledServices = SCON_ServiceContractPlanHelper.getEntitledServiceRecords (entitledServiceData);

            if (existingEntitledServices != null && !existingEntitledServices.isEmpty() ) {
                if( existingEntitledServices.size() > 1 ) {
                    throw new SvmxSystem.SvmxNestedException( System.Label.Error_EntitledServiceMoreThanOne );
                }
                // Update exisiting entitled service quantity
                entitledServiceRecord = existingEntitledServices.get(0);
                if( entitledServiceRecord.SVMXA360__ServiceCountType__c!=null && entitledServiceRecord.SVMXA360__ServiceCountType__c.equalsIgnoreCase(SCON_ServiceContractPlanManager.StringAmount) ) {
                    entitledServiceRecord.SVMXA360__TotalServiceAmount__c = String.isNotBlank(entitledServiceData.serviceQty) ? 
                        entitledServiceRecord.SVMXA360__TotalServiceAmount__c + Integer.valueOf( entitledServiceData.serviceQty ) : entitledServiceRecord.SVMXA360__TotalServiceAmount__c;                    
                } else {
                    entitledServiceRecord.SVMXA360__TotalServiceCount__c = String.isNotBlank(entitledServiceData.serviceQty) ? 
                        entitledServiceRecord.SVMXA360__TotalServiceCount__c + Integer.valueOf( entitledServiceData.serviceQty ) : entitledServiceRecord.SVMXA360__TotalServiceCount__c;
                }
            } else {
                //create new entitled service if there is no exisiting service for the product.
                entitledServiceRecord = SCON_ServiceContractPlanHelper.buildEntitlementRecord(entitledServiceData,serviceContractRecord,contractLineItemRecord);
            }
            
            entitledServiceRecord = (Entitlement) SvmxDatabase.upsertRecord( entitledServiceRecord );
            entitledServiceData.entitledServiceId = entitledServiceRecord.Id;

            serviceResponse.data = entitledServiceData;            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Failed to create Entitled Service for the request. Error= ' + e.getMessage() );
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createEntitledServices() : Failed to Create Entitled Service for the request. Error= ' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createEntitledServices() - exit; serviceResponse = ' + serviceResponse );
        }

        return serviceResponse;
    }

    public Common.ServiceResponse cancelServiceContract(CancelServiceContractData cancelServiceContract) {
        Common.ServiceResponse serviceResponse = new Common.ServiceResponse();
        try{

            if (cancelServiceContract == null) {
                System.debug(LoggingLevel.ERROR, 'cancelServiceContract Invalid request, cancelServiceContract: '+ cancelServiceContract );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
            if( String.isBlank(cancelServiceContract.salesContractId)
             || String.isBlank(cancelServiceContract.salesContractIdFieldAPIName)
             || cancelServiceContract.effectiveEndDate == null ) {

                System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Invalid request parameters. cancelServiceContract= ' + cancelServiceContract );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }

            Map<String, Schema.SObjectField> fieldsMap = COMM_DescribeManager.getInstance().getObjectFieldMap( 'ServiceContract' );
            if ( !fieldsMap.containsKey(cancelServiceContract.salesContractIdFieldAPIName) ) {
                throw new SvmxSystem.SvmxNestedException(cancelServiceContract.salesContractIdFieldAPIName + ' ' + ErrorMessage.FIELD_NOT_EXISTS );
            }

            serviceResponse.data = cancelServiceContract;

            String salesContractId = String.escapeSingleQuotes(cancelServiceContract.salesContractId);

            String queryStr = 'SELECT Id, ' + String.escapeSingleQuotes(cancelServiceContract.salesContractIdFieldAPIName)
            + ', (SELECT Id FROM ContractLineItems), (SELECT Id FROM Entitlements) FROM ServiceContract'
            + ' WHERE ' + String.escapeSingleQuotes(cancelServiceContract.salesContractIdFieldAPIName) + ' = :salesContractId';

            System.debug(LoggingLevel.INFO, 'cancelServiceContract() - queryStr = ' + queryStr);

            List<ServiceContract> serviceContractList = SvmxDatabase.query(Database.query( queryStr ) );

            System.debug(LoggingLevel.INFO, 'cancelServiceContract() - serviceContractList = ' + serviceContractList);

            List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();
            List<Entitlement> entitlementList = new List<Entitlement>();

            for ( ServiceContract serviceContract : serviceContractList ) {
                serviceContract.EndDate = cancelServiceContract.effectiveEndDate;
                if( string.isNotBlank ( cancelServiceContract.cancellationReasonFieldAPIName ) ){
                    serviceContract.put(String.escapeSingleQuotes(cancelServiceContract.cancellationReasonFieldAPIName),
                    cancelServiceContract.cancellationReason);
                }

                for(ContractLineItem contractLineItem : serviceContract.ContractLineItems ) {
                    contractLineItem.EndDate = cancelServiceContract.effectiveEndDate;
                    contractLineItemList.add(contractLineItem);
                }

                for(Entitlement entitlement : serviceContract.Entitlements ) {
                    entitlement.EndDate = cancelServiceContract.effectiveEndDate;
                    entitlementList.add(entitlement);
                }
            }

            String sourceError = 'Cancelling of Service Contract failed with errors.';
            try {
                serviceContractList = (List<ServiceContract>)SvmxDatabase.updateRecord ( serviceContractList, false );
            } catch (SvmxSystem.SvmxNestedException ex) {
                SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
            }

            try {
                contractLineItemList = (List<ContractLineItem>)SvmxDatabase.updateRecord ( contractLineItemList, false );
            } catch (SvmxSystem.SvmxNestedException ex) {
                SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
            }

            try {
                entitlementList = (List<Entitlement>)SvmxDatabase.updateRecord ( entitlementList, false );
            } catch (SvmxSystem.SvmxNestedException ex) {
                SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
            }

            return serviceResponse;
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
            System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Failed to Cancel Service Contract for the request. Error= ' + e.getMessage() );

        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'cancelServiceContract() : Failed to Cancel Service Contract for the request. Error= ' + e.getStackTraceString() );
            serviceResponse.success = false;
            serviceResponse.message = e.getMessage();
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'cancelServiceContract() - exit; serviceResponse = ' + serviceResponse );
        }

        return serviceResponse;
    }

    private void createChildRecords (Scon.ServiceContractPlan serviceContractPlan, ServiceContract serviceContractRecord, 
                                     Common.ServiceResponse serviceResponse ) {

        System.debug( LoggingLevel.DEBUG, 'createChildRecords() - enter; serviceContractRecord= ' + serviceContractRecord );
        
        try {

            if (serviceContractPlan == null) {
                return;
            }
            List<SVMXA360__MaintenancePlanOffering__c> maintenancePlanOfferingList = new List<SVMXA360__MaintenancePlanOffering__c>();            
            String sourceError = 'Service Contract created with errors.';
            // Creating entitled service records   
            if (serviceContractPlan.entitledServicePlans != null && !serviceContractPlan.entitledServicePlans.isEmpty()) {
                createEntitledServices( serviceContractPlan, serviceContractRecord );
            }
            if( !entitledServiceMap.isEmpty() ) {
            
                for ( String entitledServicePlanId : entitledServiceMap.keySet() ) {
                    entitledServiceList.addAll(entitledServiceMap.get(entitledServicePlanId));
                }

                try {
                    entitledServiceList = (List<Entitlement>)SvmxDatabase.insertRecord ( entitledServiceList, false );
                } catch (SvmxSystem.SvmxNestedException ex) {
                    SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                }
            }
            System.debug( LoggingLevel.INFO, 'createChildRecords() : entitledServiceList= ' + entitledServiceList );

            // Prepare contract price line item records for the ServiceContract Plan.
            if( serviceContractPlan.contractPriceLineItemPlans != null && !serviceContractPlan.contractPriceLineItemPlans.isEmpty() ) {

                for( Scon.ContractPriceLineItemPlan contractPriceLineTerm : serviceContractPlan.contractPriceLineItemPlans ) {
                    contractPriceLineItemList.addAll( buildContractPriceLines( contractPriceLineTerm, new List<ServiceContract> {serviceContractRecord} ) );
                }
            }
            // Prepare contract price line item records for Entitled Service Plan.
            if( !entitledServicePlans.isEmpty() ) {
                createContractPriceLines( entitledServicePlans );
            }

            if( !contractPriceLineItemList.isEmpty() ) {
                try {
                    contractPriceLineItemList = (List<SVMXA360__ContractPriceLineItem__c>)SvmxDatabase.insertRecord ( contractPriceLineItemList, false );
                } catch (SvmxSystem.SvmxNestedException ex) {
                    SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                }
            }
            System.debug( LoggingLevel.INFO, 'createChildRecords() : Inserted contractPriceLineItemList= ' + contractPriceLineItemList );

            // Creating Maintenance Plan Offering records.
            if( serviceContractPlan.offeredMaintenancePlanTemplates != null && !serviceContractPlan.offeredMaintenancePlanTemplates.isEmpty() ) {
                maintenancePlanOfferingList.addAll( buildMaintenancePlanOfferings( serviceContractPlan.offeredMaintenancePlanTemplates, serviceContractRecord.Id ));
            }
            if( !maintenancePlanOfferingList.isEmpty() ) {
                try {
                    maintenancePlanOfferingList = (List<SVMXA360__MaintenancePlanOffering__c>) SvmxDatabase.insertRecord ( maintenancePlanOfferingList, false );
                } catch (SvmxSystem.SvmxNestedException ex) {
                    SCON_ServiceContractPlanHelper.prepareServiceResponse ( serviceResponse, ex.getDatabaseResult(), sourceError );
                }
            }

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'createChildRecords() : Failed to child records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createChildRecords() : Failed to child records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createChildRecords() - exit; serviceResponse='+serviceResponse);
        }
    }
    
    /**
     * Static method to update service contract record
     */
    public Scon.ServiceContractResponse updateContractStatus (Scon.ServiceContractDetails sconRequest) {

        ServiceContract serviceContractRecord = new ServiceContract();
        Scon.ServiceContractResponse serviceContractResponse = new Scon.ServiceContractResponse();

        try{
            
            if (sconRequest == null || sconRequest.Id == null) {
                System.debug(LoggingLevel.ERROR, 'updateContractStatus Invalid request, updateContractStatus: '+ sconRequest );
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }

            List<ServiceContract> serviceContractRecords = SvmxDatabase.query( [Select Id, SVMXA360__ContractAuthoringStatus__c, SVMXA360__StatusNotes__c, SVMXA360__CanceledOn__c from ServiceContract Where Id =: sconRequest.Id] );

            if( serviceContractRecords == null || serviceContractRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' serviceContractId= ' + sconRequest.Id );
            }

            serviceContractRecord = serviceContractRecords.get(0);
            
            serviceContractRecord.SVMXA360__ContractAuthoringStatus__c = sconRequest.authoringStatus;
            serviceContractRecord.SVMXA360__StatusNotes__c = sconRequest.statusNotes;
            serviceContractRecord.SVMXA360__CanceledOn__c = sconRequest.canceledOn;
            
            serviceContractRecord = (ServiceContract) SvmxDatabase.updateRecord( serviceContractRecord );
            
            serviceContractResponse.serviceContractRecord = serviceContractRecord;  
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceContractRecord() : Failed to getServiceContractRecord. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'getServiceContractRecord() : Failed to getServiceContractRecord. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractRecord() - exit; serviceContractRecord= ' + serviceContractRecord);
        }

        return serviceContractResponse;
    }

    public Scon.ContractLineItemResponse createCLIsForAllAsset( final Scon.ServiceContractPlan serviceContractPlan, 
                                                              final List<Asset> assetRecordList, ServiceContract serviceContractRecord, 
                                                              Map<Id,ContractLineAssetData> contractLineAssetDataMap,
                                                              ContractLineItemData contractLineItemData) {

        System.debug( LoggingLevel.DEBUG, 'createCLIsForAllAsset() - enter; assetRecordList= ' + assetRecordList);
        Scon.ContractLineItemResponse contractLineItemResponse = new Scon.ContractLineItemResponse();

        try {
            final Map<String, Scon.ContractLineItemPlan> contractLineItemPlanIdMap = new Map<String, Scon.ContractLineItemPlan>();
            Scon.ContractLineItemPlan contractLineDefinition = new Scon.ContractLineItemPlan();
            Set<String> qualifyingDefinitionIds = new Set<String>();

            if( assetRecordList == null || assetRecordList.isEmpty() ) { 
                System.debug( LoggingLevel.WARN, 'createCLIsForAllAsset() : No Contract Line Items records created.');
                return contractLineItemResponse;
            }

            if ( serviceContractPlan?.contractLineItemPlans != null && serviceContractPlan.contractLineItemPlans.size() > 0 ) {
                for( Scon.ContractLineItemPlan cliPlan : serviceContractPlan.contractLineItemPlans ) {

                    if (contractLineItemData.servicePlanProductId == cliPlan.productId) {
                        contractLineDefinition = cliPlan;
                        qualifyingDefinitionIds.add(cliPlan.Id);
                        contractLineItemPlanIdMap.put(cliPlan.Id,cliPlan);
                        break;
                    }
                }
            }
            final Set<String> uniqueProductSet = new Set<String>();
            for( Asset assetRecord : assetRecordList ) {
                uniqueProductSet.add(assetRecord.Product2Id);
            }

            Map<String, PricebookEntry> pricebookEntryMap = SCON_ServiceContractPlanHelper.getPricebookEntryMap( new List<Scon.ServiceContractPlan>{serviceContractPlan} , uniqueProductSet, serviceContractRecord );
            List<ContractLineItem> contractLineItemList = new List<ContractLineItem>();

            Map<String, Schema.SObjectField> contractLineFieldResultMap = new Map<String, Schema.SObjectField>();
            
            if ( contractLineAssetDataMap != null && !contractLineAssetDataMap.isEmpty() ) {
                contractLineFieldResultMap = describeManager.getObjectFieldMap( 'ContractLineItem' );
            }

            for( Asset assetRecord : assetRecordList ) {

                if( !pricebookEntryMap.containsKey(assetRecord.Product2Id) ) {
                    System.debug( LoggingLevel.WARN, 'PricebookEntry for the Product is not available in pricebook of ServiceContract= ' + assetRecord.Product2Id );

                    throw new SvmxSystem.SvmxNestedException( String.format(
                        System.Label.Error_PriceBookEntryNotAvailable,
                        new List<String> {
                            contractLineItemData.serviceContractId,
                            serviceContractRecord.Pricebook2.Name,
                            assetRecord.Id
                        }
                    ));
                }

                ContractLineAssetData contractLineAssetRequest;
                if ( contractLineAssetDataMap != null && !contractLineAssetDataMap.isEmpty() && contractLineAssetDataMap.containsKey(assetRecord.Id) ) {
                    contractLineAssetRequest = contractLineAssetDataMap.get(assetRecord.Id);
                }

                final ContractLineItem contractLineItemRecord = SCON_ServiceContractPlanHelper.buildContractLineItem( assetRecord, contractLineDefinition, serviceContractRecord, contractLineAssetRequest, contractLineFieldResultMap );
                
                if ( contractLineAssetRequest != null && contractLineAssetRequest.pricebookEntryId != null ) {
                    contractLineItemRecord.PricebookEntryId = contractLineAssetRequest.pricebookEntryId;
                } else {
                    contractLineItemRecord.PricebookEntryId = pricebookEntryMap.get(assetRecord.Product2Id).Id;
                }

                contractLineItemRecord.UnitPrice = pricebookEntryMap.get(assetRecord.Product2Id).UnitPrice;
                contractLineItemList.add(contractLineItemRecord);
                if( !contractLineItemMap.containsKey(contractLineDefinition.Id) ) {
                    contractLineItemMap.put( contractLineDefinition.Id, new List<ContractLineItem>() );
                }

                contractLineItemMap.get(contractLineDefinition.Id).add(contractLineItemRecord);
            }
            if( !contractLineItemList.isEmpty() ) {
                contractLineItemResponse.contractLineItemList = contractLineItemList;
                contractLineItemResponse.qualifyingDefinitionIds = qualifyingDefinitionIds;
                contractLineItemResponse.contractLineItemPlanIdMap = contractLineItemPlanIdMap;
            }
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {

            System.debug( LoggingLevel.ERROR, 'createCLIsForAllAsset() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {

            System.debug( LoggingLevel.ERROR, 'createCLIsForAllAsset() : Failed to create Contract Line Item records. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'createCLIsForAllAsset() - exit; contractLineItemResponse= ' + contractLineItemResponse);
        }

        return contractLineItemResponse;
    }

}