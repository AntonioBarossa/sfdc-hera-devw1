public inherited sharing  class HDT_UTL_OrderProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    
    public static void salesProcessManagementBefore(list<Order> newOrderList,List<Order> oldOrderList){
        
    }    
    public static void salesProcessManagementAfter(list<Order> newOrderList,List<Order> oldOrderList){
        
    }

    public static void orderPhaseManagementAfterUpdate(List<Order> newOrdersList, List<Order> oldOrdersList) {

        Map<String,Order> orderMapNewToOld = new Map<String,Order>();
        for (Order newOrder : newOrdersList) {
            for (Order oldOrder : oldOrdersList) {
                if (newOrder.Id == oldOrder.Id) {
                    orderMapNewToOld.put(newOrder.Id, oldOrder);
                }
            }
        }

        List<String> orderIds = getParentOrders(newOrdersList, oldOrdersList, orderMapNewToOld);
        updateChildOrdersPhase(orderIds, 'Documentazione validata', 'Comunicazione verso Heroku');

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

}