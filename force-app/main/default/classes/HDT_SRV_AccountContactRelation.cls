/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 25/02/2021
* @description Class that holds crud and business logic for AccountContactRelation
* @history Keltin Mesonjesi – 25/02/2021 – Created class
*/
public inherited sharing class HDT_SRV_AccountContactRelation {
    
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
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('AccountContactRelation', fields, crud);
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
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
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
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description updateRecord
     * @param AccountContactRelation ac
     * @return AccountContactRelation ac
     */
    public AccountContactRelation updateRecord(AccountContactRelation ac){
        HDT_UTL_DatabaseService.updateSObject(ac);
        return ac;
    }
/**
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description createRecord
     * @param AccountContactRelation ac
     * @return AccountContactRelation ac
     */
    public AccountContactRelation createRecord(AccountContactRelation ac){
        HDT_UTL_DatabaseService.insertSObject(ac);
        return ac;
    }
    
    public List<AccountContactRelation> upsertRecord(List<AccountContactRelation> ac){
        HDT_UTL_DatabaseService.upsertSObject(ac);
        return ac;
    }
    
}
