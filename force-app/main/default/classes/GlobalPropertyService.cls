/**
 * @brief This class defines global services to work with custom setting.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2022
 */
/*****************************************************************************************************
 *    ID        Name                          Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan             13 Jan 2022     Created.
 *****************************************************************************************************/

global with sharing class GlobalPropertyService {

    global class GlobalProperty extends Common.GlobalProperty {
        
        global void setId( final String id ) {
            this.id = id;
        }
        
        global void setKey( final String key ) {
            this.key = key;
        }
        
        global void setName( final String name ) {
            this.name = name;
        }
        
        global void setValue( final String value ) {
            this.value = value;
        }
    }
    
    /**
     * This service is used to whitelist the standard object.
     */
    global static void addGlobalProperty( final GlobalProperty globalProperty, final Blob encryptionKey, final Blob encryptedData ) {
        CONF_CustomSettingsManager.getInstance().addGlobalProperty(globalProperty, encryptionKey, encryptedData);
    }
    
    /**
     * This service is used to whitelist the standard object.
     */
    global static void updateGlobalProperty( final GlobalProperty globalProperty, final Blob encryptionKey, final Blob encryptedData ) {
        CONF_CustomSettingsManager.getInstance().updateGlobalProperty(globalProperty, encryptionKey, encryptedData);
    }
}