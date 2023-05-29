@isTest
public with sharing class HDT_LC_CanaleContattoIVRLoginTst {
    
    //@TestSetup
    static void setup1(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda','Aziende SME');
        //Account accResidenziale= HDT_UTL_DataFactoryTst.createAccountResidenziale(1,true,'HERA COMM','Persona fisica','Famiglie')[0];
        List<Contact> contList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].Id);
        contList[0].FiscalCode__c = accList[0].FiscalCode__c;
        update contList;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        List<Sale__c> saleList = HDT_UTL_DataFactoryTst.createSale(1, true, accList[0].Id, 'Bozza');
        saleList[0].Channel__c = 'Teleselling Outbound';
        update saleList;
        orderList[0].Username__c = 'Username';
        orderList[0].Password__c = 'Password';
        orderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        insert orderList;
        List<Order> childOrderList = HDT_UTL_DataFactoryTst.createChildOrder(1, true, accList[0].Id, saleList, orderList[0].Id, contList[0].Id);
        List<ServicePoint__c> spList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        spList[0].ServicePointCode__c = '04280014064833';
        spList[0].Account__c = accList[0].Id;
        update spList;
        childOrderList[0].ServicePoint__c = spList[0].Id;
        update childOrderList;

        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,accList[0].Id);
        actList[0].RecordingLink__c = 'http://test.com/';
        actList[0].Order__c = orderList[0].Id;
        actList[0].Type__c = 'Validazione Vocal Order';
        insert actList;

        
    }

    static void setup2(){

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(1, false, accList[0].Id, 'Bozza');
        orderList[0].Username__c = 'Username';
        orderList[0].Password__c = 'Password';
        orderList[0].RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('HDT_RT_VolturaConSwitch').getRecordTypeId();
        orderList[0].MethodSignedAccepted__c = 'web assistito';
        insert orderList;
        
    }

    //Metodo commentato perché checkLogin viene eseguito da downloadDocument
    // @isTest
    // public static void testcheckLogin(){
        
    //     setup1();
    //     Test.startTest();
    //     Order orderRetrieved = HDT_LC_CanaleContattoIVRLogin.checkLogin('Username', 'Password');
    //     Test.stopTest();
    //     System.assertNotEquals(null, orderRetrieved, 'Nessun Order recuperato.');
    // }

    @isTest
    public static void testcheckContractualEnvelopeValidato(){

        setup2();

        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        String result = HDT_LC_CanaleContattoIVRLogin.checkContractualEnvelope(ord.Id,'Username', 'Password');
        Test.stopTest();
        System.assertEquals('Validato', result, 'Non validato.');
    }

    @isTest
    public static void testcheckContractualEnvelopeNonValidato(){

        setup1();
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];

        Test.startTest();
        String result = HDT_LC_CanaleContattoIVRLogin.checkContractualEnvelope(ord.Id,'Username', 'Password');
        Test.stopTest();
        System.assertEquals('success', result, 'Non completato.');
    }

    @isTest
    public static void testcheckListenVo(){

        setup1();
        
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        Map<String,String> mapResp = HDT_LC_CanaleContattoIVRLogin.checkListenVo(ord.Id,'Username', 'Password');
        Test.stopTest();
        System.assertNotEquals('NonPossibile', mapResp.get('res'), 'Nessuna attività custom trovata.');
    }

    @isTest
    public static void testcheckListenVoEmpty(){

        setup1();
        
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];
        List<wrts_prcgvr__Activity__c> actList = [SELECT Id, Type__c FROM wrts_prcgvr__Activity__c];
        actList[0].Type__c = 'Approvazione Offerte';
        update actList;

        Test.startTest();
        Map<String,String> mapResp = HDT_LC_CanaleContattoIVRLogin.checkListenVo(ord.Id,'Username', 'Password');
        Test.stopTest();
        System.assertEquals('NonPossibile', mapResp.get('res'), 'Trovate attività custom.');
    }

    @isTest
    public static void testdownloadDocument(){

        setup1();
        
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];
        
        DocumentalActivity__c docAct = new DocumentalActivity__c();
        docAct.OrderId__c = ord.Id;
        insert docAct;

        DocumentSendTracking__c docSendTrack = new DocumentSendTracking__c();
        docSendTrack.Order__c = ord.Id;
        insert docSendTrack;

        Test.startTest();
        Map<String,String> mapResp = HDT_LC_CanaleContattoIVRLogin.downloadDocument(ord.Id,'Username', 'Password');
        Test.stopTest();
        System.assertNotEquals('NonPossibile', mapResp.get('res'), 'Nessun documento trovato.');
    }

    @isTest
    public static void testdownloadDocumentEmpty(){

        setup1();
        
        Test.startTest();
        Map<String,String> mapResp = HDT_LC_CanaleContattoIVRLogin.downloadDocument('','Username', 'Password');
        Test.stopTest();
        System.assertEquals('NonPossibile', mapResp.get('res'), 'Trovato order non previsto.');
    }

    @isTest
    public static void testcheckFinalConfirmationOfTheContract(){

        setup1();
        
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        ord = HDT_LC_CanaleContattoIVRLogin.checkFinalConfirmationOfTheContract(ord.Id);
        Test.stopTest();
        System.assertNotEquals(false, ord != null, 'Nessun order trovato.');
    }

    @isTest
    public static void testgetOrderSiblings(){

        setup1();
        
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WHERE (ParentOrder__c = null OR ParentOrder__c = '') WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        List<Order> childOrdList = HDT_LC_CanaleContattoIVRLogin.getOrderSiblings(ord.Id);
        Test.stopTest();
        System.assertNotEquals(true, childOrdList.isEmpty(), 'Nessun order figlio trovato.');
    }

    @isTest
    public static void testgetOrderSiblingsDocumentalActivity(){

        setup1();
        
        Order ord = [SELECT Id, RecordTypeId, MethodSignedAccepted__c FROM Order WHERE (ParentOrder__c = null OR ParentOrder__c = '') WITH SECURITY_ENFORCED LIMIT 1];
        
        Test.startTest();
        List<Order> childOrdList = HDT_LC_CanaleContattoIVRLogin.getOrderSiblingsDocumentalActivity(ord.Id);
        Test.stopTest();
        System.assertNotEquals(true, childOrdList.isEmpty(), 'Nessun order figlio trovato.');
    }

    @isTest
    public static void testgenerateUsernameAndPassword(){

        setup1();

        List<Order> ordList = [SELECT Id, RecordTypeId, MethodSignedAccepted__c, ParentOrder__c FROM Order WITH SECURITY_ENFORCED];
        String childOrdId = '';
        for(Order ord : ordList){
            if(ord.ParentOrder__c != null){
                ord.SignatureMethod__c = 'Vocal Order';
                childOrdId = ord.Id;
            }
            else{
                ord.Username__c = null;
            }
        }
        update ordList;
        Test.startTest();
        HDT_LC_CanaleContattoIVRLogin.generateUsernameAndPassword(childOrdId);
        Test.stopTest();
        //System.assertEquals('Validato', result, 'Non validato.');
    }

    @isTest
    public static void testgenerateUsernameAndPasswordChildParent(){

        setup1();
        // List<Account>  accResidenziale = [SELECT Id, Category__c FROM Account WHERE Category__c = 'Famiglie' WITH SECURITY_ENFORCED];
        List<Account>  accResidenziale = [SELECT Id, Category__c, BirthDate__c FROM Account WITH SECURITY_ENFORCED];
        accResidenziale[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HDT_RT_Residenziale').getRecordTypeId();
        accResidenziale[0].Category__c = 'Famiglie';
        accResidenziale[0].CustomerMarking__c = 'Persona fisica';
        accResidenziale[0].FiscalCode__c = 'MTTRRT61A20G479C';
        accResidenziale[0].BirthDate__c = Date.newInstance(1975, 12, 04);
        update accResidenziale;
        List<Sale__c> salesList = [SELECT Id, Channel__c FROM Sale__c WITH SECURITY_ENFORCED];
        List<Order> ordList = [SELECT Id, RecordTypeId, MethodSignedAccepted__c, ParentOrder__c FROM Order WITH SECURITY_ENFORCED];
        String childOrdId = '';
        String parentOrdId = '';
        for(Order ord : ordList){
            if(ord.ParentOrder__c != null){
                childOrdId = ord.Id;
            }
            else{
                ord.SignatureMethod__c = 'Vocal Order';
                ord.AccountId = accResidenziale[0].Id;
                ord.Sale__c = salesList[0].Id;
                parentOrdId = ord.Id;
                ord.Username__c = null;
            }
        }
        update ordList;
        Test.startTest();
        HDT_LC_CanaleContattoIVRLogin.generateUsernameAndPassword(childOrdId, parentOrdId);
        Test.stopTest();
        //System.assertEquals('Validato', result, 'Non validato.');
    }
}
