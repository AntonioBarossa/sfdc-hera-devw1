@isTest
public class HDT_SRV_PostSalesCriteriaManagerTst {

    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].id, 'Bozza');
        ordList[0].ServicePoint__c = servPointList[0].Id;
        insert ordList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        caseList[0].QuotationValidityDate__c = Date.today()-5;
        caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_VariazioniEle').getRecordTypeId();
        caseList[0].Contract__c  = contractList[0].Id;

        insert caseList;

    }

    @IsTest
    static void testEvaluateDistributoriManagement(){

        Case currentCase = [SELECT Id, PhaseStory__c FROM Case LIMIT 1];
        
        Test.startTest();

        currentCase.PhaseStory__c = 'Test';
        update currentCase;

        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        Boolean result = psc.evaluate(setArgs('distributorManagement', currentCase));

        System.assertEquals(true, result, 'result = false');

        Test.stopTest();
        
    }

    @IsTest
    static void testEvaluateSecondAdmissibility(){

        Case currentCase = [SELECT Id, PhaseStory__c FROM Case LIMIT 1];
        
        Test.startTest();

        currentCase.PhaseStory__c = 'Test';
        update currentCase;

        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        Boolean result = psc.evaluate(setArgs('secondAdmissibility', currentCase));

        System.assertEquals(true, result, 'result = false');

        Test.stopTest();
        
    }

    @IsTest
    static void testEvaluateNotExecWorks(){

        Case currentCase = [SELECT Id, PhaseStory__c FROM Case LIMIT 1];
        
        Test.startTest();

        currentCase.PhaseStory__c = 'Test';
        update currentCase;

        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        Boolean result = psc.evaluate(setArgs('notExecWorks', currentCase));

        System.assertEquals(true, result, 'result = false');

        Test.stopTest();
        
    }

    @isTest
    static void isRapidoToAnaliticoTest()
    {
        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        List<Order> orderList = [Select Id FROM Order];
        Test.startTest();
            Boolean result = psc.evaluate(setArgs('isRapidoToAnalitico', orderList[0]));
        Test.stopTest();
        System.assertEquals(false, result, 'IsRapidoToAnalitico fallito');
    }
    @isTest
    static void totalResidueNotNullTest()
    {
        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        List<Case> caseList = [SELECT Id, TotalResidue__c FROM Case];
        Test.startTest();
            Boolean result = psc.evaluate(setArgs('totalResidueNotNull', caseList[0]));
        Test.stopTest();
        System.assertEquals(false, result, 'totalResidueNotNull fallito');
    }
    @isTest
    static void totalResidueNullTest()
    {
        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        List<Case> caseList = [SELECT Id, TotalResidue__c FROM Case];
        Test.startTest();
            Boolean result = psc.evaluate(setArgs('totalResidueNull', caseList[0]));
        Test.stopTest();
        System.assertEquals(true, result, 'totalResidueNull fallito');
    }



    public static Map<String, Object> setArgs (String method, SObject record) {
        
        SObject transition;
        SObject action;
        String methodUsed = method;
        Map<String, Object> args = new Map<String,Object>();
        args.put('transition', transition);
        args.put('action', action);
        args.put('method',methodUsed);
        args.put('record', record);

        return args;
    }
    @isTest
    static void areActivityOpenTest()
    {
        HDT_SRV_PostSalesCriteriaManager psc = new HDT_SRV_PostSalesCriteriaManager();
        List<Order> orderList = [Select Id FROM Order];
        Test.startTest();
            Boolean result = psc.evaluate(setArgs('areActivityOpen', orderList[0]));
        Test.stopTest();
        System.assertEquals(true, result, 'areActivityOpen riuscito');
    } 
}
