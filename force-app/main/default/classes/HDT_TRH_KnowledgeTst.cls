@isTest
public class HDT_TRH_KnowledgeTst {

    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();
    
    @TestSetup
    static void setup(){
        
        Knowledge__kav kArt = new Knowledge__kav(Title = 'Test Original Title', urlName = 'original');
        insert kArt;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Hera Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        u.UserPermissionsKnowledgeUser = true;
		insert u;

    }

    @IsTest
    static void testHandleUpdate(){

        Knowledge__kav kArt = [SELECT Id FROM Knowledge__kav LIMIT 1];
        
        User u=[SELECT Id FROM User WHERE Alias='standt' LIMIT 1];

        HDT_UTL_DataFactoryTst.assignPermissionSet(u, 'HDT_UtentiPubblicatoriKnowledge', true);

 
        System.runAs(u){

            Test.startTest();

            //Approval.lock(kArt.Id);
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
}
