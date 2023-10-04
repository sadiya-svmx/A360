/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This class has methods to retrieve custom setting values for 
 * different properties.
 * 
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       12 Jun 2020     Created.
 * A360TOOL-858 Ramachandra Mohan       01 Dec 2021     Service to retrieve/set global property values.
 * A360TOOL-947 Ramachandra Mohan       26 Jan 2022     Service to add global property.
 *****************************************************************************************************/
public with sharing class CONF_CustomSettingsManager {

    /**
     * Private string constant to hole Global Property key type.
     */
    public static final String KEY_ALLOWED_CORE_OBJECT  = 'ALLOWED_CORE_OBJECT';
    
    /**
     * Private string constant to hole Global Property key type.
     */
    public static final String KEY_SUPPORTED_LANGUAGE  	= 'SUPPORTED_LANGUAGE';
 
    /**
     * Private string constant to hole Global Property for application usage tracking.
     */
    public static final String NAME_ENABLE_APP_USAGE_TRACKING  = 'GP600';

    /**
     * Private string constant to hole Global Settings key type.
     */
    public static final String KEY_ENABLE_APP_USAGE_TRACKING  = 'ENABLE_APP_USAGE_TRACKING';
    
    /**
     * Private string constant to hole Global Settings key type for auto configurator.
     */
    public static final String KEY_AUTO_CONFIGURATOR  		= 'AUTO_CONFIGURATOR';
    
    /**
     * Private string constant to hole Global Settings key type for configuration usage settings.
	 */
    public static final String KEY_CONFIGURATION_USAGE_SETTINGS  		= 'CONFIGURATION_USAGE_SETTING';
    
    /**
     * Provate static variable to hole instance of this class.
     */
    private static CONF_CustomSettingsManager instance;
    
    /**
     * Static private variable to hold global property value cache.
     */
    private static Map<String,List<Common.GlobalProperty>> allGlobalPropertyMap;
    
    /**
     * Static method to retrieve instance of this class.
     */
    public static CONF_CustomSettingsManager getInstance() {
        
        if( instance == null ) {
            instance = new CONF_CustomSettingsManager();
        }
        
        return instance;
    }
    
    /**
     * This method is used to retrieve all configured global properties in the org.
     */
    public Map<String,List<Common.GlobalProperty>> getAllGlobalProperties() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllGlobalProperties() - enter');
        
        try {
            
            // Retrieve all property values if not exists otherwise from cache.
            if( allGlobalPropertyMap == null ) {
                
                System.debug( LoggingLevel.DEBUG, 'getAllGlobalProperties() : ');
                
                allGlobalPropertyMap = new Map<String,List<Common.GlobalProperty>>();
                
                // Create custom setting wrapper.
                final List<SVMXA360__CONF_CSET_GlobalProperties__c> allGlobalPropertyList = SVMXA360__CONF_CSET_GlobalProperties__c.getAll().values();
                for( SVMXA360__CONF_CSET_GlobalProperties__c globalPropertyRecord : allGlobalPropertyList ) {
                    
                    final Common.GlobalProperty globalProperty = new Common.GlobalProperty();
                    globalProperty.name = globalPropertyRecord.Name;
                    globalProperty.key = globalPropertyRecord.SVMXA360__Key__c;
                    globalProperty.value = globalPropertyRecord.SVMXA360__Value__c;
                    
                    if( !allGlobalPropertyMap.containsKey(globalProperty.key) ) {
                        allGlobalPropertyMap.put(globalProperty.key, new List<Common.GlobalProperty>() );
                    }
                    
                    allGlobalPropertyMap.get(globalProperty.key).add(globalProperty);
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAllGlobalProperties() : Internal setver error. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllGlobalProperties() - exit');
        }
    
        return allGlobalPropertyMap;
    }
    
    /**
     * This method is used to retireve allowed core objects from the global property list.
     */
    public List<String> getAllowedCoreObjects() {
        
        System.debug( LoggingLevel.DEBUG, 'getAllowedCoreObjects() - enter');
        
        final List<String> allowedCodeObjects = new List<String>();
        
        try {
            
            final List<SVMXA360__CONF_CSET_GlobalProperties__c> globalPropertyList = getGlobalPropertyValues(KEY_ALLOWED_CORE_OBJECT);
            for( SVMXA360__CONF_CSET_GlobalProperties__c globalPropertiesRecord : globalPropertyList ) {
                
                if( String.isNotBlank( globalPropertiesRecord.SVMXA360__Value__c ) ) {
                    allowedCodeObjects.add( globalPropertiesRecord.SVMXA360__Value__c );
                }            
            }
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAllowedCoreObjects() - exit');
        }
        
        
        return allowedCodeObjects;
    }
    
    /**
     * This method is used to retireve values for given key.
     */
    public List<SVMXA360__CONF_CSET_GlobalProperties__c> getGlobalPropertyValues( final String key ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalPropertyValues() - enter');
        
        List<SVMXA360__CONF_CSET_GlobalProperties__c> globalPropertyList = new List<SVMXA360__CONF_CSET_GlobalProperties__c>();
        
        try {

            if( String.isBlank( key ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getGlobalPropertyValues() : Invalid argument. key= ' + key );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }   
            
            for( SVMXA360__CONF_CSET_GlobalProperties__c globalProperties : SVMXA360__CONF_CSET_GlobalProperties__c.getAll().values() ) {
                if( key.equalsIgnoreCase( globalProperties.SVMXA360__Key__c ) ) {
                    globalPropertyList.add(globalProperties);
                }
            }
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGlobalPropertyValues() : Failed to restrive custom settings. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'getGlobalPropertyValues() : Failed to restrive custom settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGlobalPropertyValues() - exit');
        }
        
        return globalPropertyList;
    }

    public List<String>  getSupportedLanguages () {
        List<String> svmxSupportedLanguages = new List<String>();
        Map<String,List<Common.GlobalProperty>> globalProperties = CONF_CustomSettingsManager.getInstance().getAllGlobalProperties();
        if(globalProperties.containsKey(KEY_SUPPORTED_LANGUAGE)){
            for ( Common.GlobalProperty property: globalProperties.get(KEY_SUPPORTED_LANGUAGE) ) {
                svmxSupportedLanguages.add(property.value);
            }
        }
        return svmxSupportedLanguages;
    }

    public void saveRecordActionExtensionClass (String className) {
        SVMXA360__CONF_CSET_GlobalProperties__c prop = new SVMXA360__CONF_CSET_GlobalProperties__c();
        prop.Name = 'REC_ACTION';
        prop.SVMXA360__Key__c = 'RECORDACTION_EXTENSION_CLASS';
        prop.SVMXA360__Value__c = className;
        svmxDatabase.upsertRecord(prop);
    }

    public Common.GlobalProperty getGlobalPropertyByName( final String name ) {
        
        System.debug( LoggingLevel.DEBUG, 'getGlobalPropertyByName() - enter');
        
        final Common.GlobalProperty globalProperty = new Common.GlobalProperty();

        try {

            if( String.isBlank( name ) ) {
                
                System.debug( LoggingLevel.ERROR, 'getGlobalPropertyByName() : Invalid argument. name= ' + name );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }   

            Map<String, SVMXA360__CONF_CSET_GlobalProperties__c> propMap = SVMXA360__CONF_CSET_GlobalProperties__c.getAll();

            if(!propMap.containsKey(name)) {
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.RECORD_NOT_EXISTS + ' : ' + name);
            }

            globalProperty.id = propMap.get(name).Id;
            globalProperty.name = propMap.get(name).Name;
            globalProperty.key = propMap.get(name).SVMXA360__Key__c;
            globalProperty.value = propMap.get(name).SVMXA360__Value__c;
        }
        catch( SvmxSystem.SvmxNestedException e ) {
            System.debug( LoggingLevel.ERROR, 'getGlobalPropertyByName() : Failed to restrive custom settings. Error= ' + e.getMessage() );
            throw e;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getGlobalPropertyByName() : Failed to restrive custom settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getGlobalPropertyByName() - exit');
        }
        
        return globalProperty;
    }

    public void setGlobalPropertyByName (final String name, final String value ) {
        
        System.debug( LoggingLevel.DEBUG, 'setGlobalPropertyByName() - enter: name= ' + name + '; value= ' + value );
        
        try{
            SVMXA360__CONF_CSET_GlobalProperties__c globalProperty = [SELECT Id, Name, SVMXA360__Key__c, SVMXA360__Value__c 
                                                                                FROM SVMXA360__CONF_CSET_GlobalProperties__c 
                                                                                WHERE Name = :name
                                                                                WITH SECURITY_ENFORCED
                                                                                LIMIT 1];
            globalProperty.SVMXA360__Value__c = value;
            
            if( Schema.sObjectType.SVMXA360__CONF_CSET_GlobalProperties__c.fields.SVMXA360__Value__c.isUpdateable() ) {
                update globalProperty;
            }
        }
        catch( Exception e ) {
            
            System.debug( LoggingLevel.ERROR, 'setGlobalPropertyByName() : Failed to set custom settings. Error= ' + e.getStackTraceString() );
            throw e;
        }
    }
    
    public Common.GlobalProperty addGlobalProperty( final Common.GlobalProperty globalProperty, final Blob encryptionKey, final Blob encryptedData ) {
        
        System.debug( LoggingLevel.DEBUG, 'addGlobalProperty() - enter; globalProperty = ' + globalProperty );
        
        try {
            
            validateEncryptedData(encryptionKey, encryptedData );
            
            Map<String, SVMXA360__CONF_CSET_GlobalProperties__c> globalPropertiesMap = SVMXA360__CONF_CSET_GlobalProperties__c.getAll();
            
            if( globalProperty == null || String.isBlank( globalProperty.name ) || String.isBlank( globalProperty.value ) ) {
                
                System.debug( LoggingLevel.ERROR, 'addGlobalProperty() : Invalid argument. globalProperty= ' + globalProperty );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }   
            
            if( globalPropertiesMap.containsKey(globalProperty.name) ) {
                
                System.debug( LoggingLevel.ERROR, 'addGlobalProperty() : Duplicate global property name. name= ' + globalProperty.name );
                throw new SvmxSystem.SvmxNestedException( System.Label.Error_DuplicateGlobalPropertyName );
            }
            
            SVMXA360__CONF_CSET_GlobalProperties__c globalPropertyRecord = new SVMXA360__CONF_CSET_GlobalProperties__c();
            globalPropertyRecord.SVMXA360__Key__c = globalProperty.key;
            globalPropertyRecord.Name = globalProperty.name;
            globalPropertyRecord.SVMXA360__Value__c = globalProperty.value.toLowerCase();
            
            SvmxDatabase.insertRecord(globalPropertyRecord);
            globalProperty.id = globalPropertyRecord.id;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'addGlobalProperty() - exit');
        }
        
        return globalProperty;
    }
    
    public Common.GlobalProperty updateGlobalProperty( final Common.GlobalProperty globalProperty, final Blob encryptionKey, final Blob encryptedData ) {
        
        System.debug( LoggingLevel.DEBUG, 'updateGlobalProperty() - enter; globalProperty = ' + globalProperty );
        
        try {
            
            validateEncryptedData(encryptionKey, encryptedData );
            
            Map<String, SVMXA360__CONF_CSET_GlobalProperties__c> globalPropertiesMap = SVMXA360__CONF_CSET_GlobalProperties__c.getAll();
            
            if( globalProperty == null || String.isBlank( globalProperty.name ) ) {
                
                System.debug( LoggingLevel.ERROR, 'updateGlobalProperty() : Invalid argument. globalProperty= ' + globalProperty );
                throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
            }   
            
            if( !globalPropertiesMap.containsKey(globalProperty.name) ) {
                
                System.debug( LoggingLevel.ERROR, 'updateGlobalProperty() : global property name does not exists. name= ' + globalProperty.name );
                throw new SvmxSystem.SvmxNestedException( 'Global property name does not exists. name= ' + globalProperty.name );
            }
            
            SVMXA360__CONF_CSET_GlobalProperties__c globalPropertyRecord = globalPropertiesMap.get(globalProperty.name);
            globalPropertyRecord.SVMXA360__Value__c = globalProperty.value.toLowerCase();
            
            SvmxDatabase.updateRecord(globalPropertyRecord);
            globalProperty.id = globalPropertyRecord.id;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'updateGlobalProperty() - exit');
        }
        
        return globalProperty;
    }

    private void validateEncryptedData( final Blob encryptionKey, final Blob encryptedData ) {
        
        if( encryptionKey == null || encryptedData == null ) {
            
            System.debug( LoggingLevel.ERROR, 'validateEncryptedData() : Invalid argument.' );
            throw new SvmxSystem.SvmxNestedException( ErrorMessage.INVALID_ARGUMENT );
        }
        
        final Blob decryptedData = Crypto.decrypt('AES128', encryptionKey, Blob.valueOf('Asset 360 DataIV'), encryptedData);
		final String encryptedString = decryptedData.toString();
        
        if( !encryptedString.startsWith( UserInfo.getOrganizationId() ) ) {
            throw new SvmxSystem.SvmxNestedException( 'Invalid encrypted Data' );
        }
    }
    
    private CONF_CustomSettingsManager() {
    }
}