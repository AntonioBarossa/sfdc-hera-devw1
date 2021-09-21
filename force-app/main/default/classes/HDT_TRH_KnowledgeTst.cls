@isTest
public class HDT_TRH_KnowledgeTst {
    
    @TestSetup
    static void setup(){
        
        Knowledge__kav kArt = new Knowledge__kav(Title = 'Test Original Title', urlName = 'original');
        insert kArt;

    }

    @IsTest
    static void testHandleUpdate(){
        
        Knowledge__kav kArt = [SELECT Id FROM Knowledge__kav LIMIT 1];

        Test.startTest();

        Approval.lock(kArt.Id);
        kArt.ValidationStatus = 'Validato Da Pubblicatore';
        kArt.RecordTypeId = Schema.SobjectType.Knowledge__kav.getRecordTypeInfosByName().get('News').getRecordTypeId();
        kArt.ToPublishDate__c = Datetime.now()+5;
        update kArt;

        Knowledge__kav kArtAfterUpdate = [SELECT Id, ValidationStatus, RecordTypeId, ToPublishDate__c FROM Knowledge__kav LIMIT 1];

        System.assertEquals('Validato Da Pubblicatore', kArtAfterUpdate.ValidationStatus, 'ValidationStatus is different: ' + kArtAfterUpdate.ValidationStatus);
        System.assertEquals(Schema.SobjectType.Knowledge__kav.getRecordTypeInfosByName().get('News').getRecordTypeId(), kArtAfterUpdate.RecordTypeId, 'RecordType is different');
        System.assert(kArtAfterUpdate.ToPublishDate__c != null, 'ToPublishDate__c is null');

        Test.stopTest();
        
    }
}
