/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 19/04/2021
* @description Class HDT_TRH_Contract
* @history Keltin Mesonjesi – 19/04/2021 – Created class
*/
public inherited sharing class HDT_TRH_Contract extends HDT_TRH_TriggerHandler {
    
    private static HDT_QR_Order qrOrder = new HDT_QR_Order();
    private static HDT_UTL_ContractSubscriptionRelocation subsRelocation = new HDT_UTL_ContractSubscriptionRelocation();

    public override void beforeInsert(){
        list<Contract> newContracts = (List<Contract>) Trigger.New;
        for(Contract c : newContracts){
            c.status='Attivo';
            c.SBQQ__PreserveBundleStructureUponRenewals__c = true;
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
                        if (String.isNotBlank(String.valueOf(tempContract.SBQQ__Order__c)) && mapOrder.get(tempContract.SBQQ__Order__c)!=null ) {
                            Order relatedOrder = mapOrder.get(tempContract.SBQQ__Order__c);

                            tempContract.ServicePoint__c   = relatedOrder.ServicePoint__c;
                            tempContract.BillingProfile__c = relatedOrder.BillingProfile__c;
                            tempContract.Market__c         = relatedOrder.Market__c; 
                            tempContract.VAT__c            = relatedOrder.VAT__c ;  //02/09/2021 Email Fix Campo VAT__c su Contratto
                            tempContract.ActivatedDate      = relatedOrder.EffectiveDate__c ; //HRAWRM-638  17/09/2021
                            tempContract.SapContractCode__c = String.isNotBlank(relatedOrder.SapContractCode__c)?relatedOrder.SapContractCode__c:tempContract.SapContractCode__c; //HRAWRM-638  17/09/2021
                            tempContract.Pricebook2Id = relatedOrder.SBQQ__Quote__r.SBQQ__PriceBook__c;
                            tempContract.SBQQ__AmendmentPricebookId__c = relatedOrder.SBQQ__Quote__r.SBQQ__PriceBook__c;
                            tempContract.CommercialProduct__c = relatedOrder.CommercialProduct__c;  //08/09/2021 HRAWRM-251
                            tempContract.ContractSalesCompany__c = relatedOrder.SalesCompany__c;

                            if('Ambiente' == relatedOrder?.Commodity__c && relatedOrder.EffectiveDate__c !=null){
                                tempContract.StartDate = relatedOrder.EffectiveDate__c;
                            }

                            /*@frpanico 14/02/2022
                            * Aggiunta scrittura della EndDate
                            * Nel caso di Temporanea - Nuova Attivazione
                            */ 
                            if( mapOrder.get(tempContract.SBQQ__Order__c) != null && 'Temporanea - Nuova Attivazione'.equalsIgnoreCase(((String)mapOrder.get(tempContract.SBQQ__Order__c).get('ProcessType__c')))
                                && String.isNotBlank(String.valueOf(mapOrder.get(tempContract.SBQQ__Order__c).get('TemporaryConnectionEndDate__c'))))
                                {
                                    tempContract.EndDate = (Date) mapOrder.get(tempContract.SBQQ__Order__c).get('TemporaryConnectionEndDate__c');
                                }
                        }
                    } catch (Exception e){
                        System.debug(LoggingLevel.DEBUG, '>>> HDT_TRH_Contract.beforeUpdate ' + e.getMessage());
                        System.debug(LoggingLevel.DEBUG, '>>> HDT_TRH_Contract.beforeUpdate ' + e.getStackTraceString());
                        tempContract.addError(e.getMessage());
                    }
                }
            }
        }

        HDT_UTL_GlobaMigrationKey.setGlobalMigrationKey(Trigger.new, Trigger.oldMap);

        list<Contract> newContracts = (List<Contract>) Trigger.New;
        List<Id> orderToContract = new List<Id>();
        for(Contract c : newContracts){
            orderToContract.add(c.SBQQ__Order__c);
        }
        map<Id, Order> ordersMap = qrOrder.getOrdersRecord(orderToContract);
        //Set<id> contractsToBeBlanked = new Set<id>();
        for(Contract c : newContracts){
            Order ord = ordersMap.get(c.SBQQ__Order__c);

            if(ord!=null && ord.isMultipleQuoteOffer__c && c.SBQQ__Quote__c!=null){
                c.SBQQ__Quote__c=null;
            }
            if(
                subsRelocation.checkConditionsBefore(c, ord)
            ){
                //SF Created a New Contract but SAP didn't so we must blank Global Migration Key, 
                //assign subscription to old contract and end old subscriptions
                //c.SapContractCode__c = null;
                c.GlobalMigrationKey__c = null;
                //c.SBQQ__Quote__c = null;
            }
        }
    }

    public override void afterUpdate() {
        HDT_UTL_ActiveServicesKpi.run(Trigger.newMap, Trigger.oldMap);
        Map<Id, ServicePoint__c> spToActivate = new Map<Id, ServicePoint__c>();
        Set<Id> contractsForSieXiv = new Set<Id>();

        List<id> listOrderId = new List<id>();
        for (Contract c : (List<Contract>)Trigger.new) {
            if( c.SBQQ__Order__c != null){      listOrderId.add(c.SBQQ__Order__c);     }
        }
        Map<Id, Order> mapOrder = qrOrder.getOrdersRecord(listOrderId);

        for(Contract c : (List<Contract>)Trigger.new){
            if(c.status=='Attivo' && c.ServicePoint__c!=null && Trigger.oldMap.get(c.id).get('ServicePoint__c')==null){
                spToActivate.put(c.ServicePoint__c, new ServicePoint__c(Id=c.ServicePoint__c, MeterStatus__c='Attivo'));
                contractsForSieXiv.add(c.Id);
            }
            Order ord = mapOrder.get(c.SBQQ__Order__c);
            if(ord?.Surface__c != null && 'Ambiente' == ord?.Commodity__c && c.ServicePoint__c != null){
                ServicePoint__c sp = spToActivate.get(c.ServicePoint__c);
                sp = sp!=null? sp : new ServicePoint__c(Id=c.ServicePoint__c);
                sp.AreaDeclaredTARI__c = ord.Surface__c;
                if(ord.CommercialProductLink__r.Family == 'Offerta commerciale'){
                    sp.RonchiCategoryCode__c = ord.RonchiCode__c;
                    sp.RonchiSubCategoryCode__c = ord.RonchiSubcat__c;
                }
                spToActivate.put(sp.Id, sp);
            }
        }

        if(!spToActivate.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(spToActivate.values());
            HDT_SRV_SieXiv sie = new HDT_SRV_SieXiv();
            sie.initSIE(contractsForSieXiv);
        }
    }

}