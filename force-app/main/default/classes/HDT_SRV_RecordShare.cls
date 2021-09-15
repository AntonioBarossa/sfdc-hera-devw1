/**
* @author Lorenzo
* @date 05/2021
* @description HDT_SRV_RecordShare Classes
* @history Lorenzo – 05/2021 – Created class
*/

public with sharing class HDT_SRV_RecordShare {
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    
    public static void checkAccessInit(String fields,String crud) {
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('AccountShare', fields , crud);
        securityAccess.checkSecurityAccess();
    }

    public static void checkCreateAccess(AccountShare accSh){
        List<String> fields = helperMethods.getObjAttrList(accSh);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public static AccountShare createRecord(AccountShare accSh){
        HDT_UTL_DatabaseService.insertSObject(accSh);
        return accSh;
    }

    public static List<AccountShare> createRecord(List<AccountShare> accSh){
        HDT_UTL_DatabaseService.insertSObject(accSh);
        return accSh;
    }

    public static List<AccountShare> createRecordWithout(List<AccountShare> accSh){
        HDT_UTL_DatabaseServiceNoShare.insertSObject(accSh);
        return accSh;
    }


    public static void checkUpdateAccess(AccountShare accSh){
        List<String> fields = helperMethods.getObjAttrList(accSh);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    public static AccountShare updateRecord(AccountShare accSh){
        HDT_UTL_DatabaseService.updateSObject(accSh);
        return accSh;
    }
    public static List<AccountShare> updateRecord(List<AccountShare> accShList){
        HDT_UTL_DatabaseService.updateSObject(accShList);
        return accShList;
    }
    
}

