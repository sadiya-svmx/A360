@IsTest
public with sharing class ADM_ProcessWizardStepType_UT {
    static testmethod void testStepTypeValues() {
        system.assertEquals(4, ADM_ProcessWizardStepType.values().size(), 'Step Type should contain 4 values');
    }

    static testmethod void testStepTypeValueOf() {
        system.assertEquals(ADM_ProcessWizardStepType.FLOW, ADM_ProcessWizardStepType.valueOf('Flow'), 'Value Of should equal the Entry value');
    }

    static testmethod void testStepTypeToString() {
        system.assertEquals('Flow', ADM_ProcessWizardStepType.FLOW.toString(), 'Entry Value toString() should return the string value');
    }

    static testmethod void testStepTypeEquals() {
        system.assertEquals(TRUE, ADM_ProcessWizardStepType.FLOW == ADM_ProcessWizardStepType.FLOW, 'Equals method should return true for the same Entry Value');
    }

    static testmethod void testStepTypeEquals_Null() {
        system.assertEquals(FALSE, ADM_ProcessWizardStepType.FLOW == null, 'Equals method should return false when compared to null');
    }

    static testmethod void testStepTypeHashCode_Equals() {
        system.assertEquals(TRUE, ADM_ProcessWizardStepType.FLOW.hashCode() == ADM_ProcessWizardStepType.FLOW.hashCode(), 'HashCode should be the same for the same Entry value');
    }

    static testmethod void testStepTypeHashCode_NotEquals() {
        system.assertEquals(FALSE, ADM_ProcessWizardStepType.FLOW.hashCode() == ADM_ProcessWizardStepType.SPM_TRANSACTION.hashCode(), 'Hashcode should be different for different Entry values');
    }
}