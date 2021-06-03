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
        for (Order o : orderMapNew.values()){
            mapOrdToContact.put(o.id,o.contact__c);
        }
        Map<String,Contact> mapContact = new Map<String,Contact>(contactQr.getRecordsById(mapOrdToContact.values()));
        for(String ord : orderMapOld.keyset()){
           order oldOrd =  orderMapOld.get(ord);
           if(orderMapNew.get(ord) != null){
               order newOrd = orderMapNew.get(ord);
               if(oldOrd.phase__c != newOrd.Phase__c){
                   Contact c = null;
                   if(mapContact.get(newOrd.Contact__c) != null){
                       c = mapContact.get(newOrd.Contact__c);
                   }
                   System.debug('**************Eccolo:' + c);
                   commList.add(commUTL.instanceCommunicationLog('Attivazioni',newOrd.ProcessType__c,newOrd.Phase__c,newOrd.status,newOrd.CancellationReason__c,newOrd.Id,'',newOrd.Contact__c,newOrd.AccountId,c != null ? c.company__c : 'ND',newOrd.CompanyOwner__c));
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }
    
    // START @Picchiri HRADTR-77 Calcolo Date 01.06.21
    public static void orderCalulateDateUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) {
        system.debug('orderCalulateDateUpdate trigger --> newOrdersList : ' + JSON.serializePretty(newOrdersList));
        system.debug('orderCalulateDateUpdate trigger --> oldOrdersList : ' + JSON.serializePretty(oldOrdersList));
        List<Order> orderList = new List<Order>();                        
        for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {
                if (newOrder.SignedDate__c != oldOrder.SignedDate__c && (newOrder.WizardCompletedDate__c != null || newOrder.WizardCompletedDate__c != oldOrder.WizardCompletedDate__c) ) {                    
                    Order orderToUpdate = new Order();
                    orderToUpdate.id = newOrder.Id;
                    
                    orderToUpdate.EffectiveDate__c = HDT_UTL_SwtichInProcess.getEffectiveDate(newOrder);
                    orderToUpdate.MaxAfterthoughtDate__c = HDT_UTL_SwtichInProcess.getMaxAfterthoughtDate(newOrder);                 
                    orderToUpdate.DateSentToSII__c = HDT_UTL_SwtichInProcess.getDateSentToSii(newOrder);                                                      
                    orderList.add(orderToUpdate);                    
                }
            }
        }
        
        update orderList;

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
            if (order.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && order.Phase__c == 'Plico validato Firmato') {
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
            if (order.RecordType.DeveloperName == 'HDT_RT_OrderDossier' && order.Phase__c == 'Plico validato Firmato') {
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
                if(newOrder.TecnicalPhase__c != null && newOrder.TecnicalPhase__c == old.TecnicalPhase__c && newOrder.Phase__c=='Comunicazione verso Heroku'){
                    newOrder.Phase__c = newOrder.TecnicalPhase__c;
                    newOrder.TecnicalPhase__c = null;
                }
            }
        }
        return newOrdersList;
    }


}