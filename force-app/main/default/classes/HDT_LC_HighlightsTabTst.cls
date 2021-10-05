@isTest
public class HDT_LC_HighlightsTabTst {
    
    
    private static void mySetup(){
        
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
        caseList[0].Cluster__c  = 'Autolettura';
    
        insert caseList;
        
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = 'HDT_RT_Autolettura';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP simulato', 'Inviata a SAP', rtId, rtName,'A','','','');

    }

    @IsTest
    static void testGetKpis(){
        
        //SETUP
        mySetup();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Case cs = [SELECT Id, Status, Cluster__c, Reason__c, Phase__c FROM Case LIMIT 1];

        System.debug('Case Infomation: ');
        System.debug('Case Status: ' + cs.Status);
        System.debug('Case Cluster__c: ' + cs.Cluster__c);
        System.debug('Case Reason__c: ' + cs.Reason__c);
        System.debug('Case Phase__c: ' + cs.Phase__c);
        
        //TESTING
        Test.startTest();
        Map<String,Object> kpis = HDT_LC_HighlightsTab.getKpis(acc.Id);

        System.assert(kpis != null, 'Map == null');
        System.assertEquals(1, kpis.get('opportunities'), 'opportunities < 1');
        System.assertEquals(1, kpis.get('dossier_open'), 'dossier_open < 1');
        System.assertEquals(0, kpis.get('dossier_ko'), 'dossier_ko > 0');

        Test.stopTest();
        
    }

}