@isTest
public with sharing class HDT_SRV_HerokuPostSalesManagerTst {

    public static Map<String,Map<String,String>> genericResponseMap =
    new Map<String,Map<String,String>>
    {
        'Callout:Prova' => 
        new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
        +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
        +'},"code":null,"description":null,'
        +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
        +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
        +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
        +'{"fieldType":"TEXT","name":"rifRich","value":""},'
        +'{"fieldType":"TEXT","name":"COD_PRAT_DISTR","value":"345345"},'
        +'{"fieldType":"TEXT","name":"DT_INVIO_DL","value":"'+ Date.today() +'"},'
        +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
        +'{"fieldType":"TEXT","name":"FASE","value":""},'
        +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
        +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
        'statuscode' => '200'
        }
    };

    @TestSetup
    static void setup(){
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPointList[0].ServicePointCode__c = 'IT001E46371811';
        servPointList[0].MeterSN__c = 'R0000000';
        insert servPointList;
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].DistributorPracticeCode__c = 'A00000000288_DL';
        ordList[0].ProcessType__c = 'Subentro Ele';
        ordList[0].ServicePoint__c = servPointList[0].Id;
        
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation accountContactRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,false, accList[0].Id);
        billingProfileList[0].InvoicingStreetName__c = 'Roma';
        billingProfileList[0].InvoicingStreetNumber__c = '15';
        billingProfileList[0].InvoicingStreetNumberExtension__c = '20100 ITALIA';
        billingProfileList[0].InvoicingCity__c = 'ROMA';
        billingProfileList[0].InvoicingProvince__c = 'RM';
        billingProfileList[0].InvoicingPostalCode__c = '10190';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';

        insert billingProfileList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);

        List<wrts_prcgvr__ActivityTemplate__c> actTempList = new List<wrts_prcgvr__ActivityTemplate__c>();

        wrts_prcgvr__ActivityTemplate__c actTemplate1 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate1.Name = 'Recesso Anticipato';
        actTemplate1.wrts_prcgvr__Subject__c = 'Recesso Anticipato';

        wrts_prcgvr__ActivityTemplate__c actTemplate2 = new wrts_prcgvr__ActivityTemplate__c();
        actTemplate2.Name = 'Eseguire Gestione Manuale SAP';
        actTemplate2.wrts_prcgvr__Subject__c = 'Eseguire Gestione Manuale SAP';
        actTemplate2.wrts_prcgvr__ObjectType__c = 'Case';

        actTempList.add(actTemplate1);
        actTempList.add(actTemplate2);
        insert actTempList;

        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(3, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].Type = 'Sollecito Emissione Bolletta';
        caseList[0].EarlyRecess__c = true;
        caseList[0].MeterCode__c = 'R0000001';
        caseList[1].Type = 'Unificazione/Separazione BP-CA-Bolletta';
        caseList[1].EarlyRecess__c = true;
        caseList[1].MeterCode__c = 'R0000002';
        caseList[2].Type = 'RImborso';
        caseList[2].EarlyRecess__c = true;
        caseList[2].MeterCode__c = 'R0000003';

        insert caseList;

        Case parentCase = [SELECT Id FROM Case WHERE Type = 'Sollecito Emissione Bolletta'];
        List<Case> caseList2 = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList2[0].ParentId = parentCase.Id;
        caseList2[0].Type = 'Sospensione Fornitura';
        caseList[0].MeterCode__c = 'R0000004';
        insert caseList2;

        List<ContentVersion> contentVersionList = HDT_UTL_DataFactoryTst.createContentVersion(1, true, 'Callout_Template', 
        '{"name": "Case","label": "Caso","sObjectType": "Case","queryable": true,"fields": ['
        +'{"name": "CreatedDate","label": "DT_RIC_UTENTE"},'
        +'{"name": "CaseNumber","label": "RIF_RICH"},'
        +'{"name": "Type","label": "TIPO_OPERAZIONE"},'
        +'{"name": "Id","label": "RECORD_ID"}'
        +'],"objects" : ['
        +'{"name": "ServicePoint__c", "label": "Fornitura","sObjectType": "ServicePoint__c","relationshipName": "ServicePoint__r", "queryable": true, "fields": ['
        +'{"name": "MeterSN__c","label": "SERNR"}'
        +'],"objects" : [] },'
        +'{"name": "BillingProfile__c", "label": "Billing Profile","sObjectType": "BillingProfile__c","relationshipName": "BillingProfile__r", "queryable": true, "fields": ['
        +'{"name": "IbanCountry__c","label": "PAESE_IBAN"}'
        +'],"objects" : [] }'
        +']}'
        ,'Callout_Template.json');
        List<wrts_prcgvr__CalloutTemplate__c> calloutTemplates = HDT_UTL_DataFactoryTst.createCalloutTemplate(1,true,'Callout_Prova','prova',true,'Case','Flat',contentVersionList[0].ContentDocumentId);
        HDT_UTL_DataFactoryTst.createEndpointRule(1, true, 'Prova');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Da Inviare', rtId, rtName,'C',calloutTemplates[0].wrts_prcgvr__Code__c,'requestType=CREA_RIC;','HDT_SRV_HerokuPostSalesManager(method="execute");');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku KO', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito OK da SII', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Annullamento - Comunicazione verso Heroku OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviato al DL', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Comunicazione verso Heroku OK', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Inviato al DL', rtId, rtName,'A','','','');
        
        String rtNameAnagr =  'HDT_RT_AllineamentoAnagrafica';
        String rtIdAnagr = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviato al DL', 'Bozza', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Annullato SII', 'Bozza', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Inviato al DL', rtIdAnagr, rtNameAnagr,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Comunicazione verso Heroku OK', rtIdAnagr, rtNameAnagr,'A','','','');

        String rtNamePianoRat =  'HDT_RT_PianoRateizzazione';
        String rtIdPianoRat = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Acconto paperless pagato', 'Bozza', rtIdPianoRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviato al DL', 'Bozza', rtIdPianoRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Comunicazione verso Heroku OK', rtIdPianoRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza', 'Inviato al DL', rtIdPianoRat, rtNamePianoRat,'A','','','');


        wrts_prcgvr__AsyncJob__c asyncJob = new wrts_prcgvr__AsyncJob__c();
        asyncJob.wrts_prcgvr__JobItem__c = 'test';
        asyncJob.wrts_prcgvr__Status__c = 'Chiusa';
        insert asyncJob;

    }
    @isTest
    static void executeTst()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        /*SObject transition;
        SObject action;
        String method = 'execute';
        Map<String, String> parameters = new Map<String,String>();
        Map<String,Object> args = new Map<String,Object>{
            'transition' => transition,
            'action' => action,
            'method' => method,
            'sender' => testCase,
            'parameters' => parameters
        };*/
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        Test.startTest();
        //response = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) herokuSrv.execute(args);
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        System.assertEquals('00002349', testCaseUpd.HerokuPracticeCode__c, 'HerokuPracticeCode__c != 00002349');
        
    }

    @isTest
    static void executeTstWithComChannelATOA()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        //Create response
        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"COD_PRAT_DISTR","value":"345345"},'
            +'{"fieldType":"TEXT","name":"DT_INVIO_DL","value":"'+ Date.today() +'"},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
            +'{"fieldType":"TEXT","name":"FASE","value":""},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
            'statuscode' => '200'
            }
        };
        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(responseMap));
        //Test
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        System.assertEquals('00002349', testCaseUpd.HerokuPracticeCode__c, 'HerokuPracticeCode__c != 00002349');
        
    }

    @isTest
    static void executeTstWithComChannelResultKO()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        //Create response
        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"CREA_RIC","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"KO"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":""},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
            +'{"fieldType":"TEXT","name":"FASE","value":""},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
            'statuscode' => '200'
            }
        };
        //Mock        
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(responseMap));
        //Test
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku KO', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku KO');
        System.assertEquals('00002349', testCaseUpd.HerokuPracticeCode__c, 'HerokuPracticeCode__c != 00002349');
        
    }

    @isTest
    static void executeTstWithComChannelAnnullamentoOK()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        //Create response
        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"ANNULL","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"OK"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":"Annullato"},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
            +'{"fieldType":"TEXT","name":"FASE","value":""},'
            +'{"fieldType":"TEXT","name":"COD_PRAT_UTENTE","value":"234823"},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
            'statuscode' => '200'
            }
        };
        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(responseMap));
        //Test
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.debug('UPDATED CASE: ' + testCaseUpd);
        System.assertEquals('Annullamento - Comunicazione verso Heroku OK', testCaseUpd.Phase__c, 'Phase__c != Annullamento - Comunicazione verso Heroku OK');
        
    }

    @isTest
    static void executeTstWithComChannelAnnullamentoKO()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        //Create response
        Map<String,Map<String,String>> responseMap =
        new Map<String,Map<String,String>>
        {
            'Callout:Prova' => 
            new Map<String,String>{ 'body' => '{"responses":[{"header":{"requestId":"","requestTimestamp":null,"requestType":"ANNULL","fields":'
            +'[{"fieldType": "TEXT","name": "PROCESS_CATEGORY","value": "postsales"}]'
            +'},"code":null,"description":null,'
            +'"objects":[{"fields":[{"fieldType":"TEXT","name":"result","value":"KO"},'
            +'{"fieldType":"TEXT","name":"requestId","value":"00002349"},'
            +'{"fieldType":"TEXT","name":"errorMessage","value":"Annullato"},'
            +'{"fieldType":"TEXT","name":"rifRich","value":""},'
            +'{"fieldType":"TEXT","name":"RECORD_ID","value": xxxxx},'
            +'{"fieldType":"TEXT","name":"FASE","value":""},'
            +'{"fieldType":"TEXT","name":"COD_PRAT_UTENTE","value":"234823"},'
            +'{"fieldType":"TEXT","name":"comunicationChannel","value":"ATOA"}],'
            +'"id":null,"name":null,"objectType":null,"objects":null}]}]}',
            'statuscode' => '200'
            }
        };
        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(responseMap));
        //Test
        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.debug('UPDATED CASE: ' + testCaseUpd);
        System.assertEquals('Annullamento - Comunicazione verso Heroku KO', testCaseUpd.Phase__c, 'Phase__c != Annullamento - Comunicazione verso Heroku OK');
        
    }

    @isTest
    static void updatefutureTst()
    {   
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];
        //Test
        Test.startTest();
        testCase.Phase__c = 'Comunicazione verso Heroku OK';
        HDT_SRV_HerokuPostSalesManager.updateFuture(JSON.serialize(testCase));
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT Id, Phase__c FROM Case LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.Phase__c, 'Phase__c != Comunicazione verso Heroku OK');
    }
    @isTest
    static void handleInboundRequestRichTst()
    {
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        //HDT_WRP_MrrResponse.HDT_WRP_Object responseObj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObjPass = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        //HDT_WRP_MrrRequest notifEs = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest richPass = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest richPassDis = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest richPassVol = new HDT_WRP_MrrRequest();
        //HDT_WRP_MrrRequest richKo = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Integer statusCode;
        RestContext.request = req;
        RestContext.response = res;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Phase__c, Type FROM Case WHERE Type = 'Sollecito Emissione Bolletta' LIMIT 1];
        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        testContract.EndDate = Date.valueOf('2121-05-12');
        update testContract;

        //Create Requests
        //String notifEsString = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Comunicazione verso Heroku OK','esito_intermedio');
        String richPassString = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, 'Morosita', 'Sospensione Fornitura', '', 'Da PGM', '20220102', testCase.CaseNumber, '');
        //String notifEsKo = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Completata','esito_finale');
        String richPassDisattivazioni = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, '', 'Recesso per Altri Motivi', 'Disattivazioni', 'Da PGM', '2022-01-02', '', '');
        String richPassVolture = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, '', 'Voltura Tecnica', 'Volture', 'Da PGM', '2022-01-02', '', '');

        //notifEs = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString, HDT_WRP_MrrRequest.class);
        //richKo  = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsKo, HDT_WRP_MrrRequest.class);
        richPass = (HDT_WRP_MrrRequest) JSON.deserialize(richPassString, HDT_WRP_MrrRequest.class);
        richPassDis = (HDT_WRP_MrrRequest) JSON.deserialize(richPassDisattivazioni, HDT_WRP_MrrRequest.class);
        richPassVol = (HDT_WRP_MrrRequest) JSON.deserialize(richPassVolture, HDT_WRP_MrrRequest.class);

        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();
        //responseObj = herokuSrv.handleInboundRequest(notifEs.requests[0]);
        //responseObj = herokuSrv.handleInboundRequest(richKo.requests[0]);
        responseObjPass = herokuSrv.handleInboundRequest(richPass.requests[0]);
        responseObjPass = herokuSrv.handleInboundRequest(richPassDis.requests[0]);
        responseObjPass = herokuSrv.handleInboundRequest(richPassVol.requests[0]);
        statusCode = res.statusCode;
        Test.stopTest();
        //Assertions
        List<Case> richPassCase = [SELECT CaseNumber, Phase__c, Type FROM Case WHERE Type != :testCase.Type];
        System.assertEquals(200, statusCode, 'statusCode != 200');
        System.assertEquals(6, richPassCase.size(), 'richPassCase.size() != 5');
    }
    
    @isTest
    static void handleInboundRequestNotifTst()
    {
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        //HDT_WRP_MrrResponse.HDT_WRP_Object responseObjPass = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrRequest notifEs = new HDT_WRP_MrrRequest();
        //HDT_WRP_MrrRequest richPass = new HDT_WRP_MrrRequest();
        //HDT_WRP_MrrRequest richPassDis = new HDT_WRP_MrrRequest();
        //HDT_WRP_MrrRequest richPassVol = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest richKo = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Integer statusCode;
        RestContext.request = req;
        RestContext.response = res;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Phase__c, Type FROM Case WHERE Type = 'Sollecito Emissione Bolletta' LIMIT 1];
        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        testContract.EndDate = Date.valueOf('2121-05-12');
        update testContract;

        //Create Requests
        String notifEsString = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Comunicazione verso Heroku OK','esito_intermedio');
        //String richPassString = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, 'Morosita', 'Sospensione Fornitura', '', 'Da PGM', '20220102', testCase.CaseNumber, '');
        String notifEsKo = HDT_UTL_DataFactoryTst.notifEsReq('postsales',testCase.Id, 'Completata','esito_finale');
        //String richPassDisattivazioni = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, '', 'Recesso per Altri Motivi', 'Disattivazioni', 'Da PGM', '2022-01-02', '', '');
        //String richPassVolture = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, '', 'Voltura Tecnica', 'Volture', 'Da PGM', '2022-01-02', '', '');

        notifEs = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString, HDT_WRP_MrrRequest.class);
        richKo  = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsKo, HDT_WRP_MrrRequest.class);
        //richPass = (HDT_WRP_MrrRequest) JSON.deserialize(richPassString, HDT_WRP_MrrRequest.class);
        //richPassDis = (HDT_WRP_MrrRequest) JSON.deserialize(richPassDisattivazioni, HDT_WRP_MrrRequest.class);
        //richPassVol = (HDT_WRP_MrrRequest) JSON.deserialize(richPassVolture, HDT_WRP_MrrRequest.class);

        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();
        responseObj = herokuSrv.handleInboundRequest(notifEs.requests[0]);
        responseObj = herokuSrv.handleInboundRequest(richKo.requests[0]);
        //responseObjPass = herokuSrv.handleInboundRequest(richPass.requests[0]);
        //responseObjPass = herokuSrv.handleInboundRequest(richPassDis.requests[0]);
        //responseObjPass = herokuSrv.handleInboundRequest(richPassVol.requests[0]);
        statusCode = res.statusCode;
        Test.stopTest();
        //Assertions
        List<Case> richPassCase = [SELECT CaseNumber, Phase__c, Type FROM Case WHERE Type != :testCase.Type];
        System.assertEquals(200, statusCode, 'statusCode != 200');
        System.assertEquals(3, richPassCase.size(), 'richPassCase.size() != 2');
    }

    @isTest
    static void handleInboundRequestWithoutSfKey()
    {
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObjPass = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrRequest richPass = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        Integer statusCode;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Phase__c, Type, RecordTypeId FROM Case LIMIT 1];

        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        update testContract;
        //Create Requests
        String richPassString = HDT_UTL_DataFactoryTst.richPassReq(testSp.ServicePointCode__c, testAccount.Account.CustomerCode__c, testBillingProfile.ContractAccountCode__c, testContract.SAPContractCode__c, 'Morosita', 'Sospensione Fornitura', '', 'Da PGM', '20220102', '', '');

        richPass = (HDT_WRP_MrrRequest) JSON.deserialize(richPassString, HDT_WRP_MrrRequest.class);
        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();
        responseObjPass = herokuSrv.handleInboundRequest(richPass.requests[0]);
        statusCode = res.statusCode;
        Test.stopTest();
        //Assertions
        System.assertEquals(200, statusCode, 'statusCode != 200');
    }  

    @isTest
    static void handleInboundRequestAggiornaRCU()
    {
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrRequest notifEs = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Phase__c, Type, RecordTypeId FROM Case LIMIT 1];

        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        update testContract;
        //Create Requests
        String notifEsString = HDT_UTL_DataFactoryTst.notifEsFullReq('postsales', testCase.CaseNumber, '3010147771', 'A01', 'IT001E46371811', 'A00000000288_DL', '23423424', '23423424', '', '', testCase.Id, 'Comunicazione verso Heroku OK', 'aggiornaRCU');
        notifEs = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString, HDT_WRP_MrrRequest.class);
        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();
        responseObj = herokuSrv.handleInboundRequest(notifEs.requests[0]);
        Test.stopTest();
        //Assertions
        Case testCaseUpd = [SELECT Id, CaseNumber, Phase__c, Type FROM Case WHERE Type = 'Allineamento Anagrafica' LIMIT 1];
        System.assertEquals('Da Inviare', testCaseUpd.Phase__c, 'Phase__c != Da Inviare');
    }

    @isTest
    static void handleInboundFullRequest()
    {
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrRequest notifEs = new HDT_WRP_MrrRequest();
        HDT_WRP_MrrRequest notifEs2 = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Cluster__c, Phase__c, Type, RecordTypeId FROM Case LIMIT 1];
        testCase.Cluster__c = 'Preventivi';
        update testCase;

        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        update testContract;
        //Create Requests
        String notifEsString = HDT_UTL_DataFactoryTst.notifEsFullReq('postsales', testCase.CaseNumber, '3010147771', 'A01', testSp.Id, 'A00000000288_DL', '', '', '', '', testCase.Id, 'Inviato al DL', 'esito_intermedio');
        String notifEsString2 = HDT_UTL_DataFactoryTst.notifEsFullReq('postsales', testCase.CaseNumber, '3010147771', 'A01', testSp.Id, 'A00000000288_DL', '', '', '', '', testCase.Id, 'Esito OK da DL', 'esito_intermedio');
        notifEs = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString, HDT_WRP_MrrRequest.class);
        notifEs2 = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString2, HDT_WRP_MrrRequest.class);
        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();
        
        responseObj = herokuSrv.handleInboundRequest(notifEs.requests[0]);
        Case testCaseUpd1 = [SELECT Id, CaseNumber, Phase__c, Type FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Inviato al DL', testCaseUpd1.Phase__c, 'Phase__c != Inviato al DL');

        testCase.Cluster__c = 'Morosità';
        testCase.Type = 'Riattivazione Fornitura';
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Morosita').getRecordTypeId();
        update testCase;
        responseObj = herokuSrv.handleInboundRequest(notifEs2.requests[0]);
        Case testCaseUpd2 = [SELECT Id, CaseNumber, Phase__c, Type FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Bozza', testCaseUpd2.Phase__c, 'Phase__c != Bozza');

        Test.stopTest();

    }  

    @isTest
    static void handleInboundRequestAddAttivita()
    {
        //Declaration
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        HDT_WRP_MrrResponse.HDT_WRP_Object responseObj = new HDT_WRP_MrrResponse.HDT_WRP_Object();
        HDT_WRP_MrrRequest notifEs = new HDT_WRP_MrrRequest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        //Entity Query
        AccountContactRelation testAccount = [SELECT Account.CustomerCode__c,AccountId, ContactId, Roles FROM AccountContactRelation WHERE Roles = 'Titolare' LIMIT 1];
        ServicePoint__c testSp = [SELECT Name,ServicePointCode__c FROM ServicePoint__c LIMIT 1];
        Contract testContract = [SELECT SAPContractCode__c FROM Contract WHERE AccountId = :testAccount.AccountId];
        BillingProfile__c testBillingProfile = [SELECT ContractAccountCode__c FROM BillingProfile__c LIMIT 1];
        Case testCase = [SELECT CaseNumber, Cluster__c, Phase__c, Type, RecordTypeId FROM Case LIMIT 1];
        testCase.Type = 'Piano Rateizzazione';
        testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        update testCase;

        //Update ServicePoint Commodity
        testSp.CommoditySector__c = 'Energia Elettrica';
        update testSp; 
        testContract.ServicePoint__c = testSp.Id;
        testContract.Status = 'Attivo';
        update testContract;

        //Create Requests
        String notifEsString = HDT_UTL_DataFactoryTst.notifEsFullReq('postsales', testCase.CaseNumber, '3010147771', 'A01', testSp.Id, 'A00000000288_DL', '', '', '', 'Piano rate OK Acc. pagato', testCase.Id, 'Inviato al DL', 'AddAttivita');
        notifEs = (HDT_WRP_MrrRequest) JSON.deserialize(notifEsString, HDT_WRP_MrrRequest.class);
        //SetMock
        Test.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        //Test
        Test.startTest();

        responseObj = herokuSrv.handleInboundRequest(notifEs.requests[0]);
        
        Test.stopTest();
        Case testCaseUpd = [SELECT Id, CaseNumber, Phase__c, Type FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Acconto Paperless Pagato', testCaseUpd.Phase__c, 'Phase__c != Acconto Paperless Pagato');
        
    } 

    @IsTest
    static void getAsyncJobByJobItem(){
        
        Test.startTest();

        /*String result = HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem('test');
        System.assertEquals('OK', result, 'result != OK');

        wrts_prcgvr__AsyncJob__c asyncJob = [SELECT wrts_prcgvr__Status__c, wrts_prcgvr__Details__c FROM wrts_prcgvr__AsyncJob__c LIMIT 1];
        asyncJob.wrts_prcgvr__Status__c = 'Queued';
        asyncJob.wrts_prcgvr__Details__c = 'Test';
        update asyncJob;

        String result2 = HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem('test');
        System.assertEquals('Error', result2, 'result != Error');

        wrts_prcgvr__AsyncJob__c asyncJob2 = [SELECT wrts_prcgvr__Status__c FROM wrts_prcgvr__AsyncJob__c LIMIT 1];
        asyncJob2.wrts_prcgvr__Status__c = '';
        update asyncJob2;

        String result3 = HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem('test');
        System.assertEquals('KO', result3, 'result != KO');*/

        List<Case> myCaseList = [Select Id, Phase__c from Case LIMIT 1];
        myCaseList[0].Phase__c = 'Bozza';
        String result1 = HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem(myCaseList[0].Id);
        System.assertEquals('OK', result1, 'result != OK');


        Test.stopTest();
        
    }

    @IsTest
    static void handlePassiveCancellation(){

        Case currentCase = [SELECT Id, Phase__c, Cluster__c, Type, RecordTypeId FROM Case WITH SECURITY_ENFORCED LIMIT 1];
        currentCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AllineamentoAnagrafica').getRecordTypeId();
        update currentCase;

        Test.startTest();

        HDT_UTL_HerokuPostSalesManager hpsm = new HDT_UTL_HerokuPostSalesManager();
        hpsm.handlePassiveCancellation(currentCase, 'Case', 'N', '');

        Test.stopTest();

        Case updatedCase = [SELECT Id, Phase__c FROM Case WHERE Id =: currentCase.Id LIMIT 1];
        System.assertEquals('Annullato SII', updatedCase.Phase__c, 'Phase__c != Annullato SII');
        
    }

    @IsTest
    static void handlePassiveCancellationSecondCase(){

        Case currentCase = [SELECT Id, Phase__c, Cluster__c FROM Case WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();

        HDT_UTL_HerokuPostSalesManager hpsm = new HDT_UTL_HerokuPostSalesManager();
        hpsm.handlePassiveCancellation(currentCase, 'Case', '', 'Eseguire Gestione Manuale SAP');

        Test.stopTest();

        wrts_prcgvr__Activity__c newActivity = [SELECT Id FROM wrts_prcgvr__Activity__c WHERE Case__c =: currentCase.Id LIMIT 1];
        System.assertNotEquals(null, newActivity, 'newActivity == null');
        
    }
    
    @isTest
    static void handleRichPassResponseFieldTst()
    {
        Case testCase = [SELECT AccountId, ContactId, ServicePoint__c, Contract__c, Order__c, CaseNumber, Phase__c, Type FROM Case LIMIT 1];
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, testCase.AccountId, testCase.ContactId, testCase.ServicePoint__c, testCase.Contract__c, testCase.Order__c);
        testCase.ParentId = caseList[0].Id;
        update testCase;
        testCase = [SELECT Parent.CaseNumber, CaseNumber, Phase__c, Type FROM Case WHERE Id = : testCase.Id LIMIT 1];
        List<HDT_WRP_MrrResponse.HDT_WRP_Field> responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        Test.startTest();
        responseFieldList = herokuSrv.handleRichPassResponseField(testCase);
        Test.stopTest();
        System.Assert(responseFieldList != null, 'responseFieldList == null');
    }
    @isTest
    static void handleNotifEsResponseFieldTst()
    {
        Case testCase = [SELECT CaseNumber, Phase__c, Type,HerokuPracticeCode__c FROM Case LIMIT 1];
        List<HDT_WRP_MrrResponse.HDT_WRP_Field> responseFieldList = new List<HDT_WRP_MrrResponse.HDT_WRP_Field>();
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        Test.startTest();
        responseFieldList = herokuSrv.handleNotifEsResponseField(testCase);
        Test.stopTest();
        System.Assert(responseFieldList != null, 'responseFieldList == null');
    }

    public class HDT_WS_PostSalesTstMock2 implements HTTPCalloutMock{

        Map<String,Map<String,String>> responseMap;

        public HDT_WS_PostSalesTstMock2(Map<String,Map<String,String>> rM){
            responseMap = rM;
        }
        public HTTPResponse respond(HTTPRequest request) {

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;
            String endpoint = request.getEndpoint();

            System.debug(endpoint);
            for(String key : responseMap.keySet())
            {
                if(key.equalsIgnoreCase(endpoint))
                {
                    if(key.equalsIgnoreCase('Callout:Prova'))
                    {
                        System.debug(responseMap.get(key).get('body'));
                        String recordId = '';
                        String body = request.getBody();
                        String substring = body.substring(body.indexOf('RECORD_ID'));
                        String valueSub = substring.substring(substring.indexOf('"value":'));
                        List<String> split = valueSub.split('}');
                        split = split[0].split(':');
                        recordId = split[1];
                        bodyResponse = responseMap.get(key).get('body');
                        bodyResponse = bodyResponse.replace('xxxxx', recordId);

                        statusCode = Integer.valueOf(responseMap.get(key).get('statuscode'));
                    }
                    else 
                    {
                        bodyResponse = responseMap.get(endpoint).get('body');
                        statusCode = Integer.valueOf(responseMap.get(key).get('statuscode'));
                    }
                }
            }

            System.debug('BODY RESPONSE: ' + bodyResponse);
            System.debug('STATUS CODE RESPONSE: ' + statusCode);

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response; 
        }

    }

    //INIZIO Test Costruttori classe HDT_WRP_HerokuPostSalesManager
    @IsTest
    static void testFirstConstructorHerokuPostSalesManager(){
        
        Test.startTest();
        HDT_WRP_HerokuPostSalesManager wrapper = new HDT_WRP_HerokuPostSalesManager('test', 'result','errorMessage', 'refReq', 'communicationChannel', 'reqId', 'herokuCode', 'dlCode');

        System.assertEquals('test', wrapper.responseMap.get('requestType'), 'requestType != test');

        Test.stopTest();
        
    }

    @IsTest
    static void testSecondConstructorHerokuPostSalesManager(){
        
        Test.startTest();

        HDT_WRP_HerokuPostSalesManager wrapper = new HDT_WRP_HerokuPostSalesManager('flowTest', 'phase','idTest', 'herokuCode', 'dlCode', 'codiceContrattoTest', 'contractStatus');

        System.assertEquals('idTest', wrapper.requestMap.get('recordId'), 'recordId != idTest');

        Test.stopTest();
        
    }

    //FINE Test Costruttori classe HDT_WRP_HerokuPostSalesManager
    @isTest
    static void executeTstRimborso()
    {
        HDT_SRV_HerokuPostSalesManager herokuSrv = new HDT_SRV_HerokuPostSalesManager();
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse response = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Case testCase = [SELECT Id, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case WHERE Type = 'Rimborso' LIMIT 1];

        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock());
        Test.startTest();
        //response = (wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse) herokuSrv.execute(args);
        testCase.Phase__c = 'Da Inviare';
        update testCase;
        Test.stopTest();
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        System.assertEquals('00002349', testCaseUpd.HerokuPracticeCode__c, 'HerokuPracticeCode__c != 00002349');
        
    }

    @isTest
    static void handleMrrFieldsTestAfundi()
    {
        Case testCase = [SELECT Id, RateCategory__c, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(genericResponseMap));

        Test.startTest();

        testCase.Phase__c = 'Da Inviare';
        testCase.Type = 'Modifica Unita Immobiliari Componenti';
        testCase.RateCategory__c = 'AITBNDOME0';
        update testCase;
        
        Test.stopTest();

        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        
    }

    @isTest
    static void handleMrrFieldsTestAfunda()
    {
        Case testCase = [SELECT Id, RateCategory__c, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(genericResponseMap));

        Test.startTest();

        testCase.Phase__c = 'Da Inviare';
        testCase.Type = 'Modifica Unita Immobiliari Componenti';
        testCase.RateCategory__c = 'ACAGRICO00';
        update testCase;

        Test.stopTest();

        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        
    }

    @isTest
    static void handleMrrFieldsTestAfundc()
    {
        Case testCase = [SELECT Id, RateCategory__c, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(genericResponseMap));

        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        testCase.Type = 'Modifica Unita Immobiliari Componenti';
        testCase.RateCategory__c = 'ACARTCOMM0';
        update testCase;
        Test.stopTest();

        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        
    }

    @isTest
    static void handleMrrFieldsTestAfundz()
    {
        Case testCase = [SELECT Id, RateCategory__c, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(genericResponseMap));

        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        testCase.Type = 'Modifica Unita Immobiliari Componenti';
        testCase.RateCategory__c = 'ACAGRIZOO0';
        update testCase;
        Test.stopTest();

        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        
    }

    @isTest
    static void handleMrrFieldsTestAfund()
    {
        Case testCase = [SELECT Id, RateCategory__c, CaseNumber,RecordTypeId, Type, Phase__c, Status FROM Case LIMIT 1];

        //Mock
        wrts_prcgvr.MRR_1_0.setMock(HttpCalloutMock.class, new HDT_WS_PostSalesTstMock2(genericResponseMap));

        Test.startTest();
        testCase.Phase__c = 'Da Inviare';
        testCase.Type = 'Modifica Unita Immobiliari Componenti';
        testCase.RateCategory__c = 'ACAUGENER0';
        update testCase;
        Test.stopTest();

        //Assertions
        Case testCaseUpd = [SELECT Id,HerokuPracticeCode__c,CaseNumber, Type, Phase__c, TecnicalPhase__c, Status FROM Case WHERE Id =: testCase.Id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku OK', testCaseUpd.TecnicalPhase__c, 'TecnicalPhase__c != Comunicazione verso Heroku OK');
        
    }
    
}