/**
 * Header of the class "HDT_WS_ArricchimentoDatiTempMock"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Mock of the relative Apex Class "HDT_WS_ArricchimentoDatiTemp"
 * @history
 * @Created 07/10/2021
 * Modified By:
 **/

public class HDT_WS_ArricchimentoDatiTempMock implements HTTPCalloutMock {

    public HTTPResponse respond(HTTPRequest request){
        
        HttpResponse response = new HttpResponse();         
        
        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_testataObject testata = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_testataObject();
        testata.esito = 'esito';
        
        List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject> posizioni = new List<HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject>();
        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject posizione = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_PosizioniResponseObject();
        posizione.campo = 'IMPOSTE';
        posizione.valore = 'E_IMPOST';
        posizioni.add(posizione);
        
        HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DataResponseObject data = new HDT_WS_ArrichmentDataEntityResponse.HDT_WRP_DataResponseObject();        
        data.posizioni = posizioni;
        data.testata = testata;
                        
        HDT_WS_ArrichmentDataEntityResponse res = new HDT_WS_ArrichmentDataEntityResponse();
        res.data = data;
        res.status = 'status';
        res.correlationId = 'correlationId';
        res.timestamp = 'timestamp';
        
        String body = JSON.serialize(res);
        
        response.setStatusCode(200);
        response.setBody(body);                       
        
        return response;
        
    }
}