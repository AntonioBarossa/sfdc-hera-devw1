/**
 * @author Elvin Iluca 
 * @date 07/12/2022
 * @description HDT_WS_ArrichmentDataEntityInvoker Test Classes
 * @history Elvin Iluca 07/12/2022 – Created Class
 */
@isTest
public with sharing class HDT_WS_ArrichmentDataEntityInvokerTst {
    
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
        ret = HDT_WS_ArrichmentDataEntityInvoker.callService(contractList[0].SAPContractCode__c, contractList[0].ServicePoint__r.ServicePointCode__c);
        Test.stopTest();

        System.assertEquals(200,ret.statusCode,'ERROR: Callout fault');
    }

    @isTest
    public static void callServiceInvocable(){
        List<HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs> requestList = new List<HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs>();
        
        HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs request = new HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs();
        List<Contract> contractList = [SELECT Id, SAPContractCode__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SAPImplantCode__c FROM Contract WITH SECURITY_ENFORCED LIMIT 1];
        request.contractCode= contractList[0].SAPContractCode__c;
        request.pod = contractList[0].ServicePoint__r.ServicePointCode__c;
        request.impianto = contractList[0].ServicePoint__r.ServicePointCode__c;

        requestList.add(request);
        List<String> ret = new List<String>();
        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArrichmentDataEntityInvokerTstMock(200));

        Test.startTest();
        ret = HDT_WS_ArrichmentDataEntityInvoker.submitEnrichmentRequest(requestList);
        Test.stopTest();

        HDT_WS_ArrichmentDataEntityResponse arrichmentDataEntityResponse = (HDT_WS_ArrichmentDataEntityResponse) JSON.deserialize(ret[0], HDT_WS_ArrichmentDataEntityResponse.class);
        
        System.assertEquals(200,arrichmentDataEntityResponse.statusCode,'ERROR: Callout fault');
    }

    @isTest
    public static void callServiceInvocableKo(){
        List<HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs> requestList = new List<HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs>();
        
        HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs request = new HDT_WS_ArrichmentDataEntityInvoker.HDT_WRP_ArricchimentoFlowInputs();
        List<Contract> contractList = [SELECT Id, SAPContractCode__c, ServicePoint__r.ServicePointCode__c, ServicePoint__r.SAPImplantCode__c FROM Contract WITH SECURITY_ENFORCED LIMIT 1];
        request.contractCode= contractList[0].SAPContractCode__c;
        request.pod = contractList[0].ServicePoint__r.ServicePointCode__c;
        request.impianto = contractList[0].ServicePoint__r.ServicePointCode__c;

        requestList.add(request);
        List<String> ret = new List<String>();
        Test.setMock(HttpCalloutMock.class, new HDT_WS_ArrichmentDataEntityInvokerTstMock(404));

        Test.startTest();
        ret = HDT_WS_ArrichmentDataEntityInvoker.submitEnrichmentRequest(requestList);
        Test.stopTest();
       
        System.assertEquals('',ret[0],'ERROR: Callout successed');
    }

      /**​
    * @author Elvin Iluca
    * @date 07/12/2022
    * @description HDT_WS_ArrichmentDataEntityInvokerTst – Test Class for HDT_WS_ArrichmentDataEntityInvoker.cls
    */

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
}
