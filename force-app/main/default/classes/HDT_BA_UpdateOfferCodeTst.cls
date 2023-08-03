@isTest
public with sharing class HDT_BA_UpdateOfferCodeTst {

    @TestSetup
    static void makeData(){

        List<ServicePoint__c> listOfServicePoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, true, 'HERA COMM', 'Persona fisica', 'Famiglie');
        List<Contract> listOfContract = HDT_UTL_DataFactoryTst.createContract(1, false, accountList[0].Id);
        for(Contract con : listOfContract){
            con.ServicePoint__c = listOfServicePoint[0].Id;
        }
        insert listOfContract;
        List<OfferCodeUpdateLog__c> listOfferCodeUpdateLog = new List<OfferCodeUpdateLog__c>();
        OfferCodeUpdateLog__c offLogCodTZeroY = new OfferCodeUpdateLog__c();
        offLogCodTZeroY.SapContractCode__c = listOfContract[0].SapContractCode__c;
        offLogCodTZeroY.Pod__c = listOfServicePoint[0].ServicePointCode__c;
        offLogCodTZeroY.OfferCode__c = 'Test';
        offLogCodTZeroY.Profile__c = 'Test';
        offLogCodTZeroY.Commodity__c = 'Energia Elettrica';
        offLogCodTZeroY.EffectiveDate__c = Date.today();
        offLogCodTZeroY.CodTzero__c = 'Y';
        offLogCodTZeroY.EffectiveMonths__c = 10;
        offLogCodTZeroY.CausalCode__c = 'Test';
        listOfferCodeUpdateLog.add(offLogCodTZeroY);

        OfferCodeUpdateLog__c offLogCodTZeroN = new OfferCodeUpdateLog__c();
        offLogCodTZeroN.SapContractCode__c = listOfContract[0].SapContractCode__c;
        offLogCodTZeroN.Pod__c = listOfServicePoint[0].ServicePointCode__c;
        offLogCodTZeroN.OfferCode__c = 'Test';
        offLogCodTZeroN.Profile__c = 'Test';
        offLogCodTZeroN.Commodity__c = 'Energia Elettrica';
        offLogCodTZeroN.EffectiveDate__c = Date.today();
        offLogCodTZeroN.CodTzero__c = 'N';
        offLogCodTZeroN.EffectiveMonths__c = 10;
        offLogCodTZeroN.CausalCode__c = 'Test';
        listOfferCodeUpdateLog.add(offLogCodTZeroN);
        insert listOfferCodeUpdateLog;
    }

    @isTest
    static void executeBatch(){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));
        Test.startTest();
        Database.executeBatch(new HDT_BA_UpdateOfferCode('UpdateCodeOffer'), 200);
        Test.stopTest();
    }

    @isTest
    static void executeBatchUpdateCodeOffer(){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));
        Test.startTest();
        Database.executeBatch(new HDT_BA_UpdateOfferCode('UpdateCodeOffer'), 200);
        Test.stopTest();
    }

    @isTest
    static void executeBatchFirstCommunicationCode(){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));
        Test.startTest();
        Database.executeBatch(new HDT_BA_UpdateOfferCode('FirstCommunicationCode'), 1);
        Test.stopTest();
    }

    @isTest
    static void scheduleBatchUpdateCodeOffer(){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));
        Test.startTest();
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Scheduling', chron, new HDT_BA_UpdateOfferCode('UpdateCodeOffer'));
        Test.stopTest();
    }

    @isTest
    static void scheduleBatchFirstCommunicationCode(){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"testata":{"esito":"OK"},"posizioni":[{"campo":"IMPOSTE","valore":"200008867681"},{"campo":"STAMPADEL501GAS","valore":"200008867681"},{"campo":"ACCISE","valore":"200008867681"},{"campo":"CA","valore":"200008867681"},{"campo":"PRESSIONE","valore":"200008867681"},{"campo":"CALIBRO1","valore":"200008867681"},{"campo":"DESCRFATTURACOLL","valore":"200008867681"},{"campo":"OPZIONE","valore":"200008867681"},{"campo":"MOTIVOBLOCCOCALCOLO","valore":"200008867681"},{"campo":"ANNOFABBRCONT","valore":"2021"},{"campo":"DATACESSAZIONE","valore":"20210930"}]}}');
        response.setStatusCode(200);
        response.setStatus('OK');
        
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_AnagAlignmentTstMock(response));
        Test.startTest();
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Scheduling', chron, new HDT_BA_UpdateOfferCode('FirstCommunicationCode'));
        Test.stopTest();
    }

    public class HDT_SRV_AnagAlignmentTstMock implements HttpCalloutMock{
        HttpResponse response;
        HDT_SRV_AnagAlignmentTstMock(HttpResponse r){
            response = r;
        }
        public HTTPResponse respond(HTTPRequest request) {
            return response; 
        }
    
    }
}