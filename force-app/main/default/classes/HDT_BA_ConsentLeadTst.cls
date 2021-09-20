/**
 * Header of the class "HDT_BA_ConsentLeadTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class ""HDT_BA_ConsentLead"
 * @history
 * @Created 2021-09-16
 * Modified By:
 **/

@isTest
public class HDT_BA_ConsentLeadTst {
    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();
	@TestSetup
    static void makedata(){
        
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
		User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
		internalUser.UserPermissionsMarketingUser=true;

		insert internalUser;

        System.runAs(internalUser){

            List<Individual> inds = HDT_UTL_DataFactoryTst.createIndividual(2,true);
    
            Integer j=0;
            for(Individual i : inds){
                i.PrivacyProfilingChoiceDate__c=System.today()+j;
                i.ProfilingPrivacy__c='SI';
                j++;
            }
            update inds;
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1,true);  
            Integer i=0;
            for(Lead l : leads){
                l.FirstName='FirstNameTest' + i;
                l.LastName='LastNameTest' + i;
                l.Email='email@'+3+'.it';
                l.IndividualId=inds[1].id;
                i++;
            }
            update leads;
        
            List<Lead> leads2 = HDT_UTL_DataFactoryTst.createLead(50,true);        
            i=0;
            for(Lead l : leads2){
                l.FirstName='FirstNameTest2' + i;
                l.LastName='LastNameTest2' + i;
                l.IndividualId=inds[0].id;
                i++;
            }
            update leads2;
    
            List<Lead> leads3 = HDT_UTL_DataFactoryTst.createLead(50,true);
            i=0;
            for(Lead l : leads3){
                l.FirstName='FirstNameTest3' + i;
                l.LastName='LastNameTest3' + i;
                l.Email='indirizzo@'+i+'.it';
                l.IndividualId=inds[1].id;
                i++;
            }
            update leads3;
        
            List<Lead> leads4 = HDT_UTL_DataFactoryTst.createLead(10,true);        
            i=0;
            for(Lead l : leads4){
                l.FirstName='FirstNameTest4' + i;
                l.LastName='LastNameTest4' + i;
                l.IndividualId=inds[1].id;
                i++;
            }
            update leads4;
            
        
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(50,false,accId);
           
            i=0;
            for(Contact c : contacts){
                c.FirstName='test'+i;
                c.LastName='tester'+i;
                c.Email='email@'+i+'.it';
                c.IndividualId=inds[0].Id;
                c.Company__c='MMS';
                i++;
            }
            insert contacts;
            List<Contact> contacts2 = HDT_UTL_DataFactoryTst.createContact(50,false,accId);

            i=0;
            for(Contact c: contacts2){
                c.FirstName='test2'+i;
                c.LastName='tester2'+i;
                c.Email='email@'+i+'.it';
                c.IndividualId=inds[0].id;
                c.Company__c='MMS';
                i++;
            }    
            insert contacts2;
        
        
            HDT_UTL_DataFactoryTst.createWebServiceConfiguration('CampagenDmDmpData','https://integration-ts.gruppohera.it/dev/salesforce-api-exp/api/data-management/files','POST','MulesoftSalesforceUser');
            
        }
	}
    
    @isTest
    static void test1(){         
        
        String paramRunId = 'someid';
        
        Set<String> setEmailContactProcessed = new Set<String>();
        setEmailContactProcessed.add('email@0.it');
        
        Test.startTest();
        HDT_BA_ConsentLead cl = new HDT_BA_ConsentLead(paramRunId);
        cl.setEmailContactProcessed=setEmailContactProcessed;
        Id batchId = Database.executeBatch(cl,200);
        Test.stopTest();

        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'ConsentLead did not execute correctly');
        
    }
    @isTest
    static void test2(){         
        
        String paramRunId = 'someid';
        
        Test.startTest();
        HDT_BA_ConsentLead cl = new HDT_BA_ConsentLead(paramRunId);
        Id batchId = Database.executeBatch(cl,200);
        Test.stopTest();

        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'ConsentLead did not execute correctly');
        
    }
    @isTest
    static void test3(){
        String paramRunId = '123456789';
        
        Set<String> setEmailContactProcessed = new Set<String>();
        setEmailContactProcessed.add('email@0.it');
        
        Test.startTest();
        HDT_BA_ConsentLead cl = new HDT_BA_ConsentLead(paramRunId);
        Id batchId = Database.executeBatch(cl,200);
        Test.stopTest();

        List <ContentVersion> lista = [Select id from ContentVersion where Title LIKE 'heradmp_firstpartydata_%'];
        System.assertEquals(false, lista.isEmpty(),'ConsentLead did not execute correctly');
    }
}