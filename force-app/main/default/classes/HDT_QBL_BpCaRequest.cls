public without sharing class HDT_QBL_BpCaRequest implements Queueable,Database.AllowsCallouts {
    private Account account;
    private Contact contact;
    public HDT_QBL_BpCaRequest(Account acc ,Contact con) {
        this.account=acc;
        this.contact=con; 
    }
    public void execute(QueueableContext context) {
        //System.debug('HDT_QBL_BpCaRequest.execute');
        HDT_UTL_Account.makeRequest(account,contact);
        
    }
}
