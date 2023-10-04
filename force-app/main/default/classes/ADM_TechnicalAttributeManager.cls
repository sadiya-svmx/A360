/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class defines services to retrieve/edit/save/delete Match Rules.
 *
 * @author Mahima Tarika
 * @version 1.0
 * @since 2022 
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 A360AM-1926 Mahima Tarika      30 July 2022      Created.
 *****************************************************************************************************/
/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_TechnicalAttributeManager {
    private static ADM_TechnicalAttributeManager instance;
    private static final String TILDE = '~';
    private ADM_TechnicalAttributeManager(){

    }
    public static ADM_TechnicalAttributeManager getInstance () {
        if(instance == null){
            return new ADM_TechnicalAttributeManager();
        } else {
            return instance;
        }
    }

    /**
     * This method is used to retrieve all the Match Rules.
     * 
     * @return Returns List of all Match Rules exists in the database.
     */
    public list<Adm.TechnicalAttributeMatchRule> getAllTechnicalAttributeMatchRules () {
        System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeMatchRules() - enter' );
        
        list<Adm.TechnicalAttributeMatchRule> matchRuleList = new list<Adm.TechnicalAttributeMatchRule>();
        
        try {
            
            // Retrieve all Match Rules
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > masterMatchRuleRecordList = new list<SVMXA360__CONF_TA_TemplateMatchRule__c>();
            
            masterMatchRuleRecordList = SvmxDatabase.query( [SELECT Id, Name, LastModifiedDate, LastModifiedBy.Name, SVMXA360__Sequence__c, SVMXA360__DeveloperName__c, 
                                                                SVMXA360__Description__c, SVMXA360__RuleName__c, SVMXA360__AdvancedCriteria__c,SVMXA360__MatchRuleCriteria__c,SVMXA360__AdvancedCriteriaType__c
                                                                 FROM SVMXA360__CONF_TA_TemplateMatchRule__c WHERE SVMXA360__RuleType__c = 'Master' order by SVMXA360__Sequence__c nulls last] );
            if( masterMatchRuleRecordList.size() > 0 ) {

                matchRuleList = createMatchRulesWrapper (masterMatchRuleRecordList);
                
                System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeMatchRules() : Retrieved all Technical Attributes' );
            } 
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getAllTechnicalAttributeMatchRules() : Failed to retrieve Technical Attributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllTechnicalAttributeMatchRules() - exit; matchRulesPageRec= ' + matchRuleList );
        }
        
        return matchRuleList;
    }

    /**
     * This method is used to retrieves master the Match Rule record with detail records.
     * 
     * @return Returns List of all Match Rules exists in the database.
     */
    public Adm.TechnicalAttributeMatchRule getTechnicalAttributeTemplateRuleDetail (string recordId) {
        System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateRuleDetail() - enter' );
        
        Adm.TechnicalAttributeMatchRule matchRuleDetailRec = new Adm.TechnicalAttributeMatchRule();
        
        try {
            
            // Retrieve all Match Rules
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > masterMatchRuleRecordList = new list<SVMXA360__CONF_TA_TemplateMatchRule__c>();
            masterMatchRuleRecordList = SvmxDatabase.query( [SELECT Id, LastModifiedDate, LastModifiedBy.Name, SVMXA360__Description__c, SVMXA360__RuleName__c, SVMXA360__Sequence__c, SVMXA360__AdvancedCriteria__c, SVMXA360__MatchRuleCriteria__c, SVMXA360__AdvancedCriteriaType__c,SVMXA360__DeveloperName__c,
                                                                (SELECT id, SVMXA360__Sequence__c, SVMXA360__FieldDataType__c,SVMXA360__ObjectApiName__c, SVMXA360__FieldApiName__c, SVMXA360__OperandObjectApiName__c, SVMXA360__OperandFieldApiName__c, SVMXA360__RelatedObjectDetail__c, SVMXA360__ReferenceFieldsLabel__c from 	SVMXA360__Technical_Attribute_Template_Match_Rules__r) FROM SVMXA360__CONF_TA_TemplateMatchRule__c WHERE SVMXA360__RuleType__c = 'Master' AND id=: recordId order by SVMXA360__Sequence__c] );
            
            if( masterMatchRuleRecordList.size() > 0 ) {

                matchRuleDetailRec = createMatchRuleDetailWrapper(masterMatchRuleRecordList[0]);
                
                System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateRuleDetail() : Retrieved all Technical Attributes'+ matchRuleDetailRec );
            }
        }
        
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getTechnicalAttributeTemplateRuleDetail() : Failed to retrieve Technical Attributes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        
        finally {
            System.debug( LoggingLevel.DEBUG, 'getTechnicalAttributeTemplateRuleDetail() - exit; matchRulesPageRec= ' + recordId );
        }
        
        return matchRuleDetailRec;
    }

    /**
     * This method is used to create the Match Rules record wrapper from records.
     * 
     * @return Returns List of wrapper of all master Match Rules in the database.
     */
    private Adm.TechnicalAttributeMatchRule createMatchRuleDetailWrapper (SVMXA360__CONF_TA_TemplateMatchRule__c ruleRecord) {
        System.debug( LoggingLevel.FINEST, 'createMatchRuleDetailWrapper() - enter; masterMatchRuleRecord= ' + ruleRecord);

        Adm.TechnicalAttributeMatchRule matchRuleMasterRecord = new Adm.TechnicalAttributeMatchRule();
        matchRuleMasterRecord.id = ruleRecord.id;
        matchRuleMasterRecord.name = ruleRecord.SVMXA360__RuleName__c;
        matchRuleMasterRecord.lastModifiedDate = ruleRecord.LastModifiedDate;
        matchRuleMasterRecord.lastModifiedBy = ruleRecord.LastModifiedBy.Name;
        matchRuleMasterRecord.ruleName = ruleRecord.SVMXA360__RuleName__c;
        matchRuleMasterRecord.description = ruleRecord.SVMXA360__Description__c;
        matchRuleMasterRecord.advancedCriteria = ruleRecord.SVMXA360__AdvancedCriteria__c;
        matchRuleMasterRecord.ruleCriteria = ruleRecord.SVMXA360__MatchRuleCriteria__c;
        matchRuleMasterRecord.selectionCondition = ruleRecord.SVMXA360__AdvancedCriteriaType__c;
        matchRuleMasterRecord.developerName = ruleRecord.SVMXA360__DeveloperName__c;
        matchRuleMasterRecord.sequence = ruleRecord.SVMXA360__Sequence__c;

        list<Adm.TechnicalAttributeMatchRuleDetails> matchRuleDetailRecordList = new list<Adm.TechnicalAttributeMatchRuleDetails>();
        for (SVMXA360__CONF_TA_TemplateMatchRule__c rec : ruleRecord.SVMXA360__Technical_Attribute_Template_Match_Rules__r) {
            Adm.TechnicalAttributeMatchRuleDetails matchRuleRec= new Adm.TechnicalAttributeMatchRuleDetails();
            matchRuleRec.id = rec.id;
            matchRuleRec.sequence = rec.SVMXA360__Sequence__c;
            matchRuleRec.objectAPIName = rec.SVMXA360__ObjectApiName__c;
            matchRuleRec.objectFieldAPIName = rec.SVMXA360__FieldApiName__c;
            matchRuleRec.operandObjectAPIName = rec.SVMXA360__OperandObjectApiName__c;
            matchRuleRec.operandFieldAPIName = rec.SVMXA360__OperandFieldApiName__c;
            matchRuleRec.relatedObjectDetails = rec.SVMXA360__RelatedObjectDetail__c;
            matchRuleRec.referenceFieldLabel = rec.SVMXA360__ReferenceFieldsLabel__c;
            matchRuleRec.operator = 'Equals';
            matchRuleRec.fieldType = rec.SVMXA360__FieldDataType__c;
            matchRuleDetailRecordList.add(matchRuleRec);
        }
        matchRuleMasterRecord.matchRuleDetails = matchRuleDetailRecordList;
        System.debug( LoggingLevel.FINEST, 'createMatchRuleDetailWrapper() - enter; ruleDetailPageRec= ' + matchRuleMasterRecord);
        return matchRuleMasterRecord;
    }
    /**
     * This method is used to create the Match Rules record wrapper from records.
     * 
     * @return Returns List of wrapper of all master Match Rules in the database.
     */
    private list<Adm.TechnicalAttributeMatchRule> createMatchRulesWrapper (list<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleList) {
        System.debug( LoggingLevel.FINEST, 'createMatchRulesWrapper() - enter; matchRuleList= ' + matchRuleList);
    
        list<Adm.TechnicalAttributeMatchRule> matchRuleRecordList = new list<Adm.TechnicalAttributeMatchRule>();
        for (SVMXA360__CONF_TA_TemplateMatchRule__c rec : matchRuleList) {
            Adm.TechnicalAttributeMatchRule matchRuleRec= new Adm.TechnicalAttributeMatchRule();
            matchRuleRec.id = rec.id;
            matchRuleRec.name = rec.SVMXA360__RuleName__c;
            matchRuleRec.lastModifiedDate = rec.LastModifiedDate;
            matchRuleRec.lastModifiedBy = rec.LastModifiedBy.Name;
            matchRuleRec.sequence = rec.SVMXA360__Sequence__c;
            matchRuleRec.description = rec.SVMXA360__Description__c;
            matchRuleRec.ruleName = rec.SVMXA360__RuleName__c;
            matchRuleRec.advancedCriteria = rec.SVMXA360__AdvancedCriteria__c;
            matchRuleRec.ruleCriteria = rec.SVMXA360__MatchRuleCriteria__c;
            matchRuleRec.selectionCondition = rec.SVMXA360__AdvancedCriteriaType__c;
            matchRuleRec.developerName = rec.SVMXA360__DeveloperName__c;
            matchRuleRecordList.add(matchRuleRec);
        }
        System.debug( LoggingLevel.FINEST, 'createMatchRulesWrapper() - enter; matchRuleRecordList= ' + matchRuleRecordList);
        return matchRuleRecordList;
    }

    /**
     * This method is used to create the Match Rules records from wrapper.
     * 
     * @return Returns List of all master Match Rules received from GUI.
     */
    private list<SVMXA360__CONF_TA_TemplateMatchRule__c> createMatchRulesRecords (list<Adm.TechnicalAttributeMatchRule> matchRuleList ) {
        System.debug( LoggingLevel.FINEST, 'createMatchRulesRecords() - enter; matchRuleList= ' + matchRuleList);
    
        list<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleRecordList = new list<SVMXA360__CONF_TA_TemplateMatchRule__c>();
        for (Adm.TechnicalAttributeMatchRule rec : matchRuleList) {
            SVMXA360__CONF_TA_TemplateMatchRule__c matchRuleRec= new SVMXA360__CONF_TA_TemplateMatchRule__c();
            if(rec.id != null) {
                matchRuleRec.id = id.valueOf(rec.id);
            }
            matchRuleRec.SVMXA360__Sequence__c = rec.sequence;
            matchRuleRec.SVMXA360__Description__c = rec.description;
            matchRuleRec.SVMXA360__RuleName__c = rec.ruleName;
            matchRuleRec.SVMXA360__AdvancedCriteria__c = rec.advancedCriteria;
            matchRuleRec.SVMXA360__MatchRuleCriteria__c = rec.ruleCriteria;
            matchRuleRec.SVMXA360__AdvancedCriteriaType__c = rec.selectionCondition;
            matchRuleRec.SVMXA360__DeveloperName__c = rec.developerName;
            matchRuleRecordList.add(matchRuleRec);
        }
        System.debug( LoggingLevel.FINEST, 'createMatchRulesRecords() - enter; matchRuleRecordList= ' + matchRuleRecordList);

        return matchRuleRecordList;
    }

    /**
     * This method is used to create the Match Rules records from wrapper.
     * 
     * @return Returns List of all master Match Rules received from GUI.
     */
    private list<SVMXA360__CONF_TA_TemplateMatchRule__c> createDetailMatchRuleRecords (list<Adm.TechnicalAttributeMatchRuleDetails> matchRuleList ) {
        System.debug( LoggingLevel.FINEST, 'createDetailMatchRuleRecords() - enter; matchRuleList= ' + matchRuleList);
    
        list<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleRecordList = new list<SVMXA360__CONF_TA_TemplateMatchRule__c>();
        for (Adm.TechnicalAttributeMatchRuleDetails rec : matchRuleList) {
            SVMXA360__CONF_TA_TemplateMatchRule__c matchRuleRec= new SVMXA360__CONF_TA_TemplateMatchRule__c();
            if(rec.id != null && !rec.id.contains('newRow')){
                matchRuleRec.id = id.valueOf(rec.id);
            }
            matchRuleRec.SVMXA360__Sequence__c = rec.sequence;
            matchRuleRec.SVMXA360__ObjectApiName__c = rec.objectAPIName;
            matchRuleRec.SVMXA360__FieldApiName__c = rec.objectFieldAPIName;
            matchRuleRec.SVMXA360__OperandObjectApiName__c = rec.operandObjectAPIName;
            matchRuleRec.SVMXA360__OperandFieldApiName__c = rec.operandFieldAPIName;
            matchRuleRec.SVMXA360__RelatedObjectDetail__c = rec.relatedObjectDetails;
            matchRuleRec.SVMXA360__ReferenceFieldsLabel__c = rec.referenceFieldLabel;
            matchRuleRec.SVMXA360__FieldDataType__c = rec.fieldType;
            matchRuleRecordList.add(matchRuleRec);
        }
        System.debug( LoggingLevel.FINEST, 'createDetailMatchRuleRecords() - enter; matchRuleRecordList= ' + matchRuleRecordList);

        return matchRuleRecordList;
    }

    /**
     * This method is used to validate expression and expression details.
     * 
     * @param expression Expresssion with list of expression details to be validated.
     */
    public Adm.ValidationResult validateTechnicalAttributeMatchRule( Adm.TechnicalAttributeMatchRule technicalAttributeMatchRule ) {
        return validateTechnicalAttributeMatchRules( new List<Adm.TechnicalAttributeMatchRule>{technicalAttributeMatchRule}).get(0);
    }
    
    /**
     * This method is used to validate expression and expression details.
     * 
     * @param expressions List of expresssions with expression details to be validated.
     */
    public List<Adm.ValidationResult> validateTechnicalAttributeMatchRules( List<Adm.TechnicalAttributeMatchRule> technicalAttributeMatchRuleList ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateTechnicalAttributeMatchRules() - enter');
        
        List<Adm.ValidationResult> validationResults = new List<Adm.ValidationResult>();
        
        try {
            
            final Map<String,Common.EntityDefinition> entityDefinitionMap = new Map<String,Common.EntityDefinition>();
            
            for( Adm.TechnicalAttributeMatchRule technicalAttributeMatchRule : technicalAttributeMatchRuleList ) {
                
                for( Adm.TechnicalAttributeMatchRuleDetails technicalAttributeMatchRuleDetail : technicalAttributeMatchRule.matchRuleDetails ) {
                    
                    final Adm.ValidationResult validationResult = new Adm.ValidationResult( Adm.ConfigurationType.TechnicalAttribute );
                    validationResults.add( validationResult );
                    
                    Common.EntityDefinition entityDefinition = entityDefinitionMap.get(technicalAttributeMatchRuleDetail.operandObjectAPIName);
                    
                    if( String.isNotBlank(technicalAttributeMatchRuleDetail.operandObjectAPIName) && !entityDefinitionMap.containsKey(technicalAttributeMatchRuleDetail.operandObjectAPIName) ) {
                        
                        try {
                            final Common.EntityDefinition sourceEntityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(technicalAttributeMatchRuleDetail.operandObjectAPIName);
                            entityDefinitionMap.put( sourceEntityDefinition.apiName, sourceEntityDefinition );
                            entityDefinition = entityDefinitionMap.get(technicalAttributeMatchRuleDetail.operandObjectAPIName);
                        }
                        catch( SvmxSystem.SvmxNestedException e ) {
                            
                            validationResult.setError('Source Object does not exists: ' + technicalAttributeMatchRuleDetail.operandObjectAPIName);
                            continue;
                        }
                    }
                    
                    if( String.isNotBlank(technicalAttributeMatchRuleDetail.objectAPIName) && !entityDefinitionMap.containsKey(technicalAttributeMatchRuleDetail.objectAPIName) ) {
                        
                        try {
                            final Common.EntityDefinition sourceEntityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(technicalAttributeMatchRuleDetail.objectAPIName);
                            entityDefinitionMap.put( sourceEntityDefinition.apiName, sourceEntityDefinition );
                        }
                        catch( SvmxSystem.SvmxNestedException e ) {
                            
                            validationResult.setError('Object does not exists: ' + technicalAttributeMatchRuleDetail.objectAPIName);
                            continue;
                        }
                    }
                    
                    if( entityDefinition != null ) {
                        
                        Common.FieldDefinition fieldDefinition = entityDefinition.fieldDefinitionsByApiName.containsKey(technicalAttributeMatchRuleDetail.operandFieldAPIName.toLowerCase()) 
                        ? entityDefinition.fieldDefinitionsByApiName.get(technicalAttributeMatchRuleDetail.operandFieldAPIName.toLowerCase())
                        : entityDefinition.fieldDefinitionsByApiName.get(technicalAttributeMatchRuleDetail.operandFieldAPIName.toLowerCase() + 'id' );
                    
                        if( fieldDefinition == null ) {
                            
                            System.debug( LoggingLevel.ERROR, 'validateCriteria() - Object : '+ entityDefinition.label + ', Field does not exists : ' + technicalAttributeMatchRuleDetail.operandFieldAPIName );
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.TechnicalAttribute, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + technicalAttributeMatchRuleDetail.operandFieldAPIName ) );
                        }
                    }
                    
                    validateRuleFields( validationResult, entityDefinitionMap, technicalAttributeMatchRuleDetail.objectAPIName, technicalAttributeMatchRuleDetail.objectFieldAPIName );
                }
            }
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTechnicalAttributeMatchRules() : Failed to validate Technical Attribute Match rules. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'validateTechnicalAttributeMatchRules() : Failed to validate Technical Attribute Match rules. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'validateTechnicalAttributeMatchRules() - exit');
        }
        
        return validationResults;
    }
    
    private void validateRuleFields( final Adm.ValidationResult validationResult, final Map<String,Common.EntityDefinition> entityDefinitionMap, final String objectAPIName, String fieldAPIName ) {
        
        System.debug( LoggingLevel.DEBUG, 'validateRuleFields() - enter');
        
        Common.EntityDefinition entityDefinition = entityDefinitionMap.get(objectAPIName);
        
        if( fieldAPIName.indexOf('.') != -1 ) {
            
            final List<String> referenceObjects = fieldAPIName.split('\\.');
            if( referenceObjects.size() > 0 ) {
                fieldAPIName = referenceObjects[ referenceObjects.size() - 1 ];
            }
            
            for ( String referenceObject : referenceObjects ) {
                
                String objectName = referenceObject;
                
                if ( fieldAPIName != referenceObject ) {
                    
                    if ( referenceObject.endsWith('__r') ) {
                        objectName = referenceObject.replace('__r', '__c');
                    }
                    
                    Common.FieldDefinition fieldDefinition = entityDefinition.fieldDefinitionsByApiName.containsKey(objectName.toLowerCase()) 
                        ? entityDefinition.fieldDefinitionsByApiName.get(objectName.toLowerCase())
                        : entityDefinition.fieldDefinitionsByApiName.get(objectName.toLowerCase() + 'id' );
                    
                    if( fieldDefinition == null ) {
                        
                        System.debug( LoggingLevel.ERROR, 'validateRuleFields() - Object : '+ entityDefinition.label + ', Field does not exists : ' + objectName );
                        validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.TechnicalAttribute, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + objectName ) );
                        break;
                    }
                    
                    objectName = fieldDefinition.referenceTo[ fieldDefinition.referenceTo.size() - 1 ];
                    
                    if ( !entityDefinitionMap.containsKey(objectName) ) {
                        
                        try {
                            final Common.EntityDefinition referenceEntityDefinition = COMM_MetadataManager.getInstance().getFieldDefinitions(objectName);
                            entityDefinitionMap.put( referenceEntityDefinition.apiName, referenceEntityDefinition );
                        }
                        catch( SvmxSystem.SvmxNestedException e ) {
                            
                            System.debug( LoggingLevel.ERROR, 'validateRuleFields() - Object does not exists : '+ objectName );
                            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.TechnicalAttribute, 'Object does not exists : '+ objectName ) ); //TODO Create custom label
                            break;
                        }
                    }
                    
                    entityDefinition = entityDefinitionMap.get(objectName);
                }
            }
        }
        
        if( entityDefinition != null && !entityDefinition.fieldDefinitionsByApiName.containsKey( fieldAPIName.toLowerCase() ) ) {
            
            System.debug( LoggingLevel.ERROR, 'validateRuleFields() - Object : '+ entityDefinition.label + ', Field does not exists : ' + fieldAPIName );
            validationResult.addDetailResult( new Adm.ValidationResult( Adm.ConfigurationType.TechnicalAttribute, 'Object : '+ entityDefinition.label + ', Field does not exists : ' + fieldAPIName ) );
        }
        
        System.debug( LoggingLevel.DEBUG, 'validateRuleFields() - exit');
    }
    
    /**
     * This method is used to create the Match Rules.
     * 
     * @return Returns List of all master Match Rules updated.
     */
    public list<Adm.TechnicalAttributeMatchRule> saveTemplateRulesSequence (final list<Adm.TechnicalAttributeMatchRule> matchRuleList ) {
        System.debug( LoggingLevel.DEBUG, 'saveTemplateRulesSequence() - enter; = matchRulePage' + matchRuleList );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            
            // Verify request for valid Technical Attribute informations.
            if( matchRuleList == null ) {
             
                System.debug( LoggingLevel.ERROR, 'saveTemplateRulesSequence() : Invalid request parameters. matchRulePage= ' + matchRuleList );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            SvmxDatabase.updateRecord(createMatchRulesRecords(matchRuleList));
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTemplateRulesSequence() : Failed to save match rule sequence. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTemplateRulesSequence() : Failed to save match rule sequence. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTemplateRulesSequence() - exit; match rule sequence= ' + matchRuleList );
        }
        
        return matchRuleList;
    }
    
    /**
     * This method is used to delete the Match Rule record.
     * 
     * @return Returns List of all master Match Rules updated.
     */
    public void deleteMatchRuleRecord ( final string matchRuleId ) {
        System.debug( LoggingLevel.DEBUG, 'deleteMatchRuleRecord() - enter; = matchRuleId' + matchRuleId );
        Savepoint sPoint = Database.setSavepoint();
		try {
            
            // Verify request for valid Technical Attribute informations.
            if( matchRuleId == null ) {
             
                System.debug( LoggingLevel.ERROR, 'deleteMatchRuleRecord() : Invalid request parameters. matchRuleRecord= ' + matchRuleId );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            SvmxDatabase.deleteRecord([SELECT id from SVMXA360__CONF_TA_TemplateMatchRule__c where id =: matchRuleId or SVMXA360__MatchRuleMaster__c =: matchRuleId]);
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deleteMatchRuleRecord() : Failed to delete match rule sequence. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'deleteMatchRuleRecord() : Failed to delete match rule sequence. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'deleteMatchRuleRecord() - exit; match rule sequence= ' + matchRuleId );
        }
    }

    /**
     * This method is used to create the Match Rules.
     * 
     * @return Returns List of all master Match Rules updated.
     */
    public Adm.TechnicalAttributeMatchRule saveTechnicalAttributeTemplateRule ( Adm.TechnicalAttributeMatchRule matchRulePage ) {
        System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateRule() - enter; = matchRulePage' + matchRulePage );
        
        Savepoint sPoint = Database.setSavepoint();
        
        try {
            // Verify request for valid Technical Attribute informations.
            if ( matchRulePage == null ) {
             
                System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateRule() : Invalid request parameters. matchRulePage= ' + matchRulePage );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }
            
            if( String.isBlank(matchRulePage.id) && String.isBlank(matchRulePage.developerName)  ) {
                
                System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateRule() : Invalid request parameters. developerName= ' + matchRulePage.developerName );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.MISSING_REQUIRED_PARAMETER );
            }
            
            mapAdvancedCriteriaToRuleCriteria (matchRulePage);
            list<SVMXA360__CONF_TA_TemplateMatchRule__c> masterMatchRuleRec = createMatchRulesRecords(new list<Adm.TechnicalAttributeMatchRule>{matchRulePage});
            populateFieldsOnMaster(masterMatchRuleRec[0],matchRulePage);
            SvmxDatabase.upsertRecord(masterMatchRuleRec[0]);
            matchRulePage.id = masterMatchRuleRec[0].id;
            if ( !matchRulePage.matchRuleDetails.isEmpty() ) {
                list<SVMXA360__CONF_TA_TemplateMatchRule__c> matchRuleList = createDetailMatchRuleRecords(matchRulePage.matchRuleDetails);
                for(SVMXA360__CONF_TA_TemplateMatchRule__c child : matchRuleList){
                    child.id=null;
                    child.SVMXA360__MatchRuleMaster__c = masterMatchRuleRec[0].id;
                    child.SVMXA360__RuleType__c = 'Detail';
                }
                SvmxDatabase.deleteRecord([SELECT id from SVMXA360__CONF_TA_TemplateMatchRule__c where SVMXA360__MatchRuleMaster__c =: matchRulePage.id]);
                SvmxDatabase.upsertRecord(matchRuleList);
                for(integer i = 0; i < matchRuleList.size(); i++) {
                    matchRulePage.matchRuleDetails[i].id = matchRuleList[i].id;
                }
            }
            
        }
        catch(SvmxSystem.SvmxNestedException e ) {
            
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateRule() : Failed to save match rule sequence. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
           
            Database.rollback( sPoint );
            
            System.debug( LoggingLevel.ERROR, 'saveTechnicalAttributeTemplateRule() : Failed to save match rule sequence. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'saveTechnicalAttributeTemplateRule() - exit; match rule sequence= ' + matchRulePage );
        }
        
        return matchRulePage;
    }

    private void populateFieldsOnMaster (SVMXA360__CONF_TA_TemplateMatchRule__c masterRecord, Adm.TechnicalAttributeMatchRule pageDetails) {
        masterRecord.SVMXA360__RuleType__c = 'Master';
        masterRecord.SVMXA360__ObjectApiName__c = !pageDetails.matchRuleDetails.isEmpty() ? pageDetails.matchRuleDetails[0].objectAPIName : '';
    }

    public void mapAdvancedCriteriaToRuleCriteria (Adm.TechnicalAttributeMatchRule matchRuleRecord) {
        for(Adm.TechnicalAttributeMatchRuleDetails rule : matchRuleRecord.matchRuleDetails) {
            string sequence = string.valueOf(rule.sequence);
            matchRuleRecord.advancedCriteria = matchRuleRecord.advancedCriteria.replace(sequence,TILDE+sequence+TILDE);
        }
        matchRuleRecord.ruleCriteria = matchRuleRecord.advancedCriteria;
        for(Adm.TechnicalAttributeMatchRuleDetails rule : matchRuleRecord.matchRuleDetails){
            string clause = '('+rule.operandFieldAPIName+' != NULL AND '+rule.operandFieldAPIName +'='+rule.objectAPIName+'.'+rule.objectFieldAPIName+')';
            string temp = matchRuleRecord.ruleCriteria;
            matchRuleRecord.ruleCriteria = temp.replace(TILDE+string.valueOf(rule.sequence)+TILDE, clause);
        }
        matchRuleRecord.advancedCriteria = matchRuleRecord.advancedCriteria.replace(TILDE,'');
        //COMM_ExpressionUtils.getInstance().verifyQueryClause(matchRuleRecord.masterMatchRuleRecord.ruleCriteria, 'SVMXA360__SM_TA_TemplateAssociation__c');
    }
    
}