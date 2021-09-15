public with sharing class HDT_WS_PaperCampaignGetFile {
 

    public static wrapResponseGetId callServiceGetIdByName(String filename){
        Map<String,String> getParams = new Map<String,String>{'fileName' => filename};
        return  (wrapResponseGetId)HDT_WS_HTTPServiceCall.sendRequest('paperGetId', getParams, wrapResponseGetId.class);
    }

    public static wrapResponseGetFile callServiceGetFileById(String documentId ){
        Map<String,String> getParams = new Map<String,String>{'documentId' => documentId};
        return  (wrapResponseGetFile)HDT_WS_HTTPServiceCall.sendRequest('paperGetFile', getParams, wrapResponseGetFile.class);
    }

    public class wrapResponseGetId extends HDT_WS_Response{
        @AuraEnabled public wrapObjectGetId data{get;set;} 
    }
    public class wrapObjectGetId{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String type {get;set;}
    }
    public class wrapResponseGetFile extends HDT_WS_Response{
        @AuraEnabled public wrapObjectGetFile data{get;set;}
    }
    public class wrapObjectGetFile{
        @AuraEnabled public String fileBase64 {get;set;}
    }
}
