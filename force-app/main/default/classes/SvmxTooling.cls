/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief A namespace to hold definitions which are consumed for post install/tooling services.
 *
 * @author Ramachandra Mohan
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Ramachandra Mohan       03 Nov 2020     Created.
 *              Sathish Kumar DB       	04 Feb 2021     A360TOOL-243
 *****************************************************************************************************/
public class SvmxTooling {
    
    public interface IConfigurationData {
        
        String getVersion();
        void setVersion( final String version );
    }
    
    public class MappingData extends Adm.ObjectMapping implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }
    
    public class ExpressionData extends Adm.Expression implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }

    public class LookupConfigData extends Adm.LookupConfig implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }
    
    public class PageLayoutData extends Adm.PageLayout implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }
    
    public class ProcessWizardData extends Adm.ProcessWizard implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }
    
    public class EntitlementRuleData extends Adm.EntitlementRule implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }

    public class AdminPageData extends Adm.AdminPage implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }

    public class TransactionData extends Adm.PageLayout implements IConfigurationData {
        
        private String version;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }
    
    public class ConfigurationData implements IConfigurationData {
        
        private String version;
        
        public List<MappingData> mappingList;
        public List<ExpressionData> expressionList;
        public List<LookupConfigData> lookupConfigList;
        public List<PageLayoutData> pageLayoutList;
        public List<ProcessWizardData> wizardList;
        public List<EntitlementRuleData> entitlementRuleList;
        public List<AdminPageData> adminPageList;
        public List<TransactionData> transactionList;
        
        public String getVersion() {
            return version;
        }
        
        public void setVersion( final String version ) {
            this.version = version;
        }
    }
    
    public static System.Version toVersion( final String versionString ) {
        
        System.Version version;
        if( String.isNotBlank(versionString) ) {
            
            Integer major = 0;
            Integer minor = 0;
            Integer patch = 0;
            String[] versionArray = versionString.split('\\.');
            if( versionArray.size() > 0 ) {
                major = Integer.valueOf( versionArray.get(0) );
            }
            if( versionArray.size() > 1 ) {
                minor = Integer.valueOf( versionArray.get(1) );
            }
            if( versionArray.size() > 2 ) {
                patch = Integer.valueOf( versionArray.get(2) );
            }
            
            if( major != 0 || minor != 0 || patch != 0 ) {
                version = new System.Version( major, minor, patch );
            }
        }
        
        return version;
    }
}