/**
 * Header of the class "HDT_WS_PaperCampaignGetFileTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_WS_PaperCampaignGetFile"
 * @history
 * @Created 30/09/2021
 * Modified By:
 **/

@isTest
public class HDT_WS_PaperCampaignGetFileTst {

    @isTest
    static void test1(){
        
        Test.startTest();
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('paperGetId','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        HDT_WS_PaperCampaignGetFile.wrapResponseGetId res = HDT_WS_PaperCampaignGetFile.callServiceGetIdByName('filename');    
        
        Test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was not created');
        
        System.assertEquals(null, res.body, 'The respose fields should be set to null since the mock is not instantiated');
        
    }
    
    @isTest
    static void test2(){
        
        Test.startTest();
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('paperGetFile','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
        
        HDT_WS_PaperCampaignGetFile.wrapResponseGetFile res = HDT_WS_PaperCampaignGetFile.callServiceGetFileById('documentid');    
        
        Test.stopTest();
        
        System.assertNotEquals(null, res, 'A response was not created');
        
        System.assertEquals(null, res.body, 'The respose fields should be set to null since the mock is not instantiated');
        
    }
    
    @isTest
    static void test3(){
        
        Test.startTest();
        
        HDT_WS_PaperCampaignGetFile.wrapResponseGetFile resFile = new HDT_WS_PaperCampaignGetFile.wrapResponseGetFile();
        HDT_WS_PaperCampaignGetFile.wrapObjectGetFile obFile = new HDT_WS_PaperCampaignGetFile.wrapObjectGetFile();
        obFile.fileBase64 = 'test64';
        resFile.data = obFile;
        
        HDT_WS_PaperCampaignGetFile.wrapResponseGetId resId = new HDT_WS_PaperCampaignGetFile.wrapResponseGetId();
        HDT_WS_PaperCampaignGetFile.wrapObjectGetId obId = new HDT_WS_PaperCampaignGetFile.wrapObjectGetId();
        obId.id = 'testid';
        obId.filename = 'testfilename';
        obId.type = 'testtype';
        resId.data = obId;
        
        Test.stopTest();
        
        System.assertNotEquals(null, resFile, 'A response was not created');
        
        System.assertEquals('test64', resFile.data.fileBase64, 'Value of the field fileBase64 not successfully set');
        
        System.assertNotEquals(null, resId, 'A response was not created');
        
        System.assertEquals('testtype', resId.data.type, 'Value of the field Type not successfully set');
        
    }
}