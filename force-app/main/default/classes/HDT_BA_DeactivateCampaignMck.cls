@istest
global class HDT_BA_DeactivateCampaignMck implements HttpCalloutMock{ 
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(
            new Map<String,Object>{
                'data'=>'data' 
            }
        ));
    
        response.setStatusCode(200);
        return response; 
    }
        
}