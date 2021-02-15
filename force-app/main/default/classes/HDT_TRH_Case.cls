public class  HDT_TRH_Case extends HDT_TRH_TriggerHandler {
	
    public override void beforeInsert(){}
 	public override void beforeDelete(){}
 	public override void afterDelete(){}
  	public override void afterUndelete(){}
    
    public override void beforeUpdate(){
        //Checks Phase Transition
        ((wrts_prcgvr.Interfaces_1_2.IPhaseManagerIntegration) wrts_prcgvr.VersionManager.newClassInstance('PhaseManagerIntegration'))
                .beforeUpdate(new Map<String, Object> { 'oldObjects' => Trigger.old, 'newObjects' => Trigger.new });
        
        //Checks Mandatory Activity
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkCheckCompleted(new Map<String,Object>{'triggerNew'=>Trigger.new, 'triggerOld' => Trigger.old});

    }

    public override void afterUpdate() {
        //Execute creation Activities 
        ((wrts_prcgvr.Interfaces_1_0.IActivityUtils) wrts_prcgvr.VersionManager.newClassInstance('ActivityUtils'))
                .bulkSaveActivityContext(null);
        
        //Handles callout (update only)
        ((wrts_prcgvr.Interfaces_1_0.ICalloutUtils) wrts_prcgvr.VersionManager.newClassInstance('CalloutUtils'))
                .bulkSend(new Map<String,Object>{'newObjects'=>Trigger.new, 'oldObjects' => Trigger.old});

    }

    public override void afterInsert(){   
        wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt ObjectCompatibility =
            (wrts_prcgvr.Interfaces_1_0.IObjectCompatibilityInt) wrts_prcgvr.VersionManager.newClassInstance('ObjectCompatibility');

        for(Case c : (Case[])trigger.New){
            //call the check for the candidate SObject
            wrts_prcgvr.ObjectCompatibility_1_0.CheckResult result =
                (wrts_prcgvr.ObjectCompatibility_1_0.CheckResult) ObjectCompatibility.check(new Map<String,Object>{'sObject' => c});

            if(result.incompatibilities.size() > 0) {
                String msg = (result.incompatibilities.size() == 1) ? 'Incompatibility found on Case: ' : 'Incompatibilities found on Cases: ';
                c.addError(msg + getIncompatibilityMessage((Case[])result.incompatibilities));
            }
        }
    }   
    
    private static String getIncompatibilityMessage(Case[] incomps){
        Set<Id> conflictIds = new Set<Id>();
        for(Case c : incomps){
            conflictIds.add(c.Id);
        }

        Set<String> conflicts = new Set<String>();
        
        for(Case c : [SELECT Id, CaseNumber, RecordType.Name FROM Case WHERE Id IN :conflictIds]) {
            conflicts.add(c.CaseNumber + ' (' + c.RecordType.Name + ')');
        }
        System.debug('conflicts: '+ conflicts);

        String[] conflictsString = new List<String>(conflicts);
        return String.join(conflictsString, ', ');
    }

}