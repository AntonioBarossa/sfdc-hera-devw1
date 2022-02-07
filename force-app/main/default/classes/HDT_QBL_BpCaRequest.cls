public without sharing class HDT_QBL_BpCaRequest implements Queueable,Database.AllowsCallouts {
    private Account account;
    private Contact contact;
    private List<AccountContactRelation> accountContactRelList = new List<AccountContactRelation>();
    private string saleId;

    public HDT_QBL_BpCaRequest(Account acc ,Contact con) {
        this.account=acc;
        this.contact=con;
    }
    public HDT_QBL_BpCaRequest(List<AccountContactRelation> accountContactRelList, string saleId ) {
        this.accountContactRelList = accountContactRelList;
        this.saleId = saleId;
    }
    public void execute(QueueableContext context) {
        //System.debug('HDT_QBL_BpCaRequest.execute');
        if(!accountContactRelList.isEmpty()){
            HDT_UTL_Account.createBpCa(accountContactRelList, saleId);
        }else{
            HDT_UTL_Account.makeRequest(account,contact);
        }
        
    }
}