/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.UnusedLocalVariable, PMD.ExcessiveParameterList')
@isTest
public with sharing class HDT_SRV_GarbageManTst {
   
    public class HDT_SRV_SchedulableMock implements FinalizerContext {
        private ParentJobResult result;
        public HDT_SRV_SchedulableMock(ParentJobResult result) {
            this.result = result; 
        }
        public ParentJobResult getResult() {
            return result;
        }
        public String getRequestId() { return null;}
        public Id getAsyncApexJobId() {return null;}
        public Id getJobId() { return null;}
        public Exception getException() {return null;}

    }

    @TestSetup
	static void makeData() {
        
        createWebServiceConfiguration('AppointmentSearch', 'Callout:MulesoftBasePath/appointments/search', 'POST', 'testUser');
        createWebServiceConfiguration('AppointmentConfirm', 'Callout:MulesoftBasePath/appointments/confirm', 'POST', 'testUser');
        createWebServiceConfiguration('AppointmentView', 'Callout:MulesoftBasePath/appointments', 'GET', 'testUser');
        
        HDT_UTL_Constants constants = new HDT_UTL_Constants();
		HDT_UTL_DataFactoryTst.pClickCasePhase();

		insert new Wrts_prcgvr__PhaseTransition__c(Wrts_prcgvr__Code__c=Math.random()+'',wrts_prcgvr__ApexCalloutActions__c = 'HDT_WS_SegnalazioniTari(method="FacilityApproval");', wrts_prcgvr__CalloutTemplate__c = 'HDT_GestioneRifiuti', Wrts_prcgvr__DestinationPhase__c='Documentazione da validare', Wrts_prcgvr__OriginPhase__c='Bozza', Wrts_prcgvr__RecordTypeId__c=constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI, Wrts_prcgvr__RecordTypeName__c='HDT_GestioneRifiuti', Wrts_prcgvr__Type__c='A');

        Account acc = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','G1 - MMS Persona fisica','Famiglie')[0];

        Case caso = HDT_UTL_DataFactoryTst.createCase(1, false, acc.id, null, null, null, null)[0];
        caso.WasterCode__c = '';
        caso.StartAppointment__c = DateTime.now();
        caso.EndAppointment__c = DateTime.now();
        caso.RecordTypeId = constants.CASE_RECORDTYPEID_GENERICHE_ATTIVAZIONI;
        caso.Phase__c = '';
        caso.Status = '';
        caso.InvoicingStreetName__c = '';
        caso.InvoicingStreetNumber__c = '';
        caso.InvoicingPostalCode__c = '';
        caso.InvoicingCity__c = '';
        caso.WithdrawalFee__c = true;
        caso.Outcome__c = '';
        caso.CreatedDate = DateTime.now();
        caso.SupplyPostalCode__c = '';
        caso.SupplyStreetName__c = '';
        caso.SupplyStreetNumber__c = '';
        caso.SupplyStreetCode__c = '';
        caso.InvoicingStreetCode__c = '';
        caso.TypeOperation__c = '';
        insert caso;
	}

    public static void createWebServiceConfiguration (String name, String endpoint, String method, String user) {

		HDT_WebServiceConfiguration__c wsConfig = new HDT_WebServiceConfiguration__c(
			Name = name,
			Endpoint__c = endpoint,
			Method__c = method,
			User__c = user         
		);
		
		insert wsConfig;
	}
    
    @isTest
    static void testNotifyService(){

    Case caso = [SELECT Id, WasterCode__c, StartAppointment__c, EndAppointment__c, RecordTypeId, 
                Phase__c, Status, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingPostalCode__c, InvoicingCity__c, 
                WithdrawalFee__c, ServicePoint__c,CaseNumber, Outcome__c, CreatedDate, AccountCode__c,
                SupplyPostalCode__c, SupplyStreetName__c, SupplyStreetNumber__c, SupplyStreetCode__c,
                InvoicingStreetCode__c, TypeOperation__c 
                FROM Case LIMIT 1];

        Test.startTest();
        HDT_SRV_GarbageMan.HDT_QBL_NotifyService notifysrv = new HDT_SRV_GarbageMan.HDT_QBL_NotifyService();
        HDT_SRV_GarbageMan.HDT_QBL_NotifyService notify = new HDT_SRV_GarbageMan.HDT_QBL_NotifyService(caso.Id);
        notify.execute(((QueueableContext) null));

        FinalizerContext ctxSuccess = new HDT_SRV_SchedulableMock(ParentJobResult.SUCCESS);
        notify.execute(ctxSuccess);
        FinalizerContext ctxExeption = new HDT_SRV_SchedulableMock(ParentJobResult.UNHANDLED_EXCEPTION);
        notify.execute(ctxExeption);

        Test.stopTest();
        System.assertEquals(notify.errorCode,'08', 'TEST OK');
    }

    @isTest
    static void testScheduleAppointmentOk(){ 

        Case caso = [SELECT Id, WasterCode__c, StartAppointment__c, EndAppointment__c, RecordTypeId, 
                    Phase__c, Status, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingPostalCode__c, InvoicingCity__c, 
                    WithdrawalFee__c, ServicePoint__c,CaseNumber, Outcome__c, CreatedDate, AccountCode__c,
                    SupplyPostalCode__c, SupplyStreetName__c, SupplyStreetNumber__c, SupplyStreetCode__c,
                    InvoicingStreetCode__c, TypeOperation__c 
                    FROM Case LIMIT 1];
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse gbResponse = new HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse();
        HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest gbRequest = new HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest(caso);
        HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest gbRequest1 = new HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest(caso, '');

        Test.startTest();
        HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment scheduleApp = new HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment();

        HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment app = new HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment(caso.Id);
        
        FinalizerContext ctxSuccess = new HDT_SRV_SchedulableMock(ParentJobResult.SUCCESS);
        app.execute(ctxSuccess);
        
        
        HDT_SRV_GarbageMan.scheduleAppointment(caso.Id);
        Test.stopTest();
    	System.assertEquals(app.errorCode,'99', 'TEST OK');
        
    }
    
    @isTest
    static void testScheduleAppointmentKo(){ 

        Case caso = [SELECT Id, WasterCode__c, StartAppointment__c, EndAppointment__c, RecordTypeId, 
                    Phase__c, Status, InvoicingStreetName__c, InvoicingStreetNumber__c, InvoicingPostalCode__c, InvoicingCity__c, 
                    WithdrawalFee__c, ServicePoint__c,CaseNumber, Outcome__c, CreatedDate, AccountCode__c,
                    SupplyPostalCode__c, SupplyStreetName__c, SupplyStreetNumber__c, SupplyStreetCode__c,
                    InvoicingStreetCode__c, TypeOperation__c 
                    FROM Case LIMIT 1];
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        mock.successfullReturn=false;
        Test.setMock(HttpCalloutMock.class, mock);
        
        HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse gbResponse = new HDT_SRV_GarbageMan.HDT_WRP_GarbageManResponse();
        HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest gbRequest = new HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest(caso);
        HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest gbRequest1 = new HDT_SRV_GarbageMan.HDT_WRP_GarbageManRequest(caso, '');

        Test.startTest();
        
        HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment app = new HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment(caso.Id);
        
        FinalizerContext ctxExeption = new HDT_SRV_SchedulableMock(ParentJobResult.UNHANDLED_EXCEPTION);
        app.execute(ctxExeption);
        HDT_SRV_GarbageMan.scheduleAppointment(caso.Id);
        Test.stopTest();
    	System.assertEquals(app.errorCode,'99', 'TEST OK');
        
    }

}