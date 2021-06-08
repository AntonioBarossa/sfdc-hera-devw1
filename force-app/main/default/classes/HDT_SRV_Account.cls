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
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Account', fields, crud);
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
    public void checkCreateAccess(Account account){
        List<String> fields = helperMethods.getObjAttrList(account);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public Account createRecord(Account account){
        HDT_UTL_DatabaseService.insertSObject(account);
        return account;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Account
     * @param Account account
     */
    public void updateRecord(Account account){

        List<String> fields = helperMethods.getObjAttrList(account);
        checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.updateSObject(account);

    }
    public void updateRecords(List<Account> account){

        //List<String> fields = helperMethods.getObjAttrList(account);
        //checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.updateSObject(account);

    }
}
