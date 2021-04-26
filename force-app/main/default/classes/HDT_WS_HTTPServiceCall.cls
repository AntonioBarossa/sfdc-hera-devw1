public class HDT_WS_HTTPServiceCall {
       
    public static HDT_WS_Response sendRequest(String nomeApi,HDT_WS_Request request,type respClass){
        
        System.debug('-----------------------------');
        System.debug('-- - Send Request - ---------');
        HDT_WebServiceConfiguration__c conf = HDT_WebServiceConfiguration__c.getValues(nomeApi);
        HDT_WebServiceCredential__c cred = HDT_WebServiceCredential__c.getValues(conf.User__c);
        
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(conf.endpoint__c);
        req.setMethod(conf.method__c);
        
        if(cred != null && !String.isEmpty(cred.Username__c) && !String.isEmpty(cred.Password__c)){
            Blob headerCred = Blob.valueOf(cred.Username__c+':'+cred.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerCred);
            req.setHeader('Authorization', authorizationHeader);
            System.debug('************Authorization :' + authorizationHeader);
        }
        else{
            System.debug('********** Username e Password ARE NOT VALORIZE INSIDE THE CUSTOM SETTINGS');
        }
        
        req.setBody(JSON.serialize(request));
        System.debug('*********Request:' + req.getBody());
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();
		String r;
        try{
            System.debug('**********req:' + req);
            HTTPResponse res = h.send(req);
            System.debug('*************RESP:' + res.getBody());
            resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
            resp.statusCode = res.getStatusCode();
        }catch(Exception e){
            System.debug('************ERROR SEND Request');
            System.debug('************:' + e.getMessage());
        }
		System.debug('***********:response:' + r);
        return resp;
        
    }
}