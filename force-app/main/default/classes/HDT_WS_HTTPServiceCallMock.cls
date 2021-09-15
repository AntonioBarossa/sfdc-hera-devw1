global with sharing class HDT_WS_HTTPServiceCallMock implements HttpCalloutMock {
    
    public Boolean successfullReturn = true;

    global HTTPResponse respond(HTTPRequest req) {
        system.debug('Marketing Cloud utils Mock');
        system.debug('endpoint ' + req.getEndpoint());
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body;

        List<HDT_WebServiceConfiguration__c> webServiceConfigurations = HDT_WebServiceConfiguration__c.getAll().values();

        for(HDT_WebServiceConfiguration__c wsc : webServiceConfigurations) {
            if(req.getEndpoint() == wsc.Endpoint__c) {
                if (wsc.Name == 'TransitorioWinback') {
                    HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse transitionWbResponse = new HDT_WS_TransitionWinBack.HDT_WS_TransitionWinBackResponse();
                    
                    transitionWbResponse.result = new List<HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj>();
                    transitionWbResponse.result.add(new HDT_WS_TransitionWinBack.HDT_WS_TransitioneObj());

                    if (successfullReturn) {
                        transitionWbResponse.result.get(0).status = 'in Corso';
                        
                        body = JSON.serialize(transitionWbResponse);
                        res.setStatusCode(200);
                        res.setBody(body);
                    } else {
                        res.setStatusCode(404);
                    }
                }
            }
        }

        return res;
    }
}
