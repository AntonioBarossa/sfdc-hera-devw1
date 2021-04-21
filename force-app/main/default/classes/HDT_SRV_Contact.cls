public inherited sharing class HDT_SRV_Contact {

    private static final String READPERMISSION = 'read';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Contact', fields, crud);
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
     * @author Sabina Levonja
     * @description Check if user has create access to fields and throw exception if access not granted
     */

    public void checkCreateAccess(Contact contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    public Contact createRecord(Contact contact){
        HDT_UTL_DatabaseService.insertSObject(contact);
        return contact;
    }

    public void checkUpdateAccess(Contact contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    public Contact updateRecord(Contact contact){
        HDT_UTL_DatabaseService.updateSObject(contact);
        return contact;

    }
    public List<Contact> updateRecord(List<Contact> contacts){
        HDT_UTL_DatabaseService.updateSObject(contacts);
        return contacts;
    }
}
