@isTest
global class HDT_LC_MeterReadingControllerTstMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String s = setBody();
        response.setBody(s);
        //response.setBody('{"status": "success","correlationId": "92293250-df3b-11eb-a73c-0200a41fc6da","timestamp": "2021-07-07T17:54:13","data": []}');
        response.setStatusCode(200);
        response.setStatus('OK');
        return response; 
    }

    public static String setBody(){
        HDT_LC_MeterReadingControllerHelper.HDT_WRP_EstrattoLettureData estrattoLettureData = new HDT_LC_MeterReadingControllerHelper.HDT_WRP_EstrattoLettureData();
        estrattoLettureData.campo = '';
        estrattoLettureData.codiceContratto = '';
        estrattoLettureData.apparecchiatura = '';
        estrattoLettureData.dataLetturaPianificata = '';
        estrattoLettureData.posizioniPrecedentiLaVirgola = '';
        estrattoLettureData.decimali = '';
        estrattoLettureData.quantitaCalcolo = '';
        estrattoLettureData.tipoLettura = '';
        estrattoLettureData.categoriaLettura = '';
        estrattoLettureData.statoLettura = '';
        estrattoLettureData.consumoMedioGiornaliero = '';
        estrattoLettureData.giorniConsumo = '';
        estrattoLettureData.settoreMerceologico = '';
        estrattoLettureData.identificazioneNumeratore = '';
        estrattoLettureData.unitaDiMisura = '';
        estrattoLettureData.categoriaNumeratore = '';
        estrattoLettureData.tipoNumeratore = '';
        estrattoLettureData.motivazione = '';
        estrattoLettureData.letturaStornata = 'test';

        
        HDT_LC_MeterReadingControllerHelper.HDT_WRP_EstrattoLettureResponse estrattoLettureResponse = new HDT_LC_MeterReadingControllerHelper.HDT_WRP_EstrattoLettureResponse();
        estrattoLettureResponse.status = 'success';
        estrattoLettureResponse.correlationId = '92293250-df3b-11eb-a73c-0200a41fc6da';
        estrattoLettureResponse.timestamp = '2021-07-07T17:54:13';
        estrattoLettureResponse.data = new List<HDT_LC_MeterReadingControllerHelper.HDT_WRP_EstrattoLettureData>();
        estrattoLettureResponse.data.add(estrattoLettureData);
        return JSON.serialize(estrattoLettureResponse);
    }

}