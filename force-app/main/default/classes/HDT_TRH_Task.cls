public inherited sharing class HDT_TRH_Task extends HDT_TRH_TriggerHandler {

    protected override void beforeInsert() {
        //System.debug('HDT_TRH_Task before insert validation.');
        doValidation();
    }

    // protected override void beforeUpdate() {
    // }

    // protected override void afterInsert() {
    // }

    private void doValidation() {
        for (Task t : (List<Task>) Trigger.new) {
            if (t.IsSms__c == True && t.WhoId == null && t.PhoneNumber__c == null) {
                t.addError('È necessario inserire un Contatto oppure un numero di telefono alternativo.');
            } else if (t.IsPec__c == True && t.WhoId == null && t.PecAddress__c == null) {
                t.addError('È necessario inserire un Contatto oppure un indirizzo PEC alternativo.');
            }
        }
    }

}
