/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * service assignment rules. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020 
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       10 Dec 2020     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_ServiceAssignmentRuleManager {

    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_ServiceAssignmentRuleManager instance;
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_ServiceAssignmentRuleManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_ServiceAssignmentRuleManager();
        }
        
        return instance;
    }

    /**
     * This method is used to retrieves all service assignment rules.
     * 
     * @return Returns List of all Service Assignment rules exists in the database.
     */
    public List<Adm.ServiceAssignmentRule> getAllServiceAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - enter' );
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new List<Adm.ServiceAssignmentRule>();
        
        try {

            // Retrieve all service assignment rules
            final List<SVMXA360__CONF_EntitledServiceAssignmentRule__c > serviceAssignmentRuleRecordList = retrieveServiceAssignmentRuleRecords( null );
            
            if( serviceAssignmentRuleRecordList.size() > 0 ) {
                
                serviceAssignmentRuleList.addAll( createServiceAssignmentRules( serviceAssignmentRuleRecordList ) );
                
                System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() : Retrieved all service assignment rules' );
            } else {
                System.debug( LoggingLevel.WARN, 'getAllServiceAssignmentRules() : No service assignment rules found');
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllServiceAssignmentRules() : Failed to retrieve service assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllServiceAssignmentRules() - exit; serviceAssignmentRuleList.size()= ' + serviceAssignmentRuleList.size() );
        }
        
        return serviceAssignmentRuleList;
    }

    /**
     * This method is used to retrieves the service assignment rules for the requested object.
     * 
     * @return Returns List of all Service Assignment rules exists in the database for the requested object.
     */
    public List<Adm.ServiceAssignmentRule> getServiceAssignmentRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - enter' );
        
        List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList = new List<Adm.ServiceAssignmentRule>();
        
        try {

            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRules() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all service assignment rules
            final List<SVMXA360__CONF_EntitledServiceAssignmentRule__c > serviceAssignmentRuleRecordList = retrieveServiceAssignmentRuleRecords( objectName );
            
            if( serviceAssignmentRuleRecordList.size() > 0 ) {
                
                // Create service assignment rule wrapper for each retrieved service assignment rule records.
                for( SVMXA360__CONF_EntitledServiceAssignmentRule__c  serviceAssignmentRuleRecord : serviceAssignmentRuleRecordList ) {
                    serviceAssignmentRuleList.add( createServiceAssignmentRule( serviceAssignmentRuleRecord ) );
                }
                
                System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() : Retrieved all service assignment rules' );
            } else {
                System.debug( LoggingLevel.WARN, 'getServiceAssignmentRules() : No service assignment rules found');
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRules() : Failed to retrieve service assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRules() - exit; serviceAssignmentRuleList.size()= ' + serviceAssignmentRuleList.size() );
        }
        
        return serviceAssignmentRuleList;
    }

    /**
     * This method is used to retrieve Service Assignment rules for requested object Record Id.
     * 
     * @param serviceAssignmentRuleId Service Assignment rule id for which Service Assignment rules to be retrieved.
     * 
     * @return Returns List of Service Assignment rules for requested Rule Id.
     */
    public Adm.ServiceAssignmentRule getServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - enter; serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
        
        Adm.ServiceAssignmentRule serviceAssignmentRule;
        
        try {
            
            // Verify request for valid service assignment Rule Id.
            if( String.isBlank( serviceAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Invalid request parameters. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve the service assignment rule for requested Id.
            final SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord = getServiceAssignmentRuleRecord( serviceAssignmentRuleId );
            
            serviceAssignmentRule = createServiceAssignmentRule( serviceAssignmentRuleRecord );
            //populate the expression details
            if( serviceAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
                ADM_ExpressionManager expManager = ADM_ExpressionManager.getInstance();
                serviceAssignmentRule.qualifyingCriteria = expManager.getExpressionsWithDetails(serviceAssignmentRuleRecord.SVMXA360__ExpressionId__c);
            }
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() : Retrieved Service Assignment Rules for requested Id' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Failed to retrueve service assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRule() : Failed to retrieve service assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRule() - exit; serviceAssignmentRule= ' + serviceAssignmentRule );
        }
        
        return serviceAssignmentRule;
    }

    /**
     * This method is ueed to retrieve service rule Assignment record for requested service assignment rule id.
     * 
     * @param serviceAssignmentRuleId Service Assignment rule id for which service Assignment rules to be retrieved.
     * 
     * @returns service assignment rule record.
     */
    public SVMXA360__CONF_EntitledServiceAssignmentRule__c getServiceAssignmentRuleRecord( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRuleRecord() - enter; serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
        
        SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord;
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( serviceAssignmentRuleId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRuleRecord() : Invalid request parameters. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            List<SVMXA360__CONF_EntitledServiceAssignmentRule__c> serviceAssignmentRuleRecordList = retrieveServiceAssignmentRuleRecords(serviceAssignmentRuleId);
            
            if( serviceAssignmentRuleRecordList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRuleRecord() : Record not exists. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + serviceAssignmentRuleId );
            }
            
            serviceAssignmentRuleRecord = serviceAssignmentRuleRecordList.get(0);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRuleRecord() : Failed to retrieve service assignment rule record. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getServiceAssignmentRuleRecord() : Failed to retrieve service assignment rule record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getServiceAssignmentRuleRecord() - exit; serviceAssignmentRuleRecord= ' + serviceAssignmentRuleRecord );
        }
        
        return serviceAssignmentRuleRecord;
    }

    /**
     * This method is used to validate requested service assignment rule.
     * 
     * @param serviceAssignmentRule Service Assignment rule wrapper instance to be validated.
     * 
     * @return Returns Adm.ValidationResulte with validation details.
     */
    public Adm.ValidationResult validateServiceAssignmentRule( final Adm.ServiceAssignmentRule serviceAssignmentRule ) {
        
        return validateServiceAssignmentRules( new List<Adm.ServiceAssignmentRule> {serviceAssignmentRule} ).get(0);
    }
    
    /**
     * This method is used to validate requested service assignment rules.
     * 
     * @param serviceAssignmentRuleList Service Assignment rules wrapper instance to be validated.
     * 
     * @return Returns List of Adm.ValidationResulte with validation details.
     */
    public List<Adm.ValidationResult> validateServiceAssignmentRules( final List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRules() - enter; serviceAssignmentRuleList= ' + serviceAssignmentRuleList );
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        try {
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            final Set<String> productNameSet = new Set<String>();
            final List<Adm.ServiceAssignmentRule> validServiceAssignmentRules = new List<Adm.ServiceAssignmentRule>();
            final List<Adm.ValidationResult> serviceValidationResults = new List<Adm.ValidationResult>();
            List<Adm.Expression> expressionList = new List<Adm.Expression>();
            
            for( Adm.ServiceAssignmentRule serviceAssignmentRule : serviceAssignmentRuleList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.ServiceAssignmentRule );
                validationResults.add( validationResult );
                
                // Verify request for valid expression informations.
                if( serviceAssignmentRule == null || serviceAssignmentRule.product == null || String.isBlank(serviceAssignmentRule.product.name ) || serviceAssignmentRule.qualifyingCriteria == null  ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateServiceAssignmentRules() : Invalid request parameters. serviceAssignmentRule= ' + serviceAssignmentRule );
                    validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER);
                    
                    continue;
                }
                
                productNameSet.add(serviceAssignmentRule.product.name);
                validServiceAssignmentRules.add(serviceAssignmentRule);
                serviceValidationResults.add(validationResult);
                expressionList.add( serviceAssignmentRule.qualifyingCriteria );
            }
            
            List<Adm.ValidationResult> expressionValidationResults = ADM_ExpressionManager.getInstance().validateExpressions(expressionList );
                
            final List<Product2> productRecords = SvmxDatabase.query([Select Name FROM Product2 WHERE Name = :productNameSet]);
            productNameSet.clear();
            
            for( Product2 productRecord : productRecords ) {
                productNameSet.add(productRecord.Name);
            }
            
            for( Integer index = 0; index < validServiceAssignmentRules.size(); index++ ) {
                
                final Adm.ServiceAssignmentRule serviceAssignmentRule = validServiceAssignmentRules.get(index);
                final Adm.ValidationResult validationResult = serviceValidationResults.get(index);
                final Adm.ValidationResult expressionValidationResult = expressionValidationResults.get(index);
                
                if( !productNameSet.contains(serviceAssignmentRule.product.name) ) {
                    
                    System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRules() - Product does not exists : ' + serviceAssignmentRule.product.name );
                    validationResult.setError( 'Product does not exists : ' + serviceAssignmentRule.product.name );
                }
                
                if( !expressionValidationResult.isValid ) {
                    
                    if( String.isNotBlank(expressionValidationResult.error) ) {
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.Expression, expressionValidationResult.error ) );
                    }
                    
                    if( expressionValidationResult.detailResults != null && expressionValidationResult.detailResults.size() > 0 ) {
                        validationResult.addAllDetailResult( expressionValidationResult.detailResults );
                    }
                }
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateServiceAssignmentRules() : Failed to validate Service Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateServiceAssignmentRules() - exit; validationResults= ' + validationResults.size() );
        }
        
        return validationResults;
    }
    
    /**
     * This method is used to save requested service assignment rule. If service assignment rule id not exists then, 
     * new sevrice assignment rule record will be created otherwise, existing service assignment rule will be updated.
     * 
     * @param serviceAssignmentRule Service Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.ServiceAssignmentRule with created/updated record details.
     */
    public Adm.ServiceAssignmentRule saveServiceAssignmentRule( final Adm.ServiceAssignmentRule serviceAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - enter; serviceAssignmentRule= ' + serviceAssignmentRule );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid service assignment rule information.
            if( serviceAssignmentRule == null || String.isBlank( serviceAssignmentRule.name ) || String.isBlank( serviceAssignmentRule.objectAPIName ) || serviceAssignmentRule.product == null || String.isBlank( serviceAssignmentRule.product.id )) {

                System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Invalid request parameters. serviceAssignmentRule= ' + serviceAssignmentRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Remove expression record as service assignment rule qualification criterias are not reusable.
            if( String.isNotBlank( serviceAssignmentRule.id ) && serviceAssignmentRule.qualifyingCriteria == null ) {
                
                final SVMXA360__CONF_EntitledServiceAssignmentRule__c oldServiceAssignmentRuleRecord = (SVMXA360__CONF_EntitledServiceAssignmentRule__c) SvmxDatabase.query( [SELECT SVMXA360__ExpressionId__c FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c WHERE id = :serviceAssignmentRule.id ] ).get(0);
            	
                if( oldServiceAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
                    ADM_ExpressionManager.getInstance().deleteExpression(oldServiceAssignmentRuleRecord.SVMXA360__ExpressionId__c);
                }
            }
            
            // Upsert service assignment rule record.
            SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord = createServiceAssignmentRuleRecord(serviceAssignmentRule);
            
            // Upsert expression if exists in the request.
            if( serviceAssignmentRule.qualifyingCriteria != null ) {
                
                serviceAssignmentRule.qualifyingCriteria = ADM_ExpressionManager.getInstance().saveExpression( serviceAssignmentRule.qualifyingCriteria );
                
                // Assign expression id if exists.
                if( String.isNotBlank( serviceAssignmentRule.qualifyingCriteria.id ) ) {
                    serviceAssignmentRuleRecord.SVMXA360__ExpressionId__c = serviceAssignmentRule.qualifyingCriteria.id;
                }
            }
            
            serviceAssignmentRuleRecord = (SVMXA360__CONF_EntitledServiceAssignmentRule__c) SvmxDatabase.upsertRecord(serviceAssignmentRuleRecord);
            
            System.debug( LoggingLevel.INFO, 'saveServiceAssignmentRule() : Saved Service Assignment Rule. Name= ' + serviceAssignmentRuleRecord.Name );
            
            // Update service assignment rule id and sequence in the response.
            serviceAssignmentRule.id = serviceAssignmentRuleRecord.id;
            serviceAssignmentRule.sequence = (serviceAssignmentRuleRecord.SVMXA360__Sequence__c != null) ? Integer.valueOf(serviceAssignmentRuleRecord.SVMXA360__Sequence__c) : null;
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Failed to save Service Assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveServiceAssignmentRule() : Failed to save Service Assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveServiceAssignmentRule() - exit; serviceAssignmentRule= ' + serviceAssignmentRule );
        }
        
        return serviceAssignmentRule;
    }

    /**
     * This method is used to update service assignment rule sequence and active status. This method is applicable 
     * only for already created service assignment rules to update the rule sequence and change the active status.
     * 
     * @param serviceAssignmentRuleList List of service assignment rules for which sequence and status to be updated.
     * 
     * @return Returns List of Adm.ServiceAssignmentRule with sqeuence and status information.
     */
    public List<Adm.ServiceAssignmentRule> updateServiceAssignmentRulesSequence( final List<Adm.ServiceAssignmentRule> serviceAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - enter; serviceAssignmentRuleList= ' + serviceAssignmentRuleList );
        
        try {
            
            // Verify request for valid service assignment rule list.
            if( serviceAssignmentRuleList == null || serviceAssignmentRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Invalid request parameters. serviceAssignmentRuleList= ' + serviceAssignmentRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final List<SVMXA360__CONF_EntitledServiceAssignmentRule__c> serviceAssignmentRuleRecordList = new List<SVMXA360__CONF_EntitledServiceAssignmentRule__c>();
            
            // Create SObject for each requested service assignment rules with sequence and active status.
            for( Adm.ServiceAssignmentRule serviceAssignmentRule : serviceAssignmentRuleList ) {
                
                // Verify for valid sequence and active status.
                // isActive == true, Sequence > 0
                // id != null
                if( String.isBlank(serviceAssignmentRule.id) || serviceAssignmentRule.active == null || ( serviceAssignmentRule.active && ( serviceAssignmentRule.sequence == null || serviceAssignmentRule.sequence <= 0 ) ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Invalid request parameters. serviceAssignmentRule= ' + serviceAssignmentRule );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + serviceAssignmentRule );
                }
                
                SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord = new SVMXA360__CONF_EntitledServiceAssignmentRule__c();
                
                serviceAssignmentRuleRecord.id = serviceAssignmentRule.id;
                serviceAssignmentRuleRecord.SVMXA360__Sequence__c = serviceAssignmentRule.sequence = serviceAssignmentRule.active ? serviceAssignmentRule.sequence : null;
                serviceAssignmentRuleRecord.SVMXA360__Active__c = serviceAssignmentRule.active;
                
                serviceAssignmentRuleRecordList.add( serviceAssignmentRuleRecord );
            }
            
            // Update sequence and active status
            SvmxDatabase.updateRecord(serviceAssignmentRuleRecordList);
            
            System.debug( LoggingLevel.INFO, 'updateServiceAssignmentRulesSequence() : Updated Pricebook Assignment Rule sequence.' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Failed to update Pricebook Assignment Rule sequence and active status. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'updateServiceAssignmentRulesSequence() : Failed to update Pricebook Assignment Rule sequence and active status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateServiceAssignmentRulesSequence() - exit; serviceAssignmentRuleList= ' + serviceAssignmentRuleList );
        }
        
        return serviceAssignmentRuleList;
    }

    /**
     * This method is used to delete service assignment rule for requested service assignment id.
     * 
     * @param serviceAssignmentRuleId service assignment rule record id to be deleted.
     */
    public void deleteServiceAssignmentRule( final String serviceAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - enter; serviceAssignmentRuleId= ' + serviceAssignmentRuleId );

        Savepoint sPoint = Database.setSavepoint();
        
        try {
            // Verify for valid service assignment rule id.
            if( String.isBlank( serviceAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Invalid request parameters. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final List<SVMXA360__CONF_EntitledServiceAssignmentRule__c> serviceAssignmentRuleList = SvmxDatabase.query( [SELECT Id, SVMXA360__ExpressionId__c FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c WHERE Id = :serviceAssignmentRuleId OR SVMXA360__DeveloperName__c = :serviceAssignmentRuleId] );
            
            SvmxDatabase.deleteRecord( serviceAssignmentRuleList );
            
            // Delete qualification criteria configured for service assignment rule.
            if( !serviceAssignmentRuleList.isEmpty() && serviceAssignmentRuleList[0].SVMXA360__ExpressionId__c != null ) {
                ADM_ExpressionManager.getInstance().deleteExpression( serviceAssignmentRuleList[0].SVMXA360__ExpressionId__c );
            }
            
            System.debug( LoggingLevel.INFO, 'deleteServiceAssignmentRule() : Service Assignment rule deleted successfully. serviceAssignmentRuleId= ' + serviceAssignmentRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Failed to delete Service Assignment rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){

            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deleteServiceAssignmentRule() : Failed to delete Service Assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - exit');
        }
    }

    /**
     * Method to retrieve service assignment rule records.
     */
    public List<SVMXA360__CONF_EntitledServiceAssignmentRule__c> retrieveServiceAssignmentRuleRecords( final String filterElement ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveServiceAssignmentRuleRecords() - enter; filterElement= ' + filterElement );
        
        List<SVMXA360__CONF_EntitledServiceAssignmentRule__c> serviceAssignmentRuleRecordList = 
            new List<SVMXA360__CONF_EntitledServiceAssignmentRule__c>();
        
        try {
            
            // Validate for required fields.
            if( String.isNotBlank( filterElement ) ) {
                serviceAssignmentRuleRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Active__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__ProductId__c, SVMXA360__ProductId__r.name, SVMXA360__ExpressionId__c, SVMXA360__Sequence__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c WHERE SVMXA360__ObjectAPIName__c = :filterElement OR id =:filterElement OR SVMXA360__DeveloperName__c =:filterElement ORDER BY SVMXA360__Sequence__c NULLS LAST] );
            } else {
                serviceAssignmentRuleRecordList = SvmxDatabase.query( [SELECT Id, Name,  SVMXA360__Active__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__ProductId__c, SVMXA360__ProductId__r.name, SVMXA360__ExpressionId__c, SVMXA360__Sequence__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c ORDER BY SVMXA360__Sequence__c NULLS LAST] );
            } 
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveServiceAssignmentRuleRecords() : Failed to retrieve Service Assignment rule records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveServiceAssignmentRuleRecords() - exit; serviceAssignmentRuleRecordList.size()= ' + serviceAssignmentRuleRecordList.size() );
        }
        
        return serviceAssignmentRuleRecordList;
    }

    /**
     * Private method to create service assignment rule record.
     * 
     * @param serviceAssignmentRule Service Assignment rule wrappef for which SObject to be created.
     * @return Returns SVMXA360__CONF_EntitledServiceAssignmentRule__c sobject with populated values from serviceAssignmentRule.
     */
    private SVMXA360__CONF_EntitledServiceAssignmentRule__c createServiceAssignmentRuleRecord( final Adm.ServiceAssignmentRule serviceAssignmentRule ) {
        
        System.debug( LoggingLevel.FINEST, 'createServiceAssignmentRuleRecord() - enter; serviceAssignmentRule= ' + serviceAssignmentRule);
        
        SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord = new SVMXA360__CONF_EntitledServiceAssignmentRule__c();
        
        if( String.isNotBlank( serviceAssignmentRule.id ) ) {
            serviceAssignmentRuleRecord.id = serviceAssignmentRule.id;
        } else {
            serviceAssignmentRuleRecord.SVMXA360__DeveloperName__c = serviceAssignmentRule.developerName;
        }
        
        serviceAssignmentRuleRecord.Name = serviceAssignmentRule.name;
        serviceAssignmentRuleRecord.SVMXA360__Description__c = serviceAssignmentRule.description;
        serviceAssignmentRuleRecord.SVMXA360__ObjectAPIName__c = serviceAssignmentRule.objectAPIName;
        serviceAssignmentRuleRecord.SVMXA360__Active__c = serviceAssignmentRule.active != null ? serviceAssignmentRule.active : false;
        serviceAssignmentRuleRecord.SVMXA360__ProductId__c = serviceAssignmentRule.product.id;
        serviceAssignmentRuleRecord.SVMXA360__Sequence__c = (serviceAssignmentRule.active) ? serviceAssignmentRule.sequence : null;
		
        // Generate rule sequence for active rules.
        if( serviceAssignmentRule.active && serviceAssignmentRule.sequence == null ) {
            
            serviceAssignmentRuleRecord.SVMXA360__Sequence__c = 1;
            AggregateResult[] aggregateResultArray = (Test.isRunningTest()) 
                ? [SELECT MAX(SVMXA360__Sequence__c) MaxSequence FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c]
                : [SELECT MAX(SVMXA360__Sequence__c) MaxSequence FROM SVMXA360__CONF_EntitledServiceAssignmentRule__c WITH SECURITY_ENFORCED];
            if( aggregateResultArray != null && aggregateResultArray.size() > 0 && aggregateResultArray[0].get('MaxSequence') != null ) {
                serviceAssignmentRuleRecord.SVMXA360__Sequence__c = serviceAssignmentRule.sequence = Integer.valueOf( aggregateResultArray[0].get('MaxSequence') ) + 1;
            }
        }

        System.debug( LoggingLevel.FINEST, 'createServiceAssignmentRuleRecord() - exit; serviceAssignmentRuleRecord= ' + serviceAssignmentRuleRecord);
        
        return serviceAssignmentRuleRecord;
    }

    private List<Adm.ServiceAssignmentRule> createServiceAssignmentRules( final List<SVMXA360__CONF_EntitledServiceAssignmentRule__c> serviceAssignmentRuleRecords ) {
        
        final List<Adm.ServiceAssignmentRule> serviceAssignmentRules = new List<Adm.ServiceAssignmentRule>();
        final Map<Id,Adm.ServiceAssignmentRule> expressionIdMap = new Map<Id,Adm.ServiceAssignmentRule>();
        
        for( SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord : serviceAssignmentRuleRecords ) {
            
            final Adm.ServiceAssignmentRule serviceAssignmentRule = createServiceAssignmentRule(serviceAssignmentRuleRecord);
            if( serviceAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
                expressionIdMap.put( serviceAssignmentRule.qualifyingCriteria.id, serviceAssignmentRule );
            }
            serviceAssignmentRules.add(serviceAssignmentRule);
        }
        if( !expressionIdMap.isEmpty() ) {
            final Map<Id,Adm.Expression> idExpressionMap = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( new List<Id>(expressionIdMap.keySet()), null );
            for( Adm.ServiceAssignmentRule serviceAssignmentRule: expressionIdMap.values() ) {
                serviceAssignmentRule.qualifyingCriteria = idExpressionMap.get(serviceAssignmentRule.qualifyingCriteria.id);
            }
        }
        
        return serviceAssignmentRules;
    }
    
    /**
     * This method is used to create Service Assignment rule wrapper for requested service assignment rule record.
     * 
     * @param serviceAssignmentRuleRecord Service Assignment rule sobject record from which wrapper to be created.
     * 
     * @return Returns Adm.ServiceAssignmentRule instance with populated values from serviceAssignmentRuleRecord.
     */
    private Adm.ServiceAssignmentRule createServiceAssignmentRule( final SVMXA360__CONF_EntitledServiceAssignmentRule__c serviceAssignmentRuleRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createServiceAssignmentRule() - enter; serviceAssignmentRuleRecord= ' + serviceAssignmentRuleRecord);
        
        Adm.ServiceAssignmentRule serviceAssignmentRule = new Adm.ServiceAssignmentRule();
        serviceAssignmentRule.id = serviceAssignmentRuleRecord.id;
        serviceAssignmentRule.name = serviceAssignmentRuleRecord.Name;
        serviceAssignmentRule.description = serviceAssignmentRuleRecord.SVMXA360__Description__c;
        serviceAssignmentRule.developerName = serviceAssignmentRuleRecord.SVMXA360__DeveloperName__c;
        serviceAssignmentRule.objectAPIName = serviceAssignmentRuleRecord.SVMXA360__ObjectAPIName__c;
        serviceAssignmentRule.active = serviceAssignmentRuleRecord.SVMXA360__Active__c;
        serviceAssignmentRule.lastModifiedDate = serviceAssignmentRuleRecord.LastModifiedDate;
        serviceAssignmentRule.lastModifiedBy = serviceAssignmentRuleRecord.LastModifiedBy.Name;
        serviceAssignmentRule.sequence = (serviceAssignmentRuleRecord.SVMXA360__Sequence__c != null ) ? Integer.valueOf( serviceAssignmentRuleRecord.SVMXA360__Sequence__c ) : null;
        if( serviceAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
            
            Adm.Expression expression = new Adm.Expression();
            expression.id = serviceAssignmentRuleRecord.SVMXA360__ExpressionId__c;
            serviceAssignmentRule.qualifyingCriteria = expression;
        }

        if( serviceAssignmentRuleRecord.SVMXA360__ProductId__c  != null ) {
            Adm.LookupInfo productRecord = new Adm.LookupInfo();
            productRecord.id = serviceAssignmentRuleRecord.SVMXA360__ProductId__c;
            productRecord.name = serviceAssignmentRuleRecord.SVMXA360__ProductId__r.name;
            serviceAssignmentRule.product = productRecord;
        }
        
        System.debug( LoggingLevel.FINEST, 'createServiceAssignmentRule() - exit; serviceAssignmentRule= ' + serviceAssignmentRule);
        
        return serviceAssignmentRule;
    }

}