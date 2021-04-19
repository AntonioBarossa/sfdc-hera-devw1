public inherited sharing class HDT_UTL_ContractProcess {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    
    public static void orderCompletataPhaseManagement(List<Contract> newContractList){
        
        List<String> contractIds = getContractIds(newContractList);

        system.debug('contractIds: ' + contractIds);

        List<Contract> contractsWithOrders = contractQr.getRecordsWithOrders(contractIds);

        system.debug('****contractsWithOrders: ' + contractsWithOrders);

        // List<Contract> contractsToUpdate = prepareContractToUpdateFieldsFromOrder(contractsToQuery);

        // system.debug('****contractsToUpdate: ' + contractsToUpdate);

        // contractSrv.updateRecords(contractsToUpdate);

    }

    private static List<String> getContractIds(List<Contract> newContractList){
        List<String> ids = new List<String>();

        for (Contract contract : newContractList) {
            ids.add(contract.Id);
        }

        return ids;
    }

    // private static List<Contract> prepareContractToUpdateFieldsFromOrder(List<Contract> contracts){

    //     List<Contract> contractsToUpdate = new List<Contract>();

    //     for (Contract contract : contracts) {

    //         if (contract.SBQQ__Order__r.BillingProfile__c != null && contract.SBQQ__Order__r.ServicePoint__c != null) {
    //             system.debug('***** START if prepareContractToUpdateFieldsFromOrder');
    //             contractsToUpdate.add(new Contract(
    //                 Id = contract.Id,
    //                 BillingProfile__c = contract.SBQQ__Order__r.BillingProfile__c,
    //                 ServicePoint__c = contract.SBQQ__Order__r.ServicePoint__c
    //             ));
    //         }
    //     }

    //     return contractsToUpdate;

    // }

}