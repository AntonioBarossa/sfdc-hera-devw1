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
        String rtIdVolturaTecnica = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNameVolturaTecnica).getRecordTypeId();
        String rtNameBloccoSollecitoInteressi = 'HDT_RT_AltriProcessiPagamenti';
        String rtIdBloccoSollecitoInteressi = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNameBloccoSollecitoInteressi).getRecordTypeId();
        String rtNamePrev = 'HDT_RT_PreventiviEle';
        String rtIdPrev = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtNamePrev).getRecordTypeId();
        String rtNameVar = 'HDT_RT_VariazioniTari';
        String rtIdVar = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniTari').getRecordTypeId();
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Attesa conferma preventivo cliente', 'Bozza', rtIdPrev, rtNamePrev,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo scaduto','Attesa conferma preventivo cliente', rtIdPrev, rtNamePrev,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Attesa conferma preventivo cliente', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Ammissibilità OK', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo scaduto', 'Attesa conferma preventivo cliente', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo scaduto', 'Ammissibilità OK', rtId, rtName,'A','','','');
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

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Pratica In Attesa', 'Bozza', rtIdBloccoSollecitoInteressi, rtNameBloccoSollecitoInteressi, 'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In Lavorazione', 'Bozza', rtIdVar, rtNameVar, 'A','','','');

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(2, false, accList[0].id, 'Bozza');
        ordList[0].EffectiveDate__c = Date.today()-5;
        ordList[1].EffectiveDate__c = Date.today().addMonths(1);
        insert ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(2, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(2, true, accList[0].id);        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(14, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

        Datetime oneDayAgo = Datetime.now().addDays(-5);
        Test.setCreatedDate(caseList[3].Id, oneDayAgo);

        Datetime oneMonthAgo = Datetime.now().addDays(-40);
        Test.setCreatedDate(caseList[4].Id, oneMonthAgo);
        Test.setCreatedDate(caseList[10].Id, oneMonthAgo);
        Test.setCreatedDate(caseList[12].Id, oneMonthAgo);
        Test.setCreatedDate(caseList[13].Id, oneMonthAgo);

        servPointList[1].SupplyCity__c = 'SupplyCity__c';
        servPointList[1].SupplyStreetName__c = 'SupplyStreetName__c';
        servPointList[1].CommoditySector__c = 'Ambiente';

        update servPointList;

        contractList[1].ServicePoint__c = servPointList[1].id;
        contractList[1].Status = 'Attivo';

        update contractList;

        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].Phase__c = 'Attesa conferma preventivo cliente';
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].Cluster__c = 'Verifiche';
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PreventiviEle').getRecordTypeId();
        caseList[0].PhaseStory__c = 'Bozza@@Attesa';
        
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
        caseList[6].Commodity__c = 'Acqua';
        caseList[6].BillingProfile__c = billingProfileList[0].Id;

        caseList[7].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_AltriProcessiPagamenti').getRecordTypeId();
        caseList[7].Type = 'Blocco Sollecito/Interessi';
        caseList[7].Phase__c = 'Pratica In Attesa';
        caseList[7].SuspensionDate__c = Date.today()-10;
        caseList[7].SuspensionDays__c = 5;
        caseList[7].DepositPaymentMode__c = 'Bonifico';

        caseList[8].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaTecnica').getRecordTypeId();
        caseList[8].Type = 'Voltura Tecnica';
        caseList[8].Phase__c = 'In attesa Data Decorrenza';
        caseList[8].Subject = 'Test ricalcolo';
        caseList[8].SuspensionDate__c = Date.today()-10;
        caseList[8].EffectiveDate__c = Date.today();
        caseList[8].Order__c = ordList[1].Id;

        caseList[9].BillingProfile__c = billingProfileList[0].Id;
        caseList[9].Phase__c = 'Ammissibilità OK';
        caseList[9].QuotationValidityDate__c = Date.today()-5;
        caseList[9].QuotationType__c = 'Predeterminabile';
        caseList[9].Cluster__c = 'Verifiche';
        caseList[9].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VerificheGas').getRecordTypeId();
        caseList[9].PhaseStory__c = 'Bozza@@Attesa';

        caseList[10].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[10].Type = 'Piano Rateizzazione';
        caseList[10].Phase__c = 'Bozza';
        caseList[10].Commodity__c = 'Ambiente';
        caseList[10].MandatoryAttachments__c = 'Test';

        caseList[11].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniTari').getRecordTypeId();
        caseList[11].Type = 'Modifica post accertamento';
        caseList[11].Phase__c = 'In Lavorazione';
        caseList[11].SupplyCity__c = 'SupplyCity__c';
        caseList[11].SupplyStreetName__c = 'SupplyStreetName__c';
        caseList[11].Contract__c = null;
        caseList[11].ServicePoint__c = null;

        caseList[12].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[12].Phase__c = 'Bozza';
        caseList[12].Commodity__c = 'Acqua';
        caseList[12].Type = 'Piano Rateizzazione';

        caseList[13].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[13].Type = 'Piano Rateizzazione';
        caseList[13].Phase__c = 'Bozza';
        caseList[13].Commodity__c = 'Ambiente';
        caseList[13].MandatoryAttachments__c = 'Test_1';

        update caseList; 
        
        List<ContentVersion> contentVersion = HDT_UTL_DataFactoryTst.createContentVers(1, false);
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersion[0].Id];

        list<ContentDocumentLink> listDocumentLink = HDT_UTL_DataFactoryTst.createContentDocumentLink(1, false, caseList[13].Id, documents[0].Id);
        insert listDocumentLink;

        wrts_prcgvr__Activity__c actOne = new wrts_prcgvr__Activity__c();
        actOne.Case__c = caseList[6].Id;
        actOne.Type__c = 'In attesa risposta cliente';
        actOne.wrts_prcgvr__Status__c = 'Aperta';
  
        Datetime activityDatetime = Datetime.newInstance(2021, 10, 10);
        insert actOne;
        actOne.ActivityStartTime__c = activityDatetime;
        update actOne;

        List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = new List<wrts_prcgvr__ActivityTemplate__c>();

        wrts_prcgvr__ActivityTemplate__c elabTemplate = new wrts_prcgvr__ActivityTemplate__c();
        elabTemplate.Name = 'Elaborazione Manuale';
        elabTemplate.wrts_prcgvr__Subject__c = 'Elaborazione Manuale';
        activityTemplates.add(elabTemplate);

        wrts_prcgvr__ActivityTemplate__c varTemplate = new wrts_prcgvr__ActivityTemplate__c();
        varTemplate.Name = 'CBS_VAR005__GESTIONE_MANUALE';
        varTemplate.wrts_prcgvr__Code__c = '0aa1d286-4c0b-4678-8d44-faa6c4bd5d09';
        varTemplate.wrts_prcgvr__Subject__c = 'CBS_VAR005__GESTIONE_MANUALE';
        varTemplate.wrts_prcgvr__ObjectType__c = 'Case';
        activityTemplates.add(varTemplate);

        insert activityTemplates;

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

        CS_DaysToExpiration__c postPianoRatCustomSetting = new CS_DaysToExpiration__c();
        postPianoRatCustomSetting.Name = 'PianoRateizzazioneTari';
        postPianoRatCustomSetting.Type__c = 'PianoRateizzazioneTari';
        postPianoRatCustomSetting.NumberOfDays__c = '90';
        insert postPianoRatCustomSetting;

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
        Case myCase9 = [SELECT Id, Phase__c FROM Case WHERE QuotationType__c = 'Predeterminabile' LIMIT 1];
        Case myCase10 = [SELECT Id, Type, Phase__c, RecordType.DeveloperName, CreatedDate FROM Case WHERE Phase__c = 'Bozza' AND Type = 'Piano Rateizzazione' AND Commodity__c = 'Ambiente' AND RecordType.DeveloperName = 'HDT_RT_PianoRateizzazione' AND MandatoryAttachments__c = 'Test' LIMIT 1];
        Case myCase11 = [SELECT Id, Type, Phase__c, RecordType.DeveloperName FROM Case WHERE Phase__c = 'In Lavorazione' AND Type = 'Modifica post accertamento' AND RecordType.DeveloperName = 'HDT_RT_VariazioniTari' LIMIT 1];
        Case myCase12 = [SELECT Id, Type, Phase__c, RecordType.DeveloperName, CreatedDate FROM Case WHERE Phase__c = 'Bozza' AND Type = 'Piano Rateizzazione' AND Commodity__c <> 'Ambiente' AND RecordType.DeveloperName = 'HDT_RT_PianoRateizzazione' LIMIT 1];
        Case myCase13 = [SELECT Id, Type, Phase__c, RecordType.DeveloperName, CreatedDate FROM Case WHERE Phase__c = 'Bozza' AND Type = 'Piano Rateizzazione' AND Commodity__c = 'Ambiente' AND RecordType.DeveloperName = 'HDT_RT_PianoRateizzazione' AND MandatoryAttachments__c = 'Test_1' LIMIT 1];
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

        Case updateCase9 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase9.Id LIMIT 1];
        System.assertEquals('Preventivo scaduto', updateCase9.Phase__c, 'Preventivo non scaduto');

        Case updateCase10 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase10.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase10: ' + updateCase10.Phase__c);
        System.assertEquals('Bozza Annullata', updateCase10.Phase__c, 'Aggiornamento Non Effettuato');

        Case updateCase11 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase11.Id LIMIT 1];
        list<wrts_prcgvr__Activity__c> act = [SELECT Id, RecordTypeId, Case__c, Case__r.RecordType.DeveloperName, wrts_prcgvr__ActivityTemplate__r.Name, Case__r.AccountId, CreatedDate 
                                              FROM wrts_prcgvr__Activity__c 
                                              WHERE Case__c = :updateCase11.Id
                                              AND wrts_prcgvr__ActivityTemplate__r.Name = 'CBS_VAR005__GESTIONE_MANUALE'
                                              AND Type__c = 'Aprire Variazione'];
        System.debug(LoggingLevel.DEBUG, 'updatedCase11: ' + updateCase11.Phase__c);
        System.assertEquals(1, act.size(), 'Attenzione, la lista deve trovare una sola activity');

        Case updateCase12 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase12.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase12: ' + updateCase12.Phase__c);
        System.assertEquals('Bozza Annullata', updateCase12.Phase__c, 'Aggiornamento Non Effettuato');

        Case updateCase13 = [SELECT Id, Phase__c FROM Case WHERE Id = :myCase13.Id LIMIT 1];
        System.debug(LoggingLevel.DEBUG, 'updatedCase10: ' + updateCase13.Phase__c);
        System.assertEquals('Bozza', updateCase13.Phase__c, 'Aggiornamento Effettuato Erroneamente');

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