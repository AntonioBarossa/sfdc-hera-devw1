/**
 * Created by c.salvati on 12/12/2022.
 */

@IsTest
private class HDT_SRV_BillingRefundsServiceOneTst {

    @TestSetup
    static void setup(){
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        Id consumoRTId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_ConsumoAnomaloIdrico').getRecordTypeId();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Inviata a SAP','Da Inviare', consumoRTId, 'HDT_RT_ConsumoAnomaloIdrico');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Errore tecnico invio a SAP','Da Inviare', consumoRTId, 'HDT_RT_ConsumoAnomaloIdrico');
        Integer amount=1;
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountResidenziale(amount, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<Account>distributors=HDT_UTL_DataFactoryTst.createAccountDistributore(amount, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        for(Account tmp:accs){
            tmp.SAPIntegrationID__c=tmp.CustomerCode__c;
        }
        insert accs;
        List<ServicePoint__c> servPoint=new List<ServicePoint__c>();
        Integer k=0;
        for(ServicePoint__c sp: HDT_UTL_DataFactoryTst.createServicePoint(amount, false)) {
            sp.ServicePointCode__c=sp.ServicePointCode__c+k;
            sp.Distributor__c=distributors[0].Id;
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
        List<BillingProfile__c>billingProfList=HDT_UTL_DataFactoryTst.createBillingProfile(amount, false, accs[0].Id);
        for(BillingProfile__c tmpBill:billingProfList){
            tmpBill.Account__c=accs[k].Id;
            tmpBill.InvoicingCity__c='Roma';
            tmpBill.InvoicingCountry__c='Italia';
            tmpBill.InvoicingPlace__c='Test';
            tmpBill.InvoicingPostalCode__c='00160';
            tmpBill.InvoicingProvince__c='RM';
            tmpBill.InvoicingStreetName__c='Via test';
            tmpBill.InvoicingStreetNumber__c='15';
            tmpBill.InvoiceEmailAddress__c='testinvoice@gmail.com';
            k++;
        }
        insert billingProfList;
        k=0;
        List<Contract> cont = new List<Contract>();
        for(Contract tmp:HDT_UTL_DataFactoryTst.createContract(amount, false, accs[0].Id)){
            tmp.ServicePoint__c = servPoint[k].Id;
            tmp.SAPContractCode__c = '301960232'+k;
            tmp.AccountId=accs[k].Id;
            tmp.Contact__c=contactList[k].Id;
            tmp.BillingProfile__c=billingProfList[k].Id;
            cont.add(tmp);
            k++;
        }
        insert cont;
        List<Case> consumoCases=HDT_UTL_DataFactoryTst.createCaseAnomaloIdricoBulk(amount,false, accs[0].Id, servPoint[0].Id, cont[0].Id,billingProfList[0].Id,'', '');
        consumoCases[0].Phase__c='Da Inviare';
        insert consumoCases;
    }
    @IsTest
    static void callServiceOneFromFlowsOkTst() {
        Case consumoCase=[SELECT ServicePoint__r.Distributor__r.CompanyOwner__c,CaseNumber,
                Id,Contract__r.SAPContractCode__c,AbnormalReading__c,AbnormalReadingDate__c,AccountId,Contract__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockGenerator());
        HDT_SRV_BillingRefundsServiceOne classToTest=new HDT_SRV_BillingRefundsServiceOne();
        Test.startTest();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn=(wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)classToTest.execute(new Map<String,Object>{'sender'=>consumoCase,'method'=>'practicalescapes'});
        Test.stopTest();
        System.assertEquals('OK',responseReturn.message,'response was not ok');
    }

    @IsTest
    static void callServiceOneFromFlowsKoTst(){
        Case consumoCase=[SELECT ServicePoint__r.Distributor__r.CompanyOwner__c,CaseNumber,
                Id,Contract__r.SAPContractCode__c,AbnormalReading__c,AbnormalReadingDate__c,AccountId,Contract__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        String koBody='{"status":"failed","correlationId":"5f8e3660-7b02-11ed-b7ae-06af14a00b76","timestamp":"2022-12-13T17:22:44","errorDetails": [{"code":"ERROR","message": "TEST ERROR","additionalInfo": "THIS IS A TEST ERROR"}]}';
        Test.setMock(HttpCalloutMock.class, new MockGenerator(201,koBody));
        HDT_SRV_BillingRefundsServiceOne classToTest=new HDT_SRV_BillingRefundsServiceOne();
        Test.startTest();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn =(wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse)classToTest.execute(new Map<String,Object>{'sender'=>consumoCase,'method'=>'practicalescapes'});
        Test.stopTest();
        System.assertEquals('KO',responseReturn.message,'response was ok');
    }

    public class MockGenerator implements HttpCalloutMock{
        final Integer statusCode;
        final String body;
        public MockGenerator(Integer statusCode, String body){
            this.statusCode=statusCode;
            this.body=body;
        }
        public MockGenerator(){
            this.statusCode=200;
            this.body='{"status":"success","correlationId":"5f8e3660-7b02-11ed-b7ae-06af14a00b76","timestamp":"2022-12-13T17:22:44","errorDetails":[]}';
        }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}