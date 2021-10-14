/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 22/09/2021
* @description HDT_BA_AccountBpCaCallout for Test Classes
* @history Elfrida Kora – 22/09/2021 – Created class
*/



@IsTest
public class HDT_BA_AccountBpCaCalloutTst {
    
     @TestSetup
    static void allData() 
    {
        HDT_UTL_DataFactoryTst.createWebServiceConfiguration('BP_CA', 'end', 'method', 'testUser');
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id); 
            
        }
    
     @isTest
    public static void testConsentAccount(){
        Test.startTest();
         List<Account> myAcc = [SELECT Id,Name,CompanyOwner__c,CustomerMarking__c,Category__C,VATNumber__c,BillingCityCode__c FROM Account];
       HDT_BA_AccountBpCaCallout acc = new HDT_BA_AccountBpCaCallout();
        acc.dtos = myAcc;
        Id batchId = Database.executeBatch(acc);
          List<Account> myAcct = [SELECT Id,Name,CompanyOwner__c,Code__c,CustomerMarking__c,Category__C,VATNumber__c,BillingCityCode__c FROM Account];
        
        System.assertNotEquals('', myAcct[0].Code__c,'This field has been updated');
        
           Test.stopTest();
        
             
        
    }

}