@IsTest
public with sharing class HDT_WS_ArricchimentoDatiTempTst
{
    @IsTest
    static void arricchimentoTest()
    {
        List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs> inputs = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs>();
        HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs input = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoFlowInputs();
        input.contractCode = '3026175385';
        input.pod = '00882102210891';
        input.impianto = '40592092894';
        inputs.add(input);
        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArricchimentoMock());
        Test.startTest();
            List<String> result = HDT_WS_ArricchimentoDatiTemp.submitRequestFlow(inputs);
        Test.stopTest();
        System.assertEquals(true, !result.isEmpty(), 'Arricchimento fallito');
    }

    public class HDT_WS_ArricchimentoMock implements HTTPCalloutMock
    {
        public HTTPResponse respond(HTTPRequest request){

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;

            bodyResponse = '{ "status": "success", "correlationId": "a83ad6a0-fb70-11ec-a588-0257e41969d4", "timestamp": "2022-07-04T10:09:42", "data": { "testata": { "esito": "OK" }, "posizioni": [ { "campo": "POD", "valore": "00882102210891" }, { "campo": "DATACESSAZIONE", "valore": "99991231" }, { "campo": "DATAATTIVAZIONE", "valore": "20220501" }, { "campo": "FATTURACOLLETTIVA", "valore": "2" }, { "campo": "VENDITORE", "valore": "10V0000160" }, { "campo": "ALIQUOTAIVA", "valore": "02" }, { "campo": "CONTRATTO", "valore": "3026175385" }, { "campo": "CA", "valore": "200013542912" }, { "campo": "DEFINIZIONEOFFERTA", "valore": "PNNATGCA+N" }, { "campo": "DEFINIZIONEPROFILO", "valore": "V40" }, { "campo": "DESCRFATTURAZCOLL", "valore": "Il contratto può essere fatturato con altri contratti" }, { "campo": "TESTOALIQUOTAIVA", "valore": "CLIENTI GENERICI 21%" }, { "campo": "IMPIANTO", "valore": "4011256256" }, { "campo": "TIPOIMPIANTO", "valore": "1004" }, { "campo": "COMMODITY", "valore": "10" }, { "campo": "DESCRCOMM", "valore": "Gas" }, { "campo": "DESCRTIPOIMP", "valore": "Riscaldamento promiscuo" }, { "campo": "BP", "valore": "1009164549" }, { "campo": "CF", "valore": "FRZPLG60C21D810U" }, { "campo": "CATEGORIATARIFFA", "valore": "GATSMBSCN0" }, { "campo": "PERIODOFATTURAZIONE", "valore": "2" }, { "campo": "DESCRIZIONEPORTION", "valore": "Bim fm pari MAU" }, { "campo": "DISTRIBUTORE", "valore": "10D0000013" }, { "campo": "LOCALITA", "valore": "MARTINSICURO" }, { "campo": "CODIFICALOCALITA", "valore": "000000067047" }, { "campo": "CODICEPAESE", "valore": "IT" }, { "campo": "CIVICO", "valore": "20" }, { "campo": "CAP", "valore": "64014" }, { "campo": "REGIONE", "valore": "TE" }, { "campo": "VIA", "valore": "VIA FLAVIO GIOIA" }, { "campo": "CODICEVIA", "valore": "067047000122" }, { "campo": "STATODEVICE", "valore": "A" }, { "campo": "ANNOFABBRCONT", "valore": "2000" }, { "campo": "CALIBRO1", "valore": "GRT003" }, { "campo": "MATRICOLA1", "valore": "R013OR034420092503" }, { "campo": "GRUPPONUMERATORE", "valore": "G1V05VOL" }, { "campo": "PRESENZACORRETTORE", "valore": "NO" }, { "campo": "CODICEUFFICIO", "valore": "0000000" }, { "campo": "MODINVIOFATTURA", "valore": "03" }, { "campo": "DESCRINVIOFATT", "valore": "XML + carta/email" }, { "campo": "MERCATO", "valore": "LIBERO" }, { "campo": "TIPOMERCATO", "valore": "17" }, { "campo": "CODICEREMI", "valore": "34806300" }, { "campo": "PRESSIONE", "valore": "25.0000000" }, { "campo": "CONSUMOCAPDR", "valore": "46.0000000" }, { "campo": "CONSUMOANNUOGAS", "valore": "45.0000000" }, { "campo": "IMPOSTE", "valore": "G_ICD" } ] } }';
            statusCode = 200;

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response;
        }
    }
}
