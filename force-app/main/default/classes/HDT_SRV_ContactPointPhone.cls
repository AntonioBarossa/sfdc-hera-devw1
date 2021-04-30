public with sharing class HDT_SRV_ContactPointPhone {
    private static final String UPDATEPERMISSION = 'update';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPSERTPERMISSION = 'upsert';
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    public static void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('ContactPointPhone', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    /**
     * @author Sabina Levonja
     * @description Check if user has create access to fields and throw exception if access not granted
     */

    public static void checkCreateAccess(ContactPointPhone contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public static ContactPointPhone createRecord(ContactPointPhone contact){
        HDT_UTL_DatabaseService.insertSObject(contact);
        return contact;
    }


    public static void upsertRecord(List<ContactPointPhone> contactPointPhoneList){
        HDT_UTL_DatabaseService.upsertSObject(contactPointPhoneList);
    }

    public static void checkUpsertAccess(ContactPointPhone contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), UPSERTPERMISSION);
    }

    public static ContactPointPhone updateRecord(ContactPointPhone contact){
        HDT_UTL_DatabaseService.updateSObject(contact);
        return contact;
    }

    public static void updateRecord(List<ContactPointPhone> contactPointPhoneList){
        HDT_UTL_DatabaseService.updateSObject(contactPointPhoneList);
    }

}
