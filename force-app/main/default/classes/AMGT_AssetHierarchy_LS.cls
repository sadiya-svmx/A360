@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class AMGT_AssetHierarchy_LS {
    public final static string ACCOUNT = 'account';
    public final static string ASSET = 'asset';
    public final static string LOCATION = 'location';
    public final static string LOCATION_THEN_ASSET = 'Location > Asset';
    public final static string ASSET_ONLY = 'Asset Only';
    public final static string ACCOUNT_THEN_ASSET = 'Account > Asset';

    public static Map<Schema.SObjectType, Schema.DescribeSObjectResult> cachedDescribeObjectName = new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();

    public final static AMGT_AssetHierarchyManager assetHierarchyManager = AMGT_AssetHierarchyManager.getInstance();

    @AuraEnabled(cacheable=true)
    public static Id getRootId(Id primaryRecordId, String order,Boolean plotHierarchyField){
        System.debug( LoggingLevel.DEBUG, 'getRootId() - enter;' );
        String rootId;
        try {
            if(primaryRecordId != null && string.isNotBlank(order))  {
                String sobjectName = primaryRecordId.getSobjectType().getDescribe().getName().toLowerCase();
                if(order == LOCATION_THEN_ASSET) { 
                    if (sobjectName == LOCATION) {
                        rootId = assetHierarchyManager.getRootLocationIdForLocation(primaryRecordId);
                    } else if (sobjectName == ASSET && (plotHierarchyField == null || !plotHierarchyField)) {
                        rootId = assetHierarchyManager.getRootLocationIdForAsset(primaryRecordId);
                    } else if (sobjectName == ASSET && plotHierarchyField) {
                        throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectPlotHierarchyField  );
                    } else {
                        throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder  );
                    }
                } else if(order == ASSET_ONLY) {
                    if(sobjectName != ASSET) {
                        throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder  );
                    } else {
                        rootId = assetHierarchyManager.getRootAssetIdForAsset(primaryRecordId);
                    }
                } else if(order == ACCOUNT_THEN_ASSET) { 
                    if (sobjectName == ACCOUNT) {
                        rootId = assetHierarchyManager.getRootAccountIdForAccount(primaryRecordId);
                    } else if (sobjectName == ASSET && (plotHierarchyField == null || !plotHierarchyField)) {
                        rootId = assetHierarchyManager.getRootAccountIdForAsset(primaryRecordId);
                    } else if (sobjectName == ASSET && plotHierarchyField) {
                        throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectPlotHierarchyField  );
                    } else {
                        throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder  );
                    }
                }
            }
        } 
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getRootId() : Failed to retrieve Root Id. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRootId() - exit;' );
        }
        return rootId;
    }

    @AuraEnabled(cacheable=true)
    public static Amgt.HierarchyConfiguration getHierarchyConfiguration() {
        System.debug( LoggingLevel.DEBUG, 'getHierarchyConfiguration() - enter;' );
        Amgt.HierarchyConfiguration configuration = new Amgt.HierarchyConfiguration();
        try {
            configuration = assetHierarchyManager.getHierarchyConfigurationsForUser();

            if (configuration.isEmpty) {

                // Retrieve CONF_HierarchyConfigDetail__c records that marked as the default configuration
                configuration = assetHierarchyManager.getDefaultHierarchyConfigurationsForOrg();

                // When there are no configurations for the user AND there are no configurations defined as the "default", then use the fallback configuration.
                if (configuration.isEmpty) {
                    configuration = assetHierarchyManager.getFallbackAssetHierarchyConfigurations();
                }
            }
        } 
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getRootId() : Failed to retrieve Root Id. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getRootId() - exit;' );
        }
        return configuration;
    }

    @AuraEnabled
    public static List<Amgt.HierarchyNode> getHierarchyNodes(List<Id> recordIds, String config, Id primaryRecordId, String order ) {
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode> ();
        try { 
            if( config == null ||
                string.isBlank(config) ||
                primaryRecordId == null ||
                order == null
            )
            {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            List<String> singleQuotedRecordIds = new List<String>();
            if(recordIds != null && recordIds.size() > 0) {
                for(Id recordId : recordIds) {
                    singleQuotedRecordIds.add('\'' + recordId + '\'');
                }
                String sobjectName = recordIds[0].getSobjectType().getDescribe().getName().toLowerCase();
                if (sobjectName == LOCATION) { 
                    nodes.addAll(assetHierarchyManager.getLocationNodes(singleQuotedRecordIds, configuration, primaryRecordId));
                } else if (sobjectName == ASSET) {
                    nodes.addAll(assetHierarchyManager.getAssetNodes(singleQuotedRecordIds, configuration, primaryRecordId, order));
                } else if (sobjectName == ACCOUNT) {
                    nodes.addAll(assetHierarchyManager.getAccountNodes(singleQuotedRecordIds, configuration, primaryRecordId));
                }
            }
            return nodes;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyNodes() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyNodes() - exit; response.size() =' + nodes.size());
        }
    }

    @AuraEnabled
    public static List<SObject> getHierarchyNodesRaw(List<Id> recordIds, String config, Id primaryRecordId, String order ) {
        List<SObject> nodes = new List<SObject> ();
        try { 
            if( config == null ||
                string.isBlank(config) ||
                primaryRecordId == null ||
                order == null
            )
            {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            List<String> singleQuotedRecordIds = new List<String>();
            if(recordIds != null && recordIds.size() > 0) {
                for(Id recordId : recordIds) {
                    singleQuotedRecordIds.add('\'' + recordId + '\'');
                }
                String sobjectName = recordIds[0].getSobjectType().getDescribe().getName().toLowerCase();
                if (sobjectName == LOCATION) { 
                    nodes.addAll(assetHierarchyManager.getLocationNodesRaw(singleQuotedRecordIds, configuration, primaryRecordId));
                } else if (sobjectName == ASSET) {
                    nodes.addAll(assetHierarchyManager.getAssetNodesRaw(singleQuotedRecordIds, configuration, primaryRecordId, order));
                }
            }
            return nodes;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyNodes() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyNodes() - exit; response.size() =' + nodes.size());
        }
    }    

    @AuraEnabled
    public static List<Object> getAssetNodesForHierarchyRaw(List<Id> recordIds, String config, Id primaryRecordId, String order, boolean fetchOnlyChildren ) {
        List<Object> nodes = new List<Object> ();
        try { 
            if( config == null ||
                string.isBlank(config) ||
                primaryRecordId == null ||
                order == null
            )
            {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            List<String> singleQuotedRecordIds = new List<String>();
            if(recordIds != null && recordIds.size() > 0) {
                for(Id recordId : recordIds) {
                    singleQuotedRecordIds.add('\'' + recordId + '\'');
                }
                String sobjectName = recordIds[0].getSobjectType().getDescribe().getName().toLowerCase();
                if (fetchOnlyChildren) {
                    if (sobjectName == LOCATION ) {
                        nodes = assetHierarchyManager.getLocationAssetNodesRaw(singleQuotedRecordIds, configuration, primaryRecordId);
                    } else if (sobjectName == ACCOUNT ) {
                        nodes = assetHierarchyManager.getAccountAssetNodesRaw(singleQuotedRecordIds, configuration, primaryRecordId,true);
                    } else if (sobjectName == ASSET ) {
                        nodes = assetHierarchyManager.getAssetNodesRaw(singleQuotedRecordIds, configuration, primaryRecordId, order);
                    }                    
                } else {
                    if(order == LOCATION_THEN_ASSET) { 
                        if (sobjectName == ASSET ) {
                            String locationId = assetHierarchyManager.getLocationForAsset(primaryRecordId);
                            if(String.isBlank(locationId)){
                                return nodes;
                            }
                            Amgt.HierarchyNode node = new Amgt.HierarchyNode();
                            node.id = locationId;
                            List<Amgt.HierarchyNode> assetNodes = assetHierarchyManager.getAssetParentHierarchy (singleQuotedRecordIds, configuration, primaryRecordId);
                            node.detail = assetNodes;
                            nodes.add(node);
                        } else {
                            nodes = assetHierarchyManager.getLocationAssetNodesRaw(singleQuotedRecordIds, configuration, primaryRecordId);                    
                        }
                    } else if(order == ACCOUNT_THEN_ASSET) { 
                        if (sobjectName == ASSET ) {
                            String accountId = assetHierarchyManager.getAccountForAsset(primaryRecordId);
                            if(String.isBlank(accountId)){
                                return nodes;
                            }
                            Amgt.HierarchyNode node = new Amgt.HierarchyNode();
                            node.id = accountId;
                            List<Amgt.HierarchyNode> assetNodes = assetHierarchyManager.getAssetParentHierarchy (singleQuotedRecordIds, configuration, primaryRecordId);
                            node.detail = assetNodes;
                            nodes.add(node);
                        }  else {
                            nodes = assetHierarchyManager.getAccountAssetNodesRaw (singleQuotedRecordIds, configuration, primaryRecordId,true);
                        }
                    }
                }
            }
            return nodes;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAssetNodesForHierarchy() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetNodesForHierarchy() - exit;');
        }
    }

    @AuraEnabled
    public static Amgt.HierarchyNode getAssetHierarchyByRelatedParent (String assetId, String config, Id relatedParentId, String hierarchyOrder) {
        Amgt.HierarchyNode node = new Amgt.HierarchyNode();
        try { 
            if( string.isBlank(assetId)||
                string.isBlank(config)
            )
            {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }
			assetId = String.escapeSingleQuotes(assetId);
            if(hierarchyOrder == LOCATION_THEN_ASSET) {
                node.id = assetHierarchyManager.getRootAssetLocationIdForAsset(assetId);
            } else if (hierarchyOrder == ACCOUNT_THEN_ASSET) {
                node.id = assetHierarchyManager.getRootAssetAccountIdForAsset(assetId);
            }
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            if (relatedParentId == null && node.id == null) {
                node.id = assetHierarchyManager.getRootAssetIdForAsset(assetId);
                node.children = assetHierarchyManager.getAssetParentHierarchy (new List<String>{'\''+assetId+'\''}, configuration, relatedParentId);
            } else {
                node.detail = assetHierarchyManager.getAssetParentHierarchy (new List<String>{'\''+assetId+'\''}, configuration, relatedParentId);
            }
        } catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getAssetHierarchyByRelatedParent() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        } finally {
            System.debug( LoggingLevel.DEBUG, 'getAssetHierarchyByRelatedParent() - exit;');
        }
        return node;
    }

    @AuraEnabled
    public static Amgt.SearchResult findAssetsOfRelatedParent (
        String term,
        String config,
        Id relatedParentId,
        String timestampInMills
        ) {
        Amgt.SearchResult result = new Amgt.SearchResult ();
        try { 
            if( String.isBlank(term) ||
                String.isBlank(config) == null ||
                String.isBlank(relatedParentId) == null ||
                String.isBlank(timestampInMills)
            )
            {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            String relatedParentType = relatedParentId.getSobjectType().getDescribe().getName().toLowerCase();
            if (relatedParentType.equals(ACCOUNT)){
                result.result = assetHierarchyManager.findAssetsOfRelatedParentSOSL (String.escapeSingleQuotes(term), configuration, relatedParentId);
            } else {
                result.result = assetHierarchyManager.findAssetsOfRelatedParent (String.escapeSingleQuotes(term), configuration, relatedParentId);
            }
            result.timestampInMills = timestampInMills;
            return result;
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyNodes() : Failed to retrieve Hierarchy Nodes. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyNodes() - exit; ');
        }
    }


    @AuraEnabled
    public static List<Amgt.HierarchyNode> fetchFirstFiveLevelAccounts (
        String rootId,
        String config) {
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode> ();
        try {
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            nodes = assetHierarchyManager.fetchFirstFiveLevelAccounts (String.escapeSingleQuotes(rootId), configuration);            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return nodes;
    }
    
    @AuraEnabled
    public static List<sObject> fetchFirstFiveLevelAccountsRaw (
        String rootId,
        String config) {
        List<sObject> nodes = new List<sObject> ();
        try {
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            nodes = assetHierarchyManager.fetchFirstFiveLevelAccountsRaw (String.escapeSingleQuotes(rootId), configuration);            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return nodes;
    }
    
    @AuraEnabled
    public static List<Amgt.HierarchyNode> fetchfinalFiveLevelAccounts (
            String rootId,
            String config) {
        List<Amgt.HierarchyNode> nodes = new List<Amgt.HierarchyNode> ();
        try {
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            nodes = assetHierarchyManager.fetchfinalFiveLevelAccounts (String.escapeSingleQuotes(rootId), configuration);            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return nodes;
    }
 
    @AuraEnabled
    public static List<sObject> fetchfinalFiveLevelAccountsRaw (
            String rootId,
            String config) {
        List<sObject> nodes = new List<sObject> ();
        try {
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            nodes = assetHierarchyManager.fetchfinalFiveLevelAccountsRaw (String.escapeSingleQuotes(rootId), configuration);            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return nodes;
    }

	@AuraEnabled(cacheable=true)
    public static List<sObject> fetchChildAssetsRaw (
        String childAssetRecordId,
        String config,
        String initiatedTime) {
        List<sObject> nodes = new List<sObject> ();
        try {
            if(childAssetRecordId != null && string.isNotBlank(childAssetRecordId) && string.isNotBlank(config))  {
                Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
                nodes = assetHierarchyManager.getChildAssetNodesRaw (childAssetRecordId, configuration);         
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return nodes;
    }

    @AuraEnabled
    public static List<Amgt.SaveResponse> updateAssetRecords ( String records) {
        List<Amgt.SaveResponse> returnResult = new List<Amgt.SaveResponse> ();
        try {
            if(records != null && string.isNotBlank(records))  {
                List<Asset> assets = (List<Asset>) JSON.deserialize(records, List<Asset>.class);
                returnResult = assetHierarchyManager.updateAssetRecords(assets);
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnResult;
    }
    
    @AuraEnabled
    public static List<Amgt.NotificationDetails> getHierarchyNodesNotification(List<Id> recordIds, String order, String config) {
       List<Amgt.NotificationDetails> nodes = new List<Amgt.NotificationDetails> ();
        try { 
            if( config == null ||
                string.isBlank(config) ||
                recordIds == null ||
                order == null
            )
            {
                throw new SvmxSystem.SvmxNestedException( System.Label.Message_IncorrectHierarchyOrder );
            }
            Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
            if(recordIds != null && recordIds.size() > 0) {
                nodes.addAll(assetHierarchyManager.getNotifications(recordIds[0],order,configuration));
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getHierarchyNodesNotification() : Failed to retrieve Hierarchy Nodes Notification. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getHierarchyNodesNotification() - exit; response.size() =' + nodes.size());
        }
        return nodes;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> fetchAssetsForGivenParentRaw (
        String parentId,
        String childRelationshipName,
        String config,
        String initiatedTime) {
        List<sObject> nodes = new List<sObject> ();
        try {
            if(String.isNotBlank(parentId) && string.isNotBlank(childRelationshipName) && string.isNotBlank(config))  {
                Amgt.HierarchyConfiguration configuration = (Amgt.HierarchyConfiguration) JSON.deserialize(config, Amgt.HierarchyConfiguration.class);
                nodes = assetHierarchyManager.fetchAssetsForGivenParentRaw (parentId, childRelationshipName,configuration);         
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return nodes;
    }
}