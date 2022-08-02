@IsTest
public with sharing class HDT_LC_EditScartiComplessiTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    private final static String FAKE_ID = 'aXXX123sED45IDFaKe';

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',constants.ORDER_RECORDTYPEID_ATTIVAZIONE,constants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);

        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, acctList[0].Id);
		List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, acctList[0].Id);
        List<Product2> prods=HDT_UTL_DataFactoryTst.createProduct2(1, true);
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(6, true, acctList[0].Id, 'Attiva');
        Id pricebookId=Test.getStandardPricebookId();
        List<Order> orderWithPricebook=HDT_UTL_DataFactoryTst.createOrderWithPricebook(6, false, acctList[0].Id, sales, pricebookId);
        orderWithPricebook[0].RecordTypeId=constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        orderWithPricebook[0].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[0].Step__c = 1;
        orderWithPricebook[0].Contact__c =contacts[0].Id;

        orderWithPricebook[1].RecordTypeId=constants.ORDER_RECORDTYPEID_SUBENTRO;
        orderWithPricebook[1].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[1].Step__c = 1;
        orderWithPricebook[1].Contact__c =contacts[0].Id;

        orderWithPricebook[2].RecordTypeId=constants.ORDER_RECORDTYPEID_VOLTURA;
        orderWithPricebook[2].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[2].Step__c = 1;
        orderWithPricebook[2].Contact__c =contacts[0].Id;

        orderWithPricebook[3].RecordTypeId=constants.ORDER_RECORDTYPEID_SWITCHIN;
        orderWithPricebook[3].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[3].Step__c = 1;
        orderWithPricebook[3].Contact__c =contacts[0].Id;

        orderWithPricebook[4].RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        orderWithPricebook[4].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[4].Step__c = 1;
        orderWithPricebook[4].Contact__c =contacts[0].Id;

        orderWithPricebook[5].RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchInVolturaTecnica').getRecordTypeId();
        orderWithPricebook[5].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[5].Step__c = 1;
        orderWithPricebook[5].Contact__c =contacts[0].Id;

        insert orderWithPricebook;

        
        wrts_prcgvr__ActivityStatusSetting__c cs = new wrts_prcgvr__ActivityStatusSetting__c();
        cs.Name='Chiusa';
        cs.wrts_prcgvr__ApiName__c='Chiusa';
        cs.wrts_prcgvr__IsClosed__c=true;
        insert cs;
        /* List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, false, acctList[0].Id, 'Bozza');
        orders[0].Step__c = 1;
        orders[0].RecordTypeId=constants.ORDER_RECORDTYPEID_ATTIVAZIONE;

        insert orders; */

        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList[0].Order__c = orderWithPricebook[0].Id;
        insert actList;
        List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, acctList[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orderWithPricebook[0].Id);
        cases[0].RecordTypeId=constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        cases[0].HerokuPracticeCode__c = 'TEST_SALESFORCE';
        insert cases;	
        /*  */
    }

    @isTest
    public static void executeGetInitDataForCase(){
        String debugString = 'Method - executeGetInitDataForCase ';
        Case c = [SELECT Id FROM Case];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Case__c = c.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,String> responseMap = (Map<String,String>)JSON.deserialize(response, Map<String,String>.class);
        System.assertEquals('Case', responseMap.get('objectType'), debugString +'ObjectType Errato');
        System.assertEquals(actList[0].Id, responseMap.get('objectId'), debugString +'ObjectId Errato');
    }

    @isTest
    public static void executeGetInitDataForOrder(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);      
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            try
            {
                response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
            }
            catch(exception e){
                System.debug('exception: '+ e);
            }
        Test.stopTest();

        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];

        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        System.assertEquals(5, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void executeGetInitDataForOrderException(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        insert actList;
        String response;
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera System Administrator');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, true);
        Test.startTest();
        System.runAs(u){
            try{
                response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
            }catch(Exception e){
                response = 'Exception';
            }
        }
        Test.stopTest();
        System.assertEquals('Exception', response, debugString + 'L\'attività può essere gestita anche non dall\'assegnatario');
    }

    @isTest
    public static void executeGetInitDataForOrderBusta(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].Type__c = 'Busta Docusign non consegnata';
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        System.debug('################');
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.debug(responseMap);

        System.assertEquals('wrts_prcgvr__Activity__c', responseMap.get('objectType'), debugString +'ObjectType Errato');
    }

    @isTest
    public static void executeResubmissionPractice(){
        String debugString = 'Method - executeResubmissionPractice ';
        Order o = [SELECT Id,RecordTypeId, RecordType.DeveloperName FROM Order LIMIT 1];
        System.debug('@@@@ o ' + o);
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.resubmissionPractice(o.Id, actList[0].Id,'Attivazione');
        Test.stopTest(); 
        System.assertEquals(null, response, debugString + 'Il processo di risottomissione non ha funzionato');
        o = [SELECT Id,Phase__c FROM Order WHERE Id =:o.Id];
        wrts_prcgvr__Activity__c activity = [SELECT Id,wrts_prcgvr__Status__c,wrts_prcgvr__IsClosed__c FROM wrts_prcgvr__Activity__c where id =:actList[0].id LIMIT 1];
        System.assertEquals('Comunicazione verso Heroku', o.Phase__c, debugString + 'Fase dell\'order non aggiornata');
        System.assertEquals('Chiusa', activity.wrts_prcgvr__Status__c, debugString + 'Stato dell\'activity non aggiornata');
        System.assertEquals(true, activity.wrts_prcgvr__IsClosed__c, debugString + 'L\'activity non è stata chiusa correttamente');
        
    }

    @isTest
    public static void executeGetInitDataForOrderSub(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order where RecordTypeId =: constants.ORDER_RECORDTYPEID_SUBENTRO LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];
        System.assertEquals(5, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void executeGetInitDataForOrderVolt(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order where RecordTypeId =: constants.ORDER_RECORDTYPEID_VOLTURA LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];
        System.assertEquals(3, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void executeGetInitDataForOrderSwitchIn(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order where RecordTypeId =: constants.ORDER_RECORDTYPEID_SWITCHIN LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];
        System.assertEquals(5, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void executeGetInitDataForOrderVoltSwitch(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Id rtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        Order o = [SELECT Id FROM Order where RecordTypeId =: rtId LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];
        System.assertEquals(4, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void executeGetInitDataForOrderVoltSwitchTec(){
        String debugString = 'Method - executeGetInitDataForOrder ';
        Id rtId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_SwitchInVolturaTecnica').getRecordTypeId();
        Order o = [SELECT Id FROM Order where RecordTypeId =: rtId LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];
        System.assertEquals(11, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void executeTryCatchBlock(){
        String debugString = 'Method - executeResubmissionPractice ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        insert actList;
        Test.startTest();
            Boolean isException = false;
            try{
                HDT_LC_EditScartiComplessi.resubmissionPractice(FAKE_ID, FAKE_ID,'Attivazione');
            }catch(Exception e){
                isException = true;
            }
            System.assertEquals(true,isException,debugString + 'gestione exception non funzionante');
            isException = false;
            try{
                HDT_LC_EditScartiComplessi.getInitData(FAKE_ID);
            }catch(Exception e){
                isException = true;
            }
            System.assertEquals(true,isException,debugString + 'Invalid id non rilevato');
            isException = false;
            try{
                HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
            }catch(Exception e){
                isException = true;
            }
            System.assertEquals(true,isException,debugString + 'Invalid Activity non rilevato');
        Test.stopTest();
    }

    @isTest
    public static void executeResubmissionPracticeErrorUploadOrder(){
        String debugString = 'Method - executeResubmissionPracticeErrorUploadOrder ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        //insert actList;
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera System Administrator');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, true);
        actList[0].OwnerId = u.Id;
        insert actList;
        Test.startTest();
            String response;
            System.runAs(u){
                response = HDT_LC_EditScartiComplessi.resubmissionPractice(o.Id, actList[0].Id,'Attivazione');
            }
            System.assertEquals(null,response,debugString + 'gestione errore upload order non funzionante');
        Test.stopTest();
    }

    @isTest
    public static void executeResubmissionPracticeErrorUploadActivity(){
        String debugString = 'Method - executeResubmissionPracticeErrorUploadActivity ';
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera System Administrator');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, true);
        PermissionSet pr = new PermissionSet(Label='Order Permisson Set',Name='Order_Permisson_Set');
        insert pr;
        ObjectPermissions op = new ObjectPermissions(
            ParentId = pr.Id,
            PermissionsCreate = true,
            PermissionsDelete = true,
            PermissionsEdit = true,
            PermissionsModifyAllRecords = true,
            PermissionsRead = true,
            PermissionsViewAllRecords = true,
            SobjectType = 'Order'
        );
        insert op;
        FieldPermissions fp = new FieldPermissions(
            Field = 'Order.Phase__c',
            ParentId = pr.Id,
            PermissionsEdit = true,
            PermissionsRead = true,
            SobjectType = 'Order'
        );
        insert fp;

        PermissionSetAssignment pm = new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=pr.id);
        insert pm;
        Test.startTest();
            List<wrts_prcgvr__Activity__c> actList = [Select id, Order__c from wrts_prcgvr__Activity__c limit 1];

            String response;
            System.runAs(u){
                response = HDT_LC_EditScartiComplessi.resubmissionPractice(actList[0].Order__c, actList[0].Id,'Attivazione');
            }
            System.assertEquals(null,response,debugString + 'gestione errore chiusura activity non funzionante');
        Test.stopTest();
    }

    @isTest
    public static void executeCloseDiscardActivity(){
        String debugString = 'Method - executeCloseDiscardActivity ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.closeDiscardActivity(new List<String>{actList[0].Id})[0];
        Test.stopTest();
        wrts_prcgvr__Activity__c activity = [SELECT Id,wrts_prcgvr__Status__c,wrts_prcgvr__IsClosed__c FROM wrts_prcgvr__Activity__c where id=: actList[0].id];
        System.assertEquals(null,response,debugString + 'processo non funzionante');
        System.assertEquals('Chiusa', activity.wrts_prcgvr__Status__c, debugString + 'Stato dell\'activity non aggiornata');
        System.assertEquals(true, activity.wrts_prcgvr__IsClosed__c, debugString + 'L\'activity non è stata chiusa correttamente');
    }

    @isTest
    public static void executeCloseDiscardActivityError(){
        String debugString = 'Method - executeCloseDiscardActivityError ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Hera Standard User');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, true);
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].OwnerId = u.Id;
        insert actList;
        
        Test.startTest();
            String response;
            System.runAs(u){
                response = HDT_LC_EditScartiComplessi.closeDiscardActivity(new List<String>{actList[0].Id})[0];
            }
        	List<wrts_prcgvr__Activity__c> actList1 = [Select id, UserCompany__c, ClosedByUsername__c from wrts_prcgvr__Activity__c where id =: actList[0].Id];
            System.assertEquals(actList1[0].UserCompany__c,u.UserCompany__c,debugString + 'gestione errore chiusura activity non funzionante');
            System.assertEquals(actList1[0].ClosedByUsername__c,u.Username.toLowerCase(),debugString + 'gestione errore chiusura activity non funzionante');
        Test.stopTest();
    }

    @isTest
    public static void setStepSwitchInTest(){
        List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);

        String debugString = 'Method - executeGetInitDataForOrder ';
        Order o = [SELECT Id FROM Order where RecordTypeId =: constants.ORDER_RECORDTYPEID_SWITCHIN LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        o.SwitchOutDate__c = Date.Today();
        update o;
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        actList[0].ManuallyReassigned__c = true;
        insert actList;
        String response;
        Test.startTest();
            response = HDT_LC_EditScartiComplessi.getInitData(actList[0].Id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response);
        System.assertEquals('Order', responseMap.get('objectType'), debugString +'ObjectType Errato');
        Order retrivedOrder = (Order)JSON.deserialize(JSON.serialize(responseMap.get('object')),Order.class);
        System.assertEquals(o.Id, retrivedOrder.Id, debugString+'Ordine non corretto');
        o = [SELECT Id,Step__c FROM Order WHERE Id =:o.Id];
        System.assertEquals(3, o.Step__c, debugString +'Step non aggiornato');
    }

    @isTest
    public static void setStepForVoltureWithSwitchTest(){
        Account acc = [SELECT Id FROM Account];

        List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, false);
        servPoints[0].CommoditySector__c = 'Energia Elettrica';
        servPoints[0].Account__c = acc.Id;
        insert servPoints;

        Double resp = HDT_LC_EditScartiComplessi.setStepForVoltureWithSwitch(servPoints[0], acc.Id);
        System.assertEquals(3, resp , 'Step errato');

    }

    @isTest
    public static void setStepForVoltureWithSwitchTest2(){
        List<Account> acc = [SELECT Id FROM Account LIMIT 2];
        List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, false);

        servPoints[0].Account__c = acc[0].Id;

        insert servPoints;
        Account accDummy = new Account();
        Double resp = HDT_LC_EditScartiComplessi.setStepForVoltureWithSwitch(servPoints[0], accDummy.Id);
        System.assertEquals(4, resp , 'Step errato');

    }

}