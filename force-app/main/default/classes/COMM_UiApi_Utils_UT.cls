@IsTest
public class COMM_UiApi_Utils_UT {
    public static testMethod void test_getObjectDescribe() {
        // Expect Successful Responses
        List<String> objectApiNames = new List<String>{'User', 'Profile', 'Account', 'Contact'};
        for (String objectApiName : objectApiNames) {
            Schema.DescribeSObjectResult sObjectDescribeFirstResponse = COMM_UiApi_Utils.getObjectDescribe(objectApiName);
            System.assertNotEquals(null, sObjectDescribeFirstResponse);
            System.assertEquals(objectApiName, sObjectDescribeFirstResponse.getName());

            Schema.DescribeSObjectResult sObjectDescribeSecondResponse = COMM_UiApi_Utils.getObjectDescribe(objectApiName);
            System.assertEquals(sObjectDescribeFirstResponse, sObjectDescribeSecondResponse);
            System.assertEquals(objectApiName, sObjectDescribeSecondResponse.getName());
        }

        // Expect Failed Responses
        List<String> invalidApiNames = new List<String>{'', 'INVALIDAPI', 'doesnotexist', 'helloworld'};
        for (String invalidApiName : invalidApiNames) {
            Schema.DescribeSObjectResult invalidDescribe = COMM_UiApi_Utils.getObjectDescribe(invalidApiName);
            System.assertEquals(null, invalidDescribe);
        }
    }

    public static testMethod void test_getFieldDescribe() {
        // Expect Successful Responses
        List<String> fieldApiPaths = new List<String>{
            'User.Name', 'User.FirstName', 'User.LastName',
            'Profile.Name',
            'Account.Name',
            'Contact.Name', 'Contact.FirstName', 'Contact.LastName'
        };

        for (String fieldApiPath : fieldApiPaths) {
            List<String> fieldApiParts = fieldApiPath.split('\\.');
            String objectApiName = fieldApiParts[0];
            String fieldApiName = fieldApiParts[1];

            Schema.DescribeFieldResult fieldDescribeFirstResponse = COMM_UiApi_Utils.getFieldDescribe(objectApiName, fieldApiName);
            System.assertNotEquals(null, fieldDescribeFirstResponse);
            System.assertEquals(fieldApiName, fieldDescribeFirstResponse.getName());

            Schema.DescribeFieldResult fieldDescribeSecondResponse = COMM_UiApi_Utils.getFieldDescribe(objectApiName, fieldApiName);
            System.assertNotEquals(null, fieldDescribeSecondResponse);
            System.assertEquals(fieldApiName, fieldDescribeSecondResponse.getName());
        }

        // Expect Failed Responses
        List<String> invalidApiPaths = new List<String>{' . ', 'INVALIDAPI. ', 'INVALIDAPI.INVALIDAPI', 'doesnotexist.doesnotexist', 'helloworld.helloworld'};
        for (String invalidApiPath : invalidApiPaths) {
            List<String> invalidApiParts = invalidApiPath.split('\\.');
            String invalidObjectApiName = invalidApiParts[0];
            String invalidFieldApiName = invalidApiParts[1];

            Schema.DescribeFieldResult invalidDescribe = COMM_UiApi_Utils.getFieldDescribe(invalidObjectApiName, invalidFieldApiName);
            System.assertEquals(null, invalidDescribe);
        }
    }

    public static testMethod void test_getNameFields() {
        // Expect Successful Responses
        List<String> objectApiNames = new List<String>{'User', 'Profile', 'Account', 'Contact'};
        for (String objectApiName : objectApiNames) {
            List<String> nameFieldsFirstResponse = COMM_UiApi_Utils.getNameFields(objectApiName);
            System.assertNotEquals(null, nameFieldsFirstResponse);
            System.assertEquals(true, nameFieldsFirstResponse.size() > 0);

            List<String> nameFieldsSecondResponse = COMM_UiApi_Utils.getNameFields(objectApiName);
            System.assertEquals(nameFieldsFirstResponse, nameFieldsSecondResponse);
            System.assertEquals(true, nameFieldsSecondResponse.size() > 0);
        }

        // Expect Failed Responses
        List<String> invalidApiNames = new List<String>{'', 'INVALIDAPI', 'doesnotexist', 'helloworld'};
        for (String invalidApiName : invalidApiNames) {
            List<String> namefields = COMM_UiApi_Utils.getNameFields(invalidApiName);
            System.assertNotEquals(null, namefields);
            System.assertEquals(0, namefields.size());
        }
    }

    public static testMethod void test_getCompoundFieldMapping() {
        // Expect Successful Responses
        List<String> objectApiNames = new List<String>{'User', 'Profile', 'Account', 'Contact'};
        for (String objectApiName : objectApiNames) {
            Map<String, List<String>> compoundFieldMappingFirstResponse = COMM_UiApi_Utils.getCompoundFieldMapping(objectApiName);
            System.assertNotEquals(null, compoundFieldMappingFirstResponse);
            for (String compoundFieldApi : compoundFieldMappingFirstResponse.keySet()) {
                List<String> componentFields = compoundFieldMappingFirstResponse.get(compoundFieldApi);
                System.assertNotEquals(null, componentFields);
                System.assertEquals(false, componentFields.isEmpty());
            }

            Map<String, List<String>> compoundFieldMappingSecondResponse = COMM_UiApi_Utils.getCompoundFieldMapping(objectApiName);
            System.assertEquals(compoundFieldMappingFirstResponse, compoundFieldMappingSecondResponse);
            for (String compoundFieldApi : compoundFieldMappingSecondResponse.keySet()) {
                List<String> componentFields = compoundFieldMappingSecondResponse.get(compoundFieldApi);
                System.assertNotEquals(null, componentFields);
                System.assertEquals(false, componentFields.isEmpty());
            }
        }

        // Expect Failed Responses
        List<String> invalidApiNames = new List<String>{'', 'INVALIDAPI', 'doesnotexist', 'helloworld'};
        for (String invalidApiName : invalidApiNames) {
            Map<String, List<String>> namefields = COMM_UiApi_Utils.getCompoundFieldMapping(invalidApiName);
            System.assertNotEquals(null, namefields);
            System.assertEquals(0, namefields.size());
        }
    }

    public static testMethod void test_hasAccessToObject() {
        // Expect Successful Responses
        List<String> objectApiNames = new List<String>{'User', 'Profile', 'Account', 'Contact'};
        for (String objectApiName : objectApiNames) {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            System.assertNotEquals(null, sObjectType);
            Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();

            Boolean hasAccess = COMM_UiApi_Utils.hasAccessToObject(objectApiName);
            System.assertEquals(sObjectDescribe?.isAccessible(), hasAccess);
        }

        // Expect Failed Responses
        List<String> invalidApiNames = new List<String>{'', 'INVALIDAPI', 'doesnotexist', 'helloworld'};
        for (String invalidApiName : invalidApiNames) {
            System.assertEquals(false, COMM_UiApi_Utils.hasAccessToObject(invalidApiName));
        }
    }

    public static testMethod void test_hasAccessToField() {
        // Expect Successful Responses
        List<String> fieldApiPaths = new List<String>{
            'User.Name',
            'Profile.Name',
            'Account.Name',
            'Contact.Name', 'Contact.FirstName', 'Contact.LastName'
        };

        for (String fieldApiPath : fieldApiPaths) {
            List<String> fieldApiParts = fieldApiPath.split('\\.');
            String objectApiName = fieldApiParts[0];
            String fieldApiName = fieldApiParts[1];

            Schema.DescribeSObjectResult sObjectDescribe = COMM_UiApi_Utils.getObjectDescribe(objectApiName);
            Schema.DescribeFieldResult fieldDescribe = COMM_UiApi_Utils.getFieldDescribe(objectApiName, fieldApiName);
            Boolean hasAccess = COMM_UiApi_Utils.hasAccessToField(objectApiName, fieldApiName);
            System.assertEquals(
                sObjectDescribe?.isAccessible() && fieldDescribe?.isAccessible(),
                hasAccess
            );
        }

        // Expect Failed Responses
        List<String> invalidApiPaths = new List<String>{' . ', 'User.INVALID', 'INVALIDAPI. ', 'INVALIDAPI.INVALIDAPI', 'doesnotexist.doesnotexist', 'helloworld.helloworld'};
        for (String invalidApiPath : invalidApiPaths) {
            List<String> invalidApiParts = invalidApiPath.split('\\.');
            String invalidObjectApiName = invalidApiParts[0];
            String invalidFieldApiName = invalidApiParts[1];

            Boolean hasAccess = COMM_UiApi_Utils.hasAccessToField(invalidObjectApiName, invalidFieldApiName);
            System.assertEquals(false, hasAccess);
        }
    }

    public static testMethod void test_isStringArray() {
        // Expect Successful Responses
        List<Object> validInputs = new List<Object> {
            new List<String> {
                'Test1', 'Test2', 'Test3'
            },
            new List<Object> {
                'Test1', 'Test2', 'Test3'
            },
            (Object)(new List<Object> {
                'Test1', 'Test2', 'Test3'
            }),
            new List<Object> {},
            new List<String> {}
        };

        for (Object validInput : validInputs) {
            Boolean isStringArray = COMM_UiApi_Utils.isStringArray(validInput);
            System.assertEquals(true, isStringArray);
        }

        // Expect Failed Responses
        List<Object> invalidInputs = new List<Object> {
            'Test',
            new List<Boolean> {
                true, false, true
            },
            new List<Object> {
                'Test', true
            },
            null
        };
        for (Object invalidInput : invalidInputs) {
            Boolean isStringArray = COMM_UiApi_Utils.isStringArray(invalidInput);
            System.assertEquals(false, isStringArray);
        }
    }

    public static testMethod void test_isIdArray() {
        Id testId1 = UserInfo.getUserId(),
            testId2 = UserInfo.getOrganizationId(),
            testId3 = UserInfo.getProfileId();

        // Expect Successful Responses
        List<Object> validInputs = new List<Object> {
            new List<Id> {
                testId1, testId2, testId3
            },
            new List<Object> {
                testId1, testId2, testId3
            },
            (Object)(new List<Object> {
                testId1, testId2, testId3
            }),
            new List<Object> {},
            new List<String> {},
            new List<Id> {}
        };

        for (Object validInput : validInputs) {
            Boolean isStringArray = COMM_UiApi_Utils.isIdArray(validInput);
            System.assertEquals(true, isStringArray);
        }

        // Expect Failed Responses
        List<Object> invalidInputs = new List<Object> {
            'Test',
            new List<Boolean> {
                true, false, true
            },
            new List<Object> {
                testId1, testId2, testId3, true
            },
            null
        };
        for (Object invalidInput : invalidInputs) {
            Boolean isStringArray = COMM_UiApi_Utils.isIdArray(invalidInput);
            System.assertEquals(false, isStringArray);
        }
    }

    public static testMethod void test_convertToStringArray() {
        Map<List<Object>, List<String>> expectedResponses = new Map<List<Object>, List<String>> {
            // Test 1
            new List<Object> {
                null, true, 123, Date.newInstance(1970, 1, 1), 'test'
            } =>
            new List<String> {
                null, 'true', '123', '1970-01-01 00:00:00', 'test'
            },

            // Test 2
            new List<Object> {} =>
            new List<String> {},

            // Test 3
            null => null
        };

        for (List<Object> input : expectedResponses.keySet()) {
            List<String> expectedResponse = expectedResponses.get(input);
            List<String> response = COMM_UiApi_Utils.convertToStringArray(input);

            if (expectedResponse == null) {
                System.assertEquals(expectedResponse, response);
            } else {
                System.assertEquals(expectedResponse.size(), response.size());

                for (Integer i = 0; i < expectedResponse.size(); i++) {
                    System.assertEquals(expectedResponse[i], response[i]);
                }
            }
        }
    }

    public static testMethod void test_convertToIdArray() {
        Id testId1 = UserInfo.getUserId(),
            testId2 = UserInfo.getOrganizationId(),
            testId3 = UserInfo.getProfileId();

        // Expect Successful Responses
        Map<List<Object>, List<String>> expectedResponses = new Map<List<Object>, List<String>> {
            // Test 1
            new List<Object> {
                String.valueOf(testId1), String.valueOf(testId2), String.valueOf(testId3) 
            } =>
            new List<Id> {
                testId1, testId2, testId3
            },

            // Test 2
            new List<Object> {} =>
            new List<Id> {},

            // Test 3
            null => null
        };

        for (List<Object> input : expectedResponses.keySet()) {
            List<Id> expectedResponse = expectedResponses.get(input);
            List<Id> response = COMM_UiApi_Utils.convertToIdArray(input);

            if (expectedResponse == null) {
                System.assertEquals(expectedResponse, response);
            } else {
                System.assertEquals(expectedResponse.size(), response.size());

                for (Integer i = 0; i < expectedResponse.size(); i++) {
                    System.assertEquals(expectedResponse[i], response[i]);
                }
            }
        }

        // Expect Failed Responses
        List<List<Object>> invalidInputs = new List<List<Object>> {
            new List<Object> {true},
            new List<Object> {123},
            new List<Object> {Date.newInstance(1970, 1, 1)},
            new List<Object> {null}
        };

        for (List<Object> invalidInput : invalidInputs) {
            Boolean threwException = false;
            try {
                COMM_UiApi_Utils.convertToIdArray(invalidInput);
            } catch (Exception e) {
                threwException = true;
            }

            System.assertEquals(true, threwException);
        }
    }

    public static testMethod void test_getValueAsStringArray() {
        // Expect Successful Responses
        List<Object> validInputs = new List<Object> {
            'Test',
            new List<String> {'Test1', 'Test2', 'Test3'},
            new List<String> {},
            new List<Object> {}
        };

        for (Object validInput : validInputs) {
            List<String> response = COMM_UiApi_Utils.getValueAsStringArray(validInput);
            if (validInput instanceof String) {
                System.assertEquals(1, response.size());
                System.assertEquals(validInput, response[0]);
            } else {
                List<Object> inputAsArray = (List<Object>)validInput;
                System.assertEquals(inputAsArray.size(), response.size());

                for (Integer i = 0; i < inputAsArray.size(); i++) {
                    System.assertEquals(inputAsArray[i], response[i]);
                }
            }
        }

        // Expect Failed Responses
        List<Object> invalidInputs = new List<Object> {
            new List<Date> {Date.newInstance(1970, 1, 1)},
            false,
            123,
            null
        };
        for (Object invalidInput : invalidInputs) {
            Boolean threwException = false;
            try {
                COMM_UiApi_Utils.getValueAsStringArray(invalidInput);
            } catch (Exception e) {
                threwException = true;
            }

            System.assertEquals(true, threwException);
        }
    }

    public static testMethod void test_getValueAsIdArray() {
        Id testId1 = UserInfo.getUserId(),
            testId2 = UserInfo.getOrganizationId(),
            testId3 = UserInfo.getProfileId();

        // Expect Successful Responses
        List<Object> validInputs = new List<Object> {
            testId1,
            new List<Id> {testId1, testId2, testId3},
            new List<Id> {},
            new List<String> {},
            new List<Object> {}
        };

        for (Object validInput : validInputs) {
            List<String> response = COMM_UiApi_Utils.getValueAsIdArray(validInput);
            if (validInput instanceof Id) {
                System.assertEquals(1, response.size());
                System.assertEquals(validInput, response[0]);
            } else {
                List<Object> inputAsArray = (List<Object>)validInput;
                System.assertEquals(inputAsArray.size(), response.size());

                for (Integer i = 0; i < inputAsArray.size(); i++) {
                    System.assertEquals(inputAsArray[i], response[i]);
                }
            }
        }

        // Expect Failed Responses
        List<Object> invalidInputs = new List<Object> {
            new List<Date> {Date.newInstance(1970, 1, 1)},
            false,
            123,
            null
        };
        for (Object invalidInput : invalidInputs) {
            Boolean threwException = false;
            try {
                COMM_UiApi_Utils.getValueAsIdArray(invalidInput);
            } catch (Exception e) {
                threwException = true;
            }

            System.assertEquals(true, threwException);
        }
    }

    public static testMethod void test_convertUiApiFieldsToApexFields() {
        Map<List<String>, List<String>> testValues = new Map<List<String>, List<String>> {
            // Test Case
            new List<String> {
                'Contact.Name',
                'Contact.FirstName',
                'Contact.LastName',
                'Account.Name'
            } =>
            new List<String> {
                'Name',
                'FirstName',
                'LastName',
                'Name'
            },

            // Null Case
            null => new List<String> {}
        };

        for (List<String> testValue : testValues.keySet()) {
            List<String> expectedValues = testValues.get(testValue);
            List<String> receivedValues = COMM_UiApi_Utils.convertUiApiFieldsToApexFields(testValue);

            System.assertEquals(expectedValues.size(), receivedValues.size());
            for (Integer i = 0; i < expectedValues.size(); i++) {
                System.assertEquals(expectedValues[i], receivedValues[i]);
            }
        }
    }
}