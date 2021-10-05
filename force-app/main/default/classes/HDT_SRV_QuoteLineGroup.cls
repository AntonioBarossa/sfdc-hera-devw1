/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 15/12/2020
* @description Class that contains business logic & CRUD for SBQQ__QuoteLineGroup__c
* @history Keltin Mesonjesi – 15/12/2020 – Created class
*/
public inherited sharing class HDT_SRV_QuoteLineGroup {
    
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
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SBQQ__QuoteLineGroup__c', fields, crud);
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
     * @description Create SBQQ__QuoteLineGroup__c record
     * @param quoteLineGroup
     * @return SBQQ__QuoteLineGroup__c
     */
    public SBQQ__QuoteLineGroup__c createRecord(SBQQ__QuoteLineGroup__c quoteLineGroup){

        List<String> fields = helperMethods.getObjAttrList(quoteLineGroup);
        checkCreateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.insertSObject(quoteLineGroup);

        return quoteLineGroup;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Create records in bulk
    * @param quoteLineGroupList
    * @return List<SBQQ__QuoteLine__c>
    */
    public List<SBQQ__QuoteLineGroup__c> createRecords(List<SBQQ__QuoteLineGroup__c> quoteLineGroupList){

        for (SBQQ__QuoteLineGroup__c quoteLineGroup : quoteLineGroupList) {
            List<String> fields = helperMethods.getObjAttrList(quoteLineGroup);
            checkCreateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.insertSObject(quoteLineGroupList);

        return quoteLineGroupList;
    }

}
