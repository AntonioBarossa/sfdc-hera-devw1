@IsTest
public with sharing class HDT_SRV_AppointmentAgendaTst {
    private static HDT_SRV_AppointmentAgenda agenda = new HDT_SRV_AppointmentAgenda();
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
        cases[0].DistributorPracticeCode__c = 'COD_PRAT_TEST';
        insert cases;	
        List<wrts_prcgvr__Activity__c> actList = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acctList[0].Id);
        actList[0].isAtoA__c = true;
        actList[0].Type__c = 'Presa Appuntamento';
        actList[0].AppointmentCompetence__c = 'Vendita';
        actList[0].isSelfAppointment__c = true;
        actList[0].RecordTypeId = constants.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
        actList[0].Order__c = orders[0].Id;
        actList[0].Case__c = cases[0].Id;
        insert actList;
        actList = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Id = :actList[0].Id];
        System.assertEquals('Creata', actList[0].wrts_prcgvr__Status__c, 'Stato attività custom non inizializzato correttamente');
    }

    @isTest
    public static void executeGetActivity(){
        String methodName = 'executeGetActivity: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id FROM wrts_prcgvr__Activity__c];
        Id recordId = activity.Id;
        Test.startTest();
            String response = agenda.getActivity(recordId, new List<String>{'Id', 'wrts_prcgvr__Status__c'});
            activity = (wrts_prcgvr__Activity__c)JSON.deserialize(response, wrts_prcgvr__Activity__c.class);
            System.assertEquals(recordId, activity.Id, methodName + 'Non è stata lanciata l\'eccezione.');
        Test.stopTest();
    }

    @IsTest
    public static void executeHandleFirstSearch(){
        String methodName = 'executeHandleFirstSearch: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0165',true));
        Test.startTest();
            agenda.handleFirstSearch(activity.Id, Date.today(), '18:00/19:00');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c,AppointmentTimeSlotToConfirm__c,AppointmentDateToConfirm__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Presa appuntamento in corso', activity.wrts_prcgvr__Status__c, methodName + 'Stato non settato correttamente');
        System.assertEquals('6666', activity.AppointmentCode__c, methodName + 'Codice Appuntamento non settato correttamente');
        System.assertEquals('19:00/20:00', activity.AppointmentTimeSlotToConfirm__c, methodName + 'Fascia Oraria Preferita non settata');
        System.assertEquals(Date.newInstance(2022, 12, 31), activity.AppointmentDateToConfirm__c, methodName + 'Data appuntamento non settata correttamente');
    }

    @IsTest
    public static void executeHandleNewSlot(){
        String methodName = 'executeHandleNewSlot: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0165',true));
        Test.startTest();
            agenda.handleNewSlot(activity.Id, Date.today(), '18:00/19:00');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Presa appuntamento in corso', activity.wrts_prcgvr__Status__c, methodName + 'Lo stato è stato modificato');
        System.assertEquals('6666', activity.AppointmentCode__c, methodName + 'Il codice appuntamento è stato modificato');
    }

    @IsTest
    public static void executeHandleNewSlotModify(){
        String methodName = 'executeHandleNewSlotModify: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0190',true));
        Test.startTest();
            agenda.handleNewSlotModify(activity.Id, Date.today(), '18:00/19:00');
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
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('xxx',true));
        Test.startTest();
            agenda.handleCancellation(activity.Id, '6666');
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
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0175',true));
        Test.startTest();
            agenda.handleConfirm(activity.Id, '{"data" : "31/12/2021","fascia" : "15:00/16:00","codice" : "2222","dataLimite" : "28/12/2021","oraLimite" : "19:00","stima" :"00:30:00"}');
        Test.stopTest();
        activity = [SELECT Id,AppointmentCode__c,wrts_prcgvr__Status__c,AppoitmentTimeSlotConfirmed__c,AppointmentDate__c,MaxDateModificationAppointment__c,MaxTimeModificationAppointment__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento confermato', activity.wrts_prcgvr__Status__c, methodName + 'Stato non settato correttamente');
        System.assertEquals('2222', activity.AppointmentCode__c, methodName + 'Codice Appuntamento non settato correttamente');
        System.assertEquals('15:00/16:00', activity.AppoitmentTimeSlotConfirmed__c, methodName + 'Fascia Oraria Preferita non settata');
        System.assertEquals(Date.newInstance(2021, 12, 31), activity.AppointmentDate__c, methodName + 'Data appuntamento non settata correttamente');
        System.assertEquals(Date.newInstance(2021, 12, 28), activity.MaxDateModificationAppointment__c, methodName + 'Data limite massimo cancellazione appuntamento non settata correttamente');
        System.assertEquals('19:00', activity.MaxTimeModificationAppointment__c, methodName + 'Tempolimite massimo cancellazione appuntamento non settato correttamente');
    }

    @isTest
    public static void executeAppointmentUpdateSales_0200(){
        String methodName = 'executeAppointmentUpdateSales_0200: ';
        Map<String,String> inputMap = createRequestHeroku('Sales', '0200', null, null);
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            agenda.handleAppointmentUpdate(inputMap);
        Test.stopTest();
        activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento confermato', activity.wrts_prcgvr__Status__c,methodName+ 'messaggio di errore non corretto');
    }

    @isTest
    public static void executeAppointmentUpdatePostSales_0200(){
        String methodName = 'executeAppointmentUpdatePostSales_0200: ';
        Map<String,String> inputMap = createRequestHeroku('PostSales', '0200', null, null);
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            agenda.handleAppointmentUpdate(inputMap);
        Test.stopTest();
        activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento confermato', activity.wrts_prcgvr__Status__c,methodName+ 'messaggio di errore non corretto');
    }

    @isTest
    public static void executeAppointmentUpdateError_0200(){
        String methodName = 'executeAppointmentUpdateError_0200: ';
        Map<String,String> inputMap = createRequestHeroku('No process', '0200', null, null);
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            String response = agenda.handleAppointmentUpdate(inputMap);
            System.assertEquals('Tipo processo non gestito. (Valore ricevuto: \'No process\', valori consentiti: \'sales\',\'postSales\')', response, methodName + 'messaggio di errore non corretto');
        Test.stopTest();
    }

    @isTest
    public static void executeAppointmentDistributor_0210(){
        String methodName = 'executeAppointmentDistributor_0210: ';
        Map<String,String> inputMap = createRequestHeroku(null, '0210', '1', '1111');
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            agenda.handleAppointmentUpdate(inputMap);
        Test.stopTest();
        activity = [SELECT Id, wrts_prcgvr__Status__c,AppointmentCompetence__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento di competenza Distributore', activity.wrts_prcgvr__Status__c,methodName+ 'stato non corretto');
        System.assertEquals('Distributore', activity.AppointmentCompetence__c,methodName+ 'competenza appuntamento non corretta');
    }

    @isTest
    public static void executeAppointmentClient_0210(){
        String methodName = 'executeAppointmentClient_0210: ';
        Map<String,String> inputMap = createRequestHeroku(null, '0210', '0', '1111');
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            agenda.handleAppointmentUpdate(inputMap);
        Test.stopTest();
        List<wrts_prcgvr__Activity__c> activities = [SELECT Id, wrts_prcgvr__Status__c,AppointmentCompetence__c FROM wrts_prcgvr__Activity__c ORDER BY CreatedDate DESC];
        System.assertEquals('Creata', activities[0].wrts_prcgvr__Status__c,methodName+ 'Stato nuova activity non corretto');
        System.assertEquals('Annullata', activities[1].wrts_prcgvr__Status__c,methodName+ 'Stato vecchia activity non corretto');
        
    }

    @isTest
    public static void executeAppointmentOk_0210(){
        String methodName = 'executeAppointmentOk_0210: ';
        Map<String,String> inputMap = createRequestHeroku(null, '0210', '4', '1111');
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            agenda.handleAppointmentUpdate(inputMap);
        Test.stopTest();
        activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        System.assertEquals('Appuntamento eseguito', activity.wrts_prcgvr__Status__c,methodName+ 'stato non corretto');
    }

    @isTest
    public static void executeAppointmentError_0210(){
        String methodName = 'executeAppointmentError_0210: ';
        Map<String,String> inputMap = createRequestHeroku(null, '0210', '5', '1111');
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        activity.AppointmentCode__c = '1111';
        update activity;
        Test.startTest();
            String response = agenda.handleAppointmentUpdate(inputMap);
            System.assertEquals('Codice esito non valido. (Valore ricevuto: \'5\', valori consentiti: \'0\',\'1\',\'2\',\'3\',\'4\')', response, methodName + 'messaggio di errore non corretto');
        Test.stopTest();
    }

    @isTest
    public static void executeAppointmentUpdateError(){
        String methodName = 'executeAppointmentUpdateError: ';
        Map<String,String> inputMap = createRequestHeroku(null, 'xxxx', null, null);
        Test.startTest();
            String response = agenda.handleAppointmentUpdate(inputMap);
            System.assertEquals('Codice flusso non riconosciuto.', response, methodName + 'primo messaggio di errore non corretto');
            inputMap = createRequestHeroku('x', null, 'x', 'x');
            response = agenda.handleAppointmentUpdate(inputMap);
            System.assertEquals('Codice flusso obbligatorio.', response, methodName + 'secondo messaggio di errore non corretto');
            
        Test.stopTest();
    }

    @IsTest
    public static void executeFirstSearchError(){
        String methodName = 'executeFirstError: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0165',false));
        Test.startTest(); 
            String response = agenda.handleFirstSearch(activity.Id, Date.today(), '18:00/19:00');  
            System.assertEquals('COMPETENZA DISTRIBUTORE', response, methodName + 'Non è stata lanciata l\'eccezione.');
        Test.stopTest();
    }

    @IsTest
    public static void executeNewSlotModifyError(){
        String methodName = 'executeNewSlotModify: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Appuntamento confermato';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0190', false));
        Test.startTest();
            String response = agenda.handleNewSlotModify(activity.Id, Date.today(), '18:00/19:00');
            System.assertEquals('ERRORE MODIFICA', response, methodName + 'Non è stata lanciata l\'eccezione.');
        Test.stopTest();
    }

    @IsTest
    public static void executeHandleConfirmError(){
        String methodName = 'executeHandleConfirmError: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        activity.wrts_prcgvr__Status__c = 'Presa appuntamento in corso';
        activity.AppointmentCode__c = '6666';
        update activity;
        Test.setMock(HttpCalloutMock.class, new HDT_LC_AppointmentAgendaMock('0175', false));
        Test.startTest();
            String response = agenda.handleConfirm(activity.Id, '{"data" : "31/12/2021","fascia" : "15:00/16:00","codice" : "2222","dataLimite" : "28/12/2021","oraLimite" : "19:00","stima" :"00:30:00"}');   
            System.assertEquals('ERRORE CONFERMA', response, methodName + 'Non è stata lanciata l\'eccezione.');
        Test.stopTest();
    }

    @IsTest
    public static void executeCriptId(){
        String methodName = 'executeCriptId: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.startTest();
            String encryptedId = agenda.criptId(activity.Id);
            try{
                String activityJson = agenda.getCryptoActivity(encryptedId,new List<String>{'Id'});
            }catch(Exception e){

            }
            activity.CustomRecordId__c = encryptedId;
            update activity;
            String activityJson = agenda.getCryptoActivity(encryptedId,new List<String>{'Id'});
            wrts_prcgvr__Activity__c retrievedActivity = (wrts_prcgvr__Activity__c) JSON.deserialize(activityJson,wrts_prcgvr__Activity__c.class);
            System.assertEquals(activity.Id, retrievedActivity.Id, 'La decodifica non ha funzionato');
        Test.stopTest();
    }

    @IsTest
    public static void executeSetContactData(){
        String methodName = 'executeSetContactData: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.startTest();
            Contact cont = new Contact(FiscalCode__c = 'IT01234567891' , VATNumber__c ='');
            agenda.setContactData(activity, cont);
            System.assertEquals('01234567891', activity.VATNumber__c,methodName+'Scenario fiscal code = IT_PI non valido');
            cont = new Contact(FiscalCode__c = '01234567891' , VATNumber__c ='');
            agenda.setContactData(activity, cont);
            System.assertEquals('01234567891', activity.VATNumber__c,methodName+'Scenario fiscal code = PI non valido');
            cont = new Contact(FiscalCode__c = 'DFAVFE45T13S665T' , VATNumber__c ='');
            agenda.setContactData(activity, cont);
            System.assertEquals(cont.FiscalCode__c, activity.FiscalCode__c,methodName+'Scenario fiscal code = CF non valido');
            cont = new Contact(FiscalCode__c = 'DFAVFE45T13S665T' , VATNumber__c ='01234567891');
            agenda.setContactData(activity, cont);
            System.assertEquals(cont.FiscalCode__c, activity.FiscalCode__c,methodName+'Scenario fiscal code = CF e PI valorizzato non valido (CF Non Valido)');
            System.assertEquals(cont.VATNumber__c, activity.VATNumber__c,methodName+'Scenario fiscal code = CF e PI valorizzato non valido (PI Non Valido)');
            cont = new Contact(FiscalCode__c = 'DFAVFE45T13S665T' , VATNumber__c ='IT01234567891');
            agenda.setContactData(activity, cont);
            System.assertEquals(cont.FiscalCode__c, activity.FiscalCode__c,methodName+'Scenario fiscal code = CF e PI valorizzato (con IT) non valido (CF Non Valido)');
            System.assertEquals('01234567891', activity.VATNumber__c,methodName+'Scenario fiscal code = CF e PI valorizzato (con IT) non valido (PI Non Valido)');
            cont = new Contact(FiscalCode__c = '' , VATNumber__c ='01234567891');
            agenda.setContactData(activity, cont);
            System.assertEquals(cont.VATNumber__c, activity.VATNumber__c,methodName+'Scenario Solo PI valorizzato non valido');
            cont = new Contact(FiscalCode__c = '' , VATNumber__c ='01234567891');
            agenda.setContactData(activity, cont);
            System.assertEquals('01234567891', activity.VATNumber__c,methodName+'Scenario Solo PI (con IT) valorizzato non valido');
            cont = new Contact(FiscalCode__c = '' , VATNumber__c ='');
            agenda.setContactData(activity, cont);
            System.assertEquals('', activity.FiscalCode__c,methodName+'Scenario partita iva e cf non valorizzati');
            System.assertEquals('', activity.VATNumber__c,methodName+'Scenario partita iva e cf non valorizzati');
        Test.stopTest();
    }

    @IsTest
    public static void executeUpdateExtraSystemAppointmentKO(){
        String methodName = 'executeUpdateExtraSystemAppointmentKO: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, Case__c FROM wrts_prcgvr__Activity__c];
        activity.isAtoA__c = false;
        update activity;
        Test.startTest();
            agenda.updateExtraSystemAppointment('Esito KO da DL', activity.Case__c);
            activity = [SELECT Id, Case__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.stopTest();
        System.assertEquals('Appuntamento non eseguito', activity.wrts_prcgvr__Status__c, methodName + 'Lo stato dell\'activity non è stato correttamente aggiornato.');
    }

    @IsTest
    public static void executeUpdateExtraSystemAppointmentOK(){
        String methodName = 'executeUpdateExtraSystemAppointmentOK: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, Case__c FROM wrts_prcgvr__Activity__c];
        activity.isAtoA__c = false;
        update activity;
        Test.startTest();
            agenda.updateExtraSystemAppointment('Esito OK da DL', activity.Case__c);
            activity = [SELECT Id, Case__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.stopTest();
        System.assertEquals('Appuntamento eseguito', activity.wrts_prcgvr__Status__c, methodName + 'Lo stato dell\'activity non è stato correttamente aggiornato.');
    }

    @IsTest
    public static void executeUpdateExtraSystemAppointmentNoState(){
        String methodName = 'executeUpdateExtraSystemAppointmentNoState: ';
        wrts_prcgvr__Activity__c activity = [SELECT Id, Case__c FROM wrts_prcgvr__Activity__c];
        Test.startTest();
            agenda.updateExtraSystemAppointment('Ammissibilità OK', activity.Case__c);
            activity = [SELECT Id, Case__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c];
        Test.stopTest();
        System.assertEquals('Creata', activity.wrts_prcgvr__Status__c, methodName + 'Lo stato è stato aggiornato, mentre doveva restare invariato.');
    }

    private static Map<String,String> createRequestHeroku(String processType,String codiceFlusso,String outcome, String codiceApp){
        Map<String,String> newMap = new Map<String,String>();
        Map<String,String> herokuKeysMap = HDT_UTL_AppointmentSetting.getResponseKeysMap();
        for (String key :herokuKeysMap.keySet()){
            String newMapKey = herokuKeysMap.get(key);
            switch on newMapKey {
                when 'processType'{
                    if (String.isNotEmpty(processType)){
                        newMap.put(key,processType);
                    }
                }
                when 'flowCode' {
                    newMap.put(key,codiceFlusso);
                }
                when 'outcome' {
                    if (String.isNotEmpty(outcome)){
                        newMap.put(key,outcome);
                    }
                }
                when 'appointmentSlot'{
                    newMap.put(key,'10:00/11:00');
                }
                when 'appointmentDate'{
                    Date today = Date.today().addDays(2);
                    String day = today.day() < 10 ? '0'+String.valueOf(today.day()) : String.valueOf(today.day());
                    String month = today.month() < 10 ? '0'+String.valueOf(today.month()) : String.valueOf(today.month());
                    newMap.put(key,day+'/'+month+'/'+today.year());
                }
                when 'appointmentCode'{
                    if (String.isNotEmpty(codiceApp)){
                        newMap.put(key,codiceApp);
                    }
                }
                when 'distributorCode'{
                    newMap.put(key,'COD_PRAT_TEST');
                }
                when else {
                    newMap.put(key,'TEST');
                }
            }
        }
        return newMap;
    }

    public class HDT_LC_AppointmentAgendaMock implements HttpCalloutMock{
        private String bodyString;
        private Boolean throwError;

        public HDT_LC_AppointmentAgendaMock(Boolean errorCall){
            this.throwError = true;
            this.bodyString = '{"responseAppuntamento":{"codCaus" : "test" ,"codFlusso" : "x" ,"desEsitoConf" : "x" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "x" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "16:00/17:00","codiceApp" : "3333","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "17:00/18:00","codiceApp" : "4444","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "18:00/19:00","codiceApp" : "5555","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "19:00/20:00","codiceApp" : "6666","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}}';
        }

        public HDT_LC_AppointmentAgendaMock(String codiceFlusso, Boolean success){
            this.throwError = false;
            String esito = !success ? '0' : '1';
            String gestApp = !success ? '1' : '0';
            this.bodyString = '{"responseAppuntamento":{"codCaus" : "test" ,"codFlusso" : "'+ codiceFlusso + '" ,"desEsitoConf" : "'+ esito +'" ,"documentkey" : "test" ,"errInvioDis" : "TEST MESSAGGIO DI ERRORE" ,"extAnnotazioni" : "test" ,"rifExt" : "xxx" ,"rifRich" : "x" ,"zCodCausApp" : "x" ,"zGestApp" : "'+ gestApp +'" ,"appuntamento" : [{"appData" : "2022-12-31","appFasciaOrario" : "15:00/16:00","codiceApp" : "2222","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "16:00/17:00","codiceApp" : "3333","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "17:00/18:00","codiceApp" : "4444","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "18:00/19:00","codiceApp" : "5555","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"},{"appData" : "2022-12-31","appFasciaOrario" : "19:00/20:00","codiceApp" : "6666","zLimApp" : "2022-12-28","zLimAppOra" : "19:00:00","zStimaDurApp" :"00:30:00"}]}}';
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
