public inherited sharing class HDT_UTL_HelperMethods {
    
    /**
     * Get object attributes as a list
     * @param SObject sobject
     * @return List<String> fields
     */
    public List<String> getObjAttrList(SObject obj){

        Map<String,Object> objMap = obj.getPopulatedFieldsAsMap();

        List<String> fields = new List<String>();
        for (String field: objMap.keySet()) {
            if (! (field.equalsIgnoreCase('Id') || field.equalsIgnoreCase('attributes'))){
                fields.add(field); 
            } 
        }

        return fields;
    }

    /**
     * Check if current user is community or salesforce crm
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
}