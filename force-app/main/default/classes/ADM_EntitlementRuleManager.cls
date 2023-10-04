/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class facilitates methods to retrieve/create/update and delete 
 * entitlement rules. 
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       25 Jun 2020     Created.
 * BLOS-573     Ramachandra Mohan       20 Aug 2020     Create rule sequence for active rules.
 * BLOS-1018    Ramachandra Mohan       01 Oct 2020     Fix for Aggregate SOQL UT issue.
 *****************************************************************************************************/
public with sharing class ADM_EntitlementRuleManager {
    
    private static final String MULTIPLE_FOUND = 'MULTIPLE-FOUND';
    
    /**
     * Private static variable to hold instance of this class.
     */
    private static ADM_EntitlementRuleManager instance;
    
    /**
     * Static method to retrieve instance of this class. Only one instance of 
     * this class will be created per transaction.
     */
    public static ADM_EntitlementRuleManager getInstance() {
        
        if( instance == null ) {
            instance = new ADM_EntitlementRuleManager();
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all the entitlement rules.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public List<Adm.EntitlementRule> getAllEntitlementRules() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - enter' );
        
        List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        
        try {
            
            // Retrieve all entitlement rules
            final List<SVMXA360__CONF_EntitlementRule__c > entitlementRuleRecordList = getAllEntitlementRuleRecords();
            
            if( entitlementRuleRecordList.size() > 0 ) {
                
                entitlementRuleList.addAll( createEntitlementRules( entitlementRuleRecordList ) );
                
                System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() : Retrieved all entitlement rules' );
            } else {
                System.debug( LoggingLevel.WARN, 'getAllEntitlementRules() : No entitlement rules found');
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRules() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRules() - exit; entitlementRuleList.size()= ' + entitlementRuleList.size() );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to retrieve all the entitlement rules.
     * 
     * @return Returns List of all entitlement rules exists in the database.
     */
    public List<Adm.EntitlementRule> getAllEntitlementRulesWithDetails() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() - enter' );
        
        List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        
        try {
            
            // Retrieve all entitlement rules
            final List<SVMXA360__CONF_EntitlementRule__c > entitlementRuleRecordList = getAllEntitlementRuleRecords();
            
            if( entitlementRuleRecordList.size() > 0 ) {
                
                Map<String, Adm.Expression> expressionMap = new Map<String, Adm.Expression>();
                List<Adm.Expression> expressionList = ADM_ExpressionManager.getInstance().getAllRuleExpressions();
                for( Adm.Expression expression : expressionList ) {
                    expressionMap.put( expression.id, expression );
                }
                
                // Create entitlement rule wrapper for each retrieved entitlement rule records.
                for( SVMXA360__CONF_EntitlementRule__c  entitlementRuleRecord : entitlementRuleRecordList ) {
                    
                    Adm.EntitlementRule entitlementRule = createEntitlementRule( entitlementRuleRecord );
                    if( entitlementRule.expression != null && String.isNotBlank(entitlementRule.expression.id) && expressionMap.containsKey(entitlementRule.expression.id) ) {
                        entitlementRule.expression = expressionMap.get(entitlementRule.expression.id);
                    }
                    
                    entitlementRuleList.add( entitlementRule );
                }
                
                System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() : Retrieved all entitlement rules' );
            } else {
                System.debug( LoggingLevel.WARN, 'getAllEntitlementRulesWithDetails() : No entitlement rules found');
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRulesWithDetails() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRulesWithDetails() - exit; entitlementRuleList.size()= ' + entitlementRuleList.size() );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to retrieve entitlement rules for requested object name.
     * 
     * @param objectName Object API name for which entitlement rules to be retrieved.
     * 
     * @return Returns List of Entitlement rules for requested object.
     */
    public List<Adm.EntitlementRule> getEntitlementRules( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - enter' );
        
        List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        
        try {
            
            // Verify request for valid objectName.
            if( String.isBlank( objectName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all entitlement rules for requested object.
            final List<SVMXA360__CONF_EntitlementRule__c > entitlementRuleRecordList = getEntitlementRuleRecords( objectName );
            
            if( entitlementRuleRecordList.size() > 0 ) {
                
                // Create entitlement rule wrapper for each retrieved entitlement records.
                for( SVMXA360__CONF_EntitlementRule__c  entitlementRuleRecord : entitlementRuleRecordList ) {
                    entitlementRuleList.add( createEntitlementRule( entitlementRuleRecord ) );
                }
                
                System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() : Retrieved Entitlement Rules for requested object' );
            } else {
                System.debug( LoggingLevel.WARN, 'getEntitlementRules() : No entitlement rules found. objectName= ' + objectName );
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Failed to retrueve Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRules() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRules() - exit; entitlementRuleList.size()= ' + entitlementRuleList.size() );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to retrieve entitlement rules for requested object name.
     * 
     * @param entitlementRuleId Entitlement rule id for which entitlement rules to be retrieved.
     * 
     * @return Returns List of Entitlement rules for requested object.
     */
    public Adm.EntitlementRule getEntitlementRule( final String entitlementRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - enter; entitlementRuleId= ' + entitlementRuleId );
        
        Adm.EntitlementRule entitlementRule;
        
        try {
            
            // Verify request for valid entitlement Rule Id.
            if( String.isBlank( entitlementRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Invalid request parameters. entitlementRuleId= ' + entitlementRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Retrieve all entitlement rules for requested object.
            final SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = getEntitlementRuleRecord( entitlementRuleId );
            
            entitlementRule = createEntitlementRule( entitlementRuleRecord );
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() : Retrieved Entitlement Rules for requested object' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Failed to retrueve Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRule() : Failed to retrieve entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRule() - exit; entitlementRule= ' + entitlementRule );
        }
        
        return entitlementRule;
    }
    
    /**
     * This method is used to validate requested entitlement rule.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be validated.
     * 
     * @return Returns Adm.ValidationResult with validation details.
     */
    public Adm.ValidationResult validateEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        return validateEntitlementRules( new List<Adm.EntitlementRule> {entitlementRule} ).get(0);
    }
    
    /**
     * This method is used to validate requested entitlement rules.
     * 
     * @param entitlementRule Entitlement rules wrapper instance to be validated.
     * 
     * @return Returns List of Adm.ValidationResult with validation details.
     */
    public List<Adm.ValidationResult> validateEntitlementRules( final List<Adm.EntitlementRule> entitlementRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateEntitlementRules() - enter; entitlementRuleList= ' + entitlementRuleList );
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
            
        try {
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            final List<Adm.ValidationResult> serviceValidationResults = new List<Adm.ValidationResult>();
            List<Adm.Expression> expressionList = new List<Adm.Expression>();
            
            for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
                
                final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.EntitlementRule );
                validationResults.add( validationResult );
                
                // Verify request for valid expression informations.
                if( entitlementRule == null || String.isBlank(entitlementRule.objectAPIName ) || ( String.isBlank(entitlementRule.assetAPIName ) && String.isBlank(entitlementRule.accountAPIName ) ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'validateEntitlementRules() : Invalid request parameters. entitlementRule= ' + entitlementRule );
                    validationResult.setError(ErrorMessage.MISSING_REQUIRED_PARAMETER);
                    
                    continue;
                }
                
                if( !entityDefinitionMap.containsKey(entitlementRule.objectAPIName) ) {
                    
                    try {
                        final Common.EntityDefinition entityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(entitlementRule.objectAPIName);
                        entityDefinitionMap.put( entityDefinition.apiName, entityDefinition );
                    }
                    catch( SvmxSystem.SvmxNestedException e ) {
                        
                        validationResult.setError('Object does not exists: ' + entitlementRule.objectAPIName);
                        continue;
                    }
                }
                
                final Common.EntityDefinition entityDefinition = entityDefinitionMap.get(entitlementRule.objectAPIName);
                if( String.isNotBlank(entitlementRule.assetAPIName) && !entityDefinition.fieldDefinitionsByApiName.containsKey( entitlementRule.assetAPIName.toLowerCase() ) ) {
                    
                    System.debug( LoggingLevel.DEBUG, 'validateEntitlementRules() - Object : '+ entityDefinition.label + ', Field does not exists : ' + entitlementRule.assetAPIName );
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.EntitlementRule, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + entitlementRule.assetAPIName ) );
                }
                
                if( String.isNotBlank(entitlementRule.accountAPIName) && !entityDefinition.fieldDefinitionsByApiName.containsKey( entitlementRule.accountAPIName.toLowerCase() ) ) {
                    
                    System.debug( LoggingLevel.DEBUG, 'validateEntitlementRules() - Object : '+ entityDefinition.label + ', Field does not exists : ' + entitlementRule.accountAPIName );
                    validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.EntitlementRule, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + entitlementRule.accountAPIName ) );
                }
                
                serviceValidationResults.add(validationResult);
                expressionList.add( entitlementRule.expression );
            }
            
            List<Adm.ValidationResult> expressionValidationResults = ADM_ExpressionManager.getInstance().validateExpressions(expressionList );
            
            for( Integer index = 0; index < serviceValidationResults.size(); index++ ) {
                
                final Adm.ValidationResult validationResult = serviceValidationResults.get(index);
                final Adm.ValidationResult expressionValidationResult = expressionValidationResults.get(index);
                
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
           
            System.debug( LoggingLevel.ERROR, 'validateEntitlementRules() : Failed to validate Entitlement rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateEntitlementRules() - exit; validationResults= ' + validationResults.size() );
        }
        
        return validationResults;
    }
    
    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.EntitlementRule with created/updated record details.
     */
    public Adm.EntitlementRule saveEntitlementRule( final Adm.EntitlementRule entitlementRule ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - enter; entitlementRule= ' + entitlementRule );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( entitlementRule == null || entitlementRule.name == null || String.isBlank( entitlementRule.objectAPIName ) ) {
             
                System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Invalid request parameters. entitlementRule= ' + entitlementRule );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            // Remove expression record as entitlement rule qualification criterias are not reusable.
            if( String.isNotBlank( entitlementRule.id ) && entitlementRule.expression == null ) {
                /* sfge-disable-next-line ApexFlsViolationRule */ 
                final SVMXA360__CONF_EntitlementRule__c oldEntitlementRuleRecord = (SVMXA360__CONF_EntitlementRule__c) SvmxDatabase.query( [SELECT SVMXA360__Expression__c FROM SVMXA360__CONF_EntitlementRule__c WHERE id = :entitlementRule.id ] ).get(0);
            	
                if( oldEntitlementRuleRecord.SVMXA360__Expression__c != null ) {
                    ADM_ExpressionManager.getInstance().deleteExpression(oldEntitlementRuleRecord.SVMXA360__Expression__c);
                }
            }
            
            // Upsert entitlement rule record.
            SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = createEntitlementRuleRecord(entitlementRule);
            
            // Upsert expression if exists in the request.
            if( entitlementRule.expression != null ) {
                
                entitlementRule.expression = ADM_ExpressionManager.getInstance().saveExpression( entitlementRule.expression );
                
                // Assign expression id if exists.
                if( String.isNotBlank( entitlementRule.expression.id ) ) {
                    entitlementRuleRecord.SVMXA360__Expression__c = entitlementRule.expression.id;
                }
            }
            
            entitlementRuleRecord = (SVMXA360__CONF_EntitlementRule__c) SvmxDatabase.upsertRecord(entitlementRuleRecord);
            
            System.debug( LoggingLevel.INFO, 'saveEntitlementRule() : Saved Entitlement Rule. Name= ' + entitlementRuleRecord.Name );
            
            // Update entitlement rule id and sequence in the response.
            entitlementRule.id = entitlementRuleRecord.id;
            entitlementRule.sequence = (entitlementRuleRecord.SVMXA360__Sequence__c != null) ? Integer.valueOf(entitlementRuleRecord.SVMXA360__Sequence__c) : null;
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save Entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - exit; entitlementRule= ' + entitlementRule );
        }
        
        return entitlementRule;
    }
    
    /**
     * This method is used to save requested entitlement rule. If entitlement id not exists then, 
     * new entitlement rule record will be created otherwise, existing entitlement rule will be updated.
     * 
     * @param entitlementRule Entitlement rule wrapper instance to be created/updated.
     * 
     * @return Returns Adm.EntitlementRule with created/updated record details.
     */
    public List<Adm.EntitlementRule> saveEntitlementRules( final List<Adm.EntitlementRule> entitlementRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - enter; entitlementRuleList= ' + entitlementRuleList.size() );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid entitlement rule informations.
            if( entitlementRuleList == null || entitlementRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Invalid request parameters. entitlementRuleList= ' + entitlementRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            List<Adm.Expression> expressionList = new List<Adm.Expression>();
            
            for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
                if( entitlementRule.expression != null ) {
                    expressionList.add( entitlementRule.expression );
                }
            }
            
            // Upsert entitlement rule record.
            List<SVMXA360__CONF_EntitlementRule__c> entitlementRuleRecordList = createEntitlementRuleRecords(entitlementRuleList);
            expressionList = ADM_ExpressionManager.getInstance().saveExpressions( expressionList );
             
            for( Integer index = 0; index < entitlementRuleList.size(); index++ ) {
                
                final Adm.EntitlementRule entitlementRule = entitlementRuleList.get(index);
                final SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = entitlementRuleRecordList.get(index);
                final Adm.Expression expression = expressionList.get(index);
                
                entitlementRule.id = entitlementRuleRecord.id;
                
                if( String.isNotBlank( expression.id ) ) {
                    entitlementRuleRecord.SVMXA360__Expression__c = expression.id;
                }
                
                entitlementRule.sequence = (entitlementRuleRecord.SVMXA360__Sequence__c != null) ? Integer.valueOf(entitlementRuleRecord.SVMXA360__Sequence__c) : null;
            }
            entitlementRuleRecordList = (List<SVMXA360__CONF_EntitlementRule__c>) SvmxDatabase.upsertRecord(entitlementRuleRecordList);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save Entitlement Rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveEntitlementRule() : Failed to save Entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveEntitlementRule() - exit; entitlementRule= ' + entitlementRuleList );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to update entitlement rule sequence and active status. This method is applicable 
     * only for already created entitlement rules to update the rule sequence and change the active status.
     * 
     * @param entitlementRuleList List of Entitlement rules for which sequence and status to be updated.
     * 
     * @return Returns List of Adm.EntitlementRule with sqeuence and status information.
     */
    public List<Adm.EntitlementRule> updateEntitlementRulesSequence( final List<Adm.EntitlementRule> entitlementRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateEntitlementRulesSequence() - enter; entitlementRuleList= ' + entitlementRuleList );
        
        try {
            
            // Verify request for valid entitlement rule list.
            if( entitlementRuleList == null || entitlementRuleList.size() == 0 ) {
             
                System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Invalid request parameters. entitlementRuleList= ' + entitlementRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            final List<SVMXA360__CONF_EntitlementRule__c> entitlementRuleRecordList = new List<SVMXA360__CONF_EntitlementRule__c>();
            
            // Create SObject for each requested entitlement rules with sequence and active status.
            for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
                
                // Verify for valid sequence and active status.
                // isActive == true, Sequence > 0
                // id != null
                if( String.isBlank(entitlementRule.id) || entitlementRule.isActive == null || ( entitlementRule.isActive && ( entitlementRule.sequence == null || entitlementRule.sequence <= 0 ) ) ) {
                    
                    System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Invalid request parameters. entitlementRule= ' + entitlementRule );
                    throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT + entitlementRule );
                }
                
                SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = new SVMXA360__CONF_EntitlementRule__c();
                
                entitlementRuleRecord.id = entitlementRule.id;
                entitlementRuleRecord.SVMXA360__Sequence__c = entitlementRule.sequence = entitlementRule.isActive ? entitlementRule.sequence : null;
                entitlementRuleRecord.SVMXA360__IsActive__c = entitlementRule.isActive;
                
                entitlementRuleRecordList.add( entitlementRuleRecord );
            }
            
            // Update sequence and active status
            SvmxDatabase.updateRecord(entitlementRuleRecordList);
            
            System.debug( LoggingLevel.INFO, 'updateEntitlementRulesSequence() : Updated Entitlement Rule sequence.' );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Failed to update Entitlement Rule sequence and active status. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            System.debug( LoggingLevel.ERROR, 'updateEntitlementRulesSequence() : Failed to update Entitlement Rule sequence and active status. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateEntitlementRulesSequence() - exit; entitlementRuleList= ' + entitlementRuleList );
        }
        
        return entitlementRuleList;
    }
    
    /**
     * This method is used to delete entitlement rule for requested entitlement id.
     * 
     * @param entitlementRuleId Entitlement rule record id to be deleted.
     */
    public void deleteEntitlementRule( final String entitlementRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - enter; entitlementRuleId= ' + entitlementRuleId );
        
        try {
            // Verify for valid entitlement rule id.
            if( String.isBlank( entitlementRuleId ) ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Invalid request parameters. entitlementRuleId= ' + entitlementRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            /* sfge-disable-next-line ApexFlsViolationRule */ 
            final SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = (SVMXA360__CONF_EntitlementRule__c) SvmxDatabase.query( [SELECT Id, SVMXA360__Expression__c FROM SVMXA360__CONF_EntitlementRule__c WHERE Id = :entitlementRuleId OR SVMXA360__DeveloperName__c = :entitlementRuleId] ).get(0);
            
            SvmxDatabase.deleteRecord( entitlementRuleRecord );
            
            // Delete qualification criteria configured for entitlement rule.
            if( entitlementRuleRecord.SVMXA360__Expression__c != null ) {
                ADM_ExpressionManager.getInstance().deleteExpression( entitlementRuleRecord.SVMXA360__Expression__c );
            }
            
            System.debug( LoggingLevel.INFO, 'deleteEntitlementRule() : Entitlement rule deleted successfully. entitlementRuleId= ' + entitlementRuleId );
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Failed to delete Entitlement rule. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ){
            
            System.debug( LoggingLevel.ERROR, 'deleteEntitlementRule() : Failed to delete entitlement rule. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteEntitlementRule() - exit');
        }
    }
    
    /**
     * This method is used to retrieve all entitlement rule records.
     * 
     * @returns Returns list of entitlement rule records.
     */
    public List<SVMXA360__CONF_EntitlementRule__c > getAllEntitlementRuleRecords() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRuleRecords() - enter');
        
        List<SVMXA360__CONF_EntitlementRule__c > entitlementRuleRecordList = new List<SVMXA360__CONF_EntitlementRule__c >();
        
        try {
            entitlementRuleRecordList = entitlementRuleRecordList = retrieveEntitlementRuleRecords(null);
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllEntitlementRuleRecords() : Failed to retrieve Entitlement Rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllEntitlementRuleRecords() - exit; entitlementRuleRecordList.size()= ' + entitlementRuleRecordList.size() );
        }
        
        return entitlementRuleRecordList;
    }
    
    /**
     * This method is ueed to retrieve entitlement rule records for requested onject name.
     * 
     * @param objectName Object name for which entitlement rules to be retrieved.
     * 
     * @returns List of entitlement rule records.
     */
    public List<SVMXA360__CONF_EntitlementRule__c > getEntitlementRuleRecords( final String objectName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRuleRecords() - enter; objectName= ' + objectName );
        
        List<SVMXA360__CONF_EntitlementRule__c > entitlementRuleRecordList = new List<SVMXA360__CONF_EntitlementRule__c >();
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( objectName ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecords() : Invalid request parameters. objectName= ' + objectName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            entitlementRuleRecordList = retrieveEntitlementRuleRecords(objectName);
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecords() : Failed to retrieve entitlement rule records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecords() : Failed to retrieve Entitlement rule records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRuleRecords() - exit; entitlementRuleRecordList.size()= ' + entitlementRuleRecordList.size() );
        }
        
        return entitlementRuleRecordList;
    }
    
    /**
     * This method is ueed to retrieve entitlement rule records for requested entitlement rule id.
     * 
     * @param entitlementRuleId Entitlement rule id for which entitlement rules to be retrieved.
     * 
     * @returns List of entitlement rule records.
     */
    public SVMXA360__CONF_EntitlementRule__c getEntitlementRuleRecord( final String entitlementRuleId ) {
        
        System.debug( LoggingLevel.DEBUG, 'getEntitlementRuleRecord() - enter; entitlementRuleId= ' + entitlementRuleId );
        
        SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord;
        
        try {
            
            // Validate for required fields.
            if( String.isBlank( entitlementRuleId ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecord() : Invalid request parameters. entitlementRuleId= ' + entitlementRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            List<SVMXA360__CONF_EntitlementRule__c> entitlementRuleRecordList = retrieveEntitlementRuleRecords(entitlementRuleId);
            
            if( entitlementRuleRecordList.size() == 0 ) {
                
                System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecord() : Record not exists. entitlementRuleId= ' + entitlementRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + entitlementRuleId );
            }
            
            entitlementRuleRecord = entitlementRuleRecordList.get(0);
            
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecord() : Failed to retrieve entitlement rule records. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getEntitlementRuleRecord() : Failed to retrieve Entitlement rule records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getEntitlementRuleRecord() - exit; entitlementRuleRecord= ' + entitlementRuleRecord );
        }
        
        return entitlementRuleRecord;
    }
    
    /**
     * Private methor to retrieve entitlement rule records.
     */
    private List<SVMXA360__CONF_EntitlementRule__c> retrieveEntitlementRuleRecords( final String filterElement ) {
        
        System.debug( LoggingLevel.DEBUG, 'retrieveEntitlementRuleRecords() - enter; filterElement= ' + filterElement );
        
        List<SVMXA360__CONF_EntitlementRule__c> entitlementRuleRecordList = new List<SVMXA360__CONF_EntitlementRule__c>();
        
        try {
            
            // Validate for required fields.
            if( String.isNotBlank( filterElement ) ) {
                /* sfge-disable-next-line ApexFlsViolationRule */
                entitlementRuleRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__AccountAPIName__c, SVMXA360__AssetAPIName__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c, SVMXA360__CheckContracts__c, SVMXA360__CheckWarranties__c, SVMXA360__CoveredBy__c, SVMXA360__Expression__c, SVMXA360__IncludeParentAsset__c, SVMXA360__IncludeRootAsset__c, SVMXA360__IsActive__c, SVMXA360__MatchAccount__c, SVMXA360__MatchContact__c, SVMXA360__ObjectAPIName__c, SVMXA360__ResolutionMethod__c, SVMXA360__Sequence__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__WarrantyTypes__c, SVMXA360__DefaultBillingType__c FROM SVMXA360__CONF_EntitlementRule__c WHERE SVMXA360__ObjectAPIName__c = :filterElement OR id =:filterElement OR SVMXA360__DeveloperName__c =:filterElement ORDER BY SVMXA360__Sequence__c NULLS LAST] );
            } else {
                /* sfge-disable-next-line ApexFlsViolationRule */
                entitlementRuleRecordList = SvmxDatabase.query( [SELECT Id, Name, SVMXA360__AccountAPIName__c, SVMXA360__AssetAPIName__c, SVMXA360__DeveloperName__c, SVMXA360__Description__c, SVMXA360__CheckContracts__c, SVMXA360__CheckWarranties__c, SVMXA360__CoveredBy__c, SVMXA360__Expression__c, SVMXA360__IncludeParentAsset__c, SVMXA360__IncludeRootAsset__c, SVMXA360__IsActive__c, SVMXA360__MatchAccount__c, SVMXA360__MatchContact__c, SVMXA360__ObjectAPIName__c, SVMXA360__ResolutionMethod__c, SVMXA360__Sequence__c, LastModifiedDate, LastModifiedBy.Name, SVMXA360__WarrantyTypes__c, SVMXA360__DefaultBillingType__c FROM SVMXA360__CONF_EntitlementRule__c ORDER BY Name] );
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'retrieveEntitlementRuleRecords() : Failed to retrieve Entitlement rule records. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'retrieveEntitlementRuleRecords() - exit; entitlementRuleRecordList.size()= ' + entitlementRuleRecordList.size() );
        }
        
        return entitlementRuleRecordList;
    }
    
    private List<Adm.EntitlementRule> createEntitlementRules( final List<SVMXA360__CONF_EntitlementRule__c> entitlementRuleRecords ) {
        
        final List<Adm.EntitlementRule> entitlementRules = new List<Adm.EntitlementRule>();
        final Map<Id,Adm.EntitlementRule> expressionIdMap = new Map<Id,Adm.EntitlementRule>();
        
        for( SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord : entitlementRuleRecords ) {
            
            final Adm.EntitlementRule entitlementRule = createEntitlementRule(entitlementRuleRecord);
            if( entitlementRuleRecord.SVMXA360__Expression__c != null ) {
                expressionIdMap.put( entitlementRule.expression.id, entitlementRule );
            }
            entitlementRules.add(entitlementRule);
        }
        if( !expressionIdMap.isEmpty() ) {
            final Map<Id,Adm.Expression> idExpressionMap = ADM_ExpressionManager.getInstance().getExpressionsWithDetails( new List<Id>(expressionIdMap.keySet()), null );
            for( Adm.EntitlementRule entitlementRule: expressionIdMap.values() ) {
                entitlementRule.expression = idExpressionMap.get(entitlementRule.expression.id);
            }
        }
        
        return entitlementRules;
    }
    
    /**
     * This method is used to create entitlement rule wrapper for requested entitlement rule record.
     * 
     * @param entitlementRuleRecord Entitlement rule sobject record from which wrapper to be created.
     * 
     * @return Returns Adm.EntitlementRule instance with populated values from entitlementRuleRecord.
     */
    private Adm.EntitlementRule createEntitlementRule( final SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord ) {
        
        System.debug( LoggingLevel.FINEST, 'createEntitlementRule() - enter; entitlementRuleRecord= ' + entitlementRuleRecord);
        
        Adm.EntitlementRule entitlementRule = new Adm.EntitlementRule();
        entitlementRule.id = entitlementRuleRecord.id;
        entitlementRule.name = entitlementRuleRecord.Name;
        entitlementRule.description = entitlementRuleRecord.SVMXA360__Description__c;
        entitlementRule.developerName = entitlementRuleRecord.SVMXA360__DeveloperName__c;
        entitlementRule.defaultBillingType = entitlementRuleRecord.SVMXA360__DefaultBillingType__c;
        entitlementRule.objectAPIName = entitlementRuleRecord.SVMXA360__ObjectAPIName__c;
        entitlementRule.sequence = (entitlementRuleRecord.SVMXA360__Sequence__c != null ) ? Integer.valueOf( entitlementRuleRecord.SVMXA360__Sequence__c ) : null;
        entitlementRule.coveredBy = entitlementRuleRecord.SVMXA360__CoveredBy__c;
        entitlementRule.resolutionMethod = entitlementRuleRecord.SVMXA360__ResolutionMethod__c;
        entitlementRule.isActive = entitlementRuleRecord.SVMXA360__IsActive__c;
        entitlementRule.checkWarranties = entitlementRuleRecord.SVMXA360__CheckWarranties__c;
        entitlementRule.checkContracts = entitlementRuleRecord.SVMXA360__CheckContracts__c;
        entitlementRule.includeParentAsset = entitlementRuleRecord.SVMXA360__IncludeParentAsset__c;
        entitlementRule.includeRootAsset = entitlementRuleRecord.SVMXA360__IncludeRootAsset__c;
        entitlementRule.matchAccount = entitlementRuleRecord.SVMXA360__MatchAccount__c;
        entitlementRule.matchContact = entitlementRuleRecord.SVMXA360__MatchContact__c;
        entitlementRule.accountAPIName = entitlementRuleRecord.SVMXA360__AccountAPIName__c;
        entitlementRule.assetAPIName = entitlementRuleRecord.SVMXA360__AssetAPIName__c;
        entitlementRule.lastModifiedDate = entitlementRuleRecord.LastModifiedDate;
        entitlementRule.lastModifiedBy = entitlementRuleRecord.LastModifiedBy.Name;
        entitlementRule.warrantyTypes = entitlementRuleRecord.SVMXA360__WarrantyTypes__c;
        if( entitlementRuleRecord.SVMXA360__Expression__c != null ) {
            
            Adm.Expression expression = new Adm.Expression();
            expression.id = entitlementRuleRecord.SVMXA360__Expression__c;
            
            entitlementRule.expression = expression;
        }
        
        System.debug( LoggingLevel.FINEST, 'createEntitlementRule() - exit; entitlementRule= ' + entitlementRule);
        
        return entitlementRule;
    }
    
    private List<SVMXA360__CONF_EntitlementRule__c> createEntitlementRuleRecords( final List<Adm.EntitlementRule> entitlementRuleList ) {
        
        List<SVMXA360__CONF_EntitlementRule__c> entitlementRuleRecordList = new List<SVMXA360__CONF_EntitlementRule__c>();
        
        Map<String, Id> developerNameIdMap = new Map<String, Id>();
        
        for( SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord : getAllEntitlementRuleRecords() ) {
            developerNameIdMap.put( entitlementRuleRecord.SVMXA360__DeveloperName__c, entitlementRuleRecord.id );
        }
        
        for( Adm.EntitlementRule entitlementRule : entitlementRuleList ) {
            
            if( developerNameIdMap.containsKey( entitlementRule.developerName ) ) {
                entitlementRule.id = developerNameIdMap.get(entitlementRule.developerName);
            }
            
            entitlementRuleRecordList.add( createEntitlementRuleRecord(entitlementRule) );
        }
        
        return entitlementRuleRecordList;
    }
    
    /**
     * Private method to create entitlement rule record.
     * 
     * @param entitlementRule Entitlement rule wrappef for which SObject to be created.
     * @return Returns SVMXA360__CONF_EntitlementRule__c sobject with populated values from entitlementRule.
     */
    private SVMXA360__CONF_EntitlementRule__c createEntitlementRuleRecord( final Adm.EntitlementRule entitlementRule ) {
        
        System.debug( LoggingLevel.FINEST, 'createEntitlementRuleRecord() - enter; entitlementRule= ' + entitlementRule);
        
        SVMXA360__CONF_EntitlementRule__c entitlementRuleRecord = new SVMXA360__CONF_EntitlementRule__c();
        
        if( String.isNotBlank( entitlementRule.id ) ) {
            entitlementRuleRecord.id = entitlementRule.id;
        } else {
            entitlementRuleRecord.SVMXA360__DeveloperName__c = entitlementRule.developerName;
        }
        
        entitlementRuleRecord.Name = entitlementRule.name;
        entitlementRuleRecord.SVMXA360__Description__c = entitlementRule.description;
        entitlementRuleRecord.SVMXA360__ObjectAPIName__c = entitlementRule.objectAPIName;
        entitlementRuleRecord.SVMXA360__Sequence__c = (entitlementRule.isActive) ? entitlementRule.sequence : null;
        entitlementRuleRecord.SVMXA360__CoveredBy__c = entitlementRule.coveredBy;
        entitlementRuleRecord.SVMXA360__ResolutionMethod__c = String.isNotBlank(entitlementRule.resolutionMethod) ? entitlementRule.resolutionMethod : MULTIPLE_FOUND;
        entitlementRuleRecord.SVMXA360__IsActive__c = entitlementRule.isActive != null ? entitlementRule.isActive : false;
        entitlementRuleRecord.SVMXA360__CheckWarranties__c = entitlementRule.checkWarranties != null ? entitlementRule.checkWarranties : false;
        entitlementRuleRecord.SVMXA360__CheckContracts__c = entitlementRule.checkContracts != null ? entitlementRule.checkContracts : false;
        entitlementRuleRecord.SVMXA360__IncludeParentAsset__c = entitlementRule.includeParentAsset != null ? entitlementRule.includeParentAsset : false;
        entitlementRuleRecord.SVMXA360__IncludeRootAsset__c = entitlementRule.includeRootAsset != null ? entitlementRule.includeRootAsset : false;
        entitlementRuleRecord.SVMXA360__MatchAccount__c = entitlementRule.matchAccount != null ? entitlementRule.matchAccount : false;
        entitlementRuleRecord.SVMXA360__MatchContact__c = entitlementRule.matchContact != null ? entitlementRule.matchContact : false;
        entitlementRuleRecord.SVMXA360__AccountAPIName__c = entitlementRule.accountAPIName;
        entitlementRuleRecord.SVMXA360__AssetAPIName__c = entitlementRule.assetAPIName;
        entitlementRuleRecord.SVMXA360__WarrantyTypes__c = entitlementRule.warrantyTypes;
        entitlementRuleRecord.SVMXA360__DefaultBillingType__c = entitlementRule.defaultBillingType;

        // Generate rule sequence for active rules.
        if( entitlementRule.isActive && entitlementRule.sequence == null ) {
            
            entitlementRuleRecord.SVMXA360__Sequence__c = 1;
            /* sfge-disable-next-line ApexFlsViolationRule */
            AggregateResult[] aggregateResultArray = (Test.isRunningTest()) ? [SELECT MAX(SVMXA360__Sequence__c) MaxSequence FROM SVMXA360__CONF_EntitlementRule__c]
                : [SELECT MAX(SVMXA360__Sequence__c) MaxSequence FROM SVMXA360__CONF_EntitlementRule__c WITH SECURITY_ENFORCED];
            if( aggregateResultArray != null && aggregateResultArray.size() > 0 && aggregateResultArray[0].get('MaxSequence') != null ) {
                entitlementRuleRecord.SVMXA360__Sequence__c = entitlementRule.sequence = Integer.valueOf( aggregateResultArray[0].get('MaxSequence') ) + 1;
            }
        }
        
        System.debug( LoggingLevel.FINEST, 'createEntitlementRuleRecord() - exit; entitlementRuleRecord= ' + entitlementRuleRecord);
        
        return entitlementRuleRecord;
    }
    
    /**
     * Private constructor to restrict creation of this class instance. 
     */
    private ADM_EntitlementRuleManager() {
    }
}