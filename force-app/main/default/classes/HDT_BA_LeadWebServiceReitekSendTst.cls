/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 23/09/2021
* @description HDT_BA_LeadWebServiceReitekSend for Test Classes
* @history Elfrida Kora – 23/09/2021 – Created class
*/

@IsTest
public class HDT_BA_LeadWebServiceReitekSendTst {
    
     @TestSetup
    static void allData() 
    {
        
         HDT_UTL_DataFactoryTst.createWebServiceConfiguration('InvioNumerazioni', 'end', 'method', 'testUser');
         List<Account> acctList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        Id accId = acctList[0].Id;
        List<Contact> conList = HDT_UTL_DataFactoryTst.createContact(1,true,acctList[0].Id);
        Id conId = conList[0].Id;
          List<Lead> leadList = HDT_UTL_DataFactoryTst.createLead(1, false);
        leadList[0].ContactDate__c = system.now().addHours(-2);
        leadList[0].isSendToReitek__c = false;
        insert leadList;
        Id leadId = leadList[0].Id;
        
         List<Campaign> campaignList = HDT_UTL_DataFactoryTst.createCampaign(1,false);
        campaignList[0].Name = 'LEAD CALLBACK';
        insert campaignList;
          Id campaignId = campaignList[0].Id;
       
         List<CampaignMember> campaignMembers = HDT_UTL_DataFactoryTst.createCampaignMember(1, true,campaignId,leadId,conId);
               
        
        }
    
     @isTest
    public static void testOne(){
        Test.startTest();
                List<Campaign> myCampaign = [SELECT Id, Name,Channel__c from Campaign];
                System.debug('myCampaign' +myCampaign);


         HDT_BA_LeadWebServiceReitekSend le = new HDT_BA_LeadWebServiceReitekSend();
        Id batchId = Database.executeBatch(le);
        Test.stopTest();
          List<CampaignMember> myCampaignMemb = [SELECT Id, leadId,contactId from CampaignMember];

        List<Lead> myLeads = [SELECT Id, FirstName,LastName,CompanyOwner__c,Company,Status,isSendToReitek__c,MobilePhone from Lead WHERE Id = :myCampaignMemb[0].leadId];
                    System.debug('myLeads###' +myLeads);

           System.assertEquals(true, myLeads[0].isSendToReitek__c,'This field has been updated');
           

        
    }

}