@isTest
public with sharing class HDT_QR_ContentDocumentTst {
    @isTest
    public static void myTest() {
        Test.startTest();
        HDT_QR_ContentDocument testQr = new HDT_QR_ContentDocument ();
        List<ContentDocument> returnedValue = testQr.getRecordsByTitle('test');
      
        System.assertEquals(0, returnedValue.size(), 0);
      

        Test.stopTest();
    }
}
