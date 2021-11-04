/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 01/09/2021
* @description HDT_BA_LeadExpired for Test Classes
* @history Elfrida Kora – 01/09/2021 – Created class
*/


@IsTest
public class HDT_BA_LeadExpiredTest {
    @TestSetup
    static void createLead() 
    {
        
        HDT_UTL_DataFactoryTst.createLead(1, true);

            
        }
    
     @isTest
    public static void testConsentLead(){
         Test.startTest();
        HDT_BA_LeadExpired le = new HDT_BA_LeadExpired();
        Database.executeBatch(le);


          List<Lead> myLeads = [SELECT Id, FirstName,LastName,CompanyOwner__c,Company,Status,Birthdate__c,Gender__c from Lead];

           system.debug(myLeads);
           system.assertEquals('New', myLeads[0].Status,'We have a new Status');
           System.assertNotEquals('Expired', myLeads[0].Status,'We have expired Status');
                Test.stopTest();
        
    }
}