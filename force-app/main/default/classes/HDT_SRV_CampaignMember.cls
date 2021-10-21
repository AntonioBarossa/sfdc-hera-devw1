/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 30/06/2021
* @description Class HDT_SRV_CampaignMember
* @history Keltin Mesonjesi – 30/06/2021 – Created class
*/
public inherited sharing class HDT_SRV_CampaignMember {
    
    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 01/05/2021
    * @description Initialize security access instance
    * @param fields - Fields to check for access
    * @param crud - crud operation passed as a string (create, read, update, delete)
    */
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('CampaignMember', fields, crud);
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
    * @description updateRecord
    * @param cMember
    */
    public void updateRecord(CampaignMember cMember){
        //List<String> fields = helperMethods.getObjAttrList(cMember);
        //checkUpdateAccess(String.join(fields, ','));
        System.debug('********:eccolo');
        HDT_UTL_DatabaseService.updateSObject(cMember);
    }

    /**
    * @description createRecord
    * @param cMember
    * @return CampaignMember
    */
    public CampaignMember createRecord(CampaignMember cMember){
        //List<String> fields = helperMethods.getObjAttrList(cMember);
       // checkUpdateAccess(String.join(fields, ','));
       CampaignMember c = cMember;
       insert c;
        return c;
    }

    
    /**
    * @description createRecord
    * @param cmembers
    */
    public void updateRecords(List<CampaignMember> cmembers){
    //! non riabilitare perche da dei falsi positivi sull' oggetto CampaignMember
        // for (CampaignMember cm : cmembers) {
        //     List<String> fields = helperMethods.getObjAttrList(cm);
            // checkUpdateAccess(String.join(fields, ','));
        // }

        HDT_UTL_DatabaseService.updateSObject(cmembers);
    }
}