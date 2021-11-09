/**
 * Header of the class "HDT_BA_AttributesLeadTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_AttributesLead"
 * @history
 * @Created 06/10/2021
 * Modified By:
 **/

@isTest
public class HDT_BA_AttributesLeadTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser){        
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            
            Integer i=0;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts){
                c.Email = 'test@test.com0';
                c.Company__c='MMS';
            }
            insert contacts;
            
            i=0;
            List<BillingProfile__c> billings = HDT_UTL_DataFactoryTst.createBillingProfile(2,false,accId);
            for(BillingProfile__c b : billings){
                b.BillSendingMethod__c = 'Cartaceo';
                b.PaymentMethod__c = 'RID';
                b.Status__c = 'Attivo';
                b.Contact__c=contacts[i].id;
                i++;
            }
            insert billings;
            
            i=0;
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrder(2,false,accId,'Bozza');
            for(Order o : orders){
                o.Email__c = contacts[i].Email;
                o.Contact__c=contacts[i].id;
                i++;
            }
            insert orders;
            
            List<Lead> leadsDuplicate = HDT_UTL_DataFactoryTst.createLead(2,false);
            for(Lead l : leadsDuplicate){
                l.FirstName = 'test 0';
                l.IsConverted = false;
            }           
            insert leadsDuplicate;
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(2,false);
            leads[1].Email = leads[0].Email;
            for(Lead l : leads){
                l.IsConverted = false;
                l.Rating = 'Hot';
            }            
            insert leads;
            
            i=0;
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(2,false,accId);
            for(Contract c : contracts){
                c.Contact__c = contacts[i].id;
                c.Status = 'Attivo';
                c.EstimatedEndDate__c = System.today()+30;
                i++;
            }
            insert contracts;
            
            i=0;
            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(2,false,accId,contacts[0].id,points[0].id,contracts[0].id,orders[0].id);
            for(Case c : cases){
                c.Lead__c = leads[i].id;
                c.ContactId = contacts[i].id;
                c.EnergyService__c = 'Si';
                c.Market__c = 'Libero';
                c.Outcome__c = 'test';
                c.Reason = 'Existing problem';
                c.SalesCompany__c = 'test';
                c.SupplyType__c = 'Domestico';
                i++;
            }
            insert cases;
            
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
                
        }
    }
    
    @isTest
    static void test(){
        String paramRunId = 'someid';
        
        Test.startTest();
        
        HDT_BA_AttributesLead al = new HDT_BA_AttributesLead(paramRunId);
        Database.executeBatch(al,200);
        
        Test.stopTest();
        
        List<ContentVersion> cvs = [Select id From ContentVersion];
        
        System.assertNotEquals(null, cvs, 'ContentVersions not created');
        
        System.assertEquals(2, cvs.size(), 'AttributesLead did not work correctly');
            
    }
    
    @isTest
    static void testContacts(){
                
        List<Contact> contacts = [Select id, Email from contact];
        integer i = 0;
        for(Contact c : contacts){
            c.Email = c.Email + i;
            i++;
        }
        update contacts;
        
        String paramRunId = 'someid';
        
        Test.startTest();
        
        HDT_BA_AttributesLead al = new HDT_BA_AttributesLead(paramRunId);
        Database.executeBatch(al,200);
        
        Test.stopTest();
        
        List<ContentVersion> cvs = [Select id From ContentVersion];
        
        System.assertNotEquals(0, cvs.size(), 'ContentVersions not created');
        
        System.assertEquals(null, al.errormessage, 'AttributesLead did not work correctly');
            
    }
}