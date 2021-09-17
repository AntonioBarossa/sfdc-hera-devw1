@isTest
public class HDT_SRV_CreateGenericCaseTst {
    
    @testSetup
    static void setup() {

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCaseDocumentale(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);

    }

    @isTest
    static void testCreateCaseInvocable(){

        Case cs = [SELECT Id FROM Case LIMIT 1];

        List<HDT_SRV_CreateGenericCase.HDT_UTL_FlowInputs> inputsList = new List<HDT_SRV_CreateGenericCase.HDT_UTL_FlowInputs>();
        HDT_SRV_CreateGenericCase.HDT_UTL_FlowInputs inputs = new HDT_SRV_CreateGenericCase.HDT_UTL_FlowInputs();
        inputs.caseCluster = 'Morosità';
        inputs.caseType = 'Riattivazione Fornitura';
        inputs.recordTypeDevName = 'HDT_RT_Morosita';
        inputs.inputSobj = cs;

        inputsList.add(inputs);

        Test.startTest();

        List<String> resultList = HDT_SRV_CreateGenericCase.createCaseInvocable(inputsList);

        System.assert(resultList.size() > 0, 'resultList.size() == 0 or resultList == null');

        Test.stopTest();

    }

}
