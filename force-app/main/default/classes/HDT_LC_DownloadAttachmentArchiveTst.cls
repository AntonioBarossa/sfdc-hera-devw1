/**
 * Header of the class "HDT_LC_DownloadAttachmentArchiveTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_LC_DownloadAttachmentArchive"
 * @history
 * @Created 21/09/2021
 * Modified By:
 **/

@isTest
public class HDT_LC_DownloadAttachmentArchiveTst {

    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('Archive', 'callout:Archive/sbldownload/bolletta.pdf', 'GET', 'testUser');

    }

    @isTest
	static void testGetUrlNameDocumentLink(){

        HDT_WS_HTTPServiceCallMock mock = new HDT_WS_HTTPServiceCallMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<SiebelDocumentLink__x> docs = new List<SiebelDocumentLink__x>{new SiebelDocumentLink__x(NOME_FILE_DOWNLOAD__c = 'bolletta.pdf')};
        
        HDT_UTL_ObjectManagerTst.setMock(new HDT_UTL_MockInterfaceOverrideTst(docs));

        String msg;
        String targetId = 'test';

        Test.startTest();

        Map<String, String> result = new Map<String, String>();

        try{
        	result = HDT_LC_DownloadAttachmentArchive.getUrlNameDocumentLink(targetId);
        }catch(Exception e){
            msg = e.getMessage();
        }

        Test.stopTest();

        System.assertEquals('true', result.get('fileExist'), 'DownloadAttachmentAzure did not work correctly');
        System.assertNotEquals('false', result.get('fileExist'), 'DownloadAttachmentAzure did not work correctly');
        
    }
    
    @isTest static void testGetExtensionFile(){
        
        List<SiebelDocumentLink__x> docs = new List<SiebelDocumentLink__x>{new SiebelDocumentLink__x()};
        
        HDT_UTL_ObjectManagerTst.setMock(new HDT_UTL_MockInterfaceOverrideTst(docs));
        Test.startTest();

        Boolean b = HDT_LC_DownloadAttachmentArchive.getExtensionFile('0031X00000jNwOpQAK');
        
        Test.stopTest();

        System.assertEquals(true , b, 'GetExtensionFile did not work correctly');
        System.assertNotEquals(null, b, 'GetExtensionFile did not work correctly');
    }
    @isTest static void testGetExtensionFileEx(){
        
        String msg;

        Test.startTest();
        
        try{

        HDT_LC_DownloadAttachmentArchive.getExtensionFile('0031X00000jNwOpQAK');
            
        }catch(Exception e){
            msg = e.getMessage();
        }
        
        Test.stopTest();

        System.assertEquals('Script-thrown exception', msg, 'GetExtensionFile did not work correctly');
        System.assertNotEquals(null, msg, 'GetExtensionFile did not work correctly');
    }
}