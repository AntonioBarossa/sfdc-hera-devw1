@SuppressWarnings('PMD.AvoidDebugStatements,PMD.ApexSuggestUsingNamedCred, PMD.ClassNamingConventions, PMD.CyclomaticComplexity')
public class HDT_WS_HTTPServiceCall {
    
    public static  HDT_WS_Response sendRequest(String namedCredential,String path,String method,HDT_WS_Request request,type respClass){
               
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000); 
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint('Callout:'+namedCredential+path);
        req.setMethod(method);
        if(method!='GET'){
            req.setBody(JSON.serialize(request));
        }        
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();
        String body = '';
        try{
            System.debug(LoggingLevel.debug,'req: '+req);
            HTTPResponse res = h.send(req);

            /* if(res.getStatusCode()/100 == 2){
                resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
                resp.statusCode = res.getStatusCode();
            }
            else {
                resp.statusCode = res.getStatusCode();
                resp.status = 'KO';
                resp.errorDetails = res.getBody();
            } */
            if (res != null){
                System.debug(LoggingLevel.debug,'res: '+res);
                System.debug(LoggingLevel.debug,'body: '+res.getBody());
                body = res.getBody();
                resp = (HDT_WS_Response)JSON.deserialize(body, respClass);
                System.debug(LoggingLevel.debug,'resp: '+resp);
                resp.statusCode = res.getStatusCode();
                System.debug(LoggingLevel.debug,'respStat: '+resp.statusCode);

            }else{
                resp.exceptionMessage = 'Attenzione! Nessuna risposta dal server.';
            }
            
        }
        catch(Exception e){
            System.debug(LoggingLevel.error,'exp: ' +e);
            resp.body = HDT_UTL_RestCallRespBodyLogUtility.mustSetBody(namedCredential, path)? body : null;
            resp.exceptionMessage = e.getMessage();
        }
        return resp;  
    }
    public static HDT_WS_Response sendRequest(String namedCredential,String path,String method,List<HDT_WS_Request> request,type respClass){
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint('Callout:'+namedCredential+path);
        req.setMethod(method);        
        req.setBody(JSON.serialize(request));
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();
        String body = '';
        try{
            HTTPResponse res = h.send(req);
            body = res.getBody();
            resp = (HDT_WS_Response)JSON.deserialize(body, respClass);
            resp.statusCode = res.getStatusCode();
        }
        catch(Exception e){
            resp.body = HDT_UTL_RestCallRespBodyLogUtility.mustSetBody(namedCredential, path)? body : null;
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }
    /*
    public static HDT_WS_Response sendRequest(String namedCredential,String path,String method,Map<String,String> getParams,type respClass){
        
        String endpoint = '';
        
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000);
        req.setHeader('Content-type', 'application/json');
        String contactParamsForGet= '';
        for(String key : getParams.keyset()){
            if(getParams.get(key) != null){
                if(contactParamsForGet == null || contactParamsForGet == ''){
                    contactParamsForGet += '?' + key + '=' + getParams.get(key);
                }
                else{
                    contactParamsForGet += '&' + key + '=' + getParams.get(key);
                }
            }
        }
        if(contactParamsForGet != null){
            endpoint+= namedCredential + path + contactParamsForGet;
        }else{
            endpoint+= namedCredential + path;
        }
        req.setEndpoint('Callout:'+endpoint);
        req.setMethod(method);
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();

        try{
            HTTPResponse res = h.send(req);
            resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
            resp.statusCode = res.getStatusCode();
        }
        catch(Exception e){
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }*/
    public static HDT_WS_Response sendRequest(String namedCredential,String path,String method,Map<String,Object> request,type respClass){
                
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000);
        req.setHeader('Content-type', 'application/json');
        req.setBody(JSON.serialize(request));
        req.setEndpoint('Callout:'+namedCredential+path);
        req.setMethod(method);
        
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();
        String body = '';
        try{
            HTTPResponse res = h.send(req);
            body = res.getBody();
            resp = (HDT_WS_Response)JSON.deserialize(body, respClass);
            resp.statusCode = res.getStatusCode();
        }
        catch(Exception e){
            resp.body = HDT_UTL_RestCallRespBodyLogUtility.mustSetBody(namedCredential, path)? body : null;
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }
    public static HDT_WS_Response sendRequest(String nomeApi,HDT_WS_Request request,type respClass){
        
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
        }
        
        req.setBody(JSON.serialize(request));
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();
        try{
            HTTPResponse res = h.send(req);

            if(res.getStatusCode()/100 == 2){
                resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
                resp.statusCode = res.getStatusCode();
            }
            else {
                resp.statusCode = res.getStatusCode();
                resp.status = 'KO';
                resp.errorDetails = res.getBody();
            }
        }
        catch(Exception e){
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }

    public static HDT_WS_Response sendRequest(String nomeApi,List<HDT_WS_Request> request,type respClass){
        
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
        }
        
        req.setBody(JSON.serialize(request));
        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();

        try{
            HTTPResponse res = h.send(req);
            resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
            resp.statusCode = res.getStatusCode();
        }
        catch(Exception e){
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }

    public static HDT_WS_Response sendRequest(String nomeApi,Map<String,String> getParams,type respClass){
        
        HDT_WebServiceConfiguration__c conf = HDT_WebServiceConfiguration__c.getValues(nomeApi);
        HDT_WebServiceCredential__c cred = HDT_WebServiceCredential__c.getValues(conf.User__c);
        
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000);
        req.setHeader('Content-type', 'application/json');
        String contactParamsForGet= '';
        for(String key : getParams.keyset()){
            if(getParams.get(key) != null){
                if(contactParamsForGet == null || contactParamsForGet == ''){
                    contactParamsForGet += '?' + key + '=' + getParams.get(key);
                }
                else{
                    contactParamsForGet += '&' + key + '=' + getParams.get(key);
                }
            }
        }
        if(contactParamsForGet != null){
            req.setEndpoint(conf.endpoint__c + contactParamsForGet);
        }else{
            req.setEndpoint(conf.endpoint__c);
        }
        req.setMethod(conf.method__c);
        
        if(cred != null && !String.isEmpty(cred.Username__c) && !String.isEmpty(cred.Password__c)){
            Blob headerCred = Blob.valueOf(cred.Username__c+':'+cred.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerCred);
            req.setHeader('Authorization', authorizationHeader);
        }

        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();

        try{
            HTTPResponse res = h.send(req);
            resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
            resp.statusCode = res.getStatusCode();
        }
        catch(Exception e){
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }

    public static HDT_WS_Response sendRequest(String nomeApi,Map<String,Object> request,type respClass){
        
        HDT_WebServiceConfiguration__c conf = HDT_WebServiceConfiguration__c.getValues(nomeApi);
        HDT_WebServiceCredential__c cred = HDT_WebServiceCredential__c.getValues(conf.User__c);
        
        HTTP h = new Http();
        HTTPRequest req = new HTTPRequest();
        req.setTimeout(120000);
        req.setHeader('Content-type', 'application/json');
        req.setBody(JSON.serialize(request));
        req.setEndpoint(conf.endpoint__c);
        req.setMethod(conf.method__c);
        
        if(cred != null && !String.isEmpty(cred.Username__c) && !String.isEmpty(cred.Password__c)){
            Blob headerCred = Blob.valueOf(cred.Username__c+':'+cred.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerCred);
            req.setHeader('Authorization', authorizationHeader);
        }

        HDT_WS_Response resp = (HDT_WS_Response)respClass.newInstance();

        try{
            HTTPResponse res = h.send(req);
            resp = (HDT_WS_Response)JSON.deserialize(res.getBody(), respClass);
            resp.statusCode = res.getStatusCode();
        }
        catch(Exception e){
            resp.exceptionMessage = e.getMessage();
        }
        return resp;        
    }
}