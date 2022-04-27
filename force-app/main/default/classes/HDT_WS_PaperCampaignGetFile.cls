public with sharing class HDT_WS_PaperCampaignGetFile {
 
    /*public class WS_REQ_GETID extends HDT_WS_Request{
       @AuraEnabled
        public string fileName {get;set;}
    }
    public class WS_REQ_GETFILE extends HDT_WS_Request{
        @AuraEnabled
         public string documentId {get;set;}
     }*/

    public static wrapResponseGetId callServiceGetIdByName(String filename){
       // Map<String,String> getParams = new Map<String,String>{'fileName' => filename};
        /*ws_req_getId params=new ws_req_getId();
        params.fileName=filename;*/
        string path='/paper-communications/documents?fileName='+filename;
        return  (wrapResponseGetId)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath', path , 'GET', (HDT_WS_Request)null, wrapResponseGetId.class);//'/paper-communications/documents/'
    }

    public static wrapResponseGetFile callServiceGetFileById(String documentId ){
        //Map<String,String> getParams = new Map<String,String>{'documentId' => documentId};
        /*ws_req_getFile params=new ws_req_getFile();
        params.documentId=documentId;*/
        string path='/paper-communications/pdf-files?documentId='+documentId;
        return  (wrapResponseGetFile)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath', path, 'GET', (HDT_WS_Request)null, wrapResponseGetFile.class);
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
