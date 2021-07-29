/**
* @author Lorenzo (lorenzo.gulotta@webresults.it)
* @date 28/05/2021
* @description HDT_SRV_Attachment.cls
* @history Lorenzo – 28/05/2021 – created class
*/
public with sharing class HDT_SRV_Attachment {
    public static void insertAttach(List<Attachment> a ){
        HDT_UTL_DatabaseService.insertSObject(a);
    }

    public static ContentVersion insertContentVersion(ContentVersion v){
       
       HDT_UTL_DatabaseService.insertSObject(v);
       
       return v;
    }
}
