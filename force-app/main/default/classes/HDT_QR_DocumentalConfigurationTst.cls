@IsTest
public with sharing class HDT_QR_DocumentalConfigurationTst {

    @IsTest
    public static void executeGetRecordFromServiceItems(){
        Test.startTest();
            System.assertEquals(0, HDT_QR_DocumentalConfiguration.getRecordFromServiceItems('Order', new Set<String>()).size(),'getRecordFromServiceItems doesn\'t work');
            System.assertEquals(0, HDT_QR_DocumentalConfiguration.getRecordFromServiceItems('Order', new Set<String>{'TEST'}).size(),'getRecordFromServiceItems doesn\'t work');
            System.assertEquals(0, HDT_QR_DocumentalConfiguration.getRecordFromServiceItems('Case', new Set<String>{'TEST'}).size(),'getRecordFromServiceItems doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    public static void executeGetDocumentByContext(){
        Test.startTest();
            System.assertEquals(0, HDT_QR_DocumentalConfiguration.getDocumentByContext('Order').size(),'getDocumentByContext doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    public static void executeGetDocumentalPayloadAdministration(){
        Test.startTest();
            System.assertEquals(0, HDT_QR_DocumentalConfiguration.getDocumentalPayloadAdministration(new List<DocumentalPayloadAdministration__c>()).size(),'getDocumentalPayloadAdministration doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    public static void executeGetSignModeSettings(){
        Test.startTest();
            System.assertEquals(8, HDT_QR_DocumentalConfiguration.getSignModeSettings('','').size(),'getSignModeSettings doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    public static void executeGetDocumentalActivityById(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getDocumentalActivityById('recordId'),'getDocumentalActivityById doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    public static void executeGetDocumentSendTrackingById(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getDocumentSendTrackingById('recordId'),'getDocumentSendTrackingById doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    public static void executeGetDocumentalObjectById(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getDocumentalObjectById('8013O000003FBD9QAO'),'getDocumentalObjectById doesn\'t work');
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getDocumentalObjectById('5007Y00000Og1h4QAB'),'getDocumentalObjectById doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    public static void executeGetDocumentSendTracking(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getDocumentSendTracking('transictionId') ,'getDocumentSendTracking doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    public static void executeGetParentOrder(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getParentOrder('8013O000003FBD9QAO'),'getParentOrder doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    public static void executeGetOrderPriceBook(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getOrderPriceBook('8013O000003FBD9QAO'),'getOrderPriceBook doesn\'t work');
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    public static void executeGetEnvelopeToCancel(){
        Test.startTest();
            System.assertEquals(null, HDT_QR_DocumentalConfiguration.getEnvelopeToCancel('8013O000003FBD9QAO','Documental System', 'Send mode'),'getEnvelopeToCancel doesn\'t work');
        Test.stopTest();
    }
}