/*
 * @author Laureta Demishaj (laureta.demishaj@dunegroup.it)
 * @date 01/10/2021
 * @description HDT_LC_RecallMe for Test Classes
 * @history Laureta Demishaj – 01/10/2021 – Created class
*/
@isTest
public class HDT_LC_RecallMeTst {
private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    @TestSetup
    static void myData(){
        List<Account> accList       = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1, false);
        campaignList[0].Category__c = 'Campagna Outbound';
        campaignList[0].Channel__c  = 'Bolletta'; 
        insert campaignList;
        List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, false);
        leadList[0].CampaignSource__c  = campaignList[0].Id;
        leadList[0].SourceAgency__c    = 'Linetech';
        leadList[0].InterestProduct__c = 'Hera Bebè Gas';
        leadList[0].InterestArea__c    = 'Green';
        leadList[0].ContactReason__c   = 'Info commerciali';
        leadList[0].MobilePhone        = '0123456789';
        insert leadList;
        String sourceA = leadList[0].SourceAgency__c;
        String intProd = leadList[0].InterestProduct__c;
        String mobPh =  leadList[0].MobilePhone ; 
        List<CampaignMember> campaignListMember = HDT_UTL_DataFactoryTst.createCampaignMember(1, false, campaignList[0].Id,leadList[0].Id,null);
        campaignListMember[0].Ecid__c= '3456587334';
        insert campaignListMember;
        HDT_UTL_DataFactoryTst.createWebServiceCredential('MulesoftSalesforceUser', 'a74b50dbaac04215bfbf89a2ee315a80','48fe5165a40c49aa9bf4b3d9bca2552f');
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('postSlotRequest', 'https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/campaigns/slots/search', 'POST' , 'MulesoftSalesforceUser');
    	HDT_WebServiceConfiguration__c wsc = [SELECT Id, Mock__c FROM HDT_WebServiceConfiguration__c WHERE Name = 'postSlotRequest' LIMIT 1];
        wsc.Mock__c = true;
        update wsc;
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration ('postAppointment', 'https://test-ts.gruppohera.it/dev/salesforce-api-exp/api/campaigns/slots/search', 'POST' , 'MulesoftSalesforceUser');     
    }
    //the inner class in HDT_LC_RecallMe should have get and set in order to be covered by this method
    @isTest
    public static void wrapReturnTest(){
        Date startD = Date.today();
        Date endD   = startD.addDays(6);
        Test.startTest();
        HDT_LC_RecallMe.wrapReturn wrapRet = new HDT_LC_RecallMe.wrapReturn();
        wrapRet.availability = 5;
        wrapRet.endDate      = endD;
        wrapRet.startDate    = startD;
        Test.stopTest();
        System.assertEquals(true, wrapRet!=null, 'The wrapRet should not be null!');
        System.assertNotEquals(false, wrapRet!=null, 'The wrapRet should not be null!');
    }
    @isTest
    public static void postSlotRequestTst(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        List<CampaignMember> cmpList = [SELECT Id FROM CampaignMember];
        String startRange = String.valueOf(Date.today());
        System.debug(cmpList[0].Id);
        Test.startTest();
        List<HDT_LC_RecallMe.wrapReturn> response = HDT_LC_RecallMe.postSlotRequest(startRange, cmpList[0].Id);
        Test.stopTest();
        System.assertEquals(true, response != null, 'The response should not be null!');
        System.assertNotEquals(false, response != null, 'The response should not be null!');
    }
    @isTest
    public static void postSlotRequestEcidTst(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        List<CampaignMember> cmpList = [SELECT Id, Ecid__c FROM CampaignMember];
        String start = String.valueOf(Date.today());
        DateTime startRange = Datetime.valueOfGMT(start + ' 00:00:00');
        System.debug('User id longggg'+UserInfo.getUserId());
        Test.startTest();
        List<HDT_LC_RecallMe.wrapReturn> response = HDT_LC_RecallMe.postSlotRequestEcid(startRange, 1243576, '48fe5165a40c49aa9bf4b3d9bca2552f', cmpList[0].Ecid__c);
        Test.stopTest();
        System.assertEquals(true, response != null, 'The response should not be null!');
        System.assertNotEquals(false, response != null, 'The response should not be null!');
    }
    @isTest
    public static void postAppointmentTst(){
        List<CampaignMember> cmpList = [SELECT Id, Ecid__c FROM CampaignMember];
        Date dt = Date.today();
        Test.startTest();
        Boolean response = HDT_LC_RecallMe.postAppointment(dt, 'test as always', cmpList[0].Id);
         Test.stopTest();
        System.assertEquals(true, response, 'The response should be true!');
        System.assertNotEquals(false, response, 'The response should be true!');
    }
      @isTest
    public static void postAppointmentCatchTst(){
       Test.startTest();
       Boolean response = HDT_LC_RecallMe.postAppointment(null, null, null);
       Test.stopTest();     
       System.assertEquals(false, response, 'The response should be false!');
       System.assertNotEquals(true, response, 'The response should be false!');
    }
    @isTest
    public static void postAppointmentEcidTst(){
        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        List<CampaignMember> cmpList = [SELECT Id, Ecid__c FROM CampaignMember];
        Date dt = Date.today();
        String start = String.valueOf(Date.today());
        DateTime startRange = Datetime.valueOfGMT(start + ' 00:00:00');
        System.debug('User id longggg'+UserInfo.getUserId());
        Test.startTest();
        String response = HDT_LC_RecallMe.postAppointmentEcid(dt, 'test as always', 1243576, '48fe5165a40c49aa9bf4b3d9bca2552f', cmpList[0].Ecid__c, cmpList[0].Id);
        Test.stopTest();
        System.assertEquals(false, response!=null, 'The response should be null!');
        System.assertNotEquals(true, response!=null, 'The response should be null!');
}   
}