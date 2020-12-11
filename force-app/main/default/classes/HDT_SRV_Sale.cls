/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 27/11/2020
* @description Class that holds crud and business logic for Sale__c
* @history Keltin Mesonjesi – 27/11/2020 – Created class
*/
public inherited sharing class HDT_SRV_Sale {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static HDT_QR_Account accountQuery = new HDT_QR_Account();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/11/2020
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Sale__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    
    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param String fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create Sale__c record
     * @param Sale__c sale
     * @return Sale__c sale
     */
    public Sale__c createRecord(Sale__c sale){

        Account account = accountQuery.getRecordById(Sale.Account__c, 'Id, Name, SalesNumber__c');
        sale.Name = 'Vendita Account ' + account.Name + ' ' + (account.SalesNumber__c + 1);

        List<String> fields = helperMethods.getObjAttrList(sale);

        checkCreateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.insertSObject(sale);

        return sale;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale__c record
     * @param Sale__c sale
     */
    public void updateRecord(Sale__c sale){

        List<String> fields = helperMethods.getObjAttrList(sale);

        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(sale);

    }
}
