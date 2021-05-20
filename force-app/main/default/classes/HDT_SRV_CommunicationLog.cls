public inherited sharing class HDT_SRV_CommunicationLog {
	private static HDT_UTL_HelperMethods helperMethods = new HDT_UTL_HelperMethods();
    private static final String READPERMISSION = 'read';
    private static final String CREATEPERMISSION = 'create';
    private static final String UPDATEPERMISSION = 'update';
    
    public void checkCreateAccess(String fields){
        checkAccessInit(fields, CREATEPERMISSION);
    }
    public void checkAccessInit(String fields, String crud){
        HDT_UTL_SecurityAccess securityAccess = new HDT_UTL_SecurityAccess('CommunicationLog__c', fields, crud);
        securityAccess.checkSecurityAccess();
    }
    
    public List<CommunicationLog__c> createRecords(List<CommunicationLog__c> comm){
        
        List<String> fields = helperMethods.getObjAttrList(comm[0]);
        checkCreateAccess(String.join(fields, ','));

        HDT_UTL_DatabaseService.insertSObject(comm);

        return comm;
    }
    
    
    
    
}