
/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/04/2021
* @description Class HDT_TRH_Contract
* @history Keltin Mesonjesi – 19/04/2021 – Created class
*/
public inherited sharing class HDT_TRH_Contract extends HDT_TRH_TriggerHandler {
    public override void beforeInsert() {
      
        for (Contract tempContract :(List<Contract>)Trigger.new) {
            if (String.isNotBlank(String.valueOf(tempContract.SBQQ__Order__c))) {
                tempContract.ServicePoint__c=tempContract.SBQQ__Order__r.ServicePoint__c;
                tempContract.BillingProfile__c=tempContract.SBQQ__Order__r.BillingProfile__c;
            }
           
          
        }
    }

    public override void afterInsert() {
        HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
    }

    public override void beforeDelete() {

    }

    public override void afterDelete() {

    }

    public override void beforeUpdate(){
        // system.debug('START HDT_TRH_Contract beforeUpdate');
        // HDT_UTL_ContractProcess.orderCompletataPhaseManagement(Trigger.new);
        // system.debug('END HDT_TRH_Contract beforeUpdate');
    }

    public override void afterUpdate() {
        HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
    }
}
