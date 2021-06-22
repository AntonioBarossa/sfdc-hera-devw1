public with sharing class HDT_SRV_Lead {

    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    
    public static void checkAccessInit(String fields,String crud) {
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Lead', fields , crud);
        securityAccess.checkSecurityAccess();
    }

    /**
     * @author Elfrida Kora(elfrida.kora@dunegroup.it)
     * @description Check if user has create access to fields and throw exception if access not granted
     */



    public static void checkCreateAccess(Lead lead){
        List<String> fields = helperMethods.getObjAttrList(lead);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public static Lead createRecord(Lead lead){
        HDT_UTL_DatabaseService.insertSObject(lead);
        return lead;
    }

    public static void checkUpdateAccess(Lead lead){
        List<String> fields = helperMethods.getObjAttrList(lead);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    public static Lead updateRecord(Lead lead){
        HDT_UTL_DatabaseService.updateSObject(lead);
        return lead;
    }
    public static List<Lead> updateRecord(List<Lead> leads){
        HDT_UTL_DatabaseService.updateSObject(leads);
        return leads;
    }
    
}
