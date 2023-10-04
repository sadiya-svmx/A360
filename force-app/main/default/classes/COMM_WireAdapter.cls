/*****************************************************************************
 *                       Copyright (C) 2021 ServiceMax, Inc
 *                               All rights reserved
 *
 *****************************************************************************/

/**
 * This class offers a foundation of reusable/configurable methods/structures for any wireable
 * Apex services, such that they adhere to the behavior exhibited by standard wireable methods.
 * 
 * This class is a modular service layer class for the all Lightning Web Components.
 * This class should not be compile-time dependent on any product-specific code/config so as to
 * promote re-use across all products.
 * Optional dependencies that are resolved at runtime are fine if absolutely necessary.
 *
 * @author Jason Bradley
 * @version 1.0
 * @since 2021
 */
/*****************************************************************************************************
 *    ID        Name                    Date            Comment
 *****************************************************************************************************
 *              Jason Bradley          13 August 2021     Created.
 * 
 *****************************************************************************************************/
public inherited sharing class COMM_WireAdapter {
    public enum EWireType { READ, WRITE, UNSPECIFIED }

    public enum EWireExceptionType { BAD_PARAMETERS, INSUFFICIENT_ACCESS, INTERNAL_EXCEPTION, UNIMPLEMENTED_FEATURE }

    private static final Map<EWireExceptionType, Integer> EXCEPTION_TYPE_TO_STATUS_CODE = new Map<EWireExceptionType, Integer> {
        EWIreExceptionType.BAD_PARAMETERS => 400,
        EWireExceptionType.INSUFFICIENT_ACCESS => 403,
        EWireExceptionType.INTERNAL_EXCEPTION => 500,
        EWireExceptionType.UNIMPLEMENTED_FEATURE => 501
    };

    private static final List<EWireType> wireTypeStack = new List<EWireType>();

    public virtual class WireException extends Exception {
        @TestVisible
        protected EWireType wireType;

        @TestVisible
        protected EWireExceptionType exceptionType;
        
        public WireException(EWireType wireType, EWireExceptionType exceptionType, String message) {
            this(message);
            this.wireType = wireType;
            this.exceptionType = exceptionType;
        }
    }

    private static EWireType currentWireType {
        get {
            if (wireTypeStack.isEmpty()) {
                return EWireType.UNSPECIFIED;
            } else {
                return wireTypeStack[wireTypeStack.size() - 1];
            }
        }
        private set;
    }

    public static void pushWireType(EWireType wireType) {
        wireTypeStack.add(wireType);
    }

    public static EWireType popWireType() {
        if (wireTypeStack.isEmpty()) {
            return null;
        }

        return wireTypeStack.remove(wireTypeStack.size() - 1);
    }

    public static void throwBadParameters(String exceptionMessage) {
        throw new WireException(
            currentWireType,
            EWireExceptionType.BAD_PARAMETERS,
            exceptionMessage
        );
    }

    public static void throwInsufficientAccess() {
        throw new WireException(
            currentWireType,
            EWireExceptionType.INSUFFICIENT_ACCESS,
            'You don\'t have access to this record. Ask your administrator for help or to request access.'
        );
    }

    public static void throwInternalException(String exceptionMessage) {
        throw new WireException(
            currentWireType,
            EWireExceptionType.INTERNAL_EXCEPTION,
            exceptionMessage
        );
    }

    public static void throwUnimplementedException() {
        throw new WireException(
            currentWireType,
            EWireExceptionType.UNIMPLEMENTED_FEATURE,
            'This method has yet to be implemented.'
        );
    }

    public static void throwUnimplementedException(String featureName) {
        throw new WireException(
            currentWireType,
            EWireExceptionType.UNIMPLEMENTED_FEATURE,
            featureName + ' has yet to be implemented.'
        );
    }

    // Reference: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_error
    public class WireError {
        @AuraEnabled
        public Object body {get; set;}

        @AuraEnabled
        public Boolean ok {get; set;}

        @AuraEnabled
        public Integer status {get; set;}

        @AuraEnabled
        public String statusText {get; set;}
    }

    @TestVisible
    private static WireError createWireError(WireException e) {
        if (e == null) {
            return null;
        }

        EWireType wireType = e.wireType;

        WireError wireError = new WireError();

        wireError.ok = false;
        wireError.status = EXCEPTION_TYPE_TO_STATUS_CODE.get(e.exceptionType);
        wireError.statusText = e.getMessage();

        Map<String, Object> errorBody = new Map<String, Object> {
            'errorCode' => e.exceptionType.name(),
            'message' => e.getMessage(),
            'statusCode' => wireError.status
        };

        switch on (wireType) {
            when READ {
                wireError.body = new List<Map<String, Object>> { errorBody };
            }

            when WRITE {
                wireError.body = errorBody;
            }
        }

        return wireError;
    }
}