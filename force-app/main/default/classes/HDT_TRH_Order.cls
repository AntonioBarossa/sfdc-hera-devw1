public inherited sharing class HDT_TRH_Order {

    public void onBeforeInsert() {
    }

    public void onBeforeUpdate(){
        //Checks Phase Transition
        ((wrts_prcgvr.Interfaces_1_2.IPhaseManagerIntegration) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerIntegration'))
                .beforeUpdate(new Map<String, Object> { 'oldObjects' => Trigger.old, 'newObjects' => Trigger.new });
        
        //Checks Mandatory Activity
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkCheckCompleted(new Map<String,Object>{'triggerNew'=>Trigger.new, 'triggerOld' => Trigger.old});
        
    }
    public void onAfterUpdate() {
        //Execute creation Activities 
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkSaveActivityContext(null);
        
        //Handles callout (update only)
        ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils'))
                .bulkSend(new Map<String,Object>{'newObjects'=>Trigger.new, 'oldObjects' => Trigger.old});
        
    }

    public void onAfterInsert(){   
        wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt ObjectCompatibility =
            (wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt) wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');

        for(Order o : (Order[])trigger.New){
            //call the check for the candidate SObject
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result =
                (wrts_prcgvr.ObjectCompatibility_1_0.CheckResult) ObjectCompatibility.check(new Map<String,Object>{'sObject' => o});

            if(result.incompatibilities.size() > 0) {
                String msg = (result.incompatibilities.size() == 1) ? 'Incompatibility found on Order: ' : 'Incompatibilities found on Order: ';
                o.addError(msg + getIncompatibilityMessage((Order[])result.incompatibilities));
            }
        }
    }
    private static String getIncompatibilityMessage(Order[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        for(Order o : incomps){
            conflictIds.add(o.Id);
        }

        Set<String> conflicts = new Set<String>();
        for(Order o : [SELECT Id, OrderNumber, RecordType.Name FROM Order WHERE Id IN :conflictIds]) {
            conflicts.add(o.OrderNumber + ' (' + o.RecordType.Name + ')');
        }
        System.debug('conflicts: '+ conflicts);

        String[] conflictsString = new List<String>(conflicts);
        return String.join(conflictsString, ', ');
    }
}