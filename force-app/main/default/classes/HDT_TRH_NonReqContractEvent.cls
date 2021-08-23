public with sharing class HDT_TRH_NonReqContractEvent extends HDT_TRH_TriggerHandler{
    
    protected override void afterInsert() {
        System.debug('HDT_TRH_AnagAlignmentEvent trigger');
        List<Case> cases = new List<Case>();
        for (HDT_PEV_NonReqContract__e event : (List<HDT_PEV_NonReqContract__e>) Trigger.New) {
            Case c = (Case) JSON.deserialize(event.SerializedCase__c, Case.class);
            cases.add(c);
        }
        for (Case c : cases) {
            c.Phase__c = 'Da Inviare';
        }
        
        System.debug('Invio Case ad Heroku');
        HDT_UTL_DatabaseService.updateSObject(cases);
    }
}
