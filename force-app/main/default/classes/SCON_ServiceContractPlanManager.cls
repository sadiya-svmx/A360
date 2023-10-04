/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class implements methods to retrieve and save service contract plans. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       01 Apr 2021     Created.
 *              Sandeep Dhariwal        03 Feb 2022     A360AM-1667
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class SCON_ServiceContractPlanManager {

    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final SCON_ServiceContractPlanManager instance = new SCON_ServiceContractPlanManager();
    
    /**
     * Public static const instance to hold Amount string value.
     */
    public static final String StringAmount = 'Amount';

    private static final Set<String> ServiceContractPlanFields = new Set<String>{
        'Id',
        'Name',
        'LastModifiedDate',
        'LastModifiedBy.Name',
        'SVMXA360__ContractTermDuration__c',
        'SVMXA360__ContractTermUnitOfTime__c',
        'SVMXA360__Description__c',
        'SVMXA360__IsActive__c',
        'SVMXA360__PriceBookId__c',
        'SVMXA360__SpecialTerms__c'
    };

    private static final Set<String> ContractPriceLineItemPlanFields = new Set<String>{
        'Id',
        'Name',
        'LastModifiedDate',
        'LastModifiedBy.Name',
        'SVMXA360__ContractLineItemPlanId__c',
        'SVMXA360__ContractLineItemPlanId__r.Name',
        'SVMXA360__EntitledDiscount__c',
        'SVMXA360__EntitledPrice__c',
        'SVMXA360__EntitledServicePlanId__c',
        'SVMXA360__EntitledServicePlanId__r.Name',
        'SVMXA360__ExpenseItem__c',
        'SVMXA360__LineType__c',
        'SVMXA360__ProductId__c',
        'SVMXA360__ProductId__r.Name',
        'SVMXA360__ProductFamily__c',
        'SVMXA360__ServiceContractPlanId__c',
        'SVMXA360__ServiceContractPlanId__r.Name',
        'SVMXA360__Surcharge__c',
        'SVMXA360__UniqueKey__c',
        'SVMXA360__LineLevel__c'
    };
    
    /**
     * Public method to retrieve instance of this class.
     */
    public static SCON_ServiceContractPlanManager getInstance() {
        return instance;
    }
    
    /**
     * This method is used to retrieve all service contract plans with only 
     * header level informations.
     */
    public List<Scon.ServiceContractPlan> getAllServiceContractPlans() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllServiceContractPlans() - enter' );
        
        List<Scon.ServiceContractPlan> serviceContractPlanList = new List<Scon.ServiceContractPlan>();
        
        try {
            List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = getAllServiceContractPlanRecords();
            serviceContractPlanList = buildServiceContractPlans(serviceContractPlanRecords);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceContractPlans() : Failed to retrieve Service Contract plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceContractPlans() : Failed to retrieve Service Contract plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllServiceContractPlans() - exit; serviceContractPlanList= ' + serviceContractPlanList );
        }
        
        return serviceContractPlanList;
    }

    /**
     * This method is used to retrieve service contract plans for requested id.
     */
    public Scon.ServiceContractPlan getServiceContractPlanWithDetails( final String serviceContractPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanWithDetails() - enter; serviceContractPlanId= ' + serviceContractPlanId);
        
        Scon.ServiceContractPlan serviceContractPlan = new Scon.ServiceContractPlan();
        
        try {
            
            if( String.isBlank(serviceContractPlanId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanId= ' + serviceContractPlanId );
            }
            
            Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap = getServiceContractPlanWithDetails(new List<String>{serviceContractPlanId},serviceContractPlanId);
            serviceContractPlan = serviceContractPlanMap.get(serviceContractPlanId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanWithDetails() : Failed to retrieve Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanWithDetails() : Failed to retrieve Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanWithDetails() - exit; serviceContractPlan= ' + serviceContractPlan);
        }
        
        return serviceContractPlan;
    }

    /**
     * This method is used to retrieve service contract plans for requested id.
     */
    public Map<Id,Scon.ServiceContractPlan> getServiceContractPlanWithDetails( final List<String> serviceContractPlanIds, 
                                                                               final String primaryServiceContractPlanId) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanWithDetails() - enter; serviceContractPlanIds= ' + serviceContractPlanIds);
        
        Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap = new Map<Id, Scon.ServiceContractPlan>();
        
        try {
            
            if( serviceContractPlanIds.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanIds= ' + serviceContractPlanIds );
            }
            serviceContractPlanIds.add(primaryServiceContractPlanId);
            final List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = getServiceContractPlanRecords( serviceContractPlanIds );
            Scon.ServiceContractPlan serviceContractPlan;
            List<Scon.ContractLineItemPlan> contractLineItemPlanList = new List<Scon.ContractLineItemPlan>();
            Set<String> masterRecordIds = new Set<String>();
            Map<String,Scon.ContractLineItemPlan> contractLineItemPlanMap = new Map<String,Scon.ContractLineItemPlan>();
            Scon.ContractLineItemPlan contractLineItemPlan;
            List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList;
            Scon.OfferedMaintenancePlanTemplate offeredMPT;

            for ( SVMXA360__ServiceContractPlan__c serviceContractPlanRecord : serviceContractPlanRecords ) {

                serviceContractPlan = buildServiceContractPlan(serviceContractPlanRecord);
                contractLineItemPlanList = new List<Scon.ContractLineItemPlan>();
                offeredMPTList = new List<Scon.OfferedMaintenancePlanTemplate>();
                masterRecordIds.add(serviceContractPlanRecord.Id);

                for( SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord : serviceContractPlanRecord.Contract_Line_Item_Plans__r ) {
                    contractLineItemPlan = buildContractLineItemPlan(contractLineItemPlanRecord);
                    contractLineItemPlanList.add( contractLineItemPlan );
                    masterRecordIds.add(contractLineItemPlanRecord.Id);
                    contractLineItemPlanMap.put( contractLineItemPlan.id, contractLineItemPlan);
                }

                for( SVMXA360__OfferedMaintenancePlanTemplate__c offeredMPTRecord : serviceContractPlanRecord.Offered_Maintenance_Plan_Templates__r ) {
                    offeredMPT = buildOfferedMPT( offeredMPTRecord );
                    offeredMPTList.add( offeredMPT );
                }
                
                serviceContractPlan.offeredMaintenancePlanTemplates = offeredMPTList;
                serviceContractPlan.contractLineItemPlans = contractLineItemPlanList;
                serviceContractPlanMap.put(serviceContractPlan.id, serviceContractPlan);
            }

            final List<Scon.EntitledServicePlan> entitledServicePlanList = getEntitledServicePlans( new List<String>(masterRecordIds) );
            final Map<String,Scon.EntitledServicePlan> entitledServicePlanMap = new Map<String,Scon.EntitledServicePlan>();
            for( Scon.EntitledServicePlan entitledServicePlan : entitledServicePlanList ) {
                
                if( entitledServicePlan.contractLineItemPlanId == null ) {
                    
                    serviceContractPlan = serviceContractPlanMap.get(entitledServicePlan.serviceContractPlanId);

                    if( serviceContractPlan.entitledServicePlans == null ) {
                        serviceContractPlan.entitledServicePlans = new List<Scon.EntitledServicePlan>();
                    }
                    
                    serviceContractPlan.entitledServicePlans.add(entitledServicePlan);
                } else {
                    
                    contractLineItemPlan = contractLineItemPlanMap.get( entitledServicePlan.contractLineItemPlanId );
                    if( contractLineItemPlan.entitledServicePlans == null ) {
                        contractLineItemPlan.entitledServicePlans = new List<Scon.EntitledServicePlan>();
                    }
                    contractLineItemPlan.entitledServicePlans.add(entitledServicePlan);
                }
                masterRecordIds.add(entitledServicePlan.id);
                entitledServicePlanMap.put( entitledServicePlan.id, entitledServicePlan );
            }
            
            final List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = getContractPriceLineItemPlans( new List<String>(masterRecordIds) );
            
            for( Scon.ContractPriceLineItemPlan contractPriceLineItemPlan : contractPriceLineItemPlanList ) {
                
                if( contractPriceLineItemPlan.entitledServicePlanId != null ) {
                    
                    final Scon.EntitledServicePlan entitledServicePlan = entitledServicePlanMap.get( contractPriceLineItemPlan.entitledServicePlanId );
                    if( entitledServicePlan.contractPriceLineItemPlans == null ) {
                        entitledServicePlan.contractPriceLineItemPlans = new List<Scon.ContractPriceLineItemPlan>();
                    }
                    
                    entitledServicePlan.contractPriceLineItemPlans.add(contractPriceLineItemPlan);
                } else if( contractPriceLineItemPlan.contractLineItemPlanId != null ) {
                    
                    contractLineItemPlan = contractLineItemPlanMap.get( contractPriceLineItemPlan.contractLineItemPlanId );
                    if( contractLineItemPlan.contractPriceLineItemPlans == null ) {
                        contractLineItemPlan.contractPriceLineItemPlans = new List<Scon.ContractPriceLineItemPlan>();
                    }
                    contractLineItemPlan.contractPriceLineItemPlans.add(contractPriceLineItemPlan);
                } else {
                    
                    serviceContractPlan = serviceContractPlanMap.get(contractPriceLineItemPlan.serviceContractPlanId);

                    if( serviceContractPlan.contractPriceLineItemPlans == null ) {
                        serviceContractPlan.contractPriceLineItemPlans = new List<Scon.ContractPriceLineItemPlan>();
                    }
                    
                    serviceContractPlan.contractPriceLineItemPlans.add(contractPriceLineItemPlan);
                }
            }

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanWithDetails() : Failed to retrieve Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanWithDetails() : Failed to retrieve Service Contract Plan. Error= ' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanWithDetails() - exit; serviceContractPlanMap= ' +  serviceContractPlanMap);
        }
        
        return serviceContractPlanMap;
    }
    
    /**
     * This method is used to retrieve service contract plans for requested id.
     */
    public Scon.ServiceContractPlan getServiceContractPlan( final String serviceContractPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlan() - enter' );
        
        Scon.ServiceContractPlan serviceContractPlan = new Scon.ServiceContractPlan();
        
        try {
            
            if( String.isBlank(serviceContractPlanId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanId= ' + serviceContractPlanId );
            }
            
            Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap = getServiceContractPlans( new List<String>{serviceContractPlanId} );
            serviceContractPlan = serviceContractPlanMap.get(serviceContractPlanId);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlan() : Failed to retrieve Service Contract plan. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlan() : Failed to retrieve Service Contract plan. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlan() - exit; serviceContractPlanList= ' + serviceContractPlan );
        }
        
        return serviceContractPlan;
    }

    /**
     * This method is used to retrieve service contract plans for requested ids.
     */
    public Map<Id, Scon.ServiceContractPlan> getServiceContractPlans( final List<String> serviceContractPlanIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlans() - enter' );
        
        Map<Id, Scon.ServiceContractPlan> serviceContractPlanMap = new Map<Id, Scon.ServiceContractPlan>();
        
        try {
            
            if( serviceContractPlanIds.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanIds= ' + serviceContractPlanIds );
            }
            
            final List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = getServiceContractPlanRecords( serviceContractPlanIds );
            
            for ( SVMXA360__ServiceContractPlan__c serviceContractPlanRecord : serviceContractPlanRecords ) {
                serviceContractPlanMap.put(serviceContractPlanRecord.Id, buildServiceContractPlan(serviceContractPlanRecord));
            }
        
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlans() : Failed to retrieve Service Contract plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlans() : Failed to retrieve Service Contract plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlans() - exit; serviceContractPlanMap= ' + serviceContractPlanMap );
        }
        
        return serviceContractPlanMap;
    }

    /**
     * Retrieve Service Contract Plan record.
     */
    private List<SVMXA360__ServiceContractPlan__c> getServiceContractPlanRecords( final List<String> serviceContractPlanIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecords() - enter' );
        
        List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = new List<SVMXA360__ServiceContractPlan__c>();
        
        try {

            if( UserInfo.isMultiCurrencyOrganization() ) {
                ServiceContractPlanFields.add('CurrencyIsoCode');
            }

            serviceContractPlanRecords = SvmxDatabase.query( Database.query( 'SELECT ' + String.join(new List<String>(ServiceContractPlanFields), ',') + 
                                        ' ,(SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ServiceContractPlanId__c, SVMXA360__ServiceContractPlanId__r.Name, SVMXA360__ContractLineDuration__c, SVMXA360__ContractLineUnitOfTime__c, SVMXA360__Discount__c, SVMXA360__ProductId__c, SVMXA360__ProductId__r.Name, SVMXA360__ProductFamily__c FROM Contract_Line_Item_Plans__r)' +
                                        ', (SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ServiceContractPlanId__c, SVMXA360__ServiceContractPlanId__r.Name, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name, SVMXA360__MaintenancePlanTemplateId__r.SVMXA360__Description__c, SVMXA360__MaintenancePlanTemplateId__r.SVMXA360__IsActive__c FROM Offered_Maintenance_Plan_Templates__r) FROM SVMXA360__ServiceContractPlan__c WHERE Id  IN :serviceContractPlanIds' ) );
               
            if( serviceContractPlanRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' serviceContractPlanIds= ' + serviceContractPlanIds );
            }
            
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecords() - serviceContractPlanRecords='+serviceContractPlanRecords );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecords() - exit' );
        }
        
        return serviceContractPlanRecords;
    }
    
    /**
     * This method is used to retrieve all Applicable Contract Line Products with only header details for 
     * requested service contract plan.
     */
    public List<Scon.ContractLineItemPlan> getContractLineItemPlans( final String serviceContractPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlans() - enter; serviceContractPlanId= ' + serviceContractPlanId );
        
        List<Scon.ContractLineItemPlan> contractLineDefinitionList = new List<Scon.ContractLineItemPlan>();
        
        try {
            
            if( String.isBlank(serviceContractPlanId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanId= ' + serviceContractPlanId );
            }
            contractLineDefinitionList = buildContractLineItemPlans( getContractLineItemPlanRecords( new List<String>{serviceContractPlanId} ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlans() : Failed to retrieve Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlans() : Failed to retrieve Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlans() - exit; contractLineDefinitionList= ' + contractLineDefinitionList );
        }
        
        return contractLineDefinitionList;
    }

    /**
     * This method is used to retrieve all Applicable Contract Line Products with only header details for 
     * requested service contract plan.
     */
    public List<Scon.ContractLineItemPlan> getContractLineItemPlans( final List<String> serviceContractPlanIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlans() - enter; serviceContractPlanIds= ' + serviceContractPlanIds );
        
        List<Scon.ContractLineItemPlan> contractLineDefinitionList = new List<Scon.ContractLineItemPlan>();
        
        try {
            
            if( !serviceContractPlanIds.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanIds= ' + serviceContractPlanIds );
            }
            contractLineDefinitionList = buildContractLineItemPlans( getContractLineItemPlanRecords( serviceContractPlanIds ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlans() : Failed to retrieve Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlans() : Failed to retrieve Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlans() - exit; contractLineDefinitionList= ' + contractLineDefinitionList );
        }
        
        return contractLineDefinitionList;
    }
    
    /**
     * This method is used to retrieve entitled service plans for requested parent id. 
     * One of service contract or contract line item ids.
     */
    public List<Scon.EntitledServicePlan> getEntitledServicePlans( final String masterRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlans() - enter; masterRecordId= ' + masterRecordId );
        
        List<Scon.EntitledServicePlan> entitledServicePlanList = new List<Scon.EntitledServicePlan>();
        
        try {
            
            if( String.isBlank(masterRecordId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' masterRecordId= ' + masterRecordId );
            }
            
            entitledServicePlanList = getEntitledServicePlans( new List<String> {masterRecordId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlans() : Failed to retrieve Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlans() : Failed to retrieve Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlans() - exit; entitledServicePlanList= ' + entitledServicePlanList );
        }
        
        return entitledServicePlanList;
    }
    
    /**
     * This method is used to retrieve entitled service plans for requested list of parent ids.
     * It could be combination of service contract and contract line item ids.
     */
    public List<Scon.EntitledServicePlan> getEntitledServicePlans( final List<String> masterRecordIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlans() - enter; masterRecordIds= ' + masterRecordIds );
        
        List<Scon.EntitledServicePlan> entitledServicePlanList = new List<Scon.EntitledServicePlan>();
        
        try {
            
            if( masterRecordIds == null || masterRecordIds.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' masterRecordIds= ' + masterRecordIds );
            }
            
            entitledServicePlanList = buildEntitledServicePlans( getEntitledServicePlanRecords( masterRecordIds ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlans() : Failed to retrieve Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlans() : Failed to retrieve Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlans() - exit; entitledServicePlanList= ' + entitledServicePlanList );
        }
        
        return entitledServicePlanList;
    }
    
    /**
     * This method is used to retrieve Contract Price Line Item Plans for requested parent id.
     * The id would be one of service contract, Contract Line Item or Entitled service plan Ids.
     */
    public List<Scon.ContractPriceLineItemPlan> getContractPriceLineItemPlans( final String masterRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlans() - enter; masterRecordId= ' + masterRecordId );
        
        List<Scon.ContractPriceLineItemPlan> contractPriceLinePlanItemList = new List<Scon.ContractPriceLineItemPlan>();
        
        try {
            
            if( String.isBlank(masterRecordId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' masterRecordId= ' + masterRecordId );
            }
            
            contractPriceLinePlanItemList = getContractPriceLineItemPlans( new List<String>{masterRecordId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlans() : Failed to retrieve Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlans() : Failed to retrieve Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlans() - exit; contractPriceLinePlanItemList= ' + contractPriceLinePlanItemList );
        }
        
        return contractPriceLinePlanItemList;
    }
    
    /**
     * This method is used to retrieve contract price line item plans for requested parent ids.
     */
    public List<Scon.ContractPriceLineItemPlan> getContractPriceLineItemPlans( final List<String> masterRecordIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlans() - enter; masterRecordIds= ' + masterRecordIds );
        
        List<Scon.ContractPriceLineItemPlan> contractPriceLinePlanItemList = new List<Scon.ContractPriceLineItemPlan>();
        
        try {
            
            if( masterRecordIds == null || masterRecordIds.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' masterRecordIds= ' + masterRecordIds );
            }
            
            contractPriceLinePlanItemList = buildContractPriceLineItemPlans( getContractPriceLineItemPlanRecords( masterRecordIds ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlans() : Failed to retrieve Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlans() : Failed to retrieve Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlans() - exit; contractPriceLinePlanItemList= ' + contractPriceLinePlanItemList );
        }
        
        return contractPriceLinePlanItemList;
    }

    /**
     * This method is used to retrieve all offered maintenance plan templates with only header details for 
     * requested service contract plan.
     * MPT  - Maintenance Plan Template
     */
    public List<Scon.OfferedMaintenancePlanTemplate> getOfferedMPTs( final String serviceContractPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getOfferedMPTs() - enter; serviceContractPlanId= ' + serviceContractPlanId );
        
        List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = new List<Scon.OfferedMaintenancePlanTemplate>();
        
        try {
            
            if( String.isBlank(serviceContractPlanId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractPlanId= ' + serviceContractPlanId );
            }
            offeredMPTList = buildOfferedMPTs( getOfferedMPTRecords( serviceContractPlanId ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getOfferedMPTs() : Failed to retrieve Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getOfferedMPTs() : Failed to retrieve Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getOfferedMPTs() - exit; offeredMPTList= ' + offeredMPTList );
        }
        
        return offeredMPTList;
    }

    /**
     * This method is used to retrieve Applicable Contract Line Product records for requested service contract plan Id.
     */
    private List<SVMXA360__OfferedMaintenancePlanTemplate__c> getOfferedMPTRecords( final String serviceContractPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getOfferedMPTRecords() - enter' );
        
        List<SVMXA360__OfferedMaintenancePlanTemplate__c> offeredMPTRecords = new List<SVMXA360__OfferedMaintenancePlanTemplate__c>();
        
        try {
            offeredMPTRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ServiceContractPlanId__c, SVMXA360__ServiceContractPlanId__r.Name, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name, SVMXA360__MaintenancePlanTemplateId__r.SVMXA360__Description__c, SVMXA360__MaintenancePlanTemplateId__r.SVMXA360__IsActive__c FROM SVMXA360__OfferedMaintenancePlanTemplate__c WHERE SVMXA360__ServiceContractPlanId__c = :serviceContractPlanId Order By CreatedDate DESC]);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getOfferedMPTRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getOfferedMPTRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getOfferedMPTRecords() - exit' );
        }
        
        return offeredMPTRecords;
    }

    private List<Scon.OfferedMaintenancePlanTemplate> buildOfferedMPTs( final List<SVMXA360__OfferedMaintenancePlanTemplate__c> offeredMPTRecords ) {
        
        final List<Scon.OfferedMaintenancePlanTemplate> offeredMPTList = new List<Scon.OfferedMaintenancePlanTemplate>();
        if( offeredMPTRecords != null && !offeredMPTRecords.isEmpty() ) {
            
            for( SVMXA360__OfferedMaintenancePlanTemplate__c offeredMPTRecord : offeredMPTRecords ) {
                offeredMPTList.add( buildOfferedMPT(offeredMPTRecord) );
            }
        }
        
        return offeredMPTList;
    }

    private Scon.OfferedMaintenancePlanTemplate buildOfferedMPT( final SVMXA360__OfferedMaintenancePlanTemplate__c offeredMPTRecord ) {
        
        final Scon.OfferedMaintenancePlanTemplate offeredMPT = new Scon.OfferedMaintenancePlanTemplate();
        offeredMPT.id = offeredMPTRecord.Id;
        offeredMPT.name = offeredMPTRecord.Name;
        offeredMPT.serviceContractPlanId = offeredMPTRecord.SVMXA360__ServiceContractPlanId__c;
        offeredMPT.serviceContractPlanName = offeredMPTRecord.SVMXA360__ServiceContractPlanId__r.Name;
        offeredMPT.maintenancePlanTemplateId = offeredMPTRecord.SVMXA360__MaintenancePlanTemplateId__c;
        offeredMPT.maintenancePlanTemplateName = offeredMPTRecord.SVMXA360__MaintenancePlanTemplateId__r.Name;
        offeredMPT.description = offeredMPTRecord.SVMXA360__MaintenancePlanTemplateId__r.SVMXA360__Description__c;
        offeredMPT.isActive = offeredMPTRecord.SVMXA360__MaintenancePlanTemplateId__r.SVMXA360__IsActive__c;
        offeredMPT.lastModifiedDate = offeredMPTRecord.LastModifiedDate;
        offeredMPT.lastModifiedBy = offeredMPTRecord.LastModifiedBy.Name;
        
        return offeredMPT;
    }

    /**
     * This method is used to save list of Offered Maintenance Template Plans.
     */
    public List<Scon.OfferedMaintenancePlanTemplate> saveOfferedMPTs( final List<Scon.OfferedMaintenancePlanTemplate> offeredMPTs ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveOfferedMPTs() - enter; offeredMPTs= ' + offeredMPTs );
        
        try {
            if( offeredMPTs == null ||  offeredMPTs.isEmpty()) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' offeredMPTs= ' + offeredMPTs );
            }
            
            //Verify the new MPTs are already linked or not
            preventDuplicateMPTs (offeredMPTs);

            List<SVMXA360__OfferedMaintenancePlanTemplate__c> offeredMPTRecords = buildofferedMPTRecords(offeredMPTs);
            
            offeredMPTRecords = SvmxDatabase.upsertRecord(offeredMPTRecords);
            
            for( Integer index = 0; index < offeredMPTRecords.size(); index++ ) {
                offeredMPTs.get(index).id = offeredMPTRecords.get(index).id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveOfferedMPTs() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveOfferedMPTs() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveOfferedMPTs() - exit; offeredMPTs= ' + offeredMPTs );
        }
        
        return offeredMPTs;
    }

    private List<SVMXA360__OfferedMaintenancePlanTemplate__c> buildofferedMPTRecords( final List<Scon.OfferedMaintenancePlanTemplate> offeredMPTs ) {
        
        final List<SVMXA360__OfferedMaintenancePlanTemplate__c> offeredMPTRecords = new List<SVMXA360__OfferedMaintenancePlanTemplate__c>();
        for( Scon.OfferedMaintenancePlanTemplate offeredMPT : offeredMPTs ) {
            offeredMPTRecords.add( buildofferedMPTRecord(offeredMPT) );
        }
        
        return offeredMPTRecords;
    }

    private SVMXA360__OfferedMaintenancePlanTemplate__c buildofferedMPTRecord( final Scon.OfferedMaintenancePlanTemplate offeredMPT ) {
        
        if( offeredMPT.serviceContractPlanId == null || offeredMPT.maintenancePlanTemplateId == null) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        final SVMXA360__OfferedMaintenancePlanTemplate__c offeredMPTRecord = new SVMXA360__OfferedMaintenancePlanTemplate__c();
        
        if( offeredMPT.id != null ) {
            offeredMPTRecord.id = offeredMPT.id;
        } else {
            offeredMPTRecord.SVMXA360__ServiceContractPlanId__c = offeredMPT.serviceContractPlanId;
        }
        
        offeredMPTRecord.SVMXA360__MaintenancePlanTemplateId__c = offeredMPT.maintenancePlanTemplateId;
                
        return offeredMPTRecord;
    }

    private void preventDuplicateMPTs (final List<Scon.OfferedMaintenancePlanTemplate> offeredMPTs) {

        System.debug( LoggingLevel.DEBUG, 'preventDuplicateMPTs() - enter; offeredMPTs= ' + offeredMPTs );

        Set<Id> mptIdSet = new Set<Id>();
        Set<Id> sconPlanIdSet = new Set<Id>();
        List<String> listOfAddedMPTNames = new List<String>();

        for(Scon.OfferedMaintenancePlanTemplate newOfferedMPT : offeredMPTs) {
            if (newOfferedMPT.maintenancePlanTemplateId != null) {
                mptIdSet.add(newOfferedMPT.maintenancePlanTemplateId);
            }
            if (newOfferedMPT.serviceContractPlanId != null) {
                sconPlanIdSet.add(newOfferedMPT.serviceContractPlanId);
            }
        }

        for(SVMXA360__OfferedMaintenancePlanTemplate__c eachLinkedMPT : (List<SVMXA360__OfferedMaintenancePlanTemplate__c>) SvmxDatabase.query([Select Id, Name, SVMXA360__MaintenancePlanTemplateId__c, SVMXA360__MaintenancePlanTemplateId__r.Name FROM SVMXA360__OfferedMaintenancePlanTemplate__c Where SVMXA360__MaintenancePlanTemplateId__c IN:mptIdSet AND SVMXA360__ServiceContractPlanId__c IN:sconPlanIdSet])) {
            listOfAddedMPTNames.add(eachLinkedMPT.SVMXA360__MaintenancePlanTemplateId__r.Name);
        }
        
        if(listOfAddedMPTNames!=null && !listOfAddedMPTNames.isEmpty()) {
            String errorMessage = String.format(System.Label.Label_OfferedMPTErrorMessage, new List<String>{String.join(listOfAddedMPTNames,',')});
            throw new SvmxSystem.SvmxNestedException(errorMessage);
        }
    }

    /**
     * This method is used to delete offered Maintenance Plan Template for requested id.
     */
    public void deleteOfferedMPT( final String offeredMPTId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteOfferedMPT() - enter; offeredMPTId= ' + offeredMPTId );
        
        try {
            
            if( String.isBlank(offeredMPTId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' offeredMPTId= ' + offeredMPTId );
            }
            
            deleteOfferedMPTs( new List<String>{offeredMPTId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteOfferedMPT() : Failed to delete offered Maintenance Plan Template. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteOfferedMPT() : Failed to delete offered Maintenance Plan Template. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteOfferedMPT() - exit' );
        }
    }
    
    /**
     * This method is used to delete offered Maintenance Plan Templates for requested list of ids.
     */
    public void deleteOfferedMPTs( final List<String> offeredMPTIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteOfferedMPTs() - enter; offeredMPTIdList= ' + offeredMPTIdList );
        
        try {
            
            if( offeredMPTIdList == null || offeredMPTIdList.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' offeredMPTIdList= ' + offeredMPTIdList );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__OfferedMaintenancePlanTemplate__c WHERE Id IN :offeredMPTIdList ] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteOfferedMPTs() : Failed to delete offered Maintenance Plan Templates. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteOfferedMPTs() : Failed to delete offered Maintenance Plan Templates. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteOfferedMPTs() - exit' );
        }
    }

    /**
     * This method is used to retrieve all asset records for the given searchkeyword and account(one level child accounts) 
     */
    public List<Asset> getAssetList( final Id accountId, final String searchKeyword, List<String> loadedRowsIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getAssetList() - enter; searchKeyword= ' + searchKeyword +', accountId = '+accountId );
        
        List<Asset> assetList = new List<Asset>();
        try {
            
            if( String.isBlank(searchKeyword) || String.isBlank(accountId)) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' searchKeyword= ' + searchKeyword+' accountId= ' + accountId );
            }
            Set<Id> accountIdSet = getChildAccountIds (accountId);
            loadedRowsIds = ( loadedRowsIds == null || loadedRowsIds.isEmpty()) ? new List<String>() : loadedRowsIds;
            assetList = getAssets( searchKeyword, accountIdSet, loadedRowsIds );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssetList() : Failed to retrieve Asset records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAssetList() : Failed to retrieve Asset records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetList() - exit; assetList= ' + assetList );
        }
        
        return assetList;
    }

    /**
     * This method is used to retrieve all SCON Logs for the given service Contract Id.
     */
    public List<SVMXA360__SCONAuthoringLog__c> getSCONAuthoringLogs( final String sourceRecordId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getSCONAuthoringLogs() - enter; sourceRecordId= ' + sourceRecordId );
        
        List<SVMXA360__SCONAuthoringLog__c> sconAuthoringLogRecords = new List<SVMXA360__SCONAuthoringLog__c>();
        try {
            
            if( String.isBlank(sourceRecordId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' sourceRecordId= ' + sourceRecordId );
            }
            sconAuthoringLogRecords = SvmxDatabase.query([SELECT Id,Name, SVMXA360__Status__c,SVMXA360__LogType__c, SVMXA360__TotalBatchesCompleted__c, SVMXA360__TotalNumberOfBatches__c,
                                                                                            (Select Id,Name, SVMXA360__Status__c,SVMXA360__LogType__c,SVMXA360__ServiceContractId__c,
                                                                                            SVMXA360__ServiceContractId__r.Name,SVMXA360__Message__c from SVMXA360__SCON_Authoring_Logs__r )
                                                                                            FROM SVMXA360__SCONAuthoringLog__c where Id =:sourceRecordId AND SVMXA360__LogType__c='Master']);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSCONAuthoringLogs() : Failed to retrieve SCON Logs records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getSCONAuthoringLogs() : Failed to retrieve SCON Logs records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getSCONAuthoringLogs() - exit;  ' );
        }
        
        return sconAuthoringLogRecords;
    }

    private Set<Id> getChildAccountIds( String  accountId) {

        if( String.isBlank(accountId)) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }

        Set<Id> accountIds = new Set<Id>();

        for(Account eachAccount : (List<Account>) SvmxDatabase.query([Select Id, Name, (Select Id,Name from ChildAccounts) FROM Account Where Id=: accountId])) {
            accountIds.add(eachAccount.Id);
            for(Account eachChildAccount: eachAccount.ChildAccounts) {
                accountIds.add(eachChildAccount.Id);
            }
        }
        System.debug( LoggingLevel.DEBUG, 'getChildAccountIds() - exit; accountIds= ' + accountIds );

        return accountIds;
    }

    private List<Asset> getAssets( String searchKeyword , Set<Id> accountIdSet, List<String> loadedRowsIds) {

        System.debug( LoggingLevel.DEBUG, 'getAssets() - enter; searchKeyword= ' + searchKeyword + ',accountIdSet=' +accountIdSet);

        if( String.isBlank(searchKeyword) || accountIdSet == null || accountIdSet.isEmpty()) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }

        List<Asset> assetRecords = new List<Asset>();
        searchKeyword = '%' + String.escapeSingleQuotes(searchKeyword) + '%';
        assetRecords = SvmxDatabase.query([SELECT Id, Name, AccountId, Account.Name, toLabel(Status), SerialNumber FROM Asset WHERE Id NOT IN: loadedRowsIds AND AccountId IN: accountIdSet AND (Name LIKE: searchKeyword OR SerialNumber LIKE: searchKeyword) ORDER BY Name ]);

        System.debug( LoggingLevel.DEBUG, 'getAssets() - exit; assetRecords= ' + assetRecords );

        return assetRecords;
    }
    
    /**
     * This method is used to save Entitled service plan for Service Contract or Applicable Contract Line Product.
     */
    public Scon.ContractLineItemPlan saveContractLineItemPlan( final Scon.ContractLineItemPlan contractLineItemPlan ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractLineItemPlan() - enter; contractLineItemPlan= ' + contractLineItemPlan );
        
        try {
            
            if( contractLineItemPlan == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractLineItemPlan= ' + contractLineItemPlan );
            }
            
            saveContractLineItemPlans( new List<Scon.ContractLineItemPlan> {contractLineItemPlan} ).get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItemPlan() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItemPlan() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractLineItemPlan() - exit; contractLineItemPlan= ' + contractLineItemPlan );
        }
            
        return contractLineItemPlan;
    }
    
    /**
     * This method is used to save list of Entitled Service Plans.
     */
    public List<Scon.ContractLineItemPlan> saveContractLineItemPlans( final List<Scon.ContractLineItemPlan> contractLineItemPlans ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractLineItemPlans() - enter; contractLineItemPlans= ' + contractLineItemPlans );
        
        try {
            if( contractLineItemPlans == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractLineItemPlans= ' + contractLineItemPlans );
            }
            
            List<SVMXA360__ContractLineItemPlan__c> contractLineItemPlanRecords = buildContractLineItemPlanRecords(contractLineItemPlans);
            
            contractLineItemPlanRecords = SvmxDatabase.upsertRecord(contractLineItemPlanRecords);
            
            for( Integer index = 0; index < contractLineItemPlanRecords.size(); index++ ) {
                contractLineItemPlans.get(index).id = contractLineItemPlanRecords.get(index).id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItemPlans() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractLineItemPlans() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractLineItemPlans() - exit; contractLineItemPlans= ' + contractLineItemPlans );
        }
        
        return contractLineItemPlans;
    }
    
    /**
     * This method is used to save Entitled service plan for Service Contract or Applicable Contract Line Product.
     */
    public Scon.EntitledServicePlan saveEntitledServicePlan( final Scon.EntitledServicePlan entitledServicePlan ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitledServicePlan() - enter; entitledServicePlan= ' + entitledServicePlan );
        
        try {
            
            if( entitledServicePlan == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' entitledServicePlan= ' + entitledServicePlan );
            }
            
            saveEntitledServicePlans( new List<Scon.EntitledServicePlan> {entitledServicePlan} ).get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledServicePlans() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledServicePlans() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitledServicePlans() - exit; entitledServicePlan= ' + entitledServicePlan );
        }
            
        return entitledServicePlan;
    }
    
    /**
     * This method is used to save list of Entitled Service Plans.
     */
    public List<Scon.EntitledServicePlan> saveEntitledServicePlans( final List<Scon.EntitledServicePlan> entitledServicePlans ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitledServicePlans() - enter; entitledServicePlans= ' + entitledServicePlans );
        
        try {
            if( entitledServicePlans == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' entitledServicePlans= ' + entitledServicePlans );
            }
            
            List<SVMXA360__EntitledServicePlan__c> entitledServicePlanRecords = buildEntitledServicePlanRecords(entitledServicePlans);
            
            entitledServicePlanRecords = SvmxDatabase.upsertRecord(entitledServicePlanRecords);
            
            for( Integer index = 0; index < entitledServicePlanRecords.size(); index++ ) {
                entitledServicePlans.get(index).id = entitledServicePlanRecords.get(index).id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledServicePlans() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveEntitledServicePlans() : Failed to save Entitled Service plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitledServicePlans() - exit; entitledServicePlans= ' + entitledServicePlans );
        }
        
        return entitledServicePlans;
    }
    
    /**
     * This method is used to save Contract Price Line Item Plan
     */
    public Scon.ContractPriceLineItemPlan saveContractPriceLineItemPlan( final Scon.ContractPriceLineItemPlan contractPriceLineItemPlan ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItemPlan() - enter; contractPriceLineItemPlan= ' + contractPriceLineItemPlan );
            
        try {
            if( contractPriceLineItemPlan == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractPriceLineItemPlan= ' + contractPriceLineItemPlan );
            }
            
            saveContractPriceLineItemPlans( new List<Scon.ContractPriceLineItemPlan> {contractPriceLineItemPlan} ).get(0);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItemPlan() : Failed to save Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItemPlan() : Failed to save Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItemPlan() - exit; contractPriceLineItemPlan= ' + contractPriceLineItemPlan );
        }
        
        return contractPriceLineItemPlan;
    }
    
    /**
     * This method is used to save Contract Price Line Item Plans
     */
    public List<Scon.ContractPriceLineItemPlan> saveContractPriceLineItemPlans( final List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlans ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItemPlans() - enter; contractPriceLineItemPlans= ' + contractPriceLineItemPlans );
        
        try {
            if( contractPriceLineItemPlans == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractPriceLineItemPlans= ' + contractPriceLineItemPlans );
            }
            
            List<SVMXA360__ContractPriceLineItemPlan__c> contractPriceLineItemPlanRecords = buildContractPriceLineItemPlanRecords(contractPriceLineItemPlans);
            
            contractPriceLineItemPlanRecords = SvmxDatabase.upsertRecord(contractPriceLineItemPlanRecords);
            
            for( Integer index = 0; index < contractPriceLineItemPlanRecords.size(); index++ ) {
                contractPriceLineItemPlans.get(index).id = contractPriceLineItemPlanRecords.get(index).id;
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItemPlans() : Failed to save Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'saveContractPriceLineItemPlans() : Failed to save Contract Price Line Item plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveContractPriceLineItemPlans() - exit; contractPriceLineItemPlans= ' + contractPriceLineItemPlans );
        }
        
        return contractPriceLineItemPlans;
    }
    
    /**
     * This method is used to delete related entitled service plans and 
     * contract price line item plans when service contract deleted.
     */
    public void handleServiceContractPlanDelete( final String serviceContractId ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleServiceContractPlanDelete() - enter; serviceContractId= ' + serviceContractId );
        
        try {
            
            if( String.isBlank(serviceContractId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractId= ' + serviceContractId );
            }
            
            handleServiceContractPlanDelete( new List<String>{serviceContractId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'handleServiceContractPlanDelete() : Failed to delete related plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'handleServiceContractPlanDelete() : Failed to delete related plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleServiceContractPlanDelete() - exit' );
        }
    }
    
    /**
     * This method is used to delete related entitled service plans and 
     * contract price line item plans when list of service contract plans deleted.
     */
    public void handleServiceContractPlanDelete( final List<String> serviceContractIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'handleServiceContractPlanDelete() - enter; serviceContractIdList= ' + serviceContractIdList );
        
        final SavePoint sPoint = Database.setSavepoint();
        
        try {
            
            if( serviceContractIdList == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' serviceContractIdList= ' + serviceContractIdList );
            }
            
            final List<SVMXA360__ContractLineItemPlan__c> contractLineItemPlans = SvmxDatabase.query( [SELECT Id FROM SVMXA360__ContractLineItemPlan__c WHERE SVMXA360__ServiceContractPlanId__c IN :serviceContractIdList] );
            final List<SVMXA360__EntitledServicePlan__c> entitledServiceRecords = SvmxDatabase.query( [SELECT Id FROM SVMXA360__EntitledServicePlan__c WHERE SVMXA360__ContractLineItemPlanId__c IN :contractLineItemPlans OR SVMXA360__ServiceContractPlanId__c IN :serviceContractIdList ] );
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__ContractPriceLineItemPlan__c WHERE SVMXA360__EntitledServicePlanId__c IN :entitledServiceRecords OR SVMXA360__ContractLineItemPlanId__c IN :contractLineItemPlans OR SVMXA360__ServiceContractPlanId__c IN :serviceContractIdList] );
            SvmxDatabase.deleteRecord( entitledServiceRecords );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'handleServiceContractPlanDelete() : Failed to delete related plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'handleServiceContractPlanDelete() : Failed to delete related plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'handleServiceContractPlanDelete() - exit' );
        }
    }
    
    /**
     * This method is used to delete related entitled service plans and 
     * Applicable Contract Line Products when Applicable Contract Line Product deleted.
     */
    public void deleteContractLineItemPlan( final String contractLineItemId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractLineItemPlan() - enter; contractLineItemId= ' + contractLineItemId );

        try {
            
            if( String.isBlank(contractLineItemId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractLineItemId= ' + contractLineItemId );
            }
            
            deleteContractLineItemPlans( new List<String>{contractLineItemId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractLineItemPlan() : Failed to delete Applicable Contract Line Product. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractLineItemPlan() : Failed to delete Applicable Contract Line Product. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractLineItemPlan() - exit' );
        }
        
    }
    
    /**
     * This method is used to delete related entitled service plans and 
     * Applicable Contract Line Products when list of Applicable Contract Line Products deleted.
     */
    public void deleteContractLineItemPlans( final List<String> contractLineItemIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractLineItemPlans() - enter; contractLineItemIdList= ' + contractLineItemIdList );
        final SavePoint sPoint = Database.setSavepoint();
        
        try {
            
            if( contractLineItemIdList == null || contractLineItemIdList.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractLineItemIdList= ' + contractLineItemIdList );
            }
            
            final List<SVMXA360__EntitledServicePlan__c> entitledServiceRecords = SvmxDatabase.query( [SELECT Id FROM SVMXA360__EntitledServicePlan__c WHERE SVMXA360__ContractLineItemPlanId__c IN :contractLineItemIdList ] );
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__ContractPriceLineItemPlan__c WHERE SVMXA360__EntitledServicePlanId__c IN :entitledServiceRecords OR SVMXA360__ContractLineItemPlanId__c IN :contractLineItemIdList] );
            SvmxDatabase.deleteRecord( entitledServiceRecords );
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__ContractLineItemPlan__c WHERE Id IN :contractLineItemIdList] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'deleteContractLineItemPlans() : Failed to delete Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'deleteContractLineItemPlans() : Failed to delete Applicable Contract Line Products. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractLineItemPlans() - exit' );
        }
    }
    
    /**
     * This method is used to delete entitled service plan and related contract price line item plans.
     */
    public void deleteEntitledServicePlan( final String entitledServiceId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitledServicePlan() - enter; entitledServiceId= ' + entitledServiceId );
        
        try {
            
            if( String.isBlank(entitledServiceId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' entitledServiceId= ' + entitledServiceId );
            }
            
            deleteEntitledServicePlans( new List<String>{entitledServiceId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledServicePlan() : Failed to delete Entitled Service Plan. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledServicePlan() : Failed to delete Entitled Service Plan. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitledServicePlan() - exit' );
        }
    }
    
    /**
     * This method is used to delete list entitled service plans and all 
     * related contract price line item plans.
     */
    public void deleteEntitledServicePlans( final List<String> entitledServiceIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitledServicePlan() - enter; entitledServiceIdList= ' + entitledServiceIdList );
        
        final SavePoint sPoint = Database.setSavepoint();
        
        try {
            
            if( entitledServiceIdList == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' entitledServiceIdList= ' + entitledServiceIdList );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__ContractPriceLineItemPlan__c WHERE SVMXA360__EntitledServicePlanId__c IN :entitledServiceIdList ] );
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__EntitledServicePlan__c WHERE Id IN :entitledServiceIdList ] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledServicePlan() : Failed to delete Entitled Service Plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            Database.rollback(sPoint);
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitledServicePlan() : Failed to delete Entitled Service Plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitledServicePlan() - exit' );
        }
    }
    
    /**
     * This method is used to delete contract price line plan for requested id.
     */
    public void deleteContractPriceLinePlan( final String contractPriceLinePlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLinePlan() - enter; contractPriceLinePlanId= ' + contractPriceLinePlanId );
        
        try {
            
            if( String.isBlank(contractPriceLinePlanId) ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractPriceLinePlanId= ' + contractPriceLinePlanId );
            }
            
            deleteContractPriceLinePlans( new List<String>{contractPriceLinePlanId} );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLinePlan() : Failed to delete Contract Price Line Plan. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLinePlan() : Failed to delete Contract Price Line Plan. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLinePlan() - exit' );
        }
    }
    
    /**
     * This method is used to delete contract price line plans for requested list of ids.
     */
    public void deleteContractPriceLinePlans( final List<String> contractPriceLinePlanIdList ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLinePlan() - enter; contractPriceLinePlanIdList= ' + contractPriceLinePlanIdList );
        
        try {
            
            if( contractPriceLinePlanIdList == null ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + ' contractPriceLinePlanIdList= ' + contractPriceLinePlanIdList );
            }
            
            SvmxDatabase.deleteRecord( [SELECT Id FROM SVMXA360__ContractPriceLineItemPlan__c WHERE Id IN :contractPriceLinePlanIdList ] );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLinePlan() : Failed to delete Contract Price Line Plans. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteContractPriceLinePlan() : Failed to delete Contract Price Line Plans. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteContractPriceLinePlan() - exit' );
        }
    }
    
    /**
     * Private method to retrieve all Service Contract Plan records.
     */
    private List<SVMXA360__ServiceContractPlan__c> getAllServiceContractPlanRecords() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllServiceContractPlanRecords() - enter' );
        
        List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = new List<SVMXA360__ServiceContractPlan__c>();
        
        try {
            if( UserInfo.isMultiCurrencyOrganization() ) {
                ServiceContractPlanFields.add('CurrencyIsoCode');
            }
            serviceContractPlanRecords = SvmxDatabase.query( 'SELECT ' + String.join(new List<String>(ServiceContractPlanFields), ',') + ' FROM SVMXA360__ServiceContractPlan__c' );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceContractPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceContractPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllServiceContractPlanRecords() - exit; serviceContractPlanRecords= ' + serviceContractPlanRecords );
        }
        
        return serviceContractPlanRecords;
    }
    
    /**
     * Retrieve Service Contract Plan record.
     */
    private SVMXA360__ServiceContractPlan__c getServiceContractPlanRecord( final String serviceContractPlanId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecord() - enter' );
        
        SVMXA360__ServiceContractPlan__c serviceContractPlanRecord;
        
        try {

            if( UserInfo.isMultiCurrencyOrganization() ) {
                ServiceContractPlanFields.add('CurrencyIsoCode');
            }
            final List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords = SvmxDatabase.query( Database.query( 'SELECT ' + String.join(new List<String>(ServiceContractPlanFields), ',') + ' FROM SVMXA360__ServiceContractPlan__c WHERE Id =:serviceContractPlanId' ) );
               
            if( serviceContractPlanRecords.isEmpty() ) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' serviceContractPlanId= ' + serviceContractPlanId );
            }
            
            serviceContractPlanRecord = serviceContractPlanRecords.get(0);
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecord() - serviceContractPlanRecord='+serviceContractPlanRecord );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceContractPlanRecord() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceContractPlanRecord() - exit' );
        }
        
        return serviceContractPlanRecord;
    }
    
    /**
     * This method is used to retrieve Applicable Contract Line Product records for requested service contract plan Id.
     */
    private List<SVMXA360__ContractLineItemPlan__c> getContractLineItemPlanRecords( final List<String> serviceContractPlanIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlanRecords() - enter' );
        
        List<SVMXA360__ContractLineItemPlan__c> contractLineItemPlanRecords = new List<SVMXA360__ContractLineItemPlan__c>();

        try {

            contractLineItemPlanRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__ServiceContractPlanId__c, SVMXA360__ServiceContractPlanId__r.Name, SVMXA360__ContractLineDuration__c, SVMXA360__ContractLineUnitOfTime__c, SVMXA360__Discount__c, SVMXA360__ProductId__c, SVMXA360__ProductId__r.Name, SVMXA360__ProductFamily__c FROM SVMXA360__ContractLineItemPlan__c WHERE SVMXA360__ServiceContractPlanId__c IN :serviceContractPlanIds Order By CreatedDate DESC]);

        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractLineItemPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractLineItemPlanRecords() - exit' );
        }
        
        return contractLineItemPlanRecords;
    }
    
    /**
     * This method is used to retrieve entitled service plan records.
     */
    private List<SVMXA360__EntitledServicePlan__c> getEntitledServicePlanRecords( final List<String> masterRecordIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlanRecords() - enter' );
        
        List<SVMXA360__EntitledServicePlan__c> entitledServicePlanRecords = new List<SVMXA360__EntitledServicePlan__c>();
            
        try {
            entitledServicePlanRecords = SvmxDatabase.query([SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__EntitledServicePlanLevel__c,SVMXA360__ServiceAmountThreshold__c, SVMXA360__ServiceCountThreshold__c, SVMXA360__TotalServiceAmount__c, SVMXA360__TotalServiceCount__c, SVMXA360__OperatingHoursId__c, SVMXA360__OperatingHoursId__r.Name, SVMXA360__CaseEntitlementProcess__c, SVMXA360__ContractLineItemPlanId__c, SVMXA360__ContractLineItemPlanId__r.Name, SVMXA360__EntitledServiceDuration__c, SVMXA360__EntitledServiceProductId__c, SVMXA360__EntitledServiceProductId__r.Name, SVMXA360__EntitledServiceUnitOfTime__c, SVMXA360__ServiceContractPlanId__c,SVMXA360__ServiceContractPlanId__r.Name, SVMXA360__ServiceUnit__c, SVMXA360__WorkOrderEntitlementProcess__c FROM SVMXA360__EntitledServicePlan__c WHERE SVMXA360__ServiceContractPlanId__c IN :masterRecordIds OR SVMXA360__ContractLineItemPlanId__c IN :masterRecordIds Order By CreatedDate DESC]);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitledServicePlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitledServicePlanRecords() - exit' );
        }
        
        return entitledServicePlanRecords;
    }
    
    /**
     * This method is used to retrieve Contract Price Line Item plan records.
     */
    private List<SVMXA360__ContractPriceLineItemPlan__c> getContractPriceLineItemPlanRecords( final List<String> masterRecordIds ) {
        
        System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlanRecords() - enter' );
        
        List<SVMXA360__ContractPriceLineItemPlan__c> contractPriceLineItemPlanRecords = new List<SVMXA360__ContractPriceLineItemPlan__c>();
        
        try {

            if( UserInfo.isMultiCurrencyOrganization() ) {
                ContractPriceLineItemPlanFields.add('CurrencyIsoCode');
            }

            contractPriceLineItemPlanRecords = SvmxDatabase.query( Database.query( 'SELECT ' + String.join(new List<String>(ContractPriceLineItemPlanFields), ',') + ' FROM SVMXA360__ContractPriceLineItemPlan__c WHERE SVMXA360__ServiceContractPlanId__c IN :masterRecordIds OR SVMXA360__ContractLineItemPlanId__c IN :masterRecordIds OR SVMXA360__EntitledServicePlanId__c IN :masterRecordIds Order By CreatedDate DESC' ) );
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getContractPriceLineItemPlanRecords() : Failed to retrieve records. Error=' + e.getMessage() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getContractPriceLineItemPlanRecords() - exit' );
        }
        
        return contractPriceLineItemPlanRecords;
    }
    
    private List<Scon.ServiceContractPlan> buildServiceContractPlans( final List<SVMXA360__ServiceContractPlan__c> serviceContractPlanRecords ) {
        
        final List<Scon.ServiceContractPlan> serviceContractPlanList = new List<Scon.ServiceContractPlan>();
        if( serviceContractPlanRecords != null && !serviceContractPlanRecords.isEmpty() ) {
            
            for( SVMXA360__ServiceContractPlan__c serviceContractPlanRecord : serviceContractPlanRecords ) {
                serviceContractPlanList.add( buildServiceContractPlan(serviceContractPlanRecord) );
            }
        }
        
        return serviceContractPlanList;
    }
    
    private List<Scon.ContractLineItemPlan> buildContractLineItemPlans( final List<SVMXA360__ContractLineItemPlan__c> contractLineItemPlanRecords ) {
        
        final List<Scon.ContractLineItemPlan> contractLineItemPlanList = new List<Scon.ContractLineItemPlan>();
        if( contractLineItemPlanRecords != null && !contractLineItemPlanRecords.isEmpty() ) {
            
            for( SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord : contractLineItemPlanRecords ) {
                contractLineItemPlanList.add( buildContractLineItemPlan(contractLineItemPlanRecord) );
            }
        }
        
        return contractLineItemPlanList;
    }
    
    private List<Scon.EntitledServicePlan> buildEntitledServicePlans( final List<SVMXA360__EntitledServicePlan__c> entitledServicePlans ) {
        
        final List<Scon.EntitledServicePlan> entitledServicePlanList = new List<Scon.EntitledServicePlan>();
        if( entitledServicePlans != null && !entitledServicePlans.isEmpty() ) {
            
            final Set<Id> entitledProcessSet = new Set<Id>();
            for( SVMXA360__EntitledServicePlan__c entitledServicePlanRecord : entitledServicePlans ) {
                
                final Scon.EntitledServicePlan entitledServicePlan = buildEntitledServicePlan(entitledServicePlanRecord);
                
                if( String.isNotBlank( entitledServicePlan.caseEntitlementProcessId ) ) {
                    entitledProcessSet.add( entitledServicePlan.caseEntitlementProcessId );
                }
                
                if( String.isNotBlank( entitledServicePlan.workOrderEntitlementProcessId ) ) {
                    entitledProcessSet.add( entitledServicePlan.workOrderEntitlementProcessId );
                }
                
                entitledServicePlanList.add( entitledServicePlan );
            }
            
            if( !entitledProcessSet.isEmpty() ) {
                
                final Map<Id,SlaProcess> entitledProcessMap = EVER_EntitledServiceManager.getEntitlementProcess(entitledProcessSet);
                for( Scon.EntitledServicePlan entitledServicePlan : entitledServicePlanList ) {
                    
                    if( String.isNotBlank(entitledServicePlan.caseEntitlementProcessId) && entitledProcessMap.containsKey(entitledServicePlan.caseEntitlementProcessId) ) {
                        entitledServicePlan.caseEntitlementProcessName = entitledProcessMap.get( entitledServicePlan.caseEntitlementProcessId ).Name;
                    }
                    
                    if( String.isNotBlank(entitledServicePlan.workOrderEntitlementProcessId) && entitledProcessMap.containsKey(entitledServicePlan.workOrderEntitlementProcessId) ) {
                        entitledServicePlan.workOrderEntitlementProcessName = entitledProcessMap.get( entitledServicePlan.workOrderEntitlementProcessId ).Name;
                    }
                }
            }
        }
        
        return entitledServicePlanList;
    }
    
    private List<Scon.ContractPriceLineItemPlan> buildContractPriceLineItemPlans( final List<SVMXA360__ContractPriceLineItemPlan__c> contractPriceLineItemPlanRecords ) {
        
        final List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlanList = new List<Scon.ContractPriceLineItemPlan>();
        if( contractPriceLineItemPlanRecords != null && !contractPriceLineItemPlanRecords.isEmpty() ) {
            
            for( SVMXA360__ContractPriceLineItemPlan__c contractPriceLineItemPlanRecord : contractPriceLineItemPlanRecords ) {
                contractPriceLineItemPlanList.add( buildContractPriceLineItemPlan(contractPriceLineItemPlanRecord) );
            }
        }
        
        return contractPriceLineItemPlanList;
    }

    /**
     * This method used to get the Contract Plan Ids based on Asset
     * 
     */
    public List<Id> fetchMatchingContractPlans( final String assetId ){

        List<Id> contractPlanIds =  new List<Id>();
        
        try{
            
            if(String.isBlank( assetId ) ){
                System.debug(LoggingLevel.ERROR, 'fetchMatchingContractPlans Invalid argument');
                throw new SvmxSystem.SvmxNestedException ( ErrorMessage.INVALID_ARGUMENT );
            }
        
        List<Asset> assetList = SvmxDatabase.query([Select  Id, Product2Id, ProductFamily from Asset where Id = : assetId]);

        if (!assetList.isEmpty() && (String.isNotBlank(assetList[0].Product2Id) || String.isNotBlank(assetList[0].ProductFamily))) {

            List<SVMXA360__ContractLineItemPlan__c> matchingCLIPlans = new List<SVMXA360__ContractLineItemPlan__c>();
            String query = 'Select Id, SVMXA360__ServiceContractPlanId__c from SVMXA360__ContractLineItemPlan__c where ';

            if (String.isNotBlank(assetList[0].Product2Id)) {
                String productVal = assetList[0].Product2Id;
                if ( String.isNotBlank(assetList[0].ProductFamily) ) {
                    String productFamily = assetList[0].ProductFamily;
                    matchingCLIPlans = SvmxDatabase.query(Database.query(query + 'SVMXA360__ProductId__c = :productVal OR SVMXA360__ProductFamily__c = :productFamily'));
                } else {
                    matchingCLIPlans = SvmxDatabase.query(Database.query(query + 'SVMXA360__ProductId__c = :productVal'));
                }   
            } else {
                String productFamilyVal = assetList[0].ProductFamily;
                matchingCLIPlans = SvmxDatabase.query(Database.query(query + 'SVMXA360__ProductFamily__c = :productFamilyVal'));
            }
            
            for (SVMXA360__ContractLineItemPlan__c cliPlan : matchingCLIPlans) {
                contractPlanIds.add(cliPlan.SVMXA360__ServiceContractPlanId__c);
            }
        } 

        }catch(Exception e){
       
            System.debug(LoggingLevel.ERROR, 'fetchMatchingContractPlans() : Failed to retrieve Matching Plans '+ e.getStackTraceString() );           
            throw e;
        }
        finally{
            System.debug(LoggingLevel.DEBUG , 'fetchMatchingContractPlans - exit');
        }

        return contractPlanIds;

    }
    
    private Scon.ServiceContractPlan buildServiceContractPlan( final SVMXA360__ServiceContractPlan__c serviceContractPlanRecord ) {
        
        final Scon.ServiceContractPlan serviceContractPlan = new Scon.ServiceContractPlan();
        serviceContractPlan.id = serviceContractPlanRecord.id;
        serviceContractPlan.name = serviceContractPlanRecord.Name;
        serviceContractPlan.lastModifiedDate = serviceContractPlanRecord.LastModifiedDate;
        serviceContractPlan.lastModifiedBy = serviceContractPlanRecord.LastModifiedBy.Name;
        serviceContractPlan.duration = (serviceContractPlanRecord.SVMXA360__ContractTermDuration__c != null) ? serviceContractPlanRecord.SVMXA360__ContractTermDuration__c.intValue() : 0;
        serviceContractPlan.unitOfTime = serviceContractPlanRecord.SVMXA360__ContractTermUnitOfTime__c;
        serviceContractPlan.description = serviceContractPlanRecord.SVMXA360__Description__c;
        serviceContractPlan.isActive = serviceContractPlanRecord.SVMXA360__IsActive__c;
        serviceContractPlan.pricebookId = serviceContractPlanRecord.SVMXA360__PriceBookId__c;
        serviceContractPlan.specialTerms = serviceContractPlanRecord.SVMXA360__SpecialTerms__c;
        serviceContractPlan.currencyIsoCode = UserInfo.isMultiCurrencyOrganization() ? (String)serviceContractPlanRecord.get('CurrencyIsoCode') : null;

        return serviceContractPlan;
    }
    
    private Scon.ContractLineItemPlan buildContractLineItemPlan( final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord ) {
        
        final Scon.ContractLineItemPlan contractLineItemPlan = new Scon.ContractLineItemPlan();
        contractLineItemPlan.id = contractLineItemPlanRecord.id;
        contractLineItemPlan.name = contractLineItemPlanRecord.name;
        contractLineItemPlan.serviceContractPlanId = contractLineItemPlanRecord.SVMXA360__ServiceContractPlanId__c;
        contractLineItemPlan.serviceContractPlanName = contractLineItemPlanRecord.SVMXA360__ServiceContractPlanId__r.Name;
        contractLineItemPlan.lastModifiedDate = contractLineItemPlanRecord.LastModifiedDate;
        contractLineItemPlan.lastModifiedBy = contractLineItemPlanRecord.LastModifiedBy.Name;
        contractLineItemPlan.duration = ( contractLineItemPlanRecord.SVMXA360__ContractLineDuration__c != null ) ? contractLineItemPlanRecord.SVMXA360__ContractLineDuration__c.intValue() : 0;
        contractLineItemPlan.unitOfTime = contractLineItemPlanRecord.SVMXA360__ContractLineUnitOfTime__c;
        contractLineItemPlan.discount = contractLineItemPlanRecord.SVMXA360__Discount__c;
        contractLineItemPlan.productId = contractLineItemPlanRecord.SVMXA360__ProductId__c;
        contractLineItemPlan.productName = contractLineItemPlanRecord.SVMXA360__ProductId__r.Name;
        contractLineItemPlan.productFamily = contractLineItemPlanRecord.SVMXA360__ProductFamily__c;
            
        return contractLineItemPlan;
    }
    
    private Scon.EntitledServicePlan buildEntitledServicePlan( final SVMXA360__EntitledServicePlan__c entitledServicePlanRecord ) {
        
        final Scon.EntitledServicePlan entitledServicePlan = new Scon.EntitledServicePlan();
        entitledServicePlan.id = entitledServicePlanRecord.id;
        entitledServicePlan.name = entitledServicePlanRecord.name;
        entitledServicePlan.lastModifiedDate = entitledServicePlanRecord.LastModifiedDate;
        entitledServicePlan.lastModifiedBy = entitledServicePlanRecord.LastModifiedBy.Name;
        entitledServicePlan.serviceUnit = entitledServicePlanRecord.SVMXA360__ServiceUnit__c;
        if( entitledServicePlan.serviceUnit != null ) {
            
            entitledServicePlan.serviceAlertThreshold = entitledServicePlan.serviceUnit.equalsIgnoreCase(StringAmount) ? entitledServicePlanRecord.SVMXA360__ServiceAmountThreshold__c : entitledServicePlanRecord.SVMXA360__ServiceCountThreshold__c;
            entitledServicePlan.totalService = entitledServicePlan.serviceUnit.equalsIgnoreCase(StringAmount) ? entitledServicePlanRecord.SVMXA360__TotalServiceAmount__c : entitledServicePlanRecord.SVMXA360__TotalServiceCount__c;
        }
        entitledServicePlan.operatingHoursId = entitledServicePlanRecord.SVMXA360__OperatingHoursId__c;
        entitledServicePlan.operatingHoursName = entitledServicePlanRecord.SVMXA360__OperatingHoursId__r.Name;
        entitledServicePlan.caseEntitlementProcessId = entitledServicePlanRecord.SVMXA360__CaseEntitlementProcess__c;
        entitledServicePlan.contractLineItemPlanId = entitledServicePlanRecord.SVMXA360__ContractLineItemPlanId__c;
        entitledServicePlan.contractLineItemPlanName = entitledServicePlanRecord.SVMXA360__ContractLineItemPlanId__r.Name;
        entitledServicePlan.duration = entitledServicePlanRecord.SVMXA360__EntitledServiceDuration__c?.intValue();
        entitledServicePlan.serviceProductId = entitledServicePlanRecord.SVMXA360__EntitledServiceProductId__c;
        entitledServicePlan.serviceProductName = entitledServicePlanRecord.SVMXA360__EntitledServiceProductId__r.Name;
        entitledServicePlan.unitOfTime = entitledServicePlanRecord.SVMXA360__EntitledServiceUnitOfTime__c;
        entitledServicePlan.serviceContractPlanId = entitledServicePlanRecord.SVMXA360__ServiceContractPlanId__c;
        entitledServicePlan.serviceContractPlanName = entitledServicePlanRecord.SVMXA360__ServiceContractPlanId__r.Name;
        entitledServicePlan.workOrderEntitlementProcessId = entitledServicePlanRecord.SVMXA360__WorkOrderEntitlementProcess__c;
        entitledServicePlan.planType = entitledServicePlanRecord.SVMXA360__EntitledServicePlanLevel__c;
        
        return entitledServicePlan;
    }
    
    private Scon.ContractPriceLineItemPlan buildContractPriceLineItemPlan( final SVMXA360__ContractPriceLineItemPlan__c contractPriceLineItemPlanRecord ) {
        
        final Scon.ContractPriceLineItemPlan contractPriceLineItemPlan = new Scon.ContractPriceLineItemPlan();
        contractPriceLineItemPlan.id = contractPriceLineItemPlanRecord.id;
        contractPriceLineItemPlan.name = contractPriceLineItemPlanRecord.name;
        contractPriceLineItemPlan.lastModifiedDate = contractPriceLineItemPlanRecord.LastModifiedDate;
        contractPriceLineItemPlan.lastModifiedBy = contractPriceLineItemPlanRecord.LastModifiedBy.Name;
        contractPriceLineItemPlan.contractLineItemPlanId = contractPriceLineItemPlanRecord.SVMXA360__ContractLineItemPlanId__c;
        contractPriceLineItemPlan.contractLineItemPlanName = contractPriceLineItemPlanRecord.SVMXA360__ContractLineItemPlanId__r.Name;
        contractPriceLineItemPlan.entitledDiscount = contractPriceLineItemPlanRecord.SVMXA360__EntitledDiscount__c;
        contractPriceLineItemPlan.entitledPrice = contractPriceLineItemPlanRecord.SVMXA360__EntitledPrice__c;
        contractPriceLineItemPlan.entitledServicePlanId = contractPriceLineItemPlanRecord.SVMXA360__EntitledServicePlanId__c;
        contractPriceLineItemPlan.entitledServicePlanName = contractPriceLineItemPlanRecord.SVMXA360__EntitledServicePlanId__r.Name;
        contractPriceLineItemPlan.expenseItem = contractPriceLineItemPlanRecord.SVMXA360__ExpenseItem__c;
        contractPriceLineItemPlan.lineType = contractPriceLineItemPlanRecord.SVMXA360__LineType__c;
        contractPriceLineItemPlan.productId = contractPriceLineItemPlanRecord.SVMXA360__ProductId__c;
        contractPriceLineItemPlan.productName = contractPriceLineItemPlanRecord.SVMXA360__ProductId__r.Name;
        contractPriceLineItemPlan.productFamily = contractPriceLineItemPlanRecord.SVMXA360__ProductFamily__c;
        contractPriceLineItemPlan.serviceContractPlanId = contractPriceLineItemPlanRecord.SVMXA360__ServiceContractPlanId__c;
        contractPriceLineItemPlan.serviceContractPlanName = contractPriceLineItemPlanRecord.SVMXA360__ServiceContractPlanId__r.Name;
        contractPriceLineItemPlan.surcharge = contractPriceLineItemPlanRecord.SVMXA360__Surcharge__c;
        contractPriceLineItemPlan.uniqueKey = contractPriceLineItemPlanRecord.SVMXA360__UniqueKey__c;
        contractPriceLineItemPlan.planType = contractPriceLineItemPlanRecord.SVMXA360__LineLevel__c;
        contractPriceLineItemPlan.currencyIsoCode = UserInfo.isMultiCurrencyOrganization() ? (String)contractPriceLineItemPlanRecord.get('CurrencyIsoCode') : null;

        return contractPriceLineItemPlan;
    }
    
    private List<SVMXA360__ContractLineItemPlan__c> buildContractLineItemPlanRecords( final List<Scon.ContractLineItemPlan> contractLineItemPlans ) {
        
        final List<SVMXA360__ContractLineItemPlan__c> contractLineItemPlanRecords = new List<SVMXA360__ContractLineItemPlan__c>();
        for( Scon.ContractLineItemPlan contractLineItemPlan : contractLineItemPlans ) {
            contractLineItemPlanRecords.add( buildContractLineItemPlanRecord(contractLineItemPlan) );
        }
        
        return contractLineItemPlanRecords;
    }
    
    private List<SVMXA360__EntitledServicePlan__c> buildEntitledServicePlanRecords( final List<Scon.EntitledServicePlan> entitledServicePlans ) {
        
        final List<SVMXA360__EntitledServicePlan__c> entitledServicePlanRecords = new List<SVMXA360__EntitledServicePlan__c>();
        for( Scon.EntitledServicePlan entitledServicePlan : entitledServicePlans ) {
            entitledServicePlanRecords.add( buildEntitledServicePlanRecord(entitledServicePlan) );
        }
        
        return entitledServicePlanRecords;
    }
    
    private List<SVMXA360__ContractPriceLineItemPlan__c> buildContractPriceLineItemPlanRecords( final List<Scon.ContractPriceLineItemPlan> contractPriceLineItemPlans ) {
        
        final List<SVMXA360__ContractPriceLineItemPlan__c> contractPriceLineItemPlanRecords = new List<SVMXA360__ContractPriceLineItemPlan__c>();
        for( Scon.ContractPriceLineItemPlan contractPriceLineItemPlan : contractPriceLineItemPlans ) {
            contractPriceLineItemPlanRecords.add( buildContractPriceLineItemPlanRecord(contractPriceLineItemPlan) );
        }
        
        return contractPriceLineItemPlanRecords;
    }
    
    private SVMXA360__ContractLineItemPlan__c buildContractLineItemPlanRecord( final Scon.ContractLineItemPlan contractLineItemPlan ) {
        
        if( contractLineItemPlan.serviceContractPlanId == null ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        final SVMXA360__ContractLineItemPlan__c contractLineItemPlanRecord = new SVMXA360__ContractLineItemPlan__c();
        
        if( contractLineItemPlan.id != null ) {
            contractLineItemPlanRecord.id = contractLineItemPlan.id;
        } else {
            contractLineItemPlanRecord.SVMXA360__ServiceContractPlanId__c = contractLineItemPlan.serviceContractPlanId;
        }
        
        contractLineItemPlanRecord.SVMXA360__ContractLineDuration__c = contractLineItemPlan.duration;
        contractLineItemPlanRecord.SVMXA360__ContractLineUnitOfTime__c = contractLineItemPlan.unitOfTime;
        contractLineItemPlanRecord.SVMXA360__Discount__c = contractLineItemPlan.discount;
        contractLineItemPlanRecord.SVMXA360__ProductId__c = contractLineItemPlan.productId;
        contractLineItemPlanRecord.SVMXA360__ProductFamily__c = contractLineItemPlan.productFamily;
        
        return contractLineItemPlanRecord;
    }
    
    private SVMXA360__EntitledServicePlan__c buildEntitledServicePlanRecord( final Scon.EntitledServicePlan entitledServicePlan ) {
        
        if( entitledServicePlan.serviceContractPlanId == null || (entitledServicePlan.serviceUnit != null && entitledServicePlan.totalService == null && entitledServicePlan.serviceAlertThreshold == null) ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        final SVMXA360__EntitledServicePlan__c entitledServicePlanRecord = new SVMXA360__EntitledServicePlan__c();
        
        if( entitledServicePlan.id != null ) {
            entitledServicePlanRecord.id = entitledServicePlan.id;
        }
        entitledServicePlanRecord.Name = entitledServicePlan.name;
        entitledServicePlanRecord.SVMXA360__ServiceUnit__c = entitledServicePlan.serviceUnit;
        if( entitledServicePlan.serviceUnit != null ) {
            if( entitledServicePlan.serviceUnit.equalsIgnoreCase(StringAmount) ) {
                
                entitledServicePlanRecord.SVMXA360__TotalServiceAmount__c = entitledServicePlan.totalService;
                entitledServicePlanRecord.SVMXA360__ServiceAmountThreshold__c = entitledServicePlan.serviceAlertThreshold;
            } else {
                entitledServicePlanRecord.SVMXA360__TotalServiceCount__c = entitledServicePlan.totalService;
                entitledServicePlanRecord.SVMXA360__ServiceCountThreshold__c = entitledServicePlan.serviceAlertThreshold;
            }
        }
        entitledServicePlanRecord.SVMXA360__OperatingHoursId__c = entitledServicePlan.operatingHoursId;
        entitledServicePlanRecord.SVMXA360__CaseEntitlementProcess__c = entitledServicePlan.caseEntitlementProcessId;
        entitledServicePlanRecord.SVMXA360__WorkOrderEntitlementProcess__c = entitledServicePlan.workOrderEntitlementProcessId;
        entitledServicePlanRecord.SVMXA360__ContractLineItemPlanId__c = entitledServicePlan.contractLineItemPlanId;
        entitledServicePlanRecord.SVMXA360__EntitledServiceDuration__c = entitledServicePlan.duration;
        entitledServicePlanRecord.SVMXA360__EntitledServiceProductId__c = entitledServicePlan.serviceProductId;
        entitledServicePlanRecord.SVMXA360__EntitledServiceUnitOfTime__c = entitledServicePlan.unitOfTime;
        entitledServicePlanRecord.SVMXA360__ServiceContractPlanId__c = entitledServicePlan.serviceContractPlanId;
        
        return entitledServicePlanRecord;
    }
    
    private SVMXA360__ContractPriceLineItemPlan__c buildContractPriceLineItemPlanRecord( final Scon.ContractPriceLineItemPlan contractPriceLineItemPlan ) {
        
        if( contractPriceLineItemPlan.serviceContractPlanId == null ) {
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
        }
        
        final SVMXA360__ContractPriceLineItemPlan__c contractPriceLineItemPlanRecord = new SVMXA360__ContractPriceLineItemPlan__c();
        
        if( contractPriceLineItemPlan.id != null ) {
            contractPriceLineItemPlanRecord.id = contractPriceLineItemPlan.id;
        }
        
        contractPriceLineItemPlanRecord.SVMXA360__ContractLineItemPlanId__c = contractPriceLineItemPlan.contractLineItemPlanId;
        contractPriceLineItemPlanRecord.SVMXA360__EntitledDiscount__c = contractPriceLineItemPlan.entitledDiscount;
        contractPriceLineItemPlanRecord.SVMXA360__EntitledPrice__c = contractPriceLineItemPlan.entitledPrice;
        contractPriceLineItemPlanRecord.SVMXA360__EntitledServicePlanId__c = contractPriceLineItemPlan.entitledServicePlanId;
        contractPriceLineItemPlanRecord.SVMXA360__ExpenseItem__c = contractPriceLineItemPlan.expenseItem;
        contractPriceLineItemPlanRecord.SVMXA360__LineType__c = contractPriceLineItemPlan.lineType;
        contractPriceLineItemPlanRecord.SVMXA360__ProductId__c = contractPriceLineItemPlan.productId;
        contractPriceLineItemPlanRecord.SVMXA360__ProductFamily__c = contractPriceLineItemPlan.productFamily;
        contractPriceLineItemPlanRecord.SVMXA360__ServiceContractPlanId__c = contractPriceLineItemPlan.serviceContractPlanId;
        contractPriceLineItemPlanRecord.SVMXA360__Surcharge__c = contractPriceLineItemPlan.surcharge;
        
        if( UserInfo.isMultiCurrencyOrganization() ) {
            contractPriceLineItemPlanRecord.put('CurrencyIsoCode', contractPriceLineItemPlan.currencyIsoCode );
        }

        return contractPriceLineItemPlanRecord;
    }

    private SCON_ServiceContractPlanManager() {
    }
}