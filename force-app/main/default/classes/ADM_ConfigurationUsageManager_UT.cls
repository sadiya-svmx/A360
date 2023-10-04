@IsTest
public class ADM_ConfigurationUsageManager_UT {
    
    static testmethod void testGetAllConfigurationUsages() { 
        
        Test.startTest();

        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'New Transaction Layout',
            'SVMXA360__DeveloperName__c' => 'New_Transaction_Layout',
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__ScreenType__c' => 'Transaction',
            'SVMXA360__SourceObjectAPIName__c' => 'Account',
            'SVMXA360__TransactionType__c' => 'Source to Target',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} );
        
        SVMXA360__ConfigurationUsage__c configurationUsageRec = (SVMXA360__ConfigurationUsage__c) SvmxTestDataFactory.insertSObject('SVMXA360__ConfigurationUsage__c', 
                                                                                                                        new Map<String,Object>{
                                                                                                                        'SVMXA360__EntityLabel__c' => 'A360 - Work Order Record Page',
                                                                                                                        'SVMXA360__EntityName__c' => 'SVMXA360__WorkOrderRecordPage',
                                                                                                                        'SVMXA360__EntityType__c' => 'RecordPage',
                                                                                                                        'SVMXA360__TransactionId__c' => pageLayoutRecord.id
                                                                                                                        });


        List<Adm.ConfigurationUsage> configurationUsageList = ADM_ConfigurationUsageManager.getInstance().getAllConfigurationUsages();
        System.assert( configurationUsageList.size() != 0 );
        
        Test.stopTest();
    }
    static testmethod void testSaveConfigurationUsages() { 
        
        Test.startTest();

        SVMXA360__CONF_Layout__c pageLayoutRecord = (SVMXA360__CONF_Layout__c) SvmxTestDataFactory.insertSObject( 'SVMXA360__CONF_Layout__c', new Map<String,Object>{
            'Name' => 'New Transaction Layout',
            'SVMXA360__DeveloperName__c' => 'New_Transaction_Layout',
            'SVMXA360__ObjectAPIName__c' => 'Account',
            'SVMXA360__ScreenType__c' => 'Transaction',
            'SVMXA360__SourceObjectAPIName__c' => 'Account',
            'SVMXA360__TransactionType__c' => 'Source to Target',
            'SVMXA360__FieldSets__c' => '["fls1","fls2"]'} );

        Adm.ConfigurationUsage configUsage = new Adm.ConfigurationUsage();
       
        configUsage.entityLabel = 'Work Order Record Page 1';
        configUsage.entityName = 'SVMXA360__WorkOrderRecordPage1';
        configUsage.entityType = 'RecordPage';
        configUsage.configurationId = pageLayoutRecord.id;

        List<Adm.ConfigurationUsage> configUsageList = new List<Adm.ConfigurationUsage>{configUsage};
        configUsageList = ADM_ConfigurationUsageManager.getInstance().saveConfigurationUsages(configUsageList);
        System.assert( configUsageList.size() != 0 );
        System.assert( configUsageList.get(0).entityName == configUsage.entityName);
        
        Test.stopTest();
    }

    static testmethod void testGetWhereUsedStatus() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'COMPLETED'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'Successfully Updated Configuration Usage'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => lastExecutedDate}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'COMPLETED');
        
        Test.stopTest();
    }

    static testmethod void testGetWhereUsedStatusTODO() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'TODO'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED');
        
        Test.stopTest();
    }

    static testmethod void testGetWhereUsedStatusCANCELLED() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'CANCELLED'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED');
        
        Test.stopTest();
    }

    static testmethod void testStatusINPROGRESSWithLapseTime() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().addMinutes(-3).getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'INPROGRESS'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => ''}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => lastExecutedDate}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'CANCELLED');
        
        Test.stopTest();
    }

    static testmethod void testStatusINPROGRESSWithNoLapseTime() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'INPROGRESS'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => ''}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => lastExecutedDate}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED');
        
        Test.stopTest();
    }

    static testmethod void testStatusFAILEDWithLapseTime() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().addMinutes(-3).getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'FAILED'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => ''}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => lastExecutedDate}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED');
        
        Test.stopTest();
    }

    static testmethod void testStatusFAILEDWithNoLapseTime() { 
        
        Test.startTest();
        
        String lastExecutedDate = String.valueOf(System.now().getTime());
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => 'FAILED'}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => ''}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => lastExecutedDate}, 1);

        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
    
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED');
        
        Test.stopTest();
    }
    
    static testmethod void testGetWhereUsedStatusForNull() { 
        
        Test.startTest();
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
    
        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = true;
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED');
        
        Test.stopTest();
    }

    static testmethod void testGetWhereUsedStatusInactiveSettings() { 
        
        Test.startTest();
        
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP601','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP602','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
        SvmxTestDataFactory.insertSObjectList('SVMXA360__CONF_CSET_GlobalProperties__c', new Map<String,Object>{'Name'=>'GP603','SVMXA360__Key__c' => 'CONFIGURATION_USAGE_SETTING', 'SVMXA360__Value__c' => null}, 1);
    
        ADM_ConfigurationUsageManager  configUsageManager = ADM_ConfigurationUsageManager.getInstance();
        configUsageManager.isRemoteSiteSettingActive = false;
            
        String status = configUsageManager.getWhereUsedStatus();
        System.assert( status != null );
        System.assert( status == 'NOT COMPLETED - Remote Site Setting AutoConfigurator is not active');
        
        Test.stopTest();
    }

}