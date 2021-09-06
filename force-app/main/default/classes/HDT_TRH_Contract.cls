
/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/04/2021
* @description Class HDT_TRH_Contract
* @history Keltin Mesonjesi – 19/04/2021 – Created class
*/
public inherited sharing class HDT_TRH_Contract extends HDT_TRH_TriggerHandler {

    public override void beforeInsert() {
      
    }

    public override void afterInsert() {
        HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
    }

    public override void beforeDelete() {

    }

    public override void afterDelete() {

    }

    public override void beforeUpdate(){
        System.debug('HDT_TRH_Contract.beforeUpdate');
        // system.debug('START HDT_TRH_Contract beforeUpdate');
        // HDT_UTL_ContractProcess.orderCompletataPhaseManagement(Trigger.new);
        // system.debug('END HDT_TRH_Contract beforeUpdate');
        HDT_QR_Order qrOrder = new HDT_QR_Order();
        List<id> listOrderId = new List<id>();
        List<Contract> listContract = new List<Contract>();
        for (Contract tempContract : (List<Contract>)Trigger.new) {
            if (String.isNotBlank(String.valueOf(tempContract.SBQQ__Order__c))&& 
            (String.isBlank( String.valueOf(tempContract.ServicePoint__c)) ||String.isBlank( String.valueOf(tempContract.BillingProfile__c)) || String.isBlank( tempContract.Market__c  ) 
            || String.isBlank( tempContract.VAT__c))     
            ) {
              listOrderId.add(tempContract.SBQQ__Order__c);
              listContract.add(tempContract);
            }

        }
        if (!listOrderId.isEmpty()) {
            Map<Id, Order> mapOrder = qrOrder.getOrdersRecord(listOrderId);
      
            if (mapOrder!=null && !mapOrder.isEmpty() ) {
                for (Contract tempContract :listContract) {
                    if (String.isNotBlank(String.valueOf(tempContract.SBQQ__Order__c)) &&mapOrder.get(tempContract.SBQQ__Order__c)!=null ) {
                        tempContract.ServicePoint__c   = mapOrder.get(tempContract.SBQQ__Order__c).ServicePoint__c;
                        tempContract.BillingProfile__c = mapOrder.get(tempContract.SBQQ__Order__c).BillingProfile__c;
                        tempContract.Market__c         = mapOrder.get(tempContract.SBQQ__Order__c).Market__c; 
                        tempContract.VAT__c            = mapOrder.get(tempContract.SBQQ__Order__c).VAT__c ;  //02/09/2021 Email Fix Campo VAT__c su Contratto   
    
                    }
                }
            }
        }
    }

    public override void afterUpdate() {
       HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
    }
}
