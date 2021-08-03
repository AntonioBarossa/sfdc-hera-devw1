/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 02/08/2021
 * @description HDT_QR_ContentDocumentLink Test Class
 * @history Lucas da Silva Fernandes – 02/08/2021 – Created City Object
 */

@isTest
public with sharing class HDT_QR_ContentDocumentLinkTst {
    
    @TestSetup
    static void setup(){

        List<Opportunity> oppList = HDT_UTL_DataFactoryTst.createOpportunity(1, true);

        List<ContentVersion> contentVersion = HDT_UTL_DataFactoryTst.createContentVers(1, true);

        ContentDocumentLink contentDocLink = new ContentDocumentLink();

        contentDocLink.LinkedEntityId = oppList[0].Id;
        contentDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion[0].Id].ContentDocumentId;
        contentDocLink.ShareType = 'V';

        System.debug('Content Document ID: '+[SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion[0].Id]);

        insert contentDocLink;

    }

    @isTest
    public static void testGetRecordsByEntity() {

        Test.startTest();

        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();

        Opportunity opp = [SELECT id FROM Opportunity WHERE Name = 'testOpportunity0' LIMIT 1];

        HDT_QR_ContentDocumentLink qCdl = new HDT_QR_ContentDocumentLink();

        cdl = qCdl.getRecordsByEntity(opp.Id);

        System.assertEquals('V', cdl[0].ShareType);

        System.assertNotEquals(cdl[0].ShareType, null);

        Test.stopTest();
    }
}
