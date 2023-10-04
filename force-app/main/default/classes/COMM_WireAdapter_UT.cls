@IsTest
public class COMM_WireAdapter_UT {
    public static testMethod void test_throwBadParameters() {
        COMM_WireAdapter.WireException caughtException;
        String exceptionMessage = 'Bad Parameters';
        try {
            COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);
            COMM_WireAdapter.throwBadParameters(exceptionMessage);
            COMM_WireAdapter.popWireType();
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(exceptionMessage, caughtException.getMessage());
        System.assertEquals(COMM_WireAdapter.EWireType.READ, caughtException.wireType);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.BAD_PARAMETERS, caughtException.exceptionType);
    }

    public static testMethod void test_throwInsufficientAccess() {
        COMM_WireAdapter.WireException caughtException;
        try {
            COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);
            COMM_WireAdapter.throwInsufficientAccess();
            COMM_WireAdapter.popWireType();
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(COMM_WireAdapter.EWireType.READ, caughtException.wireType);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.INSUFFICIENT_ACCESS, caughtException.exceptionType);
    }

    public static testMethod void test_throwInternalException() {
        COMM_WireAdapter.WireException caughtException;
        String exceptionMessage = 'Internal Exception';
        try {
            COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);
            COMM_WireAdapter.throwInternalException(exceptionMessage);
            COMM_WireAdapter.popWireType();
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(exceptionMessage, caughtException.getMessage());
        System.assertEquals(COMM_WireAdapter.EWireType.READ, caughtException.wireType);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.INTERNAL_EXCEPTION, caughtException.exceptionType);
    }

    public static testMethod void test_throwUnimplementedException() {
        COMM_WireAdapter.WireException caughtException;
        try {
            COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);
            COMM_WireAdapter.throwUnimplementedException();
            COMM_WireAdapter.popWireType();
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }
        System.assertNotEquals(null, caughtException);
        System.assertEquals(COMM_WireAdapter.EWireType.READ, caughtException.wireType);
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE, caughtException.exceptionType);
    }

    public static testMethod void test_createWireError_Read() {
        COMM_WireAdapter.WireException caughtException;
        try {
            COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.READ);
            COMM_WireAdapter.throwUnimplementedException();
            COMM_WireAdapter.popWireType();
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }

        COMM_WireAdapter.WireError wireError = COMM_WireAdapter.createWireError(caughtException);
        System.assertNotEquals(null, wireError);
        System.assertEquals(false, wireError.ok);
        System.assertEquals(501, wireError.status);
        System.assertNotEquals(null, wireError.body);
        System.assertEquals(true, wireError.body instanceof List<Map<String, Object>>);
        List<Map<String, Object>> wireBody = (List<Map<String, Object>>)wireError.body;
        Map<String, Object> wireBodyDetails = wireBody[0];
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE.name(), wireBodyDetails.get('errorCode'));
        System.assertEquals('This method has yet to be implemented.', wireBodyDetails.get('message'));
        System.assertEquals(501, wireBodyDetails.get('statusCode'));
    }

    public static testMethod void test_createWireError_Write() {
        COMM_WireAdapter.WireException caughtException;
        try {
            COMM_WireAdapter.pushWireType(COMM_WireAdapter.EWireType.WRITE);
            COMM_WireAdapter.throwUnimplementedException();
            COMM_WireAdapter.popWireType();
        } catch (COMM_WireAdapter.WireException e) {
            caughtException = e;
        }

        COMM_WireAdapter.WireError wireError = COMM_WireAdapter.createWireError(caughtException);
        System.assertNotEquals(null, wireError);
        System.assertEquals(false, wireError.ok);
        System.assertEquals(501, wireError.status);
        System.assertNotEquals(null, wireError.body);
        System.assertEquals(true, wireError.body instanceof Map<String, Object>);
        Map<String, Object> wireBodyDetails = (Map<String, Object>)wireError.body;
        System.assertEquals(COMM_WireAdapter.EWireExceptionType.UNIMPLEMENTED_FEATURE.name(), wireBodyDetails.get('errorCode'));
        System.assertEquals('This method has yet to be implemented.', wireBodyDetails.get('message'));
        System.assertEquals(501, wireBodyDetails.get('statusCode'));
    }
}