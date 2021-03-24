public inherited sharing class HDT_QR_MeterReading {
    
    public static List<Contract> getAccountContracts(List<Contract> contractList, String accountId){
        contractList = new List<Contract>();
        contractList = [
            SELECT Id, ContractNumber, Status, EndDate, StartDate, ServicePoint__r.Name
            FROM Contract
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];
        return contractList;
    }

}