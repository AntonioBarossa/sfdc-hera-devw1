/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 23/11/2020
* @description HDT_QR_Account – Contains queries for Account
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_QR_Account {

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Account by Id
     * @param String id
     * @param String Fields
     * @return Account account
     */
    public Account getRecordById(String id, String fields){

        String query = 'SELECT '+ fields +
                ' FROM Account WHERE Id = :id WITH SECURITY_ENFORCED LIMIT 1';
        List<Account> accounts = Database.query(query);

        return accounts[0];
    }
}
