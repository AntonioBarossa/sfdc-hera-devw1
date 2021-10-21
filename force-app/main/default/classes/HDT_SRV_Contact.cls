/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 19/11/2020
 * @description HDT_SRV_Contact Class
 * @history Keltin Mesonjesi 19/11/2020 – Created 'createAccountShare' method
 */

public inherited sharing class HDT_SRV_Contact {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Initialize security access instance
    * @param fields - Fields to check for access
    * @param crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Contact', fields, crud);
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
     * @author Sabina Levonja
     * @description Check if user has create access to fields and throw exception if access not granted
     * @param contact
     */
    public void checkCreateAccess(Contact contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), CREATEPERMISSION);
    }

    /**
     * @description createRecord
     * @param contact
     * @return Contact
     */
    public Contact createRecord(Contact contact){
        HDT_UTL_DatabaseService.insertSObject(contact);
        return contact;
    }

    /**
     * @description createRecords
     * @param contacts
     * @return Contact
     */
    public List<Contact> createRecords(List<Contact> contacts){
        checkCreateAccess(contacts[0]);
        HDT_UTL_DatabaseService.insertSObject(contacts);
        return contacts;
    }

    /**
     * @description checkUpdateAccess
     * @param contact
     */
    public void checkUpdateAccess(Contact contact){
        List<String> fields = helperMethods.getObjAttrList(contact);
        checkAccessInit(String.join(fields, ','), UPDATEPERMISSION);
    }

    /**
     * @description updateRecord
     * @param contact
     * @return Contact
     */
    public Contact updateRecord(Contact contact){
        HDT_UTL_DatabaseService.updateSObject(contact);
        return contact;

    }

    /**
     * @description updateRecord
     * @param contacts
     * @return List<Contact>
     */
    public List<Contact> updateRecord(List<Contact> contacts){
        checkUpdateAccess(contacts[0]);
        HDT_UTL_DatabaseService.updateSObject(contacts);
        return contacts;
    }
}
