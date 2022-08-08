@IsTest
public with sharing class HDT_UTL_CreditCheckTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Credit Check KO','Bozza',constants.ORDER_RECORDTYPEID_SUBENTRO,constants.ORDER_RECORDTYPE_DEVELOPERNAME_SUBENTRO);

        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(2,false,'MMS','MMS Azienda','Aziende SME');
        insert accs;
        List<Contact> conts = HDT_UTL_DataFactoryTst.createContact(1, false, accs[0].Id);
        conts[0].Company__c='MMS';
        insert conts;
        List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,false);
        points[0].RecordTypeId = constants.SERVICEPOINT_RECORDTYPEID_GAS;
        points[0].Account__c = accs[1].id;
        points[0].PlugPresence__c = 'Si';
        points[0].isReseller__c = false;
        points[0].ServicePointCode__c = 'codicepunto';
        points[0].MeterStatus__c = 'Bozza';
        points[0].AnnualConsumption__c =500;
        points[0].CommoditySector__c = 'Gas';
        insert points;

        List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,false,accs[0].id);
        contracts[0].ServicePoint__c = points[0].id;
        insert contracts; 

        List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1, true, accs[0].id, 'Bozza');
            
        List<Order> orders =  HDT_UTL_DataFactoryTst.createOrder(1, false, accs[0].id, 'Bozza');
        orders[0].ServicePoint__c = points[0].id;
        orders[0].VoltageLevel__c ='MT';
        orders[0].MarketOrigin__c ='Libero';
        orders[0].PowerRequested__c = 50;
        orders[0].PowerCommitted__c = 45;
        orders[0].IsWinback__c = false;
        orders[0].ContractReference__c = contracts[0].id;
        orders[0].SAPImplantCode__c = '';
        insert orders;

        List<Order> childOrders =  HDT_UTL_DataFactoryTst.createChildOrder(1, false, accs[0].id, sales, orders[0].id, null);
        childOrders[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_Subentro').getRecordTypeId();
        childOrders[0].ServicePoint__c = points[0].id;
        childOrders[0].ProcessType__c = 'Subentro Gas';
        childOrders[0].Contact__c = conts[0].Id;
        insert childOrders;

    }

    @IsTest
    public static void testCreateRequest(){
        Order o = [SELECT Id,RecordType.DeveloperName,ServicePoint__r.Account__c FROM Order WHERE RecordType.DeveloperName = 'HDT_RT_Subentro'];
        Test.startTest();
            String response = JSON.serialize(HDT_UTL_CreditCheck.createRequestFromOrderId(o.Id));
            Boolean checkVoltura = HDT_UTL_CreditCheck.checkOutcomingVolturaWithSwitch(o);
        Test.stopTest();

        System.assertEquals(true, response.containsIgnoreCase('bpAlternative'), 'Problema nella creazione della request');
        System.assertEquals(false, checkVoltura, 'Metodo per il controllo Voltura con Switch non funzionante');

    }

    @IsTest
    public static void testUpdateOrderIncoming(){
        HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate data = new HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate();
        Order o = [SELECT Id,RecordType.DeveloperName,ServicePoint__r.Account__c FROM Order WHERE RecordType.DeveloperName = 'HDT_RT_Subentro'];
        data.orderId = String.valueOf(o.Id).substring(0,15);
        data.outcome = 'KO';
        data.outcomeDescription = 'Update failed. First exception on row 0 with id ; first error: STRING_TOO_LONG, Descrizione Esito Credit Check: data value too large: KO Tecnico - Expected Map&lt;String,String&gt; but found &quot;First exception on row 0 with id ; first error: STRING_TOO_LONG, Descrizione Esito Credit Check: data value too large: KO Tecnico - Expected Map&lt;String,String&gt; but found &quot;';
        data.outcoming = null;
        Test.startTest();
            HDT_UTL_CreditCheck.updateOrder(new List<HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate>{data});
            update new Order(Id = o.Id, Phase__c = 'Comunicazione Verso Heroku');
        Test.stopTest();
        o = [SELECT Id, IncomingCreditCheckResult__c,Phase__c FROM Order WHERE RecordType.DeveloperName = 'HDT_RT_Subentro'];
        System.assertEquals('KO', o.IncomingCreditCheckResult__c, 'testUpdateOrderIncoming - Esito non Aggiornato');
        System.assertEquals('Credit Check KO', o.Phase__c, 'testUpdateOrderIncoming - Fase non Aggiornata');
        
    }

    @IsTest
    public static void testUpdateOrderOutcoming(){
        HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate data = new HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate();
        Order o = [SELECT Id,RecordType.DeveloperName,ServicePoint__r.Account__c FROM Order WHERE RecordType.DeveloperName = 'HDT_RT_Subentro'];
        data.orderId = String.valueOf(o.Id).substring(0,15);
        data.outcome = 'KO';
        data.outcomeDescription = 'TEST';
        data.outcoming = true;
        Test.startTest();
            HDT_UTL_CreditCheck.updateOrder(new List<HDT_UTL_CreditCheck.HDT_WRP_DataForUpdate>{data});
            update new Order(Id = o.Id, Phase__c = 'Comunicazione Verso Heroku');
        Test.stopTest();
        o = [SELECT Id, OutgoingCreditCheckResult__c,Phase__c FROM Order WHERE RecordType.DeveloperName = 'HDT_RT_Subentro'];
        System.assertEquals('KO', o.OutgoingCreditCheckResult__c, 'testUpdateOrderOutcoming - Fase non Aggiornata');
        System.assertEquals('Credit Check KO', o.Phase__c, 'testUpdateOrderIncoming - Fase non Aggiornata');
    }

    @IsTest
    public static void testManagedErrorCode(){
        Boolean isManaged;
        Test.startTest();
            isManaged = HDT_UTL_CreditCheck.managedErrorCode('NO_CODE');
        Test.stopTest();
        System.assertEquals(false, isManaged, 'La risposta non è quella attesa');
    }

    @IsTest
    public static void testInsertCalloutLog(){
        Test.startTest();
            HDT_UTL_CreditCheck.insertCalloutLog('request', 'response');
        Test.stopTest();
        System.assertEquals(1, [SELECT id FROM wrts_prcgvr__Log__c].size(), 'La risposta non è quella attesa');
    }

}
