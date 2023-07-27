@isTest
public with sharing class HDT_WS_AlignSapOfferCodeTableTst {
    @TestSetup
    static void makeData(){
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('AllignSapOfferCode', 'Callout:MulesoftBasePath', 'method', 'testUser');
    }

    @isTest
    static void doCalloutTest(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableRequest req = new HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableRequest();
        HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData item = new HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData();
        List<HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData> listOfData = new List<HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableData>();
        item.Id = 'Test';
        item.offerCode32 = 'Test';
        item.offerProductCode = 'Test';
        item.offerProductVersion = 'Test';
        item.codT0 ='Test';
        item.effectiveMonths = 'Test';
        item.driver1 = 'Test';
        item.driver2 = 'Test';
        item.driver3 = 'Test';
        item.commodity = 'Test';
        item.company = 'Test';
        listOfData.add(item);
        req.data = listOfData;
        Test.startTest();
        HDT_WRP_AlignSapOfferCodeTable.HDT_WRP_AlignSapOfferCodeTableResponse response = HDT_WS_AlignSapOfferCodeTable.doCallout(req);
        Test.stopTest();
        System.assertEquals(false, response.data.isEmpty());
    }
}