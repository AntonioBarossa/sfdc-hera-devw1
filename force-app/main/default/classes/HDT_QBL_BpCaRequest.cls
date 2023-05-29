public without sharing class HDT_QBL_BpCaRequest implements Queueable,Database.AllowsCallouts {
    private Account account;
    private Contact contact;
    private List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();
    private string saleId;
    private Boolean searchToUse;

    public HDT_QBL_BpCaRequest(Account acc ,Contact con) {
        this.account=acc;
        this.contact=con;
    }
    public HDT_QBL_BpCaRequest(List<AccountContactRelation> accountContactRelList, string saleId, Boolean searchToUse) {
        this.accountContactRelList = accountContactRelList;
        this.saleId = saleId;
        this.searchToUse = searchToUse;
    }
    public void execute(QueueableContext context) {
        /*CPQ: Il trigger puo' essere spento in quanto non si necessita di ricalcoli */
        HDT_UTL_QuoteProcess.disableCpq();
        //System.debug('HDT_QBL_BpCaRequest.execute');
        if(!accountContactRelList.isEmpty()){
            HDT_UTL_Account.createBpCa(accountContactRelList, saleId, searchToUse);
            this.connectAccSpwithBp(saleId);
        }else{
            HDT_UTL_Account.makeRequest(account,contact);
        }
        HDT_UTL_QuoteProcess.enableCpq();
        
    }

    private void connectAccSpwithBp (Id saleId){
        Map<Id,ServicePoint__c> mapSpToModify = new Map<Id,ServicePoint__c>();
        for (SBQQ__QuoteLine__c qline : [SELECT
            Id,
            SBQQ__Quote__r.SBQQ__Account__c, 
            SBQQ__Quote__r.SBQQ__Account__r.CustomerCode__c, 
            ServicePoint__c,
            ServicePoint__r.Account__c, 
            ServicePoint__r.CustomerCodeSAP__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__r.Sale__c =:saleId
            AND SBQQ__Quote__r.SBQQ__Status__c NOT IN ('Cancelled','Rejected')
            AND SBQQ__Product__r.Name IN ('POD','PDR')
            AND ServicePoint__r.CustomerCodeSAP__c != null  WITH SECURITY_ENFORCED]){
            //System.debug('@@@QuoteLine '+JSON.serialize(qline) );    
            if (qline.ServicePoint__r.Account__c == null && qline.SBQQ__Quote__r.SBQQ__Account__r.CustomerCode__c == qline.ServicePoint__r.CustomerCodeSAP__c ){
                mapSpToModify.put(qline.ServicePoint__c,new ServicePoint__c(
                Account__c = qline.SBQQ__Quote__r.SBQQ__Account__c,Id = qline.ServicePoint__c,CustomerCodeSAP__c =null
                 ));
             }
            
         }
        if (!mapSpToModify.isEmpty()){
            HDT_UTL_DatabaseService.updateSObject(mapSpToModify.values());
        }

    }
}