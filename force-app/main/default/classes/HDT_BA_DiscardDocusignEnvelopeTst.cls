@IsTest
public with sharing class HDT_BA_DiscardDocusignEnvelopeTst {
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
        Id accId = accs[0].id;
        
        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
        contacts[0].Company__c='MMS';
        insert contacts;
        List<Order> orderList = HDT_UTL_DataFactoryTst.createOrder(4, false, accId, 'Bozza');
        orderList[0].Name = 'Status_Annullato';
        orderList[0].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orderList[0].Contact__c = contacts[0].Id;
        orderList[0].SignatureMethod__c = 'OTP Remoto';
        orderList[1].Name = 'Fase_Annullato';
        orderList[1].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orderList[1].Contact__c = contacts[0].Id;
        orderList[1].SignatureMethod__c = 'OTP Remoto';
        orderList[2].Name = 'No_DocumentTracking';
        orderList[2].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orderList[2].Contact__c = contacts[0].Id;
        orderList[2].SignatureMethod__c = 'OTP Remoto';
        orderList[3].Name = 'No_Signature_Method';
        orderList[3].RecordTypeId = constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orderList[3].Contact__c = contacts[0].Id;
        orderList[3].SignatureMethod__c = 'OTP Coopresenza';
        insert orderList;

        List<DocumentSendTracking__c> dtsList = new List<DocumentSendTracking__c>();
        dtsList.add(new DocumentSendTracking__c(
            Order__c = orderList[0].Id,
            EnvelopeId__c = 'idPlico_1',
            SendMode__c = 'E-Mail'
        ));
        dtsList.add(new DocumentSendTracking__c(
            Order__c = orderList[1].Id,
            EnvelopeId__c = 'idPlico_2',
            SendMode__c = 'E-Mail'
        ));
        dtsList.add(new DocumentSendTracking__c(
            Order__c = orderList[3].Id,
            EnvelopeId__c = 'idPlico_3',
            SendMode__c = 'E-Mail'
        ));
        insert dtsList;
        insert new DocusignSettings__c(CustomerEnviromentId__c = 'HERA-TEST');
    }

    @IsTest
    public static void executeTest1(){
        Order o = [SELECT Id fROM Order WHERE NAme = 'Status_Annullato'];
        o.Status = 'Annullato';
        update o;
        System.assertEquals(true, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Settaggio flag primo test non funzionante');
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DiscardDocusignResponse());
        Test.startTest();
            HDT_BA_DiscardDocusignEnvelope batch = new HDT_BA_DiscardDocusignEnvelope();
            batch.execute(null);
        Test.stopTest();
        System.assertEquals(false, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Primo test non funzionante');
    }

    @IsTest
    public static void executeTest2(){
        Order o = [SELECT Id fROM Order WHERE NAme = 'Fase_Annullato'];
        o.Phase__c = 'Annullato';
        update o;
        System.assertEquals(true, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Settaggio flag secondo test non funzionante');
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DiscardDocusignResponse());
        Test.startTest();
            HDT_BA_DiscardDocusignEnvelope batch = new HDT_BA_DiscardDocusignEnvelope();
            batch.execute(null);
        Test.stopTest();
        System.assertEquals(false, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Secondo test non funzionante');
    }

    @IsTest
    public static void executeTest3(){
        Order o = [SELECT Id fROM Order WHERE NAme = 'No_DocumentTracking'];
        o.Phase__c = 'Annullato';
        update o;
        System.assertEquals(true, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Settaggio flag terzo test non funzionante');
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DiscardDocusignResponse());
        Test.startTest();
            HDT_BA_DiscardDocusignEnvelope batch = new HDT_BA_DiscardDocusignEnvelope();
            batch.execute(null);
        Test.stopTest();
        System.assertEquals(false, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Terzo test non funzionante');
    }

    @IsTest
    public static void executeTest4(){
        Order o = [SELECT Id fROM Order WHERE NAme = 'No_Signature_Method'];
        o.Phase__c = 'Annullato';
        update o;
        System.assertEquals(false, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Id = :o.Id].DiscardDocusignEnvelope__c, 'Settaggio flag quarto test non funzionante');
        Test.setMock(HttpCalloutMock.class, new HDT_SRV_DiscardDocusignResponse());
        Test.startTest();
            HDT_BA_DiscardDocusignEnvelope batch = new HDT_BA_DiscardDocusignEnvelope();
            batch.execute(null);
        Test.stopTest();
        System.assertEquals(false, [SELECT DiscardDocusignEnvelope__c FROM Order WHERE Name = 'No_Signature_Method'].DiscardDocusignEnvelope__c, 'Quarto test non funzionante');
    }


    public class HDT_SRV_DiscardDocusignResponse implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            Set<String> acceptedIdTrans = new Set<String>{'idPlico_1','idPlico_2'};
            Map<String,String> requestMap = (Map<String,String>) JSON.deserialize(request.getBody(), Map<String,String>.class);
            System.assert(acceptedIdTrans.contains(requestMap.get('transactionId')));
            HTTPResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
        }
    }
}