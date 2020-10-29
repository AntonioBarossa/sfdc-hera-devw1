public with sharing class HDT_SRV_Opportunity {

    private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();

    /**
     * Create Opportunity record
     * @param Opportunity
     */
    public Opportunity createRecord(Opportunity opportunity){
        
        List<String> fields = helperMethods.getObjAttrList(opportunity);

        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('Opportunity', String.join(fields, ','), 'create');
        securityAccess.checkSecurityAccess();

        insert opportunity;

        return opportunity;
    }
}
