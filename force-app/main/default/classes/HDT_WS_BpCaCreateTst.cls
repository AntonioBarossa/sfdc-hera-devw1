/**@frpanico 2022-09-23 
 * Test Class for the BpCa module
 * It tests:
 * HDT_WS_BpCaCreate 100% (Last Update: 2022-09-23)
 * HDT_SRV_BpCaCreate 100% (Last Update: 2022-09-23)
 * HDT_UTL_BpCaCreate 90% (Last Update: 2022-09-23)
 * HDT_QR_BpCaCreate 100% (Last Update: 2022-09-23)
 */
@isTest
public with sharing class HDT_WS_BpCaCreateTst
{
    @TestSetup
    static void setup()
    {
        HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
        /*Install Process Click*/
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accountList = HDT_UTL_DataFactoryTst.createAccountResidenziale(1, false, 'MMS', 'G1 - MMS Persona fisica', 'Famiglie');
        /* Blanking customer code */
        accountList[0].CustomerCode__c = '';
        insert accountList;
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, false, accountList[0].Id);
        contactList[0].CompanyOwner__c = 'MMS';
        contactList[0].Company__c = 'MMS';
        insert contactList;
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1, false, accountList[0].Id);
        /* Blanking contract account code */
        billingProfileList[0].ContractAccountCode__c = '';
        billingProfileList[0].PaymentMethod__c = 'RID';
        billingProfileList[0].IbanABI__c = '05428';
        billingProfileList[0].IbanCAB__c = '11101';
        billingProfileList[0].IbanCodeNumber__c = '000000123456';
        billingProfileList[0].IbanCIN__c = 'X';
        billingProfileList[0].InvoicingCity__c = 'PESARO';
        billingProfileList[0].InvoicingCountry__c = 'ITALIA';
        billingProfileList[0].InvoicingStreetName__c = 'VIA RONCO';
        billingProfileList[0].InvoicingProvince__c = 'PU';
        billingProfileList[0].DivergentSubject__c = contactList[0].Id;
        billingProfileList[0].XMLType__c = 'Sintetico';
        billingProfileList[0].ElectronicInvoicingMethod__c = 'XML';
        insert billingProfileList;
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accountList[0].Id, 'Attiva');
        List<ServicePoint__c> servicePointList = HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servicePointList[0].RecordTypeId =  Schema.SObjectType.ServicePoint__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Acqua').getRecordTypeId();
        servicePointList[0].CommoditySector__c = 'Acqua';
        insert servicePointList;
        List<Order> parentOrder = HDT_UTL_DataFactoryTst.createOrder(1, true, accountList[0].Id, saleList);
        List<Order> childOrders = HDT_UTL_DataFactoryTst.createChildOrder(2, false, accountList[0].Id, saleList, parentOrder[0].Id, contactList[0].Id);
        childOrders[0].BillingProfile__c = billingProfileList[0].Id;
        childOrders[1].BillingProfile__c = billingProfileList[0].Id;
        childOrders[0].ServicePoint__c = servicePointList[0].Id;
        childOrders[1].ServicePoint__c = servicePointList[0].Id;
        insert childOrders;
        /* Create Phase Transition */
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', utlConstants.ORDER_RECORDTYPEID_VOLTURA , utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA,'A','','','');
    }

    @isTest
    static void executeSuccessTest()
    {
        HDT_WS_BpCaCreate testClass = new HDT_WS_BpCaCreate();
        List<Order> orderTest = [SELECT Id, ProcessType__c, Sale__c, AccountId, CustomerCode__c, BillingProfile__c,ContractAccountCode__c FROM Order WHERE ParentOrder__c != NULL];
        Test.setMock(HTTPCalloutMock.class, new HDT_WS_TestMock());
        Map<String, Object> argsTest = new Map<String, Object> {'method' => 'test', 'sender' => orderTest[0]};
        Test.startTest();
            testClass.execute(argsTest);
        Test.stopTest();

        List<Account> accountTst = [SELECT Id, CustomerCode__c FROM Account];
        System.assertEquals(true, String.isNotBlank(accountTst[0].CustomerCode__c), 'Integrazione fallita');
    }

    @isTest
    static void executeFailedTest()
    {
        HDT_WS_BpCaCreate testClass = new HDT_WS_BpCaCreate();
        List<Order> orderTest = [SELECT Id, ProcessType__c, Sale__c, AccountId, CustomerCode__c, BillingProfile__c,ContractAccountCode__c FROM Order WHERE ParentOrder__c != NULL];
        Map<String, Object> argsTest = new Map<String, Object> {'method' => 'mock', 'sender' => orderTest[0]};
        Test.startTest();
            testClass.execute(argsTest);
        Test.stopTest();

        List<wrts_prcgvr__Activity__c> activityTst = [SELECT Id, Type__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals(true, !activityTst.isEmpty(), 'Creazione Activity fallita');
    }

    class HDT_WS_TestMock implements HTTPCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            String body = '{"status": "success","correlationId": "0060ea20-37f5-11ed-ba57-0233fc6d39bc","timestamp": "2022-09-19T10:28:13","data": {"codiceCausale": "BPC","tipoAttivita": "OK","commenti": "BP rilevato","codiceBP": "100000001","codiceBPAlternativo":"200000001"}}';
            
            HttpResponse result = new HttpResponse();
            result.setStatusCode(200);
            result.setStatus('success');
            result.setBody(body);
            result.setHeader('Content-Type', 'application/json');

            return result;
        }
    }

}
