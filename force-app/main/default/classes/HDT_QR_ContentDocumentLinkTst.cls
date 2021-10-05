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

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion[0].Id].ContentDocumentId;

        Database.update(new ContentDocument(Id = contentDocumentId, Description = 'testClassDescription'));

        HDT_UTL_DataFactoryTst.createContentDocumentLink(1, true, oppList[0].Id, contentDocumentId);
        
    }

    @isTest
    public static void testGetRecordsByEntity() {

        Test.startTest();

        Opportunity opp = [SELECT id FROM Opportunity WHERE Name = 'testOpportunity0' LIMIT 1];

        HDT_QR_ContentDocumentLink qCdl = new HDT_QR_ContentDocumentLink();

        List<ContentDocumentLink> cdl = qCdl.getRecordsByEntity(opp.Id);

        System.assertEquals(opp.Id, cdl[0].LinkedEntityId, 'The Content Document Link was not retrieve correctly');

        System.assertNotEquals(cdl[0].ShareType, null, 'The Share Type of the Content Document Link was not correct');

        Test.stopTest();
    }

    @IsTest
    public static void testGetRecordsByEntityAndContentDocumentDescription(){
        
        Test.startTest();

        Opportunity opp = [SELECT id FROM Opportunity WHERE Name = 'testOpportunity0' LIMIT 1];

        HDT_QR_ContentDocumentLink qCdl = new HDT_QR_ContentDocumentLink();

        List<ContentDocumentLink> cdl = qCdl.getRecordsByEntityAndContentDocumentDescription(opp.Id, 'testClassDescription');

        System.assertEquals(opp.Id, cdl[0].LinkedEntityId, 'The Content Document Link was not retrieve correctly');

        System.assertNotEquals(cdl[0].ShareType, null, 'The Share Type of the Content Document Link was not correct');
        
        Test.stopTest();
        
    }
}
