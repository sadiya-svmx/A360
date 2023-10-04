/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class is the UT of PSC admin related classes.
 *
 * @author Soumyaranjan Pati
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *           Soumyaranjan Pati       11 Jan 2021       Created.
 *****************************************************************************************************/
@isTest
public class ADM_ProductServiceCampaign_LS_UT {

    static testMethod void testPSCConfigData() {
        Test.startTest();
        SVMXA360__CONF_PSCConfiguration__c confVar = new SVMXA360__CONF_PSCConfiguration__c();
        SVMXA360__CONF_PSCConfiguration__c confVar1 = new SVMXA360__CONF_PSCConfiguration__c();
        setupData(confVar, confVar1);
        Common.ServiceResponse serviceResponse = ADM_ProductServiceCampaign_LS.getAllConfigTemplates();
        Common.ServiceResponse serviceResponseMapping = ADM_ProductServiceCampaign_LS.getObjectMappingDetails('Asset', 'Case');
        Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
        configVar.id = confVar.id;
        configVar.isActive = true;
        configVar.emailId = 'test@test.com';
        configVar.name = 'test com';
        configVar.mappingJson = 'test@test.com';
        configVar.description = 'test com';
        configVar.developerName = 'test_com';
        Common.ServiceResponse saveResponseMapping = ADM_ProductServiceCampaign_LS.saveConfigTemplates(JSON.serialize(configVar));
		
        Common.ServiceResponse getTemplateInfo = ADM_ProductServiceCampaign_LS.getConfigTemplateInfo(JSON.serialize(configVar));

        Common.ServiceResponse deleteServiceResponse = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVar));
        Test.stopTest();
       
        system.assertEquals(true, deleteServiceResponse.success, 'expected successful deleteServiceResponse');
        system.assertEquals(true, serviceResponseMapping.success, 'expected successful serviceResponseMapping');
        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(true, saveResponseMapping.success, 'expected successful saveResponseMapping');
        system.assertEquals(true, getTemplateInfo.success, 'expected successful getTemplateInfo');
        system.assertEquals(1, ((List<Object>)serviceResponse.data).size(), 'expected 1 ');

        
    }
    @isTest static void testPSCConfigDataUsingNullObjectListParameter() {
        try {
            SVMXA360__CONF_PSCConfiguration__c pscConfigvar = new SVMXA360__CONF_PSCConfiguration__c();
            pscConfigvar.Name = 'Test Config Var';
            pscConfigvar.SVMXA360__Scope__c = 'Global';
            pscConfigvar.SVMXA360__Description__c = 'Description ';
            pscConfigvar.SVMXA360__PSCMappingJSON__c = '[{"targetMappingKey":"PSC2WORD","targetMappingId":"MAP001"},{"targetMappingKey":"ASSET2WORD","targetMappingId":"MAP002"}]';
            pscConfigvar.RecordTypeId = Schema.SObjectType.SVMXA360__CONF_PSCConfiguration__c.getRecordTypeInfosByDeveloperName().get('PSC_Configuration').getRecordTypeId();
            pscConfigvar.SVMXA360__Active__c = true;
            insert pscConfigvar;
            ADM_ProductServiceCampaign_LS.getAllConfigTemplates();
            System.assert(false, 'Exception was expected.');

            Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
            configVar.id = '';
            configVar.isActive = true;
            configVar.emailId = 'test@test.com';
            configVar.name = 'test com';
            configVar.mappingJson = 'test@test.com';
            configVar.description = 'test com';
            Common.ServiceResponse saveResponseMapping = ADM_ProductServiceCampaign_LS.saveConfigTemplates(JSON.serialize(configVar));
        }   
        catch ( Exception e) {
            System.assert(true, 'Exception was not thrown as expected.');
        }
    }
    static testMethod void testPSCConfigDataWithException() {
        Test.startTest();
        SVMXA360__CONF_PSCConfiguration__c confVar = new SVMXA360__CONF_PSCConfiguration__c();
        SVMXA360__CONF_PSCConfiguration__c confVar1 = new SVMXA360__CONF_PSCConfiguration__c();
        setupData(confVar, confVar1);
        Common.ServiceResponse serviceResponse = ADM_ProductServiceCampaign_LS.getAllConfigTemplates();
        Common.ServiceResponse serviceResponseMapping = ADM_ProductServiceCampaign_LS.getObjectMappingDetails('Asset', 'Case');
        Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
        configVar.id = '';
        configVar.isActive = true;
        configVar.emailId = 'test@test.com';
        configVar.name = 'test com';
        configVar.mappingJson = 'test@test.com';
        configVar.description = 'test com';
        configVar.developerName = 'test_com';
        Common.ServiceResponse saveResponseMapping = ADM_ProductServiceCampaign_LS.saveConfigTemplates(JSON.serialize(configVar));
		
        Common.ServiceResponse getTemplateInfo = ADM_ProductServiceCampaign_LS.getConfigTemplateInfo(JSON.serialize(configVar));

        Common.ServiceResponse deleteServiceResponse = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVar));

        Adm.PSCConfigurations configVar2 = new Adm.PSCConfigurations();
        configVar2.id = null;
        configVar2.isActive = true;
        configVar2.emailId = 'test@test.com';
        configVar2.name = 'test com';
        configVar2.mappingJson = 'test@test.com';
        configVar2.description = 'test com';
        configVar2.developerName = 'test_com';

        Common.ServiceResponse saveResponseMapping2 = ADM_ProductServiceCampaign_LS.saveConfigTemplates(JSON.serialize(configVar2));
		
        Common.ServiceResponse getTemplateInfo2 = ADM_ProductServiceCampaign_LS.getConfigTemplateInfo(JSON.serialize(configVar2));

        Common.ServiceResponse deleteServiceResponse2 = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVar2));

        Adm.PSCConfigurations configVarSetting1 = new Adm.PSCConfigurations();
        configVarSetting1.id = '';
		Common.ServiceResponse updateServiceResponseSetting1 = ADM_ProductServiceCampaign_LS.updateConfigTemplateSetting(JSON.serialize(configVarSetting1));
        Common.ServiceResponse deleteServiceResponseSetting1 = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVarSetting1));

        Adm.PSCConfigurations configVarSetting2 = new Adm.PSCConfigurations();
        configVarSetting2.id = null;
		Common.ServiceResponse updateServiceResponseSetting2 = ADM_ProductServiceCampaign_LS.updateConfigTemplateSetting(JSON.serialize(configVarSetting2));
        Common.ServiceResponse deleteServiceResponseSetting2 = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVarSetting2));

        Test.stopTest();
       
        system.assertEquals(false, deleteServiceResponse.success, 'expected unsuccessful deleteServiceResponse');
        system.assertEquals(true, serviceResponseMapping.success, 'expected successful serviceResponseMapping');
        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(true, saveResponseMapping.success, 'expected successful saveResponseMapping');
        system.assertEquals(true, getTemplateInfo.success, 'expected successful getTemplateInfo');
        system.assertEquals(1, ((List<Object>)serviceResponse.data).size(), 'expected 1 ');

        system.assertEquals(false, saveResponseMapping2.success, 'expected unsuccessful saveResponseMapping2');
        system.assertEquals(false, getTemplateInfo2.success, 'expected successful getTemplateInfo2');
        system.assertEquals(false, deleteServiceResponse2.success, 'expected unsuccessful deleteServiceResponse2');

        system.assertEquals(false, updateServiceResponseSetting1.success, 'expected unsuccessful updateServiceResponseSetting1');
        system.assertEquals(false, deleteServiceResponseSetting1.success, 'expected unsuccessful deleteServiceResponseSetting1');

        system.assertEquals(false, updateServiceResponseSetting2.success, 'expected unsuccessful updateServiceResponseSetting2');
        system.assertEquals(false, deleteServiceResponseSetting2.success, 'expected unsuccessful deleteServiceResponseSetting2');

        
    } 
    static testMethod void testPSCConfigDatawithActiveDelete() {
        
        SVMXA360__CONF_PSCConfiguration__c confVar = new SVMXA360__CONF_PSCConfiguration__c();
        SVMXA360__CONF_PSCConfiguration__c confVar1 = new SVMXA360__CONF_PSCConfiguration__c();
        setupData(confVar, confVar1);
        setupPSCData(confVar.Id);
        Common.ServiceResponse serviceResponse = ADM_ProductServiceCampaign_LS.getAllConfigTemplates();
        Common.ServiceResponse serviceResponseMapping = ADM_ProductServiceCampaign_LS.getObjectMappingDetails('Asset', 'Case');
        Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
        configVar.id = confVar.id;
        configVar.isActive = false;
        configVar.emailId = 'test@test.com';
        configVar.name = 'test com';
        configVar.mappingJson = 'test@test.com';
        configVar.description = 'test com';
        configVar.developerName = 'test_com';
        Common.ServiceResponse saveResponseMapping = ADM_ProductServiceCampaign_LS.saveConfigTemplates(JSON.serialize(configVar));
		
        Common.ServiceResponse getTemplateInfo = ADM_ProductServiceCampaign_LS.getConfigTemplateInfo(JSON.serialize(configVar));

        Common.ServiceResponse deleteServiceResponse = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVar));
        Test.startTest();
        Adm.PSCConfigurations configV = new Adm.PSCConfigurations();
        //configV.id = confVar.id;
        configV.isActive = false;
        configV.emailId = 'test@test.com';
        configV.name = 'test com';
        configV.mappingJson = 'test@test.com';
        configV.description = 'test com';
        configV.developerName = 'Test_Config_Var';
        Common.ServiceResponse saveResponseMappingDuplicate = ADM_ProductServiceCampaign_LS.saveConfigTemplates(JSON.serialize(configV));
        
        Test.stopTest();
       
        system.assertEquals(false, deleteServiceResponse.success, 'expected unsuccessful deleteServiceResponse');
        system.assertEquals(true, serviceResponseMapping.success, 'expected successful serviceResponseMapping');
        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(false, saveResponseMapping.success, 'expected unsuccessful saveResponseMapping');
        system.assertEquals(false, saveResponseMappingDuplicate.success, 'expected unsuccessful saveResponseMapping');
        system.assertEquals(true, getTemplateInfo.success, 'expected successful getTemplateInfo');
        system.assertEquals(1, ((List<Object>)serviceResponse.data).size(), 'expected 1 ');

        
    }
    static testMethod void testPSCConfigDataCoverException() {
        Test.startTest();
        SVMXA360__CONF_PSCConfiguration__c confVar = new SVMXA360__CONF_PSCConfiguration__c();
        SVMXA360__CONF_PSCConfiguration__c confVar1 = new SVMXA360__CONF_PSCConfiguration__c();
        setupData(confVar, confVar1);
        Common.ServiceResponse serviceResponse = ADM_ProductServiceCampaign_LS.getAllConfigTemplates();
        Common.ServiceResponse serviceResponseMapping = ADM_ProductServiceCampaign_LS.getObjectMappingDetails('Asset', 'Case');
        Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
        configVar.id = confVar.id;
        configVar.isActive = true;
        configVar.emailId = 'test@test.com';
        configVar.name = 'test com';
        configVar.mappingJson = 'test@test.com';
        configVar.description = 'test com';
        Common.ServiceResponse saveResponseMapping = ADM_ProductServiceCampaign_LS.saveConfigTemplates('Test');
		
        Common.ServiceResponse getTemplateInfo = ADM_ProductServiceCampaign_LS.getConfigTemplateInfo('Test');
        Test.stopTest();
       
        system.assertEquals(true, serviceResponseMapping.success, 'expected successful serviceResponseMapping');
        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(false, saveResponseMapping.success, 'expected successful saveResponseMapping');
        system.assertEquals(false, getTemplateInfo.success, 'expected successful getTemplateInfo');
        system.assertEquals(1, ((List<Object>)serviceResponse.data).size(), 'expected 1 ');

        
    }
    static testMethod void testPSCSettingData() {
        Test.startTest();
        SVMXA360__CONF_PSCConfiguration__c confVar = new SVMXA360__CONF_PSCConfiguration__c();
        SVMXA360__CONF_PSCConfiguration__c confVarsetting = new SVMXA360__CONF_PSCConfiguration__c();
        setupData(confVar, confVarsetting);
        System.debug('confVarsetting '+confVarsetting);
        Common.ServiceResponse serviceResponse = ADM_ProductServiceCampaign_LS.getSettingConfigTemplates();
        Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
        configVar.id = confVarsetting.id;
		Common.ServiceResponse updateServiceResponse = ADM_ProductServiceCampaign_LS.updateConfigTemplateSetting(JSON.serialize(configVar));
        Common.ServiceResponse deleteServiceResponse = ADM_ProductServiceCampaign_LS.deleteConfigTemplate(JSON.serialize(configVar));
        Test.stopTest();
      
        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(true, updateServiceResponse.success, 'expected successful updateServiceResponse');
        system.assertEquals(true, deleteServiceResponse.success, 'expected successful deleteServiceResponse');
        system.assertEquals(1, ((List<Object>)serviceResponse.data).size(), 'expected 1 ');

        
    }
    static testMethod void testPSCSettingDataHandleException() {
        Test.startTest();
        SVMXA360__CONF_PSCConfiguration__c confVar = new SVMXA360__CONF_PSCConfiguration__c();
        SVMXA360__CONF_PSCConfiguration__c confVarsetting = new SVMXA360__CONF_PSCConfiguration__c();
        setupData(confVar, confVarsetting);
        System.debug('confVarsetting '+confVarsetting);
        Common.ServiceResponse serviceResponse = ADM_ProductServiceCampaign_LS.getSettingConfigTemplates();
        Adm.PSCConfigurations configVar = new Adm.PSCConfigurations();
        //configVar.id = '';
		Common.ServiceResponse updateServiceResponse = ADM_ProductServiceCampaign_LS.updateConfigTemplateSetting('Test');
        Common.ServiceResponse deleteServiceResponse = ADM_ProductServiceCampaign_LS.deleteConfigTemplate('Test');
        Test.stopTest();
      
        system.assertEquals(true, serviceResponse.success, 'expected successful serviceResponse');
        system.assertEquals(false, updateServiceResponse.success, 'expected successful updateServiceResponse');
        system.assertEquals(false, deleteServiceResponse.success, 'expected successful deleteServiceResponse');
        system.assertEquals(1, ((List<Object>)serviceResponse.data).size(), 'expected 1 ');

        
    }
    private static void setupPSCData(Id pscconfigId){

        ProductServiceCampaign pscRec = new ProductServiceCampaign();
        pscRec.ProductServiceCampaignName = 'Test PSC record';
        pscRec.StartDate = System.Today();
        pscRec.Status = 'New';
        pscRec.Type = 'Service';
        pscRec.SVMXA360__PSCConfigurationId__c = pscconfigId;
        insert pscRec;

    }
    private static void setupData(SVMXA360__CONF_PSCConfiguration__c pscConfigvar,SVMXA360__CONF_PSCConfiguration__c pscSettingvar){
        
        pscConfigvar.Name = 'Test Config Var';
        pscConfigvar.SVMXA360__Scope__c = 'Global';
        pscConfigvar.SVMXA360__DeveloperName__c = 'Test_Config_Var';
        pscConfigvar.SVMXA360__Description__c = 'Description ';
        pscConfigvar.SVMXA360__PSCMappingJSON__c = '[{"targetMappingKey":"PSC2WORD","targetMappingId":"MAP001"},{"targetMappingKey":"ASSET2WORD","targetMappingId":"MAP002"}]';
        pscConfigvar.RecordTypeId = Schema.SObjectType.SVMXA360__CONF_PSCConfiguration__c.getRecordTypeInfosByDeveloperName().get('PSC_Configuration').getRecordTypeId();
        pscConfigvar.SVMXA360__Active__c = true;
        insert pscConfigvar;

        pscSettingvar.Name = 'Default PSC Settings';
        pscSettingvar.SVMXA360__Scope__c = 'Global';
        pscSettingvar.SVMXA360__DeveloperName__c = 'Default_PSC_Settings';
        pscSettingvar.SVMXA360__Description__c = 'Description ';
        pscSettingvar.SVMXA360__SearchBatchSize__c = 500;
        pscSettingvar.SVMXA360__DeliveryBatchSize__c = 50;
        pscSettingvar.SVMXA360__SearchResultsPerPSC__c = 5000;
        pscSettingvar.RecordTypeId = Schema.SObjectType.SVMXA360__CONF_PSCConfiguration__c.getRecordTypeInfosByDeveloperName().get('PSC_Settings').getRecordTypeId();
        pscSettingvar.SVMXA360__Active__c = true;
        insert pscSettingvar;
       
        SVMXA360__CONF_ObjectMapping__c objMapVar = new SVMXA360__CONF_ObjectMapping__c();
        objMapVar.Name = 'Asset to Case';
        objMapVar.SVMXA360__DeveloperName__c = 'Asset_to_Case';
        objMapVar.SVMXA360__Type__c = 'Field Mapping';
        objMapVar.SVMXA360__SourceObjectAPIName__c = 'Asset';
        objMapVar.SVMXA360__TargetObjectAPIName__c = 'Case';
        insert objMapVar;
    }
}