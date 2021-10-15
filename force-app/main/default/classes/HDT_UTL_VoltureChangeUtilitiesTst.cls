/**@frpanico 12/10/2021
 * Test Class for the class HDT_UTL_VoltureCHangeUtilities
 */
@IsTest
public with sharing class HDT_UTL_VoltureChangeUtilitiesTst {

    private static HDT_UTL_VoltureChangeUtilities voltureChangeUtilities = new HDT_UTL_VoltureChangeUtilities();

    @TestSetup
    static void setup()
    {
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList=HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');	
		List<Order> orderList =HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].Id, 'Bozza');
        List<Contact> contactList=HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id); 

        String recordTypeNameVolturaConSwitch = 'HDT_RT_VolturaConSwitch';
        String recordTypeIdVolturaConSwitch = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get(recordTypeNameVolturaConSwitch).getRecordTypeId();

        orderList[0].RecordTypeId = recordTypeIdVolturaConSwitch;
        orderList[0].Contact__c = contactList[0].Id;
        update orderList;

        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Comunicazione verso Heroku', 'Bozza', recordTypeIdVolturaConSwitch, recordTypeNameVolturaConSwitch,'A','','','');

    }

    @IsTest
    static void updateOrderFutureTst()
    {
        List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order];
        orderToUpdate[0].Phase__c = 'Comunicazione verso Heroku';
        Test.startTest();
        HDT_UTL_VoltureChangeUtilities.updateOrderFuture(JSON.serialize(orderToUpdate[0]));
        Test.stopTest();
        List<Order> orderUpdated = [SELECT Id, Phase__c FROM Order];
        System.assertEquals('Comunicazione verso Heroku', orderUpdated[0].Phase__c,'Fase non correttamente aggiornata');
    }

    @IsTest
    static void nextPhaseBusinessAccountTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order];
        Test.startTest();
        accountCheck = voltureChangeUtilities.nextPhaseBusinessAccount(System.today(), '', orderToUpdate[0].Id);
        Test.stopTest();
        System.assertEquals(HDT_UTL_VoltureChangeUtilities.communicationPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void nextPhaseBusinessAccountWaitingTst()
    {
        HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck accountCheck = new HDT_WRP_VoltureChangeManager.HDT_WRP_AccountCheck();
        List<Order> orderToUpdate = [SELECT Id, Phase__c FROM Order];
        Test.startTest();
        accountCheck = voltureChangeUtilities.nextPhaseBusinessAccount(System.today().addDays(1), '', orderToUpdate[0].Id);
        Test.stopTest();
        System.assertEquals(HDT_UTL_VoltureChangeUtilities.waitingPhase, accountCheck.nextPhase, 'Fase non correttamente calcolata');
    }

    @IsTest
    static void getFieldsMapTst()
    {
        wrts_prcgvr.MRR_1_0.MultiResponse responseMrr= new wrts_prcgvr.MRR_1_0.MultiResponse();
        List<wrts_prcgvr.MRR_1_0.Response> responses = new List<wrts_prcgvr.MRR_1_0.Response>();
        wrts_prcgvr.MRR_1_0.Response singleResponse = new wrts_prcgvr.MRR_1_0.Response();
        wrts_prcgvr.MRR_1_0.Header header = new wrts_prcgvr.MRR_1_0.Header();
        List<wrts_prcgvr.MRR_1_0.WObject> objects = new List<wrts_prcgvr.MRR_1_0.WObject>();
        List<wrts_prcgvr.MRR_1_0.WObject> otherObjects = new List<wrts_prcgvr.MRR_1_0.WObject>();
        wrts_prcgvr.MRR_1_0.WObject singleObject = new wrts_prcgvr.MRR_1_0.WObject();
        List<wrts_prcgvr.MRR_1_0.Field> headerFields = new List<wrts_prcgvr.MRR_1_0.Field>();
        wrts_prcgvr.MRR_1_0.Field headerField = new wrts_prcgvr.MRR_1_0.Field();
        List<wrts_prcgvr.MRR_1_0.Field> bodyFields = new List<wrts_prcgvr.MRR_1_0.Field>();
        wrts_prcgvr.MRR_1_0.Field bodyField = new wrts_prcgvr.MRR_1_0.Field();    
        
        headerField.fieldType = 'TEXT';
        headerField.name = 'requestType';
        headerField.value = 'CREA_RIC';
        headerFields.add(headerField);

        header.fields = headerFields;
        header.requestId = 'asiojadisdj';
        header.requestTimestamp = '120-39123';
        header.requestType = 'asjdioajsdoi';

        bodyField.fieldType = 'TEXT';
        bodyField.name = 'FASE';
        bodyField.value = 'PRECHECK';

        bodyFields.add(bodyField);

        singleObject.fields = bodyFields;
        singleObject.id = 'ajsidj';
        singleObject.name = 'objName';
        singleObject.objects = otherObjects;
        singleObject.objectType = 'objType';

        objects.add(singleObject);

        singleResponse.code = 'code';
        singleResponse.description = 'description';
        singleResponse.header = header;
        singleResponse.objects = objects;

        responses.add(singleResponse);

        responseMrr.responses = responses;
        
        Test.startTest();
        Map<String,Object> fieldsMap = voltureChangeUtilities.getFieldsMap(responseMrr);
        Test.stopTest();

        System.assert(fieldsMap.keySet().size() > 0, 'Response non mappata correttamente');
        
        
    }

    @IsTest
    static void getTensionBtTst()
    {
        Test.startTest();
        String result = voltureChangeUtilities.getTension(HDT_UTL_VoltureChangeUtilities.btLimit);
        Test.stopTest();
        System.assertEquals('BT', result, 'Livello Tensione BT non calcolato correttamente');
    }

    
    @IsTest
    static void getTensionMtTst()
    {
        Test.startTest();
        String result = voltureChangeUtilities.getTension(HDT_UTL_VoltureChangeUtilities.mtLimit);
        Test.stopTest();
        System.assertEquals('MT', result, 'Livello Tensione MT non calcolato correttamente');
    }

    
    @IsTest
    static void getTensionAtTst()
    {
        Test.startTest();
        String result = voltureChangeUtilities.getTension(HDT_UTL_VoltureChangeUtilities.atLimit);
        Test.stopTest();
        System.assertEquals('AT', result, 'Livello Tensione AT non calcolato correttamente');
    }

}
