/**
* @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
* @date 06/05/2021
* @description Initialize security access instance
* @history Fatjola Memishaj 06/05/2021 Created class
*/

public inherited sharing class HDT_SRV_CommercialCode {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @date 06/05/2021
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('CommercialCode__c', fields, crud);
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
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    public CommercialCode__c createRecord(CommercialCode__c cc){
        List<String> fields = helperMethods.getObjAttrList(cc);
        checkUpdateAccess(String.join(fields, ','));
        HDT_UTL_DatabaseService.insertSObject(cc);
        return cc;
    }

    public List<CommercialCode__c> createRecords(List<CommercialCode__c> cc){
        HDT_UTL_DatabaseService.insertSObject(cc);
        return cc;
    }

    /**
    * @author Fatjola Memishaj (fatjola.memishaj@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    public void updateRecord(CommercialCode__c cc){
        List<String> fields = helperMethods.getObjAttrList(cc);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(cc);
    }
}