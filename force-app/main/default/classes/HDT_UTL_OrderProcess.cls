public inherited sharing  class HDT_UTL_OrderProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_UTL_CommunicationLog commUtl = new HDT_UTL_CommunicationLog();
    private static HDT_SRV_CommunicationLog commSrv = new HDT_SRV_CommunicationLog(); 
    
    public static void salesProcessManagementBefore(list<Order> newOrderList,List<Order> oldOrderList){
        
    }    
    public static void salesProcessManagementAfter(list<Order> newOrderList,List<Order> oldOrderList){
        
    }

    public static void orderPhaseManagementAfterUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) {

        Map<String,Order> orderMapNewToOld = new Map<String,Order>();
        Map<String,Order> orderMapOld = new Map<String,Order>();
        Map<String,Order> orderMapNew = new Map<String,Order>();
        
   /*     for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {
                if (newOrder.Id == oldOrder.Id) {
                    orderMapNewToOld.put(newOrder.Id, oldOrder);
                }
            }
        }*/
        
        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
           	orderMapNew.put(newOrder.id,newOrder);
            if(orderMapOld.get(newOrder.id)!= null){
                orderMapNewToOld.put(newOrder.id,orderMapOld.get(newOrder.id));
            }
        }

        List<String> orderList = getParentOrders(newOrdersList, oldOrdersList, orderMapNewToOld);
        //List<id> docVali = filterByRecordTypeAndPhase(orderList,)
        updateChildOrdersPhase(orderList, 'Documentazione Validata', 'Comunicazione verso Heroku','Documentazione Validata','Comunicazione Motore VAS');
		insertLogForOrderChangedPhase(orderMapOld,orderMapNew);
    }
	
    private static void insertLogForOrderChangedPhase(Map<String,Order> orderMapOld, Map<String,Order> orderMapNew){
        List<CommunicationLog__c> commList = new List<CommunicationLog__c>();
        Map<String,String> mapOrdToContact = new map<String,String>();
        HDT_QR_RecordType recordtypeQR = new HDT_QR_RecordType();
        String recordtypeParentId = recordtypeQR.getRecordTypeIdByName('HDT_RT_OrderDossier');
        for (Order o : orderMapNew.values()){
            mapOrdToContact.put(o.id,o.contact__c);
        }
        Map<String,Contact> mapContact = new Map<String,Contact>(contactQr.getRecordsById(mapOrdToContact.values()));
        for(String ord : orderMapOld.keyset()){
           order oldOrd =  orderMapOld.get(ord);
           if(orderMapNew.get(ord) != null){
               order newOrd = orderMapNew.get(ord);
               if(oldOrd.phase__c != newOrd.Phase__c && newOrd.recordtypeid != recordtypeParentId){
                   String st = newOrd.Status;
                   if('annullato'.equalsIgnoreCase(st)){
                       st = 'Chiuso';
                   }
                   Contact c = null;
                   if(mapContact.get(newOrd.Contact__c) != null){
                       c = mapContact.get(newOrd.Contact__c);
                   }
                   System.debug('**************Eccolo:' + c);
                   commList.add(commUTL.instanceCommunicationLog('Attivazioni',newOrd.ProcessType__c,newOrd.Phase__c,st,newOrd.CancellationReason__c,newOrd.Id,'',newOrd.Contact__c,newOrd.AccountId,c != null ? c.company__c : 'ND',newOrd.CompanyOwner__c));
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }

    // START @Picchiri HRADTR-77 Calcolo Date 01.06.21
    // Ricalcolo delle date
    public static void orderCalulateDateUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) {
        system.debug('orderCalulateDateUpdate trigger --> newOrdersList : ' + JSON.serializePretty(newOrdersList));
        system.debug('orderCalulateDateUpdate trigger --> oldOrdersList : ' + JSON.serializePretty(oldOrdersList));
        List<Order> orderList = new List<Order>();                        
        for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {
                if (newOrder.SignedDate__c != oldOrder.SignedDate__c && (newOrder.WizardCompletedDate__c != null || newOrder.WizardCompletedDate__c != oldOrder.WizardCompletedDate__c) && newOrder.Status != 'Annullato' ) {
                    Order orderToUpdate = new Order();
                    orderToUpdate.id = newOrder.Id;                                        
                    orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(newOrder);                 
                    orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(newOrder);                                                      
                    orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(newOrder);
                    orderList.add(orderToUpdate);                    
                }
            }
        }
        
        if(orderList.size() > 0){
            update orderList;
        }        

    }
    // END @Picchiri HRADTR-77 Calcolo Date 01.06.21
    
    private static List<String> getParentOrders(List<Order> newOrdersList, List<Order> oldOrdersList, Map<String,Order> orderMapNewToOld){
        List<String> orderIds = new List<String>();
        for (Order newOrder : newOrdersList) {
            orderIds.add(newOrder.Id);
        }

        List<String> orderIdsToReturn = new List<String>();

        orderSrv.checkReadAccess('RecordType.DeveloperName, Phase__c');
        List<Order> ordersFullList = orderQr.getRecordsByIds(orderIds);

        List<Order> ordersToUpdateContract = new List<Order>();

        for (Order order : ordersFullList) {
            if (order.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && order.Phase__c == 'Documentazione Gestita') {
                orderIdsToReturn.add(order.Id);
            }

            // if (order.RecordType.DeveloperName != 'HDT_RT_OrderDossier' && order.Status == 'Chiuso' && orderMapNewToOld.get(order.Id) != null && orderMapNewToOld.get(order.Id).Status != 'Chiuso') {
            //     ordersToUpdateContract.add(new Order(
            //         Id = order.Id,
            //         SBQQ__Contracted__c = true
            //     ));
            // }
        }
        // system.debug('****ordersToUpdateContract: ' + ordersToUpdateContract);
        // orderSrv.updateRecords(ordersToUpdateContract);

        return orderIdsToReturn;
    }

    private static List<Order> getParentOrders2(List<Order> newOrdersList, List<Order> oldOrdersList, Map<String,Order> orderMapNewToOld){
        List<String> orderIds = new List<String>();
        for (Order newOrder : newOrdersList) {
            orderIds.add(newOrder.Id);
        }

        List<String> orderIdsToReturn = new List<String>();

        orderSrv.checkReadAccess('RecordType.DeveloperName, Phase__c');
        List<Order> ordersFullList = orderQr.getRecordsByIds(orderIds);

        List<Order> ordersToUpdateContract = new List<Order>();

        for (Order order : ordersFullList) {
            if (order.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && order.Phase__c == 'Documentazione Gestita') {
                orderIdsToReturn.add(order.Id);
            }

            // if (order.RecordType.DeveloperName != 'HDT_RT_OrderDossier' && order.Status == 'Chiuso' && orderMapNewToOld.get(order.Id) != null && orderMapNewToOld.get(order.Id).Status != 'Chiuso') {
            //     ordersToUpdateContract.add(new Order(
            //         Id = order.Id,
            //         SBQQ__Contracted__c = true
            //     ));
            // }
        }
        // system.debug('****ordersToUpdateContract: ' + ordersToUpdateContract);
        // orderSrv.updateRecords(ordersToUpdateContract);

        return ordersFullList;
    }

    // @Future
    // public static void updateContractedTrue(){

    // }
    
    private static void updateChildOrdersPhase(List<String> parentOrderIds, String currentPhase, String newPhase) {
        
        List<Order> childOrdersToUpdate = new List<Order>();
        
        orderSrv.checkReadAccess('Phase__c');
        List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);

        for (Order childOrder : childOrders) {
            if (childOrder.Phase__c == currentPhase) {
                Order orderToUpdate = new Order(
                    Id = childOrder.Id,
                    Phase__c = newPhase
                );
                childOrdersToUpdate.add(orderToUpdate);
            }
        }

        orderSrv.updateRecords(childOrdersToUpdate);
    }
    private static void updateChildOrdersPhase(List<String> parentOrderIds, String currentPhase, String newPhase,String currentVasPhase,String newVasPhase) {
        
        List<Order> childOrdersToUpdate = new List<Order>();
        
        orderSrv.checkReadAccess('Phase__c');
        List<Order> childOrders = orderQr.getChildOrdersByParentIds(parentOrderIds);

        for (Order childOrder : childOrders) {
            if(childOrder.recordType.Developername == 'HDT_RT_VAS'){
                if (childOrder.Phase__c == currentVasPhase) {
                    Order orderToUpdate = new Order(
                        Id = childOrder.Id,
                        Phase__c = newVasPhase
                    );
                    childOrdersToUpdate.add(orderToUpdate);
                }
            }
            else{
                if (childOrder.Phase__c == currentPhase) {
                    Order orderToUpdate = new Order(
                        Id = childOrder.Id,
                        Phase__c = newPhase
                    );
                    childOrdersToUpdate.add(orderToUpdate);
                }
            }
        }

        orderSrv.updateRecords(childOrdersToUpdate);
    }
    public static List<Order> updatePhase(List<Order> newOrdersList, List<Order> oldOrdersList) {
        Map<String,Order> orderMapOld = new Map<String,Order>();
        List<Order> ordersToUpdate = new List<Order>();        
        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
            if(orderMapOld.get(newOrder.id)!= null){
                Order old= orderMapOld.get(newOrder.id);
                if(newOrder.TecnicalPhase__c != null && newOrder.TecnicalPhase__c == old.TecnicalPhase__c && 
                    (/*Eversi aggiunta fase*/newOrder.Phase__c == 'Documentazione Validata'/*Eversi aggiunta fase*/ || newOrder.Phase__c=='Comunicazione verso Heroku' || newOrder.Phase__c=='Ripensamento - Da inviare' || newOrder.Phase__c=='Annullamento - Da inviare')){
                    newOrder.Phase__c = newOrder.TecnicalPhase__c;
                    newOrder.TecnicalPhase__c = null;
                }
            }
        }
        return newOrdersList;
    }

    
    // START @Picchiri Credit check Date 04.06.21
    // Viene invocata da una modifica lato ordine
    // In questo metodo viene invocata la classe per la creazione della Activiti del Credit Check Entanti (Nuovo cliente) e Uscenti (Vecchio cliente)
    public static void creditCheckManager(List<Order> newOrdersList, List<Order> oldOrdersList) {
        system.debug('gestioneEsitiCreditCheck trigger --> newOrdersList : ' + JSON.serializePretty(newOrdersList));
        system.debug('gestioneEsitiCreditCheck trigger --> oldOrdersList : ' + JSON.serializePretty(oldOrdersList));
        Map<String,List<Order>> orderMapNew = new Map<String,List<Order>>();
        List<Order> orderListOldCustomer = new List<Order>();                        
        List<Order> orderListNewCustomer = new List<Order>();   
        List<Order> orderListcreditCheckPhaseManager = new List<Order>();                        
        List<Order> orderList = new List<Order>();                        
        

        for (Integer i = 0; i<newOrdersList.size(); i++) {
            Order newOrder = newOrdersList[i];
            Order oldOrder = oldOrdersList[i];   
            if((newOrder.RecordType.DeveloperName == 'HDT_RT_VAS' && newOrder.OrderReferenceNumber != null && newOrder.ContractReference__c != null) || newOrder.RecordType.DeveloperName == 'HDT_RT_Voltura' || newOrder.RecordType.DeveloperName == 'HDT_RT_Subentro' || newOrder.RecordType.DeveloperName == 'HDT_RT_AttivazioneConModifica' || newOrder.RecordType.DeveloperName == 'HDT_RT_SwitchIn' || newOrder.RecordType.DeveloperName == 'HDT_RT_ConnessioneConAttivazione' || newOrder.RecordType.DeveloperName == 'HDT_RT_TemporaneaNuovaAtt'){             
                if (newOrder.CreditCheckDescription__c != null && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c) {    
                        
                    if(newOrder.CreditCheckDescription__c == 'KO Precedente Cliente' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){
                        // cliente uscente
                        orderListOldCustomer.add(newOrder);
                    }
                    if(newOrder.CreditCheckDescription__c != 'KO Precedente Cliente' && newOrder.CreditCheckDescription__c != oldOrder.CreditCheckDescription__c){
                        // cliente entrante
                        orderListNewCustomer.add(newOrder);
                    }                                      
                }
                if((oldOrder.IncomingCreditCheckResult__c!=null && oldOrder.IncomingCreditCheckResult__c.contains('KO')) && (newOrder.IncomingCreditCheckResult__c != null && newOrder.IncomingCreditCheckResult__c.contains('OK'))){
                    orderListcreditCheckPhaseManager.add(newOrder);
                }
            }

        }

        orderMapNew.put('oldCustomer',orderListOldCustomer);
        orderMapNew.put('newCustomer',orderListNewCustomer);   
        
        system.debug('gestioneEsitiCreditCheck trigger --> orderMapNew : ' + JSON.serializePretty(orderMapNew));
        system.debug('gestioneEsitiCreditCheck trigger --> orderListcreditCheckPhaseManager : ' + JSON.serializePretty(orderListcreditCheckPhaseManager));
        
        HDT_UTL_ActivityCustomProcess.createActivityForCreditCheck(orderMapNew);
        if(!orderListcreditCheckPhaseManager.isEmpty()){
            creditCheckPhaseManager(orderListcreditCheckPhaseManager);                     
        }        
    }        
    // FINE @Picchiri Credit check Date 04.06.21

    // @Picchiri 16.06.21 chiamata Mulesoft // Lista di ordini per nuovo cliente dove si è ricevuto un ok dopo un ko
    public static void creditCheckPhaseManager(List<Order> orderList){ 
        List<Order> orderListToUpdate = new List<Order>();
        Map<Id,Order> mapIdToOrderUpdate = new Map<Id,Order>();
        Map<Id,Order> mapIdToOrderClean = new Map<Id,Order>();        
        Set<Id> orderSetId = new Set<Id>();
        List<wrts_prcgvr__Activity__c> actListToUpdate = new List<wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> actListToRecheck = new List<wrts_prcgvr__Activity__c>();
        Map<Id,wrts_prcgvr__Activity__c> mapIdOrderToActivity = new Map<Id,wrts_prcgvr__Activity__c>();

        for(Order orderToUpdate : orderList){
            if(orderToUpdate.ParentOrder__r.Phase__c == 'Documentazione Gestita' && (orderToUpdate.Phase__c == 'Documentazione Validata' || orderToUpdate.Phase__c == 'Documentazione da inviare' )){
                if(orderToUpdate.recordType.Developername != 'HDT_RT_VAS'){
                    orderToUpdate.Phase__c = 'Comunicazione verso Heroku';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }else{
                    orderToUpdate.Phase__c = 'Comunicazione Motore VAS';
                    orderListToUpdate.add(orderToUpdate);
                    mapIdToOrderUpdate.put(orderToUpdate.id,orderToUpdate);
                }
            }

            if((orderToUpdate.RecordType.DeveloperName == 'HDT_RT_VAS' && orderToUpdate.OrderReferenceNumber != null && orderToUpdate.ContractReference__c != null) || orderToUpdate.RecordType.DeveloperName == 'HDT_RT_Voltura' || orderToUpdate.RecordType.DeveloperName == 'HDT_RT_Subentro' || orderToUpdate.RecordType.DeveloperName == 'HDT_RT_AttivazioneConModifica' || orderToUpdate.RecordType.DeveloperName == 'HDT_RT_SwitchIn' || orderToUpdate.RecordType.DeveloperName == 'HDT_RT_ConnessioneConAttivazione' || orderToUpdate.RecordType.DeveloperName == 'HDT_RT_TemporaneaNuovaAtt'){             
                if((orderToUpdate.IncomingCreditCheckResult__c != null && orderToUpdate.IncomingCreditCheckResult__c == 'OK') || (orderToUpdate.OutgoingCreditCheckResult__c != null && orderToUpdate.OutgoingCreditCheckResult__c == 'OK')){
                    orderSetId.add(orderToUpdate.id);
                }                
            }
        }   

        // recuperare l'activity per questi ordini
        // Le activity sull'ordine potrebbero essere più di una. Bisogna prendere quella con record type "credit check ko" e Status__c "creata" e CreditCheckReason__c contiene  "Cattivo pagatore"
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id,RecordType.DeveloperName,Status__c,CreditCheckResults__c,Order__c  FROM wrts_prcgvr__Activity__c WHERE  (RecordType.DeveloperName = 'HDT_RT_CreditCheckKO' or RecordType.DeveloperName = 'HDT_RT_KoPrecedeteCliente') and Status__c = 'Creata' and Order__c IN :orderSetId];
        
        
        for(wrts_prcgvr__Activity__c act : actList){
            mapIdOrderToActivity.put(act.Order__c,act);
        }
        for(Order ord : orderList){
            
            wrts_prcgvr__Activity__c actToUpdate = mapIdOrderToActivity.get(ord.Id);
            actToUpdate.CreditCheckResolutionReason__c = ord.CreditCheckDescription__c;
            actToUpdate.CreditCheckReason__c = ord.CreditCheckDescription__c;
            actToUpdate.CreditCheckResults__c = ord.IncomingCreditCheckResult__c;
            actToUpdate.Status__c = 'KO Risolto';
            actListToUpdate.add(actToUpdate);
            
            if(ord.CreditCheckDescription__c.contains('Saldo debito cattivo pagatore')){
                mapIdToOrderClean.put(ord.id,ord);                
            }

            if(ord.CreditCheckDescription__c.contains('Saldo debito cattivo pagatore') || ord.OutgoingCreditCheckResult__c != null){                
                actListToRecheck.add(actToUpdate);
            }
        }

        HDT_UTL_ActivityCustomProcess.updateCreditCheckActivity(actListToUpdate);

        // sbiancare l'esito ( IncomingCreditCheckResult__c / CreditCheckDescription__c) su order e reinviare la chiamata 
        if(!mapIdToOrderClean.isEmpty()){
            mapIdToOrderUpdate = cleanCreditCheckOnOrder(mapIdToOrderClean,mapIdToOrderUpdate);             
        }
        
        
        if(!mapIdToOrderUpdate.isEmpty()){
            update  mapIdToOrderUpdate.values();                    
        }             

        // reinviare la chiamata        
        if(!actListToRecheck.isEmpty()){
            HDT_UTL_ActivityCustomProcess.recheckCreditCheck(actListToRecheck);
        }
        
        
    }

    public static Boolean manageCancellationProcess(List<Order> orderList, Map<Id,SObject> orderOldMapd){
		Order orderNew = orderList[0];
		Order orderOld = (Order) Trigger.oldMap.get(orderNew.Id);
		String newPhase = orderNew.Phase__c;
		String oldPhase = orderOld.Phase__c;
        DateTime nowDateTime = DateTime.now();
		if(String.isNotBlank(newPhase) && String.isNotBlank(oldPhase) && newPhase != oldPhase){
			if(newPhase.indexOf('Annullamento') > -1 || newPhase.equalsIgnoreCase('Annullato') || newPhase.indexOf('Ripensamento') > -1 || newPhase.equalsIgnoreCase('Ripensato')){
				orderNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c;
                return true;
			}else if(oldPhase.indexOf('Annullamento - ') > -1 || oldPhase.indexOf('Ripensamento - ') > -1){
                orderNew.PhaseStory__c = oldPhase+'@@'+newPhase+'@@'+nowDateTime.getTime()+'@@A||'+orderNew.PhaseStory__c;
				return true;
			}
		}
		return false;
	}

    // @Picchiri sbiancamento esito e causale credit check all'interno dell'ordine. 
    // Per risottomissione credit check
    public static Map<Id,Order> cleanCreditCheckOnOrder(Map<Id,Order> mapIdToOrderClean,Map<Id,Order> mapIdToOrderUpdate) {
        for (Id key : mapIdToOrderClean.keySet()) {
            mapIdToOrderUpdate.get(key).IncomingCreditCheckResult__c = '';
            mapIdToOrderUpdate.get(key).OutgoingCreditCheckResult__c = '';
            mapIdToOrderUpdate.get(key).CreditCheckDescription__c = '';
        }
        
        return mapIdToOrderUpdate;    
    }
    // FINE @Picchiri Credit check Date 15.06.21


}