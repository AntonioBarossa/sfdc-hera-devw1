/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 27/11/2020
 * @description Class that holds CRUD and business logic for Account
 */

public inherited sharing class HDT_SRV_Account {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize security access instance
    * @param fields - Fields to check for access
    * @param crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Account', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
     * @description checkCreateAccess
     * @param account
     */
    public void checkCreateAccess(Account account){
        List<String> fields = helperMethods.getObjAttrList(account);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    /**
     * @description createRecord
     * @param account
     * @return Account
     */
    public Account createRecord(Account account){
        HDT_UTL_DatabaseService.insertSObject(account);
        return account;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Account
     * @param account
     */
    public void updateRecord(Account account){

        List<String> fields = helperMethods.getObjAttrList(account);
        checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.updateSObject(account);

    }

    /**
     * @description Update Accounts
     * @param account
     */
    public void updateRecords(List<Account> account){

        //List<String> fields = helperMethods.getObjAttrList(account);
        //checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.updateSObject(account);

    }

    public void updateRecordsWithCheck(List<Account> account){

        if (!account.isEmpty()) {
            List<String> fields = helperMethods.getObjAttrList(account[0]);
            checkUpdateAccess(String.join(fields, ','));
            HDT_UTL_DatabaseService.updateSObject(account);
        }
    }

    public void updateRecordsWithCheckTrigger(List<Account> account){

        if (!account.isEmpty()) {
            List<String> fields = helperMethods.getObjAttrList(account[0]);
            checkUpdateAccess(String.join(fields, ','));
            update account;
            //HDT_UTL_DatabaseService.updateSObject(account);
        }
    }

    /**
     * @description updateRecordsNoShare
     * @param account
     */
    public void updateRecordsNoShare(List<Account> account){

        //List<String> fields = helperMethods.getObjAttrList(account);
        //checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseServiceNoShare.updateSObject(account);

    }
}