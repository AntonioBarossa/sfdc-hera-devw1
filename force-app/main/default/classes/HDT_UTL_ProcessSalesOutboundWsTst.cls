@isTest
public with sharing class HDT_UTL_ProcessSalesOutboundWsTst {


    @TestSetup
    static void setup(){
        Integer amount=1;
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountResidenziale(amount, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        for(Account tmp:accs){
            tmp.SAPIntegrationID__c=tmp.CustomerCode__c;
        }
        insert accs;
        List<ServicePoint__c> servPoint=new List<ServicePoint__c>();
        Integer k=0;
        for(ServicePoint__c sp: HDT_UTL_DataFactoryTst.createServicePoint(amount, false)) {
            sp.ServicePointCode__c=sp.ServicePointCode__c+k;
            sp.SAPImplantCode__c= HDT_UTL_DataFactoryTst.generateRandomChars(20, true, false, false); 
            servPoint.add(sp);
            k++;
        }
        insert servPoint;
        k=0;
        List<Contact>contactList= HDT_UTL_DataFactoryTst.createContact(amount, false, accs[0].Id);
        for(Contact c:contactList){
            c.AccountId=accs[k].Id;
            k++;
        }
        insert contactList;
    
        k=0;
        List<Contract> cont = new List<Contract>();
        for(Contract tmp:HDT_UTL_DataFactoryTst.createContract(amount, false, accs[0].Id)){
            tmp.ServicePoint__c = servPoint[k].Id;
            tmp.SAPContractCode__c = '301960232'+k;
            tmp.AccountId=accs[k].Id;
            tmp.Contact__c=contactList[k].Id;
            cont.add(tmp);
            k++;
        }
        insert cont;
            
    }

    @isTest
    public static void callService(){
        
        List<Contract> contractList = [SELECT Id, SAPContractCode__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SAPImplantCode__c FROM Contract WITH SECURITY_ENFORCED LIMIT 1];
        HDT_WS_ArrichmentDataEntityResponse ret;

        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArrichmentDataEntityInvokerTstMock(200));
        Test.startTest(); 
        //ret = HDT_WS_ArrichmentDataEntityInvoker.callService(contractList[0].SAPContractCode__c, contractList[0].ServicePoint__r.ServicePointCode__c);

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 1;
        request.Priority__c = 1;
        request.ProcessType__c = 'SwitchIn';
        request.Status__c = 'In Lavorazione';
        insert request;


        MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
        item.MassiveLoaderRequest__c = request.Id;
        item.Status__c = 'In Lavorazione';
        item.Data__c = 'true||ITALIA|HERA COMM|URBINO|VALENTINA||||13|EDERA|041067099015|PU||false|61029|Famiglie||D1 - Persona fisica||VIA CA\' BRUNELLO|email@prova.com|+39|||DREVNT67C42L500Y||||Femmina|+39|1010369692|false|||||URBINO|VIA CA\' BRUNELLO||||Sintetico|13||XML + carta/email|Bollettino postale||false||Cartaceo||||||200015387184|ITALIA||61029|PU|||HC_VenditaMM|||false|3385050158|||Si|Iva 10% (Cod. 01)||Imposta usi domestici|Cartacea|Posta Cartacea|2023-01-04|3385050158||URBINO|ITALIA|61029|PU|VIA CA\' BRUNELLO|13||Switch in Ele||Si|Permanente|2023-03-01|||Contratto firmato|Ordinaria (Perm)|Quality call|||URBINO||PU||VALENTINA|EDERA|DREVNT67C42L500Y|+39|3385050158||||||61029|ITALIA|Titolare|100|Appartamento||Si|3|PNNECB24+N|V42|false||||KAKTUS SRL|STEFANI Ilaria|Agenzie|AGENZIE|VI|AG870|Maggioli|Chiara|AG870V013|Hera Comm S.p.A.|||BT|13A0-Usi di Abitazione BT|URBINO|3|Si|Domestico||false|13|Multiorario|IT001E59103901|4012729301|61029|PU|ITALIA|||VIA CA\' BRUNELLO|3380|||false||Energia Elettrica||3||Si|3.3||||Persona Fisica|13D0000001||||';
        //item.Data__c = 'Riattivazione Fornitura|' + acc[0].Id + '|IT001E32452366|3019602323|HCM|2021-12-23';
        Id servPointId = [SELECT Id FROM ServicePoint__c LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        item.NextStepData__c = '{"servPointId":"'+servPointId+'","parentOrderId":"8013N000004mqk9QAA","orderCompatible":true,"contactId":"0033N00000ujFRVQA2","billProfId":"a2f3N00000AqwtSQAR","accountId":"'+accId+'"}';
        insert item;

        List<MassiveLoaderRequestItem__c> itesmList = new List<MassiveLoaderRequestItem__c>();
        itesmList.add(item);
        
        HDT_BA_ProcessSales processReq = new HDT_BA_ProcessSales(request.Id, 1, request.ProcessType__c);
        Database.executeBatch(processReq, 1);

        Test.stopTest();

        //System.assertEquals(200,ret.statusCode,'ERROR: Callout fault');
    }

    public class HDT_WS_ArrichmentDataEntityInvokerTstMock implements HttpCalloutMock {
        HDT_WS_ArrichmentDataEntityResponse myBody = new HDT_WS_ArrichmentDataEntityResponse();
        Integer statusCode;

        HDT_WS_ArrichmentDataEntityInvokerTstMock(Integer statusCode){
            this.statusCode=statusCode;
        }
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(myBody));
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response; 
        }
    }

    @isTest
    public static void otherMethods(){

        AccountContactRelation rel = new AccountContactRelation();
        Account acct = new Account();
        //rel.Id = '8013N000004mqk9QAA';
        acct.Name = 'Name';
        acct.RecordTypeId = '8013N000004mqk9QAA';
        acct.LastName__c = 'lastName';
        acct.FirstName__c = 'firstName';
        acct.Category__c = 'category';
        acct.Fax = 'category';
        acct.CustomerMarking__c = 'x';
        acct.FiscalCode__c = 'x';
        acct.Vatnumber__c = 'x';
        acct.BillingCity = 'x';
        acct.BillingCountry = 'x';
        acct.BillingStreetNumber__c = 'x';
        acct.BillingPostalCode = 'x';
        acct.BillingState = 'x';
        acct.BillingStreetName__c = 'x';
        acct.CustomerCode__c = 'x';
        acct.MobilePhone__c = 'x';
        acct.BuildingFloor__c = 'x';
        acct.PrimaryEmail__c = 'x';
        acct.VATGroup__c = 'x';
        acct.VATGroupStartDate__c = Date.today();
        acct.VATGroupEndDate__c = Date.today();
        rel.Account = acct;

        HDT_UTL_ProcessSalesOutboundWs.setAccountRecord(rel, new Account());
        HDT_UTL_ProcessSalesOutboundWs.setContactRecord(rel, new Contact());
        //setOldServicePoint(ServicePoint__c servPointFromWs, ServicePoint__c oldServPoint)

    }

}