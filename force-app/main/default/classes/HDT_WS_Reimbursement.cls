public inherited sharing class HDT_WS_Reimbursement {

    /**@frpanico 05/10/2021 Modified Class
     * Aggiunta Response success
     * Refactoring della gestione response
     */


    public String calloutAccountBalance(String requestString){

        HttpRequest request = new HttpRequest();
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        String result;

        try{

            request.setEndpoint('Callout:HDT_AccountBalance');
            request.setMethod('POST');
            request.setBody(requestString);
            request.setHeader('Accept','application/json');
            request.setHeader('Content-Type','application/json');

            response = http.send(request);

        }catch(Exception e){

            result = 'Error';

        }

        if(response != null)
        {
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
            //If the response return success get 'saldo'
            if(String.valueOf(responseMap.get('status')) == 'success')
            {
                Map<String, Object> dataMap = (Map<String,Object>)responseMap.get('data');
                return String.valueOf(dataMap.get('saldo'));
            }
            //else return 'Error'
            else
            {
                result = 'Error';
            }
        }

        return result;

    }

}
