@IsTest
public class ADM_WhereUsedManager_UT {

    @testSetup public static void setup() {


        //Mapping record creation
        SVMXA360__CONF_ObjectMapping__c objectMappingRecord = (SVMXA360__CONF_ObjectMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ObjectMapping__c', 
                                                                new Map<String,Object>{'SVMXA360__SourceObjectAPIName__c' => 'Case',
                                                                    'SVMXA360__TargetObjectAPIName__c' => 'WorkOrder',
                                                                    'SVMXA360__DeveloperName__c' => 'MAP001',
                                                                    'SVMXA360__Type__c' => 'Field Mapping'});
        //Mapping detail records creation                                                            
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_ObjectMappingDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ObjectMappingID__c' => objectMappingRecord.Id}, 
                                               5);
        
        //Expression record creation
        SVMXA360__CONF_Expression__c expressionRec = (SVMXA360__CONF_Expression__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Expression__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__DeveloperName__c' => COMM_DeveloperName.createDeveloperName( Common.Application.Expression )
                                                                                                                        });
        //Expression detail records creation                                                                                                                
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionDetail__c', 
                                               new Map<String,Object>{'SVMXA360__ExpressionId__c' => expressionRec.Id});
                                            
        //lookup configuration record creation
        SVMXA360__CONF_LookupConfiguration__c lookupConfigRecord = (SVMXA360__CONF_LookupConfiguration__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_LookupConfiguration__c', 
                                               new Map<String,Object>{'SVMXA360__BasicFilter__c' => expressionRec.Id, 'SVMXA360__ObjectAPIName__c' => 'Account'});
                                 
        //Transaction record creation
        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                               new Map<String,Object>{'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
                                                   'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__QualifyingCriteria__c' => expressionRec.Id,'SVMXA360__ScreenType__c' => 'Transaction','SVMXA360__FieldMapping__c' => objectMappingRecord.Id});
        
        //Screen record creation
        SVMXA360__CONF_Layout__c screenRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_Layout__c',
                                                   new Map<String,Object>{'SVMXA360__FieldSets__c' => '["fls1","fls2"]',
                                                       'SVMXA360__ObjectAPIName__c' => 'Account', 'SVMXA360__QualifyingCriteria__c' => expressionRec.Id,'SVMXA360__ScreenType__c' => 'Screen','SVMXA360__DeveloperName__c' => 'Default Text 1'});

        //Transaction header section record creation
        List<sObject> sobjectRecordList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutSection__c', 
                new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id}, 
                1);
        
        //Transaction related section records creation
        sobjectRecordList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutRelatedSection__c', 
        new Map<String,Object>{'SVMXA360__Layout__c' => pageLayoutRecord.Id, 'SVMXA360__FieldSets__c' => '["fls1","fls2"]', 'SVMXA360__ObjectAPIName__c' => 'Contact', 'SVMXA360__QualifyingCriteria__c' => expressionRec.Id,'SVMXA360__FieldMapping__c' => objectMappingRecord.Id}, 
        2));

        //Transaction element records creation
        List<sObject> elementList = SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                new Map<String,Object>{'SVMXA360__LayoutId__c' => pageLayoutRecord.Id,
                    'SVMXA360__Type__c' => 'Button'}, 3);


        for(sObject sobjectRecord : sobjectRecordList){
        if(sobjectRecord.getSObjectType() == SVMXA360__CONF_LayoutSection__c.getSObjectType()){
        elementList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                new Map<String,Object>{'SVMXA360__LayoutSection__c' => sobjectRecord.Id,
                    'SVMXA360__Type__c' => 'Field','SVMXA360__LookupConfiguration__c' => lookupConfigRecord.Id,'SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 4));
        }else{
        elementList.addAll(SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_LayoutElement__c', 
                new Map<String,Object>{'SVMXA360__LayoutRelatedSection__c' => sobjectRecord.Id,
                    'SVMXA360__Type__c' => 'Field','SVMXA360__LookupConfiguration__c' => lookupConfigRecord.Id,'SVMXA360__FormFillMappingId__c' => objectMappingRecord.Id}, 4));                
        }
        }

        for(sObject sobjectRecord : elementList){
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_SPMEvent__c', 
                new Map<String,Object>{'SVMXA360__LayoutElementId__c' => sobjectRecord.Id}, 1);            
        }
        
        //Wizard record creation
        SVMXA360__CONF_ProcessWizard__c wizardRecord = (SVMXA360__CONF_ProcessWizard__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_ProcessWizard__c' );
        
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardStep__c', 
                            new Map<String,Object>{'SVMXA360__ProcessWizard__c' => wizardRecord.Id,'SVMXA360__VisibilityCriteria__c' => expressionRec.Id, 'SVMXA360__Type__c' => 'SPM Transaction','SVMXA360__Target__c' => pageLayoutRecord.SVMXA360__DeveloperName__c}, 
                            5 );

        //Wizard step records creation                                       
        SvmxTestDataFactory.insertSObjectList( 'SVMXA360__CONF_ProcessWizardAccess__c', 
                            new Map<String,Object>{
                                'SVMXA360__ProcessWizard__c' => wizardRecord.Id,
                                'SVMXA360__ProfileId__c' => UserInfo.getProfileId() }, 
                                    3 );

        //Depot Rule record creation 
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_DepotFinderRule__c', 
                                    new Map<String,Object>{'SVMXA360__EnableDepotFinder__c'=> true, 
                                    'SVMXA360__MatchProductAndFamily__c' => true,
                                    'SVMXA360__ObjectAPIName__c' => 'ReturnOrder', 
                                    'SVMXA360__RuleScope__c'=>'Global',
                                    'SVMXA360__DeveloperName__c' => 'Depot_Rule_001','SVMXA360__ObjectMapping__c' => objectMappingRecord.Id});

        //Warranty Configuration record creation 
        SvmxTestDataFactory.insertSObject('SVMXA360__CONF_WarrantyConfig__c', 
                                    new Map<String,Object>{'SVMXA360__AutoWarrOnCreateAsset__c'=> true, 
                                    'SVMXA360__EffectiveFromConfig__c'=>'{"Manufacture Date":"InstallDate","Install Date":"InstallDate","Purchase Date":"PurchaseDate"}', 
                                    'SVMXA360__RuleID__c'=>'Rule001', 'SVMXA360__RuleScope__c'=>'Global','SVMXA360__ObjectMapping__c' => objectMappingRecord.Id});
                                    
        //Expression Based Mapping record creation
        SVMXA360__CONF_ExpressionBasedMapping__c expressionBasedMappingHeaderRecord = (SVMXA360__CONF_ExpressionBasedMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionBasedMapping__c',
                                               new Map<String,Object>{'SVMXA360__TransactionHeader__c' => pageLayoutRecord.id});
        //Expression Based Mapping record creation
        SVMXA360__CONF_ExpressionBasedMapping__c expressionBasedMappingChildRecord = (SVMXA360__CONF_ExpressionBasedMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionBasedMapping__c',
                                               new Map<String,Object>{'SVMXA360__TransactionChild__c' => sobjectRecordList.get(1).id});
        //Expression Based Mapping record creation
        SVMXA360__CONF_ExpressionBasedMapping__c expressionBasedMappingElementRecord = (SVMXA360__CONF_ExpressionBasedMapping__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionBasedMapping__c',
                                               new Map<String,Object>{'SVMXA360__TransactionElement__c' => elementList.get(0).id});

        //Expression Based Mapping row record creation
        SVMXA360__CONF_ExpressionBasedMappingRow__c expressionBasedMappingHeaderRowRecord = (SVMXA360__CONF_ExpressionBasedMappingRow__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionBasedMappingRow__c',
                                               new Map<String,Object>{'SVMXA360__ExpressionBasedMapping__c' => expressionBasedMappingHeaderRecord.id, 'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                                     'SVMXA360__ObjectMappingId__c' => objectMappingRecord.id, 'SVMXA360__Sequence__c' => 1});
        
        //Expression Based Mapping row record creation
        SVMXA360__CONF_ExpressionBasedMappingRow__c expressionBasedMappingChildRowRecord = (SVMXA360__CONF_ExpressionBasedMappingRow__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionBasedMappingRow__c',
                                               new Map<String,Object>{'SVMXA360__ExpressionBasedMapping__c' => expressionBasedMappingChildRecord.id, 'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                                     'SVMXA360__ObjectMappingId__c' => objectMappingRecord.id, 'SVMXA360__Sequence__c' => 1});
        
        //Expression Based Mapping row record creation
        SVMXA360__CONF_ExpressionBasedMappingRow__c expressionBasedMappingElementRowRecord = (SVMXA360__CONF_ExpressionBasedMappingRow__c) SvmxTestDataFactory.insertSObject('SVMXA360__CONF_ExpressionBasedMappingRow__c',
                                               new Map<String,Object>{'SVMXA360__ExpressionBasedMapping__c' => expressionBasedMappingElementRecord.id, 'SVMXA360__ExpressionId__c' => expressionRec.id,
                                                                     'SVMXA360__ObjectMappingId__c' => objectMappingRecord.id, 'SVMXA360__Sequence__c' => 1});
        
        //PSC configuration record creation
        SVMXA360__CONF_PSCConfiguration__c pscConfiguration = new SVMXA360__CONF_PSCConfiguration__c();
        pscConfiguration.SVMXA360__Active__c = true;
        pscConfiguration.Name = 'PscTestConfiguration';
        pscConfiguration.SVMXA360__DeveloperName__c = 'PscTestConfiguration';
        pscConfiguration.SVMXA360__PSCMappingJSON__c = '[{"targetMappingKey":"PSC2WORD","targetMappingId":"MAP001"}]';
        pscConfiguration.SVMXA360__Email__c = 'testemail@test.com';
        insert pscConfiguration;  

		SVMXA360__ConfigurationUsage__c configUsage1 = new SVMXA360__ConfigurationUsage__c();
        configUsage1.SVMXA360__TransactionId__c = pageLayoutRecord.id;
        configUsage1.SVMXA360__EntityType__c = 'Flow';
        configUsage1.SVMXA360__EntityName__c = 'TestFlow';
        configUsage1.SVMXA360__EntityLabel__c = 'Test Flow';
        insert configUsage1;  
        
        SVMXA360__ConfigurationUsage__c configUsage2 = new SVMXA360__ConfigurationUsage__c();
        configUsage2.SVMXA360__TransactionId__c = pageLayoutRecord.id;
        configUsage2.SVMXA360__EntityType__c = 'RecordPage';
        configUsage2.SVMXA360__EntityName__c = 'TestRecordPage';
        configUsage2.SVMXA360__EntityLabel__c = 'Test Record Page';
        insert configUsage2;
    }
    
    static testmethod void testGetExpressionWhereUsedDetails() { 
        
        Test.startTest();
        ADM_WhereUsedManager whereUsedInstance = ADM_WhereUsedManager.getInstance();
        List<SVMXA360__CONF_Expression__c> expressionList = [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Expression__c LIMIT 1];

        Adm.WhereUsedInputRecord inputRecord = new Adm.WhereUsedInputRecord();
        inputRecord.moduleType = 'Expression';
        inputRecord.configurationId = expressionList.get(0).Id;
        inputRecord.configDeveloperName = 'expressionList.get(0).SVMXA360__DeveloperName__c';

        List<Adm.WhereUsedInfo> whereUsedInfoList = whereUsedInstance.getWhereUsedDetails(inputRecord);
        
        System.assert( whereUsedInfoList.size() == 2 );
        
        Test.stopTest();
    }
    
    static testmethod void testGetLookUpFilterWhereUsedDetails() { 
        
        Test.startTest();
        ADM_WhereUsedManager whereUsedInstance = ADM_WhereUsedManager.getInstance();
        List<SVMXA360__CONF_LookupConfiguration__c> lookupConfigList = [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_LookupConfiguration__c LIMIT 1];

        Adm.WhereUsedInputRecord inputRecord = new Adm.WhereUsedInputRecord();
        inputRecord.moduleType = 'Lookup Filter';
        inputRecord.configurationId = lookupConfigList.get(0).Id;
        inputRecord.configDeveloperName = lookupConfigList.get(0).SVMXA360__DeveloperName__c;

        List<Adm.WhereUsedInfo> whereUsedInfoList = whereUsedInstance.getWhereUsedDetails(inputRecord);
        
        System.assert( whereUsedInfoList.size() == 1 );
        
        Test.stopTest();
    }

    static testmethod void testGetTransactionWhereUsedDetails() { 
        
        Test.startTest();
        ADM_WhereUsedManager whereUsedInstance = ADM_WhereUsedManager.getInstance();
        List<SVMXA360__CONF_Layout__c> transactionList = [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_Layout__c WHERE SVMXA360__ScreenType__c = 'Transaction' LIMIT 1];

        Adm.WhereUsedInputRecord inputRecord = new Adm.WhereUsedInputRecord();
        inputRecord.moduleType = 'Transaction';
        inputRecord.configurationId = transactionList.get(0).Id;
        inputRecord.configDeveloperName = transactionList.get(0).SVMXA360__DeveloperName__c;

        List<Adm.WhereUsedInfo> whereUsedInfoList = whereUsedInstance.getWhereUsedDetails(inputRecord);
        
        System.assert( whereUsedInfoList.size() == 3 );
        
        Test.stopTest();
    }
    static testmethod void testGetMappingWhereUsedDetails() { 
        
        Test.startTest();
        ADM_WhereUsedManager whereUsedInstance = ADM_WhereUsedManager.getInstance();
        List<SVMXA360__CONF_ObjectMapping__c> mappingList = [SELECT Id, Name, SVMXA360__DeveloperName__c FROM SVMXA360__CONF_ObjectMapping__c LIMIT 1];

        Adm.WhereUsedInputRecord inputRecord = new Adm.WhereUsedInputRecord();
        inputRecord.moduleType = 'Mapping';
        inputRecord.configurationId = mappingList.get(0).Id;
        inputRecord.configDeveloperName = mappingList.get(0).SVMXA360__DeveloperName__c;

        List<Adm.WhereUsedInfo> whereUsedInfoList = whereUsedInstance.getWhereUsedDetails(inputRecord);
        
        System.assert( whereUsedInfoList.size() == 4 );
        
        Test.stopTest();
    }
}