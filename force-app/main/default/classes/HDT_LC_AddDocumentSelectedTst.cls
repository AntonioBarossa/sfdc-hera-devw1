@isTest
public class HDT_LC_AddDocumentSelectedTst {
    
    @TestSetup
    static void setup(){
        
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

        HDT_UTL_DataFactoryTst.pClickCasePhase();

        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName = constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_DOCUMENTALECOPIACONTRATTO;
        String rtId = constantsUtl.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Documentazione', 'Bozza', rtId, rtName,'A','','','');

        List<DocumentSelected__c> documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
    }

    @isTest
    static void testInsertDocuments(){

        List<String> documents = new List<String>();
        documents.add('0000411709364963'); //000041170936496 + 3

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        Case cas = [SELECT Id FROM Case WHERE AccountId =: account.Id WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();

        HDT_LC_AddDocumentSelected.insertDocuments(documents, cas.Id);

        DocumentSelected__c document = [SELECT Id FROM DocumentSelected__c WHERE Name = '0000411709364963' WITH SECURITY_ENFORCED LIMIT 1];

        System.assert(document != null, 'Si è verificato un errore in fase di inserimento del documento');

        Test.stopTest();

    }

    @isTest
    static void testCheckExistingDocuments(){

        List<String> documents = new List<String>();

        Account account = [
            SELECT Id, CustomerCode__c
            FROM Account
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Case cas = [SELECT Id FROM Case WHERE AccountId =: account.Id WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();

        List<string> documentsRetrieved = HDT_LC_AddDocumentSelected.checkExistingDocuments(documents, cas.Id);

        System.assert(documentsRetrieved.size() != 0, 'Si è verificato un errore in fase di retrieve dei documenti esistenti');

        Test.stopTest();

    }

}
