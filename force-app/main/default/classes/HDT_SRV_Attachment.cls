public with sharing class HDT_SRV_Attachment {
    public static void insertAttach(List<Attachment> a ){
        HDT_UTL_DatabaseService.insertSObject(a);
    }

    public static ContentVersion insertContentVersion(ContentVersion v){
       
       HDT_UTL_DatabaseService.insertSObject(v);
       
       return v;
    }
}
