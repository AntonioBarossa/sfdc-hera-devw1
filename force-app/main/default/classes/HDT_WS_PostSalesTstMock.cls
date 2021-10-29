@isTest
public class HDT_WS_PostSalesTstMock implements HTTPCalloutMock{

    private final Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
            +'{"fieldType":"TEXT","name":"FASE","value":"Comunicazione verso Heroku OK"},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":null}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
            'statuscode' => '200'
            },

            'Callout:ArricchimentoDatiTemp' => 
            new Map<String,String>
            {   'body' => '{"status": "success","correlationId": "2a0c1340-f6b5-11eb-bb88-068530f44c42","timestamp": "2021-08-06T14:52:33",'
                +'"data": {"testata": {"esito": "OK"},"posizioni": ['
                +'{"campo": "DATACESSAZIONE","valore": "99991231"},'
                +'{"campo": "ALIQUOTAIVA","valore": "01"},'
                +'{"campo": "CA","valore": "200008867681"},'
                +'{"campo": "DESCRFATTURAZCOLL","valore": "Il contratto può essere fatturato con altri contratti"},'
                +'{"campo": "ANNOFABBRCONT","valore": "2000"},'
                +'{"campo": "CALIBRO1","valore": "GRT003"},'
                +'{"campo": "PRESENZACORRETTORE","valore": "NO"},'
                +'{"campo": "OPZIONE","valore": "E_UD_TDR"},'
                +'{"campo": "MOTIVOBLOCCOCALCOLO","valore": "T1"},'
                +'{"campo": "ACCISE","valore": "0.02270000"},'
                +'{"campo": "CODICE_ATECO","valore": "999999"}'
                +']}}',
                'statuscode' => '200'
            },

            'Callout:HDT_PaymentCommunication' => 
                new Map<String,String>
                {
                    'body'=>'{"status": "success","correlationId": "eb9117b0-04e1-11ec-89bb-06c8ff345e9a","timestamp": "2021-08-24T15:48:13","data": {"rdsRdo": "00001945","tipoAttivita": "Pratica Avviata","note": ""}}',
                    'statuscode' => '200'
                },

            'Callout:GetEnvelopePostel' => 
            new Map<String,String>
            {
                'body' => '{"status": "success","correlationId": "eb9117b0-04e1-11ec-89bb-06c8ff345e9a","timestamp": "2021-08-24T15:48:13","data": {"responseCode": "200","responseStatus": "Test","content": "Test Content"}}',
                'statuscode' => '200'
            },

            'Callout:CreditViews' => 
            new Map<String,String>
            {
                'body'=>'{"status": "success","correlationId": "b40f74a0-0cd2-11ec-9bbe-06c86cee6034","timestamp": "2021-09-03T18:19:28",'
                +'"data": [{"contoContrattuale": "200008284449","codiceCliente": "1002647967","dataEmissione": "31/08/2021","dataScadenza": "20/10/2021",'
                +'"importo": "32.0","residuo": "32.0","documento": "500002727014","contratto": "3016825235","settoreMerceologico": "Energia elettrica",'
                +'"tipoTransazione": "EC4","idPrimoLivelloSAP": "00000000000000000000000000000000000000000000000001","oraIncassoRealTime": "00:00:00",'
                +'"loginId": "0-1","secondoLivelloInformativoF2": [{"riferimentoFattura": "0000411903129942","societa": "Hera Comm S.p.A.","contratto": "3016825235",'
                +'"settoreMerceologico": "Energia elettrica","dataEmissione": "03/04/2019","dataScadenza": "23/04/2019","importo": "64.22","totaleCopertina": "0.0",'
                +'"idSecondoLivelloSAP": "00000000000000000000000000000000000000000000000001"}]},'
                +'{"contoContrattuale": "200008284449","codiceCliente": "1002647967","dataEmissione": "31/08/2021","dataScadenza": "20/10/2021","importo": "116.0",'
                +'"residuo": "0.0","documento": "500002727015","contratto": "3016598437","settoreMerceologico": "Gas","tipoTransazione": "EC4",'
                +'"idPrimoLivelloSAP": "00000000000000000000000000000000000000000000000002","oraIncassoRealTime": "00:00:00","loginId": "0-1","secondoLivelloInformativoF2": ['
                +'{"riferimentoFattura": "0000431900252295","societa": "Hera Comm Marche","contratto": "3016598437","settoreMerceologico": "Gas","dataEmissione": "03/04/2019",'
                +'"dataScadenza": "23/04/2019","importo": "233.89","totaleCopertina": "0.0","idSecondoLivelloSAP": "00000000000000000000000000000000000000000000000001"}]}]}',
                'statuscode' => '200'
            },
            
            'Callout:HDT_AccountBalance' => 
            new Map<String,String>
            {   
                'body' => '{"status": "failed","correlationId": "c5fb0140-0fc8-11ec-9bbe-06c86cee6034","timestamp": "2021-09-07T12:45:54","errorDetails": [{'
                +'"code": "HTTP:INTERNAL_SERVER_ERROR","message": "HTTP POST on resource \'http://isudbq.service.intra:8121/sap/bc/srt/rfc/sap/z_ws_saldo_bp/150/z_ws_saldo_bp/z_ws_saldo_bp\''
                +' failed: internal server error (500).","additionalInfo": "HTTP POST on resource \'http://isudbq.service.intra:8121/sap/bc/srt/rfc/sap/z_ws_saldo_bp/150/z_ws_saldo_bp/z_ws_saldo_bp\''
                +' failed: internal server error (500)."}]}',
                'statuscode' => '500'
            },   

            'Callout:CheckLastReading' => 
            new Map<String,String>
            {
                'body' => 'Response_Body_Test_Success',
                'statuscode' => '200'
            },
            
            'Callout:ModificaLayoutFattura' => 
            new Map<String,String>
            {
                'body' => '{"status": "success","correlationId": "cd6247d0-2077-11ec-a285-02a2f3354824","timestamp": "2021-09-28T18:19:12","data": {"rds": "C-00060011","attivita": "Esito OK da SAP"}}',
                'statuscode' => '200'
            },

            'Callout:ModificaLayoutFattura_null' => 
            new Map<String,String>
            {
                'body' => '{"status": "success","correlationId": "cd6247d0-2077-11ec-a285-02a2f3354824","timestamp": "2021-09-28T18:19:12","data":""',
                'statuscode' => '200'
            },

            'Callout:ModificaLayoutFattura_notOK' => 
            new Map<String,String>
            {
                'body' => '{"status": "success","correlationId": "cd6247d0-2077-11ec-a285-02a2f3354824","timestamp": "2021-09-28T18:19:12","data": {"rds": "C-00060011","attivita": "KO"}}',
                'statuscode' => '200'
            }

        };
    
    public HTTPResponse  respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        String bodyResponse;
        Integer statusCode;
        String endpoint = request.getEndpoint();


        // System.debug('HDT_WS_PostSalesTstMock - respond');
        System.debug(endpoint);
        for(String key : responseMap.keySet())
        {
            if(key.equalsIgnoreCase(endpoint))
            {
                if(endpoint.equalsIgnoreCase('Callout:Prova'))
                {
                    System.debug(responseMap.get(key).get('body'));
                    String recordId = '';
                    String body = request.getBody();
                    String substring = body.substring(body.indexOf('RECORD_ID'));
                    String valueSub = substring.substring(substring.indexOf('"value":'));
                    List<String> split = valueSub.split('}');
                    split = split[0].split(':');
                    recordId = split[1];
                    bodyResponse = responseMap.get(key).get('body');
                    bodyResponse = bodyResponse.replace('xxxxx', recordId);

                    statusCode = Integer.valueOf(responseMap.get(key).get('statuscode'));
                }
                else 
                {
                    bodyResponse = responseMap.get(key).get('body');
                    statusCode = Integer.valueOf(responseMap.get(key).get('statuscode'));
                }
            }
        }
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(statusCode);
        response.setStatus('OK');
        return response;
        //Arricchimento Dati
        // if(endpoint.equalsIgnoreCase('ArricchimentoDatiTemp')){
        //     return creaEnrichResposne(request); // --> Ok 
        // //Pagamenti
        // }else if(endpoint.equalsIgnoreCase('Callout:GetEnvelopePostel')){
        //     return creaPostelResponse(request);  //--> Ok
        // }else if(endpoint.containsIgnoreCase('HDT_PaymentCommunication')){
        //     return creaPaymentsResponse(request); // --> Ok
        // }else if(endpoint.containsIgnoreCase('Credit')){
        //     return creaCreditViewsResponse(request); // --> Ok
        // }else if(endpoint.containsIgnoreCase('HDT_AccountBalance')){
        //     return creaAccountBalanceResponse(request); // --> Ok
        // }else if(endpoint.containsIgnoreCase('Callout:CheckLastReading')){
        //     return creaCheckLastReadingsResponse(request); // --> Ok
        // }else if(endpoint.equalsIgnoreCase('Callout:ModificaLayoutFattura')){
        //     return creaModificaLayoutFatturaResponse(request); // --> Ok 
        // }else if(endpoint.equalsIgnoreCase('Callout:ModificaLayoutFattura_null')){
        //     return creaModificaLayoutFatturaResponseNull(request); // --> 
        // }else if(endpoint.equalsIgnoreCase('Callout:ModificaLayoutFattura_notOK')){
        //     return creaModificaLayoutFatturaResponseNotOK(request);
        // } else{
        //     return creaRicResponse(request);
        // }
    }
    

    /*public static HttpResponse creaRicResponse(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        String recordId = '';
        String body = request.getBody();
        //System.debug('RecordIdIndex ' + body.indexOf('RECORD_ID'));
        //System.debug('RecordId ' + body.substring(body.indexOf('RECORD_ID')));
        String substring = body.substring(body.indexOf('RECORD_ID'));
        String valueSub = substring.substring(substring.indexOf('"value":'));
        List<String> split = valueSub.split('}');
        split = split[0].split(':');
        //System.debug('RECORD_ID ' + split[1]);
        recordId = split[1];
        // Da errore nel deserialize
        // HDT_WRP_MrrRequest.HDT_WRP_Request mrrRequest = (HDT_WRP_MrrRequest.HDT_WRP_Request) JSON.deserialize(body, HDT_WRP_MrrRequest.HDT_WRP_Request.class);
        // for(HDT_WRP_MrrRequest.HDT_WRP_Field field : mrrRequest.objects[0].fields){
        //     if(field.name == 'RECORD_ID'){
        //         recordId = field.value;
        //     }
        // }
        String responseStr = '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value":'+ recordId +'},'
            +'{"fieldType":"TEXT","name":"FASE","value":"Comunicazione verso Heroku OK"},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":null}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseStr);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }
    
    public static HttpResponse creaEnrichResposne(HttpRequest request){
        HttpResponse response = new HttpResponse();
        String bodyResponse = '{"status": "success","correlationId": "2a0c1340-f6b5-11eb-bb88-068530f44c42","timestamp": "2021-08-06T14:52:33",'
        +'"data": {"testata": {"esito": "OK"},"posizioni": ['
        +'{"campo": "DATACESSAZIONE","valore": "99991231"},'
        +'{"campo": "ALIQUOTAIVA","valore": "01"},'
        +'{"campo": "CA","valore": "200008867681"},'
        +'{"campo": "DESCRFATTURAZCOLL","valore": "Il contratto può essere fatturato con altri contratti"},'
        +'{"campo": "ANNOFABBRCONT","valore": "2000"},'
        +'{"campo": "CALIBRO1","valore": "GRT003"},'
        +'{"campo": "PRESENZACORRETTORE","valore": "NO"},'
        +'{"campo": "OPZIONE","valore": "E_UD_TDR"},'
        +'{"campo": "MOTIVOBLOCCOCALCOLO","valore": "T1"},'
        +'{"campo": "ACCISE","valore": "0.02270000"},'
        +'{"campo": "CODICE_ATECO","valore": "999999"}'
        +']}}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }
    
    public static HttpResponse creaPaymentsResponse(HttpRequest request){
        HttpResponse response = new HttpResponse();
        //successResponse
        String bodyResponse = '{"status": "success","correlationId": "eb9117b0-04e1-11ec-89bb-06c8ff345e9a","timestamp": "2021-08-24T15:48:13","data": {"rdsRdo": "00001945","tipoAttivita": "Pratica Avviata","note": ""}}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        return response;
    }

    public static HttpResponse creaPostelResponse(HttpRequest request){
        
        //System.debug('HDT_WS_PostSalesTstMock - creaPostelResponse');
        HttpResponse response = new HttpResponse();
        //successResponse
        
        
        // public Integer responseCode;
        // public String responseStatus;
        // public String content;
        
        
        String bodyResponse = '{"status": "success","correlationId": "eb9117b0-04e1-11ec-89bb-06c8ff345e9a","timestamp": "2021-08-24T15:48:13","data": {"responseCode": "200","responseStatus": "Test","content": "Test Content"}}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');   
        return response;
    }
    
    
    public static HttpResponse creaCreditViewsResponse(HttpRequest request){
        HttpResponse response = new HttpResponse();
        String bodyResponse = '{"status": "success","correlationId": "b40f74a0-0cd2-11ec-9bbe-06c86cee6034","timestamp": "2021-09-03T18:19:28",'
        +'"data": [{"contoContrattuale": "200008284449","codiceCliente": "1002647967","dataEmissione": "31/08/2021","dataScadenza": "20/10/2021",'
        +'"importo": "32.0","residuo": "32.0","documento": "500002727014","contratto": "3016825235","settoreMerceologico": "Energia elettrica",'
        +'"tipoTransazione": "EC4","idPrimoLivelloSAP": "00000000000000000000000000000000000000000000000001","oraIncassoRealTime": "00:00:00",'
        +'"loginId": "0-1","secondoLivelloInformativoF2": [{"riferimentoFattura": "0000411903129942","societa": "Hera Comm S.p.A.","contratto": "3016825235",'
        +'"settoreMerceologico": "Energia elettrica","dataEmissione": "03/04/2019","dataScadenza": "23/04/2019","importo": "64.22","totaleCopertina": "0.0",'
        +'"idSecondoLivelloSAP": "00000000000000000000000000000000000000000000000001"}]},'
        +'{"contoContrattuale": "200008284449","codiceCliente": "1002647967","dataEmissione": "31/08/2021","dataScadenza": "20/10/2021","importo": "116.0",'
        +'"residuo": "0.0","documento": "500002727015","contratto": "3016598437","settoreMerceologico": "Gas","tipoTransazione": "EC4",'
        +'"idPrimoLivelloSAP": "00000000000000000000000000000000000000000000000002","oraIncassoRealTime": "00:00:00","loginId": "0-1","secondoLivelloInformativoF2": ['
        +'{"riferimentoFattura": "0000431900252295","societa": "Hera Comm Marche","contratto": "3016598437","settoreMerceologico": "Gas","dataEmissione": "03/04/2019",'
        +'"dataScadenza": "23/04/2019","importo": "233.89","totaleCopertina": "0.0","idSecondoLivelloSAP": "00000000000000000000000000000000000000000000000001"}]}]}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        
        return response;
    }

    public static HttpResponse creaAccountBalanceResponse(HttpRequest request){
        HttpResponse response = new HttpResponse();
        String bodyResponse = '{"status": "failed","correlationId": "c5fb0140-0fc8-11ec-9bbe-06c86cee6034","timestamp": "2021-09-07T12:45:54","errorDetails": [{'
        +'"code": "HTTP:INTERNAL_SERVER_ERROR","message": "HTTP POST on resource \'http://isudbq.service.intra:8121/sap/bc/srt/rfc/sap/z_ws_saldo_bp/150/z_ws_saldo_bp/z_ws_saldo_bp\''
        +' failed: internal server error (500).","additionalInfo": "HTTP POST on resource \'http://isudbq.service.intra:8121/sap/bc/srt/rfc/sap/z_ws_saldo_bp/150/z_ws_saldo_bp/z_ws_saldo_bp\''
        +' failed: internal server error (500)."}]}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(500);
        response.setStatus('OK');
        
        return response;
    }
    
    public static HttpResponse creaCheckLastReadingsResponse(HttpRequest request){
        
        //System.debug('HDT_WS_PostSalesTstMock - creaCheckLastReadingsResponse');
        HttpResponse response = new HttpResponse();
        
        String bodyResponse = 'Response_Body_Test_Success';
        
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        
        return response;
    }
    
    public static HttpResponse creaModificaLayoutFatturaResponse(HttpRequest request){
        
        //System.debug('HDT_WS_PostSalesTstMock - creaModificaLayoutFatturaResponse');
        HttpResponse response = new HttpResponse();
        
        HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data wrpDATA = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data();
        wrpDATA.rds = 'rds';
        wrpDATA.attivita = 'Esito OK da SAP';
        
        HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
        bodyResp.status = 'TST_Status';
        bodyResp.correlationId = 'TST_CorrelId';
        bodyResp.timestamp = 'TST_TimeStamp';
        bodyResp.data = wrpDATA;
        
        
        String bodyResponse = JSON.serialize(bodyResp);
        
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        
        return response;
    }
    
    public static HttpResponse creaModificaLayoutFatturaResponseNull(HttpRequest request){
        
        //System.debug('HDT_WS_PostSalesTstMock - creaModificaLayoutFatturaResponseNull');
        HttpResponse response = new HttpResponse();
        
        HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
        bodyResp.status = 'TST_Status';
        bodyResp.correlationId = 'TST_CorrelId';
        bodyResp.timestamp = 'TST_TimeStamp';
        bodyResp.data = null;//TARGET
        
        
        String bodyResponse = JSON.serialize(bodyResp);
        
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        
        return response;
    }
    
    public static HttpResponse creaModificaLayoutFatturaResponseNotOK(HttpRequest request){
        
        //System.debug('HDT_WS_PostSalesTstMock - creaModificaLayoutFatturaResponseNotOK');
        HttpResponse response = new HttpResponse();
        
        HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data wrpDATA = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_Data();
        wrpDATA.rds = 'rds';
        wrpDATA.attivita = 'Test';//TARGET
        
        HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse bodyResp = new HDT_SRV_ModificaLayoutFattura.HDT_WRP_SuccessResponse();
        bodyResp.status = 'TST_Status';
        bodyResp.correlationId = 'TST_CorrelId';
        bodyResp.timestamp = 'TST_TimeStamp';
        bodyResp.data = wrpDATA;
        
        String bodyResponse = JSON.serialize(bodyResp);
        
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyResponse);
        response.setStatusCode(200);
        response.setStatus('OK');
        
        return response;
    }*/
    
}