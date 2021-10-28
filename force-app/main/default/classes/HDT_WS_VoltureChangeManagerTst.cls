@IsTest
public with sharing class HDT_WS_VoltureChangeManagerTst {

    /**@frapnico 13/10/2021
     * Test Class for the Class HDT_WS_VoltureChangeManager
     * TODO: Set Mock and create response
     */

    private static Boolean nullResponse = false;

    @TestSetup
    static void setup()
    {
        /*Variable Declarations*/
        String rtName = 'HDT_RT_VolturaConSwitch';
        String rtId = Schema.Order.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get(rtName).getRecordTypeId();
        List<Contact> contactList = new List<Contact>();
        /*Install Process Click*/
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        /*Create Callout Template*/
        List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', 
        '{"name": "Order","label": "Ordine","sObjectType": "Order","queryable": true,"fields": ['
        +'{"name": "ServicePointCode__c","label": "POD"},'
        +'{"name": "Id","label": "RIF_RICH"},'
        +'{"name": "OrderNumber","label": "RECORD_ID"},'
        +'{"name": "DistributorCode__c","label": "SERVICEID_DIS"},'
        +'{"name": "SalesCompanyCode__c","label": "SERVICEID_VEN"}'
        +'],'
        +'"objects":[{"name":"AccountId","label":"Account","sObjectType": "Account","relationshipName": "Account","queryable": true,"fields": ['
        +'{"name": "FiscalCode__c","label": "COD_FISCALE"},'
        +'{"name": "VATNumber__c","label": "PIVA"}'
        +'],"objects": []'
        +'},'
        +'{"label":"Static Value","queryable": false,"fields": ['
        +'{"name": "","label": "SIST_SORG","value": "SFDC"},'
        +'{"name": "","label": "COD_PRESC","value": "PKE"},'
        +'{"name": "","label": "PROCESS_CATEGORY","value": "sales"}'
        +'],"objects": []}]}','Callout_Template.json');
        List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates = HDT_UTL_DataFactoryTst.createCalloutTemplate(1,true,'Callout_Prova','prova',true,'Order','Flat',contentVersionList[0].ContentDocumentId);
        /*Create EndpointRule*/
        HDT_UTL_DataFactoryTst.createEndpointRule(1, true, 'Prova');
        /*Create Phase Transition*/
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Comunicazione verso Heroku', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_WS_VoltureChangeManager(method="execute");');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Amm. Precheck OK SII', 'Comunicazione verso Heroku', rtId, rtName,'A','','','');
        /* Create Records*/	
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        /* Update Order to match the callout template*/
        orderList[0].ServicePointCode__c = 'IT45454546676';
        orderList[0].DistributorCode__c = '13D0000001';
        orderList[0].SalesCompanyCode__c = '13V0000000';
        orderList[0].ProcessType__c = 'Voltura con Switch';
        orderList[0].RecordTypeId = rtId;
        orderList[0].Contact__c = contactList[0].Id;
        update orderList;


    }

    @IsTest
    static void executeTst()
    {
        List<Order> orderList = [SELECT Id, Phase__c FROM Order];
        orderList[0].Phase__c = 'Comunicazione verso Heroku';
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_VoltureChanageManagerMock());
        Test.startTest();
        HDT_UTL_DatabaseService.updateSObject(orderList);
        Test.stopTest();
        List<Order> orderListUpdated = [SELECT Id, TecnicalPhase__c, Phase__c FROM Order];
        System.assert((orderListUpdated[0].TecnicalPhase__c =='Amm. Precheck OK SII' || orderListUpdated[0].Phase__c =='Amm. Precheck OK SII'),
            'Fase non correttamente aggiornata');
    }

    @IsTest
    static void executeNullTst()
    {
        nullResponse = true;
        List<Order> orderList = [SELECT Id, Phase__c FROM Order];
        orderList[0].Phase__c = 'Comunicazione verso Heroku';
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_VoltureChanageManagerMock());
        Test.startTest();
        HDT_UTL_DatabaseService.updateSObject(orderList);
        Test.stopTest();
        List<Order> orderListUpdated = [SELECT Id, TecnicalPhase__c, Phase__c FROM Order];
        System.assertEquals(orderList[0].Phase__c,orderListUpdated[0].Phase__c,
            'Fase non correttamente aggiornata');
    }

    public class HDT_WS_VoltureChanageManagerMock implements HTTPCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse response = new HttpResponse();
            /* Create Body Response */
            String bodyResponse = nullResponse ? '' : createBodyResponse(request.getBody());
            /* Set Response */
            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
        }

        private String createBodyResponse(String request)
        {
            String recordId = getRecordId(request);
            /* Create the body response according to the real response */
            String bodyResponse = '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "sales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value":"'+ recordId +'"},'
            +'{"fieldType":"TEXT","name":"FASE","value":"Amm. Precheck OK SII"},'
            +'{"fieldType":"TEXT","name":"CODERR","value":"PKE"},'
            +'{"fieldType":"TEXT","name":"ANNOTAZIONI","value":"Richiesta ricevuta correttamente"},'
            +'{"fieldType":"TEXT","name":"TENSIONE","value":"12"},'
            +'{"fieldType":"TEXT","name":"VIA","value":"VIA ARTURO TOSCANINI"},'
            +'{"fieldType":"TEXT","name":"CIV","value":"51"},'
            +'{"fieldType":"TEXT","name":"CAP","value":"61112"},'
            +'{"fieldType":"TEXT","name":"ISTAT","value":"000000041044"},'
            +'{"fieldType":"TEXT","name":"LOCALITA","value":"PESARO"},'
            +'{"fieldType":"TEXT","name":"PROVINCIA","value":"PU"},'
            +'{"fieldType":"TEXT","name":"NAZIONE","value":"IT"},'
            +'{"fieldType":"TEXT","name":"ALTRO","value":""},'
            +'{"fieldType":"TEXT","name":"POTCONTRIMP","value":"3.58"},'
            +'{"fieldType":"TEXT","name":"POTDISP","value":"3.92"},'
            +'{"fieldType":"TEXT","name":"DATA_DECORRENZA_SW","value":"2021-10-14"},'
            +'{"fieldType":"TEXT","name":"DATA_DECORRENZA_VT_TIT_III","value":"2021-10-14"},'
            +'{"fieldType":"TEXT","name":"DATA_DECORRENZA_VT_TIT_IV","value":"2021-10-14"},'
            +'{"fieldType":"TEXT","name":"DES_ERR_AEEG","value":"Nessun errore rilevato"},'
            +'{"fieldType":"TEXT","name":"COD_PRAT_UTENTE","value":"C00000000716"},'
            +'{"fieldType":"TEXT","name":"COD_FLUSSO","value":""},'
            +'{"fieldType":"TEXT","name":"COD_PRAT_DISTR","value":"C00000000716_DL"},'
            +'{"fieldType":"TEXT","name":"RDSRDO","value":""}'
            +'],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}';
            return bodyResponse;
        }

        private string getRecordId(String request)
        {
            String recordId;
            /* Drill down the body response to get the recordId */
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(request);
            List<Object> requests = (List<Object>)requestMap.get('requests');
            Map<String,Object> singleRequest = (Map<String,Object>)requests[0];
            List<Object> objects = (List<Object>)singleRequest.get('objects');
            Map<String,Object> singleObj = (Map<String,Object>)objects[0];
            List<Object> fields = (List<Object>)singleObj.get('fields');
            for(Object field : fields)
            {
                Map<String,Object> fieldMap = (Map<String,Object>)field;
                if(String.valueOf(fieldMap.get('name')).equalsIgnoreCase('RECORD_ID'))
                {
                    recordId = (String)fieldMap.get('value');
                }
            }
            return recordId;
        }
    }
}