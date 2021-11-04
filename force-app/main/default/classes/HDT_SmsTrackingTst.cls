/**
 * Header of the class "HDT_SmsTrackingTs"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative trigger "HDT_SmsTracking"
 * @history
 * @Created 12/10/2021
 * Modified By:
 **/

@isTest
public class HDT_SmsTrackingTst {
    
    @isTest static void test(){
        
        Test.startTest();
        
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
        List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accs[0].id);
        contacts[0].Company__c='MMS';
        insert contacts;

        HDT_UTL_DataFactoryTst.createSmsTracking(1, true, contacts[0].id);
        
        List<SMSTracking__c> query = [Select id from SMSTracking__c];

        System.assertEquals(1, query.size(), 'SMSTracking not inserted correctly');

        System.assertNotEquals(null, query, 'SMSTracking not inserted correctly');

        Test.stopTest();
        
    }

}