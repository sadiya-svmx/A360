/* sfge-disable ApexFlsViolationRule */
public with sharing class ADM_TagHandler {
    /**
     * Static variable to hold instance of this class.
     */
    private static ADM_TagHandler instance = null;
    /**
     * Private constructor to restrict multiple instance creation of this class.
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private ADM_TagHandler() {
    }

    /**
     * Static method to return instance of this class.
     */
    public static ADM_TagHandler getInstance() {
        
        if( instance == null ) {
            instance = new ADM_TagHandler();
        }

        return instance;
    }

    public void manageSVMXTags(final Id entityId, final List<String> tagsList) {
        try{
            //Converting to Set to remove duplicate tags
            if (tagsList == null) {
                tagsList = new List<String>();
            }
            Set<String> tagsSet = new Set<String>(tagsList);
            Map<String, SVMXA360__CONF_TagElement__c> tagsToDeleteMap = new Map<String, SVMXA360__CONF_TagElement__c>();
            List<SVMXA360__CONF_TagElement__c> tagsToInsert; 

            for (SVMXA360__CONF_TagElement__c tagElement : (List<SVMXA360__CONF_TagElement__c>) SvmxDatabase.query([SELECT Id, SVMXA360__TagDefinition__r.Name FROM SVMXA360__CONF_TagElement__c WHERE SVMXA360__EntityId__c =: entityId])){

                if (!tagsSet.contains(tagElement.SVMXA360__TagDefinition__r.Name)) { 
                    tagsToDeleteMap.put(tagElement.SVMXA360__TagDefinition__r.Name, tagElement); //Tags to be deleted
                } else {
                    tagsSet.remove(tagElement.SVMXA360__TagDefinition__r.Name); //Remove tags which are already created
                }
            }

            if (!tagsSet.isEmpty()) {
                tagsToInsert = new List<SVMXA360__CONF_TagElement__c>();
                
                for (SVMXA360__CONF_TagDefinition__c tagDef :  (List<SVMXA360__CONF_TagDefinition__c>) SvmxDatabase.query([SELECT Id, Name FROM SVMXA360__CONF_TagDefinition__c WHERE Name IN : tagsSet])) {
                    if(tagsSet.contains(tagDef.Name)) {
                        tagsSet.remove(tagDef.Name);
                        tagsToInsert.add(new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDef.Id, SVMXA360__EntityId__c = entityId));
                    }
                }
            }

            if (!tagsSet.isEmpty()) {
                List<SVMXA360__CONF_TagDefinition__c> tagDefList = new List<SVMXA360__CONF_TagDefinition__c>();
                
                for (String tagName : tagsSet) {
                    SVMXA360__CONF_TagDefinition__c tagDef = new SVMXA360__CONF_TagDefinition__c(Name = tagName);
                    tagDefList.add(tagDef);
                }

                SvmxDatabase.insertRecord(tagDefList);

                if (tagsToInsert == null) {
                    tagsToInsert = new List<SVMXA360__CONF_TagElement__c>();
                }
                
                for (SVMXA360__CONF_TagDefinition__c tagDef : tagDefList) {
                    tagsToInsert.add(new SVMXA360__CONF_TagElement__c(SVMXA360__TagDefinition__c = tagDef.Id, SVMXA360__EntityId__c = entityId));
                }
            }

            if (tagsToInsert != null && !tagsToInsert.isEmpty()) {
                SvmxDatabase.insertRecord(tagsToInsert);
            }

            if (!tagsToDeleteMap.isEmpty()) {
                SvmxDatabase.deleteRecord(tagsToDeleteMap.values());

                List<SVMXA360__CONF_TagDefinition__c> tagDefnDelList = new List<SVMXA360__CONF_TagDefinition__c>();

                for (SVMXA360__CONF_TagDefinition__c tagDefnRec : (List<SVMXA360__CONF_TagDefinition__c>) SvmxDatabase.query([SELECT Id, Name, (SELECT Id from SVMXA360__TagElements__r) From SVMXA360__CONF_TagDefinition__c WHERE Name IN : tagsToDeleteMap.keySet()])) {
                    if(tagsToDeleteMap.keySet().contains(tagDefnRec.Name)) {
                        Integer count = 0;
                        for (SVMXA360__CONF_TagElement__c obj : tagDefnRec.SVMXA360__TagElements__r) { 
                            count++;
                        }
                        
                        if (count == 0) {
                            tagDefnDelList.add(tagDefnRec);
                        }
                    }   
                }

                if(!tagDefnDelList.isEmpty()){
                    SvmxDatabase.deleteRecord(tagDefnDelList);
                }
            }
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Exception occurred while inserting Servicemax Tags :' + ex.getMessage() + ' /n ' + ex.getStackTraceString());
            throw ex;
        }
    }

    public Map<String, List<String>> getSVMXTags(List<String> entityIds) {
        Map<String, List<String>> associatedTagsMap = new Map<String, List<String>>();
        
        if (!entityIds.isEmpty()) {
            
            for (SVMXA360__CONF_TagElement__c tagElement : (List<SVMXA360__CONF_TagElement__c>) SvmxDatabase.query([SELECT Id, SVMXA360__EntityId__c, SVMXA360__TagDefinition__r.Name FROM SVMXA360__CONF_TagElement__c WHERE SVMXA360__EntityId__c IN: entityIds ORDER BY SVMXA360__TagDefinition__r.Name])) {

                if (tagElement.SVMXA360__EntityId__c != null) { 
                    List<String> tempList = new List<String>();
                    
                    if (associatedTagsMap.containsKey(tagElement.SVMXA360__EntityId__c)) {
                        tempList = associatedTagsMap.get(tagElement.SVMXA360__EntityId__c);
                    }
                    
                    tempList.add(tagElement.SVMXA360__TagDefinition__r.Name);
                    associatedTagsMap.put(tagElement.SVMXA360__EntityId__c, tempList);
                }
            }
        }

        return associatedTagsMap;
    }

    public List<String> getAllTags() {
        
        List<String> tagsList = new List<String>();
        
        for(SVMXA360__CONF_TagDefinition__c tagRecord : (List<SVMXA360__CONF_TagDefinition__c>) SvmxDatabase.query([SELECT Id, Name FROM SVMXA360__CONF_TagDefinition__c])){
            tagsList.add(tagRecord.Name);
        }

        return tagsList;
    }
}