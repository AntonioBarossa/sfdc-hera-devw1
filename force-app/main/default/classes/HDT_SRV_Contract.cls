/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 22/01/2021
* @description Class that holds crud and business logic for Contract
* @history Keltin Mesonjesi – 22/01/2021 – Created class
*/
public inherited sharing class HDT_SRV_Contract {
    
    private static final String READPERMISSION = 'read';

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
}
