/**
 * @author Valere (valere@noeli-it.net)
 * @date 19/10/2021
 * @description HDT_BA_DeactivateCampaign Test Classes
 * @history valere - 19/10/2021– Created Class
 */
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