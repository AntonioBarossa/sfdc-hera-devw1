/**
* @author Sabina Levonja (sabina.levonja@dunegroup.it)
* @date 10/03/2021
* @description HDT_QR_CampaignMemberStatus_mdt – Contains queries for HDT_CampaignMemberStatus__mdt
* @history Sabina Levonja – 10/03/2021 – created class 
*/
public inherited sharing class HDT_SRV_CampaignMemberStatus {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String CREATEPERMISSION = 'create';
    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @description Initialize security access instance
    * @param String fields - Fields to check for access
    * @param String crud - crud operation passed as a string (create, read, update, delete)
    */
    public static void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('CampaignMemberStatus', fields, crud);
        securityAccess.checkSecurityAccess();
    }

    /**
    * @author Sabina Levonja (sabina.levonja@dunegroup.it)
    * @description Check if current user has create permission on object and specified fields
    * @param String fields - Fields to check for access
    */
    public static void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }

    /**
     * @author Sabina Levonja (sabina.levonja@dunegroup.it)
     * @description createRecord
     * @param CampaignMemberStatus c
     * @return CampaignMemberStatus c
     */
    public static List<CampaignMemberStatus> createRecord(List<CampaignMemberStatus> c){
        HDT_UTL_DatabaseService.insertSObject(c);
        return c;
    }

}
