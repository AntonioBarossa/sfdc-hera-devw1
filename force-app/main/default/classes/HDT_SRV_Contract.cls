/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 22/01/2021
* @description Class that holds crud and business logic for Contract
* @history Keltin Mesonjesi – 22/01/2021 – Created class
*/
public inherited sharing class HDT_SRV_Contract {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String UPDATEPERMISSION = 'update';
    
    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Contract', fields, crud);
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
    * @description Check if current user has update permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public void checkUpdateAccess(String fields){
        checkAccessInit(fields, UPDATEPERMISSION);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @description Update Contract records
    * @param List<Contract>
    */
    public void updateRecords(List<Contract> contracts){

        for (Contract contract : contracts) {
            List<String> fields = helperMethods.getObjAttrList(contract);
            checkUpdateAccess(String.join(fields, ','));
        }

        HDT_UTL_DatabaseService.updateSObject(contracts);
    }
}
