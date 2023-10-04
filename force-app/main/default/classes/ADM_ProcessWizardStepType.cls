public with sharing class ADM_ProcessWizardStepType {
    private static final Map<String, ADM_ProcessWizardStepType> ENTRIES = new Map<String, ADM_ProcessWizardStepType>();

    public static final ADM_ProcessWizardStepType FLOW = new ADM_ProcessWizardStepType('Flow');
    public static final ADM_ProcessWizardStepType SPM_TRANSACTION = new ADM_ProcessWizardStepType('SPM Transaction');
    public static final ADM_ProcessWizardStepType RECORD_ACTION = new ADM_ProcessWizardStepType('Record Action');
    public static final ADM_ProcessWizardStepType LWC = new ADM_ProcessWizardStepType('Lightning Web Component');

    public String name {get; private set;}

    public static ADM_ProcessWizardStepType valueOf(String name) {
        return ENTRIES.get(name);
    }
        
    public static ADM_ProcessWizardStepType[] values() {
        return ENTRIES.values();
    }

    private ADM_ProcessWizardStepType(String name) {
        this.name = name;
        ENTRIES.put(name, this);
    }
        
    public override String toString() {
        return name;
    }
    
    public Boolean equals(Object o) {
        if (o instanceof ADM_ProcessWizardStepType) {
            ADM_ProcessWizardStepType that = ((ADM_ProcessWizardStepType) o);
            return this.name == that.name;
        }
        return false;
    }
        
    public Integer hashCode() {
        return name.hashCode();
    }
}