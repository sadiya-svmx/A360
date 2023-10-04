@IsTest
public class SvmxTestDataFactory {

    private static Set<String> ignoreFieldSet = new Set<String>{
        'OWNERID',
        'RECORDTYPEID',
        'LATITUDE',
        'LONGITUDE'
    };
        
    private static final COMM_DescribeManager describeManager = COMM_DescribeManager.getInstance();
    
    public static SObject insertSObject( final String objectName ) {
        return insertSObject( objectName, new Map<String,Object>() ) ;
    }
    
    public static SObject insertSObject( final String objectName, final Map<String,Object> valueMapping ) {
        return insertSObjectList( objectName, valueMapping, 1 ).get(0);
    }
    
    public static List<SObject> insertSObjectList( final String objectName, final Integer objectCount ) {
        return insertSObjectList( objectName, new Map<String,Object>(), objectCount );
    }
    
    public static List<SObject> insertSObjectList( final String objectName, final Map<String,Object> valueMapping, final Integer objectCount ) {
        
        List<SObject> newSObjectList = createSObjectList( objectName, valueMapping, objectCount );
        insert newSObjectList;
        
        return newSObjectList;
    }
    
    public static SObject createSObject( final String objectName ) {
        return createSObject( objectName, new Map<String,Object>() ) ;
    }
    
    public static SObject createSObject( final String objectName, final Map<String,Object> valueMapping ) {
        return createSObjectList( objectName, valueMapping, 1 ).get(0) ;
    }
    
    public static List<SObject> createSObjectList( final String objectName, final Integer objectCount ){
        return createSObjectList( objectName, new Map<String,Object>(), objectCount );
    }
    
    public static List<SObject> createSObjectList( final String objectName, final Map<String,Object> valueMapping, final Integer objectCount ) {
        
        final List<SObject> sObjectList = new List<SObject>();
        
        final Schema.DescribeSobjectResult describeSobjectResult = describeManager.getObjectDescribe( objectName );
        
        final Map<String, Schema.SObjectField> sObjectFieldMap = describeSobjectResult.fields.getMap();
        final Map<String, Schema.DescribeFieldResult> describeFieldResultMap = new Map<String, Schema.DescribeFieldResult>();
        
        for( Schema.SObjectField sObjectField : sObjectFieldMap.values() ) {
                
            final Schema.DescribeFieldResult describeFieldResult = describeManager.getFieldDescribe( sObjectField );
            
            if( !ignoreFieldSet.contains(describeFieldResult.getName().toUpperCase()) ) {
                
                if( ( describeFieldResult.isCustom() && !describeFieldResult.isCalculated() ) || ( !describeFieldResult.isCustom() && describeFieldResult.isCreateable() )  ) {
                    describeFieldResultMap.put( describeFieldResult.getName(), describeFieldResult );
                }
            }
        }
        
        final Schema.SobjectType sobjectType = describeSobjectResult.getSobjectType();
        final String nameFieldValue = ( objectName.length() > 34 ) ? objectName.substring(0, 34) : objectName;
        
        for( Integer index = 0; index < objectCount; index++ ) {
            
            if( describeFieldResultMap.values().size() != 0 ) {
                
                SObject newSObject = sobjectType.newSObject();
                for( Schema.DescribeFieldResult describeFieldResult : describeFieldResultMap.values() ) {
                    
                    if( describeFieldResult.getType() == Schema.DisplayType.REFERENCE && !valueMapping.containsKey( describeFieldResult.getName() ) ) {
                        continue;
                    }
                       
                    final Object fieldValue = valueMapping.containsKey( describeFieldResult.getName() ) 
                        ? valueMapping.get( describeFieldResult.getName() )
                        : describeFieldResult.isNameField() 
                            ? ( nameFieldValue + index ) 
                            : getDefaultFieldValue( describeFieldResult, index, describeFieldResult.getLength() );
                    
                    newSObject.put( describeFieldResult.getSObjectField(), fieldValue );
                }
                
                sObjectList.add(newSObject);
            }
        }
        
        return sObjectList;
    }

    public static void applyPermissionSetToCurrentUser(String permissionSetName) {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        applyPermissionSet(currentUser, permissionSetName);
    }

    public static void applyPermissionSet(User user, String permissionSetName) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName];

        if (ps != null) {
            Integer assignmentCount = [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId =: user.Id AND PermissionSetId =: ps.Id];

            if (assignmentCount == 0) {
                upsert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
            }
        }
    }

    public static void insertDefaultAllowedCoreObjects() {
        final Map<String, SVMXA360__CONF_CSET_GlobalProperties__c> allGlobalPropertyMap = SVMXA360__CONF_CSET_GlobalProperties__c.getAll();
        final List<SVMXA360__CONF_CSET_GlobalProperties__c> newGlobalProperties = new List<SVMXA360__CONF_CSET_GlobalProperties__c>();

        for( String name : Common.DefaultAllowedCoreObjects.keySet() ) {
                
            // Create Custom Setting if not exists.
            if( !allGlobalPropertyMap.containsKey(name) ) {
                
                final SVMXA360__CONF_CSET_GlobalProperties__c allowedCoreObject = new SVMXA360__CONF_CSET_GlobalProperties__c();
                allowedCoreObject.Name = name;
                allowedCoreObject.SVMXA360__Key__c = CONF_CustomSettingsManager.KEY_ALLOWED_CORE_OBJECT;
                allowedCoreObject.SVMXA360__Value__c = Common.DefaultAllowedCoreObjects.get(name);
                
                newGlobalProperties.add(allowedCoreObject);
            }
        }

        if( newGlobalProperties.size() > 0 ) {
            upsert newGlobalProperties;
        }

    }

    private static Object getDefaultFieldValue( final Schema.DescribeFieldResult describeFieldResult, final Integer recordIndex, final Integer length ) {
        
        Object retValue = null;
        
        switch on describeFieldResult.getType() {
            
            when Base64 {
                retValue = Blob.valueOf(recordIndex.format());
            }
            when Boolean {
                retValue = Boolean.valueOf(true);
            }
            when Currency {
                retValue = Decimal.valueOf(recordIndex);
            }
            when Date {
                retValue = Date.today();
            }
            when Email {
                retValue = 'testemail' + recordIndex.format() + '@servicemax.com';
            }
            when Location {
                retValue = Location.newInstance(0,0);
            }
            when Integer {
                retValue = Integer.valueOf(recordIndex);
            }
            when Double {
                retValue = Double.valueOf(recordIndex);
            }
            when Percent {
                retValue = Double.valueOf( (Math.random() * 100) );
            }
            when Phone {
                retValue = String.valueOf('9876543210');
            }
            when Picklist, MultiPicklist {
                retValue = getPicklistDefaultValue( describeFieldResult );
            }
            when String, TextArea {
                retValue = 'Default Text ' + recordIndex.format();
                retValue = ((String)retValue).length() > length ? ((String)retValue).substring(0, length-1) : retValue;
            }
            when Time {
                retValue = Time.newInstance(12, 0, 0, 0); 
            }
            when URL {
                retValue = 'http://testurl' + recordIndex + '.com';
            }
        }
        return retValue;
    }
    
    private static String getPicklistDefaultValue( final Schema.DescribeFieldResult describeFieldResult) {
        
        String picklistValue;
        
        List<Schema.PicklistEntry> picklistEntryList = describeFieldResult.getPicklistValues();        
        for( Schema.PicklistEntry picklistEntry : picklistEntryList ) {
            
            if( picklistEntry.isDefaultValue() ) {
                picklistValue = picklistEntry.getValue(); break;
            }    
        }
        
        if( picklistValue == null ) {
            picklistValue = picklistEntryList.get(0).getValue();
        }
        
        return picklistValue;
    }

    public class ToolingMockEndpoint implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
    
            if(req.getEndpoint().contains('QuickActionDefinition')) {
                Common.QuickActionDefinitionDetails details = new Common.QuickActionDefinitionDetails();
                details.records = new List<Common.QuickActionDefinition>();
                Common.QuickActionDefinition newCase = new Common.QuickActionDefinition();
                newCase.id = 'testId';
                newCase.label = 'New Case';
                newCase.name = 'NewCase';
                newCase.developerName = 'NewCase';
                newCase.type = 'Create';
                newCase.targetSobjectType = 'Case';
                details.records.add(newCase);
                response.setBody(JSON.serialize(details));
            } else if (req.getEndpoint().contains('LightningComponentBundle') && !req.getEndpoint().contains('LightningComponentResource')) {
                Common.LWCRecordDetails details = new Common.LWCRecordDetails();
                details.records = new List<Common.LWCRecord>();
                Common.LWCRecord lwc = new Common.LWCRecord();
                lwc.id = 'testId';
                lwc.masterLabel = 'Mock LWC';
                lwc.developerName = 'lwc';
                details.records.add(lwc);
                response.setBody(JSON.serialize(details));
            } else if (req.getEndpoint().contains('LightningComponentResource')) {  
                Common.LWCResourceDetails resourceDetails = new Common.LWCResourceDetails();
                resourceDetails.records = new List<Common.LWCResource>();
                Common.LWCResource lwcResource = new Common.LWCResource();
                lwcResource.lightningComponentBundleId = 'testId';
                lwcResource.source = '<isExposed>true</isExposed>';
                lwcResource.format = 'js';
                lwcResource.manageableState = 'unmanaged';
                lwcResource.filePath = 'lwc/mockLWC/mockLWC.js-meta.xml';
                resourceDetails.records.add(lwcResource);
                response.setBody(JSON.serialize(resourceDetails));
            }
    
            return response;
        }
    }
    
    public class NewRelicMockEndPoint implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest request) {
        	System.assertEquals('POST', request.getMethod());
        	System.assertEquals('https://insights-collector.newrelic.com/v1/accounts/3552021/events', request.getEndpoint());
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success":true, "uuid":"aa3c60fb-0001-bf0e-b714-018311dc6ee7"}');
            response.setStatusCode(200);
            return response;
        }
    }
}