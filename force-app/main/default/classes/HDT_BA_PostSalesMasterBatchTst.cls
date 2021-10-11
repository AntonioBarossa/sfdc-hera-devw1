@isTest
public class HDT_BA_PostSalesMasterBatchTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].EffectiveDate__c = Date.today()-5;
        insert ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(3, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].Cluster__c = 'Verifiche';
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VerificheGas').getRecordTypeId();
        
        caseList[1].BillingProfile__c = billingProfileList[0].Id;
        caseList[1].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[1].Type = 'Piano Rateizzazione';
        caseList[1].SuspensionDate__c = Date.today()-10;
        caseList[1].SuspensionDays__c = 5;
        caseList[1].DepositPaymentMode__c = 'Bonifico';

        caseList[2].BillingProfile__c = billingProfileList[0].Id;
        caseList[2].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        caseList[2].Type = 'Contratto Non Richiesto';
        caseList[2].Order__c = ordList[0].Id;
        insert caseList;
        
        
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = 'HDT_RT_VerificheGas';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VerificheGas').getRecordTypeId();
        String rtNamePianoRat = 'HDT_RT_PianoRateizzazione';
        String rtIdPianRat = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_PianoRateizzazione').getRecordTypeId();
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Attesa conferma preventivo cliente', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Preventivo scaduto', 'Attesa conferma preventivo cliente', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Pratica In Attesa', 'Bozza', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Pratica In Attesa', rtIdPianRat, rtNamePianoRat,'A','','','');

        Knowledge__kav kArt = new Knowledge__kav();
        kArt.Title = 'Test Original Title';
        kArt.urlName = 'original';
        kArt.ExpirationDate__c = Date.today()-5;
        insert kArt;

    }

    @IsTest
    static void testBatchExecution(){

        Case cs = [SELECT Id, Phase__c FROM Case WHERE Type <> 'Piano Rateizzazione' LIMIT 1];
        
        Test.startTest();

        cs.Phase__c = 'Attesa conferma preventivo cliente';
        update cs;

        HDT_BA_PostSalesMasterBatch psm = new HDT_BA_PostSalesMasterBatch();
        // Id batchId = Database.executeBatch(psm);

        List<SObject> l = psm.start(null);
        System.assert(l.size() > 0, 'l.size() = 0 or l == null');

        psm.execute(null, l);

        Test.stopTest();

        Case updatedCase = [SELECT Id, Phase__c FROM Case WHERE Id =: cs.Id LIMIT 1];
        System.assertEquals('Preventivo scaduto', updatedCase.Phase__c, 'Phase != Preventivo scaduto');

        
    }

    @IsTest
    static void testBatchExecution2(){

        Case cs = [SELECT Id, Phase__c, SuspensionEndDate__c, Type  FROM Case WHERE Type = 'Piano Rateizzazione'LIMIT 1];

        cs.Phase__c = 'Pratica In Attesa';
        update cs;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HDT_BA_PostSalesMasterBatchTstMock());
        
        System.debug('DEBUG ===>');
        System.debug('DEBUG TIPO: ' + cs.Type);
        System.debug('DEBUG FASE: ' + cs.Phase__c);
        System.debug('DEBUG SUSP END DATE: ' + cs.SuspensionEndDate__c);

        HDT_BA_PostSalesMasterBatch psm = new HDT_BA_PostSalesMasterBatch();
        // Id batchId = Database.executeBatch(psm);

        List<SObject> l = psm.start(null);
        System.assert(l.size() > 0, 'l.size() = 0 or l == null');

        psm.execute(null, l);

        Test.stopTest();

    }

    @IsTest
    static void testBatchExecution3(){

        Case cs = [SELECT Id, Phase__c, Type  FROM Case WHERE Type = 'Contratto Non Richiesto' LIMIT 1];

        
        Test.startTest();

        cs.Phase__c = 'Pratica In Attesa';
        update cs;

        System.debug('DEBUG ===>');
        System.debug('DEBUG TIPO: ' + cs.Type);
        System.debug('DEBUG FASE: ' + cs.Phase__c);

        HDT_BA_PostSalesMasterBatch psm = new HDT_BA_PostSalesMasterBatch();

        // Id batchId = Database.executeBatch(psm);

        List<SObject> l = psm.start(null);
        System.assert(l.size() > 0, 'l.size() = 0 or l == null');

        psm.execute(null, l);
        
        Test.stopTest();

        Case updatedCase = [SELECT Id, Phase__c FROM Case WHERE Id =: cs.Id LIMIT 1];
        System.assertEquals('Da Inviare', updatedCase.Phase__c, 'Phase != Da Inviare');
        
    }

    public class HDT_BA_PostSalesMasterBatchTstMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":{"rdsRdo":"rds","tipoAttivita":"attivita","note":"nota","numeroBollettino":"98","importoTotale":"10.00","esito":"OK"}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }

}
