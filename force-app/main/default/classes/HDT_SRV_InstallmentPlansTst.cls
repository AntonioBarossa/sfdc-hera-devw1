@isTest
public with sharing class HDT_SRV_InstallmentPlansTst {
    
    @TestSetup
    static void setup()
    {
        HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        String rtName =  constantsUtl.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA;
        String rtId = constantsUtl.CASE_RECORDTYPEID_MOROSITA;
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(2, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        AccountContactRelation accountContactRel = HDT_UTL_DataFactoryTst.createAccountContactRelation(true, accList[1].Id,contactList[0].Id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        List<Contract> contractListTwo = HDT_UTL_DataFactoryTst.createContract(1, true, accList[1].id);
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, true, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        List<DocumentSelected__c> documents = HDT_UTL_DataFactoryTst.createDocumentSelected(1, true, false, (String) caseList[0].Id,billingProfileList[0].ContractAccountCode__c);
        List<RentProcessRule__c> ruleOne = HDT_UTL_DataFactoryTst.createRentProcessRule(1, true, true, true);
        List<RentProcessRule__c> ruleTwo = HDT_UTL_DataFactoryTst.createRentProcessRule(1, true, false, true);
        List<RentProcessRule__c> ruleThree = HDT_UTL_DataFactoryTst.createRentProcessRule(1, true, true, false);
        List<RentProcessRule__c> ruleFour = HDT_UTL_DataFactoryTst.createRentProcessRule(1, true, false, false);
    }

    @isTest
    static void predefaultInstallmentsValuesTst()
    {
        //1. Se dovesse essere necessario creare un case di Sospensione Fornitura
        //2. Mock per chiamata a vista rate
        //3. Valorizzare metodo di pagamento su BillingProfile
        //4. Creare document Selected nel Setup 
        //5. Valorizzare il campo del Customer Assisted su Account
        //6. Assert sugli ammontare
        Case testCase = [SELECT Id, TotalToPay__c FROM Case LIMIT 1];
        Account testAccount = [SELECT Id, CustomerCode__c FROM Account LIMIT 1];
        Test.startTest();
        List<HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs> inputs = new List<HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs>();
        HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs input = new HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs();
        input.recordId = testCase.Id;
        input.accountId = testAccount.Id;
        input.customerCode = testAccount.CustomerCode__c;
        input.totalToPay = testCase.TotalToPay__c;
        inputs.add(input);
        HDT_SRV_InstallmentPlans.predefaultInstallmentsValues(inputs);
        Test.stopTest();
        Case testCaseUpd = [SELECT Id, 
        SuspensionInThePastTwelveMonths__c,
        ExistingInstallmentsPlanNumber__c,
        CAWithOrWithoutSEPA__c,
        ExpirationDate__c,
        AmountToPayInInstallments__c,
        InstallmentAmount__c,
        Amount__c,
        CutomerAssisted__c
        FROM Case
        LIMIT 1];
        System.assertEquals(false, testCaseUpd.SuspensionInThePastTwelveMonths__c);
        System.Assert(testCaseUpd.ExpirationDate__c != null);
        System.Assert(testCaseUpd.AmountToPayInInstallments__c != null);
        System.Assert(testCaseUpd.InstallmentAmount__c != null);
        System.assertEquals(false, testCaseUpd.CutomerAssisted__c);
    }

    @isTest
    static void predefaultInstallmentsValuesTstWithFakeResp()
    {
        Case testCase = [SELECT Id, TotalToPay__c FROM Case LIMIT 1];
        Account testAccount = [SELECT Id, CustomerCode__c FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_InstallmentPlansTstMock());
        List<HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs> inputs = new List<HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs>();
        HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs input = new HDT_SRV_InstallmentPlans.HDT_UTL_FlowInputs();
        input.recordId = testCase.Id;
        input.accountId = testAccount.Id;
        input.customerCode = testAccount.CustomerCode__c;
        input.totalToPay = testCase.TotalToPay__c;
        inputs.add(input);
        HDT_SRV_InstallmentPlans.predefaultInstallmentsValues(inputs);
        Test.stopTest();
        Case testCaseUpd = [SELECT Id, 
        SuspensionInThePastTwelveMonths__c,
        ExistingInstallmentsPlanNumber__c,
        CAWithOrWithoutSEPA__c,
        ExpirationDate__c,
        AmountToPayInInstallments__c,
        InstallmentAmount__c,
        Amount__c,
        CutomerAssisted__c
        FROM Case
        LIMIT 1];
        System.assertEquals(false, testCaseUpd.SuspensionInThePastTwelveMonths__c);
        System.Assert(testCaseUpd.ExpirationDate__c != null);
        System.Assert(testCaseUpd.AmountToPayInInstallments__c != null);
        System.Assert(testCaseUpd.InstallmentAmount__c != null);
        System.assertEquals(false, testCaseUpd.CutomerAssisted__c);
    }

    @isTest
    static void createRequestBody()
    {
        HDT_SRV_InstallmentPlans srvInstallments = new HDT_SRV_InstallmentPlans();
        String body = '';
        Case testCase = [SELECT Id, TotalToPay__c FROM Case LIMIT 1];
        testCase.Amount__c = 100;
        testCase.InstallmentNumberRequired__c = 2;
        testCase.ExpirationDate__c = System.today();
        testCase.DepositAmount__c = 20;
        testCase.DepositPaymentMode__c = 'Paperless';
        update testCase;
        Test.startTest();
        body = srvInstallments.createRequestBody(testCase.Id);
        Test.stopTest();
        System.Assert(body != '');
    }
    @isTest
    static void transcodeInstallmentPlanTst()
    {
        HDT_SRV_InstallmentPlans srvInstallments = new HDT_SRV_InstallmentPlans();
        Test.startTest();
        String testOne = srvInstallments.transcodeInstallmentPlan(null,false);
        String testTwo = srvInstallments.transcodeInstallmentPlan('Autorita',false);
        String testThree = srvInstallments.transcodeInstallmentPlan('Piano Bonus',true);
        String testFour = srvInstallments.transcodeInstallmentPlan('Piano Bonus',false);
        String testFive = srvInstallments.transcodeInstallmentPlan('Autorita idrico',true);
        String testSix = srvInstallments.transcodeInstallmentPlan('Autorita idrico',false);
        String testSeven = srvInstallments.transcodeInstallmentPlan('Altro',true);
        String testEight = srvInstallments.transcodeInstallmentPlan('Altro',false);
        Test.stopTest();
        System.AssertEquals('', testOne);
        System.AssertEquals('Z001', testTwo);
        System.AssertEquals('Z010', testThree);
        System.AssertEquals('Z011', testFour);
        System.AssertEquals('Z012', testFive);
        System.AssertEquals('Z013', testSix);
        System.AssertEquals('Z002', testSeven);
        System.AssertEquals('Z003', testEight);
    }
    @isTest 
    static void evaluateRuleListTst()
    {
        HDT_SRV_InstallmentPlans srvInstallments = new HDT_SRV_InstallmentPlans();
        HDT_UTL_InstallmentPlans.HDT_UTL_FlowOutputs output = new HDT_UTL_InstallmentPlans.HDT_UTL_FlowOutputs();
        Case testCase = [SELECT Id, TotalToPay__c FROM Case LIMIT 1];
        testCase.ApplicationInterests__c = true;
        testCase.CAWithOrWithoutSEPA__c = false;
        testCase.SuspensionInThePastTwelveMonths__c = false;
        testCase.Deposit__c = false;
        testCase.RefundableEscape__c = false;
        testCase.WorkStatus__c = 'In Corso';
        update testCase;
        Set<String> criteriaFields = new Set<String>{
            'ApplicationInterests__c',
            'CAWithOrWithoutSEPA__c',
            'SuspensionInThePastTwelveMonths__c',
            'Deposit__c',
            'RefundableEscape__c',
            'WorkStatus__c'};
        Map<String, Object> criteriaMap = new Map<String, Object>();
        for(String fieldName : criteriaFields){
            criteriaMap.put(fieldName, testCase.get(fieldName));
        }
        List<RentProcessRule__c> ruleList = [SELECT Id, 
        AmountToPayInInstallmentsFrom__c,
        AmountToPayInInstallmentsTo__c,
        ApplicationInterests__c,
        ApprovalProcess__c,
        AttachmentManagement__c,
        CAWithOrWithoutSEPA__c,
        Deposit__c,
        ExistingInstallmentPlanUnpaidFrom__c,
        ExistingInstallmentPlanUnpaidTo__c,
        InstallmentPlanReason__c,
        MaxInstallmentsNumber__c,
        Category__c,
        SuspensionInPastTwelveMonths__c,
        RefundableEscape__c,
        WorkStatus__c
        FROM RentProcessRule__c];
        Test.startTest();
        output = srvInstallments.evaluateRuleList(ruleList, criteriaMap);
        Test.stopTest();
        System.Assert(output.errorMessage != '' && output.errorMessage != null);
    
    }

    public class HDT_SRV_InstallmentPlansTstMock implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success","correlationId":"65d9b870-1643-11ec-9817-022a9bf2c34e","timestamp":"2021-09-15T18:38:50","data":[{"contoContrattuale":"200010530499","classeConto":"Z001","codiceCliente":"1002732959","societa":"HeraCommS.p.A.","dataEmissione":"31/08/2021","dataScadenza":"20/01/2022","podPdr":"IT001E56328467","importo":"0.0","residuo":"17.0","modalitaPagamento":"bollettinopostale","documento":"500002727012","bloccoAlSollecito":"B-PG-BLOCCOAVVISORICEVUTODALCL.AVVENUTOPAG","tipoDocumento":"RATE","contratto":"3020211479","settoreMerceologico":"Energiaelettrica","tipoTransazione":"EC1","idPrimoLivelloSAP":"00000000000000000000000000000000000000000000000001","oraIncassoRealTime":"00:00:00","loginId":"0-1","secondoLivelloInformativoF2":[]}]}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response; 
        }
    }

}
