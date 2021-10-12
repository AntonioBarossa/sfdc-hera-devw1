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


}
