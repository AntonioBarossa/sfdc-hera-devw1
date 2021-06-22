public inherited sharing class HDT_TRH_Contract extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){}
    	
    public override void afterInsert(){}

    public override void beforeDelete(){}

 	public override void afterDelete(){}

    public override void beforeUpdate(){
        system.debug('START HDT_TRH_Contract beforeUpdate');
        // HDT_UTL_ContractProcess.orderCompletataPhaseManagement(Trigger.new);
        system.debug('END HDT_TRH_Contract beforeUpdate');
    }

    public override void afterUpdate(){}

}
