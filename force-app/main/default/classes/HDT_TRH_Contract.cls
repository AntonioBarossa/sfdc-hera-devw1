public inherited sharing class HDT_TRH_Contract extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){}
    	
    public override void afterInsert() {
        // system.debug('START Trigger contract after insert');
        // HDT_UTL_ContractProcess.orderCompletataPhaseManagement(Trigger.new);
        // system.debug('END Trigger contract after insert');
    }

    public override void beforeDelete(){}
 	public override void afterDelete(){}
    public override void beforeUpdate(){}
    public override void afterUpdate(){
        // system.debug('START Trigger contract after update');
        // HDT_UTL_ContractProcess.orderCompletataPhaseManagement(Trigger.new);
        // system.debug('END Trigger contract after update');
    }

}
