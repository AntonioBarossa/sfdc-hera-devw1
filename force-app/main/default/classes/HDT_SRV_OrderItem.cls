/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 07/01/2021
* @description Class that holds crud and business logic for OrderItem
* @history Keltin Mesonjesi – 07/01/2021 – Created class
*/
public inherited sharing class HDT_SRV_OrderItem {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize security access instance
    * @param fields - Fields to check for access
    * @param crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('OrderItem', fields, crud);
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
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has create permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Check if current user has update permission on object and specified fields
    * @param fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
    * @description 
    * @author federico.defelice@webresults.it | 24-09-2021 
    * @param objectsList 
    **/
    public void updateRecords(List<OrderItem> objectsList){
        for (OrderItem item : objectsList) {
            List<String> fields = helperMethods.getObjAttrList(item);
            checkUpdateAccess(String.join(fields, ','));
        }
        HDT_UTL_DatabaseService.updateSObject(objectsList);
    }
}
