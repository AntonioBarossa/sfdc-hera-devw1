@isTest
public class HDT_BA_SelfReadingsTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        caseList[0].Phase__c  = 'Inviata a SAP';
        caseList[0].Type  = 'Autolettura da cliente';
    
        insert caseList;
        
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = 'HDT_RT_Autolettura';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP simulato', 'Inviata a SAP', rtId, rtName,'A','','','');

    }

    @IsTest
    static void testBatchExecution(){

        Case cs = [SELECT Id, Phase__c, LastModifiedDate, Type FROM Case LIMIT 1];

        System.debug('Start Case Phase: ' + cs.Phase__c);
        System.debug('Start Case Type: ' + cs.Type);
        System.debug('Start Case LastModifiedDate: ' + cs.LastModifiedDate);

        Test.startTest();

        HDT_BA_SelfReadings sr = new HDT_BA_SelfReadings();
        Id batchId = Database.executeBatch(sr);

        Test.stopTest();

        Case updatedCase = [SELECT Id, Phase__c FROM Case LIMIT 1];
        System.assertEquals('Esito KO da SAP simulato', updatedCase.Phase__c, 'Phase != Esito KO da SAP simulato');
        
    }

}
