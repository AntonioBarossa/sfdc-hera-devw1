@IsTest
public with sharing class HDT_UTL_RegistryAlignmentTst {

    
    @testSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare', 'Bozza', HDT_QR_ProcessPostSales.getRecordTypeId('HDT_RT_AllineamentoAnagrafica'), 'HDT_RT_AllineamentoAnagrafica');
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(19, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<ServicePoint__c> servPoint = HDT_UTL_DataFactoryTst.createServicePoint(19, false);
        for (ServicePoint__c serv : servPoint){
            serv.CommoditySector__c = 'Gas';
        }
        insert servPoint;
        List<Contract> cont = HDT_UTL_DataFactoryTst.createContract(19, false, acc[0].Id);
        Integer codiceSap = 1019602300;
        List<Contact> contactList = new List<Contact>();
        for(Integer n=0; n<19; n++){
            codiceSap++;
            cont[n].ServicePoint__c = servPoint[n].Id;
            cont[n].SAPContractCode__c = String.valueOf(codiceSap);
            contactList.addAll(HDT_UTL_DataFactoryTst.createContact(1, false, acc[n].Id));
            cont[n].AccountId = acc[n].Id;
        }
        insert cont;
        insert contactList;
        
        

        List<AccountContactRelation> acrList = [
            SELECT Id, AccountId, ContactId
            FROM AccountContactRelation
            WHERE AccountId = :acc
            AND ContactId = :contactList
        ];

        for (AccountContactRelation acr : acrList){
            if (acr.AccountId != acc[18].Id){
                acr.Roles = 'Titolare';
            }
        }

        
        update acrList;

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 1;
        request.Priority__c = 1;
        request.ProcessType__c = 'AllineamentoAnagrafica';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
            
        for(Integer n=0; n<20; n++){
            MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            switch on n{
                //Campo Vuoto
                when 15{
                    item.Data__c = '|' + cont[n].SAPContractCode__c;
                }
                //Type Sbagliato
                when 16{
                    item.Data__c = 'Type Errato|' + cont[n].SAPContractCode__c; 
                }
                //Codice SAP Inesistente
                when 19{
                    item.Data__c = 'Allineamento Anagrafica|1019602300';
                }
                when else{
                    item.Data__c = 'Allineamento Anagrafica|' + cont[n].SAPContractCode__c;
            
                }
            }
            itemsList.add(item);
        }
        insert itemsList;

    }

    @isTest
    public static void testAllineamentoAnagrafiche(){
        Test.setMock(HttpCalloutMock.class, new HDT_MK_ArricchimentoDatiMock());
        Test.startTest();
        HDT_SRV_ProcessRequestItem r = new HDT_SRV_ProcessRequestItem();
        r.execute();
        Test.stopTest();
        List<Case> caseList = [SELECT Id,Type, Cluster__c FROM Case WHERE Type = 'Allineamento Anagrafica' AND Cluster__c = 'Modifiche Anagrafiche'];
        System.assertEquals(16, caseList.size(), 'Non sono state create il numero di richieste attese');
    }

    public class HDT_MK_ArricchimentoDatiMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(createBody());
            res.setStatusCode(200);
            return res;
        }

        private String createBody(){
            HDT_WS_ArrichmentDataEntityResponse response = new HDT_WS_ArrichmentDataEntityResponse();
            response.status = 'Success';
            response.timestamp = String.valueOf(Datetime.now());
            response.correlationId = '43trdfgc34234';
            response.data = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoData();
            response.data.testata = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoTestata();
            response.data.testata.esito = 'OK';
            response.data.posizioni = new List<HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni>();
            HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
            posizione.campo = 'TaxRate__c';
            posizione.valore = 'Iva 22% (Cod. 02)';
            response.data.posizioni.add(posizione);
            posizione = new HDT_WS_ArricchimentoDatiTemp.HDT_WRP_ArricchimentoPosizioni();
            posizione.campo = 'SalesCompanyCode__c';
            posizione.valore = '10V0000160';
            response.data.posizioni.add(posizione);
            return JSON.serialize(response);
        }
    }
}
