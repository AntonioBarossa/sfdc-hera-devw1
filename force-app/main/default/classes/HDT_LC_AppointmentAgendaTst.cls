@IsTest
public with sharing class HDT_LC_AppointmentAgendaTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void createEnviroment(){
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contacts=HDT_UTL_DataFactoryTst.createContact(1, true, acctList[0].Id);
		List<ServicePoint__c> servPoints=HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contract> contracts=HDT_UTL_DataFactoryTst.createContract(1, true, acctList[0].Id);
        List<Product2> prods=HDT_UTL_DataFactoryTst.createProduct2(1, true);
        List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(2, true, acctList[0].Id, 'Attiva');
        Id pricebookId=Test.getStandardPricebookId();
        List<Order> orderWithPricebook=HDT_UTL_DataFactoryTst.createOrderWithPricebook(2, false, acctList[0].Id, sales, pricebookId);
        orderWithPricebook[1].RecordTypeId=constants.ORDER_RECORDTYPEID_ORDERDOSSIER;
        orderWithPricebook[1].CommercialProduct__c=prods[0].Id;
        insert orderWithPricebook;
        List<Order> orders=HDT_UTL_DataFactoryTst.createOrder(1, true, acctList[0].Id, 'Bozza');
        List<Case> cases=HDT_UTL_DataFactoryTst.createCase(1, false, acctList[0].Id, contacts[0].Id, servPoints[0].Id, contracts[0].Id, orders[0].Id);
        cases[0].RecordTypeId=constants.CASE_RECORDTYPEID_DOCUMENTALECOPIACONTRATTO;
        cases[0].HerokuPracticeCode__c = 'TEST_SALESFORCE';
        insert cases;	
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList[0].isAtoA__c = true;
        actList[0].Type__c = 'Presa Appuntamento';
        actList[0].AppointmentCompetence__c = 'Vendita';
        actList[0].isSelfAppointment__c = false;
        actList[0].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
        actList[0].Order__c = orders[0].Id;
        actList[0].Case__c = cases[0].Id;
        insert actList;
        actList = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Id = :actList[0].Id];
        System.assertEquals('Creata', actList[0].wrts_prcgvr__Status__c, 'Stato attività custom non inizializzato correttamente');
    }

    @IsTest
    public static void executeFirstSearch(){
        String methodName = 'executeFirstSearch: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0165'));
        Test.startTest();
            HDT_LC_AppointmentAgenda.handleSearch(activity.Id, 'FirstSearch', Date.today(), '18:00/19:00');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c,AppointmentTimeSlotToConfirm__c,AppointmentDateToConfirm__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Presa appuntamento in corso', activity.wrts_prcgvr__Status__c, methodName + 'Stato non settato correttamente');
        System.assertEquals('6666', activity.AppointmentCode__c, methodName + 'Codice Appuntamento non settato correttamente');
        System.assertEquals('19:00/20:00', activity.AppointmentTimeSlotToConfirm__c, methodName + 'Fascia Oraria Preferita non settata');
        System.assertEquals(Date.newInstance(2022, 12, 31), activity.AppointmentDateToConfirm__c, methodName + 'Data appuntamento non settata correttamente');
    }

    @IsTest
    public static void executeNewSlot(){
        String methodName = 'executeNewSlot: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0165'));
        Test.startTest();
            HDT_LC_AppointmentAgenda.handleSearch(activity.Id, 'NewSlot', Date.today(), '18:00/19:00');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Presa appuntamento in corso', activity.wrts_prcgvr__Status__c, methodName + 'Lo stato è stato modificato');
        System.assertEquals('6666', activity.AppointmentCode__c, methodName + 'Il codice appuntamento è stato modificato');
    }

    @IsTest
    public static void executeNewSlotModify(){
        String methodName = 'executeNewSlotModify: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0190'));
        Test.startTest();
            HDT_LC_AppointmentAgenda.handleSearch(activity.Id, 'NewSlotModify', Date.today(), '18:00/19:00');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento confermato', activity.wrts_prcgvr__Status__c, methodName + 'Lo stato è stato modificato');
        System.assertEquals('6666', activity.AppointmentCode__c, methodName + 'Il codice appuntamento è stato modificato');
    }

    @IsTest
    public static void executeHandleCancellation(){
        String methodName = 'executeHandleCancellation: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('xxx'));
        Test.startTest();
            HDT_LC_AppointmentAgenda.handleCancellation(activity.Id, '6666');
        Test.stopTest();
        activity = [SELECT Id,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Annullata', activity.wrts_prcgvr__Status__c, methodName + 'Stato non settato correttamente');
    }

    @IsTest
    public static void executeHandleConfirm(){
        String methodName = 'executeHandleConfirm: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0175'));
        Test.startTest();
            HDT_LC_AppointmentAgenda.handleConfirm(activity.Id, '{"data" : "31/12/2021","fascia" : "15:00/16:00","codice" : "2222","dataLimite" : "28/12/2021","oraLimite" : "19:00","stima" :"00:30:00"}');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c,AppoitmentTimeSlotConfirmed__c,AppointmentDate__c,MaxDateModificationAppointment__c,MaxTimeModificationAppointment__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento confermato', activity.wrts_prcgvr__Status__c, methodName + 'Stato non settato correttamente');
        System.assertEquals('2222', activity.AppointmentCode__c, methodName + 'Codice Appuntamento non settato correttamente');
        System.assertEquals('15:00/16:00', activity.AppoitmentTimeSlotConfirmed__c, methodName + 'Fascia Oraria Preferita non settata');
        System.assertEquals(Date.newInstance(2021, 12, 31), activity.AppointmentDate__c, methodName + 'Data appuntamento non settata correttamente');
        System.assertEquals(Date.newInstance(2021, 12, 28), activity.MaxDateModificationAppointment__c, methodName + 'Data limite massimo cancellazione appuntamento non settata correttamente');
        System.assertEquals('19:00', activity.MaxTimeModificationAppointment__c, methodName + 'Tempolimite massimo cancellazione appuntamento non settato correttamente');
    }

    @IsTest
    public static void executeGetActivity(){
        String methodName = 'executeHandlehandleConfirmError: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Id recordId = activity.Id;
        Test.startTest();
            String response = HDT_LC_AppointmentAgenda.getActivity(recordId, new List<String>{'Id', 'wrts_prcgvr__Status__c'});
            activity = (wrts_prcgvr__Activity__c)JSON.deserialize(response, wrts_prcgvr__Activity__c.class);
            System.assertEquals(recordId, activity.Id, methodName + 'Non è stata lanciata l\'eccezione.');
        Test.stopTest();
    }

    @IsTest
    public static void executeCheckCryptId(){
        String methodName = 'executeGetEncryptedIdy: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c, CustomRecordId__c FROM wrts_prcgvr__Activity__c];
        Test.startTest();
            String encryptedId = HDT_LC_AppointmentAgenda.getEncryptedId(activity.Id);
            activity.CustomRecordId__c=encryptedId;
            update activity;
            String activityJson = HDT_LC_AppointmentAgenda.getDecryptedId(encryptedId,new List<String>{'Id'});
            wrts_prcgvr__Activity__c retrievedActivity = (wrts_prcgvr__Activity__c) JSON.deserialize(activityJson,wrts_prcgvr__Activity__c.class);
            System.assertEquals(activity.Id, retrievedActivity.Id, methodName +'La decodifica non ha funzionato');
        Test.stopTest();
    }

    @IsTest
    public static void executeErrorCall(){
        String methodName = 'executeHandleCancellationError: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
        activity.AppointmentCode__c = '6666';
        update activity;
        Boolean isAuraHandledException = false;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock(true));
        Test.startTest();
            try{
                HDT_LC_AppointmentAgenda.handleCancellation(activity.Id, '6666');
            }catch(AuraHandledException e){
                isAuraHandledException = true;
            }
            try{
                HDT_LC_AppointmentAgenda.handleSearch(activity.Id, 'NewSlot', Date.today(), '18:00/19:00');
                isAuraHandledException = false;
            }catch(AuraHandledException e){
                isAuraHandledException = isAuraHandledException;
            }
            try{
                HDT_LC_AppointmentAgenda.handleConfirm(activity.Id, '6666');
                isAuraHandledException = false;
            }catch(AuraHandledException e){
                isAuraHandledException = isAuraHandledException;
            }   
            System.assertEquals(true, isAuraHandledException, methodName + 'Non è stata lanciata l\'eccezione.');
        Test.stopTest();
    }

    public class HDT_LC_AppointmentAgendaMock implements HttpCalloutMock{
        private String bodyString;
        private Boolean throwError;

        public HDT_LC_AppointmentAgendaMock(String codiceFlusso){
            this.throwError = false;
            this.bodyString = '{"responseAppuntamento":{"codCaus" : "test" ,"codFlusso" : "'+ codiceFlusso + '" ,"desEsitoConf" : "1" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "0" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "16:00/17:00","codiceApp" : "3333","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "17:00/18:00","codiceApp" : "4444","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "18:00/19:00","codiceApp" : "5555","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "19:00/20:00","codiceApp" : "6666","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}}';
        }

        public HDT_LC_AppointmentAgendaMock(Boolean errorCall){
            this.throwError = true;
            this.bodyString = '{"responseAppuntamento":{"codCaus" : "test" ,"codFlusso" : "x" ,"desEsitoConf" : "x" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "x" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "16:00/17:00","codiceApp" : "3333","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "17:00/18:00","codiceApp" : "4444","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "18:00/19:00","codiceApp" : "5555","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "19:00/20:00","codiceApp" : "6666","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}}';
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.bodyString);
            if (this.throwError){
                response.setStatusCode(403);
                response.setStatus('ERROR');
            }else{
                response.setStatusCode(200);
                response.setStatus('OK');
            } 
            return response;
        }
    }

    
}