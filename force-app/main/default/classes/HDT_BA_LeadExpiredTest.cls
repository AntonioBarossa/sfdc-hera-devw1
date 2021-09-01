@IsTest
public class HDT_BA_LeadExpiredTest {
    @TestSetup
    static void makeData() 
    {
        List<Lead> lstLead= new List<Lead>();
        for(Integer i=0 ;i <10;i++)
        {
            Lead lead = new Lead();
            lead.LastName ='Name'+i;
            lead.CustomerMarking__c='Persona fisica';
            lead.Category__c='Famiglie';
            lead.FirstName ='Frida';
            lead.FiscalCode__c='SMTLVR75C02H501Y';
            lead.CompanyOwner__c='HERA COMM';
            lead.Email='justtest2@gmail.com';
            lead.Company='istest';
            lstLead.add(lead);
        }
        
        insert lstLead;
        
        
    }
    
     @isTest
    public static void testConsentLead(){
        Test.StartTest();
         HDT_BA_LeadExpired obj =new HDT_BA_LeadExpired(); 
        Id batchprocessid = Database.executeBatch(obj);
        Test.StopTest();
        
               
        
    }
}