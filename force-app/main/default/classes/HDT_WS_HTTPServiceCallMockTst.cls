@isTest
public with sharing class HDT_WS_HTTPServiceCallMockTst {

    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('TransitorioWinback', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('VAS.Service26', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('BP_CA', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('CampagenDmDmpData', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('postSlotRequest', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('postAppointment', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('ArrichDataEntity', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('AppointmentSearch', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('AppointmentView', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('AppointmentConfirm', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('MulesoftHergoPath', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('MulesoftHergoNotice', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('Archive', 'endpoint', 'POST', 'endUser');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('AllignSapOfferCode', 'endpoint', 'POST', 'endUser');
    }

    @isTest
    static void executeMock(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        mock.successfullReturn = true;
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HTTPRequest req = new HTTPRequest();
        HDT_WS_Response responseTransitorioWinback = HDT_WS_HTTPServiceCall.sendRequest('TransitorioWinback',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseVASService26 = HDT_WS_HTTPServiceCall.sendRequest('VAS.Service26',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseBP_CA = HDT_WS_HTTPServiceCall.sendRequest('BP_CA',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseCampagenDmDmpData = HDT_WS_HTTPServiceCall.sendRequest('CampagenDmDmpData',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responsepostSlotRequest = HDT_WS_HTTPServiceCall.sendRequest('postSlotRequest',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responsepostAppointment = HDT_WS_HTTPServiceCall.sendRequest('postAppointment',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseArrichDataEntity = HDT_WS_HTTPServiceCall.sendRequest('ArrichDataEntity',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseAppointmentSearch = HDT_WS_HTTPServiceCall.sendRequest('AppointmentSearch',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseAppointmentView = HDT_WS_HTTPServiceCall.sendRequest('AppointmentView',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseAppointmentConfirm = HDT_WS_HTTPServiceCall.sendRequest('AppointmentConfirm',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseMulesoftHergoPath = HDT_WS_HTTPServiceCall.sendRequest('MulesoftHergoPath',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseMulesoftHergoNotice = HDT_WS_HTTPServiceCall.sendRequest('MulesoftHergoNotice',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseArchive = HDT_WS_HTTPServiceCall.sendRequest('Archive',new HDT_WS_Request (), HDT_WS_Response.class);
        HDT_WS_Response responseAllignSapOfferCode = HDT_WS_HTTPServiceCall.sendRequest('AllignSapOfferCode',new HDT_WS_Request (), HDT_WS_Response.class);
        Test.stopTest();
    }
}