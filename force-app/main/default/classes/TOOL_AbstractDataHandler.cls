/*****************************************************************************
 *                       Copyright (C) 2020 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * @brief This is a abstract class which provides methods for export and import of configurations. 
 *
 * @author Sathish Kumar DB
 * @version 1.0
 * @since 2020
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Sathish Kumar DB       	06 Oct 2020     Created.
 *              Sathish Kumar DB       	04 Feb 2021     A360TOOL-243     
 *****************************************************************************************************/
public without sharing abstract class TOOL_AbstractDataHandler {

    public static String testJsonData;
    
    /**
     * Constant string static variable to hold all asset360 configurations filename
     */
    public static final String ASSET360_CONFIGURATION_FILENAME 		= 'Asset360Configurations';
    
    public static boolean isUpdate = false;

    public static final String RECORDTYPEID = 'RecordTypeId';

    public static final String SCREENTYPE = 'Transaction';
    
    private HandlerType dataHandlerType;
    
    public enum HandlerType {
        ExportData,
        ImportData
    }
    
    public class DataWrapper {
        
        public List<Adm.AdminPage> adminPageList = new List<Adm.AdminPage>();
        public List<Adm.ObjectMapping> mappingList = new List<Adm.ObjectMapping>();
        public List<Adm.Expression> expressionList = new List<Adm.Expression>();
        public List<Adm.LookupConfig> lookupConfigList = new List<Adm.LookupConfig>();
        public List<Adm.PageLayout> pageLayoutList = new List<Adm.PageLayout>();
        public List<Adm.ProcessWizard> wizardList = new List<Adm.ProcessWizard>();
        public List<Adm.EntitlementRule> entitlementRuleList = new List<Adm.EntitlementRule>();
        public List<Adm.PageLayout> transactionList = new List<Adm.PageLayout>();
    }
    
    protected final DataWrapper dataWrapper = new DataWrapper();
    
    public TOOL_AbstractDataHandler( final HandlerType handlerType ) {
        
    	this.dataHandlerType = handlerType;
    }
    
    /**
     * This method is used to invoke abstract methods where we have 
     * implementation to export/import configuration data.
     */
    public virtual void processConfigurationData() {
        
        initHandler();
        
        handleAdminPage();
        handleMapping();
        handleExpression();
        handleLookupConfig();
        handlePageLayout();
        handleProcessWizard();
        handleEntitlementRule(); 
        handleTransaction();       
    }
    
    /**
     * This method will get the static resource path for a mentioned file name
     * 
     * @param File name for which the static resource path to be retrieved and
     *        boolean value to check whether its import request
     * 
     * @return Returns static resource file path.
     */
    protected String getStaticResourcePath( final String fileName ) {
        
        System.debug( LoggingLevel.DEBUG, 'getStaticResourcePath() - enter; fileName=' + fileName );
        
        String staticResourcePath;
        try {
            
            if( String.isNotBlank(fileName) ) {
                
                final List<StaticResource> staticResourceList = (List<StaticResource>) SvmxDatabase.query( [SELECT Id,Name,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name =: fileName] );
                
                if(staticResourceList != null && staticResourceList.size() > 0) {
                    final String nameSpacePrefix = String.isBlank( staticResourceList.get(0).NamespacePrefix ) ? '' : staticResourceList.get(0).NamespacePrefix+'__';
                    staticResourcePath = '/resource/' + staticResourceList.get(0).SystemModstamp.getTime() + '/' + nameSpacePrefix + fileName;
                }
            }
        }
        catch (Exception e) {
           System.debug( LoggingLevel.ERROR, 'getStaticResourcePath() : Error while processing static resource ' + e.getStackTraceString());
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getStaticResourcePath() - exit; staticResourcePath=' + staticResourcePath );
        }
        
        return staticResourcePath;
    }
    
    /**
     * This method reads the json content for the mentioned file.
     * 
     * @param File name for which the json needs to be read.
     * @return This method returns the file content json as a string.
     */
    protected String getJsonData(String filePath) {
        
        System.debug( LoggingLevel.DEBUG, 'getJsonData() - enter; filePath= ' + filePath );
        
        String jsonData;
        try {
            
            if( Test.isRunningTest() ) {
                jsonData = testJsonData;
            } else {
                if(String.isNotBlank(filePath)){
                    PageReference pageReference = new PageReference(filePath);
                    jsonData = pageReference.getContent().toString();
                }
            }
            
        }
        catch(Exception e) {
            
            System.debug( LoggingLevel.ERROR, 'getJsonData() : Failed to retrieve Json content from file. Error=  ' + e.getMessage() );
            System.debug( LoggingLevel.ERROR, 'getJsonData() : ' + e.getStackTraceString() );
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getJsonData() - exit' );
        }
        return jsonData;
    }
    
    protected abstract void initHandler();
    protected abstract void handleAdminPage();
    protected abstract void handleMapping();
    protected abstract void handleExpression();
    protected abstract void handleLookupConfig();
    protected abstract void handlePageLayout();
    protected abstract void handleProcessWizard();
    protected abstract void handleEntitlementRule();
    protected abstract void handleTransaction();
}