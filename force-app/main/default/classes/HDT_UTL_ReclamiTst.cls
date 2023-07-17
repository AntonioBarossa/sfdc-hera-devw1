@IsTest
public with sharing class HDT_UTL_ReclamiTst
{
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    private static HDT_UTL_Reclami utlReclami = new HDT_UTL_Reclami();

    @TestSetup
	static void setup(){

        TownAtoTable__c atoTable = new TownAtoTable__c();
        atoTable.Town__c = 'Pesaro';
        atoTable.Ato__c = 'AATO 1 MARCHE NORD';
        insert atoTable;

        List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME'); 
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accountList[0].Id);
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(2, false);
        servPointList[0].CommoditySector__c = 'Acqua';
        servPointList[1].CommoditySector__c = 'Gas';
        insert servPointList;

        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accountList[0].Id);
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].Id, 'Bozza');
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(1, false, accountList[0].Id, contactList[0].Id, servPointList[0].Id, contractList[0].Id, orderList[0].Id);
        caseList[0].Commodity__c = 'Acqua';
        caseList[0].Type = 'Richiesta di informazioni';
        caseList[0].SendDate__c = System.today();
        caseList[0].CorrectionDocumentEmissionDay__c = System.today();
        insert caseList;
        List<Case> csList = HDT_UTL_DataFactoryTst.createCase(1, false, accountList[0].Id, contactList[0].Id, servPointList[1].Id, contractList[0].Id, orderList[0].Id);
        csList[0].Commodity__c = 'Gas';
        csList[0].Type = 'Richiesta Parere';
        csList[0].FirstLevelOpinion__c = 'Supporto Normativo';
        csList[0].SecondLevelOpinion__c = 'Parere Normativo';
        csList[0].SendDate__c = System.today();
        csList[0].CorrectionDocumentEmissionDay__c = System.today();
        insert csList;
    }

    @isTest
    private static void setExpirationDateAcquaTst()
    {
        Case cs = [SELECT Id, Type, Parent.Type, Parent.Commodity__c, SendDate__c, CorrectionDocumentEmissionDay__c, Commodity__c, CommodityFormula__c, FirstLevelComplaintClassification__c, SecondLevelComplaintClassification__c, ServicePoint__r.CommoditySector__c FROM Case WHERE Commodity__c = 'Acqua' LIMIT 1];

        Test.startTest();
        Map<String,String> result = utlReclami.setExpirationDate(cs, 'Pesaro', cs.ServicePoint__r.CommoditySector__c);
        Test.stopTest();

        System.assertEquals( true, String.isNotBlank(result.get('CompletedDocumentationDate__c')), 'Not correctly calculate');

    }

    @isTest
    private static void setExpirationDateEnergyTst()
    {
        Case cs = [SELECT Id, Type, Parent.Type, Parent.Commodity__c, SecondLevelOpinion__c, SendDate__c, CorrectionDocumentEmissionDay__c, Commodity__c, CommodityFormula__c, FirstLevelComplaintClassification__c, SecondLevelComplaintClassification__c, ServicePoint__r.CommoditySector__c FROM Case WHERE Commodity__c = 'Gas' LIMIT 1];

        Test.startTest();
        Map<String,String> result = utlReclami.setExpirationDate(cs, 'Pesaro', cs.ServicePoint__r.CommoditySector__c);
        Test.stopTest();

        System.assertEquals( true, String.isNotBlank(result.get('CompletedDocumentationDate__c')), 'Not correctly calculate');

    }

}