public with sharing class ADM_ServicemaxTagTriggerHandler {
    
    /**
     * Private static instance variable to hold instance of this class.
     */
    private static final ADM_ServicemaxTagTriggerHandler instance = new ADM_ServicemaxTagTriggerHandler();

    /**
     * Public method to retrieve instance of this class.
     */
    public static ADM_ServicemaxTagTriggerHandler getInstance() {
        return instance;
    }
    
    public void validateDuplicateRecords (List<SVMXA360__CONF_ServicemaxTags__c> tagRecords) {
        Set<String> contextList = new Set<String>();
        Set<String> masterTextList = new Set<String>();
        Map<String,SVMXA360__CONF_ServicemaxTags__c> contextMap = new Map<String,SVMXA360__CONF_ServicemaxTags__c>();
        for (SVMXA360__CONF_ServicemaxTags__c tagRecord: tagRecords) {
            String key = tagRecord.SVMXA360__Context__c+tagRecord.SVMXA360__MasterText__c;
            if(contextMap.containsKey(key)){	
                tagRecord.addError('Duplicate detected');
            }else{
                contextList.add (tagRecord.SVMXA360__Context__c);
                contextMap.put (key,tagRecord);
                masterTextList.add(tagRecord.SVMXA360__MasterText__c);
            }
        }
        for(SObject tagRecord: 
            SvmxDatabase.query(
                [select Id,SVMXA360__Context__c,SVMXA360__MasterText__c from SVMXA360__CONF_ServicemaxTags__c
                 where SVMXA360__Context__c in :contextList and SVMXA360__MasterText__c in :masterTextList])){
            String key = (String)tagRecord.get('SVMXA360__Context__c')+(String)tagRecord.get('SVMXA360__MasterText__c');
            if (contextMap.containsKey(key)){	
              contextMap.get(key).addError('Duplicate detected '+tagRecord.Id);
            }
        }
        
    }
}