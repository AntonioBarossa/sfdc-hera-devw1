/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 16-11-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_AppointmentTariAgendaTst {
   
    @TestSetup
    static void makedata(){     
     
        createWebServiceConfiguration('AppointmentSearch', 'Callout:MulesoftBasePath/appointments/search', 'POST', 'testUser');
        createWebServiceConfiguration('AppointmentConfirm', 'Callout:MulesoftBasePath/appointments/confirm', 'POST', 'testUser');
        createWebServiceConfiguration('AppointmentView', 'Callout:MulesoftBasePath/appointments', 'GET', 'testUser');

        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickCasePhase();
        String rtName = 'HDT_RT_Segnalazioni';
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Da Inviare', 'Bozza', rtId, rtName,'A','','','');

        List<wrts_prcgvr__FieldsTemplate__c> fieldTemplates = HDT_UTL_DataFactoryTst.createFieldsTemplate(2,false);
        fieldTemplates[0].wrts_prcgvr__Code__c = '3ae1147a-6f0b-421d-bf59-cc418b572044';
        fieldTemplates[0].wrts_prcgvr__ObjectType__c= 'Case';
        insert fieldTemplates;

        List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = HDT_UTL_DataFactoryTst.createActivityTemplate(1,false);
        activityTemplates[0].Name = 'Contattare Cliente';
        activityTemplates[0].wrts_prcgvr__Code__c = '3ae1147a-6f0b-421d-bf59-cc418b572044';
        activityTemplates[0].wrts_prcgvr__FieldsTemplate__c= fieldTemplates[0].id;
        activityTemplates[0].wrts_prcgvr__ObjectType__c = 'Case';
        insert activityTemplates;

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
    public static void confirmTest() {
        ServicePoint__c servicePoint = HDT_UTL_DataFactoryTst.createServicePoint(1, true)[0];
        String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Segnalazioni').getRecordTypeId();
        Case caso = new Case(WithdrawalFee__c = false, ServicePoint__c = servicePoint.Id, Phase__c = 'Bozza', RecordTypeId = rtId);  
        Insert caso;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(caso.Id, yesterday);  
        
        Datetime startDate =  datetime.newInstance(2000, 1, 1);
        Datetime endDate =  datetime.newInstance(2000, 1, 1);
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Case theCase = [SELECT Id, CreatedDate, WithdrawalFee__c, ServicePoint__c FROM Case LIMIT 1];

        HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentConfirmResponse  appConfirm = new HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentConfirmResponse();
        appConfirm.status='';
        appConfirm.correlationId='';
        appConfirm.timestamp='';
        HDT_LC_AppointmentTariAgenda.HDT_WRP_Data_Confirm data = new HDT_LC_AppointmentTariAgenda.HDT_WRP_Data_Confirm();
        data.noticeNumber='';
        data.workCenterId='';
        data.division='';
        data.startDate='';
        data.endDate='';
        appConfirm.data = data;

        HDT_LC_AppointmentTariAgenda.HDT_WRP_DataApp wrap = new HDT_LC_AppointmentTariAgenda.HDT_WRP_DataApp('', '', '', '', '', '', '', '', startDate, endDate);

        HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentConfirmResponse res = HDT_LC_AppointmentTariAgenda.handleConfirm(theCase, wrap);
       
        System.assertEquals(200, res.statusCode, 'The call was not successful');
        System.assertNotEquals(400, res.statusCode, 'The returned status code was not correct');

        Test.stopTest();
    }

    @isTest
    public static void newActivityTest() {

        Case caso = new Case();
        insert caso;
        caso.Outcome__c='test';
        Test.startTest();
        String templateName= 'Contattare Cliente';
        HDT_LC_AppointmentTariAgenda.handleNewActivityCreationAndCaseUpdate(caso, true , 'Contattare Cliente');
        System.assertEquals(templateName, 'Contattare Cliente', 'test');
        Test.stopTest();
    }

    @isTest
    public static void viewTest() {

        Case caso = new Case();
        insert caso;
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentViewResponse  appView = new HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentViewResponse();
        appView.status='';
        appView.correlationId='';
        appView.timestamp='';
        HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentView data = new HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentView();
        data.stanoticeNumbertus='';
        data.appointmentType='';
        data.startDate='';
        data.endDate='';
        List<HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentView> app = new List<HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentView>();
        app.add(data);
        appView.data = app;

        HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentViewResponse res = HDT_LC_AppointmentTariAgenda.handleView(null);
        System.assertEquals(200, res.statusCode, 'The call was not successful');
        System.assertNotEquals(400, res.statusCode, 'The returned status code was not correct');
        Test.stopTest();
    }

    @isTest
    public static void searchTest() {

        Case caso = new Case();
        insert caso;
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentSearchResponse  appSearch = new HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentSearchResponse();
        appSearch.status='';
        appSearch.correlationId='';
        appSearch.timestamp='';
        HDT_LC_AppointmentTariAgenda.HDT_WRP_Data_Search data = new HDT_LC_AppointmentTariAgenda.HDT_WRP_Data_Search();
        data.outcome='';
        data.text='';
        List<HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentDate> appAgenda = new List<HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentDate>();
        HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentDate app = new HDT_LC_AppointmentTariAgenda.HDT_WRP_AppointmentDate();
        app.startDate='';
        app.endDate='';
        appAgenda.add(app);
        data.appointmentData = appAgenda;

        HDT_LC_AppointmentTariAgenda.HDT_WRP_DataApp wrap = new HDT_LC_AppointmentTariAgenda.HDT_WRP_DataApp('', '', '', '', '', '', '', '', null, null);

        HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentSearchResponse res = (HDT_LC_AppointmentTariAgenda.HDT_WS_AppointmentSearchResponse) HDT_LC_AppointmentTariAgenda.handleSearch(wrap);
        System.assertEquals(200, res.statusCode, 'The call was not successful');
        System.assertNotEquals(400, res.statusCode, 'The returned status code was not correct');
        Test.stopTest();
    }

    @isTest
    public static void initAppointmentTest() {

        Case caso = new Case();
        insert caso;

        Test.startTest();
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appuntamento =
        HDT_LC_AppointmentTariAgenda.initAppointmentRequestCase(caso.Id, HDT_LC_AppointmentTariAgenda.requestType.NEW_SLOT);

        System.assertEquals(appuntamento.desEsitoAttivita, 'test', 'test');
        Test.stopTest();
    }

    @isTest
    public static void getCaseTest() {

        Case caso = new Case();

        Test.startTest();
        List<Case> cases = new List<Case>();
        cases.add(caso);
        HDT_LC_AppointmentTariAgenda.updateCase(cases);

        List<String> fields = new List<String>();
        fields.add('Id');
        Case response = HDT_LC_AppointmentTariAgenda.getCase(caso.Id,fields);
        System.assertEquals(response!= null, true, 'OK');
        
        Test.stopTest();
    }

}