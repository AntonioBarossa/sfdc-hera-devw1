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
        system.debug('orderPhaseManagementAfterUpdate START');

        Map<String,Order> orderMapNewToOld = new Map<String,Order>();
        Map<String,Order> orderMapOld = new Map<String,Order>();
        Map<String,Order> orderMapNew = new Map<String,Order>();
        
        ////// stesso order se phase__c diverso tra old e new chiamiamo funzione di una classe HDT_UTL_CommunicationLog
        
        for (Order oldOrder : oldOrdersList) {
            orderMapOld.put(oldOrder.id,oldOrder);
        }
        for (Order newOrder : newOrdersList) {
           	orderMapNew.put(newOrder.id,newOrder);
            if(orderMapOld.get(newOrder.id)!= null){
                orderMapNewToOld.put(newOrder.id,orderMapOld.get(newOrder.id));
            }
        }
        
        
       /* for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {
                if (newOrder.Id == oldOrder.Id) {
                    orderMapNewToOld.put(newOrder.Id, oldOrder);
                    break;
                }
            }
        }*/

        List<String> orderList = getParentOrders(newOrdersList, oldOrdersList, orderMapNewToOld);
        //List<id> docVali = filterByRecordTypeAndPhase(orderList,)
        updateChildOrdersPhase(orderList, 'Documentazione Validata', 'Comunicazione verso Heroku','Documentazione Validata','Comunicazione Motore VAS');
        insertLogForOrderChangedPhase(orderMapOld,orderMapNew);
        system.debug('orderPhaseManagementAfterUpdate END');
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
                   commList.add(commUTL.instanceCommunicationLog('Attivazioni',newOrd.ProcessType__c,newOrd.Phase__c,newOrd.status,newOrd.CancellationReason__c,newOrd.Id,'',newOrd.Contact__c,newOrd.AccountId,c != null ? c.company__c : '',newOrd.CompanyOwner__c));
               }
           }
        }
        if(commList != null && !commList.isEmpty()){
            commSRV.createRecords(commList);
        }
    }
    
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

    public static void updateFieldsByOrder(Order oNew, Order oOld)
    {   
        system.debug('updateFieldsByOrder START');
        
            CommunicationLog__c comm = new CommunicationLog__c();
            comm.Cluster__c= 'Attivazioni';
            comm.Processo__c = oNew.ProcessType__c;
            comm.Fase__c = oNew.Phase__c;
            comm.Stato__c = oNew.Status;
            comm.Causale__c = oNew.CancellationReason__c;
            comm.OrderID__c = oNew.Id;
            comm.ContactID__c= oNew.Contact__c;
            comm.AccountID__c= oNew.AccountId;
            comm.CompanyOwner__c = oNew.CompanyOwner__c;
            comm.Company__c = '';
            system.debug('updateFieldsByOrder comm insert : ' + comm);

            insert comm;
        

        system.debug('updateFieldsByOrder END');
    }

}