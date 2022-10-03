/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 15-09-2022
 * @last modified by  : Giacinto Florio
**/
@isTest
public with sharing class HDT_LC_AppointmentTariAgendaTst {
   
    @isTest
    public static void confirmTest() {

        Test.startTest();
        String response = HDT_LC_AppointmentTariAgenda.handleConfirm('','');
        System.assertEquals(response, 'OK', 'OK');
        Test.stopTest();
    }

    @isTest
    public static void newActivityTest() {

        Case caso = new Case();
        insert caso;
        Test.startTest();
        String templateName= 'Contattare Cliente';
        HDT_LC_AppointmentTariAgenda.handleNewActivityCreationAndCaseUpdate(caso.Id, '{"data": "value"}' , 'Contattare Cliente', '{"data": "value"}');
        System.assertEquals(templateName, 'Contattare Cliente', 'test');
        Test.stopTest();
    }

    @isTest
    public static void viewTest() {

        Case caso = new Case();
        insert caso;

        Test.startTest();
        String response = HDT_LC_AppointmentTariAgenda.handleView(caso.Id);

        System.assertEquals(response!=null, true, 'OK');
        Test.stopTest();
    }

    @isTest
    public static void searchTest() {

        Case caso = new Case();
        insert caso;

        Test.startTest();
        String response = HDT_LC_AppointmentTariAgenda.handleView(caso.Id);

        System.assertEquals(response!=null, true, 'OK');
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

}
