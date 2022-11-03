@isTest
public class HDT_SCH_PostSalesMasterBatchTst {
    
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
        HDT_UTL_DataFactoryTst.createDaysToExpiration(1, true,'30', 'PostSales');
        HDT_UTL_DataFactoryTst.createDaysToExpiration(1, true,'30', 'Autolettura');

    }

    @IsTest
    static void testScheduledPostSalesMasterBatch(){
        
        Test.startTest();

        String sch = '0 0 8 13 2 ?';

        String jobId = System.schedule('testBasicScheduledApex', sch, new HDT_SCH_PostSalesMasterBatch());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
		String year = String.valueOf(ct.NextFireTime).substring(0, 4);
        System.assertEquals(year+'-02-13 08:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }

}