@isTest
public with sharing class HDT_LC_AdvancedMeterSearchTst {

    @IsTest
    static void searchMeterOnSapTryCatchTest(){

        String matricola = '';
        String servizio = '';
        String comune = '';
        String silos = '';
        
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AdvancedMeterSearchCalloutMockFailed());
        Test.startTest();
        try{
            String results = HDT_LC_AdvancedMeterSearch.searchMeterOnSap(matricola, servizio, comune, silos);
        } catch (Exception e) {
            System.assertEquals(e.getMessage(), 'failed test', 'Errore in fase di get della response.');
        }

        Test.stopTest();
        
    }

    @IsTest
    static void searchMeterOnSapAcquaTest(){

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

    @IsTest
    static void searchMeterOnSapGasTest(){

        String matricola = '234234234';
        String servizio = 'Gas';
        String comune = '';
        String silos = '';
        
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AdvancedMeterSearchCalloutMock());
        Test.startTest();
        
        String results = HDT_LC_AdvancedMeterSearch.searchMeterOnSap(matricola, servizio, comune, silos);

        Test.stopTest();

        System.assertNotEquals(null, results, 'Errore in fase di get della response.');
        
    }

    @IsTest
    static void searchMeterOnSapEleTest(){

        String matricola = '234234234';
        String servizio = 'Energia Elettrica';
        String comune = '';
        String silos = '';
        
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AdvancedMeterSearchCalloutMock());
        Test.startTest();
        
        String results = HDT_LC_AdvancedMeterSearch.searchMeterOnSap(matricola, servizio, comune, silos);

        Test.stopTest();

        System.assertNotEquals(null, results, 'Errore in fase di get della response.');
        
    }

    @IsTest
    static void searchMeterOnSapTeleriscaldamentoTest(){

        String matricola = '234234234';
        String servizio = 'Teleriscaldamento';
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

    public class HDT_LC_AdvancedMeterSearchCalloutMockFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"fail","correlationId":"30cf9330-02f0-11ed-addc-064078045870","timestamp":"2022-27-07T12:00:34.819+02:00","data":{"esito":"KO","etOut":[{"matricola":"234234234","indirizzo":"TEST ADDRESS","puntoPresa":"90892409824","statoContratto":"Attivo","numeroContratto":"435345","tipoImpianto":""}],"responseMsg":"failed test"}}');
            res.setStatusCode(200);
            return res;
        }
    }

}
