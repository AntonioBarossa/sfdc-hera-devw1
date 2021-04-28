/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 23/11/2020
* @description HDT_QR_Account – Contains queries for Account
* @history Keltin Mesonjesi – 23/11/2020 – Created class
* @history Sabina Levonja – 10/02/2021 – Added getRecordsById method 
*/
public inherited sharing class HDT_QR_Account {
    private static HDT_SRV_Contract contractSrv = new HDT_SRV_Contract();
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Account by Id
     * @param String id
     * @param String Fields
     * @return Account account
     */
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();


    public Account getRecordById(String id, String fields){

        accountSrv.checkReadAccess(fields);
        String query = 'SELECT '+ fields +
                ' FROM Account WHERE Id = :id WITH SECURITY_ENFORCED';
        Account accounts = Database.query(query);
        
        return accounts;
    }

    public List<Account> getRecordsById(List<String> accountIdList, String fields){
        accountSrv.checkReadAccess(fields);
        String query = 'SELECT '+ fields +
                ' From Account where id IN :accountIdList';
        List<Account> accounts = Database.query(query);

        return accounts;
    }

    public Account getBillingAddressAccount(String accountId){
        contractSrv.checkReadAccess('Id,BillingAddress');
        Account ac = new Account();
        //String query = 'SELECT Id,BillingAddress FROM Account WHERE Id ='+accountId;
        ac= [SELECT Id,BillingAddress FROM Account WHERE Id =: AccountId];
        //ac = database.query(query);
        system.debug('Account retrieved******'+ ac);
        return ac;
    }
}
