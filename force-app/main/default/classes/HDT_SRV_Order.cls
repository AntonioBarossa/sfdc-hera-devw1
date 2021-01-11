/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 01/05/2021
* @description Class that holds crud and business logic for Order
* @history Keltin Mesonjesi – 01/05/2021 – Created class
*/
public inherited sharing class HDT_SRV_Order {
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 01/05/2021
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Order', fields, crud);
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
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Order record
     * @param Order quote
     * @return Order
     */
    public Order createRecord(Order order){
        
        List<String> fields = helperMethods.getObjAttrList(order);
        checkCreateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.insertSObject(order);

        return order;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 08/01/2021
    * @description Update Order record based on Order.Id
    * @param Order order - Order record with fields to update
    */
    public void updateRecord(Order order){
        List<String> fields = helperMethods.getObjAttrList(order);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(order);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Update Order records
    * @param List<Order>
    */
    public void updateRecords(List<Order> orders){

        for (Order order : orders) {
            List<String> fields = helperMethods.getObjAttrList(order);
            checkUpdateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.updateSObject(orders);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 06/01/2021
    * @description Get record type ID for 'HDT_RT_OrderDossier'
    * @param String
    */
    public String getRecordTypeIdOrderDossier(){
        List<Schema.RecordTypeInfo> recordTypes = Order.SObjectType.getDescribe().getRecordTypeInfos();
        String recordTypeIdOrderDossier = '';
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            if (recordType.getDeveloperName() == 'HDT_RT_OrderDossier') {
                recordTypeIdOrderDossier = recordType.getRecordTypeId();
            }
        }

        return recordTypeIdOrderDossier;
    }
}
