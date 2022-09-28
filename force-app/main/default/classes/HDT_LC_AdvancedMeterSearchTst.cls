@isTest
public with sharing class HDT_LC_AdvancedMeterSearchTst {

    @IsTest
    static void searchMeterOnSapTest(){

        String matricola = '234234234';
        String servizio = 'Acqua';
        String comune = '';
        String silos = '';
        
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AdvancedMeterSearchCalloutMock());
        Test.startTest();
        
        String results = HDT_LC_AdvancedMeterSearch.searchMeterOnSap(matricola, servizio, comune, silos);

        Test.stopTest();

        System.assertNotEquals(null, results, 'Errore in fase di get della response.');
        
    }

    public class HDT_LC_AdvancedMeterSearchCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","correlationId":"30cf9330-02f0-11ed-addc-064078045870","timestamp":"2022-27-07T12:00:34.819+02:00","data":{"esito":"","etOut":[{"matricola":"234234234","indirizzo":"TEST ADDRESS","puntoPresa":"90892409824","statoContratto":"Attivo","numeroContratto":"435345","tipoImpianto":""}],"responseMsg":""}}');
            res.setStatusCode(200);
            return res;
        }
    }

}
