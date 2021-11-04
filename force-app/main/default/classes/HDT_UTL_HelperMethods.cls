/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @description HDT_UTL_HelperMethods – Contains helper methods
*/
public inherited sharing class HDT_UTL_HelperMethods {
    
    private static HDT_QR_PermissionSet permissionSetQr = new HDT_QR_PermissionSet();

    private Set<String> fieldsToIgnore = new Set<String>{'id', 'attributes', 'systemmodstamp', 'createddate', 'ordernumber', 'createdbyid', 'campaignid'};

    /**
     * @description Get object attributes as a list
     * @param obj - SObject
     * @return List<String>
     */
    public List<String> getObjAttrList(SObject obj){

        Map<String,Object> objMap = obj.getPopulatedFieldsAsMap();

        List<String> fields = new List<String>();
        for (String field: objMap.keySet()) {
            if (!fieldsToIgnore.contains(field?.toLowerCase())){
                fields.add(field); 
            } 
        }

        return fields;
    }

    /**
     * @description Check if current user is community or salesforce crm
     * @return Boolean true(is community), false(is crm)
     */
    public boolean checkCommunityLogin(){
        boolean check=False;
        string us= userinfo.getUserType();
        system.debug(us);
        if (!'Standard'.Equals(us)){
            check=True;
        }
        return check;
    }

    /**
     * @description Check if current user is super user
     * @return Boolean
     */
    public Boolean isSuperUser(){
        List<PermissionSetAssignment> psasList = permissionSetQr.getPermissionSetAssignmentByName('HDT_SuperUserCPQ', UserInfo.getUserId());
        return !psasList.isEmpty();
    }
}
