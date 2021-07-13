@isTest
global class HDT_LC_OfferConfiguratorCtrlTstMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response

        HDT_WRP_SapResponse bodyResponse = new HDT_WRP_SapResponse();
        bodyResponse.status = 'success';
        bodyResponse.correlationId = '7b078be0-d4ea-11eb-8ab7-a4b1c1b951c1';
        bodyResponse.timestamp = '2021-06-24T14:48:39';
        bodyResponse.keysap = '1025';
        bodyResponse.message = 'Aggiornare anche la tabella ZBITB163- Del125/11 AR';
        bodyResponse.esito = 'OK';


        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(bodyResponse));
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }

    global class HDT_WRP_SapResponse {
        global String status;
        global String correlationId;
        global String timestamp;
        global String keysap;
        global String message;
        global String esito;
    }

}