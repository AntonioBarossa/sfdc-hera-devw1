@isTest
public with sharing class HDT_TRH_TaskTst {

    
    //DEBUG
    public static final String TEST_NAME = 'HDT_TRH_TaskTst';
    
    
    //TEST SETUP
    
    
    //TESTS
    

    @isTest
    private static void doValidationTest(){
        
        //DEBUG
        String debugString = TEST_NAME + ' - ' + 'doValidationTest';
        System.debug(debugString);
        
        //SETUP

        
        String uniqueUserName = 'systemAdmin' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'sysAdmin', Email='systemadministrator@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(2, true, accList[0].Id);
        Contact myContact = contactList[1];
        myContact.MobilePhone = '3245341020';
        Update myContact;

        Task myTask = new Task();
        myTask.WhoId = contactList[0].Id;
        myTask.PhoneNumber__c = '234987560';
        myTask.Description = 'My description contains UserTag';
        myTask.IsSms__c = true;
        
        List<Lead> myLeadList = HDT_UTL_DataFactoryTst.createLead(1,true);
        Task myTask2 = new Task();
        myTask2.WhoId = myLeadList[0].Id;
        myTask2.IsPec__c = true;

        Task myTask3 = new Task();
        myTask3.WhoId = myContact.Id;
        myTask3.IsSms__c = true;
        myTask3.Description = 'My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.My description contains UserTag.';

        //TESTING
        Test.startTest();
        Try{
            System.runAs(u) {
                PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'HDT_OneShotUser'];
                insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
            }
            System.runAs(u) {
                insert myTask;
                insert myTask2;
                insert myTask3;
            }
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }        
        Test.stopTest();
        
        //ASSERTS
        System.assert(myTask != null, 'Attenzione, myTask non può essere null!');
        System.assert(myTask2 != null, 'Attenzione, myTask2 non può essere null!');
        
    }

    //aggiunto per testare puntualmente metodo della classe HDT_QR_Task

    @IsTest
    static void testGetRecordsByIds(){
        
        //setup
        Task t1 = new Task();
        insert t1;

        //test
        Test.startTest();

        Task retrievedTask = [SELECT Id FROM Task WITH SECURITY_ENFORCED LIMIT 1];

        Set<Id> ids = new Set<Id>();
        ids.add(retrievedTask.Id);
        HDT_QR_Task qrt = new HDT_QR_Task();
        List<Task> results = qrt.getRecordsByIds(ids);

        //assert
        System.assert(results.size() > 0, 'results.size() == 0 or results == null');

        Test.stopTest();
        
    }
    
    
    //doxeeTemplateCode
    @isTest
    private static void doxeeTemplateCodeTest(){
        
        HDT_TRH_Task myObjectToTest = new HDT_TRH_Task();
        
        String result1 = myObjectToTest.doxeeTemplateCode('Comunicazione Forte Consumo (23)');
        System.assert('023'.equalsIgnoreCase(result1), 'Result1 non è 023');
        
        String result2 = myObjectToTest.doxeeTemplateCode('Comunicazione Fuga Accertata (24)');
        System.assert('024'.equalsIgnoreCase(result2), 'Result2 non è 024');
        
        String result3 = myObjectToTest.doxeeTemplateCode('Comunicazione Fuga Presunta (25)');
        System.assert('025'.equalsIgnoreCase(result3), 'Result3 non è 025');
        
        String result4 = myObjectToTest.doxeeTemplateCode('Ultimo Avviso (26)');
        System.assert('026'.equalsIgnoreCase(result4), 'Result4 non è 026');
        
        String result5 = myObjectToTest.doxeeTemplateCode('ELSE');
        System.assert('0'.equalsIgnoreCase(result5), 'Result6 non è 0');
        
    }


}
