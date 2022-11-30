/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/04/2021
* @description Class HDT_TRH_Contract
* @history Keltin Mesonjesi – 19/04/2021 – Created class
*/
public inherited sharing class HDT_TRH_Contract extends HDT_TRH_TriggerHandler {

    public override void beforeInsert(){
        list<Contract> newContracts = (List<Contract>) Trigger.New;
        /*Set<Id> orderToContract = new Set<Id>();
        for(Contract c : newContracts){
            orderToContract.add(c.SBQQ__Order__c);
        }

        map<Id, Order> ordersMap = new Map<Id, Order>([Select isMultipleQuoteOffer__c from Order where id IN:orderToContract with Security_Enforced]);
        
        for(Contract c : newContracts){
            c.status='Attivo';
            if(ordersMap.get(c.SBQQ__Order__c).isMultipleQuoteOffer__c){
                //c.SBQQ__Quote__c=null;
            }
        }*/
        for(Contract c : newContracts){
            c.status='Attivo';
        }
    }

    public override void afterInsert() {
        HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
    }

    public override void beforeUpdate(){
        System.debug('HDT_TRH_Contract.beforeUpdate');
        // system.debug('START HDT_TRH_Contract beforeUpdate');
        // HDT_UTL_ContractProcess.orderCompletataPhaseManagement(Trigger.new);
        // system.debug('END HDT_TRH_Contract beforeUpdate');
        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKey(Trigger.new, Trigger.oldMap);
        HDT_QR_Order qrOrder = new HDT_QR_Order();
        List<id> listOrderId = new List<id>();
        List<Contract> listContract = new List<Contract>();
        for (Contract tempContract : (List<Contract>)Trigger.new) {
            if (String.isNotBlank(String.valueOf(tempContract.SBQQ__Order__c))&& 
            (String.isBlank( String.valueOf(tempContract.ServicePoint__c)) ||String.isBlank( String.valueOf(tempContract.BillingProfile__c)) || String.isBlank( tempContract.Market__c  ) 
            || String.isBlank( tempContract.VAT__c)|| String.isBlank( tempContract.CommercialProduct__c) 
            || String.isBlank(String.valueOf(tempContract.ActivatedDate))// HRDTR-00_HRAWRM-638
            || String.isBlank(tempContract.SAPContractCode__c)// HRDTR-00_HRAWRM-638

              )     
            ) {
              listOrderId.add(tempContract.SBQQ__Order__c);
              listContract.add(tempContract);
            }

        }
        if (!listOrderId.isEmpty()) {
            Map<Id, Order> mapOrder = qrOrder.getOrdersRecord(listOrderId);
      
            if (mapOrder!=null && !mapOrder.isEmpty() ) {
                for (Contract tempContract :listContract) {
                    try{
                        if (String.isNotBlank(String.valueOf(tempContract.SBQQ__Order__c)) &&mapOrder.get(tempContract.SBQQ__Order__c)!=null ) {
                            tempContract.ServicePoint__c   = mapOrder.get(tempContract.SBQQ__Order__c).ServicePoint__c;
                            tempContract.BillingProfile__c = mapOrder.get(tempContract.SBQQ__Order__c).BillingProfile__c;
                            tempContract.Market__c         = mapOrder.get(tempContract.SBQQ__Order__c).Market__c; 
                            tempContract.VAT__c            = mapOrder.get(tempContract.SBQQ__Order__c).VAT__c ;  //02/09/2021 Email Fix Campo VAT__c su Contratto
                            tempContract.ActivatedDate      = mapOrder.get(tempContract.SBQQ__Order__c).EffectiveDate__c ; //HRAWRM-638  17/09/2021
                            tempContract.SapContractCode__c = mapOrder.get(tempContract.SBQQ__Order__c).SapContractCode__c ; //HRAWRM-638  17/09/2021
                            tempContract.Pricebook2Id = mapOrder.get(tempContract.SBQQ__Order__c).SBQQ__Quote__r.SBQQ__PriceBook__c;
                            tempContract.SBQQ__AmendmentPricebookId__c = mapOrder.get(tempContract.SBQQ__Order__c).SBQQ__Quote__r.SBQQ__PriceBook__c;
                            tempContract.CommercialProduct__c = mapOrder.get(tempContract.SBQQ__Order__c).CommercialProduct__c;  //08/09/2021 HRAWRM-251
                            tempContract.ContractSalesCompany__c = mapOrder.get(tempContract.SBQQ__Order__c).SalesCompany__c;
                            /*@frpanico 14/02/2022
                            * Aggiunta scrittura della EndDate
                            * Nel caso di Temporanea - Nuova Attivazione
                            */ 
                            if( mapOrder.get(tempContract.SBQQ__Order__c) != null && ((String)mapOrder.get(tempContract.SBQQ__Order__c).get('ProcessType__c')).equalsIgnoreCase('Temporanea - Nuova Attivazione')
                                && String.isNotBlank(String.valueOf(mapOrder.get(tempContract.SBQQ__Order__c).get('TemporaryConnectionEndDate__c'))))
                                {
                                    tempContract.EndDate = (Date) mapOrder.get(tempContract.SBQQ__Order__c).get('TemporaryConnectionEndDate__c');
                                }
                        }
                    } catch (Exception e){
                        System.debug(LoggingLevel.DEBUG, '>>> HDT_TRH_Contract.beforeUpdate ' + e.getMessage());
                        tempContract.addError(e.getMessage());
                    }
                }
            }
        }


        list<Contract> newContracts = (List<Contract>) Trigger.New;
        Set<Id> orderToContract = new Set<Id>();
        for(Contract c : newContracts){
            orderToContract.add(c.SBQQ__Order__c);
        }
        map<Id, Order> ordersMap = new Map<Id, Order>([Select isMultipleQuoteOffer__c from Order where id IN :orderToContract]);
        //Set<id> contractsToBeBlanked = new Set<id>();
        for(Contract c : newContracts){
            if(ordersMap.containskey(c.SBQQ__Order__c) && ordersMap.get(c.SBQQ__Order__c).isMultipleQuoteOffer__c && c.SBQQ__Quote__c!=null){
                c.SBQQ__Quote__c=null;
            }
        }
    }

    public override void afterUpdate() {
        HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
        Map<Id, ServicePoint__c> spToActivate = new Map<Id, ServicePoint__c>();
        Set<Id> contractsForSieXiv = new Set<Id>();
        for(Contract c : (List<Contract>)Trigger.new){
            if(c.status=='Attivo' && c.ServicePoint__c!=null && Trigger.oldMap.get(c.id).get('ServicePoint__c')==null){
                spToActivate.put(c.ServicePoint__c, new ServicePoint__c(Id=c.ServicePoint__c, MeterStatus__c='Attivo'));
                contractsForSieXiv.add(c.Id);
            }
        }
        if(!spToActivate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(spToActivate.values());
            HDT_SRV_SieXiv sie = new HDT_SRV_SieXiv();
            sie.initSIE(contractsForSieXiv);
        }


       /*list<Contract> newContracts = (List<Contract>) Trigger.New;
       Set<Id> orderToContract = new Set<Id>();
       for(Contract c : newContracts){
           orderToContract.add(c.SBQQ__Order__c);
       }
       map<Id, Order> ordersMap = new Map<Id, Order>([Select isMultipleQuoteOffer__c from Order where id IN :orderToContract]);
       Set<id> contractsToBeBlanked = new Set<id>();
       for(Contract c : newContracts){
           if(ordersMap.get(c.SBQQ__Order__c).isMultipleQuoteOffer__c && c.SBQQ__Quote__c!=null){
               contractsToBeBlanked.add(c.id);
           }
       }
       if(!contractsToBeBlanked.isEmpty()){
           myUpdate(contractsToBeBlanked);
       }*/
    }
}