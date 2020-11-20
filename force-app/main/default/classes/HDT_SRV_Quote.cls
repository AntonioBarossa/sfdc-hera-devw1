public inherited sharing class HDT_SRV_Quote {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static String CREATEPERMISSION = 'create';
    private static String UPDATEPERMISSION = 'update';
    // private static String DELETEPERMISSION = 'delete';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('SBQQ__Quote__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Check if current user has delete permission on object
    */
    // public void checkDeleteAccess(){
    //     String fields = '';
    //     checkAccessInit(fields, DELETEPERMISSION);
    // }

    /**
     * Create SBQQ__Quote__c record
     * @param SBQQ__Quote__c quote
     */
    public SBQQ__Quote__c createRecord(SBQQ__Quote__c quote){
        
        List<String> fields = helperMethods.getObjAttrList(quote);
        checkCreateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.insertSObject(quote);

        return quote;
    }

    /**
     * Delete single record
     * @param SBQQ__Quote__c.Id
     */
    public void deleteRecord(String quoteId){
        // checkDeleteAccess();
        HDT_UTL_DatabaseService.deleteSObject(quoteId);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 19/11/2020
    * @description Update SBQQ__Quote__c record based on SBQQ__Quote__c.Id
    * @param SBQQ__Quote__c quote - Quote record with fields to update
    */
    public void updateRecord(SBQQ__Quote__c quote){
        List<String> fields = helperMethods.getObjAttrList(quote);
        checkUpdateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.updateSObject(quote);
    }
}
