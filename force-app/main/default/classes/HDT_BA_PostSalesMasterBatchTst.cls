/*
    @Author:        Francesco Vitiello
    CreatedDate:    12/11/2021
    Reason: Ottimizzazione a seguito di gestione Case Phase "In Bozza", Case Type "Blocco Sollecito/Interessi" e Knowledge Article
*/
@isTest
public class HDT_BA_PostSalesMasterBatchTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        String rtName = 'HDT_RT_VerificheGas';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VerificheGas').getRecordTypeId();
        String rtNamePianoRat = 'HDT_RT_PianoRateizzazione';
        String rtIdPianRat = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        String rtNameAutolettura = 'HDT_RT_Autolettura';
        String rtIdAutolettura = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNameAutolettura).getRecordTypeId();
        String rtNamePostSales = 'HDT_RT_Domiciliazione';
        String rtIdPostSales = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNamePostSales).getRecordTypeId();
        String rtNameVolturaTecnica = 'HDT_RT_VolturaTecnica';
        String rtIdVolturaTecnica = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaTecnica').getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Attesa conferma preventivo cliente', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo scaduto', 'Attesa conferma preventivo cliente', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Pratica In Attesa', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtIdPostSales, rtNamePostSales,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Bozza Annullata', 'Bozza', rtIdAutolettura, rtNameAutolettura,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Data Decorrenza','Bozza', rtIdVolturaTecnica, rtNameVolturaTecnica, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'In attesa Data Decorrenza', rtIdVolturaTecnica, rtNameVolturaTecnica, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Data Decorrenza', 'Da Inviare', rtIdVolturaTecnica, rtNameVolturaTecnica, 'A','','','');


        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, 'Bozza');
        ordList[0].EffectiveDate__c = Date.today()-5;
        ordList[1].EffectiveDate__c = Date.today().addMonths(1);
        insert ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(8, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        
        Datetime oneDayAgo = Datetime.now().addDays(-5);
        Test.setCreatedDate(caseList[3].Id, oneDayAgo);

        Datetime oneMonthAgo = Datetime.now().addDays(-40);
        Test.setCreatedDate(caseList[4].Id, oneMonthAgo);

        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].Phase__c = 'Attesa conferma preventivo cliente';
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].Cluster__c = 'Verifiche';
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VerificheGas').getRecordTypeId();
        
        caseList[1].BillingProfile__c = billingProfileList[0].Id;
        caseList[1].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[1].Type = 'Piano Rateizzazione';
        caseList[1].Phase__c = 'Pratica In Attesa';
        caseList[1].SuspensionDate__c = Date.today()-10;
        caseList[1].SuspensionDays__c = 5;
        caseList[1].DepositPaymentMode__c = 'Bonifico';

        caseList[2].BillingProfile__c = billingProfileList[0].Id;
        caseList[2].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[2].Type = 'Contratto Non Richiesto';
        caseList[2].Phase__c = 'Pratica In Attesa';
        caseList[2].Order__c = ordList[0].Id;

        caseList[3].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        caseList[3].Cluster__c = 'Autolettura';        

        caseList[4].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Domiciliazione').getRecordTypeId();
        caseList[4].Cluster__c = 'Pagamenti';

        caseList[5].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaTecnica').getRecordTypeId();
        caseList[5].Type = 'Voltura Tecnica';
        caseList[5].Phase__c = 'In attesa Data Decorrenza';
        caseList[5].Subject = 'Test no ricalcolo';
        caseList[5].EffectiveDate__c = Date.today();
        caseList[5].SuspensionDate__c = Date.today()-10;


        caseList[6].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_FatturazioneConsumi').getRecordTypeId();
        caseList[6].Type = 'Ricostruzione Consumi';
        caseList[6].Phase__c = 'Bozza';
        caseList[6].Reason__c = 'Ricalcolo consumi';
        caseList[6].BillingProfile__c = billingProfileList[0].Id;
        caseList[6].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AltriProcessiPagamenti').getRecordTypeId();
        caseList[6].Type = 'Blocco Sollecito/Interessi';
        caseList[6].Phase__c = 'Pratica In Attesa';
        caseList[6].SuspensionDate__c = Date.today()-10;
        caseList[6].SuspensionDays__c = 5;
        caseList[6].DepositPaymentMode__c = 'Bonifico';

        caseList[7].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaTecnica').getRecordTypeId();
        caseList[7].Type = 'Voltura Tecnica';
        caseList[7].Phase__c = 'In attesa Data Decorrenza';
        caseList[7].Subject = 'Test ricalcolo';
        caseList[7].SuspensionDate__c = Date.today()-10;
        caseList[7].EffectiveDate__c = Date.today();
        caseList[7].Order__c = ordList[1].Id;

        update caseList;        

        wrts_prcgvr__Activity__c actOne = new wrts_prcgvr__Activity__c();
        actOne.Case__c = caseList[6].Id;
        actOne.Type__c = 'In attesa risposta cliente';
        Datetime activityDatetime = Datetime.newInstance(2021, 10, 10);
        insert actOne;
        actOne.ActivityStartTime__c = activityDatetime;
        update actOne;

        wrts_prcgvr__ActivityTemplate__c elabTemplate = new wrts_prcgvr__ActivityTemplate__c();
        elabTemplate.Name = 'Elaborazione Manuale';
        elabTemplate.wrts_prcgvr__Subject__c = 'Elaborazione Manuale';
        insert elabTemplate;

        Knowledge__kav kArt = new Knowledge__kav();
        kArt.Title = 'Test Original Title';
        kArt.urlName = 'original';
        kArt.ExpirationDate__c = Date.today()-5;
        insert kArt;
    

        CS_DaysToExpiration__c autoletturaCustomSetting = new CS_DaysToExpiration__c();
        autoletturaCustomSetting.Name = 'Autolettura';
        autoletturaCustomSetting.Type__c = 'Autolettura';
        autoletturaCustomSetting.NumberOfDays__c = '1';
        insert autoletturaCustomSetting;

        CS_DaysToExpiration__c postSalesCustomSetting = new CS_DaysToExpiration__c();
        postSalesCustomSetting.Name = 'PostSales';
        postSalesCustomSetting.Type__c = 'PostSales';
        postSalesCustomSetting.NumberOfDays__c = '30';
        insert postSalesCustomSetting;

    }

    @IsTest
    static void testBatchExecution(){

        Case myCase1 = [SELECT Id, Phase__c FROM Case WHERE Type <> 'Piano Rateizzazione' LIMIT 1];
        Case myCase2 = [SELECT Id, Phase__c, SuspensionEndDate__c, Type  FROM Case WHERE Type = 'Piano Rateizzazione'LIMIT 1];
        Case myCase3 = [SELECT Id, Phase__c, Type  FROM Case WHERE Type = 'Contratto Non Richiesto' LIMIT 1];
        Case myCase4 = [SELECT Id, Phase__c, Cluster__c FROM Case WHERE Phase__c = 'Bozza' and Cluster__c = 'Autolettura' LIMIT 1];
        Case myCase5 = [SELECT Id, Phase__c, Cluster__c FROM Case WHERE Phase__c = 'Bozza' and Cluster__c = 'Pagamenti' LIMIT 1];
        Case myCase6 = [SELECT Id, Phase__c, Type  FROM Case WHERE Type = 'Voltura Tecnica' AND Subject = 'Test no ricalcolo' LIMIT 1];
		Case myCase7 = [SELECT Id, Type FROM Case WHERE Type = 'Ricostruzione Consumi'];
        Case myCase8 = [SELECT Id, Phase__c, Type, EffectiveDate__c  FROM Case WHERE Type = 'Voltura Tecnica' AND Subject = 'Test ricalcolo' LIMIT 1];

        Knowledge__kav kArt = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav LIMIT 1];
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=uniqueUserName);
        u.UserPermissionsKnowledgeUser = true;
		insert u;

        HDT_UTL_DataFactoryTst.assignPermissionSet(u, 'HDT_UtentiPubblicatoriKnowledge', true);

        System.runAs(u){
            
            Test.setMock(HttpCalloutMock.class, new HDT_BA_PostSalesMasterBatchTstMock());

            KbManagement.PublishingService.publishArticle(kArt.KnowledgeArticleId, true);
    
            Test.startTest();

            HDT_BA_PostSalesMasterBatch psm = new HDT_BA_PostSalesMasterBatch();        

            Database.executeBatch(psm);

            Test.stopTest();

        }

        Case updatedCase1 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase1.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'UpdatedCase1: ' + updatedCase1.Phase__c);
        System.assertEquals('Preventivo scaduto', updatedCase1.Phase__c, 'Phase != Preventivo scaduto');
        // System.assertNotEquals('Preventivo scaduto', updatedCase1.Phase__c, 'Phase != Preventivo scaduto');

        Case updatedCase2 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase2.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase2: ' + updatedCase2.Phase__c);
        System.assertEquals('Da Inviare', updatedCase2.Phase__c, 'Phase != Da Inviare');
        // System.assertNotEquals('Da Inviare', updatedCase2.Phase__c, 'Phase != Da Inviare');

        Case updatedCase3 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase3.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase3: ' + updatedCase3.Phase__c);
        System.assertEquals('Da Inviare', updatedCase3.Phase__c, 'Phase != Da Inviare');
        // System.assertNotEquals('Da Inviare', updatedCase3.Phase__c, 'Phase != Da Inviare');

        Case updatedCase4 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase4.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase4: ' + updatedCase4.Phase__c);
        // System.assertEquals('Bozza Annullata', updatedCase4.Phase__c, 'Phase != Bozza Annullata');

        Case updatedCase5 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase5.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase5: ' + updatedCase5.Phase__c);
        // System.assertEquals('Bozza Annullata', updatedCase5.Phase__c, 'Phase != Bozza Annullata');

        Case updatedCase6 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase6.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase6: ' + updatedCase6.Phase__c);
        System.assertEquals('Da Inviare', updatedCase6.Phase__c, 'Phase != Da Inviare');
        // System.assertNotEquals('Da Inviare', updatedCase6.Phase__c, 'Phase != Da Inviare');

        Case updatedCase7 = [SELECT Id, Phase__c FROM Case WHERE Id =: myCase7.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase7: ' + updatedCase7.Phase__c);


        Case updatedCase8 = [SELECT Id, Phase__c, EffectiveDate__c FROM Case WHERE Id =: myCase8.Id LIMIT 1];
        
        System.assertEquals(true, updatedCase8.EffectiveDate__c > myCase8.EffectiveDate__c , 'Data decorrenza non ricalcolata');
        System.assertEquals('In attesa Data Decorrenza', updatedCase8.Phase__c , 'Phase != In attesa Data Decorrenza');

        Knowledge__kav myArticle = [Select Id, PublishStatus from Knowledge__kav where Id =: kArt.Id];
        // System.assertEquals('Archived', myArticle.PublishStatus, 'PublishStatus != Archived');

    }

    public class HDT_BA_PostSalesMasterBatchTstMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"rdsRdo":"rds","tipoAttivita":"Pratica avviata","note":"nota","numeroBollettino":"98","importoTotale":"10.00","esito":"OK"}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }

}