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
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(1, true, acctList[0].Id, 'Attiva');
        Id pricebookId=Test.getStandardPricebookId();
        List<Order> orderWithPricebook=HDT_UTL_DataFactoryTst.createOrderWithPricebook(1, false, acctList[0].Id, sales, pricebookId);
        orderWithPricebook[0].RecordTypeId=constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        orderWithPricebook[0].CommercialProduct__c=prods[0].Id;
        orderWithPricebook[0].Step__c = 1;
        insert orderWithPricebook;
        /* List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, false, acctList[0].Id, 'Bozza');
        orders[0].Step__c = 1;
        orders[0].RecordTypeId=constants.ORDER_RECORDTYPEID_ATTIVAZIONE;

        insert orders; */
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
        wrts_prcgvr__Activity__c activity = [SELECT Id,wrts_prcgvr__Status__c,wrts_prcgvr__IsClosed__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Comunicazione verso Heroku', o.Phase__c, debugString + 'Fase dell\'order non aggiornata');
        System.assertEquals('Chiusa', activity.wrts_prcgvr__Status__c, debugString + 'Stato dell\'activity non aggiornata');
        System.assertEquals(true, activity.wrts_prcgvr__IsClosed__c, debugString + 'L\'activity non è stata chiusa correttamente');
        
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
        insert actList;
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Read Only');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, true);
        Test.startTest();
            String response;
            System.runAs(u){
                response = HDT_LC_EditScartiComplessi.resubmissionPractice(o.Id, actList[0].Id,'Attivazione');
            }
            System.assertEquals('Errore nell\'aggiornamento della fase dell\'ordine.',response,debugString + 'gestione errore upload order non funzionante');
        Test.stopTest();
    }

    @isTest
    public static void executeResubmissionPracticeErrorUploadActivity(){
        String debugString = 'Method - executeResubmissionPracticeErrorUploadActivity ';
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Read Only');
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
            Order o = [SELECT Id FROM Order LIMIT 1];
            Account acc = [SELECT Id FROM Account];
            List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
            actList[0].Order__c = o.Id;
            insert actList;
            String response;
            System.runAs(u){
                response = HDT_LC_EditScartiComplessi.resubmissionPractice(o.Id, actList[0].Id,'Attivazione');
            }
            System.assertEquals('Impossibile chiudere l\'attività di scarto',response,debugString + 'gestione errore chiusura activity non funzionante');
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
        wrts_prcgvr__Activity__c activity = [SELECT Id,wrts_prcgvr__Status__c,wrts_prcgvr__IsClosed__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals(null,response,debugString + 'processo non funzionante');
        System.assertEquals('Chiusa', activity.wrts_prcgvr__Status__c, debugString + 'Stato dell\'activity non aggiornata');
        System.assertEquals(true, activity.wrts_prcgvr__IsClosed__c, debugString + 'L\'activity non è stata chiusa correttamente');
    }

    @isTest
    public static void executeCloseDiscardActivityError(){
        String debugString = 'Method - executeCloseDiscardActivityError ';
        Order o = [SELECT Id FROM Order LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        actList[0].Order__c = o.Id;
        insert actList;
        Id profileId = HDT_UTL_DataFactoryTst.getProfileId('Read Only');
        User u = HDT_UTL_DataFactoryTst.createInternalUser(profileId, true);
        Test.startTest();
            String response;
            System.runAs(u){
                response = HDT_LC_EditScartiComplessi.closeDiscardActivity(new List<String>{actList[0].Id})[0];
            }
            System.assertEquals('Impossibile chiudere l\'attività di scarto',response,debugString + 'gestione errore chiusura activity non funzionante');
        Test.stopTest();
    }


}
