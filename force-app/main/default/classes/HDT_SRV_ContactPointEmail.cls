public with sharing class HDT_SRV_ContactPointEmail {
    private static final String UPDATEPERMISSION = 'update';
    private static final String UPSERTPERMISSION = 'upsert';
    private static final String CREATEPERMISSION = 'create';
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    public static void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ContactPointEmail', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    /**
     * @author Sabina Levonja
     * @description Check if user has create access to fields and throw exception if access not granted
     */

    public static void checkCreateAccess(ContactPointEmail contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public static ContactPointEmail createRecord(ContactPointEmail contact){
        HDT_UTL_DatabaseService.insertSObject(contact);
        return contact;
    }

    public static void upsertRecord(List<ContactPointEmail> contactPointEmailList){
        HDT_UTL_DatabaseService.upsertSObject(contactPointEmailList);
        
        
    }

    public static void checkUpsertAccess(ContactPointEmail contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), UPSERTPERMISSION);
    }

    public static void checkUpdateAccess(ContactPointEmail contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    public static void updateRecord(List <ContactPointEmail> contactPointEmailList){
        HDT_UTL_DatabaseService.updateSObject(contactPointEmailList);
        
    }

    public static ContactPointEmail updateRecord(ContactPointEmail contact){
        HDT_UTL_DatabaseService.updateSObject(contact);
        return contact;
    }
}
