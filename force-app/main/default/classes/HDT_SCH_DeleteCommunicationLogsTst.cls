@isTest
public class HDT_SCH_DeleteCommunicationLogsTst {
    
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        CS_DaysToExpiration__c daysExpirationVo = new CS_DaysToExpiration__c();
        daysExpirationVo.Name = 'DeleteCommunicationLogs';
        daysExpirationVo.Type__c = 'DeleteCommunicationLogs';
        daysExpirationVo.NumberOfDays__c = '-1';
        insert daysExpirationVo;
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].EffectiveDate__c = Date.today()-5;
        ordList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Voltura').getRecordTypeId();
        insert ordList;
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(4, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniAcqua').getRecordTypeId();
        String rtName = 'HDT_RT_VariazioniAcqua';
        caseList[0].Cluster__c = 'Variazioni';
        caseList[0].Type = 'Adesione Rinuncia Fondo Fughe';
        caseList[0].RecordTypeId  = recordTypeId;

        caseList[1].Cluster__c = 'Variazioni';
        caseList[1].Type = 'Adesione Rinuncia Fondo Fughe';
        caseList[1].RecordTypeId  = recordTypeId;

        caseList[2].Cluster__c = 'Variazioni';
        caseList[2].Type = 'Adesione Rinuncia Fondo Fughe';
        caseList[2].RecordTypeId  = recordTypeId;

        insert caseList;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', recordTypeId, rtName,'A','','','');
        Id orderRtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Voltura').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Completata', 'Bozza', orderRtId, 'HDT_RT_Voltura','A','','','');

        caseList[0].Phase__c = 'Completata';
        caseList[1].Phase__c = 'Completata';
        caseList[2].Phase__c = 'Completata';
        update caseList;
        
        ordList[0].Phase__c = 'Completata';
        update ordList;

    }

    @IsTest
    static void testScheduledDeleteCommunicationLogsTst(){
        
        Test.startTest();

        String cronExpr = '0 0 8 13 2 ?';
        
        HDT_SCH_DeleteCommunicationLogs deleteJob = new HDT_SCH_DeleteCommunicationLogs();
        String jobId = System.schedule('testBasicScheduledApex', cronExpr, deleteJob);
        deleteJob.execute(null);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(cronExpr, ct.CronExpression, 'Assertion CronExpression failed');

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered, 'Assertion TimesTriggered failed');

        // // Verify the next time the job will run
		// String year = String.valueOf(ct.NextFireTime).substring(0, 4);
        // System.assertEquals(year+'-02-13 08:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
        
    }
}