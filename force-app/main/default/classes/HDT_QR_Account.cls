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
     * @param id
     * @param fields
     * @return Account account
     */
    private static HDT_SRV_Account accountSrv = new HDT_SRV_Account();


    public Account getRecordById(String id, String fields){

        accountSrv.checkReadAccess(fields);

        List<Account> accountsList = Database.query('SELECT '+ String.escapeSingleQuotes(fields) +
        ' FROM Account WHERE Id = :id WITH SECURITY_ENFORCED'); //HRAWRM-588_code_review_1342
        
        Account account = new Account();

        if (!accountsList.isEmpty()) {
            account = accountsList[0];
        }
        
        return account;
    }

    /**
     * @description getRecordsById
     * @param accountIdList
     * @param fields
     * @return List<Account>
     */
    public List<Account> getRecordsById(List<String> accountIdList, String fields){
        accountSrv.checkReadAccess(fields);
        List<Account> accounts = Database.query('SELECT '+ String.escapeSingleQuotes(fields) +
        ' From Account where id IN :accountIdList'); //HRAWRM-588_code_review_1344

        return accounts;
    }

    /**
     * @description getBillingAddressAccount
     * @param accountId
     * @return Account
     */
    public Account getBillingAddressAccount(String accountId){
        contractSrv.checkReadAccess('Id,BillingStreetNumber__c,BillingStreetNumberExtension__c,BillingStreetName__c,BillingCity,BillingState,BillingPostalCode,BillingCountry,BillingStreetCode__c,BillingCityCode__c,BillingPlace__c');
        Account ac = new Account();
        //String query = 'SELECT Id,BillingAddress FROM Account WHERE Id ='+accountId;
        ac= [SELECT Id,BillingStreetNumber__c,BillingStreetNumberExtension__c,BillingStreetName__c,BillingCity,BillingState,BillingPostalCode,BillingCountry,BillingStreetCode__c,BillingCityCode__c,BillingPlace__c FROM Account WHERE Id =: AccountId WITH SECURITY_ENFORCED];
        //ac = database.query(query);
        system.debug('Account retrieved******'+ ac);
        return ac;
    }
    
    /**
     * @description getAccountByDistributorKey
     * @param globalKeyId
     * @return Account
     */
    public Account getAccountByDistributorKey(String globalKeyId){
        contractSrv.checkReadAccess('Id,Code__c');
        Account ac = new Account();
        List<Account> listAcc = new List<Account>();
        listAcc = [SELECT Id FROM Account WHERE Code__c =:globalKeyId WITH SECURITY_ENFORCED];
        //String query = 'SELECT Id,BillingAddress FROM Account WHERE Id ='+accountId;
        if(!listAcc.isEmpty()){
            ac= listAcc[0];
        }
        
        //ac = database.query(query);
        system.debug('Account retrieved******'+ ac);
        return ac;
    }

    public Account getAccountByName(String accName){
        Account ac = new Account();
        List<Account> listAcc = new List<Account>();
        listAcc = [SELECT Id FROM Account WHERE Name =:accName WITH SECURITY_ENFORCED];
        //String query = 'SELECT Id,BillingAddress FROM Account WHERE Id ='+accountId;
        if(!listAcc.isEmpty()){
            ac= listAcc[0];
        }
        system.debug('Account retrieved******'+ ac);
        return ac;
    }

    /**
     * @description getAccountByFiscalCode
     * @param fiscalCode
     * @return List<Account>
     */
    public List<Account> getAccountByFiscalCode(String fiscalCode) {
        if(STRING.isBlank(fiscalCode)){     return new List<Account>();     }
        
        return [
            SELECT
                Id,
                Phone, MobilePhone__c, OtherPhone__c,
                CompanyOwner__c, BillingPlace__c
            FROM Account 
            WHERE FiscalCode__c = :fiscalCode
            WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @description getAllAccounts
     * @return List<Account>
     */
    public List<Account> getAllAccounts() {
        return [ SELECT Id, Name
                 FROM Account 
                 WITH SECURITY_ENFORCED
                 LIMIT 10000 ];
    }

    /**
     * @description getAccountByVat
     * @param vat
     * @return List<Account>
     */
    public List<Account> getAccountByVat(String vat) {
        return [
            SELECT
            Id
            FROM Account 
            WHERE VATNumber__c = :vat
            WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @description getAccountByFiscalCodeAndVat
     * @param fiscalCode
     * @param vat
     * @return List<Account>
     */
    public List<Account> getAccountByFiscalCodeAndVat(String fiscalCode, String vat){
        return [
            SELECT
            Id
            FROM Account 
            WHERE FiscalCode__c = :fiscalCode
            AND VATNumber__c = :vat
            WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @description getAccountById
     * @param id
     * @return List<Account>
     */
    public List<Account> getAccountById(String id){
        return [
            SELECT
            Id,Name
            FROM Account 
            WHERE id = :id
            WITH SECURITY_ENFORCED
        ];
    }
    public List<Account> getAccountList(String filter){
        HDT_QR_Helper qrHelper=new HDT_QR_Helper();
        qrHelper.setObj('Account');
        qrHelper.setFilter(filter);
        return (List<Account>)qrHelper.getListSObject();
    }


    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Get Account by Id
     * @param customerCode
     * @return List<Account>
     */
    public List<Account> getAccountByCustomerCode(String customerCode){
        return [
            SELECT
            Id,
            Name,
            Category__c
            FROM Account 
            WHERE CustomerCode__c = :customerCode
            WITH SECURITY_ENFORCED
        ];
    }
}
