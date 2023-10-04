/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * pricebook assignment rules. 
 *
 * @author Sandeep Dhariwal
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sandeep Dhariwal       16 Dec 2020     Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_PricebookAssignmentRuleManager {
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_PricebookAssignmentRuleManager instance;

    /**
     * Static variable to hold pricebook assignment records.
     */
    private static Map<String, List<Adm.PricebookAssignmentRule>> pricebookAssignmentRulesMap = new Map<String, List<Adm.PricebookAssignmentRule>>();
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_PricebookAssignmentRuleManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_PricebookAssignmentRuleManager();
        }
        
        return instance;
    }

    /**
     * This method is used to retrieves the pricebook assignment rules for the requested object.
     * 
     * @return Returns List of all Pricebook Assignment rules exists in the database for the requested object.
     */
    public List<Adm.PricebookAssignmentRule> getAllPricebookAssignmentRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - enter' );
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new List<Adm.PricebookAssignmentRule>();
        
        try {

            // Retrieve all pricebook assignment rules
            final List<SVMXA360__CONF_PricebookAssignmentRule__c > pricebookAssignmentRuleRecordList = retrievePricebookAssignmentRuleRecords( null );
            
            if( pricebookAssignmentRuleRecordList.size() > 0 ) {
                
                pricebookAssignmentRuleList.addAll( createPricebookAssignmentRules( pricebookAssignmentRuleRecordList ) );
                
                System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() : Retrieved all pricebook assignment rules' );
            } else {
                System.debug( LoggingLevel.WARN, 'getAllPricebookAssignmentRules() : No pricebook assignment rules found');
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllPricebookAssignmentRules() : Failed to retrieve pricebook assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllPricebookAssignmentRules() - exit; pricebookAssignmentRuleList.size()= ' + pricebookAssignmentRuleList.size() );
        }
        
        return pricebookAssignmentRuleList;
    }

    /**
     * This method is used to retrieves the pricebook assignment rules for the requested object.
     * 
     * @return Returns List of all Pricebook Assignment rules exists in the database for the requested object.
     */
    public List<Adm.PricebookAssignmentRule> getPricebookAssignmentRules(String objectName) {
        
        System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRules() - enter' );
        
        List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList = new List<Adm.PricebookAssignmentRule>();
        
        try {

            // Verify request for valid object name.
            if( String.isBlank( objectName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRules() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }

            if( !pricebookAssignmentRulesMap.containsKey( objectName ) ) {
                // Retrieve all pricebook assignment rules
                final List<SVMXA360__CONF_PricebookAssignmentRule__c > pricebookAssignmentRuleRecordList = retrievePricebookAssignmentRuleRecords( objectName );
                
                if( !pricebookAssignmentRuleRecordList.isEmpty() ) {
                    
                    // Create entitlement rule wrapper for each retrieved pricebook assignment rule records.
                    for( SVMXA360__CONF_PricebookAssignmentRule__c  pricebookAssignmentRuleRecord : pricebookAssignmentRuleRecordList ) {
                        pricebookAssignmentRuleList.add( createPricebookAssignmentRule( pricebookAssignmentRuleRecord ) );
                    }

                    pricebookAssignmentRulesMap.put(objectName, pricebookAssignmentRuleList);

                    System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRules() : Retrieved pricebook assignment rules' );

                } else {
                    System.debug( LoggingLevel.WARN, 'getPricebookAssignmentRules() : No pricebook assignment rules found');
                }

            } else {
                pricebookAssignmentRuleList = pricebookAssignmentRulesMap.get( objectName );
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRules() : Failed to retrieve pricebook assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRules() - exit; pricebookAssignmentRuleList.size()= ' + pricebookAssignmentRuleList.size() );
        }
        
        return pricebookAssignmentRuleList;
    }

    /**
     * This method is used to retrieve Pricebook Assignment rules for requested object Record Id.
     * 
     * @param pricebookAssignmentRuleId Pricebook Assignment rule id for which Pricebook Assignment rules to be retrieved.
     * 
     * @return Returns List of Pricebook Assignment rules for requested Rule Id.
     */
    public Adm.PricebookAssignmentRule getPricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - enter; pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        
        Adm.PricebookAssignmentRule pricebookAssignmentRule;
        
        try {
            
            // Verify request for valid service assignment Rule Id.
            if( String.isBlank( pricebookAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Invalid request parameters. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve the service assignment rule for requested Id.
            final SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord = getPricebookAssignmentRuleRecord( pricebookAssignmentRuleId );
            
            pricebookAssignmentRule = createPricebookAssignmentRule( pricebookAssignmentRuleRecord );
            //populate the expression details
            if( pricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
                ADM_ExpressionManager expManager = ADM_ExpressionManager.getInstance();
                pricebookAssignmentRule.qualifyingCriteria = expManager.getExpressionsWithDetails(pricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c);
            }
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() : Retrieved Pricebook Assignment Rules for requested Id' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Failed to retrueve pricebook assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRule() : Failed to retrieve pricebook assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRule() - exit; pricebookAssignmentRule= ' + pricebookAssignmentRule );
        }
        
        return pricebookAssignmentRule;
    }

    /**
     * This method is ueed to retrieve pricebook rule Assignment record for requested entitlement rule id.
     * 
     * @param pricebookAssignmentRuleId Pricebook Assignment rule id for which Pricebook Assignment rules to be retrieved.
     * 
     * @returns pricebook assignment rule record.
     */
    public SVMXA360__CONF_PricebookAssignmentRule__c getPricebookAssignmentRuleRecord( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRuleRecord() - enter; pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        
        SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord;
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( pricebookAssignmentRuleId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRuleRecord() : Invalid request parameters. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            List<SVMXA360__CONF_PricebookAssignmentRule__c> pricebookAssignmentRuleRecordList = 
                retrievePricebookAssignmentRuleRecords(pricebookAssignmentRuleId);
            
            if( pricebookAssignmentRuleRecordList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRuleRecord() : Record not exists. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + pricebookAssignmentRuleId );
            }
            
            pricebookAssignmentRuleRecord = pricebookAssignmentRuleRecordList.get(0);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRuleRecord() : Failed to retrieve service assignment rule record. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getPricebookAssignmentRuleRecord() : Failed to retrieve service assignment rule record. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getPricebookAssignmentRuleRecord() - exit; pricebookAssignmentRuleRecord= ' + pricebookAssignmentRuleRecord );
        }
        
        return pricebookAssignmentRuleRecord;
    }

    /**
     * This method is used to validate requested pricebook assignment rule.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment rule wrapper instance to be validated.
     * 
     * @return Returns Adm.ValidationResult with validation details.
     */
    public Adm.ValidationResult validatePricebookAssignmentRule( final Adm.PricebookAssignmentRule pricebookAssignmentRule ) {
        return validatePricebookAssignmentRules( new List<Adm.PricebookAssignmentRule> {pricebookAssignmentRule} ).get(0);
    }
    
    /**
     * This method is used to validate requested pricebook assignment rules.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment rules wrapper instance to be validated.
     * 
     * @return Returns List of Adm.ValidationResult with validation details.
     */
    public List<Adm.ValidationResult> validatePricebookAssignmentRules( final List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRules() - enter; pricebookAssignmentRuleList= ' + pricebookAssignmentRuleList );
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            final Set<String> pricebookNameSet = new Set<String>();
            final List<Adm.PricebookAssignmentRule> validPricebookAssignmentRules = new List<Adm.PricebookAssignmentRule>();
            final List<Adm.ValidationResult> pricebookValidationResults = new List<Adm.ValidationResult>();
            List<Adm.Expression> expressionList = new List<Adm.Expression>();
            
            for( Adm.PricebookAssignmentRule pricebookAssignmentRule : pricebookAssignmentRuleList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.PricebookAssignmentRule );
                validationResults.add( validationResult );
                
                // Verify request for valid expression informations.
                if( pricebookAssignmentRule == null || pricebookAssignmentRule.pricebook == null || String.isBlank(pricebookAssignmentRule.pricebook.name ) || pricebookAssignmentRule.qualifyingCriteria == null  ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validatePricebookAssignmentRules() : Invalid request parameters. pricebookAssignmentRule= ' + pricebookAssignmentRule );
                    validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER);
                    
                    continue;
                }
                
                pricebookNameSet.add(pricebookAssignmentRule.pricebook.name);
                validPricebookAssignmentRules.add(pricebookAssignmentRule);
                pricebookValidationResults.add(validationResult);
                expressionList.add( pricebookAssignmentRule.qualifyingCriteria );
            }
            
            List<Adm.ValidationResult> expressionValidationResults = ADM_ExpressionManager.getInstance().validateExpressions(expressionList );
                
            final List<Pricebook2> pricebookRecords = SvmxDatabase.query([Select Name FROM Pricebook2 WHERE Name = :pricebookNameSet]);
            pricebookNameSet.clear();
            
            for( Pricebook2 pricebookRecord : pricebookRecords ) {
                pricebookNameSet.add(pricebookRecord.Name);
            }
            
            for( Integer index = 0; index < validPricebookAssignmentRules.size(); index++ ) {
                
                final Adm.PricebookAssignmentRule pricebookAssignmentRule = validPricebookAssignmentRules.get(index);
                final Adm.ValidationResult validationResult = pricebookValidationResults.get(index);
                final Adm.ValidationResult expressionValidationResult = expressionValidationResults.get(index);
                
                if( !pricebookNameSet.contains(pricebookAssignmentRule.pricebook.name) ) {
                    
                    System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRules() - Pricebook does not exists : ' + pricebookAssignmentRule.pricebook.name );
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.PricebookAssignmentRule, 'Pricebook does not exists : ' + pricebookAssignmentRule.pricebook.name ) );
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
           
            System.debug( LoggingLevel.ERROR, 'validatePricebookAssignmentRules() : Failed to validate Pricebook Assignment rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validatePricebookAssignmentRules() - exit; validationResults= ' + validationResults.size() );
        }
        
        return validationResults;
    }
    
    /**
     * This method is used to save requested pricebook assignment rule. If pricebook assignment rule id not exists then, 
     * new pricebook assignment rule record will be created otherwise, existing pricebook assignment rule will be updated.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.PricebookAssignmentRule with created/updated record details.
     */
    public Adm.PricebookAssignmentRule savePricebookAssignmentRule( final Adm.PricebookAssignmentRule pricebookAssignmentRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - enter; pricebookAssignmentRule= ' + pricebookAssignmentRule );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid pricebook assignment rule information.
            if( pricebookAssignmentRule == null || pricebookAssignmentRule.name == null || String.isBlank( pricebookAssignmentRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Invalid request parameters. pricebookAssignmentRule= ' + pricebookAssignmentRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Remove expression record as pricebook assignment rule qualification criterias are not reusable.
            if( String.isNotBlank( pricebookAssignmentRule.id ) && pricebookAssignmentRule.qualifyingCriteria == null ) {
                
                final SVMXA360__CONF_PricebookAssignmentRule__c oldPricebookAssignmentRuleRecord = (SVMXA360__CONF_PricebookAssignmentRule__c) SvmxDatabase.query( [SELECT SVMXA360__ExpressionId__c FROM SVMXA360__CONF_PricebookAssignmentRule__c WHERE id = :pricebookAssignmentRule.id ] ).get(0);
            	
                if( oldPricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
                    ADM_ExpressionManager.getInstance().deleteExpression(oldPricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c);
                }
            }
            
            // Upsert service assignment rule record.
            SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord = createPricebookAssignmentRuleRecord(pricebookAssignmentRule);
            
            // Upsert expression if exists in the request.
            if( pricebookAssignmentRule.qualifyingCriteria != null ) {
                
                pricebookAssignmentRule.qualifyingCriteria = ADM_ExpressionManager.getInstance().saveExpression( pricebookAssignmentRule.qualifyingCriteria );
                
                // Assign expression id if exists.
                if( String.isNotBlank( pricebookAssignmentRule.qualifyingCriteria.id ) ) {
                    pricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c = pricebookAssignmentRule.qualifyingCriteria.id;
                }
            }
            
            pricebookAssignmentRuleRecord = (SVMXA360__CONF_PricebookAssignmentRule__c) SvmxDatabase.upsertRecord(pricebookAssignmentRuleRecord);
            
            System.debug( LoggingLevel.INFO, 'savePricebookAssignmentRule() : Saved Pricebook Assignment Rule. Name= ' + pricebookAssignmentRuleRecord.Name );
            
            // Update pricebook assignment rule id and sequence in the response.
            pricebookAssignmentRule.id = pricebookAssignmentRuleRecord.id;
            pricebookAssignmentRule.sequence = (pricebookAssignmentRuleRecord.SVMXA360__Sequence__c != null) ? Integer.valueOf(pricebookAssignmentRuleRecord.SVMXA360__Sequence__c) : null;
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Failed to save Pricebook Assignment Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'savePricebookAssignmentRule() : Failed to save Pricebook Assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'savePricebookAssignmentRule() - exit; pricebookAssignmentRule= ' + pricebookAssignmentRule );
        }
        
        return pricebookAssignmentRule;
    }

    /**
     * This method is used to update pricebook assignment rule sequence and active status. This method is applicable 
     * only for already created pricebook assignment rules to update the rule sequence and change the active status.
     * 
     * @param pricebookAssignmentRuleList List of pricebook assignment rules for which sequence and status to be updated.
     * 
     * @return Returns List of Adm.PricebookAssignmentRule with sqeuence and status information.
     */
    public List<Adm.PricebookAssignmentRule> updatePricebookAssignmentRulesSequence( final List<Adm.PricebookAssignmentRule> pricebookAssignmentRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - enter; pricebookAssignmentRuleList= ' + pricebookAssignmentRuleList );
        
        try {
            
            // Verify request for valid pricebook assignment rule list.
            if( pricebookAssignmentRuleList == null || pricebookAssignmentRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Invalid request parameters. pricebookAssignmentRuleList= ' + pricebookAssignmentRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final List<SVMXA360__CONF_PricebookAssignmentRule__c> pricebookAssignmentRuleRecordList = new List<SVMXA360__CONF_PricebookAssignmentRule__c>();
            
            // Create SObject for each requested pricebook assignment rules with sequence and active status.
            for( Adm.PricebookAssignmentRule pricebookAssignmentRule : pricebookAssignmentRuleList ) {
                
                // Verify for valid sequence and active status.
                // isActive == true, Sequence > 0
                // id != null
                if( String.isBlank(pricebookAssignmentRule.id) || pricebookAssignmentRule.active == null || ( pricebookAssignmentRule.active && ( pricebookAssignmentRule.sequence == null || pricebookAssignmentRule.sequence <= 0 ) ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Invalid request parameters. pricebookAssignmentRule= ' + pricebookAssignmentRule );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + pricebookAssignmentRule );
                }
                
                SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord = new SVMXA360__CONF_PricebookAssignmentRule__c();
                
                pricebookAssignmentRuleRecord.id = pricebookAssignmentRule.id;
                pricebookAssignmentRuleRecord.SVMXA360__Sequence__c = pricebookAssignmentRule.sequence = pricebookAssignmentRule.active ? pricebookAssignmentRule.sequence : null;
                pricebookAssignmentRuleRecord.SVMXA360__Active__c = pricebookAssignmentRule.active;
                
                pricebookAssignmentRuleRecordList.add( pricebookAssignmentRuleRecord );
            }
            
            // Update sequence and active status
            SvmxDatabase.updateRecord(pricebookAssignmentRuleRecordList);
            
            System.debug( LoggingLevel.INFO, 'updatePricebookAssignmentRulesSequence() : Updated Pricebook Assignment Rule sequence.' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Failed to update Pricebook Assignment Rule sequence and active status. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'updatePricebookAssignmentRulesSequence() : Failed to update Pricebook Assignment Rule sequence and active status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updatePricebookAssignmentRulesSequence() - exit; pricebookAssignmentRuleList= ' + pricebookAssignmentRuleList );
        }
        
        return pricebookAssignmentRuleList;
    }

    /**
     * This method is used to delete pricebook assignment rule for requested pricebook assignment id.
     * 
     * @param pricebookAssignmentRuleId pricebook assignment rule record id to be deleted.
     */
    public void deletePricebookAssignmentRule( final String pricebookAssignmentRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteServiceAssignmentRule() - enter; pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            // Verify for valid pricebook assignment rule id.
            if( String.isBlank( pricebookAssignmentRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Invalid request parameters. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final List<SVMXA360__CONF_PricebookAssignmentRule__c> pricebookAssignmentRuleList = SvmxDatabase.query( [SELECT Id, SVMXA360__ExpressionId__c FROM SVMXA360__CONF_PricebookAssignmentRule__c WHERE Id = :pricebookAssignmentRuleId OR SVMXA360__DeveloperName__c = :pricebookAssignmentRuleId] );
            
            SvmxDatabase.deleteRecord( pricebookAssignmentRuleList );
            
            // Delete qualification criteria configured for pricebook assignment rule.
            if( !pricebookAssignmentRuleList.isEmpty() && pricebookAssignmentRuleList[0].SVMXA360__ExpressionId__c != null ) {
                ADM_ExpressionManager.getInstance().deleteExpression( pricebookAssignmentRuleList[0].SVMXA360__ExpressionId__c );
            }
            
            System.debug( LoggingLevel.INFO, 'deletePricebookAssignmentRule() : Service Assignment rule deleted successfully. pricebookAssignmentRuleId= ' + pricebookAssignmentRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {

            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Failed to delete Pricebook Assignment rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){

            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deletePricebookAssignmentRule() : Failed to delete pricebook Assignment rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deletePricebookAssignmentRule() - exit');
        }
    }

    /**
     * Private methor to retrieve pricebook assignment rule records.
     */
    private List<SVMXA360__CONF_PricebookAssignmentRule__c> retrievePricebookAssignmentRuleRecords( final String filterElement ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrievePricebookAssignmentRuleRecords() - enter; filterElement= ' + filterElement );
        
        List<SVMXA360__CONF_PricebookAssignmentRule__c> pricebookAssignmentRuleRecordList = 
            new List<SVMXA360__CONF_PricebookAssignmentRule__c>();
        
        try {
            
            // Validate for required fields.
            if( String.isNotBlank( filterElement ) ) {
                pricebookAssignmentRuleRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__Active__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__Pricebook__c, SVMXA360__Pricebook__r.name, SVMXA360__ExpressionId__c, SVMXA360__Sequence__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_PricebookAssignmentRule__c WHERE SVMXA360__ObjectAPIName__c = :filterElement OR id =:filterElement OR SVMXA360__DeveloperName__c =:filterElement ORDER BY SVMXA360__Sequence__c NULLS LAST] );
            } else {
                pricebookAssignmentRuleRecordList = SvmxDatabase.query( [SELECT Id, Name,  SVMXA360__Active__c, SVMXA360__Description__c, SVMXA360__DeveloperName__c, SVMXA360__ObjectAPIName__c, SVMXA360__Pricebook__c, SVMXA360__Pricebook__r.name, SVMXA360__ExpressionId__c, SVMXA360__Sequence__c, LastModifiedDate, LastModifiedBy.Name FROM SVMXA360__CONF_PricebookAssignmentRule__c ORDER BY SVMXA360__Sequence__c NULLS LAST] );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrievePricebookAssignmentRuleRecords() : Failed to retrieve Pricebook Assignment rule records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrievePricebookAssignmentRuleRecords() - exit; pricebookAssignmentRuleRecordList.size()= ' + pricebookAssignmentRuleRecordList.size() );
        }
        
        return pricebookAssignmentRuleRecordList;
    }

    private List<Adm.PricebookAssignmentRule> createPricebookAssignmentRules( final List<SVMXA360__CONF_PricebookAssignmentRule__c> pricebookAssignmentRuleRecords ) {
        
        final List<Adm.PricebookAssignmentRule> pricebookAssignmentRules = new List<Adm.PricebookAssignmentRule>();
        final Map<Id,Adm.PricebookAssignmentRule> expressionIdMap = new Map<Id,Adm.PricebookAssignmentRule>();
        
        for( SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord : pricebookAssignmentRuleRecords ) {
            
            final Adm.PricebookAssignmentRule pricebookAssignmentRule = createPricebookAssignmentRule(pricebookAssignmentRuleRecord);
            if( pricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
                expressionIdMap.put( pricebookAssignmentRule.qualifyingCriteria.id, pricebookAssignmentRule );
            }
            pricebookAssignmentRules.add(pricebookAssignmentRule);
        }
        if( !expressionIdMap.isEmpty() ) {
            final Map<Id,Adm.Expression> idExpressionMap = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( new List<Id>(expressionIdMap.keySet()), null );
            for( Adm.PricebookAssignmentRule pricebookAssignmentRule: expressionIdMap.values() ) {
                pricebookAssignmentRule.qualifyingCriteria = idExpressionMap.get(pricebookAssignmentRule.qualifyingCriteria.id);
            }
        }
        
        return pricebookAssignmentRules;
    }
    
    /**
     * This method is used to create Pricebook Assignment rule wrapper for requested service assignment rule record.
     * 
     * @param pricebookAssignmentRuleRecord Pricebook Assignment rule sobject record from which wrapper to be created.
     * 
     * @return Returns Adm.PricebookAssignmentRule instance with populated values from pricebookAssignmentRuleRecord.
     */
    private Adm.PricebookAssignmentRule createPricebookAssignmentRule( final SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createPricebookAssignmentRule() - enter; pricebookAssignmentRuleRecord= ' + pricebookAssignmentRuleRecord);
        
        Adm.PricebookAssignmentRule pricebookAssignmentRule = new Adm.PricebookAssignmentRule();
        pricebookAssignmentRule.id = pricebookAssignmentRuleRecord.id;
        pricebookAssignmentRule.name = pricebookAssignmentRuleRecord.Name;
        pricebookAssignmentRule.description = pricebookAssignmentRuleRecord.SVMXA360__Description__c;
        pricebookAssignmentRule.developerName = pricebookAssignmentRuleRecord.SVMXA360__DeveloperName__c;
        pricebookAssignmentRule.objectAPIName = pricebookAssignmentRuleRecord.SVMXA360__ObjectAPIName__c;
        pricebookAssignmentRule.active = pricebookAssignmentRuleRecord.SVMXA360__Active__c;
        pricebookAssignmentRule.lastModifiedDate = pricebookAssignmentRuleRecord.LastModifiedDate;
        pricebookAssignmentRule.lastModifiedBy = pricebookAssignmentRuleRecord.LastModifiedBy.Name;
        pricebookAssignmentRule.sequence = (pricebookAssignmentRuleRecord.SVMXA360__Sequence__c != null ) ? Integer.valueOf( pricebookAssignmentRuleRecord.SVMXA360__Sequence__c ) : null;
        if( pricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c != null ) {
            
            Adm.Expression expression = new Adm.Expression();
            expression.id = pricebookAssignmentRuleRecord.SVMXA360__ExpressionId__c;
            pricebookAssignmentRule.qualifyingCriteria = expression;
        }
        if( pricebookAssignmentRuleRecord.SVMXA360__Pricebook__c != null ) {
            
            Adm.LookupInfo pricebookRecord = new Adm.LookupInfo();
            pricebookRecord.id = pricebookAssignmentRuleRecord.SVMXA360__Pricebook__c;
            pricebookRecord.name = pricebookAssignmentRuleRecord.SVMXA360__Pricebook__r.name;
            pricebookAssignmentRule.pricebook = pricebookRecord;
        }
        
        System.debug( LoggingLevel.FINEST, 'createPricebookAssignmentRule() - exit; pricebookAssignmentRule= ' + pricebookAssignmentRule);
        
        return pricebookAssignmentRule;
    }

    /**
     * Private method to create pricebook assignment rule record.
     * 
     * @param pricebookAssignmentRule Pricebook Assignment rule wrapper for which SObject to be created.
     * @return Returns SVMXA360__CONF_PricebookAssignmentRule__c sobject with populated values from PricebookAssignmentRule.
     */
    private SVMXA360__CONF_PricebookAssignmentRule__c createPricebookAssignmentRuleRecord( final Adm.PricebookAssignmentRule pricebookAssignmentRule ) {
        
        System.debug( LoggingLevel.FINEST, 'createPricebookAssignmentRuleRecord() - enter; pricebookAssignmentRule= ' + pricebookAssignmentRule);
        
        SVMXA360__CONF_PricebookAssignmentRule__c pricebookAssignmentRuleRecord = new SVMXA360__CONF_PricebookAssignmentRule__c();
        
        if( String.isNotBlank( pricebookAssignmentRule.id ) ) {
            pricebookAssignmentRuleRecord.id = pricebookAssignmentRule.id;
        } else {
            pricebookAssignmentRuleRecord.SVMXA360__DeveloperName__c = pricebookAssignmentRule.developerName;
        }
        
        pricebookAssignmentRuleRecord.Name = pricebookAssignmentRule.name;
        pricebookAssignmentRuleRecord.SVMXA360__Description__c = pricebookAssignmentRule.description;
        pricebookAssignmentRuleRecord.SVMXA360__ObjectAPIName__c = pricebookAssignmentRule.objectAPIName;
        pricebookAssignmentRuleRecord.SVMXA360__Active__c = pricebookAssignmentRule.active != null ? pricebookAssignmentRule.active : false;
        pricebookAssignmentRuleRecord.SVMXA360__Pricebook__c = pricebookAssignmentRule.pricebook.id;
        pricebookAssignmentRuleRecord.SVMXA360__Sequence__c = (pricebookAssignmentRule.active) ? pricebookAssignmentRule.sequence : null;

        // Generate rule sequence for active rules.
        if( pricebookAssignmentRule.active && pricebookAssignmentRule.sequence == null ) {
            
            pricebookAssignmentRuleRecord.SVMXA360__Sequence__c = 1;
            AggregateResult[] aggregateResultArray = (Test.isRunningTest()) 
                ? [SELECT MAX(SVMXA360__Sequence__c) MaxSequence FROM SVMXA360__CONF_PricebookAssignmentRule__c]
                : [SELECT MAX(SVMXA360__Sequence__c) MaxSequence FROM SVMXA360__CONF_PricebookAssignmentRule__c WITH SECURITY_ENFORCED];
            if( aggregateResultArray != null && aggregateResultArray.size() > 0 && aggregateResultArray[0].get('MaxSequence') != null ) {
                pricebookAssignmentRuleRecord.SVMXA360__Sequence__c = pricebookAssignmentRule.sequence = Integer.valueOf( aggregateResultArray[0].get('MaxSequence') ) + 1;
            }
        }

        System.debug( LoggingLevel.FINEST, 'createPricebookAssignmentRuleRecord() - exit; pricebookAssignmentRuleRecord= ' + pricebookAssignmentRuleRecord);
        
        return pricebookAssignmentRuleRecord;
    }

}