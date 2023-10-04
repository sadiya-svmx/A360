@IsTest
public class ADM_TechnicalAttributeManager_UT {
    
    @testSetup public static void setup() {

        final List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = (List<SVMXA360__CONF_TA_TemplateMatchRule__c >) SvmxTestDataFactory.createSObjectList('SVMXA360__CONF_TA_TemplateMatchRule__c', 4);
        List<SVMXA360__CONF_TA_TemplateMatchRule__c > masterRecList = new List<SVMXA360__CONF_TA_TemplateMatchRule__c >();
        for( Integer index = 0; index < 3; index++ ) {
            matchRuleList.get(index).SVMXA360__Description__c  = 'Test_MatchRule_Name'+index;
            matchRuleList.get(index).SVMXA360__RuleType__c  = 'Master';
            matchRuleList.get(index).SVMXA360__RuleName__c  = 'Account'+index;
            matchRuleList.get(index).SVMXA360__Sequence__c  = index;
            matchRuleList.get(index).SVMXA360__AdvancedCriteria__c = '1';
            matchRuleList.get(index).SVMXA360__MatchRuleCriteria__c = 'SVMXA360__ProductId__r.Name=Asset.Name';
            masterRecList.add(matchRuleList[index]);
        }
        
        insert masterRecList;
        matchRuleList[3].SVMXA360__ReferenceFieldsLabel__c = 'Asset Name';
        matchRuleList[3].SVMXA360__FieldApiName__c  = 'Name';
        matchRuleList[3].SVMXA360__OperandFieldApiName__c  = 'SVMXA360__ProductId__r.Name';
        matchRuleList[3].SVMXA360__ObjectApiName__c  = 'Asset';
        matchRuleList[3].SVMXA360__OperandObjectApiName__c   = 'SVMXA360__SM_TA_TemplateAssociation__c';
        matchRuleList[3].SVMXA360__MatchRuleMaster__c = masterRecList[0].id;
        insert matchRuleList[3];                                                                     
    }

    testmethod static void testGetAllMatchRules() { 
        
        Common.ServiceResponse resp = ADM_TechnicalAttribute_LS.getAllMatchRules();
        list<Adm.TechnicalAttributeMatchRule> pageData = (list<Adm.TechnicalAttributeMatchRule>)resp.data;
        System.assert( resp != null );
        System.assertEquals(4, pageData.size());
    }

    testmethod static void testSaveMatchRuleSequenceSettings() {
        try {
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = [select id, name, SVMXA360__Sequence__c, SVMXA360__Description__c, SVMXA360__RuleName__c from SVMXA360__CONF_TA_TemplateMatchRule__c where SVMXA360__RuleType__c = 'Master'];
            list<Adm.TechnicalAttributeMatchRule> matchRuleRecords = new list<Adm.TechnicalAttributeMatchRule>();
            Adm.TechnicalAttributeMatchRule rec = new Adm.TechnicalAttributeMatchRule(); 
            rec.id = matchRuleList[0].id;
            rec.description = matchRuleList[0].SVMXA360__Description__c;
            rec.ruleName = matchRuleList[0].SVMXA360__RuleName__c;
            rec.sequence = 2;
            
            matchRuleRecords.add(rec);
            rec = new Adm.TechnicalAttributeMatchRule(); 
            rec.id = matchRuleList[1].id;
            rec.description = matchRuleList[1].SVMXA360__Description__c;
            rec.ruleName = matchRuleList[1].SVMXA360__RuleName__c;
            rec.sequence = 1;
            matchRuleRecords.add(rec);
            
            rec = new Adm.TechnicalAttributeMatchRule(); 
            rec.id = matchRuleList[2].id;
            rec.description = matchRuleList[2].SVMXA360__Description__c;
            rec.ruleName = matchRuleList[2].SVMXA360__RuleName__c;
            rec.sequence = 3;
            matchRuleRecords.add(rec);
            final string jsonReq = JSON.serialize(matchRuleRecords);
            Common.ServiceResponse resp = ADM_TechnicalAttribute_LS.saveTemplateRulesSequence(jsonReq);
            System.assert( resp != null );
            list<Adm.TechnicalAttributeMatchRule> pageData = (list<Adm.TechnicalAttributeMatchRule>)resp.data;
            System.assertEquals( 3, pageData.size());
        } catch (Exception e) {
            system.assert( e!= null );
        }
    }
    
    testmethod static void testgetMatchRuleDetails() {
        try{
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = [select id, name, SVMXA360__Sequence__c, SVMXA360__Description__c, SVMXA360__RuleName__c from SVMXA360__CONF_TA_TemplateMatchRule__c where SVMXA360__RuleType__c = 'Master' order by SVMXA360__Sequence__c];
            Common.ServiceResponse resp = ADM_TechnicalAttribute_LS.getTechnicalAttributeTemplateRuleDetail(matchRuleList[0].id);
            Adm.TechnicalAttributeMatchRule pageData = (Adm.TechnicalAttributeMatchRule)resp.data;
            system.assert(pageData != null);
        } catch (Exception e ) {
            System.assert( e != null );
        }
       
    }
    
    testmethod static void testSaveMatchRuleDetails() {
        try {
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = [select id, SVMXA360__AdvancedCriteria__c,
                                                                           SVMXA360__MatchRuleCriteria__c,SVMXA360__Sequence__c, 
                                                                           SVMXA360__Description__c, SVMXA360__RuleName__c,
                                                                           (select id,SVMXA360__ReferenceFieldsLabel__c,SVMXA360__FieldApiName__c,SVMXA360__OperandFieldApiName__c,
                                                                            SVMXA360__ObjectApiName__c,SVMXA360__OperandObjectApiName__c, SVMXA360__RelatedObjectDetail__c 
                                                                           from SVMXA360__Technical_Attribute_Template_Match_Rules__r)
                                                                           from SVMXA360__CONF_TA_TemplateMatchRule__c where SVMXA360__RuleType__c = 'Master'];
            
            Adm.TechnicalAttributeMatchRule masterMatchRuleRecords = new Adm.TechnicalAttributeMatchRule();
            masterMatchRuleRecords.advancedCriteria = matchRuleList[0].SVMXA360__AdvancedCriteria__c;
            masterMatchRuleRecords.description = matchRuleList[0].SVMXA360__Description__c;
            masterMatchRuleRecords.ruleName = matchRuleList[0].SVMXA360__RuleName__c;
            masterMatchRuleRecords.ruleCriteria = matchRuleList[0].SVMXA360__MatchRuleCriteria__c;
            masterMatchRuleRecords.selectionCondition = 'AllConditionsMet';
            
			List<Adm.TechnicalAttributeMatchRuleDetails> childRecList = new  List<Adm.TechnicalAttributeMatchRuleDetails> ();
            Adm.TechnicalAttributeMatchRuleDetails rec = new Adm.TechnicalAttributeMatchRuleDetails();
            rec.sequence = 1;
            rec.objectAPIName = matchRuleList[0].SVMXA360__Technical_Attribute_Template_Match_Rules__r[0].SVMXA360__ObjectApiName__c;
            rec.objectFieldAPIName = matchRuleList[0].SVMXA360__Technical_Attribute_Template_Match_Rules__r[0].SVMXA360__FieldApiName__c;
            rec.operandObjectAPIName = matchRuleList[0].SVMXA360__Technical_Attribute_Template_Match_Rules__r[0].SVMXA360__OperandObjectApiName__c;
            rec.operandFieldAPIName = matchRuleList[0].SVMXA360__Technical_Attribute_Template_Match_Rules__r[0].SVMXA360__OperandFieldApiName__c;
            rec.relatedObjectDetails = matchRuleList[0].SVMXA360__Technical_Attribute_Template_Match_Rules__r[0].SVMXA360__RelatedObjectDetail__c;
            rec.referenceFieldLabel = matchRuleList[0].SVMXA360__Technical_Attribute_Template_Match_Rules__r[0].SVMXA360__ReferenceFieldsLabel__c;
            childRecList.add(rec);
            masterMatchRuleRecords.matchRuleDetails = childRecList;
            
            final string jsonReq = JSON.serialize(masterMatchRuleRecords);
            Common.ServiceResponse resp = ADM_TechnicalAttribute_LS.saveTechnicalAttributeTemplateRule(jsonReq);
            System.assert( resp != null );
            
        } catch (Exception e) {
            system.assert( e!= null );
        }
    }
    

    testmethod static void testDeleteRowAction() {
        try{
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = [select id, name, SVMXA360__Sequence__c, SVMXA360__Description__c, SVMXA360__RuleName__c from SVMXA360__CONF_TA_TemplateMatchRule__c];
            string idToDelete = matchRuleList[0].id;
            Common.ServiceResponse resp = ADM_TechnicalAttribute_LS.deleteMatchRuleRecord(idToDelete);
            resp = ADM_TechnicalAttribute_LS.deleteMatchRuleRecord(null);
        } catch (Exception e ) {
            System.assert( e != null );
        }
        
       
    }
    
    testmethod static void testException() {
        try{
            List<SVMXA360__CONF_TA_TemplateMatchRule__c > matchRuleList = [select id, name, SVMXA360__Sequence__c, SVMXA360__Description__c, SVMXA360__RuleName__c from SVMXA360__CONF_TA_TemplateMatchRule__c where SVMXA360__RuleType__c = 'Master'];
            list<Adm.TechnicalAttributeMatchRule> matchRuleRecords = new list<Adm.TechnicalAttributeMatchRule>();
            Adm.TechnicalAttributeMatchRule rec = new Adm.TechnicalAttributeMatchRule();
            rec.id = matchRuleList[0].id;
            rec.description = matchRuleList[0].SVMXA360__Description__c;
            rec.ruleName = matchRuleList[0].SVMXA360__RuleName__c;
            rec.sequence = 2;
            
            matchRuleRecords.add(rec);
            rec = new Adm.TechnicalAttributeMatchRule(); 
            rec.id = matchRuleList[1].id;
            rec.description = matchRuleList[1].SVMXA360__Description__c;
            rec.ruleName = matchRuleList[1].SVMXA360__RuleName__c;
            rec.sequence = 1;
            matchRuleRecords.add(rec);
            
            rec = new Adm.TechnicalAttributeMatchRule(); 
            rec.id = null;
            rec.description = matchRuleList[2].SVMXA360__Description__c;
            rec.ruleName = matchRuleList[2].SVMXA360__RuleName__c;
            rec.sequence = 3;
            matchRuleRecords.add(rec);
            final string jsonReq = JSON.serialize(matchRuleRecords);
            Common.ServiceResponse resp = ADM_TechnicalAttribute_LS.saveTemplateRulesSequence(jsonReq);
            System.assert( resp != null );
            list<Adm.TechnicalAttributeMatchRule> pageData = (list<Adm.TechnicalAttributeMatchRule>)resp.data;
            System.assertEquals( 3, pageData.size());
        } catch(Exception e ) {
            system.debug('e'+e);
        }
        
        }
        
       
    
}