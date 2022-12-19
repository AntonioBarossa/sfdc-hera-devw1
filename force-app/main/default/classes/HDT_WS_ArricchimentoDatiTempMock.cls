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
        
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoTestata testata = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoTestata();
        testata.esito = 'esito';
        
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni> posizioni = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
        posizione.campo = 'IMPOSTE';
        posizione.valore = 'E_IMPOST';
        posizioni.add(posizione);
        
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoData data = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoData();        
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