/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 10/03/2021
* @description Class that holds crud and business logic for Case
* @history Fatjola Memishaj – 10/03/2021 – Created class
*/
public inherited sharing class HDT_SRV_Case {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @date 10/03/2021
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Case', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    
    /**
     * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
     * @description Check if user has read access to fields and throw exception if access not granted
     * @param String fields
     */
    public void checkReadAccess(String fields){
        checkAccessInit(fields, READPERMISSION);
    }

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @date 10/03/2021
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @date 10/03/2021
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
     * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
     * @description Create Case record
     * @param Case c
     * @return Case c
     */
    public Case createRecord(Case c){

        List<String> fields = helperMethods.getObjAttrList(c);
        checkCreateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.insertSObject(c);
        return c;
    }

    /**
     * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
     * @description Update Case record
     * @param Case c
     */
    public void updateRecord(Case c){

        List<String> fields = helperMethods.getObjAttrList(c);
        checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.updateSObject(c);

    }
}
