/**@frpanico 12/10/2021
 * Test Class for HDT_SRV_VoltureChangeDispatcher
 */

@IsTest
public with sharing class HDT_SRV_VoltureChangeDispatcherTst 
{
    private static HDT_SRV_VoltureChangeDispatcher voltureManager = new HDT_SRV_VoltureChangeDispatcher();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.pClickCasePhase();//

        //Create 1 order one for the parent and one for the child 1
        //Create 2 OrderItems (to test loop with more than one item)
        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
		List<Sale__c> saleList=HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Attiva');
		List<Order> orderList=HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
		List<Contract> contractList=HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].Id);//
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1, true, accList[0].Id);//
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);  
        spList[0].CommoditySector__c = 'Energia Elettrica';
        update spList;

        orderList[0].Commodity__c = 'Energia Elettrica';
        orderList[0].CustomerCategory__c='Famiglie';
        update orderList;
		
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<Order> childOrderList = HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, saleList, orderList[0].Id, contactList[0].Id);
        List<Product2> productList = HDT_UTL_DataFactoryTst.createProduct2(1, true);
        //List<Pricebook2> priceBookList = HDT_UTL_DataFactoryTst.createPricebook(1, true);
        Id priceBookId = Test.getStandardPriceBookId();
        PricebookEntry pbEntry = new PriceBookEntry(Pricebook2Id = priceBookId, Product2Id = productList[0].Id, UnitPrice = 10000, IsActive = true);
        insert pbEntry;
        //List<PricebookEntry> priceBookEntryList = HDT_UTL_DataFactoryTst.createPricebookEntry(productList, true, priceBookId);
        childOrderList[0].Pricebook2Id = priceBookId;
        childOrderList[0].ProcessType__c = 'Switch in Ele';

        childOrderList[0].AccountId = accList[0].Id;
        childOrderList[0].Contact__c = contactList[0].Id;
        childOrderList[0].ContractReference__c = contractList[0].Id;
        childOrderList[0].CreatorGroup__c = 'HCM_BACK';
        childOrderList[0].PhoneNumber__c = '1112233444';
        childOrderList[0].Channel__c = 'Agenzie';
        childOrderList[0].ServicePoint__c = spList[0].Id;
        childOrderList[0].LoginWorkstation__c = 'CC_LT_Staff';
        childOrderList[0].Email__c = 'assistenza@servizioclienti.com';
        childOrderList[0].BillingProfile__c = billingProfileList[0].Id;
        childOrderList[0].ServicePointCode__c = 'IT001E00032928';
        childOrderList[0].SapContractCode__c = '3001002003';
        childOrderList[0].Commodity__c = 'Energia Elettrica';
        childOrderList[0].EffectiveDate__c = Date.newInstance(2022, 3, 1);
		childOrderList[0].CustomerCategory__c='Famiglie';


        update childOrderList;
        orderItemList = HDT_UTL_DataFactoryTst.createOrderItem(2, true, childOrderList[0].Id, spList[0].Id,productList[0].Id,pbEntry.Id);
        
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();

        String recordTypeNameVolturaTecnica = 'HDT_RT_VolturaTecnica';
        String recordTypeIdVolturaTecnica = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaTecnica).getRecordTypeId();

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'In attesa Data Decorrenza', 'Bozza', recordTypeIdVolturaTecnica, recordTypeNameVolturaTecnica,'A','','','');//
    
    }

    /**@frpanico 12/10/2021
     * The on-top class covers only one test case.
     * A full coverage of test cases can be found on "child" classes
     */

    @IsTest
    static void executeTst()
    {
        HDT_SRV_VoltureChangeDispatcher voltureDispatcher = new HDT_SRV_VoltureChangeDispatcher();
        HDT_QR_VoltureChangeManager voltureChangeQr = new HDT_QR_VoltureChangeManager();

        List<Order> orderList = [SELECT Id, 
        ParentOrder__c,
        Name,
        EffectiveDate,
        EffectiveDate__c,
        RecessNotice__c,
        AccountId,
        EstimateAmount__c,
        PowerQuote__c,
        AdministrativeBurden__c,
        EstimatedVAT__c,
        ValidityDateEstimate__c,
        CIAccoutn__c,
        QuickQuote__c,
        ChamberCommerceRegistration__c,
        Instance326__c,
        DocumentLow80__c,
        ContractSigned__c,
        SignedDate__c,
        SignatureMethod__c,
        DocSendingMethod__c,
        Sale__c,
        Pricebook2Id,
        Contact__c,
        Email__c,
        WithdrawalClass__c,
        EnergyService__c,
        UseCategory__c
        FROM Order WHERE ParentOrder__c != null];
        List<OrderItem> orderItemList = voltureChangeQr.getOrderItemByOrderId(orderList[0].Id);

        System.assertEquals(1, orderList.size(),'Order non trovato');
        System.assertEquals(2, orderItemList.size(),'OrderItmes non trovati');

        Map<String,Object> argsMap = new Map<String,Object>{'method' => 'cloneOrder', 'sender' => orderList[0]};

        Test.startTest();
        voltureDispatcher.execute(argsMap);
        Test.stopTest();

        List<Order> newOrderList = [SELECT Id, ParentOrder__c, Phase__c FROM Order WHERE (ProcessType__c = 'Voltura con Switch' OR Phase__c = 'Annullato') AND ParentOrder__c != NULL];
        List<OrderItem> newOrderItemList = [SELECT Id FROM OrderItem];
        System.assertEquals(2, newOrderList.size(),'Order non trovati');
        System.Assert(orderList[0].ParentOrder__c == newOrderList[0].ParentOrder__c, 'Parent order non associato correttamente');
        System.Assert(orderList[0].ParentOrder__c == newOrderList[1].ParentOrder__c, 'Parent order non associato correttamente');
        System.assertEquals(4, newOrderItemList.size(),'OrderItem non correttamente clonati');
        System.assert(newOrderList[0].Phase__c == 'Annullato' || newOrderList[0].Phase__c == 'Comunicazione verso Heroku', 'Fase non aggiornata correttamente');
        System.assert(newOrderList[1].Phase__c == 'Annullato' || newOrderList[1].Phase__c == 'Comunicazione verso Heroku', 'Fase non aggiornata correttamente');

    }

    @IsTest
    static void executePublishTst()
    {
        List<Order> orderList = [SELECT Id, Phase__c FROM Order WHERE ParentOrder__c != null];
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();
        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        update orderList; 
        Map<String,Object> argsMap = new Map<String,Object>{'method' => 'publishUpdate', 'sender' => orderList[0]};
        Object obj;
        
        Test.startTest();
        obj = voltureManager.execute(argsMap);
        Test.stopTest();

        List<Order> orderListUpdated = [Select Id,Phase__c FROM Order WHERE Id = :orderList[0].Id];

        System.assertEquals(HDT_SRV_VoltureChangeManager.publishUpdatePhase, orderListUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

    @IsTest
    static void executevolturaTecnicaTst()
    {
        List<Order> orderList = [SELECT Id, Phase__c, AccountId, CompanyOwner__c, Contact__c, BillingProfile__c, ContractReference__c, CreatorGroup__c, 
                                 PhoneNumber__c, Channel__c, ServicePoint__c, LoginWorkstation__c, Email__c, ServicePointCode__c, SapContractCode__c, 
                                 Commodity__c, EffectiveDate__c, FlagServizio26__c, SupplyCity__c, SupplyCityCode__c,SupplyState__c, SupplyCountry__c, SupplyPostalCode__c,
                                 SupplyStreetName__c,SupplyStreetNumber__c, BillingCity__c,BillingCityCode__c,BillingCountry__c, BillingPostalCode__c, BillingProvince__c,
                                 BillingStreetName__c, ResidentialCity__c, ResidentialCityCode__c, ResidentialCountry__c, ResidentialPostalCode__c,ResidentialState__c,
                                 ResidentialStreet__c, ResidentialStreetName__c, SalesCompany__c, SalesCompanyCode__c, DistributorCode__c, ExciseGAS__c, VAT__c,
                                 Resident__c, Market__c, SupplyType__c, AnnualConsumption__c, Caliber__c, WithdrawalClass__c, EnergyService__c, UseCategory__c
                                 FROM Order 
                                 WHERE ParentOrder__c != null
                                 AND ProcessType__c = 'Switch in Ele'];
                                 
        system.debug('orderList --> '+orderList);
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();
        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        update orderList; 
        Map<String,Object> argsMap = new Map<String,Object>{'method' => 'volturaTecnica', 'sender' => orderList[0]};
        Object obj;
        
        Test.setMock(HttpCalloutMock.class, new HDT_UTL_TestMockVolturaTecnica());

        Test.startTest();
        obj = voltureManager.execute(argsMap);
        Test.stopTest();

        List<Case> caseListUpdated = [Select Id,Phase__c, Order__c FROM Case WHERE Order__c = :orderList[0].Id];

        System.assertEquals(HDT_SRV_VoltureChangeManager.volturaTecnicaPhase, caseListUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

    @IsTest
    static void executebloccoVolturaTst()
    {
        List<Order> orderList = [SELECT Id, Phase__c, AccountId, CompanyOwner__c, Contact__c, BillingProfile__c, ContractReference__c, CreatorGroup__c, 
                                 PhoneNumber__c, Channel__c, ServicePoint__c, LoginWorkstation__c, Email__c, ServicePointCode__c, SapContractCode__c, 
                                 Commodity__c, EffectiveDate__c, FlagServizio26__c, SupplyCity__c, SupplyCityCode__c,SupplyState__c, SupplyCountry__c, SupplyPostalCode__c,
                                 SupplyStreetName__c,SupplyStreetNumber__c, BillingCity__c,BillingCityCode__c,BillingCountry__c, BillingPostalCode__c, BillingProvince__c,
                                 BillingStreetName__c, ResidentialCity__c, ResidentialCityCode__c, ResidentialCountry__c, ResidentialPostalCode__c,ResidentialState__c,
                                 ResidentialStreet__c, ResidentialStreetName__c, SalesCompany__c, SalesCompanyCode__c, DistributorCode__c, ExciseGAS__c, VAT__c,
                                 Resident__c, Market__c, SupplyType__c, AnnualConsumption__c, Caliber__c, HerokuPracticeCode__c, WithdrawalClass__c, EnergyService__c, UseCategory__c
                                 FROM Order 
                                 WHERE ParentOrder__c != null
                                 AND ProcessType__c = 'Switch in Ele'];
                                 
        system.debug('orderList --> '+orderList);
        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();
        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        update orderList; 
        Map<String,Object> argsMap = new Map<String,Object>{'method' => 'bloccoVoltura', 'sender' => orderList[0]};
        Object obj;
        
        Test.setMock(HttpCalloutMock.class, new HDT_UTL_TestMockVolturaTecnica());

        Test.startTest();
        obj = voltureManager.execute(argsMap);
        Test.stopTest();

        System.assert(orderList != null,'La lista è vuota');
    }

    public class HDT_UTL_TestMockVolturaTecnica implements HTTPCalloutMock{

        public HTTPResponse respond(HTTPRequest request){

            HttpResponse response = new HttpResponse();
            String bodyResponse;
            Integer statusCode;

            bodyResponse = '{"status": "success","prestazione": {"tipoAttivita": "TIPOATTIVITA","note": "NOTE"},"correlationId": "2a0c1340-f6b5-11eb-bb88-068530f44c42","timestamp": "2021-08-06T14:52:33",'
            +'"data": {"testata": {"esito": "OK"},"posizioni": ['
            +'{"campo": "DATACESSAZIONE","valore": "99991231"},'
            +'{"campo": "ALIQUOTAIVA","valore": "01"},'
            +'{"campo": "CA","valore": "200008867681"},'
            +'{"campo": "DESCRFATTURAZCOLL","valore": "Il contratto può essere fatturato con altri contratti"},'
            +'{"campo": "ANNOFABBRCONT","valore": "2000"},'
            +'{"campo": "CALIBRO1","valore": "GRT003"},'
            +'{"campo": "PRESENZACORRETTORE","valore": "NO"},'
            +'{"campo": "OPZIONE","valore": "E_UD_TDR"},'
            +'{"campo": "MOTIVOBLOCCOCALCOLO","valore": "T1"},'
            +'{"campo": "ACCISE","valore": "0.02270000"},'
            +'{"campo": "CODICE_ATECO","valore": "999999"}'
            +']}}';
            statusCode = 200;

            response.setHeader('Content-Type', 'application/json');
            response.setBody(bodyResponse);
            response.setStatusCode(statusCode);
            response.setStatus('OK');
            return response;
        }
    }


}