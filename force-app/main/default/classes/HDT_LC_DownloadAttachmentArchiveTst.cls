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

  @isTest
	static void testGetUrlNameDocumentLink(){
        String msg;
        String targetId = 'test';
        try{
        	HDT_LC_DownloadAttachmentArchive.getUrlNameDocumentLink(targetId);
        }catch(Exception e){
            msg = e.getMessage();
        }
        System.assertEquals('Script-thrown exception', msg, 'DownloadAttachmentAzure did not work correctly');
        System.assertNotEquals('', msg, 'DownloadAttachmentAzure did not work correctly');
        
    }
    
    @isTest static void testGetExtensionFile(){
        
        List<SiebelDocumentLink__x> docs = new List<SiebelDocumentLink__x>();
        SiebelDocumentLink__x doc = new SiebelDocumentLink__x();
        docs.add(doc);
        
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