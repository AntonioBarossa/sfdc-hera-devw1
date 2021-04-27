public inherited sharing class HDT_UTL_ContractProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    
    public static void orderCompletataPhaseManagement(List<Contract> newContractList){
        
        //get List of orderIds from Contract
        List<String> orderIds = new List<String>();

        for (Contract newContract : newContractList) {
            orderIds.add(newContract.SBQQ__Order__c);
        }

        //retrieve orders with billingProfile and ServicePoint
        List<Order> orders = orderQr.getRecordsByOrdersIdsBulk(orderIds);

        //update BillingProfile__c & ServicePoint__c on Contract
        for (Order order : orders) {
            if (order.BillingProfile__c != null && order.ServicePoint__c != null) {
                for (Contract newContract : newContractList) {
                    if (newContract.SBQQ__Order__c == order.Id) {
                        newContract.BillingProfile__c = order.BillingProfile__c;
                        newContract.ServicePoint__c = order.ServicePoint__c;
                    }
                }
            }
        }

    }

}